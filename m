From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next] virtio_net: allow to change mac when iface is running
Date: Wed, 27 Jun 2012 17:27:46 +0200
Message-ID: <1340810866-1017-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756108Ab2F0P1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 11:27:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/virtio_net.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f18149a..36a16d5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -679,11 +679,12 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct virtio_device *vdev = vi->vdev;
-	int ret;
+	struct sockaddr *addr = p;
 
-	ret = eth_mac_addr(dev, p);
-	if (ret)
-		return ret;
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
 		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
-- 
1.7.10.4
