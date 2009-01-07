From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 20/42] natsemi: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:36 -0800
Message-ID: <20090107003347.571857284@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59035 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756484AbZAGAxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:44 -0500
Content-Disposition: inline; filename=natsemi.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/natsemi.c	2009-01-05 16:37:41.039070167 -0800
+++ b/drivers/net/natsemi.c	2009-01-05 17:22:10.793568537 -0800
@@ -779,6 +779,22 @@ static void __devinit natsemi_init_media
 
 }
 
+static const struct net_device_ops natsemi_netdev_ops = {
+	.ndo_open		= netdev_open,
+	.ndo_stop		= netdev_close,
+	.ndo_start_xmit		= start_tx,
+	.ndo_get_stats		= get_stats,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_change_mtu		= natsemi_change_mtu,
+	.ndo_do_ioctl		= netdev_ioctl,
+	.ndo_tx_timeout 	= ns_tx_timeout,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= natsemi_poll_controller,
+#endif
+};
+
 static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
@@ -911,20 +927,9 @@ static int __devinit natsemi_probe1 (str
 	if (find_cnt < MAX_UNITS  &&  full_duplex[find_cnt])
 		np->full_duplex = 1;
 
-	/* The chip-specific entries in the device structure. */
-	dev->open = &netdev_open;
-	dev->hard_start_xmit = &start_tx;
-	dev->stop = &netdev_close;
-	dev->get_stats = &get_stats;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->change_mtu = &natsemi_change_mtu;
-	dev->do_ioctl = &netdev_ioctl;
-	dev->tx_timeout = &ns_tx_timeout;
+	dev->netdev_ops = &natsemi_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = &natsemi_poll_controller;
-#endif
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 
 	if (mtu)

-- 

