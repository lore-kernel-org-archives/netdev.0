From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 17/42] sis190: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:33 -0800
Message-ID: <20090107003347.229708019@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59025 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756183AbZAGAxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:36 -0500
Content-Disposition: inline; filename=sis190.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sis190.c	2009-01-05 11:06:13.882579097 -0800
+++ b/drivers/net/sis190.c	2009-01-05 11:09:18.773568969 -0800
@@ -1782,6 +1782,21 @@ static int sis190_ioctl(struct net_devic
 		generic_mii_ioctl(&tp->mii_if, if_mii(ifr), cmd, NULL);
 }
 
+static const struct net_device_ops sis190_netdev_ops = {
+	.ndo_open		= sis190_open,
+	.ndo_stop		= sis190_close,
+	.ndo_do_ioctl		= sis190_ioctl,
+	.ndo_start_xmit		= sis190_start_xmit,
+	.ndo_tx_timeout		= sis190_tx_timeout,
+	.ndo_set_multicast_list = sis190_set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	 = sis190_netpoll,
+#endif
+};
+
 static int __devinit sis190_init_one(struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
@@ -1815,19 +1830,12 @@ static int __devinit sis190_init_one(str
 
 	INIT_WORK(&tp->phy_task, sis190_phy_task);
 
-	dev->open = sis190_open;
-	dev->stop = sis190_close;
-	dev->do_ioctl = sis190_ioctl;
-	dev->tx_timeout = sis190_tx_timeout;
-	dev->watchdog_timeo = SIS190_TX_TIMEOUT;
-	dev->hard_start_xmit = sis190_start_xmit;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = sis190_netpoll;
-#endif
-	dev->set_multicast_list = sis190_set_rx_mode;
+	dev->netdev_ops = &sis190_netdev_ops;
+
 	SET_ETHTOOL_OPS(dev, &sis190_ethtool_ops);
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) 0xdead;
+	dev->watchdog_timeo = SIS190_TX_TIMEOUT;
 
 	spin_lock_init(&tp->lock);
 

-- 

