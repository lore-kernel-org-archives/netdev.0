From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 13/42] typhoon: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:29 -0800
Message-ID: <20090107003346.819560580@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59012 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755463AbZAGAx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:27 -0500
Content-Disposition: inline; filename=typhoon.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/typhoon.c	2009-01-05 22:40:41.830818586 -0800
+++ b/drivers/net/typhoon.c	2009-01-05 22:42:52.110068563 -0800
@@ -2296,6 +2296,19 @@ out:
 	return mode;
 }
 
+static const struct net_device_ops typhoon_netdev_ops = {
+	.ndo_open		= typhoon_open,
+	.ndo_stop		= typhoon_close,
+	.ndo_start_xmit		= typhoon_start_tx,
+	.ndo_set_multicast_list	= typhoon_set_rx_mode,
+	.ndo_tx_timeout		= typhoon_tx_timeout,
+	.ndo_get_stats		= typhoon_get_stats,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= typhoon_set_mac_address,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_vlan_rx_register	= typhoon_vlan_rx_register,
+};
+
 static int __devinit
 typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -2495,16 +2508,9 @@ typhoon_init_one(struct pci_dev *pdev, c
 	}
 
 	/* The chip-specific entries in the device structure. */
-	dev->open		= typhoon_open;
-	dev->hard_start_xmit	= typhoon_start_tx;
-	dev->stop		= typhoon_close;
-	dev->set_multicast_list	= typhoon_set_rx_mode;
-	dev->tx_timeout		= typhoon_tx_timeout;
+	dev->netdev_ops		= &typhoon_netdev_ops;
 	netif_napi_add(dev, &tp->napi, typhoon_poll, 16);
 	dev->watchdog_timeo	= TX_TIMEOUT;
-	dev->get_stats		= typhoon_get_stats;
-	dev->set_mac_address	= typhoon_set_mac_address;
-	dev->vlan_rx_register	= typhoon_vlan_rx_register;
 
 	SET_ETHTOOL_OPS(dev, &typhoon_ethtool_ops);
 

-- 

