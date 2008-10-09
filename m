From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: fix usb usage on big endian platforms
Date: Thu,  9 Oct 2008 13:53:14 +0100
Message-ID: <1223556794-29405-1-git-send-email-steve.glendinning@smsc.com>
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Jeff Garzik <jeff@garzik.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:49722 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757440AbYJIMxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 08:53:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warnings caught by David Miller on ppc64

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 412bde6..51e2f5d 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -320,12 +320,12 @@ static void smsc95xx_async_cmd_callback(struct urb *urb, struct pt_regs *regs)
 	usb_free_urb(urb);
 }
 
-static int smsc95xx_write_reg_async(struct usbnet *dev, u32 index, u32 *data)
+static int smsc95xx_write_reg_async(struct usbnet *dev, u16 index, u32 *data)
 {
 	struct usb_context *usb_context;
 	int status;
 	struct urb *urb;
-	const u32 size = 4;
+	const u16 size = 4;
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
@@ -344,8 +344,8 @@ static int smsc95xx_write_reg_async(struct usbnet *dev, u32 index, u32 *data)
 		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
 	usb_context->req.bRequest = USB_VENDOR_REQUEST_WRITE_REGISTER;
 	usb_context->req.wValue = 00;
-	usb_context->req.wIndex = cpu_to_le32(index);
-	usb_context->req.wLength = cpu_to_le32(size);
+	usb_context->req.wIndex = cpu_to_le16(index);
+	usb_context->req.wLength = cpu_to_le16(size);
 	init_completion(&usb_context->notify);
 
 	usb_fill_control_urb(urb, dev->udev, usb_sndctrlpipe(dev->udev, 0),
@@ -545,7 +545,7 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 	}
 
 	memcpy(&intdata, urb->transfer_buffer, 4);
-	le32_to_cpus(intdata);
+	le32_to_cpus(&intdata);
 
 	if (netif_msg_link(dev))
 		devdbg(dev, "intdata: 0x%08X", intdata);
-- 
1.5.5.1

