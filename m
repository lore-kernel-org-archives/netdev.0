From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next 2/3] net: fullly using NETIF_F_GSO_SOFTWARE macros
 and NETIF_F_SOFT_FEATURES
Date: Fri, 22 Apr 2011 19:07:45 +0800
Message-ID: <4DB16181.9010306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, rusty@rustcorp.com.au,
	mst@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49399 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754563Ab1DVLLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2011 07:11:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fullly using NETIF_F_GSO_SOFTWARE and NETIF_F_SOFT_FEATURES.
And some code style tuning. Just compile test.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/loopback.c   |   14 +++++---------
 drivers/net/macvlan.c    |    4 ++--
 drivers/net/tun.c        |    5 ++---
 drivers/net/virtio_net.c |    5 ++---
 4 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index d70fb76..0d6b6ba 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -165,16 +165,12 @@ static void loopback_setup(struct net_device *dev)
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
-	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
+	dev->hw_features	= NETIF_F_GSO_SOFTWARE;
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
-		| NETIF_F_ALL_TSO
-		| NETIF_F_UFO
-		| NETIF_F_NO_CSUM
-		| NETIF_F_RXCSUM
-		| NETIF_F_HIGHDMA
-		| NETIF_F_LLTX
-		| NETIF_F_NETNS_LOCAL
-		| NETIF_F_VLAN_CHALLENGED;
+				  | NETIF_F_GSO_SOFTWARE | NETIF_F_NO_CSUM
+				  | NETIF_F_RXCSUM | NETIF_F_HIGHDMA
+				  | NETIF_F_LLTX | NETIF_F_NETNS_LOCAL
+				  | NETIF_F_VLAN_CHALLENGED;
 	dev->ethtool_ops	= &loopback_ethtool_ops;
 	dev->header_ops		= &eth_header_ops;
 	dev->netdev_ops		= &loopback_ops;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3ad5425..a9095af 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -414,8 +414,8 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
-	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
-	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM)
+	 NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | NETIF_F_SOFT_FEATURES | \
+	 NETIF_F_RXCSUM)
 
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ade3cf9..0aca641 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -124,8 +124,7 @@ struct tun_struct {
 
 	struct net_device	*dev;
 	u32			set_features;
-#define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
-			  NETIF_F_TSO6|NETIF_F_UFO)
+#define TUN_USER_FEATURES (NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE)
 	struct fasync_struct	*fasync;
 
 	struct tap_filter       txflt;
@@ -1106,7 +1105,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		}
 
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
-			TUN_USER_FEATURES;
+				   TUN_USER_FEATURES;
 		dev->features = dev->hw_features;
 
 		err = register_netdevice(tun->dev);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0cb0b06..133419a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -904,8 +904,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
 
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
-			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
-				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
+			dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 		}
 		/* Individual feature bits: what can host handle? */
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO4))
@@ -918,7 +917,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->hw_features |= NETIF_F_UFO;
 
 		if (gso)
-			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
+			dev->features |= dev->hw_features & NETIF_F_GSO_SOFTWARE;
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 
-- 
1.6.3.3
