From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/42] sunhme: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:26 -0800
Message-ID: <20090107003346.538220674@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59005 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755463AbZAGAxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:24 -0500
Content-Disposition: inline; filename=sunhme.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sunhme.c	2009-01-05 22:20:10.258069867 -0800
+++ b/drivers/net/sunhme.c	2009-01-05 22:24:21.754819916 -0800
@@ -2607,6 +2607,18 @@ static struct quattro * __devinit quattr
 }
 #endif /* CONFIG_PCI */
 
+static const struct net_device_ops hme_netdev_ops = {
+	.ndo_open		= happy_meal_open,
+	.ndo_stop		= happy_meal_close,
+	.ndo_start_xmit		= happy_meal_start_xmit,
+	.ndo_tx_timeout		= happy_meal_tx_timeout,
+	.ndo_get_stats		= happy_meal_get_stats,
+	.ndo_set_multicast_list = happy_meal_set_multicast,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 #ifdef CONFIG_SBUS
 static int __devinit happy_meal_sbus_probe_one(struct of_device *op, int is_qfe)
 {
@@ -2750,12 +2762,7 @@ static int __devinit happy_meal_sbus_pro
 	init_timer(&hp->happy_timer);
 
 	hp->dev = dev;
-	dev->open = &happy_meal_open;
-	dev->stop = &happy_meal_close;
-	dev->hard_start_xmit = &happy_meal_start_xmit;
-	dev->get_stats = &happy_meal_get_stats;
-	dev->set_multicast_list = &happy_meal_set_multicast;
-	dev->tx_timeout = &happy_meal_tx_timeout;
+	dev->netdev_ops = &hme_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
 	dev->ethtool_ops = &hme_ethtool_ops;
 
@@ -3076,12 +3083,7 @@ static int __devinit happy_meal_pci_prob
 	init_timer(&hp->happy_timer);
 
 	hp->dev = dev;
-	dev->open = &happy_meal_open;
-	dev->stop = &happy_meal_close;
-	dev->hard_start_xmit = &happy_meal_start_xmit;
-	dev->get_stats = &happy_meal_get_stats;
-	dev->set_multicast_list = &happy_meal_set_multicast;
-	dev->tx_timeout = &happy_meal_tx_timeout;
+	dev->netdev_ops = &hme_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
 	dev->ethtool_ops = &hme_ethtool_ops;
 	dev->irq = pdev->irq;

-- 

