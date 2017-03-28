From: Rene Rebe <rene@exactcode.com>
Subject: [PATCH] r8152: The Microsoft Surface docks also use R8152 v2
Date: Tue, 28 Mar 2017 07:56:51 +0200 (CEST)
Message-ID: <20170328.075651.1863370888471526975.rene@exactcode.com>
References: <20160113.154941.1886033351271894428.davem@davemloft.net>
        <20170328.064215.1055636797214516339.rene@exactcode.com>
        <1490893565.24247.9.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, netdev@vger.kernel.org, nic_swsd@realtek.com
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.exactcode.de ([144.76.154.42]:50328 "EHLO mx.exactcode.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754586AbdC3U5T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 16:57:19 -0400
In-Reply-To: <1490893565.24247.9.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this the generic cdc_ether grabs the device,
and does not really work.

Signed-off-by: René Rebe <rene@exactcode.de>

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index f5552aa..f3ae88f 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -532,6 +532,7 @@ static const struct driver_info wwan_info = {
 #define LENOVO_VENDOR_ID	0x17ef
 #define NVIDIA_VENDOR_ID	0x0955
 #define HP_VENDOR_ID		0x03f0
+#define MICROSOFT_VENDOR_ID	0x045e
 
 static const struct usb_device_id	products[] = {
 /* BLACKLIST !!
@@ -761,6 +762,20 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+/* Microsoft Surface 2 dock (based on Realtek RTL8152) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(MICROSOFT_VENDOR_ID, 0x07ab, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
+/* Microsoft Surface 3 dock (based on Realtek RTL8153) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(MICROSOFT_VENDOR_ID, 0x07c6, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* WHITELIST!!!
  *
  * CDC Ether uses two interfaces, not necessarily consecutive.
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c34df33..07f788c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -517,6 +517,7 @@ enum rtl8152_flags {
 
 /* Define these values to match your device */
 #define VENDOR_ID_REALTEK		0x0bda
+#define VENDOR_ID_MICROSOFT		0x045e
 #define VENDOR_ID_SAMSUNG		0x04e8
 #define VENDOR_ID_LENOVO		0x17ef
 #define VENDOR_ID_NVIDIA		0x0955
@@ -4521,6 +4522,8 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 static struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07ab)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07c6)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x3062)},

-- 
  René Rebe, ExactCODE GmbH, Lietzenburger Str. 42, DE-10789 Berlin
  http://exactcode.com | http://t2-project.org | http://rene.rebe.de
