From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 3.8-stable] usbnet: smsc95xx: fix suspend failure
Date: Mon,  4 Mar 2013 18:07:13 +0800
Message-ID: <1362391633-27551-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	<stable@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41488 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755016Ab3CDKH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 05:07:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The three below functions:

        smsc95xx_enter_suspend0()
        smsc95xx_enter_suspend1()
        smsc95xx_enter_suspend2()

return > 0 in case of success, so they will cause smsc95xx_suspend()
to return > 0 and suspend failure.

This patch is backported from the upstream commit:

	From 7643721471117d5f62ca36f328d3dc8d84af4402 Mon Sep 17 00:00:00 2001
	Subject: [PATCH] usbnet: smsc95xx: fix suspend failure

Cc: <stable@vger.kernel.org>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/smsc95xx.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 9b73670..6214181 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1340,6 +1340,8 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
 	if (ret < 0)
 		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	else
+		ret = 0;
 
 	return ret;
 }
@@ -1392,6 +1394,8 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	if (ret < 0)
 		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	else
+		ret = 0;
 
 	return ret;
 }
@@ -1413,6 +1417,8 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	if (ret < 0)
 		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	else
+		ret = 0;
 
 	return ret;
 }
-- 
1.7.9.5
