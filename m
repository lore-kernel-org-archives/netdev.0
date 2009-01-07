From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 23/42] sundance: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:39 -0800
Message-ID: <20090107003347.965927410@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59042 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756620AbZAGAxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:50 -0500
Content-Disposition: inline; filename=sundance.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sundance.c	2009-01-05 11:21:54.202319462 -0800
+++ b/drivers/net/sundance.c	2009-01-05 11:24:13.205569835 -0800
@@ -449,6 +449,19 @@ static void sundance_reset(struct net_de
 	}
 }
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= netdev_open,
+	.ndo_stop		= netdev_close,
+	.ndo_start_xmit		= start_tx,
+	.ndo_get_stats 		= get_stats,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_do_ioctl 		= netdev_ioctl,
+	.ndo_tx_timeout		= tx_timeout,
+	.ndo_change_mtu		= change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit sundance_probe1 (struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
@@ -530,16 +543,10 @@ static int __devinit sundance_probe1 (st
 	np->mii_if.reg_num_mask = 0x1f;
 
 	/* The chip-specific entries in the device structure. */
-	dev->open = &netdev_open;
-	dev->hard_start_xmit = &start_tx;
-	dev->stop = &netdev_close;
-	dev->get_stats = &get_stats;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &netdev_ioctl;
+	dev->netdev_ops = &netdev_ops;
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
-	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->change_mtu = &change_mtu;
+
 	pci_set_drvdata(pdev, dev);
 
 	i = register_netdev(dev);

-- 

