From: Zheng Liu <zhliu@nvidia.com>
Subject: [PATCH net 1/1] drivers/net/usb: add device id for NVIDIA Tegra USB 3.0 Ethernet
Date: Tue, 7 Jul 2015 13:54:12 -0700
Message-ID: <1436302452-6448-1-git-send-email-zhliu@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Zheng Liu <zhliu@nvidia.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate14.nvidia.com ([216.228.121.143]:8614 "EHLO
	hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933035AbbGGUye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 16:54:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device is sold as 'NVIDIA Tegra USB 3.0 Ethernet'.
Chipset is RTL8153 and works with r8152.

Signed-off-by: Zheng Liu <zhliu@nvidia.com>
---
 drivers/net/usb/cdc_ether.c | 8 ++++++++
 drivers/net/usb/r8152.c     | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 4545e78840b0..35a2bffe848a 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -523,6 +523,7 @@ static const struct driver_info wwan_info = {
 #define REALTEK_VENDOR_ID	0x0bda
 #define SAMSUNG_VENDOR_ID	0x04e8
 #define LENOVO_VENDOR_ID	0x17ef
+#define NVIDIA_VENDOR_ID	0x0955
 
 static const struct usb_device_id	products[] = {
 /* BLACKLIST !!
@@ -710,6 +711,13 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+/* NVIDIA Tegra USB 3.0 Ethernet Adapters (based on Realtek RTL8153) */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(NVIDIA_VENDOR_ID, 0x09ff, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* WHITELIST!!!
  *
  * CDC Ether uses two interfaces, not necessarily consecutive.
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index aafa1a1898e4..7f6419ebb5e1 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -494,6 +494,7 @@ enum rtl8152_flags {
 #define VENDOR_ID_REALTEK		0x0bda
 #define VENDOR_ID_SAMSUNG		0x04e8
 #define VENDOR_ID_LENOVO		0x17ef
+#define VENDOR_ID_NVIDIA		0x0955
 
 #define MCU_TYPE_PLA			0x0100
 #define MCU_TYPE_USB			0x0000
@@ -4117,6 +4118,7 @@ static struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_NVIDIA,  0x09ff)},
 	{}
 };
 
-- 
2.1.4
