From: Christian Hesse <mail@eworm.de>
Subject: [PATCH 1/1] net/usb/r8152: add device id for Lenovo TP USB 3.0 Ethernet
Date: Tue, 31 Mar 2015 14:10:07 +0200
Message-ID: <1427803807-6334-1-git-send-email-mail@eworm.de>
Cc: Christian Hesse <mail@eworm.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:50739 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbbCaMKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 08:10:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device is sold as 'Lenovo Tinkpad USB 3.0 Ethernet 4X90E51405'.
Chipset is RTL8153 and works with r8152.

Signed-off-by: Christian Hesse <mail@eworm.de>
---
 drivers/net/usb/cdc_ether.c | 8 ++++++++
 drivers/net/usb/r8152.c     | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 9311a08..4545e78 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -522,6 +522,7 @@ static const struct driver_info wwan_info = {
 #define DELL_VENDOR_ID		0x413C
 #define REALTEK_VENDOR_ID	0x0bda
 #define SAMSUNG_VENDOR_ID	0x04e8
+#define LENOVO_VENDOR_ID	0x17ef
 
 static const struct usb_device_id	products[] = {
 /* BLACKLIST !!
@@ -702,6 +703,13 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+/* Lenovo Thinkpad USB 3.0 Ethernet Adapters (based on Realtek RTL8153) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(LENOVO_VENDOR_ID, 0x7205, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* WHITELIST!!!
  *
  * CDC Ether uses two interfaces, not necessarily consecutive.
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 438fc6b..9f7c0ab 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -492,6 +492,7 @@ enum rtl8152_flags {
 /* Define these values to match your device */
 #define VENDOR_ID_REALTEK		0x0bda
 #define VENDOR_ID_SAMSUNG		0x04e8
+#define VENDOR_ID_LENOVO		0x17ef
 
 #define MCU_TYPE_PLA			0x0100
 #define MCU_TYPE_USB			0x0000
@@ -4037,6 +4038,7 @@ static struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
 	{}
 };
 
-- 
2.3.4
