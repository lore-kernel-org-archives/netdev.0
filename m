From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 63/77] wl3501: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:30 -0700
Message-ID: <20090321053717.363149406@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36742 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761275AbZCUFse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:34 -0400
Content-Disposition: inline; filename=wl3501-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wireless/wl3501_cs.c	2009-03-20 22:25:57.381964610 -0700
+++ b/drivers/net/wireless/wl3501_cs.c	2009-03-20 22:25:59.099652050 -0700
@@ -1883,6 +1883,16 @@ static const struct iw_handler_def wl350
 	.get_wireless_stats = wl3501_get_wireless_stats,
 };
 
+static const struct net_device_ops wl3501_netdev_ops = {
+	.ndo_open		= wl3501_open,
+	.ndo_stop		= wl3501_close,
+	.ndo_start_xmit		= wl3501_hard_start_xmit,
+	.ndo_tx_timeout		= wl3501_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /**
  * wl3501_attach - creates an "instance" of the driver
  *
@@ -1917,17 +1927,14 @@ static int wl3501_probe(struct pcmcia_de
 		goto out_link;
 
 
-	dev->open		= wl3501_open;
-	dev->stop		= wl3501_close;
-	dev->hard_start_xmit	= wl3501_hard_start_xmit;
-	dev->tx_timeout		= wl3501_tx_timeout;
+	dev->netdev_ops		= &wl3501_netdev_ops;
 	dev->watchdog_timeo	= 5 * HZ;
 
 	this = netdev_priv(dev);
 	this->wireless_data.spy_data = &this->spy_data;
 	this->p_dev = p_dev;
 	dev->wireless_data	= &this->wireless_data;
-	dev->wireless_handlers	= (struct iw_handler_def *)&wl3501_handler_def;
+	dev->wireless_handlers	= &wl3501_handler_def;
 	SET_ETHTOOL_OPS(dev, &ops);
 	netif_stop_queue(dev);
 	p_dev->priv = p_dev->irq.Instance = dev;

-- 

