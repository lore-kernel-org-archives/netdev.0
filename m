From: Wei Shuai <cpuwolf@gmail.com>
Subject: [PATCH 2/2] CDC_NCM: adding support FLAG_NOARP for Infineon modem platform
Date: Sun, 20 Jan 2013 14:12:09 +0800
Message-ID: <1358662329-8294-2-git-send-email-cpuwolf@gmail.com>
References: <1358662329-8294-1-git-send-email-cpuwolf@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Wei Shuai <cpuwolf@gmail.com>
To: dcbw@redhat.com, davem@davemloft.net, peter@stuge.se,
	oneukum@suse.de, sshtylyov@mvista.com, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:41468 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890Ab3ATGQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 01:16:17 -0500
In-Reply-To: <1358662329-8294-1-git-send-email-cpuwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. we can define a new common structure wwan_noarp_info.
Then more similiar NO ARP devices can be handled easily


Signed-off-by: Wei Shuai <cpuwolf@gmail.com>
---
 drivers/net/usb/cdc_ncm.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 71b6e92..2d699b6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1155,6 +1155,20 @@ static const struct driver_info wwan_info = {
 	.tx_fixup = cdc_ncm_tx_fixup,
 };
 
+/* Same as wwan_info, but with IFF_NOARP  */
+static const struct driver_info wwan_noarp_info = {
+	.description = "Mobile Broadband Network Device (NO ARP)",
+	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
+			| FLAG_WWAN | FLAG_NOARP,
+	.bind = cdc_ncm_bind,
+	.unbind = cdc_ncm_unbind,
+	.check_connect = cdc_ncm_check_connect,
+	.manage_power = usbnet_manage_power,
+	.status = cdc_ncm_status,
+	.rx_fixup = cdc_ncm_rx_fixup,
+	.tx_fixup = cdc_ncm_tx_fixup,
+};
+
 static const struct usb_device_id cdc_devs[] = {
 	/* Ericsson MBM devices like F5521gw */
 	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
@@ -1194,6 +1208,13 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long)&wwan_info,
 	},
 
+	/* Infineon(now Intel) HSPA Modem platform */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
+		USB_CLASS_COMM,
+		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&wwan_noarp_info,
+	},
+
 	/* Generic CDC-NCM devices */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
 		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
-- 
1.7.6.5
