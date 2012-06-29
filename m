From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next v2 2/4] virtio_net: use IFF_LIVE_ADDR_CHANGE priv_flag
Date: Fri, 29 Jun 2012 17:10:06 +0200
Message-ID: <1340982608-897-3-git-send-email-jpirko@redhat.com>
References: <1340982608-897-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	danny.kukawka@bisect.de, shimoda.hiroaki@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755912Ab2F2PKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 11:10:20 -0400
In-Reply-To: <1340982608-897-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/virtio_net.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 36a16d5..1db445b 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -679,12 +679,11 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct virtio_device *vdev = vi->vdev;
-	struct sockaddr *addr = p;
+	int ret;
 
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
-	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
+	ret = eth_mac_addr(dev, p);
+	if (ret)
+		return ret;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
 		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
@@ -1063,7 +1062,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		return -ENOMEM;
 
 	/* Set up network device as normal. */
-	dev->priv_flags |= IFF_UNICAST_FLT;
+	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
 	dev->netdev_ops = &virtnet_netdev;
 	dev->features = NETIF_F_HIGHDMA;
 
-- 
1.7.10.4
