From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 25/45] lanstreamer: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:22 -0800
Message-ID: <20090109230138.556765106@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42219 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754020AbZAIXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:58 -0500
Content-Disposition: inline; filename=tr-lanstream.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tokenring/lanstreamer.c	2009-01-09 10:06:09.000000000 -0800
+++ b/drivers/net/tokenring/lanstreamer.c	2009-01-09 10:06:55.000000000 -0800
@@ -221,6 +221,18 @@ struct streamer_private *dev_streamer=NU
 #endif
 #endif
 
+static const struct net_device_ops streamer_netdev_ops = {
+	.ndo_open		= streamer_open,
+	.ndo_stop		= streamer_close,
+	.ndo_start_xmit		= streamer_xmit,
+	.ndo_change_mtu		= streamer_change_mtu,
+#if STREAMER_IOCTL
+	.ndo_do_ioctl		= streamer_ioctl,
+#endif
+	.ndo_set_multicast_list = streamer_set_rx_mode,
+	.ndo_set_mac_address	= streamer_set_mac_address,
+};
+
 static int __devinit streamer_init_one(struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {
@@ -320,17 +332,7 @@ static int __devinit streamer_init_one(s
 	init_waitqueue_head(&streamer_priv->srb_wait);
 	init_waitqueue_head(&streamer_priv->trb_wait);
 
-	dev->open = &streamer_open;
-	dev->hard_start_xmit = &streamer_xmit;
-	dev->change_mtu = &streamer_change_mtu;
-	dev->stop = &streamer_close;
-#if STREAMER_IOCTL
-	dev->do_ioctl = &streamer_ioctl;
-#else
-	dev->do_ioctl = NULL;
-#endif
-	dev->set_multicast_list = &streamer_set_rx_mode;
-	dev->set_mac_address = &streamer_set_mac_address;
+	dev->netdev_ops = &streamer_netdev_ops;
 	dev->irq = pdev->irq;
 	dev->base_addr=pio_start;
 	SET_NETDEV_DEV(dev, &pdev->dev);


