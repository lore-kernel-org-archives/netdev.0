From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 29/77] usbnet: convert dms9601 driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:56 -0700
Message-ID: <20090321053714.737716531@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36600 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760790AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usb-dm9601.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/usb/dm9601.c	2009-03-20 12:11:35.703901588 -0700
+++ b/drivers/net/usb/dm9601.c	2009-03-20 12:16:05.744902076 -0700
@@ -419,6 +419,18 @@ static int dm9601_set_mac_address(struct
 	return 0;
 }
 
+static const struct net_device_ops dm9601_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl 		= dm9601_ioctl,
+	.ndo_set_multicast_list = dm9601_set_multicast,
+	.ndo_set_mac_address	= dm9601_set_mac_address,
+};
+
 static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
@@ -428,9 +440,7 @@ static int dm9601_bind(struct usbnet *de
 	if (ret)
 		goto out;
 
-	dev->net->do_ioctl = dm9601_ioctl;
-	dev->net->set_multicast_list = dm9601_set_multicast;
-	dev->net->set_mac_address = dm9601_set_mac_address;
+	dev->net->netdev_ops = &dm9601_netdev_ops;
 	dev->net->ethtool_ops = &dm9601_ethtool_ops;
 	dev->net->hard_header_len += DM_TX_OVERHEAD;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;

-- 

