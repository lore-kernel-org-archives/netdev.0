From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 31/77] usbnet: convert sms95xx driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:58 -0700
Message-ID: <20090321053714.885523813@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36611 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760936AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usb-smsc95.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/usb/smsc95xx.c	2009-03-20 12:11:35.646901516 -0700
+++ b/drivers/net/usb/smsc95xx.c	2009-03-20 12:16:51.582901740 -0700
@@ -1008,6 +1008,18 @@ static int smsc95xx_reset(struct usbnet 
 	return 0;
 }
 
+static const struct net_device_ops smsc95xx_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl 		= smsc95xx_ioctl,
+	.ndo_set_multicast_list = smsc95xx_set_multicast,
+};
+
 static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct smsc95xx_priv *pdata = NULL;
@@ -1038,9 +1050,8 @@ static int smsc95xx_bind(struct usbnet *
 	/* Init all registers */
 	ret = smsc95xx_reset(dev);
 
-	dev->net->do_ioctl = smsc95xx_ioctl;
+	dev->net->netdev_ops = &smsc95xx_netdev_ops;
 	dev->net->ethtool_ops = &smsc95xx_ethtool_ops;
-	dev->net->set_multicast_list = smsc95xx_set_multicast;
 	dev->net->flags |= IFF_MULTICAST;
 	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD;
 	return 0;

-- 

