From: Jay Purohit <jspurohit@velocitylimitless.com>
Subject: [PATCH] Add support for iPhone 5, iPad 2 GSM/CDMA, iPad 3 GSM/CDMA to ipheth.
Date: Thu, 11 Oct 2012 17:32:51 -0500
Message-ID: <CADx9NEfxMVbjaDAsv9rcBwRayw9Jk-Ff2SbA7Z+TF0VCPJoj0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:39068 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756793Ab2JKWcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 18:32:52 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so2388022vbb.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 15:32:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces support for all devices which
officially/unofficially support
tethering over the USB connection.

This is a revision of the iPhone 5 ipheth support patch.

Signed-off-by: Jay Purohit <jspurohit@velocitylimitless.com>

diff -uprN ../old/linux-3.6.1/drivers/net/usb/ipheth.c
./drivers/net/usb/ipheth.c
--- ../old/linux-3.6.1/drivers/net/usb/ipheth.c	2012-10-07
10:41:28.000000000 -0500
+++ ./drivers/net/usb/ipheth.c	2012-10-11 17:28:39.862329304 -0500
@@ -55,13 +55,28 @@
 #include <linux/workqueue.h>

 #define USB_VENDOR_APPLE        0x05ac
+
+/*
+ * Please add the supported VID/PID for devices that support tethering here.
+ *
+ * Note: iPod touches starting with the 3G do actually support USB ethernet,
+ *       however implementing support for it in this driver would be useless,
+ *       as there is no external interface for it to bridge with on device.
+ */
+
 #define USB_PRODUCT_IPHONE      0x1290
 #define USB_PRODUCT_IPHONE_3G   0x1292
 #define USB_PRODUCT_IPHONE_3GS  0x1294
 #define USB_PRODUCT_IPHONE_4	0x1297
-#define USB_PRODUCT_IPAD 0x129a
 #define USB_PRODUCT_IPHONE_4_VZW 0x129c
 #define USB_PRODUCT_IPHONE_4S	0x12a0
+#define USB_PRODUCT_IPHONE_5	0x12a8
+
+#define USB_PRODUCT_IPAD	0x129a
+#define USB_PRODUCT_IPAD_2_GSM	0x12a2
+#define USB_PRODUCT_IPAD_2_CDMA	0x12a3
+#define USB_PRODUCT_IPAD_3_GSM	0x12a4
+#define USB_PRODUCT_IPAD_3_CDMA	0x12a5

 #define IPHETH_USBINTF_CLASS    255
 #define IPHETH_USBINTF_SUBCLASS 253
@@ -106,6 +121,22 @@ static struct usb_device_id ipheth_table
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
 	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPAD_2_GSM,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPAD_2_CDMA,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPAD_3_GSM,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPAD_3_CDMA,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
 		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4_VZW,
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
@@ -113,6 +144,10 @@ static struct usb_device_id ipheth_table
 		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4S,
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_5,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
 	{ }
 };
 MODULE_DEVICE_TABLE(usb, ipheth_table);
