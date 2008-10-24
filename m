From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: runtime mac address change support
Date: Fri, 24 Oct 2008 09:08:27 +0200
Message-ID: <1224832107-6334-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:51034 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbYJXHIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 03:08:32 -0400
Received: by nf-out-0910.google.com with SMTP id d3so297808nfc.21
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2008 00:08:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement set_mac_address for runtime mac address change.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 78df2be..db3377d 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -396,6 +396,20 @@ static void dm9601_set_multicast(struct net_device *net)
 	dm_write_reg_async(dev, DM_RX_CTRL, rx_ctl);
 }
 
+static int dm9601_set_mac_address(struct net_device *net, void *p)
+{
+	struct sockaddr *addr = p;
+	struct usbnet *dev = netdev_priv(net);
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
+	dm_write_async(dev, DM_PHY_ADDR, net->addr_len, net->dev_addr);
+
+	return 0;
+}
+
 static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
@@ -406,6 +420,7 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	dev->net->do_ioctl = dm9601_ioctl;
 	dev->net->set_multicast_list = dm9601_set_multicast;
+	dev->net->set_mac_address = dm9601_set_mac_address;
 	dev->net->ethtool_ops = &dm9601_ethtool_ops;
 	dev->net->hard_header_len += DM_TX_OVERHEAD;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
-- 
1.5.6.5

