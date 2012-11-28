From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/6] smsc75xx: check return code from smsc75xx_reset
Date: Wed, 28 Nov 2012 15:59:45 +0000
Message-ID: <1354118391-22666-2-git-send-email-steve.glendinning@shawell.net>
References: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57254 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab2K1QAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:00:00 -0500
In-Reply-To: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a missing check and error message if smsc75xx_reset
fails.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 953c4f4..a36648b 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1163,6 +1163,7 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* Init all registers */
 	ret = smsc75xx_reset(dev);
+	check_warn_return(ret, "smsc75xx_reset error %d\n", ret);
 
 	dev->net->netdev_ops = &smsc75xx_netdev_ops;
 	dev->net->ethtool_ops = &smsc75xx_ethtool_ops;
-- 
1.7.10.4
