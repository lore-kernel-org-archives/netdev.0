From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH v2 2/2] net: usb: cdc_ncm: Adding Dell DW5813 LTE AT&T Mobile Broadband Card
Date: Fri, 18 Dec 2015 14:43:34 +0100
Message-ID: <1450446214-22948-3-git-send-email-dnlplm@gmail.com>
References: <1450446214-22948-1-git-send-email-dnlplm@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Daniele Palmas <dnlplm@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35383 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbbLRNoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 08:44:08 -0500
In-Reply-To: <1450446214-22948-1-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike DW5550, Dell DW5813 is a mobile broadband card with no ARP
capabilities: the patch makes this device to use wwan_noarp_info struct

Signed-off-by: Daniele Palmas <dnlplm@gmail.com>
---
 drivers/net/usb/cdc_ncm.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 7be9b73..89536d9 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1602,6 +1602,15 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long)&wwan_noarp_info,
 	},
 
+	/* DW5813 LTE AT&T Mobile Broadband Card
+	 * Unlike DW5550 this device requires FLAG_NOARP
+	 */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x81bc,
+		USB_CLASS_COMM,
+		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&wwan_noarp_info,
+	},
+
 	/* Dell branded MBM devices like DW5550 */
 	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
 		| USB_DEVICE_ID_MATCH_VENDOR,
-- 
1.9.1
