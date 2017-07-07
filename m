From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 RFC 13/13] net: Kill NETIF_F_UFO and SKB_GSO_UDP.
Date: Fri, 07 Jul 2017 10:44:57 +0100 (WEST)
Message-ID: <20170707.104457.1545118872128376369.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49854 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752039AbdGGJo7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 05:44:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdev_features.h |  4 +---
 include/linux/netdevice.h       |  1 -
 include/linux/skbuff.h          | 31 +++++++++++++++----------------
 3 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 1d4737c..ebd2736 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -36,7 +36,6 @@ enum {
 	/**/NETIF_F_GSO_SHIFT,		/* keep the order of SKB_GSO_* bits */
 	NETIF_F_TSO_BIT			/* ... TCPv4 segmentation */
 		= NETIF_F_GSO_SHIFT,
-	NETIF_F_UFO_BIT,		/* ... UDPv4 fragmentation */
 	NETIF_F_GSO_ROBUST_BIT,		/* ... ->SKB_GSO_DODGY */
 	NETIF_F_TSO_ECN_BIT,		/* ... TCP ECN support */
 	NETIF_F_TSO_MANGLEID_BIT,	/* ... IPV4 ID mangling allowed */
@@ -118,7 +117,6 @@ enum {
 #define NETIF_F_TSO6		__NETIF_F(TSO6)
 #define NETIF_F_TSO_ECN		__NETIF_F(TSO_ECN)
 #define NETIF_F_TSO		__NETIF_F(TSO)
-#define NETIF_F_UFO		__NETIF_F(UFO)
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
@@ -172,7 +170,7 @@ enum {
 				 NETIF_F_FSO)
 
 /* List of features with software fallbacks. */
-#define NETIF_F_GSO_SOFTWARE	(NETIF_F_ALL_TSO | NETIF_F_UFO | \
+#define NETIF_F_GSO_SOFTWARE	(NETIF_F_ALL_TSO | \
 				 NETIF_F_GSO_SCTP)
 
 /*
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e48ee2e..2ddbe10 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4088,7 +4088,6 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 
 	/* check flags correspondence */
 	BUILD_BUG_ON(SKB_GSO_TCPV4   != (NETIF_F_TSO >> NETIF_F_GSO_SHIFT));
-	BUILD_BUG_ON(SKB_GSO_UDP     != (NETIF_F_UFO >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_DODGY   != (NETIF_F_GSO_ROBUST >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_ECN != (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_FIXEDID != (NETIF_F_TSO_MANGLEID >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index dbe29b6..4d7a284 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -463,39 +463,38 @@ enum {
 
 enum {
 	SKB_GSO_TCPV4 = 1 << 0,
-	SKB_GSO_UDP = 1 << 1,
 
 	/* This indicates the skb is from an untrusted source. */
-	SKB_GSO_DODGY = 1 << 2,
+	SKB_GSO_DODGY = 1 << 1,
 
 	/* This indicates the tcp segment has CWR set. */
-	SKB_GSO_TCP_ECN = 1 << 3,
+	SKB_GSO_TCP_ECN = 1 << 2,
 
-	SKB_GSO_TCP_FIXEDID = 1 << 4,
+	SKB_GSO_TCP_FIXEDID = 1 << 3,
 
-	SKB_GSO_TCPV6 = 1 << 5,
+	SKB_GSO_TCPV6 = 1 << 4,
 
-	SKB_GSO_FCOE = 1 << 6,
+	SKB_GSO_FCOE = 1 << 5,
 
-	SKB_GSO_GRE = 1 << 7,
+	SKB_GSO_GRE = 1 << 6,
 
-	SKB_GSO_GRE_CSUM = 1 << 8,
+	SKB_GSO_GRE_CSUM = 1 << 7,
 
-	SKB_GSO_IPXIP4 = 1 << 9,
+	SKB_GSO_IPXIP4 = 1 << 8,
 
-	SKB_GSO_IPXIP6 = 1 << 10,
+	SKB_GSO_IPXIP6 = 1 << 9,
 
-	SKB_GSO_UDP_TUNNEL = 1 << 11,
+	SKB_GSO_UDP_TUNNEL = 1 << 10,
 
-	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 12,
+	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 11,
 
-	SKB_GSO_PARTIAL = 1 << 13,
+	SKB_GSO_PARTIAL = 1 << 12,
 
-	SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
+	SKB_GSO_TUNNEL_REMCSUM = 1 << 13,
 
-	SKB_GSO_SCTP = 1 << 15,
+	SKB_GSO_SCTP = 1 << 14,
 
-	SKB_GSO_ESP = 1 << 16,
+	SKB_GSO_ESP = 1 << 15,
 };
 
 #if BITS_PER_LONG > 32
-- 
2.9.4
