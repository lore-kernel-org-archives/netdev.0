From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: fix function prototype of async callback
Date: Tue, 20 Jan 2009 15:09:00 +0000
Message-ID: <1232464140-27713-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Ian Saturley <ian.saturley@smsc.com>,
	Oliver Neukum <oliver@neukum.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:58776 "EHLO
	kensington.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757075AbZATPSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 10:18:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smsc95xx_async_cmd_callback doesn't currently match usb_complete_t, so
there's a cast to force the square peg into the round hole.  This patch
fixes this properly.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 26fabef..5b0b964 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -306,7 +306,7 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	return 0;
 }
 
-static void smsc95xx_async_cmd_callback(struct urb *urb, struct pt_regs *regs)
+static void smsc95xx_async_cmd_callback(struct urb *urb)
 {
 	struct usb_context *usb_context = urb->context;
 	struct usbnet *dev = usb_context->dev;
@@ -348,7 +348,7 @@ static int smsc95xx_write_reg_async(struct usbnet *dev, u16 index, u32 *data)
 
 	usb_fill_control_urb(urb, dev->udev, usb_sndctrlpipe(dev->udev, 0),
 		(void *)&usb_context->req, data, size,
-		(usb_complete_t)smsc95xx_async_cmd_callback,
+		smsc95xx_async_cmd_callback,
 		(void *)usb_context);
 
 	status = usb_submit_urb(urb, GFP_ATOMIC);
-- 
1.6.0.6

