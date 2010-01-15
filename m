From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/8] qlge: Add data for firmware dump.
Date: Fri, 15 Jan 2010 15:31:27 -0800
Message-ID: <1263598294-5685-2-git-send-email-ron.mercer@qlogic.com>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758447Ab0AOXiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:09 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |  403 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 398 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index ee0e2bd..a265325 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -75,15 +75,43 @@
 #define TX_DESC_PER_OAL 0
 #endif
 
+/* Word shifting for converting 64-bit
+ * address to a series of 16-bit words.
+ * This is used for some MPI firmware
+ * mailbox commands.
+ */
+#define LSW(x)  ((u16)(x))
+#define MSW(x)  ((u16)((u32)(x) >> 16))
+#define LSD(x)  ((u32)((u64)(x)))
+#define MSD(x)  ((u32)((((u64)(x)) >> 32)))
+
 /* MPI test register definitions. This register
  * is used for determining alternate NIC function's
  * PCI->func number.
  */
 enum {
 	MPI_TEST_FUNC_PORT_CFG = 0x1002,
+	MPI_TEST_FUNC_PRB_CTL = 0x100e,
+		MPI_TEST_FUNC_PRB_EN = 0x18a20000,
+	MPI_TEST_FUNC_RST_STS = 0x100a,
+		MPI_TEST_FUNC_RST_FRC = 0x00000003,
+	MPI_TEST_NIC_FUNC_MASK = 0x00000007,
+	MPI_TEST_NIC1_FUNCTION_ENABLE = (1 << 0),
+	MPI_TEST_NIC1_FUNCTION_MASK = 0x0000000e,
 	MPI_TEST_NIC1_FUNC_SHIFT = 1,
+	MPI_TEST_NIC2_FUNCTION_ENABLE = (1 << 4),
+	MPI_TEST_NIC2_FUNCTION_MASK = 0x000000e0,
 	MPI_TEST_NIC2_FUNC_SHIFT = 5,
-	MPI_TEST_NIC_FUNC_MASK = 0x00000007,
+	MPI_TEST_FC1_FUNCTION_ENABLE = (1 << 8),
+	MPI_TEST_FC1_FUNCTION_MASK	= 0x00000e00,
+	MPI_TEST_FC1_FUNCTION_SHIFT = 9,
+	MPI_TEST_FC2_FUNCTION_ENABLE = (1 << 12),
+	MPI_TEST_FC2_FUNCTION_MASK = 0x0000e000,
+	MPI_TEST_FC2_FUNCTION_SHIFT = 13,
+
+	MPI_NIC_READ = 0x00000000,
+	MPI_NIC_REG_BLOCK = 0x00020000,
+	MPI_NIC_FUNCTION_SHIFT = 6,
 };
 
 /*
@@ -464,7 +492,7 @@ enum {
 	MDIO_PORT = 0x00000440,
 	MDIO_STATUS = 0x00000450,
 
-	/* XGMAC AUX statistics  registers */
+	XGMAC_REGISTER_END = 0x00000740,
 };
 
 /*
@@ -505,6 +533,7 @@ enum {
 enum {
 	MAC_ADDR_IDX_SHIFT = 4,
 	MAC_ADDR_TYPE_SHIFT = 16,
+	MAC_ADDR_TYPE_COUNT = 10,
 	MAC_ADDR_TYPE_MASK = 0x000f0000,
 	MAC_ADDR_TYPE_CAM_MAC = 0x00000000,
 	MAC_ADDR_TYPE_MULTI_MAC = 0x00010000,
@@ -522,6 +551,30 @@ enum {
 	MAC_ADDR_MR = (1 << 30),
 	MAC_ADDR_MW = (1 << 31),
 	MAX_MULTICAST_ENTRIES = 32,
+
+	/* Entry count and words per entry
+	 * for each address type in the filter.
+	 */
+	MAC_ADDR_MAX_CAM_ENTRIES = 512,
+	MAC_ADDR_MAX_CAM_WCOUNT = 3,
+	MAC_ADDR_MAX_MULTICAST_ENTRIES = 32,
+	MAC_ADDR_MAX_MULTICAST_WCOUNT = 2,
+	MAC_ADDR_MAX_VLAN_ENTRIES = 4096,
+	MAC_ADDR_MAX_VLAN_WCOUNT = 1,
+	MAC_ADDR_MAX_MCAST_FLTR_ENTRIES = 4096,
+	MAC_ADDR_MAX_MCAST_FLTR_WCOUNT = 1,
+	MAC_ADDR_MAX_FC_MAC_ENTRIES = 4,
+	MAC_ADDR_MAX_FC_MAC_WCOUNT = 2,
+	MAC_ADDR_MAX_MGMT_MAC_ENTRIES = 8,
+	MAC_ADDR_MAX_MGMT_MAC_WCOUNT = 2,
+	MAC_ADDR_MAX_MGMT_VLAN_ENTRIES = 16,
+	MAC_ADDR_MAX_MGMT_VLAN_WCOUNT = 1,
+	MAC_ADDR_MAX_MGMT_V4_ENTRIES = 4,
+	MAC_ADDR_MAX_MGMT_V4_WCOUNT = 1,
+	MAC_ADDR_MAX_MGMT_V6_ENTRIES = 4,
+	MAC_ADDR_MAX_MGMT_V6_WCOUNT = 4,
+	MAC_ADDR_MAX_MGMT_TU_DP_ENTRIES = 4,
+	MAC_ADDR_MAX_MGMT_TU_DP_WCOUNT = 1,
 };
 
 /*
@@ -592,6 +645,7 @@ enum {
 enum {
 	RT_IDX_IDX_SHIFT = 8,
 	RT_IDX_TYPE_MASK = 0x000f0000,
+	RT_IDX_TYPE_SHIFT = 16,
 	RT_IDX_TYPE_RT = 0x00000000,
 	RT_IDX_TYPE_RT_INV = 0x00010000,
 	RT_IDX_TYPE_NICQ = 0x00020000,
@@ -660,7 +714,89 @@ enum {
 	RT_IDX_UNUSED013 = 13,
 	RT_IDX_UNUSED014 = 14,
 	RT_IDX_PROMISCUOUS_SLOT = 15,
-	RT_IDX_MAX_SLOTS = 16,
+	RT_IDX_MAX_RT_SLOTS = 8,
+	RT_IDX_MAX_NIC_SLOTS = 16,
+};
+
+/*
+ * Serdes Address Register (XG_SERDES_ADDR) bit definitions.
+ */
+enum {
+	XG_SERDES_ADDR_RDY = (1 << 31),
+	XG_SERDES_ADDR_R = (1 << 30),
+
+	XG_SERDES_ADDR_STS = 0x00001E06,
+	XG_SERDES_ADDR_XFI1_PWR_UP = 0x00000005,
+	XG_SERDES_ADDR_XFI2_PWR_UP = 0x0000000a,
+	XG_SERDES_ADDR_XAUI_PWR_DOWN = 0x00000001,
+
+	/* Serdes coredump definitions. */
+	XG_SERDES_XAUI_AN_START = 0x00000000,
+	XG_SERDES_XAUI_AN_END = 0x00000034,
+	XG_SERDES_XAUI_HSS_PCS_START = 0x00000800,
+	XG_SERDES_XAUI_HSS_PCS_END = 0x0000880,
+	XG_SERDES_XFI_AN_START = 0x00001000,
+	XG_SERDES_XFI_AN_END = 0x00001034,
+	XG_SERDES_XFI_TRAIN_START = 0x10001050,
+	XG_SERDES_XFI_TRAIN_END = 0x1000107C,
+	XG_SERDES_XFI_HSS_PCS_START = 0x00001800,
+	XG_SERDES_XFI_HSS_PCS_END = 0x00001838,
+	XG_SERDES_XFI_HSS_TX_START = 0x00001c00,
+	XG_SERDES_XFI_HSS_TX_END = 0x00001c1f,
+	XG_SERDES_XFI_HSS_RX_START = 0x00001c40,
+	XG_SERDES_XFI_HSS_RX_END = 0x00001c5f,
+	XG_SERDES_XFI_HSS_PLL_START = 0x00001e00,
+	XG_SERDES_XFI_HSS_PLL_END = 0x00001e1f,
+};
+
+/*
+ *  NIC Probe Mux Address Register (PRB_MX_ADDR) bit definitions.
+ */
+enum {
+	PRB_MX_ADDR_ARE = (1 << 16),
+	PRB_MX_ADDR_UP = (1 << 15),
+	PRB_MX_ADDR_SWP = (1 << 14),
+
+	/* Module select values. */
+	PRB_MX_ADDR_MAX_MODS = 21,
+	PRB_MX_ADDR_MOD_SEL_SHIFT = 9,
+	PRB_MX_ADDR_MOD_SEL_TBD = 0,
+	PRB_MX_ADDR_MOD_SEL_IDE1 = 1,
+	PRB_MX_ADDR_MOD_SEL_IDE2 = 2,
+	PRB_MX_ADDR_MOD_SEL_FRB = 3,
+	PRB_MX_ADDR_MOD_SEL_ODE1 = 4,
+	PRB_MX_ADDR_MOD_SEL_ODE2 = 5,
+	PRB_MX_ADDR_MOD_SEL_DA1 = 6,
+	PRB_MX_ADDR_MOD_SEL_DA2 = 7,
+	PRB_MX_ADDR_MOD_SEL_IMP1 = 8,
+	PRB_MX_ADDR_MOD_SEL_IMP2 = 9,
+	PRB_MX_ADDR_MOD_SEL_OMP1 = 10,
+	PRB_MX_ADDR_MOD_SEL_OMP2 = 11,
+	PRB_MX_ADDR_MOD_SEL_ORS1 = 12,
+	PRB_MX_ADDR_MOD_SEL_ORS2 = 13,
+	PRB_MX_ADDR_MOD_SEL_REG = 14,
+	PRB_MX_ADDR_MOD_SEL_MAC1 = 16,
+	PRB_MX_ADDR_MOD_SEL_MAC2 = 17,
+	PRB_MX_ADDR_MOD_SEL_VQM1 = 18,
+	PRB_MX_ADDR_MOD_SEL_VQM2 = 19,
+	PRB_MX_ADDR_MOD_SEL_MOP = 20,
+	/* Bit fields indicating which modules
+	 * are valid for each clock domain.
+	 */
+	PRB_MX_ADDR_VALID_SYS_MOD = 0x000f7ff7,
+	PRB_MX_ADDR_VALID_PCI_MOD = 0x000040c1,
+	PRB_MX_ADDR_VALID_XGM_MOD = 0x00037309,
+	PRB_MX_ADDR_VALID_FC_MOD = 0x00003001,
+	PRB_MX_ADDR_VALID_TOTAL = 34,
+
+	/* Clock domain values. */
+	PRB_MX_ADDR_CLOCK_SHIFT = 6,
+	PRB_MX_ADDR_SYS_CLOCK = 0,
+	PRB_MX_ADDR_PCI_CLOCK = 2,
+	PRB_MX_ADDR_FC_CLOCK = 5,
+	PRB_MX_ADDR_XGM_CLOCK = 6,
+
+	PRB_MX_ADDR_MAX_MUX = 64,
 };
 
 /*
@@ -1432,7 +1568,7 @@ struct nic_stats {
 	u64 rx_nic_fifo_drop;
 };
 
-/* Address/Length pairs for the coredump. */
+/* Firmware coredump internal register address/length pairs. */
 enum {
 	MPI_CORE_REGS_ADDR = 0x00030000,
 	MPI_CORE_REGS_CNT = 127,
@@ -1487,7 +1623,7 @@ struct mpi_coredump_segment_header {
 	u8	description[16];
 };
 
-/* Reg dump segment numbers. */
+/* Firmware coredump header segment numbers. */
 enum {
 	CORE_SEG_NUM = 1,
 	TEST_LOGIC_SEG_NUM = 2,
@@ -1538,6 +1674,67 @@ enum {
 
 };
 
+/* There are 64 generic NIC registers. */
+#define NIC_REGS_DUMP_WORD_COUNT		64
+/* XGMAC word count. */
+#define XGMAC_DUMP_WORD_COUNT		(XGMAC_REGISTER_END / 4)
+/* Word counts for the SERDES blocks. */
+#define XG_SERDES_XAUI_AN_COUNT		14
+#define XG_SERDES_XAUI_HSS_PCS_COUNT	33
+#define XG_SERDES_XFI_AN_COUNT		14
+#define XG_SERDES_XFI_TRAIN_COUNT		12
+#define XG_SERDES_XFI_HSS_PCS_COUNT	15
+#define XG_SERDES_XFI_HSS_TX_COUNT		32
+#define XG_SERDES_XFI_HSS_RX_COUNT		32
+#define XG_SERDES_XFI_HSS_PLL_COUNT	32
+
+/* There are 2 CNA ETS and 8 NIC ETS registers. */
+#define ETS_REGS_DUMP_WORD_COUNT		10
+
+/* Each probe mux entry stores the probe type plus 64 entries
+ * that are each each 64-bits in length. There are a total of
+ * 34 (PRB_MX_ADDR_VALID_TOTAL) valid probes.
+ */
+#define PRB_MX_ADDR_PRB_WORD_COUNT		(1 + (PRB_MX_ADDR_MAX_MUX * 2))
+#define PRB_MX_DUMP_TOT_COUNT		(PRB_MX_ADDR_PRB_WORD_COUNT * \
+							PRB_MX_ADDR_VALID_TOTAL)
+/* Each routing entry consists of 4 32-bit words.
+ * They are route type, index, index word, and result.
+ * There are 2 route blocks with 8 entries each and
+ *  2 NIC blocks with 16 entries each.
+ * The totol entries is 48 with 4 words each.
+ */
+#define RT_IDX_DUMP_ENTRIES			48
+#define RT_IDX_DUMP_WORDS_PER_ENTRY	4
+#define RT_IDX_DUMP_TOT_WORDS		(RT_IDX_DUMP_ENTRIES * \
+						RT_IDX_DUMP_WORDS_PER_ENTRY)
+/* There are 10 address blocks in filter, each with
+ * different entry counts and different word-count-per-entry.
+ */
+#define MAC_ADDR_DUMP_ENTRIES \
+	((MAC_ADDR_MAX_CAM_ENTRIES * MAC_ADDR_MAX_CAM_WCOUNT) + \
+	(MAC_ADDR_MAX_MULTICAST_ENTRIES * MAC_ADDR_MAX_MULTICAST_WCOUNT) + \
+	(MAC_ADDR_MAX_VLAN_ENTRIES * MAC_ADDR_MAX_VLAN_WCOUNT) + \
+	(MAC_ADDR_MAX_MCAST_FLTR_ENTRIES * MAC_ADDR_MAX_MCAST_FLTR_WCOUNT) + \
+	(MAC_ADDR_MAX_FC_MAC_ENTRIES * MAC_ADDR_MAX_FC_MAC_WCOUNT) + \
+	(MAC_ADDR_MAX_MGMT_MAC_ENTRIES * MAC_ADDR_MAX_MGMT_MAC_WCOUNT) + \
+	(MAC_ADDR_MAX_MGMT_VLAN_ENTRIES * MAC_ADDR_MAX_MGMT_VLAN_WCOUNT) + \
+	(MAC_ADDR_MAX_MGMT_V4_ENTRIES * MAC_ADDR_MAX_MGMT_V4_WCOUNT) + \
+	(MAC_ADDR_MAX_MGMT_V6_ENTRIES * MAC_ADDR_MAX_MGMT_V6_WCOUNT) + \
+	(MAC_ADDR_MAX_MGMT_TU_DP_ENTRIES * MAC_ADDR_MAX_MGMT_TU_DP_WCOUNT))
+#define MAC_ADDR_DUMP_WORDS_PER_ENTRY	2
+#define MAC_ADDR_DUMP_TOT_WORDS		(MAC_ADDR_DUMP_ENTRIES * \
+						MAC_ADDR_DUMP_WORDS_PER_ENTRY)
+/* Maximum of 4 functions whose semaphore registeres are
+ * in the coredump.
+ */
+#define MAX_SEMAPHORE_FUNCTIONS		4
+/* Defines for access the MPI shadow registers. */
+#define RISC_124		0x0003007c
+#define RISC_127		0x0003007f
+#define SHADOW_OFFSET	0xb0000000
+#define SHADOW_REG_SHIFT	20
+
 struct ql_nic_misc {
 	u32 rx_ring_count;
 	u32 tx_ring_count;
@@ -1579,6 +1776,199 @@ struct ql_reg_dump {
 	u32 ets[8+2];
 };
 
+struct ql_mpi_coredump {
+	/* segment 0 */
+	struct mpi_coredump_global_header mpi_global_header;
+
+	/* segment 1 */
+	struct mpi_coredump_segment_header core_regs_seg_hdr;
+	u32 mpi_core_regs[MPI_CORE_REGS_CNT];
+	u32 mpi_core_sh_regs[MPI_CORE_SH_REGS_CNT];
+
+	/* segment 2 */
+	struct mpi_coredump_segment_header test_logic_regs_seg_hdr;
+	u32 test_logic_regs[TEST_REGS_CNT];
+
+	/* segment 3 */
+	struct mpi_coredump_segment_header rmii_regs_seg_hdr;
+	u32 rmii_regs[RMII_REGS_CNT];
+
+	/* segment 4 */
+	struct mpi_coredump_segment_header fcmac1_regs_seg_hdr;
+	u32 fcmac1_regs[FCMAC_REGS_CNT];
+
+	/* segment 5 */
+	struct mpi_coredump_segment_header fcmac2_regs_seg_hdr;
+	u32 fcmac2_regs[FCMAC_REGS_CNT];
+
+	/* segment 6 */
+	struct mpi_coredump_segment_header fc1_mbx_regs_seg_hdr;
+	u32 fc1_mbx_regs[FC_MBX_REGS_CNT];
+
+	/* segment 7 */
+	struct mpi_coredump_segment_header ide_regs_seg_hdr;
+	u32 ide_regs[IDE_REGS_CNT];
+
+	/* segment 8 */
+	struct mpi_coredump_segment_header nic1_mbx_regs_seg_hdr;
+	u32 nic1_mbx_regs[NIC_MBX_REGS_CNT];
+
+	/* segment 9 */
+	struct mpi_coredump_segment_header smbus_regs_seg_hdr;
+	u32 smbus_regs[SMBUS_REGS_CNT];
+
+	/* segment 10 */
+	struct mpi_coredump_segment_header fc2_mbx_regs_seg_hdr;
+	u32 fc2_mbx_regs[FC_MBX_REGS_CNT];
+
+	/* segment 11 */
+	struct mpi_coredump_segment_header nic2_mbx_regs_seg_hdr;
+	u32 nic2_mbx_regs[NIC_MBX_REGS_CNT];
+
+	/* segment 12 */
+	struct mpi_coredump_segment_header i2c_regs_seg_hdr;
+	u32 i2c_regs[I2C_REGS_CNT];
+	/* segment 13 */
+	struct mpi_coredump_segment_header memc_regs_seg_hdr;
+	u32 memc_regs[MEMC_REGS_CNT];
+
+	/* segment 14 */
+	struct mpi_coredump_segment_header pbus_regs_seg_hdr;
+	u32 pbus_regs[PBUS_REGS_CNT];
+
+	/* segment 15 */
+	struct mpi_coredump_segment_header mde_regs_seg_hdr;
+	u32 mde_regs[MDE_REGS_CNT];
+
+	/* segment 16 */
+	struct mpi_coredump_segment_header nic_regs_seg_hdr;
+	u32 nic_regs[NIC_REGS_DUMP_WORD_COUNT];
+
+	/* segment 17 */
+	struct mpi_coredump_segment_header nic2_regs_seg_hdr;
+	u32 nic2_regs[NIC_REGS_DUMP_WORD_COUNT];
+
+	/* segment 18 */
+	struct mpi_coredump_segment_header xgmac1_seg_hdr;
+	u32 xgmac1[XGMAC_DUMP_WORD_COUNT];
+
+	/* segment 19 */
+	struct mpi_coredump_segment_header xgmac2_seg_hdr;
+	u32 xgmac2[XGMAC_DUMP_WORD_COUNT];
+
+	/* segment 20 */
+	struct mpi_coredump_segment_header code_ram_seg_hdr;
+	u32 code_ram[CODE_RAM_CNT];
+
+	/* segment 21 */
+	struct mpi_coredump_segment_header memc_ram_seg_hdr;
+	u32 memc_ram[MEMC_RAM_CNT];
+
+	/* segment 22 */
+	struct mpi_coredump_segment_header xaui_an_hdr;
+	u32 serdes_xaui_an[XG_SERDES_XAUI_AN_COUNT];
+
+	/* segment 23 */
+	struct mpi_coredump_segment_header xaui_hss_pcs_hdr;
+	u32 serdes_xaui_hss_pcs[XG_SERDES_XAUI_HSS_PCS_COUNT];
+
+	/* segment 24 */
+	struct mpi_coredump_segment_header xfi_an_hdr;
+	u32 serdes_xfi_an[XG_SERDES_XFI_AN_COUNT];
+
+	/* segment 25 */
+	struct mpi_coredump_segment_header xfi_train_hdr;
+	u32 serdes_xfi_train[XG_SERDES_XFI_TRAIN_COUNT];
+
+	/* segment 26 */
+	struct mpi_coredump_segment_header xfi_hss_pcs_hdr;
+	u32 serdes_xfi_hss_pcs[XG_SERDES_XFI_HSS_PCS_COUNT];
+
+	/* segment 27 */
+	struct mpi_coredump_segment_header xfi_hss_tx_hdr;
+	u32 serdes_xfi_hss_tx[XG_SERDES_XFI_HSS_TX_COUNT];
+
+	/* segment 28 */
+	struct mpi_coredump_segment_header xfi_hss_rx_hdr;
+	u32 serdes_xfi_hss_rx[XG_SERDES_XFI_HSS_RX_COUNT];
+
+	/* segment 29 */
+	struct mpi_coredump_segment_header xfi_hss_pll_hdr;
+	u32 serdes_xfi_hss_pll[XG_SERDES_XFI_HSS_PLL_COUNT];
+
+	/* segment 30 */
+	struct mpi_coredump_segment_header misc_nic_seg_hdr;
+	struct ql_nic_misc misc_nic_info;
+
+	/* segment 31 */
+	/* one interrupt state for each CQ */
+	struct mpi_coredump_segment_header intr_states_seg_hdr;
+	u32 intr_states[MAX_RX_RINGS];
+
+	/* segment 32 */
+	/* 3 cam words each for 16 unicast,
+	 * 2 cam words for each of 32 multicast.
+	 */
+	struct mpi_coredump_segment_header cam_entries_seg_hdr;
+	u32 cam_entries[(16 * 3) + (32 * 3)];
+
+	/* segment 33 */
+	struct mpi_coredump_segment_header nic_routing_words_seg_hdr;
+	u32 nic_routing_words[16];
+	/* segment 34 */
+	struct mpi_coredump_segment_header ets_seg_hdr;
+	u32 ets[ETS_REGS_DUMP_WORD_COUNT];
+
+	/* segment 35 */
+	struct mpi_coredump_segment_header probe_dump_seg_hdr;
+	u32 probe_dump[PRB_MX_DUMP_TOT_COUNT];
+
+	/* segment 36 */
+	struct mpi_coredump_segment_header routing_reg_seg_hdr;
+	u32 routing_regs[RT_IDX_DUMP_TOT_WORDS];
+
+	/* segment 37 */
+	struct mpi_coredump_segment_header mac_prot_reg_seg_hdr;
+	u32 mac_prot_regs[MAC_ADDR_DUMP_TOT_WORDS];
+
+	/* segment 38 */
+	struct mpi_coredump_segment_header xaui2_an_hdr;
+	u32 serdes2_xaui_an[XG_SERDES_XAUI_AN_COUNT];
+
+	/* segment 39 */
+	struct mpi_coredump_segment_header xaui2_hss_pcs_hdr;
+	u32 serdes2_xaui_hss_pcs[XG_SERDES_XAUI_HSS_PCS_COUNT];
+
+	/* segment 40 */
+	struct mpi_coredump_segment_header xfi2_an_hdr;
+	u32 serdes2_xfi_an[XG_SERDES_XFI_AN_COUNT];
+
+	/* segment 41 */
+	struct mpi_coredump_segment_header xfi2_train_hdr;
+	u32 serdes2_xfi_train[XG_SERDES_XFI_TRAIN_COUNT];
+
+	/* segment 42 */
+	struct mpi_coredump_segment_header xfi2_hss_pcs_hdr;
+	u32 serdes2_xfi_hss_pcs[XG_SERDES_XFI_HSS_PCS_COUNT];
+
+	/* segment 43 */
+	struct mpi_coredump_segment_header xfi2_hss_tx_hdr;
+	u32 serdes2_xfi_hss_tx[XG_SERDES_XFI_HSS_TX_COUNT];
+
+	/* segment 44 */
+	struct mpi_coredump_segment_header xfi2_hss_rx_hdr;
+	u32 serdes2_xfi_hss_rx[XG_SERDES_XFI_HSS_RX_COUNT];
+
+	/* segment 45 */
+	struct mpi_coredump_segment_header xfi2_hss_pll_hdr;
+	u32 serdes2_xfi_hss_pll[XG_SERDES_XFI_HSS_PLL_COUNT];
+
+	/* segment 50 */
+	/* semaphore register for all 5 functions */
+	struct mpi_coredump_segment_header sem_regs_seg_hdr;
+	u32 sem_regs[MAX_SEMAPHORE_FUNCTIONS];
+};
+
 /*
  * intr_context structure is used during initialization
  * to hook the interrupts.  It is also used in a single
@@ -1735,6 +2125,8 @@ struct ql_adapter {
 	u32 port_link_up;
 	u32 port_init;
 	u32 link_status;
+	struct ql_mpi_coredump *mpi_coredump;
+	u32 core_is_dumped;
 	u32 link_config;
 	u32 led_config;
 	u32 max_frame_size;
@@ -1747,6 +2139,7 @@ struct ql_adapter {
 	struct delayed_work mpi_work;
 	struct delayed_work mpi_port_cfg_work;
 	struct delayed_work mpi_idc_work;
+	struct delayed_work mpi_core_to_log;
 	struct completion ide_completion;
 	struct nic_operations *nic_ops;
 	u16 device_id;
-- 
1.6.0.2

