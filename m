From: Kirill Esipov <yesipov@gmail.com>
Subject: [PATCH] net: phy: micrel: fix KSZ8041FTL supported value
Date: Mon, 21 Nov 2016 19:53:31 +0300
Message-ID: <1479747211-22394-1-git-send-email-yesipov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Kirill Esipov <yesipov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix setting of SUPPORTED_FIBRE bit as it was not present in features
of KSZ8041.

Signed-off-by: Kirill Esipov <yesipov@gmail.com>
---
 drivers/net/phy/micrel.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 081df68..ea92d52 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -318,12 +318,12 @@ static int ksz8041_config_init(struct phy_device *phydev)
 	/* Limit supported and advertised modes in fiber mode */
 	if (of_property_read_bool(of_node, "micrel,fiber-mode")) {
 		phydev->dev_flags |= MICREL_PHY_FXEN;
-		phydev->supported &= SUPPORTED_FIBRE |
-				     SUPPORTED_100baseT_Full |
+		phydev->supported &= SUPPORTED_100baseT_Full |
 				     SUPPORTED_100baseT_Half;
-		phydev->advertising &= ADVERTISED_FIBRE |
-				       ADVERTISED_100baseT_Full |
+		phydev->supported |= SUPPORTED_FIBRE;
+		phydev->advertising &= ADVERTISED_100baseT_Full |
 				       ADVERTISED_100baseT_Half;
+		phydev->advertising |= ADVERTISED_FIBRE;
 		phydev->autoneg = AUTONEG_DISABLE;
 	}
 
-- 
2.7.4
