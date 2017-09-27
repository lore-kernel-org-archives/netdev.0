From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH V3] r8152:  add Linksys USB3GIGV1 id
Date: Wed, 27 Sep 2017 10:28:02 -0700
Message-ID: <20170927172802.80654-1-grundler@chromium.org>
Cc: linux-usb <linux-usb@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>
To: Hayes Wang <hayeswang@realtek.com>,
        Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This linksys dongle by default comes up in cdc_ether mode.
This patch allows r8152 to claim the device:
   Bus 002 Device 002: ID 13b1:0041 Linksys

Signed-off-by: Grant Grundler <grundler@chromium.org>
---
 drivers/net/usb/cdc_ether.c | 10 ++++++++++
 drivers/net/usb/r8152.c     |  2 ++
 2 files changed, 12 insertions(+)

V3: for backwards compat, add #ifdef CONFIG_USB_RTL8152 around
    the cdc_ether blacklist entry so the cdc_ether driver can
    still claim the device if r8152 driver isn't configured.

V2: add LINKSYS_VENDOR_ID to cdc_ether blacklist

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 8ab281b478f2..446dcc0f1f70 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -546,6 +546,7 @@ static const struct driver_info wwan_info = {
 #define DELL_VENDOR_ID		0x413C
 #define REALTEK_VENDOR_ID	0x0bda
 #define SAMSUNG_VENDOR_ID	0x04e8
+#define LINKSYS_VENDOR_ID	0x13b1
 #define LENOVO_VENDOR_ID	0x17ef
 #define NVIDIA_VENDOR_ID	0x0955
 #define HP_VENDOR_ID		0x03f0
@@ -737,6 +738,15 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+#ifdef CONFIG_USB_RTL8152
+/* Linksys USB3GIGV1 Ethernet Adapter */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(LINKSYS_VENDOR_ID, 0x0041, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+#endif
+
 /* ThinkPad USB-C Dock (based on Realtek RTL8153) */
 {
 	USB_DEVICE_AND_INTERFACE_INFO(LENOVO_VENDOR_ID, 0x3062, USB_CLASS_COMM,
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ceb78e2ea4f0..941ece08ba78 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -613,6 +613,7 @@ enum rtl8152_flags {
 #define VENDOR_ID_MICROSOFT		0x045e
 #define VENDOR_ID_SAMSUNG		0x04e8
 #define VENDOR_ID_LENOVO		0x17ef
+#define VENDOR_ID_LINKSYS		0x13b1
 #define VENDOR_ID_NVIDIA		0x0955
 
 #define MCU_TYPE_PLA			0x0100
@@ -5316,6 +5317,7 @@ static const struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x720c)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7214)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_LINKSYS, 0x0041)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_NVIDIA,  0x09ff)},
 	{}
 };
-- 
2.14.2.822.g60be5d43e6-goog
