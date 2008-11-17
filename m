From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/33] dummy: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:13 -0800
Message-ID: <20081117234355.289357416@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55049 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023AbYKRAAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:00 -0500
Content-Disposition: inline; filename=dummy-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/dummy.c	2008-11-02 09:43:24.000000000 -0800
+++ b/drivers/net/dummy.c	2008-11-02 10:06:15.000000000 -0800
@@ -57,18 +57,23 @@ static void set_multicast_list(struct ne
 {
 }
 
+static const struct net_device_ops dummy_netdev_ops = {
+	.validate_addr = eth_validate_addr,
+	.set_multicast_list = set_multicast_list,
+	.set_mac_address = dummy_set_address,
+};
+
 static void dummy_setup(struct net_device *dev)
 {
+	ether_setup(dev);
+
 	/* Initialize the device structure. */
+	dev->netdev_ops = &dummy_netdev_ops;
 	dev->hard_start_xmit = dummy_xmit;
-	dev->set_multicast_list = set_multicast_list;
-	dev->set_mac_address = dummy_set_address;
 	dev->destructor = free_netdev;
 
 	/* Fill in device structure with ethernet-generic values. */
-	ether_setup(dev);
 	dev->tx_queue_len = 0;
-	dev->change_mtu = NULL;
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
 	random_ether_addr(dev->dev_addr);

-- 

