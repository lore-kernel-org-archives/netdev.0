From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] micrel phy: fix typo in define, point people to device tree
Date: Mon, 7 Jul 2014 23:03:53 +0200
Message-ID: <20140707210353.GA29415@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	kernel@pengutronix.de, shawn.guo@freescale.com,
	plagnioj@jcrosoft.com, nicolas.ferre@atmel.com, linux@maxim.org.za,
	netdev@vger.kernel.org, dinguyen@altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There's typo "SCEW" in some defines, which made my greps fail and
confused me a lot. Plus, Dinh Nguyen pointed out that direct phy
accesses from board files should no longer be needed -- device tree
should be able to configure skew.

Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/arch/arm/mach-at91/board-dt-sama5.c b/arch/arm/mach-at91/board-dt-sama5.c
index 075ec05..528d3ce 100644
--- a/arch/arm/mach-at91/board-dt-sama5.c
+++ b/arch/arm/mach-at91/board-dt-sama5.c
@@ -50,12 +50,15 @@ static int ksz9021rn_phy_fixup(struct phy_device *phy)
 {
 	int value;
 
+	/* Should probably use dts to configure skew, see 
+	   micrel-ksz90x1.txt */
+
 	/* Set delay values */
-	value = MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW | 0x8000;
+	value = MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW | 0x8000;
 	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
 	value = 0xF2F4;
 	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
-	value = MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW | 0x8000;
+	value = MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW | 0x8000;
 	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
 	value = 0x2222;
 	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
index e60456d..fa6c7ad 100644
--- a/arch/arm/mach-imx/mach-imx6q.c
+++ b/arch/arm/mach-imx/mach-imx6q.c
@@ -42,18 +42,19 @@
 /* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
 static int ksz9021rn_phy_fixup(struct phy_device *phydev)
 {
+	/* Should probably use dt to set these, see micrel-ksz90x1.txt */
 	if (IS_BUILTIN(CONFIG_PHYLIB)) {
 		/* min rx data delay */
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
-			0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW);
+			0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW);
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
 
 		/* max rx/tx clock delay, min rx/tx control delay */
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
-			0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
+			0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0xf0f0);
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
-			MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
+			MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
 	}
 
 	return 0;
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -38,9 +38,12 @@
 /* struct phy_device dev_flags definitions */
 #define MICREL_PHY_50MHZ_CLK	0x00000001
 
+/* These probably should not be exported; see micrel-ksz90x1.txt on
+   how to configure skew from device tree. */
 #define MICREL_KSZ9021_EXTREG_CTRL	0xB
 #define MICREL_KSZ9021_EXTREG_DATA_WRITE	0xC
-#define MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW	0x104
-#define MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW	0x105
+#define MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW	0x104
+#define MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW	0x105
+#define MICREL_KSZ9021_RGMII_TX_DATA_PAD_SKEW	0x106
 
 #endif /* _MICREL_PHY_H */


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
