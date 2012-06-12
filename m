From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 1/7] usbnet: remove usb_get/put_dev in .probe and .disconnect
Date: Tue, 12 Jun 2012 09:19:39 +0800
Message-ID: <1339463985-9006-2-git-send-email-tom.leiming@gmail.com>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <tom.leiming@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61786 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab2FLBUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 21:20:11 -0400
In-Reply-To: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_device is parent device of usb_interface in the view of driver
model, so its reference count is always held during .probe/.disconnect
of usb_interface instance.

This patch just removes the unnecessay usb_get/put_dev.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 drivers/net/usb/usbnet.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9f58330..022c1e7 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1307,7 +1307,6 @@ void usbnet_disconnect (struct usb_interface *intf)
 	usb_free_urb(dev->interrupt);
 
 	free_netdev(net);
-	usb_put_dev (xdev);
 }
 EXPORT_SYMBOL_GPL(usbnet_disconnect);
 
@@ -1363,8 +1362,6 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	xdev = interface_to_usbdev (udev);
 	interface = udev->cur_altsetting;
 
-	usb_get_dev (xdev);
-
 	status = -ENOMEM;
 
 	// set up our own records
@@ -1493,7 +1490,6 @@ out3:
 out1:
 	free_netdev(net);
 out:
-	usb_put_dev(xdev);
 	return status;
 }
 EXPORT_SYMBOL_GPL(usbnet_probe);
-- 
1.7.9.5
