From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/9] defxx: convert driver to net_device_ops
Date: Thu, 20 Nov 2008 09:59:18 -0800
Message-ID: <20081120175933.921580158@vyatta.com>
References: <20081120175913.943543638@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53075 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752AbYKTSEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 13:04:13 -0500
Content-Disposition: inline; filename=defxx-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to net_device_ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/defxx.c	2008-11-19 22:10:52.000000000 -0800
+++ b/drivers/net/defxx.c	2008-11-20 09:18:52.000000000 -0800
@@ -477,6 +477,15 @@ static void dfx_get_bars(struct device *
 	}
 }
 
+static const struct net_device_ops dfx_netdev_ops = {
+	.ndo_open		= dfx_open,
+	.ndo_stop		= dfx_close,
+	.ndo_start_xmit		= dfx_xmt_queue_pkt,
+	.ndo_get_stats		= dfx_ctl_get_stats,
+	.ndo_set_multicast_list	= dfx_ctl_set_multicast_list,
+	.ndo_set_mac_address	= dfx_ctl_set_mac_address,
+};
+
 /*
  * ================
  * = dfx_register =
@@ -573,13 +582,7 @@ static int __devinit dfx_register(struct
 	}
 
 	/* Initialize new device structure */
-
-	dev->get_stats			= dfx_ctl_get_stats;
-	dev->open			= dfx_open;
-	dev->stop			= dfx_close;
-	dev->hard_start_xmit		= dfx_xmt_queue_pkt;
-	dev->set_multicast_list		= dfx_ctl_set_multicast_list;
-	dev->set_mac_address		= dfx_ctl_set_mac_address;
+	dev->netdev_ops			= &dfx_netdev_ops;
 
 	if (dfx_bus_pci)
 		pci_set_master(to_pci_dev(bdev));

-- 

