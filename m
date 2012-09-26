From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/5] smsc95xx: sleep before read for lengthy operations
Date: Wed, 26 Sep 2012 13:40:20 +0100
Message-ID: <1348663224-30403-2-git-send-email-steve.glendinning@shawell.net>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:56606 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab2IZMk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 08:40:28 -0400
In-Reply-To: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During init, the device reset is unexpected to complete immediately,
so sleep before testing the condition rather than after it.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d45e539..ed1e551 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -763,12 +763,12 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	timeout = 0;
 	do {
+		msleep(10);
 		ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 		if (ret < 0) {
 			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 			return ret;
 		}
-		msleep(10);
 		timeout++;
 	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
 
@@ -786,12 +786,12 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	timeout = 0;
 	do {
+		msleep(10);
 		ret = smsc95xx_read_reg(dev, PM_CTRL, &read_buf);
 		if (ret < 0) {
 			netdev_warn(dev->net, "Failed to read PM_CTRL: %d\n", ret);
 			return ret;
 		}
-		msleep(10);
 		timeout++;
 	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
 
-- 
1.7.9.5
