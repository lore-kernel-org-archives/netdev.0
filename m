From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 9/9] net: remove NETIF_F_NO_CSUM feature bit
Date: Wed, 16 Nov 2011 02:29:55 +0100 (CET)
Message-ID: <baa7c1da1cefc13fc3166310311b5a4ccde4e8d7.1321404954.git.mirq-linux@rere.qmqm.pl>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46035 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932898Ab1KPBaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 20:30:00 -0500
In-Reply-To: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only distinct use is checking if NETIF_F_NOCACHE_COPY should be
enabled by default. The check heuristics is altered a bit here,
so it hits other people than before. The default shouldn't be
trusted for performance-critical cases anyway.

=46or all other uses NETIF_F_NO_CSUM is equivalent to NETIF_F_HW_CSUM.

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
 include/linux/netdev_features.h |    5 ++---
 include/linux/skbuff.h          |    1 -
 net/bridge/br_device.c          |    4 ++--
 net/core/dev.c                  |   21 ++++++---------------
 net/core/ethtool.c              |    1 -
 14 files changed, 19 insertions(+), 31 deletions(-)

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
index ac5337a..25a44d94 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4361,7 +4361,7 @@ static void bond_setup(struct net_device *bond_de=
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
index 25695bd..120f1ab 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -454,7 +454,7 @@ static void can_setup(struct net_device *dev)
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
index a979b00..3f1ebcc 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -387,7 +387,7 @@ static void slc_setup(struct net_device *dev)
=20
 	/* New-style flags. */
 	dev->flags		=3D IFF_NOARP;
-	dev->features           =3D NETIF_F_NO_CSUM;
+	dev->features           =3D NETIF_F_HW_CSUM;
 }
=20
 /******************************************
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index a7c5e88..087648e 100644
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
index 46b5f5f..e05b645 100644
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
index 726c790..c5170ff 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -271,7 +271,7 @@ static void veth_setup(struct net_device *dev)
 	dev->features |=3D NETIF_F_LLTX;
 	dev->destructor =3D veth_dev_free;
=20
-	dev->hw_features =3D NETIF_F_NO_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
+	dev->hw_features =3D NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
 }
=20
 /*
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
index 20e3a1f..77f5202 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -17,7 +17,7 @@ typedef u64 netdev_features_t;
 enum {
 	NETIF_F_SG_BIT,			/* Scatter/gather IO. */
 	NETIF_F_IP_CSUM_BIT,		/* Can checksum TCP/UDP over IPv4. */
-	NETIF_F_NO_CSUM_BIT,		/* Does not require checksum. F.e. loopack. */
+	__UNUSED_NETIF_F_1,
 	NETIF_F_HW_CSUM_BIT,		/* Can checksum all the packets. */
 	NETIF_F_IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over IPV6 */
 	NETIF_F_HIGHDMA_BIT,		/* Can DMA to high memory. */
@@ -88,7 +88,6 @@ enum {
 #define NETIF_F_LRO		__NETIF_F(LRO)
 #define NETIF_F_NETNS_LOCAL	__NETIF_F(NETNS_LOCAL)
 #define NETIF_F_NOCACHE_COPY	__NETIF_F(NOCACHE_COPY)
-#define NETIF_F_NO_CSUM		__NETIF_F(NO_CSUM)
 #define NETIF_F_NTUPLE		__NETIF_F(NTUPLE)
 #define NETIF_F_RXCSUM		__NETIF_F(RXCSUM)
 #define NETIF_F_RXHASH		__NETIF_F(RXHASH)
@@ -118,7 +117,7 @@ enum {
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
 				 NETIF_F_TSO6 | NETIF_F_UFO)
=20
-#define NETIF_F_GEN_CSUM	(NETIF_F_HW_CSUM | NETIF_F_NO_CSUM)
+#define NETIF_F_GEN_CSUM	NETIF_F_HW_CSUM
 #define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
 #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a10e487..b931173 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -88,7 +88,6 @@
  *	at device setup time.
  *	NETIF_F_HW_CSUM	- it is clever device, it is able to checksum
  *			  everything.
- *	NETIF_F_NO_CSUM - loopback or reliable single hop media.
  *	NETIF_F_IP_CSUM - device is dumb. It is able to csum only
  *			  TCP/UDP over IPv4. Sigh. Vendors like this
  *			  way by an unknown reason. Though, see comment above
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 772bad3..a3754ac 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -342,10 +342,10 @@ void br_dev_setup(struct net_device *dev)
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
index 7b69568..7fd048a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5366,12 +5366,6 @@ static netdev_features_t netdev_fix_features(str=
uct net_device *dev,
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
@@ -5628,11 +5622,12 @@ int register_netdevice(struct net_device *dev)
 	dev->wanted_features =3D dev->features & dev->hw_features;
=20
 	/* Turn on no cache copy if HW is doing checksum */
-	dev->hw_features |=3D NETIF_F_NOCACHE_COPY;
-	if ((dev->features & NETIF_F_ALL_CSUM) &&
-	    !(dev->features & NETIF_F_NO_CSUM)) {
-		dev->wanted_features |=3D NETIF_F_NOCACHE_COPY;
-		dev->features |=3D NETIF_F_NOCACHE_COPY;
+	if (!(dev->flags & IFF_LOOPBACK)) {
+		dev->hw_features |=3D NETIF_F_NOCACHE_COPY;
+		if (dev->features & NETIF_F_ALL_CSUM) {
+			dev->wanted_features |=3D NETIF_F_NOCACHE_COPY;
+			dev->features |=3D NETIF_F_NOCACHE_COPY;
+		}
 	}
=20
 	/* Make NETIF_F_HIGHDMA inheritable to VLAN devices.
@@ -6378,10 +6373,6 @@ netdev_features_t netdev_increment_features(netd=
ev_features_t all,
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
index bbf84fe..d2eff9e 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -43,7 +43,6 @@ EXPORT_SYMBOL(ethtool_op_get_link);
 static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GS=
TRING_LEN] =3D {
 	[NETIF_F_SG_BIT] =3D               "tx-scatter-gather",
 	[NETIF_F_IP_CSUM_BIT] =3D          "tx-checksum-ipv4",
-	[NETIF_F_NO_CSUM_BIT] =3D          "tx-checksum-unneeded",
 	[NETIF_F_HW_CSUM_BIT] =3D          "tx-checksum-ip-generic",
 	[NETIF_F_IPV6_CSUM_BIT] =3D        "tx-checksum-ipv6",
 	[NETIF_F_HIGHDMA_BIT] =3D          "highdma",
--=20
1.7.7.1
