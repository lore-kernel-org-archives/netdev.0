From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 11/11] net/can/mscan: improve build
Date: Mon, 16 Nov 2009 23:57:54 +0100
Message-ID: <1258412274-14686-12-git-send-email-w.sang@pengutronix.de>
References: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1258412274-14686-1-git-send-email-w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

- move Kconfig entries to the subdirectory
- do remaining renames of mpc52xx to mpc5xxx

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/Kconfig             |   19 +---
 drivers/net/can/mscan/Kconfig       |   23 +++
 drivers/net/can/mscan/Makefile      |    4 +-
 drivers/net/can/mscan/mpc52xx_can.c |  259 -----------------------------------
 drivers/net/can/mscan/mpc5xxx_can.c |  259 +++++++++++++++++++++++++++++++++++
 5 files changed, 285 insertions(+), 279 deletions(-)
 create mode 100644 drivers/net/can/mscan/Kconfig
 delete mode 100644 drivers/net/can/mscan/mpc52xx_can.c
 create mode 100644 drivers/net/can/mscan/mpc5xxx_can.c

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index c16e6ff..c1cfe2e 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -108,24 +108,7 @@ config CAN_MCP251X
 	---help---
 	  Driver for the Microchip MCP251x SPI CAN controllers.
 
-config CAN_MSCAN
-	depends on CAN_DEV && (PPC || M68K || M68KNOMMU)
-	tristate "Support for Freescale MSCAN based chips"
-	---help---
-	  The Motorola Scalable Controller Area Network (MSCAN) definition
-	  is based on the MSCAN12 definition which is the specific
-	  implementation of the Motorola Scalable CAN concept targeted for
-	  the Motorola MC68HC12 Microcontroller Family.
-
-config CAN_MPC52XX
-	tristate "Freescale MPC5xxx onboard CAN controller"
-	depends on CAN_MSCAN && PPC_MPC52xx
-	---help---
-	  If you say yes here you get support for Freescale's MPC52xx
-	  onboard dualCAN controller.
-
-	  This driver can also be built as a module.  If so, the module
-	  will be called mpc5xxx_can.
+source "drivers/net/can/mscan/Kconfig"
 
 config CAN_DEBUG_DEVICES
 	bool "CAN devices debugging messages"
diff --git a/drivers/net/can/mscan/Kconfig b/drivers/net/can/mscan/Kconfig
new file mode 100644
index 0000000..cd0f2d6
--- /dev/null
+++ b/drivers/net/can/mscan/Kconfig
@@ -0,0 +1,23 @@
+config CAN_MSCAN
+	depends on CAN_DEV && (PPC || M68K || M68KNOMMU)
+	tristate "Support for Freescale MSCAN based chips"
+	---help---
+	  The Motorola Scalable Controller Area Network (MSCAN) definition
+	  is based on the MSCAN12 definition which is the specific
+	  implementation of the Motorola Scalable CAN concept targeted for
+	  the Motorola MC68HC12 Microcontroller Family.
+
+if CAN_MSCAN
+
+config CAN_MPC5XXX
+	tristate "Freescale MPC5xxx onboard CAN controller"
+	depends on PPC_MPC52xx
+	---help---
+	  If you say yes here you get support for Freescale's MPC5xxx
+	  onboard CAN controller.
+
+	  This driver can also be built as a module.  If so, the module
+	  will be called mscan-mpc5xxx.ko.
+
+endif
+
diff --git a/drivers/net/can/mscan/Makefile b/drivers/net/can/mscan/Makefile
index 2bd9f04..c9fab17 100644
--- a/drivers/net/can/mscan/Makefile
+++ b/drivers/net/can/mscan/Makefile
@@ -1,5 +1,5 @@
 
-obj-$(CONFIG_CAN_MPC52XX)	+= mscan-mpc52xx.o
-mscan-mpc52xx-objs		:= mscan.o mpc52xx_can.o
+obj-$(CONFIG_CAN_MPC5XXX)	+= mscan-mpc5xxx.o
+mscan-mpc5xxx-objs		:= mscan.o mpc5xxx_can.o
 
 ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/mscan/mpc52xx_can.c b/drivers/net/can/mscan/mpc52xx_can.c
