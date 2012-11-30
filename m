From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/2] smsc75xx: don't call usbnet_resume if usbnet_suspend fails
Date: Fri, 30 Nov 2012 14:52:43 +0000
Message-ID: <1354287164-9884-2-git-send-email-steve.glendinning@shawell.net>
References: <1354287164-9884-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47299 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498Ab2K3Owt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 09:52:49 -0500
In-Reply-To: <1354287164-9884-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If usbnet_suspend returns an error we don't want to call
usbnet_resume to clean up, but instead just return the error.

If usbnet_suspend *does* succeed, and we have a problem further
on, the desired behaviour is still to call usbnet_resume
to clean up before returning.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1823806..86d9249 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1411,7 +1411,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 	int ret;
 
 	ret = usbnet_suspend(intf, message);
-	check_warn_goto_done(ret, "usbnet_suspend error\n");
+	check_warn_return(ret, "usbnet_suspend error\n");
 
 	if (pdata->suspend_flags) {
 		netdev_warn(dev->net, "error during last resume\n");
-- 
1.7.10.4
