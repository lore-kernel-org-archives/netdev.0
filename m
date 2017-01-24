From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RESENT PATCH net,stable] qmi_wwan/cdc_ether: add device ID for HP lt2523 (Novatel E371) WWAN card
Date: Tue, 24 Jan 2017 10:45:38 +0100
Message-ID: <20170124094538.20351-1-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Oliver Neukum <oliver@neukum.org>, linux-usb@vger.kernel.org,
        =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
        Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36639 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750728AbdAXJqp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 04:46:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another rebranded Novatel E371.  qmi_wwan should drive this device, while
cdc_ether should ignore it.  Even though the USB descriptors are plain
CDC-ETHER that USB interface is a QMI interface.  Ref commit 7fdb7846c9ca
("qmi_wwan/cdc_ether: add device IDs for Dell 5804 (Novatel E371) WWAN
card")

Cc: Dan Williams <dcbw@redhat.com>
Signed-off-by: Bjørn Mork <bjorn@mork.no>
---
Resending with correct author and to address. I didn't manage to spell
kernel correctly... I guess I should have had one more cup of coffee
this morning.

No changes to the diff.


 drivers/net/usb/cdc_ether.c | 8 ++++++++
 drivers/net/usb/qmi_wwan.c  | 7 +++++++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index fe7b2886cb6b..86144f9a80ee 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -531,6 +531,7 @@ static const struct driver_info wwan_info = {
 #define SAMSUNG_VENDOR_ID	0x04e8
 #define LENOVO_VENDOR_ID	0x17ef
 #define NVIDIA_VENDOR_ID	0x0955
+#define HP_VENDOR_ID		0x03f0
 
 static const struct usb_device_id	products[] = {
 /* BLACKLIST !!
@@ -677,6 +678,13 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+/* HP lt2523 (Novatel E371) - handled by qmi_wwan */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(HP_VENDOR_ID, 0x421d, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* AnyDATA ADU960S - handled by qmi_wwan */
 {
 	USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a, USB_CLASS_COMM,
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 6fe1cdb0174f..24d5272cdce5 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -654,6 +654,13 @@ static const struct usb_device_id products[] = {
 					      USB_CDC_PROTO_NONE),
 		.driver_info        = (unsigned long)&qmi_wwan_info,
 	},
+	{	/* HP lt2523 (Novatel E371) */
+		USB_DEVICE_AND_INTERFACE_INFO(0x03f0, 0x421d,
+					      USB_CLASS_COMM,
+					      USB_CDC_SUBCLASS_ETHERNET,
+					      USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
 	{	/* HP lt4112 LTE/HSPA+ Gobi 4G Module (Huawei me906e) */
 		USB_DEVICE_AND_INTERFACE_INFO(0x03f0, 0x581d, USB_CLASS_VENDOR_SPEC, 1, 7),
 		.driver_info = (unsigned long)&qmi_wwan_info,
-- 
2.11.0