deleted file mode 100644
index 1de6f63..0000000
--- a/drivers/net/can/mscan/mpc52xx_can.c
+++ /dev/null
@@ -1,259 +0,0 @@
-/*
- * CAN bus driver for the Freescale MPC5xxx embedded CPU.
- *
- * Copyright (C) 2004-2005 Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>,
- *                         Varma Electronics Oy
- * Copyright (C) 2008-2009 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
- * Copyright (C) 2009 Wolfram Sang, Pengutronix <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the version 2 of the GNU General Public License
- * as published by the Free Software Foundation
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/interrupt.h>
-#include <linux/platform_device.h>
-#include <linux/netdevice.h>
-#include <linux/can.h>
-#include <linux/can/dev.h>
-#include <linux/of_platform.h>
-#include <sysdev/fsl_soc.h>
-#include <linux/io.h>
-#include <asm/mpc52xx.h>
-
-#include "mscan.h"
-
-#define DRV_NAME "mpc5xxx_can"
-
-static struct of_device_id mpc52xx_cdm_ids[] __devinitdata = {
-	{ .compatible = "fsl,mpc5200-cdm", },
-	{}
-};
-
-/*
- * Get frequency of the MSCAN clock source
- *
- * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock (IP_CLK)
- * can be selected. According to the MPC5200 user's manual, the oscillator
- * clock is the better choice as it has less jitter but due to a hardware
- * bug, it can not be selected for the old MPC5200 Rev. A chips.
- */
-
-static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *of,
-						      int clock_src)
-{
-	unsigned int pvr;
-	struct mpc52xx_cdm  __iomem *cdm;
-	struct device_node *np_cdm;
-	unsigned int freq;
-	u32 val;
-
-	pvr = mfspr(SPRN_PVR);
-
-	freq = mpc5xxx_get_bus_frequency(of->node);
-	if (!freq)
-		return 0;
-
-	if (clock_src == MSCAN_CLKSRC_BUS || pvr == 0x80822011)
-		return freq;
-
-	/* Determine SYS_XTAL_IN frequency from the clock domain settings */
-	np_cdm = of_find_matching_node(NULL, mpc52xx_cdm_ids);
-	if (!np_cdm) {
-		dev_err(&of->dev, "can't get clock node!\n");
-		return 0;
-	}
-	cdm = of_iomap(np_cdm, 0);
-	of_node_put(np_cdm);
-
-	if (in_8(&cdm->ipb_clk_sel) & 0x1)
-		freq *= 2;
-	val = in_be32(&cdm->rstcfg);
-
-	freq *= (val & (1 << 5)) ? 8 : 4;
-	freq /= (val & (1 << 6)) ? 12 : 16;
-
-	iounmap(cdm);
-
-	return freq;
-}
-
-static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
-				       const struct of_device_id *id)
-{
-	struct device_node *np = ofdev->node;
-	struct net_device *dev;
-	struct mscan_priv *priv;
-	void __iomem *base;
-	const char *clk_src;
-	int err, irq, clock_src;
-
-	base = of_iomap(ofdev->node, 0);
-	if (!base) {
-		dev_err(&ofdev->dev, "couldn't ioremap\n");
-		err = -ENOMEM;
-		goto exit_release_mem;
-	}
-
-	irq = irq_of_parse_and_map(np, 0);
-	if (!irq) {
-		dev_err(&ofdev->dev, "no irq found\n");
-		err = -ENODEV;
-		goto exit_unmap_mem;
-	}
-
-	dev = alloc_mscandev();
-	if (!dev) {
-		err = -ENOMEM;
-		goto exit_dispose_irq;
-	}
-
-	priv = netdev_priv(dev);
-	priv->reg_base = base;
-	dev->irq = irq;
-
-	/*
-	 * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock
-	 * (IP_CLK) can be selected as MSCAN clock source. According to
-	 * the MPC5200 user's manual, the oscillator clock is the better
-	 * choice as it has less jitter. For this reason, it is selected
-	 * by default.
-	 */
-	clk_src = of_get_property(np, "fsl,mscan-clock-source", NULL);
-	if (clk_src && strcmp(clk_src, "ip") == 0)
-		clock_src = MSCAN_CLKSRC_BUS;
-	else
-		clock_src = MSCAN_CLKSRC_XTAL;
-	priv->can.clock.freq = mpc52xx_can_clock_freq(ofdev, clock_src);
-	if (!priv->can.clock.freq) {
-		dev_err(&ofdev->dev, "couldn't get MSCAN clock frequency\n");
-		err = -ENODEV;
-		goto exit_free_mscan;
-	}
-
-	SET_NETDEV_DEV(dev, &ofdev->dev);
-
-	err = register_mscandev(dev, clock_src);
-	if (err) {
-		dev_err(&ofdev->dev, "registering %s failed (err=%d)\n",
-			DRV_NAME, err);
-		goto exit_free_mscan;
-	}
-
-	dev_set_drvdata(&ofdev->dev, dev);
-
-	dev_info(&ofdev->dev, "MSCAN at 0x%p, irq %d, clock %d Hz\n",
-		 priv->reg_base, dev->irq, priv->can.clock.freq);
-
-	return 0;
-
-exit_free_mscan:
-	free_candev(dev);
-exit_dispose_irq:
-	irq_dispose_mapping(irq);
-exit_unmap_mem:
-	iounmap(base);
-exit_release_mem:
-	return err;
-}
-
-static int __devexit mpc5xxx_can_remove(struct of_device *ofdev)
-{
-	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
-	struct mscan_priv *priv = netdev_priv(dev);
-
-	dev_set_drvdata(&ofdev->dev, NULL);
-
-	unregister_mscandev(dev);
-	iounmap(priv->reg_base);
-	irq_dispose_mapping(dev->irq);
-	free_candev(dev);
-
-	return 0;
-}
-
-#ifdef CONFIG_PM
-static struct mscan_regs saved_regs;
-static int mpc5xxx_can_suspend(struct of_device *ofdev, pm_message_t state)
-{
-	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
-	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
-
-	_memcpy_fromio(&saved_regs, regs, sizeof(*regs));
-
-	return 0;
-}
-
-static int mpc5xxx_can_resume(struct of_device *ofdev)
-{
-	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
-	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
-
-	regs->canctl0 |= MSCAN_INITRQ;
-	while (!(regs->canctl1 & MSCAN_INITAK))
-		udelay(10);
-
-	regs->canctl1 = saved_regs.canctl1;
-	regs->canbtr0 = saved_regs.canbtr0;
-	regs->canbtr1 = saved_regs.canbtr1;
-	regs->canidac = saved_regs.canidac;
-
-	/* restore masks, buffers etc. */
-	_memcpy_toio(&regs->canidar1_0, (void *)&saved_regs.canidar1_0,
-		     sizeof(*regs) - offsetof(struct mscan_regs, canidar1_0));
-
-	regs->canctl0 &= ~MSCAN_INITRQ;
-	regs->cantbsel = saved_regs.cantbsel;
-	regs->canrier = saved_regs.canrier;
-	regs->cantier = saved_regs.cantier;
-	regs->canctl0 = saved_regs.canctl0;
-
-	return 0;
-}
-#endif
-
-static struct of_device_id __devinitdata mpc5xxx_can_table[] = {
-	{.compatible = "fsl,mpc5200-mscan"},
-	{},
-};
-
-static struct of_platform_driver mpc5xxx_can_driver = {
-	.owner = THIS_MODULE,
-	.name = "mpc5xxx_can",
-	.probe = mpc5xxx_can_probe,
-	.remove = __devexit_p(mpc5xxx_can_remove),
-#ifdef CONFIG_PM
-	.suspend = mpc5xxx_can_suspend,
-	.resume = mpc5xxx_can_resume,
-#endif
-	.match_table = mpc5xxx_can_table,
-};
-
-static int __init mpc5xxx_can_init(void)
-{
-	return of_register_platform_driver(&mpc5xxx_can_driver);
-}
-module_init(mpc5xxx_can_init);
-
-static void __exit mpc5xxx_can_exit(void)
-{
-	return of_unregister_platform_driver(&mpc5xxx_can_driver);
-};
-module_exit(mpc5xxx_can_exit);
-
-MODULE_AUTHOR("Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>");
-MODULE_DESCRIPTION("Freescale MPC5200 CAN driver");
-MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
new file mode 100644
index 0000000..1de6f63
--- /dev/null
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -0,0 +1,259 @@
+/*
+ * CAN bus driver for the Freescale MPC5xxx embedded CPU.
+ *
+ * Copyright (C) 2004-2005 Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>,
+ *                         Varma Electronics Oy
+ * Copyright (C) 2008-2009 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
+ * Copyright (C) 2009 Wolfram Sang, Pengutronix <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the version 2 of the GNU General Public License
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/of_platform.h>
+#include <sysdev/fsl_soc.h>
+#include <linux/io.h>
+#include <asm/mpc52xx.h>
+
+#include "mscan.h"
+
+#define DRV_NAME "mpc5xxx_can"
+
+static struct of_device_id mpc52xx_cdm_ids[] __devinitdata = {
+	{ .compatible = "fsl,mpc5200-cdm", },
+	{}
+};
+
+/*
+ * Get frequency of the MSCAN clock source
+ *
+ * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock (IP_CLK)
+ * can be selected. According to the MPC5200 user's manual, the oscillator
+ * clock is the better choice as it has less jitter but due to a hardware
+ * bug, it can not be selected for the old MPC5200 Rev. A chips.
+ */
+
+static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *of,
+						      int clock_src)
+{
+	unsigned int pvr;
+	struct mpc52xx_cdm  __iomem *cdm;
+	struct device_node *np_cdm;
+	unsigned int freq;
+	u32 val;
+
+	pvr = mfspr(SPRN_PVR);
+
+	freq = mpc5xxx_get_bus_frequency(of->node);
+	if (!freq)
+		return 0;
+
+	if (clock_src == MSCAN_CLKSRC_BUS || pvr == 0x80822011)
+		return freq;
+
+	/* Determine SYS_XTAL_IN frequency from the clock domain settings */
+	np_cdm = of_find_matching_node(NULL, mpc52xx_cdm_ids);
+	if (!np_cdm) {
+		dev_err(&of->dev, "can't get clock node!\n");
+		return 0;
+	}
+	cdm = of_iomap(np_cdm, 0);
+	of_node_put(np_cdm);
+
+	if (in_8(&cdm->ipb_clk_sel) & 0x1)
+		freq *= 2;
+	val = in_be32(&cdm->rstcfg);
+
+	freq *= (val & (1 << 5)) ? 8 : 4;
+	freq /= (val & (1 << 6)) ? 12 : 16;
+
+	iounmap(cdm);
+
+	return freq;
+}
+
+static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
+				       const struct of_device_id *id)
+{
+	struct device_node *np = ofdev->node;
+	struct net_device *dev;
+	struct mscan_priv *priv;
+	void __iomem *base;
+	const char *clk_src;
+	int err, irq, clock_src;
+
+	base = of_iomap(ofdev->node, 0);
+	if (!base) {
+		dev_err(&ofdev->dev, "couldn't ioremap\n");
+		err = -ENOMEM;
+		goto exit_release_mem;
+	}
+
+	irq = irq_of_parse_and_map(np, 0);
+	if (!irq) {
+		dev_err(&ofdev->dev, "no irq found\n");
+		err = -ENODEV;
+		goto exit_unmap_mem;
+	}
+
+	dev = alloc_mscandev();
+	if (!dev) {
+		err = -ENOMEM;
+		goto exit_dispose_irq;
+	}
+
+	priv = netdev_priv(dev);
+	priv->reg_base = base;
+	dev->irq = irq;
+
+	/*
+	 * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock
+	 * (IP_CLK) can be selected as MSCAN clock source. According to
+	 * the MPC5200 user's manual, the oscillator clock is the better
+	 * choice as it has less jitter. For this reason, it is selected
+	 * by default.
+	 */
+	clk_src = of_get_property(np, "fsl,mscan-clock-source", NULL);
+	if (clk_src && strcmp(clk_src, "ip") == 0)
+		clock_src = MSCAN_CLKSRC_BUS;
+	else
+		clock_src = MSCAN_CLKSRC_XTAL;
+	priv->can.clock.freq = mpc52xx_can_clock_freq(ofdev, clock_src);
+	if (!priv->can.clock.freq) {
+		dev_err(&ofdev->dev, "couldn't get MSCAN clock frequency\n");
+		err = -ENODEV;
+		goto exit_free_mscan;
+	}
+
+	SET_NETDEV_DEV(dev, &ofdev->dev);
+
+	err = register_mscandev(dev, clock_src);
+	if (err) {
+		dev_err(&ofdev->dev, "registering %s failed (err=%d)\n",
+			DRV_NAME, err);
+		goto exit_free_mscan;
+	}
+
+	dev_set_drvdata(&ofdev->dev, dev);
+
+	dev_info(&ofdev->dev, "MSCAN at 0x%p, irq %d, clock %d Hz\n",
+		 priv->reg_base, dev->irq, priv->can.clock.freq);
+
+	return 0;
+
+exit_free_mscan:
+	free_candev(dev);
+exit_dispose_irq:
+	irq_dispose_mapping(irq);
+exit_unmap_mem:
+	iounmap(base);
+exit_release_mem:
+	return err;
+}
+
+static int __devexit mpc5xxx_can_remove(struct of_device *ofdev)
+{
+	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct mscan_priv *priv = netdev_priv(dev);
+
+	dev_set_drvdata(&ofdev->dev, NULL);
+
+	unregister_mscandev(dev);
+	iounmap(priv->reg_base);
+	irq_dispose_mapping(dev->irq);
+	free_candev(dev);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static struct mscan_regs saved_regs;
+static int mpc5xxx_can_suspend(struct of_device *ofdev, pm_message_t state)
+{
+	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+
+	_memcpy_fromio(&saved_regs, regs, sizeof(*regs));
+
+	return 0;
+}
+
+static int mpc5xxx_can_resume(struct of_device *ofdev)
+{
+	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+
+	regs->canctl0 |= MSCAN_INITRQ;
+	while (!(regs->canctl1 & MSCAN_INITAK))
+		udelay(10);
+
+	regs->canctl1 = saved_regs.canctl1;
+	regs->canbtr0 = saved_regs.canbtr0;
+	regs->canbtr1 = saved_regs.canbtr1;
+	regs->canidac = saved_regs.canidac;
+
+	/* restore masks, buffers etc. */
+	_memcpy_toio(&regs->canidar1_0, (void *)&saved_regs.canidar1_0,
+		     sizeof(*regs) - offsetof(struct mscan_regs, canidar1_0));
+
+	regs->canctl0 &= ~MSCAN_INITRQ;
+	regs->cantbsel = saved_regs.cantbsel;
+	regs->canrier = saved_regs.canrier;
+	regs->cantier = saved_regs.cantier;
+	regs->canctl0 = saved_regs.canctl0;
+
+	return 0;
+}
+#endif
+
+static struct of_device_id __devinitdata mpc5xxx_can_table[] = {
+	{.compatible = "fsl,mpc5200-mscan"},
+	{},
+};
+
+static struct of_platform_driver mpc5xxx_can_driver = {
+	.owner = THIS_MODULE,
+	.name = "mpc5xxx_can",
+	.probe = mpc5xxx_can_probe,
+	.remove = __devexit_p(mpc5xxx_can_remove),
+#ifdef CONFIG_PM
+	.suspend = mpc5xxx_can_suspend,
+	.resume = mpc5xxx_can_resume,
+#endif
+	.match_table = mpc5xxx_can_table,
+};
+
+static int __init mpc5xxx_can_init(void)
+{
+	return of_register_platform_driver(&mpc5xxx_can_driver);
+}
+module_init(mpc5xxx_can_init);
+
+static void __exit mpc5xxx_can_exit(void)
+{
+	return of_unregister_platform_driver(&mpc5xxx_can_driver);
+};
+module_exit(mpc5xxx_can_exit);
+
+MODULE_AUTHOR("Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>");
+MODULE_DESCRIPTION("Freescale MPC5200 CAN driver");
+MODULE_LICENSE("GPL v2");
-- 
1.6.3.3
