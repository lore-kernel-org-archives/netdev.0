From: Dmitriy Taychenachev <dimichxp@gmail.com>
Subject: [PATCH] zaurus: add usb id for motomagx phones
Date: Wed, 25 Feb 2009 12:42:48 +0800
Message-ID: <926cbbc4e9918fbc372a.1235536968@wifi.master>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:3698 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbZBYEnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 23:43:02 -0500
Received: by fk-out-0910.google.com with SMTP id f33so1899959fkf.5
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2009 20:42:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Motorola MOTOMAGX phones (Z6, E8, Zn5 so far) are providing
combined ACM/BLAN USB configuration. Since it has Vendor Specific
class, the corresponding drivers (cdc-acm, zaurus) can't find it just
by interface info. This patch adds usb id so the zaurus driver can
properly handle this combined device.

Signed-off-by: Dmitriy Taychenachev <dimichxp@gmail.com>

diff -r 2651740bf64c -r 926cbbc4e991 drivers/net/usb/zaurus.c
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
