From: Wang Jian <lark@linux.net.cn>
Subject: [PATCH 1/2] Fix copper/fiber auto-selection for 88e1111
Date: Wed, 16 Jul 2008 21:46:17 +0800
Message-ID: <487DFBA9.8070400@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexandr Smirnov <asmirnov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.82.31.146] ([210.82.31.146]:49012 "EHLO mx.linux.net.cn"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757058AbYGPNqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 09:46:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 27.15 bit (MII_M1111_HWCFG_FIBER_COPPER_AUTO) is disable bit. When
set to 1, copper/fiber auto selection is disabled. The current code
to enable but actually disable auto selection.

Signed-off-by: Wang Jian <lark@linux.net.cn>
---
  drivers/net/phy/marvell.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 32a8503..737512c 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -162,7 +162,7 @@ static int m88e1111_config_init(struct phy_device
*phydev)

  	/* Enable Fiber/Copper auto selection */
  	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
-	temp |= MII_M1111_HWCFG_FIBER_COPPER_AUTO;
+	temp &= ~MII_M1111_HWCFG_FIBER_COPPER_AUTO;
  	phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);

  	temp = phy_read(phydev, MII_BMCR);
-- 
1.5.5.4









