From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 34/77] pcmcia: convert 3c589 to net_device_ops
Date: Fri, 20 Mar 2009 22:36:01 -0700
Message-ID: <20090321053715.114984260@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36603 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760921AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=3c589.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcmcia/3c589_cs.c	2009-03-20 15:23:42.903968610 -0700
+++ b/drivers/net/pcmcia/3c589_cs.c	2009-03-20 15:29:37.743901982 -0700
@@ -169,6 +169,19 @@ static void tc589_detach(struct pcmcia_d
 
 ======================================================================*/
 
+static const struct net_device_ops el3_netdev_ops = {
+	.ndo_open 		= el3_open,
+	.ndo_stop 		= el3_close,
+	.ndo_start_xmit		= el3_start_xmit,
+	.ndo_tx_timeout 	= el3_tx_timeout,
+	.ndo_set_config		= el3_config,
+	.ndo_get_stats		= el3_get_stats,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int tc589_probe(struct pcmcia_device *link)
 {
     struct el3_private *lp;
@@ -195,17 +208,9 @@ static int tc589_probe(struct pcmcia_dev
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
 
-    /* The EL3-specific entries in the device structure. */
-    dev->hard_start_xmit = &el3_start_xmit;
-    dev->set_config = &el3_config;
-    dev->get_stats = &el3_get_stats;
-    dev->set_multicast_list = &set_multicast_list;
-    dev->open = &el3_open;
-    dev->stop = &el3_close;
-#ifdef HAVE_TX_TIMEOUT
-    dev->tx_timeout = el3_tx_timeout;
+    dev->netdev_ops = &el3_netdev_ops;
     dev->watchdog_timeo = TX_TIMEOUT;
-#endif
+
     SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 
     return tc589_config(link);

-- 

