From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 16/42] de600: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:32 -0800
Message-ID: <20090107003347.155432544@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59029 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877AbZAGAxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:42 -0500
Content-Disposition: inline; filename=de620.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/de600.c	2009-01-05 09:57:00.313823290 -0800
+++ b/drivers/net/de600.c	2009-01-05 09:58:37.145589173 -0800
@@ -378,6 +378,16 @@ static void de600_rx_intr(struct net_dev
 	 */
 }
 
+static const struct net_device_ops de600_netdev_ops = {
+	.ndo_open		= de600_open,
+	.ndo_stop		= de600_close,
+	.ndo_start_xmit		= de600_start_xmit,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+
 static struct net_device * __init de600_probe(void)
 {
 	int	i;
@@ -439,9 +449,7 @@ static struct net_device * __init de600_
 
 	printk(", Ethernet Address: %pM\n", dev->dev_addr);
 
-	dev->open = de600_open;
-	dev->stop = de600_close;
-	dev->hard_start_xmit = &de600_start_xmit;
+	dev->netdev_ops = &de600_netdev_ops;
 
 	dev->flags&=~IFF_MULTICAST;
 
--- a/drivers/net/de620.c	2009-01-05 09:54:40.509573827 -0800
+++ b/drivers/net/de620.c	2009-01-05 09:56:31.049569488 -0800
@@ -784,6 +784,17 @@ static int adapter_init(struct net_devic
 	return 0; /* all ok */
 }
 
+static const struct net_device_ops de620_netdev_ops = {
+	.ndo_open 		= de620_open,
+	.ndo_stop 		= de620_close,
+	.ndo_start_xmit 	= de620_start_xmit,
+	.ndo_tx_timeout 	= de620_timeout,
+	.ndo_set_multicast_list = de620_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /******************************************************************************
  *
  * Only start-up code below
@@ -861,12 +872,8 @@ struct net_device * __init de620_probe(i
 	else
 		printk(" UTP)\n");
 
-	dev->open 		= de620_open;
-	dev->stop 		= de620_close;
-	dev->hard_start_xmit 	= de620_start_xmit;
-	dev->tx_timeout 	= de620_timeout;
+	dev->netdev_ops = &de620_netdev_ops;
 	dev->watchdog_timeo	= HZ*2;
-	dev->set_multicast_list = de620_set_multicast_list;
 
 	/* base_addr and irq are already set, see above! */
 

-- 

