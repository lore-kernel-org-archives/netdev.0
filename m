From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: [PATCH] DRIVERS: NET: USB: DM9601 driver can drive a device not supported yet, add support for it
Date: Thu, 22 Oct 2009 20:25:48 +0200
Message-ID: <200910222025.50405.jkrzyszt@tis.icnet.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d1.icnet.pl ([212.160.220.21]:43211 "EHLO d1.icnet.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754629AbZJVSzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 14:55:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I found that the current version of drivers/net/usb/dm9601.c can be used to
successfully drive a low-power, low-cost network adapter with USB ID
0a46:9000, based on a DM9000E chipset. As no device with this ID is yet
present in the kernel, I have created a patch that adds support for the device
to the dm9601 driver.

Created and tested against linux-2.6.32-rc5.

Signed-off-by: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>

---
There seems to be plenty of those devices available on ebay recently, for example: 
http://cgi.ebay.pl/USB-TO-Fast-Ethernet-Network-RJ45-Adapter-Converter-NIC_W0QQitemZ250458092252QQcmdZViewItemQQptZUK_Computing_Networking_SM?hash=item3a507732dc

--- linux-2.6.32-rc5/drivers/net/usb/dm9601.c.orig	2009-10-22 20:14:00.000000000 +0200
+++ linux-2.6.32-rc5/drivers/net/usb/dm9601.c	2009-10-22 20:14:04.000000000 +0200
@@ -649,6 +649,10 @@ static const struct usb_device_id produc
 	USB_DEVICE(0x0fe6, 0x8101),	/* DM9601 USB to Fast Ethernet Adapter */
 	.driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	 USB_DEVICE(0x0a46, 0x9000),	/* DM9000E */
+	 .driver_info = (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
 
