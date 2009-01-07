From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 25/42] de2104x: convert to net_device_ops
Date: Tue, 06 Jan 2009 16:33:41 -0800
Message-ID: <20090107003348.195639787@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52742 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757647AbZAGA7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:59:16 -0500
Content-Disposition: inline; filename=tulip-de1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tulip/de2104x.c	2009-01-06 16:08:31.161363983 -0800
+++ b/drivers/net/tulip/de2104x.c	2009-01-06 16:14:57.956742918 -0800
@@ -1922,6 +1922,18 @@ bad_srom:
 	goto fill_defaults;
 }
 
+static const struct net_device_ops de_netdev_ops = {
+	.ndo_open		= de_open,
+	.ndo_stop		= de_close,
+	.ndo_set_multicast_list = de_set_rx_mode,
+	.ndo_start_xmit		= de_start_xmit,
+	.ndo_get_stats		= de_get_stats,
+	.ndo_tx_timeout 	= de_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit de_init_one (struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -1944,14 +1956,9 @@ static int __devinit de_init_one (struct
 	if (!dev)
 		return -ENOMEM;
 
+	dev->netdev_ops = &de_netdev_ops;
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	dev->open = de_open;
-	dev->stop = de_close;
-	dev->set_multicast_list = de_set_rx_mode;
-	dev->hard_start_xmit = de_start_xmit;
-	dev->get_stats = de_get_stats;
 	dev->ethtool_ops = &de_ethtool_ops;
-	dev->tx_timeout = de_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	de = netdev_priv(dev);

-- 

