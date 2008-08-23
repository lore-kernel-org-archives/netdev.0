From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] net/usb/mcs7830: new device IDs
Date: Sat, 23 Aug 2008 22:02:23 +0200
Message-ID: <200808232202.23822.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Viktor Horvath <ViktorHorvath@gmx.net>,
	Robbert Wethmar <robbert@wethmar.nl>,
	Bart van der Klip <bklip@xs4all.nl>,
	Jeff Garzik <jgarzik@pobox.com>
To: David Brownell <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:58832 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874AbYHWUOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 16:14:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds USB device IDs for MosChip 7730 and Sitecom LN030
to the mcs7830 driver. The IDs have been reported to work without
further modifications.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: David Brownell <david-b@pacbell.net>
Cc: Viktor Horvath <ViktorHorvath@gmx.net>
Cc: Robbert Wethmar <robbert@wethmar.nl>
Cc: Bart van der Klip <bklip@xs4all.nl>

--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -46,6 +46,10 @@
 
 #define MCS7830_VENDOR_ID	0x9710
 #define MCS7830_PRODUCT_ID	0x7830
+#define MCS7730_PRODUCT_ID	0x7730
+
+#define SITECOM_VENDOR_ID	0x0DF6
+#define LN_030_PRODUCT_ID	0x0021
 
 #define MCS7830_MII_ADVERTISE	(ADVERTISE_PAUSE_CAP | ADVERTISE_100FULL | \
 				 ADVERTISE_100HALF | ADVERTISE_10FULL | \
@@ -491,7 +495,16 @@ static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 }
 
 static const struct driver_info moschip_info = {
-	.description	= "MOSCHIP 7830 usb-NET adapter",
+	.description	= "MOSCHIP 7830/7730 usb-NET adapter",
+	.bind		= mcs7830_bind,
+	.rx_fixup	= mcs7830_rx_fixup,
+	.flags		= FLAG_ETHER,
+	.in		= 1,
+	.out		= 2,
+};
+
+static const struct driver_info sitecom_info = {
+	.description    = "Sitecom LN-30 usb-NET adapter",
 	.bind		= mcs7830_bind,
 	.rx_fixup	= mcs7830_rx_fixup,
 	.flags		= FLAG_ETHER,
@@ -504,6 +517,14 @@ static const struct usb_device_id products[] = {
 		USB_DEVICE(MCS7830_VENDOR_ID, MCS7830_PRODUCT_ID),
 		.driver_info = (unsigned long) &moschip_info,
 	},
+	{
+		USB_DEVICE(MCS7830_VENDOR_ID, MCS7730_PRODUCT_ID),
+		.driver_info = (unsigned long) &moschip_info,
+	},
+	{
+		USB_DEVICE(SITECOM_VENDOR_ID, LN_030_PRODUCT_ID),
+		.driver_info = (unsigned long) &sitecom_info,
+	},
 	{},
 };
 MODULE_DEVICE_TABLE(usb, products);

