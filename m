From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH 3/3] use generic usbnet_manage_power()
Date: Tue, 18 Dec 2012 15:46:12 +0100
Message-ID: <1355841972-1068-1-git-send-email-oliver@neukum.org>
Cc: Oliver Neukum <oliver@neukum.org>, Oliver Neukum <oneukum@suse.de>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:51107 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab2LROpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 09:45:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers the drivers that can use a primitive
implementation.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/cdc_ether.c |   10 ++--------
 drivers/net/usb/cdc_ncm.c   |   10 ++--------
 2 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index d012982..421b7b8 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -457,12 +457,6 @@ int usbnet_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_cdc_bind);
 
-static int cdc_manage_power(struct usbnet *dev, int on)
-{
-	dev->intf->needs_remote_wakeup = on;
-	return 0;
-}
-
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
 	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
@@ -470,7 +464,7 @@ static const struct driver_info	cdc_info = {
 	.bind =		usbnet_cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
 	.status =	usbnet_cdc_status,
-	.manage_power =	cdc_manage_power,
+	.manage_power =	usbnet_manage_power,
 };
 
 static const struct driver_info wwan_info = {
@@ -479,7 +473,7 @@ static const struct driver_info wwan_info = {
 	.bind =		usbnet_cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
 	.status =	usbnet_cdc_status,
-	.manage_power =	cdc_manage_power,
+	.manage_power =	usbnet_manage_power,
 };
 
 /*-------------------------------------------------------------------------*/
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index d38bc20..71b6e92 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1129,19 +1129,13 @@ static void cdc_ncm_disconnect(struct usb_interface *intf)
 	usbnet_disconnect(intf);
 }
 
-static int cdc_ncm_manage_power(struct usbnet *dev, int status)
-{
-	dev->intf->needs_remote_wakeup = status;
-	return 0;
-}
-
 static const struct driver_info cdc_ncm_info = {
 	.description = "CDC NCM",
 	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
 	.bind = cdc_ncm_bind,
 	.unbind = cdc_ncm_unbind,
 	.check_connect = cdc_ncm_check_connect,
-	.manage_power = cdc_ncm_manage_power,
+	.manage_power = usbnet_manage_power,
 	.status = cdc_ncm_status,
 	.rx_fixup = cdc_ncm_rx_fixup,
 	.tx_fixup = cdc_ncm_tx_fixup,
@@ -1155,7 +1149,7 @@ static const struct driver_info wwan_info = {
 	.bind = cdc_ncm_bind,
 	.unbind = cdc_ncm_unbind,
 	.check_connect = cdc_ncm_check_connect,
-	.manage_power = cdc_ncm_manage_power,
+	.manage_power = usbnet_manage_power,
 	.status = cdc_ncm_status,
 	.rx_fixup = cdc_ncm_rx_fixup,
 	.tx_fixup = cdc_ncm_tx_fixup,
-- 
1.7.7
