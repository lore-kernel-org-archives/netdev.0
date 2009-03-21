From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/77] irlan: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:35:34 -0700
Message-ID: <20090321053713.084967137@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36575 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760878AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irlan.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/irda/irlan/irlan_eth.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

--- a/net/irda/irlan/irlan_eth.c	2009-03-19 22:40:30.449963919 -0700
+++ b/net/irda/irlan/irlan_eth.c	2009-03-19 22:42:45.749902310 -0700
@@ -45,6 +45,16 @@ static int  irlan_eth_xmit(struct sk_buf
 static void irlan_eth_set_multicast_list( struct net_device *dev);
 static struct net_device_stats *irlan_eth_get_stats(struct net_device *dev);
 
+static const struct net_device_ops irlan_eth_netdev_ops = {
+	.ndo_open               = irlan_eth_open,
+	.ndo_stop               = irlan_eth_close,
+	.ndo_start_xmit    	= irlan_eth_xmit,
+	.ndo_get_stats	        = irlan_eth_get_stats,
+	.ndo_set_multicast_list = irlan_eth_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*
  * Function irlan_eth_setup (dev)
  *
@@ -53,14 +63,11 @@ static struct net_device_stats *irlan_et
  */
 static void irlan_eth_setup(struct net_device *dev)
 {
-	dev->open               = irlan_eth_open;
-	dev->stop               = irlan_eth_close;
-	dev->hard_start_xmit    = irlan_eth_xmit;
-	dev->get_stats	        = irlan_eth_get_stats;
-	dev->set_multicast_list = irlan_eth_set_multicast_list;
+	ether_setup(dev);
+
+	dev->netdev_ops		= &irlan_eth_netdev_ops;
 	dev->destructor		= free_netdev;
 
-	ether_setup(dev);
 
 	/*
 	 * Lets do all queueing in IrTTP instead of this device driver.

-- 

