From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH] smsc75xx: fix resume after device reset
Date: Mon, 24 Sep 2012 15:42:59 +0100
Message-ID: <1348497779-10042-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:37743 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756063Ab2IXOq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:46:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some systems this device fails to properly resume after suspend,
this patch fixes it by running the usbnet_resume handler.

I suspect this also fixes this bug:

http://code.google.com/p/chromium-os/issues/detail?id=31871
---
 drivers/net/usb/smsc75xx.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index f5ab6e6..376143e 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1253,6 +1253,7 @@ static struct usb_driver smsc75xx_driver = {
 	.probe		= usbnet_probe,
 	.suspend	= usbnet_suspend,
 	.resume		= usbnet_resume,
+	.reset_resume	= usbnet_resume,
 	.disconnect	= usbnet_disconnect,
 	.disable_hub_initiated_lpm = 1,
 };
-- 
1.7.9.5
