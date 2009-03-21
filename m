From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 61/77] raylan: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:28 -0700
Message-ID: <20090321053717.204864141@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>, coreythomas@charter.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36736 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760301AbZCUFs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:29 -0400
Content-Disposition: inline; filename=ray_cs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wireless/ray_cs.c	2009-03-20 22:14:19.352839145 -0700
+++ b/drivers/net/wireless/ray_cs.c	2009-03-20 22:25:55.863652814 -0700
@@ -298,6 +298,19 @@ static char hop_pattern_length[] = { 1,
 static char rcsid[] =
     "Raylink/WebGear wireless LAN - Corey <Thomas corey@world.std.com>";
 
+static const struct net_device_ops ray_netdev_ops = {
+	.ndo_init 		= ray_dev_init,
+	.ndo_open 		= ray_open,
+	.ndo_stop 		= ray_dev_close,
+	.ndo_start_xmit		= ray_dev_start_xmit,
+	.ndo_set_config		= ray_dev_config,
+	.ndo_get_stats		= ray_get_stats,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*=============================================================================
     ray_attach() creates an "instance" of the driver, allocating
     local data structures for one device.  The device is registered
@@ -347,9 +360,7 @@ static int ray_probe(struct pcmcia_devic
 	      p_dev, dev, local, &ray_interrupt);
 
 	/* Raylink entries in the device structure */
-	dev->hard_start_xmit = &ray_dev_start_xmit;
-	dev->set_config = &ray_dev_config;
-	dev->get_stats = &ray_get_stats;
+	dev->netdev_ops = &ray_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->wireless_handlers = &ray_handler_def;
 #ifdef WIRELESS_SPY
@@ -357,12 +368,8 @@ static int ray_probe(struct pcmcia_devic
 	dev->wireless_data = &local->wireless_data;
 #endif /* WIRELESS_SPY */
 
-	dev->set_multicast_list = &set_multicast_list;
 
 	DEBUG(2, "ray_cs ray_attach calling ether_setup.)\n");
-	dev->init = &ray_dev_init;
-	dev->open = &ray_open;
-	dev->stop = &ray_dev_close;
 	netif_stop_queue(dev);
 
 	init_timer(&local->timer);

-- 

