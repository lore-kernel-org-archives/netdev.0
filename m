From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH 4/7] arm: mach-pnx4008: Adjust i2c.c to updated i2c-pnx.c
Date: Mon,  2 Apr 2012 14:56:01 +0200
Message-ID: <1333371364-21347-5-git-send-email-stigge@antcom.de>
References: <1333371364-21347-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>
To: arm@kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-i2c@vger.kernel.org, linux-kernel@vger.kernel.org,
 w.sang@pengutronix.de, srinivas.bakki@nxp.com, kevin.wells@nxp.com,
 gregkh@linuxfoundation.org, netdev@vger.kernel.org,
 rtc-linux@googlegroups.com, a.zummo@towertech.it,
 linux-watchdog@vger.kernel.org, wim@iguana.be
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1333371364-21347-1-git-send-email-stigge@antcom.de>
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

The i2c bus driver i2c-pnx.c (used by mach-pnx4008 and mach-lpc32xx) was
updated to support device tree. In this process, the struct i2c_pnx_data was
eliminated. Therefore, the platform data of pnx4008 is adjusted with this patch
to use default resources for mem and irq. DT support for pnx4008 is still not
available, but i2c-pnx.c now supports both DT and non-DT.

arch/arm/mach-pnx4008/include/mach/i2c.h can safely be removed now since its
contents is integrated in the updated i2c-pnx.c driver and was duplicated
between platforms pnx4008 and lpc32xx.

Signed-off-by: Roland Stigge <stigge@antcom.de>

---

 Applies to v3.4-rc1

 arch/arm/mach-pnx4008/i2c.c              |   58 +++++++++++++++++-----------
 arch/arm/mach-pnx4008/include/mach/i2c.h |   64 -------------------------------
 2 files changed, 36 insertions(+), 86 deletions(-)

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
 	.name = "pnx-i2c",
 	.id = 0,
-	.dev = {
-		.platform_data = &i2c0_data,
-	},
+	.resource = i2c0_resources,
+	.num_resources = ARRAY_SIZE(i2c0_resources),
 };
 
 static struct platform_device i2c1_device = {
 	.name = "pnx-i2c",
 	.id = 1,
-	.dev = {
-		.platform_data = &i2c1_data,
-	},
+	.resource = i2c1_resources,
+	.num_resources = ARRAY_SIZE(i2c1_resources),
 };
 
 static struct platform_device i2c2_device = {
 	.name = "pnx-i2c",
 	.id = 2,
-	.dev = {
-		.platform_data = &i2c2_data,
-	},
+	.resource = i2c2_resources,
+	.num_resources = ARRAY_SIZE(i2c2_resources),
 };
 
 static struct platform_device *devices[] __initdata = {
--- linux-2.6.orig/arch/arm/mach-pnx4008/include/mach/i2c.h
+++ /dev/null
@@ -1,64 +0,0 @@
-/*
- * PNX4008-specific tweaks for I2C IP3204 block
- *
- * Author: Vitaly Wool <vwool@ru.mvista.com>
- *
- * 2005 (c) MontaVista Software, Inc. This file is licensed under
- * the terms of the GNU General Public License version 2. This program
- * is licensed "as is" without any warranty of any kind, whether express
- * or implied.
- */
-
-#ifndef __ASM_ARCH_I2C_H__
-#define __ASM_ARCH_I2C_H__
-
-enum {
-	mstatus_tdi = 0x00000001,
-	mstatus_afi = 0x00000002,
-	mstatus_nai = 0x00000004,
-	mstatus_drmi = 0x00000008,
-	mstatus_active = 0x00000020,
-	mstatus_scl = 0x00000040,
-	mstatus_sda = 0x00000080,
-	mstatus_rff = 0x00000100,
-	mstatus_rfe = 0x00000200,
-	mstatus_tff = 0x00000400,
-	mstatus_tfe = 0x00000800,
-};
-
-enum {
-	mcntrl_tdie = 0x00000001,
-	mcntrl_afie = 0x00000002,
-	mcntrl_naie = 0x00000004,
-	mcntrl_drmie = 0x00000008,
-	mcntrl_daie = 0x00000020,
-	mcntrl_rffie = 0x00000040,
-	mcntrl_tffie = 0x00000080,
-	mcntrl_reset = 0x00000100,
-	mcntrl_cdbmode = 0x00000400,
-};
-
-enum {
-	rw_bit = 1 << 0,
-	start_bit = 1 << 8,
-	stop_bit = 1 << 9,
-};
-
-#define I2C_REG_RX(a)	((a)->ioaddr)		/* Rx FIFO reg (RO) */
-#define I2C_REG_TX(a)	((a)->ioaddr)		/* Tx FIFO reg (WO) */
-#define I2C_REG_STS(a)	((a)->ioaddr + 0x04)	/* Status reg (RO) */
-#define I2C_REG_CTL(a)	((a)->ioaddr + 0x08)	/* Ctl reg */
-#define I2C_REG_CKL(a)	((a)->ioaddr + 0x0c)	/* Clock divider low */
-#define I2C_REG_CKH(a)	((a)->ioaddr + 0x10)	/* Clock divider high */
-#define I2C_REG_ADR(a)	((a)->ioaddr + 0x14)	/* I2C address */
-#define I2C_REG_RFL(a)	((a)->ioaddr + 0x18)	/* Rx FIFO level (RO) */
-#define I2C_REG_TFL(a)	((a)->ioaddr + 0x1c)	/* Tx FIFO level (RO) */
-#define I2C_REG_RXB(a)	((a)->ioaddr + 0x20)	/* Num of bytes Rx-ed (RO) */
-#define I2C_REG_TXB(a)	((a)->ioaddr + 0x24)	/* Num of bytes Tx-ed (RO) */
-#define I2C_REG_TXS(a)	((a)->ioaddr + 0x28)	/* Tx slave FIFO (RO) */
-#define I2C_REG_STFL(a)	((a)->ioaddr + 0x2c)	/* Tx slave FIFO level (RO) */
-
-#define HCLK_MHZ		13
-#define I2C_CHIP_NAME		"PNX4008-I2C"
-
-#endif				/* __ASM_ARCH_I2C_H___ */
