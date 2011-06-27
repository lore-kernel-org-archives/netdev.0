From: Greg KH <greg@kroah.com>
Subject: Fw: Remove over-broad module alias from zaurus.
Date: Mon, 27 Jun 2011 13:42:07 -0700
Message-ID: <20110627204207.GB5341@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:40420 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754415Ab1F0Ur7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 16:47:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should have gone to netdev@

----- Forwarded message from Dave Jones <davej@redhat.com> -----

Date: Fri, 17 Jun 2011 20:02:10 -0400
From: Dave Jones <davej@redhat.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-usb@vger.kernel.org
Subject: Remove over-broad module alias from zaurus.

This module and a bunch of dependancies are getting loaded on several
of laptops I have (probably picking up the mobile broadband device),
that have nothing to do with zaurus. Matching by class without
any vendor/device pair isn't the right thing to do here, as it
will prevent any other driver from correctly binding to it.
(Or in the absense of a driver, will just waste time & memory by
 unnecessarily loading modules)

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index 241756e..1a2234c 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -331,17 +331,7 @@ static const struct usb_device_id	products [] = {
 	ZAURUS_MASTER_INTERFACE,
 	.driver_info = ZAURUS_PXA_INFO,
 },
-
-
-/* At least some of the newest PXA units have very different lies about
- * their standards support:  they claim to be cell phones offering
- * direct access to their radios!  (No, they don't conform to CDC MDLM.)
- */
 {
-	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MDLM,
-			USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &bogus_mdlm_info,
-}, {
 	/* Motorola MOTOMAGX phones */
 	USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x6425, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

----- End forwarded message -----
