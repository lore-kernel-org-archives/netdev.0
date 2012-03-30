From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] sky2: dont overwrite settings for PHY Quick link
Date: Fri, 30 Mar 2012 19:28:59 +0200
Message-ID: <20120330172859.GB2703@Neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:42219 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758413Ab2C3R25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 13:28:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch corrects a bug in function sky2_open() of the Marvell Yukon 2 driver
in which the settings for PHY quick link are overwritten.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 This applies against 3.3

 drivers/net/ethernet/marvell/sky2.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 760c2b1..d0132d8 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1756,13 +1756,14 @@ static int sky2_open(struct net_device *dev)
 
 	sky2_hw_up(sky2);
 
+	/* Enable interrupts from phy/mac for port */
+	imask = sky2_read32(hw, B0_IMSK);
+
 	if (hw->chip_id == CHIP_ID_YUKON_OPT ||
 	    hw->chip_id == CHIP_ID_YUKON_PRM ||
 	    hw->chip_id == CHIP_ID_YUKON_OP_2)
 		imask |= Y2_IS_PHY_QLNK;	/* enable PHY Quick Link */
 
-	/* Enable interrupts from phy/mac for port */
-	imask = sky2_read32(hw, B0_IMSK);
 	imask |= portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 	sky2_read32(hw, B0_IMSK);
-- 
1.5.6.5
