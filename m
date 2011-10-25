From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v4 3/9] net: split netdev features to separate header
Date: Tue, 25 Oct 2011 02:36:33 +0200 (CEST)
Message-ID: <3eb7058d29bf27f6d02798c9b1efd2e44336826b.1319495302.git.mirq-linux@rere.qmqm.pl>
References: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45082 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755750Ab1JYAgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 20:36:36 -0400
In-Reply-To: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move features definitions to separate header so that linux/skbuff.h won=
't
need to include linux/netdevice.h after netdev_features_t is introduced=
=2E

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdev_features.h |   90 +++++++++++++++++++++++++++++++=
++++++++
 include/linux/netdevice.h       |   80 +------------------------------=
---
 2 files changed, 92 insertions(+), 78 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
new file mode 100644
index 0000000..32640ed
--- /dev/null
+++ b/include/linux/netdev_features.h
@@ -0,0 +1,90 @@
+/*
+ * Network device features.
+ *
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+#ifndef _LINUX_NETDEV_FEATURES_H
+#define _LINUX_NETDEV_FEATURES_H
+
+/* Net device feature bits; if you change something,
+ * also update netdev_features_strings[] in ethtool.c */
+
+#define NETIF_F_SG		1	/* Scatter/gather IO. */
+#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
+#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack.=
 */
+#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
+#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
+#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
+#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
+#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
+#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
+#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
+#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN pack=
ets */
+#define NETIF_F_GSO		2048	/* Enable software GSO. */
+#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
+					/* do not use LLTX in new drivers */
+#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces=
 */
+#define NETIF_F_GRO		16384	/* Generic receive offload */
+#define NETIF_F_LRO		32768	/* large receive offload */
+
+/* the GSO_MASK reserves bits 16 through 23 */
+#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
+#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
+#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 byte=
s*/
+#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
+#define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
+#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
+#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
+#define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
+
+/* Segmentation offload features */
+#define NETIF_F_GSO_SHIFT	16
+#define NETIF_F_GSO_MASK	0x00ff0000
+#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
+#define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
+
+/* Features valid for ethtool to change */
+/* =3D all defined minus driver/device-class-related */
+#define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
+				 NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
+#define NETIF_F_ETHTOOL_BITS	(0xff3fffff & ~NETIF_F_NEVER_CHANGE)
+
+/* List of features with software fallbacks. */
+#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
+				 NETIF_F_TSO6 | NETIF_F_UFO)
+
+#define NETIF_F_GEN_CSUM	(NETIF_F_HW_CSUM | NETIF_F_NO_CSUM)
+#define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
+#define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
+#define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
+
+#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN=
)
+
+#define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
+				 NETIF_F_FSO)
+
+/*
+ * If one device supports one of these features, then enable them
+ * for all in netdev_increment_features.
+ */
+#define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST=
 | \
+				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
+				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
+/*
+ * If one device doesn't support one of these features, then disable i=
t
+ * for all in netdev_increment_features.
+ */
+#define NETIF_F_ALL_FOR_ALL	(NETIF_F_NOCACHE_COPY | NETIF_F_FSO)
+
+/* changeable features with no special hardware requirements */
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+
+#endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2f342b9..82787b3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -51,6 +51,8 @@
 #include <net/dcbnl.h>
 #endif
=20
+#include <linux/netdev_features.h>
+
 struct vlan_group;
 struct netpoll_info;
 struct phy_device;
@@ -1005,84 +1007,6 @@ struct net_device {
 	/* mask of features inheritable by VLAN devices */
 	u32			vlan_features;
=20
-	/* Net device feature bits; if you change something,
-	 * also update netdev_features_strings[] in ethtool.c */
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
-					/* do not use LLTX in new drivers */
-#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces=
 */
-#define NETIF_F_GRO		16384	/* Generic receive offload */
-#define NETIF_F_LRO		32768	/* large receive offload */
-
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
-
-	/* Segmentation offload features */
-#define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0x00ff0000
-#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
-#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
-#define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
-#define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
-#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
-#define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
-
-	/* Features valid for ethtool to change */
-	/* =3D all defined minus driver/device-class-related */
-#define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
-				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
-#define NETIF_F_ETHTOOL_BITS	(0xff3fffff & ~NETIF_F_NEVER_CHANGE)
-
-	/* List of features with software fallbacks. */
-#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
-				 NETIF_F_TSO6 | NETIF_F_UFO)
-
-
-#define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
-#define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
-#define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
-#define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
-
-#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN=
)
-
-#define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
-				 NETIF_F_FSO)
-
-	/*
-	 * If one device supports one of these features, then enable them
-	 * for all in netdev_increment_features.
-	 */
-#define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST=
 | \
-				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
-				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
-	/*
-	 * If one device doesn't support one of these features, then disable =
it
-	 * for all in netdev_increment_features.
-	 */
-#define NETIF_F_ALL_FOR_ALL	(NETIF_F_NOCACHE_COPY | NETIF_F_FSO)
-
-	/* changeable features with no special hardware requirements */
-#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
-
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
--=20
1.7.6.3
