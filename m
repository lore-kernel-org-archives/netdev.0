From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv3] net: Define enum for the bits used in features.
Date: Wed, 25 May 2011 15:42:16 -0700
Message-ID: <1306363336-13614-1-git-send-email-maheshb@google.com>
References: <1306288567-1773-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:51402 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134Ab1EYWm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 18:42:27 -0400
In-Reply-To: <1306288567-1773-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Little bit cleanup by defining enum for all bits used. Also use those enum
values to redefine flags.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
Changes since v2:
 (1) Removed the include which was part of the other patch (split mishap).
 (2) Changed the enums to add NETIF_F_ prefix.

Changes since v1:
 Split the patch into two pieces.

 include/linux/netdevice.h |   99 +++++++++++++++++++++++++++++++--------------
 1 files changed, 69 insertions(+), 30 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ca333e7..9bb5872 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -981,6 +981,49 @@ struct net_device_ops {
 };
 
 /*
+ * Net device feature bits; if you change something,
+ * also update netdev_features_strings[] in ethtool.c
+ */
+enum netdev_features {
+	NETIF_F_SG_BIT,			/* Scatter/gather IO. */
+	NETIF_F_IP_CSUM_BIT,		/* Can checksum TCP/UDP over IPv4. */
+	NETIF_F_NO_CSUM_BIT,		/* Does not require checksum. F.e. loopack. */
+	NETIF_F_HW_CSUM_BIT,		/* Can checksum all the packets. */
+	NETIF_F_IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over IPV6 */
+	NETIF_F_HIGHDMA_BIT,		/* Can DMA to high memory. */
+	NETIF_F_FRAGLIST_BIT,		/* Scatter/gather IO. */
+	NETIF_F_HW_VLAN_TX_BIT,		/* Transmit VLAN hw acceleration */
+	NETIF_F_HW_VLAN_RX_BIT,		/* Receive VLAN hw acceleration */
+	NETIF_F_HW_VLAN_FILTER_BIT,	/* Receive filtering on VLAN */
+	NETIF_F_VLAN_CHALLENGED_BIT,	/* Device cannot handle VLAN packets */
+	NETIF_F_GSO_BIT,		/* Enable software GSO. */
+	NETIF_F_LLTX_BIT,		/* LockLess TX - deprecated. Please */
+					/* do not use LLTX in new drivers */
+	NETIF_F_NETNS_LOCAL_BIT,	/* Does not change network namespaces */
+	NETIF_F_GRO_BIT,		/* Generic receive offload */
+	NETIF_F_LRO_BIT,		/* large receive offload */
+	RESERVED16_BIT,			/* the GSO_MASK reserved bit 16 */
+	RESERVED17_BIT,			/* the GSO_MASK reserved bit 17 */
+	RESERVED18_BIT,			/* the GSO_MASK reserved bit 18 */
+	RESERVED19_BIT,			/* the GSO_MASK reserved bit 19 */
+	RESERVED20_BIT,			/* the GSO_MASK reserved bit 20 */
+	RESERVED21_BIT,			/* the GSO_MASK reserved bit 21 */
+	RESERVED22_BIT,			/* the GSO_MASK reserved bit 22 */
+	RESERVED23_BIT,			/* the GSO_MASK reserved bit 23 */
+	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
+	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
+	NETIF_F_FCOE_MTU_BIT,		/* Supports max FCoE MTU, 2158 bytes*/
+	NETIF_F_NTUPLE_BIT,		/* N-tuple filters supported */
+	NETIF_F_RXHASH_BIT,		/* Receive hashing offload */
+	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
+	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
+	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
+
+	/* Add you bit above this */
+	ND_FEATURE_NUM_BITS		/* (LAST VALUE) Total bits in use */
+};
+
+/*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
  *	data with strictly "high-level" data, and it has to know about
@@ -1035,36 +1078,32 @@ struct net_device {
 	/* mask of features inheritable by VLAN devices */
 	u32			vlan_features;
 
-	/* Net device feature bits; if you change something,
-	 * also update netdev_features_strings[] in ethtool.c */
-
-#define NETIF_F_SG		1	/* Scatter/gather IO. */
-#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
-#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
-#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
-#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
-#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
-#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
-#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
-#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
-#define NETIF_F_GSO		2048	/* Enable software GSO. */
-#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
-					/* do not use LLTX in new drivers */
-#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
-#define NETIF_F_GRO		16384	/* Generic receive offload */
-#define NETIF_F_LRO		32768	/* large receive offload */
-
-/* the GSO_MASK reserves bits 16 through 23 */
-#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
-#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
-#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
-#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
-#define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
-#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
-#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
-#define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
+#define BIT2FLAG(bit)		(1 << (bit))
+
+#define NETIF_F_SG		BIT2FLAG(NETIF_F_SG_BIT)
+#define NETIF_F_IP_CSUM		BIT2FLAG(NETIF_F_IP_CSUM_BIT)
+#define NETIF_F_NO_CSUM		BIT2FLAG(NETIF_F_NO_CSUM_BIT)
+#define NETIF_F_HW_CSUM		BIT2FLAG(NETIF_F_HW_CSUM_BIT)
+#define NETIF_F_IPV6_CSUM	BIT2FLAG(NETIF_F_IPV6_CSUM_BIT)
+#define NETIF_F_HIGHDMA		BIT2FLAG(NETIF_F_HIGHDMA_BIT)
+#define NETIF_F_FRAGLIST	BIT2FLAG(NETIF_F_FRAGLIST_BIT)
+#define NETIF_F_HW_VLAN_TX	BIT2FLAG(NETIF_F_HW_VLAN_TX_BIT)
+#define NETIF_F_HW_VLAN_RX	BIT2FLAG(NETIF_F_HW_VLAN_RX_BIT)
+#define NETIF_F_HW_VLAN_FILTER	BIT2FLAG(NETIF_F_HW_VLAN_FILTER_BIT)
+#define NETIF_F_VLAN_CHALLENGED	BIT2FLAG(NETIF_F_VLAN_CHALLENGED_BIT)
+#define NETIF_F_GSO		BIT2FLAG(NETIF_F_GSO_BIT)
+#define NETIF_F_LLTX		BIT2FLAG(NETIF_F_LLTX_BIT)
+#define NETIF_F_NETNS_LOCAL	BIT2FLAG(NETIF_F_NETNS_LOCAL_BIT)
+#define NETIF_F_GRO		BIT2FLAG(NETIF_F_GRO_BIT)
+#define NETIF_F_LRO		BIT2FLAG(NETIF_F_LRO_BIT)
+#define NETIF_F_FCOE_CRC	BIT2FLAG(NETIF_F_FCOE_CRC_BIT)
+#define NETIF_F_SCTP_CSUM	BIT2FLAG(NETIF_F_SCTP_CSUM_BIT)
+#define NETIF_F_FCOE_MTU	BIT2FLAG(NETIF_F_FCOE_MTU_BIT)
+#define NETIF_F_NTUPLE		BIT2FLAG(NETIF_F_NTUPLE_BIT)
+#define NETIF_F_RXHASH		BIT2FLAG(NETIF_F_RXHASH_BIT)
+#define NETIF_F_RXCSUM		BIT2FLAG(NETIF_F_RXCSUM_BIT)
+#define NETIF_F_NOCACHE_COPY	BIT2FLAG(NETIF_F_NOCACHE_COPY_BIT)
+#define NETIF_F_LOOPBACK	BIT2FLAG(NETIF_F_LOOPBACK_BIT)
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
-- 
1.7.3.1

