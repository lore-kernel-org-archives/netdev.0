From: ganesanr@broadcom.com
Subject: [PATCH 2/2] MIPS: Netlogic: Platform changes for XLR/XLS gmac
Date: Tue, 29 Jan 2013 14:41:39 +0530
Message-ID: <1359450699-26141-2-git-send-email-ganesanr@broadcom.com>
References: <1359450699-26141-1-git-send-email-ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ganesan Ramalingam" <ganesanr@broadcom.com>
To: linux-mips@linux-mips.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1123 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156Ab3A2JMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 04:12:06 -0500
In-Reply-To: <1359450699-26141-1-git-send-email-ganesanr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesan Ramalingam <ganesanr@broadcom.com>

Add platform code to create network interface (xlr-net) for XLR/XLS
boards.

Signed-off-by: Ganesan Ramalingam <ganesanr@broadcom.com>
---
 This patch has to be merged through MIPS tree.
 This patch depends on patch [PATCH 1/2] NET: ethernet/netlogic: Netlogic XLR/XLS GMAC driver.

 arch/mips/include/asm/netlogic/xlr/platform_net.h |   41 ++++
 arch/mips/netlogic/xlr/Makefile                   |    3 +-
 arch/mips/netlogic/xlr/platform_net.c             |  223 +++++++++++++++++++++
 3 files changed, 266 insertions(+), 1 deletions(-)
 create mode 100644 arch/mips/include/asm/netlogic/xlr/platform_net.h
 create mode 100644 arch/mips/netlogic/xlr/platform_net.c

