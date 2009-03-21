From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 35/77] pcmcia: convert 3c574 to net_device_ops
Date: Fri, 20 Mar 2009 22:36:02 -0700
Message-ID: <20090321053715.185896361@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36607 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760930AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=3c574.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcmcia/3c574_cs.c	2009-03-20 15:26:57.576028131 -0700
+++ b/drivers/net/pcmcia/3c574_cs.c	2009-03-20 15:32:44.545902019 -0700
@@ -257,6 +257,18 @@ static void tc574_detach(struct pcmcia_d
 	local data structures for one device.  The device is registered
 	with Card Services.
 */
+static const struct net_device_ops el3_netdev_ops = {
+	.ndo_open 		= el3_open,
+	.ndo_stop 		= el3_close,
+	.ndo_start_xmit		= el3_start_xmit,
+	.ndo_tx_timeout 	= el3_tx_timeout,
+	.ndo_get_stats		= el3_get_stats,
+	.ndo_do_ioctl		= el3_ioctl,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 static int tc574_probe(struct pcmcia_device *link)
 {
@@ -284,18 +296,9 @@ static int tc574_probe(struct pcmcia_dev
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
 
-	/* The EL3-specific entries in the device structure. */
-	dev->hard_start_xmit = &el3_start_xmit;
-	dev->get_stats = &el3_get_stats;
-	dev->do_ioctl = &el3_ioctl;
+	dev->netdev_ops = &el3_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
-	dev->set_multicast_list = &set_rx_mode;
-	dev->open = &el3_open;
-	dev->stop = &el3_close;
-#ifdef HAVE_TX_TIMEOUT
-	dev->tx_timeout = el3_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#endif
 
 	return tc574_config(link);
 } /* tc574_attach */

-- 

