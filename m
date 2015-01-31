From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next v4] Add support of Cavium Liquidio ethernet adapters
Date: Fri, 30 Jan 2015 18:29:38 -0800
Message-ID: <1422671378-1300-1-git-send-email-rvatsavayi@caviumnetworks.com>
References: <BY2PR07MB486D1ABE6E149FC2FE06217FE680@BY2PR07MB486.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0076.outbound.protection.outlook.com ([157.56.110.76]:44154
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753422AbbAaCtc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2015 21:49:32 -0500
In-Reply-To: <BY2PR07MB486D1ABE6E149FC2FE06217FE680@BY2PR07MB486.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds support for Cavium Liquidio ethernet adapter.
LiquidIO adapters are pci express based 10Gig server adapters.

This patch v4 has changes based on the feedback from earlier patches:
1) Added mmiowb while synchronizing queue updates and other hw interactions.
2) Statistics will now be incremented non-atomically per each ring.
   liquidio_get_stats will add stats of each ring while reporting the
   total statistics counts.
3) Modified liquidio_ioctl  to return proper return codes.
4) Modified device naming to use standard Ethernet naming.
5) Global function names in the driver will have lio_/liquidio_/octeon_
   prefix.
6) Ethtool related changes for:
   Removed redundant stats and jiffies.
   Use default ethtool handler of link status.
   Speed setting will make use of ethtool_cmd_speed_set.
7) Added checks for pci_map_*  return codes.
8) Check for signals while waiting in interruptible mode

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 MAINTAINERS                                        |   11 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/cavium/Kconfig                |   27 +
 drivers/net/ethernet/cavium/Makefile               |    5 +
 drivers/net/ethernet/cavium/liquidio/Makefile      |   16 +
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  767 ++++
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |   67 +
 drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h |  524 +++
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   |  791 ++++
 .../net/ethernet/cavium/liquidio/cn68xx_device.h   |   57 +
 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h |  505 +++
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 1488 ++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 3933 ++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  597 +++
 .../net/ethernet/cavium/liquidio/liquidio_image.h  |   60 +
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  402 ++
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  713 ++++
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 1222 ++++++
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  705 ++++
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 1075 ++++++
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  433 +++
 drivers/net/ethernet/cavium/liquidio/octeon_hw.h   |   57 +
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  274 ++
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  253 ++
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |  201 +
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.h  |   77 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  307 ++
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  218 ++
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |  218 ++
 .../net/ethernet/cavium/liquidio/request_manager.c |  637 ++++
 .../ethernet/cavium/liquidio/response_manager.c    |  272 ++
 .../ethernet/cavium/liquidio/response_manager.h    |  154 +
 33 files changed, 16068 insertions(+)
 create mode 100644 drivers/net/ethernet/cavium/Kconfig
 create mode 100644 drivers/net/ethernet/cavium/Makefile
 create mode 100644 drivers/net/ethernet/cavium/liquidio/Makefile
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_main.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/liquidio_common.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/liquidio_image.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_config.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_console.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_device.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_device.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_droq.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_droq.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_hw.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_iq.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_main.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_network.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_nic.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_nic.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/request_manager.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/response_manager.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/response_manager.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 3c3bf861..0d7b89a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2373,6 +2373,17 @@ F:	security/capability.c
 F:	security/commoncap.c
 F:	kernel/capability.c
 
+CAVIUM LIQUIDIO NETWORK DRIVER
+M:     Derek Chickles <derek.chickles@caviumnetworks.com>
+M:     Satanand Burla <satananda.burla@caviumnetworks.com>
+M:     Felix Manlunas <felix.manlunas@caviumnetworks.com>
+M:     Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
+L:     netdev@vger.kernel.org
+W:     http://www.cavium.com
+S:     Supported
+F:     drivers/net/ethernet/cavium/
+F:     drivers/net/ethernet/cavium/liquidio/
+
 CC2520 IEEE-802.15.4 RADIO DRIVER
 M:	Varka Bhadram <varkabhadram@gmail.com>
 L:	linux-wpan@vger.kernel.org
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index eadcb05..9a83085 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -34,6 +34,7 @@ source "drivers/net/ethernet/adi/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/calxeda/Kconfig"
+source "drivers/net/ethernet/cavium/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cirrus/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 1367afc..4395d99 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_NET_BFIN) += adi/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_CALXEDA_XGMAC) += calxeda/
+obj-$(CONFIG_NET_VENDOR_CAVIUM) += cavium/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CIRRUS) += cirrus/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
new file mode 100644
index 0000000..9de85ee
--- /dev/null
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -0,0 +1,27 @@
+config NET_VENDOR_CAVIUM
+	bool "Cavium network interface cards"
+	default y
+	---help---
+	  If you have a network interface card from Cavium, say Y.
+
+	  Note that the answer to this question does not directly affect the
+	  kernel: saying N will just cause the configurator to skip all the
+	  the questions regarding Cavium network cards. If you say Y, you will
+	  be asked for your specific driver in the following questions.
+
+if NET_VENDOR_CAVIUM
+
+config LIQUIDIO
+	tristate "Cavium LiquidIO support"
+	depends on PCI
+	select PTP_1588_CLOCK
+	select FW_LOADER
+	select LIBCRC32
+	---help---
+	  This driver supports Cavium LiquidIO Intelligent Server Adapters
+	  based on CN66XX and CN68XX chips.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called liquidio.  This is recommended.
+
+endif # NET_VENDOR_CAVIUM
diff --git a/drivers/net/ethernet/cavium/Makefile b/drivers/net/ethernet/cavium/Makefile
new file mode 100644
index 0000000..1128801
--- /dev/null
+++ b/drivers/net/ethernet/cavium/Makefile
@@ -0,0 +1,5 @@
+#
+# Cavium device configuration
+#
+
+obj-$(CONFIG_LIQUIDIO) += liquidio/
diff --git a/drivers/net/ethernet/cavium/liquidio/Makefile b/drivers/net/ethernet/cavium/liquidio/Makefile
new file mode 100644
index 0000000..2f36680
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/Makefile
@@ -0,0 +1,16 @@
+#
+# Cavium Liquidio ethernet device driver
+#
+obj-$(CONFIG_LIQUIDIO) += liquidio.o
+
+liquidio-objs := lio_main.o  \
+	      lio_ethtool.o      \
+	      request_manager.o  \
+	      response_manager.o \
+	      octeon_device.o    \
+	      cn66xx_device.o    \
+	      cn68xx_device.o    \
+	      octeon_mem_ops.o   \
+	      octeon_droq.o      \
+	      octeon_console.o   \
+	      octeon_nic.o
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
new file mode 100644
index 0000000..73beb9a
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -0,0 +1,767 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "liquidio_image.h"
+#include "octeon_mem_ops.h"
+
+static int cn6xxx_soft_reset(struct octeon_device *oct)
+{
+	octeon_write_csr64(oct, CN66XX_WIN_WR_MASK_REG, 0xFF);
+
+	lio_dev_dbg(oct, "BIST enabled for soft reset\n");
+
+	OCTEON_PCI_WIN_WRITE(oct, CN66XX_CIU_SOFT_BIST, 1);
+	octeon_write_csr64(oct, CN66XX_SLI_SCRATCH1, 0x1234ULL);
+
+	OCTEON_PCI_WIN_READ(oct, CN66XX_CIU_SOFT_RST);
+	OCTEON_PCI_WIN_WRITE(oct, CN66XX_CIU_SOFT_RST, 1);
+
+	/* make sure that the reset is written before starting timer */
+	mmiowb();
+
+	/* Wait for 10ms as Octeon resets. */
+	mdelay(10);
+
+	if (octeon_read_csr64(oct, CN66XX_SLI_SCRATCH1) == 0x1234ULL) {
+		lio_dev_err(oct, "Soft reset failed\n");
+		return 1;
+	}
+
+	lio_dev_dbg(oct, "Reset completed\n");
+	octeon_write_csr64(oct, CN66XX_WIN_WR_MASK_REG, 0xFF);
+
+	return 0;
+}
+
+static void cn6xxx_enable_error_reporting(struct octeon_device *oct)
+{
+	uint32_t val;
+
+	pci_read_config_dword(oct->pci_dev, CN66XX_PCIE_DEVCTL, &val);
+	if (val & 0x000f0000) {
+		lio_dev_err(oct, "PCI-E Link error detected: 0x%08x\n",
+			    val & 0x000f0000);
+	}
+
+	val |= 0xf;          /* Enable Link error reporting */
+
+	lio_dev_dbg(oct, "Enabling PCI-E error reporting..\n");
+	pci_write_config_dword(oct->pci_dev, CN66XX_PCIE_DEVCTL, val);
+}
+
+static void cn6xxx_setup_pcie_mps(struct octeon_device *oct,
+				  enum octeon_pcie_mps mps)
+{
+	uint32_t val;
+	uint64_t r64;
+
+	/* Read config register for MPS */
+	pci_read_config_dword(oct->pci_dev, CN66XX_PCIE_DEVCTL, &val);
+
+	if (mps == PCIE_MPS_DEFAULT) {
+		mps = ((val & (0x7 << 5)) >> 5);
+	} else {
+		val &= ~(0x7 << 5);  /* Turn off any MPS bits */
+		val |= (mps << 5);   /* Set MPS */
+		pci_write_config_dword(oct->pci_dev, CN66XX_PCIE_DEVCTL, val);
+	}
+
+	/* Set MPS in DPI_SLI_PRT0_CFG to the same value. */
+	r64 = OCTEON_PCI_WIN_READ(oct, CN66XX_DPI_SLI_PRTX_CFG(oct->pcie_port));
+	r64 |= (mps << 4);
+	OCTEON_PCI_WIN_WRITE(oct, CN66XX_DPI_SLI_PRTX_CFG(oct->pcie_port), r64);
+}
+
+static void cn6xxx_setup_pcie_mrrs(struct octeon_device *oct,
+				   enum octeon_pcie_mrrs mrrs)
+{
+	uint32_t val;
+	uint64_t r64;
+
+	/* Read config register for MRRS */
+	pci_read_config_dword(oct->pci_dev, CN66XX_PCIE_DEVCTL, &val);
+
+	if (mrrs == PCIE_MRRS_DEFAULT) {
+		mrrs = ((val & (0x7 << 12)) >> 12);
+	} else {
+		val &= ~(0x7 << 12); /* Turn off any MRRS bits */
+		val |= (mrrs << 12); /* Set MRRS */
+		pci_write_config_dword(oct->pci_dev, CN66XX_PCIE_DEVCTL, val);
+	}
+
+	/* Set MRRS in SLI_S2M_PORT0_CTL to the same value. */
+	r64 = octeon_read_csr64(oct, CN66XX_SLI_S2M_PORTX_CTL(oct->pcie_port));
+	r64 |= mrrs;
+	octeon_write_csr64(oct, CN66XX_SLI_S2M_PORTX_CTL(oct->pcie_port), r64);
+
+	/* Set MRRS in DPI_SLI_PRT0_CFG to the same value. */
+	r64 = OCTEON_PCI_WIN_READ(oct, CN66XX_DPI_SLI_PRTX_CFG(oct->pcie_port));
+	r64 |= mrrs;
+	OCTEON_PCI_WIN_WRITE(oct, CN66XX_DPI_SLI_PRTX_CFG(oct->pcie_port), r64);
+}
+
+uint32_t lio_cn6xxx_coprocessor_clock(struct octeon_device *oct)
+{
+	/* Bits 29:24 of MIO_RST_BOOT holds the ref. clock multiplier
+	 * for SLI.
+	 */
+	return ((OCTEON_PCI_WIN_READ(oct, CN6XXX_MIO_RST_BOOT) >> 24) & 0x3f) *
+	       50;
+}
+
+uint32_t lio_cn6xxx_get_oq_ticks(struct octeon_device *oct,
+				 uint32_t time_intr_in_us)
+{
+	/* This gives the SLI clock per microsec */
+	uint32_t oqticks_per_us = lio_cn6xxx_coprocessor_clock(oct);
+
+	/* core clock per us / oq ticks will be fractional. TO avoid that
+	 * we use the method below.
+	 */
+
+	/* This gives the clock cycles per millisecond */
+	oqticks_per_us *= 1000;
+
+	/* This gives the oq ticks (1024 core clock cycles) per millisecond */
+	oqticks_per_us /= 1024;
+
+	/* time_intr is in microseconds. The next 2 steps gives the oq ticks
+	 * corressponding to time_intr.
+	 */
+	oqticks_per_us *= time_intr_in_us;
+	oqticks_per_us /= 1000;
+
+	return oqticks_per_us;
+}
+
+static void cn6xxx_setup_global_input_regs(struct octeon_device *oct)
+{
+	/* Select Round-Robin Arb, ES, RO, NS for Input Queues */
+	octeon_write_csr(oct, CN66XX_SLI_PKT_INPUT_CONTROL,
+			 CN66XX_INPUT_CTL_MASK);
+
+	/* Instruction Read Size - Max 4 instructions per PCIE Read */
+	octeon_write_csr64(oct, CN66XX_SLI_PKT_INSTR_RD_SIZE,
+			   0xFFFFFFFFFFFFFFFFULL);
+
+	/* Select PCIE Port for all Input rings. */
+	octeon_write_csr64(oct, CN66XX_SLI_IN_PCIE_PORT,
+			   (oct->pcie_port * 0x5555555555555555ULL));
+}
+
+static void cn6xxx_setup_global_output_regs(struct octeon_device *oct)
+{
+	uint32_t time_threshold;
+	uint64_t pktctl;
+
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
+
+	pktctl = octeon_read_csr64(oct, CN66XX_SLI_PKT_CTL);
+
+	if (CFG_GET_OQ_MAX_Q(cn6xxx->conf) <= 4)
+		/* Disable RING_EN if only upto 4 rings are used. */
+		pktctl &= ~(1 << 4);
+	else
+		pktctl |= (1 << 4);
+
+	if (CFG_GET_IS_SLI_BP_ON(cn6xxx->conf))
+		pktctl |= 0xF;
+	else
+		/* Disable per-port backpressure. */
+		pktctl &= ~0xF;
+	octeon_write_csr64(oct, CN66XX_SLI_PKT_CTL, pktctl);
+
+	/* / Select PCI-E Port for all Output queues */
+	octeon_write_csr64(oct, CN66XX_SLI_PKT_PCIE_PORT64,
+			   (oct->pcie_port * 0x5555555555555555ULL));
+
+	if (CFG_GET_IS_SLI_BP_ON(cn6xxx->conf)) {
+		octeon_write_csr64(oct, CN66XX_SLI_OQ_WMARK, 32);
+	} else {
+		/* / Set Output queue watermark to 0 to disable backpressure */
+		octeon_write_csr64(oct, CN66XX_SLI_OQ_WMARK, 0);
+	}
+
+	/* / Select Info Ptr for length & data */
+	octeon_write_csr(oct, CN66XX_SLI_PKT_IPTR, 0xFFFFFFFF);
+
+	/* / Select Packet count instead of bytes for SLI_PKTi_CNTS[CNT] */
+	octeon_write_csr(oct, CN66XX_SLI_PKT_OUT_BMODE, 0);
+
+	/* / Select ES,RO,NS setting from register for Output Queue Packet
+	 * Address
+	 */
+	octeon_write_csr(oct, CN66XX_SLI_PKT_DPADDR, 0xFFFFFFFF);
+
+	/* No Relaxed Ordering, No Snoop, 64-bit swap for Output
+	 * Queue ScatterList
+	 */
+	octeon_write_csr(oct, CN66XX_SLI_PKT_SLIST_ROR, 0);
+	octeon_write_csr(oct, CN66XX_SLI_PKT_SLIST_NS, 0);
+
+	/* / ENDIAN_SPECIFIC CHANGES - 0 works for LE. */
+#ifdef __BIG_ENDIAN_BITFIELD
+	octeon_write_csr64(oct, CN66XX_SLI_PKT_SLIST_ES64,
+			   0x5555555555555555ULL);
+#else
+	octeon_write_csr64(oct, CN66XX_SLI_PKT_SLIST_ES64, 0ULL);
+#endif
+
+	/* / No Relaxed Ordering, No Snoop, 64-bit swap for Output Queue Data */
+	octeon_write_csr(oct, CN66XX_SLI_PKT_DATA_OUT_ROR, 0);
+	octeon_write_csr(oct, CN66XX_SLI_PKT_DATA_OUT_NS, 0);
+	octeon_write_csr64(oct, CN66XX_SLI_PKT_DATA_OUT_ES64,
+			   0x5555555555555555ULL);
+
+	/* / Set up interrupt packet and time threshold */
+	octeon_write_csr(oct, CN66XX_SLI_OQ_INT_LEVEL_PKTS,
+			 (uint32_t)CFG_GET_OQ_INTR_PKT(cn6xxx->conf));
+	time_threshold =
+		lio_cn6xxx_get_oq_ticks(oct, (uint32_t)
+				    CFG_GET_OQ_INTR_TIME(cn6xxx->conf));
+
+	octeon_write_csr(oct, CN66XX_SLI_OQ_INT_LEVEL_TIME, time_threshold);
+}
+
+static int cn6xxx_setup_device_regs(struct octeon_device *oct)
+{
+	cn6xxx_setup_pcie_mps(oct, PCIE_MPS_DEFAULT);
+	cn6xxx_setup_pcie_mrrs(oct, PCIE_MRRS_512B);
+
+	cn6xxx_enable_error_reporting(oct);
+
+	cn6xxx_setup_global_input_regs(oct);
+	cn6xxx_setup_global_output_regs(oct);
+
+	/* Default error timeout value should be 0x200000 to avoid host hang
+	 * when reads invalid register
+	 */
+	octeon_write_csr64(oct, CN66XX_SLI_WINDOW_CTL, 0x200000ULL);
+	return 0;
+}
+
+static void cn6xxx_setup_iq_regs(struct octeon_device *oct, uint32_t iq_no)
+{
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
+
+	/* Disable Packet-by-Packet mode; No Parse Mode or Skip length */
+	octeon_write_csr64(oct, CN66XX_SLI_IQ_PKT_INSTR_HDR64(iq_no), 0);
+
+	/* Write the start of the input queue's ring and its size  */
+	octeon_write_csr64(oct, CN66XX_SLI_IQ_BASE_ADDR64(iq_no),
+			   iq->base_addr_dma);
+	octeon_write_csr(oct, CN66XX_SLI_IQ_SIZE(iq_no), iq->max_count);
+
+	/* Remember the doorbell & instruction count register addr for this
+	 * queue
+	 */
+	iq->doorbell_reg = oct->mmio[0].hw_addr + CN66XX_SLI_IQ_DOORBELL(iq_no);
+	iq->inst_cnt_reg = oct->mmio[0].hw_addr
+			   + CN66XX_SLI_IQ_INSTR_COUNT(iq_no);
+	lio_dev_dbg(oct, "InstQ[%d]:dbell reg @ 0x%p instcnt_reg @ 0x%p\n",
+		    iq_no, iq->doorbell_reg, iq->inst_cnt_reg);
+
+	/* Store the current instruction counter
+	 * (used in flush_iq calculation)
+	 */
+	iq->reset_instr_cnt = readl(iq->inst_cnt_reg);
+
+	/* Backpressure for this queue - WMARK set to all F's. This effectively
+	 * disables the backpressure mechanism.
+	 */
+	octeon_write_csr64(oct, CN66XX_SLI_IQ_BP64(iq_no),
+			   (0xFFFFFFFFULL << 32));
+}
+
+static void cn6xxx_setup_oq_regs(struct octeon_device *oct, uint32_t oq_no)
+{
+	uint32_t intr;
+	struct octeon_droq *droq = oct->droq[oq_no];
+
+	octeon_write_csr64(oct, CN66XX_SLI_OQ_BASE_ADDR64(oq_no),
+			   droq->desc_ring_dma);
+	octeon_write_csr(oct, CN66XX_SLI_OQ_SIZE(oq_no), droq->max_count);
+
+	octeon_write_csr(oct, CN66XX_SLI_OQ_BUFF_INFO_SIZE(oq_no),
+			 (droq->buffer_size | (OCT_RH_SIZE << 16)));
+
+	/* Get the mapped address of the pkt_sent and pkts_credit regs */
+	droq->pkts_sent_reg =
+		oct->mmio[0].hw_addr + CN66XX_SLI_OQ_PKTS_SENT(oq_no);
+	droq->pkts_credit_reg =
+		oct->mmio[0].hw_addr + CN66XX_SLI_OQ_PKTS_CREDIT(oq_no);
+
+	/* Enable this output queue to generate Packet Timer Interrupt */
+	intr = octeon_read_csr(oct, CN66XX_SLI_PKT_TIME_INT_ENB);
+	intr |= (1 << oq_no);
+	octeon_write_csr(oct, CN66XX_SLI_PKT_TIME_INT_ENB, intr);
+
+	/* Enable this output queue to generate Packet Timer Interrupt */
+	intr = octeon_read_csr(oct, CN66XX_SLI_PKT_CNT_INT_ENB);
+	intr |= (1 << oq_no);
+	octeon_write_csr(oct, CN66XX_SLI_PKT_CNT_INT_ENB, intr);
+}
+
+static void cn6xxx_enable_io_queues(struct octeon_device *oct)
+{
+	octeon_write_csr(oct, CN66XX_SLI_PKT_INSTR_SIZE, oct->io_qmask.iq64B);
+	octeon_write_csr(oct, CN66XX_SLI_PKT_INSTR_ENB, oct->io_qmask.iq);
+	octeon_write_csr(oct, CN66XX_SLI_PKT_OUT_ENB, oct->io_qmask.oq);
+}
+
+static void cn6xxx_disable_io_queues(struct octeon_device *oct)
+{
+	uint32_t mask, i, loop = HZ;
+	uint32_t d32;
+
+	/* Reset the Enable bits for Input Queues. */
+	octeon_write_csr(oct, CN66XX_SLI_PKT_INSTR_ENB, 0);
+
+	/* Wait until hardware indicates that the queues are out of reset. */
+	mask = oct->io_qmask.iq;
+	d32 = octeon_read_csr(oct, CN66XX_SLI_PORT_IN_RST_IQ);
+	while (((d32 & mask) != mask) && loop--) {
+		d32 = octeon_read_csr(oct, CN66XX_SLI_PORT_IN_RST_IQ);
+		schedule_timeout_uninterruptible(1);
+	}
+
+	/* Reset the doorbell register for each Input queue. */
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+		if (!(oct->io_qmask.iq & (1UL << i)))
+			continue;
+		octeon_write_csr(oct, CN66XX_SLI_IQ_DOORBELL(i), 0xFFFFFFFF);
+		d32 = octeon_read_csr(oct, CN66XX_SLI_IQ_DOORBELL(i));
+	}
+
+	/* Reset the Enable bits for Output Queues. */
+	octeon_write_csr(oct, CN66XX_SLI_PKT_OUT_ENB, 0);
+
+	/* Wait until hardware indicates that the queues are out of reset. */
+	loop = HZ;
+	mask = oct->io_qmask.oq;
+	d32 = octeon_read_csr(oct, CN66XX_SLI_PORT_IN_RST_OQ);
+	while (((d32 & mask) != mask) && loop--) {
+		d32 = octeon_read_csr(oct, CN66XX_SLI_PORT_IN_RST_OQ);
+		schedule_timeout_uninterruptible(1);
+	}
+	;
+
+	/* Reset the doorbell register for each Output queue. */
+	/* for (i = 0; i < oct->num_oqs; i++) { */
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct->io_qmask.oq & (1UL << i)))
+			continue;
+		octeon_write_csr(oct, CN66XX_SLI_OQ_PKTS_CREDIT(i), 0xFFFFFFFF);
+		d32 = octeon_read_csr(oct, CN66XX_SLI_OQ_PKTS_CREDIT(i));
+
+		d32 = octeon_read_csr(oct, CN66XX_SLI_OQ_PKTS_SENT(i));
+		octeon_write_csr(oct, CN66XX_SLI_OQ_PKTS_SENT(i), d32);
+	}
+
+	d32 = octeon_read_csr(oct, CN66XX_SLI_PKT_CNT_INT);
+	if (d32)
+		octeon_write_csr(oct, CN66XX_SLI_PKT_CNT_INT, d32);
+
+	d32 = octeon_read_csr(oct, CN66XX_SLI_PKT_TIME_INT);
+	if (d32)
+		octeon_write_csr(oct, CN66XX_SLI_PKT_TIME_INT, d32);
+}
+
+static void cn6xxx_reinit_regs(struct octeon_device *oct)
+{
+	uint32_t i;
+
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++)
+		if (!(oct->io_qmask.iq & (1UL << i)))
+			continue;
+
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct->io_qmask.oq & (1UL << i)))
+			continue;
+		oct->fn_list.setup_oq_regs(oct, i);
+	}
+
+	oct->fn_list.setup_device_regs(oct);
+
+	oct->fn_list.enable_interrupt(oct->chip);
+
+	oct->fn_list.enable_io_queues(oct);
+
+	/* for (i = 0; i < oct->num_oqs; i++) { */
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct->io_qmask.oq & (1UL << i)))
+			continue;
+		writel(oct->droq[i]->max_count, oct->droq[i]->pkts_credit_reg);
+	}
+}
+
+static void
+cn6xxx_bar1_idx_setup(struct octeon_device *oct,
+		      uint64_t core_addr,
+		      uint32_t idx,
+		      int valid)
+{
+	uint64_t bar1;
+
+	if (valid == 0) {
+		bar1 = OCTEON_PCI_WIN_READ(oct, CN66XX_BAR1_INDEX_REG(idx));
+		OCTEON_PCI_WIN_WRITE(oct, CN66XX_BAR1_INDEX_REG(idx),
+				     (bar1 & 0xFFFFFFFEULL));
+		bar1 = OCTEON_PCI_WIN_READ(oct, CN66XX_BAR1_INDEX_REG(idx));
+		return;
+	}
+
+	/* Bits 17:4 of the PCI_BAR1_INDEXx stores bits 35:22 of
+	 * the Core Addr
+	 */
+	OCTEON_PCI_WIN_WRITE(oct, CN66XX_BAR1_INDEX_REG(idx),
+			     (((core_addr >> 22) << 4) | PCI_BAR1_MASK));
+
+	bar1 = OCTEON_PCI_WIN_READ(oct, CN66XX_BAR1_INDEX_REG(idx));
+}
+
+static void cn6xxx_bar1_idx_write(struct octeon_device *oct,
+				  uint32_t idx,
+				  uint32_t mask)
+{
+	OCTEON_PCI_WIN_WRITE(oct, CN66XX_BAR1_INDEX_REG(idx), mask);
+}
+
+static uint32_t cn6xxx_bar1_idx_read(struct octeon_device *oct, uint32_t idx)
+{
+	return (uint32_t)OCTEON_PCI_WIN_READ(oct, CN66XX_BAR1_INDEX_REG(idx));
+}
+
+static uint32_t cn6xxx_update_read_index(struct octeon_instr_queue *iq)
+{
+	uint32_t new_idx = readl(iq->inst_cnt_reg);
+
+	/* The new instr cnt reg is a 32-bit counter that can roll over. We have
+	 * noted the counter's initial value at init time into
+	 * reset_instr_cnt
+	 */
+	if (iq->reset_instr_cnt < new_idx)
+		new_idx -= iq->reset_instr_cnt;
+	else
+		new_idx += (0xffffffff - iq->reset_instr_cnt) + 1;
+
+	/* Modulo of the new index with the IQ size will give us
+	 * the new index.
+	 */
+	new_idx %= iq->max_count;
+
+	return new_idx;
+}
+
+static void cn6xxx_enable_interrupt(void *chip)
+{
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)chip;
+	uint64_t mask = cn6xxx->intr_mask64 | CN66XX_INTR_DMA0_FORCE;
+
+	/* Enable Interrupt */
+	writeq(mask, cn6xxx->intr_enb_reg64);
+}
+
+static void cn6xxx_disable_interrupt(void *chip)
+{
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)chip;
+
+	/* Disable Interrupts */
+	writeq(0, cn6xxx->intr_enb_reg64);
+
+	/* make sure interrupts are really disabled */
+	mmiowb();
+}
+
+static void cn6xxx_get_pcie_qlmport(struct octeon_device *oct)
+{
+	/* CN63xx Pass2 and newer parts implements the SLI_MAC_NUMBER register
+	 * to determine the PCIE port #
+	 */
+	oct->pcie_port = octeon_read_csr(oct, CN66XX_SLI_MAC_NUMBER) & 0xff;
+
+	lio_dev_dbg(oct, "Using PCIE Port %d\n", oct->pcie_port);
+}
+
+static void
+cn6xxx_process_pcie_error_intr(struct octeon_device *oct, uint64_t intr64)
+{
+	lio_dev_err(oct, "Error Intr: 0x%016llx\n", CVM_CAST64(intr64));
+}
+
+static int cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
+{
+	struct octeon_droq *droq;
+	uint32_t oq_no, pkt_count;
+	uint32_t droq_time_mask, droq_mask, droq_int_enb, droq_cnt_enb;
+	uint32_t droq_cnt_mask;
+
+	droq_cnt_enb = octeon_read_csr(oct, CN66XX_SLI_PKT_CNT_INT_ENB);
+	droq_cnt_mask = octeon_read_csr(oct, CN66XX_SLI_PKT_CNT_INT);
+	droq_mask = droq_cnt_mask & droq_cnt_enb;
+
+	droq_time_mask = octeon_read_csr(oct, CN66XX_SLI_PKT_TIME_INT);
+	droq_int_enb = octeon_read_csr(oct, CN66XX_SLI_PKT_TIME_INT_ENB);
+	droq_mask |= (droq_time_mask & droq_int_enb);
+
+	oct->droq_intr = 0;
+
+	/* for (oq_no = 0; oq_no < oct->num_oqs; oq_no++) { */
+	for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES; oq_no++) {
+		if (!(droq_mask & (1 << oq_no)))
+			continue;
+
+		droq = oct->droq[oq_no];
+		pkt_count = octeon_droq_check_hw_for_pkts(oct, droq);
+		if (pkt_count) {
+			oct->droq_intr |= (1ULL << oq_no);
+			if (droq->ops.poll_mode) {
+				uint32_t value;
+				uint32_t reg;
+
+				struct octeon_cn6xxx *cn6xxx =
+					(struct octeon_cn6xxx *)oct->chip;
+
+				/* disable interrupts for this droq */
+				spin_lock
+					(&cn6xxx->lock_for_droq_int_enb_reg);
+				reg = CN66XX_SLI_PKT_TIME_INT_ENB;
+				value = octeon_read_csr(oct, reg);
+				value &= ~(1 << oq_no);
+				octeon_write_csr(oct, reg, value);
+				reg = CN66XX_SLI_PKT_CNT_INT_ENB;
+				value = octeon_read_csr(oct, reg);
+				value &= ~(1 << oq_no);
+				octeon_write_csr(oct, reg, value);
+
+				/* Ensure that the enable register is written.
+				 */
+				mmiowb();
+
+				spin_unlock(&cn6xxx->lock_for_droq_int_enb_reg);
+			}
+		}
+	}
+
+	/* Reset the PKT_CNT/TIME_INT registers. */
+	if (droq_time_mask)
+		octeon_write_csr(oct, CN66XX_SLI_PKT_TIME_INT, droq_time_mask);
+
+	if (droq_cnt_mask)      /* reset PKT_CNT register:66xx */
+		octeon_write_csr(oct, CN66XX_SLI_PKT_CNT_INT, droq_cnt_mask);
+
+	return 0;
+}
+
+static irqreturn_t cn6xxx_process_interrupt_regs(void *dev)
+{
+	struct octeon_device *oct = (struct octeon_device *)dev;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
+	uint64_t intr64;
+
+	intr64 = readq(cn6xxx->intr_sum_reg64);
+
+	/* If our device has interrupted, then proceed.
+	 * Also check for all f's if interrupt was triggered on an error
+	 * and the PCI read fails.
+	 */
+	if (!intr64 || (intr64 == 0xFFFFFFFFFFFFFFFFULL))
+		return IRQ_NONE;
+
+	atomic_set(&oct->in_interrupt, 1);
+
+	oct->stats.interrupts++;
+
+	atomic_inc(&oct->interrupts);
+
+	oct->int_status = 0;
+
+	if (intr64 & CN66XX_INTR_ERR)
+		cn6xxx_process_pcie_error_intr(oct, intr64);
+
+	if (intr64 & CN66XX_INTR_PKT_DATA) {
+		cn6xxx_process_droq_intr_regs(oct);
+		oct->int_status |= OCT_DEV_INTR_PKT_DATA;
+	}
+
+	if (intr64 & CN66XX_INTR_DMA0_FORCE)
+		oct->int_status |= OCT_DEV_INTR_DMA0_FORCE;
+
+	if (intr64 & CN66XX_INTR_DMA1_FORCE)
+		oct->int_status |= OCT_DEV_INTR_DMA1_FORCE;
+
+	/* Clear the current interrupts */
+	writeq(intr64, cn6xxx->intr_sum_reg64);
+
+	atomic_set(&oct->in_interrupt, 0);
+
+	return IRQ_HANDLED;
+}
+
+static void cn6xxx_setup_reg_address(struct octeon_device *oct)
+{
+	uint8_t __iomem *bar0_pciaddr = oct->mmio[0].hw_addr;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
+
+	oct->reg_list.pci_win_wr_addr_hi =
+		(uint32_t __iomem *)(bar0_pciaddr + CN66XX_WIN_WR_ADDR_HI);
+	oct->reg_list.pci_win_wr_addr_lo =
+		(uint32_t __iomem *)(bar0_pciaddr + CN66XX_WIN_WR_ADDR_LO);
+	oct->reg_list.pci_win_wr_addr =
+		(uint64_t __iomem *)(bar0_pciaddr + CN66XX_WIN_WR_ADDR64);
+
+	oct->reg_list.pci_win_rd_addr_hi =
+		(uint32_t __iomem *)(bar0_pciaddr + CN66XX_WIN_RD_ADDR_HI);
+	oct->reg_list.pci_win_rd_addr_lo =
+		(uint32_t __iomem *)(bar0_pciaddr + CN66XX_WIN_RD_ADDR_LO);
+	oct->reg_list.pci_win_rd_addr =
+		(uint64_t __iomem *)(bar0_pciaddr + CN66XX_WIN_RD_ADDR64);
+
+	oct->reg_list.pci_win_wr_data_hi =
+		(uint32_t __iomem *)(bar0_pciaddr + CN66XX_WIN_WR_DATA_HI);
+	oct->reg_list.pci_win_wr_data_lo =
+		(uint32_t __iomem *)(bar0_pciaddr + CN66XX_WIN_WR_DATA_LO);
+	oct->reg_list.pci_win_wr_data =
+		(uint64_t __iomem *)(bar0_pciaddr + CN66XX_WIN_WR_DATA64);
+
+	oct->reg_list.pci_win_rd_data_hi =
+		(uint32_t __iomem *)(bar0_pciaddr + CN66XX_WIN_RD_DATA_HI);
+	oct->reg_list.pci_win_rd_data_lo =
+		(uint32_t __iomem *)(bar0_pciaddr + CN66XX_WIN_RD_DATA_LO);
+	oct->reg_list.pci_win_rd_data =
+		(uint64_t __iomem *)(bar0_pciaddr + CN66XX_WIN_RD_DATA64);
+
+	cn6xxx_get_pcie_qlmport(oct);
+
+	cn6xxx->intr_sum_reg64 = bar0_pciaddr + CN66XX_SLI_INT_SUM64;
+	cn6xxx->intr_mask64 = CN66XX_INTR_MASK;
+	cn6xxx->intr_enb_reg64 =
+		bar0_pciaddr + CN66XX_SLI_INT_ENB64(oct->pcie_port);
+}
+
+int lio_setup_cn66xx_octeon_device(struct octeon_device *oct)
+{
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
+
+	if (octeon_map_pci_barx(oct, 0, 0))
+		return 1;
+
+	if (octeon_map_pci_barx(oct, 1, MAX_BAR1_IOREMAP_SIZE)) {
+		lio_dev_err(oct, "%s CN66XX BAR1 map failed\n", __func__);
+		octeon_unmap_pci_barx(oct, 0);
+		return 1;
+	}
+
+	cn6xxx->conf = (struct octeon_config *)oct_get_config_info(oct);
+	if (!cn6xxx->conf) {
+		lio_dev_err(oct, "%s No Config found for CN66XX\n", __func__);
+		octeon_unmap_pci_barx(oct, 0);
+		octeon_unmap_pci_barx(oct, 1);
+		return 1;
+	}
+
+	spin_lock_init(&cn6xxx->lock_for_droq_int_enb_reg);
+
+	oct->fn_list.setup_iq_regs = cn6xxx_setup_iq_regs;
+	oct->fn_list.setup_oq_regs = cn6xxx_setup_oq_regs;
+
+	oct->fn_list.soft_reset = cn6xxx_soft_reset;
+	oct->fn_list.setup_device_regs = cn6xxx_setup_device_regs;
+	oct->fn_list.reinit_regs = cn6xxx_reinit_regs;
+	oct->fn_list.update_iq_read_idx = cn6xxx_update_read_index;
+
+	oct->fn_list.bar1_idx_setup = cn6xxx_bar1_idx_setup;
+	oct->fn_list.bar1_idx_write = cn6xxx_bar1_idx_write;
+	oct->fn_list.bar1_idx_read = cn6xxx_bar1_idx_read;
+
+	oct->fn_list.process_interrupt_regs = cn6xxx_process_interrupt_regs;
+	oct->fn_list.enable_interrupt = cn6xxx_enable_interrupt;
+	oct->fn_list.disable_interrupt = cn6xxx_disable_interrupt;
+
+	oct->fn_list.enable_io_queues = cn6xxx_enable_io_queues;
+	oct->fn_list.disable_io_queues = cn6xxx_disable_io_queues;
+
+	cn6xxx_setup_reg_address(oct);
+
+	oct->coproc_clock_rate = 1000000ULL * lio_cn6xxx_coprocessor_clock(oct);
+
+	return 0;
+}
+
+int lio_validate_cn66xx_config_info(struct octeon_device *oct,
+				    struct octeon_config *conf66xx)
+{
+	/* int total_instrs = 0; */
+
+	if (CFG_GET_IQ_MAX_Q(conf66xx) > CN6XXX_MAX_INPUT_QUEUES) {
+		lio_dev_err(oct, "%s: Num IQ (%d) exceeds Max (%d)\n",
+			    __func__, CFG_GET_IQ_MAX_Q(conf66xx),
+			    CN6XXX_MAX_INPUT_QUEUES);
+		return 1;
+	}
+
+	if (CFG_GET_OQ_MAX_Q(conf66xx) > CN6XXX_MAX_OUTPUT_QUEUES) {
+		lio_dev_err(oct, "%s: Num OQ (%d) exceeds Max (%d)\n",
+			    __func__, CFG_GET_OQ_MAX_Q(conf66xx),
+			    CN6XXX_MAX_OUTPUT_QUEUES);
+		return 1;
+	}
+
+	if (CFG_GET_IQ_INSTR_TYPE(conf66xx) != OCTEON_32BYTE_INSTR &&
+	    CFG_GET_IQ_INSTR_TYPE(conf66xx) != OCTEON_64BYTE_INSTR) {
+		lio_dev_err(oct, "%s: Invalid instr type for IQ\n",
+			    __func__);
+		return 1;
+	}
+	if (!(CFG_GET_OQ_INFO_PTR(conf66xx)) ||
+	    !(CFG_GET_OQ_REFILL_THRESHOLD(conf66xx))) {
+		lio_dev_err(oct, "%s: Invalid parameter for OQ\n",
+			    __func__);
+		return 1;
+	}
+
+	if (!(CFG_GET_OQ_INTR_TIME(conf66xx))) {
+		lio_dev_err(oct, "%s: No Time Interrupt for OQ\n",
+			    __func__);
+		return 1;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
new file mode 100644
index 0000000..8c5bf68
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
@@ -0,0 +1,67 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/*! \file  cn66xx_device.h
+ *  \brief Host Driver: Routines that perform CN66XX specific operations.
+ */
+
+#ifndef __CN66XX_DEVICE_H__
+#define  __CN66XX_DEVICE_H__
+
+/* Register address and configuration for a CN6XXX devices.
+ * If device specific changes need to be made then add a struct to include
+ * device specific fields as shown in the commented section
+ */
+struct octeon_cn6xxx {
+	/** PCI interrupt summary register */
+	uint8_t __iomem *intr_sum_reg64;
+
+	/** PCI interrupt enable register */
+	uint8_t __iomem *intr_enb_reg64;
+
+	/** The PCI interrupt mask used by interrupt handler */
+	uint64_t intr_mask64;
+
+	struct octeon_config *conf;
+
+	/* Example additional fields - not used currently
+	 *  struct {
+	 *  }cn6xyz;
+	 */
+
+	/* For the purpose of atomic access to interrupt enable reg */
+	spinlock_t lock_for_droq_int_enb_reg;
+
+};
+
+uint32_t lio_cn6xxx_coprocessor_clock(struct octeon_device *oct);
+
+uint32_t lio_cn6xxx_get_oq_ticks(struct octeon_device *oct,
+				 uint32_t time_intr_in_us);
+
+int lio_setup_cn66xx_octeon_device(struct octeon_device *);
+
+int lio_validate_cn66xx_config_info(struct octeon_device *oct,
+				    struct octeon_config *);
+
+int cn6xxx_ptp_init(struct octeon_device *oct);
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
new file mode 100644
index 0000000..41ae290
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
@@ -0,0 +1,524 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/*! \file cn66xx_regs.h
+ *  \brief Host Driver: Register Address and Register Mask values for
+ *  Octeon CN66XX devices.
+ */
+
+#ifndef __CN66XX_REGS_H__
+#define __CN66XX_REGS_H__
+
+#define     CN66XX_XPANSION_BAR             0x30
+
+#define     CN66XX_MSI_CAP                  0x50
+#define     CN66XX_MSI_ADDR_LO              0x54
+#define     CN66XX_MSI_ADDR_HI              0x58
+#define     CN66XX_MSI_DATA                 0x5C
+
+#define     CN66XX_PCIE_CAP                 0x70
+#define     CN66XX_PCIE_DEVCAP              0x74
+#define     CN66XX_PCIE_DEVCTL              0x78
+#define     CN66XX_PCIE_LINKCAP             0x7C
+#define     CN66XX_PCIE_LINKCTL             0x80
+#define     CN66XX_PCIE_SLOTCAP             0x84
+#define     CN66XX_PCIE_SLOTCTL             0x88
+
+#define     CN66XX_PCIE_ENH_CAP             0x100
+#define     CN66XX_PCIE_UNCORR_ERR_STATUS   0x104
+#define     CN66XX_PCIE_UNCORR_ERR_MASK     0x108
+#define     CN66XX_PCIE_UNCORR_ERR          0x10C
+#define     CN66XX_PCIE_CORR_ERR_STATUS     0x110
+#define     CN66XX_PCIE_CORR_ERR_MASK       0x114
+#define     CN66XX_PCIE_ADV_ERR_CAP         0x118
+
+#define     CN66XX_PCIE_ACK_REPLAY_TIMER    0x700
+#define     CN66XX_PCIE_OTHER_MSG           0x704
+#define     CN66XX_PCIE_PORT_FORCE_LINK     0x708
+#define     CN66XX_PCIE_ACK_FREQ            0x70C
+#define     CN66XX_PCIE_PORT_LINK_CTL       0x710
+#define     CN66XX_PCIE_LANE_SKEW           0x714
+#define     CN66XX_PCIE_SYM_NUM             0x718
+
+/* ##############  BAR0 Registers ################  */
+
+#define    CN66XX_SLI_CTL_PORT0                    0x0050
+#define    CN66XX_SLI_CTL_PORT1                    0x0060
+
+#define    CN66XX_SLI_WINDOW_CTL                   0x02E0
+#define    CN66XX_SLI_DBG_DATA                     0x0310
+#define    CN66XX_SLI_SCRATCH1                     0x03C0
+#define    CN66XX_SLI_SCRATCH2                     0x03D0
+#define    CN66XX_SLI_CTL_STATUS                   0x0570
+
+#define    CN66XX_WIN_WR_ADDR_LO                   0x0000
+#define    CN66XX_WIN_WR_ADDR_HI                   0x0004
+#define    CN66XX_WIN_WR_ADDR64                    CN66XX_WIN_WR_ADDR_LO
+
+#define    CN66XX_WIN_RD_ADDR_LO                   0x0010
+#define    CN66XX_WIN_RD_ADDR_HI                   0x0014
+#define    CN66XX_WIN_RD_ADDR64                    CN66XX_WIN_RD_ADDR_LO
+
+#define    CN66XX_WIN_WR_DATA_LO                   0x0020
+#define    CN66XX_WIN_WR_DATA_HI                   0x0024
+#define    CN66XX_WIN_WR_DATA64                    CN66XX_WIN_WR_DATA_LO
+
+#define    CN66XX_WIN_RD_DATA_LO                   0x0040
+#define    CN66XX_WIN_RD_DATA_HI                   0x0044
+#define    CN66XX_WIN_RD_DATA64                    CN66XX_WIN_RD_DATA_LO
+
+#define    CN66XX_WIN_WR_MASK_LO                   0x0030
+#define    CN66XX_WIN_WR_MASK_HI                   0x0034
+#define    CN66XX_WIN_WR_MASK_REG                  CN66XX_WIN_WR_MASK_LO
+
+/* 1 register (32-bit) to enable Input queues */
+#define    CN66XX_SLI_PKT_INSTR_ENB               0x1000
+
+/* 1 register (32-bit) to enable Output queues */
+#define    CN66XX_SLI_PKT_OUT_ENB                 0x1010
+
+/* 1 register (32-bit) to determine whether Output queues are in reset. */
+#define    CN66XX_SLI_PORT_IN_RST_OQ              0x11F0
+
+/* 1 register (32-bit) to determine whether Input queues are in reset. */
+#define    CN66XX_SLI_PORT_IN_RST_IQ              0x11F4
+
+/*###################### REQUEST QUEUE #########################*/
+
+/* 1 register (32-bit) - instr. size of each input queue. */
+#define    CN66XX_SLI_PKT_INSTR_SIZE             0x1020
+
+/* 32 registers for Input Queue Instr Count - SLI_PKT_IN_DONE0_CNTS */
+#define    CN66XX_SLI_IQ_INSTR_COUNT_START       0x2000
+
+/* 32 registers for Input Queue Start Addr - SLI_PKT0_INSTR_BADDR */
+#define    CN66XX_SLI_IQ_BASE_ADDR_START64       0x2800
+
+/* 32 registers for Input Doorbell - SLI_PKT0_INSTR_BAOFF_DBELL */
+#define    CN66XX_SLI_IQ_DOORBELL_START          0x2C00
+
+/* 32 registers for Input Queue size - SLI_PKT0_INSTR_FIFO_RSIZE */
+#define    CN66XX_SLI_IQ_SIZE_START              0x3000
+
+/* 32 registers for Instruction Header Options - SLI_PKT0_INSTR_HEADER */
+#define    CN66XX_SLI_IQ_PKT_INSTR_HDR_START64   0x3400
+
+/* 1 register (64-bit) - Back Pressure for each input queue - SLI_PKT0_IN_BP */
+#define    CN66XX_SLI_INPUT_BP_START64           0x3800
+
+/* Each Input Queue register is at a 16-byte Offset in BAR0 */
+#define    CN66XX_IQ_OFFSET                      0x10
+
+/* 1 register (32-bit) - ES, RO, NS, Arbitration for Input Queue Data &
+ * gather list fetches. SLI_PKT_INPUT_CONTROL.
+ */
+#define    CN66XX_SLI_PKT_INPUT_CONTROL          0x1170
+
+/* 1 register (64-bit) - Number of instructions to read at one time
+ * - 2 bits for each input ring. SLI_PKT_INSTR_RD_SIZE.
+ */
+#define    CN66XX_SLI_PKT_INSTR_RD_SIZE          0x11A0
+
+/* 1 register (64-bit) - Assign Input ring to MAC port
+ * - 2 bits for each input ring. SLI_PKT_IN_PCIE_PORT.
+ */
+#define    CN66XX_SLI_IN_PCIE_PORT               0x11B0
+
+/*------- Request Queue Macros ---------*/
+#define    CN66XX_SLI_IQ_BASE_ADDR64(iq)          \
+	(CN66XX_SLI_IQ_BASE_ADDR_START64 + ((iq) * CN66XX_IQ_OFFSET))
+
+#define    CN66XX_SLI_IQ_SIZE(iq)                 \
+	(CN66XX_SLI_IQ_SIZE_START + ((iq) * CN66XX_IQ_OFFSET))
+
+#define    CN66XX_SLI_IQ_PKT_INSTR_HDR64(iq)      \
+	(CN66XX_SLI_IQ_PKT_INSTR_HDR_START64 + ((iq) * CN66XX_IQ_OFFSET))
+
+#define    CN66XX_SLI_IQ_DOORBELL(iq)             \
+	(CN66XX_SLI_IQ_DOORBELL_START + ((iq) * CN66XX_IQ_OFFSET))
+
+#define    CN66XX_SLI_IQ_INSTR_COUNT(iq)          \
+	(CN66XX_SLI_IQ_INSTR_COUNT_START + ((iq) * CN66XX_IQ_OFFSET))
+
+#define    CN66XX_SLI_IQ_BP64(iq)                 \
+	(CN66XX_SLI_INPUT_BP_START64 + ((iq) * CN66XX_IQ_OFFSET))
+
+/*------------------ Masks ----------------*/
+#define    CN66XX_INPUT_CTL_ROUND_ROBIN_ARB         BIT(22)
+#define    CN66XX_INPUT_CTL_DATA_NS                 BIT(8)
+#define    CN66XX_INPUT_CTL_DATA_ES_64B_SWAP        BIT(6)
+#define    CN66XX_INPUT_CTL_DATA_RO                 BIT(5)
+#define    CN66XX_INPUT_CTL_USE_CSR                 BIT(4)
+#define    CN66XX_INPUT_CTL_GATHER_NS               BIT(3)
+#define    CN66XX_INPUT_CTL_GATHER_ES_64B_SWAP      BIT(2)
+#define    CN66XX_INPUT_CTL_GATHER_RO               BIT(1)
+
+#ifdef __BIG_ENDIAN_BITFIELD
+#define    CN66XX_INPUT_CTL_MASK                    \
+	(CN66XX_INPUT_CTL_DATA_ES_64B_SWAP      \
+	  | CN66XX_INPUT_CTL_USE_CSR              \
+	  | CN66XX_INPUT_CTL_GATHER_ES_64B_SWAP)
+#else
+#define    CN66XX_INPUT_CTL_MASK                    \
+	(CN66XX_INPUT_CTL_DATA_ES_64B_SWAP     \
+	  | CN66XX_INPUT_CTL_USE_CSR)
+#endif
+
+/*############################ OUTPUT QUEUE #########################*/
+
+/* 32 registers for Output queue buffer and info size - SLI_PKT0_OUT_SIZE */
+#define    CN66XX_SLI_OQ0_BUFF_INFO_SIZE         0x0C00
+
+/* 32 registers for Output Queue Start Addr - SLI_PKT0_SLIST_BADDR */
+#define    CN66XX_SLI_OQ_BASE_ADDR_START64       0x1400
+
+/* 32 registers for Output Queue Packet Credits - SLI_PKT0_SLIST_BAOFF_DBELL */
+#define    CN66XX_SLI_OQ_PKT_CREDITS_START       0x1800
+
+/* 32 registers for Output Queue size - SLI_PKT0_SLIST_FIFO_RSIZE */
+#define    CN66XX_SLI_OQ_SIZE_START              0x1C00
+
+/* 32 registers for Output Queue Packet Count - SLI_PKT0_CNTS */
+#define    CN66XX_SLI_OQ_PKT_SENT_START          0x2400
+
+/* Each Output Queue register is at a 16-byte Offset in BAR0 */
+#define    CN66XX_OQ_OFFSET                      0x10
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - Relaxed Ordering setting for reading Output Queues descriptors
+ * - SLI_PKT_SLIST_ROR
+ */
+#define    CN66XX_SLI_PKT_SLIST_ROR              0x1030
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - No Snoop mode for reading Output Queues descriptors
+ * - SLI_PKT_SLIST_NS
+ */
+#define    CN66XX_SLI_PKT_SLIST_NS               0x1040
+
+/* 1 register (64-bit) - 2 bits for each output queue
+ * - Endian-Swap mode for reading Output Queue descriptors
+ * - SLI_PKT_SLIST_ES
+ */
+#define    CN66XX_SLI_PKT_SLIST_ES64             0x1050
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - InfoPtr mode for Output Queues.
+ * - SLI_PKT_IPTR
+ */
+#define    CN66XX_SLI_PKT_IPTR                   0x1070
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - DPTR format selector for Output queues.
+ * - SLI_PKT_DPADDR
+ */
+#define    CN66XX_SLI_PKT_DPADDR                 0x1080
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - Relaxed Ordering setting for reading Output Queues data
+ * - SLI_PKT_DATA_OUT_ROR
+ */
+#define    CN66XX_SLI_PKT_DATA_OUT_ROR           0x1090
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - No Snoop mode for reading Output Queues data
+ * - SLI_PKT_DATA_OUT_NS
+ */
+#define    CN66XX_SLI_PKT_DATA_OUT_NS            0x10A0
+
+/* 1 register (64-bit)  - 2 bits for each output queue
+ * - Endian-Swap mode for reading Output Queue data
+ * - SLI_PKT_DATA_OUT_ES
+ */
+#define    CN66XX_SLI_PKT_DATA_OUT_ES64          0x10B0
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - Controls whether SLI_PKTn_CNTS is incremented for bytes or for packets.
+ * - SLI_PKT_OUT_BMODE
+ */
+#define    CN66XX_SLI_PKT_OUT_BMODE              0x10D0
+
+/* 1 register (64-bit) - 2 bits for each output queue
+ * - Assign PCIE port for Output queues
+ * - SLI_PKT_PCIE_PORT.
+ */
+#define    CN66XX_SLI_PKT_PCIE_PORT64            0x10E0
+
+/* 1 (64-bit) register for Output Queue Packet Count Interrupt Threshold
+ * & Time Threshold. The same setting applies to all 32 queues.
+ * The register is defined as a 64-bit registers, but we use the
+ * 32-bit offsets to define distinct addresses.
+ */
+#define    CN66XX_SLI_OQ_INT_LEVEL_PKTS          0x1120
+#define    CN66XX_SLI_OQ_INT_LEVEL_TIME          0x1124
+
+/* 1 (64-bit register) for Output Queue backpressure across all rings. */
+#define    CN66XX_SLI_OQ_WMARK                   0x1180
+
+/* 1 register to control output queue global backpressure & ring enable. */
+#define    CN66XX_SLI_PKT_CTL                    0x1220
+
+/*------- Output Queue Macros ---------*/
+#define    CN66XX_SLI_OQ_BASE_ADDR64(oq)          \
+	(CN66XX_SLI_OQ_BASE_ADDR_START64 + ((oq) * CN66XX_OQ_OFFSET))
+
+#define    CN66XX_SLI_OQ_SIZE(oq)                 \
+	(CN66XX_SLI_OQ_SIZE_START + ((oq) * CN66XX_OQ_OFFSET))
+
+#define    CN66XX_SLI_OQ_BUFF_INFO_SIZE(oq)                 \
+	(CN66XX_SLI_OQ0_BUFF_INFO_SIZE + ((oq) * CN66XX_OQ_OFFSET))
+
+#define    CN66XX_SLI_OQ_PKTS_SENT(oq)            \
+	(CN66XX_SLI_OQ_PKT_SENT_START + ((oq) * CN66XX_OQ_OFFSET))
+
+#define    CN66XX_SLI_OQ_PKTS_CREDIT(oq)          \
+	(CN66XX_SLI_OQ_PKT_CREDITS_START + ((oq) * CN66XX_OQ_OFFSET))
+
+/*######################### DMA Counters #########################*/
+
+/* 2 registers (64-bit) - DMA Count - 1 for each DMA counter 0/1. */
+#define    CN66XX_DMA_CNT_START                   0x0400
+
+/* 2 registers (64-bit) - DMA Timer 0/1, contains DMA timer values
+ * SLI_DMA_0_TIM
+ */
+#define    CN66XX_DMA_TIM_START                   0x0420
+
+/* 2 registers (64-bit) - DMA count & Time Interrupt threshold -
+ * SLI_DMA_0_INT_LEVEL
+ */
+#define    CN66XX_DMA_INT_LEVEL_START             0x03E0
+
+/* Each DMA register is at a 16-byte Offset in BAR0 */
+#define    CN66XX_DMA_OFFSET                      0x10
+
+/*---------- DMA Counter Macros ---------*/
+#define    CN66XX_DMA_CNT(dq)                      \
+	(CN66XX_DMA_CNT_START + ((dq) * CN66XX_DMA_OFFSET))
+
+#define    CN66XX_DMA_INT_LEVEL(dq)                \
+	(CN66XX_DMA_INT_LEVEL_START + ((dq) * CN66XX_DMA_OFFSET))
+
+#define    CN66XX_DMA_PKT_INT_LEVEL(dq)            \
+	(CN66XX_DMA_INT_LEVEL_START + ((dq) * CN66XX_DMA_OFFSET))
+
+#define    CN66XX_DMA_TIME_INT_LEVEL(dq)           \
+	(CN66XX_DMA_INT_LEVEL_START + 4 + ((dq) * CN66XX_DMA_OFFSET))
+
+#define    CN66XX_DMA_TIM(dq)                      \
+	(CN66XX_DMA_TIM_START + ((dq) * CN66XX_DMA_OFFSET))
+
+/*######################## INTERRUPTS #########################*/
+
+/* 1 register (64-bit) for Interrupt Summary */
+#define    CN66XX_SLI_INT_SUM64                  0x0330
+
+/* 1 register (64-bit) for Interrupt Enable */
+#define    CN66XX_SLI_INT_ENB64_PORT0            0x0340
+#define    CN66XX_SLI_INT_ENB64_PORT1            0x0350
+
+/* 1 register (32-bit) to enable Output Queue Packet/Byte Count Interrupt */
+#define    CN66XX_SLI_PKT_CNT_INT_ENB            0x1150
+
+/* 1 register (32-bit) to enable Output Queue Packet Timer Interrupt */
+#define    CN66XX_SLI_PKT_TIME_INT_ENB           0x1160
+
+/* 1 register (32-bit) to indicate which Output Queue reached pkt threshold */
+#define    CN66XX_SLI_PKT_CNT_INT                0x1130
+
+/* 1 register (32-bit) to indicate which Output Queue reached time threshold */
+#define    CN66XX_SLI_PKT_TIME_INT               0x1140
+
+/*------------------ Interrupt Masks ----------------*/
+
+#define    CN66XX_INTR_RML_TIMEOUT_ERR           BIT(1)
+
+#define    CN66XX_INTR_BAR0_RW_TIMEOUT_ERR       BIT(2)
+#define    CN66XX_INTR_IO2BIG_ERR                BIT(3)
+#define    CN66XX_INTR_PKT_COUNT                 BIT(4)
+#define    CN66XX_INTR_PKT_TIME                  BIT(5)
+#define    CN66XX_INTR_M0UPB0_ERR                BIT(8)
+#define    CN66XX_INTR_M0UPWI_ERR                BIT(9)
+#define    CN66XX_INTR_M0UNB0_ERR                BIT(10)
+#define    CN66XX_INTR_M0UNWI_ERR                BIT(11)
+#define    CN66XX_INTR_M1UPB0_ERR                BIT(12)
+#define    CN66XX_INTR_M1UPWI_ERR                BIT(13)
+#define    CN66XX_INTR_M1UNB0_ERR                BIT(14)
+#define    CN66XX_INTR_M1UNWI_ERR                BIT(15)
+#define    CN66XX_INTR_MIO_INT0                  BIT(16)
+#define    CN66XX_INTR_MIO_INT1                  BIT(17)
+#define    CN66XX_INTR_MAC_INT0                  BIT(18)
+#define    CN66XX_INTR_MAC_INT1                  BIT(19)
+
+#define    CN66XX_INTR_DMA0_FORCE                BIT_ULL(32)
+#define    CN66XX_INTR_DMA1_FORCE                BIT_ULL(33)
+#define    CN66XX_INTR_DMA0_COUNT                BIT_ULL(34)
+#define    CN66XX_INTR_DMA1_COUNT                BIT_ULL(35)
+#define    CN66XX_INTR_DMA0_TIME                 BIT_ULL(36)
+#define    CN66XX_INTR_DMA1_TIME                 BIT_ULL(37)
+#define    CN66XX_INTR_INSTR_DB_OF_ERR           BIT_ULL(48)
+#define    CN66XX_INTR_SLIST_DB_OF_ERR           BIT_ULL(49)
+#define    CN66XX_INTR_POUT_ERR                  BIT_ULL(50)
+#define    CN66XX_INTR_PIN_BP_ERR                BIT_ULL(51)
+#define    CN66XX_INTR_PGL_ERR                   BIT_ULL(52)
+#define    CN66XX_INTR_PDI_ERR                   BIT_ULL(53)
+#define    CN66XX_INTR_POP_ERR                   BIT_ULL(54)
+#define    CN66XX_INTR_PINS_ERR                  BIT_ULL(55)
+#define    CN66XX_INTR_SPRT0_ERR                 BIT_ULL(56)
+#define    CN66XX_INTR_SPRT1_ERR                 BIT_ULL(57)
+#define    CN66XX_INTR_ILL_PAD_ERR               BIT_ULL(60)
+
+#define    CN66XX_INTR_DMA0_DATA                 (CN66XX_INTR_DMA0_TIME)
+
+#define    CN66XX_INTR_DMA1_DATA                 (CN66XX_INTR_DMA1_TIME)
+
+#define    CN66XX_INTR_DMA_DATA                  \
+	(CN66XX_INTR_DMA0_DATA | CN66XX_INTR_DMA1_DATA)
+
+#define    CN66XX_INTR_PKT_DATA                  (CN66XX_INTR_PKT_TIME)
+
+/* Sum of interrupts for all PCI-Express Data Interrupts */
+#define    CN66XX_INTR_PCIE_DATA                 \
+	(CN66XX_INTR_DMA_DATA | CN66XX_INTR_PKT_DATA)
+
+#define    CN66XX_INTR_MIO                       \
+	(CN66XX_INTR_MIO_INT0 | CN66XX_INTR_MIO_INT1)
+
+#define    CN66XX_INTR_MAC                       \
+	(CN66XX_INTR_MAC_INT0 | CN66XX_INTR_MAC_INT1)
+
+/* Sum of interrupts for error events */
+#define    CN66XX_INTR_ERR                       \
+	(CN66XX_INTR_BAR0_RW_TIMEOUT_ERR    \
+	   | CN66XX_INTR_IO2BIG_ERR             \
+	   | CN66XX_INTR_M0UPB0_ERR             \
+	   | CN66XX_INTR_M0UPWI_ERR             \
+	   | CN66XX_INTR_M0UNB0_ERR             \
+	   | CN66XX_INTR_M0UNWI_ERR             \
+	   | CN66XX_INTR_M1UPB0_ERR             \
+	   | CN66XX_INTR_M1UPWI_ERR             \
+	   | CN66XX_INTR_M1UPB0_ERR             \
+	   | CN66XX_INTR_M1UNWI_ERR             \
+	   | CN66XX_INTR_INSTR_DB_OF_ERR        \
+	   | CN66XX_INTR_SLIST_DB_OF_ERR        \
+	   | CN66XX_INTR_POUT_ERR               \
+	   | CN66XX_INTR_PIN_BP_ERR             \
+	   | CN66XX_INTR_PGL_ERR                \
+	   | CN66XX_INTR_PDI_ERR                \
+	   | CN66XX_INTR_POP_ERR                \
+	   | CN66XX_INTR_PINS_ERR               \
+	   | CN66XX_INTR_SPRT0_ERR              \
+	   | CN66XX_INTR_SPRT1_ERR              \
+	   | CN66XX_INTR_ILL_PAD_ERR)
+
+/* Programmed Mask for Interrupt Sum */
+#define    CN66XX_INTR_MASK                      \
+	(CN66XX_INTR_PCIE_DATA              \
+	   | CN66XX_INTR_DMA0_FORCE             \
+	   | CN66XX_INTR_DMA1_FORCE             \
+	   | CN66XX_INTR_MIO                    \
+	   | CN66XX_INTR_MAC                    \
+	   | CN66XX_INTR_ERR)
+
+#define    CN66XX_SLI_S2M_PORT0_CTL              0x3D80
+#define    CN66XX_SLI_S2M_PORT1_CTL              0x3D90
+#define    CN66XX_SLI_S2M_PORTX_CTL(port)        \
+	(CN66XX_SLI_S2M_PORT0_CTL + (port * 0x10))
+
+#define    CN66XX_SLI_INT_ENB64(port)            \
+	(CN66XX_SLI_INT_ENB64_PORT0 + (port * 0x10))
+
+#define    CN66XX_SLI_MAC_NUMBER                 0x3E00
+
+/* CN66XX BAR1 Index registers. */
+#define    CN66XX_PEM_BAR1_INDEX000                0x00011800C00000A8ULL
+
+#define    CN66XX_BAR1_INDEX_START                 CN66XX_PEM_BAR1_INDEX000
+#define    CN66XX_PCI_BAR1_OFFSET                  0x8
+
+#define    CN66XX_BAR1_INDEX_REG(idx)              \
+	(CN66XX_BAR1_INDEX_START + (CN66XX_PCI_BAR1_OFFSET * (idx)))
+
+/*############################ DPI #########################*/
+
+#define    CN66XX_DPI_CTL                 0x0001df0000000040ULL
+
+#define    CN66XX_DPI_DMA_CONTROL         0x0001df0000000048ULL
+
+#define    CN66XX_DPI_REQ_GBL_ENB         0x0001df0000000050ULL
+
+#define    CN66XX_DPI_REQ_ERR_RSP         0x0001df0000000058ULL
+
+#define    CN66XX_DPI_REQ_ERR_RST         0x0001df0000000060ULL
+
+#define    CN66XX_DPI_DMA_ENG0_ENB        0x0001df0000000080ULL
+
+#define    CN66XX_DPI_DMA_ENG_ENB(q_no)   \
+	(CN66XX_DPI_DMA_ENG0_ENB + (q_no * 8))
+
+#define    CN66XX_DPI_DMA_ENG0_BUF        0x0001df0000000880ULL
+
+#define    CN66XX_DPI_DMA_ENG_BUF(q_no)   \
+	(CN66XX_DPI_DMA_ENG0_BUF + (q_no * 8))
+
+#define    CN66XX_DPI_SLI_PRT0_CFG        0x0001df0000000900ULL
+#define    CN66XX_DPI_SLI_PRT1_CFG        0x0001df0000000908ULL
+#define    CN66XX_DPI_SLI_PRTX_CFG(port)        \
+	(CN66XX_DPI_SLI_PRT0_CFG + (port * 0x10))
+
+#define    CN66XX_DPI_DMA_COMMIT_MODE     BIT_ULL(58)
+#define    CN66XX_DPI_DMA_PKT_HP          BIT_ULL(57)
+#define    CN66XX_DPI_DMA_PKT_EN          BIT_ULL(56)
+#define    CN66XX_DPI_DMA_O_ES            BIT_ULL(15)
+#define    CN66XX_DPI_DMA_O_MODE          BIT_ULL(14)
+
+#define    CN66XX_DPI_DMA_CTL_MASK             \
+	(CN66XX_DPI_DMA_COMMIT_MODE    |    \
+	 CN66XX_DPI_DMA_PKT_HP         |    \
+	 CN66XX_DPI_DMA_PKT_EN         |    \
+	 CN66XX_DPI_DMA_O_ES           |    \
+	 CN66XX_DPI_DMA_O_MODE)
+
+/*############################ CIU #########################*/
+
+#define    CN66XX_CIU_SOFT_BIST           0x0001070000000738ULL
+#define    CN66XX_CIU_SOFT_RST            0x0001070000000740ULL
+
+/*############################ MIO #########################*/
+#define    CN6XXX_MIO_PTP_CLOCK_CFG       0x0001070000000f00ULL
+#define    CN6XXX_MIO_PTP_CLOCK_LO        0x0001070000000f08ULL
+#define    CN6XXX_MIO_PTP_CLOCK_HI        0x0001070000000f10ULL
+#define    CN6XXX_MIO_PTP_CLOCK_COMP      0x0001070000000f18ULL
+#define    CN6XXX_MIO_PTP_TIMESTAMP       0x0001070000000f20ULL
+#define    CN6XXX_MIO_PTP_EVT_CNT         0x0001070000000f28ULL
+#define    CN6XXX_MIO_PTP_CKOUT_THRESH_LO 0x0001070000000f30ULL
+#define    CN6XXX_MIO_PTP_CKOUT_THRESH_HI 0x0001070000000f38ULL
+#define    CN6XXX_MIO_PTP_CKOUT_HI_INCR   0x0001070000000f40ULL
+#define    CN6XXX_MIO_PTP_CKOUT_LO_INCR   0x0001070000000f48ULL
+#define    CN6XXX_MIO_PTP_PPS_THRESH_LO   0x0001070000000f50ULL
+#define    CN6XXX_MIO_PTP_PPS_THRESH_HI   0x0001070000000f58ULL
+#define    CN6XXX_MIO_PTP_PPS_HI_INCR     0x0001070000000f60ULL
+#define    CN6XXX_MIO_PTP_PPS_LO_INCR     0x0001070000000f68ULL
+
+#define    CN6XXX_MIO_RST_BOOT            0x0001180000001600ULL
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
new file mode 100644
index 0000000..0701645
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
@@ -0,0 +1,791 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+#include "octeon_mem_ops.h"
+
+static void cn68xx_set_dpi_regs(struct octeon_device *oct)
+{
+	uint32_t i;
+	uint32_t fifo_sizes[6] = { 3, 3, 1, 1, 1, 8 };
+
+	OCTEON_PCI_WIN_WRITE(oct, CN68XX_DPI_DMA_CONTROL,
+			     CN68XX_DPI_DMA_CTL_MASK);
+	lio_dev_dbg(oct, "DPI_DMA_CONTROL: 0x%016llx\n",
+		    OCTEON_PCI_WIN_READ(oct, CN68XX_DPI_DMA_CONTROL));
+
+	for (i = 0; i < 6; i++) {
+		/* Prevent service of instruction queue for all DMA engines
+		 * Engine 5 will remain 0. Engines 0 - 4 will be setup by
+		 * core.
+		 */
+		OCTEON_PCI_WIN_WRITE(oct, CN68XX_DPI_DMA_ENG_ENB(i), 0);
+		OCTEON_PCI_WIN_WRITE(oct, CN68XX_DPI_DMA_ENG_BUF(i),
+				     fifo_sizes[i]);
+		lio_dev_dbg(oct, "DPI_ENG_BUF%d: 0x%016llx\n", i,
+			    OCTEON_PCI_WIN_READ(oct,
+						CN68XX_DPI_DMA_ENG_BUF(i)));
+	}
+
+	/* DPI_SLI_PRT_CFG has MPS and MRRS settings that will be set
+	 * separately.
+	 */
+
+	OCTEON_PCI_WIN_WRITE(oct, CN68XX_DPI_CTL, 1);
+	lio_dev_dbg(oct, "DPI_CTL: 0x%016llx\n",
+		    OCTEON_PCI_WIN_READ(oct, CN68XX_DPI_CTL));
+}
+
+static int cn68xx_soft_reset(struct octeon_device *oct)
+{
+	octeon_write_csr64(oct, CN68XX_WIN_WR_MASK_REG, 0xFF);
+
+	lio_dev_dbg(oct, "BIST enabled for CN68XX soft reset\n");
+	OCTEON_PCI_WIN_WRITE(oct, CN68XX_CIU_SOFT_BIST, 1);
+
+	octeon_write_csr64(oct, CN68XX_SLI_SCRATCH1, 0x1234ULL);
+
+	OCTEON_PCI_WIN_READ(oct, CN68XX_CIU_SOFT_RST);
+	OCTEON_PCI_WIN_WRITE(oct, CN68XX_CIU_SOFT_RST, 1);
+
+	/* make sure that the reset is written before starting timer */
+	mmiowb();
+
+	/* Wait for 100ms as Octeon resets. */
+	mdelay(100);
+
+	if (octeon_read_csr64(oct, CN68XX_SLI_SCRATCH1) == 0x1234ULL) {
+		lio_dev_err(oct, "Soft reset failed\n");
+		return 1;
+	}
+
+	lio_dev_dbg(oct, "Reset completed\n");
+	octeon_write_csr64(oct, CN68XX_WIN_WR_MASK_REG, 0xFF);
+
+	cn68xx_set_dpi_regs(oct);
+
+	return 0;
+}
+
+static void cn68xx_enable_error_reporting(struct octeon_device *oct)
+{
+	uint32_t val;
+
+	pci_read_config_dword(oct->pci_dev, CN68XX_PCIE_DEVCTL, &val);
+	if (val & 0x000f0000)
+		lio_dev_err(oct, "PCI-E Link error detected: 0x%08x\n",
+			    val & 0x000f0000);
+
+	val |= 0xf;          /* Enable Link error reporting */
+
+	pci_write_config_dword(oct->pci_dev, CN68XX_PCIE_DEVCTL, val);
+}
+
+static void
+cn68xx_setup_pcie_mps(struct octeon_device *oct, enum octeon_pcie_mps mps)
+{
+	uint32_t val;
+	uint64_t r64;
+
+	/* Read config register for MPS */
+	pci_read_config_dword(oct->pci_dev, CN68XX_PCIE_DEVCTL, &val);
+
+	if (mps == PCIE_MPS_DEFAULT) {
+		mps = ((val & (0x7 << 5)) >> 5);
+	} else {
+		val &= ~(0x7 << 5);  /* Turn off any MPS bits */
+		val |= (mps << 5);   /* Set MPS */
+		pci_write_config_dword(oct->pci_dev, CN68XX_PCIE_DEVCTL, val);
+	}
+
+	/* Set MPS in DPI_SLI_PRT0_CFG to the same value. */
+	r64 = OCTEON_PCI_WIN_READ(oct, CN68XX_DPI_SLI_PRTX_CFG(oct->pcie_port));
+	r64 |= (mps << 4);
+	OCTEON_PCI_WIN_WRITE(oct, CN68XX_DPI_SLI_PRTX_CFG(oct->pcie_port), r64);
+}
+
+static void
+cn68xx_setup_pcie_mrrs(struct octeon_device *oct, enum octeon_pcie_mrrs mrrs)
+{
+	uint32_t val;
+	uint64_t r64;
+
+	/* Read config register for MRRS */
+	pci_read_config_dword(oct->pci_dev, CN68XX_PCIE_DEVCTL, &val);
+
+	if (mrrs == PCIE_MRRS_DEFAULT) {
+		mrrs = ((val & (0x7 << 12)) >> 12);
+	} else {
+		val &= ~(0x7 << 12); /* Turn off any MRRS bits */
+		val |= (mrrs << 12); /* Set MRRS */
+		pci_write_config_dword(oct->pci_dev, CN68XX_PCIE_DEVCTL, val);
+	}
+
+	/* Set MRRS in SLI_S2M_PORT0_CTL to the same value. */
+	r64 = octeon_read_csr64(oct, CN68XX_SLI_S2M_PORTX_CTL(oct->pcie_port));
+	r64 |= mrrs;
+	octeon_write_csr64(oct, CN68XX_SLI_S2M_PORTX_CTL(oct->pcie_port), r64);
+
+	/* Set MRRS in DPI_SLI_PRT0_CFG to the same value. */
+	r64 = OCTEON_PCI_WIN_READ(oct, CN68XX_DPI_SLI_PRTX_CFG(oct->pcie_port));
+	r64 |= mrrs;
+	OCTEON_PCI_WIN_WRITE(oct, CN68XX_DPI_SLI_PRTX_CFG(oct->pcie_port), r64);
+}
+
+static void cn68xx_setup_global_input_regs(struct octeon_device *oct)
+{
+	/* Select Round-Robin Arb, ES, RO, NS for Input Queues */
+	octeon_write_csr(oct, CN68XX_SLI_PKT_INPUT_CONTROL,
+			 CN68XX_INPUT_CTL_MASK);
+
+	/* Instruction Read Size - Max 4 instructions per PCIE Read */
+	octeon_write_csr64(oct, CN68XX_SLI_PKT_INSTR_RD_SIZE,
+			   0xFFFFFFFFFFFFFFFFULL);
+
+	/* Select PCIE Port for all Input rings. */
+	octeon_write_csr64(oct, CN68XX_SLI_IN_PCIE_PORT,
+			   (oct->pcie_port * 0x5555555555555555ULL));
+}
+
+static void cn68xx_setup_global_output_regs(struct octeon_device *oct)
+{
+	uint32_t time_threshold;
+	struct octeon_cn68xx *cn68xx = (struct octeon_cn68xx *)oct->chip;
+	uint64_t pktctl;
+	uint64_t tx_pipe, max_oqs;
+
+	pktctl = octeon_read_csr64(oct, CN68XX_SLI_PKT_CTL);
+
+	max_oqs = CFG_GET_OQ_MAX_Q(CHIP_FIELD(oct, cn68xx, conf));
+	tx_pipe  = octeon_read_csr64(oct, CN68XX_SLI_TX_PIPE);
+	tx_pipe &= 0xffffffffff00ffffULL; /* clear out NUMP field */
+	tx_pipe |= max_oqs << 16; /* put max_oqs in NUMP field */
+	octeon_write_csr64(oct, CN68XX_SLI_TX_PIPE, tx_pipe);
+
+	/* / Select PCI-E Port for all Output queues */
+	octeon_write_csr64(oct, CN68XX_SLI_PKT_PCIE_PORT64,
+			   (oct->pcie_port * 0x5555555555555555ULL));
+
+	if (CFG_GET_IS_SLI_BP_ON(cn68xx->conf))
+		pktctl |= 0xF;
+	else
+		/* Disable per-port backpressure. */
+		pktctl &= ~0xF;
+	octeon_write_csr64(oct, CN68XX_SLI_PKT_CTL, pktctl);
+
+	if (CFG_GET_IS_SLI_BP_ON(cn68xx->conf)) {
+		octeon_write_csr64(oct, CN68XX_SLI_OQ_WMARK, 32);
+	} else {
+		/* / Set Output queue watermark to 0 to disable backpressure */
+		octeon_write_csr64(oct, CN68XX_SLI_OQ_WMARK, 0);
+	}
+	/* / Select Info Ptr for length & data */
+	octeon_write_csr(oct, CN68XX_SLI_PKT_IPTR, 0xFFFFFFFF);
+
+	/* / Select Packet count instead of bytes for SLI_PKTi_CNTS[CNT] */
+	octeon_write_csr(oct, CN68XX_SLI_PKT_OUT_BMODE, 0);
+
+	/* Select ES,RO,NS setting from register for
+	 * Output Queue Packet Address
+	 */
+	octeon_write_csr(oct, CN68XX_SLI_PKT_DPADDR, 0xFFFFFFFF);
+
+	/* No Relaxed Ordering, No Snoop, 64-bit swap for
+	 * Output Queue ScatterList
+	 */
+	octeon_write_csr(oct, CN68XX_SLI_PKT_SLIST_ROR, 0);
+	octeon_write_csr(oct, CN68XX_SLI_PKT_SLIST_NS, 0);
+
+	/* / ENDIAN_SPECIFIC CHANGES - 0 works for LE. */
+#ifdef __BIG_ENDIAN_BITFIELD
+	octeon_write_csr64(oct, CN68XX_SLI_PKT_SLIST_ES64,
+			   0x5555555555555555ULL);
+#else
+	octeon_write_csr64(oct, CN68XX_SLI_PKT_SLIST_ES64, 0ULL);
+#endif
+
+	/* / No Relaxed Ordering, No Snoop, 64-bit swap for Output Queue Data */
+	octeon_write_csr(oct, CN68XX_SLI_PKT_DATA_OUT_ROR, 0);
+	octeon_write_csr(oct, CN68XX_SLI_PKT_DATA_OUT_NS, 0);
+	octeon_write_csr64(oct, CN68XX_SLI_PKT_DATA_OUT_ES64,
+			   0x5555555555555555ULL);
+
+	/* / Set up interrupt packet and time threshold */
+	octeon_write_csr(oct, CN68XX_SLI_OQ_INT_LEVEL_PKTS,
+			 (uint32_t)CFG_GET_OQ_INTR_PKT(cn68xx->conf));
+
+	time_threshold =
+		lio_cn6xxx_get_oq_ticks(oct, (uint32_t)
+				    CFG_GET_OQ_INTR_TIME(cn68xx->conf));
+	octeon_write_csr(oct, CN68XX_SLI_OQ_INT_LEVEL_TIME, time_threshold);
+}
+
+static int cn68xx_setup_device_regs(struct octeon_device *oct)
+{
+	cn68xx_setup_pcie_mps(oct, PCIE_MPS_DEFAULT);
+	cn68xx_setup_pcie_mrrs(oct, PCIE_MRRS_256B);
+
+	cn68xx_enable_error_reporting(oct);
+
+	cn68xx_setup_global_input_regs(oct);
+	cn68xx_setup_global_output_regs(oct);
+
+	/* Default error timeout value should be 0x200000 to avoid host hang
+	 * when reads invalid register
+	 */
+	octeon_write_csr64(oct, CN68XX_SLI_WINDOW_CTL, 0x200000ULL);
+
+	return 0;
+}
+
+static void cn68xx_setup_iq_regs(struct octeon_device *oct, uint32_t iq_no)
+{
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
+
+	/* Disable Packet-by-Packet mode; No Parse Mode or Skip length */
+	octeon_write_csr64(oct, CN68XX_SLI_IQ_PKT_INSTR_HDR64(iq_no), 0);
+
+	/* Write the start of the input queue's ring and its size  */
+	octeon_write_csr64(oct, CN68XX_SLI_IQ_BASE_ADDR64(iq_no),
+			   iq->base_addr_dma);
+	octeon_write_csr(oct, CN68XX_SLI_IQ_SIZE(iq_no), iq->max_count);
+
+	/* this csr has other fields cannot write just pkind */
+	/* anyway host need not care about pkind. */
+
+	/* octeon_write_csr(oct, CN68XX_SLI_IQ_PORT_PKIND(iq_no), iq_no); */
+
+	/* Remember the doorbell & instruction count register addr
+	 * for this queue
+	 */
+	iq->doorbell_reg = oct->mmio[0].hw_addr + CN68XX_SLI_IQ_DOORBELL(iq_no);
+	iq->inst_cnt_reg = oct->mmio[0].hw_addr
+			   + CN68XX_SLI_IQ_INSTR_COUNT(iq_no);
+	lio_dev_dbg(oct, "InstQ[%d]:dbell reg @ 0x%p instcnt_reg @ 0x%p\n",
+		    iq_no, iq->doorbell_reg, iq->inst_cnt_reg);
+
+	/* Store the current instruction counter
+	 * (used in flush_iq calculation)
+	 */
+	iq->reset_instr_cnt = readl(iq->inst_cnt_reg);
+}
+
+static void cn68xx_setup_oq_regs(struct octeon_device *oct, uint32_t oq_no)
+{
+	uint32_t intr;
+	struct octeon_droq *droq = oct->droq[oq_no];
+
+	octeon_write_csr64(oct, CN68XX_SLI_OQ_BASE_ADDR64(oq_no),
+			   droq->desc_ring_dma);
+	octeon_write_csr(oct, CN68XX_SLI_OQ_SIZE(oq_no), droq->max_count);
+
+	octeon_write_csr(oct, CN68XX_SLI_OQ_BUFF_INFO_SIZE(oq_no),
+			 (droq->buffer_size | (OCT_RH_SIZE << 16)));
+
+	/* Get the mapped address of the pkt_sent and pkts_credit regs */
+	droq->pkts_sent_reg =
+		oct->mmio[0].hw_addr + CN68XX_SLI_OQ_PKTS_SENT(oq_no);
+	droq->pkts_credit_reg =
+		oct->mmio[0].hw_addr + CN68XX_SLI_OQ_PKTS_CREDIT(oq_no);
+
+	/* Enable this output queue to generate Packet Timer Interrupt */
+	intr = octeon_read_csr(oct, CN68XX_SLI_PKT_TIME_INT_ENB);
+	intr |= (1 << oq_no);
+	octeon_write_csr(oct, CN68XX_SLI_PKT_TIME_INT_ENB, intr);
+
+	/* Enable this output queue to generate Packet Count Interrupt */
+	intr = octeon_read_csr(oct, CN68XX_SLI_PKT_CNT_INT_ENB);
+	intr |= (1 << oq_no);
+	octeon_write_csr(oct, CN68XX_SLI_PKT_CNT_INT_ENB, intr);
+}
+
+static void cn68xx_enable_io_queues(struct octeon_device *oct)
+{
+	octeon_write_csr(oct, CN68XX_SLI_PKT_INSTR_SIZE, oct->io_qmask.iq64B);
+	octeon_write_csr(oct, CN68XX_SLI_PKT_INSTR_ENB, oct->io_qmask.iq);
+	octeon_write_csr(oct, CN68XX_SLI_PKT_OUT_ENB, oct->io_qmask.oq);
+}
+
+static void cn68xx_disable_io_queues(struct octeon_device *oct)
+{
+	uint32_t mask, i, loop = HZ;
+	uint32_t d32;
+
+	/*** Disable Input Queues. ***/
+
+	/* Reset the Enable bits for Input Queues. */
+	octeon_write_csr(oct, CN68XX_SLI_PKT_INSTR_ENB, 0);
+
+	/* Wait until hardware indicates that the queues are out of reset. */
+	mask = oct->io_qmask.iq;
+	d32 = octeon_read_csr(oct, CN68XX_SLI_PORT_IN_RST_IQ);
+	while (((d32 & mask) != mask) && loop--) {
+		d32 = octeon_read_csr(oct, CN68XX_SLI_PORT_IN_RST_IQ);
+		schedule_timeout_uninterruptible(1);
+	}
+
+	/* Reset the doorbell register for each Input queue. */
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+		if (!(oct->io_qmask.iq & (1UL << i)))
+			continue;
+		octeon_write_csr(oct, CN68XX_SLI_IQ_DOORBELL(i), 0xFFFFFFFF);
+		d32 = octeon_read_csr(oct, CN68XX_SLI_IQ_DOORBELL(i));
+	}
+
+	/*** Disable Output Queues. ***/
+
+	/* Reset the Enable bits for Output Queues. */
+	octeon_write_csr(oct, CN68XX_SLI_PKT_OUT_ENB, 0);
+
+	/* Wait until hardware indicates that the queues are out of reset. */
+	loop = HZ;
+	mask = oct->io_qmask.oq;
+	d32 = octeon_read_csr(oct, CN68XX_SLI_PORT_IN_RST_OQ);
+	while (((d32 & mask) != mask) && loop--) {
+		d32 = octeon_read_csr(oct, CN68XX_SLI_PORT_IN_RST_OQ);
+		schedule_timeout_uninterruptible(1);
+	}
+	;
+
+	/* Reset the doorbell register for each Output queue. */
+	/* for (i = 0; i < oct->num_oqs; i++) { */
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct->num_oqs & (1UL << i)))
+			continue;
+		octeon_write_csr(oct, CN68XX_SLI_OQ_PKTS_CREDIT(i), 0xFFFFFFFF);
+		d32 = octeon_read_csr(oct, CN68XX_SLI_OQ_PKTS_CREDIT(i));
+
+		d32 = octeon_read_csr(oct, CN68XX_SLI_OQ_PKTS_SENT(i));
+		octeon_write_csr(oct, CN68XX_SLI_OQ_PKTS_SENT(i), d32);
+	}
+
+	d32 = octeon_read_csr(oct, CN68XX_SLI_PKT_CNT_INT);
+	if (d32)
+		octeon_write_csr(oct, CN68XX_SLI_PKT_CNT_INT, d32);
+
+	d32 = octeon_read_csr(oct, CN68XX_SLI_PKT_TIME_INT);
+	if (d32)
+		octeon_write_csr(oct, CN68XX_SLI_PKT_TIME_INT, d32);
+}
+
+static void
+cn68xx_process_pcie_error_intr(struct octeon_device *oct, uint64_t intr64)
+{
+	lio_dev_err(oct, "Error Intr: 0x%016llx\n", CVM_CAST64(intr64));
+}
+
+static int cn68xx_process_droq_intr_regs(struct octeon_device *oct)
+{
+	struct octeon_droq *droq;
+	uint32_t oq_no, pkt_count;
+	uint32_t droq_time_mask, droq_mask, droq_int_enb, droq_cnt_enb;
+	uint32_t droq_cnt_mask; /* intrmod: count mask */
+
+	droq_cnt_enb = octeon_read_csr(oct, CN68XX_SLI_PKT_CNT_INT_ENB);
+	droq_cnt_mask = octeon_read_csr(oct, CN68XX_SLI_PKT_CNT_INT);
+	droq_mask = droq_cnt_mask & droq_cnt_enb;
+
+	droq_int_enb = octeon_read_csr(oct, CN68XX_SLI_PKT_TIME_INT_ENB);
+	droq_time_mask = octeon_read_csr(oct, CN68XX_SLI_PKT_TIME_INT);
+	droq_mask |= (droq_time_mask & droq_int_enb);
+
+	/* for (oq_no = 0; oq_no < oct->num_oqs; oq_no++) { */
+	for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES; oq_no++) {
+		if (!(droq_mask & (1 << oq_no)))
+			continue;
+
+		droq = oct->droq[oq_no];
+		pkt_count = octeon_droq_check_hw_for_pkts(oct, droq);
+		if (pkt_count) {
+			oct->droq_intr |= (1ULL << oq_no);
+			if (droq->ops.poll_mode) {
+				uint32_t value;
+				uint32_t reg;
+
+				struct octeon_cn68xx *cn68xx =
+					(struct octeon_cn68xx *)oct->chip;
+
+				/* disable interrupts for this droq */
+				spin_lock
+					(&cn68xx->lock_for_droq_int_enb_reg);
+				reg = CN68XX_SLI_PKT_TIME_INT_ENB;
+				value = octeon_read_csr(oct, reg);
+				value &= ~(1 << oq_no);
+				octeon_write_csr(oct, reg, value);
+				reg = CN68XX_SLI_PKT_CNT_INT_ENB;
+				value = octeon_read_csr(oct, reg);
+				value &= ~(1 << oq_no);
+				octeon_write_csr(oct, reg, value);
+
+				/* Ensure that the enable register is written.
+				 */
+				mmiowb();
+
+				spin_unlock(&cn68xx->lock_for_droq_int_enb_reg);
+			}
+		}
+	}
+
+	/* Reset the PKT_CNT/TIME_INT registers. */
+	if (droq_cnt_mask)
+		octeon_write_csr(oct, CN68XX_SLI_PKT_CNT_INT, droq_cnt_mask);
+	if (droq_time_mask)
+		octeon_write_csr(oct, CN68XX_SLI_PKT_TIME_INT, droq_time_mask);
+
+	return 0;
+}
+
+static irqreturn_t cn68xx_process_interrupt_regs(void *dev)
+{
+	struct octeon_device *oct = (struct octeon_device *)dev;
+	struct octeon_cn68xx *cn68xx = (struct octeon_cn68xx *)oct->chip;
+	uint64_t intr64;
+
+	intr64 = readq(cn68xx->intr_sum_reg64);
+
+	/* If our device has interrupted, then proceed.
+	 * Also check for all f's if interrupt was triggered on an error
+	 * and the PCI read fails.
+	 */
+	if (!intr64 || (intr64 == 0xFFFFFFFFFFFFFFFFULL))
+		return IRQ_NONE;
+
+	atomic_set(&oct->in_interrupt, 1);
+
+	oct->int_status = 0;
+
+	oct->stats.interrupts++;
+
+	atomic_inc(&oct->interrupts);
+
+	if (intr64 & CN68XX_INTR_ERR)
+		cn68xx_process_pcie_error_intr(oct, intr64);
+
+	if (intr64 & CN68XX_INTR_PKT_DATA) {
+		cn68xx_process_droq_intr_regs(oct);
+		oct->int_status |= OCT_DEV_INTR_PKT_DATA;
+	}
+
+	if (intr64 & CN68XX_INTR_DMA0_FORCE)
+		oct->int_status |= OCT_DEV_INTR_DMA0_FORCE;
+
+	if (intr64 & CN68XX_INTR_DMA1_FORCE)
+		oct->int_status |= OCT_DEV_INTR_DMA1_FORCE;
+
+	/* Clear the current interrupts */
+	writeq(intr64, cn68xx->intr_sum_reg64);
+
+	atomic_set(&oct->in_interrupt, 0);
+
+	return IRQ_HANDLED;
+}
+
+static void cn68xx_reinit_regs(struct octeon_device *oct)
+{
+	uint32_t i;
+
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+		if (!(oct->io_qmask.iq & (1UL << i)))
+			continue;
+		oct->fn_list.setup_iq_regs(oct, i);
+	}
+
+	/* for (i = 0; i < oct->num_oqs; i++) { */
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct->io_qmask.oq & (1UL << i)))
+			continue;
+		oct->fn_list.setup_oq_regs(oct, i);
+	}
+
+	oct->fn_list.setup_device_regs(oct);
+
+	oct->fn_list.enable_interrupt(oct->chip);
+
+	oct->fn_list.enable_io_queues(oct);
+
+	/* for (i = 0; i < oct->num_oqs; i++) { */
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct->io_qmask.oq & (1UL << i)))
+			continue;
+		writel(oct->droq[i]->max_count, oct->droq[i]->pkts_credit_reg);
+	}
+}
+
+static void
+cn68xx_bar1_idx_setup(struct octeon_device *oct,
+		      uint64_t core_addr,
+		      uint32_t idx,
+		      int valid)
+{
+	uint64_t bar1;
+
+	if (valid == 0) {
+		bar1 =
+			OCTEON_PCI_WIN_READ(oct,
+					    CN68XX_BAR1_INDEX_REG(idx,
+								  oct->pcie_port
+								  ));
+		OCTEON_PCI_WIN_WRITE(oct,
+				     CN68XX_BAR1_INDEX_REG(idx, oct->pcie_port),
+				     (bar1 & 0xFFFFFFFEULL));
+		bar1 =
+			OCTEON_PCI_WIN_READ(oct,
+					    CN68XX_BAR1_INDEX_REG(idx,
+								  oct->pcie_port
+								  ));
+		return;
+	}
+
+	/* Bits 17:4 of the PCI_BAR1_INDEXx stores bits 35:22 of the
+	 * Core Addr
+	 */
+	OCTEON_PCI_WIN_WRITE(oct, CN68XX_BAR1_INDEX_REG(idx, oct->pcie_port),
+			     (((core_addr >> 22) << 4) | PCI_BAR1_MASK));
+
+	bar1 =
+		OCTEON_PCI_WIN_READ(oct,
+				    CN68XX_BAR1_INDEX_REG(idx, oct->pcie_port));
+}
+
+static void cn68xx_bar1_idx_write(struct octeon_device *oct,
+				  uint32_t idx,
+				  uint32_t mask)
+{
+	OCTEON_PCI_WIN_WRITE(oct, CN68XX_BAR1_INDEX_REG(idx, oct->pcie_port),
+			     mask);
+}
+
+static uint32_t cn68xx_bar1_idx_read(struct octeon_device *oct, uint32_t idx)
+{
+	return (uint32_t)
+		OCTEON_PCI_WIN_READ(oct,
+				    CN68XX_BAR1_INDEX_REG(idx, oct->pcie_port));
+}
+
+static uint32_t cn68xx_update_read_index(struct octeon_instr_queue *iq)
+{
+	uint32_t new_idx = readl(iq->inst_cnt_reg);
+
+	/* The new instr cnt reg is a 32-bit counter that can roll over. We have
+	 * noted the counter's initial value at init time into reset_instr_cnt
+	 */
+	if (iq->reset_instr_cnt < new_idx)
+		new_idx -= iq->reset_instr_cnt;
+	else
+		new_idx += (0xffffffff - iq->reset_instr_cnt) + 1;
+
+	/* Modulo of the new index with the IQ size will give us the
+	 * new index.
+	 */
+	new_idx %= iq->max_count;
+
+	return new_idx;
+}
+
+static void cn68xx_enable_interrupt(void *chip)
+{
+	struct octeon_cn68xx *cn68xx = (struct octeon_cn68xx *)chip;
+	uint64_t mask = cn68xx->intr_mask64 | CN68XX_INTR_DMA0_FORCE;
+
+	/* Enable Interrupt */
+	writeq(mask, cn68xx->intr_enb_reg64);
+}
+
+static void cn68xx_disable_interrupt(void *chip)
+{
+	struct octeon_cn68xx *cn68xx = (struct octeon_cn68xx *)chip;
+
+	/* Disable Interrupts */
+	writeq(0, cn68xx->intr_enb_reg64);
+
+	/* make sure interrupts are really disabled */
+	mmiowb();
+}
+
+static void cn68xx_get_pcie_qlmport(struct octeon_device *oct)
+{
+	oct->pcie_port = octeon_read_csr(oct, CN68XX_SLI_MAC_NUMBER) & 0xff;
+}
+
+static void cn68xx_setup_reg_address(struct octeon_device *oct)
+{
+	struct octeon_cn68xx *cn68xx = (struct octeon_cn68xx *)oct->chip;
+	uint8_t __iomem *bar0_pciaddr = oct->mmio[0].hw_addr;
+
+	oct->reg_list.pci_win_wr_addr_hi =
+		(uint32_t __iomem *)(bar0_pciaddr + CN68XX_WIN_WR_ADDR_HI);
+	oct->reg_list.pci_win_wr_addr_lo =
+		(uint32_t __iomem *)(bar0_pciaddr + CN68XX_WIN_WR_ADDR_LO);
+	oct->reg_list.pci_win_wr_addr =
+		(uint64_t __iomem *)(bar0_pciaddr + CN68XX_WIN_WR_ADDR64);
+
+	oct->reg_list.pci_win_rd_addr_hi =
+		(uint32_t __iomem *)(bar0_pciaddr + CN68XX_WIN_RD_ADDR_HI);
+	oct->reg_list.pci_win_rd_addr_lo =
+		(uint32_t __iomem *)(bar0_pciaddr + CN68XX_WIN_RD_ADDR_LO);
+	oct->reg_list.pci_win_rd_addr =
+		(uint64_t __iomem *)(bar0_pciaddr + CN68XX_WIN_RD_ADDR64);
+
+	oct->reg_list.pci_win_wr_data_hi =
+		(uint32_t __iomem *)(bar0_pciaddr + CN68XX_WIN_WR_DATA_HI);
+	oct->reg_list.pci_win_wr_data_lo =
+		(uint32_t __iomem *)(bar0_pciaddr + CN68XX_WIN_WR_DATA_LO);
+	oct->reg_list.pci_win_wr_data =
+		(uint64_t __iomem *)(bar0_pciaddr + CN68XX_WIN_WR_DATA64);
+
+	oct->reg_list.pci_win_rd_data_hi =
+		(uint32_t __iomem *)(bar0_pciaddr + CN68XX_WIN_RD_DATA_HI);
+	oct->reg_list.pci_win_rd_data_lo =
+		(uint32_t __iomem *)(bar0_pciaddr + CN68XX_WIN_RD_DATA_LO);
+	oct->reg_list.pci_win_rd_data =
+		(uint64_t __iomem *)(bar0_pciaddr + CN68XX_WIN_RD_DATA64);
+
+	cn68xx_get_pcie_qlmport(oct);
+
+	cn68xx->intr_sum_reg64 = bar0_pciaddr + CN68XX_SLI_INT_SUM64;
+	cn68xx->intr_enb_reg64 =
+		bar0_pciaddr + CN68XX_SLI_INT_ENB64(oct->pcie_port);
+	cn68xx->intr_mask64 = CN68XX_INTR_MASK;
+}
+
+static inline void cn68xx_vendor_message_fix(struct octeon_device *oct)
+{
+	uint32_t val = 0;
+
+	/* Set M_VEND1_DRP and M_VEND0_DRP bits */
+	pci_read_config_dword(oct->pci_dev, CN68XX_PCIE_FLTMSK, &val);
+	val |= 0x3;
+	pci_write_config_dword(oct->pci_dev, CN68XX_PCIE_FLTMSK, val);
+}
+
+int lio_setup_cn68xx_octeon_device(struct octeon_device *oct)
+{
+	struct octeon_cn68xx *cn68xx = (struct octeon_cn68xx *)oct->chip;
+
+	if (octeon_map_pci_barx(oct, 0, 0))
+		return 1;
+
+	if (octeon_map_pci_barx(oct, 1, MAX_BAR1_IOREMAP_SIZE)) {
+		lio_dev_err(oct, "%s CN68XX BAR1 map failed\n", __func__);
+		octeon_unmap_pci_barx(oct, 0);
+		return 1;
+	}
+
+	cn68xx->conf = (struct octeon_config *)oct_get_config_info(oct);
+	if (!cn68xx->conf) {
+		lio_dev_err(oct, "%s No Config found for CN68XX\n", __func__);
+		octeon_unmap_pci_barx(oct, 0);
+		octeon_unmap_pci_barx(oct, 1);
+		return 1;
+	}
+
+	spin_lock_init(&cn68xx->lock_for_droq_int_enb_reg);
+
+	oct->fn_list.setup_iq_regs = cn68xx_setup_iq_regs;
+	oct->fn_list.setup_oq_regs = cn68xx_setup_oq_regs;
+
+	oct->fn_list.process_interrupt_regs = cn68xx_process_interrupt_regs;
+	oct->fn_list.soft_reset = cn68xx_soft_reset;
+	oct->fn_list.setup_device_regs = cn68xx_setup_device_regs;
+	oct->fn_list.reinit_regs = cn68xx_reinit_regs;
+	oct->fn_list.update_iq_read_idx = cn68xx_update_read_index;
+
+	oct->fn_list.bar1_idx_setup = cn68xx_bar1_idx_setup;
+	oct->fn_list.bar1_idx_write = cn68xx_bar1_idx_write;
+	oct->fn_list.bar1_idx_read = cn68xx_bar1_idx_read;
+
+	oct->fn_list.enable_interrupt = cn68xx_enable_interrupt;
+	oct->fn_list.disable_interrupt = cn68xx_disable_interrupt;
+
+	oct->fn_list.enable_io_queues = cn68xx_enable_io_queues;
+	oct->fn_list.disable_io_queues = cn68xx_disable_io_queues;
+
+	cn68xx_setup_reg_address(oct);
+
+	oct->coproc_clock_rate = 1000000ULL * lio_cn6xxx_coprocessor_clock(oct);
+
+	cn68xx_vendor_message_fix(oct);
+
+	return 0;
+}
+
+int lio_validate_cn68xx_config_info(struct octeon_device *oct,
+				    struct octeon_config *conf68xx)
+{
+/*      int total_instrs = 0; */
+
+	if (CFG_GET_IQ_MAX_Q(conf68xx) > CN6XXX_MAX_INPUT_QUEUES) {
+		lio_dev_err(oct, "%s: Num IQ (%d) exceeds Max (%d)\n",
+			    __func__, CFG_GET_IQ_MAX_Q(conf68xx),
+			    CN6XXX_MAX_INPUT_QUEUES);
+		return 1;
+	}
+
+	if (CFG_GET_OQ_MAX_Q(conf68xx) > CN6XXX_MAX_OUTPUT_QUEUES) {
+		lio_dev_err(oct, "%s: Num OQ (%d) exceeds Max (%d)\n",
+			    __func__, CFG_GET_OQ_MAX_Q(conf68xx),
+			    CN6XXX_MAX_OUTPUT_QUEUES);
+		return 1;
+	}
+
+	if (CFG_GET_IQ_INSTR_TYPE(conf68xx) != OCTEON_32BYTE_INSTR &&
+	    CFG_GET_IQ_INSTR_TYPE(conf68xx) != OCTEON_64BYTE_INSTR) {
+		lio_dev_err(oct, "%s: Invalid instr type for IQ\n",
+			    __func__);
+		return 1;
+	}
+
+	if (!(CFG_GET_OQ_INFO_PTR(conf68xx)) ||
+	    !(CFG_GET_OQ_REFILL_THRESHOLD(conf68xx))) {
+		lio_dev_err(oct, "%s: Invalid parameter for OQ\n",
+			    __func__);
+		return 1;
+	}
+
+	if (!(CFG_GET_OQ_INTR_TIME(conf68xx))) {
+		lio_dev_err(oct, "%s: Invalid parameter for OQ\n",
+			    __func__);
+		return 1;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
new file mode 100644
index 0000000..692b067
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
@@ -0,0 +1,57 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/*! \file  cn68xx_device.h
+ *  \brief Host Driver: Routines that perform CN68XX specific operations.
+ */
+
+#ifndef __CN68XX_DEVICE_H__
+#define  __CN68XX_DEVICE_H__
+
+/* Register address and configuration for a CN68XX device. */
+struct octeon_cn68xx {
+	uint8_t __iomem *intr_sum_reg64;
+
+	uint8_t __iomem *intr_enb_reg64;
+
+	uint64_t intr_mask64;
+
+	struct octeon_config *conf;
+
+	/* For the purpose of atomic access to interrupt enable reg */
+	spinlock_t lock_for_droq_int_enb_reg;
+
+};
+
+void cn68xx_check_config_space_error_regs(struct octeon_device *oct);
+
+int lio_setup_cn68xx_octeon_device(struct octeon_device *oct);
+
+int lio_validate_cn68xx_config_info(struct octeon_device *oct,
+				    struct octeon_config *conf68xx);
+
+uint32_t cn68xx_get_oq_ticks(struct octeon_device *oct,
+			     uint32_t time_intr_in_us);
+
+uint32_t cn68xx_core_clock(struct octeon_device *oct);
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h b/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
new file mode 100644
index 0000000..98c0861
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
@@ -0,0 +1,505 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/*! \file cn68xx_regs.h
+ *  \brief Host Driver: Register Address and Register Mask values for
+ *  Octeon CN68XX devices.
+ */
+
+#ifndef __CN68XX_REGS_H__
+#define __CN68XX_REGS_H__
+
+#define     CN68XX_XPANSION_BAR                      0x30
+
+#define     CN68XX_PCIE_CAP                          0x70
+#define     CN68XX_PCIE_DEVCAP                       0x74
+#define     CN68XX_PCIE_DEVCTL                       0x78
+#define     CN68XX_PCIE_LINKCAP                      0x7C
+#define     CN68XX_PCIE_LINKCTL                      0x80
+#define     CN68XX_PCIE_SLOTCAP                      0x84
+#define     CN68XX_PCIE_SLOTCTL                      0x88
+
+#define     CN68XX_PCIE_FLTMSK                      0x720
+
+/* ##############  BAR0 Registers ################ */
+
+#define    CN68XX_SLI_CTL_PORT0                    0x0050
+#define    CN68XX_SLI_CTL_PORT1                    0x0060
+
+#define    CN68XX_SLI_WINDOW_CTL                   0x02E0
+#define    CN68XX_SLI_DBG_DATA                     0x0310
+#define    CN68XX_SLI_SCRATCH1                     0x03C0
+#define    CN68XX_SLI_SCRATCH2                     0x03D0
+#define    CN68XX_SLI_CTL_STATUS                   0x0570
+
+#define    CN68XX_WIN_WR_ADDR_LO                   0x0000
+#define    CN68XX_WIN_WR_ADDR_HI                   0x0004
+#define    CN68XX_WIN_WR_ADDR64                    CN68XX_WIN_WR_ADDR_LO
+
+#define    CN68XX_WIN_RD_ADDR_LO                   0x0010
+#define    CN68XX_WIN_RD_ADDR_HI                   0x0014
+#define    CN68XX_WIN_RD_ADDR64                    CN68XX_WIN_RD_ADDR_LO
+
+#define    CN68XX_WIN_WR_DATA_LO                   0x0020
+#define    CN68XX_WIN_WR_DATA_HI                   0x0024
+#define    CN68XX_WIN_WR_DATA64                    CN68XX_WIN_WR_DATA_LO
+
+#define    CN68XX_WIN_RD_DATA_LO                   0x0040
+#define    CN68XX_WIN_RD_DATA_HI                   0x0044
+#define    CN68XX_WIN_RD_DATA64                    CN68XX_WIN_RD_DATA_LO
+
+#define    CN68XX_WIN_WR_MASK_LO                   0x0030
+#define    CN68XX_WIN_WR_MASK_HI                   0x0034
+#define    CN68XX_WIN_WR_MASK_REG                  CN68XX_WIN_WR_MASK_LO
+
+/* 1 register (32-bit) to enable Input queues */
+#define    CN68XX_SLI_PKT_INSTR_ENB               0x1000
+
+/* 1 register (32-bit) to enable Output queues */
+#define    CN68XX_SLI_PKT_OUT_ENB                 0x1010
+
+/* 1 register (32-bit) to determine whether Output queues are in reset. */
+#define    CN68XX_SLI_PORT_IN_RST_OQ              0x11F0
+
+/* 1 register (32-bit) to determine whether Input queues are in reset. */
+#define    CN68XX_SLI_PORT_IN_RST_IQ              0x11F4
+
+/*###################### REQUEST QUEUE #########################*/
+
+/* 1 register (32-bit) - instr. size of each input queue. */
+#define    CN68XX_SLI_PKT_INSTR_SIZE             0x1020
+
+/* 32 registers for Input Queue Instr Count - SLI_PKT_IN_DONE0_CNTS */
+#define    CN68XX_SLI_IQ_INSTR_COUNT_START       0x2000
+
+/* 32 registers for Input Queue Start Addr - SLI_PKT0_INSTR_BADDR */
+#define    CN68XX_SLI_IQ_BASE_ADDR_START64       0x2800
+
+/* 32 registers for Input Doorbell - SLI_PKT0_INSTR_BAOFF_DBELL */
+#define    CN68XX_SLI_IQ_DOORBELL_START          0x2C00
+
+/* 32 registers for Input Queue size - SLI_PKT0_INSTR_FIFO_RSIZE */
+#define    CN68XX_SLI_IQ_SIZE_START              0x3000
+
+/* 32 registers for Instruction Header Options - SLI_PKT0_INSTR_HEADER */
+#define    CN68XX_SLI_IQ_PKT_INSTR_HDR_START64   0x3400
+
+#define    CN68XX_SLI_IQ_PORT0_PKIND             0x0800
+
+/* 1 register (64-bit) - Back Pressure for each input queue - SLI_PKT0_IN_BP */
+#define    CN68XX_SLI_INPUT_BP_START64           0x3800
+
+/* Each Input Queue register is at a 16-byte Offset in BAR0 */
+#define    CN68XX_IQ_OFFSET                      0x10
+
+/* 1 register (32-bit) - ES, RO, NS, Arbitration for Input Queue Data &
+ * gather list fetches. SLI_PKT_INPUT_CONTROL.
+ */
+#define    CN68XX_SLI_PKT_INPUT_CONTROL          0x1170
+
+/* 1 register (64-bit) - Number of instructions to read at one time
+ * - 2 bits for each input ring. SLI_PKT_INSTR_RD_SIZE.
+ */
+#define    CN68XX_SLI_PKT_INSTR_RD_SIZE          0x11A0
+
+/* 1 register (64-bit) - Assign Input ring to MAC port
+ * - 2 bits for each input ring. SLI_PKT_IN_PCIE_PORT.
+ */
+#define    CN68XX_SLI_IN_PCIE_PORT               0x11B0
+
+/*------- Request Queue Macros ---------*/
+#define    CN68XX_SLI_IQ_BASE_ADDR64(iq)          \
+	(CN68XX_SLI_IQ_BASE_ADDR_START64 + ((iq) * CN68XX_IQ_OFFSET))
+
+#define    CN68XX_SLI_IQ_SIZE(iq)                 \
+	(CN68XX_SLI_IQ_SIZE_START + ((iq) * CN68XX_IQ_OFFSET))
+
+#define    CN68XX_SLI_IQ_PKT_INSTR_HDR64(iq)      \
+	(CN68XX_SLI_IQ_PKT_INSTR_HDR_START64 + ((iq) * CN68XX_IQ_OFFSET))
+
+#define    CN68XX_SLI_IQ_DOORBELL(iq)             \
+	(CN68XX_SLI_IQ_DOORBELL_START + ((iq) * CN68XX_IQ_OFFSET))
+
+#define    CN68XX_SLI_IQ_INSTR_COUNT(iq)          \
+	(CN68XX_SLI_IQ_INSTR_COUNT_START + ((iq) * CN68XX_IQ_OFFSET))
+
+#define    CN68XX_SLI_IQ_BP64(iq)                 \
+	(CN68XX_SLI_INPUT_BP_START64 + ((iq) * CN68XX_IQ_OFFSET))
+
+#define    CN68XX_SLI_IQ_PORT_PKIND(iq)           \
+	(CN68XX_SLI_IQ_PORT0_PKIND + ((iq) * CN68XX_IQ_OFFSET))
+
+/*------------------ Masks ----------------*/
+#define    CN68XX_INPUT_CTL_ROUND_ROBIN_ARB         BIT(22)
+#define    CN68XX_INPUT_CTL_DATA_NS                 BIT(8)
+#define    CN68XX_INPUT_CTL_DATA_ES_64B_SWAP        BIT(6)
+#define    CN68XX_INPUT_CTL_DATA_RO                 BIT(5)
+#define    CN68XX_INPUT_CTL_USE_CSR                 BIT(4)
+#define    CN68XX_INPUT_CTL_GATHER_NS               BIT(3)
+#define    CN68XX_INPUT_CTL_GATHER_ES_64B_SWAP      BIT(2)
+#define    CN68XX_INPUT_CTL_GATHER_RO               BIT(1)
+
+#ifdef __BIG_ENDIAN_BITFIELD
+#define    CN68XX_INPUT_CTL_MASK                    \
+	(CN68XX_INPUT_CTL_DATA_ES_64B_SWAP      \
+	  | CN68XX_INPUT_CTL_USE_CSR              \
+	  | CN68XX_INPUT_CTL_GATHER_ES_64B_SWAP)
+#else
+#define    CN68XX_INPUT_CTL_MASK                    \
+	(CN68XX_INPUT_CTL_DATA_ES_64B_SWAP     \
+	  | CN68XX_INPUT_CTL_USE_CSR)
+#endif
+
+/*############################ OUTPUT QUEUE #########################*/
+
+/* 32 registers for Output queue buffer and info size - SLI_PKT0_OUT_SIZE */
+#define    CN68XX_SLI_OQ0_BUFF_INFO_SIZE         0x0C00
+
+/* 32 registers for Output Queue Start Addr - SLI_PKT0_SLIST_BADDR */
+#define    CN68XX_SLI_OQ_BASE_ADDR_START64       0x1400
+
+/* 32 registers for Output Queue Packet Credits - SLI_PKT0_SLIST_BAOFF_DBELL */
+#define    CN68XX_SLI_OQ_PKT_CREDITS_START       0x1800
+
+/* 32 registers for Output Queue size - SLI_PKT0_SLIST_FIFO_RSIZE */
+#define    CN68XX_SLI_OQ_SIZE_START              0x1C00
+
+/* 32 registers for Output Queue Packet Count - SLI_PKT0_CNTS */
+#define    CN68XX_SLI_OQ_PKT_SENT_START          0x2400
+
+/* Each Output Queue register is at a 16-byte Offset in BAR0 */
+#define    CN68XX_OQ_OFFSET                      0x10
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - Relaxed Ordering setting for reading Output Queues descriptors
+ * - SLI_PKT_SLIST_ROR
+ */
+#define    CN68XX_SLI_PKT_SLIST_ROR              0x1030
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - No Snoop mode for reading Output Queues descriptors
+ * - SLI_PKT_SLIST_NS
+ */
+#define    CN68XX_SLI_PKT_SLIST_NS               0x1040
+
+/* 1 register (64-bit) - 2 bits for each output queue
+ * - Endian-Swap mode for reading Output Queue descriptors
+ * - SLI_PKT_SLIST_ES
+ */
+#define    CN68XX_SLI_PKT_SLIST_ES64             0x1050
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - InfoPtr mode for Output Queues.
+ * - SLI_PKT_IPTR
+ */
+#define    CN68XX_SLI_PKT_IPTR                   0x1070
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - DPTR format selector for Output queues.
+ * - SLI_PKT_DPADDR
+ */
+#define    CN68XX_SLI_PKT_DPADDR                 0x1080
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - Relaxed Ordering setting for reading Output Queues data
+ * - SLI_PKT_DATA_OUT_ROR
+ */
+#define    CN68XX_SLI_PKT_DATA_OUT_ROR           0x1090
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - No Snoop mode for reading Output Queues data
+ * - SLI_PKT_DATA_OUT_NS
+ */
+#define    CN68XX_SLI_PKT_DATA_OUT_NS            0x10A0
+
+/* 1 register (64-bit)  - 2 bits for each output queue
+ * - Endian-Swap mode for reading Output Queue data
+ * - SLI_PKT_DATA_OUT_ES
+ */
+#define    CN68XX_SLI_PKT_DATA_OUT_ES64          0x10B0
+
+/* 1 register (32-bit) - 1 bit for each output queue
+ * - Controls whether SLI_PKTn_CNTS is incremented for bytes or for packets.
+ * - SLI_PKT_OUT_BMODE
+ */
+#define    CN68XX_SLI_PKT_OUT_BMODE              0x10D0
+
+/* 1 register (64-bit) - 2 bits for each output queue
+ * - Assign PCIE port for Output queues
+ * - SLI_PKT_PCIE_PORT.
+ */
+#define    CN68XX_SLI_PKT_PCIE_PORT64            0x10E0
+
+/* 1 (64-bit) register for Output Queue Packet Count Interrupt Threshold
+ * & Time Threshold. The same setting applies to all 32 queues.
+ * The register is defined as a 64-bit registers, but we use the
+ * 32-bit offsets to define distinct addresses.
+ */
+#define    CN68XX_SLI_OQ_INT_LEVEL_PKTS          0x1120
+#define    CN68XX_SLI_OQ_INT_LEVEL_TIME          0x1124
+
+/* 1 (64-bit register) for Output Queue backpressure across all rings. */
+#define    CN68XX_SLI_OQ_WMARK                   0x1180
+
+/* 1 register to control output queue global backpressure & ring enable. */
+#define    CN68XX_SLI_PKT_CTL                                    0x1220
+
+#define    CN68XX_SLI_TX_PIPE                    0x1230
+
+/*------- Output Queue Macros ---------*/
+#define    CN68XX_SLI_OQ_BASE_ADDR64(oq)          \
+	(CN68XX_SLI_OQ_BASE_ADDR_START64 + ((oq) * CN68XX_OQ_OFFSET))
+
+#define    CN68XX_SLI_OQ_SIZE(oq)                 \
+	(CN68XX_SLI_OQ_SIZE_START + ((oq) * CN68XX_OQ_OFFSET))
+
+#define    CN68XX_SLI_OQ_BUFF_INFO_SIZE(oq)                 \
+	(CN68XX_SLI_OQ0_BUFF_INFO_SIZE + ((oq) * CN68XX_OQ_OFFSET))
+
+#define    CN68XX_SLI_OQ_PKTS_SENT(oq)            \
+	(CN68XX_SLI_OQ_PKT_SENT_START + ((oq) * CN68XX_OQ_OFFSET))
+
+#define    CN68XX_SLI_OQ_PKTS_CREDIT(oq)          \
+	(CN68XX_SLI_OQ_PKT_CREDITS_START + ((oq) * CN68XX_OQ_OFFSET))
+
+/*######################### DMA Counters #########################*/
+
+/* 2 registers (64-bit) - DMA Count - 1 for each DMA counter 0/1. */
+#define    CN68XX_DMA_CNT_START                   0x0400
+
+/* 2 registers (64-bit) - DMA Timer 0/1, contains DMA timer values
+ * SLI_DMA_0_TIM
+ */
+#define    CN68XX_DMA_TIM_START                   0x0420
+
+/* 2 registers (64-bit) - DMA count & Time Interrupt threshold -
+ * SLI_DMA_0_INT_LEVEL
+ */
+#define    CN68XX_DMA_INT_LEVEL_START             0x03E0
+
+/* Each DMA register is at a 16-byte Offset in BAR0 */
+#define    CN68XX_DMA_OFFSET                      0x10
+
+/*---------- DMA Counter Macros ---------*/
+#define    CN68XX_DMA_CNT(dq)                      \
+	(CN68XX_DMA_CNT_START + ((dq) * CN68XX_DMA_OFFSET))
+
+#define    CN68XX_DMA_INT_LEVEL(dq)                \
+	(CN68XX_DMA_INT_LEVEL_START + ((dq) * CN68XX_DMA_OFFSET))
+
+#define    CN68XX_DMA_PKT_INT_LEVEL(dq)            \
+	(CN68XX_DMA_INT_LEVEL_START + ((dq) * CN68XX_DMA_OFFSET))
+
+#define    CN68XX_DMA_TIME_INT_LEVEL(dq)           \
+	(CN68XX_DMA_INT_LEVEL_START + 4 + ((dq) * CN68XX_DMA_OFFSET))
+
+#define    CN68XX_DMA_TIM(dq)                     \
+	(CN68XX_DMA_TIM_START + ((dq) * CN68XX_DMA_OFFSET))
+
+/*######################## INTERRUPTS #########################*/
+
+/* 1 register (64-bit) for Interrupt Summary */
+#define    CN68XX_SLI_INT_SUM64                  0x0330
+
+/* 1 register (64-bit) for Interrupt Enable */
+#define    CN68XX_SLI_INT_ENB64_PORT0            0x0340
+#define    CN68XX_SLI_INT_ENB64_PORT1            0x0350
+
+/* 1 register (32-bit) to enable Output Queue Packet/Byte Count Interrupt */
+#define    CN68XX_SLI_PKT_CNT_INT_ENB            0x1150
+
+/* 1 register (32-bit) to enable Output Queue Packet Timer Interrupt */
+#define    CN68XX_SLI_PKT_TIME_INT_ENB           0x1160
+
+/* 1 register (32-bit) to indicate which Output Queue reached pkt threshold */
+#define    CN68XX_SLI_PKT_CNT_INT                0x1130
+
+/* 1 register (32-bit) to indicate which Output Queue reached time threshold */
+#define    CN68XX_SLI_PKT_TIME_INT               0x1140
+
+/*------------------ Interrupt Masks ----------------*/
+
+#define    CN68XX_INTR_RML_TIMEOUT_ERR           BIT(1)
+#define    CN68XX_INTR_BAR0_RW_TIMEOUT_ERR       BIT(2)
+#define    CN68XX_INTR_IO2BIG_ERR                BIT(3)
+#define    CN68XX_INTR_PKT_COUNT                 BIT(4)
+#define    CN68XX_INTR_PKT_TIME                  BIT(5)
+#define    CN68XX_INTR_M0UPB0_ERR                BIT(8)
+#define    CN68XX_INTR_M0UPWI_ERR                BIT(9)
+#define    CN68XX_INTR_M0UNB0_ERR                BIT(10)
+#define    CN68XX_INTR_M0UNWI_ERR                BIT(11)
+#define    CN68XX_INTR_M1UPB0_ERR                BIT(12)
+#define    CN68XX_INTR_M1UPWI_ERR                BIT(13)
+#define    CN68XX_INTR_M1UNB0_ERR                BIT(14)
+#define    CN68XX_INTR_M1UNWI_ERR                BIT(15)
+#define    CN68XX_INTR_MIO_INT0                  BIT(16)
+#define    CN68XX_INTR_MIO_INT1                  BIT(17)
+#define    CN68XX_INTR_MAC_INT0                  BIT(18)
+#define    CN68XX_INTR_MAC_INT1                  BIT(19)
+
+#define    CN68XX_INTR_DMA0_FORCE                BIT_ULL(32)
+#define    CN68XX_INTR_DMA1_FORCE                BIT_ULL(33)
+#define    CN68XX_INTR_DMA0_COUNT                BIT_ULL(34)
+#define    CN68XX_INTR_DMA1_COUNT                BIT_ULL(35)
+#define    CN68XX_INTR_DMA0_TIME                 BIT_ULL(36)
+#define    CN68XX_INTR_DMA1_TIME                 BIT_ULL(37)
+#define    CN68XX_INTR_INSTR_DB_OF_ERR           BIT_ULL(48)
+#define    CN68XX_INTR_SLIST_DB_OF_ERR           BIT_ULL(49)
+#define    CN68XX_INTR_POUT_ERR                  BIT_ULL(50)
+#define    CN68XX_INTR_PIN_BP_ERR                BIT_ULL(51)
+#define    CN68XX_INTR_PGL_ERR                   BIT_ULL(52)
+#define    CN68XX_INTR_PDI_ERR                   BIT_ULL(53)
+#define    CN68XX_INTR_POP_ERR                   BIT_ULL(54)
+#define    CN68XX_INTR_PINS_ERR                  BIT_ULL(55)
+#define    CN68XX_INTR_SPRT0_ERR                 BIT_ULL(56)
+#define    CN68XX_INTR_SPRT1_ERR                 BIT_ULL(57)
+#define    CN68XX_INTR_ILL_PAD_ERR               BIT_ULL(60)
+#define    CN68XX_INTR_PIPE_ERR                  BIT_ULL(61)
+
+#define    CN68XX_INTR_DMA0_DATA                 (CN68XX_INTR_DMA0_TIME)
+
+#define    CN68XX_INTR_DMA1_DATA                 (CN68XX_INTR_DMA1_TIME)
+
+#define    CN68XX_INTR_DMA_DATA                  \
+	(CN68XX_INTR_DMA0_DATA | CN68XX_INTR_DMA1_DATA)
+
+#define    CN68XX_INTR_PKT_DATA                  (CN68XX_INTR_PKT_TIME)
+
+/* Sum of interrupts for all PCI-Express Data Interrupts */
+#define    CN68XX_INTR_PCIE_DATA                 \
+	(CN68XX_INTR_DMA_DATA | CN68XX_INTR_PKT_DATA)
+
+#define    CN68XX_INTR_MIO                       \
+	(CN68XX_INTR_MIO_INT0 | CN68XX_INTR_MIO_INT1)
+
+#define    CN68XX_INTR_MAC                       \
+	(CN68XX_INTR_MAC_INT0 | CN68XX_INTR_MAC_INT1)
+
+/* Sum of interrupts for error events */
+#define    CN68XX_INTR_ERR                       \
+	(CN68XX_INTR_BAR0_RW_TIMEOUT_ERR    \
+	   | CN68XX_INTR_IO2BIG_ERR             \
+	   | CN68XX_INTR_M0UPB0_ERR             \
+	   | CN68XX_INTR_M0UPWI_ERR             \
+	   | CN68XX_INTR_M0UNB0_ERR             \
+	   | CN68XX_INTR_M0UNWI_ERR             \
+	   | CN68XX_INTR_M1UPB0_ERR             \
+	   | CN68XX_INTR_M1UPWI_ERR             \
+	   | CN68XX_INTR_M1UPB0_ERR             \
+	   | CN68XX_INTR_M1UNWI_ERR             \
+	   | CN68XX_INTR_INSTR_DB_OF_ERR        \
+	   | CN68XX_INTR_SLIST_DB_OF_ERR        \
+	   | CN68XX_INTR_POUT_ERR               \
+	   | CN68XX_INTR_PIN_BP_ERR             \
+	   | CN68XX_INTR_PGL_ERR                \
+	   | CN68XX_INTR_PDI_ERR                \
+	   | CN68XX_INTR_POP_ERR                \
+	   | CN68XX_INTR_PINS_ERR               \
+	   | CN68XX_INTR_SPRT0_ERR              \
+	   | CN68XX_INTR_SPRT1_ERR              \
+	   | CN68XX_INTR_ILL_PAD_ERR)
+
+/* Programmed Mask for Interrupt Sum */
+#define    CN68XX_INTR_MASK                      \
+	(CN68XX_INTR_PCIE_DATA              \
+	   | CN68XX_INTR_DMA0_FORCE             \
+	   | CN68XX_INTR_DMA1_FORCE             \
+	   | CN68XX_INTR_MIO                    \
+	   | CN68XX_INTR_MAC                    \
+	   | CN68XX_INTR_ERR)
+
+#define    CN68XX_SLI_S2M_PORT0_CTL              0x3D80
+#define    CN68XX_SLI_S2M_PORT1_CTL              0x3D90
+#define    CN68XX_SLI_S2M_PORTX_CTL(port)        \
+	(CN68XX_SLI_S2M_PORT0_CTL + (port * 0x10))
+
+#define    CN68XX_SLI_INT_ENB64(port)            \
+	(CN68XX_SLI_INT_ENB64_PORT0 + (port * 0x10))
+
+#define    CN68XX_SLI_MAC_NUMBER                 0x3E00
+
+/* CN63XX BAR1 Index registers. */
+#define    CN68XX_PEM_OFFSET                       0x0000000001000000ULL
+#define    CN68XX_PEM_BAR1_INDEX000                0x00011800C00000A8ULL
+
+#define    CN68XX_BAR1_INDEX_START                 CN68XX_PEM_BAR1_INDEX000
+#define    CN68XX_PCI_BAR1_OFFSET                  0x8
+
+#define    CN68XX_BAR1_INDEX_REG(idx, port)              \
+		(CN68XX_BAR1_INDEX_START + (port * CN68XX_PEM_OFFSET) + \
+		(CN68XX_PCI_BAR1_OFFSET * (idx)))
+
+/*############################ DPI #########################*/
+
+#define    CN68XX_DPI_CTL                 0x0001df0000000040ULL
+
+#define    CN68XX_DPI_DMA_CONTROL         0x0001df0000000048ULL
+
+#define    CN68XX_DPI_REQ_GBL_ENB         0x0001df0000000050ULL
+
+#define    CN68XX_DPI_REQ_ERR_RSP         0x0001df0000000058ULL
+
+#define    CN68XX_DPI_REQ_ERR_RST         0x0001df0000000060ULL
+
+#define    CN68XX_DPI_DMA_ENG0_ENB        0x0001df0000000080ULL
+
+#define    CN68XX_DPI_DMA_ENG_ENB(q_no)   \
+	(CN68XX_DPI_DMA_ENG0_ENB + (q_no * 8))
+
+#define    CN68XX_DPI_DMA_ENG0_BUF        0x0001df0000000880ULL
+
+#define    CN68XX_DPI_DMA_ENG_BUF(q_no)   \
+	(CN68XX_DPI_DMA_ENG0_BUF + (q_no * 8))
+
+#define    CN68XX_DPI_SLI_PRT0_CFG        0x0001df0000000900ULL
+#define    CN68XX_DPI_SLI_PRT1_CFG        0x0001df0000000908ULL
+#define    CN68XX_DPI_SLI_PRTX_CFG(port)        \
+	(CN68XX_DPI_SLI_PRT0_CFG + (port * 0x10))
+
+#define    CN68XX_DPI_DMA_COMMIT_MODE     BIT_ULL(58)
+#define    CN68XX_DPI_DMA_PKT_HP          BIT_ULL(57)
+#define    CN68XX_DPI_DMA_PKT_EN          BIT_ULL(56)
+#define    CN68XX_DPI_DMA_O_ES            BIT(15)
+#define    CN68XX_DPI_DMA_O_MODE          BIT(14)
+
+#define    CN68XX_DPI_DMA_CTL_MASK             \
+	(CN68XX_DPI_DMA_COMMIT_MODE    |    \
+	 CN68XX_DPI_DMA_PKT_HP         |    \
+	 CN68XX_DPI_DMA_PKT_EN         |    \
+	 CN68XX_DPI_DMA_O_ES           |    \
+	 CN68XX_DPI_DMA_O_MODE)
+
+/*############################ CIU #########################*/
+
+#define    CN68XX_CIU_SOFT_BIST           0x0001070000000738ULL
+#define    CN68XX_CIU_SOFT_RST            0x0001070000000740ULL
+
+/*############################ MIO #########################*/
+
+#define    CN68XX_MIO_RST_BOOT            0x0001180000001600ULL
+
+/*############################ LMC #########################*/
+
+#define    CN68XX_LMC0_RESET_CTL               0x0001180088000180ULL
+#define    CN68XX_LMC0_RESET_CTL_DDR3RST_MASK  0x0000000000000001ULL
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
new file mode 100644
index 0000000..c67071b
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -0,0 +1,1488 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#include <linux/version.h>
+#include <linux/netdevice.h>
+#include <linux/net_tstamp.h>
+#include <linux/ethtool.h>
+#include <linux/pci.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+
+struct oct_mdio_cmd_resp {
+	struct {
+		int octeon_id;
+		wait_queue_head_t wc;
+		int cond;
+	} s;
+	uint64_t rh;
+	struct oct_mdio_cmd resp;
+	uint64_t status;
+};
+
+#define OCT_MDIO45_RESP_SIZE   (sizeof(struct oct_mdio_cmd_resp))
+
+/* Octeon's interface mode of operation */
+enum {
+	INTERFACE_MODE_DISABLED,
+	INTERFACE_MODE_RGMII,
+	INTERFACE_MODE_GMII,
+	INTERFACE_MODE_SPI,
+	INTERFACE_MODE_PCIE,
+	INTERFACE_MODE_XAUI,
+	INTERFACE_MODE_SGMII,
+	INTERFACE_MODE_PICMG,
+	INTERFACE_MODE_NPI,
+	INTERFACE_MODE_LOOP,
+	INTERFACE_MODE_SRIO,
+	INTERFACE_MODE_ILK,
+	INTERFACE_MODE_RXAUI,
+	INTERFACE_MODE_QSGMII,
+	INTERFACE_MODE_AGL,
+};
+
+#define ARRAY_LENGTH(a) (sizeof(a) / sizeof((a)[0]))
+#define OCT_ETHTOOL_REGDUMP_LEN  4096
+#define OCT_ETHTOOL_REGSVER  1
+
+static const char oct_iq_stats_strings[][ETH_GSTRING_LEN] = {
+	"Instr posted",
+	"Instr processed",
+	"Instr dropped",
+	"Bytes Sent",
+	"Sgentry_sent",
+	"Inst cntreg",
+	"Tx done",
+	"Tx Iq busy",
+	"Tx dropped",
+	"Tx bytes",
+};
+
+static const char oct_droq_stats_strings[][ETH_GSTRING_LEN] = {
+	"OQ Pkts Received",
+	"OQ Bytes Received",
+	"Dropped no dispatch",
+	"Dropped nomem",
+	"Dropped toomany",
+	"Stack RX cnt",
+	"Stack RX Bytes",
+	"RX dropped",
+};
+
+#define OCTNIC_NCMD_AUTONEG_ON  0x1
+#define OCTNIC_NCMD_PHY_ON      0x2
+
+static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct oct_link_info *linfo;
+
+	linfo = &lio->linfo;
+
+	if (linfo->link.s.interface == INTERFACE_MODE_XAUI ||
+	    linfo->link.s.interface == INTERFACE_MODE_RXAUI) {
+		ecmd->port = PORT_FIBRE;
+		ecmd->supported =
+			(SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE |
+			 SUPPORTED_Pause);
+		ecmd->advertising =
+			(ADVERTISED_10000baseT_Full | ADVERTISED_Pause);
+		ecmd->transceiver = XCVR_EXTERNAL;
+		ecmd->autoneg = AUTONEG_DISABLE;
+
+	} else {
+		lio_dev_err(oct, "Unknown link interface reported\n");
+	}
+
+	if (linfo->link.s.status) {
+		ethtool_cmd_speed_set(ecmd, linfo->link.s.speed);
+		ecmd->duplex = linfo->link.s.duplex;
+	} else {
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
+	}
+
+	return 0;
+}
+
+static void
+lio_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+{
+	struct lio *lio;
+	struct octeon_device *oct;
+
+	lio = GET_LIO(netdev);
+	oct = lio->oct_dev;
+
+	memset(drvinfo, 0, sizeof(struct ethtool_drvinfo));
+	strcpy(drvinfo->driver, "liquidio");
+	strcpy(drvinfo->version, LIQUIDIO_VERSION);
+	strncpy(drvinfo->fw_version, oct->fw_info.liquidio_firmware_version,
+		ETHTOOL_FWVERS_LEN);
+	strncpy(drvinfo->bus_info, pci_name(oct->pci_dev), 32);
+	drvinfo->regdump_len = OCT_ETHTOOL_REGDUMP_LEN;
+}
+
+static void
+lio_ethtool_get_channels(struct net_device *dev,
+			 struct ethtool_channels *channel)
+{
+	struct lio *lio = GET_LIO(dev);
+	struct octeon_device *oct = lio->oct_dev;
+	uint32_t max_rx = 0, max_tx = 0, tx_count = 0, rx_count = 0;
+
+	if (oct->chip_id == OCTEON_CN66XX) {
+		struct octeon_config *conf6x = CHIP_FIELD(oct, cn6xxx, conf);
+
+		max_rx = CFG_GET_OQ_MAX_Q(conf6x);
+		max_tx = CFG_GET_IQ_MAX_Q(conf6x);
+		rx_count = CFG_GET_NUM_RXQS_NIC_IF(conf6x, lio->ifidx);
+		tx_count = CFG_GET_NUM_TXQS_NIC_IF(conf6x, lio->ifidx);
+	}
+
+	if (oct->chip_id == OCTEON_CN68XX) {
+		struct octeon_config *conf68 = CHIP_FIELD(oct, cn68xx, conf);
+
+		max_rx = CFG_GET_OQ_MAX_Q(conf68);
+		max_tx = CFG_GET_IQ_MAX_Q(conf68);
+		rx_count = CFG_GET_NUM_RXQS_NIC_IF(conf68, lio->ifidx);
+		tx_count = CFG_GET_NUM_TXQS_NIC_IF(conf68, lio->ifidx);
+	}
+
+	channel->max_rx = max_rx;
+	channel->max_tx = max_tx;
+	channel->rx_count = rx_count;
+	channel->tx_count = tx_count;
+}
+
+static int lio_get_eeprom_len(struct net_device *netdev)
+{
+	uint8_t buf[128];
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+	struct octeon_board_info *board_info;
+	int len;
+
+	board_info = (struct octeon_board_info *)(&oct_dev->boardinfo);
+	len = sprintf(buf, "boardname:%s serialnum:%s maj:%lld min:%lld\n",
+		      board_info->name, board_info->serial_number,
+		      board_info->major, board_info->minor);
+
+	return len;
+}
+
+static int
+lio_get_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
+	       u8 *bytes)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+	struct octeon_board_info *board_info;
+	int len;
+
+	if (eeprom->offset != 0)
+		return -EINVAL;
+
+	eeprom->magic = oct_dev->pci_dev->vendor;
+	board_info = (struct octeon_board_info *)(&oct_dev->boardinfo);
+	len =
+		sprintf((char *)bytes,
+			"boardname:%s serialnum:%s maj:%lld min:%lld\n",
+			board_info->name, board_info->serial_number,
+			board_info->major, board_info->minor);
+
+	return 0;
+}
+
+static int octnet_gpio_access(struct net_device *netdev, int addr, int val)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	struct octnic_ctrl_params nparams;
+	int ret = 0;
+
+	ret = liquidio_alloc_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		lio_dev_err(oct, "Failed to configure gpio value\n");
+		return -EINVAL;
+	}
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_GPIO_ACCESS;
+	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
+	nctrl.ncmd.s.param2 = addr;
+	nctrl.ncmd.s.param3 = val;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (uint64_t)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	nparams.resp_order = OCTEON_RESP_ORDERED;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	if (ret < 0) {
+		liquidio_free_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+		lio_dev_err(oct, "Failed to configure gpio value\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* Callback for when mdio command response arrives
+ */
+static void octnet_mdio_resp_callback(struct octeon_device *oct,
+				      uint32_t status,
+				      void *buf)
+{
+	struct oct_mdio_cmd_resp *mdio_cmd_rsp;
+
+	mdio_cmd_rsp = (struct oct_mdio_cmd_resp *)buf;
+	oct = lio_get_device(mdio_cmd_rsp->s.octeon_id);
+	if (status) {
+		lio_dev_err(oct, "MIDO instruction failed. Status: %llx\n",
+			    CVM_CAST64(status));
+		ACCESS_ONCE(mdio_cmd_rsp->s.cond) = -1;
+	} else {
+		ACCESS_ONCE(mdio_cmd_rsp->s.cond) = 1;
+	}
+	wake_up_interruptible(&mdio_cmd_rsp->s.wc);
+}
+
+/* This routine provides PHY access routines for
+ * mdio  clause45 .
+ */
+static int
+octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
+{
+	struct octeon_device *oct_dev = lio->oct_dev;
+	struct octeon_soft_command *sc;
+	struct oct_mdio_cmd_resp *mdio_cmd_rsp;
+	struct oct_mdio_cmd *mdio_cmd;
+	int retval = 0;
+	unsigned char *buf;
+	size_t bufsize;
+	uint64_t data;
+	size_t datasize;
+	uint64_t rdata;
+	size_t rdatasize;
+	dma_addr_t dma_addr;
+
+	bufsize = sizeof(struct octeon_soft_command) +
+		  sizeof(struct oct_mdio_cmd_resp) +
+		  sizeof(struct oct_mdio_cmd);
+
+	buf = kmalloc(bufsize, GFP_KERNEL);
+
+	if (!buf)
+		return -ENOMEM;
+
+	memset(buf, 0, bufsize);
+
+	sc = (struct octeon_soft_command *)buf;
+	mdio_cmd_rsp = (struct oct_mdio_cmd_resp *)(sc + 1);
+	mdio_cmd = (struct oct_mdio_cmd *)(mdio_cmd_rsp + 1);
+
+	ACCESS_ONCE(mdio_cmd_rsp->s.cond) = 0;
+	mdio_cmd_rsp->s.octeon_id = lio_get_device_id(oct_dev);
+	mdio_cmd->op = op;
+	mdio_cmd->mdio_addr = loc;
+	if (op)
+		mdio_cmd->value1 = *value;
+	mdio_cmd->value2 = lio->linfo.ifidx;
+	octeon_swap_8B_data((uint64_t *)mdio_cmd,
+			    sizeof(struct oct_mdio_cmd) / 8);
+
+	datasize = sizeof(struct oct_mdio_cmd);
+	dma_addr = pci_map_single(oct_dev->pci_dev, mdio_cmd, datasize,
+				  PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(oct_dev->pci_dev, dma_addr)) {
+		lio_dev_err(oct_dev, "%s DMA mapping error for mdio_cmd\n",
+			    __func__);
+		kfree(buf);
+		return -ENOMEM;
+	}
+	data = (uint64_t)dma_addr;
+
+	rdatasize = OCT_MDIO45_RESP_SIZE - sizeof(mdio_cmd_rsp->s);
+	dma_addr = pci_map_single(oct_dev->pci_dev, &mdio_cmd_rsp->rh,
+				  rdatasize, PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(oct_dev->pci_dev, dma_addr)) {
+		lio_dev_err(oct_dev, "%s DMA mapping error for mdio_cmd_rsp\n",
+			    __func__);
+		pci_unmap_single(oct_dev->pci_dev, data, datasize,
+				 PCI_DMA_TODEVICE);
+		kfree(buf);
+		return -ENOMEM;
+	}
+	rdata = (uint64_t)dma_addr;
+
+	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC, OPCODE_NIC_MDIO45,
+				    0, 0, 0,
+				    mdio_cmd, data, datasize,
+				    &mdio_cmd_rsp->rh, rdata, rdatasize);
+
+	sc->wait_time = 1000;
+	sc->callback = octnet_mdio_resp_callback;
+	sc->callback_arg = mdio_cmd_rsp;
+
+	init_waitqueue_head(&mdio_cmd_rsp->s.wc);
+
+	retval = octeon_send_soft_command(oct_dev, sc);
+
+	if (retval) {
+		lio_dev_err(oct_dev,
+			    "octnet_mdio45_access instruction failed status: %x\n",
+			    retval);
+		retval =  -EBUSY;
+	} else {
+		/* Sleep on a wait queue till the cond flag indicates that the
+		 * response arrived
+		 */
+		sleep_cond(&mdio_cmd_rsp->s.wc, &mdio_cmd_rsp->s.cond);
+		retval = mdio_cmd_rsp->status;
+		if (retval) {
+			lio_dev_err(oct_dev, "octnet mdio45 access failed\n");
+			retval = -EBUSY;
+		} else {
+			octeon_swap_8B_data((uint64_t *)(&mdio_cmd_rsp->resp),
+					    sizeof(struct oct_mdio_cmd) / 8);
+
+			if (ACCESS_ONCE(mdio_cmd_rsp->s.cond) == 1) {
+				if (!op)
+					*value = mdio_cmd_rsp->resp.value1;
+			} else {
+				retval = -EINVAL;
+			}
+		}
+	}
+
+	pci_unmap_single(oct_dev->pci_dev, data, datasize, PCI_DMA_TODEVICE);
+	pci_unmap_single(oct_dev->pci_dev, rdata, rdatasize,
+			 PCI_DMA_FROMDEVICE);
+
+	kfree(buf);
+
+	return retval;
+}
+
+static int lio_set_phys_id(struct net_device *netdev,
+			   enum ethtool_phys_id_state state)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	int value, ret;
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		if (oct->chip_id == OCTEON_CN66XX) {
+			octnet_gpio_access(netdev, VITESSE_PHY_GPIO_CFG,
+					   VITESSE_PHY_GPIO_DRIVEON);
+			return 2;
+
+		} else if (oct->chip_id == OCTEON_CN68XX) {
+			/* Save the current LED settings */
+			ret = octnet_mdio45_access(lio, 0,
+						   LIO68XX_LED_BEACON_ADDR,
+						   &lio->phy_beacon_val);
+			if (ret)
+				return ret;
+
+			ret = octnet_mdio45_access(lio, 0,
+						   LIO68XX_LED_CTRL_ADDR,
+						   &lio->led_ctrl_val);
+			if (ret)
+				return ret;
+
+			/* Configure Beacon values */
+			value = LIO68XX_LED_BEACON_CFGON;
+			ret =
+				octnet_mdio45_access(lio, 1,
+						     LIO68XX_LED_BEACON_ADDR,
+						     &value);
+			if (ret)
+				return ret;
+
+			value = LIO68XX_LED_CTRL_CFGON;
+			ret =
+				octnet_mdio45_access(lio, 1,
+						     LIO68XX_LED_CTRL_ADDR,
+						     &value);
+			if (ret)
+				return ret;
+		} else {
+			return -EINVAL;
+		}
+		break;
+
+	case ETHTOOL_ID_ON:
+		if (oct->chip_id == OCTEON_CN66XX) {
+			octnet_gpio_access(netdev, VITESSE_PHY_GPIO_CFG,
+					   VITESSE_PHY_GPIO_HIGH);
+
+		} else if (oct->chip_id == OCTEON_CN68XX) {
+			return -EINVAL;
+		} else {
+			return -EINVAL;
+		}
+		break;
+
+	case ETHTOOL_ID_OFF:
+		if (oct->chip_id == OCTEON_CN66XX)
+			octnet_gpio_access(netdev, VITESSE_PHY_GPIO_CFG,
+					   VITESSE_PHY_GPIO_LOW);
+		else if (oct->chip_id == OCTEON_CN68XX)
+			return -EINVAL;
+		else
+			return -EINVAL;
+
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		if (oct->chip_id == OCTEON_CN66XX) {
+			octnet_gpio_access(netdev, VITESSE_PHY_GPIO_CFG,
+					   VITESSE_PHY_GPIO_DRIVEOFF);
+		} else if (oct->chip_id == OCTEON_CN68XX) {
+			/* Restore LED settings */
+			ret = octnet_mdio45_access(lio, 1,
+						   LIO68XX_LED_CTRL_ADDR,
+						   &lio->led_ctrl_val);
+			if (ret)
+				return ret;
+
+			octnet_mdio45_access(lio, 1, LIO68XX_LED_BEACON_ADDR,
+					     &lio->phy_beacon_val);
+			if (ret)
+				return ret;
+
+		} else {
+			return -EINVAL;
+		}
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static void
+lio_ethtool_get_ringparam(struct net_device *netdev,
+			  struct ethtool_ringparam *ering)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	uint32_t tx_max_pending = 0, rx_max_pending = 0, tx_pending =
+		0, rx_pending = 0;
+
+	if (oct->chip_id == OCTEON_CN66XX) {
+		struct octeon_config *conf6x = CHIP_FIELD(oct, cn6xxx, conf);
+
+		tx_max_pending = CN6XXX_MAX_IQ_DESCRIPTORS;
+		rx_max_pending = CN6XXX_MAX_OQ_DESCRIPTORS;
+		rx_pending = CFG_GET_NUM_RX_DESCS_NIC_IF(conf6x, lio->ifidx);
+		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf6x, lio->ifidx);
+	}
+
+	if (oct->chip_id == OCTEON_CN68XX) {
+		struct octeon_config *conf68 = CHIP_FIELD(oct, cn68xx, conf);
+
+		tx_max_pending = CN6XXX_MAX_IQ_DESCRIPTORS;
+		rx_max_pending = CN6XXX_MAX_OQ_DESCRIPTORS;
+		rx_pending = CFG_GET_NUM_RX_DESCS_NIC_IF(conf68, lio->ifidx);
+		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf68, lio->ifidx);
+	}
+
+	if (lio->mtu > OCTNET_DEFAULT_FRM_SIZE) {
+		ering->rx_pending = 0;
+		ering->rx_max_pending = 0;
+		ering->rx_mini_pending = 0;
+		ering->rx_jumbo_pending = rx_pending;
+		ering->rx_mini_max_pending = 0;
+		ering->rx_jumbo_max_pending = rx_max_pending;
+	} else {
+		ering->rx_pending = rx_pending;
+		ering->rx_max_pending = rx_max_pending;
+		ering->rx_mini_pending = 0;
+		ering->rx_jumbo_pending = 0;
+		ering->rx_mini_max_pending = 0;
+		ering->rx_jumbo_max_pending = 0;
+	}
+
+	ering->tx_pending = tx_pending;
+	ering->tx_max_pending = tx_max_pending;
+}
+
+static u32 lio_get_msglevel(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	return lio->msg_enable;
+}
+
+static void lio_set_msglevel(struct net_device *netdev, u32 msglvl)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	lio->msg_enable = msglvl;
+}
+
+static void
+lio_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
+{
+	/* Notes: Not supporting any auto negotiation in these
+	 * drivers. Just report pause frame support.
+	 */
+	pause->tx_pause = 1;
+	pause->rx_pause = 1;    /* TODO: Need to support RX pause frame!!. */
+}
+
+static void
+lio_get_ethtool_stats(struct net_device *netdev,
+		      struct ethtool_stats *stats, u64 *data)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+	int i = 0, j;
+
+	for (j = 0; j < MAX_OCTEON_INSTR_QUEUES; j++) {
+		if (!(oct_dev->io_qmask.iq & (1UL << j)))
+			continue;
+		data[i++] =
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_posted);
+		data[i++] =
+			CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.instr_processed);
+		data[i++] =
+			CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.instr_dropped);
+		data[i++] =
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.bytes_sent);
+		data[i++] =
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.sgentry_sent);
+		data[i++] =
+			readl(oct_dev->instr_queue[j]->inst_cnt_reg);
+		data[i++] =
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_done);
+		data[i++] =
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_iq_busy);
+		data[i++] =
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_dropped);
+		data[i++] =
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_tot_bytes);
+	}
+
+	/* for (j = 0; j < oct_dev->num_oqs; j++){ */
+	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES; j++) {
+		if (!(oct_dev->io_qmask.oq & (1UL << j)))
+			continue;
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.pkts_received);
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.bytes_received);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nodispatch);
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem);
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_toomany);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.rx_pkts_received);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.rx_bytes_received);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.rx_dropped);
+	}
+}
+
+static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+	int num_iq_stats, num_oq_stats, i, j;
+
+	num_iq_stats = ARRAY_SIZE(oct_iq_stats_strings);
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+		if (!(oct_dev->io_qmask.iq & (1UL << i)))
+			continue;
+		for (j = 0; j < num_iq_stats; j++) {
+			sprintf(data, "IQ%d %s", i, oct_iq_stats_strings[j]);
+			data += ETH_GSTRING_LEN;
+		}
+	}
+
+	num_oq_stats = ARRAY_SIZE(oct_droq_stats_strings);
+	/* for (i = 0; i < oct_dev->num_oqs; i++) { */
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct_dev->io_qmask.oq & (1UL << i)))
+			continue;
+		for (j = 0; j < num_oq_stats; j++) {
+			sprintf(data, "OQ%d %s", i, oct_droq_stats_strings[j]);
+			data += ETH_GSTRING_LEN;
+		}
+	}
+}
+
+static int lio_get_sset_count(struct net_device *netdev, int sset)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+
+	return (ARRAY_SIZE(oct_iq_stats_strings) * oct_dev->num_iqs) +
+	       (ARRAY_SIZE(oct_droq_stats_strings) * oct_dev->num_oqs);
+}
+
+static int lio_get_intr_coalesce(struct net_device *netdev,
+				 struct ethtool_coalesce *intr_coal)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
+	struct octeon_instr_queue *iq;
+	struct oct_intrmod_cfg *intrmod_cfg;
+
+	intrmod_cfg = &oct->intrmod;
+
+	switch (oct->chip_id) {
+	/* case OCTEON_CN73XX: Todo */
+	/*      break; */
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX:
+		if (!intrmod_cfg->intrmod_enable) {
+			intr_coal->rx_coalesce_usecs =
+				CFG_GET_OQ_INTR_TIME(cn6xxx->conf);
+			intr_coal->rx_max_coalesced_frames =
+				CFG_GET_OQ_INTR_PKT(cn6xxx->conf);
+		} else {
+			intr_coal->use_adaptive_rx_coalesce =
+				intrmod_cfg->intrmod_enable;
+			intr_coal->rate_sample_interval =
+				intrmod_cfg->intrmod_check_intrvl;
+			intr_coal->pkt_rate_high =
+				intrmod_cfg->intrmod_maxpkt_ratethr;
+			intr_coal->pkt_rate_low =
+				intrmod_cfg->intrmod_minpkt_ratethr;
+			intr_coal->rx_max_coalesced_frames_high =
+				intrmod_cfg->intrmod_maxcnt_trigger;
+			intr_coal->rx_coalesce_usecs_high =
+				intrmod_cfg->intrmod_maxtmr_trigger;
+			intr_coal->rx_coalesce_usecs_low =
+				intrmod_cfg->intrmod_mintmr_trigger;
+			intr_coal->rx_max_coalesced_frames_low =
+				intrmod_cfg->intrmod_mincnt_trigger;
+		}
+
+		iq = oct->instr_queue[lio->linfo.txpciq[0]];
+		intr_coal->tx_max_coalesced_frames = iq->fill_threshold;
+		break;
+
+	default:
+		lio_info(lio, drv, "Unknown Chip !!\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* Callback function for intrmod */
+static void octnet_intrmod_callback(struct octeon_device *oct_dev,
+				    uint32_t status,
+				    void *ptr)
+{
+	struct oct_intrmod_cmd *cmd = ptr;
+	struct octeon_soft_command *sc = cmd->sc;
+
+	oct_dev = cmd->oct_dev;
+
+	if (status)
+		lio_dev_err(oct_dev, "intrmod config failed. Status: %llx\n",
+			    CVM_CAST64(status));
+	else
+		lio_dev_info(oct_dev,
+			     "Rx-Adaptive Interrupt moderation enabled:%llx\n",
+			     oct_dev->intrmod.intrmod_enable);
+
+	if (sc->cmd.dptr && ((struct octeon_instr_ih *)&sc->cmd.ih)->dlengsz) {
+		pci_unmap_single(oct_dev->pci_dev,
+				 (dma_addr_t)sc->cmd.dptr,
+				 (uint32_t)((struct octeon_instr_ih *)
+				 &sc->cmd.ih)->dlengsz,
+				 PCI_DMA_TODEVICE);
+	}
+
+	kfree(cmd->sc);
+	kfree(cmd->cfg);
+	kfree(cmd);
+}
+
+/*  Configure interrupt moderation parameters */
+static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
+{
+	struct octeon_soft_command *sc;
+	struct oct_intrmod_cmd *cmd;
+	int retval;
+	struct octeon_device *oct_dev = (struct octeon_device *)oct;
+	unsigned char *cfg;
+	uint64_t data;
+	size_t datasize;
+	dma_addr_t dma_addr;
+
+	/* Alloc soft command */
+	sc = (struct octeon_soft_command *)
+	     kmalloc(sizeof(struct octeon_soft_command), GFP_KERNEL);
+	if (!sc)
+		return -ENOMEM;
+
+	/* Alloc intrmod command */
+	cmd = (struct oct_intrmod_cmd *)
+	      kmalloc(sizeof(struct oct_intrmod_cmd), GFP_KERNEL);
+	if (!cmd) {
+		kfree(sc);
+		return -ENOMEM;
+	}
+
+	cfg = (unsigned char *)
+	      kmalloc(sizeof(struct oct_intrmod_cfg), GFP_KERNEL);
+	if (!cfg) {
+		kfree(sc);
+		kfree(cmd);
+		return -ENOMEM;
+	}
+
+	memset(sc, 0, sizeof(struct octeon_soft_command));
+	memset(cmd, 0, sizeof(struct oct_intrmod_cmd));
+	memset(cfg, 0, sizeof(struct oct_intrmod_cfg));
+
+	memcpy(cfg, intr_cfg, sizeof(struct oct_intrmod_cfg));
+	octeon_swap_8B_data((uint64_t *)cfg,
+			    (sizeof(struct oct_intrmod_cfg)) / 8);
+	cmd->sc = sc;
+	cmd->cfg = (struct oct_intrmod_cfg *)cfg;
+	cmd->oct_dev = oct_dev;
+
+	datasize = sizeof(struct oct_intrmod_cfg);
+	dma_addr = pci_map_single(oct_dev->pci_dev, cfg, datasize,
+				  PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(oct_dev->pci_dev, dma_addr)) {
+		lio_dev_err(oct_dev, "%s DMA mapping error\n", __func__);
+		kfree(sc);
+		kfree(cfg);
+		kfree(cmd);
+		return -ENOMEM;
+	}
+	data = (uint64_t)dma_addr;
+
+	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC,
+				    OPCODE_NIC_INTRMOD_CFG, 0, 0, 0,
+				    cfg, data, datasize,
+				    NULL, 0, 0);
+
+	sc->callback = octnet_intrmod_callback;
+	sc->callback_arg = cmd;
+	sc->wait_time = 1000;
+
+	retval = octeon_send_soft_command(oct_dev, sc);
+	if (retval) {
+		pci_unmap_single(oct_dev->pci_dev,
+				 data, datasize,
+				 PCI_DMA_TODEVICE);
+		kfree(sc);
+		kfree(cfg);
+		kfree(cmd);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+#define  OCT_SLI_REGNAME(OCT, VAR) \
+	((OCT->chip_id == OCTEON_CN68XX) ? \
+	CN68XX_SLI_ ## VAR : CN66XX_SLI_ ## VAR)
+
+/* Enable/Disable auto interrupt Moderation */
+static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
+				 *intr_coal, int adaptive)
+{
+	int ret = 0;
+	struct octeon_device *oct = lio->oct_dev;
+	struct oct_intrmod_cfg *intrmod_cfg;
+
+	intrmod_cfg = &oct->intrmod;
+
+	if (adaptive) {
+		if (intr_coal->rate_sample_interval)
+			intrmod_cfg->intrmod_check_intrvl =
+				intr_coal->rate_sample_interval;
+		else
+			intrmod_cfg->intrmod_check_intrvl =
+				LIO_INTRMOD_CHECK_INTERVAL;
+
+		if (intr_coal->pkt_rate_high)
+			intrmod_cfg->intrmod_maxpkt_ratethr =
+				intr_coal->pkt_rate_high;
+		else
+			intrmod_cfg->intrmod_maxpkt_ratethr =
+				LIO_INTRMOD_MAXPKT_RATETHR;
+
+		if (intr_coal->pkt_rate_low)
+			intrmod_cfg->intrmod_minpkt_ratethr =
+				intr_coal->pkt_rate_low;
+		else
+			intrmod_cfg->intrmod_minpkt_ratethr =
+				LIO_INTRMOD_MINPKT_RATETHR;
+
+		if (intr_coal->rx_max_coalesced_frames_high)
+			intrmod_cfg->intrmod_maxcnt_trigger =
+				intr_coal->rx_max_coalesced_frames_high;
+		else
+			intrmod_cfg->intrmod_maxcnt_trigger =
+				LIO_INTRMOD_MAXCNT_TRIGGER;
+
+		if (intr_coal->rx_coalesce_usecs_high)
+			intrmod_cfg->intrmod_maxtmr_trigger =
+				intr_coal->rx_coalesce_usecs_high;
+		else
+			intrmod_cfg->intrmod_maxtmr_trigger =
+				LIO_INTRMOD_MAXTMR_TRIGGER;
+
+		if (intr_coal->rx_coalesce_usecs_low)
+			intrmod_cfg->intrmod_mintmr_trigger =
+				intr_coal->rx_coalesce_usecs_low;
+		else
+			intrmod_cfg->intrmod_mintmr_trigger =
+				LIO_INTRMOD_MINTMR_TRIGGER;
+
+		if (intr_coal->rx_max_coalesced_frames_low)
+			intrmod_cfg->intrmod_mincnt_trigger =
+				intr_coal->rx_max_coalesced_frames_low;
+		else
+			intrmod_cfg->intrmod_mincnt_trigger =
+				LIO_INTRMOD_MINCNT_TRIGGER;
+	}
+
+	intrmod_cfg->intrmod_enable = adaptive;
+	ret = octnet_set_intrmod_cfg(oct, intrmod_cfg);
+
+	return ret;
+}
+
+static int
+oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
+{
+	int ret;
+	struct octeon_device *oct = lio->oct_dev;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
+	uint32_t rx_max_coalesced_frames;
+
+	if (!intr_coal->rx_max_coalesced_frames)
+		rx_max_coalesced_frames = CN6XXX_OQ_INTR_PKT;
+	else
+		rx_max_coalesced_frames = intr_coal->rx_max_coalesced_frames;
+
+	/* Disable adaptive interrupt modulation */
+	ret = oct_cfg_adaptive_intr(lio, intr_coal, 0);
+	if (ret)
+		return ret;
+
+	/* Config Cnt based interrupt values */
+	octeon_write_csr(oct, OCT_SLI_REGNAME(oct, OQ_INT_LEVEL_PKTS),
+			 rx_max_coalesced_frames);
+	CFG_SET_OQ_INTR_PKT(cn6xxx->conf, rx_max_coalesced_frames);
+	return 0;
+}
+
+static int oct_cfg_rx_intrtime(struct lio *lio, struct ethtool_coalesce
+			       *intr_coal)
+{
+	int ret;
+	struct octeon_device *oct = lio->oct_dev;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
+	uint32_t time_threshold, rx_coalesce_usecs;
+
+	if (!intr_coal->rx_coalesce_usecs)
+		rx_coalesce_usecs = CN6XXX_OQ_INTR_TIME;
+	else
+		rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
+
+	/* Disable adaptive interrupt modulation */
+	ret = oct_cfg_adaptive_intr(lio, intr_coal, 0);
+	if (ret)
+		return ret;
+
+	/* Config Time based interrupt values */
+	time_threshold = lio_cn6xxx_get_oq_ticks(oct, rx_coalesce_usecs);
+	octeon_write_csr(oct, OCT_SLI_REGNAME(oct, OQ_INT_LEVEL_TIME),
+			 time_threshold);
+	CFG_SET_OQ_INTR_TIME(cn6xxx->conf, rx_coalesce_usecs);
+
+	return 0;
+}
+
+static int lio_set_intr_coalesce(struct net_device *netdev,
+				 struct ethtool_coalesce *intr_coal)
+{
+	struct lio *lio = GET_LIO(netdev);
+	int ret;
+	struct octeon_device *oct = lio->oct_dev;
+	uint32_t j, q_no;
+
+	if ((intr_coal->tx_max_coalesced_frames >= CN6XXX_DB_MIN) &&
+	    (intr_coal->tx_max_coalesced_frames <= CN6XXX_DB_MAX)) {
+		for (j = 0; j < lio->linfo.num_txpciq; j++) {
+			q_no = lio->linfo.txpciq[j];
+			oct->instr_queue[q_no]->fill_threshold =
+				intr_coal->tx_max_coalesced_frames;
+		}
+	} else {
+		lio_dev_err(oct,
+			    "LIQUIDIO: Invalid tx-frames:%d. Range is min:%d max:%d\n",
+			    intr_coal->tx_max_coalesced_frames, CN6XXX_DB_MIN,
+			    CN6XXX_DB_MAX);
+		return -EINVAL;
+	}
+
+	/* User requested adaptive-rx on */
+	if (intr_coal->use_adaptive_rx_coalesce) {
+		ret = oct_cfg_adaptive_intr(lio, intr_coal, 1);
+		if (ret)
+			goto ret_intrmod;
+	}
+
+	/* User requested adaptive-rx off and rx coalesce */
+	if ((intr_coal->rx_coalesce_usecs) &&
+	    (!intr_coal->use_adaptive_rx_coalesce)) {
+		ret = oct_cfg_rx_intrtime(lio, intr_coal);
+		if (ret)
+			goto ret_intrmod;
+	}
+
+	/* User requested adaptive-rx off and rx coalesce */
+	if ((intr_coal->rx_max_coalesced_frames) &&
+	    (!intr_coal->use_adaptive_rx_coalesce)) {
+		ret = oct_cfg_rx_intrcnt(lio, intr_coal);
+		if (ret)
+			goto ret_intrmod;
+	}
+
+	/* User requested adaptive-rx off, so use default coalesce params */
+	if ((!intr_coal->rx_max_coalesced_frames) &&
+	    (!intr_coal->use_adaptive_rx_coalesce) &&
+	    (!intr_coal->rx_coalesce_usecs)) {
+		lio_dev_info(oct,
+			     "Turning off adaptive-rx interrupt moderation\n");
+		lio_dev_info(oct,
+			     "Using RX Coalesce Default values rx_coalesce_usecs:%d rx_max_coalesced_frames:%d\n",
+			     CN6XXX_OQ_INTR_TIME, CN6XXX_OQ_INTR_PKT);
+		ret = oct_cfg_rx_intrtime(lio, intr_coal);
+		if (ret)
+			goto ret_intrmod;
+
+		ret = oct_cfg_rx_intrcnt(lio, intr_coal);
+		if (ret)
+			goto ret_intrmod;
+	}
+
+	return 0;
+ret_intrmod:
+	return ret;
+}
+
+static int lio_get_ts_info(struct net_device *netdev,
+			   struct ethtool_ts_info *info)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE | SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (lio->ptp_clock)
+		info->phc_index = ptp_clock_index(lio->ptp_clock);
+	else
+		info->phc_index = -1;
+
+	info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
+
+	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
+			   (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+			   (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+			   (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT);
+
+	return 0;
+}
+
+static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct oct_link_info *linfo;
+	struct octnic_ctrl_pkt nctrl;
+	struct octnic_ctrl_params nparams;
+	int ret = 0;
+
+	/* get the link info */
+	linfo = &lio->linfo;
+
+	if (ecmd->autoneg != AUTONEG_ENABLE && ecmd->autoneg != AUTONEG_DISABLE)
+		return -EINVAL;
+
+	if (ecmd->autoneg == AUTONEG_DISABLE && ((ecmd->speed != SPEED_100 &&
+						  ecmd->speed != SPEED_10) ||
+						 (ecmd->duplex != DUPLEX_HALF &&
+						  ecmd->duplex != DUPLEX_FULL)))
+		return -EINVAL;
+
+	/* Ethtool Support is not provided for XAUI and RXAUI Interfaces
+	 * as they operate at fixed Speed and Duplex settings
+	 */
+	if (linfo->link.s.interface == INTERFACE_MODE_XAUI ||
+	    linfo->link.s.interface == INTERFACE_MODE_RXAUI) {
+		lio_dev_info(oct, "XAUI IFs settings cannot be modified.\n");
+		return -EINVAL;
+	}
+
+	ret = liquidio_alloc_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		lio_dev_err(oct, "Failed to set settings\n");
+		return -1;
+	}
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_SETTINGS;
+	nctrl.wait_time = 1000;
+	nctrl.netpndev = (uint64_t)netdev;
+	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	/* Passing the parameters sent by ethtool like Speed, Autoneg & Duplex
+	 * to SE core application using ncmd.s.more & ncmd.s.param
+	 */
+	if (ecmd->autoneg == AUTONEG_ENABLE) {
+		/* Autoneg ON */
+		nctrl.ncmd.s.more = OCTNIC_NCMD_PHY_ON |
+				     OCTNIC_NCMD_AUTONEG_ON;
+		nctrl.ncmd.s.param2 = ecmd->advertising;
+	} else {
+		/* Autoneg OFF */
+		nctrl.ncmd.s.more = OCTNIC_NCMD_PHY_ON;
+
+		nctrl.ncmd.s.param3 = ecmd->duplex;
+
+		nctrl.ncmd.s.param2 = ecmd->speed;
+	}
+
+	nparams.resp_order = OCTEON_RESP_ORDERED;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	if (ret < 0) {
+		lio_dev_err(oct, "Failed to set settings\n");
+		liquidio_free_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+		return -1;
+	}
+
+	return 0;
+}
+
+static int lio_nway_reset(struct net_device *netdev)
+{
+	if (netif_running(netdev)) {
+		struct ethtool_cmd ecmd;
+
+		memset(&ecmd, 0, sizeof(struct ethtool_cmd));
+		ecmd.autoneg = 0;
+		ecmd.speed = 0;
+		ecmd.duplex = 0;
+		lio_set_settings(netdev, &ecmd);
+	}
+	return 0;
+}
+
+/* Return register dump len. */
+static int lio_get_regs_len(struct net_device *dev)
+{
+	return OCT_ETHTOOL_REGDUMP_LEN;
+}
+
+static int cn66_read_csr_reg(char *s, struct octeon_device *oct)
+{
+	uint32_t reg;
+	int i, len = 0;
+
+	/* PCI  Window Registers */
+
+	len += sprintf(s + len, "\n\t Octeon CN66XX CSR Registers\n\n");
+	reg = CN66XX_WIN_WR_ADDR_LO;
+	len += sprintf(s + len, "\n[%02x] (WIN_WR_ADDR_LO): %08x\n",
+		       CN66XX_WIN_WR_ADDR_LO, octeon_read_csr(oct, reg));
+	reg = CN66XX_WIN_WR_ADDR_HI;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_WR_ADDR_HI): %08x\n",
+			CN66XX_WIN_WR_ADDR_HI, octeon_read_csr(oct, reg));
+	reg = CN66XX_WIN_RD_ADDR_LO;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_RD_ADDR_LO): %08x\n",
+			CN66XX_WIN_RD_ADDR_LO, octeon_read_csr(oct, reg));
+	reg = CN66XX_WIN_RD_ADDR_HI;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_RD_ADDR_HI): %08x\n",
+			CN66XX_WIN_RD_ADDR_HI, octeon_read_csr(oct, reg));
+	reg = CN66XX_WIN_WR_DATA_LO;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_WR_DATA_LO): %08x\n",
+			CN66XX_WIN_WR_DATA_LO, octeon_read_csr(oct, reg));
+	reg = CN66XX_WIN_WR_DATA_HI;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_WR_DATA_HI): %08x\n",
+			CN66XX_WIN_WR_DATA_HI, octeon_read_csr(oct, reg));
+	len +=
+		sprintf(s + len, "[%02x] (WIN_WR_MASK_REG): %08x\n",
+			CN66XX_WIN_WR_MASK_REG, octeon_read_csr(oct,
+						CN66XX_WIN_WR_MASK_REG));
+
+	/* PCI  Interrupt Register */
+	len += sprintf(s + len, "\n[%x] (INT_ENABLE PORT 0): %08x\n",
+		       CN66XX_SLI_INT_ENB64_PORT0, octeon_read_csr(oct,
+						CN66XX_SLI_INT_ENB64_PORT0));
+	len +=
+		sprintf(s + len, "\n[%x] (INT_ENABLE PORT 1): %08x\n",
+			CN66XX_SLI_INT_ENB64_PORT1, octeon_read_csr(oct,
+						CN66XX_SLI_INT_ENB64_PORT1));
+	len +=
+		sprintf(s + len, "[%x] (INT_SUM): %08x\n", CN66XX_SLI_INT_SUM64,
+			octeon_read_csr(oct, CN66XX_SLI_INT_SUM64));
+
+	/* PCI  Output queue registers */
+	for (i = 0; i < oct->num_oqs; i++) {
+		reg = CN66XX_SLI_OQ_PKTS_SENT(i);
+		len += sprintf(s + len, "\n[%x] (PKTS_SENT_%d): %08x\n",
+			       reg, i, octeon_read_csr(oct, reg));
+		reg = CN66XX_SLI_OQ_PKTS_CREDIT(i);
+		len += sprintf(s + len, "[%x] (PKT_CREDITS_%d): %08x\n",
+			       reg, i, octeon_read_csr(oct, reg));
+	}
+	reg = CN66XX_SLI_OQ_INT_LEVEL_PKTS;
+	len += sprintf(s + len, "\n[%x] (PKTS_SENT_INT_LEVEL): %08x\n",
+		       reg, octeon_read_csr(oct, reg));
+	reg = CN66XX_SLI_OQ_INT_LEVEL_TIME;
+	len += sprintf(s + len, "[%x] (PKTS_SENT_TIME): %08x\n",
+		       reg, octeon_read_csr(oct, reg));
+
+	/* PCI  Input queue registers */
+	for (i = 0; i <= 3; i++) {
+		uint32_t reg;
+
+		reg = CN66XX_SLI_IQ_DOORBELL(i);
+		len += sprintf(s + len,
+			       "\n[%x] (INSTR_DOORBELL_%d): %08x\n",
+			       reg, i, octeon_read_csr(oct, reg));
+		reg = CN66XX_SLI_IQ_INSTR_COUNT(i);
+		len += sprintf(s + len, "[%x] (INSTR_COUNT_%d): %08x\n",
+			       reg, i, octeon_read_csr(oct, reg));
+	}
+
+	/* PCI  DMA registers */
+
+	len += sprintf(s + len, "\n[%x] (DMA_CNT_0): %08x\n",
+		       CN66XX_DMA_CNT(0), octeon_read_csr(oct,
+							  CN66XX_DMA_CNT(0)));
+	reg = CN66XX_DMA_PKT_INT_LEVEL(0);
+	len +=
+		sprintf(s + len, "[%x] (DMA_INT_LEV_0): %08x\n",
+			CN66XX_DMA_PKT_INT_LEVEL(0), octeon_read_csr(oct, reg));
+	reg = CN66XX_DMA_TIME_INT_LEVEL(0);
+	len +=
+		sprintf(s + len, "[%x] (DMA_TIME_0): %08x\n",
+			CN66XX_DMA_TIME_INT_LEVEL(0), octeon_read_csr(oct,
+								      reg));
+
+	len += sprintf(s + len, "\n[%x] (DMA_CNT_1): %08x\n",
+		       CN66XX_DMA_CNT(1), octeon_read_csr(oct,
+							  CN66XX_DMA_CNT(1)));
+	reg = CN66XX_DMA_PKT_INT_LEVEL(1);
+	len +=
+		sprintf(s + len, "[%x] (DMA_INT_LEV_1): %08x\n",
+			CN66XX_DMA_PKT_INT_LEVEL(1), octeon_read_csr(oct,
+								     reg));
+	reg = CN66XX_DMA_PKT_INT_LEVEL(1);
+	len +=
+		sprintf(s + len, "[%x] (DMA_TIME_1): %08x\n",
+			CN66XX_DMA_TIME_INT_LEVEL(1), octeon_read_csr(oct,
+								      reg));
+
+	/* PCI  Index registers */
+
+	len += sprintf(s + len, "\n");
+
+	for (i = 0; i < 16; i++) {
+		reg = OCTEON_PCI_WIN_READ(oct, CN66XX_BAR1_INDEX_REG(i));
+		len += sprintf(s + len, "[%llx] (BAR1_INDEX_%02d): %08x\n",
+			       CN66XX_BAR1_INDEX_REG(i), i, reg);
+	}
+
+	return len;
+}
+
+static int cn68_read_csr_reg(char *s, struct octeon_device *oct)
+{
+	int i, len = 0;
+	uint32_t reg;
+
+	/* PCI  Window Registers */
+
+	len += sprintf(s + len, "Octeon CN68XX CSR Registers\n\n");
+	reg = CN68XX_WIN_WR_ADDR_LO;
+	len += sprintf(s + len, "\n[%02x] (WIN_WR_ADDR_LO): %08x\n",
+		       CN68XX_WIN_WR_ADDR_LO, octeon_read_csr(oct, reg));
+	reg = CN68XX_WIN_WR_ADDR_HI;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_WR_ADDR_HI): %08x\n",
+			CN68XX_WIN_WR_ADDR_HI, octeon_read_csr(oct, reg));
+	reg = CN68XX_WIN_RD_ADDR_LO;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_RD_ADDR_LO): %08x\n",
+			CN68XX_WIN_RD_ADDR_LO, octeon_read_csr(oct, reg));
+	reg = CN68XX_WIN_RD_ADDR_HI;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_RD_ADDR_HI): %08x\n",
+			CN68XX_WIN_RD_ADDR_HI, octeon_read_csr(oct, reg));
+	reg = CN68XX_WIN_WR_DATA_LO;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_WR_DATA_LO): %08x\n",
+			CN68XX_WIN_WR_DATA_LO, octeon_read_csr(oct, reg));
+	reg = CN68XX_WIN_WR_DATA_HI;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_WR_DATA_HI): %08x\n",
+			CN68XX_WIN_WR_DATA_HI, octeon_read_csr(oct, reg));
+	reg = CN68XX_WIN_WR_MASK_REG;
+	len +=
+		sprintf(s + len, "[%02x] (WIN_WR_MASK_REG): %08x\n",
+			CN68XX_WIN_WR_MASK_REG, octeon_read_csr(oct, reg));
+
+	/* PCI  Interrupt Register */
+	reg = CN68XX_SLI_INT_ENB64_PORT0;
+	len += sprintf(s + len, "\n[%x] (INT_ENABLE PORT 0): %08x\n",
+		       CN68XX_SLI_INT_ENB64_PORT0, octeon_read_csr(oct, reg));
+	reg = CN68XX_SLI_INT_ENB64_PORT1;
+	len +=
+		sprintf(s + len, "\n[%x] (INT_ENABLE PORT 1): %08x\n",
+			CN68XX_SLI_INT_ENB64_PORT1, octeon_read_csr(oct, reg));
+	len +=
+		sprintf(s + len, "[%x] (INT_SUM): %08x\n", CN68XX_SLI_INT_SUM64,
+			octeon_read_csr(oct, CN68XX_SLI_INT_SUM64));
+
+	/* PCI  Output queue registers */
+	for (i = 0; i < oct->num_oqs; i++) {
+		reg = CN68XX_SLI_OQ_PKTS_SENT(i);
+		len += sprintf(s + len, "\n[%x] (PKTS_SENT_%d): %08x\n",
+			       reg, i, octeon_read_csr(oct, reg));
+		reg = CN68XX_SLI_OQ_PKTS_CREDIT(i);
+		len += sprintf(s + len, "[%x] (PKT_CREDITS_%d): %08x\n",
+			       reg, i, octeon_read_csr(oct, reg));
+	}
+
+	reg = CN68XX_SLI_OQ_INT_LEVEL_PKTS;
+	len += sprintf(s + len, "\n[%x] (PKTS_SENT_INT_LEVEL): %08x\n",
+		       reg, octeon_read_csr(oct, reg));
+	reg = CN68XX_SLI_OQ_INT_LEVEL_TIME;
+	len += sprintf(s + len, "[%x] (PKTS_SENT_TIME): %08x\n",
+		       reg, octeon_read_csr(oct, reg));
+
+	/* PCI  Input queue registers */
+	for (i = 0; i <= 3; i++) {
+		uint32_t reg;
+
+		reg = CN68XX_SLI_IQ_DOORBELL(i);
+		len += sprintf(s + len,
+			       "\n[%x] (INSTR_DOORBELL_%d): %08x\n",
+			       reg, i, octeon_read_csr(oct, reg));
+		reg = CN68XX_SLI_IQ_INSTR_COUNT(i);
+		len += sprintf(s + len, "[%x] (INSTR_COUNT_%d): %08x\n",
+			       reg, i, octeon_read_csr(oct, reg));
+	}
+
+	/* PCI  DMA registers */
+
+	len += sprintf(s + len, "\n[%x] (DMA_CNT_0): %08x\n",
+		       CN68XX_DMA_CNT(0), octeon_read_csr(oct,
+							  CN68XX_DMA_CNT(0)));
+	reg = CN68XX_DMA_PKT_INT_LEVEL(0);
+	len +=
+		sprintf(s + len, "[%x] (DMA_INT_LEV_0): %08x\n",
+			CN68XX_DMA_PKT_INT_LEVEL(0), octeon_read_csr(oct, reg));
+	reg = CN68XX_DMA_TIME_INT_LEVEL(0);
+	len +=
+		sprintf(s + len, "[%x] (DMA_TIME_0): %08x\n",
+			CN68XX_DMA_TIME_INT_LEVEL(0), octeon_read_csr(oct,
+								      reg));
+
+	len += sprintf(s + len, "\n[%x] (DMA_CNT_1): %08x\n",
+		       CN68XX_DMA_CNT(1), octeon_read_csr(oct,
+							  CN68XX_DMA_CNT(1)));
+	reg = CN68XX_DMA_PKT_INT_LEVEL(1);
+	len +=
+		sprintf(s + len, "[%x] (DMA_INT_LEV_1): %08x\n",
+			CN68XX_DMA_PKT_INT_LEVEL(1), octeon_read_csr(oct, reg));
+	reg = CN68XX_DMA_TIME_INT_LEVEL(1);
+	len +=
+		sprintf(s + len, "[%x] (DMA_TIME_1): %08x\n",
+			CN68XX_DMA_TIME_INT_LEVEL(1), octeon_read_csr(oct,
+								      reg));
+
+	/* PCI  Index registers */
+
+	len += sprintf(s + len, "\n");
+
+	for (i = 0; i < 16; i++) {
+		reg =
+			OCTEON_PCI_WIN_READ(oct,
+					    CN68XX_BAR1_INDEX_REG(i,
+								  oct->
+								  pcie_port));
+		len +=
+			sprintf(s + len, "[%llx] (BAR1_INDEX_%02d): %08x\n",
+				CN68XX_BAR1_INDEX_REG(i, oct->pcie_port), i,
+				reg);
+	}
+
+	return len;
+}
+
+static int cn66_read_config_reg(char *s, struct octeon_device *oct)
+{
+	uint32_t val;
+	int i, len = 0;
+
+	/* PCI CONFIG Registers */
+
+	len +=
+		sprintf(s + len, "\n\t Octeon CN66XX Config space Registers\n\n"
+			);
+
+	for (i = 0; i <= 13; i++) {
+		pci_read_config_dword(oct->pci_dev, (i * 4), &val);
+		len += sprintf(s + len, "[0x%x] (Config[%d]): 0x%08x\n",
+			       (i * 4), i, val);
+	}
+
+	for (i = 30; i <= 34; i++) {
+		pci_read_config_dword(oct->pci_dev, (i * 4), &val);
+		len += sprintf(s + len, "[0x%x] (Config[%d]): 0x%08x\n",
+			       (i * 4), i, val);
+	}
+
+	return len;
+}
+
+static int cn68_read_config_reg(char *s, struct octeon_device *oct)
+{
+	int i, len = 0;
+	uint32_t val;
+
+	/* PCI CONFIG Registers */
+
+	len +=
+		sprintf(s + len, "\n\t Octeon CN68XX Config space Registers\n\n"
+			);
+
+	for (i = 0; i <= 13; i++) {
+		pci_read_config_dword(oct->pci_dev, (i * 4), &val);
+		len += sprintf(s + len, "[0x%x] (Config[%d]): 0x%08x\n",
+			       (i * 4), i, val);
+	}
+
+	for (i = 30; i <= 34; i++) {
+		pci_read_config_dword(oct->pci_dev, (i * 4), &val);
+		len += sprintf(s + len, "[0x%x] (Config[%d]): 0x%08x\n",
+			       (i * 4), i, val);
+	}
+
+	return len;
+}
+
+/*  Return register dump user app.  */
+static void lio_get_regs(struct net_device *dev,
+			 struct ethtool_regs *regs, void *regbuf)
+{
+	struct lio *lio = GET_LIO(dev);
+	int len = 0;
+	struct octeon_device *oct = lio->oct_dev;
+
+	memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN);
+	regs->version = OCT_ETHTOOL_REGSVER;
+
+	switch (oct->chip_id) {
+	/* case OCTEON_CN73XX: Todo */
+	case OCTEON_CN68XX:
+		len += cn68_read_csr_reg(regbuf + len, oct);
+		len += cn68_read_config_reg(regbuf + len, oct);
+		break;
+	case OCTEON_CN66XX:
+		len += cn66_read_csr_reg(regbuf + len, oct);
+		len += cn66_read_config_reg(regbuf + len, oct);
+		break;
+	default:
+		lio_dev_err(oct, "%s Unknown chipid: %d\n",
+			    __func__, oct->chip_id);
+	}
+}
+
+static const struct ethtool_ops lio_ethtool_ops = {
+	.get_settings		= lio_get_settings,
+	.get_link		= ethtool_op_get_link,
+	.get_drvinfo		= lio_get_drvinfo,
+	.get_ringparam		= lio_ethtool_get_ringparam,
+	.get_channels		= lio_ethtool_get_channels,
+	.set_phys_id		= lio_set_phys_id,
+	.get_eeprom_len		= lio_get_eeprom_len,
+	.get_eeprom		= lio_get_eeprom,
+	.get_strings		= lio_get_strings,
+	.get_ethtool_stats	= lio_get_ethtool_stats,
+	.get_pauseparam		= lio_get_pauseparam,
+	.get_regs_len		= lio_get_regs_len,
+	.get_regs		= lio_get_regs,
+	.get_msglevel		= lio_get_msglevel,
+	.set_msglevel		= lio_set_msglevel,
+	.get_sset_count		= lio_get_sset_count,
+	.nway_reset		= lio_nway_reset,
+	.set_settings		= lio_set_settings,
+	.get_coalesce		= lio_get_intr_coalesce,
+	.set_coalesce		= lio_set_intr_coalesce,
+	.get_ts_info		= lio_get_ts_info,
+};
+
+void liquidio_set_ethtool_ops(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &lio_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
new file mode 100644
index 0000000..c65a469
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -0,0 +1,3933 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/pci_ids.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/net_tstamp.h>
+#include <linux/if_vlan.h>
+#include <linux/firmware.h>
+#include <linux/ethtool.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/workqueue.h>
+#include <linux/interrupt.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+
+MODULE_AUTHOR("Cavium Networks, <support@cavium.com>");
+MODULE_DESCRIPTION("Cavium LiquidIO Intelligent Server Adapter Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(LIQUIDIO_VERSION);
+
+static int msi;
+module_param(msi, int, 0);
+MODULE_PARM_DESC(msi, "Flag for enabling MSI interrupts");
+
+static int ddr_timeout = 10000;
+module_param(ddr_timeout, int, 0644);
+MODULE_PARM_DESC(ddr_timeout,
+		 "Number of milliseconds to wait for DDR initialization. 0 waits for ddr_timeout to be set to non-zero value before starting to check");
+
+static uint32_t console_bitmask;
+module_param(console_bitmask, int, 0644);
+MODULE_PARM_DESC(console_bitmask,
+		 "Bitmask indicating which consoles have debug output redirected to syslog.");
+
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static uint32_t debug = -1;
+module_param(debug, int, 0644);
+MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
+
+static char fw_type[OCTEON_MAX_FW_TYPE_LEN];
+module_param_string(fw_type, fw_type, sizeof(fw_type), 0000);
+MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded. Default \"nic\"");
+
+/* Bit mask values for lio->ifstate */
+#define   LIO_IFSTATE_DROQ_OPS             0x01
+#define   LIO_IFSTATE_REGISTERED           0x02
+#define   LIO_IFSTATE_RUNNING              0x04
+#define   LIO_IFSTATE_RX_TIMESTAMP_ENABLED 0x08
+
+/* Polling interval for determining when NIC application is alive */
+#define LIQUIDIO_STARTER_POLL_INTERVAL_MS 100
+
+/* runtime link query interval */
+#define LIQUIDIO_LINK_QUERY_INTERVAL_MS         1000
+
+struct liquidio_if_cfg_resp {
+	struct {
+		int octeon_id;
+
+		wait_queue_head_t wc;
+
+		int cond;
+	} s;
+	uint64_t rh;
+	struct liquidio_if_cfg_info cfg_info;
+	uint64_t status;
+};
+
+struct oct_link_status_resp {
+	struct {
+		int octeon_id;
+
+		wait_queue_head_t wc;
+
+		int cond;
+	} s;
+
+	uint64_t rh;
+
+	struct oct_link_info link_info;
+
+	uint64_t status;
+};
+
+#define OCT_LINK_STATUS_RESP_SIZE (sizeof(struct oct_link_status_resp))
+
+struct oct_timestamp_resp {
+	uint64_t rh;
+
+	uint64_t timestamp;
+
+	uint64_t status;
+};
+
+#define OCT_TIMESTAMP_RESP_SIZE (sizeof(struct oct_timestamp_resp))
+
+union tx_info {
+	uint64_t u64;
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		uint16_t gso_size;
+		uint16_t gso_segs;
+		uint32_t reserved;
+#else
+		uint32_t reserved;
+		uint16_t gso_segs;
+		uint16_t gso_size;
+#endif
+	} s;
+};
+
+/** Octeon device properties to be used by the NIC module.
+ * Each octeon device in the system will be represented
+ * by this structure in the NIC module.
+ */
+
+#define OCTNIC_MAX_SG  (MAX_SKB_FRAGS)
+
+/** Structure of a node in list of gather components maintained by
+ * NIC driver for each network device.
+ */
+struct octnic_gather {
+	/** List manipulation. Next and prev pointers. */
+	struct list_head list;
+
+	/** Size of the gather component at sg in bytes. */
+	int sg_size;
+
+	/** Number of bytes that sg was adjusted to make it 8B-aligned. */
+	int adjust;
+
+	/** Gather component that can accommodate max sized fragment list
+	 *  received from the IP layer.
+	 */
+	struct octeon_sg_entry *sg;
+};
+
+/** This structure is used by NIC driver to store information required
+ * to free the sk_buff when the packet has been fetched by Octeon.
+ * Bytes offset below assume worst-case of a 64-bit system.
+ */
+struct octnet_buf_free_info {
+	/** Bytes 1-8.  Pointer to network device private structure. */
+	struct lio *lio;
+
+	/** Bytes 9-16.  Pointer to sk_buff. */
+	struct sk_buff *skb;
+
+	/** Bytes 17-24.  Pointer to gather list. */
+	struct octnic_gather *g;
+
+	/** Bytes 25-32. Physical address of skb->data or gather list. */
+	uint64_t dptr;
+
+	/** Bytes 33-47. Piggybacked soft command, if any */
+	struct octeon_soft_command *sc;
+};
+
+struct handshake {
+	struct completion init;
+	struct completion started;
+	struct pci_dev *pci_dev;
+	int init_ok;
+	int started_ok;
+};
+
+struct octeon_device_priv {
+	/** Tasklet structures for this device. */
+	struct tasklet_struct droq_tasklet;
+	unsigned long napi_mask;
+};
+
+static int octeon_device_init(struct octeon_device *);
+static void liquidio_remove(struct pci_dev *pdev);
+static int liquidio_probe(struct pci_dev *pdev,
+			  const struct pci_device_id *ent);
+
+static struct handshake handshake[MAX_OCTEON_DEVICES];
+static struct completion first_stage;
+
+void octeon_droq_bh(unsigned long pdev)
+{
+	int q_no;
+	int reschedule = 0;
+	struct octeon_device *oct = (struct octeon_device *)pdev;
+	struct octeon_device_priv *oct_priv =
+		(struct octeon_device_priv *)oct->priv;
+
+	oct->stats.droq_tasklet_count++;
+	/* for (q_no = 0; q_no < oct->num_oqs; q_no++) { */
+	for (q_no = 0; q_no < MAX_OCTEON_OUTPUT_QUEUES; q_no++) {
+		if (!(oct->io_qmask.oq & (1UL << q_no)))
+			continue;
+		reschedule |= octeon_droq_process_packets(oct, oct->droq[q_no]);
+	}
+
+	if (reschedule)
+		tasklet_schedule(&oct_priv->droq_tasklet);
+}
+
+int lio_wait_for_oq_pkts(struct octeon_device *oct)
+{
+	struct octeon_device_priv *oct_priv =
+		(struct octeon_device_priv *)oct->priv;
+	int retry = 100, pkt_cnt = 0, pending_pkts = 0;
+	int i;
+
+	do {
+		pending_pkts = 0;
+
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+			if (!(oct->io_qmask.oq & (1UL << i)))
+				continue;
+			pkt_cnt += octeon_droq_check_hw_for_pkts(oct,
+								 oct->droq[i]);
+		}
+		if (pkt_cnt > 0) {
+			pending_pkts += pkt_cnt;
+			tasklet_schedule(&oct_priv->droq_tasklet);
+		}
+		pkt_cnt = 0;
+		schedule_timeout_uninterruptible(1);
+
+	} while (retry-- && pending_pkts);
+
+	return pkt_cnt;
+}
+
+void octeon_report_tx_completion_to_bql(void *txq, unsigned int pkts_compl,
+					unsigned int bytes_compl)
+{
+	struct netdev_queue *netdev_queue = txq;
+
+	netdev_tx_completed_queue(netdev_queue, pkts_compl, bytes_compl);
+}
+
+void octeon_update_tx_completion_counters(void *buf, int reqtype,
+					  unsigned int *pkts_compl,
+					  unsigned int *bytes_compl)
+{
+	struct octnet_buf_free_info *finfo;
+	struct sk_buff *skb;
+	struct octeon_soft_command *sc;
+
+	switch (reqtype) {
+	case REQTYPE_NORESP_NET:
+	case REQTYPE_NORESP_NET_SG:
+		finfo = buf;
+		skb = finfo->skb;
+		break;
+
+	case REQTYPE_RESP_NET_SG:
+	case REQTYPE_RESP_NET:
+		sc = buf;
+		skb = sc->callback_arg;
+		break;
+
+	default:
+		return;
+	}
+
+	(*pkts_compl)++;
+	*bytes_compl += skb->len;
+}
+
+void octeon_report_sent_bytes_to_bql(void *buf, int reqtype)
+{
+	struct octnet_buf_free_info *finfo;
+	struct sk_buff *skb;
+	struct octeon_soft_command *sc;
+	struct netdev_queue *txq;
+
+	switch (reqtype) {
+	case REQTYPE_NORESP_NET:
+	case REQTYPE_NORESP_NET_SG:
+		finfo = buf;
+		skb = finfo->skb;
+		break;
+
+	case REQTYPE_RESP_NET_SG:
+	case REQTYPE_RESP_NET:
+		sc = buf;
+		skb = sc->callback_arg;
+		break;
+
+	default:
+		return;
+	}
+
+	txq = netdev_get_tx_queue(skb->dev, skb_get_queue_mapping(skb));
+	netdev_tx_sent_queue(txq, skb->len);
+}
+
+int octeon_console_debug_enabled(uint32_t console)
+{
+	return (console_bitmask >> (console)) & 0x1;
+}
+
+/**
+ * \brief Forces all IO queues off on a given device
+ * @param oct Pointer to Octeon device
+ */
+static void force_io_queues_off(struct octeon_device *oct)
+{
+	if (oct->chip_id == OCTEON_CN68XX) {
+		pr_info(" %s : OCTEON_CN68XX\n", __func__);
+		/* Reset the Enable bits for Input Queues. */
+		octeon_write_csr(oct, CN68XX_SLI_PKT_INSTR_ENB, 0);
+
+		/* Reset the Enable bits for Output Queues. */
+		octeon_write_csr(oct, CN68XX_SLI_PKT_OUT_ENB, 0);
+	}
+
+	if (oct->chip_id == OCTEON_CN66XX) {
+		pr_info(" %s : OCTEON_CN66XX\n", __func__);
+
+		/* Reset the Enable bits for Input Queues. */
+		octeon_write_csr(oct, CN66XX_SLI_PKT_INSTR_ENB, 0);
+
+		/* Reset the Enable bits for Output Queues. */
+		octeon_write_csr(oct, CN66XX_SLI_PKT_OUT_ENB, 0);
+	}
+}
+
+/**
+ * \brief wait for all pending requests to complete
+ * @param oct Pointer to Octeon device
+ *
+ * Called during shutdown sequence
+ */
+static int wait_for_pending_requests(struct octeon_device *oct)
+{
+	int i, pcount = 0;
+
+	for (i = 0; i < 100; i++) {
+		pcount =
+			atomic_read(&oct->response_list
+				[OCTEON_ORDERED_SC_LIST].pending_req_count);
+		if (pcount)
+			schedule_timeout_uninterruptible(HZ / 10);
+		 else
+			break;
+	}
+
+	if (pcount)
+		return 1;
+
+	return 0;
+}
+
+/**
+ * \brief Cause device to go quiet so it can be safely removed/reset/etc
+ * @param oct Pointer to Octeon device
+ */
+static inline void pcierror_quiesce_device(struct octeon_device *oct)
+{
+	int i;
+
+	pr_info(" %s :\n", __func__);
+
+	/* Disable the input and output queues now. No more packets will
+	 * arrive from Octeon, but we should wait for all packet processing
+	 * to finish.
+	 */
+	force_io_queues_off(oct);
+
+	/* To allow for in-flight requests */
+	schedule_timeout_uninterruptible(100);
+
+	if (wait_for_pending_requests(oct))
+		lio_dev_err(oct, "There were pending requests\n");
+
+	/* Force all requests waiting to be fetched by OCTEON to complete. */
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+		struct octeon_instr_queue *iq;
+
+		if (!(oct->io_qmask.iq & (1UL << i)))
+			continue;
+		iq = oct->instr_queue[i];
+
+		if (atomic_read(&iq->instr_pending)) {
+			spin_lock_bh(&iq->lock);
+			iq->fill_cnt = 0;
+			iq->octeon_read_index = iq->host_write_index;
+			iq->stats.instr_processed +=
+				atomic_read(&iq->instr_pending);
+			spin_unlock_bh(&iq->lock);
+
+			lio_process_noresponse_list(oct, iq);
+		}
+	}
+
+	/* Force all pending ordered list requests to time out. */
+	lio_process_ordered_list(oct, 1);
+
+	/* We do not need to wait for output queue packets to be processed. */
+}
+
+/**
+ * \brief Cleanup PCI AER uncorrectable error status
+ * @param dev Pointer to PCI device
+ */
+static void cleanup_aer_uncorrect_error_status(struct pci_dev *dev)
+{
+	int pos = 0x100;
+	u32 status, mask;
+
+	pr_info("%s :\n", __func__);
+
+	pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, &status);
+	pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_SEVER, &mask);
+	if (dev->error_state == pci_channel_io_normal)
+		status &= ~mask;        /* Clear corresponding nonfatal bits */
+	else
+		status &= mask;         /* Clear corresponding fatal bits */
+	pci_write_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, status);
+}
+
+/**
+ * \brief Stop all PCI IO to a given device
+ * @param dev Pointer to Octeon device
+ */
+static void stop_pci_io(struct octeon_device *oct)
+{
+	/* No more instructions will be forwarded. */
+	atomic_set(&oct->status, OCT_DEV_IN_RESET);
+
+	pci_disable_device(oct->pci_dev);
+
+	/* Disable interrupts  */
+	oct->fn_list.disable_interrupt(oct->chip);
+
+	pcierror_quiesce_device(oct);
+
+	/* Release the interrupt line */
+	free_irq(oct->pci_dev->irq, oct);
+
+	if (oct->msi_on)
+		pci_disable_msi(oct->pci_dev);
+
+	lio_dev_dbg(oct, "Device state is now %s\n",
+		    lio_get_state_string(&oct->status));
+
+	/* cn63xx_cleanup_aer_uncorrect_error_status(oct->pci_dev); */
+	/* making it a common function for all OCTEON models */
+	cleanup_aer_uncorrect_error_status(oct->pci_dev);
+}
+
+/**
+ * \brief called when PCI error is detected
+ * @param pdev Pointer to PCI device
+ * @param state The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t liquidio_pcie_error_detected(struct pci_dev *pdev,
+						     pci_channel_state_t state)
+{
+	struct octeon_device *oct = pci_get_drvdata(pdev);
+
+	/* Non-correctable Non-fatal errors */
+	if (state == pci_channel_io_normal) {
+		lio_dev_err(oct, "Non-correctable non-fatal error reported:\n");
+		cleanup_aer_uncorrect_error_status(oct->pci_dev);
+		return PCI_ERS_RESULT_CAN_RECOVER;
+	}
+
+	/* Non-correctable Fatal errors */
+	lio_dev_err(oct, "Non-correctable FATAL reported by PCI AER driver\n");
+	stop_pci_io(oct);
+
+	/* Always return a DISCONNECT. There is no support for recovery but only
+	 * for a clean shutdown.
+	 */
+	return PCI_ERS_RESULT_DISCONNECT;
+}
+
+/**
+ * \brief mmio handler
+ * @param pdev Pointer to PCI device
+ */
+static pci_ers_result_t liquidio_pcie_mmio_enabled(struct pci_dev *pdev)
+{
+	/* We should never hit this since we never ask for a reset for a Fatal
+	 * Error. We always return DISCONNECT in io_error above.
+	 * But play safe and return RECOVERED for now.
+	 */
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * \brief called after the pci bus has been reset.
+ * @param pdev Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot. Implementation
+ * resembles the first-half of the octeon_resume routine.
+ */
+static pci_ers_result_t liquidio_pcie_slot_reset(struct pci_dev *pdev)
+{
+	/* We should never hit this since we never ask for a reset for a Fatal
+	 * Error. We always return DISCONNECT in io_error above.
+	 * But play safe and return RECOVERED for now.
+	 */
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * \brief called when traffic can start flowing again.
+ * @param pdev Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation. Implementation resembles the
+ * second-half of the octeon_resume routine.
+ */
+static void liquidio_pcie_resume(struct pci_dev *pdev)
+{
+	/* Nothing to be done here. */
+}
+
+#ifdef CONFIG_PM
+/**
+ * \brief called when suspending
+ * @param pdev Pointer to PCI device
+ * @param state state to suspend to
+ */
+static int liquidio_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	return -ENOSYS;
+}
+
+/**
+ * \brief called when resuming
+ * @param pdev Pointer to PCI device
+ */
+static int liquidio_resume(struct pci_dev *pdev)
+{
+	return -ENOSYS;
+}
+#endif
+
+/* For PCI-E Advanced Error Recovery (AER) Interface */
+static struct pci_error_handlers liquidio_err_handler = {
+	.error_detected = liquidio_pcie_error_detected,
+	.mmio_enabled	= liquidio_pcie_mmio_enabled,
+	.slot_reset	= liquidio_pcie_slot_reset,
+	.resume		= liquidio_pcie_resume,
+};
+
+static const struct pci_device_id liquidio_pci_tbl[] = {
+	{       /* 68xx */
+		PCI_VENDOR_ID_CAVIUM, 0x91, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
+	},
+	{       /* 66xx */
+		PCI_VENDOR_ID_CAVIUM, 0x92, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
+	},
+	{
+		0, 0, 0, 0, 0, 0, 0
+	}
+};
+MODULE_DEVICE_TABLE(pci, liquidio_pci_tbl);
+
+static struct pci_driver liquidio_pci_driver = {
+	.name		= "LiquidIO",
+	.id_table	= liquidio_pci_tbl,
+	.probe		= liquidio_probe,
+	.remove		= liquidio_remove,
+	.err_handler	= &liquidio_err_handler,    /* For AER */
+
+#ifdef CONFIG_PM
+	.suspend	= liquidio_suspend,
+	.resume		= liquidio_resume,
+#endif
+
+};
+
+/**
+ * \brief register PCI driver
+ */
+static int liquidio_init_pci(void)
+{
+	return pci_register_driver(&liquidio_pci_driver);
+}
+
+/**
+ * \brief unregister PCI driver
+ */
+static void liquidio_deinit_pci(void)
+{
+	pci_unregister_driver(&liquidio_pci_driver);
+}
+
+/**
+ * \brief check interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to check
+ */
+static inline int ifstate_check(struct lio *lio, int state_flag)
+{
+	return atomic_read(&lio->ifstate) & state_flag;
+}
+
+/**
+ * \brief set interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to set
+ */
+static inline void ifstate_set(struct lio *lio, int state_flag)
+{
+	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) | state_flag));
+}
+
+/**
+ * \brief clear interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to clear
+ */
+static inline void ifstate_reset(struct lio *lio, int state_flag)
+{
+	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) & ~(state_flag)));
+}
+
+/**
+ * \brief Stop Tx queues
+ * @param netdev network device
+ */
+static inline void txqs_stop(struct net_device *netdev)
+{
+	if (netif_is_multiqueue(netdev)) {
+		int i;
+
+		for (i = 0; i < netdev->num_tx_queues; i++)
+			netif_stop_subqueue(netdev, i);
+	} else {
+		netif_stop_queue(netdev);
+	}
+}
+
+/**
+ * \brief Start Tx queues
+ * @param netdev network device
+ */
+static inline void txqs_start(struct net_device *netdev)
+{
+	if (netif_is_multiqueue(netdev)) {
+		int i;
+
+		for (i = 0; i < netdev->num_tx_queues; i++)
+			netif_start_subqueue(netdev, i);
+	} else {
+		netif_start_queue(netdev);
+	}
+}
+
+/**
+ * \brief Wake Tx queues
+ * @param netdev network device
+ */
+static inline void txqs_wake(struct net_device *netdev)
+{
+	if (netif_is_multiqueue(netdev)) {
+		int i;
+
+		for (i = 0; i < netdev->num_tx_queues; i++)
+			netif_wake_subqueue(netdev, i);
+	} else {
+		netif_wake_queue(netdev);
+	}
+}
+
+/**
+ * \brief Stop Tx queue
+ * @param netdev network device
+ */
+static void stop_txq(struct net_device *netdev)
+{
+	txqs_stop(netdev);
+}
+
+/**
+ * \brief Start Tx queue
+ * @param netdev network device
+ */
+static void start_txq(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	if (lio->linfo.link.s.status) {
+		txqs_start(netdev);
+		return;
+	}
+}
+
+/**
+ * \brief Wake a queue
+ * @param netdev network device
+ * @param q which queue to wake
+ */
+static inline void wake_q(struct net_device *netdev, int q)
+{
+	if (netif_is_multiqueue(netdev))
+		netif_wake_subqueue(netdev, q);
+	else
+		netif_wake_queue(netdev);
+}
+
+/**
+ * \brief Stop a queue
+ * @param netdev network device
+ * @param q which queue to stop
+ */
+static inline void stop_q(struct net_device *netdev, int q)
+{
+	if (netif_is_multiqueue(netdev))
+		netif_stop_subqueue(netdev, q);
+	else
+		netif_stop_queue(netdev);
+}
+
+/**
+ * \brief Check Tx queue status, and take appropriate action
+ * @param lio per-network private data
+ * @returns 0 if full, number of queues woken up otherwise
+ */
+static inline int check_txq_status(struct lio *lio)
+{
+	int ret_val = 0;
+
+	if (netif_is_multiqueue(lio->netdev)) {
+		int numqs = lio->netdev->num_tx_queues;
+		int q, iq = 0;
+
+		/* check each sub-queue state */
+		for (q = 0; q < numqs; q++) {
+			iq = lio->linfo.txpciq[q & (lio->linfo.num_txpciq-1)];
+			if (octnet_iq_is_full(lio->oct_dev, iq))
+				continue;
+			wake_q(lio->netdev, q);
+			ret_val++;
+		}
+	} else {
+		if (octnet_iq_is_full(lio->oct_dev, lio->txq))
+			return 0;
+		wake_q(lio->netdev, lio->txq);
+		ret_val = 1;
+	}
+	return ret_val;
+}
+
+/**
+ * Remove the node at the head of the list. The list would be empty at
+ * the end of this call if there are no more nodes in the list.
+ */
+static inline struct list_head *list_delete_head(struct list_head *root)
+{
+	struct list_head *node;
+
+	if ((root->prev == root) && (root->next == root))
+		node = NULL;
+	else
+		node = root->next;
+
+	if (node)
+		list_del(node);
+
+	return node;
+}
+
+/**
+ * \brief Delete gather list
+ * @param lio per-network private data
+ */
+static void delete_glist(struct lio *lio)
+{
+	struct octnic_gather *g;
+
+	do {
+		g = (struct octnic_gather *)
+		    list_delete_head(&lio->glist);
+		if (g) {
+			if (g->sg)
+				kfree((void *)((unsigned long)g->sg -
+						g->adjust));
+			kfree(g);
+		}
+	} while (g);
+}
+
+/**
+ * \brief Setup gather list
+ * @param lio per-network private data
+ */
+static int setup_glist(struct lio *lio)
+{
+	int i;
+	struct octnic_gather *g;
+
+	INIT_LIST_HEAD(&lio->glist);
+
+	for (i = 0; i < lio->tx_qsize; i++) {
+		g = kmalloc(sizeof(*g), GFP_KERNEL);
+		if (!g)
+			break;
+		memset(g, 0, sizeof(struct octnic_gather));
+
+		g->sg_size =
+			((ROUNDUP4(OCTNIC_MAX_SG) >> 2) * OCT_SG_ENTRY_SIZE);
+
+		g->sg = kmalloc(g->sg_size + 8, GFP_KERNEL);
+		if (!g->sg) {
+			kfree(g);
+			break;
+		}
+
+		/* The gather component should be aligned on 64-bit boundary */
+		if (((unsigned long)g->sg) & 7) {
+			g->adjust = 8 - (((unsigned long)g->sg) & 7);
+			g->sg = (struct octeon_sg_entry *)
+				((unsigned long)g->sg + g->adjust);
+		}
+		list_add_tail(&g->list, &lio->glist);
+	}
+
+	if (i == lio->tx_qsize)
+		return 0;
+
+	delete_glist(lio);
+	return 1;
+}
+
+#define LINK_STATUS_REQUESTED    1
+#define LINK_STATUS_FETCHED      2
+
+/**
+ * \brief Print link information
+ * @param netdev network device
+ */
+static void print_link_info(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED) {
+		struct oct_link_info *linfo = &lio->linfo;
+
+		if (linfo->link.s.status) {
+			lio_info(lio, link, "%d Mbps %s Duplex UP\n",
+				 linfo->link.s.speed,
+				 (linfo->link.s.duplex) ? "Full" : "Half");
+		} else {
+			lio_info(lio, link, "Link Down\n");
+		}
+	}
+}
+
+/**
+ * \brief Update link status
+ * @param netdev network device
+ * @param ls link status structure
+ *
+ * Called on receipt of a link status response from the core application to
+ * update each interface's link status.
+ */
+static inline void update_link_status(struct net_device *netdev,
+				      union oct_link_status *ls)
+{
+	struct lio *lio = GET_LIO(netdev);
+	union oct_link_status prev_st;
+
+	spin_lock(&lio->link_update_lock);
+	if (lio->intf_open) {
+		prev_st.u64 = lio->linfo.link.u64;
+		lio->linfo.link.u64 = ls->u64;
+
+		if (prev_st.u64 != ls->u64) {
+			print_link_info(netdev);
+			if (lio->linfo.link.s.status) {
+				netif_carrier_on(netdev);
+				/* start_txq(netdev); */
+				txqs_wake(netdev);
+			} else {
+				netif_carrier_off(netdev);
+				stop_txq(netdev);
+			}
+		}
+	}
+	spin_unlock(&lio->link_update_lock);
+}
+
+/**
+ * \brief Link change callback
+ * @param status status of the command
+ * @param props_ptr octeon device properties
+ *
+ * Callback for when link status command response arrives
+ * sent by the poll function (runtime link status monitoring).
+ */
+static void link_change_callback(struct octeon_device *oct,
+				 uint32_t status, void
+				 *props_ptr)
+{
+	struct octdev_props_t *props;
+	struct oct_link_status_resp *ls;
+	int ifidx;
+
+	props = (struct octdev_props_t *)props_ptr;
+	ls = props->ls;
+
+	/* Don't do anything if the status is not 0. */
+	if (ls->status)
+		goto end_of_link_change_callback;
+	octeon_swap_8B_data((uint64_t *)&ls->link_info,
+			    ((OCT_LINK_INFO_SIZE -
+			      (sizeof(ls->link_info.txpciq) +
+			       sizeof(ls->link_info.rxpciq)))) >> 3);
+	ifidx = ls->link_info.ifidx;
+
+	update_link_status(props->netdev[ifidx], &ls->link_info.link);
+
+end_of_link_change_callback:
+	atomic_set(&props->ls_flag, LINK_STATUS_FETCHED);
+}
+
+/**
+ * \brief Get link status at run-time
+ * @param work struct work_struct
+ *
+ * Get the link status at run time. This routine does not sleep waiting for
+ * a response. The link status is updated in a callback called when a response
+ * arrives from the core app.
+ */
+static void octnet_get_runtime_link_status(struct work_struct *work)
+{
+	struct octdev_props_t *props;
+	struct octeon_soft_command *sc;
+	struct oct_link_status_resp *ls;
+	int retval;
+	int octeon_id;
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct octeon_device *oct_dev = (struct octeon_device *)wk->ctxptr;
+	int i;
+	int count;
+	uint64_t rdata;
+	size_t rdatasize;
+	dma_addr_t dma_addr;
+
+	octeon_id = lio_get_device_id(oct_dev);
+	props = &oct_dev->props;
+
+	sc = props->sc_link_status;
+	ls = props->ls;
+
+	/* Do nothing if the status is not ready to be fetched
+	 * or the device is not in running state
+	 */
+	if (atomic_read(&oct_dev->status) != OCT_DEV_RUNNING) {
+		queue_delayed_work(oct_dev->link_status_wq.wq,
+				   &oct_dev->link_status_wq.wk.work,
+				   LIQUIDIO_LINK_QUERY_INTERVAL_MS);
+		return;
+	}
+
+	rdatasize = OCT_LINK_STATUS_RESP_SIZE - sizeof(ls->s);
+	dma_addr = pci_map_single(oct_dev->pci_dev, &ls->rh, rdatasize,
+				  PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(oct_dev->pci_dev, dma_addr)) {
+		lio_dev_err(oct_dev, "%s DMA mapping error\n", __func__);
+		queue_delayed_work(oct_dev->link_status_wq.wq,
+				   &oct_dev->link_status_wq.wk.work,
+				   LIQUIDIO_LINK_QUERY_INTERVAL_MS);
+		return;
+	}
+	rdata = (uint64_t)dma_addr;
+
+	for (i = 0; i < props->ifcount; i++) {
+		memset(ls, 0, OCT_LINK_STATUS_RESP_SIZE);
+
+		ACCESS_ONCE(ls->s.cond) = 0;
+		ls->s.octeon_id = octeon_id;
+
+		octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC,
+					    OPCODE_NIC_INFO, i, 0, 0,
+					    NULL, 0, 0,
+					    &ls->rh, rdata, rdatasize);
+
+		sc->callback = link_change_callback;
+		sc->callback_arg = props;
+		sc->wait_time = 1000;
+
+		atomic_set(&props->ls_flag, LINK_STATUS_REQUESTED);
+
+		retval = octeon_send_soft_command(oct_dev, sc);
+		if (retval) {
+			/* Set state to fetched so that a request can be
+			 * sent the next time this poll fn is called.
+			 */
+			lio_dev_err(oct_dev, "Soft command error\n");
+			break;
+		}
+		count = 0;
+		while (atomic_read(&props->ls_flag) !=
+		       LINK_STATUS_FETCHED) {
+			count++;
+			if (count == 10)
+				break;
+			msleep_interruptible(100);
+		}
+		if (count == 10) {
+			lio_dev_err(oct_dev,
+				    "link status failed for interface %d\n", i);
+			atomic_set(&props->ls_flag, LINK_STATUS_FETCHED);
+		}
+	}
+	pci_unmap_single(oct_dev->pci_dev, rdata, rdatasize,
+			 PCI_DMA_FROMDEVICE);
+
+	props->last_check = jiffies;
+	queue_delayed_work(oct_dev->link_status_wq.wq,
+			   &oct_dev->link_status_wq.wk.work,
+			   msecs_to_jiffies(LIQUIDIO_LINK_QUERY_INTERVAL_MS));
+}
+
+/**
+ * \brief Droq packet processor sceduler
+ * @param oct octeon device
+ */
+static
+void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
+{
+	struct octeon_device_priv *oct_priv =
+		(struct octeon_device_priv *)oct->priv;
+	uint64_t oq_no;
+	struct octeon_droq *droq;
+
+	if (oct->int_status & OCT_DEV_INTR_PKT_DATA) {
+		for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES; oq_no++) {
+			if (!(oct->droq_intr & (1 << oq_no)))
+				continue;
+
+			droq = oct->droq[oq_no];
+
+			if (droq->ops.poll_mode) {
+				droq->ops.napi_fn(droq);
+				oct_priv->napi_mask |= (1 << oq_no);
+			} else {
+				tasklet_schedule(&oct_priv->droq_tasklet);
+			}
+		}
+	}
+}
+
+/**
+ * \brief Interrupt handler for octeon
+ * @param irq unused
+ * @param dev octeon device
+ */
+static
+irqreturn_t liquidio_intr_handler(int irq __attribute__((unused)), void *dev)
+{
+	struct octeon_device *oct = (struct octeon_device *)dev;
+	irqreturn_t ret;
+
+	/* Disable our interrupts for the duration of ISR */
+	oct->fn_list.disable_interrupt(oct->chip);
+
+	ret = oct->fn_list.process_interrupt_regs(oct);
+
+	if (ret == IRQ_HANDLED)
+		liquidio_schedule_droq_pkt_handlers(oct);
+
+	/* Re-enable our interrupts  */
+	if (!(atomic_read(&oct->status) == OCT_DEV_IN_RESET))
+		oct->fn_list.enable_interrupt(oct->chip);
+
+	return ret;
+}
+
+/**
+ * \brief Setup interrupt for octeon device
+ * @param oct octeon device
+ *
+ *  Enable interrupt in Octeon device as given in the PCI interrupt mask.
+ */
+static int octeon_setup_interrupt(struct octeon_device *oct)
+{
+	int irqret;
+
+	atomic_set(&oct->in_interrupt, 0);
+	atomic_set(&oct->interrupts, 0);
+
+	if (msi == 1) {
+		if (!pci_enable_msi(oct->pci_dev)) {
+			oct->msi_on = 1;
+			lio_dev_info(oct, "MSI enabled\n");
+		}
+	}
+
+	irqret = request_irq(oct->pci_dev->irq, liquidio_intr_handler,
+			     IRQF_SHARED, "octeon", oct);
+	if (irqret) {
+		if (oct->msi_on)
+			pci_disable_msi(oct->pci_dev);
+		lio_dev_err(oct, "Request IRQ failed with code: %d\n", irqret);
+		return 1;
+	}
+
+	return 0;
+}
+
+/**
+ * \brief PCI probe handler
+ * @param pdev PCI device structure
+ * @param ent unused
+ */
+static int liquidio_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	struct octeon_device *oct_dev = NULL;
+	struct handshake *hs;
+
+	oct_dev = octeon_allocate_device(pdev->device,
+					 sizeof(struct octeon_device_priv));
+	if (!oct_dev) {
+		dev_err(&pdev->dev, "Unable to allocate device\n");
+		return -ENOMEM;
+	}
+
+	dev_info(&pdev->dev, "Initializing device %x:%x.\n",
+		 (uint32_t)pdev->vendor, (uint32_t)pdev->device);
+
+	/* Assign octeon_device for this device to the private data area. */
+	pci_set_drvdata(pdev, oct_dev);
+
+	/* set linux specific device pointer */
+	oct_dev->pci_dev = (void *)pdev;
+
+	hs = &handshake[oct_dev->octeon_id];
+	init_completion(&hs->init);
+	init_completion(&hs->started);
+	hs->pci_dev = pdev;
+
+	if (oct_dev->octeon_id == 0)
+		/* first LiquidIO NIC is detected */
+		complete(&first_stage);
+
+	if (octeon_device_init(oct_dev)) {
+		liquidio_remove(pdev);
+		return -ENOMEM;
+	}
+
+	lio_dev_dbg(oct_dev, "Device is ready\n");
+
+	return 0;
+}
+
+/**
+ *\brief Destroy resources associated with octeon device
+ * @param pdev PCI device structure
+ * @param ent unused
+ */
+static void octeon_destroy_resources(struct octeon_device *oct)
+{
+	int i;
+	struct octeon_device_priv *oct_priv =
+		(struct octeon_device_priv *)oct->priv;
+
+	struct handshake *hs;
+
+	switch (atomic_read(&oct->status)) {
+	case OCT_DEV_RUNNING:
+	case OCT_DEV_CORE_OK:
+
+		/* No more instructions will be forwarded. */
+		atomic_set(&oct->status, OCT_DEV_IN_RESET);
+
+		oct->app_mode = CVM_DRV_INVALID_APP;
+		lio_dev_dbg(oct, "Device state is now %s\n",
+			    lio_get_state_string(&oct->status));
+
+		schedule_timeout_uninterruptible(HZ / 10);
+
+		/* fallthrough */
+	case OCT_DEV_HOST_OK:
+		if (wait_for_pending_requests(oct))
+			lio_dev_err(oct, "There were pending requests\n");
+
+		if (lio_wait_for_instr_fetch(oct))
+			lio_dev_err(oct, "IQ had pending instructions\n");
+
+		/* Disable the input and output queues now. No more packets will
+		 * arrive from Octeon, but we should wait for all packet
+		 * processing to finish.
+		 */
+		oct->fn_list.disable_io_queues(oct);
+
+		if (lio_wait_for_oq_pkts(oct))
+			lio_dev_err(oct, "OQ had pending packets\n");
+
+		/* Remove any consoles */
+		octeon_remove_consoles(oct);
+
+		/* Disable interrupts  */
+		oct->fn_list.disable_interrupt(oct->chip);
+
+		/* Release the interrupt line */
+		free_irq(oct->pci_dev->irq, oct);
+
+		if (oct->msi_on)
+			pci_disable_msi(oct->pci_dev);
+
+		/* Soft reset the octeon device before exiting */
+		oct->fn_list.soft_reset(oct);
+
+		/* Disable the device, releasing the PCI INT */
+		pci_disable_device(oct->pci_dev);
+
+		/* fallthrough */
+	case OCT_DEV_IN_RESET:
+	case OCT_DEV_DROQ_INIT_DONE:
+		/*atomic_set(&oct->status, OCT_DEV_DROQ_INIT_DONE);*/
+		mdelay(100);
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+			if (!(oct->io_qmask.oq & (1UL << i)))
+				continue;
+			octeon_delete_droq(oct, i);
+		}
+
+		/* Force any pending handshakes to complete */
+		for (i = 0; i < MAX_OCTEON_DEVICES; i++) {
+			hs = &handshake[i];
+
+			if (hs->pci_dev) {
+				handshake[oct->octeon_id].init_ok = 0;
+				complete(&handshake[oct->octeon_id].init);
+				handshake[oct->octeon_id].started_ok = 0;
+				complete(&handshake[oct->octeon_id].started);
+			}
+		}
+
+		/* fallthrough */
+	case OCT_DEV_RESP_LIST_INIT_DONE:
+		octeon_delete_response_list(oct);
+
+		/* fallthrough */
+	case OCT_DEV_INSTR_QUEUE_INIT_DONE:
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+			if (!(oct->io_qmask.iq & (1UL << i)))
+				continue;
+			octeon_delete_instr_queue(oct, i);
+		}
+
+		/* fallthrough */
+	case OCT_DEV_DISPATCH_INIT_DONE:
+		octeon_delete_dispatch_list(oct);
+		cancel_delayed_work_sync(&oct->nic_poll_work.work);
+
+		/* fallthrough */
+	case OCT_DEV_PCI_MAP_DONE:
+		octeon_unmap_pci_barx(oct, 0);
+		octeon_unmap_pci_barx(oct, 1);
+
+		/* fallthrough */
+	case OCT_DEV_BEGIN_STATE:
+		/* Nothing to be done here either */
+		break;
+	}                       /* end switch(oct->status) */
+
+	tasklet_kill(&oct_priv->droq_tasklet);
+}
+
+/**
+ * \brief Send Rx control command
+ * @param lio per-network private data
+ * @param start_stop whether to start or stop
+ */
+static void send_rx_ctrl_cmd(struct lio *lio, int start_stop)
+{
+	struct octnic_ctrl_pkt nctrl;
+	struct octnic_ctrl_params nparams;
+
+	if (liquidio_alloc_ctrl_pkt_buffers(lio->oct_dev, &nctrl) < 0)
+		lio_info(lio, rx_err, "Failed to send RX Control message\n");
+
+	nctrl.ncmd.s.cmd = OCTNET_CMD_RX_CTL;
+	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
+	nctrl.ncmd.s.param2 = start_stop;
+	nctrl.netpndev = (uint64_t)lio->netdev;
+
+	nparams.resp_order = OCTEON_RESP_NORESPONSE;
+
+	if (octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams) < 0) {
+		liquidio_free_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+		lio_info(lio, rx_err, "Failed to send RX Control message\n");
+	}
+}
+
+/**
+ * \brief Destroy NIC device interface
+ * @param oct octeon device
+ * @param ifidx which interface to destroy
+ *
+ * Cleanup associated with each interface for an Octeon device  when NIC
+ * module is being unloaded or if initialization fails during load.
+ */
+static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
+{
+	struct net_device *netdev = oct->props.netdev[ifidx];
+	struct lio *lio;
+
+	if (!netdev) {
+		lio_dev_err(oct, "%s No netdevice ptr for index %d\n",
+			    __func__, ifidx);
+		return;
+	}
+
+	lio = GET_LIO(netdev);
+
+	lio_dev_dbg(oct, "NIC device cleanup\n");
+
+	send_rx_ctrl_cmd(lio, 0);
+
+	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
+		txqs_stop(netdev);
+
+	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
+		unregister_netdev(netdev);
+
+	delete_glist(lio);
+
+	free_netdev(netdev);
+
+	oct->props.netdev[ifidx] = NULL;
+}
+
+/**
+ * \brief Stop complete NIC functionality
+ * @param oct octeon device
+ */
+static int liquidio_stop_nic_module(struct octeon_device *oct)
+{
+	int i, j;
+	struct lio *lio;
+
+	lio_dev_dbg(oct, "Stopping network interfaces\n");
+	if (!oct->props.ls) {
+		lio_dev_err(oct, "Init for Octeon was not completed\n");
+		return 1;
+	}
+
+	cancel_delayed_work_sync(&oct->link_status_wq.wk.work);
+	flush_workqueue(oct->link_status_wq.wq);
+	destroy_workqueue(oct->link_status_wq.wq);
+
+	for (i = 0; i < oct->props.ifcount; i++) {
+		lio = GET_LIO(oct->props.netdev[i]);
+		for (j = 0; j < lio->linfo.num_rxpciq; j++)
+			octeon_unregister_droq_ops(oct, lio->linfo.rxpciq[j]);
+	}
+
+	for (i = 0; i < oct->props.ifcount; i++)
+		liquidio_destroy_nic_device(oct, i);
+
+	/* Free the link status buffer allocated for this Octeon device. */
+	kfree(oct->props.ls);
+
+	/* Free the soft command buffer used for sending the link status to
+	 * the core app.
+	 */
+	kfree(oct->props.sc_link_status);
+
+	lio_dev_dbg(oct, "Network interfaces stopped\n");
+	return 0;
+}
+
+/**
+ * \brief Cleans up resources at unload time
+ * @param pdev PCI device structure
+ */
+static void liquidio_remove(struct pci_dev *pdev)
+{
+	struct octeon_device *oct_dev = pci_get_drvdata(pdev);
+
+	lio_dev_dbg(oct_dev, "Stopping device\n");
+
+	if (oct_dev->app_mode && (oct_dev->app_mode == CVM_DRV_NIC_APP))
+		liquidio_stop_nic_module(oct_dev);
+
+	/* Reset the octeon device and cleanup all memory allocated for
+	 * the octeon device by driver.
+	 */
+	octeon_destroy_resources(oct_dev);
+
+	lio_dev_info(oct_dev, "Device removed\n");
+
+	/* This octeon device has been removed. Update the global
+	 * data structure to reflect this. Free the device structure.
+	 */
+	octeon_free_device_mem(oct_dev);
+}
+
+/**
+ * \brief Identify the Octeon device and to map the BAR address space
+ * @param oct octeon device
+ */
+static int octeon_chip_specific_setup(struct octeon_device *oct)
+{
+	uint32_t dev_id, rev_id;
+
+	pci_read_config_dword(oct->pci_dev, 0, &dev_id);
+	pci_read_config_dword(oct->pci_dev, 8, &rev_id);
+	oct->rev_id = rev_id & 0xff;
+
+	switch (dev_id) {
+	case OCTEON_CN68XX_PCIID:
+		lio_dev_info(oct, "CN68XX PASS%d.%d\n", OCTEON_MAJOR_REV(oct),
+			     OCTEON_MINOR_REV(oct));
+		oct->chip_id = OCTEON_CN68XX;
+		return lio_setup_cn68xx_octeon_device(oct);
+
+	case OCTEON_CN66XX_PCIID:
+		lio_dev_info(oct, "CN66XX PASS%d.%d\n", OCTEON_MAJOR_REV(oct),
+			     OCTEON_MINOR_REV(oct));
+		oct->chip_id = OCTEON_CN66XX;
+		return lio_setup_cn66xx_octeon_device(oct);
+
+	default:
+		lio_dev_err(oct, "Unknown device found (dev_id: %x)\n", dev_id);
+	}
+
+	return 1;
+}
+
+/**
+ * \brief OS-specific PCI initialization for each Octeon device.
+ * @param oct octeon device
+ */
+static int octeon_pci_os_setup(struct octeon_device *octeon_dev)
+{
+	/* setup PCI stuff first */
+	if (pci_enable_device(octeon_dev->pci_dev)) {
+		lio_dev_err(octeon_dev, "pci_enable_device failed\n");
+		return 1;
+	}
+
+	/* Octeon device supports DMA into a 64-bit space */
+	if (pci_set_dma_mask(octeon_dev->pci_dev, PCI_DMA_64BIT)) {
+		lio_dev_err(octeon_dev, "pci_set_dma_mask(64bit) failed\n");
+		return 1;
+	}
+
+	/* Enable PCI DMA Master. */
+	pci_set_master(octeon_dev->pci_dev);
+
+	return 0;
+}
+
+/**
+ * \brief Check Tx queue state for a given network buffer
+ * @param lio per-network private data
+ * @param skb network buffer
+ */
+static inline int check_txq_state(struct lio *lio, struct sk_buff *skb)
+{
+	int q = 0, iq = 0;
+
+	if (netif_is_multiqueue(lio->netdev)) {
+		q = skb->queue_mapping;
+		iq = lio->linfo.txpciq[(q & (lio->linfo.num_txpciq - 1))];
+	} else {
+		iq = lio->txq;
+	}
+
+	if (octnet_iq_is_full(lio->oct_dev, iq))
+		return 0;
+	wake_q(lio->netdev, q);
+	return 1;
+}
+
+/**
+ * \brief Unmap and free network buffer
+ * @param buf buffer
+ */
+static void free_netbuf(void *buf)
+{
+	struct sk_buff *skb;
+	struct octnet_buf_free_info *finfo;
+	struct lio *lio;
+
+	finfo = (struct octnet_buf_free_info *)buf;
+	skb = finfo->skb;
+	lio = finfo->lio;
+
+	pci_unmap_single(lio->oct_dev->pci_dev, finfo->dptr, skb->len,
+			 PCI_DMA_TODEVICE);
+
+	check_txq_state(lio, skb);
+
+	recv_buffer_free((struct sk_buff *)skb);
+}
+
+/**
+ * \brief Unmap and free gather buffer
+ * @param buf buffer
+ */
+static void free_netsgbuf(void *buf)
+{
+	struct octnet_buf_free_info *finfo;
+	struct sk_buff *skb;
+	struct lio *lio;
+	struct octnic_gather *g;
+	int i, frags;
+
+	finfo = (struct octnet_buf_free_info *)buf;
+	skb = finfo->skb;
+	lio = finfo->lio;
+	g = finfo->g;
+	frags = skb_shinfo(skb)->nr_frags;
+
+	pci_unmap_single(lio->oct_dev->pci_dev,
+			 g->sg[0].ptr[0], (skb->len - skb->data_len),
+			 PCI_DMA_TODEVICE);
+
+	i = 1;
+	while (frags--) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
+
+		pci_unmap_page((lio->oct_dev)->pci_dev,
+			       g->sg[(i >> 2)].ptr[(i & 3)],
+			       frag->size, PCI_DMA_TODEVICE);
+		i++;
+	}
+
+	pci_unmap_single((lio->oct_dev)->pci_dev,
+			 finfo->dptr, g->sg_size,
+			 PCI_DMA_TODEVICE);
+
+	spin_lock(&lio->lock);
+	list_add_tail(&g->list, &lio->glist);
+	spin_unlock(&lio->lock);
+
+	check_txq_state(lio, skb);     /* mq support: sub-queue state check */
+
+	recv_buffer_free((struct sk_buff *)skb);
+}
+
+/**
+ * \brief Unmap and free gather buffer with response
+ * @param buf buffer
+ */
+static void free_netsgbuf_with_resp(void *buf)
+{
+	struct octeon_soft_command *sc;
+	struct octnet_buf_free_info *finfo;
+	struct sk_buff *skb;
+	struct lio *lio;
+	struct octnic_gather *g;
+	int i, frags;
+
+	sc = (struct octeon_soft_command *)buf;
+	skb = (struct sk_buff *)sc->callback_arg;
+	finfo = (struct octnet_buf_free_info *)&skb->cb;
+
+	lio = finfo->lio;
+	g = finfo->g;
+	frags = skb_shinfo(skb)->nr_frags;
+
+	pci_unmap_single(lio->oct_dev->pci_dev,
+			 g->sg[0].ptr[0], (skb->len - skb->data_len),
+			 PCI_DMA_TODEVICE);
+
+	i = 1;
+	while (frags--) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
+
+		pci_unmap_page((lio->oct_dev)->pci_dev,
+			       g->sg[(i >> 2)].ptr[(i & 3)],
+			       frag->size, PCI_DMA_TODEVICE);
+		i++;
+	}
+
+	pci_unmap_single((lio->oct_dev)->pci_dev,
+			 finfo->dptr, g->sg_size,
+			 PCI_DMA_TODEVICE);
+
+	spin_lock(&lio->lock);
+	list_add_tail(&g->list, &lio->glist);
+	spin_unlock(&lio->lock);
+
+	/* Don't free the skb yet */
+
+	check_txq_state(lio, skb);
+}
+
+/**
+ * \brief Adjust ptp frequency
+ * @param ptp PTP clock info
+ * @param ppb how much to adjust by, in parts-per-billion
+ */
+static int liquidio_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct lio *lio = container_of(ptp, struct lio, ptp_info);
+	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
+	u64 comp, delta;
+	unsigned long flags;
+	bool neg_adj = false;
+
+	if (ppb < 0) {
+		neg_adj = true;
+		ppb = -ppb;
+	}
+
+	/* The hardware adds the clock compensation value to the
+	 * PTP clock on every coprocessor clock cycle, so we
+	 * compute the delta in terms of coprocessor clocks.
+	 */
+	delta = (u64)ppb << 32;
+	do_div(delta, oct->coproc_clock_rate);
+
+	spin_lock_irqsave(&lio->ptp_lock, flags);
+	comp = OCTEON_PCI_WIN_READ(oct, CN6XXX_MIO_PTP_CLOCK_COMP);
+	if (neg_adj)
+		comp -= delta;
+	else
+		comp += delta;
+	OCTEON_PCI_WIN_WRITE(oct, CN6XXX_MIO_PTP_CLOCK_COMP, comp);
+	spin_unlock_irqrestore(&lio->ptp_lock, flags);
+
+	return 0;
+}
+
+/**
+ * \brief Adjust ptp time
+ * @param ptp PTP clock info
+ * @param delta how much to adjust by, in nanosecs
+ */
+static int liquidio_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	unsigned long flags;
+	struct lio *lio = container_of(ptp, struct lio, ptp_info);
+
+	spin_lock_irqsave(&lio->ptp_lock, flags);
+	lio->ptp_adjust += delta;
+	spin_unlock_irqrestore(&lio->ptp_lock, flags);
+
+	return 0;
+}
+
+/**
+ * \brief Get hardware clock time, including any adjustment
+ * @param ptp PTP clock info
+ * @param ts timespec
+ */
+static int liquidio_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	u64 ns;
+	u32 remainder;
+	unsigned long flags;
+	struct lio *lio = container_of(ptp, struct lio, ptp_info);
+	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
+
+	spin_lock_irqsave(&lio->ptp_lock, flags);
+	ns = OCTEON_PCI_WIN_READ(oct, CN6XXX_MIO_PTP_CLOCK_HI);
+	ns += lio->ptp_adjust;
+	spin_unlock_irqrestore(&lio->ptp_lock, flags);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000ULL, &remainder);
+	ts->tv_nsec = remainder;
+
+	return 0;
+}
+
+/**
+ * \brief Set hardware clock time. Reset adjustment
+ * @param ptp PTP clock info
+ * @param ts timespec
+ */
+static int liquidio_ptp_settime(struct ptp_clock_info *ptp,
+				const struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct lio *lio = container_of(ptp, struct lio, ptp_info);
+	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
+
+	ns = timespec_to_ns(ts);
+
+	spin_lock_irqsave(&lio->ptp_lock, flags);
+	OCTEON_PCI_WIN_WRITE(oct, CN6XXX_MIO_PTP_CLOCK_HI, ns);
+	lio->ptp_adjust = 0;
+	spin_unlock_irqrestore(&lio->ptp_lock, flags);
+
+	return 0;
+}
+
+/**
+ * \brief Check if PTP is enabled
+ * @param ptp PTP clock info
+ * @param rq request
+ * @param on is it on
+ */
+static int liquidio_ptp_enable(struct ptp_clock_info *ptp,
+			       struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+/**
+ * \brief Open PTP clock source
+ * @param netdev network device
+ */
+static void oct_ptp_open(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
+
+	spin_lock_init(&lio->ptp_lock);
+
+	snprintf(lio->ptp_info.name, 16, "%s", netdev->name);
+	lio->ptp_info.owner = THIS_MODULE;
+	lio->ptp_info.max_adj = 250000000;
+	lio->ptp_info.n_alarm = 0;
+	lio->ptp_info.n_ext_ts = 0;
+	lio->ptp_info.n_per_out = 0;
+	lio->ptp_info.pps = 0;
+	lio->ptp_info.adjfreq = liquidio_ptp_adjfreq;
+	lio->ptp_info.adjtime = liquidio_ptp_adjtime;
+	lio->ptp_info.gettime = liquidio_ptp_gettime;
+	lio->ptp_info.settime = liquidio_ptp_settime;
+	lio->ptp_info.enable = liquidio_ptp_enable;
+
+	lio->ptp_adjust = 0;
+
+	lio->ptp_clock = ptp_clock_register(&lio->ptp_info,
+					     &oct->pci_dev->dev);
+
+	if (IS_ERR(lio->ptp_clock))
+		lio->ptp_clock = NULL;
+}
+
+/**
+ * \brief Init PTP clock
+ * @param oct octeon device
+ */
+static void liquidio_ptp_init(struct octeon_device *oct)
+{
+	u64 clock_comp, cfg;
+
+	clock_comp = (u64)NSEC_PER_SEC << 32;
+	do_div(clock_comp, oct->coproc_clock_rate);
+	OCTEON_PCI_WIN_WRITE(oct, CN6XXX_MIO_PTP_CLOCK_COMP, clock_comp);
+
+	/* Enable */
+	cfg = OCTEON_PCI_WIN_READ(oct, CN6XXX_MIO_PTP_CLOCK_CFG);
+	OCTEON_PCI_WIN_WRITE(oct, CN6XXX_MIO_PTP_CLOCK_CFG, cfg | 0x01);
+}
+
+/**
+ * \brief Load firmware to device
+ * @param oct octeon device
+ *
+ * Maps device to firmware filename, requests firmware, and downloads it
+ */
+static int load_firmware(struct octeon_device *oct)
+{
+	int ret = 0;
+	const struct firmware *fw;
+	char fw_name[OCTEON_MAX_FW_FILENAME_LEN];
+	char *card_type, *tmp_fw_type;
+
+	if (strncmp(fw_type, OCTEON_FW_NAME_TYPE_NONE,
+		    sizeof(OCTEON_FW_NAME_TYPE_NONE)) == 0) {
+		lio_dev_info(oct, "Skipping firmware load\n");
+		return ret;
+	}
+
+	switch (oct->chip_id) {
+	case OCTEON_CN66XX:
+		card_type = OCTEON_FW_NAME_CARD_210SV;
+		break;
+	case OCTEON_CN68XX:
+		card_type = OCTEON_FW_NAME_CARD_410NV;
+		break;
+	default:
+		card_type = OCTEON_FW_NAME_CARD_ANY;
+	}
+
+	if (fw_type[0] == '\0')
+		tmp_fw_type = OCTEON_FW_NAME_TYPE_NIC;
+	else
+		tmp_fw_type = fw_type;
+
+	sprintf(fw_name, "%s%s%s_%s%s", OCTEON_FW_DIR, OCTEON_FW_BASE_NAME,
+		card_type, tmp_fw_type, OCTEON_FW_NAME_SUFFIX);
+
+	ret = request_firmware(&fw, fw_name, &oct->pci_dev->dev);
+	if (ret) {
+		lio_dev_err(oct, "Request firmware failed. Could not find file %s.\n.",
+			    fw_name);
+		return ret;
+	}
+
+	ret = octeon_download_firmware(oct, fw->data, fw->size);
+	if (ret)
+		goto cleanup_firmware;
+
+cleanup_firmware:
+	release_firmware(fw);
+
+	return ret;
+}
+
+/**
+ * \brief Setup output queue
+ * @param oct octeon device
+ * @param q_no which queue
+ * @param num_descs how many descriptors
+ * @param desc_size size of each descriptor
+ * @param app_ctx application context
+ */
+static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
+			     int desc_size, void *app_ctx)
+{
+	int ret_val = 0;
+
+	lio_dev_dbg(oct, "Creating Droq: %d\n", q_no);
+	/* droq creation and local register settings. */
+	ret_val = octeon_create_droq(oct, q_no, num_descs, desc_size, app_ctx);
+	if (ret_val == -1)
+		return ret_val;
+
+	if (ret_val == 1) {
+		lio_dev_dbg(oct, "Using default droq %d\n", q_no);
+		return 0;
+	}
+	/* tasklet creation for the droq */
+
+	/* Enable the droq queues */
+	octeon_set_droq_pkt_op(oct, q_no, 1);
+
+	/* Send Credit for Octeon Output queues. Credits are always
+	 * sent after the output queue is enabled.
+	 */
+	writel(oct->droq[q_no]->max_count,
+	       oct->droq[q_no]->pkts_credit_reg);
+
+	return ret_val;
+}
+
+/**
+ * \brief Callback for getting interface configuration
+ * @param status status of request
+ * @param buf pointer to resp structure
+ */
+static void if_cfg_callback(struct octeon_device *oct,
+			    uint32_t status,
+			    void *buf)
+{
+	struct liquidio_if_cfg_resp *resp;
+
+	resp = (struct liquidio_if_cfg_resp *)buf;
+	oct = lio_get_device(resp->s.octeon_id);
+	if (resp->status)
+		lio_dev_err(oct, "nic if cfg instruction failed. Status: %llx\n",
+			    CVM_CAST64(resp->status));
+	ACCESS_ONCE(resp->s.cond) = 1;
+
+	/* This barrier is required to be sure that the response has been
+	 * written fully before waking up the handler
+	 */
+	wmb();
+
+	wake_up_interruptible(&resp->s.wc);
+}
+
+/**
+ * \brief Select queue based on hash
+ * @param dev Net device
+ * @param skb sk_buff structure
+ * @returns selected queue number
+ */
+static u16 select_q(struct net_device *dev, struct sk_buff *skb,
+		    void *accel_priv, select_queue_fallback_t fallback)
+{
+	int qindex;
+	struct lio *lio;
+
+	lio = GET_LIO(dev);
+	/* select queue on chosen queue_mapping or core */
+	qindex = skb_rx_queue_recorded(skb) ?
+		 skb_get_rx_queue(skb) : smp_processor_id();
+	return (u16)(qindex & (lio->linfo.num_txpciq - 1));
+}
+
+/**
+ * \brief Callback for when a init time link status command response arrives
+ * @param status status of request
+ * @param buf pointer to resp structure
+ */
+static void inittime_ls_callback(struct octeon_device *oct,
+				 uint32_t status,
+				 void *buf)
+{
+	struct oct_link_status_resp *link_status;
+
+	link_status = (struct oct_link_status_resp *)buf;
+	oct = lio_get_device(link_status->s.octeon_id);
+	if (link_status->status)
+		lio_dev_err(oct,
+			    "Link status instruction failed. Status: %llx\n",
+			    CVM_CAST64(link_status->status));
+	ACCESS_ONCE(link_status->s.cond) = 1;
+
+	wake_up_interruptible(&link_status->s.wc);
+}
+
+/**
+ * \brief Get the link status at init time.
+ * @param oct octeon device
+ * @param props_ptr octeon device properties
+ * @param ifidx interface index
+ *
+ * This routine sleeps till a response arrives from the core app. This is
+ * because the initialization cannot proceed till the host knows about the
+ * number of ethernet interfaces supported by the Octeon NIC target device.
+ */
+static inline int get_inittime_link_status(void *oct,
+					   void *props_ptr, int ifidx)
+{
+	struct octdev_props_t *props;
+	struct octeon_device *oct_dev;
+	struct octeon_soft_command *sc;
+	struct oct_link_status_resp *ls;
+	int retval;
+	int octeon_id;
+	uint64_t rdata;
+	size_t rdatasize;
+	dma_addr_t dma_addr;
+
+	props = (struct octdev_props_t *)props_ptr;
+	oct_dev = (struct octeon_device *)oct;
+	octeon_id = lio_get_device_id(oct_dev);
+
+	/* Use the link status soft command pre-allocated
+	 * for this octeon device.
+	 */
+	sc = props->sc_link_status;
+
+	/* Reset the link status buffer in props for this octeon device. */
+	ls = props->ls;
+
+	memset(ls, 0, OCT_LINK_STATUS_RESP_SIZE);
+
+	init_waitqueue_head(&ls->s.wc);
+
+	ACCESS_ONCE(ls->s.cond) = 0;
+	ls->s.octeon_id = octeon_id;
+
+	rdatasize = OCT_LINK_STATUS_RESP_SIZE - sizeof(ls->s);
+	dma_addr = pci_map_single(oct_dev->pci_dev, &ls->rh, rdatasize,
+				  PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(oct_dev->pci_dev, dma_addr)) {
+		lio_dev_err(oct_dev, "%s DMA mapping error\n", __func__);
+		return -ENOMEM;
+	}
+	rdata = (uint64_t)dma_addr;
+
+	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC, OPCODE_NIC_INFO,
+				    ifidx, 0, 0, NULL, 0, 0,
+				    &ls->rh, rdata, rdatasize);
+
+	sc->callback = inittime_ls_callback;
+	sc->callback_arg = ls;
+	sc->wait_time = 1000;
+
+	retval = octeon_send_soft_command(oct_dev, sc);
+	if (retval) {
+		lio_dev_err(oct_dev, "Link status instruction failed status: %x\n",
+			    retval);
+		pci_unmap_single(oct_dev->pci_dev, rdata, rdatasize,
+				 PCI_DMA_FROMDEVICE);
+		/* Soft instr is freed by driver in case of failure. */
+		return -EBUSY;
+	}
+
+	/* Sleep on a wait queue till the cond flag indicates that the
+	 * response arrived or timed-out.
+	 */
+	sleep_cond(&ls->s.wc, &ls->s.cond);
+
+	if (!ls->status) {
+		octeon_swap_8B_data((uint64_t *)&ls->link_info,
+				    ((OCT_LINK_INFO_SIZE -
+				      (sizeof(ls->link_info.txpciq) +
+				       sizeof(ls->link_info.rxpciq)))) >> 3);
+	} else {
+		lio_dev_err(oct_dev, "Link status fetching failed\n");
+	}
+
+	atomic_set(&oct_dev->props.ls_flag, LINK_STATUS_FETCHED);
+	oct_dev->props.last_check = jiffies;
+
+	pci_unmap_single(oct_dev->pci_dev, rdata, rdatasize,
+			 PCI_DMA_FROMDEVICE);
+
+	return ls->status;
+}
+
+/** Routine to push packets arriving on Octeon interface upto network layer.
+ * @param oct_id   - octeon device id.
+ * @param skbuff   - skbuff struct to be passed to network layer.
+ * @param len      - size of total data received.
+ * @param rh       - Control header associated with the packet
+ * @param param    - additional control data with the packet
+ */
+static void
+liquidio_push_packet(uint32_t octeon_id,
+		     void *skbuff,
+		     uint32_t len,
+		     union octeon_rh *rh,
+		     void *param)
+{
+	struct napi_struct *napi = param;
+	struct octeon_device *oct = lio_get_device(octeon_id);
+	struct sk_buff *skb = (struct sk_buff *)skbuff;
+	struct skb_shared_hwtstamps *shhwtstamps;
+	u64 ns;
+	struct net_device *netdev =
+		(struct net_device *)oct->props.netdev[rh->r_dh.link];
+	struct octeon_droq *droq = container_of(param, struct octeon_droq,
+						napi);
+
+	if (netdev) {
+		int packet_was_received;
+		struct lio *lio = GET_LIO(netdev);
+
+		/* Do not proceed if the interface is not in RUNNING state. */
+		if (!
+		    (atomic_read(&lio->ifstate) &
+		     LIO_IFSTATE_RUNNING)) {
+			recv_buffer_free(skb);
+			droq->stats.rx_dropped++;
+			return;
+		}
+
+		skb->dev = netdev;
+
+		if (rh->r_dh.has_hwtstamp) {
+			/* timestamp is included from the hardware at the
+			 * beginning of the packet.
+			 */
+			if (ifstate_check(lio,
+					  LIO_IFSTATE_RX_TIMESTAMP_ENABLED)) {
+				/* Nanoseconds are in the first 64-bits
+				 * of the packet.
+				 */
+				memcpy(&ns, (skb->data), sizeof(ns));
+				shhwtstamps = skb_hwtstamps(skb);
+				shhwtstamps->hwtstamp =
+					ns_to_ktime(ns + lio->ptp_adjust);
+			}
+			skb_pull(skb, sizeof(ns));
+		}
+
+		skb->protocol = eth_type_trans(skb, skb->dev);
+
+		if ((netdev->features & NETIF_F_RXCSUM) &&
+		    (rh->r_dh.csum_verified == CNNIC_CSUM_VERIFIED))
+			/* checksum has already been verified */
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = CHECKSUM_NONE;
+
+		packet_was_received = napi_gro_receive(napi, skb) != GRO_DROP;
+
+		if (packet_was_received) {
+			droq->stats.rx_bytes_received += len;
+			droq->stats.rx_pkts_received++;
+			netdev->last_rx = jiffies;
+		} else {
+			droq->stats.rx_dropped++;
+			lio_info(lio, rx_err,
+				 "droq:%d  error rx_dropped:%llu\n",
+				 droq->q_no, droq->stats.rx_dropped);
+		}
+
+	} else {
+		recv_buffer_free(skb);
+	}
+}
+
+/**
+ * \brief wrapper for calling napi_schedule
+ * @param param parameters to pass to napi_schedule
+ *
+ * Used when scheduling on different CPUs
+ */
+static void napi_schedule_wrapper(void *param)
+{
+	struct napi_struct *napi = param;
+
+	napi_schedule(napi);
+}
+
+/**
+ * \brief callback when receive interrupt occurs and we are in NAPI mode
+ * @param arg pointer to octeon output queue
+ */
+static void liquidio_napi_drv_callback(void *arg)
+{
+	struct octeon_droq *droq = arg;
+	int this_cpu = smp_processor_id();
+
+	if (droq->cpu_id == this_cpu) {
+		napi_schedule(&droq->napi);
+	} else {
+		struct call_single_data *csd = &droq->csd;
+
+		csd->func = napi_schedule_wrapper;
+		csd->info = &droq->napi;
+		csd->flags = 0;
+
+		smp_call_function_single_async(droq->cpu_id, csd);
+	}
+}
+
+/**
+ * \brief Main NAPI poll function
+ * @param droq octeon output queue
+ * @param budget maximum number of items to process
+ */
+static int liquidio_napi_do_rx(struct octeon_droq *droq, int budget)
+{
+	int work_done;
+	struct lio *lio = GET_LIO(droq->napi.dev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
+						 POLL_EVENT_PROCESS_PKTS,
+						 budget);
+	if (work_done < 0) {
+		lio_info(lio, rx_err,
+			 "Receive work_done < 0, rxq:%d\n", droq->q_no);
+		goto octnet_napi_finish;
+	}
+
+	if (work_done > budget)
+		lio_dev_err(oct, ">>>> %s work_done: %d budget: %d\n",
+			    __func__, work_done, budget);
+
+	return work_done;
+
+octnet_napi_finish:
+	napi_complete(&droq->napi);
+	octeon_process_droq_poll_cmd(oct, droq->q_no, POLL_EVENT_ENABLE_INTR,
+				     0);
+	return 0;
+}
+
+/**
+ * \brief Entry point for NAPI polling
+ * @param napi NAPI structure
+ * @param budget maximum number of items to process
+ */
+static int liquidio_napi_poll(struct napi_struct *napi, int budget)
+{
+	struct octeon_droq *droq;
+	int work_done;
+
+	droq = container_of(napi, struct octeon_droq, napi);
+
+	work_done = liquidio_napi_do_rx(droq, budget);
+
+	if (work_done < budget) {
+		napi_complete(napi);
+		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
+					     POLL_EVENT_ENABLE_INTR, 0);
+		return 0;
+	}
+
+	return work_done;
+}
+
+/**
+ * \brief Setup input and output queues
+ * @param octeon_dev octeon device
+ * @param net_device Net device
+ *
+ * Note: Queues are with respect to the octeon device. Thus
+ * an input queue is for egress packets, and output queues
+ * are for ingress packets.
+ */
+static inline int setup_io_queues(struct octeon_device *octeon_dev,
+				  struct net_device *net_device)
+{
+	static int first_time = 1;
+	static struct octeon_droq_ops droq_ops;
+	static int cpu_id;
+	static int cpu_id_modulus;
+	struct octeon_droq *droq;
+	struct napi_struct *napi;
+	int q, q_no, retval = 0;
+	struct lio *lio;
+	int num_tx_descs;
+
+	lio = GET_LIO(net_device);
+	if (first_time) {
+		first_time = 0;
+		memset(&droq_ops, 0, sizeof(struct octeon_droq_ops));
+
+		droq_ops.fptr = liquidio_push_packet;
+
+		droq_ops.poll_mode = 1;
+		droq_ops.napi_fn = liquidio_napi_drv_callback;
+		cpu_id = 0;
+		cpu_id_modulus = num_present_cpus();
+	}
+
+	/* set up DROQs. */
+	for (q = 0; q < lio->linfo.num_rxpciq; q++) {
+		q_no = lio->linfo.rxpciq[q];
+
+		retval = octeon_setup_droq(octeon_dev, q_no,
+					   CFG_GET_NUM_RX_DESCS_NIC_IF
+						   (octeon_get_conf(octeon_dev),
+						   lio->ifidx),
+					   CFG_GET_NUM_RX_BUF_SIZE_NIC_IF
+						   (octeon_get_conf(octeon_dev),
+						   lio->ifidx), NULL);
+		if (retval) {
+			lio_dev_err(octeon_dev,
+				    " %s : Runtime DROQ(RxQ) creation failed.\n",
+				    __func__);
+			return 1;
+		}
+
+		droq = octeon_dev->droq[q_no];
+		napi = &droq->napi;
+		netif_napi_add(net_device, napi, liquidio_napi_poll, 64);
+
+		/* designate a CPU for this droq */
+		droq->cpu_id = cpu_id;
+		cpu_id++;
+		if (cpu_id >= cpu_id_modulus)
+			cpu_id = 0;
+
+		octeon_register_droq_ops(octeon_dev, q_no, &droq_ops);
+	}
+
+	/* set up IQs. */
+	for (q = 0; q < lio->linfo.num_txpciq; q++) {
+		num_tx_descs = CFG_GET_NUM_TX_DESCS_NIC_IF(octeon_get_conf
+							   (octeon_dev),
+							   lio->ifidx);
+		retval = octeon_setup_iq(octeon_dev, lio->linfo.txpciq[q],
+					 num_tx_descs,
+					 netdev_get_tx_queue(net_device, q));
+		if (retval) {
+			lio_dev_err(octeon_dev,
+				    " %s : Runtime IQ(TxQ) creation failed.\n",
+				    __func__);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
+/**
+ * \brief Poll routine for checking transmit queue status
+ * @param work work_struct data structure
+ */
+static void octnet_poll_check_txq_status(struct work_struct *work)
+{
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct lio *lio = (struct lio *)wk->ctxptr;
+
+	if (!ifstate_check(lio, LIO_IFSTATE_RUNNING))
+		return;
+
+	check_txq_status(lio);
+	queue_delayed_work(lio->txq_status_wq.wq,
+			   &lio->txq_status_wq.wk.work, msecs_to_jiffies(1));
+}
+
+/**
+ * \brief Sets up the txq poll check
+ * @param netdev network device
+ */
+static inline void setup_tx_poll_fn(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	lio->txq_status_wq.wq = create_workqueue("txq-status");
+	if (!lio->txq_status_wq.wq) {
+		lio_dev_err(oct, "unable to create cavium txq status wq\n");
+		return;
+	}
+	INIT_DELAYED_WORK(&lio->txq_status_wq.wk.work,
+			  octnet_poll_check_txq_status);
+	lio->txq_status_wq.wk.ctxptr = lio;
+	queue_delayed_work(lio->txq_status_wq.wq,
+			   &lio->txq_status_wq.wk.work, msecs_to_jiffies(1));
+}
+
+/**
+ * \brief Net device open for LiquidIO
+ * @param netdev network device
+ */
+static int liquidio_open(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct napi_struct *napi, *n;
+
+	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+		napi_enable(napi);
+
+	oct_ptp_open(netdev);
+
+	ifstate_set(lio, LIO_IFSTATE_RUNNING);
+	setup_tx_poll_fn(netdev);
+	start_txq(netdev);
+
+	lio_info(lio, ifup, "Interface Open, ready for traffic\n");
+	try_module_get(THIS_MODULE);
+
+	/* tell Octeon to start forwarding packets to host */
+	send_rx_ctrl_cmd(lio, 1);
+
+	/* Ready for link status updates */
+	spin_lock(&lio->link_update_lock);
+	lio->intf_open = 1;
+	lio->linfo.link.u64 = 0;
+	spin_unlock(&lio->link_update_lock);
+
+	lio_dev_info(oct, "%s interface is opened\n",
+		     netdev->name);
+
+	return 0;
+}
+
+/**
+ * \brief Net device stop for LiquidIO
+ * @param netdev network device
+ */
+static int liquidio_stop(struct net_device *netdev)
+{
+	struct napi_struct *napi, *n;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	lio_info(lio, ifdown, "Stopping interface!\n");
+	/* Inform that netif carrier is down */
+	spin_lock(&lio->link_update_lock);
+	lio->intf_open = 0;
+	lio->linfo.link.u64 = 0;
+	netif_carrier_off(netdev);
+	spin_unlock(&lio->link_update_lock);
+
+	/* tell Octeon to stop forwarding packets to host */
+	send_rx_ctrl_cmd(lio, 0);
+
+	cancel_delayed_work_sync(&lio->txq_status_wq.wk.work);
+	flush_workqueue(lio->txq_status_wq.wq);
+	destroy_workqueue(lio->txq_status_wq.wq);
+
+	if (lio->ptp_clock) {
+		ptp_clock_unregister(lio->ptp_clock);
+		lio->ptp_clock = NULL;
+	}
+
+	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
+
+	/* This is a hack that allows DHCP to continue working. */
+	set_bit(__LINK_STATE_START, &lio->netdev->state);
+
+	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+		napi_disable(napi);
+
+	txqs_stop(netdev);
+
+	lio_dev_info(oct, "%s interface is stopped\n", netdev->name);
+	module_put(THIS_MODULE);
+
+	return 0;
+}
+
+void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
+{
+	struct octnic_ctrl_pkt *nctrl = (struct octnic_ctrl_pkt *)nctrl_ptr;
+	struct net_device *netdev = (struct net_device *)nctrl->netpndev;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	switch (nctrl->ncmd.s.cmd) {
+	case OCTNET_CMD_CHANGE_DEVFLAGS:
+		/* Save a copy of the flags sent to core app in the
+		 * private area.
+		 */
+		lio->core_flags = nctrl->udd[0];
+		break;
+
+	case OCTNET_CMD_CHANGE_MACADDR:
+		/* If command is successful, change the MACADDR. */
+		lio_info(lio, probe, " MACAddr changed to 0x%llx\n",
+			 CVM_CAST64(nctrl->udd[0]));
+		lio_dev_info(oct, "%s MACAddr changed to 0x%llx\n",
+			     netdev->name, CVM_CAST64(nctrl->udd[0]));
+		memcpy(netdev->dev_addr,
+		       ((uint8_t *)&nctrl->udd[0]) + 2, ETH_ALEN);
+		break;
+
+	case OCTNET_CMD_CHANGE_MTU:
+		/* If command is successful, change the MTU. */
+		lio_info(lio, probe, " MTU Changed from %d to %d\n",
+			 netdev->mtu, nctrl->ncmd.s.param2);
+		lio_dev_info(oct, "%s MTU Changed from %d to %d\n",
+			     netdev->name, netdev->mtu,
+			     nctrl->ncmd.s.param2);
+		netdev->mtu = nctrl->ncmd.s.param2;
+		break;
+
+	case OCTNET_CMD_GPIO_ACCESS:
+		lio_info(lio, probe, "LED Flashing visual identification\n");
+
+		break;
+
+	case OCTNET_CMD_LRO_ENABLE:
+		lio_dev_info(oct, "%s LRO Enabled\n", netdev->name);
+		break;
+
+	case OCTNET_CMD_LRO_DISABLE:
+		lio_dev_info(oct, "%s LRO Disabled\n",
+			     netdev->name);
+		break;
+
+	case OCTNET_CMD_SET_SETTINGS:
+		lio_dev_info(oct, "%s settings changed\n",
+			     netdev->name);
+
+		break;
+
+	default:
+		lio_dev_err(oct, "%s Unknown cmd %d\n", __func__,
+			    nctrl->ncmd.s.cmd);
+	}
+}
+
+/**
+ * \brief Converts a mask based on net device flags
+ * @param netdev network device
+ *
+ * This routine generates a octnet_ifflags mask from the net device flags
+ * received from the OS.
+ */
+static inline enum octnet_ifflags get_new_flags(struct net_device *netdev)
+{
+	enum octnet_ifflags f = 0;
+
+	if (netdev->flags & IFF_PROMISC)
+		f |= OCTNET_IFFLAG_PROMISC;
+
+	if (netdev->flags & IFF_ALLMULTI)
+		f |= OCTNET_IFFLAG_ALLMULTI;
+
+	if (netdev->flags & IFF_MULTICAST)
+		f |= OCTNET_IFFLAG_MULTICAST;
+
+	return f;
+}
+
+/**
+ * \brief Net device set_multicast_list
+ * @param netdev network device
+ */
+static void liquidio_set_mcast_list(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	struct octnic_ctrl_params nparams;
+	int ret;
+
+	if (netdev->flags == lio->netdev_flags)
+		return;
+
+	/* Save the OS net device flags. */
+	lio->netdev_flags = netdev->flags;
+
+	ret = liquidio_alloc_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+	if (ret < 0)
+		lio_dev_err(oct, "DEVFLAGS change failed in core (ret: 0x%x)\n",
+			    ret);
+
+	/* Create a ctrl pkt command to be sent to core app. */
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_DEVFLAGS;
+	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
+	nctrl.ncmd.s.param2 = 0;
+	nctrl.ncmd.s.more = 1;
+	nctrl.netpndev = (uint64_t)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	nctrl.udd[0] = (uint64_t)get_new_flags(netdev);
+	octeon_swap_8B_data(&nctrl.udd[0], 1);
+
+	/* Apparently, any activity in this call from the kernel has to
+	 * be atomic. So we won't wait for response.
+	 */
+	nctrl.wait_time = 0;
+
+	nparams.resp_order = OCTEON_RESP_NORESPONSE;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	if (ret < 0) {
+		liquidio_free_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+		lio_dev_err(oct, "DEVFLAGS change failed in core (ret: 0x%x)\n",
+			    ret);
+	}
+}
+
+/**
+ * \brief Net device set_mac_address
+ * @param netdev network device
+ */
+static int liquidio_set_mac(struct net_device *netdev, void *addr)
+{
+	int ret = 0;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct sockaddr *p_sockaddr = (struct sockaddr *)addr;
+	struct octnic_ctrl_pkt nctrl;
+	struct octnic_ctrl_params nparams;
+
+	ret = liquidio_alloc_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		lio_dev_err(oct, "MAC Address change failed\n");
+		return -1;
+	}
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MACADDR;
+	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
+	nctrl.ncmd.s.param2 = 0;
+	nctrl.ncmd.s.more = 1;
+	nctrl.netpndev = (uint64_t)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+	nctrl.wait_time = 100;
+
+	nctrl.udd[0] = 0;
+	/* The MAC Address is presented in network byte order. */
+	memcpy((uint8_t *)&nctrl.udd[0] + 2, p_sockaddr->sa_data,
+	       ETH_ALEN);
+
+	nparams.resp_order = OCTEON_RESP_ORDERED;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	if (ret < 0) {
+		liquidio_free_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+		lio_dev_err(oct, "MAC Address change failed\n");
+		return -1;
+	}
+
+	return 0;
+}
+
+/**
+ * \brief Net device get_stats
+ * @param netdev network device
+ */
+static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct net_device_stats *stats = &netdev->stats;
+	struct octeon_device *oct;
+	uint64_t pkts = 0, drop = 0, bytes = 0;
+	struct oct_droq_stats *oq_stats;
+	struct oct_iq_stats *iq_stats;
+	int i, iq_no, oq_no;
+
+	oct = lio->oct_dev;
+
+	for (i = 0; i < lio->linfo.num_txpciq; i++) {
+		iq_no = lio->linfo.txpciq[i];
+		iq_stats = &oct->instr_queue[iq_no]->stats;
+		pkts += iq_stats->tx_done;
+		drop += iq_stats->tx_dropped;
+		bytes += iq_stats->tx_tot_bytes;
+	}
+
+	stats->tx_packets = pkts;
+	stats->tx_bytes = bytes;
+	stats->tx_dropped = drop;
+
+	pkts = 0;
+	drop = 0;
+	bytes = 0;
+
+	for (i = 0; i < lio->linfo.num_rxpciq; i++) {
+		oq_no = lio->linfo.rxpciq[i];
+		oq_stats = &oct->droq[oq_no]->stats;
+		pkts += oq_stats->rx_pkts_received;
+		drop += (oq_stats->rx_dropped +
+			 oq_stats->dropped_nodispatch +
+			 oq_stats->dropped_toomany +
+			 oq_stats->dropped_nomem);
+		bytes += oq_stats->rx_bytes_received;
+	}
+
+	stats->rx_bytes = bytes;
+	stats->rx_packets = pkts;
+	stats->rx_dropped = drop;
+
+	return stats;
+}
+
+/**
+ * \brief Net device change_mtu
+ * @param netdev network device
+ */
+static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	struct octnic_ctrl_params nparams;
+	int max_frm_size = new_mtu + OCTNET_FRM_HEADER_SIZE;
+	int ret = 0;
+
+	/* Limit the MTU to make sure the ethernet packets are between 64 bytes
+	 * and 65535 bytes
+	 */
+	if ((max_frm_size < OCTNET_MIN_FRM_SIZE) ||
+	    (max_frm_size > OCTNET_MAX_FRM_SIZE)) {
+		lio_dev_err(oct,
+			    "Invalid MTU: %d (Valid values are between %d and %d)\n",
+			    new_mtu,
+			    (OCTNET_MIN_FRM_SIZE - OCTNET_FRM_HEADER_SIZE),
+			    (OCTNET_MAX_FRM_SIZE - OCTNET_FRM_HEADER_SIZE));
+		return -EINVAL;
+	}
+
+	ret = liquidio_alloc_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		lio_dev_err(oct, "Failed to set MTU\n");
+		return -1;
+	}
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MTU;
+	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
+	nctrl.ncmd.s.param2 = new_mtu;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (uint64_t)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	nparams.resp_order = OCTEON_RESP_ORDERED;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	if (ret < 0) {
+		liquidio_free_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+		lio_dev_err(oct, "Failed to set MTU\n");
+		return -1;
+	}
+
+	lio->mtu = new_mtu;
+
+	return 0;
+}
+
+/**
+ * \brief Handler for SIOCSHWTSTAMP ioctl
+ * @param netdev network device
+ * @param ifr interface request
+ * @param cmd command
+ */
+static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	struct hwtstamp_config conf;
+	struct lio *lio = GET_LIO(netdev);
+
+	if (copy_from_user(&conf, ifr->ifr_data, sizeof(conf)))
+		return -EFAULT;
+
+	if (conf.flags)
+		return -EINVAL;
+
+	switch (conf.tx_type) {
+	case HWTSTAMP_TX_ON:
+	case HWTSTAMP_TX_OFF:
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (conf.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_SOME:
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		conf.rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	if (conf.rx_filter == HWTSTAMP_FILTER_ALL)
+		ifstate_set(lio, LIO_IFSTATE_RX_TIMESTAMP_ENABLED);
+
+	else
+		ifstate_reset(lio, LIO_IFSTATE_RX_TIMESTAMP_ENABLED);
+
+	return copy_to_user(ifr->ifr_data, &conf, sizeof(conf)) ? -EFAULT : 0;
+}
+
+/**
+ * \brief ioctl handler
+ * @param netdev network device
+ * @param ifr interface request
+ * @param cmd command
+ */
+static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return hwtstamp_ioctl(netdev, ifr, cmd);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+/**
+ * \brief handle a Tx timestamp response
+ * @param status response status
+ * @param buf pointer to skb
+ */
+static void handle_timestamp(struct octeon_device *oct,
+			     uint32_t status,
+			     void *buf)
+{
+	struct octnet_buf_free_info *finfo;
+	struct octeon_soft_command *sc;
+	struct oct_timestamp_resp *resp;
+	struct lio *lio;
+	struct sk_buff *skb = (struct sk_buff *)buf;
+	struct octeon_instr_irh *irh;
+
+	finfo = (struct octnet_buf_free_info *)skb->cb;
+	lio = finfo->lio;
+	sc = finfo->sc;
+	oct = lio->oct_dev;
+	resp = (struct oct_timestamp_resp *)((uint8_t *)sc +
+	       sizeof(struct octeon_soft_command));
+
+	if (status != OCTEON_REQUEST_DONE) {
+		lio_dev_err(oct, "Tx timestamp instruction failed. Status: %llx\n",
+			    CVM_CAST64(status));
+		resp->timestamp = 0;
+	}
+
+	octeon_swap_8B_data(&resp->timestamp, 1);
+
+	if (unlikely((skb_shinfo(skb)->tx_flags | SKBTX_IN_PROGRESS) != 0)) {
+		struct skb_shared_hwtstamps ts;
+		u64 ns = resp->timestamp;
+
+		lio_info(lio, tx_done,
+			 "Got resulting SKBTX_HW_TSTAMP skb=%p ns=%016llu\n",
+			 skb, (unsigned long long)ns);
+		ts.hwtstamp = ns_to_ktime(ns + lio->ptp_adjust);
+		skb_tstamp_tx(skb, &ts);
+	}
+
+	irh = (struct octeon_instr_irh *)&sc->cmd.irh;
+
+	pci_unmap_single(oct->pci_dev, (dma_addr_t)sc->cmd.rptr,
+			 (uint32_t)((struct octeon_instr_rdp *)
+			 &sc->cmd.rdp)->rlen,
+			 PCI_DMA_FROMDEVICE);
+
+	kfree(sc);
+	recv_buffer_free(skb);
+}
+
+/* \brief Send a data packet that will be timestamped
+ * @param oct octeon device
+ * @param ndata pointer to network data
+ * @param finfo pointer to private network data
+ */
+static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
+					 struct octnic_data_pkt *ndata,
+					 struct octnet_buf_free_info *finfo,
+					 int xmit_more)
+{
+	int retval;
+	struct octeon_soft_command *sc;
+	struct octeon_instr_ih *ih;
+	struct octeon_instr_rdp *rdp;
+	struct lio *lio;
+	int ring_doorbell;
+	struct oct_timestamp_resp *rdata;
+	uint64_t rptr;
+	dma_addr_t dma_addr;
+
+	lio = finfo->lio;
+
+	rdata = kmalloc(sizeof(*rdata), GFP_ATOMIC);
+	if (!rdata)
+		return IQ_SEND_FAILED;
+
+	dma_addr = pci_map_single(oct->pci_dev, rdata,
+				  sizeof(struct oct_timestamp_resp),
+				  PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(oct->pci_dev, dma_addr)) {
+		lio_dev_err(oct, "%s DMA mapping error\n", __func__);
+		kfree(rdata);
+		return IQ_SEND_FAILED;
+	}
+	rptr = (uint64_t)dma_addr;
+
+	sc = octeon_alloc_soft_command_resp(oct, &ndata->cmd, rdata, rptr,
+					    sizeof(struct oct_timestamp_resp));
+	finfo->sc = sc;
+
+	if (!sc) {
+		lio_dev_err(oct, "No memory for timestamped data packet\n");
+		pci_unmap_single(oct->pci_dev, rptr,
+				 sizeof(struct oct_timestamp_resp),
+				 PCI_DMA_FROMDEVICE);
+		kfree(rdata);
+		return IQ_SEND_FAILED;
+	}
+
+	if (ndata->reqtype == REQTYPE_NORESP_NET)
+		ndata->reqtype = REQTYPE_RESP_NET;
+	else if (ndata->reqtype == REQTYPE_NORESP_NET_SG)
+		ndata->reqtype = REQTYPE_RESP_NET_SG;
+
+	sc->callback = handle_timestamp;
+	sc->callback_arg = finfo->skb;
+	sc->iq_no = ndata->q_no;
+
+	ih = (struct octeon_instr_ih *)&sc->cmd.ih;
+	rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+
+	ring_doorbell = !xmit_more;
+	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
+				     sc, ih->dlengsz, ndata->reqtype);
+
+	if (retval) {
+		lio_dev_err(oct, "timestamp data packet failed status: %x\n",
+			    retval);
+		pci_unmap_single(oct->pci_dev, rptr,
+				 sizeof(struct oct_timestamp_resp),
+				 PCI_DMA_FROMDEVICE);
+		kfree(rdata);
+		kfree(sc);
+	} else {
+		lio_info(lio, tx_queued, "Queued timestamp packet\n");
+	}
+
+	return retval;
+}
+
+static inline int is_ipv4(struct sk_buff *skb)
+{
+	return (skb->protocol == htons(ETH_P_IP)) &&
+	       (ip_hdr(skb)->version == 4) &&
+	       (ip_hdr(skb)->ihl == 5);
+}
+
+static inline int is_vlan(struct sk_buff *skb)
+{
+	return skb->protocol == htons(ETH_P_8021Q);
+}
+
+static inline int is_ip_fragmented(struct sk_buff *skb)
+{
+	/* The Don't fragment and Reserved flag fields are ignored.
+	 * IP is fragmented if
+	 * -  the More fragments bit is set (indicating this IP is a fragment
+	 * with more to follow; the current offset could be 0 ).
+	 * -  ths offset field is non-zero.
+	 */
+	return htons(ip_hdr(skb)->frag_off) & 0x3fff;
+}
+
+static inline int is_ipv6(struct sk_buff *skb)
+{
+	return (skb->protocol == htons(ETH_P_IPV6)) &&
+	       (ipv6_hdr(skb)->version == 6);
+}
+
+static inline int is_wo_extn_hdr(struct sk_buff *skb)
+{
+	return (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP) ||
+	       (ipv6_hdr(skb)->nexthdr == IPPROTO_UDP);
+}
+
+static inline int is_tcpudp(struct sk_buff *skb)
+{
+	return (ip_hdr(skb)->protocol == IPPROTO_TCP) ||
+	       (ip_hdr(skb)->protocol == IPPROTO_UDP);
+}
+
+/** \brief Transmit networks packets to the Octeon interface
+ * @param skbuff   skbuff struct to be passed to network layer.
+ * @param netdev    pointer to network device
+ * @returns whether the packet was transmitted to the device okay or not
+ *             (NETDEV_TX_OK or NETDEV_TX_BUSY)
+ */
+static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct lio *lio;
+	struct octnet_buf_free_info *finfo;
+	union octnic_cmd_setup cmdsetup;
+	struct octnic_data_pkt ndata;
+	struct octeon_device *oct;
+	struct oct_iq_stats *stats;
+	int cpu = 0, status = 0;
+	int q_idx = 0, iq_no = 0;
+	int xmit_more;
+
+	lio = GET_LIO(netdev);
+	oct = lio->oct_dev;
+
+	if (netif_is_multiqueue(netdev)) {
+		cpu = skb->queue_mapping;
+		q_idx = (cpu & (lio->linfo.num_txpciq - 1));
+		iq_no = lio->linfo.txpciq[q_idx];
+	} else {
+		iq_no = lio->txq;
+	}
+
+	stats = &oct->instr_queue[iq_no]->stats;
+
+	/* Check for all conditions in which the current packet cannot be
+	 * transmitted.
+	 */
+	if (!(atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING) ||
+	    (!lio->linfo.link.s.status) ||
+	    (skb->len <= 0)) {
+		lio_info(lio, tx_err,
+			 "Transmit failed link_status : %d\n",
+			 lio->linfo.link.s.status);
+		goto lio_xmit_failed;
+	}
+
+	/* Use space in skb->cb to store info used to unmap and
+	 * free the buffers.
+	 */
+	finfo = (struct octnet_buf_free_info *)skb->cb;
+	finfo->lio = lio;
+	finfo->skb = skb;
+	finfo->sc = NULL;
+
+	/* Prepare the attributes for the data to be passed to OSI. */
+	ndata.buf = (void *)finfo;
+
+	ndata.q_no = iq_no;
+
+	if (netif_is_multiqueue(netdev)) {
+		if (octnet_iq_is_full(oct, ndata.q_no)) {
+			/* defer sending if queue is full */
+			lio_info(lio, tx_err, "Transmit failed iq:%d full\n",
+				 ndata.q_no);
+			stats->tx_iq_busy++;
+			return NETDEV_TX_BUSY;
+		}
+	} else {
+		if (octnet_iq_is_full(oct, lio->txq)) {
+			/* defer sending if queue is full */
+			stats->tx_iq_busy++;
+			lio_info(lio, tx_err, "Transmit failed iq:%d full\n",
+				 ndata.q_no);
+			return NETDEV_TX_BUSY;
+		}
+	}
+	/* pr_info(" XMIT - valid Qs: %d, 1st Q no: %d, cpu:  %d, q_no:%d\n",
+	 *	lio->linfo.num_txpciq, lio->txq, cpu, ndata.q_no );
+	 */
+
+	ndata.datasize = skb->len;
+
+	cmdsetup.u64 = 0;
+	cmdsetup.s.ifidx = lio->linfo.ifidx;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if ((is_ipv4(skb) && !is_ip_fragmented(skb) &&
+		     is_tcpudp(skb)) ||
+		    (is_ipv6(skb) && is_wo_extn_hdr(skb)))
+			cmdsetup.s.cksum_offset = sizeof(struct ethhdr) + 1;
+		else if (is_vlan(skb) && !is_ip_fragmented(skb) &&
+			 is_tcpudp(skb))
+			cmdsetup.s.cksum_offset =
+				sizeof(struct vlan_hdr) + 1;
+	}
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		cmdsetup.s.timestamp = 1;
+	}
+
+	if (skb_shinfo(skb)->nr_frags == 0) {
+		cmdsetup.s.u.datasize = skb->len;
+		octnet_prepare_pci_cmd(&ndata.cmd, &cmdsetup);
+		/* Offload checksum calculation for TCP/UDP packets */
+		ndata.cmd.dptr = pci_map_single(oct->pci_dev,
+						skb->data,
+						skb->len,
+						PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(oct->pci_dev, ndata.cmd.dptr)) {
+			lio_dev_err(oct, "%s DMA mapping error 1\n",
+				    __func__);
+			return NETDEV_TX_BUSY;
+		}
+
+		finfo->dptr = ndata.cmd.dptr;
+
+		ndata.reqtype = REQTYPE_NORESP_NET;
+
+	} else {
+		int i, frags;
+		struct skb_frag_struct *frag;
+		struct octnic_gather *g;
+
+		spin_lock(&lio->lock);
+		g = (struct octnic_gather *)
+		    list_delete_head(&lio->glist);
+		spin_unlock(&lio->lock);
+
+		if (!g) {
+			lio_info(lio, tx_err,
+				 "Transmit scatter gather: glist null!\n");
+			goto lio_xmit_failed;
+		}
+
+		cmdsetup.s.gather = 1;
+		cmdsetup.s.u.gatherptrs = (skb_shinfo(skb)->nr_frags + 1);
+		octnet_prepare_pci_cmd(&ndata.cmd, &cmdsetup);
+
+		memset(g->sg, 0, g->sg_size);
+
+		g->sg[0].ptr[0] = pci_map_single(oct->pci_dev,
+						 skb->data,
+						 (skb->len - skb->data_len),
+						 PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(oct->pci_dev, g->sg[0].ptr[0])) {
+			lio_dev_err(oct, "%s DMA mapping error 2\n",
+				    __func__);
+			return NETDEV_TX_BUSY;
+		}
+		add_sg_size(&g->sg[0], (skb->len - skb->data_len), 0);
+
+		frags = skb_shinfo(skb)->nr_frags;
+		i = 1;
+		while (frags--) {
+			frag = &skb_shinfo(skb)->frags[i - 1];
+
+			g->sg[(i >> 2)].ptr[(i & 3)] =
+				pci_map_page(oct->pci_dev,
+					     frag->page.p,
+					     frag->page_offset,
+					     frag->size,
+					     PCI_DMA_TODEVICE);
+
+			add_sg_size(&g->sg[(i >> 2)], frag->size, (i & 3));
+			i++;
+		}
+
+		ndata.cmd.dptr = pci_map_single(oct->pci_dev,
+						g->sg, g->sg_size,
+						PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(oct->pci_dev, ndata.cmd.dptr)) {
+			lio_dev_err(oct, "%s DMA mapping error 3\n",
+				    __func__);
+			pci_unmap_single(oct->pci_dev, g->sg[0].ptr[0],
+					 skb->len - skb->data_len,
+					 PCI_DMA_TODEVICE);
+			return NETDEV_TX_BUSY;
+		}
+
+		finfo->dptr = ndata.cmd.dptr;
+		finfo->g = g;
+
+		ndata.reqtype = REQTYPE_NORESP_NET_SG;
+	}
+
+	if (skb_shinfo(skb)->gso_size) {
+		struct octeon_instr_irh *irh =
+			(struct octeon_instr_irh *)&ndata.cmd.irh;
+		union tx_info *tx_info = (union tx_info *)&ndata.cmd.ossp[0];
+
+		irh->len = 1;   /* to indicate that ossp[0] contains tx_info */
+		tx_info->s.gso_size = skb_shinfo(skb)->gso_size;
+		tx_info->s.gso_segs = skb_shinfo(skb)->gso_segs;
+	}
+
+	xmit_more = skb->xmit_more;
+
+	if (unlikely(cmdsetup.s.timestamp))
+		status = send_nic_timestamp_pkt(oct, &ndata, finfo, xmit_more);
+	else
+		status = octnet_send_nic_data_pkt(oct, &ndata, xmit_more);
+	if (status == IQ_SEND_FAILED)
+		goto lio_xmit_failed;
+
+	lio_info(lio, tx_queued, "Transmit queued successfully\n");
+
+	if (status == IQ_SEND_STOP)
+		stop_q(lio->netdev, q_idx);
+
+	netdev->trans_start = jiffies;
+
+	stats->tx_done++;
+	stats->tx_tot_bytes += skb->len;
+
+	return NETDEV_TX_OK;
+
+lio_xmit_failed:
+	stats->tx_dropped++;
+	lio_info(lio, tx_err, "IQ%d Transmit dropped:%llu\n",
+		 iq_no, stats->tx_dropped);
+	pci_unmap_single(oct->pci_dev, ndata.cmd.dptr,
+			 ndata.datasize, PCI_DMA_TODEVICE);
+	recv_buffer_free(skb);
+	return NETDEV_TX_OK;
+}
+
+/** \brief Network device Tx timeout
+ * @param netdev    pointer to network device
+ */
+static void liquidio_tx_timeout(struct net_device *netdev)
+{
+	struct lio *lio;
+
+	lio = GET_LIO(netdev);
+
+	lio_info(lio, tx_err,
+		 "Transmit timeout tx_dropped:%ld, waking up queues now!!\n",
+		 netdev->stats.tx_dropped);
+	netdev->trans_start = jiffies;
+	txqs_wake(netdev);
+}
+
+int liquidio_set_lro(struct net_device *netdev, int cmd)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	struct octnic_ctrl_params nparams;
+	int ret = 0;
+
+	ret = liquidio_alloc_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		lio_dev_err(oct, "DEVFLAGS change failed in core (ret: 0x%x)\n",
+			    ret);
+	}
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = cmd;
+	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (uint64_t)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	nparams.resp_order = OCTEON_RESP_NORESPONSE;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	if (ret < 0) {
+		liquidio_free_ctrl_pkt_buffers(lio->oct_dev, &nctrl);
+		lio_dev_err(oct, "DEVFLAGS change failed in core (ret: 0x%x)\n",
+			    ret);
+	}
+	return ret;
+}
+
+/** \brief Net device fix features
+ * @param netdev  pointer to network device
+ * @param request features requested
+ * @returns updated features list
+ */
+static netdev_features_t liquidio_fix_features(struct net_device *netdev,
+					       netdev_features_t request)
+{
+	struct lio *lio = netdev_priv(netdev);
+
+	if ((request & NETIF_F_RXCSUM) &&
+	    !(lio->dev_capability & NETIF_F_RXCSUM))
+		request &= ~NETIF_F_RXCSUM;
+
+	if ((request & NETIF_F_HW_CSUM) &&
+	    !(lio->dev_capability & NETIF_F_HW_CSUM))
+		request &= ~NETIF_F_HW_CSUM;
+
+	if ((request & NETIF_F_TSO) && !(lio->dev_capability & NETIF_F_TSO))
+		request &= ~NETIF_F_TSO;
+
+	if ((request & NETIF_F_TSO6) && !(lio->dev_capability & NETIF_F_TSO6))
+		request &= ~NETIF_F_TSO6;
+
+	if ((request & NETIF_F_LRO) && !(lio->dev_capability & NETIF_F_LRO))
+		request &= ~NETIF_F_LRO;
+
+	/*Disable LRO if RXCSUM is off */
+	if (!(request & NETIF_F_RXCSUM) && (netdev->features & NETIF_F_LRO) &&
+	    (lio->dev_capability & NETIF_F_LRO))
+		request &= ~NETIF_F_LRO;
+
+	return request;
+}
+
+/** \brief Net device set features
+ * @param netdev  pointer to network device
+ * @param features features to enable/disable
+ */
+static int liquidio_set_features(struct net_device *netdev,
+				 netdev_features_t features)
+{
+	struct lio *lio = netdev_priv(netdev);
+
+	if (!((netdev->features ^ features) & NETIF_F_LRO))
+		return 0;
+
+	if ((features & NETIF_F_LRO) && (lio->dev_capability & NETIF_F_LRO))
+		liquidio_set_lro(netdev, OCTNET_CMD_LRO_ENABLE);
+	else if (!(features & NETIF_F_LRO) &&
+		 (lio->dev_capability & NETIF_F_LRO))
+		liquidio_set_lro(netdev, OCTNET_CMD_LRO_DISABLE);
+
+	return 0;
+}
+
+static struct net_device_ops lionetdevops = {
+	.ndo_open		= liquidio_open,
+	.ndo_stop		= liquidio_stop,
+	.ndo_start_xmit		= liquidio_xmit,
+	.ndo_get_stats		= liquidio_get_stats,
+	.ndo_set_mac_address	= liquidio_set_mac,
+	.ndo_set_rx_mode	= liquidio_set_mcast_list,
+	.ndo_tx_timeout		= liquidio_tx_timeout,
+	.ndo_change_mtu		= liquidio_change_mtu,
+	.ndo_do_ioctl		= liquidio_ioctl,
+	.ndo_fix_features	= liquidio_fix_features,
+	.ndo_set_features	= liquidio_set_features,
+};
+
+/** \brief Entry point for the liquidio module
+ */
+static int __init liquidio_init(void)
+{
+	int i;
+	struct handshake *hs;
+
+	init_completion(&first_stage);
+
+	octeon_init_device_list();
+
+	if (liquidio_init_pci())
+		return -EINVAL;
+
+	wait_for_completion_timeout(&first_stage, msecs_to_jiffies(1000));
+
+	for (i = 0; i < MAX_OCTEON_DEVICES; i++) {
+		hs = &handshake[i];
+		if (hs->pci_dev) {
+			wait_for_completion(&hs->init);
+			if (!hs->init_ok) {
+				/* init handshake failed */
+				dev_err(&hs->pci_dev->dev,
+					"Failed to init device\n");
+				liquidio_deinit_pci();
+				return -EIO;
+			}
+		}
+	}
+
+	for (i = 0; i < MAX_OCTEON_DEVICES; i++) {
+		hs = &handshake[i];
+		if (hs->pci_dev) {
+			wait_for_completion_timeout(&hs->started,
+						    msecs_to_jiffies(30000));
+			if (!hs->started_ok) {
+				/* starter handshake failed */
+				dev_err(&hs->pci_dev->dev,
+					"Firmware failed to start\n");
+				liquidio_deinit_pci();
+				return -EIO;
+			}
+		}
+	}
+
+	return 0;
+}
+
+/**
+ * \brief Setup network interfaces
+ * @param octeon_dev  octeon device
+ *
+ * Called during init time for each device. It assumes the NIC
+ * is already up and running.  The link information for each
+ * interface is passed in link_info.
+ */
+static int setup_nic_devices(struct octeon_device *octeon_dev)
+{
+	struct lio *lio = NULL;
+	struct net_device *netdev;
+	uint8_t macaddr[6], i, j;
+	struct octeon_soft_command *sc;
+	struct liquidio_if_cfg_resp *resp;
+	int retval;
+	int num_iqueues;
+	int num_oqueues;
+	int q_no;
+	uint64_t q_mask;
+	int num_cpus = num_online_cpus();
+	uint64_t rdata;
+	size_t rdatasize;
+	dma_addr_t dma_addr;
+
+	if (num_cpus & (num_cpus - 1))
+		/* numcpus is not a power of 2 */
+		num_cpus = 1U << (fls(num_cpus) - 1);
+
+	sc = kmalloc(sizeof(*sc), GFP_KERNEL);
+	if (!sc)
+		return -ENOMEM;
+
+	resp = kmalloc(sizeof(*resp), GFP_KERNEL);
+	if (!resp) {
+		kfree(sc);
+		return -ENOMEM;
+	}
+
+	rdatasize = (sizeof(struct liquidio_if_cfg_resp) - sizeof(resp->s));
+	dma_addr = pci_map_single(octeon_dev->pci_dev, &resp->rh, rdatasize,
+				  PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(octeon_dev->pci_dev, dma_addr)) {
+		lio_dev_err(octeon_dev, "%s DMA mapping error\n", __func__);
+		kfree(sc);
+		kfree(resp);
+		return -ENOMEM;
+	}
+	rdata = (uint64_t)dma_addr;
+
+	for (i = 0; i < octeon_dev->props.ifcount; i++) {
+		memset(sc, 0, sizeof(struct octeon_soft_command));
+		memset(resp, 0, sizeof(struct liquidio_if_cfg_resp));
+		num_iqueues =
+			CFG_GET_NUM_TXQS_NIC_IF(octeon_get_conf(octeon_dev), i);
+		num_oqueues =
+			CFG_GET_NUM_RXQS_NIC_IF(octeon_get_conf(octeon_dev), i);
+		if (num_iqueues > num_cpus)
+			num_iqueues = num_cpus;
+		if (num_oqueues > num_cpus)
+			num_oqueues = num_cpus;
+		lio_dev_dbg(octeon_dev,
+			    "requesting config for interface %d, iqs %d, oqs %d\n",
+			    i, num_iqueues, num_oqueues);
+		ACCESS_ONCE(resp->s.cond) = 0;
+		resp->s.octeon_id = lio_get_device_id(octeon_dev);
+		init_waitqueue_head(&resp->s.wc);
+
+		octeon_prepare_soft_command(octeon_dev, sc, OPCODE_NIC,
+					    OPCODE_NIC_IF_CFG, i, num_iqueues,
+					    num_oqueues, NULL, 0, 0,
+					    &resp->rh, rdata, rdatasize);
+
+		sc->callback = if_cfg_callback;
+		sc->callback_arg = resp;
+		sc->wait_time = 1000;
+
+		retval = octeon_send_soft_command(octeon_dev, sc);
+		if (retval) {
+			lio_dev_err(octeon_dev,
+				    "iq/oq config failed status: %x\n",
+				    retval);
+			/* Soft instr is freed by driver in case of failure. */
+			goto setup_nic_dev_fail;
+		}
+
+		/* Sleep on a wait queue till the cond flag indicates that the
+		 * response arrived or timed-out.
+		 */
+		sleep_cond(&resp->s.wc, &resp->s.cond);
+		retval = resp->status;
+		if (retval) {
+			lio_dev_err(octeon_dev, "iq/oq config failed\n");
+			goto setup_nic_dev_fail;
+		}
+		octeon_swap_8B_data((uint64_t *)(&resp->cfg_info),
+				    (sizeof(struct liquidio_if_cfg_info)) >> 3);
+
+		num_iqueues = hweight64(resp->cfg_info.iqmask);
+		num_oqueues = hweight64(resp->cfg_info.oqmask);
+
+		if (!(num_iqueues) || !(num_oqueues)) {
+			lio_dev_err(octeon_dev,
+				    "Got bad iqueues (%016llx) or oqueues (%016llx) from firmware.\n",
+				    resp->cfg_info.iqmask,
+				    resp->cfg_info.oqmask);
+			goto setup_nic_dev_fail;
+		}
+		lio_dev_dbg(octeon_dev,
+			    "interface %d, iqmask %016llx, oqmask %016llx, numiqueues %d, numoqueues %d\n",
+			    i, resp->cfg_info.iqmask, resp->cfg_info.oqmask,
+			    num_iqueues, num_oqueues);
+		netdev = alloc_etherdev_mq(LIO_SIZE, num_iqueues);
+
+		if (!netdev) {
+			lio_dev_err(octeon_dev, "Device allocation failed\n");
+			goto setup_nic_dev_fail;
+		}
+
+		octeon_dev->props.netdev[i] = netdev;
+
+		if (num_iqueues > 1)
+			lionetdevops.ndo_select_queue = select_q;
+
+		/* Associate the routines that will handle different
+		 * netdev tasks.
+		 */
+		netdev->netdev_ops = &lionetdevops;
+
+		lio = GET_LIO(netdev);
+
+		memset(lio, 0, sizeof(struct lio));
+
+		lio->linfo.ifidx = resp->cfg_info.ifidx;
+		lio->ifidx = resp->cfg_info.ifidx;
+
+		lio->linfo.num_rxpciq = num_oqueues;
+		lio->linfo.num_txpciq = num_iqueues;
+		q_mask = resp->cfg_info.oqmask;
+		/* q_mask is 0-based and already verified mask is nonzero */
+		for (j = 0; j < num_oqueues; j++) {
+			q_no = __ffs64(q_mask);
+			q_mask &= (~(1UL << q_no));
+			lio->linfo.rxpciq[j] = q_no;
+		}
+		q_mask = resp->cfg_info.iqmask;
+		for (j = 0; j < num_iqueues; j++) {
+			q_no = __ffs64(q_mask);
+			q_mask &= (~(1UL << q_no));
+			lio->linfo.txpciq[j] = q_no;
+		}
+		retval = get_inittime_link_status(octeon_dev,
+						  &octeon_dev->props, i);
+		if (retval) {
+			lio_dev_err(octeon_dev, "link status failed\n");
+			goto setup_nic_dev_fail;
+		}
+		lio->linfo.hw_addr = octeon_dev->props.ls->link_info.hw_addr;
+		lio->linfo.gmxport = octeon_dev->props.ls->link_info.gmxport;
+
+		lio->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+
+		lio->dev_capability =
+			NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
+		lio->dev_capability |=
+			(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_LRO);
+		netif_set_gso_max_size(netdev, GSO_MAX_SIZE - ETH_HLEN - 4);
+
+		netdev->features = lio->dev_capability;
+		netdev->vlan_features = lio->dev_capability;
+
+		netdev->hw_features = lio->dev_capability;
+
+		/* Point to the  properties for octeon device to which this
+		 * interface belongs.
+		 */
+		lio->oct_dev = octeon_dev;
+		lio->octprops = &octeon_dev->props;
+		lio->netdev = netdev;
+		spin_lock_init(&lio->lock);
+
+		lio_dev_dbg(octeon_dev, "if%d gmx: %d hw_addr: 0x%llx\n", i,
+			    lio->linfo.gmxport, CVM_CAST64(lio->linfo.hw_addr));
+
+		/* 64-bit swap required on LE machines */
+		octeon_swap_8B_data(&lio->linfo.hw_addr, 1);
+		for (j = 0; j < 6; j++)
+			macaddr[j] =
+				*((uint8_t *)(((uint8_t *)&lio->linfo.hw_addr) +
+					     2 + j));
+
+		/* Copy MAC Address to OS network device structure */
+
+		ether_addr_copy(netdev->dev_addr, macaddr);
+
+		lio->linfo.link.u64 = octeon_dev->props.ls->link_info.link.u64;
+		spin_lock_init(&lio->link_update_lock);
+
+		if (setup_io_queues(octeon_dev, netdev)) {
+			lio_dev_err(octeon_dev, "I/O queues creation failed\n");
+			goto setup_nic_dev_fail;
+		}
+
+		ifstate_set(lio, LIO_IFSTATE_DROQ_OPS);
+
+		/* By default all interfaces on a single Octeon uses the same
+		 * tx and rx queues
+		 */
+		lio->txq = lio->linfo.txpciq[0];
+		lio->rxq = lio->linfo.rxpciq[0];
+
+		lio->tx_qsize = octeon_get_tx_qsize(octeon_dev, lio->txq);
+		lio->rx_qsize = octeon_get_rx_qsize(octeon_dev, lio->rxq);
+
+		if (setup_glist(lio)) {
+			lio_dev_err(octeon_dev,
+				    "Gather list allocation failed\n");
+			goto setup_nic_dev_fail;
+		}
+
+		/* Register ethtool support */
+		liquidio_set_ethtool_ops(netdev);
+
+		/* Register the network device with the OS */
+		if (register_netdev(netdev)) {
+			lio_dev_err(octeon_dev, "Device registration failed\n");
+			goto setup_nic_dev_fail;
+		}
+
+		lio_dev_dbg(octeon_dev,
+			    "Setup NIC ifidx:%d mac:%02x%02x%02x%02x%02x%02x\n",
+			    i, macaddr[0], macaddr[1], macaddr[2], macaddr[3],
+			    macaddr[4], macaddr[5]);
+		netif_carrier_off(netdev);
+
+		if (lio->linfo.link.s.status) {
+			netif_carrier_on(netdev);
+			start_txq(netdev);
+		} else {
+			netif_carrier_off(netdev);
+		}
+
+		ifstate_set(lio, LIO_IFSTATE_REGISTERED);
+
+		liquidio_set_lro(netdev, OCTNET_CMD_LRO_ENABLE);
+
+		print_link_info(netdev);
+		lio_dev_dbg(octeon_dev, "NIC ifidx:%d Setup successful\n", i);
+	}
+	pci_unmap_single(octeon_dev->pci_dev,
+			 rdata, rdatasize,
+			 PCI_DMA_FROMDEVICE);
+	kfree(sc);
+	kfree(resp);
+	return 0;
+
+setup_nic_dev_fail:
+
+	while (i--) {
+		lio_dev_err(octeon_dev, "NIC ifidx:%d Setup failed\n", i);
+		liquidio_destroy_nic_device(octeon_dev, i);
+	}
+	pci_unmap_single(octeon_dev->pci_dev,
+			 rdata, rdatasize,
+			 PCI_DMA_FROMDEVICE);
+	kfree(sc);
+	kfree(resp);
+	return -ENODEV;
+}
+
+/**
+ * \brief initialize the NIC
+ * @param oct octeon device
+ *
+ * This initialization routine is called once the Octeon device application is
+ * up and running
+ */
+static int liquidio_init_nic_module(struct octeon_device *oct)
+{
+	struct oct_link_status_resp *ls = NULL;
+	struct octeon_soft_command *sc = NULL;
+	struct oct_intrmod_cfg *intrmod_cfg;
+	int retval = 0;
+	int num_nic_ports = CFG_GET_NUM_NIC_PORTS(octeon_get_conf(oct));
+
+	lio_dev_dbg(oct, "Initializing network interfaces\n");
+
+	memset(&oct->props, 0, sizeof(struct octdev_props_t));
+
+	/* only default iq and oq were initialized
+	 * initialize the rest as well
+	 */
+	/* run port_config command for each port */
+	oct->props.ifcount = num_nic_ports;
+
+	/* Allocate a buffer to collect link status from the core app. */
+	ls = kmalloc(sizeof(*ls), GFP_KERNEL);
+	if (!ls)
+		return -ENOMEM;
+
+	oct->props.ls = ls;
+
+	/* Allocate a soft command to be used to send link status requests
+	 * to the core app.
+	 */
+	sc = kmalloc(sizeof(*sc), GFP_KERNEL);
+	if (!sc) {
+		kfree(ls);
+		return -ENOMEM;
+	}
+
+	oct->props.sc_link_status = sc;
+	retval = setup_nic_devices(oct);
+	if (retval) {
+		lio_dev_err(oct, "Setup NIC devices failed\n");
+		goto octnet_init_failure;
+	}
+	liquidio_ptp_init(oct);
+
+	/* Initialize interrupt moderation params */
+	intrmod_cfg = &((struct octeon_device *)oct)->intrmod;
+	intrmod_cfg->intrmod_enable = 1;
+	intrmod_cfg->intrmod_check_intrvl = LIO_INTRMOD_CHECK_INTERVAL;
+	intrmod_cfg->intrmod_maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
+	intrmod_cfg->intrmod_minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
+	intrmod_cfg->intrmod_maxcnt_trigger = LIO_INTRMOD_MAXCNT_TRIGGER;
+	intrmod_cfg->intrmod_maxtmr_trigger = LIO_INTRMOD_MAXTMR_TRIGGER;
+	intrmod_cfg->intrmod_mintmr_trigger = LIO_INTRMOD_MINTMR_TRIGGER;
+	intrmod_cfg->intrmod_mincnt_trigger = LIO_INTRMOD_MINCNT_TRIGGER;
+
+	/* REQTYPE_RESP_NET and REQTYPE_SOFT_COMMAND do not have free functions.
+	 * They are handled directly.
+	 */
+	octeon_register_reqtype_free_fn(oct, REQTYPE_NORESP_NET,
+					free_netbuf);
+
+	octeon_register_reqtype_free_fn(oct, REQTYPE_NORESP_NET_SG,
+					free_netsgbuf);
+
+	octeon_register_reqtype_free_fn(oct, REQTYPE_RESP_NET_SG,
+					free_netsgbuf_with_resp);
+
+	oct->link_status_wq.wq = create_workqueue("link-status-wq");
+	if (!oct->link_status_wq.wq) {
+		lio_dev_err(oct,
+			    "creating link status workqueue failed\n");
+		goto octnet_init_failure;
+	}
+	oct->link_status_wq.wk.ctxptr = oct;
+	INIT_DELAYED_WORK(&oct->link_status_wq.wk.work,
+			  octnet_get_runtime_link_status);
+	queue_delayed_work(oct->link_status_wq.wq, &oct->link_status_wq.wk.work,
+			   msecs_to_jiffies(LIQUIDIO_LINK_QUERY_INTERVAL_MS));
+
+	lio_dev_dbg(oct, "Network interfaces ready\n");
+
+	return retval;
+
+octnet_init_failure:
+	lio_dev_err(oct, "Initialization Failed\n");
+	kfree(sc);
+	kfree(ls);
+
+	return retval;
+}
+
+/**
+ * \brief starter callback that invokes the remaining initialization work after
+ * the NIC is up and running.
+ * @param octptr  work struct work_struct
+ */
+static void nic_starter(struct work_struct *work)
+{
+	struct octeon_device *oct;
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+
+	oct = (struct octeon_device *)wk->ctxptr;
+
+	if (atomic_read(&oct->status) == OCT_DEV_RUNNING)
+		return;
+
+	/* If the status of the device is CORE_OK, the core
+	 * application has reported its application type. Call
+	 * any registered handlers now and move to the RUNNING
+	 * state.
+	 */
+	if (atomic_read(&oct->status) != OCT_DEV_CORE_OK) {
+		schedule_delayed_work(&oct->nic_poll_work.work,
+				      LIQUIDIO_STARTER_POLL_INTERVAL_MS);
+		return;
+	}
+
+	atomic_set(&oct->status, OCT_DEV_RUNNING);
+
+	if (oct->app_mode && oct->app_mode == CVM_DRV_NIC_APP) {
+		lio_dev_dbg(oct, "Starting NIC module\n");
+
+		if (liquidio_init_nic_module(oct))
+			lio_dev_err(oct, "NIC initialization failed\n");
+		else
+			handshake[oct->octeon_id].started_ok = 1;
+	} else {
+		lio_dev_err(oct,
+			    "Unexpected application running on NIC (%d). Check firmware.\n",
+			    oct->app_mode);
+	}
+
+	complete(&handshake[oct->octeon_id].started);
+}
+
+/**
+ * \brief Device initialization for each Octeon device that is probed
+ * @param octeon_dev  octeon device
+ */
+static int octeon_device_init(struct octeon_device *octeon_dev)
+{
+	int j, ret;
+	struct octeon_device_priv *oct_priv =
+		(struct octeon_device_priv *)octeon_dev->priv;
+
+	atomic_set(&octeon_dev->status, OCT_DEV_BEGIN_STATE);
+
+	/* Enable access to the octeon device and make its DMA capability
+	 * known to the OS.
+	 */
+	if (octeon_pci_os_setup(octeon_dev))
+		return 1;
+
+	/* Identify the Octeon type and map the BAR address space. */
+	if (octeon_chip_specific_setup(octeon_dev)) {
+		lio_dev_err(octeon_dev, "Chip specific setup failed\n");
+		return 1;
+	}
+
+	atomic_set(&octeon_dev->status, OCT_DEV_PCI_MAP_DONE);
+
+	spin_lock_init(&octeon_dev->oct_lock);
+
+	octeon_dev->app_mode = CVM_DRV_INVALID_APP;
+
+	/* Do a soft reset of the Octeon device. */
+	if (octeon_dev->fn_list.soft_reset(octeon_dev))
+		return 1;
+
+	/* Initialize the dispatch mechanism used to push packets arriving on
+	 * Octeon Output queues.
+	 */
+	if (octeon_init_dispatch_list(octeon_dev))
+		return 1;
+
+	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
+				    OPCODE_NIC_CORE_DRV_ACTIVE,
+				    octeon_core_drv_init,
+				    octeon_dev);
+
+	INIT_DELAYED_WORK(&octeon_dev->nic_poll_work.work, nic_starter);
+	octeon_dev->nic_poll_work.ctxptr = (void *)octeon_dev;
+	schedule_delayed_work(&octeon_dev->nic_poll_work.work,
+			      LIQUIDIO_STARTER_POLL_INTERVAL_MS);
+
+	atomic_set(&octeon_dev->status, OCT_DEV_DISPATCH_INIT_DONE);
+
+	octeon_set_io_queues_off(octeon_dev);
+
+	/*  Setup the data structures that manage this Octeon's Input queues. */
+	if (octeon_setup_instr_queues(octeon_dev)) {
+		lio_dev_err(octeon_dev,
+			    "instruction queue initialization failed\n");
+		/* On error, release any previously allocated queues */
+		for (j = 0; j < octeon_dev->num_iqs; j++)
+			octeon_delete_instr_queue(octeon_dev, j);
+		return 1;
+	}
+
+	atomic_set(&octeon_dev->status, OCT_DEV_INSTR_QUEUE_INIT_DONE);
+
+	/* Initialize lists to manage the requests of different types that
+	 * arrive from user & kernel applications for this octeon device.
+	 */
+	if (octeon_setup_response_list(octeon_dev)) {
+		lio_dev_err(octeon_dev, "Response list allocation failed\n");
+		return 1;
+	}
+	atomic_set(&octeon_dev->status, OCT_DEV_RESP_LIST_INIT_DONE);
+
+	if (octeon_setup_output_queues(octeon_dev)) {
+		lio_dev_err(octeon_dev, "Output queue initialization failed\n");
+		/* Release any previously allocated queues */
+		for (j = 0; j < octeon_dev->num_oqs; j++)
+			octeon_delete_droq(octeon_dev, j);
+	}
+
+	atomic_set(&octeon_dev->status, OCT_DEV_DROQ_INIT_DONE);
+
+	/* The input and output queue registers were setup earlier (the queues
+	 * were not enabled). Any additional registers that need to be
+	 * programmed should be done now.
+	 */
+	ret = octeon_dev->fn_list.setup_device_regs(octeon_dev);
+	if (ret) {
+		lio_dev_err(octeon_dev,
+			    "Failed to configure device registers\n");
+		return ret;
+	}
+
+	/* Initialize the tasklet that handles output queue packet processing.*/
+	lio_dev_dbg(octeon_dev, "Initializing droq tasklet\n");
+	tasklet_init(&oct_priv->droq_tasklet, octeon_droq_bh,
+		     (unsigned long)octeon_dev);
+
+	/* Setup the interrupt handler and record the INT SUM register address
+	 */
+	octeon_setup_interrupt(octeon_dev);
+
+	/* Enable Octeon device interrupts */
+	octeon_dev->fn_list.enable_interrupt(octeon_dev->chip);
+
+	/* Enable the input and output queues for this Octeon device */
+	octeon_dev->fn_list.enable_io_queues(octeon_dev);
+
+	lio_dev_dbg(octeon_dev, "Waiting for DDR initialization...\n");
+
+	if (ddr_timeout == 0) {
+		lio_dev_info(octeon_dev,
+			     "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
+	}
+
+	schedule_timeout_uninterruptible(HZ * 2);
+
+	/* Wait for the octeon to initialize DDR after the soft-reset. */
+	ret = octeon_wait_for_ddr_init(octeon_dev, &ddr_timeout);
+	if (ret) {
+		lio_dev_err(octeon_dev,
+			    "DDR not initialized. Please confirm that board is configured to boot from Flash, ret: %d\n",
+			    ret);
+		return 1;
+	}
+
+	if (octeon_wait_for_bootloader(octeon_dev, 1000) != 0) {
+		lio_dev_err(octeon_dev, "Board not responding\n");
+		return 1;
+	}
+
+	lio_dev_dbg(octeon_dev, "Initializing consoles\n");
+	ret = octeon_init_consoles(octeon_dev);
+	if (ret) {
+		lio_dev_err(octeon_dev, "Could not access board consoles\n");
+		return 1;
+	}
+	ret = octeon_add_console(octeon_dev, 0);
+	if (ret) {
+		lio_dev_err(octeon_dev, "Could not access board console\n");
+		return 1;
+	}
+
+	lio_dev_dbg(octeon_dev, "Loading firmware\n");
+	ret = load_firmware(octeon_dev);
+	if (ret) {
+		lio_dev_err(octeon_dev, "Could not load firmware to board\n");
+		return 1;
+	}
+
+	handshake[octeon_dev->octeon_id].init_ok = 1;
+	complete(&handshake[octeon_dev->octeon_id].init);
+
+	atomic_set(&octeon_dev->status, OCT_DEV_HOST_OK);
+
+	/* Send Credit for Octeon Output queues. Credits are always sent after
+	 * the output queue is enabled.
+	 */
+	for (j = 0; j < octeon_dev->num_oqs; j++)
+		writel(octeon_dev->droq[j]->max_count,
+		       octeon_dev->droq[j]->pkts_credit_reg);
+
+	/* Packets can start arriving on the output queues from this point. */
+
+	return 0;
+}
+
+/**
+ * \brief Exits the module
+ */
+static void __exit liquidio_exit(void)
+{
+	liquidio_deinit_pci();
+
+	pr_info("LiquidIO network module is now unloaded\n");
+}
+
+module_init(liquidio_init);
+module_exit(liquidio_exit);
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
new file mode 100644
index 0000000..b4c7c5b
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -0,0 +1,597 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/*!  \file  liquidio_common.h
+ *   \brief Common: Structures and macros used in PCI-NIC package by core and
+ *   host driver.
+ */
+
+#ifndef __LIQUIDIO_COMMON_H__
+#define __LIQUIDIO_COMMON_H__
+
+#include "octeon_config.h"
+
+#define LIQUIDIO_VERSION        "1.1.1"
+#define LIQUIDIO_MAJOR_VERSION  1
+#define LIQUIDIO_MINOR_VERSION  1
+#define LIQUIDIO_MICRO_VERSION  1
+
+/** Tag types used by Octeon cores in its work. */
+enum octeon_tag_type {
+	ORDERED_TAG = 0,
+	ATOMIC_TAG = 1,
+	NULL_TAG = 2,
+	NULL_NULL_TAG = 3
+};
+
+/* Opcodes used by host driver/apps to perform operations on the core.
+ * These are used to identify the major subsystem that the operation
+ * is for.
+ */
+#define OPCODE_CORE 0           /* used for generic core operations */
+#define OPCODE_NIC  1           /* used for NIC operations */
+#define OPCODE_LAST OPCODE_NIC
+
+/* Subcodes are used by host driver/apps to identify the sub-operation
+ * for the core. They only need to by unique for a given subsystem.
+ */
+#define OPCODE_SUBCODE(op, sub)       (((op & 0x0f) << 8) | ((sub) & 0x7f))
+
+/** OPCODE_CORE subcodes. For future use. */
+
+/** OPCODE_NIC subcodes */
+
+/* This subcode is sent by core PCI driver to indicate cores are ready. */
+#define OPCODE_NIC_CORE_DRV_ACTIVE     0x01
+#define OPCODE_NIC_NW_DATA             0x02     /* network packet data */
+#define OPCODE_NIC_CMD                 0x03
+#define OPCODE_NIC_INFO                0x04
+#define OPCODE_NIC_PORT_STATS          0x05
+#define OPCODE_NIC_MDIO45              0x06
+#define OPCODE_NIC_TIMESTAMP           0x07
+#define OPCODE_NIC_INTRMOD_CFG         0x08
+#define OPCODE_NIC_IF_CFG              0x09
+
+#define CORE_DRV_TEST_SCATTER_OP    0xFFF5
+
+/* Application codes advertised by the core driver initialization packet. */
+#define CVM_DRV_APP_START           0x0
+#define CVM_DRV_NO_APP              0
+#define CVM_DRV_APP_COUNT           0x2
+#define CVM_DRV_BASE_APP            (CVM_DRV_APP_START + 0x0)
+#define CVM_DRV_NIC_APP             (CVM_DRV_APP_START + 0x1)
+#define CVM_DRV_INVALID_APP         (CVM_DRV_APP_START + 0x2)
+#define CVM_DRV_APP_END             (CVM_DRV_INVALID_APP - 1)
+
+/* Macro to increment index.
+ * Index is incremented by count; if the sum exceeds
+ * max, index is wrapped-around to the start.
+ */
+#define INCR_INDEX(index, count, max)                \
+do {                                                 \
+	if (((index) + (count)) >= (max))            \
+		index = ((index) + (count)) - (max); \
+	else                                         \
+		index += (count);                    \
+} while (0)
+
+#define INCR_INDEX_BY1(index, max)	\
+do {                                    \
+	if ((++(index)) == (max))       \
+		index = 0;	        \
+} while (0)
+
+#define DECR_INDEX(index, count, max)                  \
+do {						       \
+	if ((count) > (index))                         \
+		index = ((max) - ((count - index)));   \
+	else                                           \
+		index -= count;			       \
+} while (0)
+
+#define OCT_BOARD_NAME 32
+#define OCT_SERIAL_LEN 64
+
+/* Structure used by core driver to send indication that the Octeon
+ * application is ready.
+ */
+struct octeon_core_setup {
+	uint64_t corefreq;
+
+	char boardname[OCT_BOARD_NAME];
+
+	char board_serial_number[OCT_SERIAL_LEN];
+
+	uint64_t board_rev_major;
+
+	uint64_t board_rev_minor;
+
+};
+
+/*---------------------------  SCATTER GATHER ENTRY  -----------------------*/
+
+/* The Scatter-Gather List Entry. The scatter or gather component used with
+ * a Octeon input instruction has this format.
+ */
+struct octeon_sg_entry {
+	/** The first 64 bit gives the size of data in each dptr.*/
+	union {
+		uint16_t size[4];
+		uint64_t size64;
+	} u;
+
+	/** The 4 dptr pointers for this entry. */
+	uint64_t ptr[4];
+
+};
+
+#define OCT_SG_ENTRY_SIZE    (sizeof(struct octeon_sg_entry))
+
+/* \brief Add size to gather list
+ * @param sg_entry scatter/gather entry
+ * @param size size to add
+ * @param pos position to add it.
+ */
+static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
+			       uint16_t size,
+			       uint32_t pos)
+{
+#ifdef __BIG_ENDIAN_BITFIELD
+	sg_entry->u.size[pos] = size;
+#else
+	sg_entry->u.size[3 - pos] = size;
+#endif
+}
+
+/*------------------------- End Scatter/Gather ---------------------------*/
+
+#define   OCTNET_FRM_PTP_HEADER_SIZE  8
+#define   OCTNET_FRM_HEADER_SIZE     30 /* PTP timestamp + VLAN + Ethernet */
+
+#define   OCTNET_MIN_FRM_SIZE        (64  + OCTNET_FRM_PTP_HEADER_SIZE)
+#define   OCTNET_MAX_FRM_SIZE        (16000 + OCTNET_FRM_HEADER_SIZE)
+
+#define   OCTNET_DEFAULT_FRM_SIZE    (1500 + OCTNET_FRM_HEADER_SIZE)
+
+/** NIC Commands are sent using this Octeon Input Queue */
+#define   OCTNET_CMD_Q                0
+
+/* NIC Command types */
+#define   OCTNET_CMD_CHANGE_MTU       0x1
+#define   OCTNET_CMD_CHANGE_MACADDR   0x2
+#define   OCTNET_CMD_CHANGE_DEVFLAGS  0x3
+#define   OCTNET_CMD_RX_CTL           0x4
+
+#define   OCTNET_CMD_SET_MAC_TBL      0x5
+#define   OCTNET_CMD_CLEAR_STATS      0x6
+
+/* command for setting the speed, duplex & autoneg */
+#define   OCTNET_CMD_SET_SETTINGS     0x7
+#define   OCTNET_CMD_SET_FLOW_CTL     0x8
+
+#define   OCTNET_CMD_MDIO_READ_WRITE  0x9
+#define   OCTNET_CMD_GPIO_ACCESS      0xA
+#define   OCTNET_CMD_LRO_ENABLE       0xB
+#define   OCTNET_CMD_LRO_DISABLE      0xC
+#define   OCTNET_CMD_SET_RSS          0xD
+#define   OCTNET_CMD_WRITE_SA         0xE
+#define   OCTNET_CMD_DELETE_SA        0xF
+
+/* RX(packets coming from wire) Checksum verification flags */
+/* TCP/UDP csum */
+#define   CNNIC_L4SUM_VERIFIED             0x1
+#define   CNNIC_IPSUM_VERIFIED             0x2
+#define   CNNIC_TUN_CSUM_VERIFIED          0x4
+#define   CNNIC_CSUM_VERIFIED (CNNIC_IPSUM_VERIFIED | CNNIC_L4SUM_VERIFIED)
+
+/* Interface flags communicated between host driver and core app. */
+enum octnet_ifflags {
+	OCTNET_IFFLAG_PROMISC = 0x1,
+	OCTNET_IFFLAG_ALLMULTI = 0x2,
+	OCTNET_IFFLAG_MULTICAST = 0x4
+};
+
+/*   wqe
+ *  ---------------  0
+ * |  wqe  word0-3 |
+ *  ---------------  32
+ * |    PCI IH     |
+ *  ---------------  40
+ * |     RPTR      |
+ *  ---------------  48
+ * |    PCI IRH    |
+ *  ---------------  56
+ * |  OCT_NET_CMD  |
+ *  ---------------  64
+ * | Addtl 8-BData |
+ * |               |
+ *  ---------------
+ */
+
+union octnet_cmd {
+	uint64_t u64;
+
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		uint64_t cmd:5;
+
+		uint64_t more:3;
+
+		uint64_t param1:32;
+
+		uint64_t param2:16;
+
+		uint64_t param3:8;
+
+#else
+
+		uint64_t param3:8;
+
+		uint64_t param2:16;
+
+		uint64_t param1:32;
+
+		uint64_t more:3;
+
+		uint64_t cmd:5;
+
+#endif
+	} s;
+
+};
+
+#define   OCTNET_CMD_SIZE     (sizeof(union octnet_cmd))
+
+/** Instruction Header */
+struct octeon_instr_ih {
+#ifdef __BIG_ENDIAN_BITFIELD
+	/** Raw mode indicator 1 = RAW */
+	uint64_t raw:1;
+
+	/** Gather indicator 1=gather*/
+	uint64_t gather:1;
+
+	/** Data length OR no. of entries in gather list */
+	uint64_t dlengsz:14;
+
+	/** Front Data size */
+	uint64_t fsz:6;
+
+	/** Packet Order / Work Unit selection (1 of 8)*/
+	uint64_t qos:3;
+
+	/** Core group selection (1 of 16) */
+	uint64_t grp:4;
+
+	/** Short Raw Packet Indicator 1=short raw pkt */
+	uint64_t rs:1;
+
+	/** Tag type */
+	uint64_t tagtype:2;
+
+	/** Tag Value */
+	uint64_t tag:32;
+#else
+	/** Tag Value */
+	uint64_t tag:32;
+
+	/** Tag type */
+	uint64_t tagtype:2;
+
+	/** Short Raw Packet Indicator 1=short raw pkt */
+	uint64_t rs:1;
+
+	/** Core group selection (1 of 16) */
+	uint64_t grp:4;
+
+	/** Packet Order / Work Unit selection (1 of 8)*/
+	uint64_t qos:3;
+
+	/** Front Data size */
+	uint64_t fsz:6;
+
+	/** Data length OR no. of entries in gather list */
+	uint64_t dlengsz:14;
+
+	/** Gather indicator 1=gather*/
+	uint64_t gather:1;
+
+	/** Raw mode indicator 1 = RAW */
+	uint64_t raw:1;
+#endif
+};
+
+/** Input Request Header */
+struct octeon_instr_irh {
+#ifdef __BIG_ENDIAN_BITFIELD
+	uint64_t opcode:4;
+	uint64_t rflag:1;
+	uint64_t subcode:7;
+	uint64_t len:3;
+	uint64_t rid:13;
+	uint64_t reserved:4;
+	uint64_t ossp:32;             /* opcode/subcode specific parameters */
+#else
+	uint64_t ossp:32;             /* opcode/subcode specific parameters */
+	uint64_t reserved:4;
+	uint64_t rid:13;
+	uint64_t len:3;
+	uint64_t subcode:7;
+	uint64_t rflag:1;
+	uint64_t opcode:4;
+#endif
+};
+
+/** Return Data Parameters */
+struct octeon_instr_rdp {
+#ifdef __BIG_ENDIAN_BITFIELD
+	uint64_t reserved:49;
+	uint64_t pcie_port:3;
+	uint64_t rlen:12;
+#else
+	uint64_t rlen:12;
+	uint64_t pcie_port:3;
+	uint64_t reserved:49;
+#endif
+};
+
+/** Receive Header */
+union octeon_rh {
+#ifdef __BIG_ENDIAN_BITFIELD
+	uint64_t u64;
+	struct {
+		uint64_t opcode:4;
+		uint64_t subcode:8;
+		uint64_t len:3;       /** additional 64-bit words */
+		uint64_t rid:13;      /** request id in response to pkt sent by host */
+		uint64_t reserved:4;
+		uint64_t ossp:32;     /** opcode/subcode specific parameters */
+	} r;
+	struct {
+		uint64_t opcode:4;
+		uint64_t subcode:8;
+		uint64_t len:3;       /** additional 64-bit words */
+		uint64_t rid:13;      /** request id in response to pkt sent by host */
+		uint64_t reserved:4;
+		uint64_t extra:25;
+		uint64_t link:4;
+		uint64_t csum_verified:2;     /** checksum verified. */
+		uint64_t has_hwtstamp:1;      /** Has hardware timestamp. 1 = yes. */
+	} r_dh;
+	struct {
+		uint64_t opcode:4;
+		uint64_t subcode:8;
+		uint64_t len:3;       /** additional 64-bit words */
+		uint64_t rid:13;      /** request id in response to pkt sent by host */
+		uint64_t reserved:4;
+		uint64_t extra:4;
+		uint64_t app_specific:8;
+		uint64_t app_cap_flags:4;
+		uint64_t app_mode:16;
+	} r_core_drv_init;
+#else
+	uint64_t u64;
+	struct {
+		uint64_t ossp:32;  /** opcode/subcode specific parameters */
+		uint64_t reserved:4;
+		uint64_t rid:13;   /** req id in response to pkt sent by host */
+		uint64_t len:3;    /** additional 64-bit words */
+		uint64_t subcode:8;
+		uint64_t opcode:4;
+	} r;
+	struct {
+		uint64_t has_hwtstamp:1;      /** 1 = has hwtstamp */
+		uint64_t csum_verified:2;     /** checksum verified. */
+		uint64_t link:4;
+		uint64_t extra:25;
+		uint64_t reserved:4;
+		uint64_t rid:13;   /** req id in response to pkt sent by host */
+		uint64_t len:3;    /** additional 64-bit words */
+		uint64_t subcode:8;
+		uint64_t opcode:4;
+	} r_dh;
+	struct {
+		uint64_t app_mode:16;
+		uint64_t app_cap_flags:4;
+		uint64_t app_specific:8;
+		uint64_t extra:4;
+		uint64_t reserved:4;
+		uint64_t rid:13;   /** req id in response to pkt sent by host */
+		uint64_t len:3;    /** additional 64-bit words */
+		uint64_t subcode:8;
+		uint64_t opcode:4;
+	} r_core_drv_init;
+#endif
+};
+
+#define  OCT_RH_SIZE   (sizeof(union  octeon_rh))
+
+union octnic_packet_params {
+	uint32_t u32;
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		uint32_t reserved:10;
+		uint32_t ipsec_ops:4;
+		uint32_t tsflag:1;
+		uint32_t csoffset:9;
+		uint32_t ifidx:8;
+#else
+		uint32_t ifidx:8;
+		uint32_t csoffset:9;
+		uint32_t tsflag:1;
+		uint32_t ipsec_ops:4;
+		uint32_t reserved:10;
+#endif
+	} s;
+};
+
+/** Status of a RGMII Link on Octeon as seen by core driver. */
+union oct_link_status {
+	uint64_t u64;
+
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		uint64_t duplex:8;
+		uint64_t status:8;
+		uint64_t mtu:16;
+		uint64_t speed:16;
+		uint64_t autoneg:1;
+		uint64_t interface:4;
+		uint64_t pause:1;
+		uint64_t reserved:10;
+#else
+		uint64_t reserved:10;
+		uint64_t pause:1;
+		uint64_t interface:4;
+		uint64_t autoneg:1;
+		uint64_t speed:16;
+		uint64_t mtu:16;
+		uint64_t status:8;
+		uint64_t duplex:8;
+#endif
+	} s;
+};
+
+struct liquidio_if_cfg_info {
+	uint64_t ifidx;
+	/** mask for IQs enabled for  the port */
+	uint64_t iqmask;
+	/** mask for OQs enabled for the port */
+	uint64_t oqmask;
+};
+
+/** Information for a OCTEON ethernet interface shared between core & host. */
+struct oct_link_info {
+	union oct_link_status link;
+	uint64_t hw_addr;
+
+#ifdef __BIG_ENDIAN_BITFIELD
+	uint16_t gmxport;
+	uint8_t rsvd[3];
+	uint8_t num_txpciq;
+	uint8_t num_rxpciq;
+	uint8_t ifidx;
+#else
+	uint8_t ifidx;
+	uint8_t num_rxpciq;
+	uint8_t num_txpciq;
+	uint8_t rsvd[3];
+	uint16_t gmxport;
+#endif
+
+	uint8_t txpciq[MAX_IOQS_PER_NICIF];
+	uint8_t rxpciq[MAX_IOQS_PER_NICIF];
+};
+
+#define OCT_LINK_INFO_SIZE   (sizeof(struct oct_link_info))
+
+/** Stats for each NIC port in RX direction. */
+struct nic_rx_stats {
+	/* link-level stats */
+	uint64_t total_rcvd;
+	uint64_t bytes_rcvd;
+	uint64_t ctl_rcvd;
+	uint64_t fifo_err;      /* Accounts for over/under-run of buffers */
+	uint64_t dmac_drop;
+	uint64_t fcs_err;
+	uint64_t jabber_err;
+	uint64_t l2_err;
+	uint64_t frame_err;
+	uint64_t total_bcst;
+	uint64_t runts;
+
+	/* firmware stats */
+	uint64_t fw_total_rcvd;
+	uint64_t fw_total_fwd;
+	uint64_t fw_err_pko;
+	uint64_t fw_err_link;
+	uint64_t fw_err_drop;
+	/* intrmod: packet forward rate */
+	uint64_t fwd_rate;
+};
+
+/** Stats for each NIC port in RX direction. */
+struct nic_tx_stats {
+	/* link-level stats */
+	uint64_t total_rcvd;
+	uint64_t bytes_rcvd;
+	uint64_t ctl_rcvd;
+	uint64_t fifo_err;      /* Accounts for over/under-run of buffers */
+	uint64_t runts;
+	uint64_t collision;
+
+	/* firmware stats */
+	uint64_t fw_total_rcvd;
+	uint64_t fw_total_fwd;
+	uint64_t fw_err_pko;
+	uint64_t fw_err_link;
+	uint64_t fw_err_drop;
+};
+
+struct oct_link_stats {
+	struct nic_rx_stats fromwire;
+	struct nic_tx_stats fromhost;
+
+};
+
+#define LIO68XX_LED_CTRL_ADDR     0x3501
+#define LIO68XX_LED_CTRL_CFGON    0x1f
+#define LIO68XX_LED_CTRL_CFGOFF   0x100
+#define LIO68XX_LED_BEACON_ADDR   0x3508
+#define LIO68XX_LED_BEACON_CFGON  0x47fd
+#define LIO68XX_LED_BEACON_CFGOFF 0x11fc
+#define VITESSE_PHY_GPIO_DRIVEON  0x1
+#define VITESSE_PHY_GPIO_CFG      0x8
+#define VITESSE_PHY_GPIO_DRIVEOFF 0x4
+#define VITESSE_PHY_GPIO_HIGH     0x2
+#define VITESSE_PHY_GPIO_LOW      0x3
+
+struct oct_mdio_cmd {
+	uint64_t op;
+	uint64_t mdio_addr;
+	uint64_t value1;
+	uint64_t value2;
+	uint64_t value3;
+};
+
+#define OCT_LINK_STATS_SIZE   (sizeof(struct oct_link_stats))
+
+#define LIO_INTRMOD_CHECK_INTERVAL  1
+#define LIO_INTRMOD_MAXPKT_RATETHR  196608 /* max pkt rate threshold */
+#define LIO_INTRMOD_MINPKT_RATETHR  9216   /* min pkt rate threshold */
+#define LIO_INTRMOD_MAXCNT_TRIGGER  384    /* max pkts to trigger interrupt */
+#define LIO_INTRMOD_MINCNT_TRIGGER  1      /* min pkts to trigger interrupt */
+#define LIO_INTRMOD_MAXTMR_TRIGGER  128    /* max time to trigger interrupt */
+#define LIO_INTRMOD_MINTMR_TRIGGER  32     /* min time to trigger interrupt */
+
+struct oct_intrmod_cfg {
+	uint64_t intrmod_enable;
+	uint64_t intrmod_check_intrvl;
+	uint64_t intrmod_maxpkt_ratethr;
+	uint64_t intrmod_minpkt_ratethr;
+	uint64_t intrmod_maxcnt_trigger;
+	uint64_t intrmod_maxtmr_trigger;
+	uint64_t intrmod_mincnt_trigger;
+	uint64_t intrmod_mintmr_trigger;
+};
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
new file mode 100644
index 0000000..b2cc188
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
@@ -0,0 +1,60 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#ifndef _LIQUIDIO_IMAGE_H_
+#define _LIQUIDIO_IMAGE_H_
+
+#define OCTEON_MAX_FW_TYPE_LEN     (8)
+#define OCTEON_MAX_FW_FILENAME_LEN (256)
+#define OCTEON_FW_DIR              "liquidio/"
+#define OCTEON_FW_BASE_NAME        "lio_"
+#define OCTEON_FW_NAME_SUFFIX      ".bin"
+#define OCTEON_FW_NAME_CARD_210SV  "210sv"
+#define OCTEON_FW_NAME_CARD_410NV  "410nv"
+#define OCTEON_FW_NAME_CARD_ANY    "any"        /* Remove in the future? */
+#define OCTEON_FW_NAME_TYPE_NIC    "nic"
+#define OCTEON_FW_NAME_TYPE_NONE   "none"
+
+#define OCTEON_MAX_FIRMWARE_VERSION_LEN 16
+#define OCTEON_MAX_BOOTCMD_LEN 1024
+#define OCTEON_MAX_IMAGES 16
+#define OCTEON_NIC_MAGIC 0x434E4943     /* "CNIC" */
+struct octeon_firmware_desc {
+	uint64_t addr;
+	uint32_t len;
+	uint32_t crc32;         /* crc32 of image */
+};
+
+/* Following the header is a list of 64-bit aligned binary images,
+ * as described by the desc field.
+ * Numeric fields are in network byte order.
+ */
+struct octeon_firmware_file_header {
+	uint32_t magic;
+	char version[OCTEON_MAX_FIRMWARE_VERSION_LEN];
+	char bootcmd[OCTEON_MAX_BOOTCMD_LEN];
+	uint32_t num_images;
+	struct octeon_firmware_desc desc[OCTEON_MAX_IMAGES];
+	uint32_t pad;
+	uint32_t crc32;         /* header checksum */
+};
+
+#endif /* _LIQUIDIO_IMAGE_H_ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
new file mode 100644
index 0000000..538366d
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -0,0 +1,402 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/*! \file  octeon_config.h
+ *  \brief Host Driver: Configuration data structures for the host driver.
+ */
+
+#ifndef __OCTEON_CONFIG_H__
+#define __OCTEON_CONFIG_H__
+
+/*--------------------------CONFIG VALUES------------------------*/
+
+/* The following macros affect the way the driver data structures
+ * are generated for Octeon devices.
+ * They can be modified.
+ */
+
+/*  Maximum no. of octeon devices that the driver can support. */
+#define   MAX_OCTEON_DEVICES           4
+#define   MAX_OCTEON_LINKS             12
+
+/* CN6xxx IQ configuration macros */
+#define   CN6XXX_MAX_INPUT_QUEUES      32
+#define   CN6XXX_MAX_IQ_DESCRIPTORS    2048
+#define   CN6XXX_DB_MIN                1
+#define   CN6XXX_DB_MAX                8
+#define   CN6XXX_DB_TIMEOUT            1
+
+/* CN6xxx OQ configuration macros */
+#define   CN6XXX_MAX_OUTPUT_QUEUES     32
+#define   CN6XXX_MAX_OQ_DESCRIPTORS    2048
+#define   CN6XXX_OQ_BUF_SIZE               1536
+#define   CN6XXX_OQ_PKTSPER_INTR                128
+#define   CN6XXX_OQ_REFIL_THRESHOLD             128
+
+#define   CN6XXX_OQ_INTR_PKT                    64
+#define   CN6XXX_OQ_INTR_TIME                   100
+#define   DEFAULT_NUM_NIC_PORTS_66XX        2
+#define   DEFAULT_NUM_NIC_PORTS_68XX        4
+
+/* common OCTEON cinfiguration macros */
+#define   CN6XXX_CFG_IO_QUEUES                  32
+#define   OCTEON_32BYTE_INSTR                   32
+#define   OCTEON_64BYTE_INSTR                   64
+#define   OCTEON_MAX_BASE_IOQ                   4
+#define   OCTEON_OQ_BUFPTR_MODE                 0
+#define   OCTEON_OQ_INFOPTR_MODE                1
+
+#define   OCTEON_DMA_INTR_PKT                   64
+#define   OCTEON_DMA_INTR_TIME                  1000
+
+#define   OCTEON_CONFIG_TYPE_DEFAULT          1
+#define   OCTEON_CONFIG_TYPE_CN66XX_CUSTOM    5
+#define   OCTEON_CONFIG_TYPE_CN68XX_CUSTOM    6
+
+#define MAX_TXQS_PER_INTF  8
+#define MAX_RXQS_PER_INTF  8
+#define DEF_TXQS_PER_INTF  4
+#define DEF_RXQS_PER_INTF  4
+
+#define INVALID_IOQ_NO          0xff
+
+#define   DEFAULT_POW_GRP       0
+
+/* Macros to get octeon config params */
+#define CFG_GET_IQ_CFG(cfg)                      ((cfg)->iq)
+#define CFG_GET_IQ_MAX_Q(cfg)                    ((cfg)->iq.max_iqs)
+#define CFG_GET_IQ_PENDING_LIST_SIZE(cfg)        ((cfg)->iq.pending_list_size)
+#define CFG_GET_IQ_INSTR_TYPE(cfg)               ((cfg)->iq.instr_type)
+#define CFG_GET_IQ_DB_MIN(cfg)                   ((cfg)->iq.db_min)
+#define CFG_GET_IQ_DB_TIMEOUT(cfg)               ((cfg)->iq.db_timeout)
+
+#define CFG_GET_OQ_MAX_Q(cfg)                    ((cfg)->oq.max_oqs)
+#define CFG_GET_OQ_INFO_PTR(cfg)                 ((cfg)->oq.info_ptr)
+#define CFG_GET_OQ_PKTS_PER_INTR(cfg)            ((cfg)->oq.pkts_per_intr)
+#define CFG_GET_OQ_REFILL_THRESHOLD(cfg)         ((cfg)->oq.refill_threshold)
+#define CFG_GET_OQ_INTR_PKT(cfg)                 ((cfg)->oq.oq_intr_pkt)
+#define CFG_GET_OQ_INTR_TIME(cfg)                ((cfg)->oq.oq_intr_time)
+#define CFG_SET_OQ_INTR_PKT(cfg, val)            (cfg)->oq.oq_intr_pkt = val
+#define CFG_SET_OQ_INTR_TIME(cfg, val)           (cfg)->oq.oq_intr_time = val
+
+#define CFG_GET_DMA_INTR_PKT(cfg)                ((cfg)->dma.dma_intr_pkt)
+#define CFG_GET_DMA_INTR_TIME(cfg)               ((cfg)->dma.dma_intr_time)
+#define CFG_GET_NUM_NIC_PORTS(cfg)               ((cfg)->num_nic_ports)
+#define CFG_GET_NUM_DEF_TX_DESCS(cfg)            ((cfg)->num_def_tx_descs)
+#define CFG_GET_NUM_DEF_RX_DESCS(cfg)            ((cfg)->num_def_rx_descs)
+#define CFG_GET_DEF_RX_BUF_SIZE(cfg)             ((cfg)->def_rx_buf_size)
+
+#define CFG_GET_MAX_TXQS_NIC_IF(cfg, idx) \
+				((cfg)->nic_if_cfg[idx].max_txqs)
+#define CFG_GET_NUM_TXQS_NIC_IF(cfg, idx) \
+				((cfg)->nic_if_cfg[idx].num_txqs)
+#define CFG_GET_MAX_RXQS_NIC_IF(cfg, idx) \
+				((cfg)->nic_if_cfg[idx].max_rxqs)
+#define CFG_GET_NUM_RXQS_NIC_IF(cfg, idx) \
+				((cfg)->nic_if_cfg[idx].num_rxqs)
+#define CFG_GET_NUM_RX_DESCS_NIC_IF(cfg, idx) \
+				((cfg)->nic_if_cfg[idx].num_rx_descs)
+#define CFG_GET_NUM_TX_DESCS_NIC_IF(cfg, idx) \
+				((cfg)->nic_if_cfg[idx].num_tx_descs)
+#define CFG_GET_NUM_RX_BUF_SIZE_NIC_IF(cfg, idx) \
+				((cfg)->nic_if_cfg[idx].rx_buf_size)
+
+#define CFG_GET_CTRL_Q_GRP(cfg)                  ((cfg)->misc.ctrlq_grp)
+#define CFG_GET_HOST_LINK_QUERY_INTERVAL(cfg) \
+				((cfg)->misc.host_link_query_interval)
+#define CFG_GET_OCT_LINK_QUERY_INTERVAL(cfg) \
+				((cfg)->misc.oct_link_query_interval)
+#define CFG_GET_IS_SLI_BP_ON(cfg)                ((cfg)->misc.enable_sli_oq_bp)
+
+/* Max IOQs per OCTEON Link */
+#define MAX_IOQS_PER_NICIF              32
+
+#define MAX_OCTEON_NICIF                32
+
+/** Structure to define the configuration attributes for each Input queue.
+ *  Applicable to all Octeon processors
+ **/
+
+/** Structure to define the configuration attributes for each Output queue.
+ *  Applicable to all Octeon processors
+ **/
+struct octeon_iq_config {
+#ifdef __BIG_ENDIAN_BITFIELD
+	uint64_t reserved:32;
+
+	/** Minimum ticks to wait before checking for pending instructions. */
+	uint64_t db_timeout:16;
+
+	/** Minimum number of commands pending to be posted to Octeon
+	 *  before driver hits the Input queue doorbell.
+	 */
+	uint64_t db_min:8;
+
+	/** Command size - 32 or 64 bytes */
+	uint64_t instr_type:32;
+
+	/** Pending list size (usually set to the sum of the size of all Input
+	 *  queues)
+	 */
+	uint64_t pending_list_size:32;
+
+	/* Max number of IQs available */
+	uint64_t max_iqs:8;
+#else
+	/* Max number of IQs available */
+	uint64_t max_iqs:8;
+
+	/** Pending list size (usually set to the sum of the size of all Input
+	 *  queues)
+	 */
+	uint64_t pending_list_size:32;
+
+	/** Command size - 32 or 64 bytes */
+	uint64_t instr_type:32;
+
+	/** Minimum number of commands pending to be posted to Octeon
+	 *  before driver hits the Input queue doorbell.
+	 */
+	uint64_t db_min:8;
+
+	/** Minimum ticks to wait before checking for pending instructions. */
+	uint64_t db_timeout:16;
+
+	uint64_t reserved:32;
+#endif
+};
+
+/** Structure to define the configuration attributes for each Output queue.
+ *  Applicable to all Octeon processors
+ **/
+struct octeon_oq_config {
+#ifdef __BIG_ENDIAN_BITFIELD
+	uint64_t reserved:16;
+
+	uint64_t pkts_per_intr:16;
+
+	/** Interrupt Coalescing (Time Interval). Octeon will interrupt the
+	 *  host if atleast one packet was sent in the time interval specified
+	 *  by this field. The driver uses time interval interrupt coalescing
+	 *  by default. The time is specified in microseconds.
+	 */
+	uint64_t oq_intr_time:16;
+
+	/** Interrupt Coalescing (Packet Count). Octeon will interrupt the host
+	 *  only if it sent as many packets as specified by this field.
+	 *  The driver
+	 *  usually does not use packet count interrupt coalescing.
+	 */
+	uint64_t oq_intr_pkt:16;
+
+	/** The number of buffers that were consumed during packet processing by
+	 *   the driver on this Output queue before the driver attempts to
+	 *   replenish
+	 *   the descriptor ring with new buffers.
+	 */
+	uint64_t refill_threshold:16;
+
+	/** If set, the Output queue uses info-pointer mode. (Default: 1 ) */
+	uint64_t info_ptr:32;
+
+	/* Max number of OQs available */
+	uint64_t max_oqs:8;
+
+#else
+	/* Max number of OQs available */
+	uint64_t max_oqs:8;
+
+	/** If set, the Output queue uses info-pointer mode. (Default: 1 ) */
+	uint64_t info_ptr:32;
+
+	/** The number of buffers that were consumed during packet processing by
+	 *   the driver on this Output queue before the driver attempts to
+	 *   replenish
+	 *   the descriptor ring with new buffers.
+	 */
+	uint64_t refill_threshold:16;
+
+	/** Interrupt Coalescing (Packet Count). Octeon will interrupt the host
+	 *  only if it sent as many packets as specified by this field.
+	 *  The driver
+	 *  usually does not use packet count interrupt coalescing.
+	 */
+	uint64_t oq_intr_pkt:16;
+
+	/** Interrupt Coalescing (Time Interval). Octeon will interrupt the
+	 *  host if atleast one packet was sent in the time interval specified
+	 *  by this field. The driver uses time interval interrupt coalescing
+	 *  by default.  The time is specified in microseconds.
+	 */
+	uint64_t oq_intr_time:16;
+
+	uint64_t pkts_per_intr:16;
+
+	uint64_t reserved:16;
+#endif
+
+};
+
+/** This structure conatins the NIC link configuration attributes,
+ *  common for all the OCTEON Modles.
+ */
+struct octeon_nic_if_config {
+#ifdef __BIG_ENDIAN_BITFIELD
+	uint64_t reserved:48;
+
+	/* SKB size, We need not change buf size even for Jumbo frames.
+	 * Octeon can send jumbo frames in 4 consecutive descriptors,
+	 */
+	uint64_t rx_buf_size:16;
+
+	/* Num of desc for tx rings */
+	uint64_t num_tx_descs:16;
+
+	/* Num of desc for rx rings */
+	uint64_t num_rx_descs:16;
+
+	/* Actual configured value. Range could be: 1...max_rxqs */
+	uint64_t num_rxqs:8;
+
+	/* Max Rxqs: Half for each of the two ports :max_oq/2  */
+	uint64_t max_rxqs:8;
+
+	/* Actual configured value. Range could be: 1...max_txqs */
+	uint64_t num_txqs:8;
+
+	/* Max Txqs: Half for each of the two ports :max_iq/2 */
+	uint64_t max_txqs:8;
+#else
+	/* Max Txqs: Half for each of the two ports :max_iq/2 */
+	uint64_t max_txqs:8;
+
+	/* Actual configured value. Range could be: 1...max_txqs */
+	uint64_t num_txqs:8;
+
+	/* Max Rxqs: Half for each of the two ports :max_oq/2  */
+	uint64_t max_rxqs:8;
+
+	/* Actual configured value. Range could be: 1...max_rxqs */
+	uint64_t num_rxqs:8;
+
+	/* Num of desc for rx rings */
+	uint64_t num_rx_descs:16;
+
+	/* Num of desc for tx rings */
+	uint64_t num_tx_descs:16;
+
+	/* SKB size, We need not change buf size even for Jumbo frames.
+	 * Octeon can send jumbo frames in 4 consecutive descriptors,
+	 */
+	uint64_t rx_buf_size:16;
+
+	uint64_t reserved:48;
+#endif
+
+};
+
+/** Structure to define the configuration attributes for meta data.
+ *  Applicable to all Octeon processors.
+ */
+
+struct octeon_misc_config {
+#ifdef __BIG_ENDIAN_BITFIELD
+	/** Host link status polling period */
+	uint64_t host_link_query_interval:32;
+	/** Oct link status polling period */
+	uint64_t oct_link_query_interval:32;
+
+	uint64_t enable_sli_oq_bp:1;
+	/** Control IQ Group */
+	uint64_t ctrlq_grp:4;
+#else
+	/** Control IQ Group */
+	uint64_t ctrlq_grp:4;
+	/** BP for SLI OQ */
+	uint64_t enable_sli_oq_bp:1;
+	/** Host link status polling period */
+	uint64_t oct_link_query_interval:32;
+	/** Oct link status polling period */
+	uint64_t host_link_query_interval:32;
+#endif
+};
+
+/** Structure to define the configuration for all OCTEON processors. */
+struct octeon_config {
+	/** Input Queue attributes. */
+	struct octeon_iq_config iq;
+
+	/** Output Queue attributes. */
+	struct octeon_oq_config oq;
+
+	/** NIC Port Configuration */
+	struct octeon_nic_if_config nic_if_cfg[MAX_OCTEON_NICIF];
+
+	/** Miscellaneous attributes */
+	struct octeon_misc_config misc;
+
+	int num_nic_ports;
+
+	int num_def_tx_descs;
+
+	/* Num of desc for rx rings */
+	int num_def_rx_descs;
+
+	int def_rx_buf_size;
+
+};
+
+/* The following config values are fixed and should not be modified. */
+
+/* Maximum address space to be mapped for Octeon's BAR1 index-based access. */
+#define  MAX_BAR1_MAP_INDEX                     2
+#define  OCTEON_BAR1_ENTRY_SIZE         (4 * 1024 * 1024)
+
+/* BAR1 Index 0 to (MAX_BAR1_MAP_INDEX - 1) for normal mapped memory access.
+ * Bar1 register at MAX_BAR1_MAP_INDEX used by driver for dynamic access.
+ */
+#define  MAX_BAR1_IOREMAP_SIZE  ((MAX_BAR1_MAP_INDEX + 1) * \
+				 OCTEON_BAR1_ENTRY_SIZE)
+
+/* Response lists - 1 ordered, 1 unordered-blocking, 1 unordered-nonblocking
+ * NoResponse Lists are now maintained with each IQ. (Dec' 2007).
+ */
+#define MAX_RESPONSE_LISTS           4
+
+/* Opcode hash bits. The opcode is hashed on the lower 6-bits to lookup the
+ * dispatch table.
+ */
+#define OPCODE_MASK_BITS             6
+
+/* Mask for the 6-bit lookup hash */
+#define OCTEON_OPCODE_MASK           0x3f
+
+/* Size of the dispatch table. The 6-bit hash can index into 2^6 entries */
+#define DISPATCH_LIST_SIZE                      BIT(OPCODE_MASK_BITS)
+
+/* Maximum number of Octeon Instruction (command) queues */
+#define MAX_OCTEON_INSTR_QUEUES         CN6XXX_MAX_INPUT_QUEUES
+
+/* Maximum number of Octeon Instruction (command) queues */
+#define MAX_OCTEON_OUTPUT_QUEUES        CN6XXX_MAX_OUTPUT_QUEUES
+
+#endif /* __OCTEON_CONFIG_H__  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
new file mode 100644
index 0000000..c1c67df
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -0,0 +1,713 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/**
+ * @file octeon_console.c
+ */
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+#include "octeon_mem_ops.h"
+
+static void octeon_remote_lock(void);
+static void octeon_remote_unlock(void);
+static uint64_t cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
+						  const char *name,
+						  uint32_t flags);
+
+#define MIN(a, b) min((a), (b))
+#define CAST_ULL(v) ((uint64_t)(v))
+
+#define BOOTLOADER_PCI_READ_BUFFER_DATA_ADDR    0x0006c008
+#define BOOTLOADER_PCI_READ_BUFFER_LEN_ADDR     0x0006c004
+#define BOOTLOADER_PCI_READ_BUFFER_OWNER_ADDR   0x0006c000
+#define BOOTLOADER_PCI_READ_DESC_ADDR           0x0006c100
+#define BOOTLOADER_PCI_WRITE_BUFFER_STR_LEN     248
+
+#define OCTEON_PCI_IO_BUF_OWNER_OCTEON    0x00000001
+#define OCTEON_PCI_IO_BUF_OWNER_HOST      0x00000002
+
+/** Can change without breaking ABI */
+#define CVMX_BOOTMEM_NUM_NAMED_BLOCKS 64
+
+/** minimum alignment of bootmem alloced blocks */
+#define CVMX_BOOTMEM_ALIGNMENT_SIZE     (16ull)
+
+/** CVMX bootmem descriptor major version */
+#define CVMX_BOOTMEM_DESC_MAJ_VER   3
+/* CVMX bootmem descriptor minor version */
+#define CVMX_BOOTMEM_DESC_MIN_VER   0
+
+/* Current versions */
+#define OCTEON_PCI_CONSOLE_MAJOR_VERSION    1
+#define OCTEON_PCI_CONSOLE_MINOR_VERSION    0
+#define OCTEON_PCI_CONSOLE_BLOCK_NAME   "__pci_console"
+#define OCTEON_CONSOLE_POLL_INTERVAL_MS  100    /* 10 times per second */
+
+/* First three members of cvmx_bootmem_desc are left in original
+** positions for backwards compatibility.
+** Assumes big endian target
+*/
+struct cvmx_bootmem_desc {
+	/** spinlock to control access to list */
+	uint32_t lock;
+
+	/** flags for indicating various conditions */
+	uint32_t flags;
+
+	uint64_t head_addr;
+
+	/** incremented changed when incompatible changes made */
+	uint32_t major_version;
+
+	/** incremented changed when compatible changes made,
+	 *  reset to zero when major incremented
+	 */
+	uint32_t minor_version;
+
+	uint64_t app_data_addr;
+	uint64_t app_data_size;
+
+	/** number of elements in named blocks array */
+	uint32_t nb_num_blocks;
+
+	/** length of name array in bootmem blocks */
+	uint32_t named_block_name_len;
+
+	/** address of named memory block descriptors */
+	uint64_t named_block_array_addr;
+};
+
+/* Structure that defines a single console.
+ *
+ * Note: when read_index == write_index, the buffer is empty.
+ * The actual usable size of each console is console_buf_size -1;
+ */
+struct octeon_pci_console {
+	uint64_t input_base_addr;
+	uint32_t input_read_index;
+	uint32_t input_write_index;
+	uint64_t output_base_addr;
+	uint32_t output_read_index;
+	uint32_t output_write_index;
+	uint32_t lock;
+	uint32_t buf_size;
+};
+
+/* This is the main container structure that contains all the information
+ * about all PCI consoles.  The address of this structure is passed to various
+ * routines that operation on PCI consoles.
+ */
+struct octeon_pci_console_desc {
+	uint32_t major_version;
+	uint32_t minor_version;
+	uint32_t lock;
+	uint32_t flags;
+	uint32_t num_consoles;
+	uint32_t pad;
+	/* must be 64 bit aligned here... */
+	/* Array of addresses of octeon_pci_console structures */
+	uint64_t console_addr_array[0];
+	/* Implicit storage for console_addr_array */
+};
+
+/**
+ * This macro returns the size of a member of a structure.
+ * Logically it is the same as "sizeof(s::field)" in C++, but
+ * C lacks the "::" operator.
+ */
+#define SIZEOF_FIELD(s, field) sizeof(((s *)NULL)->field)
+
+/**
+ * This macro returns a member of the cvmx_bootmem_desc
+ * structure. These members can't be directly addressed as
+ * they might be in memory not directly reachable. In the case
+ * where bootmem is compiled with LINUX_HOST, the structure
+ * itself might be located on a remote Octeon. The argument
+ * "field" is the member name of the cvmx_bootmem_desc to read.
+ * Regardless of the type of the field, the return type is always
+ * a uint64_t.
+ */
+#define CVMX_BOOTMEM_DESC_GET_FIELD(oct, field)                              \
+	__cvmx_bootmem_desc_get(oct, oct->bootmem_desc_addr,                 \
+				offsetof(struct cvmx_bootmem_desc, field),   \
+				SIZEOF_FIELD(struct cvmx_bootmem_desc, field))
+
+#define __cvmx_bootmem_lock(flags)
+#define __cvmx_bootmem_unlock(flags)
+
+/**
+ * This macro returns a member of the
+ * cvmx_bootmem_named_block_desc structure. These members can't
+ * be directly addressed as they might be in memory not directly
+ * reachable. In the case where bootmem is compiled with
+ * LINUX_HOST, the structure itself might be located on a remote
+ * Octeon. The argument "field" is the member name of the
+ * cvmx_bootmem_named_block_desc to read. Regardless of the type
+ * of the field, the return type is always a uint64_t. The "addr"
+ * parameter is the physical address of the structure.
+ */
+#define CVMX_BOOTMEM_NAMED_GET_FIELD(oct, addr, field)                   \
+	__cvmx_bootmem_desc_get(oct, addr,                               \
+		offsetof(struct cvmx_bootmem_named_block_desc, field),   \
+		SIZEOF_FIELD(struct cvmx_bootmem_named_block_desc, field))
+
+/**
+ * This function is the implementation of the get macros defined
+ * for individual structure members. The argument are generated
+ * by the macros inorder to read only the needed memory.
+ *
+ * @param oct    Pointer to current octeon device
+ * @param base   64bit physical address of the complete structure
+ * @param offset Offset from the beginning of the structure to the member being
+ *               accessed.
+ * @param size   Size of the structure member.
+ *
+ * @return Value of the structure member promoted into a uint64_t.
+ */
+static inline uint64_t __cvmx_bootmem_desc_get(struct octeon_device *oct,
+					       uint64_t base, uint32_t offset,
+					       uint32_t size)
+{
+	base = (1ull << 63) | (base + offset);
+	switch (size) {
+	case 4:
+		return octeon_read_device_mem32(oct, base);
+	case 8:
+		return octeon_read_device_mem64(oct, base);
+	default:
+		return 0;
+	}
+}
+
+/**
+ * This function retrieves the string name of a named block. It is
+ * more complicated than a simple memcpy() since the named block
+ * descriptor may not be directly accessible.
+ *
+ * @param addr   Physical address of the named block descriptor
+ * @param str    String to receive the named block string name
+ * @param len    Length of the string buffer, which must match the length
+ *               stored in the bootmem descriptor.
+ */
+static void CVMX_BOOTMEM_NAMED_GET_NAME(struct octeon_device *oct,
+					uint64_t addr,
+					char *str, uint32_t len)
+{
+	addr += offsetof(struct cvmx_bootmem_named_block_desc, name);
+	octeon_pci_read_core_mem(oct, addr, str, len);
+	str[len] = 0;
+}
+
+/* See header file for descriptions of functions */
+
+/**
+ * Check the version information on the bootmem descriptor
+ *
+ * @param exact_match
+ *               Exact major version to check against. A zero means
+ *               check that the version supports named blocks.
+ *
+ * @return Zero if the version is correct. Negative if the version is
+ *         incorrect. Failures also cause a message to be displayed.
+ */
+static int __cvmx_bootmem_check_version(struct octeon_device *oct,
+					uint32_t exact_match)
+{
+	uint32_t major_version;
+
+	if (!oct->bootmem_desc_addr)
+		oct->bootmem_desc_addr =
+			octeon_read_device_mem64(oct,
+						 BOOTLOADER_PCI_READ_DESC_ADDR);
+	major_version =
+		(uint32_t)CVMX_BOOTMEM_DESC_GET_FIELD(oct, major_version);
+	lio_dev_dbg(oct, "%s: major_version=%d\n", __func__,
+		    major_version);
+	if ((major_version > 3) ||
+	    (exact_match && major_version != exact_match)) {
+		lio_dev_err(oct,
+			    "Incompatible bootmem descriptor version: %d.%d at addr: 0x%llx\n",
+			    major_version,
+			    (uint32_t)CVMX_BOOTMEM_DESC_GET_FIELD(oct,
+							     minor_version),
+			    CAST_ULL(oct->bootmem_desc_addr));
+		return -1;
+	} else {
+		return 0;
+	}
+}
+
+static const struct cvmx_bootmem_named_block_desc
+*__cvmx_bootmem_find_named_block_flags(struct octeon_device *oct,
+					const char *name, uint32_t flags)
+{
+	struct cvmx_bootmem_named_block_desc *desc =
+		&oct->bootmem_named_block_desc;
+	uint64_t named_addr =
+		cvmx_bootmem_phy_named_block_find(oct, name, flags);
+
+	if (named_addr) {
+		desc->base_addr = CVMX_BOOTMEM_NAMED_GET_FIELD(oct, named_addr,
+							       base_addr);
+		desc->size =
+			CVMX_BOOTMEM_NAMED_GET_FIELD(oct, named_addr, size);
+		strncpy(desc->name, name, sizeof(desc->name));
+		desc->name[sizeof(desc->name) - 1] = 0;
+		return &oct->bootmem_named_block_desc;
+	} else {
+		return NULL;
+	}
+}
+
+static uint64_t cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
+						  const char *name,
+						  uint32_t flags)
+{
+	uint64_t result = 0;
+
+	__cvmx_bootmem_lock(flags);
+	if (!__cvmx_bootmem_check_version(oct, 3)) {
+		uint32_t i;
+		uint64_t named_block_array_addr =
+			CVMX_BOOTMEM_DESC_GET_FIELD(oct,
+						    named_block_array_addr);
+		uint32_t num_blocks = (uint32_t)CVMX_BOOTMEM_DESC_GET_FIELD(oct,
+							     nb_num_blocks);
+		uint32_t name_length = (uint32_t)
+			CVMX_BOOTMEM_DESC_GET_FIELD(oct, named_block_name_len);
+		uint64_t named_addr = named_block_array_addr;
+
+		for (i = 0; i < num_blocks; i++) {
+			uint64_t named_size =
+				CVMX_BOOTMEM_NAMED_GET_FIELD(oct, named_addr,
+							     size);
+			if (name && named_size) {
+				char *name_tmp =
+					kmalloc(name_length + 1, GFP_KERNEL);
+				CVMX_BOOTMEM_NAMED_GET_NAME(oct, named_addr,
+							    name_tmp,
+							    name_length);
+				if (!strncmp(name, name_tmp, name_length)) {
+					result = named_addr;
+					break;
+				}
+				kfree(name_tmp);
+			} else if (!name && !named_size) {
+				result = named_addr;
+				break;
+			}
+
+			named_addr +=
+				sizeof(struct cvmx_bootmem_named_block_desc);
+		}
+	}
+	__cvmx_bootmem_unlock(flags);
+	return result;
+}
+
+/**
+ * Find a named block on the remote Octeon
+ *
+ * @param name      Name of block to find
+ * @param base_addr Address the block is at (OUTPUT)
+ * @param size      The size of the block (OUTPUT)
+ *
+ * @return Zero on success, One on failure.
+ */
+static int octeon_named_block_find(struct octeon_device *oct, const char *name,
+				   uint64_t *base_addr, uint64_t *size)
+{
+	const struct cvmx_bootmem_named_block_desc *named_block;
+
+	octeon_remote_lock();
+	named_block = __cvmx_bootmem_find_named_block_flags(oct, name, 0);
+	octeon_remote_unlock();
+	if (named_block) {
+		*base_addr = named_block->base_addr;
+		*size = named_block->size;
+		return 0;
+	}
+	return 1;
+}
+
+static void octeon_remote_lock(void)
+{
+	/* fill this in if any sharing is needed */
+}
+
+static void octeon_remote_unlock(void)
+{
+	/* fill this in if any sharing is needed */
+}
+
+int octeon_console_send_cmd(struct octeon_device *oct, char *cmd_str,
+			    uint32_t wait_hundredths)
+{
+	uint32_t len = strlen(cmd_str);
+
+	lio_dev_dbg(oct, "sending \"%s\" to bootloader\n", cmd_str);
+
+	if (len > BOOTLOADER_PCI_WRITE_BUFFER_STR_LEN - 1) {
+		lio_dev_err(oct, "Command string too long, max length is: %d\n",
+			    BOOTLOADER_PCI_WRITE_BUFFER_STR_LEN - 1);
+		return -1;
+	}
+
+	if (octeon_wait_for_bootloader(oct, wait_hundredths) != 0) {
+		lio_dev_err(oct, "Bootloader not ready for command.\n");
+		return -1;
+	}
+
+	/* Write command to bootloader */
+	octeon_remote_lock();
+	octeon_pci_write_core_mem(oct, BOOTLOADER_PCI_READ_BUFFER_DATA_ADDR,
+				  (uint8_t *)cmd_str, len);
+	octeon_write_device_mem32(oct, BOOTLOADER_PCI_READ_BUFFER_LEN_ADDR,
+				  len);
+	octeon_write_device_mem32(oct, BOOTLOADER_PCI_READ_BUFFER_OWNER_ADDR,
+				  OCTEON_PCI_IO_BUF_OWNER_OCTEON);
+
+	/* Bootloader should accept command very quickly
+	 * if it really was ready
+	 */
+	if (octeon_wait_for_bootloader(oct, 200) != 0) {
+		octeon_remote_unlock();
+		lio_dev_err(oct, "Bootloader did not accept command.\n");
+		return -1;
+	}
+	octeon_remote_unlock();
+	return 0;
+}
+
+int octeon_wait_for_bootloader(struct octeon_device *oct,
+			       uint32_t wait_time_hundredths)
+{
+	lio_dev_dbg(oct, "waiting %d0 ms for bootloader\n",
+		    wait_time_hundredths);
+
+	if (octeon_mem_access_ok(oct))
+		return -1;
+
+	while (wait_time_hundredths > 0 &&
+	       octeon_read_device_mem32(oct,
+					BOOTLOADER_PCI_READ_BUFFER_OWNER_ADDR)
+	       != OCTEON_PCI_IO_BUF_OWNER_HOST) {
+		if (--wait_time_hundredths <= 0)
+			return -1;
+		schedule_timeout_uninterruptible(HZ / 100);
+	}
+	return 0;
+}
+
+static void octeon_console_handle_result(struct octeon_device *oct,
+					 size_t console_num,
+					 char *buffer, int32_t bytes_read)
+{
+	struct octeon_console *console;
+
+	console = &oct->console[console_num];
+
+	console->waiting = 0;
+}
+
+static char console_buffer[OCTEON_CONSOLE_MAX_READ_BYTES];
+
+static void output_console_line(struct octeon_device *oct,
+				struct octeon_console *console,
+				size_t console_num,
+				char *console_buffer,
+				int32_t bytes_read)
+{
+	char *line;
+	int32_t i;
+
+	line = console_buffer;
+	for (i = 0; i < bytes_read; i++) {
+		/* Output a line at a time, prefixed */
+		if (console_buffer[i] == '\n') {
+			console_buffer[i] = '\0';
+			if (console->leftover[0]) {
+				lio_dev_info(oct, "%lu: %s%s\n", console_num,
+					     console->leftover, line);
+				console->leftover[0] = '\0';
+			} else {
+				lio_dev_info(oct, "%lu: %s\n", console_num,
+					     line);
+			}
+			line = &console_buffer[i + 1];
+		}
+	}
+
+	/* Save off any leftovers */
+	if (line != &console_buffer[bytes_read]) {
+		console_buffer[bytes_read] = '\0';
+		strcpy(console->leftover, line);
+	}
+}
+
+static void check_console(struct work_struct *work)
+{
+	int32_t bytes_read, tries, total_read;
+	struct octeon_console *console;
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
+	size_t console_num = wk->ctxul;
+	uint32_t delay;
+
+	console = &oct->console[console_num];
+	tries = 0;
+	total_read = 0;
+
+	do {
+		/* Take console output regardless of whether it will
+		 * be logged
+		 */
+		bytes_read =
+			octeon_console_read(oct, console_num, console_buffer,
+					    sizeof(console_buffer) - 1, 0);
+		if (bytes_read > 0) {
+			total_read += bytes_read;
+			if (console->waiting) {
+				octeon_console_handle_result(oct, console_num,
+							     console_buffer,
+							     bytes_read);
+			}
+			if (octeon_console_debug_enabled(console_num)) {
+				output_console_line(oct, console, console_num,
+						    console_buffer, bytes_read);
+			}
+		} else if (bytes_read < 0) {
+			lio_dev_err(oct, "Error reading console %lu, ret=%d\n",
+				    console_num, bytes_read);
+		}
+
+		tries++;
+	} while ((bytes_read > 0) && (tries < 16));
+
+	/* If nothing is read after polling the console,
+	 * output any leftovers if any
+	 */
+	if (octeon_console_debug_enabled(console_num) &&
+	    (total_read == 0) && (console->leftover[0])) {
+		lio_dev_info(oct, "%lu: %s\n",
+			     console_num, console->leftover);
+		console->leftover[0] = '\0';
+	}
+
+	delay = OCTEON_CONSOLE_POLL_INTERVAL_MS;
+
+	schedule_delayed_work(&wk->work, msecs_to_jiffies(delay));
+}
+
+int octeon_init_consoles(struct octeon_device *oct)
+{
+	int ret = 0;
+	uint64_t addr, size;
+
+	ret = octeon_mem_access_ok(oct);
+	if (ret) {
+		lio_dev_err(oct, "Memory access not okay'\n");
+		return ret;
+	}
+
+	ret = octeon_named_block_find(oct, OCTEON_PCI_CONSOLE_BLOCK_NAME, &addr,
+				      &size);
+	if (ret) {
+		lio_dev_err(oct, "Could not find console '%s'\n",
+			    OCTEON_PCI_CONSOLE_BLOCK_NAME);
+		return ret;
+	}
+
+	/* num_consoles > 0, is an indication that the consoles
+	 * are accessible
+	 */
+	oct->num_consoles = octeon_read_device_mem32(oct,
+		addr + offsetof(struct octeon_pci_console_desc,
+			num_consoles));
+	oct->console_desc_addr = addr;
+
+	lio_dev_dbg(oct, "Initialized consoles. %d available\n",
+		    oct->num_consoles);
+
+	return ret;
+}
+
+int octeon_add_console(struct octeon_device *oct, uint32_t console_num)
+{
+	int ret = 0;
+	uint32_t delay;
+	uint64_t coreaddr;
+	struct delayed_work *work;
+	struct octeon_console *console;
+
+	if (console_num >= oct->num_consoles) {
+		lio_dev_err(oct,
+			    "trying to read from console number %d when only 0 to %d exist\n",
+			    console_num, oct->num_consoles);
+	} else {
+		console = &oct->console[console_num];
+
+		console->waiting = 0;
+
+		coreaddr = oct->console_desc_addr + console_num * 8 +
+			offsetof(struct octeon_pci_console_desc,
+				 console_addr_array);
+		console->addr = octeon_read_device_mem64(oct, coreaddr);
+		coreaddr = console->addr + offsetof(struct octeon_pci_console,
+						    buf_size);
+		console->buffer_size = octeon_read_device_mem32(oct, coreaddr);
+		coreaddr = console->addr + offsetof(struct octeon_pci_console,
+						    input_base_addr);
+		console->input_base_addr =
+			octeon_read_device_mem64(oct, coreaddr);
+		coreaddr = console->addr + offsetof(struct octeon_pci_console,
+						    output_base_addr);
+		console->output_base_addr =
+			octeon_read_device_mem64(oct, coreaddr);
+		console->leftover[0] = '\0';
+
+		work = &oct->console_poll_work[console_num].work;
+
+		INIT_DELAYED_WORK(work, check_console);
+		oct->console_poll_work[console_num].ctxptr = (void *)oct;
+		oct->console_poll_work[console_num].ctxul = console_num;
+		delay = OCTEON_CONSOLE_POLL_INTERVAL_MS;
+		schedule_delayed_work(work, msecs_to_jiffies(delay));
+
+		if (octeon_console_debug_enabled(console_num)) {
+			ret = octeon_console_send_cmd(oct,
+						      "setenv pci_console_active 1",
+						      2000);
+		}
+	}
+
+	return ret;
+}
+
+/**
+ * Removes all consoles
+ *
+ * @param oct         octeon device
+ */
+void octeon_remove_consoles(struct octeon_device *oct)
+{
+	uint32_t i;
+	struct octeon_console *console;
+
+	for (i = 0; i < oct->num_consoles; i++) {
+		console = &oct->console[i];
+		oct->console[i].addr = 0;
+		oct->console[i].buffer_size = 0;
+		oct->console[i].input_base_addr = 0;
+		oct->console[i].output_base_addr = 0;
+		cancel_delayed_work_sync(&oct->console_poll_work[i].
+						work);
+	}
+
+	oct->num_consoles = 0;
+}
+
+static inline int octeon_console_free_bytes(uint32_t buffer_size,
+					    uint32_t wr_idx, uint32_t rd_idx)
+{
+	if (rd_idx >= buffer_size || wr_idx >= buffer_size)
+		return -1;
+
+	return ((buffer_size - 1) - (wr_idx - rd_idx)) % buffer_size;
+}
+
+static inline int octeon_console_avail_bytes(uint32_t buffer_size,
+					     uint32_t wr_idx, uint32_t rd_idx)
+{
+	if (rd_idx >= buffer_size || wr_idx >= buffer_size)
+		return -1;
+
+	return buffer_size - 1 -
+	       octeon_console_free_bytes(buffer_size, wr_idx, rd_idx);
+}
+
+int octeon_console_read(struct octeon_device *oct, uint32_t console_num,
+			char *buffer, uint32_t buf_size, uint32_t flags)
+{
+	int bytes_to_read;
+	uint32_t rd_idx, wr_idx;
+	struct octeon_console *console;
+
+	if (console_num >= oct->num_consoles) {
+		lio_dev_err(oct, "Attempted to read from disabled console %d\n",
+			    console_num);
+		return 0;
+	}
+
+	console = &oct->console[console_num];
+
+	/* Check to see if any data is available.
+	 * Maybe optimize this with 64-bit read.
+	 */
+	rd_idx = octeon_read_device_mem32(oct, console->addr +
+		offsetof(struct octeon_pci_console, output_read_index));
+	wr_idx = octeon_read_device_mem32(oct, console->addr +
+		offsetof(struct octeon_pci_console, output_write_index));
+
+	bytes_to_read = octeon_console_avail_bytes(console->buffer_size,
+						   wr_idx, rd_idx);
+	if (bytes_to_read <= 0)
+		return bytes_to_read;
+
+	bytes_to_read = MIN(bytes_to_read, (int32_t)buf_size);
+
+	/* Check to see if what we want to read is not contiguous, and limit
+	 * ourselves to the contiguous block
+	 */
+	if (rd_idx + bytes_to_read >= console->buffer_size)
+		bytes_to_read = console->buffer_size - rd_idx;
+
+	octeon_pci_read_core_mem(oct, console->output_base_addr + rd_idx,
+				 buffer, bytes_to_read);
+	octeon_write_device_mem32(oct, console->addr +
+				  offsetof(struct octeon_pci_console,
+					   output_read_index),
+				  (rd_idx + bytes_to_read) %
+				  console->buffer_size);
+
+	return bytes_to_read;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
new file mode 100644
index 0000000..b54cded
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -0,0 +1,1222 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/crc32.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+#include "octeon_mem_ops.h"
+
+/** Default configuration
+ *  for CN66XX OCTEON Models.
+ */
+static struct octeon_config default_cn66xx_conf = {
+	/** IQ attributes */
+	.iq					= {
+		.max_iqs			= CN6XXX_CFG_IO_QUEUES,
+		.pending_list_size		=
+			(CN6XXX_MAX_IQ_DESCRIPTORS * CN6XXX_CFG_IO_QUEUES),
+		.instr_type			= OCTEON_64BYTE_INSTR,
+		.db_min				= CN6XXX_DB_MIN,
+		.db_timeout			= CN6XXX_DB_TIMEOUT,
+	}
+	,
+
+	/** OQ attributes */
+	.oq					= {
+		.max_oqs			= CN6XXX_CFG_IO_QUEUES,
+		.info_ptr			= OCTEON_OQ_INFOPTR_MODE,
+		.refill_threshold		= CN6XXX_OQ_REFIL_THRESHOLD,
+		.oq_intr_pkt			= CN6XXX_OQ_INTR_PKT,
+		.oq_intr_time			= CN6XXX_OQ_INTR_TIME,
+		.pkts_per_intr			= CN6XXX_OQ_PKTSPER_INTR,
+	}
+	,
+
+	.num_nic_ports				= DEFAULT_NUM_NIC_PORTS_66XX,
+	.num_def_rx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+	.num_def_tx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+	.def_rx_buf_size			= CN6XXX_OQ_BUF_SIZE,
+
+	/* For ethernet interface 0:  Port cfg Attributes */
+	.nic_if_cfg[0] = {
+		/* Max Txqs: Half for each of the two ports :max_iq/2 */
+		.max_txqs			= MAX_TXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_txqs */
+		.num_txqs			= DEF_TXQS_PER_INTF,
+
+		/* Max Rxqs: Half for each of the two ports :max_oq/2  */
+		.max_rxqs			= MAX_RXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_rxqs */
+		.num_rxqs			= DEF_RXQS_PER_INTF,
+
+		/* Num of desc for rx rings */
+		.num_rx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* Num of desc for tx rings */
+		.num_tx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* SKB size, We need not change buf size even for Jumbo frames.
+		 * Octeon can send jumbo frames in 4 consecutive descriptors,
+		 */
+		.rx_buf_size			= CN6XXX_OQ_BUF_SIZE,
+
+	},
+
+	/* For ethernet interface 1:  Port cfg Attributes */
+	.nic_if_cfg[1] = {
+		/* Max Txqs: Half for each of the two ports: max_iq/2 */
+		.max_txqs			= MAX_TXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_txqs */
+		.num_txqs			= DEF_TXQS_PER_INTF,
+
+		/* Max Rxqs: Half for each of the two ports: max_oq/2 */
+		.max_rxqs			= MAX_RXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_rxqs */
+		.num_rxqs			= DEF_RXQS_PER_INTF,
+
+		/* Num of desc for rx rings */
+		.num_rx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* Num of desc for tx rings */
+		.num_tx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* SKB size, We need not change buf size even for Jumbo frames.
+		 * Octeon can send jumbo frames in 4 consecutive descriptors,
+		 */
+		.rx_buf_size			= CN6XXX_OQ_BUF_SIZE,
+
+	},
+
+	/** Miscellaneous attributes */
+	.misc					= {
+		/* Host driver link query interval */
+		.oct_link_query_interval	= 100,
+
+		/* Octeon link query interval */
+		.host_link_query_interval	= 500,
+
+		.enable_sli_oq_bp		= 0,
+
+		/* Control queue group */
+		.ctrlq_grp			= 1,
+	}
+	,
+};
+
+/** Default configuration
+ *  for CN68XX OCTEON Model.
+ */
+
+static struct octeon_config default_cn68xx_conf = {
+	/** IQ attributes */
+
+	.iq					= {
+		.max_iqs			= CN6XXX_CFG_IO_QUEUES,
+		.pending_list_size		=
+			(CN6XXX_MAX_IQ_DESCRIPTORS * CN6XXX_CFG_IO_QUEUES),
+		.instr_type			= OCTEON_64BYTE_INSTR,
+		.db_min				= CN6XXX_DB_MIN,
+		.db_timeout			= CN6XXX_DB_TIMEOUT,
+	}
+	,
+
+	/** OQ attributes */
+	.oq					= {
+		.max_oqs			= CN6XXX_CFG_IO_QUEUES,
+		.info_ptr			= OCTEON_OQ_INFOPTR_MODE,
+		.refill_threshold		= CN6XXX_OQ_REFIL_THRESHOLD,
+		.oq_intr_pkt			= CN6XXX_OQ_INTR_PKT,
+		.oq_intr_time			= CN6XXX_OQ_INTR_TIME,
+		.pkts_per_intr			= CN6XXX_OQ_PKTSPER_INTR,
+	}
+	,
+
+	.num_nic_ports				= DEFAULT_NUM_NIC_PORTS_68XX,
+	.num_def_rx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+	.num_def_tx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+	.def_rx_buf_size			= CN6XXX_OQ_BUF_SIZE,
+
+	.nic_if_cfg[0] = {
+		/* Max Txqs: Half for each of the two ports :max_iq/2 */
+		.max_txqs			= MAX_TXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_txqs */
+		.num_txqs			= DEF_TXQS_PER_INTF,
+
+		/* Max Rxqs: Half for each of the two ports :max_oq/2  */
+		.max_rxqs			= MAX_RXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_rxqs */
+		.num_rxqs			= DEF_RXQS_PER_INTF,
+
+		/* Num of desc for rx rings */
+		.num_rx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* Num of desc for tx rings */
+		.num_tx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* SKB size, We need not change buf size even for Jumbo frames.
+		 * Octeon can send jumbo frames in 4 consecutive descriptors,
+		 */
+		.rx_buf_size			= CN6XXX_OQ_BUF_SIZE,
+
+	},
+
+	/* For ethernet interface 1:  Port cfg Attributes */
+	.nic_if_cfg[1] = {
+		/* Max Txqs: Half for each of the two ports: max_iq/2 */
+		.max_txqs			= MAX_TXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_txqs */
+		.num_txqs			= DEF_TXQS_PER_INTF,
+
+		/* Max Rxqs: Half for each of the two ports: max_oq/2 */
+		.max_rxqs			= MAX_RXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_rxqs */
+		.num_rxqs			= DEF_RXQS_PER_INTF,
+
+		/* Num of desc for rx rings */
+		.num_rx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* Num of desc for tx rings */
+		.num_tx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* SKB size, We need not change buf size even for Jumbo frames.
+		 * Octeon can send jumbo frames in 4 consecutive descriptors,
+		 */
+		.rx_buf_size			= CN6XXX_OQ_BUF_SIZE,
+
+	},
+
+	/* For ethernet interface 1:  Port cfg Attributes */
+	.nic_if_cfg[2] = {
+		/* Max Txqs: Half for each of the two ports: max_iq/2 */
+		.max_txqs			= MAX_TXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_txqs */
+		.num_txqs			= DEF_TXQS_PER_INTF,
+
+		/* Max Rxqs: Half for each of the two ports: max_oq/2 */
+		.max_rxqs			= MAX_RXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_rxqs */
+		.num_rxqs			= DEF_RXQS_PER_INTF,
+
+		/* Num of desc for rx rings */
+		.num_rx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* Num of desc for tx rings */
+		.num_tx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* SKB size, We need not change buf size even for Jumbo frames.
+		 * Octeon can send jumbo frames in 4 consecutive descriptors,
+		 */
+		.rx_buf_size			= CN6XXX_OQ_BUF_SIZE,
+
+	},
+
+	/* For ethernet interface 1:  Port cfg Attributes */
+	.nic_if_cfg[3] = {
+		/* Max Txqs: Half for each of the two ports: max_iq/2 */
+		.max_txqs			= MAX_TXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_txqs */
+		.num_txqs			= DEF_TXQS_PER_INTF,
+
+		/* Max Rxqs: Half for each of the two ports: max_oq/2 */
+		.max_rxqs			= MAX_RXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_rxqs */
+		.num_rxqs			= DEF_RXQS_PER_INTF,
+
+		/* Num of desc for rx rings */
+		.num_rx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* Num of desc for tx rings */
+		.num_tx_descs			= CN6XXX_MAX_IQ_DESCRIPTORS,
+
+		/* SKB size, We need not change buf size even for Jumbo frames.
+		 * Octeon can send jumbo frames in 4 consecutive descriptors,
+		 */
+		.rx_buf_size			= CN6XXX_OQ_BUF_SIZE,
+
+	},
+	/** Miscellaneous attributes */
+	.misc					= {
+		/* Host driver link query interval */
+		.oct_link_query_interval	= 100,
+
+		/* Octeon link query interval */
+		.host_link_query_interval	= 500,
+
+		.enable_sli_oq_bp		= 0,
+
+		/* Control queue group */
+		.ctrlq_grp			= 1,
+	}
+	,
+};
+
+/* All Octeon devices use the default configuration above.
+ * To override the default:
+ * 1.  The Octeon device Id must be known for customizing the octeon
+ *     configuration.
+ * 2.  Create a custom configuration based on CN66XX or CN68XX config structure
+ *     (see octeon_config.h)
+ * 3.  Modify the config type of the octeon device in the structure below to
+ *     specify CN66XX or CN68XX configuration and replace the "custom" pointer
+ *     to point to your custom configuration
+ */
+static struct octeon_config_ptr {
+	uint32_t conf_type;
+	void *custom;
+} oct_conf_info[MAX_OCTEON_DEVICES] = {
+	{
+		OCTEON_CONFIG_TYPE_DEFAULT, NULL
+	}, {
+		OCTEON_CONFIG_TYPE_DEFAULT, NULL
+	}, {
+		OCTEON_CONFIG_TYPE_DEFAULT, NULL
+	}, {
+		OCTEON_CONFIG_TYPE_DEFAULT, NULL
+	},
+};
+
+static char oct_dev_state_str[OCT_DEV_STATES + 1][32] = {
+	"BEGIN",	"PCI-MAP-DONE",	      "DISPATCH-INIT-DONE",
+	"IQ-INIT-DONE", "RESPLIST-INIT-DONE", "DROQ-INIT-DONE",
+	"HOST-READY",	"CORE-READY",	      "RUNNING",	   "IN-RESET",
+	"INVALID"
+};
+
+static char oct_dev_app_str[CVM_DRV_APP_COUNT + 1][32] = {
+	"BASE", "NIC", "UNKNOWN"};
+
+static struct octeon_device *octeon_device[MAX_OCTEON_DEVICES];
+static uint32_t octeon_device_count;
+
+static struct octeon_core_setup core_setup[MAX_OCTEON_DEVICES];
+
+void octeon_init_device_list(void)
+{
+	memset(octeon_device, 0, (sizeof(void *) * MAX_OCTEON_DEVICES));
+}
+
+static void *__retrieve_octeon_config_info(struct octeon_device *oct)
+{
+	uint32_t oct_id = oct->octeon_id;
+
+	if (oct_conf_info[oct_id].conf_type != OCTEON_CONFIG_TYPE_DEFAULT) {
+		if ((oct->chip_id == OCTEON_CN66XX) &&
+		    (oct_conf_info[oct_id].conf_type ==
+		     OCTEON_CONFIG_TYPE_CN66XX_CUSTOM))
+			return oct_conf_info[oct_id].custom;
+
+		if ((oct->chip_id == OCTEON_CN68XX) &&
+		    (oct_conf_info[oct_id].conf_type ==
+		     OCTEON_CONFIG_TYPE_CN68XX_CUSTOM))
+			return oct_conf_info[oct_id].custom;
+
+		lio_dev_err(oct,
+			    "Incompatible config type (%d) for chip type %x\n",
+			    oct_conf_info[oct_id].conf_type, oct->chip_id);
+		return NULL;
+	}
+
+	if (oct->chip_id == OCTEON_CN66XX)
+		return (void *)&default_cn66xx_conf;
+
+	if (oct->chip_id == OCTEON_CN68XX)
+		return (void *)&default_cn68xx_conf;
+
+	return NULL;
+}
+
+static int __verify_octeon_config_info(struct octeon_device *oct, void *conf)
+{
+	switch (oct->chip_id) {
+	case OCTEON_CN66XX:
+		return lio_validate_cn66xx_config_info(oct, conf);
+
+	case OCTEON_CN68XX:
+		return lio_validate_cn68xx_config_info(oct, conf);
+
+	default:
+		break;
+	}
+
+	return 1;
+}
+
+void *oct_get_config_info(struct octeon_device *oct)
+{
+	void *conf = NULL;
+
+	conf = __retrieve_octeon_config_info(oct);
+	if (!conf)
+		return NULL;
+
+	if (__verify_octeon_config_info(oct, conf)) {
+		lio_dev_err(oct, "Configuration verification failed\n");
+		return NULL;
+	}
+
+	return conf;
+}
+
+char *lio_get_state_string(atomic_t *state_ptr)
+{
+	int32_t istate = (int32_t)atomic_read(state_ptr);
+
+	if (istate > OCT_DEV_STATES || istate < 0)
+		return oct_dev_state_str[OCT_DEV_STATE_INVALID];
+	return oct_dev_state_str[istate];
+}
+
+static char *get_oct_app_string(uint32_t app_mode)
+{
+	if (app_mode <= CVM_DRV_APP_END)
+		return oct_dev_app_str[app_mode - CVM_DRV_APP_START];
+	return oct_dev_app_str[CVM_DRV_INVALID_APP - CVM_DRV_APP_START];
+}
+
+int octeon_download_firmware(struct octeon_device *oct, const uint8_t *data,
+			     size_t size)
+{
+	int ret = 0;
+	uint8_t *p;
+	uint8_t *buffer;
+	uint32_t crc32_result;
+	uint64_t load_addr;
+	uint32_t image_len;
+	struct octeon_firmware_file_header *h;
+	int8_t tmp[OCTEON_MAX_FIRMWARE_VERSION_LEN];
+	size_t   major_version;
+	uint32_t i;
+
+	if (size < sizeof(struct octeon_firmware_file_header)) {
+		lio_dev_err(oct, "Firmware file too small (%d < %d).\n",
+			    (uint32_t)size,
+			    (uint32_t)sizeof(
+			    struct octeon_firmware_file_header));
+		return -EINVAL;
+	}
+
+	h = (struct octeon_firmware_file_header *)data;
+
+	if (h->magic != be32_to_cpu(OCTEON_NIC_MAGIC)) {
+		lio_dev_err(oct, "Unrecognized firmware file.\n");
+		return -EINVAL;
+	}
+
+	strncpy(tmp, h->version, OCTEON_MAX_FIRMWARE_VERSION_LEN);
+	for (i = 0; i < OCTEON_MAX_FIRMWARE_VERSION_LEN; i++) {
+		if (tmp[i] == '.') {
+			tmp[i] = '\0';
+			break;
+		}
+	}
+
+	ret = kstrtol(tmp, 10, &major_version);
+	if (ret) {
+		lio_dev_err(oct, "Invalid firmware version.\n");
+		return ret;
+	}
+
+	if (major_version != LIQUIDIO_MAJOR_VERSION) {
+		lio_dev_err(oct,
+			    "Incompatible firmware version. Expected %d, got %ld (%s).\n",
+			    LIQUIDIO_MAJOR_VERSION, major_version, h->version);
+		return -EINVAL;
+	}
+
+	if (be32_to_cpu(h->num_images) > OCTEON_MAX_IMAGES) {
+		lio_dev_err(oct, "Too many images in firmware file (%d).\n",
+			    be32_to_cpu(h->num_images));
+		return -EINVAL;
+	}
+
+	crc32_result =
+		crc32(~0, data,
+		      sizeof(struct octeon_firmware_file_header) -
+		      sizeof(uint32_t)) ^ ~0U;
+	if (crc32_result != be32_to_cpu(h->crc32)) {
+		lio_dev_err(oct, "Firmware CRC mismatch (0x%08x != 0x%08x).\n",
+			    crc32_result, be32_to_cpu(h->crc32));
+		return -EINVAL;
+	}
+
+	lio_dev_info(oct, "Firmware version: %s\n", h->version);
+	snprintf(oct->fw_info.liquidio_firmware_version, 32, "LIQUIDIO: %s",
+		 h->version);
+
+	buffer = kmalloc(size, GFP_KERNEL);
+	if (!buffer)
+		return -ENOMEM;
+
+	memcpy(buffer, data, size);
+
+	p = buffer + sizeof(struct octeon_firmware_file_header);
+
+	/* load all images */
+	for (i = 0; i < be32_to_cpu(h->num_images); i++) {
+		load_addr = be64_to_cpu(h->desc[i].addr);
+		image_len = be32_to_cpu(h->desc[i].len);
+
+		/* validate the image */
+		crc32_result = crc32(~0, p, image_len) ^ ~0U;
+		if (crc32_result != be32_to_cpu(h->desc[i].crc32)) {
+			lio_dev_err(oct,
+				    "Firmware CRC mismatch in image %d (0x%08x != 0x%08x).\n",
+				    i, crc32_result,
+				    be32_to_cpu(h->desc[i].crc32));
+			ret = -EINVAL;
+			goto done_downloading;
+		}
+
+		/* download the image */
+		octeon_pci_write_core_mem(oct, load_addr, p, image_len);
+
+		p += image_len;
+		lio_dev_dbg(oct,
+			    "Downloaded image %d (%d bytes) to address 0x%016llx\n",
+			    i, image_len, load_addr);
+	}
+
+	/* Invoke the bootcmd */
+	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
+
+done_downloading:
+	kfree(buffer);
+
+	return ret;
+}
+
+void octeon_free_device_mem(struct octeon_device *oct)
+{
+	uint32_t i;
+
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+		/* could check  mask as well */
+		if (oct->droq[i])
+			vfree(oct->droq[i]);
+	}
+
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+		/* could check mask as well */
+		if (oct->instr_queue[i])
+			vfree(oct->instr_queue[i]);
+	}
+
+	i = oct->octeon_id;
+	vfree(oct);
+
+	octeon_device[i] = NULL;
+	octeon_device_count--;
+}
+
+static struct octeon_device *octeon_allocate_device_mem(uint32_t pci_id,
+							uint32_t priv_size)
+{
+	struct octeon_device *oct;
+	uint8_t *buf = NULL;
+	uint32_t octdevsize = 0, configsize = 0, size;
+
+	switch (pci_id) {
+	case OCTEON_CN68XX:
+		configsize = sizeof(struct octeon_cn68xx);
+		break;
+
+	case OCTEON_CN66XX:
+		configsize = sizeof(struct octeon_cn6xxx);
+		break;
+
+	default:
+		cavium_pr_err("%s: Unknown PCI Device: 0x%x\n",
+			      __func__,
+			      pci_id);
+		return NULL;
+	}
+
+	if (configsize & 0x7)
+		configsize += (8 - (configsize & 0x7));
+
+	octdevsize = sizeof(struct octeon_device);
+	if (octdevsize & 0x7)
+		octdevsize += (8 - (octdevsize & 0x7));
+
+	if (priv_size & 0x7)
+		priv_size += (8 - (priv_size & 0x7));
+
+	size = octdevsize + priv_size + configsize +
+		(sizeof(struct octeon_dispatch) * DISPATCH_LIST_SIZE);
+
+	buf = vmalloc(size);
+	if (!buf)
+		return NULL;
+
+	memset(buf, 0, size);
+
+	oct = (struct octeon_device *)buf;
+	oct->priv = (void *)(buf + octdevsize);
+	oct->chip = (void *)(buf + octdevsize + priv_size);
+	oct->dispatch.dlist = (struct octeon_dispatch *)
+		(buf + octdevsize + priv_size + configsize);
+
+	return oct;
+}
+
+struct octeon_device *octeon_allocate_device(uint32_t pci_id,
+					     uint32_t priv_size)
+{
+	uint32_t oct_idx = 0;
+	struct octeon_device *oct = NULL;
+
+	for (oct_idx = 0; oct_idx < MAX_OCTEON_DEVICES; oct_idx++)
+		if (!octeon_device[oct_idx])
+			break;
+
+	if (oct_idx == MAX_OCTEON_DEVICES)
+		return NULL;
+
+	oct = octeon_allocate_device_mem(pci_id, priv_size);
+	if (!oct)
+		return NULL;
+
+	octeon_device_count++;
+	octeon_device[oct_idx] = oct;
+
+	oct->octeon_id = oct_idx;
+	snprintf((oct->device_name), sizeof(oct->device_name),
+		 "LiquidIO%d", (oct->octeon_id));
+
+	return oct;
+}
+
+int octeon_setup_instr_queues(struct octeon_device *oct)
+{
+	uint32_t i, num_iqs = 0;
+	uint32_t num_descs = 0;
+
+	/* this causes queue 0 to be default queue */
+	if (oct->chip_id == OCTEON_CN66XX) {
+		num_iqs = 1;
+		num_descs =
+			CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
+	}
+
+	if (oct->chip_id == OCTEON_CN68XX) {
+		num_iqs = 1;
+		num_descs =
+			CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn68xx, conf));
+	}
+
+	oct->num_iqs = 0;
+
+	for (i = 0; i < num_iqs; i++) {
+		oct->instr_queue[i] =
+			vmalloc(sizeof(struct octeon_instr_queue));
+		if (!oct->instr_queue[i])
+			return 1;
+
+		memset(oct->instr_queue[i], 0,
+		       sizeof(struct octeon_instr_queue));
+
+		oct->instr_queue[i]->app_ctx = (void *)(size_t)i;
+		if (octeon_init_instr_queue(oct, i, num_descs))
+			return 1;
+
+		oct->num_iqs++;
+	}
+
+	return 0;
+}
+
+int octeon_setup_output_queues(struct octeon_device *oct)
+{
+	uint32_t i, num_oqs = 0;
+	uint32_t num_descs = 0;
+	uint32_t desc_size = 0;
+
+	/* this causes queue 0 to be default queue */
+	if (oct->chip_id == OCTEON_CN66XX) {
+		/* CFG_GET_OQ_MAX_BASE_Q(CHIP_FIELD(oct, cn6xxx, conf)); */
+		num_oqs = 1;
+		num_descs =
+			CFG_GET_NUM_DEF_RX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
+		desc_size =
+			CFG_GET_DEF_RX_BUF_SIZE(CHIP_FIELD(oct, cn6xxx, conf));
+	}
+
+	if (oct->chip_id == OCTEON_CN68XX) {
+		/* CFG_GET_OQ_MAX_BASE_Q(CHIP_FIELD(oct, cn68xx, conf)); */
+		num_oqs = 1;
+		num_descs =
+			CFG_GET_NUM_DEF_RX_DESCS(CHIP_FIELD(oct, cn68xx, conf));
+		desc_size =
+			CFG_GET_DEF_RX_BUF_SIZE(CHIP_FIELD(oct, cn68xx, conf));
+	}
+
+	oct->num_oqs = 0;
+
+	for (i = 0; i < num_oqs; i++) {
+		oct->droq[i] = vmalloc(sizeof(*oct->droq[i]));
+		if (!oct->droq[i])
+			return 1;
+
+		memset(oct->droq[i], 0, sizeof(struct octeon_droq));
+
+		if (octeon_init_droq(oct, i, num_descs, desc_size, NULL))
+			return 1;
+
+		oct->num_oqs++;
+	}
+
+	return 0;
+}
+
+void octeon_set_io_queues_off(struct octeon_device *oct)
+{
+	/* Disable the i/p and o/p queues for this Octeon. */
+
+	if (oct->chip_id == OCTEON_CN66XX) {
+		octeon_write_csr(oct, CN66XX_SLI_PKT_INSTR_ENB, 0);
+		octeon_write_csr(oct, CN66XX_SLI_PKT_OUT_ENB, 0);
+	}
+
+	if (oct->chip_id == OCTEON_CN68XX) {
+		octeon_write_csr(oct, CN68XX_SLI_PKT_INSTR_ENB, 0);
+		octeon_write_csr(oct, CN68XX_SLI_PKT_OUT_ENB, 0);
+	}
+}
+
+void octeon_set_droq_pkt_op(struct octeon_device *oct,
+			    uint32_t q_no,
+			    uint32_t enable)
+{
+	uint32_t reg = 0, reg_val = 0;
+
+	/* Disable the i/p and o/p queues for this Octeon. */
+	if (oct->chip_id == OCTEON_CN66XX)
+		reg = CN66XX_SLI_PKT_OUT_ENB;
+	else if (oct->chip_id == OCTEON_CN68XX)
+		reg = CN68XX_SLI_PKT_OUT_ENB;
+
+	reg_val = octeon_read_csr(oct, reg);
+
+	if (enable)
+		reg_val = reg_val | (1 << q_no);
+	else
+		reg_val = reg_val & (~(1 << q_no));
+
+	octeon_write_csr(oct, reg, reg_val);
+}
+
+int octeon_init_dispatch_list(struct octeon_device *oct)
+{
+	uint32_t i;
+
+	oct->dispatch.count = 0;
+
+	for (i = 0; i < DISPATCH_LIST_SIZE; i++) {
+		oct->dispatch.dlist[i].opcode = 0;
+		INIT_LIST_HEAD(&oct->dispatch.dlist[i].list);
+	}
+
+	spin_lock_init(&oct->dispatch.lock);
+
+	return 0;
+}
+
+void octeon_delete_dispatch_list(struct octeon_device *oct)
+{
+	uint32_t i;
+	struct list_head freelist, *temp, *tmp2;
+
+	INIT_LIST_HEAD(&freelist);
+
+	spin_lock_bh(&oct->dispatch.lock);
+
+	for (i = 0; i < DISPATCH_LIST_SIZE; i++) {
+		struct list_head *dispatch;
+
+		dispatch = &oct->dispatch.dlist[i].list;
+		while (dispatch->next != dispatch) {
+			temp = dispatch->next;
+			list_del(temp);
+			list_add_tail(temp, &freelist);
+		}
+
+		oct->dispatch.dlist[i].opcode = 0;
+	}
+
+	oct->dispatch.count = 0;
+
+	spin_unlock_bh(&oct->dispatch.lock);
+
+	list_for_each_safe(temp, tmp2, &freelist) {
+		list_del(temp);
+		vfree(temp);
+	}
+}
+
+octeon_dispatch_fn_t
+octeon_get_dispatch(struct octeon_device *octeon_dev, uint16_t opcode,
+		    uint16_t subcode)
+{
+	uint32_t idx;
+	struct list_head *dispatch;
+	octeon_dispatch_fn_t fn = NULL;
+	uint16_t combined_opcode = OPCODE_SUBCODE(opcode, subcode);
+
+	idx = combined_opcode & OCTEON_OPCODE_MASK;
+
+	spin_lock_bh(&octeon_dev->dispatch.lock);
+
+	if (octeon_dev->dispatch.count == 0) {
+		spin_unlock_bh(&octeon_dev->dispatch.lock);
+		return NULL;
+	}
+
+	if (!(octeon_dev->dispatch.dlist[idx].opcode)) {
+		spin_unlock_bh(&octeon_dev->dispatch.lock);
+		return NULL;
+	}
+
+	if (octeon_dev->dispatch.dlist[idx].opcode == combined_opcode) {
+		fn = octeon_dev->dispatch.dlist[idx].dispatch_fn;
+	} else {
+		list_for_each(dispatch,
+			      &octeon_dev->dispatch.dlist[idx].list) {
+			if (((struct octeon_dispatch *)dispatch)->opcode ==
+			    combined_opcode) {
+				fn = ((struct octeon_dispatch *)
+				      dispatch)->dispatch_fn;
+				break;
+			}
+		}
+	}
+
+	spin_unlock_bh(&octeon_dev->dispatch.lock);
+	return fn;
+}
+
+/* octeon_register_dispatch_fn
+ * Parameters:
+ *   octeon_id - id of the octeon device.
+ *   opcode    - opcode for which driver should call the registered function
+ *   subcode   - subcode for which driver should call the registered function
+ *   fn        - The function to call when a packet with "opcode" arrives in
+ *		  octeon output queues.
+ *   fn_arg    - The argument to be passed when calling function "fn".
+ * Description:
+ *   Registers a function and its argument to be called when a packet
+ *   arrives in Octeon output queues with "opcode".
+ * Returns:
+ *   Success: 0
+ *   Failure: 1
+ * Locks:
+ *   No locks are held.
+ */
+int
+octeon_register_dispatch_fn(struct octeon_device *oct,
+			    uint16_t opcode,
+			    uint16_t subcode,
+			    octeon_dispatch_fn_t fn, void *fn_arg)
+{
+	uint32_t idx;
+	octeon_dispatch_fn_t pfn;
+	uint16_t combined_opcode = OPCODE_SUBCODE(opcode, subcode);
+
+	idx = combined_opcode & OCTEON_OPCODE_MASK;
+
+	spin_lock_bh(&oct->dispatch.lock);
+	/* Add dispatch function to first level of lookup table */
+	if (oct->dispatch.dlist[idx].opcode == 0) {
+		oct->dispatch.dlist[idx].opcode = combined_opcode;
+		oct->dispatch.dlist[idx].dispatch_fn = fn;
+		oct->dispatch.dlist[idx].arg = fn_arg;
+		oct->dispatch.count++;
+		spin_unlock_bh(&oct->dispatch.lock);
+		return 0;
+	}
+
+	spin_unlock_bh(&oct->dispatch.lock);
+
+	/* Check if there was a function already registered for this
+	 * opcode/subcode.
+	 */
+	pfn = octeon_get_dispatch(oct, opcode, subcode);
+	if (!pfn) {
+		struct octeon_dispatch *dispatch;
+
+		lio_dev_dbg(oct,
+			    "Adding opcode to dispatch list linked list\n");
+		dispatch = (struct octeon_dispatch *)
+			   vmalloc(sizeof(struct octeon_dispatch));
+		if (!dispatch) {
+			lio_dev_err(oct,
+				    "No memory to add dispatch function\n");
+			return 1;
+		}
+		dispatch->opcode = combined_opcode;
+		dispatch->dispatch_fn = fn;
+		dispatch->arg = fn_arg;
+
+		/* Add dispatch function to linked list of fn ptrs
+		 * at the hashed index.
+		 */
+		spin_lock_bh(&oct->dispatch.lock);
+		list_add(&dispatch->list, &oct->dispatch.dlist[idx].list);
+		oct->dispatch.count++;
+		spin_unlock_bh(&oct->dispatch.lock);
+
+	} else {
+		lio_dev_err(oct,
+			    "Found previously registered dispatch fn for opcode/subcode: %x/%x\n",
+			    opcode, subcode);
+		return 1;
+	}
+
+	return 0;
+}
+
+/* octeon_unregister_dispatch_fn
+ * Parameters:
+ *   oct       - octeon device
+ *   opcode    - driver should unregister the function for this opcode
+ *   subcode   - driver should unregister the function for this subcode
+ * Description:
+ *   Unregister the function set for this opcode+subcode.
+ * Returns:
+ *   Success: 0
+ *   Failure: 1
+ * Locks:
+ *   No locks are held.
+ */
+int
+octeon_unregister_dispatch_fn(struct octeon_device *oct, uint16_t opcode,
+			      uint16_t subcode)
+{
+	int retval = 0;
+	uint32_t idx;
+	struct list_head *dispatch, *dfree = NULL, *tmp2;
+	uint16_t combined_opcode = OPCODE_SUBCODE(opcode, subcode);
+
+	idx = combined_opcode & OCTEON_OPCODE_MASK;
+
+	spin_lock_bh(&oct->dispatch.lock);
+
+	if (oct->dispatch.count == 0) {
+		spin_unlock_bh(&oct->dispatch.lock);
+		lio_dev_err(oct,
+			    "No dispatch functions registered for this device\n");
+		return 1;
+	}
+
+	if (oct->dispatch.dlist[idx].opcode == combined_opcode) {
+		dispatch = &oct->dispatch.dlist[idx].list;
+		if (dispatch->next != dispatch) {
+			dispatch = dispatch->next;
+			oct->dispatch.dlist[idx].opcode =
+				((struct octeon_dispatch *)dispatch)->opcode;
+			oct->dispatch.dlist[idx].dispatch_fn =
+				((struct octeon_dispatch *)
+				 dispatch)->dispatch_fn;
+			oct->dispatch.dlist[idx].arg =
+				((struct octeon_dispatch *)dispatch)->arg;
+			list_del(dispatch);
+			dfree = dispatch;
+		} else {
+			oct->dispatch.dlist[idx].opcode = 0;
+			oct->dispatch.dlist[idx].dispatch_fn = NULL;
+			oct->dispatch.dlist[idx].arg = NULL;
+		}
+	} else {
+		retval = 1;
+		list_for_each_safe(dispatch, tmp2,
+				   &(oct->dispatch.dlist[idx].
+				     list)) {
+			if (((struct octeon_dispatch *)dispatch)->opcode ==
+			    combined_opcode) {
+				list_del(dispatch);
+				dfree = dispatch;
+				retval = 0;
+			}
+		}
+	}
+
+	if (!retval)
+		oct->dispatch.count--;
+
+	spin_unlock_bh(&oct->dispatch.lock);
+
+	if (dfree)
+		vfree(dfree);
+
+	return retval;
+}
+
+int octeon_core_drv_init(struct octeon_recv_info *recv_info, void *buf)
+{
+	uint32_t i, oct_id;
+	char app_name[16];
+	struct octeon_device *oct = (struct octeon_device *)buf;
+	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
+	uint32_t num_nic_ports = 0;
+
+	if (oct->chip_id == OCTEON_CN66XX)
+		num_nic_ports =
+			CFG_GET_NUM_NIC_PORTS(CHIP_FIELD(oct, cn6xxx, conf));
+
+	if (oct->chip_id == OCTEON_CN68XX)
+		num_nic_ports =
+			CFG_GET_NUM_NIC_PORTS(CHIP_FIELD(oct, cn68xx, conf));
+
+	if (atomic_read(&oct->status) >= OCT_DEV_RUNNING) {
+		lio_dev_err(oct, "Received CORE OK when device state is 0x%x\n",
+			    atomic_read(&oct->status));
+		goto core_drv_init_err;
+	}
+
+	strncpy(app_name,
+		get_oct_app_string(
+		(uint32_t)recv_pkt->rh.r_core_drv_init.app_mode),
+		sizeof(app_name) - 1);
+	oct->app_mode = (uint32_t)recv_pkt->rh.r_core_drv_init.app_mode;
+	if (recv_pkt->rh.r_core_drv_init.app_mode == CVM_DRV_NIC_APP)
+		oct->fw_info.max_nic_ports =
+			(uint32_t)recv_pkt->rh.r_core_drv_init.app_specific;
+
+	if (oct->fw_info.max_nic_ports < num_nic_ports) {
+		lio_dev_err(oct,
+			    "Config has more ports than firmware allows (%d > %d).\n",
+			    num_nic_ports, oct->fw_info.max_nic_ports);
+		goto core_drv_init_err;
+	}
+	oct->fw_info.app_cap_flags = recv_pkt->rh.r_core_drv_init.app_cap_flags;
+	oct->fw_info.app_mode = (uint32_t)recv_pkt->rh.r_core_drv_init.app_mode;
+
+	atomic_set(&oct->status, OCT_DEV_CORE_OK);
+
+	if (recv_pkt->buffer_size[0] != sizeof(struct octeon_core_setup)) {
+		lio_dev_err(oct, "Core setup bytes expected %u found %d\n",
+			    (uint32_t)sizeof(struct octeon_core_setup),
+			    recv_pkt->buffer_size[0]);
+	}
+
+	oct_id = oct->octeon_id;
+	memcpy(&core_setup[oct_id],
+	       get_rbd(recv_pkt->buffer_ptr[0]),
+	       sizeof(struct octeon_core_setup));
+	strncpy(oct->boardinfo.name,
+		core_setup[oct_id].boardname, OCT_BOARD_NAME);
+	strncpy(oct->boardinfo.serial_number,
+		core_setup[oct_id].board_serial_number, OCT_SERIAL_LEN);
+
+	octeon_swap_8B_data((uint64_t *)&core_setup[oct_id],
+			    (sizeof(struct octeon_core_setup)>>3));
+
+	oct->boardinfo.major = core_setup[oct_id].board_rev_major;
+	oct->boardinfo.minor = core_setup[oct_id].board_rev_minor;
+
+	lio_dev_info(oct,
+		     "Running %s (%llu Hz, # ports=%d)\n",
+		     app_name, CVM_CAST64(core_setup[oct_id].corefreq),
+		     recv_pkt->rh.r_core_drv_init.app_specific);
+
+core_drv_init_err:
+	for (i = 0; i < recv_pkt->buffer_count; i++)
+		recv_buffer_free(recv_pkt->buffer_ptr[i]);
+	octeon_free_recv_info(recv_info);
+	return 0;
+}
+
+int octeon_get_tx_qsize(struct octeon_device *oct, uint32_t q_no)
+
+{
+	if (oct && (q_no < MAX_OCTEON_INSTR_QUEUES) &&
+	    (oct->io_qmask.iq & (1UL << q_no)))
+		return oct->instr_queue[q_no]->max_count;
+
+	return -1;
+}
+
+int octeon_get_rx_qsize(struct octeon_device *oct, uint32_t q_no)
+{
+	if (oct && (q_no < MAX_OCTEON_OUTPUT_QUEUES) &&
+	    (oct->io_qmask.oq & (1UL << q_no)))
+		return oct->droq[q_no]->max_count;
+	return -1;
+}
+
+/* Retruns the host firmware handshake OCTEON specific configuration */
+struct octeon_config *octeon_get_conf(struct octeon_device *oct)
+{
+	struct octeon_config *default_oct_conf = NULL;
+
+	/* check the OCTEON Device model & return the corresponding octeon
+	 * configuration
+	 */
+	if (oct->chip_id == OCTEON_CN66XX)
+		default_oct_conf =
+			(struct octeon_config *)(CHIP_FIELD(oct, cn6xxx, conf));
+
+	if (oct->chip_id == OCTEON_CN68XX)
+		default_oct_conf =
+			(struct octeon_config *)(CHIP_FIELD(oct, cn68xx, conf));
+
+	return default_oct_conf;
+}
+
+/* scratch register address is same in all the OCT-II and CN70XX models */
+#define CNXX_SLI_SCRATCH1   0x3C0
+
+/** Get the octeon device pointer.
+ *  @param octeon_id  - The id for which the octeon device pointer is required.
+ *  @return Success: Octeon device pointer.
+ *  @return Failure: NULL.
+ */
+struct octeon_device *lio_get_device(uint32_t octeon_id)
+{
+	if (octeon_id >= MAX_OCTEON_DEVICES)
+		return NULL;
+	else
+		return octeon_device[octeon_id];
+}
+
+uint64_t OCTEON_PCI_WIN_READ(struct octeon_device *oct,
+			     uint64_t addr)
+{
+	uint64_t val64;
+	uint32_t val32, addrhi;
+
+	/* The windowed read happens when the LSB of the addr is written.
+	 * So write MSB first
+	 */
+	addrhi = (addr >> 32);
+	if ((oct->chip_id == OCTEON_CN66XX) || (oct->chip_id == OCTEON_CN68XX))
+		addrhi |= 0x00060000;
+	writel(addrhi, oct->reg_list.pci_win_rd_addr_hi);
+
+	/* Read back to preserve ordering of writes */
+	val32 = readl(oct->reg_list.pci_win_rd_addr_hi);
+
+	writel(addr & 0xffffffff, oct->reg_list.pci_win_rd_addr_lo);
+	val32 = readl(oct->reg_list.pci_win_rd_addr_lo);
+
+	val64 = readq(oct->reg_list.pci_win_rd_data);
+
+	return val64;
+}
+
+void OCTEON_PCI_WIN_WRITE(struct octeon_device *oct,
+			  uint64_t addr,
+			  uint64_t val)
+{
+	uint32_t val32;
+
+	writeq(addr, oct->reg_list.pci_win_wr_addr);
+
+	/* The write happens when the LSB is written. So write MSB first. */
+	writel(val >> 32, oct->reg_list.pci_win_wr_data_hi);
+	/* Read the MSB to ensure ordering of writes. */
+	val32 = readl(oct->reg_list.pci_win_wr_data_hi);
+
+	writel(val & 0xffffffff, oct->reg_list.pci_win_wr_data_lo);
+}
+
+int octeon_mem_access_ok(struct octeon_device *oct)
+{
+	uint64_t access_okay = 0;
+
+	/* Check to make sure a DDR interface is enabled */
+	uint64_t lmc0_reset_ctl =
+		OCTEON_PCI_WIN_READ(oct, CN68XX_LMC0_RESET_CTL);
+
+	access_okay = (lmc0_reset_ctl & CN68XX_LMC0_RESET_CTL_DDR3RST_MASK);
+
+	return access_okay ? 0 : 1;
+}
+
+int octeon_wait_for_ddr_init(struct octeon_device *oct, uint32_t *timeout)
+{
+	int ret = 1;
+	uint32_t ms;
+
+	if (!timeout)
+		return ret;
+
+	while (*timeout == 0)
+		schedule_timeout_uninterruptible(HZ / 10);
+
+	for (ms = 0; (ret != 0) && ((*timeout == 0) || (ms <= *timeout));
+	     ms += HZ / 10) {
+		ret = octeon_mem_access_ok(oct);
+
+		/* wait 100 ms */
+		if (ret)
+			schedule_timeout_uninterruptible(HZ / 10);
+	}
+
+	return ret;
+}
+
+/** Get the octeon id assigned to the octeon device passed as argument.
+ *  This function is exported to other modules.
+ *  @param dev - octeon device pointer passed as a void *.
+ *  @return octeon device id
+ */
+int lio_get_device_id(void *dev)
+{
+	struct octeon_device *octeon_dev = (struct octeon_device *)dev;
+	uint32_t i;
+
+	for (i = 0; i < MAX_OCTEON_DEVICES; i++)
+		if (octeon_device[i] == octeon_dev)
+			return octeon_dev->octeon_id;
+	return -1;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
new file mode 100644
index 0000000..d57366d
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -0,0 +1,705 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/*! \file octeon_device.h
+ *  \brief Host Driver: This file defines the octeon device structure.
+ */
+
+#ifndef _OCTEON_DEVICE_H_
+#define  _OCTEON_DEVICE_H_
+
+#define PCI_DMA_64BIT                  0xffffffffffffffffULL
+
+#define CAVIUM_PCI_CACHE_LINE_SIZE     2
+
+/** PCI VendorId Device Id */
+#define  OCTEON_CN68XX_PCIID          0x91177d
+#define  OCTEON_CN66XX_PCIID          0x92177d
+
+/** Driver identifies chips by these Ids, created by clubbing together
+ *  DeviceId+RevisionId; Where Revision Id is not used to distinguish
+ *  between chips, a value of 0 is used for revision id.
+ */
+#define  OCTEON_CN68XX                0x0091
+#define  OCTEON_CN66XX                0x0092
+
+/** Endian-swap modes supported by Octeon. */
+enum octeon_pci_swap_mode {
+	OCTEON_PCI_PASSTHROUGH = 0,
+	OCTEON_PCI_64BIT_SWAP = 1,
+	OCTEON_PCI_32BIT_BYTE_SWAP = 2,
+	OCTEON_PCI_32BIT_LW_SWAP = 3
+};
+
+/*---------------   PCI BAR1 index registers -------------*/
+
+/* BAR1 Mask */
+#define    PCI_BAR1_ENABLE_CA            1
+#define    PCI_BAR1_ENDIAN_MODE          OCTEON_PCI_64BIT_SWAP
+#define    PCI_BAR1_ENTRY_VALID          1
+#define    PCI_BAR1_MASK                 ((PCI_BAR1_ENABLE_CA << 3)   \
+					    | (PCI_BAR1_ENDIAN_MODE << 1) \
+					    | PCI_BAR1_ENTRY_VALID)
+
+#define    INVALID_MAP    0xffff
+
+/** Octeon Device state.
+ *  Each octeon device goes through each of these states
+ *  as it is initialized.
+ */
+#define    OCT_DEV_BEGIN_STATE            0x0
+#define    OCT_DEV_PCI_MAP_DONE           0x1
+#define    OCT_DEV_DISPATCH_INIT_DONE     0x2
+#define    OCT_DEV_INSTR_QUEUE_INIT_DONE  0x3
+#define    OCT_DEV_RESP_LIST_INIT_DONE    0x4
+#define    OCT_DEV_DROQ_INIT_DONE         0x5
+#define    OCT_DEV_HOST_OK                0x6
+#define    OCT_DEV_CORE_OK                0x7
+#define    OCT_DEV_RUNNING                0x8
+#define    OCT_DEV_IN_RESET               0x9
+#define    OCT_DEV_STATE_INVALID          0xa
+
+#define    OCT_DEV_STATES                 OCT_DEV_STATE_INVALID
+
+/** Octeon Device interrupts
+  *  These interrupt bits are set in int_status filed of
+  *  octeon_device structure
+  */
+#define	   OCT_DEV_INTR_DMA0_FORCE	  0x01
+#define	   OCT_DEV_INTR_DMA1_FORCE	  0x02
+#define	   OCT_DEV_INTR_PKT_DATA	  0x04
+
+/*---------------------------DISPATCH LIST-------------------------------*/
+
+/** The dispatch list entry.
+ *  The driver keeps a record of functions registered for each
+ *  response header opcode in this structure. Since the opcode is
+ *  hashed to index into the driver's list, more than one opcode
+ *  can hash to the same entry, in which case the list field points
+ *  to a linked list with the other entries.
+ */
+struct octeon_dispatch {
+	/** List head for this entry */
+	struct list_head list;
+
+	/** The opcode for which the dispatch function & arg should be used */
+	uint16_t opcode;
+
+	/** The function to be called for a packet received by the driver */
+	octeon_dispatch_fn_t dispatch_fn;
+
+	/* The application specified argument to be passed to the above
+	 * function along with the received packet
+	 */
+	void *arg;
+
+};
+
+/** The dispatch list structure. */
+struct octeon_dispatch_list {
+	/** access to dispatch list must be atomic */
+	spinlock_t lock;
+
+	/** Count of dispatch functions currently registered */
+	uint32_t count;
+
+	/** The list of dispatch functions */
+	struct octeon_dispatch *dlist;
+
+};
+
+/*-----------------------  THE OCTEON DEVICE  ---------------------------*/
+
+#define OCT_MEM_REGIONS     3
+/** PCI address space mapping information.
+ *  Each of the 3 address spaces given by BAR0, BAR2 and BAR4 of
+ *  Octeon gets mapped to different physical address spaces in
+ *  the kernel.
+ */
+struct octeon_mmio {
+	/** PCI address to which the BAR is mapped. */
+	uint64_t start;
+
+	/** Length of this PCI address space. */
+	uint32_t len;
+
+	/** Length that has been mapped to phys. address space. */
+	uint32_t mapped_len;
+
+	/** The physical address to which the PCI address space is mapped. */
+	uint8_t __iomem *hw_addr;
+
+	/** Flag indicating the mapping was successful. */
+	uint32_t done;
+
+};
+
+#define   MAX_OCTEON_MAPS    32
+
+/** Map of Octeon core memory address to Octeon BAR1 indexed space. */
+struct octeon_range_table {
+	/** Starting Core address mapped */
+	uint64_t core_addr;
+
+	/** Physical address (of the BAR1 mapped space) corresponding to
+	 * core_addr.
+	 */
+	void __iomem *mapped_addr;
+
+	/** Indicator that the mapping is valid. */
+	uint32_t valid;
+
+};
+
+/* \cond */
+
+struct octeon_io_enable {
+	uint32_t iq;
+
+	uint32_t oq;
+
+	uint32_t iq64B;
+
+};
+
+/* \endcond */
+
+struct octeon_reg_list {
+	uint32_t __iomem *pci_win_wr_addr_hi;
+	uint32_t __iomem *pci_win_wr_addr_lo;
+	uint64_t __iomem *pci_win_wr_addr;
+
+	uint32_t __iomem *pci_win_rd_addr_hi;
+	uint32_t __iomem *pci_win_rd_addr_lo;
+	uint64_t __iomem *pci_win_rd_addr;
+
+	uint32_t __iomem *pci_win_wr_data_hi;
+	uint32_t __iomem *pci_win_wr_data_lo;
+	uint64_t __iomem *pci_win_wr_data;
+
+	uint32_t __iomem *pci_win_rd_data_hi;
+	uint32_t __iomem *pci_win_rd_data_lo;
+	uint64_t __iomem *pci_win_rd_data;
+};
+
+#define OCTEON_CONSOLE_MAX_READ_BYTES 512
+struct octeon_console {
+	uint32_t waiting;
+	uint64_t addr;
+	uint32_t buffer_size;
+	uint64_t input_base_addr;
+	uint64_t output_base_addr;
+	char	 leftover[OCTEON_CONSOLE_MAX_READ_BYTES];
+};
+
+struct octeon_board_info {
+	char	 name[OCT_BOARD_NAME];
+	char	 serial_number[OCT_SERIAL_LEN];
+	uint64_t major;
+	uint64_t minor;
+};
+
+struct octeon_fn_list {
+	void (*setup_iq_regs)(struct octeon_device *, uint32_t);
+	void (*setup_oq_regs)(struct octeon_device *, uint32_t);
+
+	irqreturn_t (*process_interrupt_regs)(void *);
+	int (*soft_reset)(struct octeon_device *);
+	int (*setup_device_regs)(struct octeon_device *);
+	void (*reinit_regs)(struct octeon_device *);
+	void (*bar1_idx_setup)(struct octeon_device *, uint64_t, uint32_t, int);
+	void (*bar1_idx_write)(struct octeon_device *, uint32_t, uint32_t);
+	uint32_t (*bar1_idx_read)(struct octeon_device *, uint32_t);
+	uint32_t (*update_iq_read_idx)(struct octeon_instr_queue *);
+
+	void (*enable_oq_pkt_time_intr)(struct octeon_device *, uint32_t);
+	void (*disable_oq_pkt_time_intr)(struct octeon_device *, uint32_t);
+
+	void (*enable_interrupt)(void *);
+	void (*disable_interrupt)(void *);
+
+	void (*enable_io_queues)(struct octeon_device *);
+	void (*disable_io_queues)(struct octeon_device *);
+};
+
+/* Must be multiple of 8, changing breaks ABI */
+#define CVMX_BOOTMEM_NAME_LEN 128
+
+/* Structure for named memory blocks
+ * Number of descriptors
+ * available can be changed without affecting compatiblity,
+ * but name length changes require a bump in the bootmem
+ * descriptor version
+ * Note: This structure must be naturally 64 bit aligned, as a single
+ * memory image will be used by both 32 and 64 bit programs.
+ */
+struct cvmx_bootmem_named_block_desc {
+	/** Base address of named block */
+	uint64_t base_addr;
+
+	/** Size actually allocated for named block */
+	uint64_t size;
+
+	/** name of named block */
+	char name[CVMX_BOOTMEM_NAME_LEN];
+};
+
+/** Statistics table for octeon device. */
+struct oct_dev_stats {
+	uint64_t interrupts;            /** Number of interrupts received. */
+	uint64_t poll_count;            /** Ran this many times */
+	uint64_t comp_tasklet_count;    /** Ran this many times */
+	uint64_t droq_tasklet_count;    /** Ran this many times */
+};
+
+struct oct_fw_info {
+	uint32_t max_nic_ports;      /** max nic ports for the device */
+	uint64_t app_cap_flags; /** firmware cap flags */
+
+	/** The core application is running in this mode.
+	 * See octeon-drv-opcodes.h for values.
+	 */
+	uint32_t app_mode;
+	char   liquidio_firmware_version[32];
+};
+
+/* wrappers around work structs */
+struct cavium_wk {
+	struct delayed_work work;
+	void *ctxptr;
+	size_t ctxul;
+};
+
+struct cavium_wq {
+	struct workqueue_struct *wq;
+	struct cavium_wk wk;
+};
+
+struct octdev_props_t {
+	/** Number of interfaces detected in this octeon device. */
+	uint32_t ifcount;
+
+	/* Link status sent by core app is stored in a buffer at this
+	 * address.
+	 */
+	struct oct_link_status_resp *ls;
+
+	/* Pointer to pre-allocated soft command used to send link status
+	 * request to Octeon app.
+	 */
+	struct octeon_soft_command *sc_link_status;
+
+	/* Flag to indicate if a link status instruction is currently
+	 * being processed.
+	 */
+	atomic_t ls_flag;
+
+	/* The last tick at which the link status was checked. The
+	 * status is checked every second.
+	 */
+	size_t last_check;
+
+	/* Each interface in the Octeon device has a network
+	 * device pointer (used for OS specific calls).
+	 */
+	struct net_device *netdev[MAX_OCTEON_LINKS];
+};
+
+/** The Octeon device.
+ *  Each Octeon device has this structure to represent all its
+ *  components.
+ */
+struct octeon_device {
+	/** Lock for this Octeon device */
+	spinlock_t oct_lock;
+
+	/** OS dependent PCI device pointer */
+	struct pci_dev *pci_dev;
+
+	/** Chip specific information. */
+	void *chip;
+
+	struct octdev_props_t props;
+
+	/** Octeon Chip type. */
+	uint16_t chip_id;
+	uint16_t rev_id;
+
+	/** This device's id - set by the driver. */
+	uint32_t octeon_id;
+
+	/** This device's PCIe port used for traffic. */
+	uint16_t pcie_port;
+
+	/** The state of this device */
+	atomic_t status;
+
+	/** memory mapped io range */
+	struct octeon_mmio mmio[OCT_MEM_REGIONS];
+
+	struct octeon_reg_list reg_list;
+
+	struct octeon_fn_list fn_list;
+
+	struct octeon_board_info boardinfo;
+
+	atomic_t interrupts;
+
+	atomic_t in_interrupt;
+
+	uint32_t num_iqs;
+
+	/** The input instruction queues */
+	struct octeon_instr_queue *instr_queue[MAX_OCTEON_INSTR_QUEUES];
+
+	/** The doubly-linked list of instruction response */
+	struct octeon_response_list response_list[MAX_RESPONSE_LISTS];
+
+	uint32_t num_oqs;
+
+	/** The DROQ output queues  */
+	struct octeon_droq *droq[MAX_OCTEON_OUTPUT_QUEUES];
+
+	/** A table maintaining maps of core-addr to BAR1 mapped address. */
+	struct octeon_range_table range_table[MAX_OCTEON_MAPS];
+
+	/** Total number of core-address ranges mapped (Upto 32). */
+	uint32_t map_count;
+
+	struct octeon_io_enable io_qmask;
+
+	/** List of dispatch functions */
+	struct octeon_dispatch_list dispatch;
+
+	/** Statistics for this octeon device.
+	 * Does not include IQ,DROQ stats
+	 */
+	struct oct_dev_stats stats;
+
+	/* Interrupt Moderation */
+	struct oct_intrmod_cfg intrmod;
+
+	/** IRQ assigned to this device. */
+	uint32_t irq;
+
+	uint32_t msi_on;
+
+	uint32_t int_status;
+
+	uint64_t droq_intr;
+
+	/** Physical location of the cvmx_bootmem_desc_t in octeon memory */
+	uint64_t bootmem_desc_addr;
+
+	/** Placeholder memory for named blocks.
+	 * Assumes single-threaded access
+	 */
+	struct cvmx_bootmem_named_block_desc bootmem_named_block_desc;
+
+	/** Address of consoles descriptor */
+	uint64_t console_desc_addr;
+
+	/** Number of consoles available. 0 means they are inaccessible */
+	uint32_t num_consoles;
+
+	/* Console caches */
+	struct octeon_console console[MAX_OCTEON_MAPS];
+
+	/* Coprocessor clock rate. */
+	uint64_t coproc_clock_rate;
+
+	/** The core application is running in this mode. See liquidio_common.h
+	 * for values.
+	 */
+	uint32_t app_mode;
+
+	struct oct_fw_info fw_info;
+
+	/** The name given to this device. */
+	char device_name[32];
+
+	/** Application Context */
+	void *app_ctx;
+
+	atomic_t hostfw_hs_state;
+
+	struct cavium_wq link_status_wq;
+
+	struct cavium_wq dma_comp_wq;
+
+	struct cavium_wq check_db_wq[MAX_OCTEON_INSTR_QUEUES];
+
+	struct cavium_wk nic_poll_work;
+
+	struct cavium_wk console_poll_work[MAX_OCTEON_MAPS];
+
+	void *priv;
+};
+
+#define CHIP_FIELD(oct, TYPE, field)             \
+	(((struct octeon_ ## TYPE  *)(oct->chip))->field)
+
+struct oct_intrmod_cmd {
+	struct octeon_device *oct_dev;
+	struct octeon_soft_command *sc;
+	struct oct_intrmod_cfg *cfg;
+};
+
+/*------------------ Function Prototypes ----------------------*/
+
+/** Initialize device list memory */
+void octeon_init_device_list(void);
+
+/** Free memory for Input and Output queue structures for a octeon device */
+void octeon_free_device_mem(struct octeon_device *);
+
+/* Look up a free entry in the octeon_device table and allocate resources
+ * for the octeon_device structure for an octeon device. Called at init
+ * time.
+ */
+struct octeon_device *octeon_allocate_device(uint32_t pci_id,
+					     uint32_t priv_size);
+
+/**  Initialize the driver's dispatch list which is a mix of a hash table
+ *  and a linked list. This is done at driver load time.
+ *  @param octeon_dev - pointer to the octeon device structure.
+ *  @return 0 on success, else -ve error value
+ */
+int octeon_init_dispatch_list(struct octeon_device *octeon_dev);
+
+/**  Delete the driver's dispatch list and all registered entries.
+ * This is done at driver unload time.
+ *  @param octeon_dev - pointer to the octeon device structure.
+ */
+void octeon_delete_dispatch_list(struct octeon_device *octeon_dev);
+
+/** Initialize the core device fields with the info returned by the FW.
+ * @param recv_info - Receive info structure
+ * @param buf       - Receive buffer
+ */
+int octeon_core_drv_init(struct octeon_recv_info *recv_info, void *buf);
+
+/** Gets the dispatch function registered to receive packets with a
+ *  given opcode/subcode.
+ *  @param  octeon_dev  - the octeon device pointer.
+ *  @param  opcode      - the opcode for which the dispatch function
+ *                        is to checked.
+ *  @param  subcode     - the subcode for which the dispatch function
+ *                        is to checked.
+ *
+ *  @return Success: octeon_dispatch_fn_t (dispatch function pointer)
+ *  @return Failure: NULL
+ *
+ *  Looks up the dispatch list to get the dispatch function for a
+ *  given opcode.
+ */
+octeon_dispatch_fn_t
+octeon_get_dispatch(struct octeon_device *octeon_dev, uint16_t opcode,
+		    uint16_t subcode);
+
+/** Get the octeon device pointer.
+ *  @param octeon_id  - The id for which the octeon device pointer is required.
+ *  @return Success: Octeon device pointer.
+ *  @return Failure: NULL.
+ */
+struct octeon_device *lio_get_device(uint32_t octeon_id);
+
+/** Get the octeon id assigned to the octeon device passed as argument.
+ *  This function is exported to other modules.
+ *  @param dev - octeon device pointer passed as a void *.
+ *  @return octeon device id
+ */
+int lio_get_device_id(void *dev);
+
+static inline uint16_t OCTEON_MAJOR_REV(struct octeon_device *oct)
+{
+	uint16_t rev = (oct->rev_id & 0xC) >> 2;
+
+	return (rev == 0) ? 1 : rev;
+}
+
+static inline uint16_t OCTEON_MINOR_REV(struct octeon_device *oct)
+{
+	return oct->rev_id & 0x3;
+}
+
+/** Read windowed register.
+ *  @param  oct   -  pointer to the Octeon device.
+ *  @param  addr  -  Address of the register to read.
+ *
+ *  This routine is called to read from the indirectly accessed
+ *  Octeon registers that are visible through a PCI BAR0 mapped window
+ *  register.
+ *  @return  - 64 bit value read from the register.
+ */
+
+uint64_t OCTEON_PCI_WIN_READ(struct octeon_device *oct, uint64_t addr);
+
+/** Write windowed register.
+ *  @param  oct  -  pointer to the Octeon device.
+ *  @param  addr -  Address of the register to write
+ *  @param  val  -  Value to write
+ *
+ *  This routine is called to write to the indirectly accessed
+ *  Octeon registers that are visible through a PCI BAR0 mapped window
+ *  register.
+ *  @return   Nothing.
+ */
+void OCTEON_PCI_WIN_WRITE(struct octeon_device *oct,
+			  uint64_t addr,
+			  uint64_t val);
+
+/**
+ * Checks if memory access is okay
+ *
+ * @param oct which octeon to send to
+ * @return Zero on success, negative on failure.
+ */
+int octeon_mem_access_ok(struct octeon_device *oct);
+
+/**
+ * Waits for DDR initialization.
+ *
+ * @param oct which octeon to send to
+ * @param timeout_in_ms pointer to how long to wait until DDR is initialized
+ * in ms.
+ *                      If contents are 0, it waits until contents are non-zero
+ *                      before starting to check.
+ * @return Zero on success, negative on failure.
+ */
+int octeon_wait_for_ddr_init(struct octeon_device *oct,
+			     uint32_t *timeout_in_ms);
+
+/**
+ * Wait for u-boot to boot and be waiting for a command.
+ *
+ * @param wait_time_hundredths
+ *               Maximum time to wait
+ *
+ * @return Zero on success, negative on failure.
+ */
+int octeon_wait_for_bootloader(struct octeon_device *oct,
+			       uint32_t wait_time_hundredths);
+
+/**
+ * Initialize console access
+ *
+ * @param oct which octeon initialize
+ * @return Zero on success, negative on failure.
+ */
+int octeon_init_consoles(struct octeon_device *oct);
+
+/**
+ * Adds access to a console to the device.
+ *
+ * @param oct which octeon to add to
+ * @param console_num which console
+ * @return Zero on success, negative on failure.
+ */
+int octeon_add_console(struct octeon_device *oct, uint32_t console_num);
+
+/** write or read from a console */
+int octeon_console_write(struct octeon_device *oct, uint32_t console_num,
+			 char *buffer, uint32_t write_request_size,
+			 uint32_t flags);
+int octeon_console_write_avail(struct octeon_device *oct,
+			       uint32_t console_num);
+
+int octeon_console_read(struct octeon_device *oct, uint32_t console_num,
+			char *buffer, uint32_t buf_size, uint32_t flags);
+int octeon_console_read_avail(struct octeon_device *oct,
+			      uint32_t console_num);
+
+/** Removes all attached consoles. */
+void octeon_remove_consoles(struct octeon_device *oct);
+
+/**
+ * Send a string to u-boot on console 0 as a command.
+ *
+ * @param oct which octeon to send to
+ * @param cmd_str String to send
+ * @param wait_hundredths Time to wait for u-boot to accept the command.
+ *
+ * @return Zero on success, negative on failure.
+ */
+int octeon_console_send_cmd(struct octeon_device *oct, char *cmd_str,
+			    uint32_t wait_hundredths);
+
+/** Parses, validates, and downloads firmware, then boots associated cores.
+ *  @param oct which octeon to download firmware to
+ *  @param data  - The complete firmware file image
+ *  @param size  - The size of the data
+ *
+ *  @return 0 if success.
+ *         -EINVAL if file is incompatible or badly formatted.
+ *         -ENODEV if no handler was found for the application type or an
+ *         invalid octeon id was passed.
+ */
+int octeon_download_firmware(struct octeon_device *oct, const uint8_t *data,
+			     size_t size);
+
+char *lio_get_state_string(atomic_t *state_ptr);
+
+/** Sets up instruction queues for the device
+ *  @param oct which octeon to setup
+ *
+ *  @return 0 if success. 1 if fails
+ */
+int octeon_setup_instr_queues(struct octeon_device *oct);
+
+/** Sets up output queues for the device
+ *  @param oct which octeon to setup
+ *
+ *  @return 0 if success. 1 if fails
+ */
+int octeon_setup_output_queues(struct octeon_device *oct);
+
+int octeon_get_tx_qsize(struct octeon_device *oct, uint32_t q_no);
+
+int octeon_get_rx_qsize(struct octeon_device *oct, uint32_t q_no);
+
+/** Turns off the input and output queues for the device
+ *  @param oct which octeon to disable
+ */
+void octeon_set_io_queues_off(struct octeon_device *oct);
+
+/** Turns on or off the given output queue for the device
+ *  @param oct which octeon to change
+ *  @param q_no which queue
+ *  @param enable 1 to enable, 0 to disable
+ */
+void octeon_set_droq_pkt_op(struct octeon_device *oct,
+			    uint32_t q_no, uint32_t enable);
+
+/** Retrieve the config for the device
+ *  @param oct which octeon
+ *
+ *  @returns pointer to configuration
+ */
+void *oct_get_config_info(struct octeon_device *oct);
+
+/** Gets the octeon device configuration
+ *  @return - pointer to the octeon configuration struture
+ */
+struct octeon_config *octeon_get_conf(struct octeon_device *oct);
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
new file mode 100644
index 0000000..01f0753
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -0,0 +1,1075 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2014 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/pci.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+#include "octeon_mem_ops.h"
+
+/* #define CAVIUM_ONLY_PERF_MODE */
+
+#define     CVM_MIN(d1, d2)           (((d1) < (d2)) ? (d1) : (d2))
+#define     CVM_MAX(d1, d2)           (((d1) > (d2)) ? (d1) : (d2))
+
+struct niclist {
+	struct list_head list;
+	void *ptr;
+};
+
+struct __dispatch {
+	struct list_head list;
+	struct octeon_recv_info *rinfo;
+	octeon_dispatch_fn_t disp_fn;
+};
+
+/** Get the argument that the user set when registering dispatch
+ *  function for a given opcode/subcode.
+ *  @param  octeon_dev - the octeon device pointer.
+ *  @param  opcode     - the opcode for which the dispatch argument
+ *                       is to be checked.
+ *  @param  subcode    - the subcode for which the dispatch argument
+ *                       is to be checked.
+ *  @return  Success: void * (argument to the dispatch function)
+ *  @return  Failure: NULL
+ *
+ */
+static inline void *octeon_get_dispatch_arg(struct octeon_device *octeon_dev,
+					    uint16_t opcode, uint16_t subcode)
+{
+	int idx;
+	struct list_head *dispatch;
+	void *fn_arg = NULL;
+	uint16_t combined_opcode = OPCODE_SUBCODE(opcode, subcode);
+
+	idx = combined_opcode & OCTEON_OPCODE_MASK;
+
+	spin_lock_bh(&octeon_dev->dispatch.lock);
+
+	if (octeon_dev->dispatch.count == 0) {
+		spin_unlock_bh(&octeon_dev->dispatch.lock);
+		return NULL;
+	}
+
+	if (octeon_dev->dispatch.dlist[idx].opcode == combined_opcode) {
+		fn_arg = octeon_dev->dispatch.dlist[idx].arg;
+	} else {
+		list_for_each(dispatch,
+			      &octeon_dev->dispatch.dlist[idx].list) {
+			if (((struct octeon_dispatch *)dispatch)->opcode ==
+			    combined_opcode) {
+				fn_arg = ((struct octeon_dispatch *)
+					  dispatch)->arg;
+				break;
+			}
+		}
+	}
+
+	spin_unlock_bh(&octeon_dev->dispatch.lock);
+	return fn_arg;
+}
+
+uint32_t octeon_droq_check_hw_for_pkts(struct octeon_device *oct,
+				       struct octeon_droq *droq)
+{
+	uint32_t pkt_count = 0;
+
+	pkt_count = readl(droq->pkts_sent_reg);
+	if (pkt_count) {
+		atomic_add(pkt_count, &droq->pkts_pending);
+		writel(pkt_count, droq->pkts_sent_reg);
+	}
+
+	return pkt_count;
+}
+
+static void octeon_droq_compute_max_packet_bufs(struct octeon_droq *droq)
+{
+	uint32_t count = 0;
+
+	/* max_empty_descs is the max. no. of descs that can have no buffers.
+	 * If the empty desc count goes beyond this value, we cannot safely
+	 * read in a 64K packet sent by Octeon
+	 * (64K is max pkt size from Octeon)
+	 */
+	droq->max_empty_descs = 0;
+
+	do {
+		droq->max_empty_descs++;
+		count += droq->buffer_size;
+	} while (count < (64 * 1024));
+
+	droq->max_empty_descs = droq->max_count - droq->max_empty_descs;
+}
+
+static void octeon_droq_reset_indices(struct octeon_droq *droq)
+{
+	droq->read_idx = 0;
+	droq->write_idx = 0;
+	droq->refill_idx = 0;
+	droq->refill_count = 0;
+	atomic_set(&droq->pkts_pending, 0);
+}
+
+static void
+octeon_droq_destroy_ring_buffers(struct octeon_device *oct,
+				 struct octeon_droq *droq)
+{
+	uint32_t i;
+
+	for (i = 0; i < droq->max_count; i++) {
+		if (droq->recv_buf_list[i].buffer) {
+			if (droq->desc_ring) {
+				lio_unmap_ring_info(oct->pci_dev,
+						    (uint64_t)droq->
+						    desc_ring[i].info_ptr,
+						    OCT_DROQ_INFO_SIZE);
+				lio_unmap_ring(oct->pci_dev,
+					       (uint64_t)droq->desc_ring[i].
+					       buffer_ptr,
+					       droq->buffer_size);
+			}
+			recv_buffer_free(droq->recv_buf_list[i].buffer);
+			droq->recv_buf_list[i].buffer = NULL;
+		}
+	}
+
+	octeon_droq_reset_indices(droq);
+}
+
+static int
+octeon_droq_setup_ring_buffers(struct octeon_device *oct,
+			       struct octeon_droq *droq)
+{
+	uint32_t i;
+	void *buf;
+	struct octeon_droq_desc *desc_ring = droq->desc_ring;
+
+	for (i = 0; i < droq->max_count; i++) {
+		buf = recv_buffer_alloc(oct, droq->q_no, droq->buffer_size);
+
+		if (!buf) {
+			lio_dev_err(oct, "%s buffer alloc failed\n",
+				    __func__);
+			return -ENOMEM;
+		}
+
+		droq->recv_buf_list[i].buffer = buf;
+		droq->recv_buf_list[i].data = get_rbd(buf);
+
+		droq->info_list[i].length = 0;
+
+		/* map ring buffers into memory */
+		desc_ring[i].info_ptr = lio_map_ring_info(droq, i);
+		desc_ring[i].buffer_ptr =
+			lio_map_ring(oct->pci_dev,
+				     droq->recv_buf_list[i].buffer,
+				     droq->buffer_size);
+	}
+
+	octeon_droq_reset_indices(droq);
+
+	octeon_droq_compute_max_packet_bufs(droq);
+
+	return 0;
+}
+
+int octeon_delete_droq(struct octeon_device *oct, uint32_t q_no)
+{
+	struct octeon_droq *droq = oct->droq[q_no];
+
+	lio_dev_dbg(oct, "%s[%d]\n", __func__, q_no);
+
+	octeon_droq_destroy_ring_buffers(oct, droq);
+
+	if (droq->recv_buf_list)
+		vfree(droq->recv_buf_list);
+
+	if (droq->info_base_addr)
+		cnnic_free_aligned_dma(oct->pci_dev, droq->info_list,
+				       droq->info_alloc_size,
+				       droq->info_base_addr,
+				       droq->info_list_dma);
+
+	if (droq->desc_ring)
+		pci_free_consistent(oct->pci_dev,
+				    (droq->max_count * OCT_DROQ_DESC_SIZE),
+				    droq->desc_ring,
+				    droq->desc_ring_dma);
+
+	memset(droq, 0, OCT_DROQ_SIZE);
+
+	return 0;
+}
+
+int octeon_init_droq(struct octeon_device *oct,
+		     uint32_t q_no,
+		     uint32_t num_descs,
+		     uint32_t desc_size,
+		     void *app_ctx)
+{
+	struct octeon_droq *droq;
+	uint32_t desc_ring_size = 0;
+	uint32_t c_num_descs = 0, c_buf_size = 0, c_pkts_per_intr =
+		0, c_refill_threshold = 0;
+
+	lio_dev_dbg(oct, "%s[%d]\n", __func__, q_no);
+
+	droq = oct->droq[q_no];
+	memset(droq, 0, OCT_DROQ_SIZE);
+
+	droq->oct_dev = oct;
+	droq->q_no = q_no;
+	if (app_ctx)
+		droq->app_ctx = app_ctx;
+	else
+		droq->app_ctx = (void *)(size_t)q_no;
+
+	c_num_descs = num_descs;
+	c_buf_size = desc_size;
+	if (oct->chip_id == OCTEON_CN66XX) {
+		struct octeon_config *conf6x = CHIP_FIELD(oct, cn6xxx, conf);
+
+		c_pkts_per_intr = (uint32_t)CFG_GET_OQ_PKTS_PER_INTR(conf6x);
+		c_refill_threshold =
+			(uint32_t)CFG_GET_OQ_REFILL_THRESHOLD(conf6x);
+	}
+
+	if (oct->chip_id == OCTEON_CN68XX) {
+		struct octeon_config *conf68 = CHIP_FIELD(oct, cn68xx, conf);
+
+		c_pkts_per_intr = (uint32_t)CFG_GET_OQ_PKTS_PER_INTR(conf68);
+		c_refill_threshold =
+			(uint32_t)CFG_GET_OQ_REFILL_THRESHOLD(conf68);
+	}
+
+	droq->max_count = c_num_descs;
+	droq->buffer_size = c_buf_size;
+
+	desc_ring_size = droq->max_count * OCT_DROQ_DESC_SIZE;
+	droq->desc_ring =
+		pci_alloc_consistent(oct->pci_dev, desc_ring_size,
+				     (dma_addr_t *)&droq->desc_ring_dma);
+
+	if (!droq->desc_ring) {
+		lio_dev_err(oct, "Output queue %d ring alloc failed\n", q_no);
+		return 1;
+	}
+
+	lio_dev_dbg(oct, "droq[%d]: desc_ring: virt: 0x%p, dma: %lx",
+		    q_no, droq->desc_ring, droq->desc_ring_dma);
+	lio_dev_dbg(oct, "droq[%d]: num_desc: %d", q_no, droq->max_count);
+
+	droq->info_list =
+		cnnic_alloc_aligned_dma(oct->pci_dev,
+					(droq->max_count*OCT_DROQ_INFO_SIZE),
+					&droq->info_alloc_size,
+					&droq->info_base_addr,
+					&droq->info_list_dma);
+
+	if (!droq->info_list) {
+		lio_dev_err(oct, "Cannot allocate memory for info list.\n");
+		pci_free_consistent(oct->pci_dev,
+				    (droq->max_count * OCT_DROQ_DESC_SIZE),
+				    droq->desc_ring,
+				    droq->desc_ring_dma);
+		return 1;
+	}
+
+	droq->recv_buf_list = (struct octeon_recv_buffer *)
+			      vmalloc(droq->max_count *
+						OCT_DROQ_RECVBUF_SIZE);
+	if (!droq->recv_buf_list) {
+		lio_dev_err(oct, "Output queue recv buf list alloc failed\n");
+		goto init_droq_fail;
+	}
+
+	if (octeon_droq_setup_ring_buffers(oct, droq))
+		goto init_droq_fail;
+
+	droq->pkts_per_intr = c_pkts_per_intr;
+	droq->refill_threshold = c_refill_threshold;
+
+	lio_dev_dbg(oct, "DROQ INIT: max_empty_descs: %d\n",
+		    droq->max_empty_descs);
+
+	spin_lock_init(&droq->lock);
+
+	INIT_LIST_HEAD(&droq->dispatch_list);
+
+	/* For 56xx Pass1, this function won't be called, so no checks. */
+	oct->fn_list.setup_oq_regs(oct, q_no);
+
+	oct->io_qmask.oq |= (1 << q_no);
+
+	return 0;
+
+init_droq_fail:
+	octeon_delete_droq(oct, q_no);
+	return 1;
+}
+
+/* octeon_create_recv_info
+ * Parameters:
+ *  octeon_dev - pointer to the octeon device structure
+ *  droq       - droq in which the packet arrived.
+ *  buf_cnt    - no. of buffers used by the packet.
+ *  idx        - index in the descriptor for the first buffer in the packet.
+ * Description:
+ *  Allocates a recv_info_t and copies the buffer addresses for packet data
+ *  into the recv_pkt space which starts at an 8B offset from recv_info_t.
+ *  Flags the descriptors for refill later. If available descriptors go
+ *  below the threshold to receive a 64K pkt, new buffers are first allocated
+ *  before the recv_pkt_t is created.
+ *  This routine will be called in interrupt context.
+ * Returns:
+ *  Success: Pointer to recv_info_t
+ *  Failure: NULL.
+ * Locks:
+ *  The droq->lock is held when this routine is called.
+ */
+static inline struct octeon_recv_info *octeon_create_recv_info(
+		struct octeon_device *octeon_dev,
+		struct octeon_droq *droq,
+		uint32_t buf_cnt,
+		uint32_t idx)
+{
+	struct octeon_droq_info *info;
+	struct octeon_recv_pkt *recv_pkt;
+	struct octeon_recv_info *recv_info;
+	uint32_t i, bytes_left;
+
+	info = &droq->info_list[idx];
+
+	recv_info = octeon_alloc_recv_info(sizeof(struct __dispatch));
+	if (!recv_info)
+		return NULL;
+
+	recv_pkt = recv_info->recv_pkt;
+	recv_pkt->rh = info->rh;
+	recv_pkt->length = (uint32_t)info->length;
+	recv_pkt->buffer_count = (uint16_t)buf_cnt;
+	recv_pkt->octeon_id = (uint16_t)octeon_dev->octeon_id;
+
+	i = 0;
+	bytes_left = (uint32_t)info->length;
+
+	while (buf_cnt) {
+		lio_unmap_ring(octeon_dev->pci_dev,
+			       (uint64_t)droq->desc_ring[idx].buffer_ptr,
+			       droq->buffer_size);
+
+		recv_pkt->buffer_size[i] =
+			(bytes_left >=
+			 droq->buffer_size) ? droq->buffer_size : bytes_left;
+
+		recv_pkt->buffer_ptr[i] = droq->recv_buf_list[idx].buffer;
+		droq->recv_buf_list[idx].buffer = NULL;
+
+		INCR_INDEX_BY1(idx, droq->max_count);
+		bytes_left -= droq->buffer_size;
+		i++;
+		buf_cnt--;
+	}
+
+	return recv_info;
+}
+
+/* If we were not able to refill all buffers, try to move around
+ * the buffers that were not dispatched.
+ */
+static inline uint32_t
+octeon_droq_refill_pullup_descs(struct octeon_droq *droq,
+				struct octeon_droq_desc *desc_ring)
+{
+	uint32_t desc_refilled = 0;
+
+	uint32_t refill_index = droq->refill_idx;
+
+	while (refill_index != droq->read_idx) {
+		if (droq->recv_buf_list[refill_index].buffer) {
+			droq->recv_buf_list[droq->refill_idx].buffer =
+				droq->recv_buf_list[refill_index].buffer;
+			droq->recv_buf_list[droq->refill_idx].data =
+				droq->recv_buf_list[refill_index].data;
+			desc_ring[droq->refill_idx].buffer_ptr =
+				desc_ring[refill_index].buffer_ptr;
+			droq->recv_buf_list[refill_index].buffer = NULL;
+			desc_ring[refill_index].buffer_ptr = 0;
+			do {
+				INCR_INDEX_BY1(droq->refill_idx,
+					       droq->max_count);
+				desc_refilled++;
+				droq->refill_count--;
+			} while (droq->recv_buf_list[droq->refill_idx].
+				 buffer);
+		}
+		INCR_INDEX_BY1(refill_index, droq->max_count);
+	}                       /* while */
+	return desc_refilled;
+}
+
+/* octeon_droq_refill
+ * Parameters:
+ *  droq       - droq in which descriptors require new buffers.
+ * Description:
+ *  Called during normal DROQ processing in interrupt mode or by the poll
+ *  thread to refill the descriptors from which buffers were dispatched
+ *  to upper layers. Attempts to allocate new buffers. If that fails, moves
+ *  up buffers (that were not dispatched) to form a contiguous ring.
+ * Returns:
+ *  No of descriptors refilled.
+ * Locks:
+ *  This routine is called with droq->lock held.
+ */
+static uint32_t
+octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
+{
+	struct octeon_droq_desc *desc_ring;
+	void *buf = NULL;
+	uint8_t *data;
+	uint32_t desc_refilled = 0;
+
+	desc_ring = droq->desc_ring;
+
+	while (droq->refill_count && (desc_refilled < droq->max_count)) {
+		/* If a valid buffer exists (happens if there is no dispatch),
+		 * reuse
+		 * the buffer, else allocate.
+		 */
+		if (!droq->recv_buf_list[droq->refill_idx].buffer) {
+			buf = recv_buffer_alloc(octeon_dev, droq->q_no,
+						droq->buffer_size);
+			/* If a buffer could not be allocated, no point in
+			 * continuing
+			 */
+			if (!buf)
+				break;
+			droq->recv_buf_list[droq->refill_idx].buffer =
+				buf;
+			data = get_rbd(buf);
+		} else {
+			data = get_rbd(droq->recv_buf_list
+				       [droq->refill_idx].buffer);
+		}
+
+		droq->recv_buf_list[droq->refill_idx].data = data;
+
+		desc_ring[droq->refill_idx].buffer_ptr =
+			lio_map_ring(octeon_dev->pci_dev,
+				     droq->recv_buf_list[droq->
+				     refill_idx].buffer,
+				     droq->buffer_size);
+
+		/* Reset any previous values in the length field. */
+		droq->info_list[droq->refill_idx].length = 0;
+
+		INCR_INDEX_BY1(droq->refill_idx, droq->max_count);
+		desc_refilled++;
+		droq->refill_count--;
+	}
+
+	if (droq->refill_count)
+		desc_refilled +=
+			octeon_droq_refill_pullup_descs(droq, desc_ring);
+
+	/* if droq->refill_count
+	 * The refill count would not change in pass two. We only moved buffers
+	 * to close the gap in the ring, but we would still have the same no. of
+	 * buffers to refill.
+	 */
+	return desc_refilled;
+}
+
+static inline uint32_t
+octeon_droq_get_bufcount(uint32_t buf_size, uint32_t total_len)
+{
+	uint32_t buf_cnt = 0;
+
+	while (total_len > (buf_size * buf_cnt))
+		buf_cnt++;
+	return buf_cnt;
+}
+
+static int
+octeon_droq_dispatch_pkt(struct octeon_device *oct,
+			 struct octeon_droq *droq,
+			 union octeon_rh *rh,
+			 struct octeon_droq_info *info)
+{
+	uint32_t cnt;
+	octeon_dispatch_fn_t disp_fn;
+	struct octeon_recv_info *rinfo;
+
+	cnt = octeon_droq_get_bufcount(droq->buffer_size,
+				       (uint32_t)info->length);
+
+	disp_fn = octeon_get_dispatch(oct, (uint16_t)rh->r.opcode,
+				      (uint16_t)rh->r.subcode);
+	if (disp_fn) {
+		rinfo = octeon_create_recv_info(oct, droq, cnt, droq->read_idx);
+		if (rinfo) {
+			struct __dispatch *rdisp = rinfo->rsvd;
+
+			rdisp->rinfo = rinfo;
+			rdisp->disp_fn = disp_fn;
+			rinfo->recv_pkt->rh = *rh;
+			list_add_tail(&rdisp->list,
+				      &droq->dispatch_list);
+		} else {
+			droq->stats.dropped_nomem++;
+		}
+	} else {
+		lio_dev_err(oct, "DROQ: No dispatch function\n");
+		droq->stats.dropped_nodispatch++;
+	}                       /* else (dispatch_fn ... */
+
+	return cnt;
+}
+
+static inline void octeon_droq_drop_packets(struct octeon_device *oct,
+					    struct octeon_droq *droq,
+					    uint32_t cnt)
+{
+	uint32_t i = 0, buf_cnt;
+	struct octeon_droq_info *info;
+
+	for (i = 0; i < cnt; i++) {
+		info = &droq->info_list[droq->read_idx];
+		octeon_swap_8B_data((uint64_t *)info, 2);
+
+		if (info->length) {
+			info->length -= OCT_RH_SIZE;
+			droq->stats.bytes_received += info->length;
+			buf_cnt = octeon_droq_get_bufcount(droq->buffer_size,
+							   (uint32_t)
+							   info->length);
+		} else {
+			lio_dev_err(oct, "DROQ: In drop: pkt with len 0\n");
+			buf_cnt = 1;
+		}
+
+		INCR_INDEX(droq->read_idx, buf_cnt, droq->max_count);
+		droq->refill_count += buf_cnt;
+	}
+}
+
+static uint32_t
+octeon_droq_fast_process_packets(struct octeon_device *oct,
+				 struct octeon_droq *droq,
+				 uint32_t pkts_to_process)
+{
+	struct octeon_droq_info *info;
+	union octeon_rh *rh;
+	uint32_t pkt, total_len = 0, pkt_count, bufs_used = 0;
+
+	pkt_count = pkts_to_process;
+
+	for (pkt = 0; pkt < pkt_count; pkt++) {
+		uint32_t pkt_len = 0;
+		struct sk_buff *nicbuf = NULL;
+
+		info = &droq->info_list[droq->read_idx];
+
+		octeon_swap_8B_data((uint64_t *)info, 2);
+
+		if (!info->length) {
+			lio_dev_err(oct,
+				    "DROQ[%d] idx: %d len:0, pkt_cnt: %d\n",
+				    droq->q_no, droq->read_idx, pkt_count);
+			lio_print_hex_dump_bytes((uint8_t *)info,
+						 OCT_DROQ_INFO_SIZE);
+			pkt++;
+
+			break;
+		}
+
+		/* Len of resp hdr in included in the received data len. */
+		info->length -= OCT_RH_SIZE;
+		rh = &info->rh;
+
+		total_len += (uint32_t)info->length;
+
+		if (info->length <= droq->buffer_size) {
+			lio_unmap_ring(oct->pci_dev, (uint64_t)
+				       droq->desc_ring[droq->read_idx].
+				       buffer_ptr, droq->buffer_size);
+			pkt_len = (uint32_t)info->length;
+			nicbuf = droq->recv_buf_list[droq->read_idx].buffer;
+			droq->recv_buf_list[droq->read_idx].buffer = NULL;
+			INCR_INDEX_BY1(droq->read_idx, droq->max_count);
+			skb_put(nicbuf, pkt_len);
+			bufs_used++;
+		} else {
+			nicbuf = octeon_fast_packet_alloc(oct, droq,
+							  droq->q_no,
+							  (uint32_t)
+							  info->length);
+			pkt_len = 0;
+			/* nicbuf allocation can fail. We'll handle it inside
+			 * the loop.
+			 */
+			while (pkt_len < info->length) {
+				int copy_len;
+
+				copy_len = ((pkt_len + droq->buffer_size) >
+					    info->length) ?
+					    ((uint32_t)info->length - pkt_len) :
+					    droq->buffer_size;
+
+				if (nicbuf) {
+					lio_unmap_ring(oct->pci_dev,
+						       (uint64_t)droq->desc_ring
+						       [droq->read_idx].
+						       buffer_ptr,
+						       droq->buffer_size);
+					octeon_fast_packet_next(droq, nicbuf,
+								copy_len,
+								droq->read_idx);
+				}
+
+				pkt_len += copy_len;
+				INCR_INDEX_BY1(droq->read_idx, droq->max_count);
+				bufs_used++;
+			}
+		}
+
+		if (nicbuf) {
+			if (droq->ops.fptr)
+				droq->ops.fptr(oct->octeon_id, nicbuf, pkt_len,
+					       rh, &droq->napi);
+			else
+				recv_buffer_free(nicbuf);
+		}
+
+	}                       /* for ( each packet )... */
+
+	/* Increment refill_count by the number of buffers processed. */
+	droq->refill_count += bufs_used;
+	droq->stats.pkts_received += pkt;
+	droq->stats.bytes_received += total_len;
+
+	if ((droq->ops.drop_on_max) && (pkts_to_process - pkt)) {
+		octeon_droq_drop_packets(oct, droq, (pkts_to_process - pkt));
+		droq->stats.dropped_toomany += (pkts_to_process - pkt);
+		return pkts_to_process;
+	}
+
+	return pkt;
+}
+
+static uint32_t
+octeon_droq_slow_process_packets(struct octeon_device *oct,
+				 struct octeon_droq *droq,
+				 uint32_t pkts_to_process)
+{
+	union octeon_rh *rh;
+	uint32_t desc_processed = 0;
+	struct octeon_droq_info *info;
+	uint32_t pkt, pkt_count, buf_cnt = 0;
+
+	if (pkts_to_process > droq->pkts_per_intr)
+		pkt_count = droq->pkts_per_intr;
+	else
+		pkt_count = pkts_to_process;
+
+	for (pkt = 0; pkt < pkt_count; pkt++) {
+		info = &droq->info_list[droq->read_idx];
+		rh = (union octeon_rh *)&info->rh;
+
+		octeon_swap_8B_data((uint64_t *)info, 2);
+
+		if (!info->length) {
+			lio_dev_err(oct,
+				    "DROQ[idx: %d]: len:%llx, pkt_cnt: %d\n",
+				    droq->read_idx,
+				    CVM_CAST64(info->length),
+				    pkt_count);
+			lio_print_hex_dump_bytes((uint8_t *)info,
+						 OCT_DROQ_INFO_SIZE);
+
+			pkt++;
+			break;
+		}
+
+		/* Len of resp hdr in included in the received data len. */
+		info->length -= OCT_RH_SIZE;
+		droq->stats.bytes_received += info->length;
+
+		buf_cnt = octeon_droq_dispatch_pkt(oct, droq, rh, info);
+
+		INCR_INDEX(droq->read_idx, buf_cnt, droq->max_count);
+		droq->refill_count += buf_cnt;
+		desc_processed += buf_cnt;
+	}                       /* for ( each packet )... */
+
+	droq->stats.pkts_received += pkt;
+
+	if ((droq->ops.drop_on_max) && (pkts_to_process - pkt)) {
+		octeon_droq_drop_packets(oct, droq, (pkts_to_process - pkt));
+		droq->stats.dropped_toomany += (pkts_to_process - pkt);
+		return pkts_to_process;
+	}
+
+	return pkt;
+}
+
+int
+octeon_droq_process_packets(struct octeon_device *oct, struct octeon_droq *droq)
+{
+	uint32_t pkt_count = 0, pkts_processed = 0, desc_refilled = 0;
+	struct list_head *tmp, *tmp2;
+
+	pkt_count = atomic_read(&droq->pkts_pending);
+	if (!pkt_count)
+		return 0;
+
+	/* Grab the lock */
+	spin_lock(&droq->lock);
+
+	if (droq->fastpath_on)
+		pkts_processed =
+			octeon_droq_fast_process_packets(oct, droq, pkt_count);
+	else
+		pkts_processed =
+			octeon_droq_slow_process_packets(oct, droq, pkt_count);
+	atomic_sub(pkts_processed, &droq->pkts_pending);
+
+	if (droq->refill_count >= droq->refill_threshold) {
+		desc_refilled = octeon_droq_refill(oct, droq);
+
+		/* Flush the droq descriptor data to memory to be sure
+		 * that when we update the credits the data in memory
+		 * is accurate.
+		 */
+		wmb();
+		writel((desc_refilled), droq->pkts_credit_reg);
+		/* make sure mmio write has completed */
+		mmiowb();
+	}
+
+	/* Release the spin lock */
+	spin_unlock(&droq->lock);
+
+	list_for_each_safe(tmp, tmp2, &droq->dispatch_list) {
+		struct __dispatch *rdisp = (struct __dispatch *)tmp;
+
+		list_del(tmp);
+		rdisp->disp_fn(rdisp->rinfo,
+			       octeon_get_dispatch_arg
+			       (oct,
+				(uint16_t)rdisp->rinfo->recv_pkt->rh.r.opcode,
+				(uint16_t)
+				rdisp->rinfo->recv_pkt->rh.r.subcode));
+	}
+
+	/* If there are packets pending. schedule tasklet again */
+	if (atomic_read(&droq->pkts_pending))
+		return 1;
+
+	return 0;
+}
+
+/**
+ * Utility function to poll for packets. check_hw_for_packets must be
+ * called before calling this routine.
+ */
+
+static int
+octeon_droq_process_poll_pkts(struct octeon_device *oct,
+			      struct octeon_droq *droq, uint32_t budget)
+{
+	uint32_t pkts_available = 0, pkts_processed = 0, total_pkts_processed =
+		0;
+
+	if (budget > droq->max_count)
+		budget = droq->max_count;
+
+	spin_lock(&droq->lock);
+
+	pkts_available =
+		CVM_MIN(budget, (uint32_t)(atomic_read(&droq->pkts_pending)));
+
+process_some_more:
+	pkts_processed =
+		octeon_droq_fast_process_packets(oct, droq, pkts_available);
+	atomic_sub(pkts_processed, &droq->pkts_pending);
+	total_pkts_processed += pkts_processed;
+
+	if (total_pkts_processed < budget) {
+		octeon_droq_check_hw_for_pkts(oct, droq);
+		if (atomic_read(&droq->pkts_pending)) {
+			pkts_available =
+				CVM_MIN((budget - total_pkts_processed),
+					(uint32_t)
+					(atomic_read(&droq->pkts_pending)));
+			goto process_some_more;
+		}
+	}
+
+	if (droq->refill_count >= droq->refill_threshold) {
+		int desc_refilled = octeon_droq_refill(oct, droq);
+
+		/* Flush the droq descriptor data to memory to be sure
+		 * that when we update the credits the data in memory
+		 * is accurate.
+		 */
+		wmb();
+		writel((desc_refilled), droq->pkts_credit_reg);
+		/* make sure mmio write completes */
+		mmiowb();
+	}
+
+	spin_unlock(&droq->lock);
+
+	return total_pkts_processed;
+}
+
+int
+octeon_process_droq_poll_cmd(struct octeon_device *oct, uint32_t q_no, int cmd,
+			     uint32_t arg)
+{
+	struct octeon_droq *droq;
+	struct octeon_config *oct_cfg = NULL;
+
+	oct_cfg = octeon_get_conf(oct);
+
+	if (!oct_cfg)
+		return -EINVAL;
+
+	if (q_no >= CFG_GET_OQ_MAX_Q(oct_cfg)) {
+		lio_dev_err(oct, "%s: droq id (%d) exceeds MAX (%d)\n",
+			    __func__, q_no, (oct->num_oqs - 1));
+		return -EINVAL;
+	}
+
+	droq = oct->droq[q_no];
+
+	if (cmd == POLL_EVENT_PROCESS_PKTS)
+		return octeon_droq_process_poll_pkts(oct, droq, arg);
+
+	if (cmd == POLL_EVENT_ENABLE_INTR) {
+		uint32_t value;
+		unsigned long flags;
+
+		/* Enable Pkt Interrupt */
+		switch (oct->chip_id) {
+		case OCTEON_CN66XX: {
+			struct octeon_cn6xxx *cn6xxx =
+				(struct octeon_cn6xxx *)oct->chip;
+			spin_lock_irqsave
+				(&cn6xxx->lock_for_droq_int_enb_reg, flags);
+			value =
+				octeon_read_csr(oct,
+						CN66XX_SLI_PKT_TIME_INT_ENB);
+			value |= (1 << q_no);
+			octeon_write_csr(oct,
+					 CN66XX_SLI_PKT_TIME_INT_ENB,
+					 value);
+			value =
+				octeon_read_csr(oct,
+						CN66XX_SLI_PKT_CNT_INT_ENB);
+			value |= (1 << q_no);
+			octeon_write_csr(oct,
+					 CN66XX_SLI_PKT_CNT_INT_ENB,
+					 value);
+
+			/* don't bother flushing the enables */
+
+			spin_unlock_irqrestore
+				(&cn6xxx->lock_for_droq_int_enb_reg, flags);
+			return 0;
+		}
+		break;
+
+		case OCTEON_CN68XX: {
+			struct octeon_cn68xx *cn68xx =
+				(struct octeon_cn68xx *)oct->chip;
+			spin_lock_irqsave
+				(&cn68xx->lock_for_droq_int_enb_reg, flags);
+			value = octeon_read_csr(oct,
+						CN68XX_SLI_PKT_TIME_INT_ENB);
+			value |= (1 << q_no);
+			octeon_write_csr(oct,
+					 CN68XX_SLI_PKT_TIME_INT_ENB,
+					 value);
+			value = octeon_read_csr(oct,
+						CN68XX_SLI_PKT_CNT_INT_ENB);
+			value |= (1 << q_no);
+			octeon_write_csr(oct,
+					 CN68XX_SLI_PKT_CNT_INT_ENB,
+					 value);
+
+			/* don't bother flushing the enables */
+
+			spin_unlock_irqrestore
+				(&cn68xx->lock_for_droq_int_enb_reg, flags);
+			return 0;
+		}
+		break;
+		}
+
+		return 0;
+	}
+
+	lio_dev_err(oct, "%s Unknown command: %d\n", __func__, cmd);
+	return -EINVAL;
+}
+
+int octeon_register_droq_ops(struct octeon_device *oct, uint32_t q_no,
+			     struct octeon_droq_ops *ops)
+{
+	struct octeon_droq *droq;
+	unsigned long flags;
+	struct octeon_config *oct_cfg = NULL;
+
+	oct_cfg = octeon_get_conf(oct);
+
+	if (!oct_cfg)
+		return -EINVAL;
+
+	if (!(ops)) {
+		lio_dev_err(oct, "%s: droq_ops pointer is NULL\n",
+			    __func__);
+		return -EINVAL;
+	}
+
+	if (q_no >= CFG_GET_OQ_MAX_Q(oct_cfg)) {
+		lio_dev_err(oct, "%s: droq id (%d) exceeds MAX (%d)\n",
+			    __func__, q_no, (oct->num_oqs - 1));
+		return -EINVAL;
+	}
+
+	droq = oct->droq[q_no];
+
+	spin_lock_irqsave(&droq->lock, flags);
+
+	memcpy(&droq->ops, ops, sizeof(struct octeon_droq_ops));
+
+	if (droq->ops.fptr)
+		droq->fastpath_on = 1;
+
+	spin_unlock_irqrestore(&droq->lock, flags);
+
+	return 0;
+}
+
+int octeon_unregister_droq_ops(struct octeon_device *oct, uint32_t q_no)
+{
+	unsigned long flags;
+	struct octeon_droq *droq;
+	struct octeon_config *oct_cfg = NULL;
+
+	oct_cfg = octeon_get_conf(oct);
+
+	if (!oct_cfg)
+		return -EINVAL;
+
+	if (q_no >= CFG_GET_OQ_MAX_Q(oct_cfg)) {
+		lio_dev_err(oct, "%s: droq id (%d) exceeds MAX (%d)\n",
+			    __func__, q_no, oct->num_oqs - 1);
+		return -EINVAL;
+	}
+
+	droq = oct->droq[q_no];
+
+	if (!droq) {
+		lio_dev_info(oct, "Droq id (%d) not available.\n", q_no);
+		return 0;
+	}
+
+	spin_lock_irqsave(&droq->lock, flags);
+
+	droq->fastpath_on = 0;
+	droq->ops.fptr = NULL;
+	droq->ops.drop_on_max = 0;
+
+	spin_unlock_irqrestore(&droq->lock, flags);
+
+	return 0;
+}
+
+int octeon_create_droq(struct octeon_device *oct,
+		       uint32_t q_no, uint32_t num_descs,
+		       uint32_t desc_size, void *app_ctx)
+{
+	struct octeon_droq *droq;
+
+	if (oct->droq[q_no]) {
+		int32_t ret = 0;
+
+		if (q_no == 0) {
+			ret = 1;
+		} else {
+			lio_dev_err(oct,
+				    "Droq already in use. Cannot create droq %d again\n",
+				    q_no);
+			ret = -1;
+		}
+		return ret;
+	}
+
+	/* Allocate the DS for the new droq. */
+	droq = vmalloc(sizeof(*droq));
+	if (!droq)
+		goto create_droq_fail;
+	memset(droq, 0, sizeof(struct octeon_droq));
+
+	/*Disable the pkt o/p for this Q  */
+	octeon_set_droq_pkt_op(oct, q_no, 0);
+	oct->droq[q_no] = droq;
+
+	/* Initialize the Droq */
+	octeon_init_droq(oct, q_no, num_descs, desc_size, app_ctx);
+
+	oct->num_oqs++;
+
+	lio_dev_dbg(oct, "%s: Total number of OQ: %d\n", __func__,
+		    oct->num_oqs);
+
+	/* Global Droq register settings */
+
+	/* As of now not required, as setting are done for all 32 Droqs at
+	 * the same time.
+	 */
+	return 0;
+
+create_droq_fail:
+	octeon_delete_droq(oct, q_no);
+	return -1;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
new file mode 100644
index 0000000..39729c3
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -0,0 +1,433 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+
+/*!  \file  octeon_droq.h
+ *   \brief Host Driver: Implementation of Octeon Output queues.
+ */
+
+#ifndef __OCTEON_DROQ_H__
+#define __OCTEON_DROQ_H__
+
+/** Octeon descriptor format.
+ *  The descriptor ring is made of descriptors which have 2 64-bit values:
+ *  -# Physical (bus) address of the data buffer.
+ *  -# Physical (bus) address of a octeon_droq_info structure.
+ *  The Octeon device DMA's incoming packets and its information at the address
+ *  given by these descriptor fields.
+ */
+struct octeon_droq_desc {
+	/** The buffer pointer */
+	uint64_t buffer_ptr;
+
+	/** The Info pointer */
+	uint64_t info_ptr;
+
+};
+
+#define OCT_DROQ_DESC_SIZE    (sizeof(struct octeon_droq_desc))
+
+/** Information about packet DMA'ed by Octeon.
+ *  The format of the information available at Info Pointer after Octeon
+ *  has posted a packet. Not all descriptors have valid information. Only
+ *  the Info field of the first descriptor for a packet has information
+ *  about the packet.
+ */
+struct octeon_droq_info {
+	/** The Output Receive Header. */
+	union octeon_rh rh;
+
+	/** The Length of the packet. */
+	uint64_t length;
+
+};
+
+#define OCT_DROQ_INFO_SIZE   (sizeof(struct octeon_droq_info))
+
+/** Pointer to data buffer.
+ *  Driver keeps a pointer to the data buffer that it made available to
+ *  the Octeon device. Since the descriptor ring keeps physical (bus)
+ *  addresses, this field is required for the driver to keep track of
+ *  the virtual address pointers. The fields are operated by
+ *  OS-dependent routines.
+*/
+struct octeon_recv_buffer {
+	/** Pointer to the packet buffer. Hidden by void * */
+	void *buffer;
+
+	/** Pointer to the data in the packet buffer.
+	 * This could be different or same as the buffer pointer depending
+	 * on the OS for which the code is compiled.
+	 */
+	uint8_t *data;
+
+};
+
+#define OCT_DROQ_RECVBUF_SIZE    (sizeof(struct octeon_recv_buffer))
+
+/** Output Queue statistics. Each output queue has four stats fields. */
+struct oct_droq_stats {
+	/** Number of packets received in this queue. */
+	uint64_t pkts_received;
+
+	/** Bytes received by this queue. */
+	uint64_t bytes_received;
+
+	/** Packets dropped due to no dispatch function. */
+	uint64_t dropped_nodispatch;
+
+	/** Packets dropped due to no memory available. */
+	uint64_t dropped_nomem;
+
+	/** Packets dropped due to large number of pkts to process. */
+	uint64_t dropped_toomany;
+
+	/** Number of packets  sent to stack from this queue. */
+	uint64_t rx_pkts_received;
+
+	/** Number of Bytes sent to stack from this queue. */
+	uint64_t rx_bytes_received;
+
+	/** Num of Packets dropped due to receive path failures. */
+	uint64_t rx_dropped;
+};
+
+#define POLL_EVENT_INTR_ARRIVED  1
+#define POLL_EVENT_PROCESS_PKTS  2
+#define POLL_EVENT_ENABLE_INTR   3
+
+/* The maximum number of buffers that can be dispatched from the
+ * output/dma queue. Set to 64 assuming 1K buffers in DROQ and the fact that
+ * max packet size from DROQ is 64K.
+ */
+#define    MAX_RECV_BUFS    64
+
+/** Receive Packet format used when dispatching output queue packets
+ *  with non-raw opcodes.
+ *  The received packet will be sent to the upper layers using this
+ *  structure which is passed as a parameter to the dispatch function
+ */
+struct octeon_recv_pkt {
+	/**  Number of buffers in this received packet */
+	uint16_t buffer_count;
+
+	/** Id of the device that is sending the packet up */
+	uint16_t octeon_id;
+
+	/** Length of data in the packet buffer */
+	uint32_t length;
+
+	/** The receive header */
+	union octeon_rh rh;
+
+	/** Pointer to the OS-specific packet buffer */
+	void *buffer_ptr[MAX_RECV_BUFS];
+
+	/** Size of the buffers pointed to by ptr's in buffer_ptr */
+	uint32_t buffer_size[MAX_RECV_BUFS];
+
+};
+
+#define OCT_RECV_PKT_SIZE    (sizeof(struct octeon_recv_pkt))
+
+/** The first parameter of a dispatch function.
+ *  For a raw mode opcode, the driver dispatches with the device
+ *  pointer in this structure.
+ *  For non-raw mode opcode, the driver dispatches the recv_pkt
+ *  created to contain the buffers with data received from Octeon.
+ *  ---------------------
+ *  |     *recv_pkt ----|---
+ *  |-------------------|   |
+ *  | 0 or more bytes   |   |
+ *  | reserved by driver|   |
+ *  |-------------------|<-/
+ *  | octeon_recv_pkt   |
+ *  |                   |
+ *  |___________________|
+ */
+struct octeon_recv_info {
+	void *rsvd;
+	struct octeon_recv_pkt *recv_pkt;
+};
+
+#define  OCT_RECV_INFO_SIZE    (sizeof(struct octeon_recv_info))
+
+/** Allocate a recv_info structure. The recv_pkt pointer in the recv_info
+ *  structure is filled in before this call returns.
+ *  @param extra_bytes - extra bytes to be allocated at the end of the recv info
+ *                       structure.
+ *  @return - pointer to a newly allocated recv_info structure.
+ */
+static inline struct octeon_recv_info *octeon_alloc_recv_info(int extra_bytes)
+{
+	struct octeon_recv_info *recv_info;
+	uint8_t *buf;
+
+	buf = kmalloc(OCT_RECV_PKT_SIZE + OCT_RECV_INFO_SIZE +
+		      extra_bytes, GFP_ATOMIC);
+	if (!buf)
+		return NULL;
+
+	recv_info = (struct octeon_recv_info *)buf;
+	recv_info->recv_pkt =
+		(struct octeon_recv_pkt *) (buf + OCT_RECV_INFO_SIZE);
+	recv_info->rsvd = NULL;
+	if (extra_bytes)
+		recv_info->rsvd = buf + OCT_RECV_INFO_SIZE + OCT_RECV_PKT_SIZE;
+
+	return recv_info;
+}
+
+/** Free a recv_info structure.
+ *  @param recv_info - Pointer to receive_info to be freed
+ */
+static inline void octeon_free_recv_info(struct octeon_recv_info *recv_info)
+{
+	kfree(recv_info);
+}
+
+typedef int (*octeon_dispatch_fn_t)(struct octeon_recv_info *, void *);
+
+/** Used by NIC module to register packet handler and to get device
+ * information for each octeon device.
+ */
+struct octeon_droq_ops {
+	/** This registered function will be called by the driver with
+	 *  the octeon id, pointer to buffer from droq and length of
+	 *  data in the buffer. The receive header gives the port
+	 *  number to the caller.  Function pointer is set by caller.
+	 */
+	void (*fptr)(uint32_t, void *, uint32_t, union octeon_rh *, void *);
+
+	/* This function will be called by the driver for all NAPI related
+	 * events. The first param is the octeon id. The second param is the
+	 * output queue number. The third is the NAPI event that occurred.
+	 */
+	void (*napi_fn)(void *);
+
+	uint32_t poll_mode;
+
+	/** Flag indicating if the DROQ handler should drop packets that
+	 *  it cannot handle in one iteration. Set by caller.
+	 */
+	uint32_t drop_on_max;
+
+	uint16_t op_mask;
+
+	uint16_t op_major;
+};
+
+/** The Descriptor Ring Output Queue structure.
+ *  This structure has all the information required to implement a
+ *  Octeon DROQ.
+ */
+struct octeon_droq {
+	/** A spinlock to protect access to this ring. */
+	spinlock_t lock;
+
+	uint32_t q_no;
+
+	uint32_t fastpath_on;
+
+	struct octeon_droq_ops ops;
+
+	struct octeon_device *oct_dev;
+
+	/** The 8B aligned descriptor ring starts at this address. */
+	struct octeon_droq_desc *desc_ring;
+
+	/** Index in the ring where the driver should read the next packet */
+	uint32_t read_idx;
+
+	/** Index in the ring where Octeon will write the next packet */
+	uint32_t write_idx;
+
+	/** Index in the ring where the driver will refill the descriptor's
+	 * buffer
+	 */
+	uint32_t refill_idx;
+
+	/** Packets pending to be processed - tasklet implementation */
+	atomic_t pkts_pending;
+
+	/** Number of  descriptors in this ring. */
+	uint32_t max_count;
+
+	/** The number of descriptors pending refill. */
+	uint32_t refill_count;
+
+	uint32_t pkts_per_intr;
+	uint32_t refill_threshold;
+
+	/** The max number of descriptors in DROQ without a buffer.
+	 * This field is used to keep track of empty space threshold. If the
+	 * refill_count reaches this value, the DROQ cannot accept a max-sized
+	 * (64K) packet.
+	 */
+	uint32_t max_empty_descs;
+
+	/** The 8B aligned info ptrs begin from this address. */
+	struct octeon_droq_info *info_list;
+
+	/** The receive buffer list. This list has the virtual addresses of the
+	 * buffers.
+	 */
+	struct octeon_recv_buffer *recv_buf_list;
+
+	/** The size of each buffer pointed by the buffer pointer. */
+	uint32_t buffer_size;
+
+	/** Pointer to the mapped packet credit register.
+	 * Host writes number of info/buffer ptrs available to this register
+	 */
+	void  __iomem *pkts_credit_reg;
+
+	/** Pointer to the mapped packet sent register.
+	 * Octeon writes the number of packets DMA'ed to host memory
+	 * in this register.
+	 */
+	void __iomem *pkts_sent_reg;
+
+	struct list_head dispatch_list;
+
+	/** Statistics for this DROQ. */
+	struct oct_droq_stats stats;
+
+	/** DMA mapped address of the DROQ descriptor ring. */
+	size_t desc_ring_dma;
+
+	/** Info ptr list are allocated at this virtual address. */
+	size_t info_base_addr;
+
+	/** DMA mapped address of the info list */
+	size_t info_list_dma;
+
+	/** Allocated size of info list. */
+	uint32_t info_alloc_size;
+
+	/** application context */
+	void *app_ctx;
+
+	struct napi_struct napi;
+
+	uint32_t cpu_id;
+
+	struct call_single_data csd;
+};
+
+#define OCT_DROQ_SIZE   (sizeof(struct octeon_droq))
+
+/**
+ *  Allocates space for the descriptor ring for the droq and sets the
+ *   base addr, num desc etc in Octeon registers.
+ *
+ * @param  oct_dev    - pointer to the octeon device structure
+ * @param  q_no       - droq no. ranges from 0 - 3.
+ * @param app_ctx     - pointer to application context
+ * @return Success: 0    Failure: 1
+*/
+int octeon_init_droq(struct octeon_device *oct_dev,
+		     uint32_t q_no,
+		     uint32_t num_descs,
+		     uint32_t desc_size,
+		     void *app_ctx);
+
+/**
+ *  Frees the space for descriptor ring for the droq.
+ *
+ *  @param oct_dev - pointer to the octeon device structure
+ *  @param q_no    - droq no. ranges from 0 - 3.
+ *  @return:    Success: 0    Failure: 1
+*/
+int octeon_delete_droq(struct octeon_device *oct_dev, uint32_t q_no);
+
+/** Register a change in droq operations. The ops field has a pointer to a
+ * function which will called by the DROQ handler for all packets arriving
+ * on output queues given by q_no irrespective of the type of packet.
+ * The ops field also has a flag which if set tells the DROQ handler to
+ * drop packets if it receives more than what it can process in one
+ * invocation of the handler.
+ * @param oct       - octeon device
+ * @param q_no      - octeon output queue number (0 <= q_no <= MAX_OCTEON_DROQ-1
+ * @param ops       - the droq_ops settings for this queue
+ * @return          - 0 on success, -ENODEV or -EINVAL on error.
+ */
+int
+octeon_register_droq_ops(struct octeon_device *oct,
+			 uint32_t q_no,
+			 struct octeon_droq_ops *ops);
+
+/** Resets the function pointer and flag settings made by
+ * octeon_register_droq_ops(). After this routine is called, the DROQ handler
+ * will lookup dispatch function for each arriving packet on the output queue
+ * given by q_no.
+ * @param oct       - octeon device
+ * @param q_no      - octeon output queue number (0 <= q_no <= MAX_OCTEON_DROQ-1
+ * @return          - 0 on success, -ENODEV or -EINVAL on error.
+ */
+int octeon_unregister_droq_ops(struct octeon_device *oct, uint32_t q_no);
+
+/**   Register a dispatch function for a opcode/subcode. The driver will call
+ *    this dispatch function when it receives a packet with the given
+ *    opcode/subcode in its output queues along with the user specified
+ *    argument.
+ *    @param  oct        - the octeon device to register with.
+ *    @param  opcode     - the opcode for which the dispatch will be registered.
+ *    @param  subcode    - the subcode for which the dispatch will be registered
+ *    @param  fn         - the dispatch function.
+ *    @param  fn_arg     - user specified that will be passed along with the
+ *                         dispatch function by the driver.
+ *    @return Success: 0; Failure: 1
+ */
+int octeon_register_dispatch_fn(struct octeon_device *oct,
+				uint16_t opcode,
+				uint16_t subcode,
+				octeon_dispatch_fn_t fn, void *fn_arg);
+
+/**  Remove registration for an opcode/subcode. This will delete the mapping for
+ *   an opcode/subcode. The dispatch function will be unregistered and will no
+ *   longer be called if a packet with the opcode/subcode arrives in the driver
+ *   output queues.
+ *   @param  oct        -  the octeon device to unregister from.
+ *   @param  opcode     -  the opcode to be unregistered.
+ *   @param  subcode    -  the subcode to be unregistered.
+ *
+ *   @return Success: 0; Failure: 1
+ */
+int octeon_unregister_dispatch_fn(struct octeon_device *oct,
+				  uint16_t opcode,
+				  uint16_t subcode);
+
+void octeon_droq_print_stats(void);
+
+uint32_t octeon_droq_check_hw_for_pkts(struct octeon_device *oct,
+				       struct octeon_droq *droq);
+
+int octeon_create_droq(struct octeon_device *oct, uint32_t q_no,
+		       uint32_t num_descs, uint32_t desc_size, void *app_ctx);
+
+int octeon_droq_process_packets(struct octeon_device *oct,
+				struct octeon_droq *droq);
+
+int octeon_process_droq_poll_cmd(struct octeon_device *oct, uint32_t q_no,
+				 int cmd, uint32_t arg);
+
+#endif	/*__OCTEON_DROQ_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_hw.h b/drivers/net/ethernet/cavium/liquidio/octeon_hw.h
new file mode 100644
index 0000000..d31794d
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_hw.h
@@ -0,0 +1,57 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+
+/*! \file  octeon_hw.h
+ *  \brief Host Driver: PCI read/write routines and default register values.
+ */
+
+#ifndef __OCTEON_HW_H__
+#define __OCTEON_HW_H__
+
+enum octeon_pcie_mps {
+	PCIE_MPS_DEFAULT = -1,	/* Use the default setup by BIOS */
+	PCIE_MPS_128B = 0,
+	PCIE_MPS_256B = 1
+};
+
+enum octeon_pcie_mrrs {
+	PCIE_MRRS_DEFAULT = -1,	/* Use the default setup by BIOS */
+	PCIE_MRRS_128B = 0,
+	PCIE_MRRS_256B = 1,
+	PCIE_MRRS_512B = 2,
+	PCIE_MRRS_1024B = 3,
+	PCIE_MRRS_2048B = 4,
+	PCIE_MRRS_4096B = 5
+};
+
+#define   octeon_write_csr(oct_dev, reg_off, value) \
+		writel(value, oct_dev->mmio[0].hw_addr + reg_off)
+
+#define   octeon_write_csr64(oct_dev, reg_off, val64) \
+		writeq(val64, oct_dev->mmio[0].hw_addr + reg_off)
+
+#define   octeon_read_csr(oct_dev, reg_off)         \
+		readl(oct_dev->mmio[0].hw_addr + reg_off)
+
+#define   octeon_read_csr64(oct_dev, reg_off)         \
+		readq(oct_dev->mmio[0].hw_addr + reg_off)
+#endif				/* __OCTEON_HW_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
new file mode 100644
index 0000000..e6007cd
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -0,0 +1,274 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+
+/*!  \file  octeon_iq.h
+ *   \brief Host Driver: Implementation of Octeon input queues.
+ */
+
+#ifndef __OCTEON_IQ_H__
+#define  __OCTEON_IQ_H__
+
+#define IQ_STATUS_RUNNING   1
+
+#define IQ_SEND_OK          0
+#define IQ_SEND_STOP        1
+#define IQ_SEND_FAILED     -1
+
+/*-------------------------  INSTRUCTION QUEUE --------------------------*/
+
+/* \cond */
+
+#define REQTYPE_NONE                 0
+#define REQTYPE_NORESP_NET           1
+#define REQTYPE_NORESP_NET_SG        2
+#define REQTYPE_RESP_NET             3
+#define REQTYPE_RESP_NET_SG          4
+#define REQTYPE_SOFT_COMMAND         5
+#define REQTYPE_LAST                 5
+
+struct octeon_noresponse_list {
+	uint32_t reqtype;
+	void *buf;
+};
+
+struct oct_noresp_free_list {
+	struct octeon_noresponse_list *q;
+	uint32_t put_idx, get_idx;
+	atomic_t count;
+};
+
+/* \endcond */
+
+/** Input Queue statistics. Each input queue has four stats fields. */
+struct oct_iq_stats {
+	uint64_t instr_posted; /**< Instructions posted to this queue. */
+	uint64_t instr_processed; /**< Instructions processed in this queue. */
+	uint64_t instr_dropped; /**< Instructions that could not be processed */
+	uint64_t bytes_sent;  /**< Bytes sent through this queue. */
+	uint64_t sgentry_sent;/**< Gather entries sent through this queue. */
+	uint64_t tx_done;/**< Num of packets sent to network. */
+	uint64_t tx_iq_busy;/**< Numof times this iq was found to be full. */
+	uint64_t tx_dropped;/**< Numof pkts dropped dueto xmitpath errors. */
+	uint64_t tx_tot_bytes;/**< Total count of bytes sento to network. */
+};
+
+#define OCT_IQ_STATS_SIZE   (sizeof(struct oct_iq_stats))
+
+/** The instruction (input) queue.
+ *  The input queue is used to post raw (instruction) mode data or packet
+ *  data to Octeon device from the host. Each input queue (upto 4) for
+ *  a Octeon device has one such structure to represent it.
+*/
+struct octeon_instr_queue {
+	/** A spinlock to protect access to the input ring.  */
+	spinlock_t lock;
+
+	/** Flag that indicates if the queue uses 64 byte commands. */
+	uint32_t iqcmd_64B:1;
+
+	/** Queue Number. */
+	uint32_t iq_no:5;
+
+	uint32_t rsvd:17;
+
+	/* Controls the periodic flushing of iq */
+	uint32_t do_auto_flush:1;
+
+	uint32_t status:8;
+
+	/** Maximum no. of instructions in this queue. */
+	uint32_t max_count;
+
+	/** Index in input ring where the driver should write the next packet */
+	uint32_t host_write_index;
+
+	/** Index in input ring where Octeon is expected to read the next
+	 * packet.
+	 */
+	uint32_t octeon_read_index;
+
+	/** This index aids in finding the window in the queue where Octeon
+	  * has read the commands.
+	  */
+	uint32_t flush_index;
+
+	/** This field keeps track of the instructions pending in this queue. */
+	atomic_t instr_pending;
+
+	uint32_t reset_instr_cnt;
+
+	/** Pointer to the Virtual Base addr of the input ring. */
+	uint8_t *base_addr;
+
+	struct octeon_noresponse_list *nrlist;
+
+	struct oct_noresp_free_list nr_free;
+
+	/** Octeon doorbell register for the ring. */
+	void __iomem *doorbell_reg;
+
+	/** Octeon instruction count register for this ring. */
+	void __iomem *inst_cnt_reg;
+
+	/** Number of instructions pending to be posted to Octeon. */
+	uint32_t fill_cnt;
+
+	/** The max. number of instructions that can be held pending by the
+	 * driver.
+	 */
+	uint32_t fill_threshold;
+
+	/** The last time that the doorbell was rung. */
+	uint64_t last_db_time;
+
+	/** The doorbell timeout. If the doorbell was not rung for this time and
+	  * fill_cnt is non-zero, ring the doorbell again.
+	  */
+	uint32_t db_timeout;
+
+	/** Statistics for this input queue. */
+	struct oct_iq_stats stats;
+
+	/** DMA mapped base address of the input descriptor ring. */
+	uint64_t base_addr_dma;
+
+	/** Application context */
+	void *app_ctx;
+};
+
+/*----------------------  INSTRUCTION FORMAT ----------------------------*/
+
+/** 32-byte instruction format.
+ *  Format of instruction for a 32-byte mode input queue.
+ */
+struct octeon_instr_32B {
+	/** Pointer where the input data is available. */
+	uint64_t dptr;
+
+	/** Instruction Header.  */
+	uint64_t ih;
+
+	/** Pointer where the response for a RAW mode packet will be written
+	 * by Octeon.
+	 */
+	uint64_t rptr;
+
+	/** Input Request Header. Additional info about the input. */
+	uint64_t irh;
+
+};
+
+#define OCT_32B_INSTR_SIZE     (sizeof(struct octeon_instr_32B))
+
+/** 64-byte instruction format.
+ *  Format of instruction for a 64-byte mode input queue.
+ */
+struct octeon_instr_64B {
+	/** Pointer where the input data is available. */
+	uint64_t dptr;
+
+	/** Instruction Header. */
+	uint64_t ih;
+
+	/** Input Request Header. */
+	uint64_t irh;
+
+	/** opcode/subcode specific parameters */
+	uint64_t ossp[2];
+
+	/** Return Data Parameters */
+	uint64_t rdp;
+
+	/** Pointer where the response for a RAW mode packet will be written
+	 * by Octeon.
+	 */
+	uint64_t rptr;
+
+	uint64_t reserved;
+
+};
+
+#define OCT_64B_INSTR_SIZE     (sizeof(struct octeon_instr_64B))
+
+struct octeon_soft_command {
+	struct list_head node;
+	struct octeon_instr_64B cmd;
+#define COMPLETION_WORD_INIT    0xffffffffffffffffULL
+	uint64_t *status_word;
+	void *virtdptr;
+	uint64_t dmadptr;
+	void *virtrptr;
+	uint64_t dmarptr;
+	size_t wait_time;
+	size_t timeout;
+	uint32_t iq_no;
+	void (*callback)(struct octeon_device *, uint32_t, void *);
+	void *callback_arg;
+};
+
+/**
+ *  octeon_init_instr_queue()
+ *  @param octeon_dev      - pointer to the octeon device structure.
+ *  @param iq_no           - queue to be initialized (0 <= q_no <= 3).
+ *
+ *  Called at driver init time for each input queue. iq_conf has the
+ *  configuration parameters for the queue.
+ *
+ *  @return  Success: 0   Failure: 1
+ */
+int octeon_init_instr_queue(struct octeon_device *octeon_dev, uint32_t iq_no,
+			    uint32_t num_descs);
+
+/**
+ *  octeon_delete_instr_queue()
+ *  @param octeon_dev      - pointer to the octeon device structure.
+ *  @param iq_no           - queue to be deleted (0 <= q_no <= 3).
+ *
+ *  Called at driver unload time for each input queue. Deletes all
+ *  allocated resources for the input queue.
+ *
+ *  @return  Success: 0   Failure: 1
+ */
+int octeon_delete_instr_queue(struct octeon_device *octeon_dev, uint32_t iq_no);
+
+int lio_wait_for_instr_fetch(struct octeon_device *oct);
+
+int octeon_send_command(struct octeon_device *oct, uint32_t iq_no,
+			uint32_t force_db, void *cmd, void *buf,
+			uint32_t datasize, uint32_t reqtype);
+
+void octeon_prepare_soft_command(struct octeon_device *oct,
+				 struct octeon_soft_command *sc,
+				 uint8_t opcode, uint8_t subcode,
+				 uint32_t irh_ossp, uint64_t ossp0,
+				 uint64_t ossp1, void *virtdptr,
+				 uint64_t dmadptr, uint32_t datasize,
+				 void *virtrptr, uint64_t dmarptr,
+				 uint32_t rdatasize);
+
+int octeon_send_soft_command(struct octeon_device *oct,
+			     struct octeon_soft_command *sc);
+
+int octeon_setup_iq(struct octeon_device *oct, uint32_t iq_no,
+		    uint32_t num_descs, void *app_ctx);
+
+#endif				/* __OCTEON_IQ_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
new file mode 100644
index 0000000..b7c6289
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -0,0 +1,253 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+
+/*! \file octeon_main.h
+ *  \brief Host Driver: This file is included by all host driver source files
+ *  to include common definitions.
+ */
+
+#ifndef _OCTEON_MAIN_H_
+#define  _OCTEON_MAIN_H_
+
+#define cavium_pr_err(format, ...)         \
+	pr_err(format, ## __VA_ARGS__)
+#define cavium_pr_info(format, ...)         \
+	pr_info(format, ## __VA_ARGS__)
+#define lio_dev_info(oct, format, ...)         \
+	dev_info(&oct->pci_dev->dev, format, ## __VA_ARGS__)
+#define lio_dev_err(oct, format, ...)         \
+	dev_err(&oct->pci_dev->dev, format, ## __VA_ARGS__)
+#define lio_dev_dbg(oct, format, ...)         \
+	dev_dbg(&oct->pci_dev->dev, format, ## __VA_ARGS__)
+#define lio_info(lio, lvl, _fmt, _args...) \
+	netif_info(lio, lvl, lio->netdev, _fmt,  ##_args)
+#define lio_print_hex_dump_bytes(buf, len) \
+	print_hex_dump_bytes("", DUMP_PREFIX_ADDRESS, buf, len)
+
+#if BITS_PER_LONG == 32
+#define CVM_CAST64(v) ((long long)(v))
+#elif BITS_PER_LONG == 64
+#define CVM_CAST64(v) ((long long)(long)(v))
+#else
+#error "Unknown system architecture"
+#endif
+
+#define DRV_NAME "LiquidIO"
+
+/**
+ * \brief determines if a given console has debug enabled.
+ * @param console console to check
+ * @returns  1 = enabled. 0 otherwise
+ */
+int octeon_console_debug_enabled(uint32_t console);
+
+/* BQL-related functions */
+void octeon_report_sent_bytes_to_bql(void *buf, int reqtype);
+void octeon_update_tx_completion_counters(void *buf, int reqtype,
+					  unsigned int *pkts_compl,
+					  unsigned int *bytes_compl);
+void octeon_report_tx_completion_to_bql(void *txq, unsigned int pkts_compl,
+					unsigned int bytes_compl);
+
+/** Swap 8B blocks */
+static inline void octeon_swap_8B_data(uint64_t *data, uint32_t blocks)
+{
+	while (blocks) {
+		cpu_to_be64s(data);
+		blocks--;
+		data++;
+	}
+}
+
+/**
+  * \brief unmaps a PCI BAR
+  * @param oct Pointer to Octeon device
+  * @param baridx bar index
+  */
+static inline void octeon_unmap_pci_barx(struct octeon_device *oct, int baridx)
+{
+	lio_dev_dbg(oct, "Freeing PCI mapped regions for Bar%d\n", baridx);
+
+	if (oct->mmio[baridx].done)
+		iounmap(oct->mmio[baridx].hw_addr);
+
+	if (oct->mmio[baridx].start)
+		pci_release_region(oct->pci_dev, baridx * 2);
+}
+
+/**
+ * \brief maps a PCI BAR
+ * @param oct Pointer to Octeon device
+ * @param baridx bar index
+ * @param max_map_len maximum length of mapped memory
+ */
+static inline int octeon_map_pci_barx(struct octeon_device *oct,
+				      int baridx, int max_map_len)
+{
+	uint32_t mapped_len = 0;
+
+	if (pci_request_region(oct->pci_dev, baridx * 2, DRV_NAME)) {
+		lio_dev_err(oct, "pci_request_region failed for bar %d\n",
+			    baridx);
+		return 1;
+	}
+
+	oct->mmio[baridx].start = pci_resource_start(oct->pci_dev, baridx * 2);
+	oct->mmio[baridx].len = pci_resource_len(oct->pci_dev, baridx * 2);
+
+	mapped_len = oct->mmio[baridx].len;
+	if (!mapped_len)
+		return 1;
+
+	if (max_map_len && (mapped_len > max_map_len))
+		mapped_len = max_map_len;
+
+	oct->mmio[baridx].hw_addr =
+		ioremap(oct->mmio[baridx].start, mapped_len);
+	oct->mmio[baridx].mapped_len = mapped_len;
+
+	lio_dev_dbg(oct, "BAR%d start: 0x%llx mapped %u of %u bytes\n",
+		    baridx, oct->mmio[baridx].start, mapped_len,
+		    oct->mmio[baridx].len);
+
+	if (!oct->mmio[baridx].hw_addr) {
+		lio_dev_err(oct, "error ioremap for bar %d\n", baridx);
+		return 1;
+	}
+	oct->mmio[baridx].done = 1;
+
+	return 0;
+}
+
+static inline void *
+cnnic_alloc_aligned_dma(struct pci_dev *pci_dev,
+			uint32_t size,
+			uint32_t *alloc_size,
+			size_t *orig_ptr,
+			size_t *dma_addr __attribute__((unused)))
+{
+	int retries = 0;
+	void *ptr = NULL;
+
+#define OCTEON_MAX_ALLOC_RETRIES     1
+	do {
+		ptr =
+		    (void *)__get_free_pages(GFP_KERNEL,
+					     get_order(size));
+		if ((unsigned long)ptr & 0x07) {
+			free_pages((unsigned long)ptr, get_order(size));
+			ptr = NULL;
+			/* Increment the size required if the first
+			 * attempt failed.
+			 */
+			if (!retries)
+				size += 7;
+		}
+		retries++;
+	} while ((retries <= OCTEON_MAX_ALLOC_RETRIES) && !ptr);
+
+	*alloc_size = size;
+	*orig_ptr = (unsigned long)ptr;
+	if ((unsigned long)ptr & 0x07)
+		ptr = (void *)(((unsigned long)ptr + 7) & ~(7UL));
+	return ptr;
+}
+
+#define cnnic_free_aligned_dma(pci_dev, ptr, size, orig_ptr, dma_addr) \
+		free_pages(orig_ptr, get_order(size))
+
+static inline void
+sleep_cond(wait_queue_head_t *wait_queue, int *condition)
+{
+	wait_queue_t we;
+
+	init_waitqueue_entry(&we, current);
+	add_wait_queue(wait_queue, &we);
+	while (!(ACCESS_ONCE(*condition))) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (signal_pending(current))
+			goto out;
+		schedule();
+	}
+out:
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(wait_queue, &we);
+}
+
+static inline void
+sleep_atomic_cond(wait_queue_head_t *waitq, atomic_t *pcond)
+{
+	wait_queue_t we;
+
+	init_waitqueue_entry(&we, current);
+	add_wait_queue(waitq, &we);
+	while (!atomic_read(pcond)) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (signal_pending(current))
+			goto out;
+		schedule();
+	}
+out:
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(waitq, &we);
+}
+
+/* Gives up the CPU for a timeout period.
+ * Check that the condition is not true before we go to sleep for a
+ * timeout period.
+ */
+static inline void
+sleep_timeout_cond(wait_queue_head_t *wait_queue,
+		   int *condition,
+		   int timeout)
+{
+	wait_queue_t we;
+
+	init_waitqueue_entry(&we, current);
+	add_wait_queue(wait_queue, &we);
+	set_current_state(TASK_INTERRUPTIBLE);
+	if (!(*condition))
+		schedule_timeout(timeout);
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(wait_queue, &we);
+}
+
+#ifndef ROUNDUP4
+#define ROUNDUP4(val) (((val) + 3)&0xfffffffc)
+#endif
+
+#ifndef ROUNDUP8
+#define ROUNDUP8(val) (((val) + 7)&0xfffffff8)
+#endif
+
+#ifndef ROUNDUP16
+#define ROUNDUP16(val) (((val) + 15)&0xfffffff0)
+#endif
+
+#ifndef ROUNDUP128
+#define ROUNDUP128(val) (((val) + 127)&0xffffff80)
+#endif
+
+#ifndef PCI_VENDOR_ID_CAVIUM
+#define PCI_VENDOR_ID_CAVIUM               0x177D
+#endif
+#endif /* _OCTEON_MAIN_H_ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
new file mode 100644
index 0000000..1d5c618
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -0,0 +1,201 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+#include "octeon_mem_ops.h"
+
+#define MEMOPS_IDX   MAX_BAR1_MAP_INDEX
+
+static inline void
+octeon_toggle_bar1_swapmode(struct octeon_device *oct __attribute__((unused)),
+			    uint32_t idx __attribute__((unused)))
+{
+#ifdef __BIG_ENDIAN_BITFIELD
+	uint32_t mask;
+
+	mask = oct->fn_list.bar1_idx_read(oct, idx);
+	mask = (mask & 0x2) ? (mask & ~2) : (mask | 2);
+	oct->fn_list.bar1_idx_write(oct, idx, mask);
+#endif
+}
+
+static void
+octeon_pci_fastwrite(struct octeon_device *oct, uint8_t __iomem *mapped_addr,
+		     uint8_t *hostbuf, uint32_t len)
+{
+	while ((len) && ((unsigned long)mapped_addr) & 7) {
+		writeb(*(hostbuf++), mapped_addr++);
+		len--;
+	}
+
+	octeon_toggle_bar1_swapmode(oct, MEMOPS_IDX);
+
+	while (len >= 8) {
+		writeq(*((uint64_t *)hostbuf), mapped_addr);
+		mapped_addr += 8;
+		hostbuf += 8;
+		len -= 8;
+	}
+
+	octeon_toggle_bar1_swapmode(oct, MEMOPS_IDX);
+
+	while (len--)
+		writeb(*(hostbuf++), mapped_addr++);
+}
+
+static void
+octeon_pci_fastread(struct octeon_device *oct, uint8_t __iomem *mapped_addr,
+		    uint8_t *hostbuf, uint32_t len)
+{
+	while ((len) && ((unsigned long)mapped_addr) & 7) {
+		*(hostbuf++) = readb(mapped_addr++);
+		len--;
+	}
+
+	octeon_toggle_bar1_swapmode(oct, MEMOPS_IDX);
+
+	while (len >= 8) {
+		*((uint64_t *)hostbuf) = readq(mapped_addr);
+		mapped_addr += 8;
+		hostbuf += 8;
+		len -= 8;
+	}
+
+	octeon_toggle_bar1_swapmode(oct, MEMOPS_IDX);
+
+	while (len--)
+		*(hostbuf++) = readb(mapped_addr++);
+}
+
+/* Core mem read/write with temporary bar1 settings. */
+/* op = 1 to read, op = 0 to write. */
+static void
+__octeon_pci_rw_core_mem(struct octeon_device *oct,
+			 uint64_t addr,
+			 uint8_t *hostbuf, uint32_t len, uint32_t op)
+{
+	uint32_t copy_len = 0, index_reg_val = 0;
+	unsigned long flags;
+	uint8_t __iomem *mapped_addr;
+
+	spin_lock_irqsave(&oct->oct_lock, flags);
+
+	/* Save the original index reg value. */
+	index_reg_val = oct->fn_list.bar1_idx_read(oct, MEMOPS_IDX);
+	do {
+		oct->fn_list.bar1_idx_setup(oct, addr, MEMOPS_IDX, 1);
+		mapped_addr = oct->mmio[1].hw_addr
+		    + (MEMOPS_IDX << 22) + (addr & 0x3fffff);
+
+		/* If operation crosses a 4MB boundary, split the transfer
+		 * at the 4MB
+		 * boundary.
+		 */
+		if (((addr + len - 1) & ~(0x3fffff)) != (addr & ~(0x3fffff))) {
+			copy_len = (uint32_t) (((addr & ~(0x3fffff)) +
+				   (MEMOPS_IDX << 22)) - addr);
+		} else {
+			copy_len = len;
+		}
+
+		if (op) {	/* read from core */
+			octeon_pci_fastread(oct, mapped_addr, hostbuf,
+					    copy_len);
+		} else {
+			octeon_pci_fastwrite(oct, mapped_addr, hostbuf,
+					     copy_len);
+		}
+
+		len -= copy_len;
+		addr += copy_len;
+		hostbuf += copy_len;
+
+	} while (len);
+
+	oct->fn_list.bar1_idx_write(oct, MEMOPS_IDX, index_reg_val);
+
+	spin_unlock_irqrestore(&oct->oct_lock, flags);
+}
+
+void
+octeon_pci_read_core_mem(struct octeon_device *oct,
+			 uint64_t coreaddr,
+			 uint8_t *buf,
+			 uint32_t len)
+{
+	__octeon_pci_rw_core_mem(oct, coreaddr, buf, len, 1);
+}
+
+void
+octeon_pci_write_core_mem(struct octeon_device *oct,
+			  uint64_t coreaddr,
+			  uint8_t *buf,
+			  uint32_t len)
+{
+	__octeon_pci_rw_core_mem(oct, coreaddr, buf, len, 0);
+}
+
+uint64_t octeon_read_device_mem64(struct octeon_device *oct, uint64_t coreaddr)
+{
+	uint64_t ret;
+
+	__octeon_pci_rw_core_mem(oct, coreaddr, (uint8_t *)&ret, 8, 1);
+
+	return be64_to_cpu(ret);
+}
+
+uint32_t octeon_read_device_mem32(struct octeon_device *oct, uint64_t coreaddr)
+{
+	uint32_t ret;
+
+	__octeon_pci_rw_core_mem(oct, coreaddr, (uint8_t *)&ret, 4, 1);
+
+	return be32_to_cpu(ret);
+}
+
+void octeon_write_device_mem32(struct octeon_device *oct, uint64_t coreaddr,
+			       uint32_t val)
+{
+	uint32_t t = cpu_to_be32(val);
+
+	__octeon_pci_rw_core_mem(oct, coreaddr, (uint8_t *)&t, 4, 0);
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
new file mode 100644
index 0000000..853e69b
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
@@ -0,0 +1,77 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+
+/*!  \file octeon_mem_ops.h
+ *   \brief Host Driver: Routines used to read/write Octeon memory.
+ */
+
+#ifndef __OCTEON_MEM_OPS_H__
+#define __OCTEON_MEM_OPS_H__
+
+/**  Read a 64-bit value from a BAR1 mapped core memory address.
+ *   @param  oct        -  pointer to the octeon device.
+ *   @param  core_addr  -  the address to read from.
+ *
+ *   The range_idx gives the BAR1 index register for the range of address
+ *   in which core_addr is mapped.
+ *
+ *   @return  64-bit value read from Core memory
+ */
+uint64_t octeon_read_device_mem64(struct octeon_device *oct,
+				  uint64_t core_addr);
+
+/**  Read a 32-bit value from a BAR1 mapped core memory address.
+ *   @param  oct        -  pointer to the octeon device.
+ *   @param  core_addr  -  the address to read from.
+ *
+ *   @return  32-bit value read from Core memory
+ */
+uint32_t octeon_read_device_mem32(struct octeon_device *oct,
+				  uint64_t core_addr);
+
+/**  Write a 32-bit value to a BAR1 mapped core memory address.
+ *   @param  oct        -  pointer to the octeon device.
+ *   @param  core_addr  -  the address to write to.
+ *   @param  val        -  32-bit value to write.
+ */
+void
+octeon_write_device_mem32(struct octeon_device *oct,
+			  uint64_t core_addr,
+			  uint32_t val);
+
+/** Read multiple bytes from Octeon memory.
+ */
+void
+octeon_pci_read_core_mem(struct octeon_device *oct,
+			 uint64_t coreaddr,
+			 uint8_t *buf,
+			 uint32_t len);
+
+/** Write multiple bytes into Octeon memory.
+ */
+void
+octeon_pci_write_core_mem(struct octeon_device *oct,
+			  uint64_t coreaddr,
+			  uint8_t *buf,
+			  uint32_t len);
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
new file mode 100644
index 0000000..a4fedfd
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -0,0 +1,307 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+
+/*!  \file  octeon_network.h
+ *   \brief Host NIC Driver: Structure and Macro definitions used by NIC Module.
+ */
+
+#ifndef __OCTEON_NETWORK_H__
+#define __OCTEON_NETWORK_H__
+#include <linux/version.h>
+#include <linux/ptp_clock_kernel.h>
+
+/** LiquidIO per-interface network private data */
+struct lio {
+	/** State of the interface. Rx/Tx happens only in the RUNNING state.  */
+	atomic_t ifstate;
+
+	/** Octeon Interface index number. This device will be represented as
+	 *  oct<ifidx> in the system.
+	 */
+	int ifidx;
+
+	/** Octeon Input queue to use to transmit for this network interface. */
+	int txq;
+
+	/** Octeon Output queue from which pkts arrive
+	 * for this network interface.
+	 */
+	int rxq;
+
+	/** Guards the glist */
+	spinlock_t lock;
+
+	/** Linked list of gather components */
+	struct list_head glist;
+
+	/** Pointer to the NIC properties for the Octeon device this network
+	 *  interface is associated with.
+	 */
+	struct octdev_props_t *octprops;
+
+	/** Pointer to the octeon device structure. */
+	struct octeon_device *oct_dev;
+
+	struct net_device *netdev;
+
+	/** Link information sent by the core application for this interface. */
+	struct oct_link_info linfo;
+
+	/** Size of Tx queue for this octeon device. */
+	uint32_t tx_qsize;
+
+	/** Size of Rx queue for this octeon device. */
+	uint32_t rx_qsize;
+
+	/** Size of MTU this octeon device. */
+	uint32_t mtu;
+
+	/** msg level flag per interface. */
+	uint32_t msg_enable;
+
+	/** Copy of netdevice flags. */
+	uint32_t netdev_flags;
+
+	/** Copy of Interface capabilities: TSO, TSO6, LRO, Chescksums . */
+	uint64_t dev_capability;
+
+	/** Copy of beacaon reg in phy */
+	uint32_t phy_beacon_val;
+
+	/** Copy of ctrl reg in phy */
+	uint32_t led_ctrl_val;
+
+	/* Copy of the flags managed by core app & NIC module. */
+	enum octnet_ifflags core_flags;
+
+	/* PTP clock information */
+	struct ptp_clock_info ptp_info;
+	struct ptp_clock *ptp_clock;
+	int64_t ptp_adjust;
+
+	/* for atomic access to Octeon PTP reg and data struct */
+	spinlock_t ptp_lock;
+
+	/* For link updates */
+	spinlock_t link_update_lock;
+
+	/* Interface info */
+	uint32_t	intf_open;
+
+	/* work queue for  txq status */
+	struct cavium_wq	txq_status_wq;
+
+};
+
+#define LIO_SIZE         (sizeof(struct lio))
+#define GET_LIO(netdev)  ((struct lio *)netdev_priv(netdev))
+
+/**
+ * \brief Enable or disable LRO
+ * @param netdev    pointer to network device
+ * @param cmd      OCTNET_CMD_LRO_ENABLE or OCTNET_CMD_LRO_DISABLE
+ */
+int liquidio_set_lro(struct net_device *netdev, int cmd);
+
+/**
+ * \brief Link control command completion callback
+ * @param nctrl_ptr pointer to control packet structure
+ *
+ * This routine is called by the callback function when a ctrl pkt sent to
+ * core app completes. The nctrl_ptr contains a copy of the command type
+ * and data sent to the core app. This routine is only called if the ctrl
+ * pkt was sent successfully to the core app.
+ */
+void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr);
+
+/**
+ * \brief Register ethtool operations
+ * @param netdev    pointer to network device
+ */
+void liquidio_set_ethtool_ops(struct net_device *netdev);
+
+static inline void
+*recv_buffer_alloc(struct octeon_device *oct __attribute__((unused)),
+		   uint32_t q_no __attribute__((unused)), uint32_t size)
+{
+#define SKB_ADJUST_MASK  0x3F
+#define SKB_ADJUST       (SKB_ADJUST_MASK + 1)
+
+	struct sk_buff *skb = dev_alloc_skb(size + SKB_ADJUST);
+
+	if ((unsigned long)skb->data & SKB_ADJUST_MASK) {
+		uint32_t r =
+		    SKB_ADJUST - ((unsigned long)skb->data & SKB_ADJUST_MASK);
+		skb_reserve(skb, r);
+	}
+
+	return (void *)skb;
+}
+
+static inline void recv_buffer_free(void *buffer)
+{
+	dev_kfree_skb_any((struct sk_buff *)buffer);
+}
+
+#define   get_rbd(ptr)      (((struct sk_buff *)(ptr))->data)
+
+static inline uint64_t
+lio_map_ring_info(struct octeon_droq *droq, uint32_t i)
+{
+	dma_addr_t dma_addr;
+	struct octeon_device *oct = droq->oct_dev;
+
+	dma_addr = pci_map_single(oct->pci_dev, &droq->info_list[i],
+				  OCT_DROQ_INFO_SIZE, PCI_DMA_FROMDEVICE);
+
+	BUG_ON(pci_dma_mapping_error(oct->pci_dev, dma_addr));
+
+	return (uint64_t)dma_addr;
+}
+
+static inline void
+lio_unmap_ring_info(struct pci_dev *pci_dev,
+		    uint64_t info_ptr, uint32_t size)
+{
+	pci_unmap_single(pci_dev, info_ptr, size, PCI_DMA_FROMDEVICE);
+}
+
+static inline uint64_t
+lio_map_ring(struct pci_dev *pci_dev,
+	     void *buf, uint32_t size)
+{
+	dma_addr_t dma_addr;
+
+	dma_addr = pci_map_single(pci_dev, get_rbd(buf), size,
+				  PCI_DMA_FROMDEVICE);
+
+	BUG_ON(pci_dma_mapping_error(pci_dev, dma_addr));
+
+	return (uint64_t)dma_addr;
+}
+
+static inline void
+lio_unmap_ring(struct pci_dev *pci_dev,
+	       uint64_t buf_ptr, uint32_t size)
+{
+	pci_unmap_single(pci_dev,
+			 buf_ptr, size,
+			 PCI_DMA_FROMDEVICE);
+}
+
+static inline int32_t
+liquidio_alloc_ctrl_pkt_buffers(struct octeon_device *oct,
+				struct octnic_ctrl_pkt *nctrl)
+{
+	void *data;
+	void *rdata;
+	size_t datasize;
+	size_t rdatasize;
+	uint64_t rptr;
+	uint64_t dptr;
+	dma_addr_t dma_addr;
+
+	datasize = OCTNET_CMD_SIZE + (MAX_NCTRL_UDD * 8);
+
+	rdatasize = 16;
+
+	data = kmalloc((datasize + rdatasize + 8), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	memset(data, 0, (datasize + rdatasize + 8));
+
+	rdata = (uint8_t *)data + datasize;
+
+	if ((unsigned long)rdata & 0x7)
+		rdata = (void *)(((unsigned long)rdata + 8) & ~0x7);
+
+	dma_addr = pci_map_single(oct->pci_dev, data, datasize,
+				  PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(oct->pci_dev, dma_addr)) {
+		lio_dev_err(oct, "%s DMA mapping error for data\n",
+			    __func__);
+		kfree(data);
+		return -ENOMEM;
+	}
+	dptr = (uint64_t)dma_addr;
+
+	dma_addr = pci_map_single(oct->pci_dev, rdata, rdatasize,
+				  PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(oct->pci_dev, dma_addr)) {
+		lio_dev_err(oct, "%s DMA mapping error for rdata\n",
+			    __func__);
+		pci_unmap_single(oct->pci_dev, dptr, datasize,
+				 PCI_DMA_TODEVICE);
+		kfree(data);
+		return -ENOMEM;
+	}
+
+	rptr = (uint64_t)dma_addr;
+
+	nctrl->data     = (union octnet_cmd *)data;
+	nctrl->dmadata  = dptr;
+	nctrl->rdata    = rdata;
+	nctrl->dmardata = rptr;
+
+	return 0;
+}
+
+static inline void
+liquidio_free_ctrl_pkt_buffers(struct octeon_device *oct,
+			       struct octnic_ctrl_pkt *nctrl)
+{
+	size_t datasize;
+	size_t rdatasize;
+
+	datasize = OCTNET_CMD_SIZE + (MAX_NCTRL_UDD * 8);
+
+	rdatasize = 16;
+
+	pci_unmap_single(oct->pci_dev,
+			 nctrl->dmadata, datasize,
+			 PCI_DMA_TODEVICE);
+
+	pci_unmap_single(oct->pci_dev,
+			 nctrl->dmardata, rdatasize,
+			 PCI_DMA_FROMDEVICE);
+
+	kfree(nctrl->data);
+}
+
+static inline void *octeon_fast_packet_alloc(struct octeon_device *oct,
+					     struct octeon_droq *droq,
+					     uint32_t q_no, uint32_t size)
+{
+	return recv_buffer_alloc(oct, q_no, size);
+}
+
+static inline void octeon_fast_packet_next(struct octeon_droq *droq,
+					   struct sk_buff *nicbuf,
+					   int copy_len,
+					   int idx)
+{
+	memcpy(skb_put(nicbuf, copy_len),
+	       get_rbd(droq->recv_buf_list[idx].buffer), copy_len);
+}
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
new file mode 100644
index 0000000..8151298
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -0,0 +1,218 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+#include "octeon_mem_ops.h"
+
+void *
+octeon_alloc_soft_command_resp(struct octeon_device    *oct,
+			       struct octeon_instr_64B *cmd,
+			       void		       *rdata,
+			       uint64_t		       rdatadma,
+			       size_t		       rdatasize)
+{
+	struct octeon_soft_command *sc;
+	struct octeon_instr_ih  *ih;
+	struct octeon_instr_irh *irh;
+	struct octeon_instr_rdp *rdp;
+
+	sc = kmalloc(sizeof(*sc), GFP_ATOMIC);
+
+	if (!sc)
+		return NULL;
+
+	memset(sc, 0, sizeof(struct octeon_soft_command));
+	memset(rdata, 0, rdatasize);
+
+	/* Copy existing command structure into the soft command */
+	memcpy(&sc->cmd, cmd, sizeof(struct octeon_instr_64B));
+
+	/* Add in the response related fields. Opcode and Param are already
+	 * there.
+	 */
+	ih      = (struct octeon_instr_ih *)&sc->cmd.ih;
+	ih->fsz = 40; /* irh + ossp[0] + ossp[1] + rdp + rptr = 40 bytes */
+
+	irh        = (struct octeon_instr_irh *)&sc->cmd.irh;
+	irh->rflag = 1; /* a response is required */
+	irh->len   = 4; /* means four 64-bit words immediately follow irh */
+
+	rdp            = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+	rdp->pcie_port = oct->pcie_port;
+	rdp->rlen      = rdatasize;
+
+	BUG_ON(rdatasize < 16);
+	sc->virtrptr = rdata;
+	sc->dmarptr = rdatadma;
+	sc->status_word = (uint64_t *)((uint8_t *)(rdata) + rdatasize-8);
+	*sc->status_word = COMPLETION_WORD_INIT;
+
+	sc->cmd.rptr =  sc->dmarptr;
+
+	sc->wait_time = 1000;
+	sc->timeout = jiffies + sc->wait_time;
+
+	return sc;
+}
+
+int octnet_send_nic_data_pkt(struct octeon_device *oct,
+			     struct octnic_data_pkt *ndata, uint32_t xmit_more)
+{
+	int ring_doorbell;
+
+	ring_doorbell = !xmit_more;
+
+	return octeon_send_command(oct, ndata->q_no, ring_doorbell, &ndata->cmd,
+				   ndata->buf, ndata->datasize,
+				   ndata->reqtype);
+}
+
+static void octnet_link_ctrl_callback(struct octeon_device *oct,
+				      uint32_t status, void *sc_ptr)
+{
+	struct octeon_soft_command *sc = (struct octeon_soft_command *)sc_ptr;
+	struct octnic_ctrl_pkt *nctrl;
+
+	nctrl =
+	    (struct octnic_ctrl_pkt *)((uint8_t *)sc +
+				   sizeof(struct octeon_soft_command));
+
+	/* Call the callback function if status is OK.
+	 * Status is OK only if a response was expected and core returned
+	 * success.
+	 * If no response was expected, status is OK if the command was posted
+	 * successfully.
+	 */
+	if (!status && nctrl->cb_fn)
+		nctrl->cb_fn(nctrl);
+
+	liquidio_free_ctrl_pkt_buffers(oct, nctrl);
+
+	kfree(sc);
+}
+
+static inline struct octeon_soft_command
+*octnic_alloc_ctrl_pkt_sc(struct octeon_device *oct,
+			  struct octnic_ctrl_pkt *nctrl,
+			  struct octnic_ctrl_params nparams)
+{
+	struct octeon_soft_command *sc = NULL;
+	uint8_t *data;
+	uint8_t *rdata;
+	size_t rdatasize;
+	uint32_t uddsize = 0, datasize = 0;
+	uint64_t rptr;
+	uint64_t dptr;
+
+	uddsize = (uint32_t)(nctrl->ncmd.s.more * 8);
+
+	sc = kmalloc((sizeof(struct octeon_soft_command) +
+		     sizeof(struct octnic_ctrl_pkt)), GFP_KERNEL);
+	if (!sc)
+		return NULL;
+
+	memset(sc, 0, (sizeof(struct octeon_soft_command) +
+	       sizeof(struct octnic_ctrl_pkt)));
+
+	memcpy(((uint8_t *)sc + sizeof(struct octeon_soft_command)), nctrl,
+	       sizeof(struct octnic_ctrl_pkt));
+
+	data = (uint8_t *)nctrl->data;
+	dptr = nctrl->dmadata;
+
+	memcpy(data, &nctrl->ncmd,  OCTNET_CMD_SIZE);
+
+	octeon_swap_8B_data((uint64_t *)data, (OCTNET_CMD_SIZE >> 3));
+
+	if (uddsize) {
+		/* Endian-Swap for UDD should have been done by caller. */
+		memcpy(data + OCTNET_CMD_SIZE, nctrl->udd, uddsize);
+	}
+
+	if (nctrl->wait_time) {
+		rdata = (uint8_t *)nctrl->rdata;
+		rptr = nctrl->dmardata;
+		rdatasize = 16;
+	} else {
+		rdata = NULL;
+		rptr = 0;
+		rdatasize = 0;
+	}
+
+	datasize = OCTNET_CMD_SIZE + uddsize;
+
+	octeon_prepare_soft_command(oct, sc, OPCODE_NIC, OPCODE_NIC_CMD,
+				    0, 0, 0,
+				    data, dptr, datasize,
+				    rdata, rptr, rdatasize);
+
+	sc->callback = octnet_link_ctrl_callback;
+	sc->callback_arg = sc;
+	sc->wait_time = nctrl->wait_time;
+
+	return sc;
+}
+
+int
+octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
+			 struct octnic_ctrl_pkt *nctrl,
+			 struct octnic_ctrl_params nparams)
+{
+	int retval;
+	struct octeon_soft_command *sc = NULL;
+
+	sc = octnic_alloc_ctrl_pkt_sc(oct, nctrl, nparams);
+	if (!sc) {
+		lio_dev_err(oct, "%s soft command alloc failed\n",
+			    __func__);
+		return -1;
+	}
+
+	retval = octeon_send_soft_command(oct, sc);
+	if (retval) {
+		lio_dev_err(oct, "%s soft command send failed status: %x\n",
+			    __func__, retval);
+		return -1;
+	}
+
+	return retval;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
new file mode 100644
index 0000000..0d7c1f2
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -0,0 +1,218 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+
+/*!  \file octeon_nic.h
+ *   \brief Host NIC Driver: Routine to send network data &
+ *   control packet to Octeon.
+ */
+
+#ifndef __CAVIUM_NIC_H__
+#define  __CAVIUM_NIC_H__
+
+/* Maximum of 1 8-byte words can be sent in a NIC control message.
+ * There is support for upto 7 in the control command sent to Octeon but we
+ * restrict ourselves to what we need in the NIC module.
+ */
+#define  MAX_NCTRL_UDD  8
+
+typedef void (*octnic_ctrl_pkt_cb_fn_t) (void *);
+
+/* Structure of control information passed by the NIC module to the OSI
+ * layer when sending control commands to Octeon device software.
+ */
+struct octnic_ctrl_pkt {
+	/** Command to be passed to the Octeon device software. */
+	union octnet_cmd ncmd;
+
+	/** Send buffer  */
+	void *data;
+	uint64_t dmadata;
+
+	/** Response buffer */
+	void *rdata;
+	uint64_t dmardata;
+
+	/** Additional data that may be needed by some commands. */
+	uint64_t udd[MAX_NCTRL_UDD];
+
+	/** Time to wait for Octeon software to respond to this control command.
+	 *  If wait_time is 0, OSI assumes no response is expected.
+	 */
+	size_t wait_time;
+
+	/** The network device that issued the control command. */
+	uint64_t netpndev;
+
+	/** Callback function called when the command has been fetched */
+	octnic_ctrl_pkt_cb_fn_t cb_fn;
+};
+
+/** Structure of data information passed by the NIC module to the OSI
+ * layer when forwarding data to Octeon device software.
+ */
+struct octnic_data_pkt {
+	/** Pointer to information maintained by NIC module for this packet. The
+	 *  OSI layer passes this as-is to the driver.
+	 */
+	void *buf;
+
+	/** Type of buffer passed in "buf" above. */
+	uint32_t reqtype;
+
+	/** Total data bytes to be transferred in this command. */
+	uint32_t datasize;
+
+	/** Command to be passed to the Octeon device software. */
+	struct octeon_instr_64B cmd;
+
+	/** Input queue to use to send this command. */
+	uint32_t q_no;
+
+};
+
+/** Structure passed by NIC module to OSI layer to prepare a command to send
+ * network data to Octeon.
+ */
+union octnic_cmd_setup {
+	struct {
+		uint32_t ifidx:8;
+		uint32_t cksum_offset:7;
+		uint32_t gather:1;
+		uint32_t timestamp:1;
+
+		uint32_t rsvd:15;
+		union {
+			uint32_t datasize;
+			uint32_t gatherptrs;
+		} u;
+	} s;
+
+	uint64_t u64;
+
+};
+
+struct octnic_ctrl_params {
+	uint32_t resp_order;
+};
+
+static inline int octnet_iq_is_full(struct octeon_device *oct, uint32_t q_no)
+{
+	return ((uint32_t)atomic_read(&oct->instr_queue[q_no]->instr_pending)
+		>= (oct->instr_queue[q_no]->max_count - 2));
+}
+
+/** Utility function to prepare a 64B NIC instruction based on a setup command
+ * @param cmd - pointer to instruction to be filled in.
+ * @param setup - pointer to the setup structure
+ * @param q_no - which queue for back pressure
+ *
+ * Assumes the cmd instruction is pre-allocated, but no fields are filled in.
+ */
+static inline void
+octnet_prepare_pci_cmd(struct octeon_instr_64B *cmd,
+		       union octnic_cmd_setup *setup)
+{
+	struct octeon_instr_ih *ih;
+	struct octeon_instr_irh *irh;
+	union octnic_packet_params packet_params;
+
+	memset(cmd, 0, sizeof(struct octeon_instr_64B));
+
+	ih = (struct octeon_instr_ih *)&cmd->ih;
+
+	/* assume that rflag is cleared so therefore front data will only have
+	 * irh and ossp[1] and ossp[2] for a total of 24 bytes
+	 */
+	ih->fsz = 24;
+
+	ih->tagtype = ORDERED_TAG;
+	ih->grp = DEFAULT_POW_GRP;
+	ih->tag = 0x11111111 + setup->s.ifidx;
+	ih->raw = 1;
+	ih->qos = (setup->s.ifidx & 3) + 4;	/* map qos based on interface */
+
+	if (!setup->s.gather) {
+		ih->dlengsz = setup->s.u.datasize;
+	} else {
+		ih->gather = 1;
+		ih->dlengsz = setup->s.u.gatherptrs;
+	}
+
+	irh = (struct octeon_instr_irh *)&cmd->irh;
+
+	irh->opcode = OPCODE_NIC;
+	irh->subcode = OPCODE_NIC_NW_DATA;
+
+	packet_params.u32 = 0;
+
+	if (setup->s.cksum_offset)
+		packet_params.s.csoffset = setup->s.cksum_offset;
+
+	packet_params.s.ifidx = setup->s.ifidx;
+	packet_params.s.tsflag = setup->s.timestamp;
+
+	irh->ossp = packet_params.u32;
+}
+
+/** Allocate and a soft command with space for a response immediately following
+ * the commnad.
+ * @param oct - octeon device pointer
+ * @param cmd - pointer to the command structure, pre-filled for everything
+ * except the response.
+ * @param rdata - Buffer to receive response.
+ * @param rdatadma - Dma address of buffer passed in rdata.
+ * @param rdatasize - size in bytes of the response.
+ *
+ * @returns pointer to allocated buffer with command copied into it, and
+ * response space immediately following.
+ */
+void *
+octeon_alloc_soft_command_resp(struct octeon_device    *oct,
+			       struct octeon_instr_64B *cmd,
+			       void		       *rdata,
+			       uint64_t		       rdatadma,
+			       size_t		       rdatasize);
+
+/** Send a NIC data packet to the device
+ * @param oct - octeon device pointer
+ * @param ndata - control structure with queueing, and buffer information
+ *
+ * @returns IQ_FAILED if it failed to add to the input queue. IQ_STOP if it the
+ * queue should be stopped, and IQ_SEND_OK if it sent okay.
+ */
+int octnet_send_nic_data_pkt(struct octeon_device *oct,
+			     struct octnic_data_pkt *ndata, uint32_t xmit_more);
+
+/** Send a NIC control packet to the device
+ * @param oct - octeon device pointer
+ * @param nctrl - control structure with command, timout, and callback info
+ * @param nparams - response control structure
+ *
+ * @returns IQ_FAILED if it failed to add to the input queue. IQ_STOP if it the
+ * queue should be stopped, and IQ_SEND_OK if it sent okay.
+ */
+int
+octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
+			 struct octnic_ctrl_pkt *nctrl,
+			 struct octnic_ctrl_params nparams);
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
new file mode 100644
index 0000000..97e6e6c
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -0,0 +1,637 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+
+#define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
+	(octeon_dev_ptr->instr_queue[iq_no]->stats.field += count)
+
+struct iq_post_status {
+	int status;
+	int index;
+};
+
+static void check_db_timeout(struct work_struct *work);
+static void  __check_db_timeout(struct octeon_device *oct, unsigned long iq_no);
+
+static inline int IQ_INSTR_MODE_64B(struct octeon_device *oct, int iq_no)
+{
+	struct octeon_instr_queue *iq =
+	    (struct octeon_instr_queue *)oct->instr_queue[iq_no];
+	return iq->iqcmd_64B;
+}
+
+#define IQ_INSTR_MODE_32B(oct, iq_no)  (!IQ_INSTR_MODE_64B(oct, iq_no))
+
+/* Define this to return the request status comaptible to old code */
+/*#define OCTEON_USE_OLD_REQ_STATUS*/
+
+static int octeon_init_nr_free_list(struct octeon_device *oct,
+				    struct octeon_instr_queue *iq,
+				    int count)
+{
+	int size;
+
+	size = (sizeof(struct octeon_noresponse_list) * count);
+
+	/* Initialize a list to holds NORESPONSE requests that have been fetched
+	 * by Octeon but has yet to be freed by driver.
+	 */
+	iq->nrlist = vmalloc(size);
+	if (!iq->nrlist)
+		return 1;
+
+	memset(iq->nrlist, 0, size);
+
+	iq->nr_free.q = vmalloc(size);
+	if (!iq->nr_free.q) {
+		vfree(iq->nrlist);
+		iq->nrlist = NULL;
+		return 1;
+	}
+
+	atomic_set(&iq->nr_free.count, 0);
+
+	return 0;
+}
+
+/* Return 0 on success, 1 on failure */
+int octeon_init_instr_queue(struct octeon_device *oct,
+			    uint32_t iq_no, uint32_t num_descs)
+{
+	struct octeon_instr_queue *iq;
+	struct octeon_iq_config *conf = NULL;
+	uint32_t q_size;
+	struct cavium_wq *db_wq;
+
+	if (oct->chip_id == OCTEON_CN66XX)
+		conf = &(CFG_GET_IQ_CFG(CHIP_FIELD(oct, cn6xxx, conf)));
+
+	if (oct->chip_id == OCTEON_CN68XX)
+		conf = &(CFG_GET_IQ_CFG(CHIP_FIELD(oct, cn68xx, conf)));
+
+	if (!conf) {
+		lio_dev_err(oct, "Unsupported Chip %x\n", oct->chip_id);
+		return 1;
+	}
+
+	q_size = (uint32_t)conf->instr_type * num_descs;
+
+	iq = oct->instr_queue[iq_no];
+
+	iq->base_addr = pci_alloc_consistent(oct->pci_dev, q_size,
+					     (dma_addr_t *)
+					     &iq->base_addr_dma);
+	if (!iq->base_addr) {
+		lio_dev_err(oct, "Cannot allocate memory for instr queue %d\n",
+			    iq_no);
+		return 1;
+	}
+
+	if (num_descs & (num_descs - 1)) {
+		lio_dev_err(oct,
+			    "Number of descriptors for instr queue %d not in power of 2.\n",
+			    iq_no);
+		return 1;
+	}
+
+	iq->max_count = num_descs;
+
+	if (octeon_init_nr_free_list(oct, iq, iq->max_count)) {
+		pci_free_consistent(oct->pci_dev, q_size, iq->base_addr,
+				    iq->base_addr_dma);
+		lio_dev_err(oct, "Alloc failed for IQ[%d] nr free list\n",
+			    iq_no);
+		return 1;
+	}
+
+	lio_dev_dbg(oct, "IQ[%d]: base: %p basedma: %llx count: %d\n",
+		    iq_no, iq->base_addr, iq->base_addr_dma, iq->max_count);
+
+	iq->iq_no = iq_no;
+	iq->fill_threshold = (uint32_t)conf->db_min;
+	iq->fill_cnt = 0;
+	iq->host_write_index = 0;
+	iq->octeon_read_index = 0;
+	iq->flush_index = 0;
+	iq->last_db_time = 0;
+	iq->do_auto_flush = 1;
+	iq->db_timeout = (uint32_t)conf->db_timeout;
+	atomic_set(&iq->instr_pending, 0);
+
+	/* Initialize the spinlock for this instruction queue */
+	spin_lock_init(&iq->lock);
+
+	oct->io_qmask.iq |= (1 << iq_no);
+
+	/* Set the 32B/64B mode for each input queue */
+	oct->io_qmask.iq64B |= ((conf->instr_type == 64) << iq_no);
+	iq->iqcmd_64B = (conf->instr_type == 64);
+
+	oct->fn_list.setup_iq_regs(oct, iq_no);
+
+	oct->check_db_wq[iq_no].wq = create_workqueue("check_iq_db");
+	if (!oct->check_db_wq[iq_no].wq) {
+		pci_free_consistent(oct->pci_dev, q_size, iq->base_addr,
+				    iq->base_addr_dma);
+		lio_dev_err(oct, "check db wq create failed for iq %d\n",
+			    iq_no);
+		return 1;
+	}
+
+	db_wq = &oct->check_db_wq[iq_no];
+
+	INIT_DELAYED_WORK(&db_wq->wk.work, check_db_timeout);
+	db_wq->wk.ctxptr = oct;
+	db_wq->wk.ctxul = iq_no;
+	queue_delayed_work(db_wq->wq, &db_wq->wk.work, msecs_to_jiffies(1));
+
+	return 0;
+}
+
+int octeon_delete_instr_queue(struct octeon_device *oct, uint32_t iq_no)
+{
+	uint64_t desc_size = 0, q_size;
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
+
+	cancel_delayed_work_sync(&oct->check_db_wq[iq_no].wk.work);
+	flush_workqueue(oct->check_db_wq[iq_no].wq);
+	destroy_workqueue(oct->check_db_wq[iq_no].wq);
+
+	if (oct->chip_id == OCTEON_CN66XX)
+		desc_size =
+		    CFG_GET_IQ_INSTR_TYPE(CHIP_FIELD(oct, cn6xxx, conf));
+
+	if (oct->chip_id == OCTEON_CN68XX)
+		desc_size =
+		    CFG_GET_IQ_INSTR_TYPE(CHIP_FIELD(oct, cn68xx, conf));
+
+	if (iq->nr_free.q)
+		vfree(iq->nr_free.q);
+
+	if (iq->nrlist)
+		vfree(iq->nrlist);
+
+	if (iq->base_addr) {
+		q_size = iq->max_count * desc_size;
+		pci_free_consistent(oct->pci_dev, (uint32_t)q_size,
+				    iq->base_addr, iq->base_addr_dma);
+		return 0;
+	}
+	return 1;
+}
+
+/* Return 0 on success, 1 on failure */
+int octeon_setup_iq(struct octeon_device *oct,
+		    uint32_t iq_no,
+		    uint32_t num_descs,
+		    void *app_ctx)
+{
+	if (oct->instr_queue[iq_no]) {
+		if (iq_no != 0) {
+			lio_dev_err(oct,
+				    "IQ is in use. Cannot create the IQ: %d again\n",
+				    iq_no);
+			return 1;
+		}
+		oct->instr_queue[iq_no]->app_ctx = app_ctx;
+		return 0;
+	}
+	oct->instr_queue[iq_no] =
+	    vmalloc(sizeof(struct octeon_instr_queue));
+	if (!oct->instr_queue[iq_no])
+		return 1;
+
+	memset(oct->instr_queue[iq_no], 0,
+	       sizeof(struct octeon_instr_queue));
+
+	oct->instr_queue[iq_no]->app_ctx = app_ctx;
+	if (octeon_init_instr_queue(oct, iq_no, num_descs)) {
+		vfree(oct->instr_queue[iq_no]);
+		oct->instr_queue[iq_no] = NULL;
+		return 1;
+	}
+
+	oct->num_iqs++;
+	oct->fn_list.enable_io_queues(oct);
+	return 0;
+}
+
+int lio_wait_for_instr_fetch(struct octeon_device *oct)
+{
+	int i, retry = 1000, pending, instr_cnt = 0;
+
+	do {
+		instr_cnt = 0;
+
+		/*for (i = 0; i < oct->num_iqs; i++) {*/
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+			if (!(oct->io_qmask.iq & (1UL << i)))
+				continue;
+			pending =
+			    atomic_read(&oct->
+					       instr_queue[i]->instr_pending);
+			if (pending)
+				__check_db_timeout(oct, i);
+			instr_cnt += pending;
+		}
+
+		if (instr_cnt == 0)
+			break;
+
+		schedule_timeout_uninterruptible(1);
+
+	} while (retry-- && instr_cnt);
+
+	return instr_cnt;
+}
+
+static inline void
+ring_doorbell(struct octeon_device *oct, struct octeon_instr_queue *iq)
+{
+	if (atomic_read(&oct->status) == OCT_DEV_RUNNING) {
+		writel(iq->fill_cnt, iq->doorbell_reg);
+		/* make sure doorbell write goes through */
+		mmiowb();
+		iq->fill_cnt = 0;
+		iq->last_db_time = jiffies;
+		return;
+	}
+}
+
+static inline void __copy_cmd_into_iq(struct octeon_instr_queue *iq,
+				      uint8_t *cmd)
+{
+	uint8_t *iqptr, cmdsize;
+
+	cmdsize = ((iq->iqcmd_64B) ? 64 : 32);
+	iqptr = iq->base_addr + (cmdsize * iq->host_write_index);
+
+	memcpy(iqptr, cmd, cmdsize);
+}
+
+static inline int
+__post_command(struct octeon_device *octeon_dev __attribute__((unused)),
+	       struct octeon_instr_queue *iq,
+	       uint32_t force_db __attribute__((unused)), uint8_t *cmd)
+{
+	uint32_t index = -1;
+
+	/* This ensures that the read index does not wrap around to the same
+	 * position if queue gets full before Octeon could fetch any instr.
+	 */
+	if (atomic_read(&iq->instr_pending) >= (int32_t)(iq->max_count - 1))
+		return -1;
+
+	__copy_cmd_into_iq(iq, cmd);
+
+	/* "index" is returned, host_write_index is modified. */
+	index = iq->host_write_index;
+	INCR_INDEX_BY1(iq->host_write_index, iq->max_count);
+	iq->fill_cnt++;
+
+	/* Flush the command into memory. We need to be sure the data is in
+	 * memory before indicating that the instruction is pending.
+	 */
+	wmb();
+
+	atomic_inc(&iq->instr_pending);
+
+	return index;
+}
+
+static inline struct iq_post_status
+__post_command2(struct octeon_device *octeon_dev __attribute__((unused)),
+		struct octeon_instr_queue *iq,
+		uint32_t force_db __attribute__((unused)), uint8_t *cmd)
+{
+	struct iq_post_status st;
+
+	st.status = IQ_SEND_OK;
+
+	/* This ensures that the read index does not wrap around to the same
+	 * position if queue gets full before Octeon could fetch any instr.
+	 */
+	if (atomic_read(&iq->instr_pending) >= (int32_t)(iq->max_count - 1)) {
+		st.status = IQ_SEND_FAILED;
+		st.index = -1;
+		return st;
+	}
+
+	if (atomic_read(&iq->instr_pending) >= (int32_t)(iq->max_count - 2))
+		st.status = IQ_SEND_STOP;
+
+	__copy_cmd_into_iq(iq, cmd);
+
+	/* "index" is returned, host_write_index is modified. */
+	st.index = iq->host_write_index;
+	INCR_INDEX_BY1(iq->host_write_index, iq->max_count);
+	iq->fill_cnt++;
+
+	/* Flush the command into memory. We need to be sure the data is in
+	 * memory before indicating that the instruction is pending.
+	 */
+	wmb();
+
+	atomic_inc(&iq->instr_pending);
+
+	return st;
+}
+
+static inline void
+__add_to_nrlist(struct octeon_instr_queue *iq, int idx, void *buf, int reqtype)
+{
+	iq->nrlist[idx].buf = buf;
+	iq->nrlist[idx].reqtype = reqtype;
+}
+
+static int
+__process_iq_noresponse_list(struct octeon_device *oct __attribute__((unused)),
+			     struct octeon_instr_queue *iq)
+{
+	uint32_t old = iq->flush_index;
+	uint32_t inst_count = 0, put_idx;
+
+	put_idx = iq->nr_free.put_idx;
+
+	while (old != iq->octeon_read_index) {
+		if (iq->nrlist[old].reqtype == REQTYPE_NONE)
+			goto skip_this;
+
+		iq->nr_free.q[put_idx].buf = iq->nrlist[old].buf;
+		iq->nr_free.q[put_idx].reqtype = iq->nrlist[old].reqtype;
+		iq->nrlist[old].buf = NULL;
+		iq->nrlist[old].reqtype = 0;
+		INCR_INDEX_BY1(put_idx, iq->max_count);
+
+ skip_this:
+		inst_count++;
+		INCR_INDEX_BY1(old, iq->max_count);
+	}
+
+	iq->nr_free.put_idx = put_idx;
+
+	iq->flush_index = old;
+
+	return inst_count;
+}
+
+static inline void
+update_iq_indices(struct octeon_device *oct, struct octeon_instr_queue *iq)
+{
+	uint32_t inst_processed = 0;
+
+	/* Calculate how many commands Octeon has read and move the read index
+	 * accordingly.
+	 */
+	iq->octeon_read_index = oct->fn_list.update_iq_read_idx(iq);
+
+	/* Move the NORESPONSE requests to the per-device completion list. */
+	if (iq->flush_index != iq->octeon_read_index)
+		inst_processed = __process_iq_noresponse_list(oct, iq);
+
+	if (inst_processed)
+		atomic_sub(inst_processed, &iq->instr_pending);
+		iq->stats.instr_processed += inst_processed;
+}
+
+/** Check for commands that were fetched by Octeon. If they were NORESPONSE
+  * requests, move the requests from the per-queue pending list to the
+  * per-device noresponse completion list.
+  */
+static inline void
+flush_instr_queue(struct octeon_device *oct, struct octeon_instr_queue *iq)
+{
+	spin_lock_bh(&iq->lock);
+	update_iq_indices(oct, iq);
+	spin_unlock_bh(&iq->lock);
+
+	lio_process_noresponse_list(oct, iq);
+}
+
+static void
+octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
+		uint32_t pending_thresh)
+{
+	if (atomic_read(&iq->instr_pending) >= (int32_t)pending_thresh)
+		flush_instr_queue(oct, iq);
+}
+
+static void __check_db_timeout(struct octeon_device *oct, unsigned long iq_no)
+{
+	struct octeon_instr_queue *iq;
+	uint64_t next_time;
+
+	iq = oct->instr_queue[iq_no];
+
+	/* If jiffies - last_db_time < db_timeout do nothing  */
+	next_time = iq->last_db_time + iq->db_timeout;
+	if (!time_after(jiffies, (unsigned long)next_time))
+		return;
+	iq->last_db_time = jiffies;
+
+	/* Get the lock and prevent tasklets. This routine gets called from
+	 * the poll thread. Instructions can now be posted in tasklet context
+	 */
+	spin_lock_bh(&iq->lock);
+	if (iq->fill_cnt != 0)
+		ring_doorbell(oct, iq);
+
+	spin_unlock_bh(&iq->lock);
+
+	/* Flush the instruction queue */
+	if (iq->do_auto_flush)
+		octeon_flush_iq(oct, iq, 1);
+}
+
+/* Called by the Poll thread at regular intervals to check the instruction
+ * queue for commands to be posted and for commands that were fetched by Octeon.
+ */
+static void check_db_timeout(struct work_struct *work)
+{
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
+	unsigned long iq_no = wk->ctxul;
+	struct cavium_wq *db_wq = &oct->check_db_wq[iq_no];
+
+	__check_db_timeout(oct, iq_no);
+	queue_delayed_work(db_wq->wq, &db_wq->wk.work, msecs_to_jiffies(1));
+}
+
+int
+octeon_send_command(struct octeon_device *oct, uint32_t iq_no,
+		    uint32_t force_db, void *cmd, void *buf,
+		    uint32_t datasize, uint32_t reqtype)
+{
+	struct iq_post_status st;
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
+
+	spin_lock_bh(&iq->lock);
+
+	st = __post_command2(oct, iq, force_db, cmd);
+
+	if (st.status != IQ_SEND_FAILED) {
+		octeon_report_sent_bytes_to_bql(buf, reqtype);
+		__add_to_nrlist(iq, st.index, buf, reqtype);
+		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, bytes_sent, datasize);
+		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_posted, 1);
+
+		if (iq->fill_cnt >= iq->fill_threshold || force_db)
+			ring_doorbell(oct, iq);
+	} else {
+		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_dropped, 1);
+	}
+
+	spin_unlock_bh(&iq->lock);
+
+	if (iq->do_auto_flush)
+		octeon_flush_iq(oct, iq, 8);
+
+	return st.status;
+}
+
+void
+octeon_prepare_soft_command(struct octeon_device       *oct,
+			    struct octeon_soft_command *sc,
+			    uint8_t                     opcode,
+			    uint8_t                     subcode,
+			    uint32_t                    irh_ossp,
+			    uint64_t                    ossp0,
+			    uint64_t                    ossp1,
+			    void			*virtdptr,
+			    uint64_t                    dmadptr,
+			    uint32_t                    datasize,
+			    void			*virtrptr,
+			    uint64_t                    dmarptr,
+			    uint32_t                    rdatasize)
+{
+	struct octeon_config *oct_cfg;
+	struct octeon_instr_ih *ih;
+	struct octeon_instr_irh *irh;
+	struct octeon_instr_rdp *rdp;
+
+	BUG_ON(opcode > 15);
+	BUG_ON(subcode > 127);
+
+	oct_cfg = octeon_get_conf(oct);
+
+	memset(sc, 0, sizeof(struct octeon_soft_command));
+
+	ih          = (struct octeon_instr_ih *)&sc->cmd.ih;
+	ih->tagtype = ORDERED_TAG;
+	ih->tag     = 0x11111111;
+	ih->raw     = 1;
+	ih->grp     = CFG_GET_CTRL_Q_GRP(oct_cfg);
+
+	if (datasize) {
+		ih->dlengsz = datasize;
+		sc->virtdptr = virtdptr;
+		sc->dmadptr = dmadptr;
+		ih->rs = 1;
+	}
+
+	irh            = (struct octeon_instr_irh *)&sc->cmd.irh;
+	irh->opcode    = opcode;
+	irh->subcode   = subcode;
+
+	/* opcode/subcode specific parameters (ossp) */
+	irh->ossp       = irh_ossp;
+	sc->cmd.ossp[0] = ossp0;
+	sc->cmd.ossp[1] = ossp1;
+
+	if (rdatasize) {
+		BUG_ON(rdatasize < 16);
+		BUG_ON(!virtrptr);
+		sc->virtrptr = virtrptr;
+		sc->dmarptr = dmarptr;
+		sc->status_word = (uint64_t *)((uint8_t *)(sc->virtrptr) +
+					rdatasize - 8);
+
+		rdp            = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+		rdp->pcie_port = oct->pcie_port;
+		rdp->rlen      = rdatasize;
+
+		irh->rflag =  1;
+		irh->len   =  4;
+		ih->fsz    = 40; /* irh+ossp[0]+ossp[1]+rdp+rptr = 40 bytes */
+	} else {
+		irh->rflag =  0;
+		irh->len   =  2;
+		ih->fsz    = 24; /* irh + ossp[0] + ossp[1] = 24 bytes */
+	}
+
+	/*sc->iq_no = CFG_GET_CTRL_Q_NO(oct_cfg);
+	 * TODO set some config
+	 */
+	sc->iq_no = 0;
+}
+
+int octeon_send_soft_command(struct octeon_device *oct,
+			     struct octeon_soft_command *sc)
+{
+	struct octeon_instr_ih *ih;
+	struct octeon_instr_irh *irh;
+	struct octeon_instr_rdp *rdp;
+
+	ih = (struct octeon_instr_ih *)&sc->cmd.ih;
+	if (ih->dlengsz) {
+		BUG_ON(!sc->dmadptr);
+		sc->cmd.dptr = sc->dmadptr;
+	}
+
+	irh = (struct octeon_instr_irh *)&sc->cmd.irh;
+	if (irh->rflag) {
+		BUG_ON(!sc->dmarptr);
+		BUG_ON(!sc->status_word);
+		*sc->status_word = COMPLETION_WORD_INIT;
+
+		rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+
+		sc->cmd.rptr = sc->dmarptr;
+	}
+
+	if (sc->wait_time)
+		sc->timeout = jiffies + sc->wait_time;
+
+	return octeon_send_command(oct, sc->iq_no, 1, &sc->cmd, sc,
+				   (uint32_t)ih->dlengsz, REQTYPE_SOFT_COMMAND);
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
new file mode 100644
index 0000000..cc0218c
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -0,0 +1,272 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_hw.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+#include "cn66xx_regs.h"
+#include "cn66xx_device.h"
+#include "cn68xx_regs.h"
+#include "cn68xx_device.h"
+#include "liquidio_image.h"
+
+static void (*reqtype_free_fn[MAX_OCTEON_DEVICES][REQTYPE_LAST + 1]) (void *);
+
+static void oct_poll_req_completion(struct work_struct *work);
+
+int octeon_setup_response_list(struct octeon_device *oct)
+{
+	int i, ret = 0;
+	struct cavium_wq *cwq;
+
+	for (i = 0; i < MAX_RESPONSE_LISTS; i++) {
+		INIT_LIST_HEAD(&oct->response_list[i].head);
+		spin_lock_init(&oct->response_list[i].lock);
+		atomic_set(&oct->response_list[i].pending_req_count, 0);
+	}
+
+	for (i = 0; i <= REQTYPE_LAST; i++)
+		reqtype_free_fn[oct->octeon_id][i] = NULL;
+
+	oct->dma_comp_wq.wq = create_workqueue("dma-comp");
+	if (!oct->dma_comp_wq.wq) {
+		lio_dev_err(oct, "failed to create wq thread\n");
+		return -ENOMEM;
+	}
+
+	cwq = &oct->dma_comp_wq;
+	INIT_DELAYED_WORK(&cwq->wk.work, oct_poll_req_completion);
+	cwq->wk.ctxptr = oct;
+	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(100));
+
+	return ret;
+}
+
+void octeon_delete_response_list(struct octeon_device *oct)
+{
+	cancel_delayed_work_sync(&oct->dma_comp_wq.wk.work);
+	flush_workqueue(oct->dma_comp_wq.wq);
+	destroy_workqueue(oct->dma_comp_wq.wq);
+}
+
+int lio_process_ordered_list(struct octeon_device *octeon_dev,
+			     uint32_t force_quit)
+{
+	struct octeon_response_list *ordered_sc_list;
+	struct octeon_soft_command *sc;
+	int request_complete = 0;
+	int resp_to_process = MAX_ORD_REQS_TO_PROCESS;
+	uint32_t status;
+	uint64_t status64;
+	struct octeon_instr_rdp *rdp;
+
+	ordered_sc_list = &octeon_dev->response_list[OCTEON_ORDERED_SC_LIST];
+
+	do {
+		spin_lock_bh(&ordered_sc_list->lock);
+
+		if (ordered_sc_list->head.next == &ordered_sc_list->head) {
+			/* ordered_sc_list is empty; there is
+			 * nothing to process
+			 */
+			spin_unlock_bh
+			    (&ordered_sc_list->lock);
+			return 1;
+		}
+
+		sc = (struct octeon_soft_command *)ordered_sc_list->
+		    head.next;
+		rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+
+		status = OCTEON_REQUEST_PENDING;
+
+		/* check if octeon has finished DMA'ing a response
+		 * to where rptr is pointing to
+		 */
+		pci_dma_sync_single_for_cpu(octeon_dev->pci_dev, sc->cmd.rptr,
+					    rdp->rlen, PCI_DMA_FROMDEVICE);
+		status64 = *sc->status_word;
+
+		if (status64 != COMPLETION_WORD_INIT) {
+			if ((status64 & 0xff) != 0xff) {
+				octeon_swap_8B_data(&status64, 1);
+				if (((status64 & 0xff) != 0xff)) {
+					status =
+					    (uint32_t)(status64 &
+						       0xffffffffULL);
+				}
+			}
+		} else if (force_quit || (sc->timeout &&
+			time_after(jiffies, (unsigned long)sc->timeout))) {
+			status = OCTEON_REQUEST_TIMEOUT;
+		}
+
+		if (status != OCTEON_REQUEST_PENDING) {
+			/* we have received a response or we have timed out */
+			/* remove node from linked list */
+			list_del(&sc->node);
+			atomic_dec(&octeon_dev->response_list
+					  [OCTEON_ORDERED_SC_LIST].
+					  pending_req_count);
+			spin_unlock_bh
+			    (&ordered_sc_list->lock);
+
+			if (sc->callback)
+				sc->callback(octeon_dev, status,
+					     sc->callback_arg);
+
+			request_complete++;
+
+		} else {
+			/* no response yet */
+			request_complete = 0;
+			spin_unlock_bh
+			    (&ordered_sc_list->lock);
+		}
+
+		/* If we hit the Max Ordered requests to process every loop,
+		 * we quit
+		 * and let this function be invoked the next time the poll
+		 * thread runs
+		 * to process the remaining requests. This function can take up
+		 * the entire CPU if there is no upper limit to the requests
+		 * processed.
+		 */
+		if (request_complete >= resp_to_process)
+			break;
+	} while (request_complete);
+
+	return 0;
+}
+
+void lio_process_noresponse_list(struct octeon_device *oct,
+				 struct octeon_instr_queue *iq)
+{
+	uint32_t get_idx;
+	struct octeon_soft_command *sc;
+	struct octeon_instr_irh *irh;
+	int reqtype;
+	void *buf;
+	unsigned pkts_compl = 0, bytes_compl = 0;
+
+	spin_lock_bh(&iq->lock);
+
+	get_idx = iq->nr_free.get_idx;
+
+	while (get_idx != iq->nr_free.put_idx) {
+		reqtype = iq->nr_free.q[get_idx].reqtype;
+		buf     = iq->nr_free.q[get_idx].buf;
+
+		octeon_update_tx_completion_counters(buf, reqtype, &pkts_compl,
+						     &bytes_compl);
+
+		switch (reqtype) {
+		case REQTYPE_NORESP_NET:
+		case REQTYPE_NORESP_NET_SG:
+		case REQTYPE_RESP_NET_SG:
+			reqtype_free_fn[oct->octeon_id][reqtype](buf);
+			break;
+		case REQTYPE_RESP_NET:
+		case REQTYPE_SOFT_COMMAND:
+			sc = buf;
+
+			irh = (struct octeon_instr_irh *)&sc->cmd.irh;
+			if (irh->rflag) {
+				/* We're expecting a response from Octeon.
+				 * It's up to lio_process_ordered_list() to
+				 * process  sc. Add sc to the ordered soft
+				 * command response list because we expect
+				 * a response from Octeon.
+				*/
+				spin_lock_bh(&oct->response_list
+					[OCTEON_ORDERED_SC_LIST].lock);
+				atomic_inc(&oct->response_list
+					[OCTEON_ORDERED_SC_LIST].
+					pending_req_count);
+				list_add_tail(&sc->node, &oct->response_list
+					[OCTEON_ORDERED_SC_LIST].head);
+				spin_unlock_bh(&oct->response_list
+					[OCTEON_ORDERED_SC_LIST].lock);
+			} else {
+				if (sc->callback) {
+					sc->callback(oct, OCTEON_REQUEST_DONE,
+						     sc->callback_arg);
+				}
+			}
+			break;
+		default:
+			lio_dev_err(oct,
+				    "%s Unknown reqtype: %d buf: %p at idx %d\n",
+				    __func__, reqtype, buf, get_idx);
+		}
+		iq->nr_free.q[get_idx].reqtype = 0;
+		iq->nr_free.q[get_idx].buf = NULL;
+		INCR_INDEX_BY1(get_idx, iq->max_count);
+	}
+
+	iq->nr_free.get_idx = get_idx;
+
+	if (bytes_compl)
+		octeon_report_tx_completion_to_bql(iq->app_ctx, pkts_compl,
+						   bytes_compl);
+
+	spin_unlock_bh(&iq->lock);
+}
+
+static void oct_poll_req_completion(struct work_struct *work)
+{
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
+	struct cavium_wq *cwq = &oct->dma_comp_wq;
+
+	lio_process_ordered_list(oct, 0);
+
+	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(100));
+}
+
+int
+octeon_register_reqtype_free_fn(struct octeon_device *oct, int reqtype,
+				void (*fn)(void *))
+{
+	if (reqtype > REQTYPE_LAST) {
+		lio_dev_err(oct, "%s: Invalid reqtype: %d\n", __func__,
+			    reqtype);
+		return -EINVAL;
+	}
+
+	reqtype_free_fn[oct->octeon_id][reqtype] = fn;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.h b/drivers/net/ethernet/cavium/liquidio/response_manager.h
new file mode 100644
index 0000000..2eae9f9
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.h
@@ -0,0 +1,154 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2014 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium, Inc. for more information
+ **********************************************************************/
+
+/*! \file response_manager.h
+ *  \brief Host Driver:  Response queues for host instructions.
+ */
+
+#ifndef __RESPONSE_MANAGER_H__
+#define __RESPONSE_MANAGER_H__
+
+/** Maximum ordered requests to process in every invocation of
+ * lio_process_ordered_list(). The function will continue to process requests
+ * as long as it can find one that has finished processing. If it keeps
+ * finding requests that have completed, the function can run for ever. The
+ * value defined here sets an upper limit on the number of requests it can
+ * process before it returns control to the poll thread.
+ */
+#define  MAX_ORD_REQS_TO_PROCESS   4096
+
+/** Head of a response list. There are several response lists in the
+ *  system. One for each response order- Unordered, ordered
+ *  and 1 for noresponse entries on each instruction queue.
+ */
+struct octeon_response_list {
+	/** List structure to add delete pending entries to */
+	struct list_head head;
+
+	/** A lock for this response list */
+	spinlock_t lock;
+
+	atomic_t pending_req_count;
+};
+
+/** The type of response list.
+ */
+enum {
+	OCTEON_ORDERED_LIST = 0,
+	OCTEON_UNORDERED_NONBLOCKING_LIST = 1,
+	OCTEON_UNORDERED_BLOCKING_LIST = 2,
+	OCTEON_ORDERED_SC_LIST = 3
+};
+
+/** Response Order values for a Octeon Request. */
+enum {
+	OCTEON_RESP_ORDERED = 0,
+	OCTEON_RESP_UNORDERED = 1,
+	OCTEON_RESP_NORESPONSE = 2
+};
+
+/** Error codes  used in Octeon Host-Core communication.
+ *
+ *   31            16 15            0
+ *   ---------------------------------
+ *   |               |               |
+ *   ---------------------------------
+ *   Error codes are 32-bit wide. The upper 16-bits, called Major Error Number,
+ *   are reserved to identify the group to which the error code belongs. The
+ *   lower 16-bits, called Minor Error Number, carry the actual code.
+ *
+ *   So error codes are (MAJOR NUMBER << 16)| MINOR_NUMBER.
+ */
+
+/*------------   Error codes used by host driver   -----------------*/
+#define DRIVER_MAJOR_ERROR_CODE           0x0000
+
+/**  A value of 0x00000000 indicates no error i.e. success */
+#define DRIVER_ERROR_NONE                 0x00000000
+
+/**  (Major number: 0x0000; Minor Number: 0x0001) */
+#define DRIVER_ERROR_REQ_PENDING          0x00000001
+#define DRIVER_ERROR_REQ_TIMEOUT          0x00000003
+#define DRIVER_ERROR_REQ_EINTR            0x00000004
+#define DRIVER_ERROR_REQ_ENXIO            0x00000006
+#define DRIVER_ERROR_REQ_ENOMEM           0x0000000C
+#define DRIVER_ERROR_REQ_EINVAL           0x00000016
+#define DRIVER_ERROR_REQ_FAILED           0x000000ff
+
+/** Status for a request.
+ * If a request is not queued to Octeon by the driver, the driver returns
+ * an error condition that's describe by one of the OCTEON_REQ_ERR_* value
+ * below. If the request is successfully queued, the driver will return
+ * a OCTEON_REQUEST_PENDING status. OCTEON_REQUEST_TIMEOUT and
+ * OCTEON_REQUEST_INTERRUPTED are only returned by the driver if the
+ * response for request failed to arrive before a time-out period or if
+ * the request processing * got interrupted due to a signal respectively.
+ */
+enum {
+	OCTEON_REQUEST_DONE = (DRIVER_ERROR_NONE),
+	OCTEON_REQUEST_PENDING = (DRIVER_ERROR_REQ_PENDING),
+	OCTEON_REQUEST_TIMEOUT = (DRIVER_ERROR_REQ_TIMEOUT),
+	OCTEON_REQUEST_INTERRUPTED = (DRIVER_ERROR_REQ_EINTR),
+	OCTEON_REQUEST_NO_DEVICE = (0x00000021),
+	OCTEON_REQUEST_NOT_RUNNING,
+	OCTEON_REQUEST_INVALID_IQ,
+	OCTEON_REQUEST_INVALID_BUFCNT,
+	OCTEON_REQUEST_INVALID_RESP_ORDER,
+	OCTEON_REQUEST_NO_MEMORY,
+	OCTEON_REQUEST_INVALID_BUFSIZE,
+	OCTEON_REQUEST_NO_PENDING_ENTRY,
+	OCTEON_REQUEST_NO_IQ_SPACE = (0x7FFFFFFF)
+
+};
+
+/** Initialize the response lists. The number of response lists to create is
+ * given by count.
+ * @param octeon_dev      - the octeon device structure.
+ */
+int octeon_setup_response_list(struct octeon_device *octeon_dev);
+
+void octeon_delete_response_list(struct octeon_device *octeon_dev);
+
+/** Checks the noresponse list associated with one of four instr queues.
+ * The new read index tells the driver that last entry in the instr queue
+ * where octeon has read an instr. The routine cleans up all entries from
+ * the previously marked (old) read index to the current (new) read index.
+ * @param oct		   - the octeon device structure.
+ * @param iq		   - the instruction queue structure.
+ */
+void lio_process_noresponse_list(struct octeon_device *oct,
+				 struct octeon_instr_queue *iq);
+
+/** Check the status of first entry in the ordered list. If the instruction at
+ * that entry finished processing or has timed-out, the entry is cleaned.
+ * @param octeon_dev  - the octeon device structure.
+ * @param force_quit - the request is forced to timeout if this is 1
+ * @return 1 if the ordered list is empty, 0 otherwise.
+ */
+int lio_process_ordered_list(struct octeon_device *octeon_dev,
+			     uint32_t force_quit);
+
+int
+octeon_register_reqtype_free_fn(struct octeon_device *oct, int reqtype,
+				void (*fn)(void *));
+
+#endif
-- 
1.8.4.2
