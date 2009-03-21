From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 41/77] xirc2ps: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:08 -0700
Message-ID: <20090321053715.645025053@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36629 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760991AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=xirc2ps.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/pcmcia/xirc2ps_cs.c	2009-03-20 21:55:40.069839509 -0700
+++ b/drivers/net/pcmcia/xirc2ps_cs.c	2009-03-20 21:56:27.343715110 -0700
@@ -545,6 +545,19 @@ mii_wr(unsigned int ioaddr, u_char phyad
 
 /*============= Main bulk of functions	=========================*/
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= do_open,
+	.ndo_stop		= do_stop,
+	.ndo_start_xmit		= do_start_xmit,
+	.ndo_tx_timeout 	= xirc_tx_timeout,
+	.ndo_set_config		= do_config,
+	.ndo_do_ioctl		= do_ioctl,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /****************
  * xirc2ps_attach() creates an "instance" of the driver, allocating
  * local data structures for one device.  The device is registered
@@ -580,18 +593,10 @@ xirc2ps_probe(struct pcmcia_device *link
     link->irq.Instance = dev;
 
     /* Fill in card specific entries */
-    dev->hard_start_xmit = &do_start_xmit;
-    dev->set_config = &do_config;
-    dev->do_ioctl = &do_ioctl;
-    SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
-    dev->set_multicast_list = &set_multicast_list;
-    dev->open = &do_open;
-    dev->stop = &do_stop;
-#ifdef HAVE_TX_TIMEOUT
-    dev->tx_timeout = xirc_tx_timeout;
+    dev->netdev_ops = &netdev_ops;
+    dev->ethtool_ops = &netdev_ethtool_ops;
     dev->watchdog_timeo = TX_TIMEOUT;
     INIT_WORK(&local->tx_timeout_task, xirc2ps_tx_timeout_task);
-#endif
 
     return xirc2ps_config(link);
 } /* xirc2ps_attach */

-- 

