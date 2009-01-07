From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/42] epic100: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:25 -0800
Message-ID: <20090107003346.467466993@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59002 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456AbZAGAxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:23 -0500
Content-Disposition: inline; filename=epic100.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/epic100.c	2009-01-05 17:21:57.791070052 -0800
+++ b/drivers/net/epic100.c	2009-01-05 22:31:16.209590402 -0800
@@ -308,7 +308,18 @@ static int epic_close(struct net_device 
 static struct net_device_stats *epic_get_stats(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 
-
+static const struct net_device_ops epic_netdev_ops = {
+	.ndo_open		= epic_open,
+	.ndo_stop		= epic_close,
+	.ndo_start_xmit		= epic_start_xmit,
+	.ndo_tx_timeout 	= epic_tx_timeout,
+	.ndo_get_stats		= epic_get_stats,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_do_ioctl 		= netdev_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 static int __devinit epic_init_one (struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
@@ -483,15 +494,9 @@ static int __devinit epic_init_one (stru
 	dev->if_port = ep->default_port = option;
 
 	/* The Epic-specific entries in the device structure. */
-	dev->open = &epic_open;
-	dev->hard_start_xmit = &epic_start_xmit;
-	dev->stop = &epic_close;
-	dev->get_stats = &epic_get_stats;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &netdev_ioctl;
+	dev->netdev_ops = &epic_netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->tx_timeout = &epic_tx_timeout;
 	netif_napi_add(dev, &ep->napi, epic_poll, 64);
 
 	ret = register_netdev(dev);

-- 

