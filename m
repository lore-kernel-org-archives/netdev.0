From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] Cleanup usbnet_probe() return value handling
Date: Mon, 02 Jul 2007 17:40:17 +0200
Message-ID: <87lkdyx19a.fsf@nanv.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dbrownell@users.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.korsgaard.com ([64.79.194.204]:48210 "EHLO nanv.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474AbXGBPkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 11:40:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usbnet_probe() handles a positive return value from the driver bind()
function as success, but will later only setup the status handler if the
return value was zero, leading to confusion. Patch adjusts this to only
accept 0 as success in both checks.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/usbnet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.22-rc7/drivers/net/usb/usbnet.c
===================================================================
--- linux-2.6.22-rc7.orig/drivers/net/usb/usbnet.c
+++ linux-2.6.22-rc7/drivers/net/usb/usbnet.c
@@ -1182,7 +1182,7 @@
 	// NOTE net->name still not usable ...
 	if (info->bind) {
 		status = info->bind (dev, udev);
-		if (status < 0)
+		if (status != 0)
 			goto out1;
 
 		// heuristic:  "usb%d" for links we know are two-host,

-- 
Bye, Peter Korsgaard
