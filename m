From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: [PATCH] CDC NCM: release interfaces fix in unbind()
Date: Sun, 15 May 2011 22:28:27 +0200
Message-ID: <1305491307-6548-1-git-send-email-alexey.orishko@stericsson.com>
Cc: linux-usb@vger.kernel.org, davem@davemloft.net, gregkh@suse.de,
	oliver@neukum.org, Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57358 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab1EOU2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 16:28:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>
---
 drivers/net/usb/cdc_ncm.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4ab557d..500b1a6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -54,7 +54,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"06-May-2011"
+#define	DRIVER_VERSION				"15-May-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -652,28 +652,25 @@ error:
 static void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
-	struct usb_driver *driver;
+	struct usb_driver *driver = driver_of(intf);
 
 	if (ctx == NULL)
 		return;		/* no setup */
 
-	driver = driver_of(intf);
-
-	usb_set_intfdata(ctx->data, NULL);
-	usb_set_intfdata(ctx->control, NULL);
-	usb_set_intfdata(ctx->intf, NULL);
-
 	/* release interfaces, if any */
 	if (ctx->data_claimed) {
+		usb_set_intfdata(ctx->data, NULL);
 		usb_driver_release_interface(driver, ctx->data);
 		ctx->data_claimed = 0;
 	}
 
 	if (ctx->control_claimed) {
+		usb_set_intfdata(ctx->control, NULL);
 		usb_driver_release_interface(driver, ctx->control);
 		ctx->control_claimed = 0;
 	}
 
+	usb_set_intfdata(ctx->intf, NULL);
 	cdc_ncm_free(ctx);
 }
 
-- 
1.7.4.3

