From: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 1/4] mfd: ptxpmb: Add separate driver for extended CPLD
Date: Fri,  7 Oct 2016 18:19:31 +0300
Message-ID: <1475853574-22339-2-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        JawaharBalaji Thirumalaisamy <jawaharb-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475853574-22339-1-git-send-email-pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <groeck-3r7Miqu9kMnR7s880joybQ@public.gmane.org>

Extended CPLD only exists on certain boards (SPMB) and by itself requires
an MFD driver, since it supports its own interrupts and sub-devices.
It also needs to provide support for SIB hotplug. It is cleaner and easier
to maintain it as separate driver.

Signed-off-by: Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
Signed-off-by: Guenter Roeck <groeck-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
Signed-off-by: JawaharBalaji Thirumalaisamy <jawaharb-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
Signed-off-by: Tom Kavanagh <tkavanagh-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
---
 drivers/mfd/Kconfig                 |  13 +++
 drivers/mfd/Makefile                |   1 +
 drivers/mfd/ptxpmb-ext-cpld-core.c  | 221 ++++++++++++++++++++++++++++++++++++
 include/linux/mfd/ptxpmb_ext_cpld.h |  42 +++++++
 4 files changed, 277 insertions(+)
 create mode 100644 drivers/mfd/ptxpmb-ext-cpld-core.c
 create mode 100644 include/linux/mfd/ptxpmb_ext_cpld.h

diff --git a/drivers/mfd/Kconfig b/drivers/mfd/Kconfig
index 75b46a1..7e1fa14 100644
--- a/drivers/mfd/Kconfig
+++ b/drivers/mfd/Kconfig
@@ -1371,6 +1371,19 @@ config MFD_JUNIPER_SAM
 	  This driver can be built as a module. If built as a module it will be
 	  called "sam-core"
 
+config MFD_JUNIPER_EXT_CPLD
+	tristate "Juniper PTX PMB Extended CPLD"
+	depends on PTXPMB_COMMON
+	default y if PTXPMB_COMMON
+	select MFD_CORE
+	help
+	  Select this to enable the PTX PMB Extended CPLD multi-function kernel
+	  driver for the applicable Juniper platforms.
+
+	  This driver can be built as a module. If built as a module it will be
+	  called "ptxpmb-ext-cpld"
+
+
 config MFD_TWL4030_AUDIO
 	bool "TI TWL4030 Audio"
 	depends on TWL4030_CORE
diff --git a/drivers/mfd/Makefile b/drivers/mfd/Makefile
index 71a8ba6..da94482 100644
--- a/drivers/mfd/Makefile
+++ b/drivers/mfd/Makefile
@@ -150,6 +150,7 @@ obj-$(CONFIG_AB8500_DEBUG)	+= ab8500-debugfs.o
 obj-$(CONFIG_AB8500_GPADC)	+= ab8500-gpadc.o
 obj-$(CONFIG_MFD_JUNIPER_CPLD)	+= ptxpmb-cpld-core.o
 obj-$(CONFIG_MFD_JUNIPER_SAM)	+= sam-core.o
+obj-$(CONFIG_MFD_JUNIPER_EXT_CPLD) += ptxpmb-ext-cpld-core.o
 obj-$(CONFIG_MFD_DB8500_PRCMU)	+= db8500-prcmu.o
 # ab8500-core need to come after db8500-prcmu (which provides the channel)
 obj-$(CONFIG_AB8500_CORE)	+= ab8500-core.o ab8500-sysctrl.o
