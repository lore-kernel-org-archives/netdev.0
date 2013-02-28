From: Vlastimil Kosar <ikosar@fit.vutbr.cz>
Subject: [PATCH 1/1] net/phy: micrel: Disable asymmetric pause for KSZ9021
Date: Thu, 28 Feb 2013 19:45:22 +0100
Message-ID: <1362077122-4266-1-git-send-email-ikosar@fit.vutbr.cz>
Cc: linux-kernel@vger.kernel.org, Vlastimil Kosar <ikosar@fit.vutbr.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eva.fit.vutbr.cz ([147.229.176.14]:49706 "EHLO eva.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932149Ab3B1S67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 13:58:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phyter KSZ9021 has hardware bug. If asymmetric pause is enabled,
then it is necessary to disconnect and then reconnect the ethernet
cable to get the phyter working. The solution is to disable the
asymmetric pause.

Signed-off-by: Vlastimil Kosar <ikosar@fit.vutbr.cz>
---
 drivers/net/phy/micrel.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 2993444..abf7b61 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -257,8 +257,7 @@ static struct phy_driver ksphy_driver[] = {
 	.phy_id		= PHY_ID_KSZ9021,
 	.phy_id_mask	= 0x000ffffe,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
-	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
-- 
1.7.2.5
