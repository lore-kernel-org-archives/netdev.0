From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: [v16, 3/7] soc: fsl: add GUTS driver for QorIQ platforms
Date: Wed, 9 Nov 2016 11:14:08 +0800
Message-ID: <1478661252-42439-4-git-send-email-yangbo.lu@nxp.com>
References: <1478661252-42439-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	Minghuan Lian <minghuan.lian-3arQi8VN3Tc@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Scott Wood
	<oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1478661252-42439-1-git-send-email-yangbo.lu-3arQi8VN3Tc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

The global utilities block controls power management, I/O device
enabling, power-onreset(POR) configuration monitoring, alternate
function selection for multiplexed signals,and clock control.

This patch adds a driver to manage and access global utilities block.
Initially only reading SVR and registering soc device are supported.
Other guts accesses, such as reading RCW, should eventually be moved
into this driver as well.

Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
Changes for v4:
	- Added this patch
Changes for v5:
	- Modified copyright info
	- Changed MODULE_LICENSE to GPL
	- Changed EXPORT_SYMBOL_GPL to EXPORT_SYMBOL
	- Made FSL_GUTS user-invisible
	- Added a complete compatible list for GUTS
	- Stored guts info in file-scope variable
	- Added mfspr() getting SVR
	- Redefined GUTS APIs
	- Called fsl_guts_init rather than using platform driver
	- Removed useless parentheses
	- Removed useless 'extern' key words
Changes for v6:
	- Made guts thread safe in fsl_guts_init
Changes for v7:
	- Removed 'ifdef' for function declaration in guts.h
Changes for v8:
	- Fixes lines longer than 80 characters checkpatch issue
	- Added 'Acked-by: Scott Wood'
Changes for v9:
	- None
Changes for v10:
	- None
Changes for v11:
	- Changed to platform driver
Changes for v12:
	- Removed "signed-off-by: Scott"
	- Defined fsl_soc_die_attr struct array instead of
	  soc_device_attribute
	- Re-designed soc_device_attribute for QorIQ SoC
	- Other minor fixes
Changes for v13:
	- Rebased
	- Removed text after 'bool' in Kconfig
	- Removed ARCH ifdefs
	- Added more bits for ls1021a mask
	- Used devm
Changes for v14:
	- Used devm_ioremap_resource
Changes for v15:
	- Fixed error code for devm_ioremap_resource
Changes for v16:
	- Removed header file svr.h and calculated REV_MAJ/MIN in this driver
	- Added 'Acked-by: Arnd'
---
 drivers/soc/Kconfig      |   3 +-
 drivers/soc/fsl/Kconfig  |  18 ++++
 drivers/soc/fsl/Makefile |   1 +
 drivers/soc/fsl/guts.c   | 236 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fsl/guts.h | 125 +++++++++++++++----------
 5 files changed, 333 insertions(+), 50 deletions(-)
 create mode 100644 drivers/soc/fsl/Kconfig
 create mode 100644 drivers/soc/fsl/guts.c

diff --git a/drivers/soc/Kconfig b/drivers/soc/Kconfig
index e6e90e8..f31bceb 100644
--- a/drivers/soc/Kconfig
+++ b/drivers/soc/Kconfig
@@ -1,8 +1,7 @@
 menu "SOC (System On Chip) specific Drivers"
 
 source "drivers/soc/bcm/Kconfig"
-source "drivers/soc/fsl/qbman/Kconfig"
-source "drivers/soc/fsl/qe/Kconfig"
+source "drivers/soc/fsl/Kconfig"
 source "drivers/soc/mediatek/Kconfig"
 source "drivers/soc/qcom/Kconfig"
 source "drivers/soc/rockchip/Kconfig"
