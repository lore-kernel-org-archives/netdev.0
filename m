From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH] smsc95xx: fix suspend buffer overflow
Date: Tue, 27 Nov 2012 13:23:43 +0000
Message-ID: <1354022623-7317-1-git-send-email-steve.glendinning@shawell.net>
Cc: dan.carpenter@oracle.com,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47109 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771Ab2K0NXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 08:23:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a buffer overflow introduced by bbd9f9e, where
the filter_mask array is accessed beyond its bounds.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 79d495d..6cdc504 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1281,7 +1281,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	}
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
-		u32 *filter_mask = kzalloc(32, GFP_KERNEL);
+		u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);
 		u32 command[2];
 		u32 offset[2];
 		u32 crc[4];
-- 
1.7.10.4
