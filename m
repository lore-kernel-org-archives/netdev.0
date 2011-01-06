From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v4 07/10] ARM: mx28: add the second fec device registration
Date: Thu, 6 Jan 2011 15:13:15 +0800
Message-ID: <1294297998-26930-8-git-send-email-shawn.guo@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:27142
	"EHLO DB3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753972Ab1AFHMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 02:12:03 -0500
In-Reply-To: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
 arch/arm/mach-mxs/mach-mx28evk.c |   28 +++++++++++++++++++++++++---
 1 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/arch/arm/mach-mxs/mach-mx28evk.c b/arch/arm/mach-mxs/mach-mx28evk.c
index d162e95..def6519 100644
--- a/arch/arm/mach-mxs/mach-mx28evk.c
+++ b/arch/arm/mach-mxs/mach-mx28evk.c
@@ -57,6 +57,19 @@ static const iomux_cfg_t mx28evk_pads[] __initconst = {
 		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
 	MX28_PAD_ENET_CLK__CLKCTRL_ENET |
 		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
+	/* fec1 */
+	MX28_PAD_ENET0_CRS__ENET1_RX_EN |
+		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
+	MX28_PAD_ENET0_RXD2__ENET1_RXD0 |
+		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
+	MX28_PAD_ENET0_RXD3__ENET1_RXD1 |
+		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
+	MX28_PAD_ENET0_COL__ENET1_TX_EN |
+		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
+	MX28_PAD_ENET0_TXD2__ENET1_TXD0 |
+		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
+	MX28_PAD_ENET0_TXD3__ENET1_TXD1 |
+		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
 	/* phy power line */
 	MX28_PAD_SSP1_DATA3__GPIO_2_15 |
 		(MXS_PAD_4MA | MXS_PAD_3V3 | MXS_PAD_NOPULL),
@@ -106,8 +119,14 @@ static void __init mx28evk_fec_reset(void)
 	gpio_set_value(MX28EVK_FEC_PHY_RESET, 1);
 }
 
-static const struct fec_platform_data mx28_fec_pdata __initconst = {
-	.phy = PHY_INTERFACE_MODE_RMII,
+static struct fec_platform_data mx28_fec_pdata[] = {
+	{
+		/* fec0 */
+		.phy = PHY_INTERFACE_MODE_RMII,
+	}, {
+		/* fec1 */
+		.phy = PHY_INTERFACE_MODE_RMII,
+	},
 };
 
 static void __init mx28evk_init(void)
@@ -117,7 +136,10 @@ static void __init mx28evk_init(void)
 	mx28_add_duart();
 
 	mx28evk_fec_reset();
-	mx28_add_fec(0, &mx28_fec_pdata);
+	mx28_add_fec(0, &mx28_fec_pdata[0]);
+#ifdef CONFIG_FEC2
+	mx28_add_fec(1, &mx28_fec_pdata[1]);
+#endif
 }
 
 static void __init mx28evk_timer_init(void)
-- 
1.7.1


