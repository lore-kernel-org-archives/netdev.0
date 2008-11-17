From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/33] ifb: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:12 -0800
Message-ID: <20081117234355.203116784@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55046 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbYKQX77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 18:59:59 -0500
Content-Disposition: inline; filename=ifb-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ifb.c	2008-11-02 09:43:24.000000000 -0800
+++ b/drivers/net/ifb.c	2008-11-02 10:06:17.000000000 -0800
@@ -137,18 +137,23 @@ resched:
 
 }
 
+static const struct net_device_ops ifb_netdev_ops = {
+	.validate_addr = eth_validate_addr,
+	.open	= ifb_open,
+	.stop	= ifb_close,
+};
+
 static void ifb_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
 	dev->hard_start_xmit = ifb_xmit;
-	dev->open = &ifb_open;
-	dev->stop = &ifb_close;
 	dev->destructor = free_netdev;
+	dev->netdev_ops = &ifb_netdev_ops;
 
 	/* Fill in device structure with ethernet-generic values. */
 	ether_setup(dev);
 	dev->tx_queue_len = TX_Q_LIMIT;
-	dev->change_mtu = NULL;
+
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
 	random_ether_addr(dev->dev_addr);

-- 