diff --git a/drivers/soc/fsl/Kconfig b/drivers/soc/fsl/Kconfig
new file mode 100644
index 0000000..7a9fb9b
--- /dev/null
+++ b/drivers/soc/fsl/Kconfig
@@ -0,0 +1,18 @@
+#
+# Freescale SOC drivers
+#
+
+source "drivers/soc/fsl/qbman/Kconfig"
+source "drivers/soc/fsl/qe/Kconfig"
+
+config FSL_GUTS
+	bool
+	select SOC_BUS
+	help
+	  The global utilities block controls power management, I/O device
+	  enabling, power-onreset(POR) configuration monitoring, alternate
+	  function selection for multiplexed signals,and clock control.
+	  This driver is to manage and access global utilities block.
+	  Initially only reading SVR and registering soc device are supported.
+	  Other guts accesses, such as reading RCW, should eventually be moved
+	  into this driver as well.
diff --git a/drivers/soc/fsl/Makefile b/drivers/soc/fsl/Makefile
index 75e1f53..44b3beb 100644
--- a/drivers/soc/fsl/Makefile
+++ b/drivers/soc/fsl/Makefile
@@ -5,3 +5,4 @@
 obj-$(CONFIG_FSL_DPAA)                 += qbman/
 obj-$(CONFIG_QUICC_ENGINE)		+= qe/
 obj-$(CONFIG_CPM)			+= qe/
