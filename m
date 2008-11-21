From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/22] dl2k: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:47 -0800
Message-ID: <20081121232239.655518464@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57028 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754556AbYKUXXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:20 -0500
Content-Disposition: inline; filename=dl2k-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/dl2k.c	2008-11-21 13:51:10.000000000 -0800
+++ b/drivers/net/dl2k.c	2008-11-21 13:56:40.000000000 -0800
@@ -85,6 +85,19 @@ static int mii_write (struct net_device 
 
 static const struct ethtool_ops ethtool_ops;
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= rio_open,
+	.ndo_start_xmit	= start_xmit,
+	.ndo_stop		= rio_close,
+	.ndo_get_stats		= get_stats,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_multicast_list = set_multicast,
+	.ndo_do_ioctl		= rio_ioctl,
+	.ndo_tx_timeout		= rio_tx_timeout,
+	.ndo_change_mtu		= change_mtu,
+};
+
 static int __devinit
 rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -197,15 +210,8 @@ rio_probe1 (struct pci_dev *pdev, const 
 		else if (tx_coalesce > TX_RING_SIZE-1)
 			tx_coalesce = TX_RING_SIZE - 1;
 	}
-	dev->open = &rio_open;
-	dev->hard_start_xmit = &start_xmit;
-	dev->stop = &rio_close;
-	dev->get_stats = &get_stats;
-	dev->set_multicast_list = &set_multicast;
-	dev->do_ioctl = &rio_ioctl;
-	dev->tx_timeout = &rio_tx_timeout;
+	dev->netdev_ops = &netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->change_mtu = &change_mtu;
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 #if 0
 	dev->features = NETIF_F_IP_CSUM;

-- 

