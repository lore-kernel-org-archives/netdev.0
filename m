From: David Brownell <david-b@pacbell.net>
Subject: [patch] usbnet cdc_subset: fix issues talking to PXA gadgets
Date: Fri, 19 Jun 2009 00:11:28 -0700
Message-ID: <200906190011.28320.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Aric D. Blumer" <aric@sdgsystems.com>
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.sbc.mail.gq1.yahoo.com ([67.195.14.39]:33806 "HELO
	smtp109.sbc.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751978AbZFSHL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 03:11:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

The host-side CDC subset driver is binding more specifically
than it should ... only to PXA 210/25x/26x Linux-USB gadgets.

Loosen that restriction to match the gadget driver itself.
This helps various PXA 27x and PXA 3xx devices be happier
when talking to Linux hosts; and a few other gadgets too.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Tested-by: Aric D. Blumer <aric@sdgsystems.com>
---
Appropriate for -stable ... behaves like a protocol bug.

 drivers/net/usb/cdc_subset.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- a/drivers/net/usb/cdc_subset.c
+++ b/drivers/net/usb/cdc_subset.c
@@ -307,9 +307,10 @@ static const struct usb_device_id	produc
 	USB_DEVICE (0x1286, 0x8001),    // "blob" bootloader
 	.driver_info =  (unsigned long) &blob_info,
 }, {
-	// Linux Ethernet/RNDIS gadget on pxa210/25x/26x, second config
-	// e.g. Gumstix, current OpenZaurus, ...
-	USB_DEVICE_VER (0x0525, 0xa4a2, 0x0203, 0x0203),
+	// Linux Ethernet/RNDIS gadget, mostly on PXA, second config
+	// e.g. Gumstix, current OpenZaurus, ... or anything else
+	// that just enables this gadget option.
+	USB_DEVICE_VER (0x0525, 0xa4a2),
 	.driver_info =	(unsigned long) &linuxdev_info,
 },
 #endif
