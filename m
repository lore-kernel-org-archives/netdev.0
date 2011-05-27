From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH] net: ethtool: use C99 array initialization for feature-names table
Date: Fri, 27 May 2011 11:25:25 +0200 (CEST)
Message-ID: <c6eca0e13800f6fd6465fff1108ef0401b88f89d.1306488115.git.mirq-linux@rere.qmqm.pl>
References: <BANLkTik5aF-CafhXSuTOZdCZuJiyz_Ot_A@mail.gmail.com>
	<1306288567-1773-1-git-send-email-maheshb@google.com>
	<1306363336-13614-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35861 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752867Ab1E0JZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 05:25:26 -0400
In-Reply-To: <BANLkTik5aF-CafhXSuTOZdCZuJiyz_Ot_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This depends on Mahesh Bandewar's cleanup of feature bits.

Note: This is why I'd like that patch to include TSO bits as well,
so I can get rid of this ugly NETIF_F_GSO_SHIFT+n.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   65 +++++++++++++++++++++++++-------------------=
-------
 1 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 59255c1..e5de5e1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -350,42 +350,41 @@ static int ethtool_set_features(struct net_device=
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
+static const char netdev_features_strings[ND_FEATURE_NUM_BITS][ETH_GST=
RING_LEN] =3D {
+	[NETIF_F_SG_BIT] =3D               "tx-scatter-gather",
+	[NETIF_F_IP_CSUM_BIT] =3D          "tx-checksum-ipv4",
+	[NETIF_F_NO_CSUM_BIT] =3D          "tx-checksum-unneeded",
+	[NETIF_F_HW_CSUM_BIT] =3D          "tx-checksum-ip-generic",
+	[NETIF_F_IPV6_CSUM_BIT] =3D        "tx-checksum-ipv6",
+	[NETIF_F_HIGHDMA_BIT] =3D          "highdma",
+	[NETIF_F_FRAGLIST_BIT] =3D         "tx-scatter-gather-fraglist",
+	[NETIF_F_HW_VLAN_TX_BIT] =3D       "tx-vlan-hw-insert",
=20
-	/* NETIF_F_HW_VLAN_RX */      "rx-vlan-hw-parse",
-	/* NETIF_F_HW_VLAN_FILTER */  "rx-vlan-filter",
-	/* NETIF_F_VLAN_CHALLENGED */ "vlan-challenged",
-	/* NETIF_F_GSO */             "tx-generic-segmentation",
-	/* NETIF_F_LLTX */            "tx-lockless",
-	/* NETIF_F_NETNS_LOCAL */     "netns-local",
-	/* NETIF_F_GRO */             "rx-gro",
-	/* NETIF_F_LRO */             "rx-lro",
+	[NETIF_F_HW_VLAN_RX_BIT] =3D       "rx-vlan-hw-parse",
+	[NETIF_F_HW_VLAN_FILTER_BIT] =3D   "rx-vlan-filter",
+	[NETIF_F_VLAN_CHALLENGED_BIT] =3D  "vlan-challenged",
+	[NETIF_F_GSO_BIT] =3D              "tx-generic-segmentation",
+	[NETIF_F_LLTX_BIT] =3D             "tx-lockless",
+	[NETIF_F_NETNS_LOCAL_BIT] =3D      "netns-local",
+	[NETIF_F_GRO_BIT] =3D              "rx-gro",
+	[NETIF_F_LRO_BIT] =3D              "rx-lro",
=20
-	/* NETIF_F_TSO */             "tx-tcp-segmentation",
-	/* NETIF_F_UFO */             "tx-udp-fragmentation",
-	/* NETIF_F_GSO_ROBUST */      "tx-gso-robust",
-	/* NETIF_F_TSO_ECN */         "tx-tcp-ecn-segmentation",
-	/* NETIF_F_TSO6 */            "tx-tcp6-segmentation",
-	/* NETIF_F_FSO */             "tx-fcoe-segmentation",
-	"",
-	"",
+	/* must match SKB_GSO_* order */
+	[NETIF_F_GSO_SHIFT+0] =3D          "tx-tcp-segmentation",
+	[NETIF_F_GSO_SHIFT+1] =3D          "tx-udp-fragmentation",
+	[NETIF_F_GSO_SHIFT+2] =3D          "tx-gso-robust",
+	[NETIF_F_GSO_SHIFT+3] =3D          "tx-tcp-ecn-segmentation",
+	[NETIF_F_GSO_SHIFT+4] =3D          "tx-tcp6-segmentation",
+	[NETIF_F_GSO_SHIFT+5] =3D          "tx-fcoe-segmentation",
=20
-	/* NETIF_F_FCOE_CRC */        "tx-checksum-fcoe-crc",
-	/* NETIF_F_SCTP_CSUM */       "tx-checksum-sctp",
-	/* NETIF_F_FCOE_MTU */        "fcoe-mtu",
-	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
-	/* NETIF_F_RXHASH */          "rx-hashing",
-	/* NETIF_F_RXCSUM */          "rx-checksum",
-	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy",
-	/* NETIF_F_LOOPBACK */        "loopback",
+	[NETIF_F_FCOE_CRC_BIT] =3D         "tx-checksum-fcoe-crc",
+	[NETIF_F_SCTP_CSUM_BIT] =3D        "tx-checksum-sctp",
+	[NETIF_F_FCOE_MTU_BIT] =3D         "fcoe-mtu",
+	[NETIF_F_NTUPLE_BIT] =3D           "rx-ntuple-filter",
+	[NETIF_F_RXHASH_BIT] =3D           "rx-hashing",
+	[NETIF_F_RXCSUM_BIT] =3D           "rx-checksum",
+	[NETIF_F_NOCACHE_COPY_BIT] =3D     "tx-nocache-copy",
+	[NETIF_F_LOOPBACK_BIT] =3D         "loopback",
 };
=20
 static int __ethtool_get_sset_count(struct net_device *dev, int sset)
--=20
1.7.2.5

