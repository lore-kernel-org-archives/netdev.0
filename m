From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: remove unused completion struct
Date: Tue, 20 Jan 2009 15:03:15 +0000
Message-ID: <1232463795-25665-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Ian Saturley <ian.saturley@smsc.com>,
	Oliver Neukum <oliver@neukum.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:58094 "EHLO
	kensington.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754977AbZATPNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 10:13:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum spotted the useless complete() in our async callback.  On
closer inspection, the entire completion struct is unused.  This patch
removes it.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 5574abe..26fabef 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -55,7 +55,6 @@ struct smsc95xx_priv {
 
 struct usb_context {
 	struct usb_ctrlrequest req;
-	struct completion notify;
 	struct usbnet *dev;
 };
 
@@ -316,8 +315,6 @@ static void smsc95xx_async_cmd_callback(struct urb *urb, struct pt_regs *regs)
 	if (status < 0)
 		devwarn(dev, "async callback failed with %d", status);
 
-	complete(&usb_context->notify);
-
 	kfree(usb_context);
 	usb_free_urb(urb);
 }
@@ -348,7 +345,6 @@ static int smsc95xx_write_reg_async(struct usbnet *dev, u16 index, u32 *data)
 	usb_context->req.wValue = 00;
 	usb_context->req.wIndex = cpu_to_le16(index);
 	usb_context->req.wLength = cpu_to_le16(size);
-	init_completion(&usb_context->notify);
 
 	usb_fill_control_urb(urb, dev->udev, usb_sndctrlpipe(dev->udev, 0),
 		(void *)&usb_context->req, data, size,
-- 
1.6.0.6

