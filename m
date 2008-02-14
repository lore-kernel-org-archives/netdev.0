From: tony_gibbs <Tony_Gibbs@compuserve.com>
Subject: [PATCH] plusb.c patched to support Belkin F5U258 USB
  host-to-host cable
Date: Thu, 14 Feb 2008 15:56:49 -0500
Message-ID: <200802141557_MC3-1-FBB3-3DA7@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: NETDEV mailing list <netdev@vger.kernel.org>,
	Linux USB mailing list <majordomo@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from liaag1ac.mx.compuserve.com ([149.174.40.29]:38000 "EHLO
	liaag1ac.mx.compuserve.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753609AbYBOKSQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 05:18:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Dave,

I have tried to make the changes I have been working on and testing with
your help into a patch as attached.

Please let me know what you think of it.

Kind Regards,
        Tony

---
Description: To make usbnet work with the Belkin F5U258 USB Host to Host
cable,
which contains Prolific PL-25A1 chip, the file plusb.c has been edited to
add the
VID and PID values for that cable.

The changes have been checked using the checkpatch.pl script.

The patch was tested on kernel 2.6.23.14 on Fedora Core 8, and on kernel
2.6.17.14 on Ubuntu Dapper Drake.

Signed-off-by: Tony Gibbs <tony_gibbs@compuserve.com>

--- /home/tony/drivers/net/usb/plusb.c  2008-02-12 23:02:01.000000000 +0000
+++
/usr/src/redhat/BUILD/kernel-2.6.23/linux-2.6.23.i386/drivers/net/usb/plusb
.c      2008-02-12 23:17:16.000000000 +0000
@@ -1,6 +1,7 @@
 /*
  * PL-2301/2302 USB host-to-host link cables
  * Copyright (C) 2000-2005 by David Brownell
+ * PL-25A1 hack added by Tony Gibbs 07/02/2008.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -17,8 +18,8 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 
USA
  */
 
-//#define      DEBUG                   // error path messages, extra info
-//#define      VERBOSE                 // more; success messages
+#define        DEBUG                   // error path messages, extra info
+#define        VERBOSE                 // more; success messages
 
 #include <linux/module.h>
 #include <linux/init.h>
@@ -46,6 +47,8 @@
  * seems to get wedged under load.  Prolific docs are weak, and
  * don't identify differences between PL2301 and PL2302, much less
  * anything to explain the different PL2302 versions observed.
+ *
+ * PL25A1 chip in Belkin F5U258 added.
  */
 
 /*
@@ -96,7 +99,7 @@ static int pl_reset(struct usbnet *dev)
 }
 
 static const struct driver_info        prolific_info = {
-       .description =  "Prolific PL-2301/PL-2302",
+       .description =  "Prolific PL-2301/PL-2302_PL-25A1hack",
        .flags =        FLAG_NO_SETINT,
                /* some PL-2302 versions seem to fail usb_set_interface()
*/
        .reset =        pl_reset,
@@ -118,7 +121,12 @@ static const struct usb_device_id  produc
 }, {
        USB_DEVICE(0x067b, 0x0001),     // PL-2302
        .driver_info =  (unsigned long) &prolific_info,
-}, 
+}, {
+       USB_DEVICE(0x050d, 0x258a),     /*Belkin F5U258 cable containing
PL-25A1 chip.*/
+                                       /* TG hack 07/02/2008 */
+       .driver_info =  (unsigned long) &prolific_info
+},
+
        { },            // END
 };
 MODULE_DEVICE_TABLE(usb, products);
@@ -145,5 +153,5 @@ static void __exit plusb_exit(void)
 module_exit(plusb_exit);
 
 MODULE_AUTHOR("David Brownell");
-MODULE_DESCRIPTION("Prolific PL-2301/2302 USB Host to Host Link Driver");
+MODULE_DESCRIPTION("Prolific PL-2301/2302 USB Host to Host Link Driver
with PL-25A1 TG hack");
 MODULE_LICENSE("GPL");
