From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 08/11] usbnet: plusb: apply introduced usb command APIs
Date: Thu, 11 Oct 2012 20:39:26 +0800
Message-ID: <1349959169-9432-9-git-send-email-ming.lei@canonical.com>
References: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:55916 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756091Ab2JKMlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 08:41:42 -0400
In-Reply-To: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/plusb.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 4584b9a..0fcc8e6 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -71,13 +71,10 @@
 static inline int
 pl_vendor_req(struct usbnet *dev, u8 req, u8 val, u8 index)
 {
-	return usb_control_msg(dev->udev,
-		usb_rcvctrlpipe(dev->udev, 0),
-		req,
-		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		val, index,
-		NULL, 0,
-		USB_CTRL_GET_TIMEOUT);
+	return usbnet_read_cmd(dev, req,
+				USB_DIR_IN | USB_TYPE_VENDOR |
+				USB_RECIP_DEVICE,
+				val, index, NULL, 0);
 }
 
 static inline int
-- 
1.7.9.5
