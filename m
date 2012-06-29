From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: [PATCH net-next 01/15] net: bus: Add AF_BUS socket address family
Date: Fri, 29 Jun 2012 17:45:40 +0100
Message-ID: <1340988354-26981-2-git-send-email-vincent.sanders@collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Cc: Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>

This adds AF_BUS to the socket headers and net core.

AF_BUS is a message oriented inter process communication system
implemented as asocket address family. The principle features are:

 - Reliable datagram based communication (all sockets are of type
   SOCK_SEQPACKET)
 - Multicast message delivery (one to many, unicast as a subset)
 - Strict ordering (messages are delivered to every client in the same order)
 - Ability to pass file descriptors
 - Ability to pass credentials

Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Signed-off-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 include/linux/socket.h |    5 ++++-
 net/core/sock.c        |    6 +++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 25d6322..d244e69 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -195,7 +195,8 @@ struct ucred {
 #define AF_CAIF		37	/* CAIF sockets			*/
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
-#define AF_MAX		40	/* For now.. */
+#define AF_BUS		40	/* BUS sockets			*/
+#define AF_MAX		41	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -238,6 +239,7 @@ struct ucred {
 #define PF_CAIF		AF_CAIF
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
+#define PF_BUS		AF_BUS
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -312,6 +314,7 @@ struct ucred {
 #define SOL_IUCV	277
 #define SOL_CAIF	278
 #define SOL_ALG		279
+#define SOL_BUS		280
 
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/net/core/sock.c b/net/core/sock.c
index 929bdcc..b9c5fc8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -208,7 +208,7 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
   "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
-  "sk_lock-AF_NFC"   , "sk_lock-AF_MAX"
+  "sk_lock-AF_NFC"   , "sk_lock-AF_BUS"     , "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -224,7 +224,7 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
   "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
-  "slock-AF_NFC"   , "slock-AF_MAX"
+  "slock-AF_NFC"   , "slock-AF_BUS"     , "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -240,7 +240,7 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
-  "clock-AF_NFC"   , "clock-AF_MAX"
+  "clock-AF_NFC"   , "clock-AF_BUS"     , "clock-AF_MAX"
 };
 
 /*
-- 
1.7.10
