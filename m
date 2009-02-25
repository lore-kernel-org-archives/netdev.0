From: Dmitriy Taychenachev <dimichxp@gmail.com>
Subject: [PATCH] zaurus: add usb id for motomagx phones
Date: Wed, 25 Feb 2009 12:04:29 +0800
Message-ID: <9d2490ddb0002885be91.1235534669@wifi.master>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f167.google.com ([209.85.220.167]:37201 "EHLO
	mail-fx0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbZBYEEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 23:04:51 -0500
Received: by fxm11 with SMTP id 11so3404855fxm.13
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2009 20:04:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Motorola MOTOMAGX phones (Z6, E8, Zn5 so far) are providing
combined combined ACM/BLAN USB configuration. Since it has Vendor
Specific class, the corresponding drivers (cdc-acm, zaurus) can't find
it just by interface info. This patch adds usb id so the zaurus driver
can properly handle this combined device.

Signed-off-by: Dmitriy Taychenachev <dimichxp@gmail.com>

diff -r 6d17f21bc660 -r 9d2490ddb000 drivers/net/usb/zaurus.c
--- a/drivers/net/usb/zaurus.c	Tue Feb 24 13:23:08 2009 +0800
+++ b/drivers/net/usb/zaurus.c	Tue Feb 24 13:23:08 2009 +0800
@@ -341,6 +341,11 @@
 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MDLM,
 			USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &bogus_mdlm_info,
+}, {
+	/* Motorola MOTOMAGX phones */
+	USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x6425, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &bogus_mdlm_info,
 },
 
 /* Olympus has some models with a Zaurus-compatible option.
