From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH net-next-2.6] cx82310_eth: check usb_string() return value for error
Date: Sat, 11 Sep 2010 17:39:57 +0200
Message-ID: <201009111740.00243.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:56660 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752363Ab0IKPkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Sep 2010 11:40:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix that usb_string() return value is not checked for error (negative value).
Also change the ignore message a bit and lower its level to info.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.36-rc3-/drivers/net/usb/cx82310_eth.c	2010-09-11 17:06:59.000000000 +0200
+++ linux-2.6.36-rc3/drivers/net/usb/cx82310_eth.c	2010-09-11 17:21:22.000000000 +0200
@@ -138,11 +138,9 @@ static int cx82310_bind(struct usbnet *d
 	struct usb_device *udev = dev->udev;
 
 	/* avoid ADSL modems - continue only if iProduct is "USB NET CARD" */
-	if (udev->descriptor.iProduct &&
-	    usb_string(udev, udev->descriptor.iProduct, buf, sizeof(buf)) &&
-	    strcmp(buf, "USB NET CARD")) {
-		dev_err(&udev->dev,
-			"probably an ADSL modem, use cxacru driver instead\n");
+	if (usb_string(udev, udev->descriptor.iProduct, buf, sizeof(buf)) > 0
+	    && strcmp(buf, "USB NET CARD")) {
+		dev_info(&udev->dev, "ignoring: probably an ADSL modem\n");
 		return -ENODEV;
 	}
 


-- 
Ondrej Zary
