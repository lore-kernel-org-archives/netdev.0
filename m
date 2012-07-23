From: kyak <bas@bmail.ru>
Subject: [PATCH] USB: plusb: Add support for PL-2501
Date: Mon, 23 Jul 2012 15:44:11 +0400 (MSK)
Message-ID: <alpine.LNX.2.02.1207231540580.1183@bas>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Sergei Shtylyov <sshtylyov@mvista.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikhail Peselnik <peselnik@gmail.com>

This patch adds support for PL-2501 by adding the appropriate USB
ID's. This chip is used in several USB 'Easy Trasfer' Cables.

Signed-off-by: Mikhail Peselnik <peselnik@gmail.com>
Tested-by: Mikhail Peselnik <peselnik@gmail.com>
---
Now with proper sign-offs and right people in cc and unwrapped lines.
plusb driver (drivers/net/usb/plusb.c) doesn't recognize PL2501 chip.
Since PL2501 uses the same code as PL2301/PL2302 (PL2501 works in
compatibility mode with PL2301/PL2302), the fix is trivial and
attached as a patch.

Just to note: the patch is not mine, it can be found here and there on
Internet.
I've tested the patch and it works great.

Thank you.

--- linux-3.5/drivers/net/usb/plusb.c.orig	2012-07-22 21:06:41.905802795 +0400
+++ linux-3.5/drivers/net/usb/plusb.c	2012-07-22 21:07:00.345552404 +0400
@@ -107,7 +107,7 @@ static int pl_reset(struct usbnet *dev)
  }

  static const struct driver_info	prolific_info = {
-	.description =	"Prolific PL-2301/PL-2302/PL-25A1",
+	.description =	"Prolific PL-2301/PL-2302/PL-25A1/PL-2501",
  	.flags =	FLAG_POINTTOPOINT | FLAG_NO_SETINT,
  		/* some PL-2302 versions seem to fail usb_set_interface() */
  	.reset =	pl_reset,
@@ -139,6 +139,9 @@ static const struct usb_device_id	produc
  }, {
  	USB_DEVICE(0x050d, 0x258a),     /* Belkin F5U258/F5U279 (PL-25A1) */
  	.driver_info =  (unsigned long) &prolific_info,
+}, {
+	USB_DEVICE(0x067b, 0x2501),     /* PL-2501 */
+	.driver_info =  (unsigned long) &prolific_info,
  },

  	{ },		// END
@@ -158,5 +161,5 @@ static struct usb_driver plusb_driver =
  module_usb_driver(plusb_driver);

  MODULE_AUTHOR("David Brownell");
-MODULE_DESCRIPTION("Prolific PL-2301/2302/25A1 USB Host to Host Link Driver");
+MODULE_DESCRIPTION("Prolific PL-2301/2302/25A1/2501 USB Host to Host Link Driver");
  MODULE_LICENSE("GPL");
