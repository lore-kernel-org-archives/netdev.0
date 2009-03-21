From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 33/77] usbnet: convert rndis driver to net_device_ops
Date: Fri, 20 Mar 2009 22:36:00 -0700
Message-ID: <20090321053715.035583259@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36619 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760979AbZCUFsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:17 -0400
Content-Disposition: inline; filename=rndis-host.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/usb/rndis_host.c	2009-03-20 12:18:22.041027638 -0700
+++ b/drivers/net/usb/rndis_host.c	2009-03-20 12:27:20.541841282 -0700
@@ -266,6 +266,16 @@ response_error:
 	return -EDOM;
 }
 
+/* same as usbnet_netdev_ops but MTU change not allowed */
+static const struct net_device_ops rndis_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 int
 generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 {
@@ -327,7 +337,8 @@ generic_rndis_bind(struct usbnet *dev, s
 	dev->rx_urb_size &= ~(dev->maxpacket - 1);
 	u.init->max_transfer_size = cpu_to_le32(dev->rx_urb_size);
 
-	net->change_mtu = NULL;
+	net->netdev_ops = &rndis_netdev_ops;
+
 	retval = rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
 		/* it might not even be an RNDIS device!! */

-- 

