From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v2 1/6] ARM: davinci: da850: fix clock lookup for mdio device
Date: Mon, 28 Jan 2013 19:17:54 +0530
Message-ID: <1359380879-26306-2-git-send-email-prabhakar.lad@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Heiko Schocher <hs@denx.de>,
	"Lad, Prabhakar" <prabhakar.lad@ti.com>
To: Sekhar Nori <nsekhar@ti.com>, linux-arm-kernel@lists.infradead.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:47787 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756777Ab3A1Ns2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 08:48:28 -0500
In-Reply-To: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lad, Prabhakar <prabhakar.lad@ti.com>

This patch removes the clock alias for mdio device and adds a entry
in clock lookup table, this entry can now be used by both DT and NON
DT case.

Signed-off-by: Lad, Prabhakar <prabhakar.lad@ti.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Heiko Schocher <hs@denx.de>
---
 arch/arm/mach-davinci/da850.c         |    1 +
 arch/arm/mach-davinci/devices-da8xx.c |    8 ++------
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/arch/arm/mach-davinci/da850.c b/arch/arm/mach-davinci/da850.c
index 86056ca..f74bfb6 100644
--- a/arch/arm/mach-davinci/da850.c
+++ b/arch/arm/mach-davinci/da850.c
@@ -402,6 +402,7 @@ static struct clk_lookup da850_clks[] = {
 	CLK(NULL,		"arm",		&arm_clk),
 	CLK(NULL,		"rmii",		&rmii_clk),
 	CLK("davinci_emac.1",	NULL,		&emac_clk),
+	CLK("davinci_mdio.0",	"fck",		&emac_clk),
 	CLK("davinci-mcasp.0",	NULL,		&mcasp_clk),
 	CLK("da8xx_lcdc.0",	"fck",		&lcdc_clk),
 	CLK("davinci_mmc.0",	NULL,		&mmcsd0_clk),
diff --git a/arch/arm/mach-davinci/devices-da8xx.c b/arch/arm/mach-davinci/devices-da8xx.c
index 2d5502d..52faa05 100644
--- a/arch/arm/mach-davinci/devices-da8xx.c
+++ b/arch/arm/mach-davinci/devices-da8xx.c
@@ -444,12 +444,8 @@ int __init da8xx_register_emac(void)
 	ret = platform_device_register(&da8xx_mdio_device);
 	if (ret < 0)
 		return ret;
-	ret = platform_device_register(&da8xx_emac_device);
-	if (ret < 0)
-		return ret;
-	ret = clk_add_alias(NULL, dev_name(&da8xx_mdio_device.dev),
-			    NULL, &da8xx_emac_device.dev);
-	return ret;
+
+	return platform_device_register(&da8xx_emac_device);
 }
 
 static struct resource da830_mcasp1_resources[] = {
-- 
1.7.4.1
