From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/8] xen-netfront: convert to net_device_ops
Date: Mon, 05 Jan 2009 12:14:48 -0800
Message-ID: <20090105201514.756248396@vyatta.com>
References: <20090105201442.749889072@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35293 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752524AbZAEU2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 15:28:22 -0500
Content-Disposition: inline; filename=xen-netfront.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert Xen device to new API.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/xen-netfront.c	2009-01-05 12:10:31.373819168 -0800
+++ b/drivers/net/xen-netfront.c	2009-01-05 12:11:22.754068943 -0800
@@ -1105,6 +1105,16 @@ static void xennet_uninit(struct net_dev
 	gnttab_free_grant_references(np->gref_rx_head);
 }
 
+static const struct net_device_ops xennet_netdev_ops = {
+	.ndo_open            = xennet_open,
+	.ndo_uninit          = xennet_uninit,
+	.ndo_stop            = xennet_close,
+	.ndo_start_xmit      = xennet_start_xmit,
+	.ndo_change_mtu	     = xennet_change_mtu,
+	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_validate_addr   = eth_validate_addr,
+};
+
 static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev)
 {
 	int i, err;
@@ -1161,12 +1171,9 @@ static struct net_device * __devinit xen
 		goto exit_free_tx;
 	}
 
-	netdev->open            = xennet_open;
-	netdev->hard_start_xmit = xennet_start_xmit;
-	netdev->stop            = xennet_close;
+	netdev->netdev_ops	= &xennet_netdev_ops;
+
 	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
-	netdev->uninit          = xennet_uninit;
-	netdev->change_mtu	= xennet_change_mtu;
 	netdev->features        = NETIF_F_IP_CSUM;
 
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);

-- 

