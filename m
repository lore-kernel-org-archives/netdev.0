From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v3 1/6] ARM: davinci: da8xx: fix clock lookup for mdio device
Date: Sun, 23 Jun 2013 20:30:02 +0530
Message-ID: <1371999607-6483-2-git-send-email-prabhakar.csengg@gmail.com>
References: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Heiko Schocher <hs@denx.de>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	devicetree-discuss@lists.ozlabs.org, Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

This patch removes the clock alias for mdio device and adds a entry
in clock lookup table, this entry can now be used by both DT and NON
DT case.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Heiko Schocher <hs@denx.de>
---
 changes for v2: None
 Changes for v3: 
  a> added clock lookup entry for davinci_mdio in da830 file.
 
 arch/arm/mach-davinci/da830.c         |    1 +
 arch/arm/mach-davinci/da850.c         |    1 +
 arch/arm/mach-davinci/devices-da8xx.c |    8 ++------
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/arch/arm/mach-davinci/da830.c b/arch/arm/mach-davinci/da830.c
index abbaf02..1f949a9 100644
--- a/arch/arm/mach-davinci/da830.c
+++ b/arch/arm/mach-davinci/da830.c
@@ -417,6 +417,7 @@ static struct clk_lookup da830_clks[] = {
 	CLK(NULL,		"aintc",	&aintc_clk),
 	CLK(NULL,		"secu_mgr",	&secu_mgr_clk),
 	CLK("davinci_emac.1",	NULL,		&emac_clk),
+	CLK("davinci_mdio.0",   "fck",          &emac_clk),
 	CLK(NULL,		"gpio",		&gpio_clk),
 	CLK("i2c_davinci.2",	NULL,		&i2c1_clk),
 	CLK(NULL,		"usb11",	&usb11_clk),
diff --git a/arch/arm/mach-davinci/da850.c b/arch/arm/mach-davinci/da850.c
index 183a7dd..c43abee 100644
--- a/arch/arm/mach-davinci/da850.c
+++ b/arch/arm/mach-davinci/da850.c
@@ -461,6 +461,7 @@ static struct clk_lookup da850_clks[] = {
 	CLK(NULL,		"arm",		&arm_clk),
 	CLK(NULL,		"rmii",		&rmii_clk),
 	CLK("davinci_emac.1",	NULL,		&emac_clk),
+	CLK("davinci_mdio.0",	"fck",		&emac_clk),
 	CLK("davinci-mcasp.0",	NULL,		&mcasp_clk),
 	CLK("da8xx_lcdc.0",	"fck",		&lcdc_clk),
 	CLK("da830-mmc.0",	NULL,		&mmcsd0_clk),
diff --git a/arch/arm/mach-davinci/devices-da8xx.c b/arch/arm/mach-davinci/devices-da8xx.c
index bf57252..a5a78d9 100644
--- a/arch/arm/mach-davinci/devices-da8xx.c
+++ b/arch/arm/mach-davinci/devices-da8xx.c
@@ -452,12 +452,8 @@ int __init da8xx_register_emac(void)
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
1.7.9.5
