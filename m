From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 15/22] yellowfin: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:53 -0800
Message-ID: <20081121232240.165931916@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57053 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755066AbYKUXX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:27 -0500
Content-Disposition: inline; filename=yellowfin.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/yellowfin.c	2008-11-21 14:25:38.000000000 -0800
+++ b/drivers/net/yellowfin.c	2008-11-21 14:27:54.000000000 -0800
@@ -355,6 +355,16 @@ static int yellowfin_close(struct net_de
 static void set_rx_mode(struct net_device *dev);
 static const struct ethtool_ops ethtool_ops;
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open 		= yellowfin_open,
+	.ndo_stop 		= yellowfin_close,
+	.ndo_start_xmit 	= yellowfin_start_xmit,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl 		= netdev_ioctl,
+	.ndo_tx_timeout 	= yellowfin_tx_timeout,
+};
 
 static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 					const struct pci_device_id *ent)
@@ -464,13 +474,8 @@ static int __devinit yellowfin_init_one(
 		np->duplex_lock = 1;
 
 	/* The Yellowfin-specific entries in the device structure. */
-	dev->open = &yellowfin_open;
-	dev->hard_start_xmit = &yellowfin_start_xmit;
-	dev->stop = &yellowfin_close;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &netdev_ioctl;
+	dev->netdev_ops = &netdev_ops;
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
-	dev->tx_timeout = yellowfin_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	if (mtu)

-- 

