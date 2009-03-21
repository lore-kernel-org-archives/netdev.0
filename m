From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 24/77] usbnet: convert rtl driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:51 -0700
Message-ID: <20090321053714.361988448@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36586 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760901AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usb-rtl.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/usb/rtl8150.c	2009-03-20 12:12:47.085715442 -0700
+++ b/drivers/net/usb/rtl8150.c	2009-03-20 12:13:41.757841762 -0700
@@ -891,6 +891,19 @@ static int rtl8150_ioctl(struct net_devi
 	return res;
 }
 
+static const struct net_device_ops rtl8150_netdev_ops = {
+	.ndo_open		= rtl8150_open,
+	.ndo_stop		= rtl8150_close,
+	.ndo_do_ioctl		= rtl8150_ioctl,
+	.ndo_start_xmit		= rtl8150_start_xmit,
+	.ndo_tx_timeout 	= rtl8150_tx_timeout,
+	.ndo_set_multicast_list = rtl8150_set_multicast,
+	.ndo_set_mac_address	= rtl8150_set_mac_address,
+
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int rtl8150_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
@@ -917,15 +930,8 @@ static int rtl8150_probe(struct usb_inte
 	
 	dev->udev = udev;
 	dev->netdev = netdev;
-	netdev->open = rtl8150_open;
-	netdev->stop = rtl8150_close;
-	netdev->do_ioctl = rtl8150_ioctl;
+	netdev->netdev_ops = &rtl8150_netdev_ops;
 	netdev->watchdog_timeo = RTL8150_TX_TIMEOUT;
-	netdev->tx_timeout = rtl8150_tx_timeout;
-	netdev->hard_start_xmit = rtl8150_start_xmit;
-	netdev->set_multicast_list = rtl8150_set_multicast;
-	netdev->set_mac_address = rtl8150_set_mac_address;
-
 	SET_ETHTOOL_OPS(netdev, &ops);
 	dev->intr_interval = 100;	/* 100ms */
 

-- 

