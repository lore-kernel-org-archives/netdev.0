From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/42] sungem: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:27 -0800
Message-ID: <20090107003346.653177706@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59007 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755611AbZAGAxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:25 -0500
Content-Disposition: inline; filename=sungem.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sungem.c	2009-01-05 22:32:32.234069564 -0800
+++ b/drivers/net/sungem.c	2009-01-05 22:34:34.221571178 -0800
@@ -2989,6 +2989,19 @@ static void gem_remove_one(struct pci_de
 	}
 }
 
+static const struct net_device_ops gem_netdev_ops = {
+	.ndo_open		= gem_open,
+	.ndo_stop		= gem_close,
+	.ndo_start_xmit		= gem_start_xmit,
+	.ndo_get_stats		= gem_get_stats,
+	.ndo_set_multicast_list = gem_set_multicast,
+	.ndo_do_ioctl		= gem_ioctl,
+	.ndo_tx_timeout		= gem_tx_timeout,
+	.ndo_change_mtu		= gem_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit gem_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -3142,17 +3155,10 @@ static int __devinit gem_init_one(struct
 	if (gem_get_device_address(gp))
 		goto err_out_free_consistent;
 
-	dev->open = gem_open;
-	dev->stop = gem_close;
-	dev->hard_start_xmit = gem_start_xmit;
-	dev->get_stats = gem_get_stats;
-	dev->set_multicast_list = gem_set_multicast;
-	dev->do_ioctl = gem_ioctl;
+	dev->netdev_ops = &gem_netdev_ops;
 	netif_napi_add(dev, &gp->napi, gem_poll, 64);
 	dev->ethtool_ops = &gem_ethtool_ops;
-	dev->tx_timeout = gem_tx_timeout;
 	dev->watchdog_timeo = 5 * HZ;
-	dev->change_mtu = gem_change_mtu;
 	dev->irq = pdev->irq;
 	dev->dma = 0;
 	dev->set_mac_address = gem_set_mac_address;

-- 

