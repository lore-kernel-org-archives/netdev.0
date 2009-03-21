From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 38/77] pcmcia: convert nmclan driver to net_device_ops
Date: Fri, 20 Mar 2009 22:36:05 -0700
Message-ID: <20090321053715.420134725@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36620 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760980AbZCUFsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:17 -0400
Content-Disposition: inline; filename=nmclan-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcmcia/nmclan_cs.c	2009-03-20 15:37:15.711964534 -0700
+++ b/drivers/net/pcmcia/nmclan_cs.c	2009-03-20 15:39:12.895711532 -0700
@@ -436,6 +436,19 @@ static const struct ethtool_ops netdev_e
 
 static void nmclan_detach(struct pcmcia_device *p_dev);
 
+static const struct net_device_ops mace_netdev_ops = {
+	.ndo_open		= mace_open,
+	.ndo_stop		= mace_close,
+	.ndo_start_xmit		= mace_start_xmit,
+	.ndo_tx_timeout		= mace_tx_timeout,
+	.ndo_set_config		= mace_config,
+	.ndo_get_stats		= mace_get_stats,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* ----------------------------------------------------------------------------
 nmclan_attach
 	Creates an "instance" of the driver, allocating local data
@@ -474,17 +487,9 @@ static int nmclan_probe(struct pcmcia_de
 
     lp->tx_free_frames=AM2150_MAX_TX_FRAMES;
 
-    dev->hard_start_xmit = &mace_start_xmit;
-    dev->set_config = &mace_config;
-    dev->get_stats = &mace_get_stats;
-    dev->set_multicast_list = &set_multicast_list;
+    dev->netdev_ops = &mace_netdev_ops;
     SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
-    dev->open = &mace_open;
-    dev->stop = &mace_close;
-#ifdef HAVE_TX_TIMEOUT
-    dev->tx_timeout = mace_tx_timeout;
     dev->watchdog_timeo = TX_TIMEOUT;
-#endif
 
     return nmclan_config(link);
 } /* nmclan_attach */

-- 

