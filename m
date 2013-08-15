From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: [PATCH v4 1/5] ARM: davinci: fix clock lookup for mdio device
Date: Thu, 15 Aug 2013 11:31:33 +0530
Message-ID: <1376546497-26931-2-git-send-email-prabhakar.csengg@gmail.com>
References: <1376546497-26931-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376546497-26931-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

This patch removes the clock alias for mdio device and adds a entry
in clock lookup table, this entry can now be used by both DT and NON
DT case.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 changes for v2: None
 
 Changes for v3: 
  a> added clock lookup entry for davinci_mdio in da830 file.
 
 Changes for v4:
 a> added clock lookup entry for all davinci devices.
 
 arch/arm/mach-davinci/da830.c         |    1 +
 arch/arm/mach-davinci/da850.c         |    1 +
 arch/arm/mach-davinci/devices-da8xx.c |    8 ++------
 arch/arm/mach-davinci/dm365.c         |    3 +--
 arch/arm/mach-davinci/dm644x.c        |    3 +--
 arch/arm/mach-davinci/dm646x.c        |    3 +--
 6 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/arch/arm/mach-davinci/da830.c b/arch/arm/mach-davinci/da830.c
index 111613b..d6c746e 100644
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
index 5ef37f9..f56e5fb 100644
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
index 280f67d..a408b30 100644
--- a/arch/arm/mach-davinci/devices-da8xx.c
+++ b/arch/arm/mach-davinci/devices-da8xx.c
@@ -481,12 +481,8 @@ int __init da8xx_register_emac(void)
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
diff --git a/arch/arm/mach-davinci/dm365.c b/arch/arm/mach-davinci/dm365.c
index 3a039bc..278080d 100644
--- a/arch/arm/mach-davinci/dm365.c
+++ b/arch/arm/mach-davinci/dm365.c
@@ -477,6 +477,7 @@ static struct clk_lookup dm365_clks[] = {
 	CLK(NULL, "timer3", &timer3_clk),
 	CLK(NULL, "usb", &usb_clk),
 	CLK("davinci_emac.1", NULL, &emac_clk),
+	CLK("davinci_mdio.0", "fck", &emac_clk),
 	CLK("davinci_voicecodec", NULL, &voicecodec_clk),
 	CLK("davinci-mcbsp", NULL, &asp0_clk),
 	CLK(NULL, "rto", &rto_clk),
@@ -1422,8 +1423,6 @@ static int __init dm365_init_devices(void)
 
 	platform_device_register(&dm365_mdio_device);
 	platform_device_register(&dm365_emac_device);
-	clk_add_alias(NULL, dev_name(&dm365_mdio_device.dev),
-		      NULL, &dm365_emac_device.dev);
 
 	return 0;
 }
diff --git a/arch/arm/mach-davinci/dm644x.c b/arch/arm/mach-davinci/dm644x.c
index 23de0de..4f74682 100644
--- a/arch/arm/mach-davinci/dm644x.c
+++ b/arch/arm/mach-davinci/dm644x.c
@@ -307,6 +307,7 @@ static struct clk_lookup dm644x_clks[] = {
 	CLK("serial8250.1", NULL, &uart1_clk),
 	CLK("serial8250.2", NULL, &uart2_clk),
 	CLK("davinci_emac.1", NULL, &emac_clk),
+	CLK("davinci_mdio.0", "fck", &emac_clk),
 	CLK("i2c_davinci.1", NULL, &i2c_clk),
 	CLK("palm_bk3710", NULL, &ide_clk),
 	CLK("davinci-mcbsp", NULL, &asp_clk),
@@ -950,8 +951,6 @@ static int __init dm644x_init_devices(void)
 
 	platform_device_register(&dm644x_mdio_device);
 	platform_device_register(&dm644x_emac_device);
-	clk_add_alias(NULL, dev_name(&dm644x_mdio_device.dev),
-		      NULL, &dm644x_emac_device.dev);
 
 	return 0;
 }
diff --git a/arch/arm/mach-davinci/dm646x.c b/arch/arm/mach-davinci/dm646x.c
index 4b25804..68f8d1f 100644
--- a/arch/arm/mach-davinci/dm646x.c
+++ b/arch/arm/mach-davinci/dm646x.c
@@ -351,6 +351,7 @@ static struct clk_lookup dm646x_clks[] = {
 	CLK("davinci-mcasp.1", NULL, &mcasp1_clk),
 	CLK(NULL, "aemif", &aemif_clk),
 	CLK("davinci_emac.1", NULL, &emac_clk),
+	CLK("davinci_mdio.0", "fck", &emac_clk),
 	CLK(NULL, "pwm0", &pwm0_clk),
 	CLK(NULL, "pwm1", &pwm1_clk),
 	CLK(NULL, "timer0", &timer0_clk),
@@ -940,8 +941,6 @@ static int __init dm646x_init_devices(void)
 
 	platform_device_register(&dm646x_mdio_device);
 	platform_device_register(&dm646x_emac_device);
-	clk_add_alias(NULL, dev_name(&dm646x_mdio_device.dev),
-		      NULL, &dm646x_emac_device.dev);
 
 	return 0;
 }
-- 
1.7.9.5
