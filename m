From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/7] sky2: GPIO register
Date: Mon, 04 Jun 2007 17:23:25 -0700
Message-ID: <20070605002738.952939289@linux-foundation.org>
References: <20070605002320.868185090@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35689 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759218AbXFEAnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:43:21 -0400
Content-Disposition: inline; filename=sky2-gpio.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The General Purpose I/O register is yet another hardware workaround
catchall. Enable workaround that vendor driver does to stay
but for bug compatiable.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    5 +++++
 drivers/net/sky2.h |   14 ++++++++++++++
 2 files changed, 19 insertions(+)

--- a/drivers/net/sky2.h	2007-06-04 08:46:43.000000000 -0700
+++ b/drivers/net/sky2.h	2007-06-04 08:46:47.000000000 -0700
@@ -441,6 +441,20 @@ enum {
 	TST_CFG_WRITE_OFF= 1<<0, /* Disable Config Reg WR */
 };
 
+/* 	B2_GPIO */
+enum {
+	GLB_GPIO_CLK_DEB_ENA = 1<<31,	/* Clock Debug Enable */
+	GLB_GPIO_CLK_DBG_MSK = 0xf<<26, /* Clock Debug */
+
+	GLB_GPIO_INT_RST_D3_DIS = 1<<15, /* Disable Internal Reset After D3 to D0 */
+	GLB_GPIO_LED_PAD_SPEED_UP = 1<<14, /* LED PAD Speed Up */
+	GLB_GPIO_STAT_RACE_DIS	= 1<<13, /* Status Race Disable */
+	GLB_GPIO_TEST_SEL_MSK	= 3<<11, /* Testmode Select */
+	GLB_GPIO_TEST_SEL_BASE	= 1<<11,
+	GLB_GPIO_RAND_ENA	= 1<<10, /* Random Enable */
+	GLB_GPIO_RAND_BIT_1	= 1<<9,  /* Random Bit 1 */
+};
+
 /*	B2_MAC_CFG		 8 bit	MAC Configuration / Chip Revision */
 enum {
 	CFG_CHIP_R_MSK	  = 0xf<<4,	/* Bit 7.. 4: Chip Revision */
--- a/drivers/net/sky2.c	2007-06-04 08:46:45.000000000 -0700
+++ b/drivers/net/sky2.c	2007-06-04 08:46:47.000000000 -0700
@@ -230,6 +230,11 @@ static void sky2_power_on(struct sky2_hw
 		sky2_pci_write32(hw, PCI_DEV_REG5, reg);
 
 		sky2_pci_write32(hw, PCI_CFG_REG_1, 0);
+
+		/* Enable workaround for dev 4.107 on Yukon-Ultra & Extreme */
+		reg = sky2_read32(hw, B2_GP_IO);
+		reg |= GLB_GPIO_STAT_RACE_DIS;
+		sky2_write32(hw, B2_GP_IO, reg);
 	}
 }
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

