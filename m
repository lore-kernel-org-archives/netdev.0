From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH v2 7/8] i2c-pnx.c: Remove duplicated i2c.h
Date: Mon,  2 Apr 2012 20:33:06 +0200
Message-ID: <1333391587-26290-8-git-send-email-stigge@antcom.de>
References: <1333391587-26290-1-git-send-email-stigge@antcom.de>
Cc: Roland Stigge <stigge@antcom.de>
To: arm@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-i2c@vger.kernel.org, linux-kernel@vger.kernel.org,
	w.sang@pengutronix.de, srinivas.bakki@nxp.com, kevin.wells@nxp.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	rtc-linux@googlegroups.com, a.zummo@towertech.it,
	linux-watchdog@vger.kernel.org, wim@iguana.be, jonsmirl@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333391587-26290-1-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The platforms using i2c-pnx.c both defined a duplicated i2c.h (used nowhere
else). This patch removes those and integrates the contents into the driver
itself.

Signed-off-by: Roland Stigge <stigge@antcom.de>

---

 Applies to v3.4-rc1

 arch/arm/mach-lpc32xx/include/mach/i2c.h |   63 ------------------------------
 arch/arm/mach-pnx4008/include/mach/i2c.h |   64 -------------------------------
 drivers/i2c/busses/i2c-pnx.c             |   49 ++++++++++++++++++++++-
 3 files changed, 46 insertions(+), 130 deletions(-)

--- linux-2.6.orig/arch/arm/mach-lpc32xx/include/mach/i2c.h
+++ /dev/null
@@ -1,63 +0,0 @@
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
-#ifndef __ASM_ARCH_I2C_H
-#define __ASM_ARCH_I2C_H
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
-#define I2C_CHIP_NAME		"PNX4008-I2C"
-
-#endif				/* __ASM_ARCH_I2C_H */
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
--- linux-2.6.orig/drivers/i2c/busses/i2c-pnx.c
+++ linux-2.6/drivers/i2c/busses/i2c-pnx.c
@@ -24,13 +24,56 @@
 #include <linux/clk.h>
 #include <linux/slab.h>
 
-#include <mach/hardware.h>
-#include <mach/i2c.h>
-
 #define I2C_PNX_TIMEOUT		10 /* msec */
 #define I2C_PNX_SPEED_KHZ	100
 #define I2C_PNX_REGION_SIZE	0x100
 
+enum {
+	mstatus_tdi = 0x00000001,
+	mstatus_afi = 0x00000002,
+	mstatus_nai = 0x00000004,
+	mstatus_drmi = 0x00000008,
+	mstatus_active = 0x00000020,
+	mstatus_scl = 0x00000040,
+	mstatus_sda = 0x00000080,
+	mstatus_rff = 0x00000100,
+	mstatus_rfe = 0x00000200,
+	mstatus_tff = 0x00000400,
+	mstatus_tfe = 0x00000800,
+};
+
+enum {
+	mcntrl_tdie = 0x00000001,
+	mcntrl_afie = 0x00000002,
+	mcntrl_naie = 0x00000004,
+	mcntrl_drmie = 0x00000008,
+	mcntrl_daie = 0x00000020,
+	mcntrl_rffie = 0x00000040,
+	mcntrl_tffie = 0x00000080,
+	mcntrl_reset = 0x00000100,
+	mcntrl_cdbmode = 0x00000400,
+};
+
+enum {
+	rw_bit = 1 << 0,
+	start_bit = 1 << 8,
+	stop_bit = 1 << 9,
+};
+
+#define I2C_REG_RX(a)	((a)->ioaddr)		/* Rx FIFO reg (RO) */
+#define I2C_REG_TX(a)	((a)->ioaddr)		/* Tx FIFO reg (WO) */
+#define I2C_REG_STS(a)	((a)->ioaddr + 0x04)	/* Status reg (RO) */
+#define I2C_REG_CTL(a)	((a)->ioaddr + 0x08)	/* Ctl reg */
+#define I2C_REG_CKL(a)	((a)->ioaddr + 0x0c)	/* Clock divider low */
+#define I2C_REG_CKH(a)	((a)->ioaddr + 0x10)	/* Clock divider high */
+#define I2C_REG_ADR(a)	((a)->ioaddr + 0x14)	/* I2C address */
+#define I2C_REG_RFL(a)	((a)->ioaddr + 0x18)	/* Rx FIFO level (RO) */
+#define I2C_REG_TFL(a)	((a)->ioaddr + 0x1c)	/* Tx FIFO level (RO) */
+#define I2C_REG_RXB(a)	((a)->ioaddr + 0x20)	/* Num of bytes Rx-ed (RO) */
+#define I2C_REG_TXB(a)	((a)->ioaddr + 0x24)	/* Num of bytes Tx-ed (RO) */
+#define I2C_REG_TXS(a)	((a)->ioaddr + 0x28)	/* Tx slave FIFO (RO) */
+#define I2C_REG_STFL(a)	((a)->ioaddr + 0x2c)	/* Tx slave FIFO level (RO) */
+
 static inline int wait_timeout(long timeout, struct i2c_pnx_algo_data *data)
 {
 	while (timeout > 0 &&
