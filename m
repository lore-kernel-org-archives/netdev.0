From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 5/9] net: Define enum for net device features.
Date: Wed, 16 Nov 2011 02:29:55 +0100 (CET)
Message-ID: <d47c3468cf74bd42f28989d078d9a70ca8cfd7e0.1321404954.git.mirq-linux@rere.qmqm.pl>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46031 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932829Ab1KPB37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 20:29:59 -0500
In-Reply-To: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define feature values by bit position instead of direct 2**i values
and force the values to be of type netdev_features_t.

Cleaned and extended from patch by Mahesh Bandewar <maheshb@google.com>=
:
+ added netdev_features_t casts
+ included bits under NETIF_F_GSO_MASK
+ moved feature #defines out of struct net_device definition

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdev_features.h |  129 +++++++++++++++++++++++++++----=
-------
 1 files changed, 91 insertions(+), 38 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
index af52381..04ac8f8 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -14,52 +14,105 @@
=20
 typedef u32 netdev_features_t;
=20
-/* Net device feature bits; if you change something,
- * also update netdev_features_strings[] in ethtool.c */
-
-#define NETIF_F_SG		1	/* Scatter/gather IO. */
-#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
-#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack.=
 */
-#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
-#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
-#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
-#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
-#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
-#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN pack=
ets */
-#define NETIF_F_GSO		2048	/* Enable software GSO. */
-#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
+enum {
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
 					/* do not use LLTX in new drivers */
-#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces=
 */
-#define NETIF_F_GRO		16384	/* Generic receive offload */
-#define NETIF_F_LRO		32768	/* large receive offload */
+	NETIF_F_NETNS_LOCAL_BIT,	/* Does not change network namespaces */
+	NETIF_F_GRO_BIT,		/* Generic receive offload */
+	NETIF_F_LRO_BIT,		/* large receive offload */
=20
-/* the GSO_MASK reserves bits 16 through 23 */
-#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
-#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
-#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 byte=
s*/
-#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
-#define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
-#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
-#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
-#define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
+	/**/NETIF_F_GSO_SHIFT,		/* keep the order of SKB_GSO_* bits */
+	NETIF_F_TSO_BIT			/* ... TCPv4 segmentation */
+		=3D NETIF_F_GSO_SHIFT,
+	NETIF_F_UFO_BIT,		/* ... UDPv4 fragmentation */
+	NETIF_F_GSO_ROBUST_BIT,		/* ... ->SKB_GSO_DODGY */
+	NETIF_F_TSO_ECN_BIT,		/* ... TCP ECN support */
+	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
+	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
+	NETIF_F_GSO_RESERVED1,		/* ... free (fill GSO_MASK to 8 bits) */
+	/**/NETIF_F_GSO_LAST,		/* [can't be last bit, see GSO_MASK] */
+	NETIF_F_GSO_RESERVED2		/* ... free (fill GSO_MASK to 8 bits) */
+		=3D NETIF_F_GSO_LAST,
=20
-/* Segmentation offload features */
-#define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0x00ff0000
-#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
-#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
-#define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
-#define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
-#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
-#define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
+	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
+	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
+	NETIF_F_FCOE_MTU_BIT,		/* Supports max FCoE MTU, 2158 bytes*/
+	NETIF_F_NTUPLE_BIT,		/* N-tuple filters supported */
+	NETIF_F_RXHASH_BIT,		/* Receive hashing offload */
+	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
+	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
+	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
+
+	/*
+	 * Add your fresh new feature above and remember to update
+	 * netdev_features_strings[] in net/core/ethtool.c and maybe
+	 * some feature mask #defines below. Please also describe it
+	 * in Documentation/networking/netdev-features.txt.
+	 */
+
+	/**/NETDEV_FEATURE_COUNT
+};
+
+/* copy'n'paste compression ;) */
+#define __NETIF_F_BIT(bit)	((netdev_features_t)1 << (bit))
+#define __NETIF_F(name)		__NETIF_F_BIT(NETIF_F_##name##_BIT)
+
+#define NETIF_F_FCOE_CRC	__NETIF_F(FCOE_CRC)
+#define NETIF_F_FCOE_MTU	__NETIF_F(FCOE_MTU)
+#define NETIF_F_FRAGLIST	__NETIF_F(FRAGLIST)
+#define NETIF_F_FSO		__NETIF_F(FSO)
+#define NETIF_F_GRO		__NETIF_F(GRO)
+#define NETIF_F_GSO		__NETIF_F(GSO)
+#define NETIF_F_GSO_ROBUST	__NETIF_F(GSO_ROBUST)
+#define NETIF_F_HIGHDMA		__NETIF_F(HIGHDMA)
+#define NETIF_F_HW_CSUM		__NETIF_F(HW_CSUM)
+#define NETIF_F_HW_VLAN_FILTER	__NETIF_F(HW_VLAN_FILTER)
+#define NETIF_F_HW_VLAN_RX	__NETIF_F(HW_VLAN_RX)
+#define NETIF_F_HW_VLAN_TX	__NETIF_F(HW_VLAN_TX)
+#define NETIF_F_IP_CSUM		__NETIF_F(IP_CSUM)
+#define NETIF_F_IPV6_CSUM	__NETIF_F(IPV6_CSUM)
+#define NETIF_F_LLTX		__NETIF_F(LLTX)
+#define NETIF_F_LOOPBACK	__NETIF_F(LOOPBACK)
+#define NETIF_F_LRO		__NETIF_F(LRO)
+#define NETIF_F_NETNS_LOCAL	__NETIF_F(NETNS_LOCAL)
+#define NETIF_F_NOCACHE_COPY	__NETIF_F(NOCACHE_COPY)
+#define NETIF_F_NO_CSUM		__NETIF_F(NO_CSUM)
+#define NETIF_F_NTUPLE		__NETIF_F(NTUPLE)
+#define NETIF_F_RXCSUM		__NETIF_F(RXCSUM)
+#define NETIF_F_RXHASH		__NETIF_F(RXHASH)
+#define NETIF_F_SCTP_CSUM	__NETIF_F(SCTP_CSUM)
+#define NETIF_F_SG		__NETIF_F(SG)
+#define NETIF_F_TSO6		__NETIF_F(TSO6)
+#define NETIF_F_TSO_ECN		__NETIF_F(TSO_ECN)
+#define NETIF_F_TSO		__NETIF_F(TSO)
+#define NETIF_F_UFO		__NETIF_F(UFO)
+#define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
=20
 /* Features valid for ethtool to change */
 /* =3D all defined minus driver/device-class-related */
 #define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
 				 NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
-#define NETIF_F_ETHTOOL_BITS	(0xff3fffff & ~NETIF_F_NEVER_CHANGE)
+
+/* remember that ((t)1 << t_BITS) is undefined in C99 */
+#define NETIF_F_ETHTOOL_BITS	((__NETIF_F_BIT(NETDEV_FEATURE_COUNT - 1)=
 | \
+		(__NETIF_F_BIT(NETDEV_FEATURE_COUNT - 1) - 1)) & \
+		~NETIF_F_NEVER_CHANGE)
+
+/* Segmentation offload feature mask */
+#define NETIF_F_GSO_MASK	(__NETIF_F_BIT(NETIF_F_GSO_LAST + 1) - \
+		__NETIF_F_BIT(NETIF_F_GSO_SHIFT))
=20
 /* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
--=20
1.7.7.1
