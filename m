From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Fri, 11 Sep 2009 01:25:58 -0400
Message-ID: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fanotify's user interface uses a custom socket (it doesn't use netlink
since work must be done in the context of the receive side of the socket)

This patch simply defines the fanotify socket number declarations.  The
actual implementation of the socket is in a later patch.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 include/linux/socket.h |    5 ++++-
 net/core/sock.c        |    6 +++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 3b461df..e03f47b 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -195,7 +195,8 @@ struct ucred {
 #define AF_ISDN		34	/* mISDN sockets 		*/
 #define AF_PHONET	35	/* Phonet sockets		*/
 #define AF_IEEE802154	36	/* IEEE802154 sockets		*/
-#define AF_MAX		37	/* For now.. */
+#define AF_FANOTIFY	37	/* fscking all access sockets	*/
+#define AF_MAX		38	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -235,6 +236,7 @@ struct ucred {
 #define PF_ISDN		AF_ISDN
 #define PF_PHONET	AF_PHONET
 #define PF_IEEE802154	AF_IEEE802154
+#define PF_FANOTIFY	AF_FANOTIFY
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -306,6 +308,7 @@ struct ucred {
 #define SOL_PNPIPE	275
 #define SOL_RDS		276
 #define SOL_IUCV	277
+#define SOL_FANOTIFY	278
 
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/net/core/sock.c b/net/core/sock.c
index 30d5446..28a99bf 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -155,7 +155,7 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"      ,
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
-  "sk_lock-AF_IEEE802154",
+  "sk_lock-AF_IEEE802154", "sk_lock-AF_FANOTIFY",
   "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
@@ -171,7 +171,7 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
-  "slock-AF_IEEE802154",
+  "slock-AF_IEEE802154", "slock=AF_FANOTIFY",
   "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
@@ -187,7 +187,7 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
-  "clock-AF_IEEE802154",
+  "clock-AF_IEEE802154", "clock-AF_FANOTIFY",
   "clock-AF_MAX"
 };
 

