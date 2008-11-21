From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 18/22] hamachi: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:56 -0800
Message-ID: <20081121232240.417398289@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57065 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755298AbYKUXXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:35 -0500
Content-Disposition: inline; filename=hamachi.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/hamachi.c	2008-11-21 14:34:32.000000000 -0800
+++ b/drivers/net/hamachi.c	2008-11-21 14:37:20.000000000 -0800
@@ -568,6 +568,19 @@ static void set_rx_mode(struct net_devic
 static const struct ethtool_ops ethtool_ops;
 static const struct ethtool_ops ethtool_ops_no_mii;
 
+static const struct net_device_ops hamachi_netdev_ops = {
+	.ndo_open		= hamachi_open,
+	.ndo_stop		= hamachi_close,
+	.ndo_start_xmit		= hamachi_start_xmit,
+	.ndo_get_stats		= hamachi_get_stats,
+	.ndo_set_multicast_list	= set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_tx_timeout		= hamachi_tx_timeout,
+	.ndo_do_ioctl		= netdev_ioctl,
+};
+
+
 static int __devinit hamachi_init_one (struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
@@ -722,17 +735,11 @@ static int __devinit hamachi_init_one (s
 
 
 	/* The Hamachi-specific entries in the device structure. */
-	dev->open = &hamachi_open;
-	dev->hard_start_xmit = &hamachi_start_xmit;
-	dev->stop = &hamachi_close;
-	dev->get_stats = &hamachi_get_stats;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &netdev_ioctl;
+	dev->netdev_ops = &hamachi_netdev_ops;
 	if (chip_tbl[hmp->chip_id].flags & CanHaveMII)
 		SET_ETHTOOL_OPS(dev, &ethtool_ops);
 	else
 		SET_ETHTOOL_OPS(dev, &ethtool_ops_no_mii);
-	dev->tx_timeout = &hamachi_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	if (mtu)
 		dev->mtu = mtu;

-- 

