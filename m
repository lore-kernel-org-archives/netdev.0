From: Oliver Neukum <oliver@neukum.org>
Subject: [patch]USB autosuspend for cdc-eem
Date: Thu, 3 Dec 2009 15:25:48 +0100
Message-ID: <200912031525.49001.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Omar Laazimani <omar.oberthur@gmail.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:52982 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbZLCOZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 09:25:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this uses the generic framework of usbnet to implement USB autosuspend
for cdc-eem. Comments?

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oliver@neukum.org>

--

commit 77893e39353314a8982c80a45ef117687789fb4c
Author: Oliver Neukum <oliver@neukum.org>
Date:   Thu Dec 3 14:11:17 2009 +0100

    usb:cdc-eem: implement autosuspend
    
    implements aggressive autosuspend by using the generic methods of usbnet
    
    Signed-off-by: Oliver Neukum <oliver@neukum.org>

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 2330065..d6c16a9 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -335,10 +335,17 @@ next:
 	return 1;
 }
 
+static int eem_manage_power(struct usbnet *dev, int on)
+{
+	dev->intf->needs_remote_wakeup = on;
+	return 0;
+}
+
 static const struct driver_info eem_info = {
 	.description =	"CDC EEM Device",
 	.flags =	FLAG_ETHER,
 	.bind =		eem_bind,
+	.manage_power =	eem_manage_power,
 	.rx_fixup =	eem_rx_fixup,
 	.tx_fixup =	eem_tx_fixup,
 };
@@ -364,6 +371,7 @@ static struct usb_driver eem_driver = {
 	.disconnect =	usbnet_disconnect,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.supports_autosuspend = 1,
 };
 
 
