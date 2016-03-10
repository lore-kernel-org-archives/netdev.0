From: Joseph CHANG <josright123@gmail.com>
Subject: [PATCH 1/3] dm9601: enable EP3 interrupt
Date: Thu, 10 Mar 2016 19:23:34 +0800
Message-ID: <1457609014-3597-1-git-send-email-josright123@gmail.com>
Cc: Joseph Chang <joseph_chang@davicom.com.tw>
To: Peter Korsgaard <jacmet@sunsite.dk>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joseph CHANG <josright123@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35159 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965852AbcCJLXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 06:23:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable chip's EP3 interrupt to get the link-up notify soon
immediately.

Signed-off-by: Joseph CHANG <josright123@gmail.com>
---
 drivers/net/usb/dm9601.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 0b4bdd3..520de4f 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -46,6 +46,9 @@
 #define DM_GPR_DATA	0x1f
 #define DM_CHIP_ID	0x2c
 #define DM_MODE_CTRL	0x91	/* only on dm9620 */
+#define	DM_USB_CTRL	0xf4
+
+#define	USB_CTRL_EP3ACK	0x20
 
 /* chip id values */
 #define ID_DM9601	0
@@ -414,6 +417,9 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 			goto out;
 		}
 		dm_write_reg(dev, DM_MODE_CTRL, mode & 0x7f);
+
+		/* Always return 8-bytes data to host per interrupt-interval */
+		dm_write_reg(dev, DM_USB_CTRL, USB_CTRL_EP3ACK);
 	}
 
 	/* power up phy */
-- 
2.1.4
