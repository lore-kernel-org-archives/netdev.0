From: Kosta Zertsekel <konszert@marvell.com>
Subject: [PATCH] Fix phy_init for Marvell network eth driver
Date: Thu, 10 Jan 2013 12:04:58 +0200
Message-ID: <1357812298-26399-2-git-send-email-konszert@marvell.com>
References: <1357812298-26399-1-git-send-email-konszert@marvell.com>
Cc: benavi@marvell.com, alior@marvell.com,
	linux-arm-kernel@lists.infradead.org, andrew@lunn.ch,
	Kosta Zertsekel <konszert@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:51995 "EHLO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752167Ab3AJKLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 05:11:06 -0500
In-Reply-To: <1357812298-26399-1-git-send-email-konszert@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least it fixes DNS323_REV_C1 board case (mach-orion5x/dsn323-setup.c file).

Change-Id: I37d64795f79c358f66a211a150cec2263e40e295
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 84c1326..7b8c1ac 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2789,7 +2789,7 @@ static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 
 	phy_reset(mp);
 
-	phy_attach(mp->dev, dev_name(&phy->dev), 0, PHY_INTERFACE_MODE_GMII);
+	phy_attach(mp->dev, dev_name(&phy->dev), phy->dev_flags, PHY_INTERFACE_MODE_GMII);
 
 	if (speed == 0) {
 		phy->autoneg = AUTONEG_ENABLE;
-- 
1.8.1
