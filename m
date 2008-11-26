From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 04/14] smc: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:23 -0800
Message-ID: <20081126011545.505564954@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58790 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbYKZBSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:48 -0500
Content-Disposition: inline; filename=smc-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert both eisa and mca versions of this driver, though I doubt
anyone still has the hardware.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/smc-mca.c	2008-11-25 16:23:38.000000000 -0800
+++ b/drivers/net/smc-mca.c	2008-11-25 16:41:33.000000000 -0800
@@ -182,6 +182,22 @@ static char *smc_mca_adapter_names[] __i
 
 static int ultra_found = 0;
 
+
+static const struct net_device_ops ultra_netdev_ops = {
+	.ndo_open		= ultramca_open,
+	.ndo_stop		= ultramca_close_card,
+
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller 	= ei_poll,
+#endif
+};
+
 static int __init ultramca_probe(struct device *gen_dev)
 {
 	unsigned short ioaddr;
@@ -384,11 +400,7 @@ static int __init ultramca_probe(struct 
 
 	ei_status.priv = slot;
 
-	dev->open = &ultramca_open;
-	dev->stop = &ultramca_close_card;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+	dev->netdev_ops = &ultramca_netdev_ops;
 
 	NS8390_init(dev, 0);
 
--- a/drivers/net/smc-ultra.c	2008-11-25 16:23:38.000000000 -0800
+++ b/drivers/net/smc-ultra.c	2008-11-25 16:41:33.000000000 -0800
@@ -187,6 +187,21 @@ out:
 }
 #endif
 
+static const struct net_device_ops ultra_netdev_ops = {
+	.ndo_open		= ultra_open,
+	.ndo_stop		= ultra_close_card,
+
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller 	= ei_poll,
+#endif
+};
+
 static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, retval;
@@ -300,11 +315,8 @@ static int __init ultra_probe1(struct ne
 		ei_status.get_8390_hdr = &ultra_get_8390_hdr;
 	}
 	ei_status.reset_8390 = &ultra_reset_8390;
-	dev->open = &ultra_open;
-	dev->stop = &ultra_close_card;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+
+	dev->netdev_ops = &ultra_netdev_ops;
 	NS8390_init(dev, 0);
 
 	retval = register_netdev(dev);


