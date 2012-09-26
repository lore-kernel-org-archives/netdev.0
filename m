From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 4/5] smsc95xx: fix resume when usb device is reset
Date: Wed, 26 Sep 2012 13:40:23 +0100
Message-ID: <1348663224-30403-5-git-send-email-steve.glendinning@shawell.net>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:56606 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186Ab2IZMkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 08:40:33 -0400
In-Reply-To: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an issue on some systems, where after suspend the
link is re-established but the ethernet interface does not resume.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d0ff01e..f29860d 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1282,6 +1282,7 @@ static struct usb_driver smsc95xx_driver = {
 	.probe		= usbnet_probe,
 	.suspend	= usbnet_suspend,
 	.resume		= usbnet_resume,
+	.reset_resume	= usbnet_resume,
 	.disconnect	= usbnet_disconnect,
 	.disable_hub_initiated_lpm = 1,
 };
-- 
1.7.9.5
