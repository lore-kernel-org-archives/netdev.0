From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 14/45] 3c501: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:11 -0800
Message-ID: <20090109230137.746974197@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42184 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007AbZAIXRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:55 -0500
Content-Disposition: inline; filename=3c501.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c501.c	2009-01-09 13:44:04.000000000 -0800
+++ b/drivers/net/3c501.c	2009-01-09 13:46:44.000000000 -0800
@@ -197,6 +197,17 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops el_netdev_ops = {
+	.ndo_open		= el_open,
+	.ndo_stop		= el1_close,
+	.ndo_start_xmit 	= el_start_xmit,
+	.ndo_tx_timeout		= el_timeout,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /**
  *	el1_probe1:
  *	@dev: The device structure to use
@@ -305,12 +316,8 @@ static int __init el1_probe1(struct net_
 	 *	The EL1-specific entries in the device structure.
 	 */
 
-	dev->open = &el_open;
-	dev->hard_start_xmit = &el_start_xmit;
-	dev->tx_timeout = &el_timeout;
+	dev->netdev_ops = &el_netdev_ops;
 	dev->watchdog_timeo = HZ;
-	dev->stop = &el1_close;
-	dev->set_multicast_list = &set_multicast_list;
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	return 0;
 }


