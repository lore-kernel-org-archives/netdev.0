From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 21/42] fealnx: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:37 -0800
Message-ID: <20090107003347.691234582@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59050 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756725AbZAGAxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:54 -0500
Content-Disposition: inline; filename=fealnx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/fealnx.c	2009-01-05 16:37:40.999073216 -0800
+++ b/drivers/net/fealnx.c	2009-01-05 16:54:57.478318812 -0800
@@ -467,6 +467,18 @@ static void stop_nic_rxtx(void __iomem *
 	}
 }
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= netdev_open,
+	.ndo_stop		= netdev_close,
+	.ndo_start_xmit		= start_tx,
+	.ndo_get_stats 		= get_stats,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_do_ioctl		= mii_ioctl,
+	.ndo_tx_timeout		= fealnx_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 static int __devinit fealnx_init_one(struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
@@ -649,15 +661,8 @@ static int __devinit fealnx_init_one(str
 		np->mii.force_media = 1;
 	}
 
-	/* The chip-specific entries in the device structure. */
-	dev->open = &netdev_open;
-	dev->hard_start_xmit = &start_tx;
-	dev->stop = &netdev_close;
-	dev->get_stats = &get_stats;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &mii_ioctl;
+	dev->netdev_ops = &netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	dev->tx_timeout = &fealnx_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	err = register_netdev(dev);

-- 

