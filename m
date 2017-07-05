From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC 12/12] net: Kill NETIF_F_UFO and SKB_GSO_UDP.
Date: Wed, 05 Jul 2017 16:06:46 +0100 (WEST)
Message-ID: <20170705.160646.1642092925279713744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42620 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751856AbdGEPGv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:06:51 -0400
Received: from localhost (unknown [193.136.225.129])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id EE356126C97F8
        for <netdev@vger.kernel.org>; Wed,  5 Jul 2017 08:06:50 -0700 (PDT)
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
index 85f01d6..02f1421 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4087,7 +4087,6 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 
 	/* check flags correspondence */
 	BUILD_BUG_ON(SKB_GSO_TCPV4   != (NETIF_F_TSO >> NETIF_F_GSO_SHIFT));
-	BUILD_BUG_ON(SKB_GSO_UDP     != (NETIF_F_UFO >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_DODGY   != (NETIF_F_GSO_ROBUST >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_ECN != (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_FIXEDID != (NETIF_F_TSO_MANGLEID >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3d3ceaa..45c4aa9 100644
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
