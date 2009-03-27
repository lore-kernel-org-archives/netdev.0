From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 03/30] uml: convert network device to netdevice ops
Date: Thu, 26 Mar 2009 18:11:17 -0700
Message-ID: <20090327011255.168951778@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, jdike@addtoit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39797 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752985AbZC0BWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:22:40 -0400
Content-Disposition: inline; filename=uml-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/arch/um/drivers/net_kern.c	2009-03-22 21:11:51.000000000 -0700
+++ b/arch/um/drivers/net_kern.c	2009-03-22 21:17:17.920674346 -0700
@@ -371,6 +371,18 @@ static void net_device_release(struct de
 	free_netdev(netdev);
 }
 
+static const struct net_device_ops uml_netdev_ops = {
+	.ndo_open 		= uml_net_open,
+	.ndo_stop 		= uml_net_close,
+	.ndo_start_xmit 	= uml_net_start_xmit,
+	.ndo_set_multicast_list = uml_net_set_multicast_list,
+	.ndo_tx_timeout 	= uml_net_tx_timeout,
+	.ndo_set_mac_address	= uml_net_set_mac,
+	.ndo_change_mtu 	= uml_net_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*
  * Ensures that platform_driver_register is called only once by
  * eth_configure.  Will be set in an initcall.
@@ -467,13 +479,7 @@ static void eth_configure(int n, void *i
 
 	set_ether_mac(dev, device->mac);
 	dev->mtu = transport->user->mtu;
-	dev->open = uml_net_open;
-	dev->hard_start_xmit = uml_net_start_xmit;
-	dev->stop = uml_net_close;
-	dev->set_multicast_list = uml_net_set_multicast_list;
-	dev->tx_timeout = uml_net_tx_timeout;
-	dev->set_mac_address = uml_net_set_mac;
-	dev->change_mtu = uml_net_change_mtu;
+	dev->netdev_ops = &uml_netdev_ops;
 	dev->ethtool_ops = &uml_net_ethtool_ops;
 	dev->watchdog_timeo = (HZ >> 1);
 	dev->irq = UM_ETH_IRQ;


