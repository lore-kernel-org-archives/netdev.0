From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 37/77] pcmcia: convert fmvj18x driver to net_device_ops
Date: Fri, 20 Mar 2009 22:36:04 -0700
Message-ID: <20090321053715.337103339@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36614 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760959AbZCUFsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:17 -0400
Content-Disposition: inline; filename=fmv-netops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcmcia/fmvj18x_cs.c	2009-03-20 15:33:28.183090032 -0700
+++ b/drivers/net/pcmcia/fmvj18x_cs.c	2009-03-20 15:35:39.076839897 -0700
@@ -227,6 +227,18 @@ typedef struct local_info_t {
 #define BANK_1U              0x24 /* bank 1 (CONFIG_1) */
 #define BANK_2U              0x28 /* bank 2 (CONFIG_1) */
 
+static const struct net_device_ops fjn_netdev_ops = {
+	.ndo_open 		= fjn_open,
+	.ndo_stop		= fjn_close,
+	.ndo_start_xmit 	= fjn_start_xmit,
+	.ndo_tx_timeout 	= fjn_tx_timeout,
+	.ndo_set_config 	= fjn_config,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int fmvj18x_probe(struct pcmcia_device *link)
 {
     local_info_t *lp;
@@ -258,16 +270,9 @@ static int fmvj18x_probe(struct pcmcia_d
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
-    /* The FMVJ18x specific entries in the device structure. */
-    dev->hard_start_xmit = &fjn_start_xmit;
-    dev->set_config = &fjn_config;
-    dev->set_multicast_list = &set_rx_mode;
-    dev->open = &fjn_open;
-    dev->stop = &fjn_close;
-#ifdef HAVE_TX_TIMEOUT
-    dev->tx_timeout = fjn_tx_timeout;
+    dev->netdev_ops = &fjn_netdev_ops;
     dev->watchdog_timeo = TX_TIMEOUT;
-#endif
+
     SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 
     return fmvj18x_config(link);

-- 

