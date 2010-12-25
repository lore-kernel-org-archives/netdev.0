From: Dan Carpenter <error27@gmail.com>
Subject: [patch] USB: cdc_ether: remove unneeded check
Date: Sun, 26 Dec 2010 01:23:42 +0300
Message-ID: <20101225222341.GS1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Oliver Neukum <oliver@neukum.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37603 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab0LYWX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 17:23:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already verified that "dev->udev->actconfig->extralen" was non-zero
so "len" is non-zero here as well.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
Compile tested.

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index b3fe0de..9a60e41 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -99,9 +99,7 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 		 */
 		buf = dev->udev->actconfig->extra;
 		len = dev->udev->actconfig->extralen;
-		if (len)
-			dev_dbg(&intf->dev,
-				"CDC descriptors on config\n");
+		dev_dbg(&intf->dev, "CDC descriptors on config\n");
 	}
 
 	/* Maybe CDC descriptors are after the endpoint?  This bug has
