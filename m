From: Wang Jian <lark@linux.net.cn>
Subject: [PATCH 2/2] Fix 88e1111 copper/fiber selection in RGMII mode
Date: Wed, 16 Jul 2008 21:46:20 +0800
Message-ID: <487DFBAC.7090006@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexandr Smirnov <asmirnov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.82.31.146] ([210.82.31.146]:49017 "EHLO mx.linux.net.cn"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757205AbYGPNqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 09:46:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MII_M1111_HWCFG_FIBER_COPPER_RES is a bit of MII_M1111_PHY_EXT_SR, not
MII_M1111_PHY_EXT_CR.

Signed-off-by: Wang Jian <lark@linux.net.cn>
---
 drivers/net/phy/marvell.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 737512c..4aa5479 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -158,7 +158,6 @@ static int m88e1111_config_init(struct phy_device
*phydev)
 {
 	int err;
 	int temp;
-	int mode;

 	/* Enable Fiber/Copper auto selection */
 	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
@@ -198,9 +197,7 @@ static int m88e1111_config_init(struct phy_device
*phydev)

 		temp &= ~(MII_M1111_HWCFG_MODE_MASK);

-		mode = phy_read(phydev, MII_M1111_PHY_EXT_CR);
-
-		if (mode & MII_M1111_HWCFG_FIBER_COPPER_RES)
+		if (temp & MII_M1111_HWCFG_FIBER_COPPER_RES)
 			temp |= MII_M1111_HWCFG_MODE_FIBER_RGMII;
 		else
 			temp |= MII_M1111_HWCFG_MODE_COPPER_RGMII;
-- 
1.5.5.4







