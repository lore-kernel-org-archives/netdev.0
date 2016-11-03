From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V4 9/9] liquidio CN23XX: fix for new check patch errors
Date: Thu, 3 Nov 2016 14:35:18 -0700
Message-ID: <1478208918-8330-10-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1478208918-8330-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0057.outbound.protection.outlook.com ([104.47.34.57]:60789
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933011AbcKCVgY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 17:36:24 -0400
In-Reply-To: <1478208918-8330-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New checkpatch script shows some errors with pre-existing
driver. This patch provides fix for those errors.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/cn23xx_pf_regs.h  |  12 +--
 drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h |  12 +--
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   |   2 +-
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |   9 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  15 +--
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  50 ++++-----
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 113 ++++++++++-----------
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  28 ++---
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  25 +++--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  40 ++++----
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |   3 +
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |   2 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   6 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |   2 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |  16 ++-
 15 files changed, 155 insertions(+), 180 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
index 680a405..e6d4ad9 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
@@ -58,7 +58,7 @@
 
 #define     CN23XX_CONFIG_SRIOV_BAR_START	   0x19C
 #define     CN23XX_CONFIG_SRIOV_BARX(i)		\
-		(CN23XX_CONFIG_SRIOV_BAR_START + (i * 4))
+		(CN23XX_CONFIG_SRIOV_BAR_START + ((i) * 4))
 #define     CN23XX_CONFIG_SRIOV_BAR_PF		   0x08
 #define     CN23XX_CONFIG_SRIOV_BAR_64BIT	   0x04
 #define     CN23XX_CONFIG_SRIOV_BAR_IO		   0x01
@@ -508,7 +508,7 @@
 /* 4 Registers (64 - bit) */
 #define    CN23XX_SLI_S2M_PORT_CTL_START         0x23D80
 #define    CN23XX_SLI_S2M_PORTX_CTL(port)	\
-		(CN23XX_SLI_S2M_PORT_CTL_START + (port * 0x10))
+		(CN23XX_SLI_S2M_PORT_CTL_START + ((port) * 0x10))
 
 #define    CN23XX_SLI_MAC_NUMBER                 0x20050
 
@@ -549,26 +549,26 @@
  * Provides DMA Engine Queue Enable
  */
 #define    CN23XX_DPI_DMA_ENG0_ENB        0x0001df0000000080ULL
-#define    CN23XX_DPI_DMA_ENG_ENB(eng) (CN23XX_DPI_DMA_ENG0_ENB + (eng * 8))
+#define    CN23XX_DPI_DMA_ENG_ENB(eng) (CN23XX_DPI_DMA_ENG0_ENB + ((eng) * 8))
 
 /* 8 register (64-bit) - DPI_DMA(0..7)_REQQ_CTL
  * Provides control bits for transaction on 8 Queues
  */
 #define    CN23XX_DPI_DMA_REQQ0_CTL       0x0001df0000000180ULL
 #define    CN23XX_DPI_DMA_REQQ_CTL(q_no)	\
-		(CN23XX_DPI_DMA_REQQ0_CTL + (q_no * 8))
+		(CN23XX_DPI_DMA_REQQ0_CTL + ((q_no) * 8))
 
 /* 6 register (64-bit) - DPI_ENG(0..5)_BUF
  * Provides DMA Engine FIFO (Queue) Size
  */
 #define    CN23XX_DPI_DMA_ENG0_BUF        0x0001df0000000880ULL
 #define    CN23XX_DPI_DMA_ENG_BUF(eng)   \
-		(CN23XX_DPI_DMA_ENG0_BUF + (eng * 8))
+		(CN23XX_DPI_DMA_ENG0_BUF + ((eng) * 8))
 
 /* 4 Registers (64-bit) */
 #define    CN23XX_DPI_SLI_PRT_CFG_START   0x0001df0000000900ULL
 #define    CN23XX_DPI_SLI_PRTX_CFG(port)        \
-		(CN23XX_DPI_SLI_PRT_CFG_START + (port * 0x8))
+		(CN23XX_DPI_SLI_PRT_CFG_START + ((port) * 0x8))
 
 /* Masks for DPI_DMA_CONTROL Register */
 #define    CN23XX_DPI_DMA_COMMIT_MODE     BIT_ULL(58)
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
index 23152c0..b248966 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
@@ -438,10 +438,10 @@
 #define    CN6XXX_SLI_S2M_PORT0_CTL              0x3D80
 #define    CN6XXX_SLI_S2M_PORT1_CTL              0x3D90
 #define    CN6XXX_SLI_S2M_PORTX_CTL(port)        \
-	(CN6XXX_SLI_S2M_PORT0_CTL + (port * 0x10))
+	(CN6XXX_SLI_S2M_PORT0_CTL + ((port) * 0x10))
 
 #define    CN6XXX_SLI_INT_ENB64(port)            \
-	(CN6XXX_SLI_INT_ENB64_PORT0 + (port * 0x10))
+	(CN6XXX_SLI_INT_ENB64_PORT0 + ((port) * 0x10))
 
 #define    CN6XXX_SLI_MAC_NUMBER                 0x3E00
 
@@ -453,7 +453,7 @@
 #define    CN6XXX_PCI_BAR1_OFFSET                  0x8
 
 #define    CN6XXX_BAR1_REG(idx, port) \
-		(CN6XXX_BAR1_INDEX_START + (port * CN6XXX_PEM_OFFSET) + \
+		(CN6XXX_BAR1_INDEX_START + ((port) * CN6XXX_PEM_OFFSET) + \
 		(CN6XXX_PCI_BAR1_OFFSET * (idx)))
 
 /*############################ DPI #########################*/
@@ -471,17 +471,17 @@
 #define    CN6XXX_DPI_DMA_ENG0_ENB        0x0001df0000000080ULL
 
 #define    CN6XXX_DPI_DMA_ENG_ENB(q_no)   \
-	(CN6XXX_DPI_DMA_ENG0_ENB + (q_no * 8))
+	(CN6XXX_DPI_DMA_ENG0_ENB + ((q_no) * 8))
 
 #define    CN6XXX_DPI_DMA_ENG0_BUF        0x0001df0000000880ULL
 
 #define    CN6XXX_DPI_DMA_ENG_BUF(q_no)   \
-	(CN6XXX_DPI_DMA_ENG0_BUF + (q_no * 8))
+	(CN6XXX_DPI_DMA_ENG0_BUF + ((q_no) * 8))
 
 #define    CN6XXX_DPI_SLI_PRT0_CFG        0x0001df0000000900ULL
 #define    CN6XXX_DPI_SLI_PRT1_CFG        0x0001df0000000908ULL
 #define    CN6XXX_DPI_SLI_PRTX_CFG(port)        \
-	(CN6XXX_DPI_SLI_PRT0_CFG + (port * 0x10))
+	(CN6XXX_DPI_SLI_PRT0_CFG + ((port) * 0x10))
 
 #define    CN6XXX_DPI_DMA_COMMIT_MODE     BIT_ULL(58)
 #define    CN6XXX_DPI_DMA_PKT_HP          BIT_ULL(57)
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
index 1e40f1a..50b533f 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
@@ -72,7 +72,7 @@ static void lio_cn68xx_setup_pkt_ctl_regs(struct octeon_device *oct)
 	pktctl = octeon_read_csr64(oct, CN6XXX_SLI_PKT_CTL);
 
 	/* 68XX specific */
-	max_oqs = CFG_GET_OQ_MAX_Q(CHIP_FIELD(oct, cn6xxx, conf));
+	max_oqs = CFG_GET_OQ_MAX_Q(CHIP_CONF(oct, cn6xxx));
 	tx_pipe  = octeon_read_csr64(oct, CN68XX_SLI_TX_PIPE);
 	tx_pipe &= 0xffffffffff00ffffULL; /* clear out NUMP field */
 	tx_pipe |= max_oqs << 16; /* put max_oqs in NUMP field */
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index c7c39a0..e233796 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -70,7 +70,6 @@ enum {
 	INTERFACE_MODE_MIXED,
 };
 
-#define ARRAY_LENGTH(a) (sizeof(a) / sizeof((a)[0]))
 #define OCT_ETHTOOL_REGDUMP_LEN  4096
 #define OCT_ETHTOOL_REGDUMP_LEN_23XX  (4096 * 11)
 #define OCT_ETHTOOL_REGSVER  1
@@ -255,14 +254,14 @@ static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	u32 max_rx = 0, max_tx = 0, tx_count = 0, rx_count = 0;
 
 	if (OCTEON_CN6XXX(oct)) {
-		struct octeon_config *conf6x = CHIP_FIELD(oct, cn6xxx, conf);
+		struct octeon_config *conf6x = CHIP_CONF(oct, cn6xxx);
 
 		max_rx = CFG_GET_OQ_MAX_Q(conf6x);
 		max_tx = CFG_GET_IQ_MAX_Q(conf6x);
 		rx_count = CFG_GET_NUM_RXQS_NIC_IF(conf6x, lio->ifidx);
 		tx_count = CFG_GET_NUM_TXQS_NIC_IF(conf6x, lio->ifidx);
 	} else if (OCTEON_CN23XX_PF(oct)) {
-		struct octeon_config *conf23 = CHIP_FIELD(oct, cn23xx_pf, conf);
+		struct octeon_config *conf23 = CHIP_CONF(oct, cn23xx_pf);
 
 		max_rx = CFG_GET_OQ_MAX_Q(conf23);
 		max_tx = CFG_GET_IQ_MAX_Q(conf23);
@@ -585,14 +584,14 @@ static int lio_set_phys_id(struct net_device *netdev,
 	    rx_pending = 0;
 
 	if (OCTEON_CN6XXX(oct)) {
-		struct octeon_config *conf6x = CHIP_FIELD(oct, cn6xxx, conf);
+		struct octeon_config *conf6x = CHIP_CONF(oct, cn6xxx);
 
 		tx_max_pending = CN6XXX_MAX_IQ_DESCRIPTORS;
 		rx_max_pending = CN6XXX_MAX_OQ_DESCRIPTORS;
 		rx_pending = CFG_GET_NUM_RX_DESCS_NIC_IF(conf6x, lio->ifidx);
 		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf6x, lio->ifidx);
 	} else if (OCTEON_CN23XX_PF(oct)) {
-		struct octeon_config *conf23 = CHIP_FIELD(oct, cn23xx_pf, conf);
+		struct octeon_config *conf23 = CHIP_CONF(oct, cn23xx_pf);
 
 		tx_max_pending = CN23XX_MAX_IQ_DESCRIPTORS;
 		rx_max_pending = CN23XX_MAX_OQ_DESCRIPTORS;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index bf0373a..05612d2 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -48,9 +48,6 @@
 
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
-#define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
-	(octeon_dev_ptr->instr_queue[iq_no]->stats.field += count)
-
 static int debug = -1;
 module_param(debug, int, 0644);
 MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
@@ -59,10 +56,6 @@
 module_param_string(fw_type, fw_type, sizeof(fw_type), 0000);
 MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded. Default \"nic\"");
 
-static int conf_type;
-module_param(conf_type, int, 0);
-MODULE_PARM_DESC(conf_type, "select octeon configuration 0 default 1 ovs");
-
 static int ptp_enable = 1;
 
 /* Bit mask values for lio->ifstate */
@@ -3720,7 +3713,7 @@ static int liquidio_set_vf_link_state(struct net_device *netdev, int vfidx,
 	return 0;
 }
 
-static struct net_device_ops lionetdevops = {
+static const struct net_device_ops lionetdevops = {
 	.ndo_open		= liquidio_open,
 	.ndo_stop		= liquidio_stop,
 	.ndo_start_xmit		= liquidio_xmit,
@@ -3741,6 +3734,7 @@ static int liquidio_set_vf_link_state(struct net_device *netdev, int vfidx,
 	.ndo_set_vf_vlan	= liquidio_set_vf_vlan,
 	.ndo_get_vf_config	= liquidio_get_vf_config,
 	.ndo_set_vf_link_state  = liquidio_set_vf_link_state,
+	.ndo_select_queue	= select_q
 };
 
 /** \brief Entry point for the liquidio module
@@ -3752,7 +3746,7 @@ static int __init liquidio_init(void)
 
 	init_completion(&first_stage);
 
-	octeon_init_device_list(conf_type);
+	octeon_init_device_list(OCTEON_CONFIG_TYPE_DEFAULT);
 
 	if (liquidio_init_pci())
 		return -EINVAL;
@@ -3973,9 +3967,6 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		SET_NETDEV_DEV(netdev, &octeon_dev->pci_dev->dev);
 
-		if (num_iqueues > 1)
-			lionetdevops.ndo_select_queue = select_q;
-
 		/* Associate the routines that will handle different
 		 * netdev tasks.
 		 */
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 82a4eed..f308ee4 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -66,7 +66,7 @@ enum octeon_tag_type {
 /* Subcodes are used by host driver/apps to identify the sub-operation
  * for the core. They only need to by unique for a given subsystem.
  */
-#define OPCODE_SUBCODE(op, sub)       (((op & 0x0f) << 8) | ((sub) & 0x7f))
+#define OPCODE_SUBCODE(op, sub)       ((((op) & 0x0f) << 8) | ((sub) & 0x7f))
 
 /** OPCODE_CORE subcodes. For future use. */
 
@@ -89,10 +89,6 @@ enum octeon_tag_type {
 
 #define CORE_DRV_TEST_SCATTER_OP    0xFFF5
 
-#define OPCODE_SLOW_PATH(rh)  \
-	(OPCODE_SUBCODE(rh->r.opcode, rh->r.subcode) != \
-		OPCODE_SUBCODE(OPCODE_NIC, OPCODE_NIC_NW_DATA))
-
 /* Application codes advertised by the core driver initialization packet. */
 #define CVM_DRV_APP_START           0x0
 #define CVM_DRV_NO_APP              0
@@ -102,31 +98,15 @@ enum octeon_tag_type {
 #define CVM_DRV_INVALID_APP         (CVM_DRV_APP_START + 0x2)
 #define CVM_DRV_APP_END             (CVM_DRV_INVALID_APP - 1)
 
-/* Macro to increment index.
- * Index is incremented by count; if the sum exceeds
- * max, index is wrapped-around to the start.
- */
-#define INCR_INDEX(index, count, max)                \
-do {                                                 \
-	if (((index) + (count)) >= (max))            \
-		index = ((index) + (count)) - (max); \
-	else                                         \
-		index += (count);                    \
-} while (0)
-
-#define INCR_INDEX_BY1(index, max)	\
-do {                                    \
-	if ((++(index)) == (max))       \
-		index = 0;	        \
-} while (0)
-
-#define DECR_INDEX(index, count, max)                  \
-do {						       \
-	if ((count) > (index))                         \
-		index = ((max) - ((count - index)));   \
-	else                                           \
-		index -= count;			       \
-} while (0)
+static inline u32 incr_index(u32 index, u32 count, u32 max)
+{
+	if ((index + count) >= max)
+		index = index + count - max;
+	else
+		index += count;
+
+	return index;
+}
 
 #define OCT_BOARD_NAME 32
 #define OCT_SERIAL_LEN 64
@@ -827,6 +807,16 @@ struct oct_link_stats {
 
 };
 
+static inline int opcode_slow_path(union octeon_rh *rh)
+{
+	u16 subcode1, subcode2;
+
+	subcode1 = OPCODE_SUBCODE((rh)->r.opcode, (rh)->r.subcode);
+	subcode2 = OPCODE_SUBCODE(OPCODE_NIC, OPCODE_NIC_NW_DATA);
+
+	return (subcode2 != subcode1);
+}
+
 #define LIO68XX_LED_CTRL_ADDR     0x3501
 #define LIO68XX_LED_CTRL_CFGON    0x1f
 #define LIO68XX_LED_CTRL_CFGOFF   0x100
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index c0089ed..3265e0b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -138,46 +138,6 @@ struct octeon_pci_console_desc {
 };
 
 /**
- * This macro returns the size of a member of a structure.
- * Logically it is the same as "sizeof(s::field)" in C++, but
- * C lacks the "::" operator.
- */
-#define SIZEOF_FIELD(s, field) sizeof(((s *)NULL)->field)
-
-/**
- * This macro returns a member of the cvmx_bootmem_desc
- * structure. These members can't be directly addressed as
- * they might be in memory not directly reachable. In the case
- * where bootmem is compiled with LINUX_HOST, the structure
- * itself might be located on a remote Octeon. The argument
- * "field" is the member name of the cvmx_bootmem_desc to read.
- * Regardless of the type of the field, the return type is always
- * a u64.
- */
-#define CVMX_BOOTMEM_DESC_GET_FIELD(oct, field)                              \
-	__cvmx_bootmem_desc_get(oct, oct->bootmem_desc_addr,                 \
-				offsetof(struct cvmx_bootmem_desc, field),   \
-				SIZEOF_FIELD(struct cvmx_bootmem_desc, field))
-
-#define __cvmx_bootmem_lock(flags)	(flags = flags)
-#define __cvmx_bootmem_unlock(flags)	(flags = flags)
-
-/**
- * This macro returns a member of the
- * cvmx_bootmem_named_block_desc structure. These members can't
- * be directly addressed as they might be in memory not directly
- * reachable. In the case where bootmem is compiled with
- * LINUX_HOST, the structure itself might be located on a remote
- * Octeon. The argument "field" is the member name of the
- * cvmx_bootmem_named_block_desc to read. Regardless of the type
- * of the field, the return type is always a u64. The "addr"
- * parameter is the physical address of the structure.
- */
-#define CVMX_BOOTMEM_NAMED_GET_FIELD(oct, addr, field)                   \
-	__cvmx_bootmem_desc_get(oct, addr,                               \
-		offsetof(struct cvmx_bootmem_named_block_desc, field),   \
-		SIZEOF_FIELD(struct cvmx_bootmem_named_block_desc, field))
-/**
  * \brief determines if a given console has debug enabled.
  * @param console console to check
  * @returns  1 = enabled. 0 otherwise
@@ -258,10 +218,15 @@ static int __cvmx_bootmem_check_version(struct octeon_device *oct,
 		oct->bootmem_desc_addr =
 			octeon_read_device_mem64(oct,
 						 BOOTLOADER_PCI_READ_DESC_ADDR);
-	major_version =
-		(u32)CVMX_BOOTMEM_DESC_GET_FIELD(oct, major_version);
-	minor_version =
-		(u32)CVMX_BOOTMEM_DESC_GET_FIELD(oct, minor_version);
+	major_version = (u32)__cvmx_bootmem_desc_get(
+			oct, oct->bootmem_desc_addr,
+			offsetof(struct cvmx_bootmem_desc, major_version),
+			FIELD_SIZEOF(struct cvmx_bootmem_desc, major_version));
+	minor_version = (u32)__cvmx_bootmem_desc_get(
+			oct, oct->bootmem_desc_addr,
+			offsetof(struct cvmx_bootmem_desc, minor_version),
+			FIELD_SIZEOF(struct cvmx_bootmem_desc, minor_version));
+
 	dev_dbg(&oct->pci_dev->dev, "%s: major_version=%d\n", __func__,
 		major_version);
 	if ((major_version > 3) ||
@@ -284,10 +249,20 @@ static int __cvmx_bootmem_check_version(struct octeon_device *oct,
 	u64 named_addr = cvmx_bootmem_phy_named_block_find(oct, name, flags);
 
 	if (named_addr) {
-		desc->base_addr = CVMX_BOOTMEM_NAMED_GET_FIELD(oct, named_addr,
-							       base_addr);
-		desc->size =
-			CVMX_BOOTMEM_NAMED_GET_FIELD(oct, named_addr, size);
+		desc->base_addr = __cvmx_bootmem_desc_get(
+				oct, named_addr,
+				offsetof(struct cvmx_bootmem_named_block_desc,
+					 base_addr),
+				FIELD_SIZEOF(
+					struct cvmx_bootmem_named_block_desc,
+					base_addr));
+		desc->size = __cvmx_bootmem_desc_get(oct, named_addr,
+				offsetof(struct cvmx_bootmem_named_block_desc,
+					 size),
+				FIELD_SIZEOF(
+					struct cvmx_bootmem_named_block_desc,
+					size));
+
 		strncpy(desc->name, name, sizeof(desc->name));
 		desc->name[sizeof(desc->name) - 1] = 0;
 		return &oct->bootmem_named_block_desc;
@@ -302,22 +277,41 @@ static u64 cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
 {
 	u64 result = 0;
 
-	__cvmx_bootmem_lock(flags);
 	if (!__cvmx_bootmem_check_version(oct, 3)) {
 		u32 i;
-		u64 named_block_array_addr =
-			CVMX_BOOTMEM_DESC_GET_FIELD(oct,
-						    named_block_array_addr);
-		u32 num_blocks = (u32)
-			CVMX_BOOTMEM_DESC_GET_FIELD(oct, nb_num_blocks);
-		u32 name_length = (u32)
-			CVMX_BOOTMEM_DESC_GET_FIELD(oct, named_block_name_len);
+
+		u64 named_block_array_addr = __cvmx_bootmem_desc_get(
+					oct, oct->bootmem_desc_addr,
+					offsetof(struct cvmx_bootmem_desc,
+						 named_block_array_addr),
+					FIELD_SIZEOF(struct cvmx_bootmem_desc,
+						     named_block_array_addr));
+		u32 num_blocks = (u32)__cvmx_bootmem_desc_get(
+					oct, oct->bootmem_desc_addr,
+					offsetof(struct cvmx_bootmem_desc,
+						 nb_num_blocks),
+					FIELD_SIZEOF(struct cvmx_bootmem_desc,
+						     nb_num_blocks));
+
+		u32 name_length = (u32)__cvmx_bootmem_desc_get(
+					oct, oct->bootmem_desc_addr,
+					offsetof(struct cvmx_bootmem_desc,
+						 named_block_name_len),
+					FIELD_SIZEOF(struct cvmx_bootmem_desc,
+						     named_block_name_len));
+
 		u64 named_addr = named_block_array_addr;
 
 		for (i = 0; i < num_blocks; i++) {
-			u64 named_size =
-				CVMX_BOOTMEM_NAMED_GET_FIELD(oct, named_addr,
-							     size);
+			u64 named_size = __cvmx_bootmem_desc_get(
+					oct, named_addr,
+					 offsetof(
+					struct cvmx_bootmem_named_block_desc,
+					size),
+					 FIELD_SIZEOF(
+					struct cvmx_bootmem_named_block_desc,
+					size));
+
 			if (name && named_size) {
 				char *name_tmp =
 					kmalloc(name_length + 1, GFP_KERNEL);
@@ -342,7 +336,6 @@ static u64 cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
 				sizeof(struct cvmx_bootmem_named_block_desc);
 		}
 	}
-	__cvmx_bootmem_unlock(flags);
 	return result;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 4a30d7c..79c8875 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -516,11 +516,6 @@
 	}
 };
 
-enum {
-	OCTEON_CONFIG_TYPE_DEFAULT = 0,
-	NUM_OCTEON_CONFS,
-};
-
 static struct octeon_config_ptr {
 	u32 conf_type;
 } oct_conf_info[MAX_OCTEON_DEVICES] = {
@@ -792,10 +787,9 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 
 	if (OCTEON_CN6XXX(oct))
 		num_descs =
-			CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
+			CFG_GET_NUM_DEF_TX_DESCS(CHIP_CONF(oct, cn6xxx));
 	else if (OCTEON_CN23XX_PF(oct))
-		num_descs = CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn23xx_pf,
-								conf));
+		num_descs = CFG_GET_NUM_DEF_TX_DESCS(CHIP_CONF(oct, cn23xx_pf));
 
 	oct->num_iqs = 0;
 
@@ -835,14 +829,12 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 
 	if (OCTEON_CN6XXX(oct)) {
 		num_descs =
-			CFG_GET_NUM_DEF_RX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
+			CFG_GET_NUM_DEF_RX_DESCS(CHIP_CONF(oct, cn6xxx));
 		desc_size =
-			CFG_GET_DEF_RX_BUF_SIZE(CHIP_FIELD(oct, cn6xxx, conf));
+			CFG_GET_DEF_RX_BUF_SIZE(CHIP_CONF(oct, cn6xxx));
 	} else if (OCTEON_CN23XX_PF(oct)) {
-		num_descs = CFG_GET_NUM_DEF_RX_DESCS(CHIP_FIELD(oct, cn23xx_pf,
-								conf));
-		desc_size = CFG_GET_DEF_RX_BUF_SIZE(CHIP_FIELD(oct, cn23xx_pf,
-							       conf));
+		num_descs = CFG_GET_NUM_DEF_RX_DESCS(CHIP_CONF(oct, cn23xx_pf));
+		desc_size = CFG_GET_DEF_RX_BUF_SIZE(CHIP_CONF(oct, cn23xx_pf));
 	}
 	oct->num_oqs = 0;
 	oct->droq[0] = vmalloc_node(sizeof(*oct->droq[0]), numa_node);
@@ -1071,10 +1063,10 @@ int octeon_core_drv_init(struct octeon_recv_info *recv_info, void *buf)
 
 	if (OCTEON_CN6XXX(oct))
 		num_nic_ports =
-			CFG_GET_NUM_NIC_PORTS(CHIP_FIELD(oct, cn6xxx, conf));
+			CFG_GET_NUM_NIC_PORTS(CHIP_CONF(oct, cn6xxx));
 	else if (OCTEON_CN23XX_PF(oct))
 		num_nic_ports =
-			CFG_GET_NUM_NIC_PORTS(CHIP_FIELD(oct, cn23xx_pf, conf));
+			CFG_GET_NUM_NIC_PORTS(CHIP_CONF(oct, cn23xx_pf));
 
 	if (atomic_read(&oct->status) >= OCT_DEV_RUNNING) {
 		dev_err(&oct->pci_dev->dev, "Received CORE OK when device state is 0x%x\n",
@@ -1169,10 +1161,10 @@ struct octeon_config *octeon_get_conf(struct octeon_device *oct)
 
 	if (OCTEON_CN6XXX(oct)) {
 		default_oct_conf =
-			(struct octeon_config *)(CHIP_FIELD(oct, cn6xxx, conf));
+			(struct octeon_config *)(CHIP_CONF(oct, cn6xxx));
 	} else if (OCTEON_CN23XX_PF(oct)) {
 		default_oct_conf = (struct octeon_config *)
-			(CHIP_FIELD(oct, cn23xx_pf, conf));
+			(CHIP_CONF(oct, cn23xx_pf));
 	}
 	return default_oct_conf;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index c59b77e..5ce2048 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -48,6 +48,11 @@ enum octeon_pci_swap_mode {
 	OCTEON_PCI_32BIT_LW_SWAP = 3
 };
 
+enum {
+	OCTEON_CONFIG_TYPE_DEFAULT = 0,
+	NUM_OCTEON_CONFS,
+};
+
 #define  OCTEON_OUTPUT_INTR   (2)
 #define  OCTEON_MBOX_INTR     (4)
 #define  OCTEON_ALL_INTR      0xff
@@ -524,12 +529,14 @@ struct octeon_device {
 
 #define  OCT_DRV_ONLINE 1
 #define  OCT_DRV_OFFLINE 2
-#define  OCTEON_CN6XXX(oct)           ((oct->chip_id == OCTEON_CN66XX) || \
-				       (oct->chip_id == OCTEON_CN68XX))
-#define  OCTEON_CN23XX_PF(oct)        (oct->chip_id == OCTEON_CN23XX_PF_VID)
+#define  OCTEON_CN6XXX(oct)	({					\
+				 typeof(oct) _oct = (oct);		\
+				 ((_oct->chip_id == OCTEON_CN66XX) ||	\
+				  (_oct->chip_id == OCTEON_CN68XX));	})
+#define  OCTEON_CN23XX_PF(oct)        ((oct)->chip_id == OCTEON_CN23XX_PF_VID)
 #define  OCTEON_CN23XX_VF(oct)        ((oct)->chip_id == OCTEON_CN23XX_VF_VID)
-#define CHIP_FIELD(oct, TYPE, field)             \
-	(((struct octeon_ ## TYPE  *)(oct->chip))->field)
+#define CHIP_CONF(oct, TYPE)             \
+	(((struct octeon_ ## TYPE  *)((oct)->chip))->conf)
 
 struct oct_intrmod_cmd {
 	struct octeon_device *oct_dev;
@@ -641,16 +648,16 @@ static inline u16 OCTEON_MINOR_REV(struct octeon_device *oct)
 
 /* Routines for reading and writing CSRs */
 #define   octeon_write_csr(oct_dev, reg_off, value) \
-		writel(value, oct_dev->mmio[0].hw_addr + reg_off)
+		writel(value, (oct_dev)->mmio[0].hw_addr + (reg_off))
 
 #define   octeon_write_csr64(oct_dev, reg_off, val64) \
-		writeq(val64, oct_dev->mmio[0].hw_addr + reg_off)
+		writeq(val64, (oct_dev)->mmio[0].hw_addr + (reg_off))
 
 #define   octeon_read_csr(oct_dev, reg_off)         \
-		readl(oct_dev->mmio[0].hw_addr + reg_off)
+		readl((oct_dev)->mmio[0].hw_addr + (reg_off))
 
 #define   octeon_read_csr64(oct_dev, reg_off)         \
-		readq(oct_dev->mmio[0].hw_addr + reg_off)
+		readq((oct_dev)->mmio[0].hw_addr + (reg_off))
 
 /**
  * Checks if memory access is okay
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index d7ba000..8bf1ac76 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -29,9 +29,6 @@
 #include "cn66xx_device.h"
 #include "cn23xx_pf_device.h"
 
-#define     CVM_MIN(d1, d2)           (((d1) < (d2)) ? (d1) : (d2))
-#define     CVM_MAX(d1, d2)           (((d1) > (d2)) ? (d1) : (d2))
-
 struct niclist {
 	struct list_head list;
 	void *ptr;
@@ -254,13 +251,13 @@ int octeon_init_droq(struct octeon_device *oct,
 	c_num_descs = num_descs;
 	c_buf_size = desc_size;
 	if (OCTEON_CN6XXX(oct)) {
-		struct octeon_config *conf6x = CHIP_FIELD(oct, cn6xxx, conf);
+		struct octeon_config *conf6x = CHIP_CONF(oct, cn6xxx);
 
 		c_pkts_per_intr = (u32)CFG_GET_OQ_PKTS_PER_INTR(conf6x);
 		c_refill_threshold =
 			(u32)CFG_GET_OQ_REFILL_THRESHOLD(conf6x);
 	} else if (OCTEON_CN23XX_PF(oct)) {
-		struct octeon_config *conf23 = CHIP_FIELD(oct, cn23xx_pf, conf);
+		struct octeon_config *conf23 = CHIP_CONF(oct, cn23xx_pf);
 
 		c_pkts_per_intr = (u32)CFG_GET_OQ_PKTS_PER_INTR(conf23);
 		c_refill_threshold = (u32)CFG_GET_OQ_REFILL_THRESHOLD(conf23);
@@ -405,7 +402,7 @@ static inline struct octeon_recv_info *octeon_create_recv_info(
 		recv_pkt->buffer_ptr[i] = droq->recv_buf_list[idx].buffer;
 		droq->recv_buf_list[idx].buffer = NULL;
 
-		INCR_INDEX_BY1(idx, droq->max_count);
+		idx = incr_index(idx, 1, droq->max_count);
 		bytes_left -= droq->buffer_size;
 		i++;
 		buf_cnt--;
@@ -436,14 +433,15 @@ static inline struct octeon_recv_info *octeon_create_recv_info(
 			droq->recv_buf_list[refill_index].buffer = NULL;
 			desc_ring[refill_index].buffer_ptr = 0;
 			do {
-				INCR_INDEX_BY1(droq->refill_idx,
-					       droq->max_count);
+				droq->refill_idx = incr_index(droq->refill_idx,
+							      1,
+							      droq->max_count);
 				desc_refilled++;
 				droq->refill_count--;
 			} while (droq->recv_buf_list[droq->refill_idx].
 				 buffer);
 		}
-		INCR_INDEX_BY1(refill_index, droq->max_count);
+		refill_index = incr_index(refill_index, 1, droq->max_count);
 	}                       /* while */
 	return desc_refilled;
 }
@@ -510,7 +508,8 @@ static inline struct octeon_recv_info *octeon_create_recv_info(
 		/* Reset any previous values in the length field. */
 		droq->info_list[droq->refill_idx].length = 0;
 
-		INCR_INDEX_BY1(droq->refill_idx, droq->max_count);
+		droq->refill_idx = incr_index(droq->refill_idx, 1,
+					      droq->max_count);
 		desc_refilled++;
 		droq->refill_count--;
 	}
@@ -595,7 +594,8 @@ static inline void octeon_droq_drop_packets(struct octeon_device *oct,
 			buf_cnt = 1;
 		}
 
-		INCR_INDEX(droq->read_idx, buf_cnt, droq->max_count);
+		droq->read_idx = incr_index(droq->read_idx, buf_cnt,
+					    droq->max_count);
 		droq->refill_count += buf_cnt;
 	}
 }
@@ -635,11 +635,12 @@ static inline void octeon_droq_drop_packets(struct octeon_device *oct,
 		rh = &info->rh;
 
 		total_len += (u32)info->length;
-		if (OPCODE_SLOW_PATH(rh)) {
+		if (opcode_slow_path(rh)) {
 			u32 buf_cnt;
 
 			buf_cnt = octeon_droq_dispatch_pkt(oct, droq, rh, info);
-			INCR_INDEX(droq->read_idx, buf_cnt, droq->max_count);
+			droq->read_idx = incr_index(droq->read_idx,
+						    buf_cnt, droq->max_count);
 			droq->refill_count += buf_cnt;
 		} else {
 			if (info->length <= droq->buffer_size) {
@@ -653,7 +654,8 @@ static inline void octeon_droq_drop_packets(struct octeon_device *oct,
 				droq->recv_buf_list[droq->read_idx].buffer =
 					NULL;
 
-				INCR_INDEX_BY1(droq->read_idx, droq->max_count);
+				droq->read_idx = incr_index(droq->read_idx, 1,
+							    droq->max_count);
 				droq->refill_count++;
 			} else {
 				nicbuf = octeon_fast_packet_alloc((u32)
@@ -685,8 +687,9 @@ static inline void octeon_droq_drop_packets(struct octeon_device *oct,
 					}
 
 					pkt_len += cpy_len;
-					INCR_INDEX_BY1(droq->read_idx,
-						       droq->max_count);
+					droq->read_idx =
+						incr_index(droq->read_idx, 1,
+							   droq->max_count);
 					droq->refill_count++;
 				}
 			}
@@ -800,9 +803,8 @@ static inline void octeon_droq_drop_packets(struct octeon_device *oct,
 	while (total_pkts_processed < budget) {
 		octeon_droq_check_hw_for_pkts(droq);
 
-		pkts_available =
-			CVM_MIN((budget - total_pkts_processed),
-				(u32)(atomic_read(&droq->pkts_pending)));
+		pkts_available = min((budget - total_pkts_processed),
+				     (u32)(atomic_read(&droq->pkts_pending)));
 
 		if (pkts_available == 0)
 			break;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index c67152a..e04ca8f 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -303,6 +303,9 @@ struct octeon_sc_buffer_pool {
 	atomic_t alloc_buf_count;
 };
 
+#define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
+		(((octeon_dev_ptr)->instr_queue[iq_no]->stats.field) += count)
+
 int octeon_setup_sc_buffer_pool(struct octeon_device *oct);
 int octeon_free_sc_buffer_pool(struct octeon_device *oct);
 struct octeon_soft_command *
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 98d8066d..13a18c9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -36,7 +36,7 @@
 	oct->fn_list.bar1_idx_write(oct, idx, mask);
 }
 #else
-#define octeon_toggle_bar1_swapmode(oct, idx) (oct = oct)
+#define octeon_toggle_bar1_swapmode(oct, idx)
 #endif
 
 static void
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 172b70e..e94edc8 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -128,7 +128,7 @@ struct lio {
 #define LIO_SIZE         (sizeof(struct lio))
 #define GET_LIO(netdev)  ((struct lio *)netdev_priv(netdev))
 
-#define CIU3_WDOG(c)                 (0x1010000020000ULL + (c << 3))
+#define CIU3_WDOG(c)                 (0x1010000020000ULL + ((c) << 3))
 #define CIU3_WDOG_MASK               12ULL
 #define LIO_MONITOR_WDOG_EXPIRE      1
 #define LIO_MONITOR_CORE_STUCK_MSGD  2
@@ -339,9 +339,9 @@ static inline void tx_buffer_free(void *buffer)
 }
 
 #define lio_dma_alloc(oct, size, dma_addr) \
-	dma_alloc_coherent(&oct->pci_dev->dev, size, dma_addr, GFP_KERNEL)
+	dma_alloc_coherent(&(oct)->pci_dev->dev, size, dma_addr, GFP_KERNEL)
 #define lio_dma_free(oct, size, virt_addr, dma_addr) \
-	dma_free_coherent(&oct->pci_dev->dev, size, virt_addr, dma_addr)
+	dma_free_coherent(&(oct)->pci_dev->dev, size, virt_addr, dma_addr)
 
 static inline
 void *get_rbd(struct sk_buff *skb)
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index b059979..0c7a5c9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -64,7 +64,7 @@ struct octnic_ctrl_pkt {
 	octnic_ctrl_pkt_cb_fn_t cb_fn;
 };
 
-#define MAX_UDD_SIZE(nctrl) (sizeof(nctrl->udd))
+#define MAX_UDD_SIZE(nctrl) (sizeof((nctrl)->udd))
 
 /** Structure of data information passed by the NIC module to the OSI
  * layer when forwarding data to Octeon device software.
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 0cc1583..8531a00 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -29,9 +29,6 @@
 #include "cn66xx_device.h"
 #include "cn23xx_pf_device.h"
 
-#define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
-	(octeon_dev_ptr->instr_queue[iq_no]->stats.field += count)
-
 struct iq_post_status {
 	int status;
 	int index;
@@ -68,9 +65,9 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	int numa_node = cpu_to_node(iq_no % num_online_cpus());
 
 	if (OCTEON_CN6XXX(oct))
-		conf = &(CFG_GET_IQ_CFG(CHIP_FIELD(oct, cn6xxx, conf)));
+		conf = &(CFG_GET_IQ_CFG(CHIP_CONF(oct, cn6xxx)));
 	else if (OCTEON_CN23XX_PF(oct))
-		conf = &(CFG_GET_IQ_CFG(CHIP_FIELD(oct, cn23xx_pf, conf)));
+		conf = &(CFG_GET_IQ_CFG(CHIP_CONF(oct, cn23xx_pf)));
 	if (!conf) {
 		dev_err(&oct->pci_dev->dev, "Unsupported Chip %x\n",
 			oct->chip_id);
@@ -182,10 +179,10 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 
 	if (OCTEON_CN6XXX(oct))
 		desc_size =
-		    CFG_GET_IQ_INSTR_TYPE(CHIP_FIELD(oct, cn6xxx, conf));
+		    CFG_GET_IQ_INSTR_TYPE(CHIP_CONF(oct, cn6xxx));
 	else if (OCTEON_CN23XX_PF(oct))
 		desc_size =
-		    CFG_GET_IQ_INSTR_TYPE(CHIP_FIELD(oct, cn23xx_pf, conf));
+		    CFG_GET_IQ_INSTR_TYPE(CHIP_CONF(oct, cn23xx_pf));
 
 	vfree(iq->request_list);
 
@@ -317,7 +314,8 @@ static inline void __copy_cmd_into_iq(struct octeon_instr_queue *iq,
 
 	/* "index" is returned, host_write_index is modified. */
 	st.index = iq->host_write_index;
-	INCR_INDEX_BY1(iq->host_write_index, iq->max_count);
+	iq->host_write_index = incr_index(iq->host_write_index, 1,
+					  iq->max_count);
 	iq->fill_cnt++;
 
 	/* Flush the command into memory. We need to be sure the data is in
@@ -432,7 +430,7 @@ static inline void __copy_cmd_into_iq(struct octeon_instr_queue *iq,
 
  skip_this:
 		inst_count++;
-		INCR_INDEX_BY1(old, iq->max_count);
+		old = incr_index(old, 1, iq->max_count);
 
 		if ((napi_budget) && (inst_count >= napi_budget))
 			break;
-- 
1.8.3.1
