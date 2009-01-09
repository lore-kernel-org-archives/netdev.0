From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 15/45] 3c505: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:12 -0800
Message-ID: <20090109230137.819142727@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, philb@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44939 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755928AbZAIXT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:19:29 -0500
Content-Disposition: inline; filename=3c505.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/3c505.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

--- a/drivers/net/3c505.c	2009-01-08 13:40:02.000000000 -0800
+++ b/drivers/net/3c505.c	2009-01-09 10:02:54.000000000 -0800
@@ -1348,6 +1348,17 @@ static int __init elp_autodetect(struct 
 	return 0;		/* Because of this, the layer above will return -ENODEV */
 }
 
+static const struct net_device_ops elp_netdev_ops = {
+	.ndo_open		= elp_open,
+	.ndo_stop		= elp_close,
+	.ndo_get_stats 		= elp_get_stats,
+	.ndo_start_xmit		= elp_start_xmit,
+	.ndo_tx_timeout 	= elp_timeout,
+	.ndo_set_multicast_list = elp_set_mc_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 /******************************************************
  *
@@ -1552,13 +1563,8 @@ static int __init elplus_setup(struct ne
 		printk(KERN_ERR "%s: adapter configuration failed\n", dev->name);
 	}
 
-	dev->open = elp_open;				/* local */
-	dev->stop = elp_close;				/* local */
-	dev->get_stats = elp_get_stats;			/* local */
-	dev->hard_start_xmit = elp_start_xmit;		/* local */
-	dev->tx_timeout = elp_timeout;			/* local */
+	dev->netdev_ops = &elp_netdev_ops;
 	dev->watchdog_timeo = 10*HZ;
-	dev->set_multicast_list = elp_set_mc_list;	/* local */
 	dev->ethtool_ops = &netdev_ethtool_ops;		/* local */
 
 	dev->mem_start = dev->mem_end = 0;


