From: Marek Vasut <marex@denx.de>
Subject: [PATCH 2/3 V4] phy/micrel: Rename KS80xx to KSZ80xx
Date: Mon, 24 Sep 2012 04:58:50 +0200
Message-ID: <1348455531-24371-2-git-send-email-marex@denx.de>
References: <1348455531-24371-1-git-send-email-marex@denx.de>
Cc: Marek Vasut <marex@denx.de>,
	"David J. Choi" <david.choi@micrel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Linux ARM kernel <linux-arm-kernel@lists.infradead.org>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:54909 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700Ab2IXC65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2012 22:58:57 -0400
In-Reply-To: <1348455531-24371-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no such part as KS8001, KS8041 or KS8051. There are only
KSZ8001, KSZ8041 and KSZ8051. Rename these parts as such to match
the Micrel naming.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: David J. Choi <david.choi@micrel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Cc: Linux ARM kernel <linux-arm-kernel@lists.infradead.org>
Cc: Fabio Estevam <fabio.estevam@freescale.com>
Cc: Shawn Guo <shawn.guo@linaro.org>
---
 arch/arm/mach-mxs/mach-mxs.c |    2 +-
 drivers/net/phy/micrel.c     |   18 +++++++++---------
 include/linux/micrel_phy.h   |    6 +++---
 3 files changed, 13 insertions(+), 13 deletions(-)

V2: Rebase this on adjusted 1/3 patch
V3: Resend, rebased on V2
V4: Resend, rebased on V3 (with no changes)

NOTE: This affect one board in Linux ARM, but the change is
      very minor it should not cause merge conflict, so if
      this could go through net, that would be for the best.

diff --git a/arch/arm/mach-mxs/mach-mxs.c b/arch/arm/mach-mxs/mach-mxs.c
index 3f29a52..fc9c8d5 100644
--- a/arch/arm/mach-mxs/mach-mxs.c
+++ b/arch/arm/mach-mxs/mach-mxs.c
@@ -295,7 +295,7 @@ static void __init apx4devkit_init(void)
 	enable_clk_enet_out();
 
 	if (IS_BUILTIN(CONFIG_PHYLIB))
-		phy_register_fixup_for_uid(PHY_ID_KS8051, MICREL_PHY_ID_MASK,
+		phy_register_fixup_for_uid(PHY_ID_KSZ8051, MICREL_PHY_ID_MASK,
 					   apx4devkit_phy_fixup);
 
 	mxsfb_pdata.mode_list = apx4devkit_video_modes;
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index e8e00dc..2165d5f 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -154,9 +154,9 @@ static struct phy_driver ksphy_driver[] = {
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
-	.phy_id		= PHY_ID_KS8041,
+	.phy_id		= PHY_ID_KSZ8041,
 	.phy_id_mask	= 0x00fffff0,
-	.name		= "Micrel KS8041",
+	.name		= "Micrel KSZ8041",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -167,9 +167,9 @@ static struct phy_driver ksphy_driver[] = {
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
-	.phy_id		= PHY_ID_KS8051,
+	.phy_id		= PHY_ID_KSZ8051,
 	.phy_id_mask	= 0x00fffff0,
-	.name		= "Micrel KS8051",
+	.name		= "Micrel KSZ8051",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -180,8 +180,8 @@ static struct phy_driver ksphy_driver[] = {
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
-	.phy_id		= PHY_ID_KS8001,
-	.name		= "Micrel KS8001 or KS8721",
+	.phy_id		= PHY_ID_KSZ8001,
+	.name		= "Micrel KSZ8001 or KS8721",
 	.phy_id_mask	= 0x00ffffff,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -227,11 +227,11 @@ MODULE_LICENSE("GPL");
 
 static struct mdio_device_id __maybe_unused micrel_tbl[] = {
 	{ PHY_ID_KSZ9021, 0x000ffffe },
-	{ PHY_ID_KS8001, 0x00ffffff },
+	{ PHY_ID_KSZ8001, 0x00ffffff },
 	{ PHY_ID_KS8737, 0x00fffff0 },
 	{ PHY_ID_KSZ8021, 0x00ffffff },
-	{ PHY_ID_KS8041, 0x00fffff0 },
-	{ PHY_ID_KS8051, 0x00fffff0 },
+	{ PHY_ID_KSZ8041, 0x00fffff0 },
+	{ PHY_ID_KSZ8051, 0x00fffff0 },
 	{ }
 };
 
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index be7f366..d02355d 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -6,10 +6,10 @@
 #define PHY_ID_KSZ9021		0x00221610
 #define PHY_ID_KS8737		0x00221720
 #define PHY_ID_KSZ8021		0x00221555
-#define PHY_ID_KS8041		0x00221510
-#define PHY_ID_KS8051		0x00221550
+#define PHY_ID_KSZ8041		0x00221510
+#define PHY_ID_KSZ8051		0x00221550
 /* both for ks8001 Rev. A/B, and for ks8721 Rev 3. */
-#define PHY_ID_KS8001		0x0022161A
+#define PHY_ID_KSZ8001		0x0022161A
 
 /* struct phy_device dev_flags definitions */
 #define MICREL_PHY_50MHZ_CLK	0x00000001
-- 
1.7.10.4
