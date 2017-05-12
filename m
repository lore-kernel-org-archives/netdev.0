From: Johan Hovold <johan@kernel.org>
Subject: [PATCH] net: irda: irda-usb: fix firmware name on big-endian hosts
Date: Fri, 12 May 2017 12:11:13 +0200
Message-ID: <20170512101113.1935-1-johan@kernel.org>
Cc: netdev@vger.kernel.org, Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>,
        Nick Fedchik <nfedchik@atlantic-link.com.ua>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36383 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756761AbdELKLe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 06:11:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing endianness conversion when using the USB device-descriptor
bcdDevice field to construct a firmware file name.

Fixes: 8ef80aef118e ("[IRDA]: irda-usb.c: STIR421x cleanups")
Cc: stable <stable@vger.kernel.org>     # 2.6.18
Cc: Nick Fedchik <nfedchik@atlantic-link.com.ua>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/irda/irda-usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 8716b8c07feb..6f3c805f7211 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1077,7 +1077,7 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
          * are "42101001.sb" or "42101002.sb"
          */
         sprintf(stir421x_fw_name, "4210%4X.sb",
-                self->usbdev->descriptor.bcdDevice);
+		le16_to_cpu(self->usbdev->descriptor.bcdDevice));
         ret = request_firmware(&fw, stir421x_fw_name, &self->usbdev->dev);
         if (ret < 0)
                 return ret;
-- 
2.13.0
