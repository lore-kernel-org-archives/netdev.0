From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [RFC 3/3] arm: mach-mxs: make enabling enet_out a legacy function
Date: Tue, 29 Jan 2013 15:46:13 +0100
Message-ID: <1359470773-14290-4-git-send-email-w.sang@pengutronix.de>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Cc: netdev@vger.kernel.org, Shawn Guo <shawn.guo@freescale.com>,
	Wolfram Sang <w.sang@pengutronix.de>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59049 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756934Ab3A2Oq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 09:46:28 -0500
In-Reply-To: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enet_out is now handled via the driver, so handling it in board init
will print a warning.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
---
 arch/arm/mach-mxs/mach-mxs.c |   24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/arch/arm/mach-mxs/mach-mxs.c b/arch/arm/mach-mxs/mach-mxs.c
index c66129b..1f2e3bf 100644
--- a/arch/arm/mach-mxs/mach-mxs.c
+++ b/arch/arm/mach-mxs/mach-mxs.c
@@ -252,17 +252,25 @@ static void __init imx23_evk_init(void)
 	mxsfb_pdata.ld_intf_width = STMLCDIF_24BIT;
 }
 
-static inline void enable_clk_enet_out(void)
+static inline void legacy_enable_clk_enet_out(void)
 {
-	struct clk *clk = clk_get_sys("enet_out", NULL);
+	struct device_node *np;
+	struct clk *clk;
+
+	for_each_compatible_node(np, NULL, "fsl,imx28-fec")
+		if (of_property_match_string(np, "clock-names", "enet_out") >= 0)
+			return;
+
+	WARN(1, "Please specify enet_out-clk in devicetree.\n");
 
+	clk = clk_get_sys("enet_out", NULL);
 	if (!IS_ERR(clk))
 		clk_prepare_enable(clk);
 }
 
 static void __init imx28_evk_init(void)
 {
-	enable_clk_enet_out();
+	legacy_enable_clk_enet_out();
 	update_fec_mac_prop(OUI_FSL);
 
 	mxsfb_pdata.mode_list = mx28evk_video_modes;
@@ -292,7 +300,7 @@ static void __init m28evk_init(void)
 
 static void __init sc_sps1_init(void)
 {
-	enable_clk_enet_out();
+	legacy_enable_clk_enet_out();
 }
 
 static int apx4devkit_phy_fixup(struct phy_device *phy)
@@ -303,7 +311,7 @@ static int apx4devkit_phy_fixup(struct phy_device *phy)
 
 static void __init apx4devkit_init(void)
 {
-	enable_clk_enet_out();
+	legacy_enable_clk_enet_out();
 
 	if (IS_BUILTIN(CONFIG_PHYLIB))
 		phy_register_fixup_for_uid(PHY_ID_KSZ8051, MICREL_PHY_ID_MASK,
@@ -351,7 +359,7 @@ static void __init tx28_post_init(void)
 	struct pinctrl *pctl;
 	int ret;
 
-	enable_clk_enet_out();
+	legacy_enable_clk_enet_out();
 
 	np = of_find_compatible_node(NULL, NULL, "fsl,imx28-fec");
 	pdev = of_find_device_by_node(np);
@@ -391,13 +399,13 @@ static void __init tx28_post_init(void)
 
 static void __init cfa10049_init(void)
 {
-	enable_clk_enet_out();
+	legacy_enable_clk_enet_out();
 	update_fec_mac_prop(OUI_CRYSTALFONTZ);
 }
 
 static void __init apf28_init(void)
 {
-	enable_clk_enet_out();
+	legacy_enable_clk_enet_out();
 
 	mxsfb_pdata.mode_list = apf28dev_video_modes;
 	mxsfb_pdata.mode_count = ARRAY_SIZE(apf28dev_video_modes);
-- 
1.7.10.4
