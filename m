From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] cdc-subset: make compile with all config options
Date: Wed, 30 Jul 2014 10:54:46 +0200
Message-ID: <1406710486-29138-1-git-send-email-oneukum@suse.de>
Cc: Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33446 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751579AbaG3Iyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 04:54:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My earlier patch introduced helper methods errornously
subject to conditional compilation. This patch makes them
available under all config options.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/cdc_subset.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/cdc_subset.c b/drivers/net/usb/cdc_subset.c
index 3ef411e..6ea98cf 100644
--- a/drivers/net/usb/cdc_subset.c
+++ b/drivers/net/usb/cdc_subset.c
@@ -99,16 +99,6 @@ static void m5632_recover(struct usbnet *dev)
 	usb_unlock_device(udev);
 }
 
-static int dummy_prereset(struct usb_interface *intf)
-{
-	return 0;
-}
-
-static int dummy_postreset(struct usb_interface *intf)
-{
-	return 0;
-}
-
 static const struct driver_info	ali_m5632_info = {
 	.description =	"ALi M5632",
 	.flags       = FLAG_POINTTOPOINT,
@@ -117,7 +107,6 @@ static const struct driver_info	ali_m5632_info = {
 
 #endif
 
-
 #ifdef	CONFIG_USB_AN2720
 #define	HAVE_HARDWARE
 
@@ -351,6 +340,15 @@ static const struct usb_device_id	products [] = {
 MODULE_DEVICE_TABLE(usb, products);
 
 /*-------------------------------------------------------------------------*/
+static int dummy_prereset(struct usb_interface *intf)
+{
+        return 0;
+}
+
+static int dummy_postreset(struct usb_interface *intf)
+{
+        return 0;
+}
 
 static struct usb_driver cdc_subset_driver = {
 	.name =		"cdc_subset",
-- 
1.8.4.5