+obj-$(CONFIG_FSL_GUTS)			+= guts.o
diff --git a/drivers/soc/fsl/guts.c b/drivers/soc/fsl/guts.c
new file mode 100644
index 0000000..0ac8826
--- /dev/null
+++ b/drivers/soc/fsl/guts.c
@@ -0,0 +1,236 @@
+/*
+ * Freescale QorIQ Platforms GUTS Driver
+ *
+ * Copyright (C) 2016 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/io.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/of_fdt.h>
+#include <linux/sys_soc.h>
+#include <linux/of_address.h>
+#include <linux/platform_device.h>
+#include <linux/fsl/guts.h>
+
+struct guts {
+	struct ccsr_guts __iomem *regs;
+	bool little_endian;
+};
+
+struct fsl_soc_die_attr {
+	char	*die;
+	u32	svr;
+	u32	mask;
+};
+
+static struct guts *guts;
+static struct soc_device_attribute soc_dev_attr;
+static struct soc_device *soc_dev;
+
+
+/* SoC die attribute definition for QorIQ platform */
+static const struct fsl_soc_die_attr fsl_soc_die[] = {
+	/*
+	 * Power Architecture-based SoCs T Series
+	 */
+
+	/* Die: T4240, SoC: T4240/T4160/T4080 */
+	{ .die		= "T4240",
+	  .svr		= 0x82400000,
+	  .mask		= 0xfff00000,
+	},
+	/* Die: T1040, SoC: T1040/T1020/T1042/T1022 */
+	{ .die		= "T1040",
+	  .svr		= 0x85200000,
+	  .mask		= 0xfff00000,
+	},
+	/* Die: T2080, SoC: T2080/T2081 */
+	{ .die		= "T2080",
+	  .svr		= 0x85300000,
+	  .mask		= 0xfff00000,
+	},
+	/* Die: T1024, SoC: T1024/T1014/T1023/T1013 */
+	{ .die		= "T1024",
+	  .svr		= 0x85400000,
+	  .mask		= 0xfff00000,
+	},
+
+	/*
+	 * ARM-based SoCs LS Series
+	 */
+
+	/* Die: LS1043A, SoC: LS1043A/LS1023A */
+	{ .die		= "LS1043A",
+	  .svr		= 0x87920000,
+	  .mask		= 0xffff0000,
+	},
+	/* Die: LS2080A, SoC: LS2080A/LS2040A/LS2085A */
+	{ .die		= "LS2080A",
+	  .svr		= 0x87010000,
+	  .mask		= 0xff3f0000,
+	},
+	/* Die: LS1088A, SoC: LS1088A/LS1048A/LS1084A/LS1044A */
+	{ .die		= "LS1088A",
+	  .svr		= 0x87030000,
+	  .mask		= 0xff3f0000,
+	},
+	/* Die: LS1012A, SoC: LS1012A */
+	{ .die		= "LS1012A",
+	  .svr		= 0x87040000,
+	  .mask		= 0xffff0000,
+	},
+	/* Die: LS1046A, SoC: LS1046A/LS1026A */
+	{ .die		= "LS1046A",
+	  .svr		= 0x87070000,
+	  .mask		= 0xffff0000,
+	},
+	/* Die: LS2088A, SoC: LS2088A/LS2048A/LS2084A/LS2044A */
+	{ .die		= "LS2088A",
+	  .svr		= 0x87090000,
+	  .mask		= 0xff3f0000,
+	},
+	/* Die: LS1021A, SoC: LS1021A/LS1020A/LS1022A */
+	{ .die		= "LS1021A",
+	  .svr		= 0x87000000,
+	  .mask		= 0xfff70000,
+	},
+	{ },
+};
+
+static const struct fsl_soc_die_attr *fsl_soc_die_match(
+	u32 svr, const struct fsl_soc_die_attr *matches)
+{
+	while (matches->svr) {
+		if (matches->svr == (svr & matches->mask))
+			return matches;
+		matches++;
+	};
+	return NULL;
+}
+
+u32 fsl_guts_get_svr(void)
+{
+	u32 svr = 0;
+
+	if (!guts || !guts->regs)
+		return svr;
+
+	if (guts->little_endian)
+		svr = ioread32(&guts->regs->svr);
+	else
+		svr = ioread32be(&guts->regs->svr);
+
+	return svr;
+}
+EXPORT_SYMBOL(fsl_guts_get_svr);
+
+static int fsl_guts_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct device *dev = &pdev->dev;
+	struct resource *res;
+	const struct fsl_soc_die_attr *soc_die;
+	const char *machine;
+	u32 svr;
+
+	/* Initialize guts */
+	guts = devm_kzalloc(dev, sizeof(*guts), GFP_KERNEL);
+	if (!guts)
+		return -ENOMEM;
+
+	guts->little_endian = of_property_read_bool(np, "little-endian");
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	guts->regs = devm_ioremap_resource(dev, res);
+	if (IS_ERR(guts->regs))
+		return PTR_ERR(guts->regs);
+
+	/* Register soc device */
+	machine = of_flat_dt_get_machine_name();
+	if (machine)
+		soc_dev_attr.machine = devm_kstrdup(dev, machine, GFP_KERNEL);
+
+	svr = fsl_guts_get_svr();
+	soc_die = fsl_soc_die_match(svr, fsl_soc_die);
+	if (soc_die) {
+		soc_dev_attr.family = devm_kasprintf(dev, GFP_KERNEL,
+						     "QorIQ %s", soc_die->die);
+	} else {
+		soc_dev_attr.family = devm_kasprintf(dev, GFP_KERNEL, "QorIQ");
+	}
+	soc_dev_attr.soc_id = devm_kasprintf(dev, GFP_KERNEL,
+					     "svr:0x%08x", svr);
+	soc_dev_attr.revision = devm_kasprintf(dev, GFP_KERNEL, "%d.%d",
+					       (svr >>  4) & 0xf, svr & 0xf);
+
+	soc_dev = soc_device_register(&soc_dev_attr);
+	if (IS_ERR(soc_dev))
+		return PTR_ERR(soc_dev);
+
+	pr_info("Machine: %s\n", soc_dev_attr.machine);
+	pr_info("SoC family: %s\n", soc_dev_attr.family);
+	pr_info("SoC ID: %s, Revision: %s\n",
+		soc_dev_attr.soc_id, soc_dev_attr.revision);
+	return 0;
+}
+
+static int fsl_guts_remove(struct platform_device *dev)
+{
+	soc_device_unregister(soc_dev);
+	return 0;
+}
+
+/*
+ * Table for matching compatible strings, for device tree
+ * guts node, for Freescale QorIQ SOCs.
+ */
+static const struct of_device_id fsl_guts_of_match[] = {
+	{ .compatible = "fsl,qoriq-device-config-1.0", },
+	{ .compatible = "fsl,qoriq-device-config-2.0", },
+	{ .compatible = "fsl,p1010-guts", },
+	{ .compatible = "fsl,p1020-guts", },
+	{ .compatible = "fsl,p1021-guts", },
+	{ .compatible = "fsl,p1022-guts", },
+	{ .compatible = "fsl,p1023-guts", },
+	{ .compatible = "fsl,p2020-guts", },
+	{ .compatible = "fsl,bsc9131-guts", },
+	{ .compatible = "fsl,bsc9132-guts", },
+	{ .compatible = "fsl,mpc8536-guts", },
+	{ .compatible = "fsl,mpc8544-guts", },
+	{ .compatible = "fsl,mpc8548-guts", },
+	{ .compatible = "fsl,mpc8568-guts", },
+	{ .compatible = "fsl,mpc8569-guts", },
+	{ .compatible = "fsl,mpc8572-guts", },
+	{ .compatible = "fsl,ls1021a-dcfg", },
+	{ .compatible = "fsl,ls1043a-dcfg", },
+	{ .compatible = "fsl,ls2080a-dcfg", },
+	{}
+};
+MODULE_DEVICE_TABLE(of, fsl_guts_of_match);
+
+static struct platform_driver fsl_guts_driver = {
+	.driver = {
+		.name = "fsl-guts",
+		.of_match_table = fsl_guts_of_match,
+	},
+	.probe = fsl_guts_probe,
+	.remove = fsl_guts_remove,
+};
+
+static int __init fsl_guts_init(void)
+{
+	return platform_driver_register(&fsl_guts_driver);
+}
+core_initcall(fsl_guts_init);
+
+static void __exit fsl_guts_exit(void)
+{
+	platform_driver_unregister(&fsl_guts_driver);
+}
+module_exit(fsl_guts_exit);
diff --git a/include/linux/fsl/guts.h b/include/linux/fsl/guts.h
index 649e917..3efa3b8 100644
--- a/include/linux/fsl/guts.h
+++ b/include/linux/fsl/guts.h
@@ -29,83 +29,112 @@
  * #ifdefs.
  */
 struct ccsr_guts {
-	__be32	porpllsr;	/* 0x.0000 - POR PLL Ratio Status Register */
-	__be32	porbmsr;	/* 0x.0004 - POR Boot Mode Status Register */
-	__be32	porimpscr;	/* 0x.0008 - POR I/O Impedance Status and Control Register */
-	__be32	pordevsr;	/* 0x.000c - POR I/O Device Status Register */
-	__be32	pordbgmsr;	/* 0x.0010 - POR Debug Mode Status Register */
-	__be32	pordevsr2;	/* 0x.0014 - POR device status register 2 */
+	u32	porpllsr;	/* 0x.0000 - POR PLL Ratio Status Register */
+	u32	porbmsr;	/* 0x.0004 - POR Boot Mode Status Register */
+	u32	porimpscr;	/* 0x.0008 - POR I/O Impedance Status and
+				 *           Control Register
+				 */
+	u32	pordevsr;	/* 0x.000c - POR I/O Device Status Register */
+	u32	pordbgmsr;	/* 0x.0010 - POR Debug Mode Status Register */
+	u32	pordevsr2;	/* 0x.0014 - POR device status register 2 */
 	u8	res018[0x20 - 0x18];
-	__be32	porcir;		/* 0x.0020 - POR Configuration Information Register */
+	u32	porcir;		/* 0x.0020 - POR Configuration Information
+				 *           Register
+				 */
 	u8	res024[0x30 - 0x24];
-	__be32	gpiocr;		/* 0x.0030 - GPIO Control Register */
+	u32	gpiocr;		/* 0x.0030 - GPIO Control Register */
 	u8	res034[0x40 - 0x34];
-	__be32	gpoutdr;	/* 0x.0040 - General-Purpose Output Data Register */
+	u32	gpoutdr;	/* 0x.0040 - General-Purpose Output Data
+				 *           Register
+				 */
 	u8	res044[0x50 - 0x44];
-	__be32	gpindr;		/* 0x.0050 - General-Purpose Input Data Register */
+	u32	gpindr;		/* 0x.0050 - General-Purpose Input Data
+				 *           Register
+				 */
 	u8	res054[0x60 - 0x54];
-	__be32	pmuxcr;		/* 0x.0060 - Alternate Function Signal Multiplex Control */
-        __be32  pmuxcr2;	/* 0x.0064 - Alternate function signal multiplex control 2 */
-        __be32  dmuxcr;		/* 0x.0068 - DMA Mux Control Register */
+	u32	pmuxcr;		/* 0x.0060 - Alternate Function Signal
+				 *           Multiplex Control
+				 */
+	u32	pmuxcr2;	/* 0x.0064 - Alternate function signal
+				 *           multiplex control 2
+				 */
+	u32	dmuxcr;		/* 0x.0068 - DMA Mux Control Register */
         u8	res06c[0x70 - 0x6c];
-	__be32	devdisr;	/* 0x.0070 - Device Disable Control */
+	u32	devdisr;	/* 0x.0070 - Device Disable Control */
 #define CCSR_GUTS_DEVDISR_TB1	0x00001000
 #define CCSR_GUTS_DEVDISR_TB0	0x00004000
-	__be32	devdisr2;	/* 0x.0074 - Device Disable Control 2 */
+	u32	devdisr2;	/* 0x.0074 - Device Disable Control 2 */
 	u8	res078[0x7c - 0x78];
-	__be32  pmjcr;		/* 0x.007c - 4 Power Management Jog Control Register */
-	__be32	powmgtcsr;	/* 0x.0080 - Power Management Status and Control Register */
-	__be32  pmrccr;		/* 0x.0084 - Power Management Reset Counter Configuration Register */
-	__be32  pmpdccr;	/* 0x.0088 - Power Management Power Down Counter Configuration Register */
-	__be32  pmcdr;		/* 0x.008c - 4Power management clock disable register */
-	__be32	mcpsumr;	/* 0x.0090 - Machine Check Summary Register */
-	__be32	rstrscr;	/* 0x.0094 - Reset Request Status and Control Register */
-	__be32  ectrstcr;	/* 0x.0098 - Exception reset control register */
-	__be32  autorstsr;	/* 0x.009c - Automatic reset status register */
-	__be32	pvr;		/* 0x.00a0 - Processor Version Register */
-	__be32	svr;		/* 0x.00a4 - System Version Register */
+	u32	pmjcr;		/* 0x.007c - 4 Power Management Jog Control
+				 *           Register
+				 */
+	u32	powmgtcsr;	/* 0x.0080 - Power Management Status and
+				 *           Control Register
+				 */
+	u32	pmrccr;		/* 0x.0084 - Power Management Reset Counter
+				 *           Configuration Register
+				 */
+	u32	pmpdccr;	/* 0x.0088 - Power Management Power Down Counter
+				 *           Configuration Register
+				 */
+	u32	pmcdr;		/* 0x.008c - 4Power management clock disable
+				 *           register
+				 */
+	u32	mcpsumr;	/* 0x.0090 - Machine Check Summary Register */
+	u32	rstrscr;	/* 0x.0094 - Reset Request Status and
+				 *           Control Register
+				 */
+	u32	ectrstcr;	/* 0x.0098 - Exception reset control register */
+	u32	autorstsr;	/* 0x.009c - Automatic reset status register */
+	u32	pvr;		/* 0x.00a0 - Processor Version Register */
+	u32	svr;		/* 0x.00a4 - System Version Register */
 	u8	res0a8[0xb0 - 0xa8];
-	__be32	rstcr;		/* 0x.00b0 - Reset Control Register */
+	u32	rstcr;		/* 0x.00b0 - Reset Control Register */
 	u8	res0b4[0xc0 - 0xb4];
-	__be32  iovselsr;	/* 0x.00c0 - I/O voltage select status register
+	u32	iovselsr;	/* 0x.00c0 - I/O voltage select status register
 					     Called 'elbcvselcr' on 86xx SOCs */
 	u8	res0c4[0x100 - 0xc4];
-	__be32	rcwsr[16];	/* 0x.0100 - Reset Control Word Status registers
+	u32	rcwsr[16];	/* 0x.0100 - Reset Control Word Status registers
 					     There are 16 registers */
 	u8	res140[0x224 - 0x140];
-	__be32  iodelay1;	/* 0x.0224 - IO delay control register 1 */
-	__be32  iodelay2;	/* 0x.0228 - IO delay control register 2 */
+	u32	iodelay1;	/* 0x.0224 - IO delay control register 1 */
+	u32	iodelay2;	/* 0x.0228 - IO delay control register 2 */
 	u8	res22c[0x604 - 0x22c];
-	__be32	pamubypenr; 	/* 0x.604 - PAMU bypass enable register */
+	u32	pamubypenr;	/* 0x.604 - PAMU bypass enable register */
 	u8	res608[0x800 - 0x608];
-	__be32	clkdvdr;	/* 0x.0800 - Clock Divide Register */
+	u32	clkdvdr;	/* 0x.0800 - Clock Divide Register */
 	u8	res804[0x900 - 0x804];
-	__be32	ircr;		/* 0x.0900 - Infrared Control Register */
+	u32	ircr;		/* 0x.0900 - Infrared Control Register */
 	u8	res904[0x908 - 0x904];
-	__be32	dmacr;		/* 0x.0908 - DMA Control Register */
+	u32	dmacr;		/* 0x.0908 - DMA Control Register */
 	u8	res90c[0x914 - 0x90c];
-	__be32	elbccr;		/* 0x.0914 - eLBC Control Register */
+	u32	elbccr;		/* 0x.0914 - eLBC Control Register */
 	u8	res918[0xb20 - 0x918];
-	__be32	ddr1clkdr;	/* 0x.0b20 - DDR1 Clock Disable Register */
-	__be32	ddr2clkdr;	/* 0x.0b24 - DDR2 Clock Disable Register */
-	__be32	ddrclkdr;	/* 0x.0b28 - DDR Clock Disable Register */
+	u32	ddr1clkdr;	/* 0x.0b20 - DDR1 Clock Disable Register */
+	u32	ddr2clkdr;	/* 0x.0b24 - DDR2 Clock Disable Register */
+	u32	ddrclkdr;	/* 0x.0b28 - DDR Clock Disable Register */
 	u8	resb2c[0xe00 - 0xb2c];
-	__be32	clkocr;		/* 0x.0e00 - Clock Out Select Register */
+	u32	clkocr;		/* 0x.0e00 - Clock Out Select Register */
 	u8	rese04[0xe10 - 0xe04];
-	__be32	ddrdllcr;	/* 0x.0e10 - DDR DLL Control Register */
+	u32	ddrdllcr;	/* 0x.0e10 - DDR DLL Control Register */
 	u8	rese14[0xe20 - 0xe14];
-	__be32	lbcdllcr;	/* 0x.0e20 - LBC DLL Control Register */
-	__be32  cpfor;		/* 0x.0e24 - L2 charge pump fuse override register */
+	u32	lbcdllcr;	/* 0x.0e20 - LBC DLL Control Register */
+	u32	cpfor;		/* 0x.0e24 - L2 charge pump fuse override
+				 *           register
+				 */
 	u8	rese28[0xf04 - 0xe28];
-	__be32	srds1cr0;	/* 0x.0f04 - SerDes1 Control Register 0 */
-	__be32	srds1cr1;	/* 0x.0f08 - SerDes1 Control Register 0 */
+	u32	srds1cr0;	/* 0x.0f04 - SerDes1 Control Register 0 */
+	u32	srds1cr1;	/* 0x.0f08 - SerDes1 Control Register 0 */
 	u8	resf0c[0xf2c - 0xf0c];
-	__be32  itcr;		/* 0x.0f2c - Internal transaction control register */
+	u32	itcr;		/* 0x.0f2c - Internal transaction control
+				 *           register
+				 */
 	u8	resf30[0xf40 - 0xf30];
-	__be32	srds2cr0;	/* 0x.0f40 - SerDes2 Control Register 0 */
-	__be32	srds2cr1;	/* 0x.0f44 - SerDes2 Control Register 0 */
+	u32	srds2cr0;	/* 0x.0f40 - SerDes2 Control Register 0 */
+	u32	srds2cr1;	/* 0x.0f44 - SerDes2 Control Register 0 */
 } __attribute__ ((packed));
 
+u32 fsl_guts_get_svr(void);
 
 /* Alternate function signal multiplex control */
 #define MPC85xx_PMUXCR_QE(x) (0x8000 >> (x))
-- 
2.1.0.27.g96db324
