From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 4/6] smsc95xx: sleep before read for lengthy operations
Date: Wed, 10 Mar 2010 18:32:37 +0000
Message-ID: <1268245959-13861-5-git-send-email-steve.glendinning@smsc.com>
References: <1268245959-13861-1-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-2-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-3-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-4-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:41122 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932698Ab0CJScv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:32:51 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 1409867E45
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:32:40 +0000 (GMT)
In-Reply-To: <1268245959-13861-4-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During init, the device reset is unexpected to complete immediately,
so sleep before testing the condition rather than after it.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index a55dc27..56fe73d 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -768,12 +768,12 @@ static int smsc95xx_reset(struct usbnet *dev)
 
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
 
@@ -791,12 +791,12 @@ static int smsc95xx_reset(struct usbnet *dev)
 
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
1.6.6.1