diff --git a/arch/mips/include/asm/netlogic/xlr/platform_net.h b/arch/mips/include/asm/netlogic/xlr/platform_net.h
new file mode 100644
index 0000000..617d9bb
--- /dev/null
+++ b/arch/mips/include/asm/netlogic/xlr/platform_net.h
@@ -0,0 +1,41 @@
+/*
+ * Copyright (c) 2003-2012 Broadcom Corporation
+ * All Rights Reserved
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the Broadcom
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY BROADCOM ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL BROADCOM OR CONTRIBUTORS BE LIABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+struct xlr_net_data {
+	int phy_interface;
+	int rfr_station;
+	int tx_stnid;
+	int *bucket_size;
+	int phy_addr;
+	struct xlr_fmn_info *gmac_fmn_info;
+};
diff --git a/arch/mips/netlogic/xlr/Makefile b/arch/mips/netlogic/xlr/Makefile
index 05902bc..ff7ed2e 100644
--- a/arch/mips/netlogic/xlr/Makefile
+++ b/arch/mips/netlogic/xlr/Makefile
@@ -1,2 +1,3 @@
-obj-y			+=  fmn.o fmn-config.o setup.o platform.o platform-flash.o
+obj-y			+=  fmn.o fmn-config.o setup.o platform.o \
+				 platform-flash.o platform_net.o
 obj-$(CONFIG_SMP)	+= wakeup.o
diff --git a/arch/mips/netlogic/xlr/platform_net.c b/arch/mips/netlogic/xlr/platform_net.c
new file mode 100644
index 0000000..31004fc
--- /dev/null
+++ b/arch/mips/netlogic/xlr/platform_net.c
@@ -0,0 +1,223 @@
+/*
+ * Copyright (c) 2003-2012 Broadcom Corporation
+ * All Rights Reserved
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * 1. Redistributions of source code must retain the above copyright
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the Broadcom
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY BROADCOM ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL BROADCOM OR CONTRIBUTORS BE LIABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/device.h>
+#include <linux/platform_device.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/ioport.h>
+#include <linux/resource.h>
+#include <linux/phy.h>
+
+#include <asm/netlogic/haldefs.h>
+#include <asm/netlogic/xlr/fmn.h>
+#include <asm/netlogic/xlr/xlr.h>
+#include <asm/netlogic/psb-bootinfo.h>
+#include <asm/netlogic/xlr/pic.h>
+#include <asm/netlogic/xlr/iomap.h>
+#include <asm/netlogic/xlr/platform_net.h>
+
+/* Linux Net */
+#define MAX_NUM_GMAC		8
+#define MAX_NUM_XLS_GMAC	8
+#define MAX_NUM_XLR_GMAC	4
+
+
+static u32 xlr_gmac_offsets[] = {
+	NETLOGIC_IO_GMAC_0_OFFSET, NETLOGIC_IO_GMAC_1_OFFSET,
+	NETLOGIC_IO_GMAC_2_OFFSET, NETLOGIC_IO_GMAC_3_OFFSET,
+	NETLOGIC_IO_GMAC_4_OFFSET, NETLOGIC_IO_GMAC_5_OFFSET,
+	NETLOGIC_IO_GMAC_6_OFFSET, NETLOGIC_IO_GMAC_7_OFFSET
+};
+
+static u32 xlr_gmac_irqs[] = { PIC_GMAC_0_IRQ, PIC_GMAC_1_IRQ,
+	PIC_GMAC_2_IRQ, PIC_GMAC_3_IRQ,
+	PIC_GMAC_4_IRQ, PIC_GMAC_5_IRQ,
+	PIC_GMAC_6_IRQ, PIC_GMAC_7_IRQ
+};
+
+static struct xlr_net_data ndata[MAX_NUM_GMAC];
+static struct resource xlr_net_res[8][5];
+static struct platform_device xlr_net_dev[8];
+
+static void config_mac(int mac, int phy, int mii, int serdes,
+		int pcs, int rfr, int tx, int *bkt_size,
+		struct xlr_fmn_info *gmac_fmn_info,
+		int phy_addr, struct resource *res)
+{
+	ndata[mac].phy_interface = phy;
+	ndata[mac].rfr_station = rfr;
+	ndata[mac].tx_stnid = tx;
+
+	res[0].name = "gmac";
+	res[0].start =
+		CPHYSADDR(nlm_mmio_base(xlr_gmac_offsets[mac]));
+	res[0].end = res[0].start + 0xfff;
+	res[0].flags = IORESOURCE_MEM;
+
+	res[1].name = "gmac";
+	res[1].start = xlr_gmac_irqs[mac];
+	res[1].end = xlr_gmac_irqs[mac];
+	res[1].flags = IORESOURCE_IRQ;
+
+	res[2].name = "gmac";
+	res[2].start = nlm_mmio_base(mii);
+	res[2].end = nlm_mmio_base(mii);
+	res[2].flags = IORESOURCE_MEM;
+
+	res[3].name = "gmac";
+	res[3].start = nlm_mmio_base(serdes);
+	res[3].end = nlm_mmio_base(serdes);
+	res[3].flags = IORESOURCE_MEM;
+
+	res[4].name = "gmac";
+	res[4].start = nlm_mmio_base(pcs);
+	res[4].end = nlm_mmio_base(pcs);
+	res[4].flags = IORESOURCE_MEM;
+
+	ndata[mac].bucket_size = bkt_size;
+	ndata[mac].gmac_fmn_info = gmac_fmn_info;
+	ndata[mac].phy_addr = phy_addr;
+}
+
+static void net_device_init(int id, struct resource *res)
+{
+	xlr_net_dev[id].name = "xlr-net";
+	xlr_net_dev[id].id = id;
+	xlr_net_dev[id].num_resources = 5;
+	xlr_net_dev[id].resource = res;
+	xlr_net_dev[id].dev.platform_data = &ndata[id];
+}
+
+static void gmac_init_xls(void)
+{
+	int mac;
+
+	switch (nlm_prom_info.board_major_version) {
+	case 12:
+		/* first block RGMII or XAUI, use RGMII */
+		config_mac(0,
+			PHY_INTERFACE_MODE_RGMII,
+			NETLOGIC_IO_GMAC_0_OFFSET,  /* mii */
+			NETLOGIC_IO_GMAC_0_OFFSET,  /* serdes */
+			NETLOGIC_IO_GMAC_0_OFFSET,  /* pcs */
+			FMN_STNID_GMACRFR_0,
+			FMN_STNID_GMAC0_TX0,
+			xlr_board_fmn_config.bucket_size,
+			&xlr_board_fmn_config.gmac[0],
+			0,
+			xlr_net_res[0]);
+
+		net_device_init(0, xlr_net_res[0]);
+		platform_device_register(&xlr_net_dev[0]);
+
+		/* second block is XAUI, not supported yet */
+		break;
+	default:
+		/* default XLS config, all ports SGMII */
+		for (mac = 0; mac < 4; mac++) {
+			config_mac(mac,
+				PHY_INTERFACE_MODE_SGMII,
+				NETLOGIC_IO_GMAC_0_OFFSET,  /* mii */
+				NETLOGIC_IO_GMAC_0_OFFSET,  /* serdes */
+				NETLOGIC_IO_GMAC_0_OFFSET,  /* pcs */
+				FMN_STNID_GMACRFR_0,
+				FMN_STNID_GMAC0_TX0 + mac,
+				xlr_board_fmn_config.bucket_size,
+				&xlr_board_fmn_config.gmac[0],
+				/* PHY address according to chip/board */
+				mac + 0x10,
+				xlr_net_res[mac]);
+
+			net_device_init(mac, xlr_net_res[mac]);
+			platform_device_register(&xlr_net_dev[mac]);
+		}
+
+		for (mac = 4; mac < MAX_NUM_XLS_GMAC; mac++) {
+			config_mac(mac,
+				PHY_INTERFACE_MODE_SGMII,
+				NETLOGIC_IO_GMAC_0_OFFSET,  /* mii */
+				NETLOGIC_IO_GMAC_4_OFFSET,  /* serdes */
+				NETLOGIC_IO_GMAC_4_OFFSET,  /* pcs */
+				FMN_STNID_GMAC1_FR_0,
+				FMN_STNID_GMAC1_TX0 + mac - 4,
+				xlr_board_fmn_config.bucket_size,
+				&xlr_board_fmn_config.gmac[1],
+				/* PHY address according to chip/board */
+				mac + 0x10,
+				xlr_net_res[mac]);
+
+			net_device_init(mac, xlr_net_res[mac]);
+			platform_device_register(&xlr_net_dev[mac]);
+		}
+	}
+}
+
+static void gmac_init_xlr(void)
+{
+	int mac;
+
+	/* assume all GMACs for now */
+	for (mac = 0; mac < MAX_NUM_XLR_GMAC; mac++) {
+		config_mac(mac,
+			PHY_INTERFACE_MODE_RGMII,
+			NETLOGIC_IO_GMAC_0_OFFSET,
+			0,
+			0,
+			FMN_STNID_GMACRFR_0,
+			FMN_STNID_GMAC0_TX0,
+			xlr_board_fmn_config.bucket_size,
+			&xlr_board_fmn_config.gmac[0],
+			mac,
+			xlr_net_res[mac]);
+		net_device_init(mac, xlr_net_res[mac]);
+		platform_device_register(&xlr_net_dev[mac]);
+	}
+}
+
+static int __init xlr_net_init(void)
+{
+
+	if (nlm_chip_is_xls())
+		gmac_init_xls();
+	else
+		gmac_init_xlr();
+
+	return 0;
+}
+
+arch_initcall(xlr_net_init);
-- 
1.7.6
