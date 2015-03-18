From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] Revert "net: cx82310_eth: use common match macro"
Date: Wed, 18 Mar 2015 23:01:01 +0100
Message-ID: <1426716061-20953-1-git-send-email-linux@rainbow-software.org>
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 11ad714b98f6d9ca0067568442afe3e70eb94845 because
it breaks cx82310_eth.

The custom USB_DEVICE_CLASS macro matches
bDeviceClass, bDeviceSubClass and bDeviceProtocol
but the common USB_DEVICE_AND_INTERFACE_INFO matches
bInterfaceClass, bInterfaceSubClass and bInterfaceProtocol instead, which are
not specified.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/usb/cx82310_eth.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cx82310_eth.c b/drivers/net/usb/cx82310_eth.c
index 3eed708..fe48f4c 100644
--- a/drivers/net/usb/cx82310_eth.c
+++ b/drivers/net/usb/cx82310_eth.c
@@ -300,9 +300,18 @@ static const struct driver_info	cx82310_info = {
 	.tx_fixup	= cx82310_tx_fixup,
 };
 
+#define USB_DEVICE_CLASS(vend, prod, cl, sc, pr) \
+	.match_flags = USB_DEVICE_ID_MATCH_DEVICE | \
+		       USB_DEVICE_ID_MATCH_DEV_INFO, \
+	.idVendor = (vend), \
+	.idProduct = (prod), \
+	.bDeviceClass = (cl), \
+	.bDeviceSubClass = (sc), \
+	.bDeviceProtocol = (pr)
+
 static const struct usb_device_id products[] = {
 	{
-		USB_DEVICE_AND_INTERFACE_INFO(0x0572, 0xcb01, 0xff, 0, 0),
+		USB_DEVICE_CLASS(0x0572, 0xcb01, 0xff, 0, 0),
 		.driver_info = (unsigned long) &cx82310_info
 	},
 	{ },
-- 
Ondrej Zary
