From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 3/7] usbnet:cdc-phonet: remove usb_get/put_dev in .probe and .disconnect
Date: Tue, 12 Jun 2012 09:19:41 +0800
Message-ID: <1339463985-9006-4-git-send-email-tom.leiming@gmail.com>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <tom.leiming@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:51886 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab2FLBUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 21:20:33 -0400
In-Reply-To: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_device is parent device of usb_interface in the view of driver
model, so its reference count is always held during .probe/.disconnect
of usb_interface instance.

This patch just removes the unnecessay usb_get/put_dev.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 drivers/net/usb/cdc-phonet.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index d848d4d..187c144 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -394,7 +394,7 @@ int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
 	SET_NETDEV_DEV(dev, &intf->dev);
 
 	pnd->dev = dev;
-	pnd->usb = usb_get_dev(usbdev);
+	pnd->usb = usbdev;
 	pnd->intf = intf;
 	pnd->data_intf = data_intf;
 	spin_lock_init(&pnd->tx_lock);
@@ -440,7 +440,6 @@ out:
 static void usbpn_disconnect(struct usb_interface *intf)
 {
 	struct usbpn_dev *pnd = usb_get_intfdata(intf);
-	struct usb_device *usb = pnd->usb;
 
 	if (pnd->disconnected)
 		return;
@@ -449,7 +448,6 @@ static void usbpn_disconnect(struct usb_interface *intf)
 	usb_driver_release_interface(&usbpn_driver,
 			(pnd->intf == intf) ? pnd->data_intf : pnd->intf);
 	unregister_netdev(pnd->dev);
-	usb_put_dev(usb);
 }
 
 static struct usb_driver usbpn_driver = {
-- 
1.7.9.5
