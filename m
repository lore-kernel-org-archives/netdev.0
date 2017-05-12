From: Johan Hovold <johan@kernel.org>
Subject: [PATCH] wireless: mwifiex: add missing USB-descriptor endianness conversion
Date: Fri, 12 May 2017 12:15:55 +0200
Message-ID: <20170512101555.2111-1-johan@kernel.org>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34354 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933039AbdELKQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 06:16:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the missing endianness conversions to a debug statement printing
the USB device-descriptor bcdUSB field during probe.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/wireless/marvell/mwifiex/usb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/usb.c b/drivers/net/wireless/marvell/mwifiex/usb.c
index 2f7705c50161..debd6216366a 100644
--- a/drivers/net/wireless/marvell/mwifiex/usb.c
+++ b/drivers/net/wireless/marvell/mwifiex/usb.c
@@ -424,7 +424,8 @@ static int mwifiex_usb_probe(struct usb_interface *intf,
 	card->intf = intf;
 
 	pr_debug("info: bcdUSB=%#x Device Class=%#x SubClass=%#x Protocol=%#x\n",
-		 udev->descriptor.bcdUSB, udev->descriptor.bDeviceClass,
+		 le16_to_cpu(udev->descriptor.bcdUSB),
+		 udev->descriptor.bDeviceClass,
 		 udev->descriptor.bDeviceSubClass,
 		 udev->descriptor.bDeviceProtocol);
 
-- 
2.13.0
