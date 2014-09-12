From: Mike Looijmans <mike.looijmans@topic.nl>
Subject: [PATCH v2] net/phy: micrel: Disable asymmetric pause for KSZ9031
Date: Fri, 12 Sep 2014 14:40:37 +0200
Message-ID: <1410525637-849-1-git-send-email-mike.looijmans@topic.nl>
References: <5411ECE9.8050600@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Looijmans <mike.looijmans@topic.nl>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5411ECE9.8050600@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The KSZ9031 appears to suffer from the same hardware bug as described
for the KSZ9021 in commit 32fcafbcd1c9f6c7013016a22a5369b4acb93577
("net/phy: micrel: Disable asymmetric pause for KSZ9021")
you have to unplug the cable and plug it back to get it to work.

Remove the SUPPORTED_Asym_Pause flag for the KSZ9031 to fix this.

Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
---
 drivers/net/phy/micrel.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 5a8993b..a932a35 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -425,8 +425,7 @@ static struct phy_driver ksphy_driver[] = {
 	.phy_id		= PHY_ID_KSZ9031,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KSZ9031 Gigabit PHY",
-	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
-				| SUPPORTED_Asym_Pause),
+	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
-- 
1.7.9.5
