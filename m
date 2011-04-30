From: Rabin Vincent <rabin@rab.in>
Subject: [PATCH] smsc95xx: fix reset check
Date: Sat, 30 Apr 2011 23:59:27 +0530
Message-ID: <1304188167-18152-1-git-send-email-rabin@rab.in>
Cc: netdev@vger.kernel.org, Rabin Vincent <rabin@rab.in>
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:33310 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986Ab1D3S26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2011 14:28:58 -0400
Received: by pzk9 with SMTP id 9so2563465pzk.19
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2011 11:28:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reset loop check should check the MII_BMCR register value for
BMCR_RESET rather than for MII_BMCR (the register address, which also
happens to be zero).

Signed-off-by: Rabin Vincent <rabin@rab.in>
---
 drivers/net/usb/smsc95xx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 24f4b37..2b16d54 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -689,7 +689,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 		msleep(10);
 		bmcr = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
 		timeout++;
-	} while ((bmcr & MII_BMCR) && (timeout < 100));
+	} while ((bmcr & BMCR_RESET) && (timeout < 100));
 
 	if (timeout >= 100) {
 		netdev_warn(dev->net, "timeout on PHY Reset");
-- 
1.7.4.1

