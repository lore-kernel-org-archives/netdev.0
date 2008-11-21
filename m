From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/22] via-rhine: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:43 -0800
Message-ID: <20081121232239.318895015@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57016 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754081AbYKUXXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:17 -0500
Content-Disposition: inline; filename=via-rhine.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/via-rhine.c	2008-11-20 22:07:15.000000000 -0800
+++ b/drivers/net/via-rhine.c	2008-11-20 22:21:59.000000000 -0800
@@ -614,6 +614,20 @@ static void __devinit rhine_hw_init(stru
 	rhine_reload_eeprom(pioaddr, dev);
 }
 
+static const struct net_device_ops rhine_netdev_ops = {
+	.ndo_open		 = rhine_open,
+	.ndo_stop		 = rhine_close,
+	.ndo_start_xmit		 = rhine_start_tx,
+	.ndo_get_stats		 = rhine_get_stats,
+	.ndo_set_multicast_list	 = rhine_set_rx_mode,
+	.ndo_validate_addr	 = eth_validate_addr,
+	.ndo_do_ioctl		 = netdev_ioctl,
+	.ndo_tx_timeout 	 = rhine_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	 = rhine_poll,
+#endif
+};
+
 static int __devinit rhine_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
@@ -764,18 +778,10 @@ static int __devinit rhine_init_one(stru
 	rp->mii_if.reg_num_mask = 0x1f;
 
 	/* The chip-specific entries in the device structure. */
-	dev->open = rhine_open;
-	dev->hard_start_xmit = rhine_start_tx;
-	dev->stop = rhine_close;
-	dev->get_stats = rhine_get_stats;
-	dev->set_multicast_list = rhine_set_rx_mode;
-	dev->do_ioctl = netdev_ioctl;
-	dev->ethtool_ops = &netdev_ethtool_ops;
-	dev->tx_timeout = rhine_tx_timeout;
+	dev->netdev_ops = &rhine_netdev_ops;
+	dev->ethtool_ops = &netdev_ethtool_ops,
 	dev->watchdog_timeo = TX_TIMEOUT;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = rhine_poll;
-#endif
+
 	netif_napi_add(dev, &rp->napi, rhine_napipoll, 64);
 
 	if (rp->quirks & rqRhineI)

-- 

