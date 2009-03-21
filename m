From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 58/77] wavelan: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:25 -0700
Message-ID: <20090321053716.965014826@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>, jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:50129 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762084AbZCUFwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:52:30 -0400
Content-Disposition: inline; filename=wavelan-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wireless/wavelan_cs.c	2009-03-20 22:16:50.602027068 -0700
+++ b/drivers/net/wireless/wavelan_cs.c	2009-03-20 22:25:51.618651474 -0700
@@ -4436,6 +4436,19 @@ wavelan_close(struct net_device *	dev)
   return 0;
 }
 
+static const struct net_device_ops wavelan_netdev_ops = {
+	.ndo_open 		= wavelan_open,
+	.ndo_stop		= wavelan_close,
+	.ndo_start_xmit		= wavelan_packet_xmit,
+	.ndo_set_multicast_list = wavelan_set_multicast_list,
+#ifdef SET_MAC_ADDRESS
+	.ndo_set_mac_address	= wavelan_set_mac_address,
+#endif
+	.ndo_tx_timeout		= wavelan_watchdog,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*------------------------------------------------------------------*/
 /*
  * wavelan_attach() creates an "instance" of the driver, allocating
@@ -4496,16 +4509,7 @@ wavelan_probe(struct pcmcia_device *p_de
   lp->dev = dev;
 
   /* wavelan NET3 callbacks */
-  dev->open = &wavelan_open;
-  dev->stop = &wavelan_close;
-  dev->hard_start_xmit = &wavelan_packet_xmit;
-  dev->set_multicast_list = &wavelan_set_multicast_list;
-#ifdef SET_MAC_ADDRESS
-  dev->set_mac_address = &wavelan_set_mac_address;
-#endif	/* SET_MAC_ADDRESS */
-
-  /* Set the watchdog timer */
-  dev->tx_timeout	= &wavelan_watchdog;
+  dev->netdev_ops = &wavelan_netdev_ops;
   dev->watchdog_timeo	= WATCHDOG_JIFFIES;
   SET_ETHTOOL_OPS(dev, &ops);
 

-- 

