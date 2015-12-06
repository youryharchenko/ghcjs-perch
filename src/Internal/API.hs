module Internal.API where

import           Internal.FFI
import           Internal.Type

import           Data.JSString          (pack)
import           Data.JSString.Text     (textToJSString)
import           Data.Text              (Text)
import           GHCJS.Foreign.Callback (asyncCallback1, releaseCallback)
import           GHCJS.Marshal          (FromJSVal (..))
import           GHCJS.Types            (JSVal)
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
getDocument :: IO Elem
getDocument = js_document

getBody :: IO Elem
getBody = js_documentBody

newElem :: String -> IO Elem
newElem = js_documentCreateNode . pack

newTextElem :: Text -> IO Elem
newTextElem = js_createTextNode . textToJSString


parent :: Elem -> IO Elem
parent = js_parentNode

-- | Appends one element to another.
addChild :: Elem -- ^ child element to append
         -> Elem -- ^ parent element
         -> IO ()
addChild = flip js_appendChild

-- | Remove child from parent.
removeChild :: Elem -- ^ child to remove
            -> Elem -- ^ parent node
            -> IO ()
removeChild = flip js_removeChild

clearChildren :: Elem -> IO ()
clearChildren = js_clearChildren

replace :: Elem -> Elem -> IO Elem
replace o n =
  do par <- parent o
     js_replaceChild par o n
     return n

setAttr :: Elem -> PropId -> Text -> IO ()
setAttr e p = js_setAttribute e p . textToJSString

inner :: Elem -> Text -> IO ()
inner e = js_innerHtml e . textToJSString


queryAll :: Text -> IO [Elem]
queryAll query =
  do res <- js_querySelectorAll (textToJSString query)
     fromJSValUncheckedListOf res

onEvent :: NamedEvent a => Elem -> a -> (JSVal -> IO()) -> IO (IO ())
onEvent el et hnd = do
  callback <- asyncCallback1 hnd
  js_addEventListener el (pack (eventName et)) callback
  return (releaseCallback callback)
--------------------------------------------------------------------------------
