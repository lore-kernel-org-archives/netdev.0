From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 07/10] net: remove NETIF_F_NO_CSUM feature
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)
Message-ID: <aa24cb5cdd3bd082d038960efd7d5c9a2ba95d8e.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59823 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752815Ab1GNAKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:32 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are no explicit users, so this is now equivalent to NETIF_F_HW_CS=
UM.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/ieee802154/fakehard.c   |    2 +-
 drivers/misc/sgi-xp/xpnet.c     |    2 +-
 drivers/net/bonding/bond_main.c |    2 +-
 drivers/net/can/dev.c           |    2 +-
 drivers/net/can/slcan.c         |    2 +-
 drivers/net/dummy.c             |    2 +-
 drivers/net/ifb.c               |    2 +-
 drivers/net/loopback.c          |    2 +-
 drivers/net/veth.c              |    2 +-
 include/linux/netdevice.h       |    3 +--
 include/linux/skbuff.h          |    1 -
 net/bridge/br_device.c          |    4 ++--
 net/core/dev.c                  |   12 +-----------
 net/core/ethtool.c              |    2 +-
 14 files changed, 14 insertions(+), 26 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehar=
d.c
index eb0e2cc..73d4531 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -343,7 +343,7 @@ static void ieee802154_fake_setup(struct net_device=
 *dev)
 {
 	dev->addr_len		=3D IEEE802154_ADDR_LEN;
 	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
-	dev->features		=3D NETIF_F_NO_CSUM;
+	dev->features		=3D NETIF_F_HW_CSUM;
 	dev->needed_tailroom	=3D 2; /* FCS */
 	dev->mtu		=3D 127;
 	dev->tx_queue_len	=3D 10;
diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 42f0673..3fac67a 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -576,7 +576,7 @@ xpnet_init(void)
 	 * report an error if the data is not retrievable and the
 	 * packet will be dropped.
 	 */
-	xpnet_device->features =3D NETIF_F_NO_CSUM;
+	xpnet_device->features =3D NETIF_F_HW_CSUM;
=20
 	result =3D register_netdev(xpnet_device);
 	if (result !=3D 0) {
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index b9eaf5c..90844a9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4409,7 +4409,7 @@ static void bond_setup(struct net_device *bond_de=
v)
 				NETIF_F_HW_VLAN_RX |
 				NETIF_F_HW_VLAN_FILTER;
=20
-	bond_dev->hw_features &=3D ~(NETIF_F_ALL_CSUM & ~NETIF_F_NO_CSUM);
+	bond_dev->hw_features &=3D ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
 	bond_dev->features |=3D bond_dev->hw_features;
 }
=20
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index d0f8c7e..3f405b40 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -442,7 +442,7 @@ static void can_setup(struct net_device *dev)
=20
 	/* New-style flags. */
 	dev->flags =3D IFF_NOARP;
-	dev->features =3D NETIF_F_NO_CSUM;
+	dev->features =3D NETIF_F_HW_CSUM;
 }
=20
 struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame=
 **cf)
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 1b49df6..d8d9b3e 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -409,7 +409,7 @@ static void slc_setup(struct net_device *dev)
=20
 	/* New-style flags. */
 	dev->flags		=3D IFF_NOARP;
-	dev->features           =3D NETIF_F_NO_CSUM;
+	dev->features           =3D NETIF_F_HW_CSUM;
 }
=20
 /******************************************
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 39cf9b9..6b5c186 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -134,7 +134,7 @@ static void dummy_setup(struct net_device *dev)
 	dev->flags |=3D IFF_NOARP;
 	dev->flags &=3D ~IFF_MULTICAST;
 	dev->features	|=3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
-	dev->features	|=3D NETIF_F_NO_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
+	dev->features	|=3D NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
 	random_ether_addr(dev->dev_addr);
 }
=20
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 6e82dd3..a3926a4 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -164,7 +164,7 @@ static const struct net_device_ops ifb_netdev_ops =3D=
 {
 	.ndo_validate_addr =3D eth_validate_addr,
 };
=20
-#define IFB_FEATURES (NETIF_F_NO_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST=
	| \
+#define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST=
	| \
 		      NETIF_F_TSO_ECN | NETIF_F_TSO | NETIF_F_TSO6	| \
 		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_TX)
=20
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 4ce9e5f..b71998d 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -169,7 +169,7 @@ static void loopback_setup(struct net_device *dev)
 	dev->features 		=3D NETIF_F_SG | NETIF_F_FRAGLIST
 		| NETIF_F_ALL_TSO
 		| NETIF_F_UFO
-		| NETIF_F_NO_CSUM
+		| NETIF_F_HW_CSUM
 		| NETIF_F_RXCSUM
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 7f78db7..9d487d9 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -268,7 +268,7 @@ static void veth_setup(struct net_device *dev)
 	dev->features |=3D NETIF_F_LLTX;
 	dev->destructor =3D veth_dev_free;
=20
-	dev->hw_features =3D NETIF_F_NO_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
+	dev->hw_features =3D NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
 }
=20
 /*
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index faa415d..ebace1b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1027,7 +1027,6 @@ struct net_device {
=20
 #define NETIF_F_SG		1	/* Scatter/gather IO. */
 #define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
