From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH V5 5/7] ARM: OMAP3+: hwmod: Add AM33XX HWMOD data for davinci_mdio module
Date: Thu, 15 Nov 2012 00:37:58 +0530
Message-ID: <1352920080-6179-6-git-send-email-mugunthanvnm@ti.com>
References: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds hwmod entry for davinci MDIO module,
creating parent<->child relationship between CPSW and MDIO module.

This Parent-child relation is required in order to use common resources
like, clock, but still maintaining the logical separation between them.

CPGMAC SubSystem consist of various sub-modules, like, mdio, cpdma,
cpsw, etc... These sub-modules are also used in some of Davinci
family of devices, so separate and independent platform devices &
drivers for CPSW and MDIO is implemented.
In case of AM33XX, the resources are shared and common register
bit-field is provided to control module/clock enable/disable,
makes it difficult to handle common resources from both drivers.

So the solution is, create parent<->child relationship between
CPGMAC & MDIO modules.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: Paul Walmsley <paul@pwsan.com>
Acked-by: Peter Korsgaard <jacmet@sunsite.dk>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 arch/arm/mach-omap2/omap_hwmod_33xx_data.c |   31 ++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-omap2/omap_hwmod_33xx_data.c b/arch/arm/mach-omap2/omap_hwmod_33xx_data.c
index 59d5c1c..3125835 100644
--- a/arch/arm/mach-omap2/omap_hwmod_33xx_data.c
+++ b/arch/arm/mach-omap2/omap_hwmod_33xx_data.c
@@ -674,6 +674,7 @@ static struct omap_hwmod am33xx_cpgmac0_hwmod = {
 	.name		= "cpgmac0",
 	.class		= &am33xx_cpgmac0_hwmod_class,
 	.clkdm_name	= "cpsw_125mhz_clkdm",
+	.flags		= (HWMOD_SWSUP_SIDLE | HWMOD_SWSUP_MSTANDBY),
 	.mpu_irqs	= am33xx_cpgmac0_irqs,
 	.main_clk	= "cpsw_125mhz_gclk",
 	.prcm		= {
@@ -685,6 +686,20 @@ static struct omap_hwmod am33xx_cpgmac0_hwmod = {
 };
 
 /*
+ * mdio class
+ */
+static struct omap_hwmod_class am33xx_mdio_hwmod_class = {
+	.name		= "davinci_mdio",
+};
+
+static struct omap_hwmod am33xx_mdio_hwmod = {
+	.name		= "davinci_mdio",
+	.class		= &am33xx_mdio_hwmod_class,
+	.clkdm_name	= "cpsw_125mhz_clkdm",
+	.main_clk	= "cpsw_125mhz_gclk",
+};
+
+/*
  * dcan class
  */
 static struct omap_hwmod_class am33xx_dcan_hwmod_class = {
@@ -2501,6 +2516,21 @@ static struct omap_hwmod_ocp_if am33xx_l4_hs__cpgmac0 = {
 	.user		= OCP_USER_MPU,
 };
 
+struct omap_hwmod_addr_space am33xx_mdio_addr_space[] = {
+	{
+		.pa_start	= 0x4A101000,
+		.pa_end		= 0x4A101000 + SZ_256 - 1,
+	},
+	{ }
+};
+
+struct omap_hwmod_ocp_if am33xx_cpgmac0__mdio = {
+	.master		= &am33xx_cpgmac0_hwmod,
+	.slave		= &am33xx_mdio_hwmod,
+	.addr		= am33xx_mdio_addr_space,
+	.user		= OCP_USER_MPU,
+};
+
 static struct omap_hwmod_addr_space am33xx_elm_addr_space[] = {
 	{
 		.pa_start	= 0x48080000,
@@ -3371,6 +3401,7 @@ static struct omap_hwmod_ocp_if *am33xx_hwmod_ocp_ifs[] __initdata = {
 	&am33xx_l3_main__tptc2,
 	&am33xx_l3_s__usbss,
 	&am33xx_l4_hs__cpgmac0,
+	&am33xx_cpgmac0__mdio,
 	NULL,
 };
 
-- 
1.7.0.4

