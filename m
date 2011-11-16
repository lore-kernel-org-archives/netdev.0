From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 6/9] net: ethtool: use C99 array initialization for
 feature-names table
Date: Wed, 16 Nov 2011 02:29:55 +0100 (CET)
Message-ID: <fab0871cb71339c4d0eba86a33761e477b574e7e.1321404954.git.mirq-linux@rere.qmqm.pl>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46032 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932834Ab1KPB37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 20:29:59 -0500
In-Reply-To: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   74 +++++++++++++++++++++++++-------------------=
-------
 1 files changed, 36 insertions(+), 38 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f135f1c..817ad4b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -40,6 +40,42 @@ EXPORT_SYMBOL(ethtool_op_get_link);
=20
 #define ETHTOOL_DEV_FEATURE_WORDS	1
=20
+static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GS=
TRING_LEN] =3D {
+	[NETIF_F_SG_BIT] =3D               "tx-scatter-gather",
+	[NETIF_F_IP_CSUM_BIT] =3D          "tx-checksum-ipv4",
+	[NETIF_F_NO_CSUM_BIT] =3D          "tx-checksum-unneeded",
+	[NETIF_F_HW_CSUM_BIT] =3D          "tx-checksum-ip-generic",
+	[NETIF_F_IPV6_CSUM_BIT] =3D        "tx-checksum-ipv6",
+	[NETIF_F_HIGHDMA_BIT] =3D          "highdma",
+	[NETIF_F_FRAGLIST_BIT] =3D         "tx-scatter-gather-fraglist",
+	[NETIF_F_HW_VLAN_TX_BIT] =3D       "tx-vlan-hw-insert",
+
+	[NETIF_F_HW_VLAN_RX_BIT] =3D       "rx-vlan-hw-parse",
+	[NETIF_F_HW_VLAN_FILTER_BIT] =3D   "rx-vlan-filter",
+	[NETIF_F_VLAN_CHALLENGED_BIT] =3D  "vlan-challenged",
+	[NETIF_F_GSO_BIT] =3D              "tx-generic-segmentation",
+	[NETIF_F_LLTX_BIT] =3D             "tx-lockless",
+	[NETIF_F_NETNS_LOCAL_BIT] =3D      "netns-local",
+	[NETIF_F_GRO_BIT] =3D              "rx-gro",
+	[NETIF_F_LRO_BIT] =3D              "rx-lro",
+
+	[NETIF_F_TSO_BIT] =3D              "tx-tcp-segmentation",
+	[NETIF_F_UFO_BIT] =3D              "tx-udp-fragmentation",
+	[NETIF_F_GSO_ROBUST_BIT] =3D       "tx-gso-robust",
+	[NETIF_F_TSO_ECN_BIT] =3D          "tx-tcp-ecn-segmentation",
+	[NETIF_F_TSO6_BIT] =3D             "tx-tcp6-segmentation",
+	[NETIF_F_FSO_BIT] =3D              "tx-fcoe-segmentation",
+
+	[NETIF_F_FCOE_CRC_BIT] =3D         "tx-checksum-fcoe-crc",
+	[NETIF_F_SCTP_CSUM_BIT] =3D        "tx-checksum-sctp",
+	[NETIF_F_FCOE_MTU_BIT] =3D         "fcoe-mtu",
+	[NETIF_F_NTUPLE_BIT] =3D           "rx-ntuple-filter",
+	[NETIF_F_RXHASH_BIT] =3D           "rx-hashing",
+	[NETIF_F_RXCSUM_BIT] =3D           "rx-checksum",
+	[NETIF_F_NOCACHE_COPY_BIT] =3D     "tx-nocache-copy",
+	[NETIF_F_LOOPBACK_BIT] =3D         "loopback",
+};
+
 static int ethtool_get_features(struct net_device *dev, void __user *u=
seraddr)
 {
 	struct ethtool_gfeatures cmd =3D {
@@ -107,44 +143,6 @@ static int ethtool_set_features(struct net_device =
*dev, void __user *useraddr)
 	return ret;
 }
=20
-static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * =
32][ETH_GSTRING_LEN] =3D {
-	/* NETIF_F_SG */              "tx-scatter-gather",
-	/* NETIF_F_IP_CSUM */         "tx-checksum-ipv4",
-	/* NETIF_F_NO_CSUM */         "tx-checksum-unneeded",
-	/* NETIF_F_HW_CSUM */         "tx-checksum-ip-generic",
-	/* NETIF_F_IPV6_CSUM */       "tx-checksum-ipv6",
-	/* NETIF_F_HIGHDMA */         "highdma",
-	/* NETIF_F_FRAGLIST */        "tx-scatter-gather-fraglist",
-	/* NETIF_F_HW_VLAN_TX */      "tx-vlan-hw-insert",
-
-	/* NETIF_F_HW_VLAN_RX */      "rx-vlan-hw-parse",
-	/* NETIF_F_HW_VLAN_FILTER */  "rx-vlan-filter",
-	/* NETIF_F_VLAN_CHALLENGED */ "vlan-challenged",
-	/* NETIF_F_GSO */             "tx-generic-segmentation",
-	/* NETIF_F_LLTX */            "tx-lockless",
-	/* NETIF_F_NETNS_LOCAL */     "netns-local",
-	/* NETIF_F_GRO */             "rx-gro",
-	/* NETIF_F_LRO */             "rx-lro",
-
-	/* NETIF_F_TSO */             "tx-tcp-segmentation",
-	/* NETIF_F_UFO */             "tx-udp-fragmentation",
-	/* NETIF_F_GSO_ROBUST */      "tx-gso-robust",
-	/* NETIF_F_TSO_ECN */         "tx-tcp-ecn-segmentation",
-	/* NETIF_F_TSO6 */            "tx-tcp6-segmentation",
-	/* NETIF_F_FSO */             "tx-fcoe-segmentation",
-	"",
-	"",
-
-	/* NETIF_F_FCOE_CRC */        "tx-checksum-fcoe-crc",
-	/* NETIF_F_SCTP_CSUM */       "tx-checksum-sctp",
-	/* NETIF_F_FCOE_MTU */        "fcoe-mtu",
-	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
-	/* NETIF_F_RXHASH */          "rx-hashing",
-	/* NETIF_F_RXCSUM */          "rx-checksum",
-	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy",
-	/* NETIF_F_LOOPBACK */        "loopback",
-};
-
 static int __ethtool_get_sset_count(struct net_device *dev, int sset)
 {
 	const struct ethtool_ops *ops =3D dev->ethtool_ops;
--=20
1.7.7.1