diff --git a/drivers/mfd/ptxpmb-ext-cpld-core.c b/drivers/mfd/ptxpmb-ext-cpld-core.c
new file mode 100644
index 0000000..a1b1793
--- /dev/null
+++ b/drivers/mfd/ptxpmb-ext-cpld-core.c
@@ -0,0 +1,221 @@
+/*
+ * Juniper PTX PMB Extended CPLD multi-function core driver
+ *
+ * Copyright (C) 2012 Juniper Networks
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/wait.h>
+#include <linux/clk.h>
+#include <linux/interrupt.h>
+#include <linux/device.h>
+#include <linux/spinlock.h>
+#include <linux/platform_device.h>
+#include <linux/delay.h>
+#include <linux/io.h>
+#include <linux/mfd/core.h>
+#include <linux/of.h>
+#include <linux/sched.h>
+#include <linux/mfd/ptxpmb_ext_cpld.h>
+#include <linux/jnx/jnx-subsys.h>
+
+struct pmb_ext_cpld_core {
+	struct device		*dev;
+	struct pmb_boot_cpld_ext __iomem *cpld;
+	spinlock_t		lock;
+	int			irq0, irq1;
+	wait_queue_head_t	wqh;
+};
+
+static irqreturn_t pmb_ext_cpld_core_interrupt(int irq, void *dev_data)
+{
+	struct pmb_ext_cpld_core *cpld = dev_data;
+	unsigned char __iomem *data;
+	int i;
+	u8 buffer[48];
+
+	dev_info(cpld->dev, "interrupt %d sib presence=0x%x irq status=0x%x\n",
+		 irq, ioread16(&cpld->cpld->sib_presence),
+		 ioread16(&cpld->cpld->sib_irq_status));
+
+	data = (u8 *)cpld->cpld;
+	for (i = 0; i < 48; i++)
+		buffer[i] = ioread8(data + i);
+
+	print_hex_dump(KERN_INFO, dev_name(cpld->dev), DUMP_PREFIX_OFFSET,
+		       16, 4, buffer, 48, false);
+
+	spin_lock(&cpld->wqh.lock);
+
+	/* clear interrupt, wake up any handlers */
+	wake_up_locked(&cpld->wqh);
+
+	spin_unlock(&cpld->wqh.lock);
+
+	return IRQ_HANDLED;
+}
+
+static ssize_t show_sib_status(struct device *dev,
+			       struct device_attribute *attr, char *buf)
+{
+	struct pmb_ext_cpld_core *cpld = dev_get_drvdata(dev);
+
+	WARN_ONCE(1,
+		  "sib_status is deprecated and should no longer be used for presence detection\n");
+
+	return sprintf(buf, "0x%04x\n",
+		       ioread16(&cpld->cpld->sib_presence));
+}
+
+static DEVICE_ATTR(sib_status, S_IRUGO, show_sib_status, NULL);
+
+static struct resource pmb_ext_cpld_resources[] = {
+	{
+		.start	= 0,
+		.end	= sizeof(struct pmb_boot_cpld_ext) - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+};
+
+static struct mfd_cell pmb_ext_cpld_cells[] = {
+	{
+		.name = "gpio-ptxpmb-ext-cpld",
+		.num_resources = ARRAY_SIZE(pmb_ext_cpld_resources),
+		.resources = pmb_ext_cpld_resources,
+		.of_compatible = "jnx,gpio-ptxpmb-ext-cpld",
+	},
+};
+
+static int pmb_ext_cpld_core_probe(struct platform_device *pdev)
+{
+	static struct pmb_ext_cpld_core *cpld;
+	struct device *dev = &pdev->dev;
+	struct resource *res;
+	int error;
+	u16 asid;
+
+	cpld = devm_kzalloc(dev, sizeof(*cpld), GFP_KERNEL);
+	if (!cpld)
+		return -ENOMEM;
+
+	cpld->dev = dev;
+	dev_set_drvdata(dev, cpld);
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	cpld->cpld = devm_ioremap_resource(dev, res);
+	if (IS_ERR(cpld->cpld))
+		return PTR_ERR(cpld->cpld);
+
+	cpld->irq0 = platform_get_irq(pdev, 0);
+	if (cpld->irq0 >= 0) {
+		error = devm_request_threaded_irq(dev, cpld->irq0, NULL,
+						  pmb_ext_cpld_core_interrupt,
+						  IRQF_TRIGGER_RISING |
+						  IRQF_TRIGGER_FALLING |
+						  IRQF_ONESHOT,
+						  dev_name(dev), cpld);
+		if (error < 0)
+			return error;
+	}
+
+	cpld->irq1 = platform_get_irq(pdev, 1);
+	if (cpld->irq1 >= 0) {
+		error = devm_request_threaded_irq(dev, cpld->irq1, NULL,
+						  pmb_ext_cpld_core_interrupt,
+						  IRQF_TRIGGER_RISING |
+						  IRQF_TRIGGER_FALLING |
+						  IRQF_ONESHOT,
+						  dev_name(dev), cpld);
+		if (error < 0)
+			return error;
+	}
+
+	spin_lock_init(&cpld->lock);
+	init_waitqueue_head(&cpld->wqh);
+
+	asid = ioread16be(&cpld->cpld->cb_assembly_id);
+
+	dev_info(dev, "Ext CPLD rev %u.%u CB asy 0x%x CB rev %u.%u\n",
+		 ioread8(&cpld->cpld->major_rev),
+		 ioread8(&cpld->cpld->minor_rev),
+		 asid,
+		 ioread8(&cpld->cpld->cb_major_version),
+		 ioread8(&cpld->cpld->cb_minor_version));
+
+	dev_info(dev, "SIB status=0x%x SIB irq status=0x%x\n",
+		 ioread16(&cpld->cpld->sib_presence),
+		 ioread16(&cpld->cpld->sib_irq_status));
+
+	error = device_create_file(dev, &dev_attr_sib_status);
+	if (error)
+		return error;
+	error = mfd_add_devices(dev, pdev->id, pmb_ext_cpld_cells,
+				ARRAY_SIZE(pmb_ext_cpld_cells), res,
+				0, NULL);
+	if (error < 0)
+		goto abort;
+
+	iowrite16(0xffff, &cpld->cpld->sib_presence_irq_en);
+	iowrite16(0xffff, &cpld->cpld->sib_irq_en);
+
+	return 0;
+
+abort:
+	device_remove_file(dev, &dev_attr_sib_status);
+	return error;
+}
+
+static int pmb_ext_cpld_core_remove(struct platform_device *pdev)
+{
+	mfd_remove_devices(&pdev->dev);
+	device_remove_file(&pdev->dev, &dev_attr_sib_status);
+	return 0;
+}
+
+static const struct of_device_id pmb_ext_cpld_of_ids[] = {
+	{ .compatible = "jnx,ptxpmb-ext-cpld" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, pmb_ext_cpld_of_ids);
+
+static struct platform_driver pmb_ext_cpld_core_driver = {
+	.probe		= pmb_ext_cpld_core_probe,
+	.remove		= pmb_ext_cpld_core_remove,
+	.driver		= {
+		.name	= "ptxpmb-ext-cpld",
+		.of_match_table = pmb_ext_cpld_of_ids,
+		.owner	= THIS_MODULE,
+	}
+};
+
+static int __init pmb_ext_cpld_core_init(void)
+{
+	return platform_driver_register(&pmb_ext_cpld_core_driver);
+}
+module_init(pmb_ext_cpld_core_init);
+
+static void __exit pmb_ext_cpld_core_exit(void)
+{
+	platform_driver_unregister(&pmb_ext_cpld_core_driver);
+}
+module_exit(pmb_ext_cpld_core_exit);
+
+MODULE_DESCRIPTION("Juniper PTX PMB Extended CPLD Core Driver");
+MODULE_AUTHOR("Guenter Roeck <groeck-3r7Miqu9kMnR7s880joybQ@public.gmane.org>");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:ptxpmb-cpld");
diff --git a/include/linux/mfd/ptxpmb_ext_cpld.h b/include/linux/mfd/ptxpmb_ext_cpld.h
new file mode 100644
index 0000000..bac9a73
--- /dev/null
+++ b/include/linux/mfd/ptxpmb_ext_cpld.h
@@ -0,0 +1,42 @@
+/*---------------------------------------------------------------------------
+ *
+ * ptxpmb_ext_cpld_core.h
+ *     Copyright (c) 2012, 2013 Juniper Networks
+ *
+ *---------------------------------------------------------------------------
+ */
+
+#ifndef PTXPMB_EXT_CPLD_CORE_H
+#define PTXPMB_EXT_CPLD_CORE_H
+
+/*
+ * Extended CPLD registers
+ */
+struct pmb_boot_cpld_ext {
+	u8 major_rev;			/* 0x00 */
+	u8 minor_rev;			/* 0x01 */
+	u16 sib_presence;		/* 0x02 */
+	u8 unused0[4];			/* 0x04 */
+	u16 sib_presence_irq_en;	/* 0x08 */
+	u8 unused1[4];			/* 0x0a */
+	u16 sib_irq_status;		/* 0x0e */
+	u8 unused2[4];			/* 0x10 */
+	u16 sib_irq_en;			/* 0x14 */
+	u8 unused3[4];			/* 0x16 */
+	u8 i2c_group;			/* 0x1a */
+	u8 i2c_mux_sel;			/* 0x1b */
+	u8 re_status;			/* 0x1c */
+	u8 unused4[0x24 - 0x1d];	/* 0x1d */
+	u16 cb_assembly_id;		/* 0x24 */
+	u8 cb_major_version;		/* 0x26 */
+	u8 cb_minor_version;		/* 0x27 */
+	u8 unused5[0x40 - 0x28];	/* 0x28 */
+	u8 spare_a;			/* 0x40 */
+	u8 spare_b;			/* 0x41 */
+	u8 spare_c;			/* 0x42 */
+	u8 spare_d;			/* 0x43 */
+	u8 spare_e;			/* 0x44 */
+	u8 unused6[0x3ff - 0x45];	/* 0x45 */
+};
+
+#endif /* PTXPMB_EXT_CPLD_CORE_H */
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
