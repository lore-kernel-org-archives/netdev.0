From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 36/42] gadget: convert devices to new API
Date: Tue, 06 Jan 2009 16:33:52 -0800
Message-ID: <20090107003349.373645990@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	David Brownell <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60716 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757020AbZAGAyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:14 -0500
Content-Disposition: inline; filename=gadget.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/usb/gadget/u_ether.c	2009-01-04 22:14:36.959037978 -0800
+++ b/drivers/usb/gadget/u_ether.c	2009-01-04 22:18:45.758033254 -0800
@@ -716,6 +716,14 @@ static int __init get_ether_addr(const c
 
 static struct eth_dev *the_dev;
 
+static const struct net_device_ops eth_netdev_ops = {
+	.ndo_open		= eth_open,
+	.ndo_stop		= eth_stop,
+	.ndo_start_xmit		= eth_start_xmit,
+	.ndo_change_mtu		= ueth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 /**
  * gether_setup - initialize one ethernet-over-usb link
@@ -764,12 +772,8 @@ int __init gether_setup(struct usb_gadge
 	if (ethaddr)
 		memcpy(ethaddr, dev->host_mac, ETH_ALEN);
 
-	net->change_mtu = ueth_change_mtu;
-	net->hard_start_xmit = eth_start_xmit;
-	net->open = eth_open;
-	net->stop = eth_stop;
-	/* watchdog_timeo, tx_timeout ... */
-	/* set_multicast_list */
+	net->netdev_ops = &eth_netdev_ops;
+
 	SET_ETHTOOL_OPS(net, &ops);
 
 	/* two kinds of host-initiated state changes:

-- 

