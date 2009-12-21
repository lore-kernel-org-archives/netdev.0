From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 1/2] mx25: add support for FEC on i.MX25
Date: Mon, 21 Dec 2009 13:44:31 +0200
Message-ID: <97e6c149bb27754075241fc672985c5a2ecef4b6.1261395135.git.baruch@tkos.co.il>
References: <20091221110807.GE15126@pengutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Baruch Siach <baruch@tkos.co.il>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:53363 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753032AbZLULpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2009 06:45:54 -0500
In-Reply-To: <20091221110807.GE15126@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 arch/arm/mach-mx25/clock.c            |    2 ++
 arch/arm/mach-mx25/devices.c          |   19 +++++++++++++++++++
 arch/arm/mach-mx25/devices.h          |    1 +
 arch/arm/plat-mxc/include/mach/mx25.h |    4 ++++
 4 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-mx25/clock.c b/arch/arm/mach-mx25/clock.c
index dbbbcc6..ea8c3da 100644
--- a/arch/arm/mach-mx25/clock.c
+++ b/arch/arm/mach-mx25/clock.c
@@ -173,6 +173,7 @@ DEFINE_CLOCK(pwm4_clk,	 0, CCM_CGCR2,  2, get_rate_ipg, NULL);
 DEFINE_CLOCK(kpp_clk,	 0, CCM_CGCR1, 28, get_rate_ipg, NULL);
 DEFINE_CLOCK(tsc_clk,	 0, CCM_CGCR2, 13, get_rate_ipg, NULL);
 DEFINE_CLOCK(i2c_clk,	 0, CCM_CGCR0,  6, get_rate_i2c, NULL);
+DEFINE_CLOCK(fec_clk,	 0, CCM_CGCR0, 23, get_rate_ipg, NULL);
 
 #define _REGISTER_CLOCK(d, n, c)	\
 	{				\
@@ -204,6 +205,7 @@ static struct clk_lookup lookups[] = {
 	_REGISTER_CLOCK("imx-i2c.0", NULL, i2c_clk)
 	_REGISTER_CLOCK("imx-i2c.1", NULL, i2c_clk)
 	_REGISTER_CLOCK("imx-i2c.2", NULL, i2c_clk)
+	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
 };
 
 int __init mx25_clocks_init(unsigned long fref)
diff --git a/arch/arm/mach-mx25/devices.c b/arch/arm/mach-mx25/devices.c
index 63511de..9fdeea1 100644
--- a/arch/arm/mach-mx25/devices.c
+++ b/arch/arm/mach-mx25/devices.c
@@ -419,3 +419,22 @@ int __init mxc_register_gpios(void)
 	return mxc_gpio_init(imx_gpio_ports, ARRAY_SIZE(imx_gpio_ports));
 }
 
+static struct resource mx25_fec_resources[] = {
+	{
+		.start	= MX25_FEC_BASE_ADDR,
+		.end	= MX25_FEC_BASE_ADDR + 0xfff,
+		.flags	= IORESOURCE_MEM,
+	},
+	{
+		.start	= MX25_INT_FEC,
+		.end	= MX25_INT_FEC,
+		.flags	= IORESOURCE_IRQ,
+	},
+};
+
+struct platform_device mx25_fec_device = {
+	.name	= "fec",
+	.id	= 0,
+	.num_resources	= ARRAY_SIZE(mx25_fec_resources),
+	.resource	= mx25_fec_resources,
+};
diff --git a/arch/arm/mach-mx25/devices.h b/arch/arm/mach-mx25/devices.h
index fe6bf88..fe5420f 100644
--- a/arch/arm/mach-mx25/devices.h
+++ b/arch/arm/mach-mx25/devices.h
@@ -17,3 +17,4 @@ extern struct platform_device mxc_keypad_device;
 extern struct platform_device mxc_i2c_device0;
 extern struct platform_device mxc_i2c_device1;
 extern struct platform_device mxc_i2c_device2;
+extern struct platform_device mx25_fec_device;
diff --git a/arch/arm/plat-mxc/include/mach/mx25.h b/arch/arm/plat-mxc/include/mach/mx25.h
index ec64bd9..106f651 100644
--- a/arch/arm/plat-mxc/include/mach/mx25.h
+++ b/arch/arm/plat-mxc/include/mach/mx25.h
@@ -41,4 +41,8 @@
 #define UART1_BASE_ADDR			0x43f90000
 #define UART2_BASE_ADDR			0x43f94000
 
+#define MX25_FEC_BASE_ADDR		0x50038000
+
+#define MX25_INT_FEC	57
+
 #endif /* __MACH_MX25_H__ */
-- 
1.6.5

