From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 2/6] Add constants for the ieee 802.15.4/ZigBee stack
Date: Wed,  3 Jun 2009 13:33:45 +0400
Message-ID: <1244021629-18409-3-git-send-email-dbaryshkov@gmail.com>
References: <1244021629-18409-1-git-send-email-dbaryshkov@gmail.com>
 <1244021629-18409-2-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, Stephen Rothwell <sfr@canb.auug.org.au>,
	Sergey Lapin <slapin@ossfans.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:45724 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbZFCJeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 05:34:18 -0400
In-Reply-To: <1244021629-18409-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IEEE 802.15.4/ZigBee stack requires several constants to be defined/adjusted.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Signed-off-by: Sergey Lapin <slapin@ossfans.org>
---
 include/linux/if.h       |    2 ++
 include/linux/if_arp.h   |    2 ++
 include/linux/if_ether.h |    2 ++
 include/linux/socket.h   |    6 +++++-
 net/core/dev.c           |    6 ++++--
 net/core/sock.c          |    3 +++
 6 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index 1108f3e..3f574b8 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -68,6 +68,8 @@
 #define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
 #define IFF_WAN_HDLC	0x200		/* WAN HDLC device		*/
 
+#define IFF_IEEE802154_COORD 0x100	/* IEEE802.15.4 PAN coordinator */
+
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
 
diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 5ff8980..b554300 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -86,6 +86,8 @@
 #define ARPHRD_IEEE80211 801		/* IEEE 802.11			*/
 #define ARPHRD_IEEE80211_PRISM 802	/* IEEE 802.11 + Prism2 header  */
 #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header */
+#define ARPHRD_IEEE802154	  804
+#define ARPHRD_IEEE802154_PHY	  805
 
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index cfe4fe1..0a08e92 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -106,6 +106,8 @@
 #define ETH_P_DSA	0x001B		/* Distributed Switch Arch.	*/
 #define ETH_P_TRAILER	0x001C		/* Trailer switch tagging	*/
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
+#define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
+#define ETH_P_IEEE802154_MAC 0x00F7	/* IEEE802.15.4 MAC frame	*/
 
 /*
  *	This is an Ethernet frame header.
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 421afb4..09d792e 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -194,7 +194,9 @@ struct ucred {
 #define AF_RXRPC	33	/* RxRPC sockets 		*/
 #define AF_ISDN		34	/* mISDN sockets 		*/
 #define AF_PHONET	35	/* Phonet sockets		*/
-#define AF_MAX		36	/* For now.. */
+#define AF_IEEE802154	36	/* IEEE802154 sockets		*/
+#define AF_ZIGBEE	37	/* ZIGBEE sockets		*/
+#define AF_MAX		38	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -233,6 +235,8 @@ struct ucred {
 #define PF_RXRPC	AF_RXRPC
 #define PF_ISDN		AF_ISDN
 #define PF_PHONET	AF_PHONET
+#define PF_IEEE802154	AF_IEEE802154
+#define PF_ZIGBEE	AF_ZIGBEE
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/net/core/dev.c b/net/core/dev.c
index e2e9e4a..4119dfc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -268,7 +268,8 @@ static const unsigned short netdev_lock_type[] =
 	 ARPHRD_IRDA, ARPHRD_FCPP, ARPHRD_FCAL, ARPHRD_FCPL,
 	 ARPHRD_FCFABRIC, ARPHRD_IEEE802_TR, ARPHRD_IEEE80211,
 	 ARPHRD_IEEE80211_PRISM, ARPHRD_IEEE80211_RADIOTAP, ARPHRD_PHONET,
-	 ARPHRD_PHONET_PIPE, ARPHRD_VOID, ARPHRD_NONE};
+	 ARPHRD_PHONET_PIPE, ARPHRD_IEEE802154, ARPHRD_IEEE802154_PHY,
+	 ARPHRD_VOID, ARPHRD_NONE};
 
 static const char *netdev_lock_name[] =
 	{"_xmit_NETROM", "_xmit_ETHER", "_xmit_EETHER", "_xmit_AX25",
@@ -285,7 +286,8 @@ static const char *netdev_lock_name[] =
 	 "_xmit_IRDA", "_xmit_FCPP", "_xmit_FCAL", "_xmit_FCPL",
 	 "_xmit_FCFABRIC", "_xmit_IEEE802_TR", "_xmit_IEEE80211",
 	 "_xmit_IEEE80211_PRISM", "_xmit_IEEE80211_RADIOTAP", "_xmit_PHONET",
-	 "_xmit_PHONET_PIPE", "_xmit_VOID", "_xmit_NONE"};
+	 "_xmit_PHONET_PIPE", "_xmit_IEEE802154", "_xmit_IEEE802154_PHY",
+	 "_xmit_VOID", "_xmit_NONE"};
 
 static struct lock_class_key netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)];
 static struct lock_class_key netdev_addr_lock_key[ARRAY_SIZE(netdev_lock_type)];
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dbf3ff..72d593b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -155,6 +155,7 @@ static const char *af_family_key_strings[AF_MAX+1] = {
   "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"      ,
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
+  "sk_lock-AF_IEEE802154", "sk_lock-AF_ZIGBEE",
   "sk_lock-AF_MAX"
 };
 static const char *af_family_slock_key_strings[AF_MAX+1] = {
@@ -170,6 +171,7 @@ static const char *af_family_slock_key_strings[AF_MAX+1] = {
   "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
+  "slock-AF_IEEE802154", "slock-AF_ZIGBEE",
   "slock-AF_MAX"
 };
 static const char *af_family_clock_key_strings[AF_MAX+1] = {
@@ -185,6 +187,7 @@ static const char *af_family_clock_key_strings[AF_MAX+1] = {
   "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
+  "clock-AF_IEEE802154", "clock-AF_ZIGBEE",
   "clock-AF_MAX"
 };
 
-- 
1.6.3.1

