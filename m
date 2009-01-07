From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 14/42] enc28j60: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:30 -0800
Message-ID: <20090107003346.940014842@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59027 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754246AbZAGAxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:38 -0500
Content-Disposition: inline; filename=enc28j60.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/enc28j60.c	2009-01-05 09:43:14.970576391 -0800
+++ b/drivers/net/enc28j60.c	2009-01-05 09:46:16.138139560 -0800
@@ -1529,6 +1529,17 @@ static int enc28j60_chipset_init(struct 
 	return enc28j60_hw_init(priv);
 }
 
+static const struct net_device_ops enc28j60_netdev_ops = {
+	.ndo_open		= enc28j60_net_open,
+	.ndo_stop		= enc28j60_net_close,
+	.ndo_start_xmit		= enc28j60_send_packet,
+	.ndo_set_multicast_list = enc28j60_set_multicast_list,
+	.ndo_set_mac_address	= enc28j60_set_mac_address,
+	.ndo_tx_timeout		= enc28j60_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit enc28j60_probe(struct spi_device *spi)
 {
 	struct net_device *dev;
@@ -1583,12 +1594,7 @@ static int __devinit enc28j60_probe(stru
 
 	dev->if_port = IF_PORT_10BASET;
 	dev->irq = spi->irq;
-	dev->open = enc28j60_net_open;
-	dev->stop = enc28j60_net_close;
-	dev->hard_start_xmit = enc28j60_send_packet;
-	dev->set_multicast_list = &enc28j60_set_multicast_list;
-	dev->set_mac_address = enc28j60_set_mac_address;
-	dev->tx_timeout = &enc28j60_tx_timeout;
+	dev->netdev_ops = &enc28j60_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	SET_ETHTOOL_OPS(dev, &enc28j60_ethtool_ops);
 

-- 