-#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack.=
 */
 #define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
 #define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
 #define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
@@ -1074,7 +1073,7 @@ struct net_device {
 				 NETIF_F_TSO6 | NETIF_F_UFO)
=20
=20
-#define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
+#define NETIF_F_GEN_CSUM	(NETIF_F_HW_CSUM)
 #define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
 #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a24218c..ec107ac 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -81,7 +81,6 @@
  *	at device setup time.
  *	NETIF_F_HW_CSUM	- it is clever device, it is able to checksum
  *			  everything.
- *	NETIF_F_NO_CSUM - loopback or reliable single hop media.
  *	NETIF_F_IP_CSUM - device is dumb. It is able to csum only
  *			  TCP/UDP over IPv4. Sigh. Vendors like this
  *			  way by an unknown reason. Though, see comment above
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 32b8f9f..9d607ba 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -344,10 +344,10 @@ void br_dev_setup(struct net_device *dev)
 	dev->priv_flags =3D IFF_EBRIDGE;
=20
 	dev->features =3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
-			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
+			NETIF_F_GSO_MASK | NETIF_F_HW_CSUM | NETIF_F_LLTX |
 			NETIF_F_NETNS_LOCAL | NETIF_F_HW_VLAN_TX;
 	dev->hw_features =3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA =
|
-			   NETIF_F_GSO_MASK | NETIF_F_NO_CSUM |
+			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
 			   NETIF_F_HW_VLAN_TX;
=20
 	br->dev =3D dev;
diff --git a/net/core/dev.c b/net/core/dev.c
index 7b9e2f4..09ce52c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5218,12 +5218,6 @@ u32 netdev_fix_features(struct net_device *dev, =
u32 features)
 		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
 	}
=20
-	if ((features & NETIF_F_NO_CSUM) &&
-	    (features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))=
 {
-		netdev_warn(dev, "mixed no checksumming and other settings.\n");
-		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM|NETIF_F_HW_CSUM);
-	}
-
 	/* Fix illegal SG+CSUM combinations. */
 	if ((features & NETIF_F_SG) &&
 	    !(features & NETIF_F_ALL_CSUM)) {
@@ -6215,17 +6209,13 @@ static int dev_cpu_callback(struct notifier_blo=
ck *nfb,
  */
 u32 netdev_increment_features(u32 all, u32 one, u32 mask)
 {
-	if (mask & NETIF_F_GEN_CSUM)
+	if (mask & NETIF_F_HW_CSUM)
 		mask |=3D NETIF_F_ALL_CSUM;
 	mask |=3D NETIF_F_VLAN_CHALLENGED;
=20
 	all |=3D one & (NETIF_F_ONE_FOR_ALL|NETIF_F_ALL_CSUM) & mask;
 	all &=3D one | ~NETIF_F_ALL_FOR_ALL;
=20
-	/* If device needs checksumming, downgrade to it. */
-	if (all & (NETIF_F_ALL_CSUM & ~NETIF_F_NO_CSUM))
-		all &=3D ~NETIF_F_NO_CSUM;
-
 	/* If one device supports hw checksumming, set for all. */
 	if (all & NETIF_F_GEN_CSUM)
 		all &=3D ~(NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b7c12a6..3b5cee6 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -341,7 +341,7 @@ static int ethtool_set_features(struct net_device *=
dev, void __user *useraddr)
 static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * =
32][ETH_GSTRING_LEN] =3D {
 	/* NETIF_F_SG */              "tx-scatter-gather",
 	/* NETIF_F_IP_CSUM */         "tx-checksum-ipv4",
-	/* NETIF_F_NO_CSUM */         "tx-checksum-unneeded",
+	"",
 	/* NETIF_F_HW_CSUM */         "tx-checksum-ip-generic",
 	/* NETIF_F_IPV6_CSUM */       "tx-checksum-ipv6",
 	/* NETIF_F_HIGHDMA */         "highdma",
--=20
1.7.5.4

