From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH v3 6/8] i2c-pnx.c: Use resources in platforms
Date: Wed,  4 Apr 2012 10:34:38 +0200
Message-ID: <1333528480-17134-7-git-send-email-stigge@antcom.de>
References: <1333528480-17134-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>
To: arm@kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-i2c@vger.kernel.org, linux-kernel@vger.kernel.org,
 w.sang@pengutronix.de, srinivas.bakki@nxp.com, kevin.wells@nxp.com,
 gregkh@linuxfoundation.org, netdev@vger.kernel.org,
 rtc-linux@googlegroups.com, a.zummo@towertech.it,
 linux-watchdog@vger.kernel.org, wim@iguana.be, jonsmirl@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1333528480-17134-1-git-send-email-stigge@antcom.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

As a precondition for device tree conversion, the platforms using i2c-pnx.c are
converted to using mem and irq resources instead of platform data.

Signed-off-by: Roland Stigge <stigge@antcom.de>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>

---

 Applies to v3.4-rc1

 arch/arm/mach-lpc32xx/common.c |   75 +++++++++++++++++++++++++----------------
 arch/arm/mach-pnx4008/i2c.c    |   64 +++++++++++++++++++++-------------
 drivers/i2c/busses/i2c-pnx.c   |   47 +++++++++++++------------
 include/linux/i2c-pnx.h        |    9 +---
 4 files changed, 112 insertions(+), 83 deletions(-)

--- linux-2.6.orig/arch/arm/mach-lpc32xx/common.c
+++ linux-2.6/arch/arm/mach-lpc32xx/common.c
@@ -27,7 +27,6 @@
 
 #include <asm/mach/map.h>
 
-#include <mach/i2c.h>
 #include <mach/hardware.h>
 #include <mach/platform.h>
 #include "common.h"
@@ -53,46 +52,64 @@ struct platform_device lpc32xx_watchdog_
 /*
  * I2C busses
  */
