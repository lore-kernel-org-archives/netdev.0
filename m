From: Alexander Graf <agraf@suse.de>
Subject: [PATCH v2 1/2] phy dp83867: Fix compilation with CONFIG_OF_MDIO=m
Date: Mon, 16 May 2016 20:52:42 +0200
Message-ID: <1463424763-58807-1-git-send-email-agraf@suse.de>
Cc: linux-kernel@vger.kernel.org, michal.simek@xilinx.com,
	Dan Murphy <dmurphy@ti.com>, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_OF_MDIO is configured as module, the #define for it really
is CONFIG_OF_MDIO_MODULE, not CONFIG_OF_MDIO. So if we are compiling it
as module, the dp83867 doesn't see that OF_MDIO was selected and doesn't
read the dt rgmii parameters.

The fix is simple: Use IS_ENABLED(). It checks for both - module as well
as compiled in code.

Signed-off-by: Alexander Graf <agraf@suse.de>
---
 drivers/net/phy/dp83867.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 2afa61b..94cc278 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -99,7 +99,7 @@ static int dp83867_config_intr(struct phy_device *phydev)
 	return phy_write(phydev, MII_DP83867_MICR, micr_status);
 }
 
-#ifdef CONFIG_OF_MDIO
+#if IS_ENABLED(CONFIG_OF_MDIO)
 static int dp83867_of_init(struct phy_device *phydev)
 {
 	struct dp83867_private *dp83867 = phydev->priv;
-- 
1.8.5.6
