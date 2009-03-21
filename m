From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 30/77] usbnet: convert msc7830 driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:57 -0700
Message-ID: <20090321053714.808098082@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36605 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760929AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usb-msc7830.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/usb/mcs7830.c	2009-03-20 12:11:35.680902515 -0700
+++ b/drivers/net/usb/mcs7830.c	2009-03-20 12:16:27.334776706 -0700
@@ -486,6 +486,18 @@ static int mcs7830_set_mac_address(struc
 	return 0;
 }
 
+static const struct net_device_ops mcs7830_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl 		= mcs7830_ioctl,
+	.ndo_set_multicast_list = mcs7830_set_multicast,
+	.ndo_set_mac_address	 = mcs7830_set_mac_address,
+};
+
 static int mcs7830_bind(struct usbnet *dev, struct usb_interface *udev)
 {
 	struct net_device *net = dev->net;
@@ -495,11 +507,9 @@ static int mcs7830_bind(struct usbnet *d
 	if (ret)
 		goto out;
 
-	net->do_ioctl = mcs7830_ioctl;
 	net->ethtool_ops = &mcs7830_ethtool_ops;
-	net->set_multicast_list = mcs7830_set_multicast;
+	net->netdev_ops = &mcs7830_netdev_ops;
 	mcs7830_set_multicast(net);
-	net->set_mac_address = mcs7830_set_mac_address;
 
 	/* reserve space for the status byte on rx */
 	dev->rx_urb_size = ETH_FRAME_LEN + 1;

-- 

