From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 43/77] smc91c92: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:10 -0700
Message-ID: <20090321053715.795022273@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36638 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760305AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=smc91c92-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/pcmcia/smc91c92_cs.c |   23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

--- a/drivers/net/pcmcia/smc91c92_cs.c	2009-03-20 16:07:00.765795319 -0700
+++ b/drivers/net/pcmcia/smc91c92_cs.c	2009-03-20 16:08:08.144027094 -0700
@@ -300,6 +300,19 @@ static void mdio_write(struct net_device
 static int smc_link_ok(struct net_device *dev);
 static const struct ethtool_ops ethtool_ops;
 
+static const struct net_device_ops smc_netdev_ops = {
+	.ndo_open		= smc_open,
+	.ndo_stop		= smc_close,
+	.ndo_start_xmit		= smc_start_xmit,
+	.ndo_tx_timeout 	= smc_tx_timeout,
+	.ndo_set_config 	= s9k_config,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_do_ioctl		= &smc_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*======================================================================
 
   smc91c92_attach() creates an "instance" of the driver, allocating
@@ -335,17 +348,9 @@ static int smc91c92_probe(struct pcmcia_
     link->conf.IntType = INT_MEMORY_AND_IO;
 
     /* The SMC91c92-specific entries in the device structure. */
-    dev->hard_start_xmit = &smc_start_xmit;
-    dev->set_config = &s9k_config;
-    dev->set_multicast_list = &set_rx_mode;
-    dev->open = &smc_open;
-    dev->stop = &smc_close;
-    dev->do_ioctl = &smc_ioctl;
+    dev->netdev_ops = &smc_netdev_ops;
     SET_ETHTOOL_OPS(dev, &ethtool_ops);
-#ifdef HAVE_TX_TIMEOUT
-    dev->tx_timeout = smc_tx_timeout;
     dev->watchdog_timeo = TX_TIMEOUT;
-#endif
 
     smc->mii_if.dev = dev;
     smc->mii_if.mdio_read = mdio_read;

-- 

