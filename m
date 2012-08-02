From: Peter Meiser <meiser@gmx-topmail.de>
Subject: Re: [PATCH] cdc-ncm: tag Ericsson WWAN devices (eg F5521gw) with
 FLAG_WWAN
Date: Thu, 02 Aug 2012 14:30:20 +0200
Message-ID: <501A72DC.7070306@gmx-topmail.de>
References: <1343155402.29196.7.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: public-netdev-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org,
	public-linux-usb-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:58900 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534Ab2HBMbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 08:31:55 -0400
Received: from public by plane.gmane.org with local (Exim 4.69)
	(envelope-from <public@plane.gmane.org>)
	id 1SwuZH-0000F6-BW
	for netdev@vger.kernel.org; Thu, 02 Aug 2012 14:31:55 +0200
In-Reply-To: <1343155402.29196.7.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




Hello,

looking at http://sourceforge.net/apps/mediawiki/mbm/index.php?title=Main_Page#Supported_devices, there are branded Ericsson devices from Dell and Toshiba.

The to-be-added vendor IDs are 0x413c for Dell and 0x0930 for Toshiba.

Please find attached a patch to add these vendor IDs.

Signed-off-by: Peter Meiser <meiser@gmx-topmail.de>
---

diff -Naur a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1233,6 +1233,26 @@
 	  .driver_info = (unsigned long) &wwan_info,
 	},
 
+	/* Dell branded MBM devices like DW5550 */
+	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
+		| USB_DEVICE_ID_MATCH_VENDOR,
+	  .idVendor = 0x413c,
+	  .bInterfaceClass = USB_CLASS_COMM,
+	  .bInterfaceSubClass = USB_CDC_SUBCLASS_NCM,
+	  .bInterfaceProtocol = USB_CDC_PROTO_NONE,
+	  .driver_info = (unsigned long) &wwan_info,
+	},
+
+	/* Toshiba branded MBM devices */
+	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
+		| USB_DEVICE_ID_MATCH_VENDOR,
+	  .idVendor = 0x0930,
+	  .bInterfaceClass = USB_CLASS_COMM,
+	  .bInterfaceSubClass = USB_CDC_SUBCLASS_NCM,
+	  .bInterfaceProtocol = USB_CDC_PROTO_NONE,
+	  .driver_info = (unsigned long) &wwan_info,
+	},
+
 	/* Generic CDC-NCM devices */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
 		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
