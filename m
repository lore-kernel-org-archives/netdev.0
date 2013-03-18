From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 4/4] ARM: mxs: remove unneeded enet_out clk initialization
Date: Mon, 18 Mar 2013 16:26:25 +0800
Message-ID: <1363595185-12302-5-git-send-email-shawn.guo@linaro.org>
References: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Shawn Guo <shawn.guo@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:11392
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644Ab3CRI0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 04:26:41 -0400
In-Reply-To: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With fec driver taking care of enet_out clk, most of board setup
do not need to enable enet_out clk.  So remove them.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 arch/arm/mach-mxs/mach-mxs.c |   12 ------------
 1 file changed, 12 deletions(-)

diff --git a/arch/arm/mach-mxs/mach-mxs.c b/arch/arm/mach-mxs/mach-mxs.c
index 0521867..026edfc 100644
--- a/arch/arm/mach-mxs/mach-mxs.c
+++ b/arch/arm/mach-mxs/mach-mxs.c
@@ -271,7 +271,6 @@ static inline void enable_clk_enet_out(void)
 
 static void __init imx28_evk_init(void)
 {
-	enable_clk_enet_out();
 	update_fec_mac_prop(OUI_FSL);
 
 	mxsfb_pdata.mode_list = mx28evk_video_modes;
@@ -299,11 +298,6 @@ static void __init m28evk_init(void)
 	mxsfb_pdata.ld_intf_width = STMLCDIF_18BIT;
 }
 
-static void __init sc_sps1_init(void)
-{
-	enable_clk_enet_out();
-}
-
 static int apx4devkit_phy_fixup(struct phy_device *phy)
 {
 	phy->dev_flags |= MICREL_PHY_50MHZ_CLK;
@@ -400,13 +394,11 @@ static void __init tx28_post_init(void)
 
 static void __init cfa10049_init(void)
 {
-	enable_clk_enet_out();
 	update_fec_mac_prop(OUI_CRYSTALFONTZ);
 }
 
 static void __init cfa10037_init(void)
 {
-	enable_clk_enet_out();
 	update_fec_mac_prop(OUI_CRYSTALFONTZ);
 
 	mxsfb_pdata.mode_list = cfa10049_video_modes;
@@ -417,8 +409,6 @@ static void __init cfa10037_init(void)
 
 static void __init apf28_init(void)
 {
-	enable_clk_enet_out();
-
 	mxsfb_pdata.mode_list = apf28dev_video_modes;
 	mxsfb_pdata.mode_count = ARRAY_SIZE(apf28dev_video_modes);
 	mxsfb_pdata.default_bpp = 16;
@@ -441,8 +431,6 @@ static void __init mxs_machine_init(void)
 		cfa10049_init();
 	else if (of_machine_is_compatible("armadeus,imx28-apf28"))
 		apf28_init();
-	else if (of_machine_is_compatible("schulercontrol,imx28-sps1"))
-		sc_sps1_init();
 
 	of_platform_populate(NULL, of_default_bus_match_table,
 			     mxs_auxdata_lookup, NULL);
-- 
1.7.9.5
