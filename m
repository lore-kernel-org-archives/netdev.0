From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/8] virtio: convert to net_device_ops
Date: Mon, 05 Jan 2009 12:14:47 -0800
Message-ID: <20090105201514.658060465@vyatta.com>
References: <20090105201442.749889072@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35284 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011AbZAEUZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 15:25:08 -0500
Content-Disposition: inline; filename=virtio.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/virtio_net.c	2009-01-05 11:24:44.578819161 -0800
+++ b/drivers/net/virtio_net.c	2009-01-05 12:11:17.169569416 -0800
@@ -624,6 +624,18 @@ static int virtnet_change_mtu(struct net
 	return 0;
 }
 
+static const struct net_device_ops virtnet_netdev = {
+	.ndo_open            = virtnet_open,
+	.ndo_stop   	     = virtnet_close,
+	.ndo_start_xmit      = start_xmit,
+	.ndo_validate_addr   = eth_validate_addr,
+	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_change_mtu	     = virtnet_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = virtnet_netpoll,
+#endif
+};
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int err;
@@ -636,14 +648,8 @@ static int virtnet_probe(struct virtio_d
 		return -ENOMEM;
 
 	/* Set up network device as normal. */
-	dev->open = virtnet_open;
-	dev->stop = virtnet_close;
-	dev->hard_start_xmit = start_xmit;
-	dev->change_mtu = virtnet_change_mtu;
+	dev->netdev_ops = &virtnet_netdev;
 	dev->features = NETIF_F_HIGHDMA;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = virtnet_netpoll;
-#endif
 	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
 	SET_NETDEV_DEV(dev, &vdev->dev);
 

-- 

