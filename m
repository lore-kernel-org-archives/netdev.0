From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH 3/3] arm: imx: don't check for CONFIG_PHYLIB as builtin
Date: Mon, 27 May 2013 18:18:44 +0200
Message-ID: <1369671524-14797-4-git-send-email-alexandre.belloni@free-electrons.com>
References: <1369671524-14797-1-git-send-email-alexandre.belloni@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	Sascha Hauer <kernel@pengutronix.de>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369671524-14797-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 arch/arm/mach-imx/mach-imx6q.c | 23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
index 5536fd8..91c3cfb 100644
--- a/arch/arm/mach-imx/mach-imx6q.c
+++ b/arch/arm/mach-imx/mach-imx6q.c
@@ -99,16 +99,14 @@ soft:
 /* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
 static int ksz9021rn_phy_fixup(struct phy_device *phydev)
 {
-	if (IS_BUILTIN(CONFIG_PHYLIB)) {
-		/* min rx data delay */
-		phy_write(phydev, 0x0b, 0x8105);
-		phy_write(phydev, 0x0c, 0x0000);
-
-		/* max rx/tx clock delay, min rx/tx control delay */
-		phy_write(phydev, 0x0b, 0x8104);
-		phy_write(phydev, 0x0c, 0xf0f0);
-		phy_write(phydev, 0x0b, 0x104);
-	}
+	/* min rx data delay */
+	phy_write(phydev, 0x0b, 0x8105);
+	phy_write(phydev, 0x0c, 0x0000);
+
+	/* max rx/tx clock delay, min rx/tx control delay */
+	phy_write(phydev, 0x0b, 0x8104);
+	phy_write(phydev, 0x0c, 0xf0f0);
+	phy_write(phydev, 0x0b, 0x104);
 
 	return 0;
 }
@@ -139,9 +137,8 @@ put_clk:
 
 static void __init imx6q_sabrelite_init(void)
 {
-	if (IS_BUILTIN(CONFIG_PHYLIB))
-		phy_register_fixup_for_uid(PHY_ID_KSZ9021, MICREL_PHY_ID_MASK,
-				ksz9021rn_phy_fixup);
+	phy_register_fixup_for_uid(PHY_ID_KSZ9021, MICREL_PHY_ID_MASK,
+			ksz9021rn_phy_fixup);
 	imx6q_sabrelite_cko1_setup();
 }
 
-- 
1.8.1.2
