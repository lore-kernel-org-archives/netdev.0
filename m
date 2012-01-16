From: Dmitry Antipov <dmitry.antipov@linaro.org>
Subject: [PATCH] drivers/net/usb/smsc95xx.c: change msleep() to usleep_range()
Date: Mon, 16 Jan 2012 12:49:34 +0400
Message-ID: <1326703774-1154-1-git-send-email-dmitry.antipov@linaro.org>
Cc: patches@linaro.org, Dmitry Antipov <dmitry.antipov@linaro.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60189 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593Ab2APIso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 03:48:44 -0500
Received: by bkas6 with SMTP id s6so424087bka.19
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2012 00:48:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The resolution of msleep is related to HZ, so 10ms msleep() causes
~23ms sleep with OMAP's default CONFIG_HZ=128 timer configuration.
This looks too much, and usleep_range() with some slack gives more
control of what is happening here.

Signed-off-by: Dmitry Antipov <dmitry.antipov@linaro.org>
---
 drivers/net/usb/smsc95xx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d45520e..5d406d4 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -688,7 +688,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
 
 	do {
-		msleep(10);
+		usleep_range(10000, 15000);
 		bmcr = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
 		timeout++;
 	} while ((bmcr & BMCR_RESET) && (timeout < 100));
@@ -736,7 +736,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 			return ret;
 		}
-		msleep(10);
+		usleep_range(10000, 15000);
 		timeout++;
 	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
 
@@ -759,7 +759,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 			netdev_warn(dev->net, "Failed to read PM_CTRL: %d\n", ret);
 			return ret;
 		}
-		msleep(10);
+		usleep_range(10000, 15000);
 		timeout++;
 	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
 
-- 
1.7.7.5
