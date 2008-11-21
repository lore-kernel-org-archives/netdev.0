From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 16/22] ns83820: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:54 -0800
Message-ID: <20081121232240.249738168@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57055 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754949AbYKUXX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:28 -0500
Content-Disposition: inline; filename=ns83820.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ns83820.c	2008-11-21 14:28:24.000000000 -0800
+++ b/drivers/net/ns83820.c	2008-11-21 14:31:10.000000000 -0800
@@ -1948,7 +1948,19 @@ static void ns83820_probe_phy(struct net
 }
 #endif
 
-static int __devinit ns83820_init_one(struct pci_dev *pci_dev, const struct pci_device_id *id)
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= ns83820_open,
+	.ndo_stop		= ns83820_stop,
+	.ndo_start_xmit		= ns83820_hard_start_xmit,
+	.ndo_get_stats		= ns83820_get_stats,
+	.ndo_change_mtu		= ns83820_change_mtu,
+	.ndo_set_multicast_list = ns83820_set_multicast,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_tx_timeout		= ns83820_tx_timeout,
+};
+
+static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
+				      const struct pci_device_id *id)
 {
 	struct net_device *ndev;
 	struct ns83820 *dev;
@@ -2040,14 +2052,8 @@ static int __devinit ns83820_init_one(st
 		ndev->name, le32_to_cpu(readl(dev->base + 0x22c)),
 		pci_dev->subsystem_vendor, pci_dev->subsystem_device);
 
-	ndev->open = ns83820_open;
-	ndev->stop = ns83820_stop;
-	ndev->hard_start_xmit = ns83820_hard_start_xmit;
-	ndev->get_stats = ns83820_get_stats;
-	ndev->change_mtu = ns83820_change_mtu;
-	ndev->set_multicast_list = ns83820_set_multicast;
+	ndev->netdev_ops = &netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &ops);
-	ndev->tx_timeout = ns83820_tx_timeout;
 	ndev->watchdog_timeo = 5 * HZ;
 	pci_set_drvdata(pci_dev, ndev);
 

-- 

