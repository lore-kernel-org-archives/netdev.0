From: Bjorge Dijkstra <bjd@jooz.net>
Subject: [PATCH 2/8] [PATCH] Hardwire CDC descriptors when missing
Date: Sat, 22 Dec 2007 22:51:28 +0100
Message-ID: <11983602953487-git-send-email-bjd@jooz.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:10178 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbXLVVvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 16:51:35 -0500
In-Reply-To: <11983602942818-git-send-email-bjd@jooz.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just as ActiveSync devices, some regular RNDIS devices also lack
the CDC descriptors (e.g. devices based on BCM4320 WLAN chip).
This patch hardwires the CDC descriptors for all RNDIS style devices
when they are missing.

Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>
---
 drivers/net/usb/cdc_ether.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index a42acc3..97c17bb 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -228,15 +228,16 @@ next_desc:
 		buf += buf [0];
 	}
 
-	/* Microsoft ActiveSync based RNDIS devices lack the CDC descriptors,
-	 * so we'll hard-wire the interfaces and not check for descriptors.
+	/* Microsoft ActiveSync based and some regular RNDIS devices lack the
+	 * CDC descriptors, so we'll hard-wire the interfaces and not check
+	 * for descriptors.
 	 */
-	if (is_activesync(&intf->cur_altsetting->desc) && !info->u) {
+	if (rndis && !info->u) {
 		info->control = usb_ifnum_to_if(dev->udev, 0);
 		info->data = usb_ifnum_to_if(dev->udev, 1);
 		if (!info->control || !info->data) {
 			dev_dbg(&intf->dev,
-				"activesync: master #0/%p slave #1/%p\n",
+				"rndis: master #0/%p slave #1/%p\n",
 				info->control,
 				info->data);
 			goto bad_desc;
@@ -316,7 +317,6 @@ void usbnet_cdc_unbind(struct usbnet *dev, struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_cdc_unbind);
 
-
 /*-------------------------------------------------------------------------
  *
  * Communications Device Class, Ethernet Control model
-- 
1.5.2.5

