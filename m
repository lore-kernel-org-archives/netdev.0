From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/5] smsc95xx: fix error checking of usbnet_resume
Date: Thu, 22 Nov 2012 18:05:22 +0000
Message-ID: <1353607526-19307-2-git-send-email-steve.glendinning@shawell.net>
References: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:59701 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab2KVSaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 13:30:25 -0500
In-Reply-To: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

without this patch the two lines below won't ever execute

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index e083f53..e8465fe 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1304,7 +1304,7 @@ static int smsc95xx_resume(struct usb_interface *intf)
 		check_warn_return(ret, "Error writing PM_CTRL");
 	}
 
-	return usbnet_resume(intf);
+	ret = usbnet_resume(intf);
 	check_warn_return(ret, "usbnet_resume error");
 
 	return 0;
-- 
1.7.10.4