-static struct i2c_pnx_data i2c0_data = {
-	.name = I2C_CHIP_NAME "1",
-	.base = LPC32XX_I2C1_BASE,
-	.irq = IRQ_LPC32XX_I2C_1,
-};
-
-static struct i2c_pnx_data i2c1_data = {
-	.name = I2C_CHIP_NAME "2",
-	.base = LPC32XX_I2C2_BASE,
-	.irq = IRQ_LPC32XX_I2C_2,
-};
-
-static struct i2c_pnx_data i2c2_data = {
-	.name = "USB-I2C",
-	.base = LPC32XX_OTG_I2C_BASE,
-	.irq = IRQ_LPC32XX_USB_I2C,
+static struct resource i2c0_resources[] = {
+	[0] = {
+		.start = LPC32XX_I2C1_BASE,
+		.end = LPC32XX_I2C1_BASE + 0x100 - 1,
+		.flags = IORESOURCE_MEM,
+	},
+	[1] = {
+		.start = IRQ_LPC32XX_I2C_1,
+		.end = IRQ_LPC32XX_I2C_1,
+		.flags = IORESOURCE_IRQ,
+	},
+};
+
+static struct resource i2c1_resources[] = {
+	[0] = {
+		.start = LPC32XX_I2C2_BASE,
+		.end = LPC32XX_I2C2_BASE + 0x100 - 1,
+		.flags = IORESOURCE_MEM,
+	},
+	[1] = {
+		.start = IRQ_LPC32XX_I2C_2,
+		.end = IRQ_LPC32XX_I2C_2,
+		.flags = IORESOURCE_IRQ,
+	},
+};
+
+static struct resource i2c2_resources[] = {
+	[0] = {
+		.start = LPC32XX_OTG_I2C_BASE,
+		.end = LPC32XX_OTG_I2C_BASE + 0x100 - 1,
+		.flags = IORESOURCE_MEM,
+	},
+	[1] = {
+		.start = IRQ_LPC32XX_USB_I2C,
+		.end = IRQ_LPC32XX_USB_I2C,
+		.flags = IORESOURCE_IRQ,
+	},
 };
 
 struct platform_device lpc32xx_i2c0_device = {
-	.name = "pnx-i2c",
+	.name = "pnx-i2c.0",
 	.id = 0,
-	.dev = {
-		.platform_data = &i2c0_data,
-	},
+	.num_resources = ARRAY_SIZE(i2c0_resources),
+	.resource = i2c0_resources,
 };
 
 struct platform_device lpc32xx_i2c1_device = {
-	.name = "pnx-i2c",
+	.name = "pnx-i2c.1",
 	.id = 1,
-	.dev = {
-		.platform_data = &i2c1_data,
-	},
+	.num_resources = ARRAY_SIZE(i2c1_resources),
+	.resource = i2c1_resources,
 };
 
 struct platform_device lpc32xx_i2c2_device = {
-	.name = "pnx-i2c",
+	.name = "pnx-i2c.2",
 	.id = 2,
-	.dev = {
-		.platform_data = &i2c2_data,
-	},
+	.num_resources = ARRAY_SIZE(i2c2_resources),
+	.resource = i2c2_resources,
 };
 
 /* TSC (Touch Screen Controller) */
--- linux-2.6.orig/arch/arm/mach-pnx4008/i2c.c
+++ linux-2.6/arch/arm/mach-pnx4008/i2c.c
@@ -16,48 +16,62 @@
 #include <linux/err.h>
 #include <mach/platform.h>
 #include <mach/irqs.h>
-#include <mach/i2c.h>
 
-static struct i2c_pnx_data i2c0_data = {
-	.name = I2C_CHIP_NAME "0",
-	.base = PNX4008_I2C1_BASE,
-	.irq = I2C_1_INT,
+static struct resource i2c0_resources[] = {
+	{
+		.start = PNX4008_I2C1_BASE,
+		.end = PNX4008_I2C1_BASE + SZ_4K - 1,
+		.flags = IORESOURCE_MEM,
+	}, {
+		.start = I2C_1_INT,
+		.end = I2C_1_INT,
+		.flags = IORESOURCE_IRQ,
+	},
 };
 
-static struct i2c_pnx_data i2c1_data = {
-	.name = I2C_CHIP_NAME "1",
-	.base = PNX4008_I2C2_BASE,
-	.irq = I2C_2_INT,
+static struct resource i2c1_resources[] = {
+	{
+		.start = PNX4008_I2C2_BASE,
+		.end = PNX4008_I2C2_BASE + SZ_4K - 1,
+		.flags = IORESOURCE_MEM,
+	}, {
+		.start = I2C_2_INT,
+		.end = I2C_2_INT,
+		.flags = IORESOURCE_IRQ,
+	},
 };
 
-static struct i2c_pnx_data i2c2_data = {
-	.name = "USB-I2C",
-	.base = (PNX4008_USB_CONFIG_BASE + 0x300),
-	.irq = USB_I2C_INT,
+static struct resource i2c2_resources[] = {
+	{
+		.start = PNX4008_USB_CONFIG_BASE + 0x300,
+		.end = PNX4008_USB_CONFIG_BASE + 0x300 + SZ_4K - 1,
+		.flags = IORESOURCE_MEM,
+	}, {
+		.start = USB_I2C_INT,
+		.end = USB_I2C_INT,
+		.flags = IORESOURCE_IRQ,
+	},
 };
 
 static struct platform_device i2c0_device = {
-	.name = "pnx-i2c",
+	.name = "pnx-i2c.0",
 	.id = 0,
-	.dev = {
-		.platform_data = &i2c0_data,
-	},
+	.resource = i2c0_resources,
+	.num_resources = ARRAY_SIZE(i2c0_resources),
 };
 
 static struct platform_device i2c1_device = {
-	.name = "pnx-i2c",
+	.name = "pnx-i2c.1",
 	.id = 1,
-	.dev = {
-		.platform_data = &i2c1_data,
-	},
+	.resource = i2c1_resources,
+	.num_resources = ARRAY_SIZE(i2c1_resources),
 };
 
 static struct platform_device i2c2_device = {
-	.name = "pnx-i2c",
+	.name = "pnx-i2c.2",
 	.id = 2,
-	.dev = {
-		.platform_data = &i2c2_data,
-	},
+	.resource = i2c2_resources,
+	.num_resources = ARRAY_SIZE(i2c2_resources),
 };
 
 static struct platform_device *devices[] __initdata = {
--- linux-2.6.orig/drivers/i2c/busses/i2c-pnx.c
+++ linux-2.6/drivers/i2c/busses/i2c-pnx.c
@@ -568,14 +568,7 @@ static int __devinit i2c_pnx_probe(struc
 	int ret = 0;
 	struct i2c_pnx_algo_data *alg_data;
 	unsigned long freq;
-	struct i2c_pnx_data *i2c_pnx = pdev->dev.platform_data;
-
-	if (!i2c_pnx || !i2c_pnx->name) {
-		dev_err(&pdev->dev, "%s: no platform data supplied\n",
-		       __func__);
-		ret = -EINVAL;
-		goto out;
-	}
+	struct resource *res;
 
 	alg_data = kzalloc(sizeof(*alg_data), GFP_KERNEL);
 	if (!alg_data) {
@@ -585,13 +578,10 @@ static int __devinit i2c_pnx_probe(struc
 
 	platform_set_drvdata(pdev, alg_data);
 
-	strlcpy(alg_data->adapter.name, i2c_pnx->name,
-		sizeof(alg_data->adapter.name));
 	alg_data->adapter.dev.parent = &pdev->dev;
 	alg_data->adapter.algo = &pnx_algorithm;
 	alg_data->adapter.algo_data = alg_data;
 	alg_data->adapter.nr = pdev->id;
-	alg_data->i2c_pnx = i2c_pnx;
 
 	alg_data->clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(alg_data->clk)) {
@@ -603,17 +593,27 @@ static int __devinit i2c_pnx_probe(struc
 	alg_data->mif.timer.function = i2c_pnx_timeout;
 	alg_data->mif.timer.data = (unsigned long)alg_data;
 
+	snprintf(alg_data->adapter.name, sizeof(alg_data->adapter.name),
+		 "%s", pdev->name);
+
 	/* Register I/O resource */
-	if (!request_mem_region(i2c_pnx->base, I2C_PNX_REGION_SIZE,
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "Unable to get mem resource.\n");
+		ret = -EBUSY;
+		goto out_clkget;
+	}
+	if (!request_mem_region(res->start, I2C_PNX_REGION_SIZE,
 				pdev->name)) {
 		dev_err(&pdev->dev,
 		       "I/O region 0x%08x for I2C already in use.\n",
-		       i2c_pnx->base);
+		       res->start);
 		ret = -ENODEV;
 		goto out_clkget;
 	}
 
-	alg_data->ioaddr = ioremap(i2c_pnx->base, I2C_PNX_REGION_SIZE);
+	alg_data->base = res->start;
+	alg_data->ioaddr = ioremap(res->start, I2C_PNX_REGION_SIZE);
 	if (!alg_data->ioaddr) {
 		dev_err(&pdev->dev, "Couldn't ioremap I2C I/O region\n");
 		ret = -ENOMEM;
@@ -650,7 +650,12 @@ static int __devinit i2c_pnx_probe(struc
 	}
 	init_completion(&alg_data->mif.complete);
 
-	ret = request_irq(i2c_pnx->irq, i2c_pnx_interrupt,
+	alg_data->irq = platform_get_irq(pdev, 0);
+	if (alg_data->irq < 0) {
+		dev_err(&pdev->dev, "Failed to get IRQ from platform resource\n");
+		goto out_irq;
+	}
+	ret = request_irq(alg_data->irq, i2c_pnx_interrupt,
 			0, pdev->name, alg_data);
 	if (ret)
 		goto out_clock;
@@ -663,38 +668,36 @@ static int __devinit i2c_pnx_probe(struc
 	}
 
 	dev_dbg(&pdev->dev, "%s: Master at %#8x, irq %d.\n",
-	       alg_data->adapter.name, i2c_pnx->base, i2c_pnx->irq);
+		alg_data->adapter.name, res->start, alg_data->irq);
 
 	return 0;
 
 out_irq:
-	free_irq(i2c_pnx->irq, alg_data);
+	free_irq(alg_data->irq, alg_data);
 out_clock:
 	clk_disable(alg_data->clk);
 out_unmap:
 	iounmap(alg_data->ioaddr);
 out_release:
-	release_mem_region(i2c_pnx->base, I2C_PNX_REGION_SIZE);
+	release_mem_region(res->start, I2C_PNX_REGION_SIZE);
 out_clkget:
 	clk_put(alg_data->clk);
 out_drvdata:
 	kfree(alg_data);
 err_kzalloc:
 	platform_set_drvdata(pdev, NULL);
-out:
 	return ret;
 }
 
 static int __devexit i2c_pnx_remove(struct platform_device *pdev)
 {
 	struct i2c_pnx_algo_data *alg_data = platform_get_drvdata(pdev);
-	struct i2c_pnx_data *i2c_pnx = alg_data->i2c_pnx;
 
-	free_irq(i2c_pnx->irq, alg_data);
+	free_irq(alg_data->irq, alg_data);
 	i2c_del_adapter(&alg_data->adapter);
 	clk_disable(alg_data->clk);
 	iounmap(alg_data->ioaddr);
-	release_mem_region(i2c_pnx->base, I2C_PNX_REGION_SIZE);
+	release_mem_region(alg_data->base, I2C_PNX_REGION_SIZE);
 	clk_put(alg_data->clk);
 	kfree(alg_data);
 	platform_set_drvdata(pdev, NULL);
--- linux-2.6.orig/include/linux/i2c-pnx.h
+++ linux-2.6/include/linux/i2c-pnx.h
@@ -29,14 +29,9 @@ struct i2c_pnx_algo_data {
 	struct i2c_pnx_mif	mif;
 	int			last;
 	struct clk		*clk;
-	struct i2c_pnx_data	*i2c_pnx;
 	struct i2c_adapter	adapter;
-};
-
-struct i2c_pnx_data {
-	const char *name;
-	u32 base;
-	int irq;
+	phys_addr_t		base;
+	int			irq;
 };
 
 #endif /* __I2C_PNX_H__ */
