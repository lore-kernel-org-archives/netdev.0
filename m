From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 41/45] yam: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:38 -0800
Message-ID: <20090109230139.766864365@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, jpr@f6fbb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42315 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755379AbZAIXSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:20 -0500
Content-Disposition: inline; filename=yam-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/hamradio/yam.c	2009-01-09 12:54:25.000000000 -0800
+++ b/drivers/net/hamradio/yam.c	2009-01-09 12:54:26.000000000 -0800
@@ -1044,6 +1044,14 @@ static int yam_set_mac_address(struct ne
 
 /* --------------------------------------------------------------------- */
 
+static const struct net_device_ops yam_netdev_ops = {
+	.ndo_open	     = yam_open,
+	.ndo_stop	     = yam_close,
+	.ndo_start_xmit      = yam_send_packet,
+	.ndo_do_ioctl 	     = yam_ioctl,
+	.ndo_set_mac_address = yam_set_mac_address,
+};
+
 static void yam_setup(struct net_device *dev)
 {
 	struct yam_port *yp = netdev_priv(dev);
@@ -1064,18 +1072,11 @@ static void yam_setup(struct net_device 
 	dev->base_addr = yp->iobase;
 	dev->irq = yp->irq;
 
-	dev->open = yam_open;
-	dev->stop = yam_close;
-	dev->do_ioctl = yam_ioctl;
-	dev->hard_start_xmit = yam_send_packet;
-	dev->get_stats = yam_get_stats;
-
 	skb_queue_head_init(&yp->send_queue);
 
+	dev->netdev_ops = &yam_netdev_ops;
 	dev->header_ops = &ax25_header_ops;
 
-	dev->set_mac_address = yam_set_mac_address;
-
 	dev->type = ARPHRD_AX25;
 	dev->hard_header_len = AX25_MAX_HEADER_LEN;
 	dev->mtu = AX25_MTU;


