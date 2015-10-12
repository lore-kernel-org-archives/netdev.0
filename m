From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v5 01/10] qed: Add module with basic common support
Date: Mon, 12 Oct 2015 21:30:13 +0300
Message-ID: <1444674622-13059-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1444674622-13059-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:30217 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751745AbbJLSag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 14:30:36 -0400
Received: from pps.filterd (m0045602.ppops.net [127.0.0.1])
	by mx0a-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t9CISGxh015003
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 11:30:35 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0a-0016ce01.pphosted.com with ESMTP id 1xghx8r0y0-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 11:30:32 -0700
In-Reply-To: <1444674622-13059-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Qlogic Everest Driver is the backend module for the 579xx ethernet
products by Qlogic.

This module serves two main purposes:
 1. It's responsible to contain all the common code that will be shared
    between the various drivers that would be used with said line of
    products. Flows such as chip initialization and de-initialization
    fall under this category.

 2. It would abstract the protocol-specific HW & FW components, allowing
    the protocol drivers to have a clean APIs which is detached in its
    slowpath configuration from the actual HSI.

This adds a very basic module without any protocol-specific bits.
I.e., this adds a basic implementation that almost entirely falls under
the first category.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 MAINTAINERS                                        |   10 +
 drivers/net/ethernet/qlogic/Kconfig                |    6 +
 drivers/net/ethernet/qlogic/Makefile               |    1 +
 drivers/net/ethernet/qlogic/qed/Makefile           |    3 +
 drivers/net/ethernet/qlogic/qed/qed.h              |  448 ++
 drivers/net/ethernet/qlogic/qed/qed_cxt.c          |  851 ++++
 drivers/net/ethernet/qlogic/qed/qed_cxt.h          |  138 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c          | 1285 +++++
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h      |  221 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          | 5040 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_hw.c           |  776 +++
 drivers/net/ethernet/qlogic/qed/qed_hw.h           |  266 ++
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    |  882 ++++
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c     |  545 +++
 drivers/net/ethernet/qlogic/qed/qed_init_ops.h     |  109 +
 drivers/net/ethernet/qlogic/qed/qed_int.c          |  837 ++++
 drivers/net/ethernet/qlogic/qed/qed_int.h          |  404 ++
 drivers/net/ethernet/qlogic/qed/qed_main.c         | 1000 ++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c          |  582 +++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h          |  231 +
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |  366 ++
 drivers/net/ethernet/qlogic/qed/qed_sp.h           |  328 ++
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c  |  180 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c          |  849 ++++
 include/linux/qed/common_hsi.h                     |  607 +++
 include/linux/qed/qed_chain.h                      |  538 +++
 include/linux/qed/qed_if.h                         |  497 ++
 27 files changed, 17000 insertions(+)
 create mode 100644 drivers/net/ethernet/qlogic/qed/Makefile
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_cxt.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_cxt.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_dev.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_dev_api.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_hsi.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_hw.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_hw.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_init_ops.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_init_ops.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_int.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_int.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_main.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_mcp.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_mcp.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_sp.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_spq.c
 create mode 100644 include/linux/qed/common_hsi.h
 create mode 100644 include/linux/qed/qed_chain.h
 create mode 100644 include/linux/qed/qed_if.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 4d0171c..9db166d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8526,6 +8526,16 @@ L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/qlogic/qlge/
 
+QLOGIC 579xx ETHERNET DRIVER
+M:	Yuval Mintz <Yuval.Mintz@qlogic.com>
+M:	Ariel Elior <Ariel.Elior@qlogic.com>
+M:	everest-linux-l2@qlogic.com
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/qlogic/qed/
+F:	include/linux/qed/
+F:	drivers/net/ethernet/qlogic/qede/
+
 QNX4 FILESYSTEM
 M:	Anders Larsen <al@alarsen.net>
 W:	http://www.alarsen.net/linux/qnx4fs/
diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index f1f0108..1a77311 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -91,4 +91,10 @@ config NETXEN_NIC
 	---help---
 	  This enables the support for NetXen's Gigabit Ethernet card.
 
+config QED
+	tristate "QLogic QED 25/40/100Gb core driver"
+	depends on PCI
+	---help---
+	  This enables the support for ...
+
 endif # NET_VENDOR_QLOGIC
diff --git a/drivers/net/ethernet/qlogic/Makefile b/drivers/net/ethernet/qlogic/Makefile
index b2a283d..7600138 100644
--- a/drivers/net/ethernet/qlogic/Makefile
+++ b/drivers/net/ethernet/qlogic/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_QLA3XXX) += qla3xxx.o
 obj-$(CONFIG_QLCNIC) += qlcnic/
 obj-$(CONFIG_QLGE) += qlge/
 obj-$(CONFIG_NETXEN_NIC) += netxen/
+obj-$(CONFIG_QED) += qed/
diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
new file mode 100644
index 0000000..5bbe0c7
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_QED) := qed.o
+
+qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
new file mode 100644
index 0000000..f9f01bb
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -0,0 +1,448 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_H
+#define _QED_H
+#include <linux/types.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/firmware.h>
+#include <linux/interrupt.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/workqueue.h>
+#include <linux/zlib.h>
+#include <linux/hashtable.h>
+#include <linux/qed/qed_if.h>
+#include "qed_hsi.h"
+
+#define DRV_MODULE_VERSION "8.4.0.0"
+
+#define MAX_HWFNS_PER_DEVICE    (4)
+#define NAME_SIZE 16
+#define VER_SIZE 16
+
+/* cau states */
+enum qed_coalescing_mode {
+	QED_COAL_MODE_DISABLE,
+	QED_COAL_MODE_ENABLE
+};
+
+struct qed_eth_cb_ops;
+struct qed_dev_info;
+
+/* helpers */
+static inline u32 DB_ADDR(u32	cid,
+			  u32	DEMS)
+{
+	u32 db_addr = FIELD_VALUE(DB_LEGACY_ADDR_DEMS, DEMS) |
+		FIELD_VALUE(DB_LEGACY_ADDR_ICID, cid);
+
+	return db_addr;
+}
+
+#define ALIGNED_TYPE_SIZE(type_name, p_hwfn)				     \
+	((sizeof(type_name) + (u32)(1 << (p_hwfn->cdev->cache_shift)) - 1) & \
+	 ~((1 << (p_hwfn->cdev->cache_shift)) - 1))
+
+#define for_each_hwfn(cdev, i)  for (i = 0; i < cdev->num_hwfns; i++)
+
+#define D_TRINE(val, cond1, cond2, true1, true2, def) \
+	(val == (cond1) ? true1 :		      \
+	 (val == (cond2) ? true2 : def))
+
+/* forward */
+struct qed_ptt_pool;
+struct qed_spq;
+struct qed_sb_info;
+struct qed_sb_attn_info;
+struct qed_cxt_mngr;
+struct qed_sb_sp_info;
+struct qed_mcp_info;
+
+struct qed_rt_data {
+	u32 init_val;
+	bool b_valid;
+};
+
+/* The PCI personality is not quite synonymous to protocol ID:
+ * 1. All personalities need CORE connections
+ * 2. The Ethernet personality may support also the RoCE protocol
+ */
+enum qed_pci_personality {
+	QED_PCI_ETH,
+	QED_PCI_DEFAULT /* default in shmem */
+};
+
+/* All VFs are symmetric, all counters are PF + all VFs */
+struct qed_qm_iids {
+	u32 cids;
+	u32 vf_cids;
+	u32 tids;
+};
+
+enum QED_RESOURCES {
+	QED_SB,
+	QED_VPORT,
+	QED_PQ,
+	QED_RL,
+	QED_ILT,
+	QED_MAX_RESC,
+};
+
+struct qed_hw_info {
+	/* PCI personality */
+	enum qed_pci_personality	personality;
+
+	/* Resource Allocation scheme results */
+	u32				resc_start[QED_MAX_RESC];
+	u32				resc_num[QED_MAX_RESC];
+
+#define RESC_START(_p_hwfn, resc) ((_p_hwfn)->hw_info.resc_start[resc])
+#define RESC_NUM(_p_hwfn, resc) ((_p_hwfn)->hw_info.resc_num[resc])
+#define FEAT_NUM(_p_hwfn, resc) ((_p_hwfn)->hw_info.feat_num[resc])
+
+	u8				num_tc;
+	u8				offload_tc;
+	u8				non_offload_tc;
+
+	u32				concrete_fid;
+	u16				opaque_fid;
+	u16				ovlan;
+	u32				part_num[4];
+
+	u32				vendor_id;
+	u32				device_id;
+
+	unsigned char			hw_mac_addr[ETH_ALEN];
+
+	struct qed_igu_info		*p_igu_info;
+
+	u32				port_mode;
+	u32				hw_mode;
+};
+
+struct qed_hw_cid_data {
+	u32	cid;
+	bool	b_cid_allocated;
+
+	/* Additional identifiers */
+	u16	opaque_fid;
+	u8	vport_id;
+};
+
+/* maximun size of read/write commands (HW limit) */
+#define DMAE_MAX_RW_SIZE        0x2000
+
+struct qed_dmae_info {
+	/* Mutex for synchronizing access to functions */
+	struct mutex	mutex;
+
+	u8		channel;
+
+	dma_addr_t	completion_word_phys_addr;
+
+	/* The memory location where the DMAE writes the completion
+	 * value when an operation is finished on this context.
+	 */
+	u32		*p_completion_word;
+
+	dma_addr_t	intermediate_buffer_phys_addr;
+
+	/* An intermediate buffer for DMAE operations that use virtual
+	 * addresses - data is DMA'd to/from this buffer and then
+	 * memcpy'd to/from the virtual address
+	 */
+	u32		*p_intermediate_buffer;
+
+	dma_addr_t	dmae_cmd_phys_addr;
+	struct dmae_cmd *p_dmae_cmd;
+};
+
+struct qed_qm_info {
+	struct init_qm_pq_params	*qm_pq_params;
+	struct init_qm_vport_params	*qm_vport_params;
+	struct init_qm_port_params	*qm_port_params;
+	u16				start_pq;
+	u8				start_vport;
+	u8				pure_lb_pq;
+	u8				offload_pq;
+	u8				pure_ack_pq;
+	u8				vf_queues_offset;
+	u16				num_pqs;
+	u16				num_vf_pqs;
+	u8				num_vports;
+	u8				max_phys_tcs_per_port;
+	bool				pf_rl_en;
+	bool				pf_wfq_en;
+	bool				vport_rl_en;
+	bool				vport_wfq_en;
+	u8				pf_wfq;
+	u32				pf_rl;
+};
+
+struct qed_fw_data {
+	const u8		*modes_tree_buf;
+	union init_op		*init_ops;
+	const u32		*arr_data;
+	u32			init_ops_size;
+};
+
+struct qed_simd_fp_handler {
+	void	*token;
+	void	(*func)(void *);
+};
+
+struct qed_hwfn {
+	struct qed_dev			*cdev;
+	u8				my_id;          /* ID inside the PF */
+#define IS_LEAD_HWFN(edev)              (!((edev)->my_id))
+	u8				rel_pf_id;      /* Relative to engine*/
+	u8				abs_pf_id;
+#define QED_PATH_ID(_p_hwfn)		((_p_hwfn)->abs_pf_id & 1)
+	u8				port_id;
+	bool				b_active;
+
+	u32				dp_module;
+	u8				dp_level;
+	char				name[NAME_SIZE];
+
+	bool				first_on_engine;
+	bool				hw_init_done;
+
+	/* BAR access */
+	void __iomem			*regview;
+	void __iomem			*doorbells;
+	u64				db_phys_addr;
+	unsigned long			db_size;
+
+	/* PTT pool */
+	struct qed_ptt_pool		*p_ptt_pool;
+
+	/* HW info */
+	struct qed_hw_info		hw_info;
+
+	/* rt_array (for init-tool) */
+	struct qed_rt_data		*rt_data;
+
+	/* SPQ */
+	struct qed_spq			*p_spq;
+
+	/* EQ */
+	struct qed_eq			*p_eq;
+
+	/* Consolidate Q*/
+	struct qed_consq		*p_consq;
+
+	/* Slow-Path definitions */
+	struct tasklet_struct		*sp_dpc;
+	bool				b_sp_dpc_enabled;
+
+	struct qed_ptt			*p_main_ptt;
+	struct qed_ptt			*p_dpc_ptt;
+
+	struct qed_sb_sp_info		*p_sp_sb;
+	struct qed_sb_attn_info		*p_sb_attn;
+
+	/* Protocol related */
+	struct qed_pf_params		pf_params;
+
+	/* Array of sb_info of all status blocks */
+	struct qed_sb_info		*sbs_info[MAX_SB_PER_PF_MIMD];
+	u16				num_sbs;
+
+	struct qed_cxt_mngr		*p_cxt_mngr;
+
+	/* Flag indicating whether interrupts are enabled or not*/
+	bool				b_int_enabled;
+
+	struct qed_mcp_info		*mcp_info;
+
+	struct qed_dmae_info		dmae_info;
+
+	/* QM init */
+	struct qed_qm_info		qm_info;
+
+	/* Buffer for unzipping firmware data */
+	void				*unzip_buf;
+
+	struct qed_simd_fp_handler	simd_proto_handler[64];
+
+	struct z_stream_s		*stream;
+};
+
+struct pci_params {
+	int		pm_cap;
+
+	unsigned long	mem_start;
+	unsigned long	mem_end;
+	unsigned int	irq;
+	u8		pf_num;
+};
+
+struct qed_int_param {
+	u32	int_mode;
+	u8	num_vectors;
+	u8	min_msix_cnt; /* for minimal functionality */
+};
+
+struct qed_int_params {
+	struct qed_int_param	in;
+	struct qed_int_param	out;
+	struct msix_entry	*msix_table;
+	bool			fp_initialized;
+	u8			fp_msix_base;
+	u8			fp_msix_cnt;
+};
+
+struct qed_dev {
+	u32	dp_module;
+	u8	dp_level;
+	char	name[NAME_SIZE];
+
+	u8	type;
+#define QED_DEV_TYPE_BB_A0      (0 << 0)
+#define QED_DEV_TYPE_MASK       (0x3)
+#define QED_DEV_TYPE_SHIFT      (0)
+
+	u16	chip_num;
+#define CHIP_NUM_MASK                   0xffff
+#define CHIP_NUM_SHIFT                  16
+
+	u16	chip_rev;
+#define CHIP_REV_MASK                   0xf
+#define CHIP_REV_SHIFT                  12
+
+	u16				chip_metal;
+#define CHIP_METAL_MASK                 0xff
+#define CHIP_METAL_SHIFT                4
+
+	u16				chip_bond_id;
+#define CHIP_BOND_ID_MASK               0xf
+#define CHIP_BOND_ID_SHIFT              0
+
+	u8				num_engines;
+	u8				num_ports_in_engines;
+	u8				num_funcs_in_port;
+
+	u8				path_id;
+	enum mf_mode			mf_mode;
+#define IS_MF(_p_hwfn)          (((_p_hwfn)->cdev)->mf_mode != SF)
+#define IS_MF_SI(_p_hwfn)       (((_p_hwfn)->cdev)->mf_mode == MF_NPAR)
+#define IS_MF_SD(_p_hwfn)       (((_p_hwfn)->cdev)->mf_mode == MF_OVLAN)
+
+	int				pcie_width;
+	int				pcie_speed;
+	u8				ver_str[VER_SIZE];
+
+	/* Add MF related configuration */
+	u8				mcp_rev;
+	u8				boot_mode;
+
+	u8				wol;
+
+	u32				int_mode;
+	enum qed_coalescing_mode	int_coalescing_mode;
+	u8				rx_coalesce_usecs;
+	u8				tx_coalesce_usecs;
+
+	/* Start Bar offset of first hwfn */
+	void __iomem			*regview;
+	void __iomem			*doorbells;
+	u64				db_phys_addr;
+	unsigned long			db_size;
+
+	/* PCI */
+	u8				cache_shift;
+
+	/* Init */
+	const struct iro		*iro_arr;
+#define IRO (p_hwfn->cdev->iro_arr)
+
+	/* HW functions */
+	u8				num_hwfns;
+	struct qed_hwfn			hwfns[MAX_HWFNS_PER_DEVICE];
+
+	u32				drv_type;
+
+	struct qed_eth_stats		*reset_stats;
+	struct qed_fw_data		*fw_data;
+
+	u32				mcp_nvm_resp;
+
+	/* Linux specific here */
+	struct  qede_dev		*edev;
+	struct  pci_dev			*pdev;
+	int				msg_enable;
+
+	struct pci_params		pci_params;
+
+	struct qed_int_params		int_params;
+
+	u8				protocol;
+#define IS_QED_ETH_IF(cdev)     ((cdev)->protocol == QED_PROTOCOL_ETH)
+
+	const struct firmware		*firmware;
+};
+
+#define QED_GET_TYPE(dev)       (((dev)->type & QED_DEV_TYPE_MASK) >> \
+				 QED_DEV_TYPE_SHIFT)
+#define QED_IS_BB_A0(dev)       (QED_GET_TYPE(dev) == QED_DEV_TYPE_BB_A0)
+#define QED_IS_BB(dev)  (QED_IS_BB_A0(dev))
+
+#define NUM_OF_SBS(dev)         MAX_SB_PER_PATH_BB
+#define NUM_OF_ENG_PFS(dev)     MAX_NUM_PFS_BB
+
+/**
+ * @brief qed_concrete_to_sw_fid - get the sw function id from
+ *        the concrete value.
+ *
+ * @param concrete_fid
+ *
+ * @return inline u8
+ */
+static inline u8 qed_concrete_to_sw_fid(struct qed_dev *cdev,
+					u32 concrete_fid)
+{
+	u8 pfid = GET_FIELD(concrete_fid, PXP_CONCRETE_FID_PFID);
+
+	return pfid;
+}
+
+#define PURE_LB_TC 8
+
+#define QED_LEADING_HWFN(dev)   (&dev->hwfns[0])
+
+/* Other Linux specific common definitions */
+#define DP_NAME(cdev) ((cdev)->name)
+
+#define REG_ADDR(cdev, offset)          (void __iomem *)((u8 __iomem *)\
+						(cdev->regview) + \
+							 (offset))
+
+#define REG_RD(cdev, offset)            readl(REG_ADDR(cdev, offset))
+#define REG_WR(cdev, offset, val)       writel((u32)val, REG_ADDR(cdev, offset))
+#define REG_WR16(cdev, offset, val)     writew((u16)val, REG_ADDR(cdev, offset))
+
+#define DOORBELL(cdev, db_addr, val)			 \
+	writel((u32)val, (void __iomem *)((u8 __iomem *)\
+					  (cdev->doorbells) + (db_addr)))
+
+/* Prototypes */
+int qed_fill_dev_info(struct qed_dev		*cdev,
+		      struct qed_dev_info	*dev_info);
+u32 qed_unzip_data(struct qed_hwfn *p_hwfn,
+		   u32 input_len, u8 *input_buf,
+		   u32 max_size, u8 *unzip_buf);
+
+#define QED_ETH_INTERFACE_VERSION       300
+
+#endif /* _QED_H */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
new file mode 100644
index 0000000..4acc053
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -0,0 +1,851 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <linux/bitops.h>
+#include <linux/dma-mapping.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/log2.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include "qed.h"
+#include "qed_cxt.h"
+#include "qed_dev_api.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_init_ops.h"
+#include "qed_reg_addr.h"
+
+/* Max number of connection types in HW (DQ/CDU etc.) */
+#define MAX_CONN_TYPES		PROTOCOLID_COMMON
+#define NUM_TASK_TYPES		2
+#define NUM_TASK_PF_SEGMENTS	4
+
+/* QM constants */
+#define QM_PQ_ELEMENT_SIZE	4 /* in bytes */
+
+/* Doorbell-Queue constants */
+#define DQ_RANGE_SHIFT		4
+#define DQ_RANGE_ALIGN		BIT(DQ_RANGE_SHIFT)
+
+/* ILT constants */
+#define ILT_DEFAULT_HW_P_SIZE		3
+#define ILT_PAGE_IN_BYTES(hw_p_size)	(1U << ((hw_p_size) + 12))
+#define ILT_CFG_REG(cli, reg) \
+	PSWRQ2_REG_ ## cli ## _ ## reg ## _RT_OFFSET
+
+/* ILT entry structure */
+#define ILT_ENTRY_PHY_ADDR_MASK		0x000FFFFFFFFFFFULL
+#define ILT_ENTRY_PHY_ADDR_SHIFT	0
+#define ILT_ENTRY_VALID_MASK		0x1ULL
+#define ILT_ENTRY_VALID_SHIFT		52
+#define ILT_ENTRY_IN_REGS		2
+#define ILT_REG_SIZE_IN_BYTES		4
+
+/* connection context union */
+union conn_context {
+	struct core_conn_context core_ctx;
+	struct eth_conn_context eth_ctx;
+};
+
+#define CONN_CXT_SIZE(p_hwfn) \
+	ALIGNED_TYPE_SIZE(union conn_context, p_hwfn)
+
+/* PF per protocl configuration object */
+struct qed_conn_type_cfg {
+	u32 cid_count;
+	u32 cid_start;
+};
+
+/* ILT Client configuration, Per connection type (protocol) resources. */
+#define ILT_CLI_PF_BLOCKS	(1 + NUM_TASK_PF_SEGMENTS * 2)
+#define CDUC_BLK		(0)
+
+enum ilt_clients {
+	ILT_CLI_CDUC,
+	ILT_CLI_QM,
+	ILT_CLI_MAX
+};
+
+struct ilt_cfg_pair {
+	u32 reg;
+	u32 val;
+};
+
+struct qed_ilt_cli_blk {
+	u32 total_size; /* 0 means not active */
+	u32 real_size_in_page;
+	u32 start_line;
+};
+
+struct qed_ilt_client_cfg {
+	bool active;
+
+	/* ILT boundaries */
+	struct ilt_cfg_pair first;
+	struct ilt_cfg_pair last;
+	struct ilt_cfg_pair p_size;
+
+	/* ILT client blocks for PF */
+	struct qed_ilt_cli_blk pf_blks[ILT_CLI_PF_BLOCKS];
+	u32 pf_total_lines;
+};
+
+/* Per Path -
+ *      ILT shadow table
+ *      Protocol acquired CID lists
+ *      PF start line in ILT
+ */
+struct qed_dma_mem {
+	dma_addr_t p_phys;
+	void *p_virt;
+	size_t size;
+};
+
+#define MAP_WORD_SIZE sizeof(unsigned long)
+#define BITS_PER_MAP_WORD (MAP_WORD_SIZE * 8)
+
+struct qed_cid_acquired_map {
+	u32		start_cid;
+	u32		max_count;
+	unsigned long	*cid_map;
+};
+
+struct qed_cxt_mngr {
+	/* Per protocl configuration */
+	struct qed_conn_type_cfg	conn_cfg[MAX_CONN_TYPES];
+
+	/* computed ILT structure */
+	struct qed_ilt_client_cfg	clients[ILT_CLI_MAX];
+
+	/* Acquired CIDs */
+	struct qed_cid_acquired_map	acquired[MAX_CONN_TYPES];
+
+	/* ILT  shadow table */
+	struct qed_dma_mem		*ilt_shadow;
+	u32				pf_start_line;
+};
+
+/* counts the iids for the CDU/CDUC ILT client configuration */
+struct qed_cdu_iids {
+	u32	pf_cids;
+};
+
+static void qed_cxt_cdu_iids(struct qed_cxt_mngr *p_mngr,
+			     struct qed_cdu_iids *iids)
+{
+	u32 type;
+
+	for (type = 0; type < MAX_CONN_TYPES; type++)
+		iids->pf_cids += p_mngr->conn_cfg[type].cid_count;
+}
+
+static void qed_cxt_qm_iids(struct qed_hwfn *p_hwfn,
+			    struct qed_qm_iids *iids)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	int type;
+
+	for (type = 0; type < MAX_CONN_TYPES; type++)
+		iids->cids += p_mngr->conn_cfg[type].cid_count;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_ILT, "iids: CIDS %08x\n", iids->cids);
+}
+
+/* set the iids count per protocol */
+static void qed_cxt_set_proto_cid_count(struct qed_hwfn *p_hwfn,
+					enum protocol_type type,
+					u32 cid_count)
+{
+	struct qed_cxt_mngr *p_mgr = p_hwfn->p_cxt_mngr;
+	struct qed_conn_type_cfg *p_conn = &p_mgr->conn_cfg[type];
+
+	p_conn->cid_count = roundup(cid_count, DQ_RANGE_ALIGN);
+}
+
+static void qed_ilt_cli_blk_fill(struct qed_ilt_client_cfg *p_cli,
+				 struct qed_ilt_cli_blk *p_blk,
+				 u32 start_line, u32 total_size,
+				 u32 elem_size)
+{
+	u32 ilt_size = ILT_PAGE_IN_BYTES(p_cli->p_size.val);
+
+	/* verify thatits called only once for each block */
+	if (p_blk->total_size)
+		return;
+
+	p_blk->total_size = total_size;
+	p_blk->real_size_in_page = 0;
+	if (elem_size)
+		p_blk->real_size_in_page = (ilt_size / elem_size) * elem_size;
+	p_blk->start_line = start_line;
+}
+
+static void qed_ilt_cli_adv_line(struct qed_hwfn *p_hwfn,
+				 struct qed_ilt_client_cfg *p_cli,
+				 struct qed_ilt_cli_blk *p_blk,
+				 u32 *p_line, enum ilt_clients client_id)
+{
+	if (!p_blk->total_size)
+		return;
+
+	if (!p_cli->active)
+		p_cli->first.val = *p_line;
+
+	p_cli->active = true;
+	*p_line += DIV_ROUND_UP(p_blk->total_size,
+				p_blk->real_size_in_page);
+	p_cli->last.val = *p_line - 1;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_ILT,
+		   "ILT[Client %d] - Lines: [%08x - %08x]. Block - Size %08x [Real %08x] Start line %d\n",
+		   client_id, p_cli->first.val,
+		   p_cli->last.val, p_blk->total_size,
+		   p_blk->real_size_in_page, p_blk->start_line);
+}
+
+int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	struct qed_ilt_client_cfg *p_cli;
+	struct qed_ilt_cli_blk *p_blk;
+	struct qed_cdu_iids cdu_iids;
+	struct qed_qm_iids qm_iids;
+	u32 curr_line, total;
+
+	memset(&qm_iids, 0, sizeof(qm_iids));
+	memset(&cdu_iids, 0, sizeof(cdu_iids));
+
+	p_mngr->pf_start_line = RESC_START(p_hwfn, QED_ILT);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_ILT,
+		   "hwfn [%d] - Set context manager starting line to be 0x%08x\n",
+		   p_hwfn->my_id, p_hwfn->p_cxt_mngr->pf_start_line);
+
+	/* CDUC */
+	p_cli = &p_mngr->clients[ILT_CLI_CDUC];
+	curr_line = p_mngr->pf_start_line;
+	p_cli->pf_total_lines = 0;
+
+	/* get the counters for the CDUC and QM clients  */
+	qed_cxt_cdu_iids(p_mngr, &cdu_iids);
+
+	p_blk = &p_cli->pf_blks[CDUC_BLK];
+
+	total = cdu_iids.pf_cids * CONN_CXT_SIZE(p_hwfn);
+
+	qed_ilt_cli_blk_fill(p_cli,
+			     p_blk,
+			     curr_line,
+			     total,
+			     CONN_CXT_SIZE(p_hwfn));
+
+	qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line, ILT_CLI_CDUC);
+	p_cli->pf_total_lines = curr_line - p_blk->start_line;
+
+	/* QM */
+	p_cli	= &p_mngr->clients[ILT_CLI_QM];
+	p_blk	= &p_cli->pf_blks[0];
+
+	qed_cxt_qm_iids(p_hwfn, &qm_iids);
+	total = qed_qm_pf_mem_size(p_hwfn->rel_pf_id, qm_iids.cids, 0, 0,
+				   p_hwfn->qm_info.num_pqs, 0);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_ILT,
+		   "QM ILT Info, (cids=%d, num_pqs=%d, memory_size=%d)\n",
+		   qm_iids.cids, p_hwfn->qm_info.num_pqs, total);
+
+	qed_ilt_cli_blk_fill(p_cli, p_blk,
+			     curr_line, total * 0x1000,
+			     QM_PQ_ELEMENT_SIZE);
+
+	qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line, ILT_CLI_QM);
+	p_cli->pf_total_lines = curr_line - p_blk->start_line;
+
+	if (curr_line - p_hwfn->p_cxt_mngr->pf_start_line >
+	    RESC_NUM(p_hwfn, QED_ILT)) {
+		DP_ERR(p_hwfn, "too many ilt lines...#lines=%d\n",
+		       curr_line - p_hwfn->p_cxt_mngr->pf_start_line);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+#define for_each_ilt_valid_client(pos, clients)	\
+		for (pos = 0; pos < ILT_CLI_MAX; pos++)
+
+/* Total number of ILT lines used by this PF */
+static u32 qed_cxt_ilt_shadow_size(struct qed_ilt_client_cfg *ilt_clients)
+{
+	u32 size = 0;
+	u32 i;
+
+	for_each_ilt_valid_client(i, ilt_clients) {
+		if (!ilt_clients[i].active)
+			continue;
+		size += (ilt_clients[i].last.val -
+			 ilt_clients[i].first.val + 1);
+	}
+
+	return size;
+}
+
+static void qed_ilt_shadow_free(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ilt_client_cfg *p_cli = p_hwfn->p_cxt_mngr->clients;
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 ilt_size, i;
+
+	ilt_size = qed_cxt_ilt_shadow_size(p_cli);
+
+	for (i = 0; p_mngr->ilt_shadow && i < ilt_size; i++) {
+		struct qed_dma_mem *p_dma = &p_mngr->ilt_shadow[i];
+
+		if (p_dma->p_virt)
+			dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+					  p_dma->size, p_dma->p_virt,
+					  p_dma->p_phys);
+		p_dma->p_virt = NULL;
+	}
+	kfree(p_mngr->ilt_shadow);
+}
+
+static int qed_ilt_blk_alloc(struct qed_hwfn *p_hwfn,
+			     struct qed_ilt_cli_blk *p_blk,
+			     enum ilt_clients ilt_client,
+			     u32 start_line_offset)
+{
+	struct qed_dma_mem *ilt_shadow = p_hwfn->p_cxt_mngr->ilt_shadow;
+	u32 lines, line, sz_left;
+
+	if (!p_blk->total_size)
+		return 0;
+
+	sz_left = p_blk->total_size;
+	lines = DIV_ROUND_UP(sz_left, p_blk->real_size_in_page);
+	line = p_blk->start_line + start_line_offset -
+	       p_hwfn->p_cxt_mngr->pf_start_line;
+
+	for (; lines; lines--) {
+		dma_addr_t p_phys;
+		void *p_virt;
+		u32 size;
+
+		size = min_t(u32, sz_left,
+			     p_blk->real_size_in_page);
+		p_virt = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+					    size,
+					    &p_phys,
+					    GFP_KERNEL);
+		if (!p_virt)
+			return -ENOMEM;
+		memset(p_virt, 0, size);
+
+		ilt_shadow[line].p_phys = p_phys;
+		ilt_shadow[line].p_virt = p_virt;
+		ilt_shadow[line].size	= size;
+
+		DP_VERBOSE(p_hwfn, QED_MSG_ILT,
+			   "ILT shadow: Line [%d] Physical 0x%llx Virtual %p Size %d\n",
+			    line, (u64)p_phys, p_virt, size);
+
+		sz_left -= size;
+		line++;
+	}
+
+	return 0;
+}
+
+static int qed_ilt_shadow_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	struct qed_ilt_client_cfg *clients = p_mngr->clients;
+	struct qed_ilt_cli_blk *p_blk;
+	u32 size, i, j;
+	int rc;
+
+	size = qed_cxt_ilt_shadow_size(clients);
+	p_mngr->ilt_shadow = kcalloc(size, sizeof(struct qed_dma_mem),
+				     GFP_KERNEL);
+	if (!p_mngr->ilt_shadow) {
+		DP_NOTICE(p_hwfn, "Failed to allocate ilt shadow table\n");
+		rc = -ENOMEM;
+		goto ilt_shadow_fail;
+	} else {
+		DP_VERBOSE(p_hwfn, QED_MSG_ILT,
+			   "Allocated 0x%x bytes for ilt shadow\n",
+			   (u32)(size * sizeof(struct qed_dma_mem)));
+	}
+
+	for_each_ilt_valid_client(i, clients) {
+		if (!clients[i].active)
+			continue;
+		for (j = 0; j < ILT_CLI_PF_BLOCKS; j++) {
+			p_blk = &clients[i].pf_blks[j];
+			rc = qed_ilt_blk_alloc(p_hwfn, p_blk, i, 0);
+			if (rc != 0)
+				goto ilt_shadow_fail;
+		}
+	}
+
+	return 0;
+
+ilt_shadow_fail:
+	qed_ilt_shadow_free(p_hwfn);
+	return rc;
+}
+
+static void qed_cid_map_free(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 type;
+
+	for (type = 0; type < MAX_CONN_TYPES; type++) {
+		kfree(p_mngr->acquired[type].cid_map);
+		p_mngr->acquired[type].max_count = 0;
+		p_mngr->acquired[type].start_cid = 0;
+	}
+}
+
+static int qed_cid_map_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 start_cid	= 0;
+	u32 type;
+
+	for (type = 0; type < MAX_CONN_TYPES; type++) {
+		u32 cid_cnt = p_hwfn->p_cxt_mngr->conn_cfg[type].cid_count;
+		u32 size;
+
+		if (cid_cnt == 0)
+			continue;
+
+		size = MAP_WORD_SIZE * DIV_ROUND_UP(cid_cnt,
+						    BITS_PER_MAP_WORD);
+		p_mngr->acquired[type].cid_map = kzalloc(size, GFP_KERNEL);
+		if (!p_mngr->acquired[type].cid_map)
+			goto cid_map_fail;
+
+		p_mngr->acquired[type].max_count = cid_cnt;
+		p_mngr->acquired[type].start_cid = start_cid;
+
+		p_hwfn->p_cxt_mngr->conn_cfg[type].cid_start = start_cid;
+
+		DP_VERBOSE(p_hwfn, QED_MSG_CXT,
+			   "Type %08x start: %08x count %08x\n",
+			   type, p_mngr->acquired[type].start_cid,
+			   p_mngr->acquired[type].max_count);
+		start_cid += cid_cnt;
+	}
+
+	return 0;
+
+cid_map_fail:
+	qed_cid_map_free(p_hwfn);
+	return -ENOMEM;
+}
+
+int qed_cxt_mngr_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr;
+	u32 i;
+
+	p_mngr = kzalloc(sizeof(*p_mngr), GFP_ATOMIC);
+	if (!p_mngr) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_cxt_mngr'\n");
+		return -ENOMEM;
+	}
+
+	/* Initialize ILT client registers */
+	p_mngr->clients[ILT_CLI_CDUC].first.reg = ILT_CFG_REG(CDUC, FIRST_ILT);
+	p_mngr->clients[ILT_CLI_CDUC].last.reg = ILT_CFG_REG(CDUC, LAST_ILT);
+	p_mngr->clients[ILT_CLI_CDUC].p_size.reg = ILT_CFG_REG(CDUC, P_SIZE);
+
+	p_mngr->clients[ILT_CLI_QM].first.reg = ILT_CFG_REG(QM, FIRST_ILT);
+	p_mngr->clients[ILT_CLI_QM].last.reg = ILT_CFG_REG(QM, LAST_ILT);
+	p_mngr->clients[ILT_CLI_QM].p_size.reg = ILT_CFG_REG(QM, P_SIZE);
+
+	/* default ILT page size for all clients is 32K */
+	for (i = 0; i < ILT_CLI_MAX; i++)
+		p_mngr->clients[i].p_size.val = ILT_DEFAULT_HW_P_SIZE;
+
+	/* Set the cxt mangr pointer priori to further allocations */
+	p_hwfn->p_cxt_mngr = p_mngr;
+
+	return 0;
+}
+
+int qed_cxt_tables_alloc(struct qed_hwfn *p_hwfn)
+{
+	int rc;
+
+	/* Allocate the ILT shadow table */
+	rc = qed_ilt_shadow_alloc(p_hwfn);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to allocate ilt memory\n");
+		goto tables_alloc_fail;
+	}
+
+	/* Allocate and initialize the acquired cids bitmaps */
+	rc = qed_cid_map_alloc(p_hwfn);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to allocate cid maps\n");
+		goto tables_alloc_fail;
+	}
+
+	return 0;
+
+tables_alloc_fail:
+	qed_cxt_mngr_free(p_hwfn);
+	return rc;
+}
+
+void qed_cxt_mngr_free(struct qed_hwfn *p_hwfn)
+{
+	if (!p_hwfn->p_cxt_mngr)
+		return;
+
+	qed_cid_map_free(p_hwfn);
+	qed_ilt_shadow_free(p_hwfn);
+	kfree(p_hwfn->p_cxt_mngr);
+
+	p_hwfn->p_cxt_mngr = NULL;
+}
+
+void qed_cxt_mngr_setup(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	int type;
+
+	/* Reset acquired cids */
+	for (type = 0; type < MAX_CONN_TYPES; type++) {
+		u32 cid_cnt = p_hwfn->p_cxt_mngr->conn_cfg[type].cid_count;
+		u32 i;
+
+		if (cid_cnt == 0)
+			continue;
+
+		for (i = 0; i < DIV_ROUND_UP(cid_cnt, BITS_PER_MAP_WORD); i++)
+			p_mngr->acquired[type].cid_map[i] = 0;
+	}
+}
+
+/* CDU Common */
+#define CDUC_CXT_SIZE_SHIFT \
+	CDU_REG_CID_ADDR_PARAMS_CONTEXT_SIZE_SHIFT
+
+#define CDUC_CXT_SIZE_MASK \
+	(CDU_REG_CID_ADDR_PARAMS_CONTEXT_SIZE >> CDUC_CXT_SIZE_SHIFT)
+
+#define CDUC_BLOCK_WASTE_SHIFT \
+	CDU_REG_CID_ADDR_PARAMS_BLOCK_WASTE_SHIFT
+
+#define CDUC_BLOCK_WASTE_MASK \
+	(CDU_REG_CID_ADDR_PARAMS_BLOCK_WASTE >> CDUC_BLOCK_WASTE_SHIFT)
+
+#define CDUC_NCIB_SHIFT	\
+	CDU_REG_CID_ADDR_PARAMS_NCIB_SHIFT
+
+#define CDUC_NCIB_MASK \
+	(CDU_REG_CID_ADDR_PARAMS_NCIB >> CDUC_NCIB_SHIFT)
+
+static void qed_cdu_init_common(struct qed_hwfn *p_hwfn)
+{
+	u32 page_sz, elems_per_page, block_waste, cxt_size, cdu_params = 0;
+
+	/* CDUC - connection configuration */
+	page_sz = p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUC].p_size.val;
+	cxt_size = CONN_CXT_SIZE(p_hwfn);
+	elems_per_page = ILT_PAGE_IN_BYTES(page_sz) / cxt_size;
+	block_waste = ILT_PAGE_IN_BYTES(page_sz) - elems_per_page * cxt_size;
+
+	SET_FIELD(cdu_params, CDUC_CXT_SIZE, cxt_size);
+	SET_FIELD(cdu_params, CDUC_BLOCK_WASTE, block_waste);
+	SET_FIELD(cdu_params, CDUC_NCIB, elems_per_page);
+	STORE_RT_REG(p_hwfn, CDU_REG_CID_ADDR_PARAMS_RT_OFFSET, cdu_params);
+}
+
+void qed_qm_init_pf(struct qed_hwfn *p_hwfn)
+{
+	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
+	struct qed_qm_iids iids;
+
+	memset(&iids, 0, sizeof(iids));
+	qed_cxt_qm_iids(p_hwfn, &iids);
+
+	qed_qm_pf_rt_init(p_hwfn, p_hwfn->p_main_ptt, p_hwfn->port_id,
+			  p_hwfn->rel_pf_id, qm_info->max_phys_tcs_per_port,
+			  p_hwfn->first_on_engine,
+			  iids.cids, 0, 0,
+			  qm_info->start_pq,
+			  qm_info->num_pqs, 0,
+			  qm_info->start_vport,
+			  qm_info->num_vports, qm_info->pf_wfq, qm_info->pf_rl,
+			  p_hwfn->qm_info.qm_pq_params,
+			  p_hwfn->qm_info.qm_vport_params);
+}
+
+/* CM PF */
+static int qed_cm_init_pf(struct qed_hwfn *p_hwfn)
+{
+	union qed_qm_pq_params pq_params;
+	u16 pq;
+
+	/* XCM pure-LB queue */
+	memset(&pq_params, 0, sizeof(pq_params));
+	pq_params.core.tc = LB_TC;
+	pq = qed_get_qm_pq(p_hwfn, PROTOCOLID_CORE, &pq_params);
+	STORE_RT_REG(p_hwfn, XCM_REG_CON_PHY_Q3_RT_OFFSET, pq);
+
+	return 0;
+}
+
+/* DQ PF */
+static void qed_dq_init_pf(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 dq_pf_max_cid = 0;
+
+	dq_pf_max_cid += (p_mngr->conn_cfg[0].cid_count >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_0_RT_OFFSET, dq_pf_max_cid);
+
+	dq_pf_max_cid += (p_mngr->conn_cfg[1].cid_count >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_1_RT_OFFSET, dq_pf_max_cid);
+
+	dq_pf_max_cid += (p_mngr->conn_cfg[2].cid_count >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_2_RT_OFFSET, dq_pf_max_cid);
+
+	dq_pf_max_cid += (p_mngr->conn_cfg[3].cid_count >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_3_RT_OFFSET, dq_pf_max_cid);
+
+	dq_pf_max_cid += (p_mngr->conn_cfg[4].cid_count >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_4_RT_OFFSET, dq_pf_max_cid);
+
+	/* 5 - PF */
+	dq_pf_max_cid += (p_mngr->conn_cfg[5].cid_count >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_5_RT_OFFSET, dq_pf_max_cid);
+}
+
+static void qed_ilt_bounds_init(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ilt_client_cfg *ilt_clients;
+	int i;
+
+	ilt_clients = p_hwfn->p_cxt_mngr->clients;
+	for_each_ilt_valid_client(i, ilt_clients) {
+		if (!ilt_clients[i].active)
+			continue;
+		STORE_RT_REG(p_hwfn,
+			     ilt_clients[i].first.reg,
+			     ilt_clients[i].first.val);
+		STORE_RT_REG(p_hwfn,
+			     ilt_clients[i].last.reg,
+			     ilt_clients[i].last.val);
+		STORE_RT_REG(p_hwfn,
+			     ilt_clients[i].p_size.reg,
+			     ilt_clients[i].p_size.val);
+	}
+}
+
+/* ILT (PSWRQ2) PF */
+static void qed_ilt_init_pf(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ilt_client_cfg *clients;
+	struct qed_cxt_mngr *p_mngr;
+	struct qed_dma_mem *p_shdw;
+	u32 line, rt_offst, i;
+
+	qed_ilt_bounds_init(p_hwfn);
+
+	p_mngr	= p_hwfn->p_cxt_mngr;
+	p_shdw	= p_mngr->ilt_shadow;
+	clients = p_hwfn->p_cxt_mngr->clients;
+
+	for_each_ilt_valid_client(i, clients) {
+		if (!clients[i].active)
+			continue;
+
+		/** Client's 1st val and RT array are absolute, ILT shadows'
+		 *  lines are relative.
+		 */
+		line = clients[i].first.val - p_mngr->pf_start_line;
+		rt_offst = PSWRQ2_REG_ILT_MEMORY_RT_OFFSET +
+			   clients[i].first.val * ILT_ENTRY_IN_REGS;
+
+		for (; line <= clients[i].last.val - p_mngr->pf_start_line;
+		     line++, rt_offst += ILT_ENTRY_IN_REGS) {
+			u64 ilt_hw_entry = 0;
+
+			/** p_virt could be NULL incase of dynamic
+			 *  allocation
+			 */
+			if (p_shdw[line].p_virt) {
+				SET_FIELD(ilt_hw_entry, ILT_ENTRY_VALID, 1ULL);
+				SET_FIELD(ilt_hw_entry, ILT_ENTRY_PHY_ADDR,
+					  (p_shdw[line].p_phys >> 12));
+
+				DP_VERBOSE(p_hwfn, QED_MSG_ILT,
+					   "Setting RT[0x%08x] from ILT[0x%08x] [Client is %d] to Physical addr: 0x%llx\n",
+					   rt_offst, line, i,
+					   (u64)(p_shdw[line].p_phys >> 12));
+			}
+
+			STORE_RT_REG_AGG(p_hwfn, rt_offst, ilt_hw_entry);
+		}
+	}
+}
+
+void qed_cxt_hw_init_common(struct qed_hwfn *p_hwfn)
+{
+	qed_cdu_init_common(p_hwfn);
+}
+
+void qed_cxt_hw_init_pf(struct qed_hwfn *p_hwfn)
+{
+	qed_qm_init_pf(p_hwfn);
+	qed_cm_init_pf(p_hwfn);
+	qed_dq_init_pf(p_hwfn);
+	qed_ilt_init_pf(p_hwfn);
+}
+
+int qed_cxt_acquire_cid(struct qed_hwfn *p_hwfn,
+			enum protocol_type type,
+			u32 *p_cid)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 rel_cid;
+
+	if (type >= MAX_CONN_TYPES || !p_mngr->acquired[type].cid_map) {
+		DP_NOTICE(p_hwfn, "Invalid protocol type %d", type);
+		return -EINVAL;
+	}
+
+	rel_cid = find_first_zero_bit(p_mngr->acquired[type].cid_map,
+				      p_mngr->acquired[type].max_count);
+
+	if (rel_cid >= p_mngr->acquired[type].max_count) {
+		DP_NOTICE(p_hwfn, "no CID available for protocol %d\n",
+			  type);
+		return -EINVAL;
+	}
+
+	__set_bit(rel_cid, p_mngr->acquired[type].cid_map);
+
+	*p_cid = rel_cid + p_mngr->acquired[type].start_cid;
+
+	return 0;
+}
+
+static bool qed_cxt_test_cid_acquired(struct qed_hwfn *p_hwfn,
+				      u32 cid,
+				      enum protocol_type *p_type)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	struct qed_cid_acquired_map *p_map;
+	enum protocol_type p;
+	u32 rel_cid;
+
+	/* Iterate over protocols and find matching cid range */
+	for (p = 0; p < MAX_CONN_TYPES; p++) {
+		p_map = &p_mngr->acquired[p];
+
+		if (!p_map->cid_map)
+			continue;
+		if (cid >= p_map->start_cid &&
+		    cid < p_map->start_cid + p_map->max_count)
+			break;
+	}
+	*p_type = p;
+
+	if (p == MAX_CONN_TYPES) {
+		DP_NOTICE(p_hwfn, "Invalid CID %d", cid);
+		return false;
+	}
+
+	rel_cid = cid - p_map->start_cid;
+	if (!test_bit(rel_cid, p_map->cid_map)) {
+		DP_NOTICE(p_hwfn, "CID %d not acquired", cid);
+		return false;
+	}
+	return true;
+}
+
+void qed_cxt_release_cid(struct qed_hwfn *p_hwfn,
+			 u32 cid)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	enum protocol_type type;
+	bool b_acquired;
+	u32 rel_cid;
+
+	/* Test acquired and find matching per-protocol map */
+	b_acquired = qed_cxt_test_cid_acquired(p_hwfn, cid, &type);
+
+	if (!b_acquired)
+		return;
+
+	rel_cid = cid - p_mngr->acquired[type].start_cid;
+	__clear_bit(rel_cid, p_mngr->acquired[type].cid_map);
+}
+
+int qed_cxt_get_cid_info(struct qed_hwfn *p_hwfn,
+			 struct qed_cxt_info *p_info)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 conn_cxt_size, hw_p_size, cxts_per_p, line;
+	enum protocol_type type;
+	bool b_acquired;
+
+	/* Test acquired and find matching per-protocol map */
+	b_acquired = qed_cxt_test_cid_acquired(p_hwfn, p_info->iid, &type);
+
+	if (!b_acquired)
+		return -EINVAL;
+
+	/* set the protocl type */
+	p_info->type = type;
+
+	/* compute context virtual pointer */
+	hw_p_size = p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUC].p_size.val;
+
+	conn_cxt_size = CONN_CXT_SIZE(p_hwfn);
+	cxts_per_p = ILT_PAGE_IN_BYTES(hw_p_size) / conn_cxt_size;
+	line = p_info->iid / cxts_per_p;
+
+	/* Make sure context is allocated (dynamic allocation) */
+	if (!p_mngr->ilt_shadow[line].p_virt)
+		return -EINVAL;
+
+	p_info->p_cxt = (u8 *)p_mngr->ilt_shadow[line].p_virt +
+			      p_info->iid % cxts_per_p * conn_cxt_size;
+
+	DP_VERBOSE(p_hwfn, (QED_MSG_ILT | QED_MSG_CXT),
+		   "Accessing ILT shadow[%d]: CXT pointer is at %p (for iid %d)\n",
+		   p_info->iid / cxts_per_p, p_info->p_cxt, p_info->iid);
+
+	return 0;
+}
+
+int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn)
+{
+	struct qed_eth_pf_params *p_params = &p_hwfn->pf_params.eth_pf_params;
+
+	/* Set the number of required CORE connections */
+	u32 core_cids = 1; /* SPQ */
+
+	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_CORE, core_cids);
+
+	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_ETH,
+				    p_params->num_cons);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.h b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
new file mode 100644
index 0000000..570a73d
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
@@ -0,0 +1,138 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_CXT_H
+#define _QED_CXT_H
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/qed/qed_if.h>
+#include "qed_hsi.h"
+#include "qed.h"
+
+struct qed_cxt_info {
+	void			*p_cxt;
+	u32			iid;
+	enum protocol_type	type;
+};
+
+/**
+ * @brief qed_cxt_acquire - Acquire a new cid of a specific protocol type
+ *
+ * @param p_hwfn
+ * @param type
+ * @param p_cid
+ *
+ * @return int
+ */
+int qed_cxt_acquire_cid(struct qed_hwfn		*p_hwfn,
+			enum protocol_type	type,
+			u32			*p_cid);
+
+/**
+ * @brief qedo_cid_get_cxt_info - Returns the context info for a specific cid
+ *
+ *
+ * @param p_hwfn
+ * @param p_info in/out
+ *
+ * @return int
+ */
+int qed_cxt_get_cid_info(struct qed_hwfn	*p_hwfn,
+			 struct qed_cxt_info	*p_info);
+
+enum qed_cxt_elem_type {
+	QED_ELEM_CXT,
+	QED_ELEM_TASK
+};
+
+/**
+ * @brief qed_cxt_set_pf_params - Set the PF params for cxt init
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_cxt_cfg_ilt_compute - compute ILT init parameters
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_cxt_mngr_alloc - Allocate and init the context manager struct
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_cxt_mngr_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_cxt_mngr_free
+ *
+ * @param p_hwfn
+ */
+void qed_cxt_mngr_free(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_cxt_tables_alloc - Allocate ILT shadow, Searcher T2, acquired map
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_cxt_tables_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_cxt_mngr_setup - Reset the acquired CIDs
+ *
+ * @param p_hwfn
+ */
+void qed_cxt_mngr_setup(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_cxt_hw_init_common - Initailze ILT and DQ, common phase, per path.
+ *
+ *
+ *
+ * @param p_hwfn
+ */
+void qed_cxt_hw_init_common(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_cxt_hw_init_pf - Initailze ILT and DQ, PF phase, per path.
+ *
+ *
+ *
+ * @param p_hwfn
+ */
+void qed_cxt_hw_init_pf(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_qm_init_pf - Initailze the QM PF phase, per path
+ *
+ * @param p_hwfn
+ */
+
+void qed_qm_init_pf(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_cxt_release - Release a cid
+ *
+ * @param p_hwfn
+ * @param cid
+ */
+void qed_cxt_release_cid(struct qed_hwfn	*p_hwfn,
+			 u32			cid);
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
new file mode 100644
index 0000000..14366af
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -0,0 +1,1285 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/mutex.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/etherdevice.h>
+#include <linux/qed/qed_chain.h>
+#include <linux/qed/qed_if.h>
+#include "qed.h"
+#include "qed_cxt.h"
+#include "qed_dev_api.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_init_ops.h"
+#include "qed_int.h"
+#include "qed_mcp.h"
+#include "qed_reg_addr.h"
+#include "qed_sp.h"
+
+/* API common to all protocols */
+void qed_init_dp(struct qed_dev *cdev,
+		 u32		dp_module,
+		 u8		dp_level)
+{
+	u32 i;
+
+	cdev->dp_level	= dp_level;
+	cdev->dp_module = dp_module;
+	for (i = 0; i < MAX_HWFNS_PER_DEVICE; i++) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		p_hwfn->dp_level	= dp_level;
+		p_hwfn->dp_module	= dp_module;
+	}
+}
+
+void qed_init_struct(struct qed_dev *cdev)
+{
+	u8 i;
+
+	for (i = 0; i < MAX_HWFNS_PER_DEVICE; i++) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		p_hwfn->cdev		= cdev;
+		p_hwfn->my_id		= i;
+		p_hwfn->b_active	= false;
+
+		;
+		mutex_init(&p_hwfn->dmae_info.mutex);
+	}
+
+	/* hwfn 0 is always active */
+	cdev->hwfns[0].b_active = true;
+
+	/* set the default cache alignment to 128 */
+	cdev->cache_shift = 7;
+}
+
+static void qed_qm_info_free(struct qed_hwfn *p_hwfn)
+{
+	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
+
+	kfree(qm_info->qm_pq_params);
+	qm_info->qm_pq_params = NULL;
+	kfree(qm_info->qm_vport_params);
+	qm_info->qm_vport_params = NULL;
+	kfree(qm_info->qm_port_params);
+	qm_info->qm_port_params = NULL;
+}
+
+void qed_resc_free(struct qed_dev *cdev)
+{
+	int i;
+
+	kfree(cdev->fw_data);
+	cdev->fw_data = NULL;
+
+	kfree(cdev->reset_stats);
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		qed_cxt_mngr_free(p_hwfn);
+		qed_qm_info_free(p_hwfn);
+		qed_spq_free(p_hwfn);
+		qed_eq_free(p_hwfn, p_hwfn->p_eq);
+		qed_consq_free(p_hwfn, p_hwfn->p_consq);
+		qed_int_free(p_hwfn);
+		qed_dmae_info_free(p_hwfn);
+	}
+}
+
+static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
+{
+	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
+	struct init_qm_port_params *p_qm_port;
+	u8 num_vports, i, vport_id, num_ports;
+	u16 num_pqs, multi_cos_tcs = 1;
+
+	memset(qm_info, 0, sizeof(*qm_info));
+
+	num_pqs = multi_cos_tcs + 1; /* The '1' is for pure-LB */
+	num_vports = (u8)RESC_NUM(p_hwfn, QED_VPORT);
+
+	/* Sanity checking that setup requires legal number of resources */
+	if (num_pqs > RESC_NUM(p_hwfn, QED_PQ)) {
+		DP_ERR(p_hwfn,
+		       "Need too many Physical queues - 0x%04x when only %04x are available\n",
+		       num_pqs, RESC_NUM(p_hwfn, QED_PQ));
+		return -EINVAL;
+	}
+
+	/* PQs will be arranged as follows: First per-TC PQ then pure-LB quete.
+	 */
+	qm_info->qm_pq_params = kzalloc(sizeof(*qm_info->qm_pq_params) *
+					num_pqs, GFP_ATOMIC);
+	if (!qm_info->qm_pq_params)
+		goto alloc_err;
+
+	qm_info->qm_vport_params = kzalloc(sizeof(*qm_info->qm_vport_params) *
+					   num_vports, GFP_ATOMIC);
+	if (!qm_info->qm_vport_params)
+		goto alloc_err;
+
+	qm_info->qm_port_params = kzalloc(sizeof(*qm_info->qm_port_params) *
+					  MAX_NUM_PORTS, GFP_ATOMIC);
+	if (!qm_info->qm_port_params)
+		goto alloc_err;
+
+	vport_id = (u8)RESC_START(p_hwfn, QED_VPORT);
+
+	/* First init per-TC PQs */
+	for (i = 0; i < multi_cos_tcs; i++) {
+		struct init_qm_pq_params *params = &qm_info->qm_pq_params[i];
+
+		params->vport_id = vport_id;
+		params->tc_id = p_hwfn->hw_info.non_offload_tc;
+		params->wrr_group = 1;
+	}
+
+	/* Then init pure-LB PQ */
+	qm_info->pure_lb_pq = i;
+	qm_info->qm_pq_params[i].vport_id = (u8)RESC_START(p_hwfn, QED_VPORT);
+	qm_info->qm_pq_params[i].tc_id = PURE_LB_TC;
+	qm_info->qm_pq_params[i].wrr_group = 1;
+	i++;
+
+	qm_info->offload_pq = 0;
+	qm_info->num_pqs = num_pqs;
+	qm_info->num_vports = num_vports;
+
+	/* Initialize qm port parameters */
+	num_ports = p_hwfn->cdev->num_ports_in_engines;
+	for (i = 0; i < num_ports; i++) {
+		p_qm_port = &qm_info->qm_port_params[i];
+		p_qm_port->active = 1;
+		p_qm_port->num_active_phys_tcs = 4;
+		p_qm_port->num_pbf_cmd_lines = PBF_MAX_CMD_LINES / num_ports;
+		p_qm_port->num_btb_blocks = BTB_MAX_BLOCKS / num_ports;
+	}
+
+	qm_info->max_phys_tcs_per_port = NUM_OF_PHYS_TCS;
+
+	qm_info->start_pq = (u16)RESC_START(p_hwfn, QED_PQ);
+
+	qm_info->start_vport = (u8)RESC_START(p_hwfn, QED_VPORT);
+
+	qm_info->pf_wfq = 0;
+	qm_info->pf_rl = 0;
+	qm_info->vport_rl_en = 1;
+
+	return 0;
+
+alloc_err:
+	DP_NOTICE(p_hwfn, "Failed to allocate memory for QM params\n");
+	kfree(qm_info->qm_pq_params);
+	kfree(qm_info->qm_vport_params);
+	kfree(qm_info->qm_port_params);
+
+	return -ENOMEM;
+}
+
+int qed_resc_alloc(struct qed_dev *cdev)
+{
+	struct qed_consq *p_consq;
+	struct qed_eq *p_eq;
+	int i, rc = 0;
+
+	cdev->fw_data = kzalloc(sizeof(*cdev->fw_data), GFP_KERNEL);
+	if (!cdev->fw_data)
+		return -ENOMEM;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		/* First allocate the context manager structure */
+		rc = qed_cxt_mngr_alloc(p_hwfn);
+		if (rc)
+			goto alloc_err;
+
+		/* Set the HW cid/tid numbers (in the contest manager)
+		 * Must be done prior to any further computations.
+		 */
+		rc = qed_cxt_set_pf_params(p_hwfn);
+		if (rc)
+			goto alloc_err;
+
+		/* Prepare and process QM requirements */
+		rc = qed_init_qm_info(p_hwfn);
+		if (rc)
+			goto alloc_err;
+
+		/* Compute the ILT client partition */
+		rc = qed_cxt_cfg_ilt_compute(p_hwfn);
+		if (rc)
+			goto alloc_err;
+
+		/* CID map / ILT shadow table / T2
+		 * The talbes sizes are determined by the computations above
+		 */
+		rc = qed_cxt_tables_alloc(p_hwfn);
+		if (rc)
+			goto alloc_err;
+
+		/* SPQ, must follow ILT because initializes SPQ context */
+		rc = qed_spq_alloc(p_hwfn);
+		if (rc)
+			goto alloc_err;
+
+		/* SP status block allocation */
+		p_hwfn->p_dpc_ptt = qed_get_reserved_ptt(p_hwfn,
+							 RESERVED_PTT_DPC);
+
+		rc = qed_int_alloc(p_hwfn, p_hwfn->p_main_ptt);
+		if (rc)
+			goto alloc_err;
+
+		/* EQ */
+		p_eq = qed_eq_alloc(p_hwfn, 256);
+
+		if (!p_eq)
+			goto alloc_err;
+		p_hwfn->p_eq = p_eq;
+
+		p_consq = qed_consq_alloc(p_hwfn);
+		if (!p_consq)
+			goto alloc_err;
+		p_hwfn->p_consq = p_consq;
+
+		/* DMA info initialization */
+		rc = qed_dmae_info_alloc(p_hwfn);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "Failed to allocate memory for dmae_info structure\n");
+			goto alloc_err;
+		}
+	}
+
+	cdev->reset_stats = kzalloc(sizeof(*cdev->reset_stats), GFP_ATOMIC);
+	if (!cdev->reset_stats) {
+		DP_NOTICE(cdev, "Failed to allocate reset statistics\n");
+		goto alloc_err;
+	}
+
+	return 0;
+
+alloc_err:
+	qed_resc_free(cdev);
+	return rc;
+}
+
+void qed_resc_setup(struct qed_dev *cdev)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		qed_cxt_mngr_setup(p_hwfn);
+		qed_spq_setup(p_hwfn);
+		qed_eq_setup(p_hwfn, p_hwfn->p_eq);
+		qed_consq_setup(p_hwfn, p_hwfn->p_consq);
+
+		/* Read shadow of current MFW mailbox */
+		qed_mcp_read_mb(p_hwfn, p_hwfn->p_main_ptt);
+		memcpy(p_hwfn->mcp_info->mfw_mb_shadow,
+		       p_hwfn->mcp_info->mfw_mb_cur,
+		       p_hwfn->mcp_info->mfw_mb_length);
+
+		qed_int_setup(p_hwfn, p_hwfn->p_main_ptt);
+	}
+}
+
+#define FINAL_CLEANUP_CMD_OFFSET        (0)
+#define FINAL_CLEANUP_CMD (0x1)
+#define FINAL_CLEANUP_VALID_OFFSET      (6)
+#define FINAL_CLEANUP_VFPF_ID_SHIFT     (7)
+#define FINAL_CLEANUP_COMP (0x2)
+#define FINAL_CLEANUP_POLL_CNT          (100)
+#define FINAL_CLEANUP_POLL_TIME         (10)
+int qed_final_cleanup(struct qed_hwfn *p_hwfn,
+		      struct qed_ptt *p_ptt,
+		      u16 id)
+{
+	u32 command = 0, addr, count = FINAL_CLEANUP_POLL_CNT;
+	int rc = -EBUSY;
+
+	addr = GTT_BAR0_MAP_REG_USDM_RAM + USTORM_FLR_FINAL_ACK_OFFSET;
+
+	command |= FINAL_CLEANUP_CMD << FINAL_CLEANUP_CMD_OFFSET;
+	command |= 1 << FINAL_CLEANUP_VALID_OFFSET;
+	command |= id << FINAL_CLEANUP_VFPF_ID_SHIFT;
+	command |= FINAL_CLEANUP_COMP << SDM_OP_GEN_COMP_TYPE_SHIFT;
+
+	/* Make sure notification is not set before initiating final cleanup */
+	if (REG_RD(p_hwfn, addr)) {
+		DP_NOTICE(
+			p_hwfn,
+			"Unexpected; Found final cleanup notification before initiating final cleanup\n");
+		REG_WR(p_hwfn, addr, 0);
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "Sending final cleanup for PFVF[%d] [Command %08x\n]",
+		   id, command);
+
+	qed_wr(p_hwfn, p_ptt, XSDM_REG_OPERATION_GEN, command);
+
+	/* Poll until completion */
+	while (!REG_RD(p_hwfn, addr) && count--)
+		msleep(FINAL_CLEANUP_POLL_TIME);
+
+	if (REG_RD(p_hwfn, addr))
+		rc = 0;
+	else
+		DP_NOTICE(p_hwfn,
+			  "Failed to receive FW final cleanup notification\n");
+
+	/* Cleanup afterwards */
+	REG_WR(p_hwfn, addr, 0);
+
+	return rc;
+}
+
+static void qed_calc_hw_mode(struct qed_hwfn *p_hwfn)
+{
+	int hw_mode = 0;
+
+	hw_mode = (1 << MODE_BB_A0);
+
+	switch (p_hwfn->cdev->num_ports_in_engines) {
+	case 1:
+		hw_mode |= 1 << MODE_PORTS_PER_ENG_1;
+		break;
+	case 2:
+		hw_mode |= 1 << MODE_PORTS_PER_ENG_2;
+		break;
+	case 4:
+		hw_mode |= 1 << MODE_PORTS_PER_ENG_4;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "num_ports_in_engine = %d not supported\n",
+			  p_hwfn->cdev->num_ports_in_engines);
+		return;
+	}
+
+	switch (p_hwfn->cdev->mf_mode) {
+	case SF:
+		hw_mode |= 1 << MODE_SF;
+		break;
+	case MF_OVLAN:
+		hw_mode |= 1 << MODE_MF_SD;
+		break;
+	case MF_NPAR:
+		hw_mode |= 1 << MODE_MF_SI;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Unsupported MF mode, init as SF\n");
+		hw_mode |= 1 << MODE_SF;
+	}
+
+	hw_mode |= 1 << MODE_ASIC;
+
+	p_hwfn->hw_info.hw_mode = hw_mode;
+}
+
+/* Init run time data for all PFs on an engine. */
+static void qed_init_cau_rt_data(struct qed_dev *cdev)
+{
+	u32 offset = CAU_REG_SB_VAR_MEMORY_RT_OFFSET;
+	int i, sb_id;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		struct qed_igu_info *p_igu_info;
+		struct qed_igu_block *p_block;
+		struct cau_sb_entry sb_entry;
+
+		p_igu_info = p_hwfn->hw_info.p_igu_info;
+
+		for (sb_id = 0; sb_id < QED_MAPPING_MEMORY_SIZE(cdev);
+		     sb_id++) {
+			p_block = &p_igu_info->igu_map.igu_blocks[sb_id];
+			if (!p_block->is_pf)
+				continue;
+
+			qed_init_cau_sb_entry(p_hwfn, &sb_entry,
+					      p_block->function_id,
+					      0, 0);
+			STORE_RT_REG_AGG(p_hwfn, offset + sb_id * 2,
+					 sb_entry);
+		}
+	}
+}
+
+static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt,
+			      int hw_mode)
+{
+	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
+	struct qed_dev *cdev = p_hwfn->cdev;
+	int rc = 0;
+
+	qed_init_cau_rt_data(cdev);
+
+	/* Program GTT windows */
+	qed_gtt_init(p_hwfn);
+
+	if (p_hwfn->mcp_info) {
+		if (p_hwfn->mcp_info->func_info.bandwidth_max)
+			qm_info->pf_rl_en = 1;
+		if (p_hwfn->mcp_info->func_info.bandwidth_min)
+			qm_info->pf_wfq_en = 1;
+	}
+
+	qed_qm_common_rt_init(p_hwfn,
+			      p_hwfn->cdev->num_ports_in_engines,
+			      qm_info->max_phys_tcs_per_port,
+			      qm_info->pf_rl_en, qm_info->pf_wfq_en,
+			      qm_info->vport_rl_en, qm_info->vport_wfq_en,
+			      qm_info->qm_port_params);
+
+	qed_cxt_hw_init_common(p_hwfn);
+
+	/* Close gate from NIG to BRB/Storm; By default they are open, but
+	 * we close them to prevent NIG from passing data to reset blocks.
+	 * Should have been done in the ENGINE phase, but init-tool lacks
+	 * proper port-pretend capabilities.
+	 */
+	qed_wr(p_hwfn, p_ptt, NIG_REG_RX_BRB_OUT_EN, 0);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_STORM_OUT_EN, 0);
+	qed_port_pretend(p_hwfn, p_ptt, p_hwfn->port_id ^ 1);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_RX_BRB_OUT_EN, 0);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_STORM_OUT_EN, 0);
+	qed_port_unpretend(p_hwfn, p_ptt);
+
+	rc = qed_init_run(p_hwfn, p_ptt, PHASE_ENGINE, ANY_PHASE_ID, hw_mode);
+	if (rc != 0)
+		return rc;
+
+	qed_wr(p_hwfn, p_ptt, PSWRQ2_REG_L2P_VALIDATE_VFID, 0);
+	qed_wr(p_hwfn, p_ptt, PGLUE_B_REG_USE_CLIENTID_IN_TAG, 1);
+
+	/* Disable relaxed ordering in the PCI config space */
+	qed_wr(p_hwfn, p_ptt, 0x20b4,
+	       qed_rd(p_hwfn, p_ptt, 0x20b4) & ~0x10);
+
+	return rc;
+}
+
+static int qed_hw_init_port(struct qed_hwfn *p_hwfn,
+			    struct qed_ptt *p_ptt,
+			    int hw_mode)
+{
+	int rc = 0;
+
+	rc = qed_init_run(p_hwfn, p_ptt, PHASE_PORT, p_hwfn->port_id,
+			  hw_mode);
+	return rc;
+}
+
+static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  int hw_mode,
+			  bool b_hw_start,
+			  enum qed_int_mode int_mode,
+			  bool allow_npar_tx_switch)
+{
+	u8 rel_pf_id = p_hwfn->rel_pf_id;
+	int rc = 0;
+
+	if (p_hwfn->mcp_info) {
+		struct qed_mcp_function_info *p_info;
+
+		p_info = &p_hwfn->mcp_info->func_info;
+		if (p_info->bandwidth_min)
+			p_hwfn->qm_info.pf_wfq = p_info->bandwidth_min;
+
+		/* Update rate limit once we'll actually have a link */
+		p_hwfn->qm_info.pf_rl = 100;
+	}
+
+	qed_cxt_hw_init_pf(p_hwfn);
+
+	qed_int_igu_init_rt(p_hwfn);
+
+	/* Set VLAN in NIG if needed */
+	if (hw_mode & (1 << MODE_MF_SD)) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_HW, "Configuring LLH_FUNC_TAG\n");
+		STORE_RT_REG(p_hwfn, NIG_REG_LLH_FUNC_TAG_EN_RT_OFFSET, 1);
+		STORE_RT_REG(p_hwfn, NIG_REG_LLH_FUNC_TAG_VALUE_RT_OFFSET,
+			     p_hwfn->hw_info.ovlan);
+	}
+
+	/* Enable classification by MAC if needed */
+	if (hw_mode & MODE_MF_SI) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+			   "Configuring TAGMAC_CLS_TYPE\n");
+		STORE_RT_REG(p_hwfn,
+			     NIG_REG_LLH_FUNC_TAGMAC_CLS_TYPE_RT_OFFSET, 1);
+	}
+
+	/* Protocl Configuration  */
+	STORE_RT_REG(p_hwfn, PRS_REG_SEARCH_TCP_RT_OFFSET, 0);
+	STORE_RT_REG(p_hwfn, PRS_REG_SEARCH_FCOE_RT_OFFSET, 0);
+	STORE_RT_REG(p_hwfn, PRS_REG_SEARCH_ROCE_RT_OFFSET, 0);
+
+	/* Cleanup chip from previous driver if such remains exist */
+	rc = qed_final_cleanup(p_hwfn, p_ptt, rel_pf_id);
+	if (rc != 0)
+		return rc;
+
+	/* PF Init sequence */
+	rc = qed_init_run(p_hwfn, p_ptt, PHASE_PF, rel_pf_id, hw_mode);
+	if (rc)
+		return rc;
+
+	/* QM_PF Init sequence (may be invoked separately e.g. for DCB) */
+	rc = qed_init_run(p_hwfn, p_ptt, PHASE_QM_PF, rel_pf_id, hw_mode);
+	if (rc)
+		return rc;
+
+	/* Pure runtime initializations - directly to the HW  */
+	qed_int_igu_init_pure_rt(p_hwfn, p_ptt, true, true);
+
+	if (b_hw_start) {
+		/* enable interrupts */
+		qed_int_igu_enable(p_hwfn, p_ptt, int_mode);
+
+		/* send function start command */
+		rc = qed_sp_pf_start(p_hwfn, p_hwfn->cdev->mf_mode);
+		if (rc)
+			DP_NOTICE(p_hwfn, "Function start ramrod failed\n");
+	}
+	return rc;
+}
+
+static int qed_change_pci_hwfn(struct qed_hwfn *p_hwfn,
+			       struct qed_ptt *p_ptt,
+			       u8 enable)
+{
+	u32 delay_idx = 0, val, set_val = enable ? 1 : 0;
+
+	/* Change PF in PXP */
+	qed_wr(p_hwfn, p_ptt,
+	       PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER, set_val);
+
+	/* wait until value is set - try for 1 second every 50us */
+	for (delay_idx = 0; delay_idx < 20000; delay_idx++) {
+		val = qed_rd(p_hwfn, p_ptt,
+			     PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER);
+		if (val == set_val)
+			break;
+
+		usleep_range(50, 60);
+	}
+
+	if (val != set_val) {
+		DP_NOTICE(p_hwfn,
+			  "PFID_ENABLE_MASTER wasn't changed after a second\n");
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
+static void qed_reset_mb_shadow(struct qed_hwfn *p_hwfn,
+				struct qed_ptt	*p_main_ptt)
+{
+	/* Read shadow of current MFW mailbox */
+	qed_mcp_read_mb(p_hwfn, p_main_ptt);
+	memcpy(p_hwfn->mcp_info->mfw_mb_shadow,
+	       p_hwfn->mcp_info->mfw_mb_cur,
+	       p_hwfn->mcp_info->mfw_mb_length);
+}
+
+int qed_hw_init(struct qed_dev *cdev,
+		bool b_hw_start,
+		enum qed_int_mode int_mode,
+		bool allow_npar_tx_switch,
+		const u8 *bin_fw_data)
+{
+	u32 load_code, param;
+	int rc, mfw_rc, i;
+
+	rc = qed_init_fw_data(cdev, bin_fw_data);
+	if (rc != 0)
+		return rc;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		/* Enable DMAE in PXP */
+		rc = qed_change_pci_hwfn(p_hwfn, p_hwfn->p_main_ptt, true);
+
+		qed_calc_hw_mode(p_hwfn);
+
+		rc = qed_mcp_load_req(p_hwfn, p_hwfn->p_main_ptt,
+				      &load_code);
+		if (rc) {
+			DP_NOTICE(p_hwfn, "Failed sending LOAD_REQ command\n");
+			return rc;
+		}
+
+		qed_reset_mb_shadow(p_hwfn, p_hwfn->p_main_ptt);
+
+		DP_VERBOSE(
+			p_hwfn,
+			QED_MSG_SP,
+			"Load request was sent. Resp:0x%x, Load code: 0x%x\n",
+			rc,
+			load_code);
+
+		p_hwfn->first_on_engine = (load_code ==
+					   FW_MSG_CODE_DRV_LOAD_ENGINE);
+
+		switch (load_code) {
+		case FW_MSG_CODE_DRV_LOAD_ENGINE:
+			rc = qed_hw_init_common(p_hwfn, p_hwfn->p_main_ptt,
+						p_hwfn->hw_info.hw_mode);
+			if (rc)
+				break;
+		/* Fall into */
+		case FW_MSG_CODE_DRV_LOAD_PORT:
+			rc = qed_hw_init_port(p_hwfn, p_hwfn->p_main_ptt,
+					      p_hwfn->hw_info.hw_mode);
+			if (rc)
+				break;
+
+		/* Fall into */
+		case FW_MSG_CODE_DRV_LOAD_FUNCTION:
+			rc = qed_hw_init_pf(p_hwfn, p_hwfn->p_main_ptt,
+					    p_hwfn->hw_info.hw_mode,
+					    b_hw_start, int_mode,
+					    allow_npar_tx_switch);
+			break;
+		default:
+			rc = -EINVAL;
+			break;
+		}
+
+		if (rc)
+			DP_NOTICE(p_hwfn,
+				  "init phase failed for loadcode 0x%x (rc %d)\n",
+				   load_code, rc);
+
+		/* ACK mfw regardless of success or failure of initialization */
+		mfw_rc = qed_mcp_cmd(p_hwfn, p_hwfn->p_main_ptt,
+				     DRV_MSG_CODE_LOAD_DONE,
+				     0, &load_code, &param);
+		if (rc)
+			return rc;
+		if (mfw_rc) {
+			DP_NOTICE(p_hwfn, "Failed sending LOAD_DONE command\n");
+			return mfw_rc;
+		}
+
+		p_hwfn->hw_init_done = true;
+	}
+
+	return 0;
+}
+
+#define QED_HW_STOP_RETRY_LIMIT (10)
+int qed_hw_stop(struct qed_dev *cdev)
+{
+	int rc = 0, t_rc;
+	int i, j;
+
+	for_each_hwfn(cdev, j) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[j];
+		struct qed_ptt *p_ptt	= p_hwfn->p_main_ptt;
+
+		DP_VERBOSE(p_hwfn, NETIF_MSG_IFDOWN, "Stopping hw/fw\n");
+
+		/* mark the hw as uninitialized... */
+		p_hwfn->hw_init_done = false;
+
+		rc = qed_sp_pf_stop(p_hwfn);
+		if (rc)
+			return rc;
+
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x1);
+
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_TCP, 0x0);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_UDP, 0x0);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_FCOE, 0x0);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_ROCE, 0x0);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_OPENFLOW, 0x0);
+
+		qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_CONN, 0x0);
+		qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_TASK, 0x0);
+		for (i = 0; i < QED_HW_STOP_RETRY_LIMIT; i++) {
+			if ((!qed_rd(p_hwfn, p_ptt,
+				     TM_REG_PF_SCAN_ACTIVE_CONN)) &&
+			    (!qed_rd(p_hwfn, p_ptt,
+				     TM_REG_PF_SCAN_ACTIVE_TASK)))
+				break;
+
+			usleep_range(1000, 2000);
+		}
+		if (i == QED_HW_STOP_RETRY_LIMIT)
+			DP_NOTICE(p_hwfn,
+				  "Timers linear scans are not over [Connection %02x Tasks %02x]\n",
+				  (u8)qed_rd(p_hwfn, p_ptt,
+					     TM_REG_PF_SCAN_ACTIVE_CONN),
+				  (u8)qed_rd(p_hwfn, p_ptt,
+					     TM_REG_PF_SCAN_ACTIVE_TASK));
+
+		/* Disable Attention Generation */
+		qed_int_igu_disable_int(p_hwfn, p_ptt);
+
+		qed_wr(p_hwfn, p_ptt, IGU_REG_LEADING_EDGE_LATCH, 0);
+		qed_wr(p_hwfn, p_ptt, IGU_REG_TRAILING_EDGE_LATCH, 0);
+
+		qed_int_igu_init_pure_rt(p_hwfn, p_ptt, false, true);
+
+		/* Need to wait 1ms to guarantee SBs are cleared */
+		usleep_range(1000, 2000);
+	}
+
+	/* Disable DMAE in PXP - in CMT, this should only be done for
+	 * first hw-function, and only after all transactions have
+	 * stopped for all active hw-functions.
+	 */
+	t_rc = qed_change_pci_hwfn(&cdev->hwfns[0],
+				   cdev->hwfns[0].p_main_ptt,
+				   false);
+	if (t_rc != 0)
+		rc = t_rc;
+
+	return rc;
+}
+
+static int qed_reg_assert(struct qed_hwfn *hwfn,
+			  struct qed_ptt *ptt, u32 reg,
+			  bool expected)
+{
+	u32 assert_val = qed_rd(hwfn, ptt, reg);
+
+	if (assert_val != expected) {
+		DP_NOTICE(hwfn, "Value at address 0x%x != 0x%08x\n",
+			  reg, expected);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int qed_hw_reset(struct qed_dev *cdev)
+{
+	int rc = 0;
+	u32 unload_resp, unload_param;
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		DP_VERBOSE(p_hwfn, NETIF_MSG_IFDOWN, "Resetting hw/fw\n");
+
+		/* Check for incorrect states */
+		qed_reg_assert(p_hwfn, p_hwfn->p_main_ptt,
+			       QM_REG_USG_CNT_PF_TX, 0);
+		qed_reg_assert(p_hwfn, p_hwfn->p_main_ptt,
+			       QM_REG_USG_CNT_PF_OTHER, 0);
+
+		/* Disable PF in HW blocks */
+		qed_wr(p_hwfn, p_hwfn->p_main_ptt, DORQ_REG_PF_DB_ENABLE, 0);
+		qed_wr(p_hwfn, p_hwfn->p_main_ptt, QM_REG_PF_EN, 0);
+		qed_wr(p_hwfn, p_hwfn->p_main_ptt,
+		       TCFC_REG_STRONG_ENABLE_PF, 0);
+		qed_wr(p_hwfn, p_hwfn->p_main_ptt,
+		       CCFC_REG_STRONG_ENABLE_PF, 0);
+
+		/* Send unload command to MCP */
+		rc = qed_mcp_cmd(p_hwfn, p_hwfn->p_main_ptt,
+				 DRV_MSG_CODE_UNLOAD_REQ,
+				 DRV_MB_PARAM_UNLOAD_WOL_MCP,
+				 &unload_resp, &unload_param);
+		if (rc) {
+			DP_NOTICE(p_hwfn, "qed_hw_reset: UNLOAD_REQ failed\n");
+			unload_resp = FW_MSG_CODE_DRV_UNLOAD_ENGINE;
+		}
+
+		rc = qed_mcp_cmd(p_hwfn, p_hwfn->p_main_ptt,
+				 DRV_MSG_CODE_UNLOAD_DONE,
+				 0, &unload_resp, &unload_param);
+		if (rc) {
+			DP_NOTICE(p_hwfn, "qed_hw_reset: UNLOAD_DONE failed\n");
+			return rc;
+		}
+	}
+
+	return rc;
+}
+
+/* Free hwfn memory and resources acquired in hw_hwfn_prepare */
+static void qed_hw_hwfn_free(struct qed_hwfn *p_hwfn)
+{
+	qed_ptt_pool_free(p_hwfn);
+	kfree(p_hwfn->hw_info.p_igu_info);
+}
+
+/* Setup bar access */
+static int qed_hw_hwfn_prepare(struct qed_hwfn *p_hwfn)
+{
+	int rc;
+
+	/* Allocate PTT pool */
+	rc = qed_ptt_pool_alloc(p_hwfn);
+	if (rc)
+		return rc;
+
+	/* Allocate the main PTT */
+	p_hwfn->p_main_ptt = qed_get_reserved_ptt(p_hwfn, RESERVED_PTT_MAIN);
+
+	/* clear indirect access */
+	qed_wr(p_hwfn, p_hwfn->p_main_ptt, PGLUE_B_REG_PGL_ADDR_88_F0, 0);
+	qed_wr(p_hwfn, p_hwfn->p_main_ptt, PGLUE_B_REG_PGL_ADDR_8C_F0, 0);
+	qed_wr(p_hwfn, p_hwfn->p_main_ptt, PGLUE_B_REG_PGL_ADDR_90_F0, 0);
+	qed_wr(p_hwfn, p_hwfn->p_main_ptt, PGLUE_B_REG_PGL_ADDR_94_F0, 0);
+
+	/* Clean Previous errors if such exist */
+	qed_wr(p_hwfn, p_hwfn->p_main_ptt,
+	       PGLUE_B_REG_WAS_ERROR_PF_31_0_CLR,
+	       1 << p_hwfn->abs_pf_id);
+
+	/* enable internal target-read */
+	qed_wr(p_hwfn, p_hwfn->p_main_ptt,
+	       PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ, 1);
+
+	return 0;
+}
+
+static void get_function_id(struct qed_hwfn *p_hwfn)
+{
+	/* ME Register */
+	p_hwfn->hw_info.opaque_fid = (u16)REG_RD(p_hwfn, PXP_PF_ME_OPAQUE_ADDR);
+
+	p_hwfn->hw_info.concrete_fid = REG_RD(p_hwfn, PXP_PF_ME_CONCRETE_ADDR);
+
+	p_hwfn->abs_pf_id = (p_hwfn->hw_info.concrete_fid >> 16) & 0xf;
+	p_hwfn->rel_pf_id = GET_FIELD(p_hwfn->hw_info.concrete_fid,
+				      PXP_CONCRETE_FID_PFID);
+	p_hwfn->port_id = GET_FIELD(p_hwfn->hw_info.concrete_fid,
+				    PXP_CONCRETE_FID_PORT);
+}
+
+static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
+{
+	u32 *resc_start = p_hwfn->hw_info.resc_start;
+	u32 *resc_num = p_hwfn->hw_info.resc_num;
+	int num_funcs, i;
+
+	num_funcs = IS_MF(p_hwfn) ? MAX_NUM_PFS_BB
+				  : p_hwfn->cdev->num_ports_in_engines;
+
+	resc_num[QED_SB] = min_t(u32,
+				 (MAX_SB_PER_PATH_BB / num_funcs),
+				 qed_int_get_num_sbs(p_hwfn, NULL));
+	resc_num[QED_VPORT] = MAX_NUM_VPORTS_BB / num_funcs;
+	resc_num[QED_PQ] = MAX_QM_TX_QUEUES_BB / num_funcs;
+	resc_num[QED_RL] = 8;
+	resc_num[QED_ILT] = 950;
+
+	for (i = 0; i < QED_MAX_RESC; i++)
+		resc_start[i] = resc_num[i] * p_hwfn->rel_pf_id;
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_PROBE,
+		   "The numbers for each resource are:\n"
+		   "SB = %d start = %d\n"
+		   "VPORT = %d start = %d\n"
+		   "PQ = %d start = %d\n"
+		   "RL = %d start = %d\n"
+		   "ILT = %d start = %d\n",
+		   p_hwfn->hw_info.resc_num[QED_SB],
+		   p_hwfn->hw_info.resc_start[QED_SB],
+		   p_hwfn->hw_info.resc_num[QED_VPORT],
+		   p_hwfn->hw_info.resc_start[QED_VPORT],
+		   p_hwfn->hw_info.resc_num[QED_PQ],
+		   p_hwfn->hw_info.resc_start[QED_PQ],
+		   p_hwfn->hw_info.resc_num[QED_RL],
+		   p_hwfn->hw_info.resc_start[QED_RL],
+		   p_hwfn->hw_info.resc_num[QED_ILT],
+		   p_hwfn->hw_info.resc_start[QED_ILT]);
+}
+
+static int qed_hw_get_nvm_info(struct qed_hwfn	*p_hwfn,
+			       struct qed_ptt	*p_ptt)
+{
+	u32 nvm_cfg1_offset, mf_mode, addr, generic_cont0;
+	u32 val;
+
+	/* Read global nvm_cfg address */
+	u32 nvm_cfg_addr = qed_rd(p_hwfn, p_ptt, MISC_REG_GEN_PURP_CR0);
+
+	/* Verify MCP has initialized it */
+	if (nvm_cfg_addr == 0) {
+		DP_NOTICE(p_hwfn, "Shared memory not initialized\n");
+		return -EINVAL;
+	}
+
+	/* Read nvm_cfg1  (Notice this is just offset, and not offsize (TBD) */
+	nvm_cfg1_offset = qed_rd(p_hwfn, p_ptt, nvm_cfg_addr + 4);
+
+	/* Read Vendor Id / Device Id */
+	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
+	       offsetof(struct nvm_cfg1, glob) +
+	       offsetof(struct nvm_cfg1_glob, pci_id);
+	p_hwfn->hw_info.vendor_id = qed_rd(p_hwfn, p_ptt, addr) &
+				    NVM_CFG1_GLOB_VENDOR_ID_MASK;
+	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
+	       offsetof(struct nvm_cfg1, func[MCP_PF_ID(p_hwfn)]) +
+	       offsetof(struct nvm_cfg1_func, device_id);
+	val = qed_rd(p_hwfn, p_ptt, addr);
+
+	if (IS_MF(p_hwfn)) {
+		p_hwfn->hw_info.device_id =
+			(val & NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_MASK) >>
+			NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_OFFSET;
+	} else {
+		p_hwfn->hw_info.device_id =
+			(val & NVM_CFG1_FUNC_VENDOR_DEVICE_ID_MASK) >>
+			NVM_CFG1_FUNC_VENDOR_DEVICE_ID_OFFSET;
+	}
+
+	/* Read Multi-function information from shmem */
+	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
+	       offsetof(struct nvm_cfg1, glob) +
+	       offsetof(struct nvm_cfg1_glob, generic_cont0);
+
+	generic_cont0 = qed_rd(p_hwfn, p_ptt, addr);
+
+	mf_mode = (generic_cont0 & NVM_CFG1_GLOB_MF_MODE_MASK) >>
+		  NVM_CFG1_GLOB_MF_MODE_OFFSET;
+
+	switch (mf_mode) {
+	case NVM_CFG1_GLOB_MF_MODE_MF_ALLOWED:
+		p_hwfn->cdev->mf_mode = MF_OVLAN;
+		break;
+	case NVM_CFG1_GLOB_MF_MODE_NPAR1_0:
+		p_hwfn->cdev->mf_mode = MF_NPAR;
+		break;
+	case NVM_CFG1_GLOB_MF_MODE_FORCED_SF:
+		p_hwfn->cdev->mf_mode = SF;
+		break;
+	}
+	DP_INFO(p_hwfn, "Multi function mode is %08x\n",
+		p_hwfn->cdev->mf_mode);
+
+	return qed_mcp_fill_shmem_func_info(p_hwfn, p_ptt);
+}
+
+static int
+qed_get_hw_info(struct qed_hwfn *p_hwfn,
+		struct qed_ptt *p_ptt,
+		enum qed_pci_personality personality)
+{
+	u32 port_mode;
+	int rc;
+
+	/* Read the port mode */
+	port_mode = qed_rd(p_hwfn, p_ptt,
+			   CNIG_REG_NW_PORT_MODE_BB_B0);
+
+	if (port_mode < 3) {
+		p_hwfn->cdev->num_ports_in_engines = 1;
+	} else if (port_mode <= 5) {
+		p_hwfn->cdev->num_ports_in_engines = 2;
+	} else {
+		DP_NOTICE(p_hwfn, "PORT MODE: %d not supported\n",
+			  p_hwfn->cdev->num_ports_in_engines);
+
+		/* Default num_ports_in_engines to something */
+		p_hwfn->cdev->num_ports_in_engines = 1;
+	}
+
+	qed_hw_get_nvm_info(p_hwfn, p_ptt);
+
+	rc = qed_int_igu_read_cam(p_hwfn, p_ptt);
+	if (rc)
+		return rc;
+
+	if (qed_mcp_is_init(p_hwfn)) {
+		ether_addr_copy(p_hwfn->hw_info.hw_mac_addr,
+				p_hwfn->mcp_info->func_info.mac);
+	} else {
+		static u8 mcp_hw_mac[6] = { 0, 2, 3, 4, 5, 6 };
+
+		ether_addr_copy(p_hwfn->hw_info.hw_mac_addr, mcp_hw_mac);
+		p_hwfn->hw_info.hw_mac_addr[5] = p_hwfn->abs_pf_id;
+	}
+
+	if (qed_mcp_is_init(p_hwfn)) {
+		if (p_hwfn->mcp_info->func_info.ovlan != QED_MCP_VLAN_UNSET)
+			p_hwfn->hw_info.ovlan =
+				p_hwfn->mcp_info->func_info.ovlan;
+
+		qed_mcp_cmd_port_init(p_hwfn, p_ptt);
+	}
+
+	if (qed_mcp_is_init(p_hwfn))
+		p_hwfn->hw_info.personality =
+			p_hwfn->mcp_info->func_info.protocol;
+
+	qed_hw_get_resc(p_hwfn);
+
+	return rc;
+}
+
+static int qed_get_dev_info(struct qed_dev *cdev)
+{
+	u32 tmp;
+
+	cdev->chip_num = (u16)qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+				     MISCS_REG_CHIP_NUM);
+	cdev->chip_rev = (u16)qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+				     MISCS_REG_CHIP_REV);
+	MASK_FIELD(CHIP_REV, cdev->chip_rev);
+
+	/* Learn number of HW-functions */
+	tmp = qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+		     MISCS_REG_CMT_ENABLED_FOR_PAIR);
+
+	if (tmp & (1 << cdev->hwfns[0].rel_pf_id)) {
+		DP_NOTICE(cdev->hwfns, "device in CMT mode\n");
+		cdev->num_hwfns = 2;
+	} else {
+		cdev->num_hwfns = 1;
+	}
+
+	cdev->chip_bond_id = qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+				    MISCS_REG_CHIP_TEST_REG) >> 4;
+	MASK_FIELD(CHIP_BOND_ID, cdev->chip_bond_id);
+	cdev->chip_metal = (u16)qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+				       MISCS_REG_CHIP_METAL);
+	MASK_FIELD(CHIP_METAL, cdev->chip_metal);
+
+	DP_INFO(cdev->hwfns,
+		"Chip details - Num: %04x Rev: %04x Bond id: %04x Metal: %04x\n",
+		cdev->chip_num, cdev->chip_rev,
+		cdev->chip_bond_id, cdev->chip_metal);
+
+	return 0;
+}
+
+static int qed_hw_prepare_single(struct qed_hwfn *p_hwfn,
+				 void __iomem *p_regview,
+				 void __iomem *p_doorbells,
+				 enum qed_pci_personality personality)
+{
+	int rc = 0;
+
+	/* Split PCI bars evenly between hwfns */
+	p_hwfn->regview		= p_regview;
+	p_hwfn->doorbells	= p_doorbells;
+
+	/* Validate that chip access is feasible */
+	if (REG_RD(p_hwfn, PXP_PF_ME_OPAQUE_ADDR) == 0xffffffff) {
+		DP_ERR(p_hwfn,
+		       "Reading the ME register returns all Fs; Preventing further chip access\n");
+		return -EINVAL;
+	}
+
+	get_function_id(p_hwfn);
+
+	rc = qed_hw_hwfn_prepare(p_hwfn);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to prepare hwfn's hw\n");
+		goto err0;
+	}
+
+	/* First hwfn learns basic information, e.g., number of hwfns */
+	if (!p_hwfn->my_id) {
+		rc = qed_get_dev_info(p_hwfn->cdev);
+		if (rc != 0)
+			goto err1;
+	}
+
+	/* Initialize MCP structure */
+	rc = qed_mcp_cmd_init(p_hwfn, p_hwfn->p_main_ptt);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed initializing mcp command\n");
+		goto err1;
+	}
+
+	/* Read the device configuration information from the HW and SHMEM */
+	rc = qed_get_hw_info(p_hwfn, p_hwfn->p_main_ptt, personality);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to get HW information\n");
+		goto err2;
+	}
+
+	/* Allocate the init RT array and initialize the init-ops engine */
+	rc = qed_init_alloc(p_hwfn);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to allocate the init array\n");
+		goto err2;
+	}
+
+	return rc;
+err2:
+	qed_mcp_free(p_hwfn);
+err1:
+	qed_hw_hwfn_free(p_hwfn);
+err0:
+	return rc;
+}
+
+static u32 qed_hw_bar_size(struct qed_dev	*cdev,
+			   u8			bar_id)
+{
+	u32 size = pci_resource_len(cdev->pdev, (bar_id > 0) ? 2 : 0);
+
+	return size / cdev->num_hwfns;
+}
+
+int qed_hw_prepare(struct qed_dev	*cdev,
+		   int			personality)
+{
+	int rc, i;
+
+	/* Store the precompiled init data ptrs */
+	qed_init_iro_array(cdev);
+
+	/* Initialize the first hwfn - will learn number of hwfns */
+	rc = qed_hw_prepare_single(&cdev->hwfns[0], cdev->regview,
+				   cdev->doorbells, personality);
+	if (rc != 0)
+		return rc;
+
+	personality = cdev->hwfns[0].hw_info.personality;
+
+	/* Initialize the rest of the hwfns */
+	for (i = 1; i < cdev->num_hwfns; i++) {
+		void __iomem *p_regview, *p_doorbell;
+
+		p_regview = (void __iomem *)
+			    ((u8 __iomem *)cdev->regview + i *
+					   qed_hw_bar_size(cdev, 0));
+		p_doorbell = (void __iomem *)
+			     ((u8 __iomem *)cdev->doorbells + i *
+					    qed_hw_bar_size(cdev, 1));
+		rc = qed_hw_prepare_single(&cdev->hwfns[i], p_regview,
+					   p_doorbell, personality);
+		if (rc != 0) {
+			/* Cleanup previously initialized hwfns */
+			while (--i >= 0) {
+				qed_init_free(&cdev->hwfns[i]);
+				qed_mcp_free(&cdev->hwfns[i]);
+				qed_hw_hwfn_free(&cdev->hwfns[i]);
+			}
+			return rc;
+		}
+	}
+
+	return 0;
+}
+
+void qed_hw_remove(struct qed_dev *cdev)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		qed_init_free(p_hwfn);
+		qed_hw_hwfn_free(p_hwfn);
+		qed_mcp_free(p_hwfn);
+	}
+}
+
+int qed_chain_alloc(struct qed_dev *cdev,
+		    enum qed_chain_use_mode intended_use,
+		    enum qed_chain_mode mode,
+		    u16	num_elems,
+		    size_t elem_size,
+		    struct qed_chain *p_chain)
+{
+	dma_addr_t p_pbl_phys = 0;
+	void *p_pbl_virt = NULL;
+	dma_addr_t p_phys = 0;
+	void *p_virt = NULL;
+	u16 page_cnt = 0;
+	size_t size;
+
+	if (mode == QED_CHAIN_MODE_SINGLE)
+		page_cnt = 1;
+	else
+		page_cnt = QED_CHAIN_PAGE_CNT(num_elems, elem_size, mode);
+
+	size = page_cnt * QED_CHAIN_PAGE_SIZE;
+	p_virt = dma_alloc_coherent(&cdev->pdev->dev,
+				    size, &p_phys, GFP_KERNEL);
+	if (!p_virt) {
+		DP_NOTICE(cdev, "Failed to allocate chain mem\n");
+		goto nomem;
+	}
+
+	if (mode == QED_CHAIN_MODE_PBL) {
+		size = page_cnt * QED_CHAIN_PBL_ENTRY_SIZE;
+		p_pbl_virt = dma_alloc_coherent(&cdev->pdev->dev,
+						size, &p_pbl_phys,
+						GFP_KERNEL);
+		if (!p_pbl_virt) {
+			DP_NOTICE(cdev, "Failed to allocate chain pbl mem\n");
+			goto nomem;
+		}
+
+		qed_chain_pbl_init(p_chain, p_virt, p_phys, page_cnt,
+				   (u8)elem_size, intended_use,
+				   p_pbl_phys, p_pbl_virt);
+	} else {
+		qed_chain_init(p_chain, p_virt, p_phys, page_cnt,
+			       (u8)elem_size, intended_use, mode);
+	}
+
+	return 0;
+
+nomem:
+	dma_free_coherent(&cdev->pdev->dev,
+			  page_cnt * QED_CHAIN_PAGE_SIZE,
+			  p_virt, p_phys);
+	dma_free_coherent(&cdev->pdev->dev,
+			  page_cnt * QED_CHAIN_PBL_ENTRY_SIZE,
+			  p_pbl_virt, p_pbl_phys);
+
+	return -ENOMEM;
+}
+
+void qed_chain_free(struct qed_dev *cdev,
+		    struct qed_chain *p_chain)
+{
+	size_t size;
+
+	if (!p_chain->p_virt_addr)
+		return;
+
+	if (p_chain->mode == QED_CHAIN_MODE_PBL) {
+		size = p_chain->page_cnt * QED_CHAIN_PBL_ENTRY_SIZE;
+		dma_free_coherent(&cdev->pdev->dev, size,
+				  p_chain->pbl.p_virt_table,
+				  p_chain->pbl.p_phys_table);
+	}
+
+	size = p_chain->page_cnt * QED_CHAIN_PAGE_SIZE;
+	dma_free_coherent(&cdev->pdev->dev, size,
+			  p_chain->p_virt_addr,
+			  p_chain->p_phys_addr);
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
new file mode 100644
index 0000000..1579035
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -0,0 +1,221 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_DEV_API_H
+#define _QED_DEV_API_H
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/qed/qed_chain.h>
+#include <linux/qed/qed_if.h>
+#include "qed_int.h"
+
+/**
+ * @brief qed_init_dp - initialize the debug level
+ *
+ * @param cdev
+ * @param dp_module
+ * @param dp_level
+ */
+void qed_init_dp(struct qed_dev *cdev,
+		 u32		dp_module,
+		 u8		dp_level);
+
+/**
+ * @brief qed_init_struct - initialize the device structure to
+ *        its defaults
+ *
+ * @param cdev
+ */
+void qed_init_struct(struct qed_dev *cdev);
+
+/**
+ * @brief qed_resc_free -
+ *
+ * @param cdev
+ */
+void qed_resc_free(struct qed_dev *cdev);
+
+/**
+ * @brief qed_resc_alloc -
+ *
+ * @param cdev
+ *
+ * @return int
+ */
+int qed_resc_alloc(struct qed_dev *cdev);
+
+/**
+ * @brief qed_resc_setup -
+ *
+ * @param cdev
+ */
+void qed_resc_setup(struct qed_dev *cdev);
+
+/**
+ * @brief qed_hw_init -
+ *
+ * @param cdev
+ * @param b_hw_start
+ * @param int_mode - interrupt mode [msix, inta, etc.] to use.
+ * @param allow_npar_tx_switch - npar tx switching to be used
+ *	  for vports configured for tx-switching.
+ * @param bin_fw_data - binary fw data pointer in binary fw file.
+ *			Pass NULL if not using binary fw file.
+ *
+ * @return int
+ */
+int qed_hw_init(struct qed_dev			*cdev,
+		bool				b_hw_start,
+		enum qed_int_mode		int_mode,
+		bool				allow_npar_tx_switch,
+		const u8			*bin_fw_data);
+
+/**
+ * @brief qed_hw_stop -
+ *
+ * @param cdev
+ *
+ * @return int
+ */
+int qed_hw_stop(struct qed_dev *cdev);
+
+/**
+ * @brief qed_hw_reset -
+ *
+ * @param cdev
+ *
+ * @return int
+ */
+int qed_hw_reset(struct qed_dev *cdev);
+
+/**
+ * @brief qed_hw_prepare -
+ *
+ * @param cdev
+ * @param personality - personality to initialize
+ *
+ * @return int
+ */
+int qed_hw_prepare(struct qed_dev	*cdev,
+		   int			personality);
+
+/**
+ * @brief qed_hw_remove -
+ *
+ * @param cdev
+ */
+void qed_hw_remove(struct qed_dev *cdev);
+
+/**
+ * @brief qed_ptt_acquire - Allocate a PTT window
+ *
+ * Should be called at the entry point to the driver (at the beginning of an
+ * exported function)
+ *
+ * @param p_hwfn
+ *
+ * @return struct qed_ptt
+ */
+struct qed_ptt *qed_ptt_acquire(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_ptt_release - Release PTT Window
+ *
+ * Should be called at the end of a flow - at the end of the function that
+ * acquired the PTT.
+ *
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ */
+void qed_ptt_release(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt);
+
+enum qed_dmae_address_type_t {
+	QED_DMAE_ADDRESS_HOST_VIRT,
+	QED_DMAE_ADDRESS_HOST_PHYS,
+	QED_DMAE_ADDRESS_GRC
+};
+
+/* value of flags If QED_DMAE_FLAG_RW_REPL_SRC flag is set and the
+ * source is a block of length DMAE_MAX_RW_SIZE and the
+ * destination is larger, the source block will be duplicated as
+ * many times as required to fill the destination block. This is
+ * used mostly to write a zeroed buffer to destination address
+ * using DMA
+ */
+#define QED_DMAE_FLAG_RW_REPL_SRC       0x00000001
+#define QED_DMAE_FLAG_COMPLETION_DST    0x00000008
+
+struct qed_dmae_params {
+	u32	flags; /* consists of QED_DMAE_FLAG_* values */
+};
+
+/**
+ * @brief qed_dmae_host2grc - copy data from source addr to
+ * dmae registers using the given ptt
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param source_addr
+ * @param grc_addr (dmae_data_offset)
+ * @param size_in_dwords
+ * @param flags (one of the flags defined above)
+ */
+int
+qed_dmae_host2grc(struct qed_hwfn	*p_hwfn,
+		  struct qed_ptt	*p_ptt,
+		  u64			source_addr,
+		  u32			grc_addr,
+		  u32			size_in_dwords,
+		  u32			flags);
+
+/**
+ * @brief qed_chain_alloc - Allocate and initialize a chain
+ *
+ * @param p_hwfn
+ * @param intended_use
+ * @param mode
+ * @param num_elems
+ * @param elem_size
+ * @param p_chain
+ *
+ * @return int
+ */
+int
+qed_chain_alloc(struct qed_dev		*cdev,
+		enum qed_chain_use_mode intended_use,
+		enum qed_chain_mode	mode,
+		u16			num_elems,
+		size_t			elem_size,
+		struct qed_chain	*p_chain);
+
+/**
+ * @brief qed_chain_free - Free chain DMA memory
+ *
+ * @param p_hwfn
+ * @param p_chain
+ */
+void qed_chain_free(struct qed_dev	*cdev,
+		    struct qed_chain	*p_chain);
+
+/**
+ * *@brief Cleanup of previous driver remains prior to load
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param id - For PF, engine-relative. For VF, PF-relative.
+ *
+ * @return int
+ */
+int qed_final_cleanup(struct qed_hwfn	*p_hwfn,
+		      struct qed_ptt	*p_ptt,
+		      u16		id);
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
new file mode 100644
index 0000000..cbb0c1c
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -0,0 +1,5040 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_HSI_H
+#define _QED_HSI_H
+#include <linux/types.h>
+#include <linux/io.h>
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/qed/common_hsi.h>
+
+struct qed_hwfn;
+struct qed_ptt;
+/********************************/
+/* Add include to common target */
+/********************************/
+
+/* opcodes for the event ring */
+enum common_event_opcode {
+	COMMON_EVENT_PF_START,
+	COMMON_EVENT_PF_STOP,
+	COMMON_EVENT_RESERVED,
+	COMMON_EVENT_RESERVED2,
+	COMMON_EVENT_RESERVED3,
+	COMMON_EVENT_RESERVED4,
+	COMMON_EVENT_RESERVED5,
+	MAX_COMMON_EVENT_OPCODE
+};
+
+/* Common Ramrod Command IDs */
+enum common_ramrod_cmd_id {
+	COMMON_RAMROD_UNUSED,
+	COMMON_RAMROD_PF_START /* PF Function Start Ramrod */,
+	COMMON_RAMROD_PF_STOP /* PF Function Stop Ramrod */,
+	COMMON_RAMROD_RESERVED,
+	COMMON_RAMROD_RESERVED2,
+	COMMON_RAMROD_RESERVED3,
+	MAX_COMMON_RAMROD_CMD_ID
+};
+
+/* The core storm context for the Ystorm */
+struct ystorm_core_conn_st_ctx {
+	__le32 reserved[4];
+};
+
+/* The core storm context for the Pstorm */
+struct pstorm_core_conn_st_ctx {
+	__le32 reserved[4];
+};
+
+/* Core Slowpath Connection storm context of Xstorm */
+struct xstorm_core_conn_st_ctx {
+	__le32		spq_base_lo /* SPQ Ring Base Address low dword */;
+	__le32		spq_base_hi /* SPQ Ring Base Address high dword */;
+	struct regpair	consolid_base_addr;
+	__le16		spq_cons /* SPQ Ring Consumer */;
+	__le16		consolid_cons /* Consolidation Ring Consumer */;
+	__le32		reserved0[55] /* Pad to 15 cycles */;
+};
+
+struct xstorm_core_conn_ag_ctx {
+	u8	reserved0 /* cdu_validation */;
+	u8	core_state /* state */;
+	u8	flags0;
+#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM0_MASK         0x1
+#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM0_SHIFT        0
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED1_MASK            0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED1_SHIFT           1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED2_MASK            0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED2_SHIFT           2
+#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM3_MASK         0x1
+#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM3_SHIFT        3
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED3_MASK            0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED3_SHIFT           4
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED4_MASK            0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED4_SHIFT           5
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED5_MASK            0x1   /* bit6 */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED5_SHIFT           6
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED6_MASK            0x1   /* bit7 */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED6_SHIFT           7
+	u8 flags1;
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED7_MASK            0x1   /* bit8 */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED7_SHIFT           0
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED8_MASK            0x1   /* bit9 */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED8_SHIFT           1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED9_MASK            0x1   /* bit10 */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED9_SHIFT           2
+#define XSTORM_CORE_CONN_AG_CTX_BIT11_MASK                0x1   /* bit11 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT11_SHIFT               3
+#define XSTORM_CORE_CONN_AG_CTX_BIT12_MASK                0x1   /* bit12 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT12_SHIFT               4
+#define XSTORM_CORE_CONN_AG_CTX_BIT13_MASK                0x1   /* bit13 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT13_SHIFT               5
+#define XSTORM_CORE_CONN_AG_CTX_TX_RULE_ACTIVE_MASK       0x1   /* bit14 */
+#define XSTORM_CORE_CONN_AG_CTX_TX_RULE_ACTIVE_SHIFT      6
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_ACTIVE_MASK         0x1   /* bit15 */
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_ACTIVE_SHIFT        7
+	u8 flags2;
+#define XSTORM_CORE_CONN_AG_CTX_CF0_MASK                  0x3   /* timer0cf */
+#define XSTORM_CORE_CONN_AG_CTX_CF0_SHIFT                 0
+#define XSTORM_CORE_CONN_AG_CTX_CF1_MASK                  0x3   /* timer1cf */
+#define XSTORM_CORE_CONN_AG_CTX_CF1_SHIFT                 2
+#define XSTORM_CORE_CONN_AG_CTX_CF2_MASK                  0x3   /* timer2cf */
+#define XSTORM_CORE_CONN_AG_CTX_CF2_SHIFT                 4
+#define XSTORM_CORE_CONN_AG_CTX_CF3_MASK                  0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF3_SHIFT                 6
+	u8 flags3;
+#define XSTORM_CORE_CONN_AG_CTX_CF4_MASK                  0x3   /* cf4 */
+#define XSTORM_CORE_CONN_AG_CTX_CF4_SHIFT                 0
+#define XSTORM_CORE_CONN_AG_CTX_CF5_MASK                  0x3   /* cf5 */
+#define XSTORM_CORE_CONN_AG_CTX_CF5_SHIFT                 2
+#define XSTORM_CORE_CONN_AG_CTX_CF6_MASK                  0x3   /* cf6 */
+#define XSTORM_CORE_CONN_AG_CTX_CF6_SHIFT                 4
+#define XSTORM_CORE_CONN_AG_CTX_CF7_MASK                  0x3   /* cf7 */
+#define XSTORM_CORE_CONN_AG_CTX_CF7_SHIFT                 6
+	u8 flags4;
+#define XSTORM_CORE_CONN_AG_CTX_CF8_MASK                  0x3   /* cf8 */
+#define XSTORM_CORE_CONN_AG_CTX_CF8_SHIFT                 0
+#define XSTORM_CORE_CONN_AG_CTX_CF9_MASK                  0x3   /* cf9 */
+#define XSTORM_CORE_CONN_AG_CTX_CF9_SHIFT                 2
+#define XSTORM_CORE_CONN_AG_CTX_CF10_MASK                 0x3   /* cf10 */
+#define XSTORM_CORE_CONN_AG_CTX_CF10_SHIFT                4
+#define XSTORM_CORE_CONN_AG_CTX_CF11_MASK                 0x3   /* cf11 */
+#define XSTORM_CORE_CONN_AG_CTX_CF11_SHIFT                6
+	u8 flags5;
+#define XSTORM_CORE_CONN_AG_CTX_CF12_MASK                 0x3   /* cf12 */
+#define XSTORM_CORE_CONN_AG_CTX_CF12_SHIFT                0
+#define XSTORM_CORE_CONN_AG_CTX_CF13_MASK                 0x3   /* cf13 */
+#define XSTORM_CORE_CONN_AG_CTX_CF13_SHIFT                2
+#define XSTORM_CORE_CONN_AG_CTX_CF14_MASK                 0x3   /* cf14 */
+#define XSTORM_CORE_CONN_AG_CTX_CF14_SHIFT                4
+#define XSTORM_CORE_CONN_AG_CTX_CF15_MASK                 0x3   /* cf15 */
+#define XSTORM_CORE_CONN_AG_CTX_CF15_SHIFT                6
+	u8 flags6;
+#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_MASK     0x3   /* cf16 */
+#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_SHIFT    0
+#define XSTORM_CORE_CONN_AG_CTX_CF17_MASK                 0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF17_SHIFT                2
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_MASK                0x3   /* cf18 */
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_SHIFT               4
+#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_MASK         0x3   /* cf19 */
+#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_SHIFT        6
+	u8 flags7;
+#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_MASK             0x3   /* cf20 */
+#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_SHIFT            0
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED10_MASK           0x3   /* cf21 */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED10_SHIFT          2
+#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_MASK            0x3   /* cf22 */
+#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_SHIFT           4
+#define XSTORM_CORE_CONN_AG_CTX_CF0EN_MASK                0x1   /* cf0en */
+#define XSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT               6
+#define XSTORM_CORE_CONN_AG_CTX_CF1EN_MASK                0x1   /* cf1en */
+#define XSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT               7
+	u8 flags8;
+#define XSTORM_CORE_CONN_AG_CTX_CF2EN_MASK                0x1   /* cf2en */
+#define XSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT               0
+#define XSTORM_CORE_CONN_AG_CTX_CF3EN_MASK                0x1   /* cf3en */
+#define XSTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT               1
+#define XSTORM_CORE_CONN_AG_CTX_CF4EN_MASK                0x1   /* cf4en */
+#define XSTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT               2
+#define XSTORM_CORE_CONN_AG_CTX_CF5EN_MASK                0x1   /* cf5en */
+#define XSTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT               3
+#define XSTORM_CORE_CONN_AG_CTX_CF6EN_MASK                0x1   /* cf6en */
+#define XSTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT               4
+#define XSTORM_CORE_CONN_AG_CTX_CF7EN_MASK                0x1   /* cf7en */
+#define XSTORM_CORE_CONN_AG_CTX_CF7EN_SHIFT               5
+#define XSTORM_CORE_CONN_AG_CTX_CF8EN_MASK                0x1   /* cf8en */
+#define XSTORM_CORE_CONN_AG_CTX_CF8EN_SHIFT               6
+#define XSTORM_CORE_CONN_AG_CTX_CF9EN_MASK                0x1   /* cf9en */
+#define XSTORM_CORE_CONN_AG_CTX_CF9EN_SHIFT               7
+	u8 flags9;
+#define XSTORM_CORE_CONN_AG_CTX_CF10EN_MASK               0x1   /* cf10en */
+#define XSTORM_CORE_CONN_AG_CTX_CF10EN_SHIFT              0
+#define XSTORM_CORE_CONN_AG_CTX_CF11EN_MASK               0x1   /* cf11en */
+#define XSTORM_CORE_CONN_AG_CTX_CF11EN_SHIFT              1
+#define XSTORM_CORE_CONN_AG_CTX_CF12EN_MASK               0x1   /* cf12en */
+#define XSTORM_CORE_CONN_AG_CTX_CF12EN_SHIFT              2
+#define XSTORM_CORE_CONN_AG_CTX_CF13EN_MASK               0x1   /* cf13en */
+#define XSTORM_CORE_CONN_AG_CTX_CF13EN_SHIFT              3
+#define XSTORM_CORE_CONN_AG_CTX_CF14EN_MASK               0x1   /* cf14en */
+#define XSTORM_CORE_CONN_AG_CTX_CF14EN_SHIFT              4
+#define XSTORM_CORE_CONN_AG_CTX_CF15EN_MASK               0x1   /* cf15en */
+#define XSTORM_CORE_CONN_AG_CTX_CF15EN_SHIFT              5
+#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_EN_MASK  0x1   /* cf16en */
+#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_EN_SHIFT 6
+#define XSTORM_CORE_CONN_AG_CTX_CF17EN_MASK               0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF17EN_SHIFT              7
+	u8 flags10;
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_EN_MASK             0x1   /* cf18en */
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_EN_SHIFT            0
+#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_EN_MASK      0x1   /* cf19en */
+#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_EN_SHIFT     1
+#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_EN_MASK          0x1   /* cf20en */
+#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_EN_SHIFT         2
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED11_MASK           0x1   /* cf21en */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED11_SHIFT          3
+#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_EN_MASK         0x1   /* cf22en */
+#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_EN_SHIFT        4
+#define XSTORM_CORE_CONN_AG_CTX_CF23EN_MASK               0x1   /* cf23en */
+#define XSTORM_CORE_CONN_AG_CTX_CF23EN_SHIFT              5
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED12_MASK           0x1   /* rule0en */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED12_SHIFT          6
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED13_MASK           0x1   /* rule1en */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED13_SHIFT          7
+	u8 flags11;
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED14_MASK           0x1   /* rule2en */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED14_SHIFT          0
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED15_MASK           0x1   /* rule3en */
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED15_SHIFT          1
+#define XSTORM_CORE_CONN_AG_CTX_TX_DEC_RULE_EN_MASK       0x1   /* rule4en */
+#define XSTORM_CORE_CONN_AG_CTX_TX_DEC_RULE_EN_SHIFT      2
+#define XSTORM_CORE_CONN_AG_CTX_RULE5EN_MASK              0x1   /* rule5en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT             3
+#define XSTORM_CORE_CONN_AG_CTX_RULE6EN_MASK              0x1   /* rule6en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT             4
+#define XSTORM_CORE_CONN_AG_CTX_RULE7EN_MASK              0x1   /* rule7en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT             5
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED1_MASK         0x1   /* rule8en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED1_SHIFT        6
+#define XSTORM_CORE_CONN_AG_CTX_RULE9EN_MASK              0x1   /* rule9en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE9EN_SHIFT             7
+	u8 flags12;
+#define XSTORM_CORE_CONN_AG_CTX_RULE10EN_MASK             0x1   /* rule10en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE10EN_SHIFT            0
+#define XSTORM_CORE_CONN_AG_CTX_RULE11EN_MASK             0x1   /* rule11en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE11EN_SHIFT            1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED2_MASK         0x1   /* rule12en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED2_SHIFT        2
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED3_MASK         0x1   /* rule13en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED3_SHIFT        3
+#define XSTORM_CORE_CONN_AG_CTX_RULE14EN_MASK             0x1   /* rule14en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE14EN_SHIFT            4
+#define XSTORM_CORE_CONN_AG_CTX_RULE15EN_MASK             0x1   /* rule15en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE15EN_SHIFT            5
+#define XSTORM_CORE_CONN_AG_CTX_RULE16EN_MASK             0x1   /* rule16en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE16EN_SHIFT            6
+#define XSTORM_CORE_CONN_AG_CTX_RULE17EN_MASK             0x1   /* rule17en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE17EN_SHIFT            7
+	u8 flags13;
+#define XSTORM_CORE_CONN_AG_CTX_RULE18EN_MASK             0x1   /* rule18en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE18EN_SHIFT            0
+#define XSTORM_CORE_CONN_AG_CTX_RULE19EN_MASK             0x1   /* rule19en */
+#define XSTORM_CORE_CONN_AG_CTX_RULE19EN_SHIFT            1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED4_MASK         0x1   /* rule20en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED4_SHIFT        2
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED5_MASK         0x1   /* rule21en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED5_SHIFT        3
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED6_MASK         0x1   /* rule22en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED6_SHIFT        4
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED7_MASK         0x1   /* rule23en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED7_SHIFT        5
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED8_MASK         0x1   /* rule24en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED8_SHIFT        6
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED9_MASK         0x1   /* rule25en */
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED9_SHIFT        7
+	u8 flags14;
+#define XSTORM_CORE_CONN_AG_CTX_BIT16_MASK                0x1   /* bit16 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT16_SHIFT               0
+#define XSTORM_CORE_CONN_AG_CTX_BIT17_MASK                0x1   /* bit17 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT17_SHIFT               1
+#define XSTORM_CORE_CONN_AG_CTX_BIT18_MASK                0x1   /* bit18 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT18_SHIFT               2
+#define XSTORM_CORE_CONN_AG_CTX_BIT19_MASK                0x1   /* bit19 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT19_SHIFT               3
+#define XSTORM_CORE_CONN_AG_CTX_BIT20_MASK                0x1   /* bit20 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT20_SHIFT               4
+#define XSTORM_CORE_CONN_AG_CTX_BIT21_MASK                0x1   /* bit21 */
+#define XSTORM_CORE_CONN_AG_CTX_BIT21_SHIFT               5
+#define XSTORM_CORE_CONN_AG_CTX_CF23_MASK                 0x3   /* cf23 */
+#define XSTORM_CORE_CONN_AG_CTX_CF23_SHIFT                6
+	u8	byte2 /* byte2 */;
+	__le16	physical_q0 /* physical_q0 */;
+	__le16	consolid_prod /* physical_q1 */;
+	__le16	reserved16 /* physical_q2 */;
+	__le16	tx_bd_cons /* word3 */;
+	__le16	tx_bd_or_spq_prod /* word4 */;
+	__le16	word5 /* word5 */;
+	__le16	conn_dpi /* conn_dpi */;
+	u8	byte3 /* byte3 */;
+	u8	byte4 /* byte4 */;
+	u8	byte5 /* byte5 */;
+	u8	byte6 /* byte6 */;
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le32	reg4 /* reg4 */;
+	__le32	reg5 /* cf_array0 */;
+	__le32	reg6 /* cf_array1 */;
+	__le16	word7 /* word7 */;
+	__le16	word8 /* word8 */;
+	__le16	word9 /* word9 */;
+	__le16	word10 /* word10 */;
+	__le32	reg7 /* reg7 */;
+	__le32	reg8 /* reg8 */;
+	__le32	reg9 /* reg9 */;
+	u8	byte7 /* byte7 */;
+	u8	byte8 /* byte8 */;
+	u8	byte9 /* byte9 */;
+	u8	byte10 /* byte10 */;
+	u8	byte11 /* byte11 */;
+	u8	byte12 /* byte12 */;
+	u8	byte13 /* byte13 */;
+	u8	byte14 /* byte14 */;
+	u8	byte15 /* byte15 */;
+	u8	byte16 /* byte16 */;
+	__le16	word11 /* word11 */;
+	__le32	reg10 /* reg10 */;
+	__le32	reg11 /* reg11 */;
+	__le32	reg12 /* reg12 */;
+	__le32	reg13 /* reg13 */;
+	__le32	reg14 /* reg14 */;
+	__le32	reg15 /* reg15 */;
+	__le32	reg16 /* reg16 */;
+	__le32	reg17 /* reg17 */;
+	__le32	reg18 /* reg18 */;
+	__le32	reg19 /* reg19 */;
+	__le16	word12 /* word12 */;
+	__le16	word13 /* word13 */;
+	__le16	word14 /* word14 */;
+	__le16	word15 /* word15 */;
+};
+
+/* The core storm context for the Mstorm */
+struct mstorm_core_conn_st_ctx {
+	__le32 reserved[24];
+};
+
+/* The core storm context for the Ustorm */
+struct ustorm_core_conn_st_ctx {
+	__le32 reserved[4];
+};
+
+/* core connection context */
+struct core_conn_context {
+	struct ystorm_core_conn_st_ctx	ystorm_st_context;
+	struct regpair			ystorm_st_padding[2] /* padding */;
+	struct pstorm_core_conn_st_ctx	pstorm_st_context;
+	struct regpair			pstorm_st_padding[2];
+	struct xstorm_core_conn_st_ctx	xstorm_st_context;
+	struct xstorm_core_conn_ag_ctx	xstorm_ag_context;
+	struct mstorm_core_conn_st_ctx	mstorm_st_context;
+	struct regpair			mstorm_st_padding[2];
+	struct ustorm_core_conn_st_ctx	ustorm_st_context;
+	struct regpair			ustorm_st_padding[2] /* padding */;
+};
+
+/* Event Ring Next Page Address */
+struct event_ring_next_addr {
+	struct regpair	addr /* Next Page Address */;
+	__le32		reserved[2] /* Reserved */;
+};
+
+union event_ring_element {
+	struct event_ring_entry		entry /* Event Ring Entry */;
+	struct event_ring_next_addr	next_addr;
+};
+
+enum personality_type {
+	PERSONALITY_RESERVED,
+	PERSONALITY_RESERVED2,
+	PERSONALITY_RDMA_AND_ETH /* Roce or Iwarp */,
+	PERSONALITY_RESERVED3,
+	PERSONALITY_ETH /* Ethernet */,
+	PERSONALITY_RESERVED4,
+	MAX_PERSONALITY_TYPE
+};
+
+struct pf_start_tunnel_config {
+	u8	set_vxlan_udp_port_flg;
+	u8	set_geneve_udp_port_flg;
+	u8	tx_enable_vxlan /* If set, enable VXLAN tunnel in TX path. */;
+	u8	tx_enable_l2geneve;
+	u8	tx_enable_ipgeneve;
+	u8	tx_enable_l2gre /* If set, enable l2 GRE tunnel in TX path. */;
+	u8	tx_enable_ipgre /* If set, enable IP GRE tunnel in TX path. */;
+	u8	tunnel_clss_vxlan /* Classification scheme for VXLAN tunnel. */;
+	u8	tunnel_clss_l2geneve;
+	u8	tunnel_clss_ipgeneve;
+	u8	tunnel_clss_l2gre;
+	u8	tunnel_clss_ipgre;
+	__le16	vxlan_udp_port /* VXLAN tunnel UDP destination port. */;
+	__le16	geneve_udp_port /* GENEVE tunnel UDP destination port. */;
+};
+
+/* Ramrod data for PF start ramrod */
+struct pf_start_ramrod_data {
+	struct regpair			event_ring_pbl_addr;
+	struct regpair			consolid_q_pbl_addr;
+	struct pf_start_tunnel_config	tunnel_config;
+	__le16				event_ring_sb_id;
+	u8				base_vf_id;
+	u8				num_vfs;
+	u8				event_ring_num_pages;
+	u8				event_ring_sb_index;
+	u8				path_id;
+	u8				warning_as_error;
+	u8				dont_log_ramrods;
+	u8				personality;
+	__le16				log_type_mask;
+	u8				mf_mode /* Multi function mode */;
+	u8				integ_phase /* Integration phase */;
+	u8				allow_npar_tx_switching;
+	u8				inner_to_outer_pri_map[8];
+	u8				pri_map_valid;
+	u32				outer_tag;
+	u8				reserved0[4];
+};
+
+enum ports_mode {
+	ENGX2_PORTX1 /* 2 engines x 1 port */,
+	ENGX2_PORTX2 /* 2 engines x 2 ports */,
+	ENGX1_PORTX1 /* 1 engine  x 1 port */,
+	ENGX1_PORTX2 /* 1 engine  x 2 ports */,
+	ENGX1_PORTX4 /* 1 engine  x 4 ports */,
+	MAX_PORTS_MODE
+};
+
+/* Ramrod Header of SPQE */
+struct ramrod_header {
+	__le32	cid /* Slowpath Connection CID */;
+	u8	cmd_id /* Ramrod Cmd (Per Protocol Type) */;
+	u8	protocol_id /* Ramrod Protocol ID */;
+	__le16	echo /* Ramrod echo */;
+};
+
+/* Slowpath Element (SPQE) */
+struct slow_path_element {
+	struct ramrod_header	hdr /* Ramrod Header */;
+	struct regpair		data_ptr;
+};
+
+struct tstorm_per_port_stat {
+	struct regpair	trunc_error_discard;
+	struct regpair	mac_error_discard;
+	struct regpair	mftag_filter_discard;
+	struct regpair	eth_mac_filter_discard;
+	struct regpair	ll2_mac_filter_discard;
+	struct regpair	ll2_conn_disabled_discard;
+	struct regpair	iscsi_irregular_pkt;
+	struct regpair	fcoe_irregular_pkt;
+	struct regpair	roce_irregular_pkt;
+	struct regpair	eth_irregular_pkt;
+	struct regpair	toe_irregular_pkt;
+	struct regpair	preroce_irregular_pkt;
+};
+
+struct atten_status_block {
+	__le32	atten_bits;
+	__le32	atten_ack;
+	__le16	reserved0;
+	__le16	sb_index /* status block running index */;
+	__le32	reserved1;
+};
+
+enum block_addr {
+	GRCBASE_GRC		= 0x50000,
+	GRCBASE_MISCS		= 0x9000,
+	GRCBASE_MISC		= 0x8000,
+	GRCBASE_DBU		= 0xa000,
+	GRCBASE_PGLUE_B		= 0x2a8000,
+	GRCBASE_CNIG		= 0x218000,
+	GRCBASE_CPMU		= 0x30000,
+	GRCBASE_NCSI		= 0x40000,
+	GRCBASE_OPTE		= 0x53000,
+	GRCBASE_BMB		= 0x540000,
+	GRCBASE_PCIE		= 0x54000,
+	GRCBASE_MCP		= 0xe00000,
+	GRCBASE_MCP2		= 0x52000,
+	GRCBASE_PSWHST		= 0x2a0000,
+	GRCBASE_PSWHST2		= 0x29e000,
+	GRCBASE_PSWRD		= 0x29c000,
+	GRCBASE_PSWRD2		= 0x29d000,
+	GRCBASE_PSWWR		= 0x29a000,
+	GRCBASE_PSWWR2		= 0x29b000,
+	GRCBASE_PSWRQ		= 0x280000,
+	GRCBASE_PSWRQ2		= 0x240000,
+	GRCBASE_PGLCS		= 0x0,
+	GRCBASE_PTU		= 0x560000,
+	GRCBASE_DMAE		= 0xc000,
+	GRCBASE_TCM		= 0x1180000,
+	GRCBASE_MCM		= 0x1200000,
+	GRCBASE_UCM		= 0x1280000,
+	GRCBASE_XCM		= 0x1000000,
+	GRCBASE_YCM		= 0x1080000,
+	GRCBASE_PCM		= 0x1100000,
+	GRCBASE_QM		= 0x2f0000,
+	GRCBASE_TM		= 0x2c0000,
+	GRCBASE_DORQ		= 0x100000,
+	GRCBASE_BRB		= 0x340000,
+	GRCBASE_SRC		= 0x238000,
+	GRCBASE_PRS		= 0x1f0000,
+	GRCBASE_TSDM		= 0xfb0000,
+	GRCBASE_MSDM		= 0xfc0000,
+	GRCBASE_USDM		= 0xfd0000,
+	GRCBASE_XSDM		= 0xf80000,
+	GRCBASE_YSDM		= 0xf90000,
+	GRCBASE_PSDM		= 0xfa0000,
+	GRCBASE_TSEM		= 0x1700000,
+	GRCBASE_MSEM		= 0x1800000,
+	GRCBASE_USEM		= 0x1900000,
+	GRCBASE_XSEM		= 0x1400000,
+	GRCBASE_YSEM		= 0x1500000,
+	GRCBASE_PSEM		= 0x1600000,
+	GRCBASE_RSS		= 0x238800,
+	GRCBASE_TMLD		= 0x4d0000,
+	GRCBASE_MULD		= 0x4e0000,
+	GRCBASE_YULD		= 0x4c8000,
+	GRCBASE_XYLD		= 0x4c0000,
+	GRCBASE_PRM		= 0x230000,
+	GRCBASE_PBF_PB1		= 0xda0000,
+	GRCBASE_PBF_PB2		= 0xda4000,
+	GRCBASE_RPB		= 0x23c000,
+	GRCBASE_BTB		= 0xdb0000,
+	GRCBASE_PBF		= 0xd80000,
+	GRCBASE_RDIF		= 0x300000,
+	GRCBASE_TDIF		= 0x310000,
+	GRCBASE_CDU		= 0x580000,
+	GRCBASE_CCFC		= 0x2e0000,
+	GRCBASE_TCFC		= 0x2d0000,
+	GRCBASE_IGU		= 0x180000,
+	GRCBASE_CAU		= 0x1c0000,
+	GRCBASE_UMAC		= 0x51000,
+	GRCBASE_XMAC		= 0x210000,
+	GRCBASE_DBG		= 0x10000,
+	GRCBASE_NIG		= 0x500000,
+	GRCBASE_WOL		= 0x600000,
+	GRCBASE_BMBN		= 0x610000,
+	GRCBASE_IPC		= 0x20000,
+	GRCBASE_NWM		= 0x800000,
+	GRCBASE_NWS		= 0x700000,
+	GRCBASE_MS		= 0x6a0000,
+	GRCBASE_PHY_PCIE	= 0x618000,
+	GRCBASE_MISC_AEU	= 0x8000,
+	GRCBASE_BAR0_MAP	= 0x1c00000,
+	MAX_BLOCK_ADDR
+};
+
+enum block_id {
+	BLOCK_GRC,
+	BLOCK_MISCS,
+	BLOCK_MISC,
+	BLOCK_DBU,
+	BLOCK_PGLUE_B,
+	BLOCK_CNIG,
+	BLOCK_CPMU,
+	BLOCK_NCSI,
+	BLOCK_OPTE,
+	BLOCK_BMB,
+	BLOCK_PCIE,
+	BLOCK_MCP,
+	BLOCK_MCP2,
+	BLOCK_PSWHST,
+	BLOCK_PSWHST2,
+	BLOCK_PSWRD,
+	BLOCK_PSWRD2,
+	BLOCK_PSWWR,
+	BLOCK_PSWWR2,
+	BLOCK_PSWRQ,
+	BLOCK_PSWRQ2,
+	BLOCK_PGLCS,
+	BLOCK_PTU,
+	BLOCK_DMAE,
+	BLOCK_TCM,
+	BLOCK_MCM,
+	BLOCK_UCM,
+	BLOCK_XCM,
+	BLOCK_YCM,
+	BLOCK_PCM,
+	BLOCK_QM,
+	BLOCK_TM,
+	BLOCK_DORQ,
+	BLOCK_BRB,
+	BLOCK_SRC,
+	BLOCK_PRS,
+	BLOCK_TSDM,
+	BLOCK_MSDM,
+	BLOCK_USDM,
+	BLOCK_XSDM,
+	BLOCK_YSDM,
+	BLOCK_PSDM,
+	BLOCK_TSEM,
+	BLOCK_MSEM,
+	BLOCK_USEM,
+	BLOCK_XSEM,
+	BLOCK_YSEM,
+	BLOCK_PSEM,
+	BLOCK_RSS,
+	BLOCK_TMLD,
+	BLOCK_MULD,
+	BLOCK_YULD,
+	BLOCK_XYLD,
+	BLOCK_PRM,
+	BLOCK_PBF_PB1,
+	BLOCK_PBF_PB2,
+	BLOCK_RPB,
+	BLOCK_BTB,
+	BLOCK_PBF,
+	BLOCK_RDIF,
+	BLOCK_TDIF,
+	BLOCK_CDU,
+	BLOCK_CCFC,
+	BLOCK_TCFC,
+	BLOCK_IGU,
+	BLOCK_CAU,
+	BLOCK_UMAC,
+	BLOCK_XMAC,
+	BLOCK_DBG,
+	BLOCK_NIG,
+	BLOCK_WOL,
+	BLOCK_BMBN,
+	BLOCK_IPC,
+	BLOCK_NWM,
+	BLOCK_NWS,
+	BLOCK_MS,
+	BLOCK_PHY_PCIE,
+	BLOCK_MISC_AEU,
+	BLOCK_BAR0_MAP,
+	MAX_BLOCK_ID
+};
+
+enum command_type_bit {
+	IGU_COMMAND_TYPE_NOP	= 0,
+	IGU_COMMAND_TYPE_SET	= 1,
+	MAX_COMMAND_TYPE_BIT
+};
+
+struct dmae_cmd {
+	__le32 opcode;
+#define DMAE_CMD_SRC_MASK              0x1
+#define DMAE_CMD_SRC_SHIFT             0
+#define DMAE_CMD_DST_MASK              0x3
+#define DMAE_CMD_DST_SHIFT             1
+#define DMAE_CMD_C_DST_MASK            0x1
+#define DMAE_CMD_C_DST_SHIFT           3
+#define DMAE_CMD_CRC_RESET_MASK        0x1
+#define DMAE_CMD_CRC_RESET_SHIFT       4
+#define DMAE_CMD_SRC_ADDR_RESET_MASK   0x1
+#define DMAE_CMD_SRC_ADDR_RESET_SHIFT  5
+#define DMAE_CMD_DST_ADDR_RESET_MASK   0x1
+#define DMAE_CMD_DST_ADDR_RESET_SHIFT  6
+#define DMAE_CMD_COMP_FUNC_MASK        0x1
+#define DMAE_CMD_COMP_FUNC_SHIFT       7
+#define DMAE_CMD_COMP_WORD_EN_MASK     0x1
+#define DMAE_CMD_COMP_WORD_EN_SHIFT    8
+#define DMAE_CMD_COMP_CRC_EN_MASK      0x1
+#define DMAE_CMD_COMP_CRC_EN_SHIFT     9
+#define DMAE_CMD_COMP_CRC_OFFSET_MASK  0x7
+#define DMAE_CMD_COMP_CRC_OFFSET_SHIFT 10
+#define DMAE_CMD_RESERVED1_MASK        0x1
+#define DMAE_CMD_RESERVED1_SHIFT       13
+#define DMAE_CMD_ENDIANITY_MODE_MASK   0x3
+#define DMAE_CMD_ENDIANITY_MODE_SHIFT  14
+#define DMAE_CMD_ERR_HANDLING_MASK     0x3
+#define DMAE_CMD_ERR_HANDLING_SHIFT    16
+#define DMAE_CMD_PORT_ID_MASK          0x3
+#define DMAE_CMD_PORT_ID_SHIFT         18
+#define DMAE_CMD_SRC_PF_ID_MASK        0xF
+#define DMAE_CMD_SRC_PF_ID_SHIFT       20
+#define DMAE_CMD_DST_PF_ID_MASK        0xF
+#define DMAE_CMD_DST_PF_ID_SHIFT       24
+#define DMAE_CMD_SRC_VF_ID_VALID_MASK  0x1
+#define DMAE_CMD_SRC_VF_ID_VALID_SHIFT 28
+#define DMAE_CMD_DST_VF_ID_VALID_MASK  0x1
+#define DMAE_CMD_DST_VF_ID_VALID_SHIFT 29
+#define DMAE_CMD_RESERVED2_MASK        0x3
+#define DMAE_CMD_RESERVED2_SHIFT       30
+	__le32	src_addr_lo;
+	__le32	src_addr_hi;
+	__le32	dst_addr_lo;
+	__le32	dst_addr_hi;
+	__le16	length /* Length in DW */;
+	__le16	opcode_b;
+#define DMAE_CMD_SRC_VF_ID_MASK        0xFF     /* Source VF id */
+#define DMAE_CMD_SRC_VF_ID_SHIFT       0
+#define DMAE_CMD_DST_VF_ID_MASK        0xFF     /* Destination VF id */
+#define DMAE_CMD_DST_VF_ID_SHIFT       8
+	__le32	comp_addr_lo /* PCIe completion address low or grc address */;
+	__le32	comp_addr_hi;
+	__le32	comp_val /* Value to write to copmletion address */;
+	__le32	crc32 /* crc16 result */;
+	__le32	crc_32_c /* crc32_c result */;
+	__le16	crc16 /* crc16 result */;
+	__le16	crc16_c /* crc16_c result */;
+	__le16	crc10 /* crc_t10 result */;
+	__le16	reserved;
+	__le16	xsum16 /* checksum16 result  */;
+	__le16	xsum8 /* checksum8 result  */;
+};
+
+struct igu_cleanup {
+	__le32 sb_id_and_flags;
+#define IGU_CLEANUP_RESERVED0_MASK     0x7FFFFFF
+#define IGU_CLEANUP_RESERVED0_SHIFT    0
+#define IGU_CLEANUP_CLEANUP_SET_MASK   0x1 /* cleanup clear - 0, set - 1 */
+#define IGU_CLEANUP_CLEANUP_SET_SHIFT  27
+#define IGU_CLEANUP_CLEANUP_TYPE_MASK  0x7
+#define IGU_CLEANUP_CLEANUP_TYPE_SHIFT 28
+#define IGU_CLEANUP_COMMAND_TYPE_MASK  0x1
+#define IGU_CLEANUP_COMMAND_TYPE_SHIFT 31
+	__le32 reserved1;
+};
+
+union igu_command {
+	struct igu_prod_cons_update	prod_cons_update;
+	struct igu_cleanup		cleanup;
+};
+
+struct igu_command_reg_ctrl {
+	__le16	opaque_fid;
+	__le16	igu_command_reg_ctrl_fields;
+#define IGU_COMMAND_REG_CTRL_PXP_BAR_ADDR_MASK  0xFFF
+#define IGU_COMMAND_REG_CTRL_PXP_BAR_ADDR_SHIFT 0
+#define IGU_COMMAND_REG_CTRL_RESERVED_MASK      0x7
+#define IGU_COMMAND_REG_CTRL_RESERVED_SHIFT     12
+#define IGU_COMMAND_REG_CTRL_COMMAND_TYPE_MASK  0x1
+#define IGU_COMMAND_REG_CTRL_COMMAND_TYPE_SHIFT 15
+};
+
+struct igu_mapping_line {
+	__le32 igu_mapping_line_fields;
+#define IGU_MAPPING_LINE_VALID_MASK            0x1
+#define IGU_MAPPING_LINE_VALID_SHIFT           0
+#define IGU_MAPPING_LINE_VECTOR_NUMBER_MASK    0xFF
+#define IGU_MAPPING_LINE_VECTOR_NUMBER_SHIFT   1
+#define IGU_MAPPING_LINE_FUNCTION_NUMBER_MASK  0xFF
+#define IGU_MAPPING_LINE_FUNCTION_NUMBER_SHIFT 9
+#define IGU_MAPPING_LINE_PF_VALID_MASK         0x1      /* PF-1, VF-0 */
+#define IGU_MAPPING_LINE_PF_VALID_SHIFT        17
+#define IGU_MAPPING_LINE_IPS_GROUP_MASK        0x3F
+#define IGU_MAPPING_LINE_IPS_GROUP_SHIFT       18
+#define IGU_MAPPING_LINE_RESERVED_MASK         0xFF
+#define IGU_MAPPING_LINE_RESERVED_SHIFT        24
+};
+
+struct igu_msix_vector {
+	struct regpair	address;
+	__le32		data;
+	__le32		msix_vector_fields;
+#define IGU_MSIX_VECTOR_MASK_BIT_MASK      0x1
+#define IGU_MSIX_VECTOR_MASK_BIT_SHIFT     0
+#define IGU_MSIX_VECTOR_RESERVED0_MASK     0x7FFF
+#define IGU_MSIX_VECTOR_RESERVED0_SHIFT    1
+#define IGU_MSIX_VECTOR_STEERING_TAG_MASK  0xFF
+#define IGU_MSIX_VECTOR_STEERING_TAG_SHIFT 16
+#define IGU_MSIX_VECTOR_RESERVED1_MASK     0xFF
+#define IGU_MSIX_VECTOR_RESERVED1_SHIFT    24
+};
+
+enum init_modes {
+	MODE_BB_A0,
+	MODE_RESERVED,
+	MODE_RESERVED2,
+	MODE_ASIC,
+	MODE_RESERVED3,
+	MODE_RESERVED4,
+	MODE_RESERVED5,
+	MODE_SF,
+	MODE_MF_SD,
+	MODE_MF_SI,
+	MODE_PORTS_PER_ENG_1,
+	MODE_PORTS_PER_ENG_2,
+	MODE_PORTS_PER_ENG_4,
+	MODE_40G,
+	MODE_100G,
+	MODE_EAGLE_ENG1_WORKAROUND,
+	MAX_INIT_MODES
+};
+
+enum init_phases {
+	PHASE_ENGINE,
+	PHASE_PORT,
+	PHASE_PF,
+	PHASE_RESERVED,
+	PHASE_QM_PF,
+	MAX_INIT_PHASES
+};
+
+struct mstorm_core_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define MSTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
+#define MSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
+#define MSTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
+#define MSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
+#define MSTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* cf0 */
+#define MSTORM_CORE_CONN_AG_CTX_CF0_SHIFT     2
+#define MSTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* cf1 */
+#define MSTORM_CORE_CONN_AG_CTX_CF1_SHIFT     4
+#define MSTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* cf2 */
+#define MSTORM_CORE_CONN_AG_CTX_CF2_SHIFT     6
+	u8 flags1;
+#define MSTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
+#define MSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   0
+#define MSTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
+#define MSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   1
+#define MSTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
+#define MSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   2
+#define MSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
+#define MSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 3
+#define MSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
+#define MSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 4
+#define MSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
+#define MSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 5
+#define MSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
+#define MSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 6
+#define MSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
+#define MSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 7
+	__le16	word0 /* word0 */;
+	__le16	word1 /* word1 */;
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+};
+
+/* per encapsulation type enabling flags */
+struct prs_reg_encapsulation_type_en {
+	u8 flags;
+#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GRE_ENABLE_MASK     0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GRE_ENABLE_SHIFT    0
+#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GRE_ENABLE_MASK      0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GRE_ENABLE_SHIFT     1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_VXLAN_ENABLE_MASK            0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_VXLAN_ENABLE_SHIFT           2
+#define PRS_REG_ENCAPSULATION_TYPE_EN_T_TAG_ENABLE_MASK            0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_T_TAG_ENABLE_SHIFT           3
+#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GENEVE_ENABLE_MASK  0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GENEVE_ENABLE_SHIFT 4
+#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GENEVE_ENABLE_MASK   0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GENEVE_ENABLE_SHIFT  5
+#define PRS_REG_ENCAPSULATION_TYPE_EN_RESERVED_MASK                0x3
+#define PRS_REG_ENCAPSULATION_TYPE_EN_RESERVED_SHIFT               6
+};
+
+enum pxp_tph_st_hint {
+	TPH_ST_HINT_BIDIR /* Read/Write access by Host and Device */,
+	TPH_ST_HINT_REQUESTER /* Read/Write access by Device */,
+	TPH_ST_HINT_TARGET,
+	TPH_ST_HINT_TARGET_PRIO,
+	MAX_PXP_TPH_ST_HINT
+};
+
+/* QM hardware structure of enable bypass credit mask */
+struct qm_rf_bypass_mask {
+	u8 flags;
+#define QM_RF_BYPASS_MASK_LINEVOQ_MASK    0x1
+#define QM_RF_BYPASS_MASK_LINEVOQ_SHIFT   0
+#define QM_RF_BYPASS_MASK_RESERVED0_MASK  0x1
+#define QM_RF_BYPASS_MASK_RESERVED0_SHIFT 1
+#define QM_RF_BYPASS_MASK_PFWFQ_MASK      0x1
+#define QM_RF_BYPASS_MASK_PFWFQ_SHIFT     2
+#define QM_RF_BYPASS_MASK_VPWFQ_MASK      0x1
+#define QM_RF_BYPASS_MASK_VPWFQ_SHIFT     3
+#define QM_RF_BYPASS_MASK_PFRL_MASK       0x1
+#define QM_RF_BYPASS_MASK_PFRL_SHIFT      4
+#define QM_RF_BYPASS_MASK_VPQCNRL_MASK    0x1
+#define QM_RF_BYPASS_MASK_VPQCNRL_SHIFT   5
+#define QM_RF_BYPASS_MASK_FWPAUSE_MASK    0x1
+#define QM_RF_BYPASS_MASK_FWPAUSE_SHIFT   6
+#define QM_RF_BYPASS_MASK_RESERVED1_MASK  0x1
+#define QM_RF_BYPASS_MASK_RESERVED1_SHIFT 7
+};
+
+/* QM hardware structure of opportunistic credit mask */
+struct qm_rf_opportunistic_mask {
+	__le16 flags;
+#define QM_RF_OPPORTUNISTIC_MASK_LINEVOQ_MASK     0x1
+#define QM_RF_OPPORTUNISTIC_MASK_LINEVOQ_SHIFT    0
+#define QM_RF_OPPORTUNISTIC_MASK_BYTEVOQ_MASK     0x1
+#define QM_RF_OPPORTUNISTIC_MASK_BYTEVOQ_SHIFT    1
+#define QM_RF_OPPORTUNISTIC_MASK_PFWFQ_MASK       0x1
+#define QM_RF_OPPORTUNISTIC_MASK_PFWFQ_SHIFT      2
+#define QM_RF_OPPORTUNISTIC_MASK_VPWFQ_MASK       0x1
+#define QM_RF_OPPORTUNISTIC_MASK_VPWFQ_SHIFT      3
+#define QM_RF_OPPORTUNISTIC_MASK_PFRL_MASK        0x1
+#define QM_RF_OPPORTUNISTIC_MASK_PFRL_SHIFT       4
+#define QM_RF_OPPORTUNISTIC_MASK_VPQCNRL_MASK     0x1
+#define QM_RF_OPPORTUNISTIC_MASK_VPQCNRL_SHIFT    5
+#define QM_RF_OPPORTUNISTIC_MASK_FWPAUSE_MASK     0x1
+#define QM_RF_OPPORTUNISTIC_MASK_FWPAUSE_SHIFT    6
+#define QM_RF_OPPORTUNISTIC_MASK_RESERVED0_MASK   0x1
+#define QM_RF_OPPORTUNISTIC_MASK_RESERVED0_SHIFT  7
+#define QM_RF_OPPORTUNISTIC_MASK_QUEUEEMPTY_MASK  0x1
+#define QM_RF_OPPORTUNISTIC_MASK_QUEUEEMPTY_SHIFT 8
+#define QM_RF_OPPORTUNISTIC_MASK_RESERVED1_MASK   0x7F
+#define QM_RF_OPPORTUNISTIC_MASK_RESERVED1_SHIFT  9
+};
+
+/* QM hardware structure of QM map memory */
+struct qm_rf_pq_map {
+	u32 reg;
+#define QM_RF_PQ_MAP_PQ_VALID_MASK          0x1         /* PQ active */
+#define QM_RF_PQ_MAP_PQ_VALID_SHIFT         0
+#define QM_RF_PQ_MAP_RL_ID_MASK             0xFF        /* RL ID */
+#define QM_RF_PQ_MAP_RL_ID_SHIFT            1
+#define QM_RF_PQ_MAP_VP_PQ_ID_MASK          0x1FF
+#define QM_RF_PQ_MAP_VP_PQ_ID_SHIFT         9
+#define QM_RF_PQ_MAP_VOQ_MASK               0x1F        /* VOQ */
+#define QM_RF_PQ_MAP_VOQ_SHIFT              18
+#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_MASK  0x3         /* WRR weight */
+#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_SHIFT 23
+#define QM_RF_PQ_MAP_RL_VALID_MASK          0x1         /* RL active */
+#define QM_RF_PQ_MAP_RL_VALID_SHIFT         25
+#define QM_RF_PQ_MAP_RESERVED_MASK          0x3F
+#define QM_RF_PQ_MAP_RESERVED_SHIFT         26
+};
+
+/* SDM operation gen command (generate aggregative interrupt) */
+struct sdm_op_gen {
+	__le32 command;
+#define SDM_OP_GEN_COMP_PARAM_MASK  0xFFFF      /* completion parameters 0-15 */
+#define SDM_OP_GEN_COMP_PARAM_SHIFT 0
+#define SDM_OP_GEN_COMP_TYPE_MASK   0xF         /* completion type 16-19 */
+#define SDM_OP_GEN_COMP_TYPE_SHIFT  16
+#define SDM_OP_GEN_RESERVED_MASK    0xFFF       /* reserved 20-31 */
+#define SDM_OP_GEN_RESERVED_SHIFT   20
+};
+
+struct tstorm_core_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define TSTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
+#define TSTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
+#define TSTORM_CORE_CONN_AG_CTX_BIT2_MASK     0x1       /* bit2 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT2_SHIFT    2
+#define TSTORM_CORE_CONN_AG_CTX_BIT3_MASK     0x1       /* bit3 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT3_SHIFT    3
+#define TSTORM_CORE_CONN_AG_CTX_BIT4_MASK     0x1       /* bit4 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT4_SHIFT    4
+#define TSTORM_CORE_CONN_AG_CTX_BIT5_MASK     0x1       /* bit5 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT5_SHIFT    5
+#define TSTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* timer0cf */
+#define TSTORM_CORE_CONN_AG_CTX_CF0_SHIFT     6
+	u8 flags1;
+#define TSTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* timer1cf */
+#define TSTORM_CORE_CONN_AG_CTX_CF1_SHIFT     0
+#define TSTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* timer2cf */
+#define TSTORM_CORE_CONN_AG_CTX_CF2_SHIFT     2
+#define TSTORM_CORE_CONN_AG_CTX_CF3_MASK      0x3       /* timer_stop_all */
+#define TSTORM_CORE_CONN_AG_CTX_CF3_SHIFT     4
+#define TSTORM_CORE_CONN_AG_CTX_CF4_MASK      0x3       /* cf4 */
+#define TSTORM_CORE_CONN_AG_CTX_CF4_SHIFT     6
+	u8 flags2;
+#define TSTORM_CORE_CONN_AG_CTX_CF5_MASK      0x3       /* cf5 */
+#define TSTORM_CORE_CONN_AG_CTX_CF5_SHIFT     0
+#define TSTORM_CORE_CONN_AG_CTX_CF6_MASK      0x3       /* cf6 */
+#define TSTORM_CORE_CONN_AG_CTX_CF6_SHIFT     2
+#define TSTORM_CORE_CONN_AG_CTX_CF7_MASK      0x3       /* cf7 */
+#define TSTORM_CORE_CONN_AG_CTX_CF7_SHIFT     4
+#define TSTORM_CORE_CONN_AG_CTX_CF8_MASK      0x3       /* cf8 */
+#define TSTORM_CORE_CONN_AG_CTX_CF8_SHIFT     6
+	u8 flags3;
+#define TSTORM_CORE_CONN_AG_CTX_CF9_MASK      0x3       /* cf9 */
+#define TSTORM_CORE_CONN_AG_CTX_CF9_SHIFT     0
+#define TSTORM_CORE_CONN_AG_CTX_CF10_MASK     0x3       /* cf10 */
+#define TSTORM_CORE_CONN_AG_CTX_CF10_SHIFT    2
+#define TSTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
+#define TSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   4
+#define TSTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
+#define TSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   5
+#define TSTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
+#define TSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   6
+#define TSTORM_CORE_CONN_AG_CTX_CF3EN_MASK    0x1       /* cf3en */
+#define TSTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT   7
+	u8 flags4;
+#define TSTORM_CORE_CONN_AG_CTX_CF4EN_MASK    0x1       /* cf4en */
+#define TSTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT   0
+#define TSTORM_CORE_CONN_AG_CTX_CF5EN_MASK    0x1       /* cf5en */
+#define TSTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT   1
+#define TSTORM_CORE_CONN_AG_CTX_CF6EN_MASK    0x1       /* cf6en */
+#define TSTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT   2
+#define TSTORM_CORE_CONN_AG_CTX_CF7EN_MASK    0x1       /* cf7en */
+#define TSTORM_CORE_CONN_AG_CTX_CF7EN_SHIFT   3
+#define TSTORM_CORE_CONN_AG_CTX_CF8EN_MASK    0x1       /* cf8en */
+#define TSTORM_CORE_CONN_AG_CTX_CF8EN_SHIFT   4
+#define TSTORM_CORE_CONN_AG_CTX_CF9EN_MASK    0x1       /* cf9en */
+#define TSTORM_CORE_CONN_AG_CTX_CF9EN_SHIFT   5
+#define TSTORM_CORE_CONN_AG_CTX_CF10EN_MASK   0x1       /* cf10en */
+#define TSTORM_CORE_CONN_AG_CTX_CF10EN_SHIFT  6
+#define TSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 7
+	u8 flags5;
+#define TSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 0
+#define TSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 1
+#define TSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 2
+#define TSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 3
+#define TSTORM_CORE_CONN_AG_CTX_RULE5EN_MASK  0x1       /* rule5en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT 4
+#define TSTORM_CORE_CONN_AG_CTX_RULE6EN_MASK  0x1       /* rule6en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT 5
+#define TSTORM_CORE_CONN_AG_CTX_RULE7EN_MASK  0x1       /* rule7en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT 6
+#define TSTORM_CORE_CONN_AG_CTX_RULE8EN_MASK  0x1       /* rule8en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE8EN_SHIFT 7
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le32	reg4 /* reg4 */;
+	__le32	reg5 /* reg5 */;
+	__le32	reg6 /* reg6 */;
+	__le32	reg7 /* reg7 */;
+	__le32	reg8 /* reg8 */;
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	word0 /* word0 */;
+	u8	byte4 /* byte4 */;
+	u8	byte5 /* byte5 */;
+	__le16	word1 /* word1 */;
+	__le16	word2 /* conn_dpi */;
+	__le16	word3 /* word3 */;
+	__le32	reg9 /* reg9 */;
+	__le32	reg10 /* reg10 */;
+};
+
+struct ustorm_core_conn_ag_ctx {
+	u8	reserved /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define USTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
+#define USTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
+#define USTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
+#define USTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
+#define USTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* timer0cf */
+#define USTORM_CORE_CONN_AG_CTX_CF0_SHIFT     2
+#define USTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* timer1cf */
+#define USTORM_CORE_CONN_AG_CTX_CF1_SHIFT     4
+#define USTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* timer2cf */
+#define USTORM_CORE_CONN_AG_CTX_CF2_SHIFT     6
+	u8 flags1;
+#define USTORM_CORE_CONN_AG_CTX_CF3_MASK      0x3       /* timer_stop_all */
+#define USTORM_CORE_CONN_AG_CTX_CF3_SHIFT     0
+#define USTORM_CORE_CONN_AG_CTX_CF4_MASK      0x3       /* cf4 */
+#define USTORM_CORE_CONN_AG_CTX_CF4_SHIFT     2
+#define USTORM_CORE_CONN_AG_CTX_CF5_MASK      0x3       /* cf5 */
+#define USTORM_CORE_CONN_AG_CTX_CF5_SHIFT     4
+#define USTORM_CORE_CONN_AG_CTX_CF6_MASK      0x3       /* cf6 */
+#define USTORM_CORE_CONN_AG_CTX_CF6_SHIFT     6
+	u8 flags2;
+#define USTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
+#define USTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   0
+#define USTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
+#define USTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   1
+#define USTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
+#define USTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   2
+#define USTORM_CORE_CONN_AG_CTX_CF3EN_MASK    0x1       /* cf3en */
+#define USTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT   3
+#define USTORM_CORE_CONN_AG_CTX_CF4EN_MASK    0x1       /* cf4en */
+#define USTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT   4
+#define USTORM_CORE_CONN_AG_CTX_CF5EN_MASK    0x1       /* cf5en */
+#define USTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT   5
+#define USTORM_CORE_CONN_AG_CTX_CF6EN_MASK    0x1       /* cf6en */
+#define USTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT   6
+#define USTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
+#define USTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 7
+	u8 flags3;
+#define USTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
+#define USTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 0
+#define USTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
+#define USTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 1
+#define USTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
+#define USTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 2
+#define USTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
+#define USTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 3
+#define USTORM_CORE_CONN_AG_CTX_RULE5EN_MASK  0x1       /* rule5en */
+#define USTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT 4
+#define USTORM_CORE_CONN_AG_CTX_RULE6EN_MASK  0x1       /* rule6en */
+#define USTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT 5
+#define USTORM_CORE_CONN_AG_CTX_RULE7EN_MASK  0x1       /* rule7en */
+#define USTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT 6
+#define USTORM_CORE_CONN_AG_CTX_RULE8EN_MASK  0x1       /* rule8en */
+#define USTORM_CORE_CONN_AG_CTX_RULE8EN_SHIFT 7
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	word0 /* conn_dpi */;
+	__le16	word1 /* word1 */;
+	__le32	rx_producers /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le16	word2 /* word2 */;
+	__le16	word3 /* word3 */;
+};
+
+struct ystorm_core_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define YSTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
+#define YSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
+#define YSTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
+#define YSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
+#define YSTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* cf0 */
+#define YSTORM_CORE_CONN_AG_CTX_CF0_SHIFT     2
+#define YSTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* cf1 */
+#define YSTORM_CORE_CONN_AG_CTX_CF1_SHIFT     4
+#define YSTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* cf2 */
+#define YSTORM_CORE_CONN_AG_CTX_CF2_SHIFT     6
+	u8 flags1;
+#define YSTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
+#define YSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   0
+#define YSTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
+#define YSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   1
+#define YSTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
+#define YSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   2
+#define YSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
+#define YSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 3
+#define YSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
+#define YSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 4
+#define YSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
+#define YSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 5
+#define YSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
+#define YSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 6
+#define YSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
+#define YSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 7
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	word0 /* word0 */;
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le16	word1 /* word1 */;
+	__le16	word2 /* word2 */;
+	__le16	word3 /* word3 */;
+	__le16	word4 /* word4 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+};
+
+/*********************************** Init ************************************/
+
+/* Width of GRC address in bits (addresses are specified in dwords) */
+#define GRC_ADDR_BITS                   23
+#define MAX_GRC_ADDR                    ((1 << GRC_ADDR_BITS) - 1)
+
+/* indicates an init that should be applied to any phase ID */
+#define ANY_PHASE_ID                    0xffff
+
+/* init pattern size in bytes */
+#define INIT_PATTERN_SIZE_BITS  4
+#define MAX_INIT_PATTERN_SIZE	BIT(INIT_PATTERN_SIZE_BITS)
+
+/* Max size in dwords of a zipped array */
+#define MAX_ZIPPED_SIZE                 8192
+
+/* Global PXP window */
+#define NUM_OF_PXP_WIN                  19
+#define PXP_WIN_DWORD_SIZE_BITS 10
+#define PXP_WIN_DWORD_SIZE		BIT(PXP_WIN_DWORD_SIZE_BITS)
+#define PXP_WIN_BYTE_SIZE_BITS  (PXP_WIN_DWORD_SIZE_BITS + 2)
+#define PXP_WIN_BYTE_SIZE               (PXP_WIN_DWORD_SIZE * 4)
+
+/********************************* GRC Dump **********************************/
+
+/* width of GRC dump register sequence length in bits */
+#define DUMP_SEQ_LEN_BITS                       8
+#define DUMP_SEQ_LEN_MAX_VAL            ((1 << DUMP_SEQ_LEN_BITS) - 1)
+
+/* width of GRC dump memory length in bits */
+#define DUMP_MEM_LEN_BITS                       18
+#define DUMP_MEM_LEN_MAX_VAL            ((1 << DUMP_MEM_LEN_BITS) - 1)
+
+/* width of register type ID in bits */
+#define REG_TYPE_ID_BITS                        6
+#define REG_TYPE_ID_MAX_VAL                     ((1 << REG_TYPE_ID_BITS) - 1)
+
+/* width of block ID in bits */
+#define BLOCK_ID_BITS                           8
+#define BLOCK_ID_MAX_VAL                        ((1 << BLOCK_ID_BITS) - 1)
+
+/******************************** Idle Check *********************************/
+
+/* max number of idle check predicate immediates */
+#define MAX_IDLE_CHK_PRED_IMM           3
+
+/* max number of idle check argument registers */
+#define MAX_IDLE_CHK_READ_REGS          3
+
+/* max number of idle check loops */
+#define MAX_IDLE_CHK_LOOPS                      0x10000
+
+/* max idle check address increment */
+#define MAX_IDLE_CHK_INCREMENT          0x10000
+
+/* inicates an undefined idle check line index */
+#define IDLE_CHK_UNDEFINED_LINE_IDX     0xffffff
+
+/* max number of register values following the idle check header */
+#define IDLE_CHK_MAX_DUMP_REGS          2
+
+/* arguments for IDLE_CHK_MACRO_TYPE_QM_RD_WR */
+#define IDLE_CHK_QM_RD_WR_PTR           0
+#define IDLE_CHK_QM_RD_WR_BANK          1
+
+/**************************************/
+/* HSI Functions constants and macros */
+/**************************************/
+
+/* Number of VLAN priorities */
+#define NUM_OF_VLAN_PRIORITIES                  8
+
+/* the MCP Trace meta data signautre is duplicated in the perl script that
+ * generats the NVRAM images.
+ */
+#define MCP_TRACE_META_IMAGE_SIGNATURE  0x669955aa
+
+/* Binary buffer header */
+struct bin_buffer_hdr {
+	u32	offset;
+	u32	length /* buffer length in bytes */;
+};
+
+/* binary buffer types */
+enum bin_buffer_type {
+	BIN_BUF_FW_VER_INFO /* fw_ver_info struct */,
+	BIN_BUF_INIT_CMD /* init commands */,
+	BIN_BUF_INIT_VAL /* init data */,
+	BIN_BUF_INIT_MODE_TREE /* init modes tree */,
+	BIN_BUF_IRO /* internal RAM offsets array */,
+	MAX_BIN_BUFFER_TYPE
+};
+
+/* Chip IDs */
+enum chip_ids {
+	CHIP_BB_A0 /* BB A0 chip ID */,
+	CHIP_BB_B0 /* BB B0 chip ID */,
+	CHIP_K2 /* AH chip ID */,
+	MAX_CHIP_IDS
+};
+
+enum idle_chk_severity_types {
+	IDLE_CHK_SEVERITY_ERROR /* idle check failure should cause an error */,
+	IDLE_CHK_SEVERITY_ERROR_NO_TRAFFIC,
+	IDLE_CHK_SEVERITY_WARNING,
+	MAX_IDLE_CHK_SEVERITY_TYPES
+};
+
+struct init_array_raw_hdr {
+	__le32 data;
+#define INIT_ARRAY_RAW_HDR_TYPE_MASK    0xF
+#define INIT_ARRAY_RAW_HDR_TYPE_SHIFT   0
+#define INIT_ARRAY_RAW_HDR_PARAMS_MASK  0xFFFFFFF       /* init array params */
+#define INIT_ARRAY_RAW_HDR_PARAMS_SHIFT 4
+};
+
+struct init_array_standard_hdr {
+	__le32 data;
+#define INIT_ARRAY_STANDARD_HDR_TYPE_MASK  0xF
+#define INIT_ARRAY_STANDARD_HDR_TYPE_SHIFT 0
+#define INIT_ARRAY_STANDARD_HDR_SIZE_MASK  0xFFFFFFF
+#define INIT_ARRAY_STANDARD_HDR_SIZE_SHIFT 4
+};
+
+struct init_array_zipped_hdr {
+	__le32 data;
+#define INIT_ARRAY_ZIPPED_HDR_TYPE_MASK         0xF
+#define INIT_ARRAY_ZIPPED_HDR_TYPE_SHIFT        0
+#define INIT_ARRAY_ZIPPED_HDR_ZIPPED_SIZE_MASK  0xFFFFFFF
+#define INIT_ARRAY_ZIPPED_HDR_ZIPPED_SIZE_SHIFT 4
+};
+
+struct init_array_pattern_hdr {
+	__le32 data;
+#define INIT_ARRAY_PATTERN_HDR_TYPE_MASK          0xF
+#define INIT_ARRAY_PATTERN_HDR_TYPE_SHIFT         0
+#define INIT_ARRAY_PATTERN_HDR_PATTERN_SIZE_MASK  0xF
+#define INIT_ARRAY_PATTERN_HDR_PATTERN_SIZE_SHIFT 4
+#define INIT_ARRAY_PATTERN_HDR_REPETITIONS_MASK   0xFFFFFF
+#define INIT_ARRAY_PATTERN_HDR_REPETITIONS_SHIFT  8
+};
+
+union init_array_hdr {
+	struct init_array_raw_hdr	raw /* raw init array header */;
+	struct init_array_standard_hdr	standard;
+	struct init_array_zipped_hdr	zipped /* zipped init array header */;
+	struct init_array_pattern_hdr	pattern /* pattern init array header */;
+};
+
+enum init_array_types {
+	INIT_ARR_STANDARD /* standard init array */,
+	INIT_ARR_ZIPPED /* zipped init array */,
+	INIT_ARR_PATTERN /* a repeated pattern */,
+	MAX_INIT_ARRAY_TYPES
+};
+
+/* init operation: callback */
+struct init_callback_op {
+	__le32	op_data;
+#define INIT_CALLBACK_OP_OP_MASK        0xF
+#define INIT_CALLBACK_OP_OP_SHIFT       0
+#define INIT_CALLBACK_OP_RESERVED_MASK  0xFFFFFFF
+#define INIT_CALLBACK_OP_RESERVED_SHIFT 4
+	__le16	callback_id /* Callback ID */;
+	__le16	block_id /* Blocks ID */;
+};
+
+/* init comparison types */
+enum init_comparison_types {
+	INIT_COMPARISON_EQ /* init value is included in the init command */,
+	INIT_COMPARISON_OR /* init value is all zeros */,
+	INIT_COMPARISON_AND /* init value is an array of values */,
+	MAX_INIT_COMPARISON_TYPES
+};
+
+/* init operation: delay */
+struct init_delay_op {
+	__le32	op_data;
+#define INIT_DELAY_OP_OP_MASK        0xF
+#define INIT_DELAY_OP_OP_SHIFT       0
+#define INIT_DELAY_OP_RESERVED_MASK  0xFFFFFFF
+#define INIT_DELAY_OP_RESERVED_SHIFT 4
+	__le32	delay /* delay in us */;
+};
+
+/* init operation: if_mode */
+struct init_if_mode_op {
+	__le32 op_data;
+#define INIT_IF_MODE_OP_OP_MASK          0xF
+#define INIT_IF_MODE_OP_OP_SHIFT         0
+#define INIT_IF_MODE_OP_RESERVED1_MASK   0xFFF
+#define INIT_IF_MODE_OP_RESERVED1_SHIFT  4
+#define INIT_IF_MODE_OP_CMD_OFFSET_MASK  0xFFFF
+#define INIT_IF_MODE_OP_CMD_OFFSET_SHIFT 16
+	__le16	reserved2;
+	__le16	modes_buf_offset;
+};
+
+/*  init operation: if_phase */
+struct init_if_phase_op {
+	__le32 op_data;
+#define INIT_IF_PHASE_OP_OP_MASK           0xF
+#define INIT_IF_PHASE_OP_OP_SHIFT          0
+#define INIT_IF_PHASE_OP_DMAE_ENABLE_MASK  0x1
+#define INIT_IF_PHASE_OP_DMAE_ENABLE_SHIFT 4
+#define INIT_IF_PHASE_OP_RESERVED1_MASK    0x7FF
+#define INIT_IF_PHASE_OP_RESERVED1_SHIFT   5
+#define INIT_IF_PHASE_OP_CMD_OFFSET_MASK   0xFFFF
+#define INIT_IF_PHASE_OP_CMD_OFFSET_SHIFT  16
+	__le32 phase_data;
+#define INIT_IF_PHASE_OP_PHASE_MASK        0xFF /* Init phase */
+#define INIT_IF_PHASE_OP_PHASE_SHIFT       0
+#define INIT_IF_PHASE_OP_RESERVED2_MASK    0xFF
+#define INIT_IF_PHASE_OP_RESERVED2_SHIFT   8
+#define INIT_IF_PHASE_OP_PHASE_ID_MASK     0xFFFF /* Init phase ID */
+#define INIT_IF_PHASE_OP_PHASE_ID_SHIFT    16
+};
+
+/* init mode operators */
+enum init_mode_ops {
+	INIT_MODE_OP_NOT /* init mode not operator */,
+	INIT_MODE_OP_OR /* init mode or operator */,
+	INIT_MODE_OP_AND /* init mode and operator */,
+	MAX_INIT_MODE_OPS
+};
+
+/* init operation: raw */
+struct init_raw_op {
+	__le32	op_data;
+#define INIT_RAW_OP_OP_MASK      0xF
+#define INIT_RAW_OP_OP_SHIFT     0
+#define INIT_RAW_OP_PARAM1_MASK  0xFFFFFFF      /* init param 1 */
+#define INIT_RAW_OP_PARAM1_SHIFT 4
+	__le32	param2 /* Init param 2 */;
+};
+
+/* init array params */
+struct init_op_array_params {
+	__le16	size /* array size in dwords */;
+	__le16	offset /* array start offset in dwords */;
+};
+
+/* Write init operation arguments */
+union init_write_args {
+	__le32				inline_val;
+	__le32				zeros_count;
+	__le32				array_offset;
+	struct init_op_array_params	runtime;
+};
+
+/* init operation: write */
+struct init_write_op {
+	__le32 data;
+#define INIT_WRITE_OP_OP_MASK        0xF
+#define INIT_WRITE_OP_OP_SHIFT       0
+#define INIT_WRITE_OP_SOURCE_MASK    0x7
+#define INIT_WRITE_OP_SOURCE_SHIFT   4
+#define INIT_WRITE_OP_RESERVED_MASK  0x1
+#define INIT_WRITE_OP_RESERVED_SHIFT 7
+#define INIT_WRITE_OP_WIDE_BUS_MASK  0x1
+#define INIT_WRITE_OP_WIDE_BUS_SHIFT 8
+#define INIT_WRITE_OP_ADDRESS_MASK   0x7FFFFF
+#define INIT_WRITE_OP_ADDRESS_SHIFT  9
+	union init_write_args args /* Write init operation arguments */;
+};
+
+/* init operation: read */
+struct init_read_op {
+	__le32 op_data;
+#define INIT_READ_OP_OP_MASK         0xF
+#define INIT_READ_OP_OP_SHIFT        0
+#define INIT_READ_OP_POLL_COMP_MASK  0x7
+#define INIT_READ_OP_POLL_COMP_SHIFT 4
+#define INIT_READ_OP_RESERVED_MASK   0x1
+#define INIT_READ_OP_RESERVED_SHIFT  7
+#define INIT_READ_OP_POLL_MASK       0x1
+#define INIT_READ_OP_POLL_SHIFT      8
+#define INIT_READ_OP_ADDRESS_MASK    0x7FFFFF
+#define INIT_READ_OP_ADDRESS_SHIFT   9
+	__le32 expected_val;
+};
+
+/* Init operations union */
+union init_op {
+	struct init_raw_op	raw /* raw init operation */;
+	struct init_write_op	write /* write init operation */;
+	struct init_read_op	read /* read init operation */;
+	struct init_if_mode_op	if_mode /* if_mode init operation */;
+	struct init_if_phase_op if_phase /* if_phase init operation */;
+	struct init_callback_op callback /* callback init operation */;
+	struct init_delay_op	delay /* delay init operation */;
+};
+
+/* Init command operation types */
+enum init_op_types {
+	INIT_OP_READ /* GRC read init command */,
+	INIT_OP_WRITE /* GRC write init command */,
+	INIT_OP_IF_MODE,
+	INIT_OP_IF_PHASE,
+	INIT_OP_DELAY /* delay init command */,
+	INIT_OP_CALLBACK /* callback init command */,
+	MAX_INIT_OP_TYPES
+};
+
+/* init source types */
+enum init_source_types {
+	INIT_SRC_INLINE /* init value is included in the init command */,
+	INIT_SRC_ZEROS /* init value is all zeros */,
+	INIT_SRC_ARRAY /* init value is an array of values */,
+	INIT_SRC_RUNTIME /* init value is provided during runtime */,
+	MAX_INIT_SOURCE_TYPES
+};
+
+/* Internal RAM Offsets macro data */
+struct iro {
+	u32	base /* RAM field offset */;
+	u16	m1 /* multiplier 1 */;
+	u16	m2 /* multiplier 2 */;
+	u16	m3 /* multiplier 3 */;
+	u16	size /* RAM field size */;
+};
+
+/* QM per-port init parameters */
+struct init_qm_port_params {
+	u8	active /* Indicates if this port is active */;
+	u8	num_active_phys_tcs;
+	u16	num_pbf_cmd_lines;
+	u16	num_btb_blocks;
+	__le16	reserved;
+};
+
+/* QM per-PQ init parameters */
+struct init_qm_pq_params {
+	u8	vport_id /* VPORT ID */;
+	u8	tc_id /* TC ID */;
+	u8	wrr_group /* WRR group */;
+	u8	reserved;
+};
+
+/* QM per-vport init parameters */
+struct init_qm_vport_params {
+	u32	vport_rl;
+	u16	vport_wfq;
+	u16	first_tx_pq_id[NUM_OF_TCS];
+};
+
+/* Win 2 */
+#define GTT_BAR0_MAP_REG_IGU_CMD \
+	0x00f000UL
+/* Win 3 */
+#define GTT_BAR0_MAP_REG_TSDM_RAM \
+	0x010000UL
+/* Win 4 */
+#define GTT_BAR0_MAP_REG_MSDM_RAM \
+	0x011000UL
+/* Win 5 */
+#define GTT_BAR0_MAP_REG_MSDM_RAM_1024 \
+	0x012000UL
+/* Win 6 */
+#define GTT_BAR0_MAP_REG_USDM_RAM \
+	0x013000UL
+/* Win 7 */
+#define GTT_BAR0_MAP_REG_USDM_RAM_1024 \
+	0x014000UL
+/* Win 8 */
+#define GTT_BAR0_MAP_REG_USDM_RAM_2048 \
+	0x015000UL
+/* Win 9 */
+#define GTT_BAR0_MAP_REG_XSDM_RAM \
+	0x016000UL
+/* Win 10 */
+#define GTT_BAR0_MAP_REG_YSDM_RAM \
+	0x017000UL
+/* Win 11 */
+#define GTT_BAR0_MAP_REG_PSDM_RAM \
+	0x018000UL
+/* forward declarations */
+struct init_qm_pq_params;
+/**
+ * @brief qed_qm_pf_mem_size - prepare QM ILT sizes
+ *
+ * Returns the required host memory size in 4KB units.
+ * Must be called before all QM init HSI functions.
+ *
+ * @param pf_id			- physical function ID
+ * @param num_pf_cids	- number of connections used by this PF
+ * @param num_vf_cids	- number of connections used by VFs of this PF
+ * @param num_tids		- number of tasks used by this PF
+ * @param num_pf_pqs	- number of PQs used by this PF
+ * @param num_vf_pqs	- number of PQs used by VFs of this PF
+ *
+ * @return The required host memory size in 4KB units.
+ */
+u32 qed_qm_pf_mem_size(u8	pf_id,
+		       u32	num_pf_cids,
+		       u32	num_vf_cids,
+		       u32	num_tids,
+		       u16	num_pf_pqs,
+		       u16	num_vf_pqs);
+/**
+ * @brief qed_qm_common_rt_init - Prepare QM runtime init values for the
+ * engine phase.
+ *
+ * @param p_hwfn
+ * @param max_ports_per_engine	- max number of ports per engine in HW
+ * @param max_phys_tcs_per_port	- max number of physical TCs per port in HW
+ * @param pf_rl_en				- enable per-PF rate limiters
+ * @param pf_wfq_en				- enable per-PF WFQ
+ * @param vport_rl_en			- enable per-VPORT rate limiters
+ * @param vport_wfq_en			- enable per-VPORT WFQ
+ * @param port_params			- array of size MAX_NUM_PORTS with
+ *						arameters for each port
+ *
+ * @return 0 on success, -1 on error.
+ */
+int qed_qm_common_rt_init(
+	struct qed_hwfn			*p_hwfn,
+	u8				max_ports_per_engine,
+	u8				max_phys_tcs_per_port,
+	bool				pf_rl_en,
+	bool				pf_wfq_en,
+	bool				vport_rl_en,
+	bool				vport_wfq_en,
+	struct init_qm_port_params	port_params[
+		MAX_NUM_PORTS]);
+int qed_qm_pf_rt_init(struct qed_hwfn			*p_hwfn,
+		      struct qed_ptt			*p_ptt,
+		      u8				port_id,
+		      u8				pf_id,
+		      u8				max_phys_tcs_per_port,
+		      bool				is_first_pf,
+		      u32				num_pf_cids,
+		      u32				num_vf_cids,
+		      u32				num_tids,
+		      u16				start_pq,
+		      u16				num_pf_pqs,
+		      u16				num_vf_pqs,
+		      u8				start_vport,
+		      u8				num_vports,
+		      u8				pf_wfq,
+		      u32				pf_rl,
+		      struct init_qm_pq_params		*pq_params,
+		      struct init_qm_vport_params	*vport_params);
+/**
+ * @brief qed_init_pf_rl  Initializes the rate limit of the specified PF
+ *
+ * @param p_hwfn
+ * @param p_ptt	- ptt window used for writing the registers
+ * @param pf_id	- PF ID
+ * @param pf_rl	- rate limit in Mb/sec units
+ *
+ * @return 0 on success, -1 on error.
+ */
+int qed_init_pf_rl(struct qed_hwfn	*p_hwfn,
+		   struct qed_ptt	*p_ptt,
+		   u8			pf_id,
+		   u32			pf_rl);
+/**
+ * @brief qed_init_vport_rl  Initializes the rate limit of the specified VPORT
+ *
+ * @param p_hwfn
+ * @param p_ptt		- ptt window used for writing the registers
+ * @param vport_id	- VPORT ID
+ * @param vport_rl	- rate limit in Mb/sec units
+ *
+ * @return 0 on success, -1 on error.
+ */
+int qed_init_vport_rl(struct qed_hwfn	*p_hwfn,
+		      struct qed_ptt	*p_ptt,
+		      u8		vport_id,
+		      u32		vport_rl);
+/**
+ * @brief qed_send_qm_stop_cmd  Sends a stop command to the QM
+ *
+ * @param p_hwfn
+ * @param p_ptt	         - ptt window used for writing the registers
+ * @param is_release_cmd - true for release, false for stop.
+ * @param is_tx_pq       - true for Tx PQs, false for Other PQs.
+ * @param start_pq       - first PQ ID to stop
+ * @param num_pqs        - Number of PQs to stop, starting from start_pq.
+ *
+ * @return bool, true if successful, false if timeout occurred while waiting
+ *					for QM command done.
+ */
+bool qed_send_qm_stop_cmd(struct qed_hwfn	*p_hwfn,
+			  struct qed_ptt	*p_ptt,
+			  bool			is_release_cmd,
+			  bool			is_tx_pq,
+			  u16			start_pq,
+			  u16			num_pqs);
+
+#ifndef __IRO_H__
+#define __IRO_H__
+
+/* Ystorm flow control mode. Use enum fw_flow_ctrl_mode */
+#define YSTORM_FLOW_CONTROL_MODE_OFFSET			(IRO[0].base)
+#define YSTORM_FLOW_CONTROL_MODE_SIZE			(IRO[0].size)
+/* Tstorm port statistics */
+#define TSTORM_PORT_STAT_OFFSET(port_id)		(IRO[1].base + \
+							 ((port_id) * \
+							  IRO[1].m1))
+#define TSTORM_PORT_STAT_SIZE				(IRO[1].size)
+/* Ustorm VF-PF Channel ready flag */
+#define USTORM_VF_PF_CHANNEL_READY_OFFSET(vf_id)	(IRO[2].base +	\
+							 ((vf_id) *	\
+							  IRO[2].m1))
+#define USTORM_VF_PF_CHANNEL_READY_SIZE			(IRO[2].size)
+/* Ustorm Final flr cleanup ack */
+#define USTORM_FLR_FINAL_ACK_OFFSET			(IRO[3].base)
+#define USTORM_FLR_FINAL_ACK_SIZE			(IRO[3].size)
+/* Ustorm Event ring consumer */
+#define USTORM_EQE_CONS_OFFSET(pf_id)			(IRO[4].base +	\
+							 ((pf_id) *	\
+							  IRO[4].m1))
+#define USTORM_EQE_CONS_SIZE				(IRO[4].size)
+/* Ustorm Completion ring consumer */
+#define USTORM_CQ_CONS_OFFSET(global_queue_id)		(IRO[5].base +	\
+							 ((global_queue_id) * \
+							  IRO[5].m1))
+#define USTORM_CQ_CONS_SIZE				(IRO[5].size)
+/* Xstorm Integration Test Data */
+#define XSTORM_INTEG_TEST_DATA_OFFSET			(IRO[6].base)
+#define XSTORM_INTEG_TEST_DATA_SIZE			(IRO[6].size)
+/* Ystorm Integration Test Data */
+#define YSTORM_INTEG_TEST_DATA_OFFSET			(IRO[7].base)
+#define YSTORM_INTEG_TEST_DATA_SIZE			(IRO[7].size)
+/* Pstorm Integration Test Data */
+#define PSTORM_INTEG_TEST_DATA_OFFSET			(IRO[8].base)
+#define PSTORM_INTEG_TEST_DATA_SIZE			(IRO[8].size)
+/* Tstorm Integration Test Data */
+#define TSTORM_INTEG_TEST_DATA_OFFSET			(IRO[9].base)
+#define TSTORM_INTEG_TEST_DATA_SIZE			(IRO[9].size)
+/* Mstorm Integration Test Data */
+#define MSTORM_INTEG_TEST_DATA_OFFSET			(IRO[10].base)
+#define MSTORM_INTEG_TEST_DATA_SIZE			(IRO[10].size)
+/* Ustorm Integration Test Data */
+#define USTORM_INTEG_TEST_DATA_OFFSET			(IRO[11].base)
+#define USTORM_INTEG_TEST_DATA_SIZE			(IRO[11].size)
+/* Tstorm producers */
+#define TSTORM_LL2_RX_PRODS_OFFSET(core_rx_queue_id)	(IRO[12].base +	\
+							 ((core_rx_queue_id) * \
+							  IRO[12].m1))
+#define TSTORM_LL2_RX_PRODS_SIZE			(IRO[12].size)
+/* Tstorm LiteL2 queue statistics */
+#define CORE_LL2_TSTORM_PER_QUEUE_STAT_OFFSET(core_rx_q_id) (IRO[13].base + \
+							     ((core_rx_q_id) * \
+							      IRO[13].m1))
+#define CORE_LL2_TSTORM_PER_QUEUE_STAT_SIZE		(IRO[13].size)
+/* Ustorm LiteL2 queue statistics */
+#define CORE_LL2_USTORM_PER_QUEUE_STAT_OFFSET(core_rx_q_id) (IRO[14].base + \
+							     ((core_rx_q_id) * \
+							      IRO[14].m1))
+#define CORE_LL2_USTORM_PER_QUEUE_STAT_SIZE		(IRO[14].size)
+/* Pstorm LiteL2 queue statistics */
+#define CORE_LL2_PSTORM_PER_QUEUE_STAT_OFFSET(core_txst_id) (IRO[15].base + \
+							     ((core_txst_id) * \
+							      IRO[15].m1))
+#define CORE_LL2_PSTORM_PER_QUEUE_STAT_SIZE		(IRO[15].size)
+/* Mstorm queue statistics */
+#define MSTORM_QUEUE_STAT_OFFSET(stat_counter_id) (IRO[16].base + \
+						   ((stat_counter_id) *	\
+						    IRO[16].m1))
+#define MSTORM_QUEUE_STAT_SIZE				(IRO[16].size)
+/* Mstorm producers */
+#define MSTORM_PRODS_OFFSET(queue_id)			(IRO[17].base +	\
+							 ((queue_id) *	\
+							  IRO[17].m1))
+#define MSTORM_PRODS_SIZE				(IRO[17].size)
+/* TPA agregation timeout in us resolution (on ASIC) */
+#define MSTORM_TPA_TIMEOUT_US_OFFSET			(IRO[18].base)
+#define MSTORM_TPA_TIMEOUT_US_SIZE			(IRO[18].size)
+/* Ustorm queue statistics */
+#define USTORM_QUEUE_STAT_OFFSET(stat_counter_id)	(IRO[19].base +	\
+							((stat_counter_id) * \
+							 IRO[19].m1))
+#define USTORM_QUEUE_STAT_SIZE				(IRO[19].size)
+/* Ustorm queue zone */
+#define USTORM_ETH_QUEUE_ZONE_OFFSET(queue_id)		(IRO[20].base +	\
+							 ((queue_id) *	\
+							  IRO[20].m1))
+#define USTORM_ETH_QUEUE_ZONE_SIZE			(IRO[20].size)
+/* Pstorm queue statistics */
+#define PSTORM_QUEUE_STAT_OFFSET(stat_counter_id)	(IRO[21].base +	\
+							 ((stat_counter_id) * \
+							  IRO[21].m1))
+#define PSTORM_QUEUE_STAT_SIZE				(IRO[21].size)
+/* Tstorm last parser message */
+#define TSTORM_ETH_PRS_INPUT_OFFSET(pf_id)		(IRO[22].base +	\
+							 ((pf_id) *	\
+							  IRO[22].m1))
+#define TSTORM_ETH_PRS_INPUT_SIZE			(IRO[22].size)
+/* Ystorm queue zone */
+#define YSTORM_ETH_QUEUE_ZONE_OFFSET(queue_id)		(IRO[23].base +	\
+							 ((queue_id) *	\
+							  IRO[23].m1))
+#define YSTORM_ETH_QUEUE_ZONE_SIZE			(IRO[23].size)
+/* Ystorm cqe producer */
+#define YSTORM_TOE_CQ_PROD_OFFSET(rss_id)		(IRO[24].base +	\
+							 ((rss_id) *	\
+							  IRO[24].m1))
+#define YSTORM_TOE_CQ_PROD_SIZE				(IRO[24].size)
+/* Ustorm cqe producer */
+#define USTORM_TOE_CQ_PROD_OFFSET(rss_id)		(IRO[25].base +	\
+							 ((rss_id) *	\
+							  IRO[25].m1))
+#define USTORM_TOE_CQ_PROD_SIZE				(IRO[25].size)
+/* Ustorm grq producer */
+#define USTORM_TOE_GRQ_PROD_OFFSET(pf_id)		(IRO[26].base +	\
+							 ((pf_id) *	\
+							  IRO[26].m1))
+#define USTORM_TOE_GRQ_PROD_SIZE			(IRO[26].size)
+/* Tstorm cmdq-cons of given command queue-id */
+#define TSTORM_SCSI_CMDQ_CONS_OFFSET(cmdq_queue_id)	(IRO[27].base +	\
+							 ((cmdq_queue_id) * \
+							  IRO[27].m1))
+#define TSTORM_SCSI_CMDQ_CONS_SIZE			(IRO[27].size)
+/* Mstorm rq-cons of given queue-id */
+#define MSTORM_SCSI_RQ_CONS_OFFSET(rq_queue_id)		(IRO[28].base +	\
+							 ((rq_queue_id) * \
+							  IRO[28].m1))
+#define MSTORM_SCSI_RQ_CONS_SIZE			(IRO[28].size)
+/* Pstorm RoCE statistics */
+#define PSTORM_ROCE_STAT_OFFSET(stat_counter_id)	(IRO[29].base +	\
+							 ((stat_counter_id) * \
+							  IRO[29].m1))
+#define PSTORM_ROCE_STAT_SIZE				(IRO[29].size)
+/* Tstorm RoCE statistics */
+#define TSTORM_ROCE_STAT_OFFSET(stat_counter_id)	(IRO[30].base +	\
+							 ((stat_counter_id) * \
+							  IRO[30].m1))
+#define TSTORM_ROCE_STAT_SIZE				(IRO[30].size)
+
+#endif /* __IRO_H__ */
+
+#ifndef __IRO_VALUES_H__
+#define __IRO_VALUES_H__
+
+static const struct iro iro_arr[31] = {
+	{ 0x10,	  0x0,	 0x0,	0x0,   0x8     },
+	{ 0x4448, 0x60,	 0x0,	0x0,   0x60    },
+	{ 0x498,  0x8,	 0x0,	0x0,   0x4     },
+	{ 0x494,  0x0,	 0x0,	0x0,   0x4     },
+	{ 0x10,	  0x8,	 0x0,	0x0,   0x2     },
+	{ 0x90,	  0x8,	 0x0,	0x0,   0x2     },
+	{ 0x4540, 0x0,	 0x0,	0x0,   0xf8    },
+	{ 0x39e0, 0x0,	 0x0,	0x0,   0xf8    },
+	{ 0x2598, 0x0,	 0x0,	0x0,   0xf8    },
+	{ 0x4350, 0x0,	 0x0,	0x0,   0xf8    },
+	{ 0x52d0, 0x0,	 0x0,	0x0,   0xf8    },
+	{ 0x7a48, 0x0,	 0x0,	0x0,   0xf8    },
+	{ 0x100,  0x8,	 0x0,	0x0,   0x8     },
+	{ 0x5808, 0x10,	 0x0,	0x0,   0x10    },
+	{ 0xb100, 0x30,	 0x0,	0x0,   0x30    },
+	{ 0x95c0, 0x30,	 0x0,	0x0,   0x30    },
+	{ 0x54f8, 0x40,	 0x0,	0x0,   0x40    },
+	{ 0x200,  0x10,	 0x0,	0x0,   0x8     },
+	{ 0x9e70, 0x0,	 0x0,	0x0,   0x4     },
+	{ 0x7ca0, 0x40,	 0x0,	0x0,   0x30    },
+	{ 0xd00,  0x8,	 0x0,	0x0,   0x8     },
+	{ 0x2790, 0x80,	 0x0,	0x0,   0x38    },
+	{ 0xa520, 0xf0,	 0x0,	0x0,   0xf0    },
+	{ 0x80,	  0x8,	 0x0,	0x0,   0x8     },
+	{ 0xac0,  0x8,	 0x0,	0x0,   0x8     },
+	{ 0x2580, 0x8,	 0x0,	0x0,   0x8     },
+	{ 0x2500, 0x8,	 0x0,	0x0,   0x8     },
+	{ 0x440,  0x8,	 0x0,	0x0,   0x2     },
+	{ 0x1800, 0x8,	 0x0,	0x0,   0x2     },
+	{ 0x27c8, 0x80,	 0x0,	0x0,   0x10    },
+	{ 0x4710, 0x10,	 0x0,	0x0,   0x10    },
+};
+
+#endif /* __IRO_VALUES_H__ */
+
+#ifndef __RT_DEFS_H__
+#define __RT_DEFS_H__
+
+/* Runtime array offsets */
+#define DORQ_REG_PF_MAX_ICID_0_RT_OFFSET                                0
+#define DORQ_REG_PF_MAX_ICID_1_RT_OFFSET                                1
+#define DORQ_REG_PF_MAX_ICID_2_RT_OFFSET                                2
+#define DORQ_REG_PF_MAX_ICID_3_RT_OFFSET                                3
+#define DORQ_REG_PF_MAX_ICID_4_RT_OFFSET                                4
+#define DORQ_REG_PF_MAX_ICID_5_RT_OFFSET                                5
+#define DORQ_REG_PF_MAX_ICID_6_RT_OFFSET                                6
+#define DORQ_REG_PF_MAX_ICID_7_RT_OFFSET                                7
+#define DORQ_REG_VF_MAX_ICID_0_RT_OFFSET                                8
+#define DORQ_REG_VF_MAX_ICID_1_RT_OFFSET                                9
+#define DORQ_REG_VF_MAX_ICID_2_RT_OFFSET                                10
+#define DORQ_REG_VF_MAX_ICID_3_RT_OFFSET                                11
+#define DORQ_REG_VF_MAX_ICID_4_RT_OFFSET                                12
+#define DORQ_REG_VF_MAX_ICID_5_RT_OFFSET                                13
+#define DORQ_REG_VF_MAX_ICID_6_RT_OFFSET                                14
+#define DORQ_REG_VF_MAX_ICID_7_RT_OFFSET                                15
+#define DORQ_REG_PF_WAKE_ALL_RT_OFFSET                                  16
+#define IGU_REG_PF_CONFIGURATION_RT_OFFSET                              17
+#define IGU_REG_VF_CONFIGURATION_RT_OFFSET                              18
+#define IGU_REG_ATTN_MSG_ADDR_L_RT_OFFSET                               19
+#define IGU_REG_ATTN_MSG_ADDR_H_RT_OFFSET                               20
+#define IGU_REG_LEADING_EDGE_LATCH_RT_OFFSET                            21
+#define IGU_REG_TRAILING_EDGE_LATCH_RT_OFFSET                           22
+#define CAU_REG_CQE_AGG_UNIT_SIZE_RT_OFFSET                             23
+#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET                                 760
+#define CAU_REG_SB_VAR_MEMORY_RT_SIZE                                   736
+#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET                                 760
+#define CAU_REG_SB_VAR_MEMORY_RT_SIZE                                   736
+#define CAU_REG_SB_ADDR_MEMORY_RT_OFFSET                                1496
+#define CAU_REG_SB_ADDR_MEMORY_RT_SIZE                                  736
+#define CAU_REG_PI_MEMORY_RT_OFFSET                                     2232
+#define CAU_REG_PI_MEMORY_RT_SIZE                                       4416
+#define PRS_REG_SEARCH_RESP_INITIATOR_TYPE_RT_OFFSET                    6648
+#define PRS_REG_TASK_ID_MAX_INITIATOR_PF_RT_OFFSET                      6649
+#define PRS_REG_TASK_ID_MAX_INITIATOR_VF_RT_OFFSET                      6650
+#define PRS_REG_TASK_ID_MAX_TARGET_PF_RT_OFFSET                         6651
+#define PRS_REG_TASK_ID_MAX_TARGET_VF_RT_OFFSET                         6652
+#define PRS_REG_SEARCH_TCP_RT_OFFSET                                    6653
+#define PRS_REG_SEARCH_FCOE_RT_OFFSET                                   6654
+#define PRS_REG_SEARCH_ROCE_RT_OFFSET                                   6655
+#define PRS_REG_ROCE_DEST_QP_MAX_VF_RT_OFFSET                           6656
+#define PRS_REG_ROCE_DEST_QP_MAX_PF_RT_OFFSET                           6657
+#define PRS_REG_SEARCH_OPENFLOW_RT_OFFSET                               6658
+#define PRS_REG_SEARCH_NON_IP_AS_OPENFLOW_RT_OFFSET                     6659
+#define PRS_REG_OPENFLOW_SUPPORT_ONLY_KNOWN_OVER_IP_RT_OFFSET           6660
+#define PRS_REG_OPENFLOW_SEARCH_KEY_MASK_RT_OFFSET                      6661
+#define PRS_REG_LIGHT_L2_ETHERTYPE_EN_RT_OFFSET                         6662
+#define SRC_REG_FIRSTFREE_RT_OFFSET                                     6663
+#define SRC_REG_FIRSTFREE_RT_SIZE                                       2
+#define SRC_REG_LASTFREE_RT_OFFSET                                      6665
+#define SRC_REG_LASTFREE_RT_SIZE                                        2
+#define SRC_REG_COUNTFREE_RT_OFFSET                                     6667
+#define SRC_REG_NUMBER_HASH_BITS_RT_OFFSET                              6668
+#define PSWRQ2_REG_CDUT_P_SIZE_RT_OFFSET                                6669
+#define PSWRQ2_REG_CDUC_P_SIZE_RT_OFFSET                                6670
+#define PSWRQ2_REG_TM_P_SIZE_RT_OFFSET                                  6671
+#define PSWRQ2_REG_QM_P_SIZE_RT_OFFSET                                  6672
+#define PSWRQ2_REG_SRC_P_SIZE_RT_OFFSET                                 6673
+#define PSWRQ2_REG_TM_FIRST_ILT_RT_OFFSET                               6674
+#define PSWRQ2_REG_TM_LAST_ILT_RT_OFFSET                                6675
+#define PSWRQ2_REG_QM_FIRST_ILT_RT_OFFSET                               6676
+#define PSWRQ2_REG_QM_LAST_ILT_RT_OFFSET                                6677
+#define PSWRQ2_REG_SRC_FIRST_ILT_RT_OFFSET                              6678
+#define PSWRQ2_REG_SRC_LAST_ILT_RT_OFFSET                               6679
+#define PSWRQ2_REG_CDUC_FIRST_ILT_RT_OFFSET                             6680
+#define PSWRQ2_REG_CDUC_LAST_ILT_RT_OFFSET                              6681
+#define PSWRQ2_REG_CDUT_FIRST_ILT_RT_OFFSET                             6682
+#define PSWRQ2_REG_CDUT_LAST_ILT_RT_OFFSET                              6683
+#define PSWRQ2_REG_TSDM_FIRST_ILT_RT_OFFSET                             6684
+#define PSWRQ2_REG_TSDM_LAST_ILT_RT_OFFSET                              6685
+#define PSWRQ2_REG_TM_NUMBER_OF_PF_BLOCKS_RT_OFFSET                     6686
+#define PSWRQ2_REG_CDUT_NUMBER_OF_PF_BLOCKS_RT_OFFSET                   6687
+#define PSWRQ2_REG_CDUC_NUMBER_OF_PF_BLOCKS_RT_OFFSET                   6688
+#define PSWRQ2_REG_TM_VF_BLOCKS_RT_OFFSET                               6689
+#define PSWRQ2_REG_CDUT_VF_BLOCKS_RT_OFFSET                             6690
+#define PSWRQ2_REG_CDUC_VF_BLOCKS_RT_OFFSET                             6691
+#define PSWRQ2_REG_TM_BLOCKS_FACTOR_RT_OFFSET                           6692
+#define PSWRQ2_REG_CDUT_BLOCKS_FACTOR_RT_OFFSET                         6693
+#define PSWRQ2_REG_CDUC_BLOCKS_FACTOR_RT_OFFSET                         6694
+#define PSWRQ2_REG_VF_BASE_RT_OFFSET                                    6695
+#define PSWRQ2_REG_VF_LAST_ILT_RT_OFFSET                                6696
+#define PSWRQ2_REG_WR_MBS0_RT_OFFSET                                    6697
+#define PSWRQ2_REG_RD_MBS0_RT_OFFSET                                    6698
+#define PSWRQ2_REG_DRAM_ALIGN_WR_RT_OFFSET                              6699
+#define PSWRQ2_REG_DRAM_ALIGN_RD_RT_OFFSET                              6700
+#define PSWRQ2_REG_ILT_MEMORY_RT_OFFSET                                 6701
+#define PSWRQ2_REG_ILT_MEMORY_RT_SIZE                                   22000
+#define PGLUE_REG_B_VF_BASE_RT_OFFSET                                   28701
+#define PGLUE_REG_B_CACHE_LINE_SIZE_RT_OFFSET                           28702
+#define PGLUE_REG_B_PF_BAR0_SIZE_RT_OFFSET                              28703
+#define PGLUE_REG_B_PF_BAR1_SIZE_RT_OFFSET                              28704
+#define PGLUE_REG_B_VF_BAR1_SIZE_RT_OFFSET                              28705
+#define TM_REG_VF_ENABLE_CONN_RT_OFFSET                                 28706
+#define TM_REG_PF_ENABLE_CONN_RT_OFFSET                                 28707
+#define TM_REG_PF_ENABLE_TASK_RT_OFFSET                                 28708
+#define TM_REG_GROUP_SIZE_RESOLUTION_CONN_RT_OFFSET                     28709
+#define TM_REG_GROUP_SIZE_RESOLUTION_TASK_RT_OFFSET                     28710
+#define TM_REG_CONFIG_CONN_MEM_RT_OFFSET                                28711
+#define TM_REG_CONFIG_CONN_MEM_RT_SIZE                                  416
+#define TM_REG_CONFIG_TASK_MEM_RT_OFFSET                                29127
+#define TM_REG_CONFIG_TASK_MEM_RT_SIZE                                  512
+#define QM_REG_MAXPQSIZE_0_RT_OFFSET                                    29639
+#define QM_REG_MAXPQSIZE_1_RT_OFFSET                                    29640
+#define QM_REG_MAXPQSIZE_2_RT_OFFSET                                    29641
+#define QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET                               29642
+#define QM_REG_MAXPQSIZETXSEL_1_RT_OFFSET                               29643
+#define QM_REG_MAXPQSIZETXSEL_2_RT_OFFSET                               29644
+#define QM_REG_MAXPQSIZETXSEL_3_RT_OFFSET                               29645
+#define QM_REG_MAXPQSIZETXSEL_4_RT_OFFSET                               29646
+#define QM_REG_MAXPQSIZETXSEL_5_RT_OFFSET                               29647
+#define QM_REG_MAXPQSIZETXSEL_6_RT_OFFSET                               29648
+#define QM_REG_MAXPQSIZETXSEL_7_RT_OFFSET                               29649
+#define QM_REG_MAXPQSIZETXSEL_8_RT_OFFSET                               29650
+#define QM_REG_MAXPQSIZETXSEL_9_RT_OFFSET                               29651
+#define QM_REG_MAXPQSIZETXSEL_10_RT_OFFSET                              29652
+#define QM_REG_MAXPQSIZETXSEL_11_RT_OFFSET                              29653
+#define QM_REG_MAXPQSIZETXSEL_12_RT_OFFSET                              29654
+#define QM_REG_MAXPQSIZETXSEL_13_RT_OFFSET                              29655
+#define QM_REG_MAXPQSIZETXSEL_14_RT_OFFSET                              29656
+#define QM_REG_MAXPQSIZETXSEL_15_RT_OFFSET                              29657
+#define QM_REG_MAXPQSIZETXSEL_16_RT_OFFSET                              29658
+#define QM_REG_MAXPQSIZETXSEL_17_RT_OFFSET                              29659
+#define QM_REG_MAXPQSIZETXSEL_18_RT_OFFSET                              29660
+#define QM_REG_MAXPQSIZETXSEL_19_RT_OFFSET                              29661
+#define QM_REG_MAXPQSIZETXSEL_20_RT_OFFSET                              29662
+#define QM_REG_MAXPQSIZETXSEL_21_RT_OFFSET                              29663
+#define QM_REG_MAXPQSIZETXSEL_22_RT_OFFSET                              29664
+#define QM_REG_MAXPQSIZETXSEL_23_RT_OFFSET                              29665
+#define QM_REG_MAXPQSIZETXSEL_24_RT_OFFSET                              29666
+#define QM_REG_MAXPQSIZETXSEL_25_RT_OFFSET                              29667
+#define QM_REG_MAXPQSIZETXSEL_26_RT_OFFSET                              29668
+#define QM_REG_MAXPQSIZETXSEL_27_RT_OFFSET                              29669
+#define QM_REG_MAXPQSIZETXSEL_28_RT_OFFSET                              29670
+#define QM_REG_MAXPQSIZETXSEL_29_RT_OFFSET                              29671
+#define QM_REG_MAXPQSIZETXSEL_30_RT_OFFSET                              29672
+#define QM_REG_MAXPQSIZETXSEL_31_RT_OFFSET                              29673
+#define QM_REG_MAXPQSIZETXSEL_32_RT_OFFSET                              29674
+#define QM_REG_MAXPQSIZETXSEL_33_RT_OFFSET                              29675
+#define QM_REG_MAXPQSIZETXSEL_34_RT_OFFSET                              29676
+#define QM_REG_MAXPQSIZETXSEL_35_RT_OFFSET                              29677
+#define QM_REG_MAXPQSIZETXSEL_36_RT_OFFSET                              29678
+#define QM_REG_MAXPQSIZETXSEL_37_RT_OFFSET                              29679
+#define QM_REG_MAXPQSIZETXSEL_38_RT_OFFSET                              29680
+#define QM_REG_MAXPQSIZETXSEL_39_RT_OFFSET                              29681
+#define QM_REG_MAXPQSIZETXSEL_40_RT_OFFSET                              29682
+#define QM_REG_MAXPQSIZETXSEL_41_RT_OFFSET                              29683
+#define QM_REG_MAXPQSIZETXSEL_42_RT_OFFSET                              29684
+#define QM_REG_MAXPQSIZETXSEL_43_RT_OFFSET                              29685
+#define QM_REG_MAXPQSIZETXSEL_44_RT_OFFSET                              29686
+#define QM_REG_MAXPQSIZETXSEL_45_RT_OFFSET                              29687
+#define QM_REG_MAXPQSIZETXSEL_46_RT_OFFSET                              29688
+#define QM_REG_MAXPQSIZETXSEL_47_RT_OFFSET                              29689
+#define QM_REG_MAXPQSIZETXSEL_48_RT_OFFSET                              29690
+#define QM_REG_MAXPQSIZETXSEL_49_RT_OFFSET                              29691
+#define QM_REG_MAXPQSIZETXSEL_50_RT_OFFSET                              29692
+#define QM_REG_MAXPQSIZETXSEL_51_RT_OFFSET                              29693
+#define QM_REG_MAXPQSIZETXSEL_52_RT_OFFSET                              29694
+#define QM_REG_MAXPQSIZETXSEL_53_RT_OFFSET                              29695
+#define QM_REG_MAXPQSIZETXSEL_54_RT_OFFSET                              29696
+#define QM_REG_MAXPQSIZETXSEL_55_RT_OFFSET                              29697
+#define QM_REG_MAXPQSIZETXSEL_56_RT_OFFSET                              29698
+#define QM_REG_MAXPQSIZETXSEL_57_RT_OFFSET                              29699
+#define QM_REG_MAXPQSIZETXSEL_58_RT_OFFSET                              29700
+#define QM_REG_MAXPQSIZETXSEL_59_RT_OFFSET                              29701
+#define QM_REG_MAXPQSIZETXSEL_60_RT_OFFSET                              29702
+#define QM_REG_MAXPQSIZETXSEL_61_RT_OFFSET                              29703
+#define QM_REG_MAXPQSIZETXSEL_62_RT_OFFSET                              29704
+#define QM_REG_MAXPQSIZETXSEL_63_RT_OFFSET                              29705
+#define QM_REG_BASEADDROTHERPQ_RT_OFFSET                                29706
+#define QM_REG_BASEADDROTHERPQ_RT_SIZE                                  128
+#define QM_REG_VOQCRDLINE_RT_OFFSET                                     29834
+#define QM_REG_VOQCRDLINE_RT_SIZE                                       20
+#define QM_REG_VOQINITCRDLINE_RT_OFFSET                                 29854
+#define QM_REG_VOQINITCRDLINE_RT_SIZE                                   20
+#define QM_REG_AFULLQMBYPTHRPFWFQ_RT_OFFSET                             29874
+#define QM_REG_AFULLQMBYPTHRVPWFQ_RT_OFFSET                             29875
+#define QM_REG_AFULLQMBYPTHRPFRL_RT_OFFSET                              29876
+#define QM_REG_AFULLQMBYPTHRGLBLRL_RT_OFFSET                            29877
+#define QM_REG_AFULLOPRTNSTCCRDMASK_RT_OFFSET                           29878
+#define QM_REG_WRROTHERPQGRP_0_RT_OFFSET                                29879
+#define QM_REG_WRROTHERPQGRP_1_RT_OFFSET                                29880
+#define QM_REG_WRROTHERPQGRP_2_RT_OFFSET                                29881
+#define QM_REG_WRROTHERPQGRP_3_RT_OFFSET                                29882
+#define QM_REG_WRROTHERPQGRP_4_RT_OFFSET                                29883
+#define QM_REG_WRROTHERPQGRP_5_RT_OFFSET                                29884
+#define QM_REG_WRROTHERPQGRP_6_RT_OFFSET                                29885
+#define QM_REG_WRROTHERPQGRP_7_RT_OFFSET                                29886
+#define QM_REG_WRROTHERPQGRP_8_RT_OFFSET                                29887
+#define QM_REG_WRROTHERPQGRP_9_RT_OFFSET                                29888
+#define QM_REG_WRROTHERPQGRP_10_RT_OFFSET                               29889
+#define QM_REG_WRROTHERPQGRP_11_RT_OFFSET                               29890
+#define QM_REG_WRROTHERPQGRP_12_RT_OFFSET                               29891
+#define QM_REG_WRROTHERPQGRP_13_RT_OFFSET                               29892
+#define QM_REG_WRROTHERPQGRP_14_RT_OFFSET                               29893
+#define QM_REG_WRROTHERPQGRP_15_RT_OFFSET                               29894
+#define QM_REG_WRROTHERGRPWEIGHT_0_RT_OFFSET                            29895
+#define QM_REG_WRROTHERGRPWEIGHT_1_RT_OFFSET                            29896
+#define QM_REG_WRROTHERGRPWEIGHT_2_RT_OFFSET                            29897
+#define QM_REG_WRROTHERGRPWEIGHT_3_RT_OFFSET                            29898
+#define QM_REG_WRRTXGRPWEIGHT_0_RT_OFFSET                               29899
+#define QM_REG_WRRTXGRPWEIGHT_1_RT_OFFSET                               29900
+#define QM_REG_PQTX2PF_0_RT_OFFSET                                      29901
+#define QM_REG_PQTX2PF_1_RT_OFFSET                                      29902
+#define QM_REG_PQTX2PF_2_RT_OFFSET                                      29903
+#define QM_REG_PQTX2PF_3_RT_OFFSET                                      29904
+#define QM_REG_PQTX2PF_4_RT_OFFSET                                      29905
+#define QM_REG_PQTX2PF_5_RT_OFFSET                                      29906
+#define QM_REG_PQTX2PF_6_RT_OFFSET                                      29907
+#define QM_REG_PQTX2PF_7_RT_OFFSET                                      29908
+#define QM_REG_PQTX2PF_8_RT_OFFSET                                      29909
+#define QM_REG_PQTX2PF_9_RT_OFFSET                                      29910
+#define QM_REG_PQTX2PF_10_RT_OFFSET                                     29911
+#define QM_REG_PQTX2PF_11_RT_OFFSET                                     29912
+#define QM_REG_PQTX2PF_12_RT_OFFSET                                     29913
+#define QM_REG_PQTX2PF_13_RT_OFFSET                                     29914
+#define QM_REG_PQTX2PF_14_RT_OFFSET                                     29915
+#define QM_REG_PQTX2PF_15_RT_OFFSET                                     29916
+#define QM_REG_PQTX2PF_16_RT_OFFSET                                     29917
+#define QM_REG_PQTX2PF_17_RT_OFFSET                                     29918
+#define QM_REG_PQTX2PF_18_RT_OFFSET                                     29919
+#define QM_REG_PQTX2PF_19_RT_OFFSET                                     29920
+#define QM_REG_PQTX2PF_20_RT_OFFSET                                     29921
+#define QM_REG_PQTX2PF_21_RT_OFFSET                                     29922
+#define QM_REG_PQTX2PF_22_RT_OFFSET                                     29923
+#define QM_REG_PQTX2PF_23_RT_OFFSET                                     29924
+#define QM_REG_PQTX2PF_24_RT_OFFSET                                     29925
+#define QM_REG_PQTX2PF_25_RT_OFFSET                                     29926
+#define QM_REG_PQTX2PF_26_RT_OFFSET                                     29927
+#define QM_REG_PQTX2PF_27_RT_OFFSET                                     29928
+#define QM_REG_PQTX2PF_28_RT_OFFSET                                     29929
+#define QM_REG_PQTX2PF_29_RT_OFFSET                                     29930
+#define QM_REG_PQTX2PF_30_RT_OFFSET                                     29931
+#define QM_REG_PQTX2PF_31_RT_OFFSET                                     29932
+#define QM_REG_PQTX2PF_32_RT_OFFSET                                     29933
+#define QM_REG_PQTX2PF_33_RT_OFFSET                                     29934
+#define QM_REG_PQTX2PF_34_RT_OFFSET                                     29935
+#define QM_REG_PQTX2PF_35_RT_OFFSET                                     29936
+#define QM_REG_PQTX2PF_36_RT_OFFSET                                     29937
+#define QM_REG_PQTX2PF_37_RT_OFFSET                                     29938
+#define QM_REG_PQTX2PF_38_RT_OFFSET                                     29939
+#define QM_REG_PQTX2PF_39_RT_OFFSET                                     29940
+#define QM_REG_PQTX2PF_40_RT_OFFSET                                     29941
+#define QM_REG_PQTX2PF_41_RT_OFFSET                                     29942
+#define QM_REG_PQTX2PF_42_RT_OFFSET                                     29943
+#define QM_REG_PQTX2PF_43_RT_OFFSET                                     29944
+#define QM_REG_PQTX2PF_44_RT_OFFSET                                     29945
+#define QM_REG_PQTX2PF_45_RT_OFFSET                                     29946
+#define QM_REG_PQTX2PF_46_RT_OFFSET                                     29947
+#define QM_REG_PQTX2PF_47_RT_OFFSET                                     29948
+#define QM_REG_PQTX2PF_48_RT_OFFSET                                     29949
+#define QM_REG_PQTX2PF_49_RT_OFFSET                                     29950
+#define QM_REG_PQTX2PF_50_RT_OFFSET                                     29951
+#define QM_REG_PQTX2PF_51_RT_OFFSET                                     29952
+#define QM_REG_PQTX2PF_52_RT_OFFSET                                     29953
+#define QM_REG_PQTX2PF_53_RT_OFFSET                                     29954
+#define QM_REG_PQTX2PF_54_RT_OFFSET                                     29955
+#define QM_REG_PQTX2PF_55_RT_OFFSET                                     29956
+#define QM_REG_PQTX2PF_56_RT_OFFSET                                     29957
+#define QM_REG_PQTX2PF_57_RT_OFFSET                                     29958
+#define QM_REG_PQTX2PF_58_RT_OFFSET                                     29959
+#define QM_REG_PQTX2PF_59_RT_OFFSET                                     29960
+#define QM_REG_PQTX2PF_60_RT_OFFSET                                     29961
+#define QM_REG_PQTX2PF_61_RT_OFFSET                                     29962
+#define QM_REG_PQTX2PF_62_RT_OFFSET                                     29963
+#define QM_REG_PQTX2PF_63_RT_OFFSET                                     29964
+#define QM_REG_PQOTHER2PF_0_RT_OFFSET                                   29965
+#define QM_REG_PQOTHER2PF_1_RT_OFFSET                                   29966
+#define QM_REG_PQOTHER2PF_2_RT_OFFSET                                   29967
+#define QM_REG_PQOTHER2PF_3_RT_OFFSET                                   29968
+#define QM_REG_PQOTHER2PF_4_RT_OFFSET                                   29969
+#define QM_REG_PQOTHER2PF_5_RT_OFFSET                                   29970
+#define QM_REG_PQOTHER2PF_6_RT_OFFSET                                   29971
+#define QM_REG_PQOTHER2PF_7_RT_OFFSET                                   29972
+#define QM_REG_PQOTHER2PF_8_RT_OFFSET                                   29973
+#define QM_REG_PQOTHER2PF_9_RT_OFFSET                                   29974
+#define QM_REG_PQOTHER2PF_10_RT_OFFSET                                  29975
+#define QM_REG_PQOTHER2PF_11_RT_OFFSET                                  29976
+#define QM_REG_PQOTHER2PF_12_RT_OFFSET                                  29977
+#define QM_REG_PQOTHER2PF_13_RT_OFFSET                                  29978
+#define QM_REG_PQOTHER2PF_14_RT_OFFSET                                  29979
+#define QM_REG_PQOTHER2PF_15_RT_OFFSET                                  29980
+#define QM_REG_RLGLBLPERIOD_0_RT_OFFSET                                 29981
+#define QM_REG_RLGLBLPERIOD_1_RT_OFFSET                                 29982
+#define QM_REG_RLGLBLPERIODTIMER_0_RT_OFFSET                            29983
+#define QM_REG_RLGLBLPERIODTIMER_1_RT_OFFSET                            29984
+#define QM_REG_RLGLBLPERIODSEL_0_RT_OFFSET                              29985
+#define QM_REG_RLGLBLPERIODSEL_1_RT_OFFSET                              29986
+#define QM_REG_RLGLBLPERIODSEL_2_RT_OFFSET                              29987
+#define QM_REG_RLGLBLPERIODSEL_3_RT_OFFSET                              29988
+#define QM_REG_RLGLBLPERIODSEL_4_RT_OFFSET                              29989
+#define QM_REG_RLGLBLPERIODSEL_5_RT_OFFSET                              29990
+#define QM_REG_RLGLBLPERIODSEL_6_RT_OFFSET                              29991
+#define QM_REG_RLGLBLPERIODSEL_7_RT_OFFSET                              29992
+#define QM_REG_RLGLBLINCVAL_RT_OFFSET                                   29993
+#define QM_REG_RLGLBLINCVAL_RT_SIZE                                     256
+#define QM_REG_RLGLBLUPPERBOUND_RT_OFFSET                               30249
+#define QM_REG_RLGLBLUPPERBOUND_RT_SIZE                                 256
+#define QM_REG_RLGLBLCRD_RT_OFFSET                                      30505
+#define QM_REG_RLGLBLCRD_RT_SIZE                                        256
+#define QM_REG_RLGLBLENABLE_RT_OFFSET                                   30761
+#define QM_REG_RLPFPERIOD_RT_OFFSET                                     30762
+#define QM_REG_RLPFPERIODTIMER_RT_OFFSET                                30763
+#define QM_REG_RLPFINCVAL_RT_OFFSET                                     30764
+#define QM_REG_RLPFINCVAL_RT_SIZE                                       16
+#define QM_REG_RLPFUPPERBOUND_RT_OFFSET                                 30780
+#define QM_REG_RLPFUPPERBOUND_RT_SIZE                                   16
+#define QM_REG_RLPFCRD_RT_OFFSET                                        30796
+#define QM_REG_RLPFCRD_RT_SIZE                                          16
+#define QM_REG_RLPFENABLE_RT_OFFSET                                     30812
+#define QM_REG_RLPFVOQENABLE_RT_OFFSET                                  30813
+#define QM_REG_WFQPFWEIGHT_RT_OFFSET                                    30814
+#define QM_REG_WFQPFWEIGHT_RT_SIZE                                      16
+#define QM_REG_WFQPFUPPERBOUND_RT_OFFSET                                30830
+#define QM_REG_WFQPFUPPERBOUND_RT_SIZE                                  16
+#define QM_REG_WFQPFCRD_RT_OFFSET                                       30846
+#define QM_REG_WFQPFCRD_RT_SIZE                                         160
+#define QM_REG_WFQPFENABLE_RT_OFFSET                                    31006
+#define QM_REG_WFQVPENABLE_RT_OFFSET                                    31007
+#define QM_REG_BASEADDRTXPQ_RT_OFFSET                                   31008
+#define QM_REG_BASEADDRTXPQ_RT_SIZE                                     512
+#define QM_REG_TXPQMAP_RT_OFFSET                                        31520
+#define QM_REG_TXPQMAP_RT_SIZE                                          512
+#define QM_REG_WFQVPWEIGHT_RT_OFFSET                                    32032
+#define QM_REG_WFQVPWEIGHT_RT_SIZE                                      512
+#define QM_REG_WFQVPUPPERBOUND_RT_OFFSET                                32544
+#define QM_REG_WFQVPUPPERBOUND_RT_SIZE                                  512
+#define QM_REG_WFQVPCRD_RT_OFFSET                                       33056
+#define QM_REG_WFQVPCRD_RT_SIZE                                         512
+#define QM_REG_WFQVPMAP_RT_OFFSET                                       33568
+#define QM_REG_WFQVPMAP_RT_SIZE                                         512
+#define QM_REG_WFQPFCRD_MSB_RT_OFFSET                                   34080
+#define QM_REG_WFQPFCRD_MSB_RT_SIZE                                     160
+#define NIG_REG_LLH_CLS_TYPE_DUALMODE_RT_OFFSET                         34240
+#define NIG_REG_OUTER_TAG_VALUE_LIST0_RT_OFFSET                         34241
+#define NIG_REG_OUTER_TAG_VALUE_LIST1_RT_OFFSET                         34242
+#define NIG_REG_OUTER_TAG_VALUE_LIST2_RT_OFFSET                         34243
+#define NIG_REG_OUTER_TAG_VALUE_LIST3_RT_OFFSET                         34244
+#define NIG_REG_OUTER_TAG_VALUE_MASK_RT_OFFSET                          34245
+#define NIG_REG_LLH_FUNC_TAGMAC_CLS_TYPE_RT_OFFSET                      34246
+#define NIG_REG_LLH_FUNC_TAG_EN_RT_OFFSET                               34247
+#define NIG_REG_LLH_FUNC_TAG_EN_RT_SIZE                                 4
+#define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_OFFSET                          34251
+#define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_SIZE                            4
+#define NIG_REG_LLH_FUNC_TAG_VALUE_RT_OFFSET                            34255
+#define NIG_REG_LLH_FUNC_TAG_VALUE_RT_SIZE                              4
+#define NIG_REG_LLH_FUNC_NO_TAG_RT_OFFSET                               34259
+#define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_OFFSET                         34260
+#define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_SIZE                           32
+#define NIG_REG_LLH_FUNC_FILTER_EN_RT_OFFSET                            34292
+#define NIG_REG_LLH_FUNC_FILTER_EN_RT_SIZE                              16
+#define NIG_REG_LLH_FUNC_FILTER_MODE_RT_OFFSET                          34308
+#define NIG_REG_LLH_FUNC_FILTER_MODE_RT_SIZE                            16
+#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_OFFSET                 34324
+#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_SIZE                   16
+#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_OFFSET                       34340
+#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_SIZE                         16
+#define NIG_REG_TX_EDPM_CTRL_RT_OFFSET                                  34356
+#define CDU_REG_CID_ADDR_PARAMS_RT_OFFSET                               34357
+#define CDU_REG_SEGMENT0_PARAMS_RT_OFFSET                               34358
+#define CDU_REG_SEGMENT1_PARAMS_RT_OFFSET                               34359
+#define CDU_REG_PF_SEG0_TYPE_OFFSET_RT_OFFSET                           34360
+#define CDU_REG_PF_SEG1_TYPE_OFFSET_RT_OFFSET                           34361
+#define CDU_REG_PF_SEG2_TYPE_OFFSET_RT_OFFSET                           34362
+#define CDU_REG_PF_SEG3_TYPE_OFFSET_RT_OFFSET                           34363
+#define CDU_REG_PF_FL_SEG0_TYPE_OFFSET_RT_OFFSET                        34364
+#define CDU_REG_PF_FL_SEG1_TYPE_OFFSET_RT_OFFSET                        34365
+#define CDU_REG_PF_FL_SEG2_TYPE_OFFSET_RT_OFFSET                        34366
+#define CDU_REG_PF_FL_SEG3_TYPE_OFFSET_RT_OFFSET                        34367
+#define CDU_REG_VF_SEG_TYPE_OFFSET_RT_OFFSET                            34368
+#define CDU_REG_VF_FL_SEG_TYPE_OFFSET_RT_OFFSET                         34369
+#define PBF_REG_BTB_SHARED_AREA_SIZE_RT_OFFSET                          34370
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ0_RT_OFFSET                        34371
+#define PBF_REG_BTB_GUARANTEED_VOQ0_RT_OFFSET                           34372
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ0_RT_OFFSET                    34373
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ1_RT_OFFSET                        34374
+#define PBF_REG_BTB_GUARANTEED_VOQ1_RT_OFFSET                           34375
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ1_RT_OFFSET                    34376
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ2_RT_OFFSET                        34377
+#define PBF_REG_BTB_GUARANTEED_VOQ2_RT_OFFSET                           34378
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ2_RT_OFFSET                    34379
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ3_RT_OFFSET                        34380
+#define PBF_REG_BTB_GUARANTEED_VOQ3_RT_OFFSET                           34381
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ3_RT_OFFSET                    34382
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ4_RT_OFFSET                        34383
+#define PBF_REG_BTB_GUARANTEED_VOQ4_RT_OFFSET                           34384
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ4_RT_OFFSET                    34385
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ5_RT_OFFSET                        34386
+#define PBF_REG_BTB_GUARANTEED_VOQ5_RT_OFFSET                           34387
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ5_RT_OFFSET                    34388
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ6_RT_OFFSET                        34389
+#define PBF_REG_BTB_GUARANTEED_VOQ6_RT_OFFSET                           34390
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ6_RT_OFFSET                    34391
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ7_RT_OFFSET                        34392
+#define PBF_REG_BTB_GUARANTEED_VOQ7_RT_OFFSET                           34393
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ7_RT_OFFSET                    34394
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ8_RT_OFFSET                        34395
+#define PBF_REG_BTB_GUARANTEED_VOQ8_RT_OFFSET                           34396
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ8_RT_OFFSET                    34397
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ9_RT_OFFSET                        34398
+#define PBF_REG_BTB_GUARANTEED_VOQ9_RT_OFFSET                           34399
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ9_RT_OFFSET                    34400
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ10_RT_OFFSET                       34401
+#define PBF_REG_BTB_GUARANTEED_VOQ10_RT_OFFSET                          34402
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ10_RT_OFFSET                   34403
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ11_RT_OFFSET                       34404
+#define PBF_REG_BTB_GUARANTEED_VOQ11_RT_OFFSET                          34405
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ11_RT_OFFSET                   34406
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ12_RT_OFFSET                       34407
+#define PBF_REG_BTB_GUARANTEED_VOQ12_RT_OFFSET                          34408
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ12_RT_OFFSET                   34409
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ13_RT_OFFSET                       34410
+#define PBF_REG_BTB_GUARANTEED_VOQ13_RT_OFFSET                          34411
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ13_RT_OFFSET                   34412
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ14_RT_OFFSET                       34413
+#define PBF_REG_BTB_GUARANTEED_VOQ14_RT_OFFSET                          34414
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ14_RT_OFFSET                   34415
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ15_RT_OFFSET                       34416
+#define PBF_REG_BTB_GUARANTEED_VOQ15_RT_OFFSET                          34417
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ15_RT_OFFSET                   34418
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ16_RT_OFFSET                       34419
+#define PBF_REG_BTB_GUARANTEED_VOQ16_RT_OFFSET                          34420
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ16_RT_OFFSET                   34421
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ17_RT_OFFSET                       34422
+#define PBF_REG_BTB_GUARANTEED_VOQ17_RT_OFFSET                          34423
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ17_RT_OFFSET                   34424
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ18_RT_OFFSET                       34425
+#define PBF_REG_BTB_GUARANTEED_VOQ18_RT_OFFSET                          34426
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ18_RT_OFFSET                   34427
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ19_RT_OFFSET                       34428
+#define PBF_REG_BTB_GUARANTEED_VOQ19_RT_OFFSET                          34429
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ19_RT_OFFSET                   34430
+#define XCM_REG_CON_PHY_Q3_RT_OFFSET                                    34431
+
+#define RUNTIME_ARRAY_SIZE 34432
+
+#endif /* __RT_DEFS_H__ */
+
+/************************************************************************/
+/* Add include to common eth target for both eCore and protocol driver */
+/************************************************************************/
+
+/* The eth storm context for the Ystorm */
+struct ystorm_eth_conn_st_ctx {
+	__le32 reserved[4];
+};
+
+/* The eth storm context for the Pstorm */
+struct pstorm_eth_conn_st_ctx {
+	__le32 reserved[8];
+};
+
+/* The eth storm context for the Xstorm */
+struct xstorm_eth_conn_st_ctx {
+	__le32 reserved[60];
+};
+
+struct xstorm_eth_conn_ag_ctx {
+	u8	reserved0 /* cdu_validation */;
+	u8	eth_state /* state */;
+	u8	flags0;
+#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_MASK            0x1
+#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_SHIFT           0
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED1_MASK               0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED1_SHIFT              1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED2_MASK               0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED2_SHIFT              2
+#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM3_MASK            0x1
+#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM3_SHIFT           3
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED3_MASK               0x1 /* bit4 */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED3_SHIFT              4
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED4_MASK               0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED4_SHIFT              5
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED5_MASK               0x1 /* bit6 */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED5_SHIFT              6
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED6_MASK               0x1 /* bit7 */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED6_SHIFT              7
+	u8 flags1;
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED7_MASK               0x1 /* bit8 */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED7_SHIFT              0
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED8_MASK               0x1 /* bit9 */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED8_SHIFT              1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED9_MASK               0x1 /* bit10 */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED9_SHIFT              2
+#define XSTORM_ETH_CONN_AG_CTX_BIT11_MASK                   0x1 /* bit11 */
+#define XSTORM_ETH_CONN_AG_CTX_BIT11_SHIFT                  3
+#define XSTORM_ETH_CONN_AG_CTX_BIT12_MASK                   0x1 /* bit12 */
+#define XSTORM_ETH_CONN_AG_CTX_BIT12_SHIFT                  4
+#define XSTORM_ETH_CONN_AG_CTX_BIT13_MASK                   0x1 /* bit13 */
+#define XSTORM_ETH_CONN_AG_CTX_BIT13_SHIFT                  5
+#define XSTORM_ETH_CONN_AG_CTX_TX_RULE_ACTIVE_MASK          0x1 /* bit14 */
+#define XSTORM_ETH_CONN_AG_CTX_TX_RULE_ACTIVE_SHIFT         6
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_ACTIVE_MASK            0x1 /* bit15 */
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_ACTIVE_SHIFT           7
+	u8 flags2;
+#define XSTORM_ETH_CONN_AG_CTX_CF0_MASK                     0x3 /* timer0cf */
+#define XSTORM_ETH_CONN_AG_CTX_CF0_SHIFT                    0
+#define XSTORM_ETH_CONN_AG_CTX_CF1_MASK                     0x3 /* timer1cf */
+#define XSTORM_ETH_CONN_AG_CTX_CF1_SHIFT                    2
+#define XSTORM_ETH_CONN_AG_CTX_CF2_MASK                     0x3 /* timer2cf */
+#define XSTORM_ETH_CONN_AG_CTX_CF2_SHIFT                    4
+#define XSTORM_ETH_CONN_AG_CTX_CF3_MASK                     0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF3_SHIFT                    6
+	u8 flags3;
+#define XSTORM_ETH_CONN_AG_CTX_CF4_MASK                     0x3 /* cf4 */
+#define XSTORM_ETH_CONN_AG_CTX_CF4_SHIFT                    0
+#define XSTORM_ETH_CONN_AG_CTX_CF5_MASK                     0x3 /* cf5 */
+#define XSTORM_ETH_CONN_AG_CTX_CF5_SHIFT                    2
+#define XSTORM_ETH_CONN_AG_CTX_CF6_MASK                     0x3 /* cf6 */
+#define XSTORM_ETH_CONN_AG_CTX_CF6_SHIFT                    4
+#define XSTORM_ETH_CONN_AG_CTX_CF7_MASK                     0x3 /* cf7 */
+#define XSTORM_ETH_CONN_AG_CTX_CF7_SHIFT                    6
+	u8 flags4;
+#define XSTORM_ETH_CONN_AG_CTX_CF8_MASK                     0x3 /* cf8 */
+#define XSTORM_ETH_CONN_AG_CTX_CF8_SHIFT                    0
+#define XSTORM_ETH_CONN_AG_CTX_CF9_MASK                     0x3 /* cf9 */
+#define XSTORM_ETH_CONN_AG_CTX_CF9_SHIFT                    2
+#define XSTORM_ETH_CONN_AG_CTX_CF10_MASK                    0x3 /* cf10 */
+#define XSTORM_ETH_CONN_AG_CTX_CF10_SHIFT                   4
+#define XSTORM_ETH_CONN_AG_CTX_CF11_MASK                    0x3 /* cf11 */
+#define XSTORM_ETH_CONN_AG_CTX_CF11_SHIFT                   6
+	u8 flags5;
+#define XSTORM_ETH_CONN_AG_CTX_CF12_MASK                    0x3 /* cf12 */
+#define XSTORM_ETH_CONN_AG_CTX_CF12_SHIFT                   0
+#define XSTORM_ETH_CONN_AG_CTX_CF13_MASK                    0x3 /* cf13 */
+#define XSTORM_ETH_CONN_AG_CTX_CF13_SHIFT                   2
+#define XSTORM_ETH_CONN_AG_CTX_CF14_MASK                    0x3 /* cf14 */
+#define XSTORM_ETH_CONN_AG_CTX_CF14_SHIFT                   4
+#define XSTORM_ETH_CONN_AG_CTX_CF15_MASK                    0x3 /* cf15 */
+#define XSTORM_ETH_CONN_AG_CTX_CF15_SHIFT                   6
+	u8 flags6;
+#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_MASK        0x3 /* cf16 */
+#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_SHIFT       0
+#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_MASK        0x3
+#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_SHIFT       2
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_MASK                   0x3 /* cf18 */
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_SHIFT                  4
+#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_MASK            0x3 /* cf19 */
+#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_SHIFT           6
+	u8 flags7;
+#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_MASK                0x3 /* cf20 */
+#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_SHIFT               0
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED10_MASK              0x3 /* cf21 */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED10_SHIFT             2
+#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_MASK               0x3 /* cf22 */
+#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_SHIFT              4
+#define XSTORM_ETH_CONN_AG_CTX_CF0EN_MASK                   0x1 /* cf0en */
+#define XSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT                  6
+#define XSTORM_ETH_CONN_AG_CTX_CF1EN_MASK                   0x1 /* cf1en */
+#define XSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT                  7
+	u8 flags8;
+#define XSTORM_ETH_CONN_AG_CTX_CF2EN_MASK                   0x1 /* cf2en */
+#define XSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT                  0
+#define XSTORM_ETH_CONN_AG_CTX_CF3EN_MASK                   0x1 /* cf3en */
+#define XSTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT                  1
+#define XSTORM_ETH_CONN_AG_CTX_CF4EN_MASK                   0x1 /* cf4en */
+#define XSTORM_ETH_CONN_AG_CTX_CF4EN_SHIFT                  2
+#define XSTORM_ETH_CONN_AG_CTX_CF5EN_MASK                   0x1 /* cf5en */
+#define XSTORM_ETH_CONN_AG_CTX_CF5EN_SHIFT                  3
+#define XSTORM_ETH_CONN_AG_CTX_CF6EN_MASK                   0x1 /* cf6en */
+#define XSTORM_ETH_CONN_AG_CTX_CF6EN_SHIFT                  4
+#define XSTORM_ETH_CONN_AG_CTX_CF7EN_MASK                   0x1 /* cf7en */
+#define XSTORM_ETH_CONN_AG_CTX_CF7EN_SHIFT                  5
+#define XSTORM_ETH_CONN_AG_CTX_CF8EN_MASK                   0x1 /* cf8en */
+#define XSTORM_ETH_CONN_AG_CTX_CF8EN_SHIFT                  6
+#define XSTORM_ETH_CONN_AG_CTX_CF9EN_MASK                   0x1 /* cf9en */
+#define XSTORM_ETH_CONN_AG_CTX_CF9EN_SHIFT                  7
+	u8 flags9;
+#define XSTORM_ETH_CONN_AG_CTX_CF10EN_MASK                  0x1 /* cf10en */
+#define XSTORM_ETH_CONN_AG_CTX_CF10EN_SHIFT                 0
+#define XSTORM_ETH_CONN_AG_CTX_CF11EN_MASK                  0x1 /* cf11en */
+#define XSTORM_ETH_CONN_AG_CTX_CF11EN_SHIFT                 1
+#define XSTORM_ETH_CONN_AG_CTX_CF12EN_MASK                  0x1 /* cf12en */
+#define XSTORM_ETH_CONN_AG_CTX_CF12EN_SHIFT                 2
+#define XSTORM_ETH_CONN_AG_CTX_CF13EN_MASK                  0x1 /* cf13en */
+#define XSTORM_ETH_CONN_AG_CTX_CF13EN_SHIFT                 3
+#define XSTORM_ETH_CONN_AG_CTX_CF14EN_MASK                  0x1 /* cf14en */
+#define XSTORM_ETH_CONN_AG_CTX_CF14EN_SHIFT                 4
+#define XSTORM_ETH_CONN_AG_CTX_CF15EN_MASK                  0x1 /* cf15en */
+#define XSTORM_ETH_CONN_AG_CTX_CF15EN_SHIFT                 5
+#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_MASK     0x1 /* cf16en */
+#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_SHIFT    6
+#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_EN_MASK     0x1
+#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_EN_SHIFT    7
+	u8 flags10;
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_EN_MASK                0x1 /* cf18en */
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_EN_SHIFT               0
+#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_EN_MASK         0x1 /* cf19en */
+#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_EN_SHIFT        1
+#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_EN_MASK             0x1 /* cf20en */
+#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_EN_SHIFT            2
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED11_MASK              0x1 /* cf21en */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED11_SHIFT             3
+#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_EN_MASK            0x1 /* cf22en */
+#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_EN_SHIFT           4
+#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_MASK  0x1 /* cf23en */
+#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_SHIFT 5
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED12_MASK              0x1 /* rule0en */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED12_SHIFT             6
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED13_MASK              0x1 /* rule1en */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED13_SHIFT             7
+	u8 flags11;
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED14_MASK              0x1 /* rule2en */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED14_SHIFT             0
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED15_MASK              0x1 /* rule3en */
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED15_SHIFT             1
+#define XSTORM_ETH_CONN_AG_CTX_TX_DEC_RULE_EN_MASK          0x1 /* rule4en */
+#define XSTORM_ETH_CONN_AG_CTX_TX_DEC_RULE_EN_SHIFT         2
+#define XSTORM_ETH_CONN_AG_CTX_RULE5EN_MASK                 0x1 /* rule5en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT                3
+#define XSTORM_ETH_CONN_AG_CTX_RULE6EN_MASK                 0x1 /* rule6en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE6EN_SHIFT                4
+#define XSTORM_ETH_CONN_AG_CTX_RULE7EN_MASK                 0x1 /* rule7en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT                5
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED1_MASK            0x1 /* rule8en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED1_SHIFT           6
+#define XSTORM_ETH_CONN_AG_CTX_RULE9EN_MASK                 0x1 /* rule9en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE9EN_SHIFT                7
+	u8 flags12;
+#define XSTORM_ETH_CONN_AG_CTX_RULE10EN_MASK                0x1 /* rule10en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE10EN_SHIFT               0
+#define XSTORM_ETH_CONN_AG_CTX_RULE11EN_MASK                0x1 /* rule11en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE11EN_SHIFT               1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED2_MASK            0x1 /* rule12en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED2_SHIFT           2
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED3_MASK            0x1 /* rule13en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED3_SHIFT           3
+#define XSTORM_ETH_CONN_AG_CTX_RULE14EN_MASK                0x1 /* rule14en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE14EN_SHIFT               4
+#define XSTORM_ETH_CONN_AG_CTX_RULE15EN_MASK                0x1 /* rule15en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE15EN_SHIFT               5
+#define XSTORM_ETH_CONN_AG_CTX_RULE16EN_MASK                0x1 /* rule16en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE16EN_SHIFT               6
+#define XSTORM_ETH_CONN_AG_CTX_RULE17EN_MASK                0x1 /* rule17en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE17EN_SHIFT               7
+	u8 flags13;
+#define XSTORM_ETH_CONN_AG_CTX_RULE18EN_MASK                0x1 /* rule18en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE18EN_SHIFT               0
+#define XSTORM_ETH_CONN_AG_CTX_RULE19EN_MASK                0x1 /* rule19en */
+#define XSTORM_ETH_CONN_AG_CTX_RULE19EN_SHIFT               1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED4_MASK            0x1 /* rule20en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED4_SHIFT           2
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED5_MASK            0x1 /* rule21en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED5_SHIFT           3
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED6_MASK            0x1 /* rule22en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED6_SHIFT           4
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED7_MASK            0x1 /* rule23en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED7_SHIFT           5
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED8_MASK            0x1 /* rule24en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED8_SHIFT           6
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED9_MASK            0x1 /* rule25en */
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED9_SHIFT           7
+	u8 flags14;
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_USE_EXT_HDR_MASK        0x1 /* bit16 */
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_USE_EXT_HDR_SHIFT       0
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_MASK      0x1 /* bit17 */
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_SHIFT     1
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_MASK    0x1 /* bit18 */
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_SHIFT   2
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_MASK    0x1 /* bit19 */
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_SHIFT   3
+#define XSTORM_ETH_CONN_AG_CTX_L2_EDPM_ENABLE_MASK          0x1 /* bit20 */
+#define XSTORM_ETH_CONN_AG_CTX_L2_EDPM_ENABLE_SHIFT         4
+#define XSTORM_ETH_CONN_AG_CTX_ROCE_EDPM_ENABLE_MASK        0x1 /* bit21 */
+#define XSTORM_ETH_CONN_AG_CTX_ROCE_EDPM_ENABLE_SHIFT       5
+#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_MASK              0x3 /* cf23 */
+#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_SHIFT             6
+	u8	edpm_event_id /* byte2 */;
+	__le16	physical_q0 /* physical_q0 */;
+	__le16	word1 /* physical_q1 */;
+	__le16	edpm_num_bds /* physical_q2 */;
+	__le16	tx_bd_cons /* word3 */;
+	__le16	tx_bd_prod /* word4 */;
+	__le16	go_to_bd_cons /* word5 */;
+	__le16	conn_dpi /* conn_dpi */;
+	u8	byte3 /* byte3 */;
+	u8	byte4 /* byte4 */;
+	u8	byte5 /* byte5 */;
+	u8	byte6 /* byte6 */;
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le32	reg4 /* reg4 */;
+	__le32	reg5 /* cf_array0 */;
+	__le32	reg6 /* cf_array1 */;
+	__le16	word7 /* word7 */;
+	__le16	word8 /* word8 */;
+	__le16	word9 /* word9 */;
+	__le16	word10 /* word10 */;
+	__le32	reg7 /* reg7 */;
+	__le32	reg8 /* reg8 */;
+	__le32	reg9 /* reg9 */;
+	u8	byte7 /* byte7 */;
+	u8	byte8 /* byte8 */;
+	u8	byte9 /* byte9 */;
+	u8	byte10 /* byte10 */;
+	u8	byte11 /* byte11 */;
+	u8	byte12 /* byte12 */;
+	u8	byte13 /* byte13 */;
+	u8	byte14 /* byte14 */;
+	u8	byte15 /* byte15 */;
+	u8	byte16 /* byte16 */;
+	__le16	word11 /* word11 */;
+	__le32	reg10 /* reg10 */;
+	__le32	reg11 /* reg11 */;
+	__le32	reg12 /* reg12 */;
+	__le32	reg13 /* reg13 */;
+	__le32	reg14 /* reg14 */;
+	__le32	reg15 /* reg15 */;
+	__le32	reg16 /* reg16 */;
+	__le32	reg17 /* reg17 */;
+	__le32	reg18 /* reg18 */;
+	__le32	reg19 /* reg19 */;
+	__le16	word12 /* word12 */;
+	__le16	word13 /* word13 */;
+	__le16	word14 /* word14 */;
+	__le16	word15 /* word15 */;
+};
+
+/* The eth storm context for the Tstorm */
+struct tstorm_eth_conn_st_ctx {
+	__le32 reserved[4];
+};
+
+/* The eth storm context for the Mstorm */
+struct mstorm_eth_conn_st_ctx {
+	__le32 reserved[8];
+};
+
+/* The eth storm context for the Ustorm */
+struct ustorm_eth_conn_st_ctx {
+	__le32 reserved[40];
+};
+
+/* eth connection context */
+struct eth_conn_context {
+	struct ystorm_eth_conn_st_ctx	ystorm_st_context;
+	struct regpair			ystorm_st_padding[2] /* padding */;
+	struct pstorm_eth_conn_st_ctx	pstorm_st_context;
+	struct regpair			pstorm_st_padding[2] /* padding */;
+	struct xstorm_eth_conn_st_ctx	xstorm_st_context;
+	struct xstorm_eth_conn_ag_ctx	xstorm_ag_context;
+	struct tstorm_eth_conn_st_ctx	tstorm_st_context;
+	struct regpair			tstorm_st_padding[2] /* padding */;
+	struct mstorm_eth_conn_st_ctx	mstorm_st_context;
+	struct ustorm_eth_conn_st_ctx	ustorm_st_context;
+};
+
+struct mstorm_eth_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define MSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_MASK  0x1   /* exist_in_qm0 */
+#define MSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_SHIFT 0
+#define MSTORM_ETH_CONN_AG_CTX_BIT1_MASK          0x1   /* exist_in_qm1 */
+#define MSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT         1
+#define MSTORM_ETH_CONN_AG_CTX_CF0_MASK           0x3   /* cf0 */
+#define MSTORM_ETH_CONN_AG_CTX_CF0_SHIFT          2
+#define MSTORM_ETH_CONN_AG_CTX_CF1_MASK           0x3   /* cf1 */
+#define MSTORM_ETH_CONN_AG_CTX_CF1_SHIFT          4
+#define MSTORM_ETH_CONN_AG_CTX_CF2_MASK           0x3   /* cf2 */
+#define MSTORM_ETH_CONN_AG_CTX_CF2_SHIFT          6
+	u8 flags1;
+#define MSTORM_ETH_CONN_AG_CTX_CF0EN_MASK         0x1   /* cf0en */
+#define MSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT        0
+#define MSTORM_ETH_CONN_AG_CTX_CF1EN_MASK         0x1   /* cf1en */
+#define MSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT        1
+#define MSTORM_ETH_CONN_AG_CTX_CF2EN_MASK         0x1   /* cf2en */
+#define MSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT        2
+#define MSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK       0x1   /* rule0en */
+#define MSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT      3
+#define MSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK       0x1   /* rule1en */
+#define MSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT      4
+#define MSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK       0x1   /* rule2en */
+#define MSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT      5
+#define MSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK       0x1   /* rule3en */
+#define MSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT      6
+#define MSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK       0x1   /* rule4en */
+#define MSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT      7
+	__le16	word0 /* word0 */;
+	__le16	word1 /* word1 */;
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+};
+
+struct tstorm_eth_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define TSTORM_ETH_CONN_AG_CTX_BIT0_MASK      0x1       /* exist_in_qm0 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT0_SHIFT     0
+#define TSTORM_ETH_CONN_AG_CTX_BIT1_MASK      0x1       /* exist_in_qm1 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT     1
+#define TSTORM_ETH_CONN_AG_CTX_BIT2_MASK      0x1       /* bit2 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT2_SHIFT     2
+#define TSTORM_ETH_CONN_AG_CTX_BIT3_MASK      0x1       /* bit3 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT3_SHIFT     3
+#define TSTORM_ETH_CONN_AG_CTX_BIT4_MASK      0x1       /* bit4 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT4_SHIFT     4
+#define TSTORM_ETH_CONN_AG_CTX_BIT5_MASK      0x1       /* bit5 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT5_SHIFT     5
+#define TSTORM_ETH_CONN_AG_CTX_CF0_MASK       0x3       /* timer0cf */
+#define TSTORM_ETH_CONN_AG_CTX_CF0_SHIFT      6
+	u8 flags1;
+#define TSTORM_ETH_CONN_AG_CTX_CF1_MASK       0x3       /* timer1cf */
+#define TSTORM_ETH_CONN_AG_CTX_CF1_SHIFT      0
+#define TSTORM_ETH_CONN_AG_CTX_CF2_MASK       0x3       /* timer2cf */
+#define TSTORM_ETH_CONN_AG_CTX_CF2_SHIFT      2
+#define TSTORM_ETH_CONN_AG_CTX_CF3_MASK       0x3       /* timer_stop_all */
+#define TSTORM_ETH_CONN_AG_CTX_CF3_SHIFT      4
+#define TSTORM_ETH_CONN_AG_CTX_CF4_MASK       0x3       /* cf4 */
+#define TSTORM_ETH_CONN_AG_CTX_CF4_SHIFT      6
+	u8 flags2;
+#define TSTORM_ETH_CONN_AG_CTX_CF5_MASK       0x3       /* cf5 */
+#define TSTORM_ETH_CONN_AG_CTX_CF5_SHIFT      0
+#define TSTORM_ETH_CONN_AG_CTX_CF6_MASK       0x3       /* cf6 */
+#define TSTORM_ETH_CONN_AG_CTX_CF6_SHIFT      2
+#define TSTORM_ETH_CONN_AG_CTX_CF7_MASK       0x3       /* cf7 */
+#define TSTORM_ETH_CONN_AG_CTX_CF7_SHIFT      4
+#define TSTORM_ETH_CONN_AG_CTX_CF8_MASK       0x3       /* cf8 */
+#define TSTORM_ETH_CONN_AG_CTX_CF8_SHIFT      6
+	u8 flags3;
+#define TSTORM_ETH_CONN_AG_CTX_CF9_MASK       0x3       /* cf9 */
+#define TSTORM_ETH_CONN_AG_CTX_CF9_SHIFT      0
+#define TSTORM_ETH_CONN_AG_CTX_CF10_MASK      0x3       /* cf10 */
+#define TSTORM_ETH_CONN_AG_CTX_CF10_SHIFT     2
+#define TSTORM_ETH_CONN_AG_CTX_CF0EN_MASK     0x1       /* cf0en */
+#define TSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT    4
+#define TSTORM_ETH_CONN_AG_CTX_CF1EN_MASK     0x1       /* cf1en */
+#define TSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT    5
+#define TSTORM_ETH_CONN_AG_CTX_CF2EN_MASK     0x1       /* cf2en */
+#define TSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT    6
+#define TSTORM_ETH_CONN_AG_CTX_CF3EN_MASK     0x1       /* cf3en */
+#define TSTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT    7
+	u8 flags4;
+#define TSTORM_ETH_CONN_AG_CTX_CF4EN_MASK     0x1       /* cf4en */
+#define TSTORM_ETH_CONN_AG_CTX_CF4EN_SHIFT    0
+#define TSTORM_ETH_CONN_AG_CTX_CF5EN_MASK     0x1       /* cf5en */
+#define TSTORM_ETH_CONN_AG_CTX_CF5EN_SHIFT    1
+#define TSTORM_ETH_CONN_AG_CTX_CF6EN_MASK     0x1       /* cf6en */
+#define TSTORM_ETH_CONN_AG_CTX_CF6EN_SHIFT    2
+#define TSTORM_ETH_CONN_AG_CTX_CF7EN_MASK     0x1       /* cf7en */
+#define TSTORM_ETH_CONN_AG_CTX_CF7EN_SHIFT    3
+#define TSTORM_ETH_CONN_AG_CTX_CF8EN_MASK     0x1       /* cf8en */
+#define TSTORM_ETH_CONN_AG_CTX_CF8EN_SHIFT    4
+#define TSTORM_ETH_CONN_AG_CTX_CF9EN_MASK     0x1       /* cf9en */
+#define TSTORM_ETH_CONN_AG_CTX_CF9EN_SHIFT    5
+#define TSTORM_ETH_CONN_AG_CTX_CF10EN_MASK    0x1       /* cf10en */
+#define TSTORM_ETH_CONN_AG_CTX_CF10EN_SHIFT   6
+#define TSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK   0x1       /* rule0en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT  7
+	u8 flags5;
+#define TSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK   0x1       /* rule1en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT  0
+#define TSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK   0x1       /* rule2en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT  1
+#define TSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK   0x1       /* rule3en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT  2
+#define TSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK   0x1       /* rule4en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT  3
+#define TSTORM_ETH_CONN_AG_CTX_RULE5EN_MASK   0x1       /* rule5en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT  4
+#define TSTORM_ETH_CONN_AG_CTX_RX_BD_EN_MASK  0x1       /* rule6en */
+#define TSTORM_ETH_CONN_AG_CTX_RX_BD_EN_SHIFT 5
+#define TSTORM_ETH_CONN_AG_CTX_RULE7EN_MASK   0x1       /* rule7en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT  6
+#define TSTORM_ETH_CONN_AG_CTX_RULE8EN_MASK   0x1       /* rule8en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT  7
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le32	reg4 /* reg4 */;
+	__le32	reg5 /* reg5 */;
+	__le32	reg6 /* reg6 */;
+	__le32	reg7 /* reg7 */;
+	__le32	reg8 /* reg8 */;
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	rx_bd_cons /* word0 */;
+	u8	byte4 /* byte4 */;
+	u8	byte5 /* byte5 */;
+	__le16	rx_bd_prod /* word1 */;
+	__le16	word2 /* conn_dpi */;
+	__le16	word3 /* word3 */;
+	__le32	reg9 /* reg9 */;
+	__le32	reg10 /* reg10 */;
+};
+
+struct ustorm_eth_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define USTORM_ETH_CONN_AG_CTX_BIT0_MASK                  0x1
+#define USTORM_ETH_CONN_AG_CTX_BIT0_SHIFT                 0
+#define USTORM_ETH_CONN_AG_CTX_BIT1_MASK                  0x1
+#define USTORM_ETH_CONN_AG_CTX_BIT1_SHIFT                 1
+#define USTORM_ETH_CONN_AG_CTX_CF0_MASK                   0x3   /* timer0cf */
+#define USTORM_ETH_CONN_AG_CTX_CF0_SHIFT                  2
+#define USTORM_ETH_CONN_AG_CTX_CF1_MASK                   0x3   /* timer1cf */
+#define USTORM_ETH_CONN_AG_CTX_CF1_SHIFT                  4
+#define USTORM_ETH_CONN_AG_CTX_CF2_MASK                   0x3   /* timer2cf */
+#define USTORM_ETH_CONN_AG_CTX_CF2_SHIFT                  6
+	u8 flags1;
+#define USTORM_ETH_CONN_AG_CTX_CF3_MASK                   0x3
+#define USTORM_ETH_CONN_AG_CTX_CF3_SHIFT                  0
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_MASK             0x3   /* cf4 */
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_SHIFT            2
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_MASK             0x3   /* cf5 */
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_SHIFT            4
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_MASK     0x3   /* cf6 */
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_SHIFT    6
+	u8 flags2;
+#define USTORM_ETH_CONN_AG_CTX_CF0EN_MASK                 0x1   /* cf0en */
+#define USTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT                0
+#define USTORM_ETH_CONN_AG_CTX_CF1EN_MASK                 0x1   /* cf1en */
+#define USTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT                1
+#define USTORM_ETH_CONN_AG_CTX_CF2EN_MASK                 0x1   /* cf2en */
+#define USTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT                2
+#define USTORM_ETH_CONN_AG_CTX_CF3EN_MASK                 0x1   /* cf3en */
+#define USTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT                3
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_MASK          0x1   /* cf4en */
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_SHIFT         4
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_MASK          0x1   /* cf5en */
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_SHIFT         5
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_MASK  0x1   /* cf6en */
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_SHIFT 6
+#define USTORM_ETH_CONN_AG_CTX_RULE0EN_MASK               0x1   /* rule0en */
+#define USTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT              7
+	u8 flags3;
+#define USTORM_ETH_CONN_AG_CTX_RULE1EN_MASK               0x1   /* rule1en */
+#define USTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT              0
+#define USTORM_ETH_CONN_AG_CTX_RULE2EN_MASK               0x1   /* rule2en */
+#define USTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT              1
+#define USTORM_ETH_CONN_AG_CTX_RULE3EN_MASK               0x1   /* rule3en */
+#define USTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT              2
+#define USTORM_ETH_CONN_AG_CTX_RULE4EN_MASK               0x1   /* rule4en */
+#define USTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT              3
+#define USTORM_ETH_CONN_AG_CTX_RULE5EN_MASK               0x1   /* rule5en */
+#define USTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT              4
+#define USTORM_ETH_CONN_AG_CTX_RULE6EN_MASK               0x1   /* rule6en */
+#define USTORM_ETH_CONN_AG_CTX_RULE6EN_SHIFT              5
+#define USTORM_ETH_CONN_AG_CTX_RULE7EN_MASK               0x1   /* rule7en */
+#define USTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT              6
+#define USTORM_ETH_CONN_AG_CTX_RULE8EN_MASK               0x1   /* rule8en */
+#define USTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT              7
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	word0 /* conn_dpi */;
+	__le16	tx_bd_cons /* word1 */;
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le16	tx_drv_bd_cons /* word2 */;
+	__le16	rx_drv_cqe_cons /* word3 */;
+};
+
+struct xstorm_eth_hw_conn_ag_ctx {
+	u8	reserved0 /* cdu_validation */;
+	u8	eth_state /* state */;
+	u8	flags0;
+#define XSTORM_ETH_HW_CONN_AG_CTX_EXIST_IN_QM0_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_EXIST_IN_QM0_SHIFT           0
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED1_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED1_SHIFT              1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED2_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED2_SHIFT              2
+#define XSTORM_ETH_HW_CONN_AG_CTX_EXIST_IN_QM3_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_EXIST_IN_QM3_SHIFT           3
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED3_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED3_SHIFT              4
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED4_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED4_SHIFT              5
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED5_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED5_SHIFT              6
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED6_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED6_SHIFT              7
+	u8 flags1;
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED7_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED7_SHIFT              0
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED8_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED8_SHIFT              1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED9_MASK               0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED9_SHIFT              2
+#define XSTORM_ETH_HW_CONN_AG_CTX_BIT11_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_BIT11_SHIFT                  3
+#define XSTORM_ETH_HW_CONN_AG_CTX_BIT12_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_BIT12_SHIFT                  4
+#define XSTORM_ETH_HW_CONN_AG_CTX_BIT13_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_BIT13_SHIFT                  5
+#define XSTORM_ETH_HW_CONN_AG_CTX_TX_RULE_ACTIVE_MASK          0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_TX_RULE_ACTIVE_SHIFT         6
+#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_ACTIVE_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_ACTIVE_SHIFT           7
+	u8 flags2;
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF0_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF0_SHIFT                    0
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF1_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF1_SHIFT                    2
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF2_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF2_SHIFT                    4
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF3_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF3_SHIFT                    6
+	u8 flags3;
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF4_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF4_SHIFT                    0
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF5_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF5_SHIFT                    2
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF6_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF6_SHIFT                    4
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF7_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF7_SHIFT                    6
+	u8 flags4;
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF8_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF8_SHIFT                    0
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF9_MASK                     0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF9_SHIFT                    2
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF10_MASK                    0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF10_SHIFT                   4
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF11_MASK                    0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF11_SHIFT                   6
+	u8 flags5;
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF12_MASK                    0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF12_SHIFT                   0
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF13_MASK                    0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF13_SHIFT                   2
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF14_MASK                    0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF14_SHIFT                   4
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF15_MASK                    0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF15_SHIFT                   6
+	u8 flags6;
+#define XSTORM_ETH_HW_CONN_AG_CTX_GO_TO_BD_CONS_CF_MASK        0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_GO_TO_BD_CONS_CF_SHIFT       0
+#define XSTORM_ETH_HW_CONN_AG_CTX_MULTI_UNICAST_CF_MASK        0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_MULTI_UNICAST_CF_SHIFT       2
+#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_MASK                   0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_SHIFT                  4
+#define XSTORM_ETH_HW_CONN_AG_CTX_TERMINATE_CF_MASK            0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_TERMINATE_CF_SHIFT           6
+	u8 flags7;
+#define XSTORM_ETH_HW_CONN_AG_CTX_FLUSH_Q0_MASK                0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_FLUSH_Q0_SHIFT               0
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED10_MASK              0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED10_SHIFT             2
+#define XSTORM_ETH_HW_CONN_AG_CTX_SLOW_PATH_MASK               0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_SLOW_PATH_SHIFT              4
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF0EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF0EN_SHIFT                  6
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF1EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF1EN_SHIFT                  7
+	u8 flags8;
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF2EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF2EN_SHIFT                  0
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF3EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF3EN_SHIFT                  1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF4EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF4EN_SHIFT                  2
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF5EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF5EN_SHIFT                  3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF6EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF6EN_SHIFT                  4
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF7EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF7EN_SHIFT                  5
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF8EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF8EN_SHIFT                  6
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF9EN_MASK                   0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF9EN_SHIFT                  7
+	u8 flags9;
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF10EN_MASK                  0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF10EN_SHIFT                 0
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF11EN_MASK                  0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF11EN_SHIFT                 1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF12EN_MASK                  0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF12EN_SHIFT                 2
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF13EN_MASK                  0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF13EN_SHIFT                 3
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF14EN_MASK                  0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF14EN_SHIFT                 4
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF15EN_MASK                  0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_CF15EN_SHIFT                 5
+#define XSTORM_ETH_HW_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_MASK     0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_SHIFT    6
+#define XSTORM_ETH_HW_CONN_AG_CTX_MULTI_UNICAST_CF_EN_MASK     0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_MULTI_UNICAST_CF_EN_SHIFT    7
+	u8 flags10;
+#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_EN_SHIFT               0
+#define XSTORM_ETH_HW_CONN_AG_CTX_TERMINATE_CF_EN_MASK         0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_TERMINATE_CF_EN_SHIFT        1
+#define XSTORM_ETH_HW_CONN_AG_CTX_FLUSH_Q0_EN_MASK             0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_FLUSH_Q0_EN_SHIFT            2
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED11_MASK              0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED11_SHIFT             3
+#define XSTORM_ETH_HW_CONN_AG_CTX_SLOW_PATH_EN_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_SLOW_PATH_EN_SHIFT           4
+#define XSTORM_ETH_HW_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_MASK  0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_SHIFT 5
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED12_MASK              0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED12_SHIFT             6
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED13_MASK              0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED13_SHIFT             7
+	u8 flags11;
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED14_MASK              0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED14_SHIFT             0
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED15_MASK              0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED15_SHIFT             1
+#define XSTORM_ETH_HW_CONN_AG_CTX_TX_DEC_RULE_EN_MASK          0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_TX_DEC_RULE_EN_SHIFT         2
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE5EN_MASK                 0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE5EN_SHIFT                3
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE6EN_MASK                 0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE6EN_SHIFT                4
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE7EN_MASK                 0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE7EN_SHIFT                5
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED1_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED1_SHIFT           6
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE9EN_MASK                 0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE9EN_SHIFT                7
+	u8 flags12;
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE10EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE10EN_SHIFT               0
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE11EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE11EN_SHIFT               1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED2_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED2_SHIFT           2
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED3_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED3_SHIFT           3
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE14EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE14EN_SHIFT               4
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE15EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE15EN_SHIFT               5
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE16EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE16EN_SHIFT               6
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE17EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE17EN_SHIFT               7
+	u8 flags13;
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE18EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE18EN_SHIFT               0
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE19EN_MASK                0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_RULE19EN_SHIFT               1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED4_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED4_SHIFT           2
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED5_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED5_SHIFT           3
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED6_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED6_SHIFT           4
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED7_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED7_SHIFT           5
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED8_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED8_SHIFT           6
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED9_MASK            0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED9_SHIFT           7
+	u8 flags14;
+#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_USE_EXT_HDR_MASK        0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_USE_EXT_HDR_SHIFT       0
+#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_MASK      0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_SHIFT     1
+#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_MASK    0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_SHIFT   2
+#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_MASK    0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_SHIFT   3
+#define XSTORM_ETH_HW_CONN_AG_CTX_L2_EDPM_ENABLE_MASK          0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_L2_EDPM_ENABLE_SHIFT         4
+#define XSTORM_ETH_HW_CONN_AG_CTX_ROCE_EDPM_ENABLE_MASK        0x1
+#define XSTORM_ETH_HW_CONN_AG_CTX_ROCE_EDPM_ENABLE_SHIFT       5
+#define XSTORM_ETH_HW_CONN_AG_CTX_TPH_ENABLE_MASK              0x3
+#define XSTORM_ETH_HW_CONN_AG_CTX_TPH_ENABLE_SHIFT             6
+	u8	edpm_event_id /* byte2 */;
+	__le16	physical_q0 /* physical_q0 */;
+	__le16	word1 /* physical_q1 */;
+	__le16	edpm_num_bds /* physical_q2 */;
+	__le16	tx_bd_cons /* word3 */;
+	__le16	tx_bd_prod /* word4 */;
+	__le16	go_to_bd_cons /* word5 */;
+	__le16	conn_dpi /* conn_dpi */;
+};
+
+#define MFW_HSI_H
+
+#define VF_MAX_STATIC 192       /* In case of K2 */
+
+#define MCP_GLOB_PATH_MAX       2
+#define MCP_PORT_MAX            2       /* Global */
+#define MCP_GLOB_PORT_MAX       4       /* Global */
+#define MCP_GLOB_FUNC_MAX       16      /* Global */
+
+typedef u32 offsize_t;                  /* In DWORDS !!! */
+/* Offset from the beginning of the MCP scratchpad */
+#define OFFSIZE_OFFSET_SHIFT    0
+#define OFFSIZE_OFFSET_MASK     0x0000ffff
+/* Size of specific element (not the whole array if any) */
+#define OFFSIZE_SIZE_SHIFT      16
+#define OFFSIZE_SIZE_MASK       0xffff0000
+
+/* SECTION_OFFSET is calculating the offset in bytes out of offsize */
+#define SECTION_OFFSET(_offsize)        ((((_offsize &		    \
+					    OFFSIZE_OFFSET_MASK) >> \
+					   OFFSIZE_OFFSET_SHIFT) << 2))
+
+/* QED_SECTION_SIZE is calculating the size in bytes out of offsize */
+#define QED_SECTION_SIZE(_offsize)              (((_offsize &		 \
+						   OFFSIZE_SIZE_MASK) >> \
+						  OFFSIZE_SIZE_SHIFT) << 2)
+
+/* SECTION_ADDR returns the GRC addr of a section, given offsize and index
+ * within section.
+ */
+#define SECTION_ADDR(_offsize, idx)     (MCP_REG_SCRATCH +	    \
+					 SECTION_OFFSET(_offsize) + \
+					 (QED_SECTION_SIZE(_offsize) * idx))
+
+/* SECTION_OFFSIZE_ADDR returns the GRC addr to the offsize address.
+ * Use offsetof, since the OFFSETUP collide with the firmware definition
+ */
+#define SECTION_OFFSIZE_ADDR(_pub_base, _section) (_pub_base +		     \
+						   offsetof(struct	     \
+							    mcp_public_data, \
+							    sections[_section]))
+/* PHY configuration */
+struct pmm_phy_cfg {
+	u32	speed;
+#define PMM_SPEED_AUTONEG   0
+
+	u32	pause;  /* bitmask */
+#define PMM_PAUSE_NONE          0x0
+#define PMM_PAUSE_AUTONEG       0x1
+#define PMM_PAUSE_RX            0x2
+#define PMM_PAUSE_TX            0x4
+
+	u32	adv_speed;  /* Default should be the speed_cap_mask */
+	u32	loopback_mode;
+#define PMM_LOOPBACK_NONE               0
+#define PMM_LOOPBACK_INT_PHY    1
+#define PMM_LOOPBACK_EXT_PHY    2
+#define PMM_LOOPBACK_EXT                3
+#define PMM_LOOPBACK_MAC                4
+
+	/* features */
+	u32 feature_config_flags;
+};
+
+struct port_mf_cfg {
+	u32	dynamic_cfg; /* device control channel */
+#define PORT_MF_CFG_OV_TAG_MASK              0x0000ffff
+#define PORT_MF_CFG_OV_TAG_SHIFT             0
+#define PORT_MF_CFG_OV_TAG_DEFAULT         PORT_MF_CFG_OV_TAG_MASK
+
+	u32	reserved[1];
+};
+
+/* DO NOT add new fields in the middle
+ * MUST be synced with struct pmm_stats_map
+ */
+struct pmm_stats {
+	u64	r64;    /* 0x00 (Offset 0x00 ) RX 64-byte frame counter*/
+	u64	r127;   /* 0x01 (Offset 0x08 ) RX 65 to 127 byte frame counter*/
+	u64	r255;
+	u64	r511;
+	u64	r1023;
+	u64	r1518;
+	u64	r1522;
+	u64	r2047;
+	u64	r4095;
+	u64	r9216;
+	u64	r16383;
+	u64	rfcs;   /* 0x0F (Offset 0x58 ) RX FCS error frame counter*/
+	u64	rxcf;   /* 0x10 (Offset 0x60 ) RX control frame counter*/
+	u64	rxpf;   /* 0x11 (Offset 0x68 ) RX pause frame counter*/
+	u64	rxpp;   /* 0x12 (Offset 0x70 ) RX PFC frame counter*/
+	u64	raln;   /* 0x16 (Offset 0x78 ) RX alignment error counter*/
+	u64	rfcr;   /* 0x19 (Offset 0x80 ) RX false carrier counter */
+	u64	rovr;   /* 0x1A (Offset 0x88 ) RX oversized frame counter*/
+	u64	rjbr;   /* 0x1B (Offset 0x90 ) RX jabber frame counter */
+	u64	rund;   /* 0x34 (Offset 0x98 ) RX undersized frame counter */
+	u64	rfrg;   /* 0x35 (Offset 0xa0 ) RX fragment counter */
+	u64	t64;    /* 0x40 (Offset 0xa8 ) TX 64-byte frame counter */
+	u64	t127;
+	u64	t255;
+	u64	t511;
+	u64	t1023;
+	u64	t1518;
+	u64	t2047;
+	u64	t4095;
+	u64	t9216;
+	u64	t16383;
+	u64	txpf;   /* 0x50 (Offset 0xf8 ) TX pause frame counter */
+	u64	txpp;   /* 0x51 (Offset 0x100) TX PFC frame counter */
+	u64	tlpiec;
+	u64	tncl;
+	u64	rbyte;  /* 0x3d (Offset 0x118) RX byte counter */
+	u64	rxuca;  /* 0x0c (Offset 0x120) RX UC frame counter */
+	u64	rxmca;  /* 0x0d (Offset 0x128) RX MC frame counter */
+	u64	rxbca;  /* 0x0e (Offset 0x130) RX BC frame counter */
+	u64	rxpok;
+	u64	tbyte;  /* 0x6f (Offset 0x140) TX byte counter */
+	u64	txuca;  /* 0x4d (Offset 0x148) TX UC frame counter */
+	u64	txmca;  /* 0x4e (Offset 0x150) TX MC frame counter */
+	u64	txbca;  /* 0x4f (Offset 0x158) TX BC frame counter */
+	u64	txcf;   /* 0x54 (Offset 0x160) TX control frame counter */
+};
+
+struct brb_stats {
+	u64	brb_truncate[8];
+	u64	brb_discard[8];
+};
+
+struct port_stats {
+	struct brb_stats	brb;
+	struct pmm_stats	pmm;
+};
+
+#define CMT_TEAM0 0
+#define CMT_TEAM1 1
+#define CMT_TEAM_MAX 2
+
+struct couple_mode_teaming {
+	u8 port_cmt[MCP_GLOB_PORT_MAX];
+#define PORT_CMT_IN_TEAM		BIT(0)
+
+#define PORT_CMT_PORT_ROLE		BIT(1)
+#define PORT_CMT_PORT_INACTIVE      (0 << 1)
+#define PORT_CMT_PORT_ACTIVE		BIT(1)
+
+#define PORT_CMT_TEAM_MASK		BIT(2)
+#define PORT_CMT_TEAM0              (0 << 2)
+#define PORT_CMT_TEAM1			BIT(2)
+};
+
+/**************************************
+*     LLDP and DCBX HSI structures
+**************************************/
+#define LLDP_CHASSIS_ID_STAT_LEN 4
+#define LLDP_PORT_ID_STAT_LEN 4
+#define DCBX_MAX_APP_PROTOCOL           32
+#define MAX_SYSTEM_LLDP_TLV_DATA    32
+
+enum lldp_agent_e {
+	LLDP_NEAREST_BRIDGE = 0,
+	LLDP_NEAREST_NON_TPMR_BRIDGE,
+	LLDP_NEAREST_CUSTOMER_BRIDGE,
+	LLDP_MAX_LLDP_AGENTS
+};
+
+struct lldp_config_params_s {
+	u32 config;
+#define LLDP_CONFIG_TX_INTERVAL_MASK        0x000000ff
+#define LLDP_CONFIG_TX_INTERVAL_SHIFT       0
+#define LLDP_CONFIG_HOLD_MASK               0x00000f00
+#define LLDP_CONFIG_HOLD_SHIFT              8
+#define LLDP_CONFIG_MAX_CREDIT_MASK         0x0000f000
+#define LLDP_CONFIG_MAX_CREDIT_SHIFT        12
+#define LLDP_CONFIG_ENABLE_RX_MASK          0x40000000
+#define LLDP_CONFIG_ENABLE_RX_SHIFT         30
+#define LLDP_CONFIG_ENABLE_TX_MASK          0x80000000
+#define LLDP_CONFIG_ENABLE_TX_SHIFT         31
+	u32	local_chassis_id[LLDP_CHASSIS_ID_STAT_LEN];
+	u32	local_port_id[LLDP_PORT_ID_STAT_LEN];
+};
+
+struct lldp_status_params_s {
+	u32	prefix_seq_num;
+	u32	status; /* TBD */
+
+	/* Holds remote Chassis ID TLV header, subtype and 9B of payload. */
+	u32	peer_chassis_id[LLDP_CHASSIS_ID_STAT_LEN];
+
+	/* Holds remote Port ID TLV header, subtype and 9B of payload. */
+	u32	peer_port_id[LLDP_PORT_ID_STAT_LEN];
+	u32	suffix_seq_num;
+};
+
+struct dcbx_ets_feature {
+	u32 flags;
+#define DCBX_ETS_ENABLED_MASK                   0x00000001
+#define DCBX_ETS_ENABLED_SHIFT                  0
+#define DCBX_ETS_WILLING_MASK                   0x00000002
+#define DCBX_ETS_WILLING_SHIFT                  1
+#define DCBX_ETS_ERROR_MASK                     0x00000004
+#define DCBX_ETS_ERROR_SHIFT                    2
+#define DCBX_ETS_CBS_MASK                       0x00000008
+#define DCBX_ETS_CBS_SHIFT                      3
+#define DCBX_ETS_MAX_TCS_MASK                   0x000000f0
+#define DCBX_ETS_MAX_TCS_SHIFT                  4
+	u32	pri_tc_tbl[1];
+#define DCBX_ISCSI_OOO_TC                       4
+#define NIG_ETS_ISCSI_OOO_CLIENT_OFFSET         (DCBX_ISCSI_OOO_TC + 1)
+	u32	tc_bw_tbl[2];
+	u32	tc_tsa_tbl[2];
+#define DCBX_ETS_TSA_STRICT                     0
+#define DCBX_ETS_TSA_CBS                        1
+#define DCBX_ETS_TSA_ETS                        2
+};
+
+struct dcbx_app_priority_entry {
+	u32 entry;
+#define DCBX_APP_PRI_MAP_MASK       0x000000ff
+#define DCBX_APP_PRI_MAP_SHIFT      0
+#define DCBX_APP_PRI_0              0x01
+#define DCBX_APP_PRI_1              0x02
+#define DCBX_APP_PRI_2              0x04
+#define DCBX_APP_PRI_3              0x08
+#define DCBX_APP_PRI_4              0x10
+#define DCBX_APP_PRI_5              0x20
+#define DCBX_APP_PRI_6              0x40
+#define DCBX_APP_PRI_7              0x80
+#define DCBX_APP_SF_MASK            0x00000300
+#define DCBX_APP_SF_SHIFT           8
+#define DCBX_APP_SF_ETHTYPE         0
+#define DCBX_APP_SF_PORT            1
+#define DCBX_APP_PROTOCOL_ID_MASK   0xffff0000
+#define DCBX_APP_PROTOCOL_ID_SHIFT  16
+};
+
+/* FW structure in BE */
+struct dcbx_app_priority_feature {
+	u32 flags;
+#define DCBX_APP_ENABLED_MASK           0x00000001
+#define DCBX_APP_ENABLED_SHIFT          0
+#define DCBX_APP_WILLING_MASK           0x00000002
+#define DCBX_APP_WILLING_SHIFT          1
+#define DCBX_APP_ERROR_MASK             0x00000004
+#define DCBX_APP_ERROR_SHIFT            2
+/* Not in use
+ * #define DCBX_APP_DEFAULT_PRI_MASK       0x00000f00
+ * #define DCBX_APP_DEFAULT_PRI_SHIFT      8
+ */
+#define DCBX_APP_MAX_TCS_MASK           0x0000f000
+#define DCBX_APP_MAX_TCS_SHIFT          12
+#define DCBX_APP_NUM_ENTRIES_MASK       0x00ff0000
+#define DCBX_APP_NUM_ENTRIES_SHIFT      16
+	struct dcbx_app_priority_entry app_pri_tbl[DCBX_MAX_APP_PROTOCOL];
+};
+
+/* FW structure in BE */
+struct dcbx_features {
+	/* PG feature */
+	struct dcbx_ets_feature ets;
+
+	/* PFC feature */
+	u32			pfc;
+#define DCBX_PFC_PRI_EN_BITMAP_MASK             0x000000ff
+#define DCBX_PFC_PRI_EN_BITMAP_SHIFT            0
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_0            0x01
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_1            0x02
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_2            0x04
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_3            0x08
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_4            0x10
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_5            0x20
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_6            0x40
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_7            0x80
+
+#define DCBX_PFC_FLAGS_MASK                     0x0000ff00
+#define DCBX_PFC_FLAGS_SHIFT                    8
+#define DCBX_PFC_CAPS_MASK                      0x00000f00
+#define DCBX_PFC_CAPS_SHIFT                     8
+#define DCBX_PFC_MBC_MASK                       0x00004000
+#define DCBX_PFC_MBC_SHIFT                      14
+#define DCBX_PFC_WILLING_MASK                   0x00008000
+#define DCBX_PFC_WILLING_SHIFT                  15
+#define DCBX_PFC_ENABLED_MASK                   0x00010000
+#define DCBX_PFC_ENABLED_SHIFT                  16
+#define DCBX_PFC_ERROR_MASK                     0x00020000
+#define DCBX_PFC_ERROR_SHIFT                    17
+
+	/* APP feature */
+	struct dcbx_app_priority_feature app;
+};
+
+struct dcbx_local_params {
+	u32 config;
+#define DCBX_CONFIG_VERSION_MASK            0x00000003
+#define DCBX_CONFIG_VERSION_SHIFT           0
+#define DCBX_CONFIG_VERSION_DISABLED        0
+#define DCBX_CONFIG_VERSION_IEEE            1
+#define DCBX_CONFIG_VERSION_CEE             2
+
+	u32			flags;
+	struct dcbx_features	features;
+};
+
+struct dcbx_mib {
+	u32	prefix_seq_num;
+	u32	flags;
+	struct dcbx_features	features;
+	u32			suffix_seq_num;
+};
+
+struct lldp_system_tlvs_buffer_s {
+	u16	valid;
+	u16	length;
+	u32	data[MAX_SYSTEM_LLDP_TLV_DATA];
+};
+
+/**************************************/
+/*                                    */
+/*     P U B L I C      G L O B A L   */
+/*                                    */
+/**************************************/
+struct public_global {
+	u32				max_path;
+#define MAX_PATH_BIG_BEAR       2
+#define MAX_PATH_K2             1
+	u32				max_ports;
+#define MODE_1P 1
+#define MODE_2P 2
+#define MODE_3P 3
+#define MODE_4P 4
+	u32				debug_mb_offset;
+	u32				phymod_dbg_mb_offset;
+	struct couple_mode_teaming	cmt;
+	s32				internal_temperature;
+	u32				mfw_ver;
+	u32				running_bundle_id;
+};
+
+/**************************************/
+/*                                    */
+/*     P U B L I C      P A T H       */
+/*                                    */
+/**************************************/
+
+/****************************************************************************
+* Shared Memory 2 Region                                                   *
+****************************************************************************/
+/* The fw_flr_ack is actually built in the following way:                   */
+/* 8 bit:  PF ack                                                           */
+/* 128 bit: VF ack                                                           */
+/* 8 bit:  ios_dis_ack                                                      */
+/* In order to maintain endianity in the mailbox hsi, we want to keep using */
+/* u32. The fw must have the VF right after the PF since this is how it     */
+/* access arrays(it expects always the VF to reside after the PF, and that  */
+/* makes the calculation much easier for it. )                              */
+/* In order to answer both limitations, and keep the struct small, the code */
+/* will abuse the structure defined here to achieve the actual partition    */
+/* above                                                                    */
+/****************************************************************************/
+struct fw_flr_mb {
+	u32	aggint;
+	u32	opgen_addr;
+	u32	accum_ack;  /* 0..15:PF, 16..207:VF, 256..271:IOV_DIS */
+#define ACCUM_ACK_PF_BASE       0
+#define ACCUM_ACK_PF_SHIFT      0
+
+#define ACCUM_ACK_VF_BASE       8
+#define ACCUM_ACK_VF_SHIFT      3
+
+#define ACCUM_ACK_IOV_DIS_BASE  256
+#define ACCUM_ACK_IOV_DIS_SHIFT 8
+};
+
+struct public_path {
+	struct fw_flr_mb	flr_mb;
+	u32			mcp_vf_disabled[VF_MAX_STATIC / 32];
+
+	u32			process_kill;
+#define PROCESS_KILL_COUNTER_MASK               0x0000ffff
+#define PROCESS_KILL_COUNTER_SHIFT              0
+#define PROCESS_KILL_GLOB_AEU_BIT_MASK          0xffff0000
+#define PROCESS_KILL_GLOB_AEU_BIT_SHIFT         16
+#define GLOBAL_AEU_BIT(aeu_reg_id, aeu_bit) (aeu_reg_id * 32 + aeu_bit)
+};
+
+/**************************************/
+/*                                    */
+/*     P U B L I C      P O R T       */
+/*                                    */
+/**************************************/
+
+/****************************************************************************
+* Driver <-> FW Mailbox                                                    *
+****************************************************************************/
+
+struct public_port {
+	u32 validity_map;   /* 0x0 (4*2 = 0x8) */
+
+	/* validity bits */
+#define MCP_VALIDITY_PCI_CFG                    0x00100000
+#define MCP_VALIDITY_MB                         0x00200000
+#define MCP_VALIDITY_DEV_INFO                   0x00400000
+#define MCP_VALIDITY_RESERVED                   0x00000007
+
+	/* One licensing bit should be set */
+#define MCP_VALIDITY_LIC_KEY_IN_EFFECT_MASK     0x00000038
+#define MCP_VALIDITY_LIC_MANUF_KEY_IN_EFFECT    0x00000008
+#define MCP_VALIDITY_LIC_UPGRADE_KEY_IN_EFFECT  0x00000010
+#define MCP_VALIDITY_LIC_NO_KEY_IN_EFFECT       0x00000020
+
+	/* Active MFW */
+#define MCP_VALIDITY_ACTIVE_MFW_UNKNOWN         0x00000000
+#define MCP_VALIDITY_ACTIVE_MFW_MASK            0x000001c0
+#define MCP_VALIDITY_ACTIVE_MFW_NCSI            0x00000040
+#define MCP_VALIDITY_ACTIVE_MFW_NONE            0x000001c0
+
+	u32 link_status;
+#define LINK_STATUS_LINK_UP \
+	0x00000001
+#define LINK_STATUS_SPEED_AND_DUPLEX_MASK                       0x0000001e
+#define LINK_STATUS_SPEED_AND_DUPLEX_1000THD		BIT(1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_1000TFD            (2 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_10G                        (3 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_20G                        (4 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_40G                        (5 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_50G                        (6 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_100G                       (7 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_25G                        (8 << 1)
+
+#define LINK_STATUS_AUTO_NEGOTIATE_ENABLED                      0x00000020
+
+#define LINK_STATUS_AUTO_NEGOTIATE_COMPLETE                     0x00000040
+#define LINK_STATUS_PARALLEL_DETECTION_USED                     0x00000080
+
+#define LINK_STATUS_PFC_ENABLED	\
+	0x00000100
+#define LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE        0x00000200
+#define LINK_STATUS_LINK_PARTNER_1000THD_CAPABLE        0x00000400
+#define LINK_STATUS_LINK_PARTNER_10G_CAPABLE            0x00000800
+#define LINK_STATUS_LINK_PARTNER_20G_CAPABLE            0x00001000
+#define LINK_STATUS_LINK_PARTNER_40G_CAPABLE            0x00002000
+#define LINK_STATUS_LINK_PARTNER_50G_CAPABLE            0x00004000
+#define LINK_STATUS_LINK_PARTNER_100G_CAPABLE           0x00008000
+#define LINK_STATUS_LINK_PARTNER_25G_CAPABLE            0x00010000
+
+#define LINK_STATUS_LINK_PARTNER_FLOW_CONTROL_MASK      0x000C0000
+#define LINK_STATUS_LINK_PARTNER_NOT_PAUSE_CAPABLE      (0 << 18)
+#define LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE	BIT(18)
+#define LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE       (2 << 18)
+#define LINK_STATUS_LINK_PARTNER_BOTH_PAUSE                     (3 << 18)
+
+#define LINK_STATUS_SFP_TX_FAULT \
+	0x00100000
+#define LINK_STATUS_TX_FLOW_CONTROL_ENABLED                     0x00200000
+#define LINK_STATUS_RX_FLOW_CONTROL_ENABLED                     0x00400000
+
+	u32			link_status1;
+	u32			ext_phy_fw_version;
+	u32			drv_phy_cfg_addr;
+
+	u32			port_stx;
+
+	u32			stat_nig_timer;
+
+	struct port_mf_cfg	port_mf_config;
+	struct port_stats	stats;
+
+	u32			media_type;
+#define MEDIA_UNSPECIFIED       0x0
+#define MEDIA_SFPP_10G_FIBER    0x1
+#define MEDIA_XFP_FIBER         0x2
+#define MEDIA_DA_TWINAX         0x3
+#define MEDIA_BASE_T            0x4
+#define MEDIA_SFP_1G_FIBER      0x5
+#define MEDIA_KR                0xf0
+#define MEDIA_NOT_PRESENT       0xff
+
+	u32 lfa_status;
+#define LFA_LINK_FLAP_REASON_OFFSET             0
+#define LFA_LINK_FLAP_REASON_MASK               0x000000ff
+#define LFA_NO_REASON                                   (0 << 0)
+#define LFA_LINK_DOWN					BIT(0)
+#define LFA_FORCE_INIT                                  BIT(1)
+#define LFA_LOOPBACK_MISMATCH                           BIT(2)
+#define LFA_SPEED_MISMATCH                              BIT(3)
+#define LFA_FLOW_CTRL_MISMATCH                          BIT(4)
+#define LFA_ADV_SPEED_MISMATCH                          BIT(5)
+#define LINK_FLAP_AVOIDANCE_COUNT_OFFSET        8
+#define LINK_FLAP_AVOIDANCE_COUNT_MASK          0x0000ff00
+#define LINK_FLAP_COUNT_OFFSET                  16
+#define LINK_FLAP_COUNT_MASK                    0x00ff0000
+
+	u32					link_change_count;
+
+	/* LLDP params */
+	struct lldp_config_params_s		lldp_config_params[
+		LLDP_MAX_LLDP_AGENTS];
+	struct lldp_status_params_s		lldp_status_params[
+		LLDP_MAX_LLDP_AGENTS];
+	struct lldp_system_tlvs_buffer_s	system_lldp_tlvs_buf;
+
+	/* DCBX related MIB */
+	struct dcbx_local_params		local_admin_dcbx_mib;
+	struct dcbx_mib				remote_dcbx_mib;
+	struct dcbx_mib				operational_dcbx_mib;
+};
+
+/**************************************/
+/*                                    */
+/*     P U B L I C      F U N C       */
+/*                                    */
+/**************************************/
+
+struct public_func {
+	u32	iscsi_boot_signature;
+	u32	iscsi_boot_block_offset;
+
+	u32	reserved[8];
+
+	u32	config;
+
+	/* E/R/I/D */
+	/* function 0 of each port cannot be hidden */
+#define FUNC_MF_CFG_FUNC_HIDE                   0x00000001
+#define FUNC_MF_CFG_PAUSE_ON_HOST_RING          0x00000002
+#define FUNC_MF_CFG_PAUSE_ON_HOST_RING_SHIFT    0x00000001
+
+#define FUNC_MF_CFG_PROTOCOL_MASK               0x000000f0
+#define FUNC_MF_CFG_PROTOCOL_SHIFT              4
+#define FUNC_MF_CFG_PROTOCOL_ETHERNET           0x00000000
+#define FUNC_MF_CFG_PROTOCOL_ISCSI              0x00000010
+#define FUNC_MF_CFG_PROTOCOL_FCOE               0x00000020
+#define FUNC_MF_CFG_PROTOCOL_ROCE               0x00000030
+#define FUNC_MF_CFG_PROTOCOL_MAX                0x00000030
+
+	/* MINBW, MAXBW */
+	/* value range - 0..100, increments in 1 %  */
+#define FUNC_MF_CFG_MIN_BW_MASK                 0x0000ff00
+#define FUNC_MF_CFG_MIN_BW_SHIFT                8
+#define FUNC_MF_CFG_MIN_BW_DEFAULT              0x00000000
+#define FUNC_MF_CFG_MAX_BW_MASK                 0x00ff0000
+#define FUNC_MF_CFG_MAX_BW_SHIFT                16
+#define FUNC_MF_CFG_MAX_BW_DEFAULT              0x00640000
+
+	u32	status;
+#define FUNC_STATUS_VLINK_DOWN                  0x00000001
+
+	u32	mac_upper;  /* MAC */
+#define FUNC_MF_CFG_UPPERMAC_MASK               0x0000ffff
+#define FUNC_MF_CFG_UPPERMAC_SHIFT              0
+#define FUNC_MF_CFG_UPPERMAC_DEFAULT            FUNC_MF_CFG_UPPERMAC_MASK
+	u32	mac_lower;
+#define FUNC_MF_CFG_LOWERMAC_DEFAULT            0xffffffff
+
+	u32	fcoe_wwn_port_name_upper;
+	u32	fcoe_wwn_port_name_lower;
+
+	u32	fcoe_wwn_node_name_upper;
+	u32	fcoe_wwn_node_name_lower;
+
+	u32	ovlan_stag; /* tags */
+#define FUNC_MF_CFG_OV_STAG_MASK              0x0000ffff
+#define FUNC_MF_CFG_OV_STAG_SHIFT             0
+#define FUNC_MF_CFG_OV_STAG_DEFAULT           FUNC_MF_CFG_OV_STAG_MASK
+
+	u32	pf_allocation;  /* vf per pf */
+
+	u32	preserve_data;  /* Will be used bt CCM */
+
+	u32	driver_last_activity_ts;
+
+	u32	drv_ack_vf_disabled[VF_MAX_STATIC / 32]; /* 0x0044 */
+
+	u32	drv_id;
+#define DRV_ID_PDA_COMP_VER_MASK        0x0000ffff
+#define DRV_ID_PDA_COMP_VER_SHIFT       0
+
+#define DRV_ID_MCP_HSI_VER_MASK         0x00ff0000
+#define DRV_ID_MCP_HSI_VER_SHIFT        16
+#define DRV_ID_MCP_HSI_VER_CURRENT	BIT(DRV_ID_MCP_HSI_VER_SHIFT)
+
+#define DRV_ID_DRV_TYPE_MASK            0xff000000
+#define DRV_ID_DRV_TYPE_SHIFT           24
+#define DRV_ID_DRV_TYPE_UNKNOWN         (0 << DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_LINUX		BIT(DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_WINDOWS         (2 << DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_DIAG            (3 << DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_PREBOOT         (4 << DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_SOLARIS         (5 << DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_VMWARE          (6 << DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_FREEBSD         (7 << DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_AIX             (8 << DRV_ID_DRV_TYPE_SHIFT)
+};
+
+/**************************************/
+/*                                    */
+/*     P U B L I C       M B          */
+/*                                    */
+/**************************************/
+/* This is the only section that the driver can write to, and each */
+/* Basically each driver request to set feature parameters,
+ * will be done using a different command, which will be linked
+ * to a specific data structure from the union below.
+ * For huge strucuture, the common blank structure should be used.
+ */
+
+struct mcp_mac {
+	u32	mac_upper;  /* Upper 16 bits are always zeroes */
+	u32	mac_lower;
+};
+
+struct mcp_val64 {
+	u32	lo;
+	u32	hi;
+};
+
+struct mcp_file_att {
+	u32	nvm_start_addr;
+	u32	len;
+};
+
+#define MCP_DRV_VER_STR_SIZE 16
+#define MCP_DRV_VER_STR_SIZE_DWORD (MCP_DRV_VER_STR_SIZE / sizeof(u32))
+#define MCP_DRV_NVM_BUF_LEN 32
+struct drv_version_stc {
+	u32	version;
+	u8	name[MCP_DRV_VER_STR_SIZE - 4];
+};
+
+union drv_union_data {
+	u32			ver_str[MCP_DRV_VER_STR_SIZE_DWORD];
+	struct mcp_mac		wol_mac;
+
+	struct pmm_phy_cfg	drv_phy_cfg;
+
+	struct mcp_val64	val64; /* For PHY / AVS commands */
+
+	u8			raw_data[MCP_DRV_NVM_BUF_LEN];
+
+	struct mcp_file_att	file_att;
+
+	u32			ack_vf_disabled[VF_MAX_STATIC / 32];
+
+	struct drv_version_stc	drv_version;
+
+	/* ... */
+};
+
+struct public_drv_mb {
+	u32 drv_mb_header;
+#define DRV_MSG_CODE_MASK                       0xffff0000
+#define DRV_MSG_CODE_LOAD_REQ                   0x10000000
+#define DRV_MSG_CODE_LOAD_DONE                  0x11000000
+#define DRV_MSG_CODE_UNLOAD_REQ                 0x20000000
+#define DRV_MSG_CODE_UNLOAD_DONE                0x21000000
+#define DRV_MSG_CODE_INIT_PHY                   0x22000000
+	/* Params - FORCE - Reinitialize the link regardless of LFA */
+	/*        - DONT_CARE - Don't flap the link if up */
+#define DRV_MSG_CODE_LINK_RESET                 0x23000000
+
+#define DRV_MSG_CODE_SET_LLDP                   0x24000000
+#define DRV_MSG_CODE_SET_DCBX                   0x25000000
+
+#define DRV_MSG_CODE_NIG_DRAIN                  0x30000000
+
+#define DRV_MSG_CODE_INITIATE_FLR               0x02000000
+#define DRV_MSG_CODE_VF_DISABLED_DONE           0xc0000000
+#define DRV_MSG_CODE_CFG_VF_MSIX                0xc0010000
+#define DRV_MSG_CODE_NVM_PUT_FILE_BEGIN         0x00010000
+#define DRV_MSG_CODE_NVM_PUT_FILE_DATA          0x00020000
+#define DRV_MSG_CODE_NVM_GET_FILE_ATT           0x00030000
+#define DRV_MSG_CODE_NVM_READ_NVRAM             0x00050000
+#define DRV_MSG_CODE_NVM_WRITE_NVRAM            0x00060000
+#define DRV_MSG_CODE_NVM_DEL_FILE               0x00080000
+#define DRV_MSG_CODE_MCP_RESET                  0x00090000
+#define DRV_MSG_CODE_SET_SECURE_MODE            0x000a0000
+#define DRV_MSG_CODE_PHY_RAW_READ               0x000b0000
+#define DRV_MSG_CODE_PHY_RAW_WRITE              0x000c0000
+#define DRV_MSG_CODE_PHY_CORE_READ              0x000d0000
+#define DRV_MSG_CODE_PHY_CORE_WRITE             0x000e0000
+#define DRV_MSG_CODE_SET_VERSION                0x000f0000
+
+#define DRV_MSG_SEQ_NUMBER_MASK                 0x0000ffff
+
+	u32 drv_mb_param;
+
+	/* UNLOAD_REQ params */
+#define DRV_MB_PARAM_UNLOAD_WOL_UNKNOWN         0x00000000
+#define DRV_MB_PARAM_UNLOAD_WOL_MCP             0x00000001
+#define DRV_MB_PARAM_UNLOAD_WOL_DISABLED        0x00000002
+#define DRV_MB_PARAM_UNLOAD_WOL_ENABLED         0x00000003
+
+	/* UNLOAD_DONE_params */
+#define DRV_MB_PARAM_UNLOAD_NON_D3_POWER        0x00000001
+
+	/* INIT_PHY params */
+#define DRV_MB_PARAM_INIT_PHY_FORCE             0x00000001
+#define DRV_MB_PARAM_INIT_PHY_DONT_CARE         0x00000002
+
+	/* LLDP / DCBX params*/
+#define DRV_MB_PARAM_LLDP_SEND_MASK             0x00000001
+#define DRV_MB_PARAM_LLDP_SEND_SHIFT            0
+#define DRV_MB_PARAM_LLDP_AGENT_MASK            0x00000006
+#define DRV_MB_PARAM_LLDP_AGENT_SHIFT           1
+#define DRV_MB_PARAM_DCBX_NOTIFY_MASK           0x00000008
+#define DRV_MB_PARAM_DCBX_NOTIFY_SHIFT          3
+
+#define DRV_MB_PARAM_NIG_DRAIN_PERIOD_MS_MASK   0x000000FF
+#define DRV_MB_PARAM_NIG_DRAIN_PERIOD_MS_SHIFT  0
+
+#define DRV_MB_PARAM_NVM_PUT_FILE_BEGIN_MFW     0x1
+#define DRV_MB_PARAM_NVM_PUT_FILE_BEGIN_IMAGE   0x2
+
+#define DRV_MB_PARAM_NVM_OFFSET_SHIFT           0
+#define DRV_MB_PARAM_NVM_OFFSET_MASK            0x00FFFFFF
+#define DRV_MB_PARAM_NVM_LEN_SHIFT              24
+#define DRV_MB_PARAM_NVM_LEN_MASK               0xFF000000
+
+#define DRV_MB_PARAM_PHY_ADDR_SHIFT             0
+#define DRV_MB_PARAM_PHY_ADDR_MASK              0x1FF0FFFF
+#define DRV_MB_PARAM_PHY_LANE_SHIFT             16
+#define DRV_MB_PARAM_PHY_LANE_MASK              0x000F0000
+#define DRV_MB_PARAM_PHY_SELECT_PORT_SHIFT      29
+#define DRV_MB_PARAM_PHY_SELECT_PORT_MASK       0x20000000
+#define DRV_MB_PARAM_PHY_PORT_SHIFT             30
+#define DRV_MB_PARAM_PHY_PORT_MASK              0xc0000000
+
+/* configure vf MSIX params*/
+#define DRV_MB_PARAM_CFG_VF_MSIX_VF_ID_SHIFT    0
+#define DRV_MB_PARAM_CFG_VF_MSIX_VF_ID_MASK     0x000000FF
+#define DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_SHIFT   8
+#define DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_MASK    0x0000FF00
+
+	u32 fw_mb_header;
+#define FW_MSG_CODE_MASK                        0xffff0000
+#define FW_MSG_CODE_DRV_LOAD_ENGINE             0x10100000
+#define FW_MSG_CODE_DRV_LOAD_PORT               0x10110000
+#define FW_MSG_CODE_DRV_LOAD_FUNCTION           0x10120000
+#define FW_MSG_CODE_DRV_LOAD_REFUSED_PDA        0x10200000
+#define FW_MSG_CODE_DRV_LOAD_REFUSED_HSI        0x10210000
+#define FW_MSG_CODE_DRV_LOAD_REFUSED_DIAG       0x10220000
+#define FW_MSG_CODE_DRV_LOAD_DONE               0x11100000
+#define FW_MSG_CODE_DRV_UNLOAD_ENGINE           0x20110000
+#define FW_MSG_CODE_DRV_UNLOAD_PORT             0x20120000
+#define FW_MSG_CODE_DRV_UNLOAD_FUNCTION         0x20130000
+#define FW_MSG_CODE_DRV_UNLOAD_DONE             0x21100000
+#define FW_MSG_CODE_INIT_PHY_DONE               0x21200000
+#define FW_MSG_CODE_INIT_PHY_ERR_INVALID_ARGS   0x21300000
+#define FW_MSG_CODE_LINK_RESET_DONE             0x23000000
+#define FW_MSG_CODE_SET_LLDP_DONE               0x24000000
+#define FW_MSG_CODE_SET_LLDP_UNSUPPORTED_AGENT  0x24010000
+#define FW_MSG_CODE_SET_DCBX_DONE               0x25000000
+#define FW_MSG_CODE_NIG_DRAIN_DONE              0x30000000
+#define FW_MSG_CODE_VF_DISABLED_DONE            0xb0000000
+#define FW_MSG_CODE_DRV_CFG_VF_MSIX_DONE        0xb0010000
+#define FW_MSG_CODE_FLR_ACK                     0x02000000
+#define FW_MSG_CODE_FLR_NACK                    0x02100000
+
+#define FW_MSG_CODE_NVM_OK                      0x00010000
+#define FW_MSG_CODE_NVM_INVALID_MODE            0x00020000
+#define FW_MSG_CODE_NVM_PREV_CMD_WAS_NOT_FINISHED       0x00030000
+#define FW_MSG_CODE_NVM_FAILED_TO_ALLOCATE_PAGE 0x00040000
+#define FW_MSG_CODE_NVM_INVALID_DIR_FOUND       0x00050000
+#define FW_MSG_CODE_NVM_PAGE_NOT_FOUND          0x00060000
+#define FW_MSG_CODE_NVM_FAILED_PARSING_BNDLE_HEADER 0x00070000
+#define FW_MSG_CODE_NVM_FAILED_PARSING_IMAGE_HEADER 0x00080000
+#define FW_MSG_CODE_NVM_PARSING_OUT_OF_SYNC     0x00090000
+#define FW_MSG_CODE_NVM_FAILED_UPDATING_DIR     0x000a0000
+#define FW_MSG_CODE_NVM_FAILED_TO_FREE_PAGE     0x000b0000
+#define FW_MSG_CODE_NVM_FILE_NOT_FOUND          0x000c0000
+#define FW_MSG_CODE_NVM_OPERATION_FAILED        0x000d0000
+#define FW_MSG_CODE_NVM_FAILED_UNALIGNED        0x000e0000
+#define FW_MSG_CODE_NVM_BAD_OFFSET              0x000f0000
+#define FW_MSG_CODE_NVM_BAD_SIGNATURE           0x00100000
+#define FW_MSG_CODE_NVM_FILE_READ_ONLY          0x00200000
+#define FW_MSG_CODE_NVM_UNKNOWN_FILE            0x00300000
+#define FW_MSG_CODE_NVM_PUT_FILE_FINISH_OK      0x00400000
+#define FW_MSG_CODE_MCP_RESET_REJECT            0x00600000
+#define FW_MSG_CODE_PHY_OK                      0x00110000
+#define FW_MSG_CODE_PHY_ERROR                   0x00120000
+#define FW_MSG_CODE_SET_SECURE_MODE_ERROR       0x00130000
+#define FW_MSG_CODE_SET_SECURE_MODE_OK          0x00140000
+#define FW_MSG_MODE_PHY_PRIVILEGE_ERROR         0x00150000
+
+#define FW_MSG_SEQ_NUMBER_MASK                  0x0000ffff
+
+	u32	fw_mb_param;
+
+	u32	drv_pulse_mb;
+#define DRV_PULSE_SEQ_MASK                      0x00007fff
+#define DRV_PULSE_SYSTEM_TIME_MASK              0xffff0000
+#define DRV_PULSE_ALWAYS_ALIVE                  0x00008000
+	u32 mcp_pulse_mb;
+#define MCP_PULSE_SEQ_MASK                      0x00007fff
+#define MCP_PULSE_ALWAYS_ALIVE                  0x00008000
+#define MCP_EVENT_MASK                          0xffff0000
+#define MCP_EVENT_OTHER_DRIVER_RESET_REQ        0x00010000
+
+	union drv_union_data union_data;
+};
+
+/* MFW - DRV MB */
+/**********************************************************************
+* Description
+*   Incremental Aggregative
+*   8-bit MFW counter per message
+*   8-bit ack-counter per message
+* Capabilities
+*   Provides up to 256 aggregative message per type
+*   Provides 4 message types in dword
+*   Message type pointers to byte offset
+*   Backward Compatibility by using sizeof for the counters.
+*   No lock requires for 32bit messages
+* Limitations:
+* In case of messages greater than 32bit, a dedicated mechanism(e.g lock)
+* is required to prevent data corruption.
+**********************************************************************/
+enum MFW_DRV_MSG_TYPE {
+	MFW_DRV_MSG_LINK_CHANGE,
+	MFW_DRV_MSG_FLR_FW_ACK_FAILED,
+	MFW_DRV_MSG_VF_DISABLED,
+	MFW_DRV_MSG_LLDP_DATA_UPDATED,
+	MFW_DRV_MSG_DCBX_REMOTE_MIB_UPDATED,
+	MFW_DRV_MSG_DCBX_OPERATIONAL_MIB_UPDATED,
+	MFW_DRV_MSG_ERROR_RECOVERY,
+	MFW_DRV_MSG_MAX
+};
+
+#define MFW_DRV_MSG_MAX_DWORDS(msgs)    (((msgs - 1) >> 2) + 1)
+#define MFW_DRV_MSG_DWORD(msg_id)       (msg_id >> 2)
+#define MFW_DRV_MSG_OFFSET(msg_id)      ((msg_id & 0x3) << 3)
+#define MFW_DRV_MSG_MASK(msg_id)        (0xff << MFW_DRV_MSG_OFFSET(msg_id))
+
+struct public_mfw_mb {
+	u32	sup_msgs;
+	u32	msg[MFW_DRV_MSG_MAX_DWORDS(MFW_DRV_MSG_MAX)];
+	u32	ack[MFW_DRV_MSG_MAX_DWORDS(MFW_DRV_MSG_MAX)];
+};
+
+/**************************************/
+/*                                    */
+/*     P U B L I C       D A T A      */
+/*                                    */
+/**************************************/
+enum public_sections {
+	PUBLIC_DRV_MB,          /* Points to the first drv_mb of path0 */
+	PUBLIC_MFW_MB,          /* Points to the first mfw_mb of path0 */
+	PUBLIC_GLOBAL,
+	PUBLIC_PATH,
+	PUBLIC_PORT,
+	PUBLIC_FUNC,
+	PUBLIC_MAX_SECTIONS
+};
+
+struct drv_ver_info_stc {
+	u32	ver;
+	u8	name[32];
+};
+
+struct mcp_public_data {
+	/* The sections fields is an array */
+	u32			num_sections;
+	offsize_t		sections[PUBLIC_MAX_SECTIONS];
+	struct public_drv_mb	drv_mb[MCP_GLOB_FUNC_MAX];
+	struct public_mfw_mb	mfw_mb[MCP_GLOB_FUNC_MAX];
+	struct public_global	global;
+	struct public_path	path[MCP_GLOB_PATH_MAX];
+	struct public_port	port[MCP_GLOB_PORT_MAX];
+	struct public_func	func[MCP_GLOB_FUNC_MAX];
+	struct drv_ver_info_stc drv_info;
+};
+
+/****************************************************************************
+* Copyright(c) 2015 Qlogic Corporation, all rights reserved
+* Proprietary and Confidential Information.
+*
+* This source file is the property of Qlogic Corporation, and
+* may not be copied or distributed in any isomorphic form without
+* the prior written consent of Qlogic Corporation.
+*
+* Name:        nvm_cfg.h
+*
+* Description: NVM config file - Generated file from nvm cfg excel.
+*              DO NOT MODIFY !!!
+*
+* Created:     6/18/2015
+*
+****************************************************************************/
+
+struct nvm_cfg_mac_address {
+	u32	mac_addr_hi;
+#define NVM_CFG_MAC_ADDRESS_HI_MASK                             0x0000FFFF
+#define NVM_CFG_MAC_ADDRESS_HI_OFFSET                           0
+
+	u32	mac_addr_lo;
+};
+
+/******************************************
+* nvm_cfg1 structs
+******************************************/
+
+struct nvm_cfg1_glob {
+	u32 generic_cont0;					/* 0x0 */
+#define NVM_CFG1_GLOB_BOARD_SWAP_MASK                           0x0000000F
+#define NVM_CFG1_GLOB_BOARD_SWAP_OFFSET                         0
+#define NVM_CFG1_GLOB_BOARD_SWAP_NONE                           0x0
+#define NVM_CFG1_GLOB_BOARD_SWAP_PATH                           0x1
+#define NVM_CFG1_GLOB_BOARD_SWAP_PORT                           0x2
+#define NVM_CFG1_GLOB_BOARD_SWAP_BOTH                           0x3
+#define NVM_CFG1_GLOB_MF_MODE_MASK                              0x00000FF0
+#define NVM_CFG1_GLOB_MF_MODE_OFFSET                            4
+#define NVM_CFG1_GLOB_MF_MODE_MF_ALLOWED                        0x0
+#define NVM_CFG1_GLOB_MF_MODE_FORCED_SF                         0x1
+#define NVM_CFG1_GLOB_MF_MODE_SPIO4                             0x2
+#define NVM_CFG1_GLOB_MF_MODE_NPAR1_0                           0x3
+#define NVM_CFG1_GLOB_MF_MODE_NPAR1_5                           0x4
+#define NVM_CFG1_GLOB_MF_MODE_NPAR2_0                           0x5
+#define NVM_CFG1_GLOB_MF_MODE_BD                                0x6
+#define NVM_CFG1_GLOB_MF_MODE_UFP                               0x7
+#define NVM_CFG1_GLOB_FAN_FAILURE_ENFORCEMENT_MASK              0x00001000
+#define NVM_CFG1_GLOB_FAN_FAILURE_ENFORCEMENT_OFFSET            12
+#define NVM_CFG1_GLOB_FAN_FAILURE_ENFORCEMENT_DISABLED          0x0
+#define NVM_CFG1_GLOB_FAN_FAILURE_ENFORCEMENT_ENABLED           0x1
+#define NVM_CFG1_GLOB_AVS_MARGIN_LOW_MASK                       0x001FE000
+#define NVM_CFG1_GLOB_AVS_MARGIN_LOW_OFFSET                     13
+#define NVM_CFG1_GLOB_AVS_MARGIN_HIGH_MASK                      0x1FE00000
+#define NVM_CFG1_GLOB_AVS_MARGIN_HIGH_OFFSET                    21
+#define NVM_CFG1_GLOB_ENABLE_SRIOV_MASK                         0x20000000
+#define NVM_CFG1_GLOB_ENABLE_SRIOV_OFFSET                       29
+#define NVM_CFG1_GLOB_ENABLE_SRIOV_DISABLED                     0x0
+#define NVM_CFG1_GLOB_ENABLE_SRIOV_ENABLED                      0x1
+#define NVM_CFG1_GLOB_ENABLE_ATC_MASK                           0x40000000
+#define NVM_CFG1_GLOB_ENABLE_ATC_OFFSET                         30
+#define NVM_CFG1_GLOB_ENABLE_ATC_DISABLED                       0x0
+#define NVM_CFG1_GLOB_ENABLE_ATC_ENABLED                        0x1
+#define NVM_CFG1_GLOB_CLOCK_SLOWDOWN_MASK                       0x80000000
+#define NVM_CFG1_GLOB_CLOCK_SLOWDOWN_OFFSET                     31
+#define NVM_CFG1_GLOB_CLOCK_SLOWDOWN_DISABLED                   0x0
+#define NVM_CFG1_GLOB_CLOCK_SLOWDOWN_ENABLED                    0x1
+
+	u32	engineering_change[3];				/* 0x4 */
+
+	u32	manufacturing_id;				/* 0x10 */
+
+	u32	serial_number[4];				/* 0x14 */
+
+	u32	pcie_cfg;					/* 0x24 */
+#define NVM_CFG1_GLOB_PCI_GEN_MASK                              0x00000003
+#define NVM_CFG1_GLOB_PCI_GEN_OFFSET                            0
+#define NVM_CFG1_GLOB_PCI_GEN_PCI_GEN1                          0x0
+#define NVM_CFG1_GLOB_PCI_GEN_PCI_GEN2                          0x1
+#define NVM_CFG1_GLOB_PCI_GEN_PCI_GEN3                          0x2
+#define NVM_CFG1_GLOB_BEACON_WOL_ENABLED_MASK                   0x00000004
+#define NVM_CFG1_GLOB_BEACON_WOL_ENABLED_OFFSET                 2
+#define NVM_CFG1_GLOB_BEACON_WOL_ENABLED_DISABLED               0x0
+#define NVM_CFG1_GLOB_BEACON_WOL_ENABLED_ENABLED                0x1
+#define NVM_CFG1_GLOB_ASPM_SUPPORT_MASK                         0x00000018
+#define NVM_CFG1_GLOB_ASPM_SUPPORT_OFFSET                       3
+#define NVM_CFG1_GLOB_ASPM_SUPPORT_L0S_L1_ENABLED               0x0
+#define NVM_CFG1_GLOB_ASPM_SUPPORT_L0S_DISABLED                 0x1
+#define NVM_CFG1_GLOB_ASPM_SUPPORT_L1_DISABLED                  0x2
+#define NVM_CFG1_GLOB_ASPM_SUPPORT_L0S_L1_DISABLED              0x3
+#define NVM_CFG1_GLOB_PREVENT_PCIE_L1_MENTRY_MASK               0x00000020
+#define NVM_CFG1_GLOB_PREVENT_PCIE_L1_MENTRY_OFFSET             5
+#define NVM_CFG1_GLOB_PREVENT_PCIE_L1_MENTRY_DISABLED           0x0
+#define NVM_CFG1_GLOB_PREVENT_PCIE_L1_MENTRY_ENABLED            0x1
+#define NVM_CFG1_GLOB_PCIE_G2_TX_AMPLITUDE_MASK                 0x000003C0
+#define NVM_CFG1_GLOB_PCIE_G2_TX_AMPLITUDE_OFFSET               6
+#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_MASK                     0x00001C00
+#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_OFFSET                   10
+#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_HW                       0x0
+#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_0DB                      0x1
+#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_3_5DB                    0x2
+#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_6_0DB                    0x3
+#define NVM_CFG1_GLOB_WWN_NODE_PREFIX0_MASK                     0x001FE000
+#define NVM_CFG1_GLOB_WWN_NODE_PREFIX0_OFFSET                   13
+#define NVM_CFG1_GLOB_WWN_NODE_PREFIX1_MASK                     0x1FE00000
+#define NVM_CFG1_GLOB_WWN_NODE_PREFIX1_OFFSET                   21
+#define NVM_CFG1_GLOB_NCSI_PACKAGE_ID_MASK                      0x60000000
+#define NVM_CFG1_GLOB_NCSI_PACKAGE_ID_OFFSET                    29
+
+	u32 mgmt_traffic;                                       /* 0x28 */
+#define NVM_CFG1_GLOB_RESERVED60_MASK                           0x00000001
+#define NVM_CFG1_GLOB_RESERVED60_OFFSET                         0
+#define NVM_CFG1_GLOB_RESERVED60_100KHZ                         0x0
+#define NVM_CFG1_GLOB_RESERVED60_400KHZ                         0x1
+#define NVM_CFG1_GLOB_WWN_PORT_PREFIX0_MASK                     0x000001FE
+#define NVM_CFG1_GLOB_WWN_PORT_PREFIX0_OFFSET                   1
+#define NVM_CFG1_GLOB_WWN_PORT_PREFIX1_MASK                     0x0001FE00
+#define NVM_CFG1_GLOB_WWN_PORT_PREFIX1_OFFSET                   9
+#define NVM_CFG1_GLOB_SMBUS_ADDRESS_MASK                        0x01FE0000
+#define NVM_CFG1_GLOB_SMBUS_ADDRESS_OFFSET                      17
+#define NVM_CFG1_GLOB_SIDEBAND_MODE_MASK                        0x06000000
+#define NVM_CFG1_GLOB_SIDEBAND_MODE_OFFSET                      25
+#define NVM_CFG1_GLOB_SIDEBAND_MODE_DISABLED                    0x0
+#define NVM_CFG1_GLOB_SIDEBAND_MODE_RMII                        0x1
+#define NVM_CFG1_GLOB_SIDEBAND_MODE_SGMII                       0x2
+
+	u32 core_cfg;                                           /* 0x2C */
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_MASK                    0x000000FF
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_OFFSET                  0
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X40G                0x0
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X50G                0x1
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X100G               0x2
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X10G_F              0x3
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X10G_E              0x4
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X20G                0x5
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X40G                0xB
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X25G                0xC
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X25G                0xD
+#define NVM_CFG1_GLOB_EAGLE_ENFORCE_TX_FIR_CFG_MASK             0x00000100
+#define NVM_CFG1_GLOB_EAGLE_ENFORCE_TX_FIR_CFG_OFFSET           8
+#define NVM_CFG1_GLOB_EAGLE_ENFORCE_TX_FIR_CFG_DISABLED         0x0
+#define NVM_CFG1_GLOB_EAGLE_ENFORCE_TX_FIR_CFG_ENABLED          0x1
+#define NVM_CFG1_GLOB_FALCON_ENFORCE_TX_FIR_CFG_MASK            0x00000200
+#define NVM_CFG1_GLOB_FALCON_ENFORCE_TX_FIR_CFG_OFFSET          9
+#define NVM_CFG1_GLOB_FALCON_ENFORCE_TX_FIR_CFG_DISABLED        0x0
+#define NVM_CFG1_GLOB_FALCON_ENFORCE_TX_FIR_CFG_ENABLED         0x1
+#define NVM_CFG1_GLOB_EAGLE_CORE_ADDR_MASK                      0x0003FC00
+#define NVM_CFG1_GLOB_EAGLE_CORE_ADDR_OFFSET                    10
+#define NVM_CFG1_GLOB_FALCON_CORE_ADDR_MASK                     0x03FC0000
+#define NVM_CFG1_GLOB_FALCON_CORE_ADDR_OFFSET                   18
+#define NVM_CFG1_GLOB_AVS_MODE_MASK                             0x1C000000
+#define NVM_CFG1_GLOB_AVS_MODE_OFFSET                           26
+#define NVM_CFG1_GLOB_AVS_MODE_CLOSE_LOOP                       0x0
+#define NVM_CFG1_GLOB_AVS_MODE_OPEN_LOOP                        0x1
+#define NVM_CFG1_GLOB_AVS_MODE_DISABLED                         0x3
+#define NVM_CFG1_GLOB_OVERRIDE_SECURE_MODE_MASK                 0x60000000
+#define NVM_CFG1_GLOB_OVERRIDE_SECURE_MODE_OFFSET               29
+#define NVM_CFG1_GLOB_OVERRIDE_SECURE_MODE_DISABLED             0x0
+#define NVM_CFG1_GLOB_OVERRIDE_SECURE_MODE_ENABLED              0x1
+
+	u32 e_lane_cfg1;					/* 0x30 */
+#define NVM_CFG1_GLOB_RX_LANE0_SWAP_MASK                        0x0000000F
+#define NVM_CFG1_GLOB_RX_LANE0_SWAP_OFFSET                      0
+#define NVM_CFG1_GLOB_RX_LANE1_SWAP_MASK                        0x000000F0
+#define NVM_CFG1_GLOB_RX_LANE1_SWAP_OFFSET                      4
+#define NVM_CFG1_GLOB_RX_LANE2_SWAP_MASK                        0x00000F00
+#define NVM_CFG1_GLOB_RX_LANE2_SWAP_OFFSET                      8
+#define NVM_CFG1_GLOB_RX_LANE3_SWAP_MASK                        0x0000F000
+#define NVM_CFG1_GLOB_RX_LANE3_SWAP_OFFSET                      12
+#define NVM_CFG1_GLOB_TX_LANE0_SWAP_MASK                        0x000F0000
+#define NVM_CFG1_GLOB_TX_LANE0_SWAP_OFFSET                      16
+#define NVM_CFG1_GLOB_TX_LANE1_SWAP_MASK                        0x00F00000
+#define NVM_CFG1_GLOB_TX_LANE1_SWAP_OFFSET                      20
+#define NVM_CFG1_GLOB_TX_LANE2_SWAP_MASK                        0x0F000000
+#define NVM_CFG1_GLOB_TX_LANE2_SWAP_OFFSET                      24
+#define NVM_CFG1_GLOB_TX_LANE3_SWAP_MASK                        0xF0000000
+#define NVM_CFG1_GLOB_TX_LANE3_SWAP_OFFSET                      28
+
+	u32 e_lane_cfg2;					/* 0x34 */
+#define NVM_CFG1_GLOB_RX_LANE0_POL_FLIP_MASK                    0x00000001
+#define NVM_CFG1_GLOB_RX_LANE0_POL_FLIP_OFFSET                  0
+#define NVM_CFG1_GLOB_RX_LANE1_POL_FLIP_MASK                    0x00000002
+#define NVM_CFG1_GLOB_RX_LANE1_POL_FLIP_OFFSET                  1
+#define NVM_CFG1_GLOB_RX_LANE2_POL_FLIP_MASK                    0x00000004
+#define NVM_CFG1_GLOB_RX_LANE2_POL_FLIP_OFFSET                  2
+#define NVM_CFG1_GLOB_RX_LANE3_POL_FLIP_MASK                    0x00000008
+#define NVM_CFG1_GLOB_RX_LANE3_POL_FLIP_OFFSET                  3
+#define NVM_CFG1_GLOB_TX_LANE0_POL_FLIP_MASK                    0x00000010
+#define NVM_CFG1_GLOB_TX_LANE0_POL_FLIP_OFFSET                  4
+#define NVM_CFG1_GLOB_TX_LANE1_POL_FLIP_MASK                    0x00000020
+#define NVM_CFG1_GLOB_TX_LANE1_POL_FLIP_OFFSET                  5
+#define NVM_CFG1_GLOB_TX_LANE2_POL_FLIP_MASK                    0x00000040
+#define NVM_CFG1_GLOB_TX_LANE2_POL_FLIP_OFFSET                  6
+#define NVM_CFG1_GLOB_TX_LANE3_POL_FLIP_MASK                    0x00000080
+#define NVM_CFG1_GLOB_TX_LANE3_POL_FLIP_OFFSET                  7
+#define NVM_CFG1_GLOB_SMBUS_MODE_MASK                           0x00000F00
+#define NVM_CFG1_GLOB_SMBUS_MODE_OFFSET                         8
+#define NVM_CFG1_GLOB_SMBUS_MODE_DISABLED                       0x0
+#define NVM_CFG1_GLOB_SMBUS_MODE_100KHZ                         0x1
+#define NVM_CFG1_GLOB_SMBUS_MODE_400KHZ                         0x2
+#define NVM_CFG1_GLOB_NCSI_MASK                                 0x0000F000
+#define NVM_CFG1_GLOB_NCSI_OFFSET                               12
+#define NVM_CFG1_GLOB_NCSI_DISABLED                             0x0
+#define NVM_CFG1_GLOB_NCSI_ENABLED                              0x1
+
+	u32 f_lane_cfg1;					/* 0x38 */
+#define NVM_CFG1_GLOB_RX_LANE0_SWAP_MASK                        0x0000000F
+#define NVM_CFG1_GLOB_RX_LANE0_SWAP_OFFSET                      0
+#define NVM_CFG1_GLOB_RX_LANE1_SWAP_MASK                        0x000000F0
+#define NVM_CFG1_GLOB_RX_LANE1_SWAP_OFFSET                      4
+#define NVM_CFG1_GLOB_RX_LANE2_SWAP_MASK                        0x00000F00
+#define NVM_CFG1_GLOB_RX_LANE2_SWAP_OFFSET                      8
+#define NVM_CFG1_GLOB_RX_LANE3_SWAP_MASK                        0x0000F000
+#define NVM_CFG1_GLOB_RX_LANE3_SWAP_OFFSET                      12
+#define NVM_CFG1_GLOB_TX_LANE0_SWAP_MASK                        0x000F0000
+#define NVM_CFG1_GLOB_TX_LANE0_SWAP_OFFSET                      16
+#define NVM_CFG1_GLOB_TX_LANE1_SWAP_MASK                        0x00F00000
+#define NVM_CFG1_GLOB_TX_LANE1_SWAP_OFFSET                      20
+#define NVM_CFG1_GLOB_TX_LANE2_SWAP_MASK                        0x0F000000
+#define NVM_CFG1_GLOB_TX_LANE2_SWAP_OFFSET                      24
+#define NVM_CFG1_GLOB_TX_LANE3_SWAP_MASK                        0xF0000000
+#define NVM_CFG1_GLOB_TX_LANE3_SWAP_OFFSET                      28
+
+	u32 f_lane_cfg2;					/* 0x3C */
+#define NVM_CFG1_GLOB_RX_LANE0_POL_FLIP_MASK                    0x00000001
+#define NVM_CFG1_GLOB_RX_LANE0_POL_FLIP_OFFSET                  0
+#define NVM_CFG1_GLOB_RX_LANE1_POL_FLIP_MASK                    0x00000002
+#define NVM_CFG1_GLOB_RX_LANE1_POL_FLIP_OFFSET                  1
+#define NVM_CFG1_GLOB_RX_LANE2_POL_FLIP_MASK                    0x00000004
+#define NVM_CFG1_GLOB_RX_LANE2_POL_FLIP_OFFSET                  2
+#define NVM_CFG1_GLOB_RX_LANE3_POL_FLIP_MASK                    0x00000008
+#define NVM_CFG1_GLOB_RX_LANE3_POL_FLIP_OFFSET                  3
+#define NVM_CFG1_GLOB_TX_LANE0_POL_FLIP_MASK                    0x00000010
+#define NVM_CFG1_GLOB_TX_LANE0_POL_FLIP_OFFSET                  4
+#define NVM_CFG1_GLOB_TX_LANE1_POL_FLIP_MASK                    0x00000020
+#define NVM_CFG1_GLOB_TX_LANE1_POL_FLIP_OFFSET                  5
+#define NVM_CFG1_GLOB_TX_LANE2_POL_FLIP_MASK                    0x00000040
+#define NVM_CFG1_GLOB_TX_LANE2_POL_FLIP_OFFSET                  6
+#define NVM_CFG1_GLOB_TX_LANE3_POL_FLIP_MASK                    0x00000080
+#define NVM_CFG1_GLOB_TX_LANE3_POL_FLIP_OFFSET                  7
+
+	u32 eagle_preemphasis;					/* 0x40 */
+#define NVM_CFG1_GLOB_LANE0_PREEMP_MASK                         0x000000FF
+#define NVM_CFG1_GLOB_LANE0_PREEMP_OFFSET                       0
+#define NVM_CFG1_GLOB_LANE1_PREEMP_MASK                         0x0000FF00
+#define NVM_CFG1_GLOB_LANE1_PREEMP_OFFSET                       8
+#define NVM_CFG1_GLOB_LANE2_PREEMP_MASK                         0x00FF0000
+#define NVM_CFG1_GLOB_LANE2_PREEMP_OFFSET                       16
+#define NVM_CFG1_GLOB_LANE3_PREEMP_MASK                         0xFF000000
+#define NVM_CFG1_GLOB_LANE3_PREEMP_OFFSET                       24
+
+	u32 eagle_driver_current;				/* 0x44 */
+#define NVM_CFG1_GLOB_LANE0_AMP_MASK                            0x000000FF
+#define NVM_CFG1_GLOB_LANE0_AMP_OFFSET                          0
+#define NVM_CFG1_GLOB_LANE1_AMP_MASK                            0x0000FF00
+#define NVM_CFG1_GLOB_LANE1_AMP_OFFSET                          8
+#define NVM_CFG1_GLOB_LANE2_AMP_MASK                            0x00FF0000
+#define NVM_CFG1_GLOB_LANE2_AMP_OFFSET                          16
+#define NVM_CFG1_GLOB_LANE3_AMP_MASK                            0xFF000000
+#define NVM_CFG1_GLOB_LANE3_AMP_OFFSET                          24
+
+	u32 falcon_preemphasis;					/* 0x48 */
+#define NVM_CFG1_GLOB_LANE0_PREEMP_MASK                         0x000000FF
+#define NVM_CFG1_GLOB_LANE0_PREEMP_OFFSET                       0
+#define NVM_CFG1_GLOB_LANE1_PREEMP_MASK                         0x0000FF00
+#define NVM_CFG1_GLOB_LANE1_PREEMP_OFFSET                       8
+#define NVM_CFG1_GLOB_LANE2_PREEMP_MASK                         0x00FF0000
+#define NVM_CFG1_GLOB_LANE2_PREEMP_OFFSET                       16
+#define NVM_CFG1_GLOB_LANE3_PREEMP_MASK                         0xFF000000
+#define NVM_CFG1_GLOB_LANE3_PREEMP_OFFSET                       24
+
+	u32 falcon_driver_current;				/* 0x4C */
+#define NVM_CFG1_GLOB_LANE0_AMP_MASK                            0x000000FF
+#define NVM_CFG1_GLOB_LANE0_AMP_OFFSET                          0
+#define NVM_CFG1_GLOB_LANE1_AMP_MASK                            0x0000FF00
+#define NVM_CFG1_GLOB_LANE1_AMP_OFFSET                          8
+#define NVM_CFG1_GLOB_LANE2_AMP_MASK                            0x00FF0000
+#define NVM_CFG1_GLOB_LANE2_AMP_OFFSET                          16
+#define NVM_CFG1_GLOB_LANE3_AMP_MASK                            0xFF000000
+#define NVM_CFG1_GLOB_LANE3_AMP_OFFSET                          24
+
+	u32	pci_id;						/* 0x50 */
+#define NVM_CFG1_GLOB_VENDOR_ID_MASK                            0x0000FFFF
+#define NVM_CFG1_GLOB_VENDOR_ID_OFFSET                          0
+
+	u32	pci_subsys_id;					/* 0x54 */
+#define NVM_CFG1_GLOB_SUBSYSTEM_VENDOR_ID_MASK                  0x0000FFFF
+#define NVM_CFG1_GLOB_SUBSYSTEM_VENDOR_ID_OFFSET                0
+#define NVM_CFG1_GLOB_SUBSYSTEM_DEVICE_ID_MASK                  0xFFFF0000
+#define NVM_CFG1_GLOB_SUBSYSTEM_DEVICE_ID_OFFSET                16
+
+	u32	bar;						/* 0x58 */
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_MASK                   0x0000000F
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_OFFSET                 0
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_DISABLED               0x0
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_2K                     0x1
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_4K                     0x2
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_8K                     0x3
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_16K                    0x4
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_32K                    0x5
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_64K                    0x6
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_128K                   0x7
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_256K                   0x8
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_512K                   0x9
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_1M                     0xA
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_2M                     0xB
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_4M                     0xC
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_8M                     0xD
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_16M                    0xE
+#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_32M                    0xF
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_MASK                     0x000000F0
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_OFFSET                   4
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_DISABLED                 0x0
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_4K                       0x1
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_8K                       0x2
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_16K                      0x3
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_32K                      0x4
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_64K                      0x5
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_128K                     0x6
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_256K                     0x7
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_512K                     0x8
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_1M                       0x9
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_2M                       0xA
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_4M                       0xB
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_8M                       0xC
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_16M                      0xD
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_32M                      0xE
+#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_64M                      0xF
+#define NVM_CFG1_GLOB_BAR2_SIZE_MASK                            0x00000F00
+#define NVM_CFG1_GLOB_BAR2_SIZE_OFFSET                          8
+#define NVM_CFG1_GLOB_BAR2_SIZE_DISABLED                        0x0
+#define NVM_CFG1_GLOB_BAR2_SIZE_64K                             0x1
+#define NVM_CFG1_GLOB_BAR2_SIZE_128K                            0x2
+#define NVM_CFG1_GLOB_BAR2_SIZE_256K                            0x3
+#define NVM_CFG1_GLOB_BAR2_SIZE_512K                            0x4
+#define NVM_CFG1_GLOB_BAR2_SIZE_1M                              0x5
+#define NVM_CFG1_GLOB_BAR2_SIZE_2M                              0x6
+#define NVM_CFG1_GLOB_BAR2_SIZE_4M                              0x7
+#define NVM_CFG1_GLOB_BAR2_SIZE_8M                              0x8
+#define NVM_CFG1_GLOB_BAR2_SIZE_16M                             0x9
+#define NVM_CFG1_GLOB_BAR2_SIZE_32M                             0xA
+#define NVM_CFG1_GLOB_BAR2_SIZE_64M                             0xB
+#define NVM_CFG1_GLOB_BAR2_SIZE_128M                            0xC
+#define NVM_CFG1_GLOB_BAR2_SIZE_256M                            0xD
+#define NVM_CFG1_GLOB_BAR2_SIZE_512M                            0xE
+#define NVM_CFG1_GLOB_BAR2_SIZE_1G                              0xF
+
+	u32 eagle_txfir_main;					/* 0x5C */
+#define NVM_CFG1_GLOB_LANE0_TXFIR_MAIN_MASK                     0x000000FF
+#define NVM_CFG1_GLOB_LANE0_TXFIR_MAIN_OFFSET                   0
+#define NVM_CFG1_GLOB_LANE1_TXFIR_MAIN_MASK                     0x0000FF00
+#define NVM_CFG1_GLOB_LANE1_TXFIR_MAIN_OFFSET                   8
+#define NVM_CFG1_GLOB_LANE2_TXFIR_MAIN_MASK                     0x00FF0000
+#define NVM_CFG1_GLOB_LANE2_TXFIR_MAIN_OFFSET                   16
+#define NVM_CFG1_GLOB_LANE3_TXFIR_MAIN_MASK                     0xFF000000
+#define NVM_CFG1_GLOB_LANE3_TXFIR_MAIN_OFFSET                   24
+
+	u32 eagle_txfir_post;					/* 0x60 */
+#define NVM_CFG1_GLOB_LANE0_TXFIR_POST_MASK                     0x000000FF
+#define NVM_CFG1_GLOB_LANE0_TXFIR_POST_OFFSET                   0
+#define NVM_CFG1_GLOB_LANE1_TXFIR_POST_MASK                     0x0000FF00
+#define NVM_CFG1_GLOB_LANE1_TXFIR_POST_OFFSET                   8
+#define NVM_CFG1_GLOB_LANE2_TXFIR_POST_MASK                     0x00FF0000
+#define NVM_CFG1_GLOB_LANE2_TXFIR_POST_OFFSET                   16
+#define NVM_CFG1_GLOB_LANE3_TXFIR_POST_MASK                     0xFF000000
+#define NVM_CFG1_GLOB_LANE3_TXFIR_POST_OFFSET                   24
+
+	u32 falcon_txfir_main;					/* 0x64 */
+#define NVM_CFG1_GLOB_LANE0_TXFIR_MAIN_MASK                     0x000000FF
+#define NVM_CFG1_GLOB_LANE0_TXFIR_MAIN_OFFSET                   0
+#define NVM_CFG1_GLOB_LANE1_TXFIR_MAIN_MASK                     0x0000FF00
+#define NVM_CFG1_GLOB_LANE1_TXFIR_MAIN_OFFSET                   8
+#define NVM_CFG1_GLOB_LANE2_TXFIR_MAIN_MASK                     0x00FF0000
+#define NVM_CFG1_GLOB_LANE2_TXFIR_MAIN_OFFSET                   16
+#define NVM_CFG1_GLOB_LANE3_TXFIR_MAIN_MASK                     0xFF000000
+#define NVM_CFG1_GLOB_LANE3_TXFIR_MAIN_OFFSET                   24
+
+	u32 falcon_txfir_post;					/* 0x68 */
+#define NVM_CFG1_GLOB_LANE0_TXFIR_POST_MASK                     0x000000FF
+#define NVM_CFG1_GLOB_LANE0_TXFIR_POST_OFFSET                   0
+#define NVM_CFG1_GLOB_LANE1_TXFIR_POST_MASK                     0x0000FF00
+#define NVM_CFG1_GLOB_LANE1_TXFIR_POST_OFFSET                   8
+#define NVM_CFG1_GLOB_LANE2_TXFIR_POST_MASK                     0x00FF0000
+#define NVM_CFG1_GLOB_LANE2_TXFIR_POST_OFFSET                   16
+#define NVM_CFG1_GLOB_LANE3_TXFIR_POST_MASK                     0xFF000000
+#define NVM_CFG1_GLOB_LANE3_TXFIR_POST_OFFSET                   24
+
+	u32 manufacture_ver;					/* 0x6C */
+#define NVM_CFG1_GLOB_MANUF0_VER_MASK                           0x0000003F
+#define NVM_CFG1_GLOB_MANUF0_VER_OFFSET                         0
+#define NVM_CFG1_GLOB_MANUF1_VER_MASK                           0x00000FC0
+#define NVM_CFG1_GLOB_MANUF1_VER_OFFSET                         6
+#define NVM_CFG1_GLOB_MANUF2_VER_MASK                           0x0003F000
+#define NVM_CFG1_GLOB_MANUF2_VER_OFFSET                         12
+#define NVM_CFG1_GLOB_MANUF3_VER_MASK                           0x00FC0000
+#define NVM_CFG1_GLOB_MANUF3_VER_OFFSET                         18
+#define NVM_CFG1_GLOB_MANUF4_VER_MASK                           0x3F000000
+#define NVM_CFG1_GLOB_MANUF4_VER_OFFSET                         24
+
+	u32 manufacture_time;					/* 0x70 */
+#define NVM_CFG1_GLOB_MANUF0_TIME_MASK                          0x0000003F
+#define NVM_CFG1_GLOB_MANUF0_TIME_OFFSET                        0
+#define NVM_CFG1_GLOB_MANUF1_TIME_MASK                          0x00000FC0
+#define NVM_CFG1_GLOB_MANUF1_TIME_OFFSET                        6
+#define NVM_CFG1_GLOB_MANUF2_TIME_MASK                          0x0003F000
+#define NVM_CFG1_GLOB_MANUF2_TIME_OFFSET                        12
+
+	u32 led_global_settings;				/* 0x74 */
+#define NVM_CFG1_GLOB_LED_SWAP_0_MASK                           0x0000000F
+#define NVM_CFG1_GLOB_LED_SWAP_0_OFFSET                         0
+#define NVM_CFG1_GLOB_LED_SWAP_1_MASK                           0x000000F0
+#define NVM_CFG1_GLOB_LED_SWAP_1_OFFSET                         4
+#define NVM_CFG1_GLOB_LED_SWAP_2_MASK                           0x00000F00
+#define NVM_CFG1_GLOB_LED_SWAP_2_OFFSET                         8
+#define NVM_CFG1_GLOB_LED_SWAP_3_MASK                           0x0000F000
+#define NVM_CFG1_GLOB_LED_SWAP_3_OFFSET                         12
+
+	u32	generic_cont1;					/* 0x78 */
+#define NVM_CFG1_GLOB_AVS_DAC_CODE_MASK                         0x000003FF
+#define NVM_CFG1_GLOB_AVS_DAC_CODE_OFFSET                       0
+
+	u32	mbi_version;					/* 0x7C */
+#define NVM_CFG1_GLOB_MBI_VERSION_0_MASK                        0x000000FF
+#define NVM_CFG1_GLOB_MBI_VERSION_0_OFFSET                      0
+#define NVM_CFG1_GLOB_MBI_VERSION_1_MASK                        0x0000FF00
+#define NVM_CFG1_GLOB_MBI_VERSION_1_OFFSET                      8
+#define NVM_CFG1_GLOB_MBI_VERSION_2_MASK                        0x00FF0000
+#define NVM_CFG1_GLOB_MBI_VERSION_2_OFFSET                      16
+
+	u32	mbi_date;					/* 0x80 */
+
+	u32	misc_sig;					/* 0x84 */
+
+	/*  Define the GPIO mapping to switch i2c mux */
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO_0_MASK                   0x000000FF
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO_0_OFFSET                 0
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO_1_MASK                   0x0000FF00
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO_1_OFFSET                 8
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__NA                      0x0
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO0                   0x1
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO1                   0x2
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO2                   0x3
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO3                   0x4
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO4                   0x5
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO5                   0x6
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO6                   0x7
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO7                   0x8
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO8                   0x9
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO9                   0xA
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO10                  0xB
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO11                  0xC
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO12                  0xD
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO13                  0xE
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO14                  0xF
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO15                  0x10
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO16                  0x11
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO17                  0x12
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO18                  0x13
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO19                  0x14
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO20                  0x15
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO21                  0x16
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO22                  0x17
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO23                  0x18
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO24                  0x19
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO25                  0x1A
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO26                  0x1B
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO27                  0x1C
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO28                  0x1D
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO29                  0x1E
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO30                  0x1F
+#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO31                  0x20
+
+	u32 reserved[46];					/* 0x88 */
+};
+
+struct nvm_cfg1_path {
+	u32 reserved[30];					/* 0x0 */
+};
+
+struct nvm_cfg1_port {
+	u32 power_dissipated;					/* 0x0 */
+#define NVM_CFG1_PORT_POWER_DIS_D0_MASK                         0x000000FF
+#define NVM_CFG1_PORT_POWER_DIS_D0_OFFSET                       0
+#define NVM_CFG1_PORT_POWER_DIS_D1_MASK                         0x0000FF00
+#define NVM_CFG1_PORT_POWER_DIS_D1_OFFSET                       8
+#define NVM_CFG1_PORT_POWER_DIS_D2_MASK                         0x00FF0000
+#define NVM_CFG1_PORT_POWER_DIS_D2_OFFSET                       16
+#define NVM_CFG1_PORT_POWER_DIS_D3_MASK                         0xFF000000
+#define NVM_CFG1_PORT_POWER_DIS_D3_OFFSET                       24
+
+	u32 power_consumed;					/* 0x4 */
+#define NVM_CFG1_PORT_POWER_CONS_D0_MASK                        0x000000FF
+#define NVM_CFG1_PORT_POWER_CONS_D0_OFFSET                      0
+#define NVM_CFG1_PORT_POWER_CONS_D1_MASK                        0x0000FF00
+#define NVM_CFG1_PORT_POWER_CONS_D1_OFFSET                      8
+#define NVM_CFG1_PORT_POWER_CONS_D2_MASK                        0x00FF0000
+#define NVM_CFG1_PORT_POWER_CONS_D2_OFFSET                      16
+#define NVM_CFG1_PORT_POWER_CONS_D3_MASK                        0xFF000000
+#define NVM_CFG1_PORT_POWER_CONS_D3_OFFSET                      24
+
+	u32 generic_cont0;					/* 0x8 */
+#define NVM_CFG1_PORT_LED_MODE_MASK                             0x000000FF
+#define NVM_CFG1_PORT_LED_MODE_OFFSET                           0
+#define NVM_CFG1_PORT_LED_MODE_MAC1                             0x0
+#define NVM_CFG1_PORT_LED_MODE_PHY1                             0x1
+#define NVM_CFG1_PORT_LED_MODE_PHY2                             0x2
+#define NVM_CFG1_PORT_LED_MODE_PHY3                             0x3
+#define NVM_CFG1_PORT_LED_MODE_MAC2                             0x4
+#define NVM_CFG1_PORT_LED_MODE_PHY4                             0x5
+#define NVM_CFG1_PORT_LED_MODE_PHY5                             0x6
+#define NVM_CFG1_PORT_LED_MODE_PHY6                             0x7
+#define NVM_CFG1_PORT_LED_MODE_MAC3                             0x8
+#define NVM_CFG1_PORT_LED_MODE_PHY7                             0x9
+#define NVM_CFG1_PORT_LED_MODE_PHY8                             0xA
+#define NVM_CFG1_PORT_LED_MODE_PHY9                             0xB
+#define NVM_CFG1_PORT_LED_MODE_MAC4                             0xC
+#define NVM_CFG1_PORT_LED_MODE_PHY10                            0xD
+#define NVM_CFG1_PORT_LED_MODE_PHY11                            0xE
+#define NVM_CFG1_PORT_LED_MODE_PHY12                            0xF
+#define NVM_CFG1_PORT_ROCE_PRIORITY_MASK                        0x0000FF00
+#define NVM_CFG1_PORT_ROCE_PRIORITY_OFFSET                      8
+#define NVM_CFG1_PORT_DCBX_MODE_MASK                            0x000F0000
+#define NVM_CFG1_PORT_DCBX_MODE_OFFSET                          16
+#define NVM_CFG1_PORT_DCBX_MODE_DISABLED                        0x0
+#define NVM_CFG1_PORT_DCBX_MODE_IEEE                            0x1
+#define NVM_CFG1_PORT_DCBX_MODE_CEE                             0x2
+#define NVM_CFG1_PORT_DCBX_MODE_DYNAMIC                         0x3
+
+	u32	pcie_cfg;					/* 0xC */
+#define NVM_CFG1_PORT_RESERVED15_MASK                           0x00000007
+#define NVM_CFG1_PORT_RESERVED15_OFFSET                         0
+
+	u32	features;					/* 0x10 */
+#define NVM_CFG1_PORT_ENABLE_WOL_ON_ACPI_PATTERN_MASK           0x00000001
+#define NVM_CFG1_PORT_ENABLE_WOL_ON_ACPI_PATTERN_OFFSET         0
+#define NVM_CFG1_PORT_ENABLE_WOL_ON_ACPI_PATTERN_DISABLED       0x0
+#define NVM_CFG1_PORT_ENABLE_WOL_ON_ACPI_PATTERN_ENABLED        0x1
+#define NVM_CFG1_PORT_MAGIC_PACKET_WOL_MASK                     0x00000002
+#define NVM_CFG1_PORT_MAGIC_PACKET_WOL_OFFSET                   1
+#define NVM_CFG1_PORT_MAGIC_PACKET_WOL_DISABLED                 0x0
+#define NVM_CFG1_PORT_MAGIC_PACKET_WOL_ENABLED                  0x1
+
+	u32 speed_cap_mask;					/* 0x14 */
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_MASK            0x0000FFFF
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_OFFSET          0
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G              0x1
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_10G             0x2
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_25G             0x8
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_40G             0x10
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G             0x20
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_100G            0x40
+#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_MASK            0xFFFF0000
+#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_OFFSET          16
+#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_1G              0x1
+#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_10G             0x2
+#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_25G             0x8
+#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_40G             0x10
+#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_50G             0x20
+#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_100G            0x40
+
+	u32 link_settings;					/* 0x18 */
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_MASK                       0x0000000F
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_OFFSET                     0
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_AUTONEG                    0x0
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_1G                         0x1
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_10G                        0x2
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_25G                        0x4
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_40G                        0x5
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_50G                        0x6
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_100G                       0x7
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_MASK                     0x00000070
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_OFFSET                   4
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_AUTONEG                  0x1
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_RX                       0x2
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_TX                       0x4
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_MASK                       0x00000780
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_OFFSET                     7
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_AUTONEG                    0x0
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_1G                         0x1
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_10G                        0x2
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_25G                        0x4
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_40G                        0x5
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_50G                        0x6
+#define NVM_CFG1_PORT_MFW_LINK_SPEED_100G                       0x7
+#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_MASK                     0x00003800
+#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_OFFSET                   11
+#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_AUTONEG                  0x1
+#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_RX                       0x2
+#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_TX                       0x4
+#define NVM_CFG1_PORT_OPTIC_MODULE_VENDOR_ENFORCEMENT_MASK      0x00004000
+#define NVM_CFG1_PORT_OPTIC_MODULE_VENDOR_ENFORCEMENT_OFFSET    14
+#define NVM_CFG1_PORT_OPTIC_MODULE_VENDOR_ENFORCEMENT_DISABLED  0x0
+#define NVM_CFG1_PORT_OPTIC_MODULE_VENDOR_ENFORCEMENT_ENABLED   0x1
+
+	u32 phy_cfg;						/* 0x1C */
+#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_MASK                  0x0000FFFF
+#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_OFFSET                0
+#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_HIGIG                 0x1
+#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_SCRAMBLER             0x2
+#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_FIBER                 0x4
+#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_DISABLE_CL72_AN       0x8
+#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_DISABLE_FEC_AN        0x10
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_MASK                 0x00FF0000
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_OFFSET               16
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_BYPASS               0x0
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_KR                   0x2
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_KR2                  0x3
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_KR4                  0x4
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XFI                  0x8
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_SFI                  0x9
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_1000X                0xB
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_SGMII                0xC
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XLAUI                0xD
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_CAUI                 0xE
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XLPPI                0xF
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_CPPI                 0x10
+#define NVM_CFG1_PORT_AN_MODE_MASK                              0xFF000000
+#define NVM_CFG1_PORT_AN_MODE_OFFSET                            24
+#define NVM_CFG1_PORT_AN_MODE_NONE                              0x0
+#define NVM_CFG1_PORT_AN_MODE_CL73                              0x1
+#define NVM_CFG1_PORT_AN_MODE_CL37                              0x2
+#define NVM_CFG1_PORT_AN_MODE_CL73_BAM                          0x3
+#define NVM_CFG1_PORT_AN_MODE_CL37_BAM                          0x4
+#define NVM_CFG1_PORT_AN_MODE_HPAM                              0x5
+#define NVM_CFG1_PORT_AN_MODE_SGMII                             0x6
+
+	u32 mgmt_traffic;					/* 0x20 */
+#define NVM_CFG1_PORT_RESERVED61_MASK                           0x0000000F
+#define NVM_CFG1_PORT_RESERVED61_OFFSET                         0
+#define NVM_CFG1_PORT_RESERVED61_DISABLED                       0x0
+#define NVM_CFG1_PORT_RESERVED61_NCSI_OVER_RMII                 0x1
+#define NVM_CFG1_PORT_RESERVED61_NCSI_OVER_SMBUS                0x2
+
+	u32 ext_phy;						/* 0x24 */
+#define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_MASK                    0x000000FF
+#define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_OFFSET                  0
+#define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_NONE                    0x0
+#define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_BCM84844                0x1
+#define NVM_CFG1_PORT_EXTERNAL_PHY_ADDRESS_MASK                 0x0000FF00
+#define NVM_CFG1_PORT_EXTERNAL_PHY_ADDRESS_OFFSET               8
+
+	u32 mba_cfg1;						/* 0x28 */
+#define NVM_CFG1_PORT_MBA_MASK                                  0x00000001
+#define NVM_CFG1_PORT_MBA_OFFSET                                0
+#define NVM_CFG1_PORT_MBA_DISABLED                              0x0
+#define NVM_CFG1_PORT_MBA_ENABLED                               0x1
+#define NVM_CFG1_PORT_MBA_BOOT_TYPE_MASK                        0x00000006
+#define NVM_CFG1_PORT_MBA_BOOT_TYPE_OFFSET                      1
+#define NVM_CFG1_PORT_MBA_BOOT_TYPE_AUTO                        0x0
+#define NVM_CFG1_PORT_MBA_BOOT_TYPE_BBS                         0x1
+#define NVM_CFG1_PORT_MBA_BOOT_TYPE_INT18H                      0x2
+#define NVM_CFG1_PORT_MBA_BOOT_TYPE_INT19H                      0x3
+#define NVM_CFG1_PORT_MBA_DELAY_TIME_MASK                       0x00000078
+#define NVM_CFG1_PORT_MBA_DELAY_TIME_OFFSET                     3
+#define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_MASK                    0x00000080
+#define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_OFFSET                  7
+#define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_CTRL_S                  0x0
+#define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_CTRL_B                  0x1
+#define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_MASK                0x00000100
+#define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_OFFSET              8
+#define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_DISABLED            0x0
+#define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_ENABLED             0x1
+#define NVM_CFG1_PORT_RESERVED5_MASK                            0x0001FE00
+#define NVM_CFG1_PORT_RESERVED5_OFFSET                          9
+#define NVM_CFG1_PORT_RESERVED5_DISABLED                        0x0
+#define NVM_CFG1_PORT_RESERVED5_2K                              0x1
+#define NVM_CFG1_PORT_RESERVED5_4K                              0x2
+#define NVM_CFG1_PORT_RESERVED5_8K                              0x3
+#define NVM_CFG1_PORT_RESERVED5_16K                             0x4
+#define NVM_CFG1_PORT_RESERVED5_32K                             0x5
+#define NVM_CFG1_PORT_RESERVED5_64K                             0x6
+#define NVM_CFG1_PORT_RESERVED5_128K                            0x7
+#define NVM_CFG1_PORT_RESERVED5_256K                            0x8
+#define NVM_CFG1_PORT_RESERVED5_512K                            0x9
+#define NVM_CFG1_PORT_RESERVED5_1M                              0xA
+#define NVM_CFG1_PORT_RESERVED5_2M                              0xB
+#define NVM_CFG1_PORT_RESERVED5_4M                              0xC
+#define NVM_CFG1_PORT_RESERVED5_8M                              0xD
+#define NVM_CFG1_PORT_RESERVED5_16M                             0xE
+#define NVM_CFG1_PORT_RESERVED5_32M                             0xF
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_MASK                       0x001E0000
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_OFFSET                     17
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_AUTONEG                    0x0
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_1G                         0x1
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_10G                        0x2
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_25G                        0x4
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_40G                        0x5
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_50G                        0x6
+#define NVM_CFG1_PORT_MBA_LINK_SPEED_100G                       0x7
+#define NVM_CFG1_PORT_MBA_BOOT_RETRY_COUNT_MASK                 0x00E00000
+#define NVM_CFG1_PORT_MBA_BOOT_RETRY_COUNT_OFFSET               21
+
+	u32	mba_cfg2;					/* 0x2C */
+#define NVM_CFG1_PORT_MBA_VLAN_VALUE_MASK                       0x0000FFFF
+#define NVM_CFG1_PORT_MBA_VLAN_VALUE_OFFSET                     0
+#define NVM_CFG1_PORT_MBA_VLAN_MASK                             0x00010000
+#define NVM_CFG1_PORT_MBA_VLAN_OFFSET                           16
+
+	u32	vf_cfg;						/* 0x30 */
+#define NVM_CFG1_PORT_RESERVED8_MASK                            0x0000FFFF
+#define NVM_CFG1_PORT_RESERVED8_OFFSET                          0
+#define NVM_CFG1_PORT_RESERVED6_MASK                            0x000F0000
+#define NVM_CFG1_PORT_RESERVED6_OFFSET                          16
+#define NVM_CFG1_PORT_RESERVED6_DISABLED                        0x0
+#define NVM_CFG1_PORT_RESERVED6_4K                              0x1
+#define NVM_CFG1_PORT_RESERVED6_8K                              0x2
+#define NVM_CFG1_PORT_RESERVED6_16K                             0x3
+#define NVM_CFG1_PORT_RESERVED6_32K                             0x4
+#define NVM_CFG1_PORT_RESERVED6_64K                             0x5
+#define NVM_CFG1_PORT_RESERVED6_128K                            0x6
+#define NVM_CFG1_PORT_RESERVED6_256K                            0x7
+#define NVM_CFG1_PORT_RESERVED6_512K                            0x8
+#define NVM_CFG1_PORT_RESERVED6_1M                              0x9
+#define NVM_CFG1_PORT_RESERVED6_2M                              0xA
+#define NVM_CFG1_PORT_RESERVED6_4M                              0xB
+#define NVM_CFG1_PORT_RESERVED6_8M                              0xC
+#define NVM_CFG1_PORT_RESERVED6_16M                             0xD
+#define NVM_CFG1_PORT_RESERVED6_32M                             0xE
+#define NVM_CFG1_PORT_RESERVED6_64M                             0xF
+
+	struct nvm_cfg_mac_address	lldp_mac_address;	/* 0x34 */
+
+	u32				led_port_settings;	/* 0x3C */
+#define NVM_CFG1_PORT_LANE_LED_SPD_0_SEL_MASK                   0x000000FF
+#define NVM_CFG1_PORT_LANE_LED_SPD_0_SEL_OFFSET                 0
+#define NVM_CFG1_PORT_LANE_LED_SPD_1_SEL_MASK                   0x0000FF00
+#define NVM_CFG1_PORT_LANE_LED_SPD_1_SEL_OFFSET                 8
+#define NVM_CFG1_PORT_LANE_LED_SPD_2_SEL_MASK                   0x00FF0000
+#define NVM_CFG1_PORT_LANE_LED_SPD_2_SEL_OFFSET                 16
+#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_1G                      0x1
+#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_10G                     0x2
+#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_25G                     0x8
+#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_40G                     0x10
+#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_50G                     0x20
+#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_100G                    0x40
+
+	u32 transceiver_00;					/* 0x40 */
+
+	/*  Define for mapping of transceiver signal module absent */
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_MASK                     0x000000FF
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_OFFSET                   0
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_NA                       0x0
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO0                    0x1
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO1                    0x2
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO2                    0x3
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO3                    0x4
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO4                    0x5
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO5                    0x6
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO6                    0x7
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO7                    0x8
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO8                    0x9
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO9                    0xA
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO10                   0xB
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO11                   0xC
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO12                   0xD
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO13                   0xE
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO14                   0xF
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO15                   0x10
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO16                   0x11
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO17                   0x12
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO18                   0x13
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO19                   0x14
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO20                   0x15
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO21                   0x16
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO22                   0x17
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO23                   0x18
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO24                   0x19
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO25                   0x1A
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO26                   0x1B
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO27                   0x1C
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO28                   0x1D
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO29                   0x1E
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO30                   0x1F
+#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO31                   0x20
+	/*  Define the GPIO mux settings  to switch i2c mux to this port */
+#define NVM_CFG1_PORT_I2C_MUX_SEL_VALUE_0_MASK                  0x00000F00
+#define NVM_CFG1_PORT_I2C_MUX_SEL_VALUE_0_OFFSET                8
+#define NVM_CFG1_PORT_I2C_MUX_SEL_VALUE_1_MASK                  0x0000F000
+#define NVM_CFG1_PORT_I2C_MUX_SEL_VALUE_1_OFFSET                12
+
+	u32 reserved[133];					/* 0x44 */
+};
+
+struct nvm_cfg1_func {
+	struct nvm_cfg_mac_address	mac_address;		/* 0x0 */
+
+	u32				rsrv1;			/* 0x8 */
+#define NVM_CFG1_FUNC_RESERVED1_MASK                            0x0000FFFF
+#define NVM_CFG1_FUNC_RESERVED1_OFFSET                          0
+#define NVM_CFG1_FUNC_RESERVED2_MASK                            0xFFFF0000
+#define NVM_CFG1_FUNC_RESERVED2_OFFSET                          16
+
+	u32				rsrv2;			/* 0xC */
+#define NVM_CFG1_FUNC_RESERVED3_MASK                            0x0000FFFF
+#define NVM_CFG1_FUNC_RESERVED3_OFFSET                          0
+#define NVM_CFG1_FUNC_RESERVED4_MASK                            0xFFFF0000
+#define NVM_CFG1_FUNC_RESERVED4_OFFSET                          16
+
+	u32				device_id;		/* 0x10 */
+#define NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_MASK                  0x0000FFFF
+#define NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_OFFSET                0
+#define NVM_CFG1_FUNC_VENDOR_DEVICE_ID_MASK                     0xFFFF0000
+#define NVM_CFG1_FUNC_VENDOR_DEVICE_ID_OFFSET                   16
+
+	u32				cmn_cfg;		/* 0x14 */
+#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_MASK                    0x00000007
+#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_OFFSET                  0
+#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_PXE                     0x0
+#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_RPL                     0x1
+#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_BOOTP                   0x2
+#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_ISCSI_BOOT              0x3
+#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_FCOE_BOOT               0x4
+#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_NONE                    0x7
+#define NVM_CFG1_FUNC_VF_PCI_DEVICE_ID_MASK                     0x0007FFF8
+#define NVM_CFG1_FUNC_VF_PCI_DEVICE_ID_OFFSET                   3
+#define NVM_CFG1_FUNC_PERSONALITY_MASK                          0x00780000
+#define NVM_CFG1_FUNC_PERSONALITY_OFFSET                        19
+#define NVM_CFG1_FUNC_PERSONALITY_ETHERNET                      0x0
+#define NVM_CFG1_FUNC_PERSONALITY_ISCSI                         0x1
+#define NVM_CFG1_FUNC_PERSONALITY_FCOE                          0x2
+#define NVM_CFG1_FUNC_PERSONALITY_ROCE                          0x3
+#define NVM_CFG1_FUNC_BANDWIDTH_WEIGHT_MASK                     0x7F800000
+#define NVM_CFG1_FUNC_BANDWIDTH_WEIGHT_OFFSET                   23
+#define NVM_CFG1_FUNC_PAUSE_ON_HOST_RING_MASK                   0x80000000
+#define NVM_CFG1_FUNC_PAUSE_ON_HOST_RING_OFFSET                 31
+#define NVM_CFG1_FUNC_PAUSE_ON_HOST_RING_DISABLED               0x0
+#define NVM_CFG1_FUNC_PAUSE_ON_HOST_RING_ENABLED                0x1
+
+	u32 pci_cfg;						/* 0x18 */
+#define NVM_CFG1_FUNC_NUMBER_OF_VFS_PER_PF_MASK                 0x0000007F
+#define NVM_CFG1_FUNC_NUMBER_OF_VFS_PER_PF_OFFSET               0
+#define NVM_CFG1_FUNC_RESERVESD12_MASK                          0x00003F80
+#define NVM_CFG1_FUNC_RESERVESD12_OFFSET                        7
+#define NVM_CFG1_FUNC_BAR1_SIZE_MASK                            0x0003C000
+#define NVM_CFG1_FUNC_BAR1_SIZE_OFFSET                          14
+#define NVM_CFG1_FUNC_BAR1_SIZE_DISABLED                        0x0
+#define NVM_CFG1_FUNC_BAR1_SIZE_64K                             0x1
+#define NVM_CFG1_FUNC_BAR1_SIZE_128K                            0x2
+#define NVM_CFG1_FUNC_BAR1_SIZE_256K                            0x3
+#define NVM_CFG1_FUNC_BAR1_SIZE_512K                            0x4
+#define NVM_CFG1_FUNC_BAR1_SIZE_1M                              0x5
+#define NVM_CFG1_FUNC_BAR1_SIZE_2M                              0x6
+#define NVM_CFG1_FUNC_BAR1_SIZE_4M                              0x7
+#define NVM_CFG1_FUNC_BAR1_SIZE_8M                              0x8
+#define NVM_CFG1_FUNC_BAR1_SIZE_16M                             0x9
+#define NVM_CFG1_FUNC_BAR1_SIZE_32M                             0xA
+#define NVM_CFG1_FUNC_BAR1_SIZE_64M                             0xB
+#define NVM_CFG1_FUNC_BAR1_SIZE_128M                            0xC
+#define NVM_CFG1_FUNC_BAR1_SIZE_256M                            0xD
+#define NVM_CFG1_FUNC_BAR1_SIZE_512M                            0xE
+#define NVM_CFG1_FUNC_BAR1_SIZE_1G                              0xF
+#define NVM_CFG1_FUNC_MAX_BANDWIDTH_MASK                        0x03FC0000
+#define NVM_CFG1_FUNC_MAX_BANDWIDTH_OFFSET                      18
+
+	struct nvm_cfg_mac_address	fcoe_node_wwn_mac_addr;	/* 0x1C */
+
+	struct nvm_cfg_mac_address	fcoe_port_wwn_mac_addr;	/* 0x24 */
+
+	u32				reserved[9];		/* 0x2C */
+};
+
+struct nvm_cfg1 {
+	struct nvm_cfg1_glob	glob;				/* 0x0 */
+
+	struct nvm_cfg1_path	path[MCP_GLOB_PATH_MAX];	/* 0x140 */
+
+	struct nvm_cfg1_port	port[MCP_GLOB_PORT_MAX];	/* 0x230 */
+
+	struct nvm_cfg1_func	func[MCP_GLOB_FUNC_MAX];	/* 0xB90 */
+};
+
+/******************************************
+* nvm_cfg structs
+******************************************/
+
+enum nvm_cfg_sections {
+	NVM_CFG_SECTION_NVM_CFG1,
+	NVM_CFG_SECTION_MAX
+};
+
+struct nvm_cfg {
+	u32		num_sections;
+	u32		sections_offset[NVM_CFG_SECTION_MAX];
+	struct nvm_cfg1 cfg1;
+};
+
+#ifndef SPAD_LAYOUT_H
+#define SPAD_LAYOUT_H
+
+#define PORT_0          0
+#define PORT_1          1
+#define PORT_2          2
+#define PORT_3          3
+
+extern struct spad_layout g_spad;
+
+#define MCP_SPAD_SIZE                       0x00028000  /* 160 KB */
+
+#define SPAD_OFFSET(addr) (((u32)addr - (u32)CPU_SPAD_BASE))
+
+#define TO_OFFSIZE(_offset, _size)				\
+	(u32)((((u32)(_offset) >> 2) << OFFSIZE_OFFSET_SHIFT) |	\
+	      (((u32)(_size) >> 2) << OFFSIZE_SIZE_SHIFT))
+
+enum spad_sections {
+	SPAD_SECTION_TRACE,
+	SPAD_SECTION_NVM_CFG,
+	SPAD_SECTION_PUBLIC,
+	SPAD_SECTION_PRIVATE,
+	SPAD_SECTION_MAX
+};
+
+struct spad_layout {
+	struct nvm_cfg		nvm_cfg;
+	struct mcp_public_data	public_data;
+};
+
+#endif                          /* SPAD_LAYOUT_H */
+
+#ifndef NVM_MAP_H
+#define NVM_MAP_H
+
+#define CRC_MAGIC_VALUE                     0xDEBB20E3
+#define CRC32_POLYNOMIAL                    0xEDB88320
+#define NVM_CRC_SIZE                            (sizeof(u32))
+
+enum nvm_sw_arbitrator {
+	NVM_SW_ARB_HOST,
+	NVM_SW_ARB_MCP,
+	NVM_SW_ARB_UART,
+	NVM_SW_ARB_RESERVED
+};
+
+/****************************************************************************
+* Boot Strap Region                                                        *
+****************************************************************************/
+struct legacy_bootstrap_region {
+	u32	magic_value;
+#define NVM_MAGIC_VALUE          0x669955aa
+	u32	sram_start_addr;
+	u32	code_len;               /* boot code length (in dwords) */
+	u32	code_start_addr;
+	u32	crc;                    /* 32-bit CRC */
+};
+
+/****************************************************************************
+* Directories Region                                                       *
+****************************************************************************/
+struct nvm_code_entry {
+	u32	image_type;             /* Image type */
+	u32	nvm_start_addr;         /* NVM address of the image */
+	u32	len;                    /* Include CRC */
+	u32	sram_start_addr;
+	u32	sram_run_addr;          /* Relevant in case of MIM only */
+};
+
+enum nvm_image_type {
+	NVM_TYPE_TIM1		= 0x01,
+	NVM_TYPE_TIM2		= 0x02,
+	NVM_TYPE_MIM1		= 0x03,
+	NVM_TYPE_MIM2		= 0x04,
+	NVM_TYPE_MBA		= 0x05,
+	NVM_TYPE_MODULES_PN	= 0x06,
+	NVM_TYPE_VPD		= 0x07,
+	NVM_TYPE_MFW_TRACE1	= 0x08,
+	NVM_TYPE_MFW_TRACE2	= 0x09,
+	NVM_TYPE_NVM_CFG1	= 0x0a,
+	NVM_TYPE_L2B		= 0x0b,
+	NVM_TYPE_DIR1		= 0x0c,
+	NVM_TYPE_EAGLE_FW1	= 0x0d,
+	NVM_TYPE_FALCON_FW1	= 0x0e,
+	NVM_TYPE_PCIE_FW1	= 0x0f,
+	NVM_TYPE_HW_SET		= 0x10,
+	NVM_TYPE_LIM		= 0x11,
+	NVM_TYPE_AVS_FW1	= 0x12,
+	NVM_TYPE_DIR2		= 0x13,
+	NVM_TYPE_CCM		= 0x14,
+	NVM_TYPE_EAGLE_FW2	= 0x15,
+	NVM_TYPE_FALCON_FW2	= 0x16,
+	NVM_TYPE_PCIE_FW2	= 0x17,
+	NVM_TYPE_AVS_FW2	= 0x18,
+
+	NVM_TYPE_MAX,
+};
+
+#ifdef DEFINE_IMAGE_TABLE
+struct image_map {
+	char	name[32];
+	char	option[32];
+	u32	image_type;
+};
+
+struct image_map g_image_table[] = {
+	{ "TIM1",	 "-tim1",	 NVM_TYPE_TIM1 },
+	{ "TIM2",	 "-tim2",	 NVM_TYPE_TIM2 },
+	{ "MIM1",	 "-mim1",	 NVM_TYPE_MIM1 },
+	{ "MIM2",	 "-mim2",	 NVM_TYPE_MIM2 },
+	{ "MBA",	 "-mba",	 NVM_TYPE_MBA },
+	{ "OPT_MODULES", "-optm",	 NVM_TYPE_MODULES_PN },
+	{ "VPD",	 "-vpd",	 NVM_TYPE_VPD },
+	{ "MFW_TRACE1",	 "-mfwt1",	 NVM_TYPE_MFW_TRACE1 },
+	{ "MFW_TRACE2",	 "-mfwt2",	 NVM_TYPE_MFW_TRACE2 },
+	{ "NVM_CFG1",	 "-cfg",	 NVM_TYPE_NVM_CFG1 },
+	{ "L2B",	 "-l2b",	 NVM_TYPE_L2B },
+	{ "DIR1",	 "-dir1",	 NVM_TYPE_DIR1 },
+	{ "EAGLE_FW1",	 "-eagle1",	 NVM_TYPE_EAGLE_FW1 },
+	{ "FALCON_FW1",	 "-falcon1",	 NVM_TYPE_FALCON_FW1 },
+	{ "PCIE_FW1",	 "-pcie1",	 NVM_TYPE_PCIE_FW1 },
+	{ "HW_SET",	 "-hw_set",	 NVM_TYPE_HW_SET },
+	{ "LIM",	 "-lim",	 NVM_TYPE_LIM },
+	{ "AVS_FW1",	 "-avs1",	 NVM_TYPE_AVS_FW1 },
+	{ "DIR2",	 "-dir2",	 NVM_TYPE_DIR2 },
+	{ "CCM",	 "-ccm",	 NVM_TYPE_CCM },
+	{ "EAGLE_FW2",	 "-eagle2",	 NVM_TYPE_EAGLE_FW2 },
+	{ "FALCON_FW2",	 "-falcon2",	 NVM_TYPE_FALCON_FW2 },
+	{ "PCIE_FW2",	 "-pcie2",	 NVM_TYPE_PCIE_FW2 },
+	{ "AVS_FW2",	 "-avs2",	 NVM_TYPE_AVS_FW2 }
+};
+
+#define IMAGE_TABLE_SIZE (sizeof(g_image_table) / sizeof(struct image_map))
+
+#endif  /* #ifdef DEFINE_IMAGE_TABLE */
+#define MAX_NVM_DIR_ENTRIES 200
+
+struct nvm_dir {
+	s32 seq;
+#define NVM_DIR_NEXT_MFW_MASK   0x00000001
+#define NVM_DIR_SEQ_MASK        0xfffffffe
+#define NVM_DIR_NEXT_MFW(seq) ((seq) & NVM_DIR_NEXT_MFW_MASK)
+
+#define IS_DIR_SEQ_VALID(seq) ((seq & NVM_DIR_SEQ_MASK) != NVM_DIR_SEQ_MASK)
+
+	u32			num_images;
+	u32			rsrv;
+	struct nvm_code_entry	code[1]; /* Up to MAX_NVM_DIR_ENTRIES */
+};
+
+#define NVM_DIR_SIZE(_num_images) (sizeof(struct nvm_dir) +		 \
+				   (_num_images -			 \
+				    1) * sizeof(struct nvm_code_entry) + \
+				   NVM_CRC_SIZE)
+
+struct nvm_vpd_image {
+	u32	format_revision;
+#define VPD_IMAGE_VERSION        1
+
+	/* This array length depends on the number of VPD fields */
+	u8	vpd_data[1];
+};
+
+/****************************************************************************
+* NVRAM FULL MAP                                                           *
+****************************************************************************/
+#define DIR_ID_1    (0)
+#define DIR_ID_2    (1)
+#define MAX_DIR_IDS (2)
+
+#define MFW_BUNDLE_1    (0)
+#define MFW_BUNDLE_2    (1)
+#define MAX_MFW_BUNDLES (2)
+
+#define FLASH_PAGE_SIZE 0x1000
+#define NVM_DIR_MAX_SIZE    (FLASH_PAGE_SIZE)           /* 4Kb */
+#define ASIC_MIM_MAX_SIZE   (300 * FLASH_PAGE_SIZE)     /* 1.2Mb */
+#define FPGA_MIM_MAX_SIZE   (25 * FLASH_PAGE_SIZE)      /* 60Kb */
+
+#define LIM_MAX_SIZE        ((2 *				      \
+			      FLASH_PAGE_SIZE) -		      \
+			     sizeof(struct legacy_bootstrap_region) - \
+			     NVM_RSV_SIZE)
+#define LIM_OFFSET          (NVM_OFFSET(lim_image))
+#define NVM_RSV_SIZE            (44)
+#define MIM_MAX_SIZE(is_asic) ((is_asic) ? ASIC_MIM_MAX_SIZE : \
+			       FPGA_MIM_MAX_SIZE)
+#define MIM_OFFSET(idx, is_asic) (NVM_OFFSET(dir[MAX_MFW_BUNDLES]) + \
+				  ((idx ==			     \
+				    NVM_TYPE_MIM2) ? MIM_MAX_SIZE(is_asic) : 0))
+#define NVM_FIXED_AREA_SIZE(is_asic) (sizeof(struct nvm_image) + \
+				      MIM_MAX_SIZE(is_asic) * 2)
+
+union nvm_dir_union {
+	struct nvm_dir	dir;
+	u8		page[FLASH_PAGE_SIZE];
+};
+
+/*                        Address
+ *  +-------------------+ 0x000000
+ *  |    Bootstrap:     |
+ *  | magic_number      |
+ *  | sram_start_addr   |
+ *  | code_len          |
+ *  | code_start_addr   |
+ *  | crc               |
+ *  +-------------------+ 0x000014
+ *  | rsrv              |
+ *  +-------------------+ 0x000040
+ *  | LIM               |
+ *  +-------------------+ 0x002000
+ *  | Dir1              |
+ *  +-------------------+ 0x003000
+ *  | Dir2              |
+ *  +-------------------+ 0x004000
+ *  | MIM1              |
+ *  +-------------------+ 0x130000
+ *  | MIM2              |
+ *  +-------------------+ 0x25C000
+ *  | Rest Images:      |
+ *  | TIM1/2            |
+ *  | MFW_TRACE1/2      |
+ *  | Eagle/Falcon FW   |
+ *  | PCIE/AVS FW       |
+ *  | MBA/CCM/L2B       |
+ *  | VPD               |
+ *  | optic_modules     |
+ *  |  ...              |
+ *  +-------------------+ 0x400000
+ */
+struct nvm_image {
+/*********** !!!  FIXED SECTIONS  !!! DO NOT MODIFY !!! **********************/
+	/* NVM Offset  (size) */
+	struct legacy_bootstrap_region	bootstrap;
+	u8				rsrv[NVM_RSV_SIZE];
+	u8				lim_image[LIM_MAX_SIZE];
+	union nvm_dir_union		dir[MAX_MFW_BUNDLES];
+
+	/* MIM1_IMAGE                              0x004000 (0x12c000) */
+	/* MIM2_IMAGE                              0x130000 (0x12c000) */
+/*********** !!!  FIXED SECTIONS  !!! DO NOT MODIFY !!! **********************/
+};                              /* 0x134 */
+
+#define NVM_OFFSET(f)	((u32_t)((int_ptr_t)(&(((struct nvm_image *)0)->f))))
+
+struct hw_set_info {
+	u32	reg_type;
+#define GRC_REG_TYPE 1
+#define PHY_REG_TYPE 2
+#define PCI_REG_TYPE 4
+
+	u32	bank_num;
+	u32	pf_num;
+	u32	operation;
+#define READ_OP     1
+#define WRITE_OP    2
+#define RMW_SET_OP  3
+#define RMW_CLR_OP  4
+
+	u32	reg_addr;
+	u32	reg_data;
+
+	u32	reset_type;
+#define POR_RESET_TYPE	BIT(0)
+#define HARD_RESET_TYPE	BIT(1)
+#define CORE_RESET_TYPE	BIT(2)
+#define MCP_RESET_TYPE	BIT(3)
+#define PERSET_ASSERT	BIT(4)
+#define PERSET_DEASSERT	BIT(5)
+};
+
+struct hw_set_image {
+	u32			format_version;
+#define HW_SET_IMAGE_VERSION        1
+	u32			no_hw_sets;
+
+	/* This array length depends on the no_hw_sets */
+	struct hw_set_info	hw_sets[1];
+};
+
+#endif
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
new file mode 100644
index 0000000..1512b72
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -0,0 +1,776 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/qed/qed_chain.h>
+#include "qed.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_reg_addr.h"
+
+#define QED_BAR_ACQUIRE_TIMEOUT 1000
+
+/* Invalid values */
+#define QED_BAR_INVALID_OFFSET          (cpu_to_le32(-1))
+
+struct qed_ptt {
+	struct list_head	list_entry;
+	unsigned int		idx;
+	struct pxp_ptt_entry	pxp;
+};
+
+struct qed_ptt_pool {
+	struct list_head	free_list;
+	spinlock_t		lock; /* ptt synchronized access */
+	struct qed_ptt		ptts[PXP_EXTERNAL_BAR_PF_WINDOW_NUM];
+};
+
+int qed_ptt_pool_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ptt_pool *p_pool = kmalloc(sizeof(*p_pool),
+					      GFP_ATOMIC);
+	int i;
+
+	if (!p_pool)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&p_pool->free_list);
+	for (i = 0; i < PXP_EXTERNAL_BAR_PF_WINDOW_NUM; i++) {
+		p_pool->ptts[i].idx = i;
+		p_pool->ptts[i].pxp.offset = QED_BAR_INVALID_OFFSET;
+		p_pool->ptts[i].pxp.pretend.control = 0;
+		if (i >= RESERVED_PTT_MAX)
+			list_add(&p_pool->ptts[i].list_entry,
+				 &p_pool->free_list);
+	}
+
+	p_hwfn->p_ptt_pool = p_pool;
+	spin_lock_init(&p_pool->lock);
+
+	return 0;
+}
+
+void qed_ptt_invalidate(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ptt *p_ptt;
+	int i;
+
+	for (i = 0; i < PXP_EXTERNAL_BAR_PF_WINDOW_NUM; i++) {
+		p_ptt = &p_hwfn->p_ptt_pool->ptts[i];
+		p_ptt->pxp.offset = QED_BAR_INVALID_OFFSET;
+	}
+}
+
+void qed_ptt_pool_free(struct qed_hwfn *p_hwfn)
+{
+	kfree(p_hwfn->p_ptt_pool);
+	p_hwfn->p_ptt_pool = NULL;
+}
+
+struct qed_ptt *qed_ptt_acquire(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ptt *p_ptt;
+	unsigned int i;
+
+	/* Take the free PTT from the list */
+	for (i = 0; i < QED_BAR_ACQUIRE_TIMEOUT; i++) {
+		spin_lock_bh(&p_hwfn->p_ptt_pool->lock);
+
+		if (!list_empty(&p_hwfn->p_ptt_pool->free_list)) {
+			p_ptt = list_first_entry(&p_hwfn->p_ptt_pool->free_list,
+						 struct qed_ptt, list_entry);
+			list_del(&p_ptt->list_entry);
+
+			spin_unlock_bh(&p_hwfn->p_ptt_pool->lock);
+
+			DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+				   "allocated ptt %d\n", p_ptt->idx);
+			return p_ptt;
+		}
+
+		spin_unlock_bh(&p_hwfn->p_ptt_pool->lock);
+		usleep_range(1000, 2000);
+	}
+
+	DP_NOTICE(p_hwfn, "PTT acquire timeout - failed to allocate PTT\n");
+	return NULL;
+}
+
+void qed_ptt_release(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt)
+{
+	spin_lock_bh(&p_hwfn->p_ptt_pool->lock);
+	list_add(&p_ptt->list_entry, &p_hwfn->p_ptt_pool->free_list);
+	spin_unlock_bh(&p_hwfn->p_ptt_pool->lock);
+}
+
+u32 qed_ptt_get_hw_addr(struct qed_hwfn *p_hwfn,
+			struct qed_ptt	*p_ptt)
+{
+	/* The HW is using DWORDS and we need to translate it to Bytes */
+	return le32_to_cpu(p_ptt->pxp.offset) << 2;
+}
+
+static u32 qed_ptt_config_addr(struct qed_ptt *p_ptt)
+{
+	return PXP_PF_WINDOW_ADMIN_PER_PF_START +
+	       p_ptt->idx * sizeof(struct pxp_ptt_entry);
+}
+
+u32 qed_ptt_get_bar_addr(struct qed_ptt *p_ptt)
+{
+	return PXP_EXTERNAL_BAR_PF_WINDOW_START +
+	       p_ptt->idx * PXP_EXTERNAL_BAR_PF_WINDOW_SINGLE_SIZE;
+}
+
+void qed_ptt_set_win(struct qed_hwfn *p_hwfn,
+		     struct qed_ptt *p_ptt,
+		     u32 new_hw_addr)
+{
+	u32 prev_hw_addr;
+
+	prev_hw_addr = qed_ptt_get_hw_addr(p_hwfn, p_ptt);
+
+	if (new_hw_addr == prev_hw_addr)
+		return;
+
+	/* Update PTT entery in admin window */
+	DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+		   "Updating PTT entry %d to offset 0x%x\n",
+		   p_ptt->idx, new_hw_addr);
+
+	/* The HW is using DWORDS and the address is in Bytes */
+	p_ptt->pxp.offset = cpu_to_le32(new_hw_addr >> 2);
+
+	REG_WR(p_hwfn,
+	       qed_ptt_config_addr(p_ptt) +
+	       offsetof(struct pxp_ptt_entry, offset),
+	       le32_to_cpu(p_ptt->pxp.offset));
+}
+
+static u32 qed_set_ptt(struct qed_hwfn *p_hwfn,
+		       struct qed_ptt *p_ptt,
+		       u32 hw_addr)
+{
+	u32 win_hw_addr = qed_ptt_get_hw_addr(p_hwfn, p_ptt);
+	u32 offset;
+
+	offset = hw_addr - win_hw_addr;
+
+	/* Verify the address is within the window */
+	if (hw_addr < win_hw_addr ||
+	    offset >= PXP_EXTERNAL_BAR_PF_WINDOW_SINGLE_SIZE) {
+		qed_ptt_set_win(p_hwfn, p_ptt, hw_addr);
+		offset = 0;
+	}
+
+	return qed_ptt_get_bar_addr(p_ptt) + offset;
+}
+
+struct qed_ptt *qed_get_reserved_ptt(struct qed_hwfn *p_hwfn,
+				     enum reserved_ptts ptt_idx)
+{
+	if (ptt_idx >= RESERVED_PTT_MAX) {
+		DP_NOTICE(p_hwfn,
+			  "Requested PTT %d is out of range\n", ptt_idx);
+		return NULL;
+	}
+
+	return &p_hwfn->p_ptt_pool->ptts[ptt_idx];
+}
+
+void qed_wr(struct qed_hwfn *p_hwfn,
+	    struct qed_ptt *p_ptt,
+	    u32 hw_addr, u32 val)
+{
+	u32 bar_addr = qed_set_ptt(p_hwfn, p_ptt, hw_addr);
+
+	REG_WR(p_hwfn, bar_addr, val);
+	DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+		   "bar_addr 0x%x, hw_addr 0x%x, val 0x%x\n",
+		   bar_addr, hw_addr, val);
+}
+
+u32 qed_rd(struct qed_hwfn *p_hwfn,
+	   struct qed_ptt *p_ptt,
+	   u32 hw_addr)
+{
+	u32 bar_addr = qed_set_ptt(p_hwfn, p_ptt, hw_addr);
+	u32 val = REG_RD(p_hwfn, bar_addr);
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+		   "bar_addr 0x%x, hw_addr 0x%x, val 0x%x\n",
+		   bar_addr, hw_addr, val);
+
+	return val;
+}
+
+static void qed_memcpy_hw(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  void *addr,
+			  u32 hw_addr,
+			  size_t n,
+			  bool to_device)
+{
+	u32 dw_count, *host_addr, hw_offset;
+	size_t quota, done = 0;
+	u32 __iomem *reg_addr;
+
+	while (done < n) {
+		quota = min_t(size_t, n - done,
+			      PXP_EXTERNAL_BAR_PF_WINDOW_SINGLE_SIZE);
+
+		qed_ptt_set_win(p_hwfn, p_ptt, hw_addr + done);
+		hw_offset = qed_ptt_get_bar_addr(p_ptt);
+
+		dw_count = quota / 4;
+		host_addr = (u32 *)((u8 *)addr + done);
+		reg_addr = (u32 __iomem *)REG_ADDR(p_hwfn, hw_offset);
+		if (to_device)
+			while (dw_count--)
+				DIRECT_REG_WR(reg_addr++, *host_addr++);
+		else
+			while (dw_count--)
+				*host_addr++ = DIRECT_REG_RD(reg_addr++);
+
+		done += quota;
+	}
+}
+
+void qed_memcpy_from(struct qed_hwfn *p_hwfn,
+		     struct qed_ptt *p_ptt,
+		     void *dest, u32 hw_addr, size_t n)
+{
+	DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+		   "hw_addr 0x%x, dest %p hw_addr 0x%x, size %lu\n",
+		   hw_addr, dest, hw_addr, (unsigned long)n);
+
+	qed_memcpy_hw(p_hwfn, p_ptt, dest, hw_addr, n, false);
+}
+
+void qed_memcpy_to(struct qed_hwfn *p_hwfn,
+		   struct qed_ptt *p_ptt,
+		   u32 hw_addr, void *src, size_t n)
+{
+	DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+		   "hw_addr 0x%x, hw_addr 0x%x, src %p size %lu\n",
+		   hw_addr, hw_addr, src, (unsigned long)n);
+
+	qed_memcpy_hw(p_hwfn, p_ptt, src, hw_addr, n, true);
+}
+
+void qed_fid_pretend(struct qed_hwfn *p_hwfn,
+		     struct qed_ptt *p_ptt,
+		     u16 fid)
+{
+	u16 control = 0;
+
+	SET_FIELD(control, PXP_PRETEND_CMD_IS_CONCRETE, 1);
+	SET_FIELD(control, PXP_PRETEND_CMD_PRETEND_FUNCTION, 1);
+
+	/* Every pretend undos previous pretends, including
+	 * previous port pretend.
+	 */
+	SET_FIELD(control, PXP_PRETEND_CMD_PORT, 0);
+	SET_FIELD(control, PXP_PRETEND_CMD_USE_PORT, 0);
+	SET_FIELD(control, PXP_PRETEND_CMD_PRETEND_PORT, 1);
+
+	if (!GET_FIELD(fid, PXP_CONCRETE_FID_VFVALID))
+		fid = GET_FIELD(fid, PXP_CONCRETE_FID_PFID);
+
+	p_ptt->pxp.pretend.control = cpu_to_le16(control);
+	p_ptt->pxp.pretend.fid.concrete_fid.fid = cpu_to_le16(fid);
+
+	REG_WR(p_hwfn,
+	       qed_ptt_config_addr(p_ptt) +
+	       offsetof(struct pxp_ptt_entry, pretend),
+	       *(u32 *)&p_ptt->pxp.pretend);
+}
+
+void qed_port_pretend(struct qed_hwfn *p_hwfn,
+		      struct qed_ptt *p_ptt,
+		      u8 port_id)
+{
+	u16 control = 0;
+
+	SET_FIELD(control, PXP_PRETEND_CMD_PORT, port_id);
+	SET_FIELD(control, PXP_PRETEND_CMD_USE_PORT, 1);
+	SET_FIELD(control, PXP_PRETEND_CMD_PRETEND_PORT, 1);
+
+	p_ptt->pxp.pretend.control = cpu_to_le16(control);
+
+	REG_WR(p_hwfn,
+	       qed_ptt_config_addr(p_ptt) +
+	       offsetof(struct pxp_ptt_entry, pretend),
+	       *(u32 *)&p_ptt->pxp.pretend);
+}
+
+void qed_port_unpretend(struct qed_hwfn *p_hwfn,
+			struct qed_ptt *p_ptt)
+{
+	u16 control = 0;
+
+	SET_FIELD(control, PXP_PRETEND_CMD_PORT, 0);
+	SET_FIELD(control, PXP_PRETEND_CMD_USE_PORT, 0);
+	SET_FIELD(control, PXP_PRETEND_CMD_PRETEND_PORT, 1);
+
+	p_ptt->pxp.pretend.control = cpu_to_le16(control);
+
+	REG_WR(p_hwfn,
+	       qed_ptt_config_addr(p_ptt) +
+	       offsetof(struct pxp_ptt_entry, pretend),
+	       *(u32 *)&p_ptt->pxp.pretend);
+}
+
+/* DMAE */
+static void qed_dmae_opcode(struct qed_hwfn *p_hwfn,
+			    const u8 is_src_type_grc,
+			    const u8 is_dst_type_grc,
+			    struct qed_dmae_params *p_params)
+{
+	u32 opcode = 0;
+	u16 opcodeB = 0;
+
+	/* Whether the source is the PCIe or the GRC.
+	 * 0- The source is the PCIe
+	 * 1- The source is the GRC.
+	 */
+	opcode |= (is_src_type_grc ? DMAE_CMD_SRC_MASK_GRC
+				   : DMAE_CMD_SRC_MASK_PCIE) <<
+		   DMAE_CMD_SRC_SHIFT;
+	opcode |= ((p_hwfn->rel_pf_id & DMAE_CMD_SRC_PF_ID_MASK) <<
+		   DMAE_CMD_SRC_PF_ID_SHIFT);
+
+	/* The destination of the DMA can be: 0-None 1-PCIe 2-GRC 3-None */
+	opcode |= (is_dst_type_grc ? DMAE_CMD_DST_MASK_GRC
+				   : DMAE_CMD_DST_MASK_PCIE) <<
+		   DMAE_CMD_DST_SHIFT;
+	opcode |= ((p_hwfn->rel_pf_id & DMAE_CMD_DST_PF_ID_MASK) <<
+		   DMAE_CMD_DST_PF_ID_SHIFT);
+
+	/* Whether to write a completion word to the completion destination:
+	 * 0-Do not write a completion word
+	 * 1-Write the completion word
+	 */
+	opcode |= (DMAE_CMD_COMP_WORD_EN_MASK << DMAE_CMD_COMP_WORD_EN_SHIFT);
+	opcode |= (DMAE_CMD_SRC_ADDR_RESET_MASK <<
+		   DMAE_CMD_SRC_ADDR_RESET_SHIFT);
+
+	if (p_params->flags & QED_DMAE_FLAG_COMPLETION_DST)
+		opcode |= (1 << DMAE_CMD_COMP_FUNC_SHIFT);
+
+	opcode |= (DMAE_CMD_ENDIANITY << DMAE_CMD_ENDIANITY_MODE_SHIFT);
+
+	opcode |= ((p_hwfn->port_id) << DMAE_CMD_PORT_ID_SHIFT);
+
+	/* reset source address in next go */
+	opcode |= (DMAE_CMD_SRC_ADDR_RESET_MASK <<
+		   DMAE_CMD_SRC_ADDR_RESET_SHIFT);
+
+	/* reset dest address in next go */
+	opcode |= (DMAE_CMD_DST_ADDR_RESET_MASK <<
+		   DMAE_CMD_DST_ADDR_RESET_SHIFT);
+
+	opcodeB |= (DMAE_CMD_SRC_VF_ID_MASK <<
+		    DMAE_CMD_SRC_VF_ID_SHIFT);
+
+	opcodeB |= (DMAE_CMD_DST_VF_ID_MASK <<
+		    DMAE_CMD_DST_VF_ID_SHIFT);
+
+	p_hwfn->dmae_info.p_dmae_cmd->opcode = cpu_to_le32(opcode);
+	p_hwfn->dmae_info.p_dmae_cmd->opcode_b = cpu_to_le16(opcodeB);
+}
+
+u32 qed_dmae_idx_to_go_cmd(u8 idx)
+{
+	/* All the DMAE 'go' registers form an array in internal memory */
+	return DMAE_REG_GO_C0 + (idx << 2);
+}
+
+static int
+qed_dmae_post_command(struct qed_hwfn *p_hwfn,
+		      struct qed_ptt *p_ptt)
+{
+	struct dmae_cmd *command = p_hwfn->dmae_info.p_dmae_cmd;
+	u8 idx_cmd = p_hwfn->dmae_info.channel, i;
+	int qed_status = 0;
+
+	/* verify address is not NULL */
+	if ((((command->dst_addr_lo == 0) && (command->dst_addr_hi == 0)) ||
+	     ((command->src_addr_lo == 0) && (command->src_addr_hi == 0)))) {
+		DP_NOTICE(p_hwfn,
+			  "source or destination address 0 idx_cmd=%d\n"
+			  "opcode = [0x%08x,0x%04x] len=0x%x src=0x%x:%x dst=0x%x:%x\n",
+			   idx_cmd,
+			   le32_to_cpu(command->opcode),
+			   le16_to_cpu(command->opcode_b),
+			   le16_to_cpu(command->length),
+			   le32_to_cpu(command->src_addr_hi),
+			   le32_to_cpu(command->src_addr_lo),
+			   le32_to_cpu(command->dst_addr_hi),
+			   le32_to_cpu(command->dst_addr_lo));
+
+		return -EINVAL;
+	}
+
+	DP_VERBOSE(p_hwfn,
+		   NETIF_MSG_HW,
+		   "Posting DMAE command [idx %d]: opcode = [0x%08x,0x%04x] len=0x%x src=0x%x:%x dst=0x%x:%x\n",
+		   idx_cmd,
+		   le32_to_cpu(command->opcode),
+		   le16_to_cpu(command->opcode_b),
+		   le16_to_cpu(command->length),
+		   le32_to_cpu(command->src_addr_hi),
+		   le32_to_cpu(command->src_addr_lo),
+		   le32_to_cpu(command->dst_addr_hi),
+		   le32_to_cpu(command->dst_addr_lo));
+
+	/* Copy the command to DMAE - need to do it before every call
+	 * for source/dest address no reset.
+	 * The first 9 DWs are the command registers, the 10 DW is the
+	 * GO register, and the rest are result registers
+	 * (which are read only by the client).
+	 */
+	for (i = 0; i < DMAE_CMD_SIZE; i++) {
+		u32 data = (i < DMAE_CMD_SIZE_TO_FILL) ?
+			   *(((u32 *)command) + i) : 0;
+
+		qed_wr(p_hwfn, p_ptt,
+		       DMAE_REG_CMD_MEM +
+		       (idx_cmd * DMAE_CMD_SIZE * sizeof(u32)) +
+		       (i * sizeof(u32)), data);
+	}
+
+	qed_wr(p_hwfn, p_ptt,
+	       qed_dmae_idx_to_go_cmd(idx_cmd),
+	       DMAE_GO_VALUE);
+
+	return qed_status;
+}
+
+int qed_dmae_info_alloc(struct qed_hwfn *p_hwfn)
+{
+	dma_addr_t *p_addr = &p_hwfn->dmae_info.completion_word_phys_addr;
+	struct dmae_cmd **p_cmd	= &p_hwfn->dmae_info.p_dmae_cmd;
+	u32 **p_buff = &p_hwfn->dmae_info.p_intermediate_buffer;
+	u32 **p_comp = &p_hwfn->dmae_info.p_completion_word;
+
+	*p_comp = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				     sizeof(u32),
+				     p_addr,
+				     GFP_KERNEL);
+	if (!*p_comp) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `p_completion_word'\n");
+		qed_dmae_info_free(p_hwfn);
+		return -ENOMEM;
+	}
+
+	p_addr = &p_hwfn->dmae_info.dmae_cmd_phys_addr;
+	*p_cmd = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				    sizeof(struct dmae_cmd),
+				    p_addr, GFP_KERNEL);
+	if (!*p_cmd) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct dmae_cmd'\n");
+		qed_dmae_info_free(p_hwfn);
+		return -ENOMEM;
+	}
+
+	p_addr	= &p_hwfn->dmae_info.intermediate_buffer_phys_addr;
+	*p_buff = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				     sizeof(u32) * DMAE_MAX_RW_SIZE,
+				     p_addr, GFP_KERNEL);
+	if (!*p_buff) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `intermediate_buffer'\n");
+		qed_dmae_info_free(p_hwfn);
+		return -ENOMEM;
+	}
+
+	p_hwfn->dmae_info.channel = p_hwfn->rel_pf_id;
+
+	return 0;
+}
+
+void qed_dmae_info_free(struct qed_hwfn *p_hwfn)
+{
+	dma_addr_t p_phys;
+
+	/* Just make sure no one is in the middle */
+	mutex_lock(&p_hwfn->dmae_info.mutex);
+
+	if (p_hwfn->dmae_info.p_completion_word) {
+		p_phys = p_hwfn->dmae_info.completion_word_phys_addr;
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  sizeof(u32),
+				  p_hwfn->dmae_info.p_completion_word,
+				  p_phys);
+		p_hwfn->dmae_info.p_completion_word = NULL;
+	}
+
+	if (p_hwfn->dmae_info.p_dmae_cmd) {
+		p_phys = p_hwfn->dmae_info.dmae_cmd_phys_addr;
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  sizeof(struct dmae_cmd),
+				  p_hwfn->dmae_info.p_dmae_cmd,
+				  p_phys);
+		p_hwfn->dmae_info.p_dmae_cmd = NULL;
+	}
+
+	if (p_hwfn->dmae_info.p_intermediate_buffer) {
+		p_phys = p_hwfn->dmae_info.intermediate_buffer_phys_addr;
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  sizeof(u32) * DMAE_MAX_RW_SIZE,
+				  p_hwfn->dmae_info.p_intermediate_buffer,
+				  p_phys);
+		p_hwfn->dmae_info.p_intermediate_buffer = NULL;
+	}
+
+	mutex_unlock(&p_hwfn->dmae_info.mutex);
+}
+
+static int qed_dmae_operation_wait(struct qed_hwfn *p_hwfn)
+{
+	u32 wait_cnt = 0;
+	u32 wait_cnt_limit = 10000;
+
+	int qed_status = 0;
+
+	barrier();
+	while (*p_hwfn->dmae_info.p_completion_word != DMAE_COMPLETION_VAL) {
+		udelay(DMAE_MIN_WAIT_TIME);
+		if (++wait_cnt > wait_cnt_limit) {
+			DP_NOTICE(p_hwfn->cdev,
+				  "Timed-out waiting for operation to complete. Completion word is 0x%08x expected 0x%08x.\n",
+				  *p_hwfn->dmae_info.p_completion_word,
+				 DMAE_COMPLETION_VAL);
+			qed_status = -EBUSY;
+			break;
+		}
+
+		/* to sync the completion_word since we are not
+		 * using the volatile keyword for p_completion_word
+		 */
+		barrier();
+	}
+
+	if (qed_status == 0)
+		*p_hwfn->dmae_info.p_completion_word = 0;
+
+	return qed_status;
+}
+
+static int qed_dmae_execute_sub_operation(struct qed_hwfn *p_hwfn,
+					  struct qed_ptt *p_ptt,
+					  u64 src_addr,
+					  u64 dst_addr,
+					  u8 src_type,
+					  u8 dst_type,
+					  u32 length)
+{
+	dma_addr_t phys = p_hwfn->dmae_info.intermediate_buffer_phys_addr;
+	struct dmae_cmd *cmd = p_hwfn->dmae_info.p_dmae_cmd;
+	int qed_status = 0;
+
+	switch (src_type) {
+	case QED_DMAE_ADDRESS_GRC:
+	case QED_DMAE_ADDRESS_HOST_PHYS:
+		cmd->src_addr_hi = cpu_to_le32(upper_32_bits(src_addr));
+		cmd->src_addr_lo = cpu_to_le32(lower_32_bits(src_addr));
+		break;
+	/* for virtual source addresses we use the intermediate buffer. */
+	case QED_DMAE_ADDRESS_HOST_VIRT:
+		cmd->src_addr_hi = cpu_to_le32(upper_32_bits(phys));
+		cmd->src_addr_lo = cpu_to_le32(lower_32_bits(phys));
+		memcpy(&p_hwfn->dmae_info.p_intermediate_buffer[0],
+		       (void *)(uintptr_t)src_addr,
+		       length * sizeof(u32));
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	switch (dst_type) {
+	case QED_DMAE_ADDRESS_GRC:
+	case QED_DMAE_ADDRESS_HOST_PHYS:
+		cmd->dst_addr_hi = cpu_to_le32(upper_32_bits(dst_addr));
+		cmd->dst_addr_lo = cpu_to_le32(lower_32_bits(dst_addr));
+		break;
+	/* for virtual source addresses we use the intermediate buffer. */
+	case QED_DMAE_ADDRESS_HOST_VIRT:
+		cmd->dst_addr_hi = cpu_to_le32(upper_32_bits(phys));
+		cmd->dst_addr_lo = cpu_to_le32(lower_32_bits(phys));
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	cmd->length = cpu_to_le16((u16)length);
+
+	qed_dmae_post_command(p_hwfn, p_ptt);
+
+	qed_status = qed_dmae_operation_wait(p_hwfn);
+
+	if (qed_status) {
+		DP_NOTICE(p_hwfn,
+			  "qed_dmae_host2grc: Wait Failed. source_addr 0x%llx, grc_addr 0x%llx, size_in_dwords 0x%x\n",
+			  src_addr,
+			  dst_addr,
+			  length);
+		return qed_status;
+	}
+
+	if (dst_type == QED_DMAE_ADDRESS_HOST_VIRT)
+		memcpy((void *)(uintptr_t)(dst_addr),
+		       &p_hwfn->dmae_info.p_intermediate_buffer[0],
+		       length * sizeof(u32));
+
+	return 0;
+}
+
+static int qed_dmae_execute_command(struct qed_hwfn *p_hwfn,
+				    struct qed_ptt *p_ptt,
+				    u64 src_addr, u64 dst_addr,
+				    u8 src_type, u8 dst_type,
+				    u32 size_in_dwords,
+				    struct qed_dmae_params *p_params)
+{
+	dma_addr_t phys = p_hwfn->dmae_info.completion_word_phys_addr;
+	u16 length_cur = 0, i = 0, cnt_split = 0, length_mod = 0;
+	struct dmae_cmd *cmd = p_hwfn->dmae_info.p_dmae_cmd;
+	u64 src_addr_split = 0, dst_addr_split = 0;
+	u16 length_limit = DMAE_MAX_RW_SIZE;
+	int qed_status	= 0;
+	u32 offset = 0;
+
+	qed_dmae_opcode(p_hwfn,
+			(src_type == QED_DMAE_ADDRESS_GRC),
+			(dst_type == QED_DMAE_ADDRESS_GRC),
+			p_params);
+
+	cmd->comp_addr_lo = cpu_to_le32(lower_32_bits(phys));
+	cmd->comp_addr_hi = cpu_to_le32(upper_32_bits(phys));
+	cmd->comp_val = cpu_to_le32(DMAE_COMPLETION_VAL);
+
+	/* Check if the grc_addr is valid like < MAX_GRC_OFFSET */
+	cnt_split = size_in_dwords / length_limit;
+	length_mod = size_in_dwords % length_limit;
+
+	src_addr_split = src_addr;
+	dst_addr_split = dst_addr;
+
+	for (i = 0; i <= cnt_split; i++) {
+		offset = length_limit * i;
+
+		if (!(p_params->flags & QED_DMAE_FLAG_RW_REPL_SRC)) {
+			if (src_type == QED_DMAE_ADDRESS_GRC)
+				src_addr_split = src_addr + offset;
+			else
+				src_addr_split = src_addr + (offset * 4);
+		}
+
+		if (dst_type == QED_DMAE_ADDRESS_GRC)
+			dst_addr_split = dst_addr + offset;
+		else
+			dst_addr_split = dst_addr + (offset * 4);
+
+		length_cur = (cnt_split == i) ? length_mod : length_limit;
+
+		/* might be zero on last iteration */
+		if (!length_cur)
+			continue;
+
+		qed_status = qed_dmae_execute_sub_operation(p_hwfn,
+							    p_ptt,
+							    src_addr_split,
+							    dst_addr_split,
+							    src_type,
+							    dst_type,
+							    length_cur);
+		if (qed_status) {
+			DP_NOTICE(p_hwfn,
+				  "qed_dmae_execute_sub_operation Failed with error 0x%x. source_addr 0x%llx, destination addr 0x%llx, size_in_dwords 0x%x\n",
+				  qed_status,
+				  src_addr,
+				  dst_addr,
+				  length_cur);
+			break;
+		}
+	}
+
+	return qed_status;
+}
+
+int qed_dmae_host2grc(struct qed_hwfn *p_hwfn,
+		      struct qed_ptt *p_ptt,
+		      u64 source_addr,
+		      u32 grc_addr,
+		      u32 size_in_dwords,
+		      u32 flags)
+{
+	u32 grc_addr_in_dw = grc_addr / sizeof(u32);
+	struct qed_dmae_params params;
+	int rc;
+
+	memset(&params, 0, sizeof(struct qed_dmae_params));
+	params.flags = flags;
+
+	mutex_lock(&p_hwfn->dmae_info.mutex);
+
+	rc = qed_dmae_execute_command(p_hwfn, p_ptt, source_addr,
+				      grc_addr_in_dw,
+				      QED_DMAE_ADDRESS_HOST_VIRT,
+				      QED_DMAE_ADDRESS_GRC,
+				      size_in_dwords, &params);
+
+	mutex_unlock(&p_hwfn->dmae_info.mutex);
+
+	return rc;
+}
+
+u16 qed_get_qm_pq(struct qed_hwfn		*p_hwfn,
+		  enum protocol_type		proto,
+		  union qed_qm_pq_params	*p_params)
+{
+	u16 pq_id = 0;
+
+	if ((proto == PROTOCOLID_CORE || proto == PROTOCOLID_ETH) &&
+	    !p_params) {
+		DP_NOTICE(p_hwfn,
+			  "Protocol %d received NULL PQ params\n",
+			  proto);
+		return 0;
+	}
+
+	switch (proto) {
+	case PROTOCOLID_CORE:
+		if (p_params->core.tc == LB_TC)
+			pq_id = p_hwfn->qm_info.pure_lb_pq;
+		else
+			pq_id = p_hwfn->qm_info.offload_pq;
+		break;
+	case PROTOCOLID_ETH:
+		pq_id = p_params->eth.tc;
+		break;
+	default:
+		pq_id = 0;
+	}
+
+	pq_id = CM_TX_PQ_BASE + pq_id + RESC_START(p_hwfn, QED_PQ);
+
+	return pq_id;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.h b/drivers/net/ethernet/qlogic/qed/qed_hw.h
new file mode 100644
index 0000000..8c486c2
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.h
@@ -0,0 +1,266 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_HW_H
+#define _QED_HW_H
+#include <linux/types.h>
+#include <linux/bitops.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include "qed.h"
+#include "qed_dev_api.h"
+
+/* Forward decleration */
+struct qed_ptt;
+
+enum reserved_ptts {
+	RESERVED_PTT_EDIAG,
+	RESERVED_PTT_USER_SPACE,
+	RESERVED_PTT_MAIN,
+	RESERVED_PTT_DPC,
+	RESERVED_PTT_MAX
+};
+
+enum _dmae_cmd_dst_mask {
+	DMAE_CMD_DST_MASK_NONE	= 0,
+	DMAE_CMD_DST_MASK_PCIE	= 1,
+	DMAE_CMD_DST_MASK_GRC	= 2
+};
+
+enum _dmae_cmd_src_mask {
+	DMAE_CMD_SRC_MASK_PCIE	= 0,
+	DMAE_CMD_SRC_MASK_GRC	= 1
+};
+
+enum _dmae_cmd_crc_mask {
+	DMAE_CMD_COMP_CRC_EN_MASK_NONE	= 0,
+	DMAE_CMD_COMP_CRC_EN_MASK_SET	= 1
+};
+
+/* definitions for DMA constants */
+#define DMAE_GO_VALUE   0x1
+
+#define DMAE_COMPLETION_VAL     0xD1AE
+#define DMAE_CMD_ENDIANITY      0x2
+
+#define DMAE_CMD_SIZE   14
+#define DMAE_CMD_SIZE_TO_FILL   (DMAE_CMD_SIZE - 5)
+#define DMAE_MIN_WAIT_TIME      0x2
+#define DMAE_MAX_CLIENTS        32
+
+/**
+ * @brief qed_gtt_init - Initialize GTT windows
+ *
+ * @param p_hwfn
+ */
+void qed_gtt_init(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_ptt_invalidate - Forces all ptt entries to be re-configured
+ *
+ * @param p_hwfn
+ */
+void qed_ptt_invalidate(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_ptt_pool_alloc - Allocate and initialize PTT pool
+ *
+ * @param p_hwfn
+ *
+ * @return struct _qed_status - success (0), negative - error.
+ */
+int qed_ptt_pool_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_ptt_pool_free -
+ *
+ * @param p_hwfn
+ */
+void qed_ptt_pool_free(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_ptt_get_hw_addr - Get PTT's GRC/HW address
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ *
+ * @return u32
+ */
+u32 qed_ptt_get_hw_addr(struct qed_hwfn *p_hwfn,
+			struct qed_ptt	*p_ptt);
+
+/**
+ * @brief qed_ptt_get_bar_addr - Get PPT's external BAR address
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ *
+ * @return u32
+ */
+u32 qed_ptt_get_bar_addr(struct qed_ptt *p_ptt);
+
+/**
+ * @brief qed_ptt_set_win - Set PTT Window's GRC BAR address
+ *
+ * @param p_hwfn
+ * @param new_hw_addr
+ * @param p_ptt
+ */
+void qed_ptt_set_win(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt,
+		     u32		new_hw_addr);
+
+/**
+ * @brief qed_get_reserved_ptt - Get a specific reserved PTT
+ *
+ * @param p_hwfn
+ * @param ptt_idx
+ *
+ * @return struct qed_ptt *
+ */
+struct qed_ptt *qed_get_reserved_ptt(struct qed_hwfn	*p_hwfn,
+				     enum reserved_ptts ptt_idx);
+
+/**
+ * @brief qed_wr - Write value to BAR using the given ptt
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param val
+ * @param hw_addr
+ */
+void qed_wr(struct qed_hwfn	*p_hwfn,
+	    struct qed_ptt	*p_ptt,
+	    u32			hw_addr,
+	    u32			val);
+
+/**
+ * @brief qed_rd - Read value from BAR using the given ptt
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param val
+ * @param hw_addr
+ */
+u32 qed_rd(struct qed_hwfn	*p_hwfn,
+	   struct qed_ptt	*p_ptt,
+	   u32			hw_addr);
+
+/**
+ * @brief qed_memcpy_from - copy n bytes from BAR using the given
+ *        ptt
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param dest
+ * @param hw_addr
+ * @param n
+ */
+void qed_memcpy_from(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt,
+		     void		*dest,
+		     u32		hw_addr,
+		     size_t		n);
+
+/**
+ * @brief qed_memcpy_to - copy n bytes to BAR using the given
+ *        ptt
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param hw_addr
+ * @param src
+ * @param n
+ */
+void qed_memcpy_to(struct qed_hwfn	*p_hwfn,
+		   struct qed_ptt	*p_ptt,
+		   u32			hw_addr,
+		   void			*src,
+		   size_t		n);
+/**
+ * @brief qed_fid_pretend - pretend to another function when
+ *        accessing the ptt window. There is no way to unpretend
+ *        a function. The only way to cancel a pretend is to
+ *        pretend back to the original function.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param fid - fid field of pxp_pretend structure. Can contain
+ *            either pf / vf, port/path fields are don't care.
+ */
+void qed_fid_pretend(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt,
+		     u16		fid);
+
+/**
+ * @brief qed_port_pretend - pretend to another port when
+ *        accessing the ptt window
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param port_id - the port to pretend to
+ */
+void qed_port_pretend(struct qed_hwfn	*p_hwfn,
+		      struct qed_ptt	*p_ptt,
+		      u8		port_id);
+
+/**
+ * @brief qed_port_unpretend - cancel any previously set port
+ *        pretend
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ */
+void qed_port_unpretend(struct qed_hwfn *p_hwfn,
+			struct qed_ptt	*p_ptt);
+
+/**
+ * @brief qed_dmae_idx_to_go_cmd - map the idx to dmae cmd
+ * this is declared here since other files will require it.
+ * @param idx
+ */
+u32 qed_dmae_idx_to_go_cmd(u8 idx);
+
+/**
+ * @brief qed_dmae_info_alloc - Init the dmae_info structure
+ * which is part of p_hwfn.
+ * @param p_hwfn
+ */
+int qed_dmae_info_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_dmae_info_free - Free the dmae_info structure
+ * which is part of p_hwfn
+ *
+ * @param p_hwfn
+ */
+void qed_dmae_info_free(struct qed_hwfn *p_hwfn);
+
+union qed_qm_pq_params {
+	struct {
+		u8 q_idx;
+	}	iscsi;
+
+	struct {
+		u8 tc;
+	}	core;
+
+	struct {
+		u8	is_vf;
+		u8	vf_id;
+		u8	tc;
+	}	eth;
+};
+
+u16 qed_get_qm_pq(struct qed_hwfn		*p_hwfn,
+		  enum protocol_type		proto,
+		  union qed_qm_pq_params	*params);
+
+int qed_init_fw_data(struct qed_dev	*cdev,
+		     const u8		*fw_data);
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
new file mode 100644
index 0000000..c622ffb
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
@@ -0,0 +1,882 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_init_ops.h"
+#include "qed_reg_addr.h"
+enum cminterface {
+	MCM_SEC,
+	MCM_PRI,
+	UCM_SEC,
+	UCM_PRI,
+	TCM_SEC,
+	TCM_PRI,
+	YCM_SEC,
+	YCM_PRI,
+	XCM_SEC,
+	XCM_PRI,
+	NUM_OF_CM_INTERFACES
+};
+
+/* general constants */
+#define QM_PQ_ELEMENT_SIZE                      4 /* in bytes */
+#define QM_PQ_MEM_4KB(pq_size)	(pq_size ? DIV_ROUND_UP((pq_size + \
+							 1) *	\
+							 QM_PQ_ELEMENT_SIZE, \
+							0x1000) : 0)
+#define QM_PQ_SIZE_256B(pq_size)	(pq_size ? DIV_ROUND_UP(pq_size, \
+								0x100) - 1 : 0)
+#define QM_INVALID_PQ_ID                        0xffff
+/* feature enable */
+#define QM_BYPASS_EN                            1
+#define QM_BYTE_CRD_EN                          1
+/* other PQ constants */
+#define QM_OTHER_PQS_PER_PF                     4
+/* WFQ constants */
+#define QM_WFQ_UPPER_BOUND		6250000
+#define QM_WFQ_VP_PQ_VOQ_SHIFT          0
+#define QM_WFQ_VP_PQ_PF_SHIFT           5
+#define QM_WFQ_INC_VAL(weight)          ((weight) * 0x9000)
+#define QM_WFQ_MAX_INC_VAL                      4375000
+#define QM_WFQ_INIT_CRD(inc_val)        (2 * (inc_val))
+/* RL constants */
+#define QM_RL_UPPER_BOUND                       6250000
+#define QM_RL_PERIOD                            5               /* in us */
+#define QM_RL_PERIOD_CLK_25M            (25 * QM_RL_PERIOD)
+#define QM_RL_INC_VAL(rate)		max_t(u32,	\
+					      (((rate ? rate : 1000000)	\
+						* QM_RL_PERIOD) / 8), 1)
+#define QM_RL_MAX_INC_VAL                       4375000
+/* AFullOprtnstcCrdMask constants */
+#define QM_OPPOR_LINE_VOQ_DEF           1
+#define QM_OPPOR_FW_STOP_DEF            0
+#define QM_OPPOR_PQ_EMPTY_DEF           1
+#define EAGLE_WORKAROUND_TC                     7
+/* Command Queue constants */
+#define PBF_CMDQ_PURE_LB_LINES                          150
+#define PBF_CMDQ_EAGLE_WORKAROUND_LINES         8
+#define PBF_CMDQ_LINES_RT_OFFSET(voq)           (		 \
+		PBF_REG_YCMD_QS_NUM_LINES_VOQ0_RT_OFFSET + voq * \
+		(PBF_REG_YCMD_QS_NUM_LINES_VOQ1_RT_OFFSET -	 \
+		 PBF_REG_YCMD_QS_NUM_LINES_VOQ0_RT_OFFSET))
+#define PBF_BTB_GUARANTEED_RT_OFFSET(voq)       (	      \
+		PBF_REG_BTB_GUARANTEED_VOQ0_RT_OFFSET + voq * \
+		(PBF_REG_BTB_GUARANTEED_VOQ1_RT_OFFSET -      \
+		 PBF_REG_BTB_GUARANTEED_VOQ0_RT_OFFSET))
+#define QM_VOQ_LINE_CRD(pbf_cmd_lines)          ((((pbf_cmd_lines) - \
+						   4) *		     \
+						  2) | QM_LINE_CRD_REG_SIGN_BIT)
+/* BTB: blocks constants (block size = 256B) */
+#define BTB_JUMBO_PKT_BLOCKS            38
+#define BTB_HEADROOM_BLOCKS                     BTB_JUMBO_PKT_BLOCKS
+#define BTB_EAGLE_WORKAROUND_BLOCKS     4
+#define BTB_PURE_LB_FACTOR                      10
+#define BTB_PURE_LB_RATIO                       7
+/* QM stop command constants */
+#define QM_STOP_PQ_MASK_WIDTH                   32
+#define QM_STOP_CMD_ADDR                                0x2
+#define QM_STOP_CMD_STRUCT_SIZE                 2
+#define QM_STOP_CMD_PAUSE_MASK_OFFSET   0
+#define QM_STOP_CMD_PAUSE_MASK_SHIFT    0
+#define QM_STOP_CMD_PAUSE_MASK_MASK             -1
+#define QM_STOP_CMD_GROUP_ID_OFFSET             1
+#define QM_STOP_CMD_GROUP_ID_SHIFT              16
+#define QM_STOP_CMD_GROUP_ID_MASK               15
+#define QM_STOP_CMD_PQ_TYPE_OFFSET              1
+#define QM_STOP_CMD_PQ_TYPE_SHIFT               24
+#define QM_STOP_CMD_PQ_TYPE_MASK                1
+#define QM_STOP_CMD_MAX_POLL_COUNT              100
+#define QM_STOP_CMD_POLL_PERIOD_US              500
+/* QM command macros */
+#define QM_CMD_STRUCT_SIZE(cmd)			cmd ## \
+	_STRUCT_SIZE
+#define QM_CMD_SET_FIELD(var, cmd, field,				  \
+			 value)        SET_FIELD(var[cmd ## _ ## field ## \
+						     _OFFSET],		  \
+						 cmd ## _ ## field,	  \
+						 value)
+/* QM: VOQ macros */
+#define PHYS_VOQ(port, tc, max_phy_tcs_pr_port)	((port) *	\
+						 (max_phy_tcs_pr_port) \
+						 + (tc))
+#define LB_VOQ(port)				( \
+		MAX_PHYS_VOQS + (port))
+#define VOQ(port, tc, max_phy_tcs_pr_port)	\
+	((tc) <		\
+	 LB_TC ? PHYS_VOQ(port,		\
+			  tc,			 \
+			  max_phy_tcs_pr_port) \
+		: LB_VOQ(port))
+/******************** INTERNAL IMPLEMENTATION *********************/
+/* Prepare PF RL enable/disable runtime init values */
+static void qed_enable_pf_rl(struct qed_hwfn	*p_hwfn,
+			     bool		pf_rl_en)
+{
+	STORE_RT_REG(p_hwfn, QM_REG_RLPFENABLE_RT_OFFSET, pf_rl_en ? 1 : 0);
+	if (pf_rl_en) {
+		/* enable RLs for all VOQs */
+		STORE_RT_REG(p_hwfn, QM_REG_RLPFVOQENABLE_RT_OFFSET,
+			     (1 << MAX_NUM_VOQS) - 1);
+		/* write RL period */
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_RLPFPERIOD_RT_OFFSET,
+			     QM_RL_PERIOD_CLK_25M);
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_RLPFPERIODTIMER_RT_OFFSET,
+			     QM_RL_PERIOD_CLK_25M);
+		/* set credit threshold for QM bypass flow */
+		if (QM_BYPASS_EN)
+			STORE_RT_REG(p_hwfn,
+				     QM_REG_AFULLQMBYPTHRPFRL_RT_OFFSET,
+				     QM_RL_UPPER_BOUND);
+	}
+}
+
+/* Prepare PF WFQ enable/disable runtime init values */
+static void qed_enable_pf_wfq(struct qed_hwfn	*p_hwfn,
+			      bool		pf_wfq_en)
+{
+	STORE_RT_REG(p_hwfn, QM_REG_WFQPFENABLE_RT_OFFSET, pf_wfq_en ? 1 : 0);
+	/* set credit threshold for QM bypass flow */
+	if (pf_wfq_en && QM_BYPASS_EN)
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_AFULLQMBYPTHRPFWFQ_RT_OFFSET,
+			     QM_WFQ_UPPER_BOUND);
+}
+
+/* Prepare VPORT RL enable/disable runtime init values */
+static void qed_enable_vport_rl(struct qed_hwfn *p_hwfn,
+				bool		vport_rl_en)
+{
+	STORE_RT_REG(p_hwfn, QM_REG_RLGLBLENABLE_RT_OFFSET,
+		     vport_rl_en ? 1 : 0);
+	if (vport_rl_en) {
+		/* write RL period (use timer 0 only) */
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_RLGLBLPERIOD_0_RT_OFFSET,
+			     QM_RL_PERIOD_CLK_25M);
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_RLGLBLPERIODTIMER_0_RT_OFFSET,
+			     QM_RL_PERIOD_CLK_25M);
+		/* set credit threshold for QM bypass flow */
+		if (QM_BYPASS_EN)
+			STORE_RT_REG(p_hwfn,
+				     QM_REG_AFULLQMBYPTHRGLBLRL_RT_OFFSET,
+				     QM_RL_UPPER_BOUND);
+	}
+}
+
+/* Prepare VPORT WFQ enable/disable runtime init values */
+static void qed_enable_vport_wfq(struct qed_hwfn	*p_hwfn,
+				 bool			vport_wfq_en)
+{
+	STORE_RT_REG(p_hwfn, QM_REG_WFQVPENABLE_RT_OFFSET,
+		     vport_wfq_en ? 1 : 0);
+	/* set credit threshold for QM bypass flow */
+	if (vport_wfq_en && QM_BYPASS_EN)
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_AFULLQMBYPTHRVPWFQ_RT_OFFSET,
+			     QM_WFQ_UPPER_BOUND);
+}
+
+/* Prepare runtime init values to allocate PBF command queue lines for
+ * the specified VOQ
+ */
+static void qed_cmdq_lines_voq_rt_init(struct qed_hwfn	*p_hwfn,
+				       u8		voq,
+				       u16		cmdq_lines)
+{
+	u32	qm_line_crd;
+
+	/* In A0 - Limit the size of pbf queue so that only 511 commands with
+	 * the minimum size of 4 (FCoE minimum size)
+	 */
+	bool	is_bb_a0 = QED_IS_BB_A0(p_hwfn->cdev);
+
+	if (is_bb_a0)
+		cmdq_lines = min_t(u32, cmdq_lines, 1022);
+	qm_line_crd = QM_VOQ_LINE_CRD(cmdq_lines);
+	OVERWRITE_RT_REG(p_hwfn, PBF_CMDQ_LINES_RT_OFFSET(voq),
+			 (u32)cmdq_lines);
+	STORE_RT_REG(p_hwfn, QM_REG_VOQCRDLINE_RT_OFFSET + voq, qm_line_crd);
+	STORE_RT_REG(p_hwfn, QM_REG_VOQINITCRDLINE_RT_OFFSET + voq,
+		     qm_line_crd);
+}
+
+/* Prepare runtime init values to allocate PBF command queue lines. */
+static void qed_cmdq_lines_rt_init(
+	struct qed_hwfn			*p_hwfn,
+	u8
+	max_ports_per_engine,
+	u8
+	max_phys_tcs_per_port,
+	struct init_qm_port_params	port_params[
+		MAX_NUM_PORTS])
+{
+	u8	tc, voq, port_id;
+
+	/* clear PBF lines for all VOQs */
+	for (voq = 0; voq < MAX_NUM_VOQS; voq++)
+		STORE_RT_REG(p_hwfn, PBF_CMDQ_LINES_RT_OFFSET(voq), 0);
+	for (port_id = 0; port_id < max_ports_per_engine; port_id++) {
+		if (port_params[port_id].active) {
+			u16 phys_lines, phys_lines_per_tc;
+
+			/* find #lines to divide between the active
+			 * physical TCs.
+			 */
+			phys_lines = port_params[port_id].num_pbf_cmd_lines -
+				PBF_CMDQ_PURE_LB_LINES;
+			/* find #lines per active physical TC */
+			phys_lines_per_tc = phys_lines /
+				port_params[port_id].num_active_phys_tcs;
+			/* init registers per active TC */
+			for (tc = 0;
+			     tc < port_params[port_id].num_active_phys_tcs;
+			     tc++) {
+				voq = PHYS_VOQ(port_id,
+					       tc,
+					       max_phys_tcs_per_port);
+				qed_cmdq_lines_voq_rt_init(p_hwfn,
+							   voq,
+							   phys_lines_per_tc);
+			}
+			/* init registers for pure LB TC */
+			qed_cmdq_lines_voq_rt_init(p_hwfn, LB_VOQ(
+							   port_id),
+						   PBF_CMDQ_PURE_LB_LINES);
+		}
+	}
+}
+
+static void qed_btb_blocks_rt_init(
+	struct qed_hwfn			*p_hwfn,
+	u8
+	max_ports_per_engine,
+	u8
+	max_phys_tcs_per_port,
+	struct init_qm_port_params	port_params[
+		MAX_NUM_PORTS])
+{
+	u8	tc, voq, port_id;
+	u32	usable_blocks, pure_lb_blocks, phys_blocks;
+
+	for (port_id = 0; port_id < max_ports_per_engine; port_id++) {
+		if (port_params[port_id].active) {
+			u32 temp;
+
+			/* subtract headroom blocks */
+			usable_blocks = port_params[port_id].num_btb_blocks -
+				BTB_HEADROOM_BLOCKS;
+			/* find blocks per physical TC. use factor to avoid
+			 * floating arithmethic.
+			 */
+			pure_lb_blocks =
+				(usable_blocks *
+				 BTB_PURE_LB_FACTOR) /
+				(port_params[port_id].num_active_phys_tcs *
+				 BTB_PURE_LB_FACTOR + BTB_PURE_LB_RATIO);
+			pure_lb_blocks	= max_t(
+					u32,
+					BTB_JUMBO_PKT_BLOCKS,
+					pure_lb_blocks /
+					BTB_PURE_LB_FACTOR);
+			phys_blocks	=
+				(usable_blocks -
+				 pure_lb_blocks) /
+				port_params[port_id].num_active_phys_tcs;
+			/* init physical TCs */
+			for (tc = 0;
+			     tc < port_params[port_id].num_active_phys_tcs;
+			     tc++) {
+				voq = PHYS_VOQ(port_id,
+					       tc,
+					       max_phys_tcs_per_port);
+				STORE_RT_REG(p_hwfn,
+					     PBF_BTB_GUARANTEED_RT_OFFSET(voq),
+					     phys_blocks);
+			}
+
+			temp = LB_VOQ(port_id);
+			/* init pure LB TC */
+			STORE_RT_REG(p_hwfn,
+				     PBF_BTB_GUARANTEED_RT_OFFSET(temp),
+				     pure_lb_blocks);
+		}
+	}
+}
+
+/* Prepare Tx PQ mapping runtime init values for the specified PF */
+static void qed_tx_pq_map_rt_init(
+	struct qed_hwfn			*p_hwfn,
+	struct qed_ptt			*p_ptt,
+	u8				port_id,
+	u8				pf_id,
+	u8
+	max_phys_tcs_per_port,
+	bool				is_first_pf,
+	u32				num_pf_cids,
+	u32				num_vf_cids,
+	u16				start_pq,
+	u16				num_pf_pqs,
+	u16				num_vf_pqs,
+	u8				start_vport,
+	u32
+	base_mem_addr_4kb,
+	struct init_qm_pq_params	*pq_params,
+	struct init_qm_vport_params	*vport_params)
+{
+	u16	i, pq_id, pq_group;
+	u16	num_pqs		= num_pf_pqs + num_vf_pqs;
+	u16	first_pq_group	= start_pq / QM_PF_QUEUE_GROUP_SIZE;
+	u16	last_pq_group	=
+		(start_pq + num_pqs - 1) / QM_PF_QUEUE_GROUP_SIZE;
+	bool	is_bb_a0 = QED_IS_BB_A0(p_hwfn->cdev);
+
+	/* a bit per Tx PQ indicating if the PQ is associated with a VF */
+	u32	tx_pq_vf_mask[MAX_QM_TX_QUEUES /
+			      QM_PF_QUEUE_GROUP_SIZE] = { 0 };
+	u32	tx_pq_vf_mask_width
+		= is_bb_a0 ? 32 : QM_PF_QUEUE_GROUP_SIZE;
+	u32	num_tx_pq_vf_masks
+		= MAX_QM_TX_QUEUES / tx_pq_vf_mask_width;
+	u32	pq_mem_4kb
+		= QM_PQ_MEM_4KB(num_pf_cids);
+	u32	vport_pq_mem_4kb
+		= QM_PQ_MEM_4KB(num_vf_cids);
+	u32	mem_addr_4kb
+		= base_mem_addr_4kb;
+
+	/* set mapping from PQ group to PF */
+	for (pq_group = first_pq_group; pq_group <= last_pq_group; pq_group++)
+		STORE_RT_REG(p_hwfn, QM_REG_PQTX2PF_0_RT_OFFSET + pq_group,
+			     (u32)(pf_id));
+	/* set PQ sizes */
+	STORE_RT_REG(p_hwfn, QM_REG_MAXPQSIZE_0_RT_OFFSET,
+		     QM_PQ_SIZE_256B(num_pf_cids));
+	STORE_RT_REG(p_hwfn, QM_REG_MAXPQSIZE_1_RT_OFFSET,
+		     QM_PQ_SIZE_256B(num_vf_cids));
+	/* go over all Tx PQs */
+	for (i = 0, pq_id = start_pq; i < num_pqs; i++, pq_id++) {
+		struct qm_rf_pq_map	tx_pq_map;
+		u8			voq	= VOQ(port_id,
+						      pq_params[i].tc_id,
+						      max_phys_tcs_per_port);
+		bool	is_vf_pq		= (i >= num_pf_pqs);
+
+		/* update first Tx PQ of VPORT/TC */
+		u8	vport_id_in_pf =
+			pq_params[i].vport_id - start_vport;
+		u16	first_tx_pq_id =
+			vport_params[vport_id_in_pf].first_tx_pq_id[pq_params[i]
+								    .tc_id];
+		if (first_tx_pq_id == QM_INVALID_PQ_ID) {
+			/* create new VP PQ */
+			vport_params[vport_id_in_pf].first_tx_pq_id[pq_params[i]
+								    .tc_id] =
+				pq_id;
+			first_tx_pq_id
+				= pq_id;
+			/* map VP PQ to VOQ and PF */
+			STORE_RT_REG(p_hwfn,
+				     QM_REG_WFQVPMAP_RT_OFFSET + first_tx_pq_id,
+				     (voq <<
+				      QM_WFQ_VP_PQ_VOQ_SHIFT) |
+				     (pf_id << QM_WFQ_VP_PQ_PF_SHIFT));
+		}
+		/* fill PQ map entry */
+		memset(&tx_pq_map, 0, sizeof(tx_pq_map));
+		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_PQ_VALID, 1);
+		SET_FIELD(tx_pq_map.reg,
+			  QM_RF_PQ_MAP_RL_VALID,
+			  is_vf_pq ? 1 : 0);
+		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_VP_PQ_ID, first_tx_pq_id);
+		SET_FIELD(tx_pq_map.reg,
+			  QM_RF_PQ_MAP_RL_ID,
+			  is_vf_pq ? pq_params[i].vport_id : 0);
+		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_VOQ, voq);
+		SET_FIELD(tx_pq_map.reg,
+			  QM_RF_PQ_MAP_WRR_WEIGHT_GROUP,
+			  pq_params[i].wrr_group);
+		/* write PQ map entry to CAM */
+		STORE_RT_REG(p_hwfn, QM_REG_TXPQMAP_RT_OFFSET + pq_id,
+			     *((u32 *)&tx_pq_map));
+		/* set base address */
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_BASEADDRTXPQ_RT_OFFSET + pq_id,
+			     mem_addr_4kb);
+		/* check if VF PQ */
+		if (is_vf_pq) {
+			/* if PQ is associated with a VF, add indication
+			 * to PQ VF mask
+			 */
+			tx_pq_vf_mask[pq_id /
+				      tx_pq_vf_mask_width] |=
+				(1 << (pq_id % tx_pq_vf_mask_width));
+			mem_addr_4kb +=
+				vport_pq_mem_4kb;
+		} else {
+			mem_addr_4kb += pq_mem_4kb;
+		}
+	}
+	/* store Tx PQ VF mask to size select register */
+	for (i = 0; i < num_tx_pq_vf_masks; i++) {
+		if (tx_pq_vf_mask[i]) {
+			if (is_bb_a0) {
+				/* A0-only: perform read-modify-write
+				 * (fixed in B0)
+				 */
+				u32 curr_mask = is_first_pf ? 0 : qed_rd(
+						p_hwfn,
+						p_ptt,
+						QM_REG_MAXPQSIZETXSEL_0
+						+ i * 4);
+				STORE_RT_REG(
+					p_hwfn,
+					QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET
+					+ i,
+					curr_mask | tx_pq_vf_mask[i]);
+			} else {
+				STORE_RT_REG(
+					p_hwfn,
+					QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET
+					+ i,
+					tx_pq_vf_mask[i]);
+			}
+		}
+	}
+}
+
+/* Prepare Other PQ mapping runtime init values for the specified PF */
+static void qed_other_pq_map_rt_init(struct qed_hwfn	*p_hwfn,
+				     u8			port_id,
+				     u8			pf_id,
+				     u32		num_pf_cids,
+				     u32		num_tids,
+				     u32		base_mem_addr_4kb)
+{
+	u16	i, pq_id;
+
+	/* a single other PQ group is used in each PF,
+	 * where PQ group i is used in PF i.
+	 */
+	u16	pq_group	= pf_id;
+	u32	pq_size		= num_pf_cids + num_tids;
+	u32	pq_mem_4kb	= QM_PQ_MEM_4KB(pq_size);
+	u32	mem_addr_4kb	= base_mem_addr_4kb;
+
+	/* map PQ group to PF */
+	STORE_RT_REG(p_hwfn, QM_REG_PQOTHER2PF_0_RT_OFFSET + pq_group,
+		     (u32)(pf_id));
+	/* set PQ sizes */
+	STORE_RT_REG(p_hwfn, QM_REG_MAXPQSIZE_2_RT_OFFSET,
+		     QM_PQ_SIZE_256B(pq_size));
+	/* set base address */
+	for (i = 0, pq_id = pf_id * QM_PF_QUEUE_GROUP_SIZE;
+	     i < QM_OTHER_PQS_PER_PF; i++, pq_id++) {
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_BASEADDROTHERPQ_RT_OFFSET + pq_id,
+			     mem_addr_4kb);
+		mem_addr_4kb += pq_mem_4kb;
+	}
+}
+
+/* Prepare PF WFQ runtime init values for the specified PF.
+ * Return -1 on error.
+ */
+static int qed_pf_wfq_rt_init(struct qed_hwfn		*p_hwfn,
+			      u8			port_id,
+			      u8			pf_id,
+			      u8			pf_wfq,
+			      u8			max_phys_tcs_per_port,
+			      u16			num_tx_pqs,
+			      struct init_qm_pq_params	*pq_params)
+{
+	u16	i;
+	u32	inc_val;
+	u32	crd_reg_offset =
+		(pf_id <
+		 MAX_NUM_PFS_BB ? QM_REG_WFQPFCRD_RT_OFFSET :
+		 QM_REG_WFQPFCRD_MSB_RT_OFFSET)
+		+ (pf_id % MAX_NUM_PFS_BB);
+
+	inc_val = QM_WFQ_INC_VAL(pf_wfq);
+	if (inc_val > QM_WFQ_MAX_INC_VAL) {
+		DP_NOTICE(p_hwfn, "Invalid PF WFQ weight configuration");
+		return -1;
+	}
+	STORE_RT_REG(p_hwfn, QM_REG_WFQPFWEIGHT_RT_OFFSET + pf_id, inc_val);
+	STORE_RT_REG(p_hwfn,
+		     QM_REG_WFQPFUPPERBOUND_RT_OFFSET + pf_id,
+		     QM_WFQ_UPPER_BOUND | QM_WFQ_CRD_REG_SIGN_BIT);
+	for (i = 0; i < num_tx_pqs; i++) {
+		u8 voq = VOQ(port_id, pq_params[i].tc_id,
+			     max_phys_tcs_per_port);
+
+		OVERWRITE_RT_REG(p_hwfn,
+				 crd_reg_offset + voq * MAX_NUM_PFS_BB,
+				 QM_WFQ_INIT_CRD(
+					 inc_val) | QM_WFQ_CRD_REG_SIGN_BIT);
+	}
+	return 0;
+}
+
+/* Prepare PF RL runtime init values for the specified PF.
+ * Return -1 on error.
+ */
+static int qed_pf_rl_rt_init(struct qed_hwfn	*p_hwfn,
+			     u8			pf_id,
+			     u32		pf_rl)
+{
+	u32 inc_val = QM_RL_INC_VAL(pf_rl);
+
+	if (inc_val > QM_RL_MAX_INC_VAL) {
+		DP_NOTICE(p_hwfn, "Invalid PF rate limit configuration");
+		return -1;
+	}
+	STORE_RT_REG(p_hwfn,
+		     QM_REG_RLPFCRD_RT_OFFSET + pf_id,
+		     QM_RL_CRD_REG_SIGN_BIT);
+	STORE_RT_REG(p_hwfn,
+		     QM_REG_RLPFUPPERBOUND_RT_OFFSET + pf_id,
+		     QM_RL_UPPER_BOUND | QM_RL_CRD_REG_SIGN_BIT);
+	STORE_RT_REG(p_hwfn, QM_REG_RLPFINCVAL_RT_OFFSET + pf_id, inc_val);
+	return 0;
+}
+
+/* Prepare VPORT WFQ runtime init values for the specified VPORTs.
+ * Return -1 on error.
+ */
+static int qed_vp_wfq_rt_init(struct qed_hwfn			*p_hwfn,
+			      u8				start_vport,
+			      u8				num_vports,
+			      struct init_qm_vport_params	*vport_params)
+{
+	u8	tc, i, vport_id;
+	u32	inc_val;
+
+	/* go over all PF VPORTs */
+	for (i = 0, vport_id = start_vport; i < num_vports; i++, vport_id++) {
+		u32 temp = QM_REG_WFQVPUPPERBOUND_RT_OFFSET;
+
+		if (vport_params[i].vport_wfq) {
+			inc_val = QM_WFQ_INC_VAL(vport_params[i].vport_wfq);
+			if (inc_val > QM_WFQ_MAX_INC_VAL) {
+				DP_NOTICE(
+					p_hwfn,
+					"Invalid VPORT WFQ weight configuration");
+				return -1;
+			}
+			/* each VPORT can have several VPORT PQ IDs for
+			 * different TCs
+			 */
+			for (tc = 0; tc < NUM_OF_TCS; tc++) {
+				u16 vport_pq_id =
+					vport_params[i].first_tx_pq_id[tc];
+				if (vport_pq_id != QM_INVALID_PQ_ID) {
+					STORE_RT_REG(
+						p_hwfn,
+						QM_REG_WFQVPWEIGHT_RT_OFFSET +
+						vport_pq_id,
+						inc_val);
+					STORE_RT_REG(p_hwfn, temp +
+						     vport_pq_id,
+						     QM_WFQ_UPPER_BOUND |
+						     QM_WFQ_CRD_REG_SIGN_BIT);
+					STORE_RT_REG(
+						p_hwfn,
+						QM_REG_WFQVPCRD_RT_OFFSET
+						+ vport_pq_id,
+						QM_WFQ_INIT_CRD(
+							inc_val) |
+						QM_WFQ_CRD_REG_SIGN_BIT);
+				}
+			}
+		}
+	}
+	return 0;
+}
+
+static int qed_vport_rl_rt_init(struct qed_hwfn			*p_hwfn,
+				u8				start_vport,
+				u8				num_vports,
+				struct init_qm_vport_params	*vport_params)
+{
+	u8 i, vport_id;
+
+	/* go over all PF VPORTs */
+	for (i = 0, vport_id = start_vport; i < num_vports; i++, vport_id++) {
+		u32 inc_val = QM_RL_INC_VAL(vport_params[i].vport_rl);
+
+		if (inc_val > QM_RL_MAX_INC_VAL) {
+			DP_NOTICE(p_hwfn,
+				  "Invalid VPORT rate-limit configuration");
+			return -1;
+		}
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_RLGLBLCRD_RT_OFFSET + vport_id,
+			     QM_RL_CRD_REG_SIGN_BIT);
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_RLGLBLUPPERBOUND_RT_OFFSET + vport_id,
+			     QM_RL_UPPER_BOUND | QM_RL_CRD_REG_SIGN_BIT);
+		STORE_RT_REG(p_hwfn,
+			     QM_REG_RLGLBLINCVAL_RT_OFFSET + vport_id,
+			     inc_val);
+	}
+	return 0;
+}
+
+static bool qed_poll_on_qm_cmd_ready(struct qed_hwfn	*p_hwfn,
+				     struct qed_ptt	*p_ptt)
+{
+	u32 reg_val, i;
+
+	for (i = 0, reg_val = 0; i < QM_STOP_CMD_MAX_POLL_COUNT && reg_val == 0;
+	     i++) {
+		udelay(QM_STOP_CMD_POLL_PERIOD_US);
+		reg_val = qed_rd(p_hwfn, p_ptt, QM_REG_SDMCMDREADY);
+	}
+	/* check if timeout while waiting for SDM command ready */
+	if (i == QM_STOP_CMD_MAX_POLL_COUNT) {
+		DP_VERBOSE(
+			p_hwfn,
+			NETIF_MSG_HW,
+			"Timeout when waiting for QM SDM command ready signal\n");
+		return false;
+	}
+	return true;
+}
+
+static bool qed_send_qm_cmd(struct qed_hwfn	*p_hwfn,
+			    struct qed_ptt	*p_ptt,
+			    u32			cmd_addr,
+			    u32			cmd_data_lsb,
+			    u32			cmd_data_msb)
+{
+	if (!qed_poll_on_qm_cmd_ready(p_hwfn, p_ptt))
+		return false;
+	qed_wr(p_hwfn, p_ptt, QM_REG_SDMCMDADDR, cmd_addr);
+	qed_wr(p_hwfn, p_ptt, QM_REG_SDMCMDDATALSB, cmd_data_lsb);
+	qed_wr(p_hwfn, p_ptt, QM_REG_SDMCMDDATAMSB, cmd_data_msb);
+	qed_wr(p_hwfn, p_ptt, QM_REG_SDMCMDGO, 1);
+	qed_wr(p_hwfn, p_ptt, QM_REG_SDMCMDGO, 0);
+	return qed_poll_on_qm_cmd_ready(p_hwfn, p_ptt);
+}
+
+/******************** INTERFACE IMPLEMENTATION *********************/
+u32 qed_qm_pf_mem_size(u8	pf_id,
+		       u32	num_pf_cids,
+		       u32	num_vf_cids,
+		       u32	num_tids,
+		       u16	num_pf_pqs,
+		       u16	num_vf_pqs)
+{
+	return QM_PQ_MEM_4KB(num_pf_cids) * num_pf_pqs +
+	       QM_PQ_MEM_4KB(num_vf_cids) * num_vf_pqs +
+	       QM_PQ_MEM_4KB(num_pf_cids + num_tids) * QM_OTHER_PQS_PER_PF;
+}
+
+int qed_qm_common_rt_init(
+	struct qed_hwfn			*p_hwfn,
+	u8				max_ports_per_engine,
+	u8				max_phys_tcs_per_port,
+	bool				pf_rl_en,
+	bool				pf_wfq_en,
+	bool				vport_rl_en,
+	bool				vport_wfq_en,
+	struct init_qm_port_params	port_params[
+		MAX_NUM_PORTS])
+{
+	/* init AFullOprtnstcCrdMask */
+	u32	mask =
+		(QM_OPPOR_LINE_VOQ_DEF <<
+		 QM_RF_OPPORTUNISTIC_MASK_LINEVOQ_SHIFT) |
+		(QM_BYTE_CRD_EN << QM_RF_OPPORTUNISTIC_MASK_BYTEVOQ_SHIFT) |
+		(pf_wfq_en << QM_RF_OPPORTUNISTIC_MASK_PFWFQ_SHIFT) |
+		(vport_wfq_en << QM_RF_OPPORTUNISTIC_MASK_VPWFQ_SHIFT) |
+		(pf_rl_en << QM_RF_OPPORTUNISTIC_MASK_PFRL_SHIFT) |
+		(vport_rl_en << QM_RF_OPPORTUNISTIC_MASK_VPQCNRL_SHIFT) |
+		(QM_OPPOR_FW_STOP_DEF <<
+		 QM_RF_OPPORTUNISTIC_MASK_FWPAUSE_SHIFT) |
+		(QM_OPPOR_PQ_EMPTY_DEF <<
+		 QM_RF_OPPORTUNISTIC_MASK_QUEUEEMPTY_SHIFT);
+
+	STORE_RT_REG(p_hwfn, QM_REG_AFULLOPRTNSTCCRDMASK_RT_OFFSET, mask);
+	/* enable/disable PF RL */
+	qed_enable_pf_rl(p_hwfn, pf_rl_en);
+	/* enable/disable PF WFQ */
+	qed_enable_pf_wfq(p_hwfn, pf_wfq_en);
+	/* enable/disable VPORT RL */
+	qed_enable_vport_rl(p_hwfn, vport_rl_en);
+	/* enable/disable VPORT WFQ */
+	qed_enable_vport_wfq(p_hwfn, vport_wfq_en);
+	/* init PBF CMDQ line credit */
+	qed_cmdq_lines_rt_init(p_hwfn,
+			       max_ports_per_engine,
+			       max_phys_tcs_per_port,
+			       port_params);
+	/* init BTB blocks in PBF */
+	qed_btb_blocks_rt_init(p_hwfn,
+			       max_ports_per_engine,
+			       max_phys_tcs_per_port,
+			       port_params);
+	return 0;
+}
+
+int qed_qm_pf_rt_init(struct qed_hwfn			*p_hwfn,
+		      struct qed_ptt			*p_ptt,
+		      u8				port_id,
+		      u8				pf_id,
+		      u8				max_phys_tcs_per_port,
+		      bool				is_first_pf,
+		      u32				num_pf_cids,
+		      u32				num_vf_cids,
+		      u32				num_tids,
+		      u16				start_pq,
+		      u16				num_pf_pqs,
+		      u16				num_vf_pqs,
+		      u8				start_vport,
+		      u8				num_vports,
+		      u8				pf_wfq,
+		      u32				pf_rl,
+		      struct init_qm_pq_params		*pq_params,
+		      struct init_qm_vport_params	*vport_params)
+{
+	u8	tc, i;
+	u32	other_mem_size_4kb =
+		QM_PQ_MEM_4KB(num_pf_cids + num_tids) * QM_OTHER_PQS_PER_PF;
+
+	/* clear first Tx PQ ID array for each VPORT */
+	for (i = 0; i < num_vports; i++)
+		for (tc = 0; tc < NUM_OF_TCS; tc++)
+			vport_params[i].first_tx_pq_id[tc] = QM_INVALID_PQ_ID;
+	/* map Other PQs (if any) */
+	qed_other_pq_map_rt_init(p_hwfn,
+				 port_id,
+				 pf_id,
+				 num_pf_cids,
+				 num_tids,
+				 0);
+	/* map Tx PQs */
+	qed_tx_pq_map_rt_init(p_hwfn,
+			      p_ptt,
+			      port_id,
+			      pf_id,
+			      max_phys_tcs_per_port,
+			      is_first_pf,
+			      num_pf_cids,
+			      num_vf_cids,
+			      start_pq,
+			      num_pf_pqs,
+			      num_vf_pqs,
+			      start_vport,
+			      other_mem_size_4kb,
+			      pq_params,
+			      vport_params);
+	/* init PF WFQ */
+	if (pf_wfq)
+		if (qed_pf_wfq_rt_init(p_hwfn, port_id, pf_id, pf_wfq,
+				       max_phys_tcs_per_port, num_pf_pqs +
+				       num_vf_pqs, pq_params) != 0)
+			return -1;
+	/* init PF RL */
+	if (qed_pf_rl_rt_init(p_hwfn, pf_id, pf_rl) != 0)
+		return -1;
+	/* set VPORT WFQ */
+	if (qed_vp_wfq_rt_init(p_hwfn, start_vport, num_vports,
+			       vport_params) != 0)
+		return -1;
+	/* set VPORT RL */
+	if (qed_vport_rl_rt_init(p_hwfn, start_vport, num_vports,
+				 vport_params) != 0)
+		return -1;
+	return 0;
+}
+
+int qed_init_pf_rl(struct qed_hwfn	*p_hwfn,
+		   struct qed_ptt	*p_ptt,
+		   u8			pf_id,
+		   u32			pf_rl)
+{
+	u32 inc_val = QM_RL_INC_VAL(pf_rl);
+
+	if (inc_val > QM_RL_MAX_INC_VAL) {
+		DP_NOTICE(p_hwfn, "Invalid PF rate limit configuration");
+		return -1;
+	}
+	qed_wr(p_hwfn,
+	       p_ptt,
+	       QM_REG_RLPFCRD + pf_id * 4,
+	       QM_RL_CRD_REG_SIGN_BIT);
+	qed_wr(p_hwfn, p_ptt, QM_REG_RLPFINCVAL + pf_id * 4, inc_val);
+	return 0;
+}
+
+int qed_init_vport_rl(struct qed_hwfn	*p_hwfn,
+		      struct qed_ptt	*p_ptt,
+		      u8		vport_id,
+		      u32		vport_rl)
+{
+	u32 inc_val = QM_RL_INC_VAL(vport_rl);
+
+	if (inc_val > QM_RL_MAX_INC_VAL) {
+		DP_NOTICE(p_hwfn, "Invalid VPORT rate-limit configuration");
+		return -1;
+	}
+	qed_wr(p_hwfn,
+	       p_ptt,
+	       QM_REG_RLGLBLCRD + vport_id * 4,
+	       QM_RL_CRD_REG_SIGN_BIT);
+	qed_wr(p_hwfn, p_ptt, QM_REG_RLGLBLINCVAL + vport_id * 4, inc_val);
+	return 0;
+}
+
+bool qed_send_qm_stop_cmd(struct qed_hwfn	*p_hwfn,
+			  struct qed_ptt	*p_ptt,
+			  bool			is_release_cmd,
+			  bool			is_tx_pq,
+			  u16			start_pq,
+			  u16			num_pqs)
+{
+	u32	cmd_arr[QM_CMD_STRUCT_SIZE(QM_STOP_CMD)]	= { 0 };
+	u32	pq_mask						= 0, last_pq =
+		start_pq + num_pqs - 1, pq_id;
+
+	/* set command's PQ type */
+	QM_CMD_SET_FIELD(cmd_arr, QM_STOP_CMD, PQ_TYPE, is_tx_pq ? 0 : 1);
+	/* go over requested PQs */
+	for (pq_id = start_pq; pq_id <= last_pq; pq_id++) {
+		/* set PQ bit in mask (stop command only) */
+		if (!is_release_cmd)
+			pq_mask |= (1 << (pq_id % QM_STOP_PQ_MASK_WIDTH));
+		/* if last PQ or end of PQ mask, write command */
+		if ((pq_id == last_pq) ||
+		    (pq_id % QM_STOP_PQ_MASK_WIDTH ==
+		     (QM_STOP_PQ_MASK_WIDTH - 1))) {
+			QM_CMD_SET_FIELD(cmd_arr,
+					 QM_STOP_CMD,
+					 PAUSE_MASK,
+					 pq_mask);
+			QM_CMD_SET_FIELD(cmd_arr,
+					 QM_STOP_CMD,
+					 GROUP_ID,
+					 pq_id / QM_STOP_PQ_MASK_WIDTH);
+			if (!qed_send_qm_cmd(p_hwfn, p_ptt, QM_STOP_CMD_ADDR,
+					     cmd_arr[0], cmd_arr[1]))
+				return false;
+			pq_mask = 0;
+		}
+	}
+	return true;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
new file mode 100644
index 0000000..355f185
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
@@ -0,0 +1,545 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include "qed.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_init_ops.h"
+#include "qed_reg_addr.h"
+
+#define QED_INIT_MAX_POLL_COUNT 100
+#define QED_INIT_POLL_PERIOD_US 500
+
+static u32 pxp_global_win[] = {
+	0,
+	0,
+	0x1c02, /* win 2: addr=0x1c02000, size=4096 bytes */
+	0x1c80, /* win 3: addr=0x1c80000, size=4096 bytes */
+	0x1d00, /* win 4: addr=0x1d00000, size=4096 bytes */
+	0x1d01, /* win 5: addr=0x1d01000, size=4096 bytes */
+	0x1d80, /* win 6: addr=0x1d80000, size=4096 bytes */
+	0x1d81, /* win 7: addr=0x1d81000, size=4096 bytes */
+	0x1d82, /* win 8: addr=0x1d82000, size=4096 bytes */
+	0x1e00, /* win 9: addr=0x1e00000, size=4096 bytes */
+	0x1e80, /* win 10: addr=0x1e80000, size=4096 bytes */
+	0x1f00, /* win 11: addr=0x1f00000, size=4096 bytes */
+	0,
+	0,
+	0,
+	0,
+	0,
+	0,
+	0,
+};
+
+void qed_init_iro_array(struct qed_dev *cdev)
+{
+	cdev->iro_arr = iro_arr;
+}
+
+/* Runtime configuration helpers */
+void qed_init_clear_rt_data(struct qed_hwfn *p_hwfn)
+{
+	int i;
+
+	for (i = 0; i < RUNTIME_ARRAY_SIZE; i++)
+		p_hwfn->rt_data[i].b_valid = false;
+}
+
+void qed_init_store_rt_reg(struct qed_hwfn	*p_hwfn,
+			   u32			rt_offset,
+			   u32			val)
+{
+	p_hwfn->rt_data[rt_offset].init_val	= val;
+	p_hwfn->rt_data[rt_offset].b_valid	= true;
+}
+
+void qed_init_store_rt_agg(struct qed_hwfn	*p_hwfn,
+			   u32			rt_offset,
+			   u32			*val,
+			   size_t		size)
+{
+	size_t i;
+
+	for (i = 0; i < size / sizeof(u32); i++) {
+		p_hwfn->rt_data[rt_offset + i].init_val = val[i];
+		p_hwfn->rt_data[rt_offset + i].b_valid	= true;
+	}
+}
+
+static void qed_init_rt(struct qed_hwfn *p_hwfn,
+			struct qed_ptt	*p_ptt,
+			u32		addr,
+			u32		rt_offset,
+			u32		size)
+{
+	struct qed_rt_data	*rt_data = p_hwfn->rt_data + rt_offset;
+	u32			i;
+
+	for (i = 0; i < size; i++) {
+		if (!rt_data[i].b_valid)
+			continue;
+		qed_wr(p_hwfn, p_ptt, addr + (i << 2), rt_data[i].init_val);
+	}
+}
+
+int qed_init_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_rt_data *rt_data;
+
+	rt_data = kzalloc(sizeof(*rt_data) * RUNTIME_ARRAY_SIZE, GFP_ATOMIC);
+	if (!rt_data)
+		return -ENOMEM;
+
+	p_hwfn->rt_data = rt_data;
+
+	return 0;
+}
+
+void qed_init_free(struct qed_hwfn *p_hwfn)
+{
+	kfree(p_hwfn->rt_data);
+	p_hwfn->rt_data = NULL;
+}
+
+static int qed_init_array_dmae(struct qed_hwfn	*p_hwfn,
+			       struct qed_ptt	*p_ptt,
+			       u32		addr,
+			       u32		dmae_data_offset,
+			       u32		size,
+			       const u32	*buf,
+			       bool		b_must_dmae,
+			       bool		b_can_dmae)
+{
+	int rc = 0;
+
+	/* Perform DMAE only for lengthy enough sections or for wide-bus */
+	if (!b_can_dmae || (!b_must_dmae && (size < 16))) {
+		const u32	*data = buf + dmae_data_offset;
+		u32		i;
+
+		for (i = 0; i < size; i++)
+			qed_wr(p_hwfn, p_ptt, addr + (i << 2), data[i]);
+	} else {
+		rc = qed_dmae_host2grc(p_hwfn, p_ptt,
+				       (uintptr_t)(buf + dmae_data_offset),
+				       addr, size, 0);
+	}
+
+	return rc;
+}
+
+static int qed_init_fill_dmae(struct qed_hwfn	*p_hwfn,
+			      struct qed_ptt	*p_ptt,
+			      u32		addr,
+			      u32		fill,
+			      u32		fill_count)
+{
+	static u32	zero_buffer[DMAE_MAX_RW_SIZE];
+	int		rc = 0;
+
+	memset(zero_buffer, 0, sizeof(u32) * DMAE_MAX_RW_SIZE);
+
+	/* invoke the DMAE virtual/physical buffer API with
+	 * 1. DMAE init channel
+	 * 2. addr,
+	 * 3. p_hwfb->temp_data,
+	 * 4. fill_count
+	 */
+	/* TEMP: implement through external BAR (so the HW address of the PTT
+	 * should be saved and restored)
+	 */
+
+	rc = qed_dmae_host2grc(p_hwfn, p_ptt,
+			       (uintptr_t)(&zero_buffer[0]),
+			       addr, fill_count,
+			       QED_DMAE_FLAG_RW_REPL_SRC);
+
+	return rc;
+}
+
+static void qed_init_fill(struct qed_hwfn	*p_hwfn,
+			  struct qed_ptt	*p_ptt,
+			  u32			addr,
+			  u32			fill,
+			  u32			fill_count)
+{
+	u32 i;
+
+	for (i = 0; i < fill_count; i++, addr += sizeof(u32))
+		qed_wr(p_hwfn, p_ptt, addr, fill);
+}
+
+static int qed_init_cmd_array(struct qed_hwfn		*p_hwfn,
+			      struct qed_ptt		*p_ptt,
+			      struct init_write_op	*cmd,
+			      bool			b_must_dmae,
+			      bool			b_can_dmae)
+{
+	u32 data = le32_to_cpu(cmd->data);
+	u32 addr = GET_FIELD(data, INIT_WRITE_OP_ADDRESS) << 2;
+	u32 dmae_array_offset = le32_to_cpu(cmd->args.array_offset);
+	u32 offset, output_len, input_len, max_size;
+	struct qed_dev *cdev = p_hwfn->cdev;
+	union init_array_hdr *hdr;
+	const u32 *array_data;
+	int rc = 0;
+	u32 size;
+
+	array_data = cdev->fw_data->arr_data;
+
+	hdr = (union init_array_hdr *)(array_data +
+				       dmae_array_offset);
+	data = le32_to_cpu(hdr->raw.data);
+	switch (GET_FIELD(data, INIT_ARRAY_RAW_HDR_TYPE)) {
+	case INIT_ARR_ZIPPED:
+		offset = dmae_array_offset + 1;
+		input_len = GET_FIELD(data,
+				      INIT_ARRAY_ZIPPED_HDR_ZIPPED_SIZE);
+		max_size = MAX_ZIPPED_SIZE * 4;
+		memset(p_hwfn->unzip_buf, 0, max_size);
+
+		output_len = qed_unzip_data(p_hwfn, input_len,
+					    (u8 *)&array_data[offset],
+					    max_size, (u8 *)p_hwfn->unzip_buf);
+		if (output_len) {
+			rc = qed_init_array_dmae(p_hwfn, p_ptt, addr, 0,
+						 output_len,
+						 p_hwfn->unzip_buf,
+						 b_must_dmae, b_can_dmae);
+		} else {
+			DP_NOTICE(p_hwfn, "Failed to unzip dmae data\n");
+			rc = -EINVAL;
+		}
+		break;
+	case INIT_ARR_PATTERN:
+	{
+		u32 repeats = GET_FIELD(data,
+					INIT_ARRAY_PATTERN_HDR_REPETITIONS);
+		u32 i;
+
+		size = GET_FIELD(data, INIT_ARRAY_PATTERN_HDR_PATTERN_SIZE);
+
+		for (i = 0; i < repeats; i++, addr += size << 2) {
+			rc = qed_init_array_dmae(p_hwfn, p_ptt, addr,
+						 dmae_array_offset + 1,
+						 size, array_data,
+						 b_must_dmae, b_can_dmae);
+			if (rc)
+				break;
+		}
+		break;
+	}
+	case INIT_ARR_STANDARD:
+		size = GET_FIELD(data, INIT_ARRAY_STANDARD_HDR_SIZE);
+		rc = qed_init_array_dmae(p_hwfn, p_ptt, addr,
+					 dmae_array_offset + 1,
+					 size, array_data,
+					 b_must_dmae, b_can_dmae);
+		break;
+	}
+	return rc;
+}
+
+/* init_ops write command */
+static int qed_init_cmd_wr(struct qed_hwfn	*p_hwfn,
+			   struct qed_ptt	*p_ptt,
+			   struct init_write_op *cmd,
+			   bool			b_can_dmae)
+{
+	u32 data = le32_to_cpu(cmd->data);
+	u32 addr = GET_FIELD(data, INIT_WRITE_OP_ADDRESS) << 2;
+	bool b_must_dmae = GET_FIELD(data, INIT_WRITE_OP_WIDE_BUS);
+	union init_write_args *arg = &cmd->args;
+	int rc = 0;
+
+	/* Sanitize */
+	if (b_must_dmae && !b_can_dmae) {
+		DP_NOTICE(
+			p_hwfn,
+			"Need to write to %08x for Wide-bus but DMAE isn't allowed\n",
+			addr);
+		return -EINVAL;
+	}
+
+	switch (GET_FIELD(data, INIT_WRITE_OP_SOURCE)) {
+	case INIT_SRC_INLINE:
+		qed_wr(p_hwfn, p_ptt, addr,
+		       le32_to_cpu(arg->inline_val));
+		break;
+	case INIT_SRC_ZEROS:
+		if (b_must_dmae ||
+		    (b_can_dmae && (le32_to_cpu(arg->zeros_count) >= 64)))
+			rc = qed_init_fill_dmae(p_hwfn, p_ptt, addr, 0,
+						le32_to_cpu(arg->zeros_count));
+		else
+			qed_init_fill(p_hwfn, p_ptt, addr, 0,
+				      le32_to_cpu(arg->zeros_count));
+		break;
+	case INIT_SRC_ARRAY:
+		rc = qed_init_cmd_array(p_hwfn, p_ptt, cmd,
+					b_must_dmae, b_can_dmae);
+		break;
+	case INIT_SRC_RUNTIME:
+		qed_init_rt(p_hwfn, p_ptt, addr,
+			    le16_to_cpu(arg->runtime.offset),
+			    le16_to_cpu(arg->runtime.size));
+		break;
+	}
+
+	return rc;
+}
+
+static inline bool comp_eq(u32	val,
+			   u32	expected_val)
+{
+	return val == expected_val;
+}
+
+static inline bool comp_and(u32 val,
+			    u32 expected_val)
+{
+	return (val & expected_val) == expected_val;
+}
+
+static inline bool comp_or(u32	val,
+			   u32	expected_val)
+{
+	return (val | expected_val) > 0;
+}
+
+/* init_ops read/poll commands */
+static void qed_init_cmd_rd(struct qed_hwfn	*p_hwfn,
+			    struct qed_ptt	*p_ptt,
+			    struct init_read_op *cmd)
+{
+	u32 data = le32_to_cpu(cmd->op_data);
+	u32 addr = GET_FIELD(data, INIT_READ_OP_ADDRESS) << 2;
+
+	bool	(*comp_check)(u32	val,
+			      u32	expected_val);
+	u32	delay = QED_INIT_POLL_PERIOD_US, val;
+
+	val = qed_rd(p_hwfn, p_ptt, addr);
+
+	data = le32_to_cpu(cmd->op_data);
+	if (GET_FIELD(data, INIT_READ_OP_POLL)) {
+		int i;
+
+		switch (GET_FIELD(data, INIT_READ_OP_POLL_COMP)) {
+		case INIT_COMPARISON_EQ:
+			comp_check = comp_eq;
+			break;
+		case INIT_COMPARISON_OR:
+			comp_check = comp_or;
+			break;
+		case INIT_COMPARISON_AND:
+			comp_check = comp_and;
+			break;
+		default:
+			comp_check = NULL;
+			DP_ERR(p_hwfn, "Invalid poll comparison type %08x\n",
+			       data);
+			return;
+		}
+
+		for (i = 0;
+		     i < QED_INIT_MAX_POLL_COUNT &&
+		     !comp_check(val, le32_to_cpu(cmd->expected_val));
+		     i++) {
+			udelay(delay);
+			val = qed_rd(p_hwfn, p_ptt, addr);
+		}
+
+		if (i == QED_INIT_MAX_POLL_COUNT)
+			DP_ERR(
+				p_hwfn,
+				"Timeout when polling reg: 0x%08x [ Waiting-for: %08x Got: %08x (comparsion %08x)]\n",
+				addr,
+				le32_to_cpu(cmd->expected_val),
+				val,
+				data);
+	}
+}
+
+/* init_ops callbacks entry point */
+static void qed_init_cmd_cb(struct qed_hwfn		*p_hwfn,
+			    struct qed_ptt		*p_ptt,
+			    struct init_callback_op	*p_cmd)
+{
+	DP_NOTICE(p_hwfn, "Currently init values have no need of callbacks\n");
+}
+
+static u8 qed_init_cmd_mode_match(struct qed_hwfn	*p_hwfn,
+				  u16			*offset,
+				  int			modes)
+{
+	struct qed_dev	*cdev = p_hwfn->cdev;
+	const u8	*modes_tree_buf;
+	u8		arg1, arg2, tree_val;
+
+	modes_tree_buf	= cdev->fw_data->modes_tree_buf;
+	tree_val	= modes_tree_buf[(*offset)++];
+	switch (tree_val) {
+	case INIT_MODE_OP_NOT:
+		return qed_init_cmd_mode_match(p_hwfn, offset, modes) ^ 1;
+	case INIT_MODE_OP_OR:
+		arg1	= qed_init_cmd_mode_match(p_hwfn, offset, modes);
+		arg2	= qed_init_cmd_mode_match(p_hwfn, offset, modes);
+		return arg1 | arg2;
+	case INIT_MODE_OP_AND:
+		arg1	= qed_init_cmd_mode_match(p_hwfn, offset, modes);
+		arg2	= qed_init_cmd_mode_match(p_hwfn, offset, modes);
+		return arg1 & arg2;
+	default:
+		tree_val -= MAX_INIT_MODE_OPS;
+		return (modes & (1 << tree_val)) ? 1 : 0;
+	}
+}
+
+static u32 qed_init_cmd_mode(struct qed_hwfn		*p_hwfn,
+			     struct init_if_mode_op	*p_cmd,
+			     int			modes)
+{
+	u16 offset = le16_to_cpu(p_cmd->modes_buf_offset);
+
+	if (qed_init_cmd_mode_match(p_hwfn, &offset, modes))
+		return 0;
+	else
+		return GET_FIELD(le32_to_cpu(p_cmd->op_data),
+				 INIT_IF_MODE_OP_CMD_OFFSET);
+}
+
+static u32 qed_init_cmd_phase(struct qed_hwfn		*p_hwfn,
+			      struct init_if_phase_op	*p_cmd,
+			      u32			phase,
+			      u32			phase_id)
+{
+	u32 data = le32_to_cpu(p_cmd->phase_data);
+	u32 op_data = le32_to_cpu(p_cmd->op_data);
+
+	if (!(GET_FIELD(data, INIT_IF_PHASE_OP_PHASE) == phase &&
+	      (GET_FIELD(data, INIT_IF_PHASE_OP_PHASE_ID) == ANY_PHASE_ID ||
+	       GET_FIELD(data, INIT_IF_PHASE_OP_PHASE_ID) == phase_id)))
+		return GET_FIELD(op_data, INIT_IF_PHASE_OP_CMD_OFFSET);
+	else
+		return 0;
+}
+
+int qed_init_run(struct qed_hwfn	*p_hwfn,
+		 struct qed_ptt		*p_ptt,
+		 int			phase,
+		 int			phase_id,
+		 int			modes)
+{
+	struct qed_dev	*cdev	= p_hwfn->cdev;
+	int		rc	= 0;
+	u32		cmd_num, num_init_ops;
+	union init_op	*init_ops;
+	bool		b_dmae = false;
+
+	num_init_ops	= cdev->fw_data->init_ops_size;
+	init_ops	= cdev->fw_data->init_ops;
+
+	p_hwfn->unzip_buf = kzalloc(MAX_ZIPPED_SIZE * 4, GFP_ATOMIC);
+	if (!p_hwfn->unzip_buf) {
+		DP_NOTICE(p_hwfn, "Failed to allocate unzip buffer\n");
+		return -ENOMEM;
+	}
+
+	for (cmd_num = 0; cmd_num < num_init_ops; cmd_num++) {
+		union init_op *cmd = &init_ops[cmd_num];
+		u32 data = le32_to_cpu(cmd->raw.op_data);
+
+		switch (GET_FIELD(data, INIT_CALLBACK_OP_OP)) {
+		case INIT_OP_WRITE:
+			rc = qed_init_cmd_wr(p_hwfn, p_ptt, &cmd->write,
+					     b_dmae);
+			break;
+
+		case INIT_OP_READ:
+			qed_init_cmd_rd(p_hwfn, p_ptt, &cmd->read);
+			break;
+
+		case INIT_OP_IF_MODE:
+			cmd_num += qed_init_cmd_mode(p_hwfn, &cmd->if_mode,
+						     modes);
+			break;
+		case INIT_OP_IF_PHASE:
+			cmd_num += qed_init_cmd_phase(p_hwfn, &cmd->if_phase,
+						      phase, phase_id);
+			b_dmae = GET_FIELD(data, INIT_IF_PHASE_OP_DMAE_ENABLE);
+			break;
+		case INIT_OP_DELAY:
+			/* qed_init_run is always invoked from
+			 * sleep-able context
+			 */
+			udelay(le32_to_cpu(cmd->delay.delay));
+			break;
+
+		case INIT_OP_CALLBACK:
+			qed_init_cmd_cb(p_hwfn, p_ptt, &cmd->callback);
+			break;
+		}
+
+		if (rc)
+			break;
+	}
+	kfree(p_hwfn->unzip_buf);
+	return rc;
+}
+
+void qed_gtt_init(struct qed_hwfn *p_hwfn)
+{
+	u32	gtt_base;
+	u32	i;
+
+	/* Set the global windows */
+	gtt_base = PXP_PF_WINDOW_ADMIN_START + PXP_PF_WINDOW_ADMIN_GLOBAL_START;
+
+	for (i = 0; i < ARRAY_SIZE(pxp_global_win); i++)
+		if (pxp_global_win[i])
+			REG_WR(p_hwfn, gtt_base + i * PXP_GLOBAL_ENTRY_SIZE,
+			       pxp_global_win[i]);
+}
+
+int qed_init_fw_data(struct qed_dev	*cdev,
+		     const u8		*data)
+{
+	struct qed_fw_data *fw = cdev->fw_data;
+
+	struct bin_buffer_hdr	*buf_hdr;
+	u32			offset, len;
+
+	if (!data) {
+		DP_NOTICE(cdev, "Invalid fw data\n");
+		return -EINVAL;
+	}
+
+	buf_hdr = (struct bin_buffer_hdr *)data;
+
+	offset		= buf_hdr[BIN_BUF_INIT_CMD].offset;
+	fw->init_ops	= (union init_op *)(data + offset);
+
+	offset		= buf_hdr[BIN_BUF_INIT_VAL].offset;
+	fw->arr_data	= (u32 *)(data + offset);
+
+	offset			= buf_hdr[BIN_BUF_INIT_MODE_TREE].offset;
+	fw->modes_tree_buf	= (u8 *)(data + offset);
+	len			= buf_hdr[BIN_BUF_INIT_CMD].length;
+	fw->init_ops_size	= len / sizeof(struct init_raw_op);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_ops.h b/drivers/net/ethernet/qlogic/qed/qed_init_ops.h
new file mode 100644
index 0000000..0ffb98f0a
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_ops.h
@@ -0,0 +1,109 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_INIT_OPS_H
+#define _QED_INIT_OPS_H
+#include <linux/types.h>
+#include <linux/slab.h>
+#include "qed.h"
+
+/**
+ * @brief qed_init_iro_array - init iro_arr.
+ *
+ *
+ * @param cdev
+ */
+void qed_init_iro_array(struct qed_dev *cdev);
+
+/**
+ * @brief qed_init_run - Run the init-sequence.
+ *
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param phase
+ * @param phase_id
+ * @param modes
+ * @return _qed_status_t
+ */
+int qed_init_run(struct qed_hwfn	*p_hwfn,
+		 struct qed_ptt		*p_ptt,
+		 int			phase,
+		 int			phase_id,
+		 int			modes);
+
+/**
+ * @brief qed_init_hwfn_allocate - Allocate RT array, Store 'values' ptrs.
+ *
+ *
+ * @param p_hwfn
+ *
+ * @return _qed_status_t
+ */
+int qed_init_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_init_hwfn_deallocate
+ *
+ *
+ * @param p_hwfn
+ */
+void qed_init_free(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_init_clear_rt_data - Clears the runtime init array.
+ *
+ *
+ * @param p_hwfn
+ */
+void qed_init_clear_rt_data(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_init_store_rt_reg - Store a configuration value in the RT array.
+ *
+ *
+ * @param p_hwfn
+ * @param rt_offset
+ * @param val
+ */
+void qed_init_store_rt_reg(struct qed_hwfn	*p_hwfn,
+			   u32			rt_offset,
+			   u32			val);
+
+#define STORE_RT_REG(hwfn, offset, val)	\
+	qed_init_store_rt_reg(hwfn, offset, val)
+
+#define OVERWRITE_RT_REG(hwfn, offset, val) \
+	qed_init_store_rt_reg(hwfn, offset, val)
+
+/**
+ * @brief
+ *
+ *
+ * @param p_hwfn
+ * @param rt_offset
+ * @param val
+ * @param size
+ */
+void qed_init_store_rt_agg(struct qed_hwfn	*p_hwfn,
+			   u32			rt_offset,
+			   u32			*val,
+			   size_t		size);
+
+#define STORE_RT_REG_AGG(hwfn, offset, val) \
+	qed_init_store_rt_agg(hwfn, offset, (u32 *)&val, sizeof(val))
+
+/**
+ * @brief
+ *      Initialize GTT global windows and set admin window
+ *      related params of GTT/PTT to default values.
+ *
+ * @param p_hwfn
+ */
+void qed_gtt_init(struct qed_hwfn *p_hwfn);
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
new file mode 100644
index 0000000..ac44e90
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -0,0 +1,837 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/io.h>
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include "qed.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_init_ops.h"
+#include "qed_int.h"
+#include "qed_mcp.h"
+#include "qed_reg_addr.h"
+#include "qed_sp.h"
+
+struct qed_pi_info {
+	qed_int_comp_cb_t	comp_cb;
+	void			*cookie;
+};
+
+struct qed_sb_sp_info {
+	struct qed_sb_info	sb_info;
+
+	/* per protocol index data */
+	struct qed_pi_info	pi_info_arr[PIS_PER_SB];
+};
+
+void qed_int_sp_dpc(unsigned long hwfn_cookie)
+{
+	struct qed_hwfn		*p_hwfn = (struct qed_hwfn *)hwfn_cookie;
+	struct qed_sb_info	*sb_info;
+	struct qed_pi_info	*pi_info	= NULL;
+	u16			rc		= 0;
+	static int		arr_size;
+
+	if (!p_hwfn) {
+		DP_ERR(p_hwfn->cdev, "DPC called - no hwfn!\n");
+		return;
+	}
+
+	if (!p_hwfn->p_sp_sb) {
+		DP_ERR(p_hwfn->cdev, "DPC called - no p_sp_sb\n");
+		return;
+	}
+
+	sb_info		= &p_hwfn->p_sp_sb->sb_info;
+	arr_size	= ARRAY_SIZE(p_hwfn->p_sp_sb->pi_info_arr);
+	if (!sb_info) {
+		DP_ERR(p_hwfn->cdev,
+		       "Status block is NULL - cannot ack interrupts\n");
+		return;
+	}
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR, "DPC Called! (hwfn %p %d)\n",
+		   p_hwfn, p_hwfn->my_id);
+
+	/* Disable ack for def status block. Required both for msix +
+	 * inta in non-mask mode, in inta does no harm.
+	 */
+	qed_sb_ack(sb_info, IGU_INT_DISABLE, 0);
+
+	/* Gather Interrupts/Attentions information */
+	if (!sb_info->sb_virt) {
+		DP_ERR(
+			p_hwfn->cdev,
+			"Interrupt Status block is NULL - cannot check for new interrupts!\n");
+	} else {
+		u32 tmp_index = sb_info->sb_ack;
+
+		rc = qed_sb_update_sb_idx(sb_info);
+		DP_VERBOSE(p_hwfn->cdev, NETIF_MSG_INTR,
+			   "Interrupt indices: 0x%08x --> 0x%08x\n",
+			   tmp_index, sb_info->sb_ack);
+	}
+
+	/* Check if we expect interrupts at this time. if not just ack them */
+	if (!(rc & QED_SB_EVENT_MASK)) {
+		qed_sb_ack(sb_info, IGU_INT_ENABLE, 1);
+		return;
+	}
+
+	/* Check the validity of the DPC ptt. If not ack interrupts and fail */
+	if (!p_hwfn->p_dpc_ptt) {
+		DP_NOTICE(p_hwfn->cdev, "Failed to allocate PTT\n");
+		qed_sb_ack(sb_info, IGU_INT_ENABLE, 1);
+		return;
+	}
+
+	if (rc & QED_SB_IDX) {
+		int pi;
+
+		/* Look for a free index */
+		for (pi = 0; pi < arr_size; pi++) {
+			pi_info = &p_hwfn->p_sp_sb->pi_info_arr[pi];
+			if (pi_info->comp_cb)
+				pi_info->comp_cb(p_hwfn, pi_info->cookie);
+		}
+	}
+
+	qed_sb_ack(sb_info, IGU_INT_ENABLE, 1);
+}
+
+/* coalescing timeout = timeset << (timer_res + 1) */
+#define QED_CAU_DEF_RX_USECS 24
+#define QED_CAU_DEF_TX_USECS 48
+
+void qed_init_cau_sb_entry(struct qed_hwfn	*p_hwfn,
+			   struct cau_sb_entry	*p_sb_entry,
+			   u8			pf_id,
+			   u16			vf_number,
+			   u8			vf_valid)
+{
+	u32 cau_state;
+
+	memset(p_sb_entry, 0, sizeof(*p_sb_entry));
+
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_PF_NUMBER, pf_id);
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_VF_NUMBER, vf_number);
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_VF_VALID, vf_valid);
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_SB_TIMESET0, 0x7F);
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_SB_TIMESET1, 0x7F);
+
+	/* setting the time resultion to a fixed value ( = 1) */
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_TIMER_RES0,
+		  QED_CAU_DEF_RX_TIMER_RES);
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_TIMER_RES1,
+		  QED_CAU_DEF_TX_TIMER_RES);
+
+	cau_state = CAU_HC_DISABLE_STATE;
+
+	if (p_hwfn->cdev->int_coalescing_mode == QED_COAL_MODE_ENABLE) {
+		cau_state = CAU_HC_ENABLE_STATE;
+		if (!p_hwfn->cdev->rx_coalesce_usecs)
+			p_hwfn->cdev->rx_coalesce_usecs =
+				QED_CAU_DEF_RX_USECS;
+		if (!p_hwfn->cdev->tx_coalesce_usecs)
+			p_hwfn->cdev->tx_coalesce_usecs =
+				QED_CAU_DEF_TX_USECS;
+	}
+
+	SET_FIELD(p_sb_entry->data, CAU_SB_ENTRY_STATE0, cau_state);
+	SET_FIELD(p_sb_entry->data, CAU_SB_ENTRY_STATE1, cau_state);
+}
+
+void qed_int_cau_conf_sb(struct qed_hwfn	*p_hwfn,
+			 struct qed_ptt		*p_ptt,
+			 dma_addr_t		sb_phys,
+			 u16			igu_sb_id,
+			 u16			vf_number,
+			 u8			vf_valid)
+{
+	struct cau_sb_entry	sb_entry;
+	u32			val;
+
+	qed_init_cau_sb_entry(p_hwfn, &sb_entry, p_hwfn->rel_pf_id,
+			      vf_number, vf_valid);
+
+	if (p_hwfn->hw_init_done) {
+		val = CAU_REG_SB_ADDR_MEMORY + igu_sb_id * sizeof(u64);
+		qed_wr(p_hwfn, p_ptt, val, lower_32_bits(sb_phys));
+		qed_wr(p_hwfn, p_ptt, val + sizeof(u32),
+		       upper_32_bits(sb_phys));
+
+		val = CAU_REG_SB_VAR_MEMORY + igu_sb_id * sizeof(u64);
+		qed_wr(p_hwfn, p_ptt, val, sb_entry.data);
+		qed_wr(p_hwfn, p_ptt, val + sizeof(u32), sb_entry.params);
+	} else {
+		/* Initialize Status Block Address */
+		STORE_RT_REG_AGG(
+			p_hwfn,
+			CAU_REG_SB_ADDR_MEMORY_RT_OFFSET + igu_sb_id *
+			2,
+			sb_phys);
+
+		STORE_RT_REG_AGG(
+			p_hwfn,
+			CAU_REG_SB_VAR_MEMORY_RT_OFFSET + igu_sb_id *
+			2,
+			sb_entry);
+	}
+
+	/* Configure pi coalescing if set */
+	if (p_hwfn->cdev->int_coalescing_mode == QED_COAL_MODE_ENABLE) {
+		u8	num_tc	= 1; /* @@@TBD aelior QED_MULTI_COS */
+		u8	timeset = p_hwfn->cdev->rx_coalesce_usecs >>
+			(QED_CAU_DEF_RX_TIMER_RES + 1);
+		u8	i;
+
+		qed_int_cau_conf_pi(p_hwfn, p_ptt, igu_sb_id, RX_PI,
+				    QED_COAL_RX_STATE_MACHINE,
+				    timeset);
+
+		timeset = p_hwfn->cdev->tx_coalesce_usecs >>
+			(QED_CAU_DEF_TX_TIMER_RES + 1);
+
+		for (i = 0; i < num_tc; i++) {
+			qed_int_cau_conf_pi(p_hwfn, p_ptt,
+					    igu_sb_id, TX_PI(i),
+					    QED_COAL_TX_STATE_MACHINE,
+					    timeset);
+		}
+	}
+}
+
+void qed_int_cau_conf_pi(struct qed_hwfn		*p_hwfn,
+			 struct qed_ptt			*p_ptt,
+			 u16				igu_sb_id,
+			 u32				pi_index,
+			 enum qed_coalescing_fsm	coalescing_fsm,
+			 u8				timeset)
+{
+	struct cau_pi_entry	pi_entry;
+	u32			sb_offset;
+	u32			pi_offset;
+
+	sb_offset = igu_sb_id * PIS_PER_SB;
+	memset(&pi_entry, 0, sizeof(struct cau_pi_entry));
+
+	SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_PI_TIMESET, timeset);
+	if (coalescing_fsm == QED_COAL_RX_STATE_MACHINE)
+		SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_FSM_SEL, 0);
+	else
+		SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_FSM_SEL, 1);
+
+	pi_offset = sb_offset + pi_index;
+	if (p_hwfn->hw_init_done) {
+		qed_wr(p_hwfn, p_ptt,
+		       CAU_REG_PI_MEMORY + pi_offset * sizeof(u32),
+		       *((u32 *)&(pi_entry)));
+	} else {
+		STORE_RT_REG(p_hwfn,
+			     CAU_REG_PI_MEMORY_RT_OFFSET + pi_offset,
+			     *((u32 *)&(pi_entry)));
+	}
+}
+
+void qed_int_sb_setup(struct qed_hwfn		*p_hwfn,
+		      struct qed_ptt		*p_ptt,
+		      struct qed_sb_info	*sb_info)
+{
+	/* zero status block and ack counter */
+	sb_info->sb_ack = 0;
+	memset(sb_info->sb_virt, 0, sizeof(*sb_info->sb_virt));
+
+	qed_int_cau_conf_sb(p_hwfn, p_ptt, sb_info->sb_phys,
+			    sb_info->igu_sb_id, 0, 0);
+}
+
+/**
+ *
+ * @brief qed_get_igu_sb_id - given a sw sb_id return the
+ *        igu_sb_id
+ *
+ * @param p_hwfn
+ * @param sb_id
+ *
+ * @return u16
+ */
+static u16 qed_get_igu_sb_id(struct qed_hwfn	*p_hwfn,
+			     u16		sb_id)
+{
+	u16 igu_sb_id;
+
+	/* Assuming continuous set of IGU SBs dedicated for given PF */
+	if (sb_id == QED_SP_SB_ID)
+		igu_sb_id = p_hwfn->hw_info.p_igu_info->igu_dsb_id;
+	else
+		igu_sb_id = sb_id + p_hwfn->hw_info.p_igu_info->igu_base_sb;
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR, "SB [%s] index is 0x%04x\n",
+		   (sb_id == QED_SP_SB_ID) ? "DSB" : "non-DSB", igu_sb_id);
+
+	return igu_sb_id;
+}
+
+int qed_int_sb_init(struct qed_hwfn	*p_hwfn,
+		    struct qed_ptt	*p_ptt,
+		    struct qed_sb_info	*sb_info,
+		    void		*sb_virt_addr,
+		    dma_addr_t		sb_phy_addr,
+		    u16			sb_id)
+{
+	sb_info->sb_virt	= sb_virt_addr;
+	sb_info->sb_phys	= sb_phy_addr;
+
+	sb_info->igu_sb_id = qed_get_igu_sb_id(p_hwfn, sb_id);
+
+	if (sb_id != QED_SP_SB_ID) {
+		p_hwfn->sbs_info[sb_id] = sb_info;
+		p_hwfn->num_sbs++;
+	}
+
+	sb_info->cdev = p_hwfn->cdev;
+
+	/* The igu address will hold the absolute address that needs to be
+	 * written to for a specific status block
+	 */
+	sb_info->igu_addr = (u8 __iomem *)p_hwfn->regview +
+					  GTT_BAR0_MAP_REG_IGU_CMD +
+					  (sb_info->igu_sb_id << 3);
+
+	sb_info->flags |= QED_SB_INFO_INIT;
+
+	qed_int_sb_setup(p_hwfn, p_ptt, sb_info);
+
+	return 0;
+}
+
+int qed_int_sb_release(struct qed_hwfn		*p_hwfn,
+		       struct qed_sb_info	*sb_info,
+		       u16			sb_id)
+{
+	if (sb_id == QED_SP_SB_ID) {
+		DP_ERR(p_hwfn, "Do Not free sp sb using this function");
+		return -EINVAL;
+	}
+
+	/* zero status block and ack counter */
+	sb_info->sb_ack = 0;
+	memset(sb_info->sb_virt, 0, sizeof(*sb_info->sb_virt));
+
+	p_hwfn->sbs_info[sb_id] = NULL;
+	p_hwfn->num_sbs--;
+
+	return 0;
+}
+
+static void qed_int_sp_sb_free(struct qed_hwfn *p_hwfn)
+{
+	struct qed_sb_sp_info *p_sb = p_hwfn->p_sp_sb;
+
+	if (p_sb) {
+		if (p_sb->sb_info.sb_virt)
+			dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+					  SB_ALIGNED_SIZE(p_hwfn),
+					  p_sb->sb_info.sb_virt,
+					  p_sb->sb_info.sb_phys);
+		kfree(p_sb);
+	}
+}
+
+static int qed_int_sp_sb_alloc(struct qed_hwfn	*p_hwfn,
+			       struct qed_ptt	*p_ptt)
+{
+	struct qed_sb_sp_info	*p_sb;
+	void			*p_virt;
+	dma_addr_t		p_phys = 0;
+
+	/* SB struct */
+	p_sb = kmalloc(sizeof(*p_sb), GFP_ATOMIC);
+	if (!p_sb) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_sb_info'\n");
+		return -ENOMEM;
+	}
+
+	/* SB ring  */
+	p_virt =
+		dma_alloc_coherent(&p_hwfn->cdev->pdev->dev, SB_ALIGNED_SIZE(
+					   p_hwfn), &p_phys, GFP_KERNEL);
+
+	if (!p_virt) {
+		DP_NOTICE(p_hwfn, "Failed to allocate status block\n");
+		kfree(p_sb);
+		return -ENOMEM;
+	}
+
+	/* Status Block setup */
+	p_hwfn->p_sp_sb = p_sb;
+	qed_int_sb_init(p_hwfn,
+			p_ptt,
+			&p_sb->sb_info,
+			p_virt,
+			p_phys,
+			QED_SP_SB_ID);
+
+	memset(p_sb->pi_info_arr, 0, sizeof(p_sb->pi_info_arr));
+
+	return 0;
+}
+
+static void qed_int_sp_sb_setup(struct qed_hwfn *p_hwfn,
+				struct qed_ptt	*p_ptt)
+{
+	if (!p_hwfn)
+		return;
+
+	if (p_hwfn->p_sp_sb)
+		qed_int_sb_setup(p_hwfn, p_ptt, &p_hwfn->p_sp_sb->sb_info);
+	else
+		DP_NOTICE(
+			p_hwfn->cdev,
+			"Failed to setup Slow path status block - NULL pointer\n");
+}
+
+int qed_int_register_cb(struct qed_hwfn		*p_hwfn,
+			qed_int_comp_cb_t	comp_cb,
+			void			*cookie,
+			u8			*sb_idx,
+			__le16			**p_fw_cons)
+{
+	struct qed_sb_sp_info	*p_sp_sb	= p_hwfn->p_sp_sb;
+	int			qed_status	= -ENOMEM;
+	u8			pi;
+
+	/* Look for a free index */
+	for (pi = 0; pi < ARRAY_SIZE(p_sp_sb->pi_info_arr); pi++) {
+		if (!p_sp_sb->pi_info_arr[pi].comp_cb) {
+			p_sp_sb->pi_info_arr[pi].comp_cb	= comp_cb;
+			p_sp_sb->pi_info_arr[pi].cookie		= cookie;
+			*sb_idx					= pi;
+			*p_fw_cons				=
+				&p_sp_sb->sb_info.sb_virt->pi_array[pi];
+			qed_status = 0;
+			break;
+		}
+	}
+
+	return qed_status;
+}
+
+int qed_int_unregister_cb(struct qed_hwfn	*p_hwfn,
+			  u8			pi)
+{
+	struct qed_sb_sp_info	*p_sp_sb	= p_hwfn->p_sp_sb;
+	int			qed_status	= -ENOMEM;
+
+	if (p_sp_sb->pi_info_arr[pi].comp_cb) {
+		p_sp_sb->pi_info_arr[pi].comp_cb	= NULL;
+		p_sp_sb->pi_info_arr[pi].cookie		= NULL;
+		qed_status				= 0;
+	}
+
+	return qed_status;
+}
+
+u16 qed_int_get_sp_sb_id(struct qed_hwfn *p_hwfn)
+{
+	return p_hwfn->p_sp_sb->sb_info.igu_sb_id;
+}
+
+void qed_int_igu_enable_int(struct qed_hwfn	*p_hwfn,
+			    struct qed_ptt	*p_ptt,
+			    enum qed_int_mode	int_mode)
+{
+	u32 igu_pf_conf = IGU_PF_CONF_FUNC_EN;
+
+	p_hwfn->cdev->int_mode = int_mode;
+	switch (p_hwfn->cdev->int_mode) {
+	case QED_INT_MODE_INTA:
+		igu_pf_conf	|= IGU_PF_CONF_INT_LINE_EN;
+		igu_pf_conf	|= IGU_PF_CONF_SINGLE_ISR_EN;
+		break;
+
+	case QED_INT_MODE_MSI:
+		igu_pf_conf	|= IGU_PF_CONF_MSI_MSIX_EN;
+		igu_pf_conf	|= IGU_PF_CONF_SINGLE_ISR_EN;
+		break;
+
+	case QED_INT_MODE_MSIX:
+		igu_pf_conf |= IGU_PF_CONF_MSI_MSIX_EN;
+		break;
+	case QED_INT_MODE_POLL:
+		break;
+	}
+
+	qed_wr(p_hwfn, p_ptt, IGU_REG_PF_CONFIGURATION, igu_pf_conf);
+}
+
+void qed_int_igu_enable(struct qed_hwfn		*p_hwfn,
+			struct qed_ptt		*p_ptt,
+			enum qed_int_mode	int_mode)
+{
+	int i;
+
+	p_hwfn->b_int_enabled = 1;
+
+	/* Mask non-link attentions */
+	for (i = 0; i < 9; i++)
+		qed_wr(p_hwfn, p_ptt,
+		       MISC_REG_AEU_ENABLE1_IGU_OUT_0 + (i << 2), 0);
+
+	/* Enable interrupt Generation */
+	qed_int_igu_enable_int(p_hwfn, p_ptt, int_mode);
+
+	/* Flush the writes to IGU */
+	mmiowb();
+}
+
+void qed_int_igu_disable_int(struct qed_hwfn	*p_hwfn,
+			     struct qed_ptt	*p_ptt)
+{
+	p_hwfn->b_int_enabled = 0;
+
+	qed_wr(p_hwfn, p_ptt, IGU_REG_PF_CONFIGURATION, 0);
+}
+
+#define IGU_CLEANUP_SLEEP_LENGTH                (1000)
+void qed_int_igu_cleanup_sb(struct qed_hwfn	*p_hwfn,
+			    struct qed_ptt	*p_ptt,
+			    u32			sb_id,
+			    bool		cleanup_set,
+			    u16			opaque_fid
+			    )
+{
+	u32			pxp_addr	= IGU_CMD_INT_ACK_BASE + sb_id;
+	u32			sleep_cnt	= IGU_CLEANUP_SLEEP_LENGTH;
+	u32			data		= 0;
+	u32			cmd_ctrl	= 0;
+	u32			val		= 0;
+	u32			sb_bit		= 0;
+	u32			sb_bit_addr	= 0;
+	u8			type		= 0; /* FIXME MichalS type??? */
+
+	static const u32	sb_bit_addr_addr[] = {
+		IGU_REG_CLEANUP_STATUS_0,
+		IGU_REG_CLEANUP_STATUS_1,
+		IGU_REG_CLEANUP_STATUS_2,
+		IGU_REG_CLEANUP_STATUS_3,
+		IGU_REG_CLEANUP_STATUS_4,
+	};
+
+	/* Set the data field */
+	SET_FIELD(data, IGU_CLEANUP_CLEANUP_SET, cleanup_set ? 1 : 0);
+	SET_FIELD(data, IGU_CLEANUP_CLEANUP_TYPE, type);
+	SET_FIELD(data, IGU_CLEANUP_COMMAND_TYPE, IGU_COMMAND_TYPE_SET);
+
+	/* Set the control register */
+	SET_FIELD(cmd_ctrl, IGU_CTRL_REG_PXP_ADDR, pxp_addr);
+	SET_FIELD(cmd_ctrl, IGU_CTRL_REG_FID, opaque_fid);
+	SET_FIELD(cmd_ctrl, IGU_CTRL_REG_TYPE, IGU_CTRL_CMD_TYPE_WR);
+
+	qed_wr(p_hwfn, p_ptt, IGU_REG_COMMAND_REG_32LSB_DATA, data);
+
+	barrier();
+
+	qed_wr(p_hwfn, p_ptt, IGU_REG_COMMAND_REG_CTRL, cmd_ctrl);
+
+	/* Flush the write to IGU */
+	mmiowb();
+
+	/* calculate where to read the status bit from */
+	sb_bit		= 1 << (sb_id % 32);
+	sb_bit_addr	= sb_id / 32 * sizeof(u32);
+
+	sb_bit_addr += sb_bit_addr_addr[type];
+
+	/* Now wait for the command to complete */
+	do {
+		val = qed_rd(p_hwfn, p_ptt, sb_bit_addr);
+
+		if ((val & sb_bit) == (cleanup_set ? sb_bit : 0))
+			break;
+
+		usleep_range(5000, 10000);
+	} while (--sleep_cnt);
+
+	if (!sleep_cnt)
+		DP_NOTICE(
+			p_hwfn,
+			"Timeout waiting for clear status 0x%08x [for sb %d]\n",
+			val,
+			sb_id);
+}
+
+void qed_int_igu_init_pure_rt_single(struct qed_hwfn	*p_hwfn,
+				     struct qed_ptt	*p_ptt,
+				     u32		sb_id,
+				     u16		opaque,
+				     bool		b_set)
+{
+	int pi;
+
+	/* Set */
+	if (b_set)
+		qed_int_igu_cleanup_sb(p_hwfn, p_ptt, sb_id, 1, opaque);
+
+	/* Clear */
+	qed_int_igu_cleanup_sb(p_hwfn, p_ptt, sb_id, 0, opaque);
+
+	/* Clear the CAU for the SB */
+	for (pi = 0; pi < 12; pi++)
+		qed_wr(p_hwfn, p_ptt,
+		       CAU_REG_PI_MEMORY + (sb_id * 12 + pi) * 4, 0);
+}
+
+void qed_int_igu_init_pure_rt(struct qed_hwfn	*p_hwfn,
+			      struct qed_ptt	*p_ptt,
+			      bool		b_set,
+			      bool		b_slowpath)
+{
+	u32	igu_base_sb	= p_hwfn->hw_info.p_igu_info->igu_base_sb;
+	u32	igu_sb_cnt	= p_hwfn->hw_info.p_igu_info->igu_sb_cnt;
+	u32	sb_id		= 0;
+	u32	val		= 0;
+
+	/* @@@TBD MichalK temporary... should be moved to init-tool... */
+	val	= qed_rd(p_hwfn, p_ptt, IGU_REG_BLOCK_CONFIGURATION);
+	val	|= IGU_REG_BLOCK_CONFIGURATION_VF_CLEANUP_EN;
+	val	&= ~IGU_REG_BLOCK_CONFIGURATION_PXP_TPH_INTERFACE_EN;
+	qed_wr(p_hwfn, p_ptt, IGU_REG_BLOCK_CONFIGURATION, val);
+	/* end temporary */
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+		   "IGU cleaning SBs [%d,...,%d]\n",
+		   igu_base_sb, igu_base_sb + igu_sb_cnt - 1);
+
+	for (sb_id = igu_base_sb; sb_id < igu_base_sb + igu_sb_cnt; sb_id++)
+		qed_int_igu_init_pure_rt_single(p_hwfn, p_ptt, sb_id,
+						p_hwfn->hw_info.opaque_fid,
+						b_set);
+
+	if (b_slowpath) {
+		sb_id = p_hwfn->hw_info.p_igu_info->igu_dsb_id;
+		DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+			   "IGU cleaning slowpath SB [%d]\n", sb_id);
+		qed_int_igu_init_pure_rt_single(p_hwfn, p_ptt, sb_id,
+						p_hwfn->hw_info.opaque_fid,
+						b_set);
+	}
+}
+
+int qed_int_igu_read_cam(struct qed_hwfn	*p_hwfn,
+			 struct qed_ptt		*p_ptt)
+{
+	struct qed_igu_info	*p_igu_info;
+	struct qed_igu_block	*p_block;
+	u32			val;
+	u16			sb_id;
+	u16			prev_sb_id = 0xFF;
+
+	p_hwfn->hw_info.p_igu_info = kzalloc(sizeof(*p_igu_info), GFP_ATOMIC);
+
+	if (!p_hwfn->hw_info.p_igu_info)
+		return -ENOMEM;
+
+	p_igu_info = p_hwfn->hw_info.p_igu_info;
+
+	/* Initialize base sb / sb cnt for PFs */
+	p_igu_info->igu_base_sb		= 0xffff;
+	p_igu_info->igu_sb_cnt		= 0;
+	p_igu_info->igu_dsb_id		= 0xffff;
+	p_igu_info->igu_base_sb_iov	= 0xffff;
+
+	for (sb_id = 0; sb_id < QED_MAPPING_MEMORY_SIZE(p_hwfn->cdev);
+	     sb_id++) {
+		p_block = &p_igu_info->igu_map.igu_blocks[sb_id];
+
+		val = qed_rd(p_hwfn, p_ptt,
+			     IGU_REG_MAPPING_MEMORY + sizeof(u32) * sb_id);
+
+		/* stop scanning when hit first invalid PF entry */
+		if (!GET_FIELD(val, IGU_MAPPING_LINE_VALID) &&
+		    GET_FIELD(val, IGU_MAPPING_LINE_PF_VALID))
+			break;
+
+		p_block->status		= QED_IGU_STATUS_VALID;
+		p_block->function_id	=
+			GET_FIELD(val, IGU_MAPPING_LINE_FUNCTION_NUMBER);
+		p_block->is_pf =
+			GET_FIELD(val, IGU_MAPPING_LINE_PF_VALID);
+		p_block->vector_number =
+			GET_FIELD(val, IGU_MAPPING_LINE_VECTOR_NUMBER);
+
+		DP_VERBOSE(
+			p_hwfn,
+			NETIF_MSG_INTR,
+			"IGU_BLOCK[sb_id]:%x:func_id = %d is_pf = %d vector_num = 0x%x\n",
+			val,
+			p_block->function_id,
+			p_block->is_pf,
+			p_block->vector_number);
+
+		if (p_block->is_pf) {
+			if (p_block->function_id == p_hwfn->rel_pf_id) {
+				p_block->status |= QED_IGU_STATUS_PF;
+
+				if (p_block->vector_number == 0) {
+					if (p_igu_info->igu_dsb_id == 0xffff)
+						p_igu_info->igu_dsb_id = sb_id;
+				} else {
+					if (p_igu_info->igu_base_sb ==
+					    0xffff) {
+						p_igu_info->igu_base_sb = sb_id;
+					} else if (prev_sb_id != sb_id - 1) {
+						DP_NOTICE(
+							p_hwfn->cdev,
+							"consecutive igu vectors for HWFN %x broken",
+							p_hwfn->rel_pf_id);
+						break;
+					}
+					prev_sb_id = sb_id;
+					/* we don't count the default */
+					(p_igu_info->igu_sb_cnt)++;
+				}
+			}
+		}
+	}
+
+	DP_VERBOSE(
+		p_hwfn,
+		NETIF_MSG_INTR,
+		"IGU igu_base_sb=0x%x igu_sb_cnt=%d igu_dsb_id=0x%x\n",
+		p_igu_info->igu_base_sb,
+		p_igu_info->igu_sb_cnt,
+		p_igu_info->igu_dsb_id);
+
+	if (p_igu_info->igu_base_sb == 0xffff ||
+	    p_igu_info->igu_dsb_id == 0xffff ||
+	    p_igu_info->igu_sb_cnt == 0) {
+		DP_NOTICE(
+			p_hwfn,
+			"IGU CAM returned invalid values igu_base_sb=0x%x igu_sb_cnt=%d igu_dsb_id=0x%x\n",
+			p_igu_info->igu_base_sb,
+			p_igu_info->igu_sb_cnt,
+			p_igu_info->igu_dsb_id);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
+ *
+ * @brief Initialize igu runtime registers
+ *
+ * @param p_hwfn
+ */
+void qed_int_igu_init_rt(struct qed_hwfn *p_hwfn)
+{
+	u32 igu_pf_conf = 0;
+
+	igu_pf_conf |= IGU_PF_CONF_FUNC_EN;
+
+	STORE_RT_REG(p_hwfn, IGU_REG_PF_CONFIGURATION_RT_OFFSET, igu_pf_conf);
+}
+
+u64 qed_int_igu_read_sisr_reg(struct qed_hwfn *p_hwfn)
+{
+	u64			intr_status		= 0;
+	u32			intr_status_lo		= 0;
+	u32			intr_status_hi		= 0;
+	static const u32	lsb_igu_cmd_addr	=
+		IGU_REG_SISR_MDPC_WMASK_LSB_UPPER - IGU_CMD_INT_ACK_BASE;
+	static const u32	msb_igu_cmd_addr =
+		IGU_REG_SISR_MDPC_WMASK_MSB_UPPER - IGU_CMD_INT_ACK_BASE;
+
+	intr_status_lo = REG_RD(p_hwfn,
+				GTT_BAR0_MAP_REG_IGU_CMD +
+				lsb_igu_cmd_addr * 8);
+	intr_status_hi = REG_RD(p_hwfn,
+				GTT_BAR0_MAP_REG_IGU_CMD +
+				msb_igu_cmd_addr * 8);
+	intr_status = ((u64)intr_status_hi << 32) + (u64)intr_status_lo;
+
+	return intr_status;
+}
+
+static void qed_int_sp_dpc_setup(struct qed_hwfn *p_hwfn)
+{
+	tasklet_init(p_hwfn->sp_dpc,
+		     qed_int_sp_dpc, (unsigned long)p_hwfn);
+	p_hwfn->b_sp_dpc_enabled = true;
+}
+
+static int qed_int_sp_dpc_alloc(struct qed_hwfn *p_hwfn)
+{
+	p_hwfn->sp_dpc = kmalloc(sizeof(*p_hwfn->sp_dpc), GFP_ATOMIC);
+	if (!p_hwfn->sp_dpc)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void qed_int_sp_dpc_free(struct qed_hwfn *p_hwfn)
+{
+	kfree(p_hwfn->sp_dpc);
+}
+
+int qed_int_alloc(struct qed_hwfn	*p_hwfn,
+		  struct qed_ptt	*p_ptt)
+{
+	int rc = 0;
+
+	rc = qed_int_sp_dpc_alloc(p_hwfn);
+	if (rc) {
+		DP_ERR(p_hwfn->cdev, "Failed to allocate sp dpc mem\n");
+		return rc;
+	}
+	rc = qed_int_sp_sb_alloc(p_hwfn, p_ptt);
+	if (rc) {
+		DP_ERR(p_hwfn->cdev, "Failed to allocate sp sb mem\n");
+		return rc;
+	}
+
+	return rc;
+}
+
+void qed_int_free(struct qed_hwfn *p_hwfn)
+{
+	qed_int_sp_sb_free(p_hwfn);
+	qed_int_sp_dpc_free(p_hwfn);
+}
+
+void qed_int_setup(struct qed_hwfn	*p_hwfn,
+		   struct qed_ptt	*p_ptt)
+{
+	qed_int_sp_sb_setup(p_hwfn, p_ptt);
+	qed_int_sp_dpc_setup(p_hwfn);
+}
+
+int qed_int_get_num_sbs(struct qed_hwfn *p_hwfn,
+			int		*p_iov_blks)
+{
+	struct qed_igu_info *info = p_hwfn->hw_info.p_igu_info;
+
+	if (!info)
+		return 0;
+
+	if (p_iov_blks)
+		*p_iov_blks = info->free_blks;
+
+	return info->igu_sb_cnt;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.h b/drivers/net/ethernet/qlogic/qed/qed_int.h
new file mode 100644
index 0000000..d296725
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.h
@@ -0,0 +1,404 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_INT_H
+#define _QED_INT_H
+#include <linux/types.h>
+#include <linux/slab.h>
+#include "qed.h"
+/**
+ * @file
+ *
+ * @brief IGU Definitions required for configurations done in
+ *        the driver
+ */
+
+#ifndef _QED_IGU_DEF_H_
+#define _QED_IGU_DEF_H_
+
+/* Fields of IGU PF CONFIGRATION REGISTER */
+#define IGU_PF_CONF_FUNC_EN       (0x1 << 0)    /* function enable        */
+#define IGU_PF_CONF_MSI_MSIX_EN   (0x1 << 1)    /* MSI/MSIX enable        */
+#define IGU_PF_CONF_INT_LINE_EN   (0x1 << 2)    /* INT enable             */
+#define IGU_PF_CONF_ATTN_BIT_EN   (0x1 << 3)    /* attention enable       */
+#define IGU_PF_CONF_SINGLE_ISR_EN (0x1 << 4)    /* single ISR mode enable */
+#define IGU_PF_CONF_SIMD_MODE     (0x1 << 5)    /* simd all ones mode     */
+
+/* Igu control commands
+ */
+enum igu_ctrl_cmd {
+	IGU_CTRL_CMD_TYPE_RD,
+	IGU_CTRL_CMD_TYPE_WR,
+	MAX_IGU_CTRL_CMD
+};
+
+/* Control register for the IGU command register
+ */
+struct igu_ctrl_reg {
+	u32 ctrl_data;
+#define IGU_CTRL_REG_FID_MASK           0xFFFF  /* Opaque_FID	 */
+#define IGU_CTRL_REG_FID_SHIFT          0
+#define IGU_CTRL_REG_PXP_ADDR_MASK      0xFFF   /* Command address */
+#define IGU_CTRL_REG_PXP_ADDR_SHIFT     16
+#define IGU_CTRL_REG_RESERVED_MASK      0x1
+#define IGU_CTRL_REG_RESERVED_SHIFT     28
+#define IGU_CTRL_REG_TYPE_MASK          0x1 /* use enum igu_ctrl_cmd */
+#define IGU_CTRL_REG_TYPE_SHIFT         31
+};
+
+#endif
+
+enum qed_coalescing_fsm {
+	QED_COAL_RX_STATE_MACHINE,
+	QED_COAL_TX_STATE_MACHINE
+};
+
+/**
+ * @brief qed_int_cau_conf_pi - configure cau for a given
+ *        status block
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param igu_sb_id
+ * @param pi_index
+ * @param state
+ * @param timeset
+ */
+void qed_int_cau_conf_pi(struct qed_hwfn		*p_hwfn,
+			 struct qed_ptt			*p_ptt,
+			 u16				igu_sb_id,
+			 u32				pi_index,
+			 enum qed_coalescing_fsm	coalescing_fsm,
+			 u8				timeset);
+
+/**
+ *
+ * @brief qed_int_igu_enable_int - enable device interrupts
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param int_mode - interrupt mode to use
+ */
+void qed_int_igu_enable_int(struct qed_hwfn	*p_hwfn,
+			    struct qed_ptt	*p_ptt,
+			    enum qed_int_mode	int_mode);
+
+/**
+ *
+ * @brief qed_int_igu_disable_int - disable device interrupts
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ */
+void qed_int_igu_disable_int(struct qed_hwfn	*p_hwfn,
+			     struct qed_ptt	*p_ptt);
+
+/**
+ *
+ * @brief qed_int_igu_read_sisr_reg - Reads the single isr multiple dpc
+ *        register from igu.
+ *
+ * @param p_hwfn
+ *
+ * @return u64
+ */
+u64 qed_int_igu_read_sisr_reg(struct qed_hwfn *p_hwfn);
+
+#define QED_SP_SB_ID 0xffff
+/**
+ * @brief qed_int_sb_init - Initializes the sb_info structure.
+ *
+ * once the structure is initialized it can be passed to sb related functions.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param sb_info	points to an uninitialized (but
+ *			allocated) sb_info structure
+ * @param sb_virt_addr
+ * @param sb_phy_addr
+ * @param sb_id		the sb_id to be used (zero based in driver)
+ *			should use QED_SP_SB_ID for SP Status block
+ *
+ * @return int
+ */
+int qed_int_sb_init(struct qed_hwfn	*p_hwfn,
+		    struct qed_ptt	*p_ptt,
+		    struct qed_sb_info	*sb_info,
+		    void		*sb_virt_addr,
+		    dma_addr_t		sb_phy_addr,
+		    u16			sb_id);
+/**
+ * @brief qed_int_sb_setup - Setup the sb.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param sb_info	initialized sb_info structure
+ */
+void qed_int_sb_setup(struct qed_hwfn		*p_hwfn,
+		      struct qed_ptt		*p_ptt,
+		      struct qed_sb_info	*sb_info);
+
+/**
+ * @brief qed_int_sb_release - releases the sb_info structure.
+ *
+ * once the structure is released, it's memory can be freed
+ *
+ * @param p_hwfn
+ * @param sb_info	points to an allocated sb_info structure
+ * @param sb_id		the sb_id to be used (zero based in driver)
+ *			should never be equal to QED_SP_SB_ID
+ *			(SP Status block)
+ *
+ * @return int
+ */
+int qed_int_sb_release(struct qed_hwfn		*p_hwfn,
+		       struct qed_sb_info	*sb_info,
+		       u16			sb_id);
+
+/**
+ * @brief qed_int_sp_dpc - To be called when an interrupt is received on the
+ *        default status block.
+ *
+ * @param p_hwfn - pointer to hwfn
+ *
+ */
+void qed_int_sp_dpc(unsigned long hwfn_cookie);
+
+/**
+ * @brief qed_int_get_num_sbs - get the number of status
+ *        blocks configured for this funciton in the igu.
+ *
+ * @param p_hwfn
+ * @param p_iov_blks - configured free blks for vfs
+ *
+ * @return int - number of status blocks configured
+ */
+int qed_int_get_num_sbs(struct qed_hwfn *p_hwfn,
+			int		*p_iov_blks);
+
+/**
+ * @file
+ *
+ * @brief Interrupt handler
+ */
+
+#define QED_CAU_DEF_RX_TIMER_RES 0
+#define QED_CAU_DEF_TX_TIMER_RES 0
+
+#define QED_SB_ATT_IDX  0x0001
+#define QED_SB_EVENT_MASK       0x0003
+
+#define SB_ALIGNED_SIZE(p_hwfn)	\
+	ALIGNED_TYPE_SIZE(struct status_block, p_hwfn)
+
+struct qed_igu_block {
+	u8	status;
+#define QED_IGU_STATUS_FREE     0x01
+#define QED_IGU_STATUS_VALID    0x02
+#define QED_IGU_STATUS_PF       0x04
+
+	u8	vector_number;
+	u8	function_id;
+	u8	is_pf;
+};
+
+struct qed_igu_map {
+	struct qed_igu_block igu_blocks[MAX_TOT_SB_PER_PATH];
+};
+
+struct qed_igu_info {
+	struct qed_igu_map	igu_map;
+	u16			igu_dsb_id;
+	u16			igu_base_sb;
+	u16			igu_base_sb_iov;
+	u16			igu_sb_cnt;
+	u16			igu_sb_cnt_iov;
+	u16			free_blks;
+};
+
+/* TODO Names of function may change... */
+void qed_int_igu_init_pure_rt(struct qed_hwfn	*p_hwfn,
+			      struct qed_ptt	*p_ptt,
+			      bool		b_set,
+			      bool		b_slowpath);
+
+void qed_int_igu_init_rt(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_int_igu_read_cam - Reads the IGU CAM.
+ *	This function needs to be called during hardware
+ *	prepare. It reads the info from igu cam to know which
+ *	status block is the default / base status block etc.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ *
+ * @return int
+ */
+int qed_int_igu_read_cam(struct qed_hwfn	*p_hwfn,
+			 struct qed_ptt		*p_ptt);
+
+typedef int (*qed_int_comp_cb_t)(struct qed_hwfn	*p_hwfn,
+				 void			*cookie);
+/**
+ * @brief qed_int_register_cb - Register callback func for
+ *      slowhwfn statusblock.
+ *
+ *	Every protocol that uses the slowhwfn status block
+ *	should register a callback function that will be called
+ *	once there is an update of the sp status block.
+ *
+ * @param p_hwfn
+ * @param comp_cb - function to be called when there is an
+ *                  interrupt on the sp sb
+ *
+ * @param cookie  - passed to the callback function
+ * @param sb_idx  - OUT parameter which gives the chosen index
+ *                  for this protocol.
+ * @param p_fw_cons  - pointer to the actual address of the
+ *                     consumer for this protocol.
+ *
+ * @return int
+ */
+int qed_int_register_cb(struct qed_hwfn		*p_hwfn,
+			qed_int_comp_cb_t	comp_cb,
+			void			*cookie,
+			u8			*sb_idx,
+			__le16			**p_fw_cons);
+
+/**
+ * @brief qed_int_unregister_cb - Unregisters callback
+ *      function from sp sb.
+ *      Partner of qed_int_register_cb -> should be called
+ *      when no longer required.
+ *
+ * @param p_hwfn
+ * @param pi
+ *
+ * @return int
+ */
+int qed_int_unregister_cb(struct qed_hwfn	*p_hwfn,
+			  u8			pi);
+
+/**
+ * @brief qed_int_get_sp_sb_id - Get the slowhwfn sb id.
+ *
+ * @param p_hwfn
+ *
+ * @return u16
+ */
+u16 qed_int_get_sp_sb_id(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief Status block cleanup. Should be called for each status
+ *        block that will be used -> both PF / VF
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param sb_id		- igu status block id
+ * @param cleanup_set	- set(1) / clear(0)
+ * @param opaque_fid    - the function for which to perform
+ *			cleanup, for example a PF on behalf of
+ *			its VFs.
+ */
+void qed_int_igu_cleanup_sb(struct qed_hwfn	*p_hwfn,
+			    struct qed_ptt	*p_ptt,
+			    u32			sb_id,
+			    bool		cleanup_set,
+			    u16			opaque_fid);
+
+/**
+ * @brief Status block cleanup. Should be called for each status
+ *        block that will be used -> both PF / VF
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param sb_id		- igu status block id
+ * @param opaque	- opaque fid of the sb owner.
+ * @param cleanup_set	- set(1) / clear(0)
+ */
+void qed_int_igu_init_pure_rt_single(struct qed_hwfn	*p_hwfn,
+				     struct qed_ptt	*p_ptt,
+				     u32		sb_id,
+				     u16		opaque,
+				     bool		b_set);
+
+/**
+ * @brief qed_int_cau_conf - configure cau for a given status
+ *        block
+ *
+ * @param p_hwfn
+ * @param ptt
+ * @param sb_phys
+ * @param igu_sb_id
+ * @param vf_number
+ * @param vf_valid
+ */
+void qed_int_cau_conf_sb(struct qed_hwfn	*p_hwfn,
+			 struct qed_ptt		*p_ptt,
+			 dma_addr_t		sb_phys,
+			 u16			igu_sb_id,
+			 u16			vf_number,
+			 u8			vf_valid);
+
+/**
+ * @brief qed_int_alloc
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ *
+ * @return int
+ */
+int qed_int_alloc(struct qed_hwfn	*p_hwfn,
+		  struct qed_ptt	*p_ptt);
+
+/**
+ * @brief qed_int_free
+ *
+ * @param p_hwfn
+ */
+void qed_int_free(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_int_setup
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ */
+void qed_int_setup(struct qed_hwfn	*p_hwfn,
+		   struct qed_ptt	*p_ptt);
+
+/**
+ * @brief - Enable Interrupt & Attention for hw function
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param int_mode
+ */
+void qed_int_igu_enable(struct qed_hwfn		*p_hwfn,
+			struct qed_ptt		*p_ptt,
+			enum qed_int_mode	int_mode);
+
+/**
+ * @brief - Initialize CAU status block entry
+ *
+ * @param p_hwfn
+ * @param p_sb_entry
+ * @param pf_id
+ * @param vf_number
+ * @param vf_valid
+ */
+void qed_init_cau_sb_entry(struct qed_hwfn	*p_hwfn,
+			   struct cau_sb_entry	*p_sb_entry,
+			   u8			pf_id,
+			   u16			vf_number,
+			   u8			vf_valid);
+
+#define QED_MAPPING_MEMORY_SIZE(dev)	(NUM_OF_SBS(dev))
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
new file mode 100644
index 0000000..f2870d6
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -0,0 +1,1000 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/stddef.h>
+#include <linux/pci.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/version.h>
+#include <linux/delay.h>
+#include <asm/byteorder.h>
+#include <linux/dma-mapping.h>
+#include <linux/string.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/workqueue.h>
+#include <linux/ethtool.h>
+#include <linux/etherdevice.h>
+#include <linux/vmalloc.h>
+#include <linux/qed/qed_if.h>
+
+#include "qed.h"
+#include "qed_sp.h"
+#include "qed_dev_api.h"
+#include "qed_mcp.h"
+#include "qed_hw.h"
+
+static const char version[] =
+	"QLogic 579xx 40G/100G Ethernet Driver qed " DRV_MODULE_VERSION "\n";
+
+MODULE_DESCRIPTION("QLogic 25G/40G/50G/100G Core Module");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_MODULE_VERSION);
+
+#define FW_FILE_VERSION				\
+	__stringify(FW_MAJOR_VERSION) "."	\
+	__stringify(FW_MINOR_VERSION) "."	\
+	__stringify(FW_REVISION_VERSION) "."	\
+	__stringify(FW_ENGINEERING_VERSION)
+
+#define QED_FW_FILE_NAME	\
+	"qed/qed_init_values_zipped-" FW_FILE_VERSION ".bin"
+
+static int __init qed_init(void)
+{
+	pr_notice("qed_init called\n");
+
+	pr_info("%s", version);
+
+	return 0;
+}
+
+static void __exit qed_cleanup(void)
+{
+	pr_notice("qed_cleanup called\n");
+}
+
+module_init(qed_init);
+module_exit(qed_cleanup);
+
+/* Check if the DMA controller on the machine can properly handle the DMA
+ * addressing required by the device.
+*/
+static int qed_set_coherency_mask(struct qed_dev *cdev)
+{
+	struct device *dev = &cdev->pdev->dev;
+
+	if (dma_set_mask(dev, DMA_BIT_MASK(64)) == 0) {
+		if (dma_set_coherent_mask(dev, DMA_BIT_MASK(64)) != 0) {
+			DP_NOTICE(cdev,
+				  "Can't request 64-bit consistent allocations\n");
+			return -EIO;
+		}
+	} else if (dma_set_mask(dev, DMA_BIT_MASK(32)) != 0) {
+		DP_NOTICE(cdev, "Can't request 64b/32b DMA addresses\n");
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static void qed_free_pci(struct qed_dev *cdev)
+{
+	struct pci_dev *pdev = cdev->pdev;
+
+	if (cdev->doorbells)
+		iounmap(cdev->doorbells);
+	if (cdev->regview)
+		iounmap(cdev->regview);
+	if (atomic_read(&pdev->enable_cnt) == 1)
+		pci_release_regions(pdev);
+
+	pci_disable_device(pdev);
+}
+
+/* Performs PCI initializations as well as initializing PCI-related parameters
+ * in the device structrue. Returns 0 in case of success.
+ */
+static int qed_init_pci(struct qed_dev *cdev,
+			struct pci_dev *pdev)
+{
+	int rc;
+
+	cdev->pdev = pdev;
+
+	rc = pci_enable_device(pdev);
+	if (rc) {
+		DP_NOTICE(cdev, "Cannot enable PCI device\n");
+		goto err0;
+	}
+
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+		DP_NOTICE(cdev, "No memory region found in bar #0\n");
+		rc = -EIO;
+		goto err1;
+	}
+
+	if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
+		DP_NOTICE(cdev, "No memory region found in bar #2\n");
+		rc = -EIO;
+		goto err1;
+	}
+
+	if (atomic_read(&pdev->enable_cnt) == 1) {
+		rc = pci_request_regions(pdev, "qed");
+		if (rc) {
+			DP_NOTICE(cdev,
+				  "Failed to request PCI memory resources\n");
+			goto err1;
+		}
+		pci_set_master(pdev);
+		pci_save_state(pdev);
+	}
+
+	if (!pci_is_pcie(pdev)) {
+		DP_NOTICE(cdev, "The bus is not PCI Express\n");
+		rc = -EIO;
+		goto err2;
+	}
+
+	cdev->pci_params.pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
+	if (cdev->pci_params.pm_cap == 0) {
+		DP_NOTICE(cdev, "Cannot find power management capability\n");
+		/* FIXME - emulation currently has no PM (13_06_04) */
+		/* rc = -EIO;
+		 * goto err2;
+		 */
+	}
+
+	rc = qed_set_coherency_mask(cdev);
+	if (rc)
+		goto err2;
+
+	cdev->pci_params.mem_start = pci_resource_start(pdev, 0);
+	cdev->pci_params.mem_end = pci_resource_end(pdev, 0);
+	cdev->pci_params.irq = pdev->irq;
+
+	cdev->regview = pci_ioremap_bar(pdev, 0);
+	if (!cdev->regview) {
+		DP_NOTICE(cdev, "Cannot map register space, aborting\n");
+		rc = -ENOMEM;
+		goto err2;
+	}
+
+	cdev->db_phys_addr = pci_resource_start(cdev->pdev, 2);
+	cdev->db_size = pci_resource_len(cdev->pdev, 2);
+	cdev->doorbells = ioremap_wc(cdev->db_phys_addr, cdev->db_size);
+	if (!cdev->doorbells) {
+		DP_NOTICE(cdev, "Cannot map doorbell space\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+
+err2:
+	pci_release_regions(pdev);
+err1:
+	pci_disable_device(pdev);
+err0:
+	return rc;
+}
+
+int qed_fill_dev_info(struct qed_dev *cdev,
+		      struct qed_dev_info *dev_info)
+{
+	memset(dev_info, 0, sizeof(struct qed_dev_info));
+
+	dev_info->num_hwfns = cdev->num_hwfns;
+	dev_info->pci_mem_start = cdev->pci_params.mem_start;
+	dev_info->pci_mem_end = cdev->pci_params.mem_end;
+	dev_info->pci_irq = cdev->pci_params.irq;
+	dev_info->is_mf = IS_MF(&cdev->hwfns[0]);
+	ether_addr_copy(dev_info->hw_mac, cdev->hwfns[0].hw_info.hw_mac_addr);
+
+	dev_info->fw_major = FW_MAJOR_VERSION;
+	dev_info->fw_minor = FW_MINOR_VERSION;
+	dev_info->fw_rev = FW_REVISION_VERSION;
+	dev_info->fw_eng = FW_ENGINEERING_VERSION;
+	dev_info->mf_mode = cdev->mf_mode;
+
+	qed_mcp_get_mfw_ver(cdev, &dev_info->mfw_rev);
+
+	return 0;
+}
+
+static void qed_free_cdev(struct qed_dev *cdev)
+{
+	kfree((void *)cdev);
+}
+
+static struct qed_dev *qed_alloc_cdev(struct pci_dev *pdev)
+{
+	struct qed_dev *cdev;
+
+	cdev = kzalloc(sizeof(*cdev), GFP_KERNEL);
+	if (!cdev)
+		return cdev;
+
+	qed_init_struct(cdev);
+
+	return cdev;
+}
+
+/* Sets the requested power state */
+static int qed_set_power_state(struct qed_dev *cdev,
+			       pci_power_t state)
+{
+	struct pci_dev *pdev = cdev->pdev;
+	u16 pmcsr;
+
+	if (!cdev)
+		return -ENODEV;
+
+	/* FIXME - emulation currently does not support PM (13_06_04) */
+	DP_VERBOSE(cdev, NETIF_MSG_DRV, "Omitting Power state change\n");
+	return 0;
+
+	pci_read_config_word(pdev, cdev->pci_params.pm_cap + PCI_PM_CTRL,
+			     &pmcsr);
+
+	switch (state) {
+	case PCI_D0:
+		pci_write_config_word(pdev,
+				      cdev->pci_params.pm_cap + PCI_PM_CTRL,
+				      ((pmcsr & ~PCI_PM_CTRL_STATE_MASK) |
+				       PCI_PM_CTRL_PME_STATUS));
+
+		if (pmcsr & PCI_PM_CTRL_STATE_MASK)
+			/* delay required during transition out of D3hot */
+			msleep(20);
+		break;
+
+	case PCI_D3hot:
+		/* If there are other clients (e.g. Diag) above don't shut down
+		 * the power.
+		 */
+		if (atomic_read(&cdev->pdev->enable_cnt) != 1)
+			return 0;
+		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
+		pmcsr |= 3;
+
+		if (cdev->wol)
+			pmcsr |= PCI_PM_CTRL_PME_ENABLE;
+
+		pci_write_config_word(pdev,
+				      cdev->pci_params.pm_cap + PCI_PM_CTRL,
+				      pmcsr);
+
+		/* No more memory access after this point until
+		* device is brought back to D0.
+		*/
+		break;
+
+	default:
+		DP_ERR(cdev, "Can't support state = %d\n", state);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* probing */
+static struct qed_dev *qed_probe(struct pci_dev *pdev,
+				 enum qed_protocol protocol,
+				 u32 dp_module,
+				 u8 dp_level)
+{
+	struct qed_dev *cdev;
+	int rc;
+
+	cdev = qed_alloc_cdev(pdev);
+	if (!cdev)
+		goto err0;
+
+	cdev->protocol = protocol;
+
+	qed_init_dp(cdev, dp_module, dp_level);
+
+	rc = qed_init_pci(cdev, pdev);
+	if (rc) {
+		DP_ERR(cdev, "init pci failed\n");
+		goto err1;
+	}
+	DP_INFO(cdev, "PCI init completed successfully\n");
+
+	rc = qed_hw_prepare(cdev, QED_PCI_DEFAULT);
+	if (rc) {
+		DP_ERR(cdev, "hw prepare failed\n");
+		goto err2;
+	}
+
+	DP_INFO(cdev, "qed_probe completed successffuly\n");
+
+	return cdev;
+
+err2:
+	qed_free_pci(cdev);
+err1:
+	qed_free_cdev(cdev);
+err0:
+	return NULL;
+}
+
+static void qed_remove(struct qed_dev *cdev)
+{
+	if (!cdev)
+		return;
+
+	qed_hw_remove(cdev);
+
+	qed_free_pci(cdev);
+
+	qed_set_power_state(cdev, PCI_D3hot);
+
+	qed_free_cdev(cdev);
+}
+
+static void qed_disable_msix(struct qed_dev *cdev)
+{
+	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
+		pci_disable_msix(cdev->pdev);
+		kfree(cdev->int_params.msix_table);
+	} else if (cdev->int_params.out.int_mode == QED_INT_MODE_MSI) {
+		pci_disable_msi(cdev->pdev);
+	}
+
+	memset(&cdev->int_params.out, 0, sizeof(struct qed_int_param));
+}
+
+static int qed_enable_msix(struct qed_dev *cdev,
+			   struct qed_int_params *int_params)
+{
+	int i, rc, cnt;
+
+	cnt = int_params->in.num_vectors;
+
+	for (i = 0; i < cnt; i++)
+		int_params->msix_table[i].entry = i;
+
+	rc = pci_enable_msix_range(cdev->pdev, int_params->msix_table,
+				   int_params->in.min_msix_cnt, cnt);
+	if (rc < cnt && rc >= int_params->in.min_msix_cnt &&
+	    (rc % cdev->num_hwfns)) {
+		pci_disable_msix(cdev->pdev);
+
+		/* If fastpath is initialized, we need at least one interrupt
+		 * per hwfn [and the slow path interrupts]. New requested number
+		 * should be a multiple of the number of hwfns.
+		 */
+		cnt = (rc / cdev->num_hwfns) * cdev->num_hwfns;
+		DP_NOTICE(cdev,
+			  "Trying to enable MSI-X with less vectors (%d out of %d)\n",
+			  cnt, int_params->in.num_vectors);
+		rc = pci_enable_msix_exact(cdev->pdev,
+					   int_params->msix_table, cnt);
+		if (!rc)
+			rc = cnt;
+	}
+
+	if (rc > 0) {
+		/* MSI-x configuration was achieved */
+		int_params->out.int_mode = QED_INT_MODE_MSIX;
+		int_params->out.num_vectors = rc;
+		rc = 0;
+	} else {
+		DP_NOTICE(cdev,
+			  "Failed to enable MSI-X [Requested %d vectors][rc %d]\n",
+			  cnt, rc);
+	}
+
+	return rc;
+}
+
+/* This function outputs the int mode and the number of enabled msix vector */
+static int qed_set_int_mode(struct qed_dev *cdev, bool force_mode)
+{
+	struct qed_int_params *int_params = &cdev->int_params;
+	struct msix_entry *tbl;
+	int rc = 0, cnt;
+
+	switch (int_params->in.int_mode) {
+	case QED_INT_MODE_MSIX:
+		/* Allocate MSIX table */
+		cnt = int_params->in.num_vectors;
+		int_params->msix_table = kcalloc(cnt, sizeof(*tbl), GFP_KERNEL);
+		if (!int_params->msix_table) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		/* Enable MSIX */
+		rc = qed_enable_msix(cdev, int_params);
+		if (!rc)
+			goto out;
+
+		DP_NOTICE(cdev, "Failed to enable MSI-X\n");
+		kfree(int_params->msix_table);
+		if (force_mode)
+			goto out;
+		/* Fallthrough */
+
+	case QED_INT_MODE_MSI:
+		rc = pci_enable_msi(cdev->pdev);
+		if (!rc) {
+			int_params->out.int_mode = QED_INT_MODE_MSI;
+			goto out;
+		}
+
+		DP_NOTICE(cdev, "Failed to enable MSI\n");
+		if (force_mode)
+			goto out;
+		/* Fallthrough */
+
+	case QED_INT_MODE_INTA:
+			int_params->out.int_mode = QED_INT_MODE_INTA;
+			rc = 0;
+			goto out;
+	default:
+		DP_NOTICE(cdev, "Unknown int_mode value %d\n",
+			  int_params->in.int_mode);
+		rc = -EINVAL;
+	}
+
+out:
+	cdev->int_coalescing_mode = QED_COAL_MODE_ENABLE;
+
+	return rc;
+}
+
+static void qed_simd_handler_config(struct qed_dev *cdev, void *token,
+				    int index, void(*handler)(void *))
+{
+	struct qed_hwfn *hwfn = &cdev->hwfns[index % cdev->num_hwfns];
+	int relative_idx = index / cdev->num_hwfns;
+
+	hwfn->simd_proto_handler[relative_idx].func = handler;
+	hwfn->simd_proto_handler[relative_idx].token = token;
+}
+
+static void qed_simd_handler_clean(struct qed_dev *cdev, int index)
+{
+	struct qed_hwfn *hwfn = &cdev->hwfns[index % cdev->num_hwfns];
+	int relative_idx = index / cdev->num_hwfns;
+
+	memset(&hwfn->simd_proto_handler[relative_idx], 0,
+	       sizeof(struct qed_simd_fp_handler));
+}
+
+static irqreturn_t qed_msix_sp_int(int irq, void *tasklet)
+{
+	tasklet_schedule((struct tasklet_struct *)tasklet);
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t qed_single_int(int irq, void *dev_instance)
+{
+	struct qed_dev *cdev = (struct qed_dev *)dev_instance;
+	struct qed_hwfn *hwfn;
+	irqreturn_t rc = IRQ_NONE;
+	u64 status;
+	int i, j;
+
+	for (i = 0; i < cdev->num_hwfns; i++) {
+		status = qed_int_igu_read_sisr_reg(&cdev->hwfns[i]);
+
+		if (!status)
+			continue;
+
+		hwfn = &cdev->hwfns[i];
+
+		/* Slowpath interrupt */
+		if (unlikely(status & 0x1)) {
+			tasklet_schedule(hwfn->sp_dpc);
+			status &= ~0x1;
+			rc = IRQ_HANDLED;
+		}
+
+		/* Fastpath interrupts */
+		for (j = 0; j < 64; j++) {
+			if ((0x2ULL << j) & status) {
+				hwfn->simd_proto_handler[j].func(
+					hwfn->simd_proto_handler[j].token);
+				status &= ~(0x2ULL << j);
+				rc = IRQ_HANDLED;
+			}
+		}
+
+		if (unlikely(status))
+			DP_VERBOSE(hwfn, NETIF_MSG_INTR,
+				   "got an unknown interrupt status 0x%llx\n",
+				   status);
+	}
+
+	return rc;
+}
+
+static int qed_slowpath_irq_req(struct qed_dev *cdev)
+{
+	int i = 0, rc = 0;
+
+	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
+		/* Request all the slowpath MSI-X vectors */
+		for (i = 0; i < cdev->num_hwfns; i++) {
+			snprintf(cdev->hwfns[i].name, NAME_SIZE,
+				 "sp-%d-%02x:%02x.%02x",
+				 i, cdev->pdev->bus->number,
+				 PCI_SLOT(cdev->pdev->devfn),
+				 cdev->hwfns[i].abs_pf_id);
+
+			rc = request_irq(cdev->int_params.msix_table[i].vector,
+					 qed_msix_sp_int, 0,
+					 cdev->hwfns[i].name,
+					 cdev->hwfns[i].sp_dpc);
+			if (rc)
+				break;
+
+			DP_VERBOSE(&cdev->hwfns[i],
+				   (NETIF_MSG_INTR | QED_MSG_SP),
+				   "Requested slowpath MSI-X\n");
+		}
+
+		if (i != cdev->num_hwfns) {
+			/* Free already request MSI-X vectors */
+			for (i--; i >= 0; i--) {
+				unsigned int vec =
+					cdev->int_params.msix_table[i].vector;
+				synchronize_irq(vec);
+				free_irq(cdev->int_params.msix_table[i].vector,
+					 cdev->hwfns[i].sp_dpc);
+			}
+		}
+	} else {
+		unsigned long flags = 0;
+
+		snprintf(cdev->name, NAME_SIZE, "%02x:%02x.%02x",
+			 cdev->pdev->bus->number, PCI_SLOT(cdev->pdev->devfn),
+			 PCI_FUNC(cdev->pdev->devfn));
+
+		if (cdev->int_params.out.int_mode == QED_INT_MODE_INTA)
+			flags |= IRQF_SHARED;
+
+		rc = request_irq(cdev->pdev->irq, qed_single_int,
+				 flags, cdev->name, cdev);
+	}
+
+	return rc;
+}
+
+static void qed_slowpath_irq_free(struct qed_dev *cdev)
+{
+	int i;
+
+	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
+		for_each_hwfn(cdev, i) {
+			synchronize_irq(cdev->int_params.msix_table[i].vector);
+			free_irq(cdev->int_params.msix_table[i].vector,
+				 cdev->hwfns[i].sp_dpc);
+		}
+	} else {
+		/* @@@TODO - correct squence for freeing INTA ? */
+		free_irq(cdev->pdev->irq, cdev);
+	}
+}
+
+static int qed_nic_stop(struct qed_dev *cdev)
+{
+	int i, rc;
+
+	rc = qed_hw_stop(cdev);
+
+	for (i = 0; i < cdev->num_hwfns; i++) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		if (p_hwfn->b_sp_dpc_enabled) {
+			tasklet_disable(p_hwfn->sp_dpc);
+			p_hwfn->b_sp_dpc_enabled = false;
+			DP_VERBOSE(cdev, NETIF_MSG_IFDOWN,
+				   "Disabled sp taskelt [hwfn %d] at %p\n",
+				   i, p_hwfn->sp_dpc);
+		}
+	}
+
+	return rc;
+}
+
+static int qed_nic_reset(struct qed_dev *cdev)
+{
+	int rc;
+
+	rc = qed_hw_reset(cdev);
+	if (rc)
+		return rc;
+
+	qed_resc_free(cdev);
+
+	return 0;
+}
+
+static int qed_nic_setup(struct qed_dev *cdev)
+{
+	int rc;
+
+	rc = qed_resc_alloc(cdev);
+	if (rc)
+		return rc;
+
+	DP_INFO(cdev, "Allocated qed resources\n");
+
+	qed_resc_setup(cdev);
+
+	return rc;
+}
+
+static int qed_set_int_fp(struct qed_dev *cdev, u16 cnt)
+{
+	int limit = 0;
+
+	/* Mark the fastpath as free/used */
+	cdev->int_params.fp_initialized = cnt ? true : false;
+
+	if (cdev->int_params.out.int_mode != QED_INT_MODE_MSIX)
+		limit = cdev->num_hwfns * 63;
+	else if (cdev->int_params.fp_msix_cnt)
+		limit = cdev->int_params.fp_msix_cnt;
+
+	if (!limit)
+		return -ENOMEM;
+
+	return min_t(int, cnt, limit);
+}
+
+static int qed_get_int_fp(struct qed_dev *cdev, struct qed_int_info *info)
+{
+	memset(info, 0, sizeof(struct qed_int_info));
+
+	if (!cdev->int_params.fp_initialized) {
+		DP_INFO(cdev,
+			"Protocol driver requested interrupt information, but its support is not yet configured\n");
+		return -EINVAL;
+	}
+
+	/* Need to expose only MSI-X information; Single IRQ is handled solely
+	 * by qed.
+	 */
+	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
+		int msix_base = cdev->int_params.fp_msix_base;
+
+		info->msix_cnt = cdev->int_params.fp_msix_cnt;
+		info->msix = &cdev->int_params.msix_table[msix_base];
+	}
+
+	return 0;
+}
+
+static int qed_slowpath_setup_int(struct qed_dev *cdev,
+				  enum qed_int_mode int_mode)
+{
+	int rc, i;
+
+	memset(&cdev->int_params, 0, sizeof(struct qed_int_params));
+
+	cdev->int_params.in.int_mode = int_mode;
+	for_each_hwfn(cdev, i) {
+		cdev->int_params.in.num_vectors +=
+			qed_int_get_num_sbs(&cdev->hwfns[i], NULL);
+		cdev->int_params.in.num_vectors++; /* slowpath */
+	}
+
+	/* We want a minimum of one slowpath and one fastpath vector per hwfn */
+	cdev->int_params.in.min_msix_cnt = cdev->num_hwfns * 2;
+
+	rc = qed_set_int_mode(cdev, false);
+	if (rc)  {
+		DP_ERR(cdev, "qed_slowpath_setup_int ERR\n");
+		return rc;
+	}
+
+	cdev->int_params.fp_msix_base = cdev->num_hwfns;
+	cdev->int_params.fp_msix_cnt =
+		cdev->int_params.out.num_vectors - cdev->num_hwfns;
+
+	return 0;
+}
+
+u32 qed_unzip_data(struct qed_hwfn *p_hwfn, u32 input_len,
+		   u8 *input_buf, u32 max_size, u8 *unzip_buf)
+{
+	int rc;
+
+	p_hwfn->stream->next_in = input_buf;
+	p_hwfn->stream->avail_in = input_len;
+	p_hwfn->stream->next_out = unzip_buf;
+	p_hwfn->stream->avail_out = max_size;
+
+	rc = zlib_inflateInit2(p_hwfn->stream, MAX_WBITS);
+
+	if (rc != Z_OK) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_DRV, "zlib init failed, rc = %d\n",
+			   rc);
+		return 0;
+	}
+
+	rc = zlib_inflate(p_hwfn->stream, Z_FINISH);
+	zlib_inflateEnd(p_hwfn->stream);
+
+	if (rc != Z_OK && rc != Z_STREAM_END) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_DRV, "FW unzip error: %s, rc=%d\n",
+			   p_hwfn->stream->msg, rc);
+		return 0;
+	}
+
+	return p_hwfn->stream->total_out / 4;
+}
+
+static int qed_alloc_stream_mem(struct qed_dev *cdev)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		p_hwfn->stream = kzalloc(sizeof(*p_hwfn->stream), GFP_KERNEL);
+		if (!p_hwfn->stream)
+			return -ENOMEM;
+
+		p_hwfn->stream->workspace =
+				vzalloc(zlib_inflate_workspacesize());
+		if (!p_hwfn->stream->workspace)
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void qed_free_stream_mem(struct qed_dev *cdev)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		if (!p_hwfn->stream)
+			return;
+
+		vfree(p_hwfn->stream->workspace);
+		kfree(p_hwfn->stream);
+	}
+}
+
+static void qed_update_pf_params(struct qed_dev *cdev,
+				 struct qed_pf_params *params)
+{
+	int i;
+
+	for (i = 0; i < cdev->num_hwfns; i++) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		p_hwfn->pf_params = *params;
+	}
+}
+
+static int qed_slowpath_start(struct qed_dev *cdev,
+			      struct qed_slowpath_params *params)
+{
+	const u8 *data = NULL;
+	struct qed_hwfn *hwfn;
+	struct qed_mcp_drv_version drv_version;
+	int rc;
+
+	rc = request_firmware(&cdev->firmware, QED_FW_FILE_NAME,
+			      &cdev->pdev->dev);
+	if (rc) {
+		DP_NOTICE(cdev,
+			  "Failed to find fw file - /lib/firmware/%s\n",
+			  QED_FW_FILE_NAME);
+		goto err;
+	}
+
+	rc = qed_nic_setup(cdev);
+	if (rc)
+		goto err;
+
+	rc = qed_slowpath_setup_int(cdev, params->int_mode);
+	if (rc)
+		goto err1;
+
+	/* Request the slowpath IRQ */
+	rc = qed_slowpath_irq_req(cdev);
+	if (rc)
+		goto err2;
+
+	/* Allocate stream for unzipping */
+	rc = qed_alloc_stream_mem(cdev);
+	if (rc) {
+		DP_NOTICE(cdev, "Failed to allocate stream memory\n");
+		goto err3;
+	}
+
+	/* Start the slowpath */
+	data = cdev->firmware->data;
+
+	rc = qed_hw_init(cdev, true, cdev->int_params.out.int_mode,
+			 true, data);
+	if (rc)
+		goto err3;
+
+	DP_INFO(cdev,
+		"HW initialization and function start completed successfully\n");
+
+	hwfn = QED_LEADING_HWFN(cdev);
+	drv_version.version = (params->drv_major << 24) |
+			      (params->drv_minor << 16) |
+			      (params->drv_rev << 8) |
+			      (params->drv_eng);
+	strlcpy(drv_version.name, params->name,
+		MCP_DRV_VER_STR_SIZE - 4);
+	rc = qed_mcp_send_drv_version(hwfn, hwfn->p_main_ptt,
+				      &drv_version);
+	if (rc) {
+		DP_NOTICE(cdev, "Failed sending drv version command\n");
+		return rc;
+	}
+
+	return 0;
+
+err3:
+	qed_free_stream_mem(cdev);
+	qed_slowpath_irq_free(cdev);
+err2:
+	qed_disable_msix(cdev);
+err1:
+	qed_resc_free(cdev);
+err:
+	release_firmware(cdev->firmware);
+
+	return rc;
+}
+
+static int qed_slowpath_stop(struct qed_dev *cdev)
+{
+	if (!cdev)
+		return -ENODEV;
+
+	qed_free_stream_mem(cdev);
+
+	qed_nic_stop(cdev);
+	qed_slowpath_irq_free(cdev);
+
+	qed_disable_msix(cdev);
+	qed_nic_reset(cdev);
+
+	release_firmware(cdev->firmware);
+
+	return 0;
+}
+
+static void qed_set_id(struct qed_dev *cdev, char name[NAME_SIZE],
+		       char ver_str[VER_SIZE])
+{
+	int i;
+
+	memcpy(cdev->name, name, NAME_SIZE);
+	for_each_hwfn(cdev, i) {
+		snprintf(cdev->hwfns[i].name, NAME_SIZE, "%s-%d", name, i);
+	}
+	memcpy(cdev->ver_str, ver_str, VER_SIZE);
+	cdev->drv_type = DRV_ID_DRV_TYPE_LINUX;
+}
+
+static u32 qed_sb_init(struct qed_dev *cdev,
+		       struct qed_sb_info *sb_info,
+		       void *sb_virt_addr,
+		       dma_addr_t sb_phy_addr, u16 sb_id,
+		       enum qed_sb_type type)
+{
+	struct qed_hwfn *p_hwfn;
+	int hwfn_index;
+	u16 rel_sb_id;
+	u8 n_hwfns;
+	u32 rc;
+
+	/* RoCE uses single engine and CMT uses two engines. When using both
+	 * we force only a single engine. Storage uses only engine 0 too.
+	 */
+	if (type == QED_SB_TYPE_L2_QUEUE)
+		n_hwfns = cdev->num_hwfns;
+	else
+		n_hwfns = 1;
+
+	hwfn_index = sb_id % n_hwfns;
+	p_hwfn = &cdev->hwfns[hwfn_index];
+	rel_sb_id = sb_id / n_hwfns;
+
+	DP_VERBOSE(cdev, NETIF_MSG_INTR,
+		   "hwfn [%d] <--[init]-- SB %04x [0x%04x upper]\n",
+		   hwfn_index, rel_sb_id, sb_id);
+
+	rc = qed_int_sb_init(p_hwfn, p_hwfn->p_main_ptt, sb_info,
+			     sb_virt_addr, sb_phy_addr, rel_sb_id);
+
+	return rc;
+}
+
+static u32 qed_sb_release(struct qed_dev *cdev,
+			  struct qed_sb_info *sb_info,
+			  u16 sb_id)
+{
+	struct qed_hwfn *p_hwfn;
+	int hwfn_index;
+	u16 rel_sb_id;
+	u32 rc;
+
+	hwfn_index = sb_id % cdev->num_hwfns;
+	p_hwfn = &cdev->hwfns[hwfn_index];
+	rel_sb_id = sb_id / cdev->num_hwfns;
+
+	DP_VERBOSE(cdev, NETIF_MSG_INTR,
+		   "hwfn [%d] <--[init]-- SB %04x [0x%04x upper]\n",
+		   hwfn_index, rel_sb_id, sb_id);
+
+	rc = qed_int_sb_release(p_hwfn, sb_info, rel_sb_id);
+
+	return rc;
+}
+
+static int qed_drain(struct qed_dev *cdev)
+{
+	struct qed_hwfn *hwfn;
+	struct qed_ptt *ptt;
+	int i, rc;
+
+	for_each_hwfn(cdev, i) {
+		hwfn = &cdev->hwfns[i];
+		ptt = qed_ptt_acquire(hwfn);
+		if (!ptt) {
+			DP_NOTICE(hwfn, "Failed to drain NIG; No PTT\n");
+			return -EBUSY;
+		}
+		rc = qed_mcp_drain(hwfn, ptt);
+		if (rc)
+			return rc;
+		qed_ptt_release(hwfn, ptt);
+	}
+
+	return 0;
+}
+
+const struct qed_common_ops qed_common_ops_pass = {
+	.probe = &qed_probe,
+	.remove = &qed_remove,
+	.set_power_state = &qed_set_power_state,
+	.set_id = &qed_set_id,
+	.update_pf_params = &qed_update_pf_params,
+	.slowpath_start = &qed_slowpath_start,
+	.slowpath_stop = &qed_slowpath_stop,
+	.set_fp_int = &qed_set_int_fp,
+	.get_fp_int = &qed_get_int_fp,
+	.sb_init = &qed_sb_init,
+	.sb_release = &qed_sb_release,
+	.simd_handler_config = &qed_simd_handler_config,
+	.simd_handler_clean = &qed_simd_handler_clean,
+	.drain = &qed_drain,
+	.update_msglvl = &qed_init_dp,
+	.chain_alloc = &qed_chain_alloc,
+	.chain_free = &qed_chain_free,
+};
+
+u32 qed_get_protocol_version(enum qed_protocol protocol)
+{
+	switch (protocol) {
+	case QED_PROTOCOL_ETH:
+		return QED_ETH_INTERFACE_VERSION;
+	default:
+		return 0;
+	}
+}
+EXPORT_SYMBOL(qed_get_protocol_version);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
new file mode 100644
index 0000000..28eaa65
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -0,0 +1,582 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/delay.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/mutex.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include "qed.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_mcp.h"
+#include "qed_reg_addr.h"
+/**
+ * @file
+ *
+ * @brief ECODE MCP
+ *
+ */
+
+#define CHIP_MCP_RESP_ITER_US 10
+
+#define QED_DRV_MB_MAX_RETRIES	(500 * 1000)	/* Account for 5 sec */
+#define QED_MCP_RESET_RETRIES	(50 * 1000)	/* Account for 500 msec */
+
+#define DRV_INNER_WR(_p_hwfn, _p_ptt, _ptr, _offset, _val)	     \
+	qed_wr(_p_hwfn, _p_ptt, (_p_hwfn->mcp_info->_ptr + _offset), \
+	       _val)
+
+#define DRV_INNER_RD(_p_hwfn, _p_ptt, _ptr, _offset) \
+	qed_rd(_p_hwfn, _p_ptt, (_p_hwfn->mcp_info->_ptr + _offset))
+
+#define DRV_MB_WR(_p_hwfn, _p_ptt, _field, _val)  \
+	DRV_INNER_WR(p_hwfn, _p_ptt, drv_mb_addr, \
+		     offsetof(struct public_drv_mb, _field), _val)
+
+#define DRV_MB_RD(_p_hwfn, _p_ptt, _field)	   \
+	DRV_INNER_RD(_p_hwfn, _p_ptt, drv_mb_addr, \
+		     offsetof(struct public_drv_mb, _field))
+
+#define PDA_COMP (((FW_MAJOR_VERSION) + (FW_MINOR_VERSION << 8)) << \
+		  DRV_ID_PDA_COMP_VER_SHIFT)
+
+#define MCP_BYTES_PER_MBIT_SHIFT 17
+
+bool qed_mcp_is_init(struct qed_hwfn *p_hwfn)
+{
+	if (!p_hwfn->mcp_info || !p_hwfn->mcp_info->public_base)
+		return false;
+	return true;
+}
+
+void qed_mcp_cmd_port_init(struct qed_hwfn	*p_hwfn,
+			   struct qed_ptt	*p_ptt)
+{
+	u32 mfw_mb_offsize = qed_rd(
+			p_hwfn, p_ptt,
+			SECTION_OFFSIZE_ADDR(p_hwfn->mcp_info->public_base,
+					     PUBLIC_PORT));
+
+	p_hwfn->mcp_info->port_addr = SECTION_ADDR(mfw_mb_offsize,
+						   MFW_PORT(p_hwfn));
+	DP_VERBOSE(p_hwfn, QED_MSG_SP,
+		   "port_addr = 0x%x, port_id 0x%02x\n",
+		   p_hwfn->mcp_info->port_addr, MFW_PORT(p_hwfn));
+}
+
+void qed_mcp_read_mb(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt)
+{
+	u32 length = MFW_DRV_MSG_MAX_DWORDS(p_hwfn->mcp_info->mfw_mb_length);
+	u32	tmp;
+	u32	i;
+
+	if (!p_hwfn->mcp_info->public_base)
+		return;
+
+	for (i = 0; i < length; i++) {
+		tmp = qed_rd(p_hwfn, p_ptt,
+			     p_hwfn->mcp_info->mfw_mb_addr +
+			     (i << 2) + sizeof(u32));
+
+		/* The MB data is actually BE; Need to force it to cpu */
+		((u32 *)p_hwfn->mcp_info->mfw_mb_cur)[i] =
+			be32_to_cpu((__force __be32)tmp);
+	}
+}
+
+int qed_mcp_free(struct qed_hwfn *p_hwfn)
+{
+	if (p_hwfn->mcp_info) {
+		kfree(p_hwfn->mcp_info->mfw_mb_cur);
+		kfree(p_hwfn->mcp_info->mfw_mb_shadow);
+		;
+	}
+	kfree(p_hwfn->mcp_info);
+
+	return 0;
+}
+
+static int qed_load_mcp_offsets(struct qed_hwfn	*p_hwfn,
+				struct qed_ptt	*p_ptt)
+{
+	struct qed_mcp_info	*p_info		= p_hwfn->mcp_info;
+	u32			mcp_pf_id	= MCP_PF_ID(p_hwfn);
+	u32			drv_mb_offsize, mfw_mb_offsize;
+
+	p_info->public_base = qed_rd(p_hwfn, p_ptt, MISC_REG_SHARED_MEM_ADDR);
+	if (!p_info->public_base)
+		return 0;
+
+	p_info->public_base |= GRCBASE_MCP;
+
+	/* Calculate the driver and MFW mailbox address */
+	drv_mb_offsize = qed_rd(
+			p_hwfn, p_ptt,
+			SECTION_OFFSIZE_ADDR(p_info->public_base,
+					     PUBLIC_DRV_MB));
+	p_info->drv_mb_addr = SECTION_ADDR(drv_mb_offsize, mcp_pf_id);
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SP,
+		"drv_mb_offsiz = 0x%x, drv_mb_addr = 0x%x mcp_pf_id = 0x%x\n",
+		drv_mb_offsize,
+		p_info->drv_mb_addr,
+		mcp_pf_id);
+
+	/* Set the MFW MB address */
+	mfw_mb_offsize = qed_rd(
+			p_hwfn, p_ptt,
+			SECTION_OFFSIZE_ADDR(p_info->public_base,
+					     PUBLIC_MFW_MB));
+	p_info->mfw_mb_addr	= SECTION_ADDR(mfw_mb_offsize, mcp_pf_id);
+	p_info->mfw_mb_length	=
+		(u16)qed_rd(p_hwfn, p_ptt, p_info->mfw_mb_addr);
+
+	/* Get the current driver mailbox sequence before sending
+	 * the first command
+	 */
+	p_info->drv_mb_seq = DRV_MB_RD(p_hwfn, p_ptt, drv_mb_header) &
+		DRV_MSG_SEQ_NUMBER_MASK;
+
+	/*	printf("p_info->drv_mb_addr 0x%x\n", p_info->drv_mb_addr);*/
+	/* Get current FW pulse sequence */
+	p_info->drv_pulse_seq =
+		DRV_MB_RD(p_hwfn, p_ptt, drv_pulse_mb) & DRV_PULSE_SEQ_MASK;
+
+	p_info->mcp_hist =
+		(u16)qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0);
+
+	return 0;
+}
+
+int qed_mcp_cmd_init(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt)
+{
+	struct qed_mcp_info *p_info;
+
+	/* Allocate mcp_info structure */
+	p_hwfn->mcp_info = kzalloc(sizeof(*p_hwfn->mcp_info), GFP_ATOMIC);
+	if (!p_hwfn->mcp_info)
+		goto err;
+	p_info = p_hwfn->mcp_info;
+
+	if (qed_load_mcp_offsets(p_hwfn, p_ptt) != 0) {
+		DP_NOTICE(p_hwfn, "MCP is not initialized\n");
+		/* Do not free mcp_info here, since public_base indicate that
+		 * the MCP is not initialized
+		 */
+		return 0;
+	}
+
+	p_info->mfw_mb_cur =
+		kzalloc(sizeof(u32) * MFW_DRV_MSG_MAX_DWORDS(
+				p_info->mfw_mb_length), GFP_ATOMIC);
+	p_info->mfw_mb_shadow =
+		kzalloc(sizeof(u32) * MFW_DRV_MSG_MAX_DWORDS(
+				p_info->mfw_mb_length), GFP_ATOMIC);
+	if (!p_info->mfw_mb_shadow || !p_info->mfw_mb_addr)
+		goto err;
+
+	/* Initialize the MFW mutex */
+	;
+	mutex_init(&p_info->mutex);
+
+	return 0;
+
+err:
+	DP_NOTICE(p_hwfn, "Failed to allocate mcp memory\n");
+	qed_mcp_free(p_hwfn);
+	return -ENOMEM;
+}
+
+int qed_mcp_reset(struct qed_hwfn	*p_hwfn,
+		  struct qed_ptt	*p_ptt)
+{
+	u32	org_mcp_reset_seq, cnt = 0;
+	u32	seq	= ++p_hwfn->mcp_info->drv_mb_seq;
+	u8	delay	= CHIP_MCP_RESP_ITER_US;
+	int	rc = 0;
+
+	/* Set drv command along with the updated sequence */
+	org_mcp_reset_seq = qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0);
+	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_header,
+		  (DRV_MSG_CODE_MCP_RESET | seq));
+
+	do {
+		/* Wait for MFW response */
+		udelay(delay);
+		/* Give the FW up to 500 second (50*1000*10usec) */
+	} while ((org_mcp_reset_seq == qed_rd(p_hwfn, p_ptt,
+					      MISCS_REG_GENERIC_POR_0)) &&
+		 (cnt++ < QED_MCP_RESET_RETRIES));
+
+	if (org_mcp_reset_seq !=
+	    qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0)) {
+		DP_VERBOSE(p_hwfn, QED_MSG_SP,
+			   "MCP was reset after %d usec\n", cnt * delay);
+	} else {
+		DP_ERR(p_hwfn, "Failed to reset MCP\n");
+		rc = -EAGAIN;
+	}
+
+	return rc;
+}
+
+static int qed_do_mcp_cmd(struct qed_hwfn	*p_hwfn,
+			  struct qed_ptt	*p_ptt,
+			  u32			cmd,
+			  u32			param,
+			  u32			*o_mcp_resp,
+			  u32			*o_mcp_param)
+{
+	u32	seq, cnt = 1, actual_mb_seq;
+	int	rc	= 0;
+	u8	delay	= CHIP_MCP_RESP_ITER_US;
+
+	/* Get actual driver mailbox sequence */
+	actual_mb_seq = DRV_MB_RD(p_hwfn, p_ptt, drv_mb_header) &
+		DRV_MSG_SEQ_NUMBER_MASK;
+
+	/* Use MCP history register to check if MCP reset occurred between
+	 * init time and now.
+	 */
+	if (p_hwfn->mcp_info->mcp_hist !=
+	    qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0)) {
+		DP_VERBOSE(p_hwfn, QED_MSG_SP, "Rereading MCP offsets\n");
+		qed_load_mcp_offsets(p_hwfn, p_ptt);
+		qed_mcp_cmd_port_init(p_hwfn, p_ptt);
+	}
+	seq = ++p_hwfn->mcp_info->drv_mb_seq;
+
+	/* Set drv param */
+	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_param, param);
+
+	/* Set drv command along with the updated sequence */
+	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_header, (cmd | seq));
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SP,
+		   "wrote command (%x) to MFW MB param 0x%08x\n",
+		   (cmd | seq), param);
+
+	do {
+		/* Wait for MFW response */
+		udelay(delay);
+		*o_mcp_resp = DRV_MB_RD(p_hwfn, p_ptt, fw_mb_header);
+
+		/* Give the FW up to 5 second (500*10ms) */
+	} while ((seq != (*o_mcp_resp & FW_MSG_SEQ_NUMBER_MASK)) &&
+		 (cnt++ < QED_DRV_MB_MAX_RETRIES));
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SP,
+		   "[after %d ms] read (%x) seq is (%x) from FW MB\n",
+		   cnt * delay, *o_mcp_resp, seq);
+
+	/* Is this a reply to our command? */
+	if (seq == (*o_mcp_resp & FW_MSG_SEQ_NUMBER_MASK)) {
+		*o_mcp_resp &= FW_MSG_CODE_MASK;
+		/* Get the MCP param */
+		*o_mcp_param = DRV_MB_RD(p_hwfn, p_ptt, fw_mb_param);
+	} else {
+		/* FW BUG! */
+		DP_ERR(p_hwfn, "MFW failed to respond!\n");
+		*o_mcp_resp	= 0;
+		rc		= -EAGAIN;
+	}
+	return rc;
+}
+
+int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
+		struct qed_ptt	*p_ptt,
+		u32		cmd,
+		u32		param,
+		u32		*o_mcp_resp,
+		u32		*o_mcp_param)
+{
+	int rc = 0;
+
+	/* MCP not initialized */
+	if (!qed_mcp_is_init(p_hwfn)) {
+		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
+		return -EBUSY;
+	}
+
+	/* Lock Mutex to ensure only single thread is
+	 * accessing the MCP at one time
+	 */
+	mutex_lock(&p_hwfn->mcp_info->mutex);
+	rc = qed_do_mcp_cmd(p_hwfn, p_ptt, cmd, param,
+			    o_mcp_resp, o_mcp_param);
+	/* Release Mutex */
+	mutex_unlock(&p_hwfn->mcp_info->mutex);
+
+	return rc;
+}
+
+static void qed_mcp_set_drv_ver(struct qed_dev	*cdev,
+				struct qed_hwfn *p_hwfn,
+				struct qed_ptt	*p_ptt)
+{
+	u32 i;
+
+	/* Copy version string to MCP */
+	for (i = 0; i < MCP_DRV_VER_STR_SIZE_DWORD; i++)
+		DRV_MB_WR(p_hwfn, p_ptt, union_data.ver_str[i],
+			  *(u32 *)&cdev->ver_str[i * sizeof(u32)]);
+}
+
+int qed_mcp_load_req(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt,
+		     u32		*p_load_code)
+{
+	int		rc;
+	u32		param;
+	struct qed_dev	*cdev = p_hwfn->cdev;
+
+	if (!qed_mcp_is_init(p_hwfn)) {
+		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
+		return -EBUSY;
+	}
+
+	/* Save driver's version to shmem */
+	qed_mcp_set_drv_ver(cdev, p_hwfn, p_ptt);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SP, "fw_seq 0x%08x, drv_pulse 0x%x\n",
+		   p_hwfn->mcp_info->drv_mb_seq,
+		   p_hwfn->mcp_info->drv_pulse_seq);
+
+	/* Load Request */
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_LOAD_REQ,
+			 (PDA_COMP | DRV_ID_MCP_HSI_VER_CURRENT |
+			  cdev->drv_type),
+			 p_load_code, &param);
+
+	/* if mcp fails to respond we must abort */
+	if (rc) {
+		DP_ERR(p_hwfn, "MCP response failure, aborting\n");
+		return rc;
+	}
+
+	/* If MFW refused (e.g. other port is in diagnostic mode) we
+	 * must abort. This can happen in the following cases:
+	 * - Other port is in diagnostic mode
+	 * - Previously loaded function on the engine is not compliant with
+	 *   the requester.
+	 * - MFW cannot cope with the requester's DRV_MFW_HSI_VERSION.
+	 *      -
+	 */
+	if (!(*p_load_code) ||
+	    ((*p_load_code) == FW_MSG_CODE_DRV_LOAD_REFUSED_HSI) ||
+	    ((*p_load_code) == FW_MSG_CODE_DRV_LOAD_REFUSED_PDA) ||
+	    ((*p_load_code) == FW_MSG_CODE_DRV_LOAD_REFUSED_DIAG)) {
+		DP_ERR(p_hwfn, "MCP refused load request, aborting\n");
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+int qed_mcp_get_mfw_ver(struct qed_dev	*cdev,
+			u32		*p_mfw_ver)
+{
+	struct qed_hwfn *p_hwfn = &cdev->hwfns[0];
+	struct qed_ptt	*p_ptt;
+	u32		global_offsize;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	global_offsize = qed_rd(p_hwfn, p_ptt,
+				SECTION_OFFSIZE_ADDR(p_hwfn->mcp_info->
+						     public_base,
+						     PUBLIC_GLOBAL));
+	*p_mfw_ver = qed_rd(p_hwfn, p_ptt,
+			    SECTION_ADDR(global_offsize, 0) +
+			    offsetof(struct public_global, mfw_ver));
+
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return 0;
+}
+
+static u32 qed_mcp_get_shmem_func(struct qed_hwfn	*p_hwfn,
+				  struct qed_ptt	*p_ptt,
+				  struct public_func	*p_data,
+				  int			pfid)
+{
+	u32 mfw_path_offsize = qed_rd(
+			p_hwfn, p_ptt,
+			SECTION_OFFSIZE_ADDR(p_hwfn->mcp_info->public_base,
+					     PUBLIC_FUNC));
+	u32	func_addr = SECTION_ADDR(mfw_path_offsize, pfid);
+	u32	i, size;
+
+	memset(p_data, 0, sizeof(*p_data));
+
+	size = min_t(u32, sizeof(*p_data),
+		     QED_SECTION_SIZE(mfw_path_offsize));
+	for (i = 0; i < size / sizeof(u32); i++)
+		((u32 *)p_data)[i] = qed_rd(p_hwfn, p_ptt,
+					    func_addr + (i << 2));
+
+	return size;
+}
+
+static int
+qed_mcp_get_shmem_proto(struct qed_hwfn			*p_hwfn,
+			struct public_func		*p_info,
+			enum qed_pci_personality	*p_proto)
+{
+	int rc = 0;
+
+	switch (p_info->config & FUNC_MF_CFG_PROTOCOL_MASK) {
+	case FUNC_MF_CFG_PROTOCOL_ETHERNET:
+		*p_proto = QED_PCI_ETH;
+		break;
+	default:
+		rc = -EINVAL;
+	}
+
+	return rc;
+}
+
+int qed_mcp_fill_shmem_func_info(struct qed_hwfn	*p_hwfn,
+				 struct qed_ptt		*p_ptt)
+{
+	struct qed_mcp_function_info	*info;
+	struct public_func		shmem_info;
+
+	qed_mcp_get_shmem_func(p_hwfn, p_ptt, &shmem_info,
+			       MCP_PF_ID(p_hwfn));
+	info = &p_hwfn->mcp_info->func_info;
+
+	info->pause_on_host = (shmem_info.config &
+			       FUNC_MF_CFG_PAUSE_ON_HOST_RING) ? 1 : 0;
+
+	if (qed_mcp_get_shmem_proto(p_hwfn, &shmem_info,
+				    &info->protocol)) {
+		DP_ERR(p_hwfn, "Unknown personality %08x\n",
+		       (u32)(shmem_info.config & FUNC_MF_CFG_PROTOCOL_MASK));
+		return -EINVAL;
+	}
+
+	if (p_hwfn->cdev->mf_mode != SF) {
+		info->bandwidth_min = (shmem_info.config &
+				       FUNC_MF_CFG_MIN_BW_MASK) >>
+			FUNC_MF_CFG_MIN_BW_SHIFT;
+		if (info->bandwidth_min < 1 || info->bandwidth_min > 100) {
+			DP_INFO(
+				p_hwfn,
+				"bandwidth minimum out of bounds [%02x]. Set to 1\n",
+				info->bandwidth_min);
+			info->bandwidth_min = 1;
+		}
+
+		info->bandwidth_max = (shmem_info.config &
+				       FUNC_MF_CFG_MAX_BW_MASK) >>
+			FUNC_MF_CFG_MAX_BW_SHIFT;
+		if (info->bandwidth_max < 1 || info->bandwidth_max > 100) {
+			DP_INFO(
+				p_hwfn,
+				"bandwidth maximum out of bounds [%02x]. Set to 100\n",
+				info->bandwidth_max);
+			info->bandwidth_max = 100;
+		}
+	}
+
+	if (shmem_info.mac_upper || shmem_info.mac_lower) {
+		info->mac[0]	= (u8)(shmem_info.mac_upper >> 8);
+		info->mac[1]	= (u8)(shmem_info.mac_upper);
+		info->mac[2]	= (u8)(shmem_info.mac_lower >> 24);
+		info->mac[3]	= (u8)(shmem_info.mac_lower >> 16);
+		info->mac[4]	= (u8)(shmem_info.mac_lower >> 8);
+		info->mac[5]	= (u8)(shmem_info.mac_lower);
+	} else {
+		DP_NOTICE(p_hwfn, "MAC is 0 in shmem\n");
+	}
+
+	info->wwn_port = (u64)shmem_info.fcoe_wwn_port_name_upper |
+		(((u64)shmem_info.fcoe_wwn_port_name_lower) << 32);
+	info->wwn_node = (u64)shmem_info.fcoe_wwn_node_name_upper |
+		(((u64)shmem_info.fcoe_wwn_node_name_lower) << 32);
+
+	info->ovlan = (u16)(shmem_info.ovlan_stag & FUNC_MF_CFG_OV_STAG_MASK);
+
+	DP_VERBOSE(
+		p_hwfn,
+		(QED_MSG_SP | NETIF_MSG_IFUP),
+		"Read configuration from shmem: pause_on_host %02x protocol %02x BW [%02x - %02x] MAC %02x:%02x:%02x:%02x:%02x:%02x wwn port %llx node %llx ovlan %04x\n",
+		info->pause_on_host,
+		info->protocol,
+		info->bandwidth_min,
+		info->bandwidth_max,
+		info->mac[0],
+		info->mac[1],
+		info->mac[2],
+		info->mac[3],
+		info->mac[4],
+		info->mac[5],
+		info->wwn_port,
+		info->wwn_node,
+		info->ovlan);
+
+	return 0;
+}
+
+int qed_mcp_drain(struct qed_hwfn	*p_hwfn,
+		  struct qed_ptt	*p_ptt)
+{
+	int	rc;
+	u32	resp = 0, param = 0;
+
+	rc = qed_mcp_cmd(p_hwfn, p_ptt,
+			 DRV_MSG_CODE_NIG_DRAIN, 100,
+			 &resp, &param);
+
+	/* Wait for the drain to complete before returning */
+	msleep(120);
+
+	return rc;
+}
+
+int
+qed_mcp_send_drv_version(struct qed_hwfn		*p_hwfn,
+			 struct qed_ptt			*p_ptt,
+			 struct qed_mcp_drv_version	*p_ver)
+{
+	int	rc	= 0;
+	u32	param	= 0, reply = 0, i;
+
+	if (!qed_mcp_is_init(p_hwfn)) {
+		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
+		return -EBUSY;
+	}
+
+	DRV_MB_WR(p_hwfn, p_ptt, union_data.drv_version.version,
+		  p_ver->version);
+	/* Copy version string to shmem */
+	for (i = 0; i < (MCP_DRV_VER_STR_SIZE - 4) / 4; i++) {
+		DRV_MB_WR(p_hwfn, p_ptt,
+			  union_data.drv_version.name[i * sizeof(u32)],
+			  *(u32 *)&p_ver->name[i * sizeof(u32)]);
+	}
+
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_SET_VERSION, 0, &reply,
+			 &param);
+	if (rc) {
+		DP_ERR(p_hwfn, "MCP response failure, aborting\n");
+		return rc;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
new file mode 100644
index 0000000..5f11720
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -0,0 +1,231 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_MCP_H
+#define _QED_MCP_H
+#include <linux/types.h>
+#include <linux/delay.h>
+#include <linux/mutex.h>
+#include <linux/slab.h>
+#include "qed_hsi.h"
+
+struct qed_mcp_function_info {
+	u8				pause_on_host;
+
+	enum qed_pci_personality	protocol;
+
+	u8				bandwidth_min;
+	u8				bandwidth_max;
+
+	u8				mac[ETH_ALEN];
+
+	u64				wwn_port;
+	u64				wwn_node;
+
+#define QED_MCP_VLAN_UNSET              (0xffff)
+	u16				ovlan;
+};
+
+struct qed_mcp_nvm_common {
+	u32	offset;
+	u32	param;
+	u32	resp;
+	u32	cmd;
+};
+
+struct qed_mcp_drv_version {
+	u32	version;
+	u8	name[MCP_DRV_VER_STR_SIZE - 4];
+};
+
+/**
+ * @brief Get the management firmware version value
+ *
+ * @param cdev       - qed dev pointer
+ * @param mfw_ver    - mfw version value
+ *
+ * @return int - 0 - operation was successul.
+ */
+int qed_mcp_get_mfw_ver(struct qed_dev	*cdev,
+			u32		*mfw_ver);
+
+/**
+ * @brief General function for sending commands to the MCP
+ *        mailbox. It acquire mutex lock for the entire
+ *        operation, from sending the request until the MCP
+ *        response. Waiting for MCP response will be checked up
+ *        to 5 seconds every 5ms.
+ *
+ * @param p_hwfn     - hw function
+ * @param p_ptt      - PTT required for register access
+ * @param cmd        - command to be sent to the MCP.
+ * @param param      - Optional param
+ * @param o_mcp_resp - The MCP response code (exclude sequence).
+ * @param o_mcp_param- Optional parameter provided by the MCP
+ *                     response
+ * @return int - 0 - operation
+ * was successul.
+ */
+int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
+		struct qed_ptt	*p_ptt,
+		u32		cmd,
+		u32		param,
+		u32		*o_mcp_resp,
+		u32		*o_mcp_param);
+
+/**
+ * @brief - drains the nig, allowing completion to pass in case of pauses.
+ *          (Should be called only from sleepable context)
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ */
+int qed_mcp_drain(struct qed_hwfn	*p_hwfn,
+		  struct qed_ptt	*p_ptt);
+
+/**
+ * @brief Send driver version to MFW
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param version - Version value
+ * @param name - Protocol driver name
+ *
+ * @return int - 0 - operation was successul.
+ */
+int
+qed_mcp_send_drv_version(struct qed_hwfn		*p_hwfn,
+			 struct qed_ptt			*p_ptt,
+			 struct qed_mcp_drv_version	*p_ver);
+
+/* Using hwfn number (and not pf_num) is required since in CMT mode,
+ * same pf_num may be used by two different hwfn
+ * TODO - this shouldn't really be in .h file, but until all fields
+ * required during hw-init will be placed in their correct place in shmem
+ * we need it in qed_dev.c [for readin the nvram reflection in shmem].
+ */
+#define MCP_PF_ID_BY_REL(p_hwfn, rel_pfid) (QED_IS_BB((p_hwfn)->cdev) ?	       \
+					    ((rel_pfid) |		       \
+					     ((p_hwfn)->abs_pf_id & 1) << 3) : \
+					    rel_pfid)
+#define MCP_PF_ID(p_hwfn) MCP_PF_ID_BY_REL(p_hwfn, (p_hwfn)->rel_pf_id)
+
+/* TODO - this is only correct as long as only BB is supported, and
+ * no port-swapping is implemented; Afterwards we'll need to fix it.
+ */
+#define MFW_PORT(_p_hwfn)       ((_p_hwfn)->abs_pf_id %	\
+				 ((_p_hwfn)->cdev->num_ports_in_engines * 2))
+struct qed_mcp_info {
+	struct mutex				mutex; /* MCP access lock */
+	u32					public_base;
+	u32					drv_mb_addr;
+	u32					mfw_mb_addr;
+	u32					port_addr;
+	u16					drv_mb_seq;
+	u16					drv_pulse_seq;
+	struct qed_mcp_function_info		func_info;
+
+	u8					*mfw_mb_cur;
+	u8					*mfw_mb_shadow;
+	u16					mfw_mb_length;
+	u16					mcp_hist;
+};
+
+/**
+ * @brief Initialize the interface with the MCP
+ *
+ * @param p_hwfn - HW func
+ * @param p_ptt - PTT required for register access
+ *
+ * @return int
+ */
+int qed_mcp_cmd_init(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt);
+
+/**
+ * @brief Initialize the port interface with the MCP
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * Can only be called after `num_ports_in_engines' is set
+ */
+void qed_mcp_cmd_port_init(struct qed_hwfn	*p_hwfn,
+			   struct qed_ptt	*p_ptt);
+/**
+ * @brief Releases resources allocated during the init process.
+ *
+ * @param p_hwfn - HW func
+ * @param p_ptt - PTT required for register access
+ *
+ * @return int
+ */
+
+int qed_mcp_free(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief Sends a LOAD_REQ to the MFW, and in case operation
+ *        succeed, returns whether this PF is the first on the
+ *        chip/engine/port or function. This function should be
+ *        called when driver is ready to accept MFW events after
+ *        Storms initializations are done.
+ *
+ * @param p_hwfn       - hw function
+ * @param p_ptt        - PTT required for register access
+ * @param p_load_code  - The MCP response param containing one
+ *      of the following:
+ *      FW_MSG_CODE_DRV_LOAD_ENGINE
+ *      FW_MSG_CODE_DRV_LOAD_PORT
+ *      FW_MSG_CODE_DRV_LOAD_FUNCTION
+ * @return int -
+ *      0 - Operation was successul.
+ *      -EBUSY - Operation failed
+ */
+int qed_mcp_load_req(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt,
+		     u32		*p_load_code);
+
+/**
+ * @brief Read the MFW mailbox into Current buffer.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ */
+void qed_mcp_read_mb(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt);
+
+/**
+ * @brief - calls during init to read shmem of all function-related info.
+ *
+ * @param p_hwfn
+ *
+ * @param return 0 upon success.
+ */
+int qed_mcp_fill_shmem_func_info(struct qed_hwfn	*p_hwfn,
+				 struct qed_ptt		*p_ptt);
+
+/**
+ * @brief - Reset the MCP using mailbox command.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ *
+ * @param return 0 upon success.
+ */
+int qed_mcp_reset(struct qed_hwfn	*p_hwfn,
+		  struct qed_ptt	*p_ptt);
+
+/**
+ * @brief indicates whether the MFW objects [under mcp_info] are accessible
+ *
+ * @param p_hwfn
+ *
+ * @return true iff MFW is running and mcp_info is initialized
+ */
+bool qed_mcp_is_init(struct qed_hwfn *p_hwfn);
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
new file mode 100644
index 0000000..7a5ce59
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -0,0 +1,366 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef REG_ADDR_H
+#define REG_ADDR_H
+
+#define  CDU_REG_CID_ADDR_PARAMS_CONTEXT_SIZE_SHIFT \
+	0
+
+#define  CDU_REG_CID_ADDR_PARAMS_CONTEXT_SIZE		( \
+		0xfff << 0)
+
+#define  CDU_REG_CID_ADDR_PARAMS_BLOCK_WASTE_SHIFT \
+	12
+
+#define  CDU_REG_CID_ADDR_PARAMS_BLOCK_WASTE		( \
+		0xfff << 12)
+
+#define  CDU_REG_CID_ADDR_PARAMS_NCIB_SHIFT \
+	24
+
+#define  CDU_REG_CID_ADDR_PARAMS_NCIB			( \
+		0xff << 24)
+
+#define  XSDM_REG_OPERATION_GEN \
+	0xf80408UL
+#define  NIG_REG_RX_BRB_OUT_EN \
+	0x500e18UL
+#define  NIG_REG_STORM_OUT_EN \
+	0x500e08UL
+#define  PSWRQ2_REG_L2P_VALIDATE_VFID \
+	0x240c50UL
+#define  PGLUE_B_REG_USE_CLIENTID_IN_TAG	\
+	0x2aae04UL
+#define  PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER	\
+	0x2aa16cUL
+#define  BAR0_MAP_REG_MSDM_RAM \
+	0x1d00000UL
+#define  BAR0_MAP_REG_USDM_RAM \
+	0x1d80000UL
+#define  BAR0_MAP_REG_PSDM_RAM \
+	0x1f00000UL
+#define  BAR0_MAP_REG_TSDM_RAM \
+	0x1c80000UL
+#define  NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF \
+	0x5011f4UL
+#define  PRS_REG_SEARCH_TCP \
+	0x1f0400UL
+#define  PRS_REG_SEARCH_UDP \
+	0x1f0404UL
+#define  PRS_REG_SEARCH_FCOE \
+	0x1f0408UL
+#define  PRS_REG_SEARCH_ROCE \
+	0x1f040cUL
+#define  PRS_REG_SEARCH_OPENFLOW	\
+	0x1f0434UL
+#define  TM_REG_PF_ENABLE_CONN \
+	0x2c043cUL
+#define  TM_REG_PF_ENABLE_TASK \
+	0x2c0444UL
+#define  TM_REG_PF_SCAN_ACTIVE_CONN \
+	0x2c04fcUL
+#define  TM_REG_PF_SCAN_ACTIVE_TASK \
+	0x2c0500UL
+#define  IGU_REG_LEADING_EDGE_LATCH \
+	0x18082cUL
+#define  IGU_REG_TRAILING_EDGE_LATCH \
+	0x180830UL
+#define  QM_REG_USG_CNT_PF_TX \
+	0x2f2eacUL
+#define  QM_REG_USG_CNT_PF_OTHER	\
+	0x2f2eb0UL
+#define  DORQ_REG_PF_DB_ENABLE \
+	0x100508UL
+#define  QM_REG_PF_EN \
+	0x2f2ea4UL
+#define  TCFC_REG_STRONG_ENABLE_PF \
+	0x2d0708UL
+#define  CCFC_REG_STRONG_ENABLE_PF \
+	0x2e0708UL
+#define  PGLUE_B_REG_PGL_ADDR_88_F0 \
+	0x2aa404UL
+#define  PGLUE_B_REG_PGL_ADDR_8C_F0 \
+	0x2aa408UL
+#define  PGLUE_B_REG_PGL_ADDR_90_F0 \
+	0x2aa40cUL
+#define  PGLUE_B_REG_PGL_ADDR_94_F0 \
+	0x2aa410UL
+#define  PGLUE_B_REG_WAS_ERROR_PF_31_0_CLR \
+	0x2aa138UL
+#define  PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ \
+	0x2aa174UL
+#define  MISC_REG_GEN_PURP_CR0 \
+	0x008c80UL
+#define  MCP_REG_SCRATCH	\
+	0xe20000UL
+#define  CNIG_REG_NW_PORT_MODE_BB_B0 \
+	0x218200UL
+#define  MISCS_REG_CHIP_NUM \
+	0x00976cUL
+#define  MISCS_REG_CHIP_REV \
+	0x009770UL
+#define  MISCS_REG_CMT_ENABLED_FOR_PAIR \
+	0x00971cUL
+#define  MISCS_REG_CHIP_TEST_REG	\
+	0x009778UL
+#define  MISCS_REG_CHIP_METAL \
+	0x009774UL
+#define  BRB_REG_HEADER_SIZE \
+	0x340804UL
+#define  BTB_REG_HEADER_SIZE \
+	0xdb0804UL
+#define  CAU_REG_LONG_TIMEOUT_THRESHOLD \
+	0x1c0708UL
+#define  CCFC_REG_ACTIVITY_COUNTER \
+	0x2e8800UL
+#define  CDU_REG_CID_ADDR_PARAMS	\
+	0x580900UL
+#define  DBG_REG_CLIENT_ENABLE \
+	0x010004UL
+#define  DMAE_REG_INIT \
+	0x00c000UL
+#define  DORQ_REG_IFEN \
+	0x100040UL
+#define  GRC_REG_TIMEOUT_EN \
+	0x050404UL
+#define  IGU_REG_BLOCK_CONFIGURATION \
+	0x180040UL
+#define  MCM_REG_INIT \
+	0x1200000UL
+#define  MCP2_REG_DBG_DWORD_ENABLE \
+	0x052404UL
+#define  MISC_REG_PORT_MODE \
+	0x008c00UL
+#define  MISCS_REG_CLK_100G_MODE	\
+	0x009070UL
+#define  MSDM_REG_ENABLE_IN1 \
+	0xfc0004UL
+#define  MSEM_REG_ENABLE_IN \
+	0x1800004UL
+#define  NIG_REG_CM_HDR \
+	0x500840UL
+#define  NCSI_REG_CONFIG	\
+	0x040200UL
+#define  PBF_REG_INIT \
+	0xd80000UL
+#define  PTU_REG_ATC_INIT_ARRAY \
+	0x560000UL
+#define  PCM_REG_INIT \
+	0x1100000UL
+#define  PGLUE_B_REG_ADMIN_PER_PF_REGION	\
+	0x2a9000UL
+#define  PRM_REG_DISABLE_PRM \
+	0x230000UL
+#define  PRS_REG_SOFT_RST \
+	0x1f0000UL
+#define  PSDM_REG_ENABLE_IN1 \
+	0xfa0004UL
+#define  PSEM_REG_ENABLE_IN \
+	0x1600004UL
+#define  PSWRQ_REG_DBG_SELECT \
+	0x280020UL
+#define  PSWRQ2_REG_CDUT_P_SIZE \
+	0x24000cUL
+#define  PSWHST_REG_DISCARD_INTERNAL_WRITES \
+	0x2a0040UL
+#define  PSWHST2_REG_DBGSYN_ALMOST_FULL_THR \
+	0x29e050UL
+#define  PSWRD_REG_DBG_SELECT \
+	0x29c040UL
+#define  PSWRD2_REG_CONF11 \
+	0x29d064UL
+#define  PSWWR_REG_USDM_FULL_TH \
+	0x29a040UL
+#define  PSWWR2_REG_CDU_FULL_TH2	\
+	0x29b040UL
+#define  QM_REG_MAXPQSIZE_0 \
+	0x2f0434UL
+#define  RSS_REG_RSS_INIT_EN \
+	0x238804UL
+#define  RDIF_REG_STOP_ON_ERROR \
+	0x300040UL
+#define  SRC_REG_SOFT_RST \
+	0x23874cUL
+#define  TCFC_REG_ACTIVITY_COUNTER \
+	0x2d8800UL
+#define  TCM_REG_INIT \
+	0x1180000UL
+#define  TM_REG_PXP_READ_DATA_FIFO_INIT \
+	0x2c0014UL
+#define  TSDM_REG_ENABLE_IN1 \
+	0xfb0004UL
+#define  TSEM_REG_ENABLE_IN \
+	0x1700004UL
+#define  TDIF_REG_STOP_ON_ERROR \
+	0x310040UL
+#define  UCM_REG_INIT \
+	0x1280000UL
+#define  UMAC_REG_IPG_HD_BKP_CNTL_BB_B0 \
+	0x051004UL
+#define  USDM_REG_ENABLE_IN1 \
+	0xfd0004UL
+#define  USEM_REG_ENABLE_IN \
+	0x1900004UL
+#define  XCM_REG_INIT \
+	0x1000000UL
+#define  XSDM_REG_ENABLE_IN1 \
+	0xf80004UL
+#define  XSEM_REG_ENABLE_IN \
+	0x1400004UL
+#define  YCM_REG_INIT \
+	0x1080000UL
+#define  YSDM_REG_ENABLE_IN1 \
+	0xf90004UL
+#define  YSEM_REG_ENABLE_IN \
+	0x1500004UL
+#define  XYLD_REG_SCBD_STRICT_PRIO \
+	0x4c0000UL
+#define  TMLD_REG_SCBD_STRICT_PRIO \
+	0x4d0000UL
+#define  MULD_REG_SCBD_STRICT_PRIO \
+	0x4e0000UL
+#define  YULD_REG_SCBD_STRICT_PRIO \
+	0x4c8000UL
+#define  MISC_REG_SHARED_MEM_ADDR \
+	0x008c20UL
+#define  DMAE_REG_GO_C0 \
+	0x00c048UL
+#define  DMAE_REG_GO_C1 \
+	0x00c04cUL
+#define  DMAE_REG_GO_C2 \
+	0x00c050UL
+#define  DMAE_REG_GO_C3 \
+	0x00c054UL
+#define  DMAE_REG_GO_C4 \
+	0x00c058UL
+#define  DMAE_REG_GO_C5 \
+	0x00c05cUL
+#define  DMAE_REG_GO_C6 \
+	0x00c060UL
+#define  DMAE_REG_GO_C7 \
+	0x00c064UL
+#define  DMAE_REG_GO_C8 \
+	0x00c068UL
+#define  DMAE_REG_GO_C9 \
+	0x00c06cUL
+#define  DMAE_REG_GO_C10	\
+	0x00c070UL
+#define  DMAE_REG_GO_C11	\
+	0x00c074UL
+#define  DMAE_REG_GO_C12	\
+	0x00c078UL
+#define  DMAE_REG_GO_C13	\
+	0x00c07cUL
+#define  DMAE_REG_GO_C14	\
+	0x00c080UL
+#define  DMAE_REG_GO_C15	\
+	0x00c084UL
+#define  DMAE_REG_GO_C16	\
+	0x00c088UL
+#define  DMAE_REG_GO_C17	\
+	0x00c08cUL
+#define  DMAE_REG_GO_C18	\
+	0x00c090UL
+#define  DMAE_REG_GO_C19	\
+	0x00c094UL
+#define  DMAE_REG_GO_C20	\
+	0x00c098UL
+#define  DMAE_REG_GO_C21	\
+	0x00c09cUL
+#define  DMAE_REG_GO_C22	\
+	0x00c0a0UL
+#define  DMAE_REG_GO_C23	\
+	0x00c0a4UL
+#define  DMAE_REG_GO_C24	\
+	0x00c0a8UL
+#define  DMAE_REG_GO_C25	\
+	0x00c0acUL
+#define  DMAE_REG_GO_C26	\
+	0x00c0b0UL
+#define  DMAE_REG_GO_C27	\
+	0x00c0b4UL
+#define  DMAE_REG_GO_C28	\
+	0x00c0b8UL
+#define  DMAE_REG_GO_C29	\
+	0x00c0bcUL
+#define  DMAE_REG_GO_C30	\
+	0x00c0c0UL
+#define  DMAE_REG_GO_C31	\
+	0x00c0c4UL
+#define  DMAE_REG_CMD_MEM \
+	0x00c800UL
+#define  QM_REG_MAXPQSIZETXSEL_0	\
+	0x2f0440UL
+#define  QM_REG_SDMCMDREADY \
+	0x2f1e10UL
+#define  QM_REG_SDMCMDADDR \
+	0x2f1e04UL
+#define  QM_REG_SDMCMDDATALSB \
+	0x2f1e08UL
+#define  QM_REG_SDMCMDDATAMSB \
+	0x2f1e0cUL
+#define  QM_REG_SDMCMDGO	\
+	0x2f1e14UL
+#define  QM_REG_RLPFCRD \
+	0x2f4d80UL
+#define  QM_REG_RLPFINCVAL \
+	0x2f4c80UL
+#define  QM_REG_RLGLBLCRD \
+	0x2f4400UL
+#define  QM_REG_RLGLBLINCVAL \
+	0x2f3400UL
+#define  IGU_REG_ATTENTION_ENABLE \
+	0x18083cUL
+#define  IGU_REG_ATTN_MSG_ADDR_L	\
+	0x180820UL
+#define  IGU_REG_ATTN_MSG_ADDR_H	\
+	0x180824UL
+#define  MISC_REG_AEU_GENERAL_ATTN_0 \
+	0x008400UL
+#define  CAU_REG_SB_ADDR_MEMORY \
+	0x1c8000UL
+#define  CAU_REG_SB_VAR_MEMORY \
+	0x1c6000UL
+#define  CAU_REG_PI_MEMORY \
+	0x1d0000UL
+#define  IGU_REG_PF_CONFIGURATION \
+	0x180800UL
+#define  MISC_REG_AEU_ENABLE1_IGU_OUT_0 \
+	0x00849cUL
+#define  MISC_REG_AEU_MASK_ATTN_IGU \
+	0x008494UL
+#define  IGU_REG_CLEANUP_STATUS_0 \
+	0x180980UL
+#define  IGU_REG_CLEANUP_STATUS_1 \
+	0x180a00UL
+#define  IGU_REG_CLEANUP_STATUS_2 \
+	0x180a80UL
+#define  IGU_REG_CLEANUP_STATUS_3 \
+	0x180b00UL
+#define  IGU_REG_CLEANUP_STATUS_4 \
+	0x180b80UL
+#define  IGU_REG_COMMAND_REG_32LSB_DATA \
+	0x180840UL
+#define  IGU_REG_COMMAND_REG_CTRL \
+	0x180848UL
+#define  IGU_REG_BLOCK_CONFIGURATION_VF_CLEANUP_EN	( \
+		0x1 << 1)
+#define  IGU_REG_BLOCK_CONFIGURATION_PXP_TPH_INTERFACE_EN	( \
+		0x1 << 0)
+#define  IGU_REG_MAPPING_MEMORY \
+	0x184000UL
+#define  MISCS_REG_GENERIC_POR_0	\
+	0x0096d4UL
+#define  MCP_REG_NVM_CFG4 \
+	0xe0642cUL
+#define  MCP_REG_NVM_CFG4_FLASH_SIZE	( \
+		0x7 << 0)
+#define  MCP_REG_NVM_CFG4_FLASH_SIZE_SHIFT \
+	0
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
new file mode 100644
index 0000000..71c03d9
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -0,0 +1,328 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_SP_H
+#define _QED_SP_H
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/qed/qed_chain.h>
+#include "qed.h"
+#include "qed_hsi.h"
+
+enum spq_mode {
+	QED_SPQ_MODE_BLOCK,     /* Client will poll a designated mem. address */
+	QED_SPQ_MODE_CB,        /* Client supplies a callback */
+	QED_SPQ_MODE_EBLOCK,    /* QED should block until completion */
+};
+
+struct qed_spq_comp_cb {
+	void	(*function)(struct	qed_hwfn *,
+			    void *,
+			    union	event_ring_data *,
+			    u8		fw_return_code);
+	void	*cookie;
+};
+
+union ramrod_data {
+	struct pf_start_ramrod_data			pf_start;
+};
+
+#define EQ_MAX_CREDIT   0xffffffff
+
+enum spq_priority {
+	QED_SPQ_PRIORITY_NORMAL,
+	QED_SPQ_PRIORITY_HIGH,
+};
+
+union qed_spq_req_comp {
+	struct qed_spq_comp_cb	cb;
+	u64			*done_addr;
+};
+
+struct qed_spq_comp_done {
+	u64	done;
+	u8	fw_return_code;
+};
+
+struct qed_spq_entry {
+	struct list_head		list;
+
+	u8				flags;
+
+	/* HSI slow path element */
+	struct slow_path_element	elem;
+
+	union ramrod_data		ramrod;
+
+	enum spq_priority		priority;
+
+	/* pending queue for this entry */
+	struct list_head		*queue;
+
+	enum spq_mode			comp_mode;
+	struct qed_spq_comp_cb		comp_cb;
+	struct qed_spq_comp_done	comp_done; /* SPQ_MODE_EBLOCK */
+};
+
+struct qed_eq {
+	struct qed_chain	chain;
+	u8			eq_sb_index;    /* index within the SB */
+	__le16			*p_fw_cons;     /* ptr to index value */
+};
+
+struct qed_consq {
+	struct qed_chain chain;
+};
+
+struct qed_spq {
+	spinlock_t		lock; /* SPQ lock */
+
+	struct list_head	unlimited_pending;
+	struct list_head	pending;
+	struct list_head	completion_pending;
+	struct list_head	free_pool;
+
+	struct qed_chain	chain;
+
+	/* allocated dma-able memory for spq entries (+ramrod data) */
+	dma_addr_t		p_phys;
+	struct qed_spq_entry	*p_virt;
+
+	/* Used as index for completions (returns on EQ by FW) */
+	u16			echo_idx;
+
+	/* Statistics */
+	u32			unlimited_pending_count;
+	u32			normal_count;
+	u32			high_count;
+	u32			comp_sent_count;
+	u32			comp_count;
+
+	u32			cid;
+};
+
+/**
+ * @brief qed_spq_post - Posts a Slow hwfn request to FW, or lacking that
+ *        Pends it to the future list.
+ *
+ * @param p_hwfn
+ * @param p_req
+ *
+ * @return int
+ */
+int qed_spq_post(struct qed_hwfn	*p_hwfn,
+		 struct qed_spq_entry	*p_ent,
+		 u8			*fw_return_code);
+
+/**
+ * @brief qed_spq_allocate - Alloocates & initializes the SPQ and EQ.
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_spq_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_spq_setup - Reset the SPQ to its start state.
+ *
+ * @param p_hwfn
+ */
+void qed_spq_setup(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_spq_deallocate - Deallocates the given SPQ struct.
+ *
+ * @param p_hwfn
+ */
+void qed_spq_free(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_spq_get_entry - Obtain an entrry from the spq
+ *        free pool list.
+ *
+ *
+ *
+ * @param p_hwfn
+ * @param pp_ent
+ *
+ * @return int
+ */
+int
+qed_spq_get_entry(struct qed_hwfn	*p_hwfn,
+		  struct qed_spq_entry	**pp_ent);
+
+/**
+ * @brief qed_spq_return_entry - Return an entry to spq free
+ *                                 pool list
+ *
+ * @param p_hwfn
+ * @param p_ent
+ */
+void qed_spq_return_entry(struct qed_hwfn	*p_hwfn,
+			  struct qed_spq_entry	*p_ent);
+/**
+ * @brief qed_eq_allocate - Allocates & initializes an EQ struct
+ *
+ * @param p_hwfn
+ * @param num_elem number of elements in the eq
+ *
+ * @return struct qed_eq* - a newly allocated structure; NULL upon error.
+ */
+struct qed_eq *qed_eq_alloc(struct qed_hwfn	*p_hwfn,
+			    u16			num_elem);
+
+/**
+ * @brief qed_eq_setup - Reset the SPQ to its start state.
+ *
+ * @param p_hwfn
+ * @param p_eq
+ */
+void qed_eq_setup(struct qed_hwfn	*p_hwfn,
+		  struct qed_eq		*p_eq);
+
+/**
+ * @brief qed_eq_deallocate - deallocates the given EQ struct.
+ *
+ * @param p_hwfn
+ * @param p_eq
+ */
+void qed_eq_free(struct qed_hwfn	*p_hwfn,
+		 struct qed_eq		*p_eq);
+
+/**
+ * @brief qed_eq_prod_update - update the FW with default EQ producer
+ *
+ * @param p_hwfn
+ * @param prod
+ */
+void qed_eq_prod_update(struct qed_hwfn *p_hwfn,
+			u16		prod);
+
+/**
+ * @brief qed_eq_completion - Completes currently pending EQ elements
+ *
+ * @param p_hwfn
+ * @param cookie
+ *
+ * @return int
+ */
+int qed_eq_completion(struct qed_hwfn	*p_hwfn,
+		      void		*cookie);
+
+/**
+ * @brief qed_spq_completion - Completes a single event
+ *
+ * @param p_hwfn
+ * @param echo - echo value from cookie (used for determining completion)
+ * @param p_data - data from cookie (used in callback function if applicable)
+ *
+ * @return int
+ */
+int qed_spq_completion(struct qed_hwfn		*p_hwfn,
+		       __le16			echo,
+		       u8			fw_return_code,
+		       union event_ring_data	*p_data);
+
+/**
+ * @brief qed_spq_get_cid - Given p_hwfn, return cid for the hwfn's SPQ
+ *
+ * @param p_hwfn
+ *
+ * @return u32 - SPQ CID
+ */
+u32 qed_spq_get_cid(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_consq_alloc - Allocates & initializes an ConsQ
+ *        struct
+ *
+ * @param p_hwfn
+ *
+ * @return struct qed_eq* - a newly allocated structure; NULL upon error.
+ */
+struct qed_consq *qed_consq_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_consq_setup - Reset the ConsQ to its start
+ *        state.
+ *
+ * @param p_hwfn
+ * @param p_eq
+ */
+void qed_consq_setup(struct qed_hwfn	*p_hwfn,
+		     struct qed_consq	*p_consq);
+
+/**
+ * @brief qed_consq_free - deallocates the given ConsQ struct.
+ *
+ * @param p_hwfn
+ * @param p_eq
+ */
+void qed_consq_free(struct qed_hwfn	*p_hwfn,
+		    struct qed_consq	*p_consq);
+
+/**
+ * @file
+ *
+ * @brief Slow-hwfn low-level commands (Ramrods) function definitions.
+ */
+
+#define QED_SP_EQ_COMPLETION  0x01
+#define QED_SP_CQE_COMPLETION 0x02
+
+int  qed_sp_init_request(struct qed_spq_entry	**pp_ent,
+			 u32			cid,
+			 u16			opaque_fid,
+			 struct qed_hwfn	*p_hwfn,
+			 u8			cmd,
+			 u8			protocol,
+			 size_t			ramrod_data_size,
+			 enum spq_mode		comp_mode,
+			 struct qed_spq_comp_cb *p_comp_data);
+
+/**
+ * @brief qed_sp_pf_start - PF Function Start Ramrod
+ *
+ * This ramrod is sent to initialize a physical function (PF). It will
+ * configure the function related parameters and write its completion to the
+ * event ring specified in the parameters.
+ *
+ * Ramrods complete on the common event ring for the PF. This ring is
+ * allocated by the driver on host memory and its parameters are written
+ * to the internal RAM of the UStorm by the Function Start Ramrod.
+ *
+ * @param p_hwfn
+ * @param mode
+ *
+ * @return int
+ */
+
+int qed_sp_pf_start(struct qed_hwfn			*p_hwfn,
+		    enum mf_mode			mode);
+
+/**
+ * @brief qed_sp_pf_stop - PF Function Stop Ramrod
+ *
+ * This ramrod is sent to close a Physical Function (PF). It is the last ramrod
+ * sent and the last completion written to the PFs Event Ring. This ramrod also
+ * deletes the context for the Slowhwfn connection on this PF.
+ *
+ * @note Not required for first packet.
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+
+int qed_sp_pf_stop(struct qed_hwfn *p_hwfn);
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
new file mode 100644
index 0000000..f714a10
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -0,0 +1,180 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/bitops.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include "qed.h"
+#include <linux/qed/qed_chain.h>
+#include "qed_cxt.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_int.h"
+#include "qed_reg_addr.h"
+#include "qed_sp.h"
+
+int  qed_sp_init_request(
+	struct qed_spq_entry	**pp_ent,
+	u32			cid,
+	u16			opaque_fid,
+	struct qed_hwfn		*p_hwfn,
+	u8			cmd,
+	u8			protocol,
+	size_t			ramrod_data_size,
+	enum spq_mode		comp_mode,
+	struct qed_spq_comp_cb	*p_comp_data)
+{
+	int			rc		= -EPIPE;
+	struct qed_spq_entry	*p_ent		= NULL;
+	u32			opaque_cid	= opaque_fid << 16 | cid;
+
+	if (!pp_ent)
+		return -ENOMEM;
+
+	rc = qed_spq_get_entry(p_hwfn, pp_ent);
+
+	if (rc != 0)
+		return rc;
+
+	p_ent = *pp_ent;
+
+	p_ent->elem.hdr.cid		= cpu_to_le32(opaque_cid);
+	p_ent->elem.hdr.cmd_id		= cmd;
+	p_ent->elem.hdr.protocol_id	= protocol;
+
+	p_ent->priority		= QED_SPQ_PRIORITY_NORMAL;
+	p_ent->comp_mode	= comp_mode;
+	p_ent->comp_done.done	= 0;
+
+	switch (p_ent->comp_mode) {
+	case QED_SPQ_MODE_EBLOCK:
+		p_ent->comp_cb.cookie = &p_ent->comp_done;
+		break;
+
+	case QED_SPQ_MODE_BLOCK:
+		if (!p_comp_data)
+			return -EINVAL;
+
+		p_ent->comp_cb.cookie = p_comp_data->cookie;
+		break;
+
+	case QED_SPQ_MODE_CB:
+		if (!p_comp_data)
+			p_ent->comp_cb.function = NULL;
+		else
+			p_ent->comp_cb = *p_comp_data;
+		break;
+
+	default:
+		DP_NOTICE(p_hwfn, "Unknown SPQE completion mode %d\n",
+			  p_ent->comp_mode);
+		return -EINVAL;
+	}
+
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SPQ,
+		"Initialized: CID %08x cmd %02x protocol %02x data_addr %lu comp_mode [%s]\n",
+		opaque_cid,
+		cmd,
+		protocol,
+		(unsigned long)&p_ent->ramrod,
+		D_TRINE(p_ent->comp_mode, QED_SPQ_MODE_EBLOCK,
+			QED_SPQ_MODE_BLOCK, "MODE_EBLOCK", "MODE_BLOCK",
+			"MODE_CB"));
+	if (ramrod_data_size)
+		memset(&p_ent->ramrod, 0, ramrod_data_size);
+
+	return 0;
+}
+
+int qed_sp_pf_start(struct qed_hwfn			*p_hwfn,
+		    enum mf_mode			mode)
+{
+	int				rc		= -EPIPE;
+	struct pf_start_ramrod_data	*p_ramrod	= NULL;
+	struct qed_spq_entry		*p_ent		= NULL;
+	u16				sb		= qed_int_get_sp_sb_id(
+			p_hwfn);
+	u8				sb_index	=
+		p_hwfn->p_eq->eq_sb_index;
+
+	/* update initial eq producer */
+	qed_eq_prod_update(p_hwfn,
+			   qed_chain_get_prod_idx(&p_hwfn->p_eq->chain));
+
+	rc = qed_sp_init_request(&p_ent,
+				 qed_spq_get_cid(p_hwfn),
+				 p_hwfn->hw_info.opaque_fid,
+				 p_hwfn,
+				 COMMON_RAMROD_PF_START,
+				 PROTOCOLID_COMMON,
+				 sizeof(*p_ramrod),
+				 QED_SPQ_MODE_EBLOCK,
+				 NULL);
+
+	if (rc != 0)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.pf_start;
+
+	p_ramrod->event_ring_sb_id	= cpu_to_le16(sb);
+	p_ramrod->event_ring_sb_index	= sb_index;
+	p_ramrod->path_id		= QED_PATH_ID(p_hwfn);
+	p_ramrod->dont_log_ramrods	= 0;
+	p_ramrod->log_type_mask		= cpu_to_le16(0xf);
+	p_ramrod->mf_mode = mode;
+	p_ramrod->outer_tag = p_hwfn->hw_info.ovlan;
+
+	/* Place EQ address in RAMROD */
+	p_ramrod->event_ring_pbl_addr.hi
+		= DMA_HI_LE(p_hwfn->p_eq->chain.pbl.p_phys_table);
+	p_ramrod->event_ring_pbl_addr.lo
+					= DMA_LO_LE(
+				p_hwfn->p_eq->chain.pbl.p_phys_table);
+	p_ramrod->event_ring_num_pages	= (u8)p_hwfn->p_eq->chain.page_cnt;
+
+	p_ramrod->consolid_q_pbl_addr.hi
+		= DMA_HI_LE(p_hwfn->p_consq->chain.pbl.p_phys_table);
+	p_ramrod->consolid_q_pbl_addr.lo
+		= DMA_LO_LE(p_hwfn->p_consq->chain.pbl.p_phys_table);
+
+	p_hwfn->hw_info.personality = PERSONALITY_ETH;
+
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SPQ,
+		"Setting event_ring_sb [id %04x index %02x], mf [%s] outer_tag [%d]\n",
+		sb,
+		sb_index,
+		(p_ramrod->mf_mode == SF) ? "SF" : "Multi-Pf",
+		p_ramrod->outer_tag);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	return rc;
+}
+
+int qed_sp_pf_stop(struct qed_hwfn *p_hwfn)
+{
+	int			rc	= -EPIPE;
+	struct qed_spq_entry	*p_ent	= NULL;
+
+	rc = qed_sp_init_request(&p_ent, qed_spq_get_cid(p_hwfn),
+				 p_hwfn->hw_info.opaque_fid, p_hwfn,
+				 COMMON_RAMROD_PF_STOP, PROTOCOLID_COMMON,
+				 0, QED_SPQ_MODE_EBLOCK,
+				 NULL);
+	if (rc != 0)
+		return rc;
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
new file mode 100644
index 0000000..9dcc02f
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -0,0 +1,849 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include "qed.h"
+#include "qed_cxt.h"
+#include "qed_dev_api.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_int.h"
+#include "qed_mcp.h"
+#include "qed_reg_addr.h"
+#include "qed_sp.h"
+
+/***************************************************************************
+* Structures & Definitions
+***************************************************************************/
+
+#define SPQ_HIGH_PRI_RESERVE_DEFAULT    (1)
+#define SPQ_BLOCK_SLEEP_LENGTH          (1000)
+
+/***************************************************************************
+* Blocking Imp. (BLOCK/EBLOCK mode)
+***************************************************************************/
+static void qed_spq_blocking_cb(struct qed_hwfn		*p_hwfn,
+				void			*cookie,
+				union event_ring_data	*data,
+				u8			fw_return_code)
+{
+	struct qed_spq_comp_done *comp_done;
+
+	comp_done = (struct qed_spq_comp_done *)cookie;
+
+	comp_done->done			= 0x1;
+	comp_done->fw_return_code	= fw_return_code;
+
+	/* make update visible to waiting thread */
+	smp_wmb();
+}
+
+static int qed_spq_block(struct qed_hwfn	*p_hwfn,
+			 struct qed_spq_entry	*p_ent,
+			 u8			*p_fw_ret)
+{
+	int				sleep_count = SPQ_BLOCK_SLEEP_LENGTH;
+	struct qed_spq_comp_done	*comp_done;
+	int				rc;
+
+	comp_done = (struct qed_spq_comp_done *)p_ent->comp_cb.cookie;
+	while (sleep_count) {
+		/* validate we receive completion update */
+		smp_rmb();
+		if (comp_done->done == 1) {
+			if (p_fw_ret)
+				*p_fw_ret = comp_done->fw_return_code;
+			return 0;
+		}
+		usleep_range(5000, 10000);
+		sleep_count--;
+	}
+
+	DP_INFO(p_hwfn, "Ramrod is stuck, requesting MCP drain\n");
+	rc = qed_mcp_drain(p_hwfn, p_hwfn->p_main_ptt);
+	if (rc != 0)
+		DP_NOTICE(p_hwfn, "MCP drain failed\n");
+
+	/* Retry after drain */
+	sleep_count = SPQ_BLOCK_SLEEP_LENGTH;
+	while (sleep_count) {
+		/* validate we receive completion update */
+		smp_rmb();
+		if (comp_done->done == 1) {
+			if (p_fw_ret)
+				*p_fw_ret = comp_done->fw_return_code;
+			return 0;
+		}
+		usleep_range(5000, 10000);
+		sleep_count--;
+	}
+
+	if (comp_done->done == 1) {
+		if (p_fw_ret)
+			*p_fw_ret = comp_done->fw_return_code;
+		return 0;
+	}
+
+	DP_NOTICE(p_hwfn, "Ramrod is stuck, MCP drain failed\n");
+
+	return -EBUSY;
+}
+
+/***************************************************************************
+* SPQ entries inner API
+***************************************************************************/
+static int
+qed_spq_fill_entry(struct qed_hwfn	*p_hwfn,
+		   struct qed_spq_entry *p_ent)
+{
+	/* FIX ME - field name should change to 'echo' */
+	/* cpu_to_le16(p_hwfn->p_spq->echo_idx); */
+	p_ent->elem.hdr.echo = 0;
+	p_hwfn->p_spq->echo_idx++;
+	p_ent->flags = 0;
+
+	switch (p_ent->comp_mode) {
+	case QED_SPQ_MODE_EBLOCK:
+	case QED_SPQ_MODE_BLOCK:
+		p_ent->comp_cb.function = qed_spq_blocking_cb;
+		break;
+	case QED_SPQ_MODE_CB:
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Unknown SPQE completion mode %d\n",
+			  p_ent->comp_mode);
+		return -EINVAL;
+	}
+
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SPQ,
+		"Ramrod header: [CID 0x%08x CMD 0x%02x protocol 0x%02x] Data pointer: [%08x:%08x] Completion Mode: %s\n",
+		p_ent->elem.hdr.cid,
+		p_ent->elem.hdr.cmd_id,
+		p_ent->elem.hdr.protocol_id,
+		p_ent->elem.data_ptr.hi,
+		p_ent->elem.data_ptr.lo,
+		D_TRINE(p_ent->comp_mode, QED_SPQ_MODE_EBLOCK,
+			QED_SPQ_MODE_BLOCK, "MODE_EBLOCK", "MODE_BLOCK",
+			"MODE_CB"));
+
+	return 0;
+}
+
+/***************************************************************************
+* HSI access
+***************************************************************************/
+static void qed_spq_hw_initialize(struct qed_hwfn	*p_hwfn,
+				  struct qed_spq	*p_spq)
+{
+	u16				pq;
+	struct qed_cxt_info		cxt_info;
+	struct core_conn_context	*p_cxt;
+	union qed_qm_pq_params		pq_params;
+	int				rc;
+
+	cxt_info.iid = p_spq->cid;
+
+	rc = qed_cxt_get_cid_info(p_hwfn, &cxt_info);
+
+	if (rc < 0) {
+		DP_NOTICE(p_hwfn, "Cannot find context info for cid=%d\n",
+			  p_spq->cid);
+		return;
+	}
+
+	p_cxt = cxt_info.p_cxt;
+
+	SET_FIELD(p_cxt->xstorm_ag_context.flags10,
+		  XSTORM_CORE_CONN_AG_CTX_DQ_CF_EN, 1);
+	SET_FIELD(p_cxt->xstorm_ag_context.flags1,
+		  XSTORM_CORE_CONN_AG_CTX_DQ_CF_ACTIVE, 1);
+	SET_FIELD(p_cxt->xstorm_ag_context.flags9,
+		  XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_EN, 1);
+
+	/* CDU validation - FIXME currently disabled */
+
+	/* QM physical queue */
+	memset(&pq_params, 0, sizeof(pq_params));
+	pq_params.core.tc			= LB_TC;
+	pq					= qed_get_qm_pq(p_hwfn,
+								PROTOCOLID_CORE,
+								&pq_params);
+	p_cxt->xstorm_ag_context.physical_q0	= cpu_to_le16(pq);
+
+	p_cxt->xstorm_st_context.spq_base_lo =
+		DMA_LO_LE(p_spq->chain.p_phys_addr);
+	p_cxt->xstorm_st_context.spq_base_hi =
+		DMA_HI_LE(p_spq->chain.p_phys_addr);
+
+	p_cxt->xstorm_st_context.consolid_base_addr.lo =
+		DMA_LO_LE(p_hwfn->p_consq->chain.p_phys_addr);
+	p_cxt->xstorm_st_context.consolid_base_addr.hi =
+		DMA_HI_LE(p_hwfn->p_consq->chain.p_phys_addr);
+}
+
+static int qed_spq_hw_post(struct qed_hwfn	*p_hwfn,
+			   struct qed_spq	*p_spq,
+			   struct qed_spq_entry *p_ent)
+{
+	struct qed_chain		*p_chain = &p_hwfn->p_spq->chain;
+	struct slow_path_element	*elem;
+	struct core_db_data		db;
+
+	elem = qed_chain_produce(p_chain);
+	if (!elem) {
+		DP_NOTICE(p_hwfn, "Failed to produce from SPQ chain\n");
+		return -EINVAL;
+	}
+
+	*elem = p_ent->elem; /* struct assignment */
+
+	/* send a doorbell on the slow hwfn session */
+	memset(&db, 0, sizeof(db));
+	SET_FIELD(db.params, CORE_DB_DATA_DEST, DB_DEST_XCM);
+	SET_FIELD(db.params, CORE_DB_DATA_AGG_CMD, DB_AGG_CMD_SET);
+	SET_FIELD(db.params, CORE_DB_DATA_AGG_VAL_SEL,
+		  DQ_XCM_CORE_SPQ_PROD_CMD);
+	db.agg_flags = DQ_XCM_CORE_DQ_CF_CMD;
+
+	/* validate producer is up to-date */
+	rmb();
+
+	db.spq_prod = cpu_to_le16(qed_chain_get_prod_idx(p_chain));
+
+	/* do not reorder */
+	barrier();
+
+	DOORBELL(p_hwfn, DB_ADDR(p_spq->cid, DQ_DEMS_LEGACY), *(u32 *)&db);
+
+	/* make sure doorbell is rang */
+	mmiowb();
+
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SPQ,
+		"Doorbelled [0x%08x, CID 0x%08x] with Flags: %02x agg_params: %02x, prod: %04x\n",
+		DB_ADDR(p_spq->cid, DQ_DEMS_LEGACY),
+		p_spq->cid,
+		db.params,
+		db.agg_flags,
+		qed_chain_get_prod_idx(p_chain));
+
+	return 0;
+}
+
+/***************************************************************************
+* Asynchronous events
+***************************************************************************/
+static int
+qed_async_event_completion(struct qed_hwfn		*p_hwfn,
+			   struct event_ring_entry	*p_eqe)
+{
+	DP_NOTICE(p_hwfn,
+		  "Unknown Async completion for protocol: %d\n",
+		   p_eqe->protocol_id);
+	return -EINVAL;
+}
+
+/***************************************************************************
+* EQ API
+***************************************************************************/
+void qed_eq_prod_update(struct qed_hwfn *p_hwfn,
+			u16		prod)
+{
+	u32 addr = GTT_BAR0_MAP_REG_USDM_RAM +
+		USTORM_EQE_CONS_OFFSET(p_hwfn->rel_pf_id);
+
+	REG_WR16(p_hwfn, addr, prod);
+
+	/* keep prod updates ordered */
+	mmiowb();
+}
+
+int qed_eq_completion(struct qed_hwfn	*p_hwfn,
+		      void		*cookie)
+
+{
+	struct qed_eq		*p_eq		= cookie;
+	struct qed_chain	*p_chain	= &p_eq->chain;
+	int			rc		= 0;
+
+	/* take a snapshot of the FW consumer */
+	u16 fw_cons_idx = le16_to_cpu(*p_eq->p_fw_cons);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SPQ, "fw_cons_idx %x\n", fw_cons_idx);
+
+	/* Need to guarantee the fw_cons index we use points to a usuable
+	 * element (to comply with our chain), so our macros would comply
+	 */
+	if ((fw_cons_idx & qed_chain_get_usable_per_page(p_chain)) ==
+	    qed_chain_get_usable_per_page(p_chain))
+		fw_cons_idx += qed_chain_get_unusable_per_page(p_chain);
+
+	/* Complete current segment of eq entries */
+	while (fw_cons_idx != qed_chain_get_cons_idx(p_chain)) {
+		struct event_ring_entry *p_eqe = qed_chain_consume(p_chain);
+
+		if (!p_eqe) {
+			rc = -EINVAL;
+			break;
+		}
+
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_SPQ,
+			   "op %x prot %x res0 %x echo %x fwret %x flags %x\n",
+			   p_eqe->opcode,
+			   p_eqe->protocol_id,
+			   p_eqe->reserved0,
+			   le16_to_cpu(p_eqe->echo),
+			   p_eqe->fw_return_code,
+			   p_eqe->flags);
+
+		if (GET_FIELD(p_eqe->flags, EVENT_RING_ENTRY_ASYNC)) {
+			if (qed_async_event_completion(p_hwfn, p_eqe))
+				rc = -EINVAL;
+		} else if (qed_spq_completion(p_hwfn,
+					      p_eqe->echo,
+					      p_eqe->fw_return_code,
+					      &p_eqe->data)) {
+			rc = -EINVAL;
+		}
+
+		qed_chain_recycle_consumed(p_chain);
+	}
+
+	qed_eq_prod_update(p_hwfn, qed_chain_get_prod_idx(p_chain));
+
+	return rc;
+}
+
+struct qed_eq *qed_eq_alloc(struct qed_hwfn	*p_hwfn,
+			    u16			num_elem)
+{
+	struct qed_eq *p_eq;
+
+	/* Allocate EQ struct */
+	p_eq = kzalloc(sizeof(*p_eq), GFP_ATOMIC);
+	if (!p_eq) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_eq'\n");
+		return NULL;
+	}
+
+	/* Allocate and initialize EQ chain*/
+	if (qed_chain_alloc(p_hwfn->cdev,
+			    QED_CHAIN_USE_TO_PRODUCE,
+			    QED_CHAIN_MODE_PBL,
+			    num_elem,
+			    sizeof(union event_ring_element),
+			    &p_eq->chain)) {
+		DP_NOTICE(p_hwfn, "Failed to allocate eq chain\n");
+		goto eq_allocate_fail;
+	}
+
+	/* register EQ completion on the SP SB */
+	qed_int_register_cb(p_hwfn,
+			    qed_eq_completion,
+			    p_eq,
+			    &p_eq->eq_sb_index,
+			    &p_eq->p_fw_cons);
+
+	return p_eq;
+
+eq_allocate_fail:
+	qed_eq_free(p_hwfn, p_eq);
+	return NULL;
+}
+
+void qed_eq_setup(struct qed_hwfn	*p_hwfn,
+		  struct qed_eq		*p_eq)
+{
+	qed_chain_reset(&p_eq->chain);
+}
+
+void qed_eq_free(struct qed_hwfn	*p_hwfn,
+		 struct qed_eq		*p_eq)
+{
+	if (!p_eq)
+		return;
+	qed_chain_free(p_hwfn->cdev, &p_eq->chain);
+	kfree(p_eq);
+}
+
+/***************************************************************************
+* Slow hwfn Queue (spq)
+***************************************************************************/
+void qed_spq_setup(struct qed_hwfn *p_hwfn)
+{
+	struct qed_spq		*p_spq	= p_hwfn->p_spq;
+	struct qed_spq_entry	*p_virt = NULL;
+	dma_addr_t		p_phys	= 0;
+	unsigned int		i	= 0;
+
+	INIT_LIST_HEAD(&p_spq->pending);
+	INIT_LIST_HEAD(&p_spq->completion_pending);
+	INIT_LIST_HEAD(&p_spq->free_pool);
+	INIT_LIST_HEAD(&p_spq->unlimited_pending);
+	spin_lock_init(&p_spq->lock);
+
+	/* SPQ empty pool */
+	p_phys	= p_spq->p_phys + offsetof(struct qed_spq_entry, ramrod);
+	p_virt	= p_spq->p_virt;
+
+	for (i = 0; i < p_spq->chain.capacity; i++) {
+		p_virt->elem.data_ptr.hi	= DMA_HI_LE(p_phys);
+		p_virt->elem.data_ptr.lo	= DMA_LO_LE(p_phys);
+
+		list_add_tail(&p_virt->list, &p_spq->free_pool);
+
+		p_virt++;
+		p_phys += sizeof(struct qed_spq_entry);
+	}
+
+	/* Statistics */
+	p_spq->normal_count		= 0;
+	p_spq->comp_count		= 0;
+	p_spq->comp_sent_count		= 0;
+	p_spq->unlimited_pending_count	= 0;
+	p_spq->echo_idx			= 0;
+
+	/* SPQ cid, cannot fail */
+	qed_cxt_acquire_cid(p_hwfn, PROTOCOLID_CORE, &p_spq->cid);
+	qed_spq_hw_initialize(p_hwfn, p_spq);
+
+	/* reset the chain itself */
+	qed_chain_reset(&p_spq->chain);
+}
+
+int qed_spq_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_spq		*p_spq	= NULL;
+	dma_addr_t		p_phys	= 0;
+	struct qed_spq_entry	*p_virt = NULL;
+
+	/* SPQ struct */
+	p_spq =
+		kzalloc(sizeof(struct qed_spq), GFP_ATOMIC);
+	if (!p_spq) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_spq'\n");
+		return -ENOMEM;
+	}
+
+	/* SPQ ring  */
+	if (qed_chain_alloc(p_hwfn->cdev,
+			    QED_CHAIN_USE_TO_PRODUCE,
+			    QED_CHAIN_MODE_SINGLE,
+			    0,   /* N/A when the mode is SINGLE */
+			    sizeof(struct slow_path_element),
+			    &p_spq->chain)) {
+		DP_NOTICE(p_hwfn, "Failed to allocate spq chain\n");
+		goto spq_allocate_fail;
+	}
+
+	/* allocate and fill the SPQ elements (incl. ramrod data list) */
+	p_virt = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				    p_spq->chain.capacity *
+				    sizeof(struct qed_spq_entry),
+				    &p_phys,
+				    GFP_KERNEL);
+
+	if (!p_virt)
+		goto spq_allocate_fail;
+
+	p_spq->p_virt	= p_virt;
+	p_spq->p_phys	= p_phys;
+
+	;
+
+	p_hwfn->p_spq = p_spq;
+	return 0;
+
+spq_allocate_fail:
+	qed_chain_free(p_hwfn->cdev, &p_spq->chain);
+	kfree(p_spq);
+	return -ENOMEM;
+}
+
+void qed_spq_free(struct qed_hwfn *p_hwfn)
+{
+	struct qed_spq *p_spq = p_hwfn->p_spq;
+
+	if (!p_spq)
+		return;
+
+	if (p_spq->p_virt)
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  p_spq->chain.capacity *
+				  sizeof(struct qed_spq_entry),
+				  p_spq->p_virt,
+				  p_spq->p_phys);
+
+	qed_chain_free(p_hwfn->cdev, &p_spq->chain);
+	;
+	kfree(p_spq);
+}
+
+int
+qed_spq_get_entry(struct qed_hwfn	*p_hwfn,
+		  struct qed_spq_entry	**pp_ent)
+{
+	struct qed_spq		*p_spq	= p_hwfn->p_spq;
+	struct qed_spq_entry	*p_ent	= NULL;
+
+	spin_lock_bh(&p_spq->lock);
+
+	if (list_empty(&p_spq->free_pool)) {
+		p_ent = kzalloc(sizeof(*p_ent), GFP_ATOMIC);
+		if (!p_ent) {
+			spin_unlock_bh(&p_spq->lock);
+			return -ENOMEM;
+		}
+		p_ent->queue = &p_spq->unlimited_pending;
+	} else {
+		p_ent = list_first_entry(&p_spq->free_pool,
+					 struct qed_spq_entry,
+					 list);
+		list_del(&p_ent->list);
+		p_ent->queue = &p_spq->pending;
+	}
+
+	*pp_ent = p_ent;
+
+	spin_unlock_bh(&p_spq->lock);
+
+	return 0;
+}
+
+/* Locked variant; Should be called while the SPQ lock is taken */
+static void __qed_spq_return_entry(struct qed_hwfn	*p_hwfn,
+				   struct qed_spq_entry *p_ent)
+{
+	list_add_tail(&p_ent->list, &p_hwfn->p_spq->free_pool);
+}
+
+void qed_spq_return_entry(struct qed_hwfn	*p_hwfn,
+			  struct qed_spq_entry	*p_ent)
+{
+	spin_lock_bh(&p_hwfn->p_spq->lock);
+	__qed_spq_return_entry(p_hwfn, p_ent);
+	spin_unlock_bh(&p_hwfn->p_spq->lock);
+}
+
+/**
+ * @brief qed_spq_add_entry - adds a new entry to the pending
+ *        list. Should be used while lock is being held.
+ *
+ * Addes an entry to the pending list is there is room (en empty
+ * element is available in the free_pool), or else places the
+ * entry in the unlimited_pending pool.
+ *
+ * @param p_hwfn
+ * @param p_ent
+ * @param priority
+ *
+ * @return int
+ */
+static int
+qed_spq_add_entry(struct qed_hwfn	*p_hwfn,
+		  struct qed_spq_entry	*p_ent,
+		  enum spq_priority	priority)
+{
+	struct qed_spq *p_spq = p_hwfn->p_spq;
+
+	if (p_ent->queue == &p_spq->unlimited_pending) {
+		struct qed_spq_entry *p_en2;
+
+		if (list_empty(&p_spq->free_pool)) {
+			list_add_tail(&p_ent->list, &p_spq->unlimited_pending);
+			p_spq->unlimited_pending_count++;
+
+			return 0;
+		}
+
+		p_en2 = list_first_entry(&p_spq->free_pool,
+					 struct qed_spq_entry,
+					 list);
+		list_del(&p_en2->list);
+
+		/* Strcut assignment */
+		*p_en2 = *p_ent;
+
+		kfree(p_ent);
+
+		p_ent = p_en2;
+	}
+
+	/* entry is to be placed in 'pending' queue */
+	switch (priority) {
+	case QED_SPQ_PRIORITY_NORMAL:
+		list_add_tail(&p_ent->list, &p_spq->pending);
+		p_spq->normal_count++;
+		break;
+	case QED_SPQ_PRIORITY_HIGH:
+		list_add(&p_ent->list, &p_spq->pending);
+		p_spq->high_count++;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/***************************************************************************
+* Accessor
+***************************************************************************/
+u32 qed_spq_get_cid(struct qed_hwfn *p_hwfn)
+{
+	if (!p_hwfn->p_spq)
+		return 0xffffffff;      /* illegal */
+	return p_hwfn->p_spq->cid;
+}
+
+/***************************************************************************
+* Posting new Ramrods
+***************************************************************************/
+static int qed_spq_post_list(struct qed_hwfn	*p_hwfn,
+			     struct list_head	*head,
+			     u32		keep_reserve)
+{
+	struct qed_spq	*p_spq = p_hwfn->p_spq;
+	int		rc;
+
+	/* TODO - implementation might be wasteful; will always keep room
+	 * for an additional high priority ramrod (even if one is already
+	 * pending FW)
+	 */
+	while (qed_chain_get_elem_left(&p_spq->chain) > keep_reserve &&
+	       !list_empty(head)) {
+		struct qed_spq_entry *p_ent =
+			list_first_entry(head, struct qed_spq_entry, list);
+		list_del(&p_ent->list);
+		list_add_tail(&p_ent->list, &p_spq->completion_pending);
+		p_spq->comp_sent_count++;
+
+		rc = qed_spq_hw_post(p_hwfn, p_spq, p_ent);
+		if (rc) {
+			list_del(&p_ent->list);
+			__qed_spq_return_entry(p_hwfn, p_ent);
+			return rc;
+		}
+	}
+
+	return 0;
+}
+
+static int qed_spq_pend_post(struct qed_hwfn *p_hwfn)
+{
+	struct qed_spq		*p_spq	= p_hwfn->p_spq;
+	struct qed_spq_entry	*p_ent	= NULL;
+
+	while (!list_empty(&p_spq->free_pool)) {
+		if (list_empty(&p_spq->unlimited_pending))
+			break;
+
+		p_ent = list_first_entry(&p_spq->unlimited_pending,
+					 struct qed_spq_entry,
+					 list);
+		if (!p_ent)
+			return -EINVAL;
+
+		list_del(&p_ent->list);
+
+		qed_spq_add_entry(p_hwfn, p_ent, p_ent->priority);
+	}
+
+	return qed_spq_post_list(p_hwfn, &p_spq->pending,
+				 SPQ_HIGH_PRI_RESERVE_DEFAULT);
+}
+
+int qed_spq_post(struct qed_hwfn	*p_hwfn,
+		 struct qed_spq_entry	*p_ent,
+		 u8			*fw_return_code)
+{
+	int		rc		= 0;
+	struct qed_spq	*p_spq		= p_hwfn ? p_hwfn->p_spq : NULL;
+	bool		b_ret_ent	= true;
+
+	if (!p_hwfn)
+		return -EINVAL;
+
+	if (!p_ent) {
+		DP_NOTICE(p_hwfn, "Got a NULL pointer\n");
+		return -EINVAL;
+	}
+
+	/* Complete the entry */
+	rc = qed_spq_fill_entry(p_hwfn, p_ent);
+
+	spin_lock_bh(&p_spq->lock);
+
+	/* Check return value after LOCK is taken for cleaner error flow */
+	if (rc)
+		goto spq_post_fail;
+
+	/* Add the request to the pending queue */
+	rc = qed_spq_add_entry(p_hwfn, p_ent, p_ent->priority);
+	if (rc)
+		goto spq_post_fail;
+
+	rc = qed_spq_pend_post(p_hwfn);
+	if (rc) {
+		/* Since it's possible that pending failed for a different
+		 * entry [although unlikely], the failed entry was already
+		 * dealt with; No need to return it here.
+		 */
+		b_ret_ent = false;
+		goto spq_post_fail;
+	}
+
+	spin_unlock_bh(&p_spq->lock);
+
+	if (p_ent->comp_mode == QED_SPQ_MODE_EBLOCK) {
+		/* For entries in QED BLOCK mode, the completion code cannot
+		 * perform the necessary cleanup - if it did, we couldn't
+		 * access p_ent here to see whether it's successful or not.
+		 * Thus, after gaining the answer perform the cleanup here.
+		 */
+		rc = qed_spq_block(p_hwfn, p_ent, fw_return_code);
+		if (rc)
+			goto spq_post_fail2;
+
+		/* return to pool */
+		qed_spq_return_entry(p_hwfn, p_ent);
+	}
+	return rc;
+
+spq_post_fail2:
+	spin_lock_bh(&p_spq->lock);
+	list_del(&p_ent->list);
+	qed_chain_return_produced(&p_spq->chain);
+
+spq_post_fail:
+	/* return to the free pool */
+	if (b_ret_ent)
+		__qed_spq_return_entry(p_hwfn, p_ent);
+	spin_unlock_bh(&p_spq->lock);
+
+	return rc;
+}
+
+int qed_spq_completion(struct qed_hwfn		*p_hwfn,
+		       __le16			echo,
+		       u8			fw_return_code,
+		       union event_ring_data	*p_data)
+{
+	struct qed_spq		*p_spq;
+	struct qed_spq_entry	*p_ent = NULL;
+	struct qed_spq_entry	*tmp;
+	struct qed_spq_entry	*found = NULL;
+	int			rc;
+
+	if (!p_hwfn)
+		return -EINVAL;
+
+	p_spq = p_hwfn->p_spq;
+	if (!p_spq)
+		return -EINVAL;
+
+	spin_lock_bh(&p_spq->lock);
+	list_for_each_entry_safe(p_ent, tmp, &p_spq->completion_pending,
+				 list) {
+		if (p_ent->elem.hdr.echo == echo) {
+			list_del(&p_ent->list);
+
+			qed_chain_return_produced(&p_spq->chain);
+			p_spq->comp_count++;
+			found = p_ent;
+			break;
+		}
+	}
+
+	/* Release lock before callback, as callback may post
+	 * an additional ramrod.
+	 */
+	spin_unlock_bh(&p_spq->lock);
+
+	if (!found) {
+		DP_NOTICE(p_hwfn,
+			  "Failed to find an entry this EQE completes\n");
+		return -EEXIST;
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SPQ, "Complete: func %p cookie %p)\n",
+		   p_ent->comp_cb.function, p_ent->comp_cb.cookie);
+	if (found->comp_cb.function)
+		found->comp_cb.function(p_hwfn, found->comp_cb.cookie, p_data,
+					fw_return_code);
+
+	if (found->comp_mode != QED_SPQ_MODE_EBLOCK)
+		/* EBLOCK is responsible for freeing its own entry */
+		qed_spq_return_entry(p_hwfn, found);
+
+	/* Attempt to post pending requests */
+	spin_lock_bh(&p_spq->lock);
+	rc = qed_spq_pend_post(p_hwfn);
+	spin_unlock_bh(&p_spq->lock);
+
+	return rc;
+}
+
+struct qed_consq *qed_consq_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_consq *p_consq;
+
+	/* Allocate ConsQ struct */
+	p_consq = kzalloc(sizeof(*p_consq), GFP_ATOMIC);
+	if (!p_consq) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_consq'\n");
+		return NULL;
+	}
+
+	/* Allocate and initialize EQ chain*/
+	if (qed_chain_alloc(p_hwfn->cdev,
+			    QED_CHAIN_USE_TO_PRODUCE,
+			    QED_CHAIN_MODE_PBL,
+			    QED_CHAIN_PAGE_SIZE / 0x80,
+			    0x80,
+			    &p_consq->chain)) {
+		DP_NOTICE(p_hwfn, "Failed to allocate consq chain");
+		goto consq_allocate_fail;
+	}
+
+	return p_consq;
+
+consq_allocate_fail:
+	qed_consq_free(p_hwfn, p_consq);
+	return NULL;
+}
+
+void qed_consq_setup(struct qed_hwfn	*p_hwfn,
+		     struct qed_consq	*p_consq)
+{
+	qed_chain_reset(&p_consq->chain);
+}
+
+void qed_consq_free(struct qed_hwfn	*p_hwfn,
+		    struct qed_consq	*p_consq)
+{
+	if (!p_consq)
+		return;
+	qed_chain_free(p_hwfn->cdev, &p_consq->chain);
+	kfree(p_consq);
+}
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
new file mode 100644
index 0000000..6a43476
--- /dev/null
+++ b/include/linux/qed/common_hsi.h
@@ -0,0 +1,607 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef __COMMON_HSI__
+#define __COMMON_HSI__
+
+#define FW_MAJOR_VERSION	8
+#define FW_MINOR_VERSION	4
+#define FW_REVISION_VERSION	2
+#define FW_ENGINEERING_VERSION	0
+
+/***********************/
+/* COMMON HW CONSTANTS */
+/***********************/
+
+/* PCI functions */
+#define MAX_NUM_PORTS_K2	(4)
+#define MAX_NUM_PORTS_BB	(2)
+#define MAX_NUM_PORTS		(MAX_NUM_PORTS_K2)
+
+#define MAX_NUM_PFS_K2	(16)
+#define MAX_NUM_PFS_BB	(8)
+#define MAX_NUM_PFS	(MAX_NUM_PFS_K2)
+#define MAX_NUM_OF_PFS_IN_CHIP (16) /* On both engines */
+
+#define MAX_NUM_VFS_K2	(192)
+#define MAX_NUM_VFS_BB	(120)
+#define MAX_NUM_VFS	(MAX_NUM_VFS_K2)
+
+#define MAX_NUM_FUNCTIONS_BB	(MAX_NUM_PFS_BB + MAX_NUM_VFS_BB)
+#define MAX_NUM_FUNCTIONS	(MAX_NUM_PFS + MAX_NUM_VFS)
+
+#define MAX_FUNCTION_NUMBER_BB	(MAX_NUM_PFS + MAX_NUM_VFS_BB)
+#define MAX_FUNCTION_NUMBER	(MAX_NUM_PFS + MAX_NUM_VFS)
+
+#define MAX_NUM_VPORTS_K2	(208)
+#define MAX_NUM_VPORTS_BB	(160)
+#define MAX_NUM_VPORTS		(MAX_NUM_VPORTS_K2)
+
+#define MAX_NUM_L2_QUEUES_K2	(320)
+#define MAX_NUM_L2_QUEUES_BB	(256)
+#define MAX_NUM_L2_QUEUES	(MAX_NUM_L2_QUEUES_K2)
+
+/* Traffic classes in network-facing blocks (PBF, BTB, NIG, BRB, PRS and QM) */
+#define NUM_PHYS_TCS_4PORT_K2	(4)
+#define NUM_OF_PHYS_TCS		(8)
+
+#define NUM_TCS_4PORT_K2	(NUM_PHYS_TCS_4PORT_K2 + 1)
+#define NUM_OF_TCS		(NUM_OF_PHYS_TCS + 1)
+
+#define LB_TC			(NUM_OF_PHYS_TCS)
+
+/* Num of possible traffic priority values */
+#define NUM_OF_PRIO		(8)
+
+#define MAX_NUM_VOQS_K2		(NUM_TCS_4PORT_K2 * MAX_NUM_PORTS_K2)
+#define MAX_NUM_VOQS_BB		(NUM_OF_TCS * MAX_NUM_PORTS_BB)
+#define MAX_NUM_VOQS		(MAX_NUM_VOQS_K2)
+#define MAX_PHYS_VOQS		(NUM_OF_PHYS_TCS * MAX_NUM_PORTS_BB)
+
+/* CIDs */
+#define NUM_OF_CONNECTION_TYPES	(8)
+#define NUM_OF_LCIDS		(320)
+#define NUM_OF_LTIDS		(320)
+
+/*****************/
+/* CDU CONSTANTS */
+/*****************/
+
+#define CDU_SEG_TYPE_OFFSET_REG_TYPE_SHIFT              (17)
+#define CDU_SEG_TYPE_OFFSET_REG_OFFSET_MASK             (0x1ffff)
+
+/*****************/
+/* DQ CONSTANTS  */
+/*****************/
+
+/* DEMS */
+#define DQ_DEMS_LEGACY			0
+
+/* XCM agg val selection */
+#define DQ_XCM_AGG_VAL_SEL_WORD2  0
+#define DQ_XCM_AGG_VAL_SEL_WORD3  1
+#define DQ_XCM_AGG_VAL_SEL_WORD4  2
+#define DQ_XCM_AGG_VAL_SEL_WORD5  3
+#define DQ_XCM_AGG_VAL_SEL_REG3   4
+#define DQ_XCM_AGG_VAL_SEL_REG4   5
+#define DQ_XCM_AGG_VAL_SEL_REG5   6
+#define DQ_XCM_AGG_VAL_SEL_REG6   7
+
+/* XCM agg val selection */
+#define DQ_XCM_ETH_EDPM_NUM_BDS_CMD \
+	DQ_XCM_AGG_VAL_SEL_WORD2
+#define DQ_XCM_ETH_TX_BD_CONS_CMD \
+	DQ_XCM_AGG_VAL_SEL_WORD3
+#define DQ_XCM_CORE_TX_BD_CONS_CMD \
+	DQ_XCM_AGG_VAL_SEL_WORD3
+#define DQ_XCM_ETH_TX_BD_PROD_CMD \
+	DQ_XCM_AGG_VAL_SEL_WORD4
+#define DQ_XCM_CORE_TX_BD_PROD_CMD \
+	DQ_XCM_AGG_VAL_SEL_WORD4
+#define DQ_XCM_CORE_SPQ_PROD_CMD \
+	DQ_XCM_AGG_VAL_SEL_WORD4
+#define DQ_XCM_ETH_GO_TO_BD_CONS_CMD            DQ_XCM_AGG_VAL_SEL_WORD5
+
+/* XCM agg counter flag selection */
+#define DQ_XCM_AGG_FLG_SHIFT_BIT14  0
+#define DQ_XCM_AGG_FLG_SHIFT_BIT15  1
+#define DQ_XCM_AGG_FLG_SHIFT_CF12   2
+#define DQ_XCM_AGG_FLG_SHIFT_CF13   3
+#define DQ_XCM_AGG_FLG_SHIFT_CF18   4
+#define DQ_XCM_AGG_FLG_SHIFT_CF19   5
+#define DQ_XCM_AGG_FLG_SHIFT_CF22   6
+#define DQ_XCM_AGG_FLG_SHIFT_CF23   7
+
+/* XCM agg counter flag selection */
+#define DQ_XCM_ETH_DQ_CF_CMD		(1 << \
+					DQ_XCM_AGG_FLG_SHIFT_CF18)
+#define DQ_XCM_CORE_DQ_CF_CMD		(1 << \
+					DQ_XCM_AGG_FLG_SHIFT_CF18)
+#define DQ_XCM_ETH_TERMINATE_CMD	(1 << \
+					DQ_XCM_AGG_FLG_SHIFT_CF19)
+#define DQ_XCM_CORE_TERMINATE_CMD	(1 << \
+					DQ_XCM_AGG_FLG_SHIFT_CF19)
+#define DQ_XCM_ETH_SLOW_PATH_CMD	(1 << \
+					DQ_XCM_AGG_FLG_SHIFT_CF22)
+#define DQ_XCM_CORE_SLOW_PATH_CMD	(1 << \
+					DQ_XCM_AGG_FLG_SHIFT_CF22)
+#define DQ_XCM_ETH_TPH_EN_CMD		(1 << \
+					DQ_XCM_AGG_FLG_SHIFT_CF23)
+
+/*****************/
+/* QM CONSTANTS  */
+/*****************/
+
+/* number of TX queues in the QM */
+#define MAX_QM_TX_QUEUES_K2	512
+#define MAX_QM_TX_QUEUES_BB	448
+#define MAX_QM_TX_QUEUES	MAX_QM_TX_QUEUES_K2
+
+/* number of Other queues in the QM */
+#define MAX_QM_OTHER_QUEUES_BB	64
+#define MAX_QM_OTHER_QUEUES_K2	128
+#define MAX_QM_OTHER_QUEUES	MAX_QM_OTHER_QUEUES_K2
+
+/* number of queues in a PF queue group */
+#define QM_PF_QUEUE_GROUP_SIZE	8
+
+/* base number of Tx PQs in the CM PQ representation.
+ * should be used when storing PQ IDs in CM PQ registers and context
+ */
+#define CM_TX_PQ_BASE	0x200
+
+/* QM registers data */
+#define QM_LINE_CRD_REG_WIDTH		16
+#define QM_LINE_CRD_REG_SIGN_BIT	(1 << (QM_LINE_CRD_REG_WIDTH - 1))
+#define QM_BYTE_CRD_REG_WIDTH		24
+#define QM_BYTE_CRD_REG_SIGN_BIT	(1 << (QM_BYTE_CRD_REG_WIDTH - 1))
+#define QM_WFQ_CRD_REG_WIDTH		32
+#define QM_WFQ_CRD_REG_SIGN_BIT		(1 << (QM_WFQ_CRD_REG_WIDTH - 1))
+#define QM_RL_CRD_REG_WIDTH		32
+#define QM_RL_CRD_REG_SIGN_BIT		(1 << (QM_RL_CRD_REG_WIDTH - 1))
+
+/*****************/
+/* CAU CONSTANTS */
+/*****************/
+
+#define CAU_FSM_ETH_RX  0
+#define CAU_FSM_ETH_TX  1
+
+/* Number of Protocol Indices per Status Block */
+#define PIS_PER_SB    12
+
+#define CAU_HC_STOPPED_STATE	3
+#define CAU_HC_DISABLE_STATE	4
+#define CAU_HC_ENABLE_STATE	0
+
+/*****************/
+/* IGU CONSTANTS */
+/*****************/
+
+#define MAX_SB_PER_PATH_K2	(368)
+#define MAX_SB_PER_PATH_BB	(288)
+#define MAX_TOT_SB_PER_PATH \
+	MAX_SB_PER_PATH_K2
+
+#define MAX_SB_PER_PF_MIMD	129
+#define MAX_SB_PER_PF_SIMD	64
+#define MAX_SB_PER_VF		64
+
+/* Memory addresses on the BAR for the IGU Sub Block */
+#define IGU_MEM_BASE			0x0000
+
+#define IGU_MEM_MSIX_BASE		0x0000
+#define IGU_MEM_MSIX_UPPER		0x0101
+#define IGU_MEM_MSIX_RESERVED_UPPER	0x01ff
+
+#define IGU_MEM_PBA_MSIX_BASE		0x0200
+#define IGU_MEM_PBA_MSIX_UPPER		0x0202
+#define IGU_MEM_PBA_MSIX_RESERVED_UPPER	0x03ff
+
+#define IGU_CMD_INT_ACK_BASE		0x0400
+#define IGU_CMD_INT_ACK_UPPER		(IGU_CMD_INT_ACK_BASE +	\
+					 MAX_TOT_SB_PER_PATH -	\
+					 1)
+#define IGU_CMD_INT_ACK_RESERVED_UPPER	0x05ff
+
+#define IGU_CMD_ATTN_BIT_UPD_UPPER	0x05f0
+#define IGU_CMD_ATTN_BIT_SET_UPPER	0x05f1
+#define IGU_CMD_ATTN_BIT_CLR_UPPER	0x05f2
+
+#define IGU_REG_SISR_MDPC_WMASK_UPPER		0x05f3
+#define IGU_REG_SISR_MDPC_WMASK_LSB_UPPER	0x05f4
+#define IGU_REG_SISR_MDPC_WMASK_MSB_UPPER	0x05f5
+#define IGU_REG_SISR_MDPC_WOMASK_UPPER		0x05f6
+
+#define IGU_CMD_PROD_UPD_BASE			0x0600
+#define IGU_CMD_PROD_UPD_UPPER			(IGU_CMD_PROD_UPD_BASE +\
+						 MAX_TOT_SB_PER_PATH - \
+						 1)
+#define IGU_CMD_PROD_UPD_RESERVED_UPPER		0x07ff
+
+/*****************/
+/* PXP CONSTANTS */
+/*****************/
+
+/* PTT and GTT */
+#define PXP_NUM_PF_WINDOWS		12
+#define PXP_PER_PF_ENTRY_SIZE		8
+#define PXP_NUM_GLOBAL_WINDOWS		243
+#define PXP_GLOBAL_ENTRY_SIZE		4
+#define PXP_ADMIN_WINDOW_ALLOWED_LENGTH	4
+#define PXP_PF_WINDOW_ADMIN_START	0
+#define PXP_PF_WINDOW_ADMIN_LENGTH	0x1000
+#define PXP_PF_WINDOW_ADMIN_END		(PXP_PF_WINDOW_ADMIN_START + \
+					 PXP_PF_WINDOW_ADMIN_LENGTH - 1)
+#define PXP_PF_WINDOW_ADMIN_PER_PF_START	0
+#define PXP_PF_WINDOW_ADMIN_PER_PF_LENGTH	(PXP_NUM_PF_WINDOWS * \
+						 PXP_PER_PF_ENTRY_SIZE)
+#define PXP_PF_WINDOW_ADMIN_PER_PF_END	(PXP_PF_WINDOW_ADMIN_PER_PF_START + \
+					 PXP_PF_WINDOW_ADMIN_PER_PF_LENGTH - 1)
+#define PXP_PF_WINDOW_ADMIN_GLOBAL_START	0x200
+#define PXP_PF_WINDOW_ADMIN_GLOBAL_LENGTH	(PXP_NUM_GLOBAL_WINDOWS * \
+						 PXP_GLOBAL_ENTRY_SIZE)
+#define PXP_PF_WINDOW_ADMIN_GLOBAL_END \
+		(PXP_PF_WINDOW_ADMIN_GLOBAL_START + \
+		 PXP_PF_WINDOW_ADMIN_GLOBAL_LENGTH - 1)
+#define PXP_PF_GLOBAL_PRETEND_ADDR	0x1f0
+#define PXP_PF_ME_OPAQUE_MASK_ADDR	0xf4
+#define PXP_PF_ME_OPAQUE_ADDR		0x1f8
+#define PXP_PF_ME_CONCRETE_ADDR		0x1fc
+
+#define PXP_EXTERNAL_BAR_PF_WINDOW_START	0x1000
+#define PXP_EXTERNAL_BAR_PF_WINDOW_NUM		PXP_NUM_PF_WINDOWS
+#define PXP_EXTERNAL_BAR_PF_WINDOW_SINGLE_SIZE	0x1000
+#define PXP_EXTERNAL_BAR_PF_WINDOW_LENGTH \
+	(PXP_EXTERNAL_BAR_PF_WINDOW_NUM * \
+	 PXP_EXTERNAL_BAR_PF_WINDOW_SINGLE_SIZE)
+#define PXP_EXTERNAL_BAR_PF_WINDOW_END \
+	(PXP_EXTERNAL_BAR_PF_WINDOW_START + \
+	 PXP_EXTERNAL_BAR_PF_WINDOW_LENGTH - 1)
+
+#define PXP_EXTERNAL_BAR_GLOBAL_WINDOW_START \
+	(PXP_EXTERNAL_BAR_PF_WINDOW_END + 1)
+#define PXP_EXTERNAL_BAR_GLOBAL_WINDOW_NUM		PXP_NUM_GLOBAL_WINDOWS
+#define PXP_EXTERNAL_BAR_GLOBAL_WINDOW_SINGLE_SIZE	0x1000
+#define PXP_EXTERNAL_BAR_GLOBAL_WINDOW_LENGTH \
+	(PXP_EXTERNAL_BAR_GLOBAL_WINDOW_NUM * \
+	 PXP_EXTERNAL_BAR_GLOBAL_WINDOW_SINGLE_SIZE)
+#define PXP_EXTERNAL_BAR_GLOBAL_WINDOW_END \
+	(PXP_EXTERNAL_BAR_GLOBAL_WINDOW_START + \
+	 PXP_EXTERNAL_BAR_GLOBAL_WINDOW_LENGTH - 1)
+
+#define PXP_ILT_PAGE_SIZE_NUM_BITS_MIN	12
+#define PXP_ILT_BLOCK_FACTOR_MULTIPLIER	1024
+
+/* ILT Records */
+#define PXP_NUM_ILT_RECORDS_BB 7600
+#define PXP_NUM_ILT_RECORDS_K2 11000
+#define MAX_NUM_ILT_RECORDS MAX(PXP_NUM_ILT_RECORDS_BB, PXP_NUM_ILT_RECORDS_K2)
+
+/******************/
+/* PBF CONSTANTS  */
+/******************/
+
+/* Number of PBF command queue lines. Each line is 32B. */
+#define PBF_MAX_CMD_LINES 3328
+
+/* Number of BTB blocks. Each block is 256B. */
+#define BTB_MAX_BLOCKS 1440
+
+/*****************/
+/* PRS CONSTANTS */
+/*****************/
+
+/* Async data KCQ CQE */
+struct async_data {
+	__le32	cid;
+	__le16	itid;
+	u8	error_code;
+	u8	fw_debug_param;
+};
+
+struct regpair {
+	__le32	lo;
+	__le32	hi;
+};
+
+/* Event Data Union */
+union event_ring_data {
+	u8				bytes[8];
+	struct async_data		async_info;
+};
+
+/* Event Ring Entry */
+struct event_ring_entry {
+	u8			protocol_id;
+	u8			opcode;
+	__le16			reserved0;
+	__le16			echo;
+	u8			fw_return_code;
+	u8			flags;
+#define EVENT_RING_ENTRY_ASYNC_MASK      0x1
+#define EVENT_RING_ENTRY_ASYNC_SHIFT     0
+#define EVENT_RING_ENTRY_RESERVED1_MASK  0x7F
+#define EVENT_RING_ENTRY_RESERVED1_SHIFT 1
+	union event_ring_data	data;
+};
+
+/* Multi function mode */
+enum mf_mode {
+	SF,
+	MF_OVLAN,
+	MF_NPAR,
+	MAX_MF_MODE
+};
+
+/* Per-protocol connection types */
+enum protocol_type {
+	PROTOCOLID_RESERVED1,
+	PROTOCOLID_RESERVED2,
+	PROTOCOLID_RESERVED3,
+	PROTOCOLID_CORE,
+	PROTOCOLID_ETH,
+	PROTOCOLID_RESERVED4,
+	PROTOCOLID_RESERVED5,
+	PROTOCOLID_PREROCE,
+	PROTOCOLID_COMMON,
+	PROTOCOLID_RESERVED6,
+	MAX_PROTOCOL_TYPE
+};
+
+/* status block structure */
+struct cau_pi_entry {
+	u32 prod;
+#define CAU_PI_ENTRY_PROD_VAL_MASK    0xFFFF
+#define CAU_PI_ENTRY_PROD_VAL_SHIFT   0
+#define CAU_PI_ENTRY_PI_TIMESET_MASK  0x7F
+#define CAU_PI_ENTRY_PI_TIMESET_SHIFT 16
+#define CAU_PI_ENTRY_FSM_SEL_MASK     0x1
+#define CAU_PI_ENTRY_FSM_SEL_SHIFT    23
+#define CAU_PI_ENTRY_RESERVED_MASK    0xFF
+#define CAU_PI_ENTRY_RESERVED_SHIFT   24
+};
+
+/* status block structure */
+struct cau_sb_entry {
+	u32 data;
+#define CAU_SB_ENTRY_SB_PROD_MASK      0xFFFFFF
+#define CAU_SB_ENTRY_SB_PROD_SHIFT     0
+#define CAU_SB_ENTRY_STATE0_MASK       0xF
+#define CAU_SB_ENTRY_STATE0_SHIFT      24
+#define CAU_SB_ENTRY_STATE1_MASK       0xF
+#define CAU_SB_ENTRY_STATE1_SHIFT      28
+	u32 params;
+#define CAU_SB_ENTRY_SB_TIMESET0_MASK  0x7F
+#define CAU_SB_ENTRY_SB_TIMESET0_SHIFT 0
+#define CAU_SB_ENTRY_SB_TIMESET1_MASK  0x7F
+#define CAU_SB_ENTRY_SB_TIMESET1_SHIFT 7
+#define CAU_SB_ENTRY_TIMER_RES0_MASK   0x3
+#define CAU_SB_ENTRY_TIMER_RES0_SHIFT  14
+#define CAU_SB_ENTRY_TIMER_RES1_MASK   0x3
+#define CAU_SB_ENTRY_TIMER_RES1_SHIFT  16
+#define CAU_SB_ENTRY_VF_NUMBER_MASK    0xFF
+#define CAU_SB_ENTRY_VF_NUMBER_SHIFT   18
+#define CAU_SB_ENTRY_VF_VALID_MASK     0x1
+#define CAU_SB_ENTRY_VF_VALID_SHIFT    26
+#define CAU_SB_ENTRY_PF_NUMBER_MASK    0xF
+#define CAU_SB_ENTRY_PF_NUMBER_SHIFT   27
+#define CAU_SB_ENTRY_TPH_MASK          0x1
+#define CAU_SB_ENTRY_TPH_SHIFT         31
+};
+
+/* core doorbell data */
+struct core_db_data {
+	u8 params;
+#define CORE_DB_DATA_DEST_MASK         0x3
+#define CORE_DB_DATA_DEST_SHIFT        0
+#define CORE_DB_DATA_AGG_CMD_MASK      0x3
+#define CORE_DB_DATA_AGG_CMD_SHIFT     2
+#define CORE_DB_DATA_BYPASS_EN_MASK    0x1
+#define CORE_DB_DATA_BYPASS_EN_SHIFT   4
+#define CORE_DB_DATA_RESERVED_MASK     0x1
+#define CORE_DB_DATA_RESERVED_SHIFT    5
+#define CORE_DB_DATA_AGG_VAL_SEL_MASK  0x3
+#define CORE_DB_DATA_AGG_VAL_SEL_SHIFT 6
+	u8	agg_flags;
+	__le16	spq_prod;
+};
+
+/* Enum of doorbell aggregative command selection */
+enum db_agg_cmd_sel {
+	DB_AGG_CMD_NOP,
+	DB_AGG_CMD_SET,
+	DB_AGG_CMD_ADD,
+	DB_AGG_CMD_MAX,
+	MAX_DB_AGG_CMD_SEL
+};
+
+/* Enum of doorbell destination */
+enum db_dest {
+	DB_DEST_XCM,
+	DB_DEST_UCM,
+	DB_DEST_TCM,
+	DB_NUM_DESTINATIONS,
+	MAX_DB_DEST
+};
+
+/* Structure for doorbell address, in legacy mode */
+struct db_legacy_addr {
+	__le32 addr;
+#define DB_LEGACY_ADDR_RESERVED0_MASK  0x3
+#define DB_LEGACY_ADDR_RESERVED0_SHIFT 0
+#define DB_LEGACY_ADDR_DEMS_MASK       0x7
+#define DB_LEGACY_ADDR_DEMS_SHIFT      2
+#define DB_LEGACY_ADDR_ICID_MASK       0x7FFFFFF
+#define DB_LEGACY_ADDR_ICID_SHIFT      5
+};
+
+/* Igu interrupt command */
+enum igu_int_cmd {
+	IGU_INT_ENABLE	= 0,
+	IGU_INT_DISABLE = 1,
+	IGU_INT_NOP	= 2,
+	IGU_INT_NOP2	= 3,
+	MAX_IGU_INT_CMD
+};
+
+/* IGU producer or consumer update command */
+struct igu_prod_cons_update {
+	u32 sb_id_and_flags;
+#define IGU_PROD_CONS_UPDATE_SB_INDEX_MASK        0xFFFFFF
+#define IGU_PROD_CONS_UPDATE_SB_INDEX_SHIFT       0
+#define IGU_PROD_CONS_UPDATE_UPDATE_FLAG_MASK     0x1
+#define IGU_PROD_CONS_UPDATE_UPDATE_FLAG_SHIFT    24
+#define IGU_PROD_CONS_UPDATE_ENABLE_INT_MASK      0x3
+#define IGU_PROD_CONS_UPDATE_ENABLE_INT_SHIFT     25
+#define IGU_PROD_CONS_UPDATE_SEGMENT_ACCESS_MASK  0x1
+#define IGU_PROD_CONS_UPDATE_SEGMENT_ACCESS_SHIFT 27
+#define IGU_PROD_CONS_UPDATE_TIMER_MASK_MASK      0x1
+#define IGU_PROD_CONS_UPDATE_TIMER_MASK_SHIFT     28
+#define IGU_PROD_CONS_UPDATE_RESERVED0_MASK       0x3
+#define IGU_PROD_CONS_UPDATE_RESERVED0_SHIFT      29
+#define IGU_PROD_CONS_UPDATE_COMMAND_TYPE_MASK    0x1
+#define IGU_PROD_CONS_UPDATE_COMMAND_TYPE_SHIFT   31
+	u32 reserved1;
+};
+
+/* Igu segments access for default status block only */
+enum igu_seg_access {
+	IGU_SEG_ACCESS_REG	= 0,
+	IGU_SEG_ACCESS_ATTN	= 1,
+	MAX_IGU_SEG_ACCESS
+};
+
+struct parsing_and_err_flags {
+	__le16 flags;
+#define PARSING_AND_ERR_FLAGS_L3TYPE_MASK                      0x3
+#define PARSING_AND_ERR_FLAGS_L3TYPE_SHIFT                     0
+#define PARSING_AND_ERR_FLAGS_L4PROTOCOL_MASK                  0x3
+#define PARSING_AND_ERR_FLAGS_L4PROTOCOL_SHIFT                 2
+#define PARSING_AND_ERR_FLAGS_IPV4FRAG_MASK                    0x1
+#define PARSING_AND_ERR_FLAGS_IPV4FRAG_SHIFT                   4
+#define PARSING_AND_ERR_FLAGS_TAG8021QEXIST_MASK               0x1
+#define PARSING_AND_ERR_FLAGS_TAG8021QEXIST_SHIFT              5
+#define PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED_MASK        0x1
+#define PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED_SHIFT       6
+#define PARSING_AND_ERR_FLAGS_TIMESYNCPKT_MASK                 0x1
+#define PARSING_AND_ERR_FLAGS_TIMESYNCPKT_SHIFT                7
+#define PARSING_AND_ERR_FLAGS_TIMESTAMPRECORDED_MASK           0x1
+#define PARSING_AND_ERR_FLAGS_TIMESTAMPRECORDED_SHIFT          8
+#define PARSING_AND_ERR_FLAGS_IPHDRERROR_MASK                  0x1
+#define PARSING_AND_ERR_FLAGS_IPHDRERROR_SHIFT                 9
+#define PARSING_AND_ERR_FLAGS_L4CHKSMERROR_MASK                0x1
+#define PARSING_AND_ERR_FLAGS_L4CHKSMERROR_SHIFT               10
+#define PARSING_AND_ERR_FLAGS_TUNNELEXIST_MASK                 0x1
+#define PARSING_AND_ERR_FLAGS_TUNNELEXIST_SHIFT                11
+#define PARSING_AND_ERR_FLAGS_TUNNEL8021QTAGEXIST_MASK         0x1
+#define PARSING_AND_ERR_FLAGS_TUNNEL8021QTAGEXIST_SHIFT        12
+#define PARSING_AND_ERR_FLAGS_TUNNELIPHDRERROR_MASK            0x1
+#define PARSING_AND_ERR_FLAGS_TUNNELIPHDRERROR_SHIFT           13
+#define PARSING_AND_ERR_FLAGS_TUNNELL4CHKSMWASCALCULATED_MASK  0x1
+#define PARSING_AND_ERR_FLAGS_TUNNELL4CHKSMWASCALCULATED_SHIFT 14
+#define PARSING_AND_ERR_FLAGS_TUNNELL4CHKSMERROR_MASK          0x1
+#define PARSING_AND_ERR_FLAGS_TUNNELL4CHKSMERROR_SHIFT         15
+};
+
+/* Concrete Function ID. */
+struct pxp_concrete_fid {
+	__le16 fid;
+#define PXP_CONCRETE_FID_PFID_MASK     0xF
+#define PXP_CONCRETE_FID_PFID_SHIFT    0
+#define PXP_CONCRETE_FID_PORT_MASK     0x3
+#define PXP_CONCRETE_FID_PORT_SHIFT    4
+#define PXP_CONCRETE_FID_PATH_MASK     0x1
+#define PXP_CONCRETE_FID_PATH_SHIFT    6
+#define PXP_CONCRETE_FID_VFVALID_MASK  0x1
+#define PXP_CONCRETE_FID_VFVALID_SHIFT 7
+#define PXP_CONCRETE_FID_VFID_MASK     0xFF
+#define PXP_CONCRETE_FID_VFID_SHIFT    8
+};
+
+struct pxp_pretend_concrete_fid {
+	__le16 fid;
+#define PXP_PRETEND_CONCRETE_FID_PFID_MASK      0xF
+#define PXP_PRETEND_CONCRETE_FID_PFID_SHIFT     0
+#define PXP_PRETEND_CONCRETE_FID_RESERVED_MASK  0x7
+#define PXP_PRETEND_CONCRETE_FID_RESERVED_SHIFT 4
+#define PXP_PRETEND_CONCRETE_FID_VFVALID_MASK   0x1
+#define PXP_PRETEND_CONCRETE_FID_VFVALID_SHIFT  7
+#define PXP_PRETEND_CONCRETE_FID_VFID_MASK      0xFF
+#define PXP_PRETEND_CONCRETE_FID_VFID_SHIFT     8
+};
+
+union pxp_pretend_fid {
+	struct pxp_pretend_concrete_fid concrete_fid;
+	__le16				opaque_fid;
+};
+
+/* Pxp Pretend Command Register. */
+struct pxp_pretend_cmd {
+	union pxp_pretend_fid	fid;
+	__le16			control;
+#define PXP_PRETEND_CMD_PATH_MASK              0x1
+#define PXP_PRETEND_CMD_PATH_SHIFT             0
+#define PXP_PRETEND_CMD_USE_PORT_MASK          0x1
+#define PXP_PRETEND_CMD_USE_PORT_SHIFT         1
+#define PXP_PRETEND_CMD_PORT_MASK              0x3
+#define PXP_PRETEND_CMD_PORT_SHIFT             2
+#define PXP_PRETEND_CMD_RESERVED0_MASK         0xF
+#define PXP_PRETEND_CMD_RESERVED0_SHIFT        4
+#define PXP_PRETEND_CMD_RESERVED1_MASK         0xF
+#define PXP_PRETEND_CMD_RESERVED1_SHIFT        8
+#define PXP_PRETEND_CMD_PRETEND_PATH_MASK      0x1
+#define PXP_PRETEND_CMD_PRETEND_PATH_SHIFT     12
+#define PXP_PRETEND_CMD_PRETEND_PORT_MASK      0x1
+#define PXP_PRETEND_CMD_PRETEND_PORT_SHIFT     13
+#define PXP_PRETEND_CMD_PRETEND_FUNCTION_MASK  0x1
+#define PXP_PRETEND_CMD_PRETEND_FUNCTION_SHIFT 14
+#define PXP_PRETEND_CMD_IS_CONCRETE_MASK       0x1
+#define PXP_PRETEND_CMD_IS_CONCRETE_SHIFT      15
+};
+
+/* PTT Record in PXP Admin Window. */
+struct pxp_ptt_entry {
+	__le32			offset;
+#define PXP_PTT_ENTRY_OFFSET_MASK     0x7FFFFF
+#define PXP_PTT_ENTRY_OFFSET_SHIFT    0
+#define PXP_PTT_ENTRY_RESERVED0_MASK  0x1FF
+#define PXP_PTT_ENTRY_RESERVED0_SHIFT 23
+	struct pxp_pretend_cmd	pretend;
+};
+
+/* RSS hash type */
+enum rss_hash_type {
+	RSS_HASH_TYPE_DEFAULT	= 0,
+	RSS_HASH_TYPE_IPV4	= 1,
+	RSS_HASH_TYPE_TCP_IPV4	= 2,
+	RSS_HASH_TYPE_IPV6	= 3,
+	RSS_HASH_TYPE_TCP_IPV6	= 4,
+	RSS_HASH_TYPE_UDP_IPV4	= 5,
+	RSS_HASH_TYPE_UDP_IPV6	= 6,
+	MAX_RSS_HASH_TYPE
+};
+
+/* status block structure */
+struct status_block {
+	__le16	pi_array[PIS_PER_SB];
+	__le32	sb_num;
+#define STATUS_BLOCK_SB_NUM_MASK      0x1FF
+#define STATUS_BLOCK_SB_NUM_SHIFT     0
+#define STATUS_BLOCK_ZERO_PAD_MASK    0x7F
+#define STATUS_BLOCK_ZERO_PAD_SHIFT   9
+#define STATUS_BLOCK_ZERO_PAD2_MASK   0xFFFF
+#define STATUS_BLOCK_ZERO_PAD2_SHIFT  16
+	__le32 prod_index;
+#define STATUS_BLOCK_PROD_INDEX_MASK  0xFFFFFF
+#define STATUS_BLOCK_PROD_INDEX_SHIFT 0
+#define STATUS_BLOCK_ZERO_PAD3_MASK   0xFF
+#define STATUS_BLOCK_ZERO_PAD3_SHIFT  24
+};
+
+#endif /* __COMMON_HSI__ */
diff --git a/include/linux/qed/qed_chain.h b/include/linux/qed/qed_chain.h
new file mode 100644
index 0000000..ea9345b
--- /dev/null
+++ b/include/linux/qed/qed_chain.h
@@ -0,0 +1,538 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_CHAIN_H
+#define _QED_CHAIN_H
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/qed/common_hsi.h>
+
+/* dma_addr_t manip */
+#define DMA_LO_LE(x)            cpu_to_le32(lower_32_bits(x))
+#define DMA_HI_LE(x)            cpu_to_le32(upper_32_bits(x))
+
+#define HILO_GEN(hi, lo, type)  ((((type)(hi)) << 32) + (lo))
+#define HILO_DMA(hi, lo)        HILO_GEN(hi, lo, dma_addr_t)
+#define HILO_64(hi, lo) HILO_GEN((le32_to_cpu(hi)), (le32_to_cpu(lo)), u64)
+#define HILO_DMA_REGPAIR(regpair)       (HILO_DMA(regpair.hi, regpair.lo))
+#define HILO_64_REGPAIR(regpair)        (HILO_64(regpair.hi, regpair.lo))
+
+enum qed_chain_mode {
+	/* Each Page contains a next pointer at its end */
+	QED_CHAIN_MODE_NEXT_PTR,
+
+	/* Chain is a single page (next ptr) is unrequired */
+	QED_CHAIN_MODE_SINGLE,
+
+	/* Page pointers are located in a side list */
+	QED_CHAIN_MODE_PBL,
+};
+
+enum qed_chain_use_mode {
+	QED_CHAIN_USE_TO_PRODUCE,		/* Chain starts empty */
+	QED_CHAIN_USE_TO_CONSUME,		/* Chain starts full */
+	QED_CHAIN_USE_TO_CONSUME_PRODUCE,	/* Chain starts empty */
+};
+
+struct qed_chain_next {
+	struct regpair	next_phys;
+	void		*next_virt;
+};
+
+struct qed_chain_pbl {
+	dma_addr_t	p_phys_table;
+	void		*p_virt_table;
+	u16		prod_page_idx;
+	u16		cons_page_idx;
+};
+
+struct qed_chain {
+	void			*p_virt_addr;
+	dma_addr_t		p_phys_addr;
+	void			*p_prod_elem;
+	void			*p_cons_elem;
+	u16			page_cnt;
+	enum qed_chain_mode	mode;
+	enum qed_chain_use_mode intended_use; /* used to produce/consume */
+	u16			capacity; /*< number of _usable_ elements */
+	u16			size; /* number of elements */
+	u16			prod_idx;
+	u16			cons_idx;
+	u16			elem_per_page;
+	u16			elem_per_page_mask;
+	u16			elem_unusable;
+	u16			usable_per_page;
+	u16			elem_size;
+	u16			next_page_mask;
+	struct qed_chain_pbl	pbl;
+};
+
+#define QED_CHAIN_PBL_ENTRY_SIZE        (8)
+#define QED_CHAIN_PAGE_SIZE             (0x1000)
+#define ELEMS_PER_PAGE(elem_size)       (QED_CHAIN_PAGE_SIZE / (elem_size))
+
+#define UNUSABLE_ELEMS_PER_PAGE(elem_size, mode)     \
+	((mode == QED_CHAIN_MODE_NEXT_PTR) ?	     \
+	 (1 + ((sizeof(struct qed_chain_next) - 1) / \
+	       (elem_size))) : 0)
+
+#define USABLE_ELEMS_PER_PAGE(elem_size, mode) \
+	((u32)(ELEMS_PER_PAGE(elem_size) -     \
+	       UNUSABLE_ELEMS_PER_PAGE(elem_size, mode)))
+
+#define QED_CHAIN_PAGE_CNT(elem_cnt, elem_size, mode) \
+	DIV_ROUND_UP(elem_cnt, USABLE_ELEMS_PER_PAGE(elem_size, mode))
+
+/* Accessors */
+static inline u16 qed_chain_get_prod_idx(struct qed_chain *p_chain)
+{
+	return p_chain->prod_idx;
+}
+
+static inline u16 qed_chain_get_cons_idx(struct qed_chain *p_chain)
+{
+	return p_chain->cons_idx;
+}
+
+static inline u16 qed_chain_get_elem_left(struct qed_chain *p_chain)
+{
+	u16 used;
+
+	/* we don't need to trancate upon assignmet, as we assign u32->u16 */
+	used = ((u32)0x10000u + (u32)(p_chain->prod_idx)) -
+		(u32)p_chain->cons_idx;
+	if (p_chain->mode == QED_CHAIN_MODE_NEXT_PTR)
+		used -= (used / p_chain->elem_per_page);
+
+	return p_chain->capacity - used;
+}
+
+static inline u8 qed_chain_is_full(struct qed_chain *p_chain)
+{
+	return qed_chain_get_elem_left(p_chain) == p_chain->capacity;
+}
+
+static inline u8 qed_chain_is_empty(struct qed_chain *p_chain)
+{
+	return qed_chain_get_elem_left(p_chain) == 0;
+}
+
+static inline u16 qed_chain_get_elem_per_page(
+	struct qed_chain *p_chain)
+{
+	return p_chain->elem_per_page;
+}
+
+static inline u16 qed_chain_get_usable_per_page(
+	struct qed_chain *p_chain)
+{
+	return p_chain->usable_per_page;
+}
+
+static inline u16 qed_chain_get_unusable_per_page(
+	struct qed_chain *p_chain)
+{
+	return p_chain->elem_unusable;
+}
+
+static inline u16 qed_chain_get_size(struct qed_chain *p_chain)
+{
+	return p_chain->size;
+}
+
+static inline dma_addr_t
+qed_chain_get_pbl_phys(struct qed_chain *p_chain)
+{
+	return p_chain->pbl.p_phys_table;
+}
+
+/**
+ * @brief qed_chain_advance_page -
+ *
+ * Advance the next element accros pages for a linked chain
+ *
+ * @param p_chain
+ * @param p_next_elem
+ * @param idx_to_inc
+ * @param page_to_inc
+ */
+static inline void
+qed_chain_advance_page(struct qed_chain *p_chain,
+		       void		**p_next_elem,
+		       u16		*idx_to_inc,
+		       u16		*page_to_inc)
+
+{
+	switch (p_chain->mode) {
+	case QED_CHAIN_MODE_NEXT_PTR:
+	{
+		struct qed_chain_next *p_next = *p_next_elem;
+		*p_next_elem = p_next->next_virt;
+		*idx_to_inc += p_chain->elem_unusable;
+		break;
+	}
+	case QED_CHAIN_MODE_SINGLE:
+		*p_next_elem = p_chain->p_virt_addr;
+		break;
+
+	case QED_CHAIN_MODE_PBL:
+		/* It is assumed pages are sequential, next element needs
+		 * to change only when passing going back to first from last.
+		 */
+		if (++(*page_to_inc) == p_chain->page_cnt) {
+			*page_to_inc = 0;
+			*p_next_elem = p_chain->p_virt_addr;
+		}
+	}
+}
+
+#define is_unusable_idx(p, idx)	\
+	(((p)->idx & (p)->elem_per_page_mask) == (p)->usable_per_page)
+
+#define is_unusable_next_idx(p, idx) \
+	((((p)->idx + 1) & (p)->elem_per_page_mask) == (p)->usable_per_page)
+
+#define test_ans_skip(p, idx)				\
+	do {						\
+		if (is_unusable_idx(p, idx)) {		\
+			(p)->idx += (p)->elem_unusable;	\
+		}					\
+	} while (0)
+
+/**
+ * @brief qed_chain_return_multi_produced -
+ *
+ * A chain in which the driver "Produces" elements should use this API
+ * to indicate previous produced elements are now consumed.
+ *
+ * @param p_chain
+ * @param num
+ */
+static inline void
+qed_chain_return_multi_produced(struct qed_chain	*p_chain,
+				u16			num)
+{
+	p_chain->cons_idx += num;
+	test_ans_skip(p_chain, cons_idx);
+}
+
+/**
+ * @brief qed_chain_return_produced -
+ *
+ * A chain in which the driver "Produces" elements should use this API
+ * to indicate previous produced elements are now consumed.
+ *
+ * @param p_chain
+ */
+static inline void qed_chain_return_produced(struct qed_chain *p_chain)
+{
+	p_chain->cons_idx++;
+	test_ans_skip(p_chain, cons_idx);
+}
+
+/**
+ * @brief qed_chain_produce -
+ *
+ * A chain in which the driver "Produces" elements should use this to get
+ * a pointer to the next element which can be "Produced". It's driver
+ * responsibility to validate that the chain has room for new element.
+ *
+ * @param p_chain
+ *
+ * @return void*, a pointer to next element
+ */
+static inline void *qed_chain_produce(struct qed_chain *p_chain)
+{
+	void *ret = NULL;
+
+	if ((p_chain->prod_idx & p_chain->elem_per_page_mask) ==
+	    p_chain->next_page_mask) {
+		qed_chain_advance_page(p_chain, &p_chain->p_prod_elem,
+				       &p_chain->prod_idx,
+				       &p_chain->pbl.prod_page_idx);
+	}
+
+	ret = p_chain->p_prod_elem;
+	p_chain->prod_idx++;
+	p_chain->p_prod_elem = (void *)(((u8 *)p_chain->p_prod_elem) +
+					p_chain->elem_size);
+
+	return ret;
+}
+
+/**
+ * @brief qed_chain_get_capacity -
+ *
+ * Get the maximum number of BDs in chain
+ *
+ * @param p_chain
+ * @param num
+ *
+ * @return u16, number of unusable BDs
+ */
+static inline u16 qed_chain_get_capacity(struct qed_chain *p_chain)
+{
+	return p_chain->capacity;
+}
+
+/**
+ * @brief qed_chain_recycle_consumed -
+ *
+ * Returns an element which was previously consumed;
+ * Increments producers so they could be written to FW.
+ *
+ * @param p_chain
+ */
+static inline void
+qed_chain_recycle_consumed(struct qed_chain *p_chain)
+{
+	test_ans_skip(p_chain, prod_idx);
+	p_chain->prod_idx++;
+}
+
+/**
+ * @brief qed_chain_consume -
+ *
+ * A Chain in which the driver utilizes data written by a different source
+ * (i.e., FW) should use this to access passed buffers.
+ *
+ * @param p_chain
+ *
+ * @return void*, a pointer to the next buffer written
+ */
+static inline void *qed_chain_consume(struct qed_chain *p_chain)
+{
+	void *ret = NULL;
+
+	if ((p_chain->cons_idx & p_chain->elem_per_page_mask) ==
+	    p_chain->next_page_mask) {
+		qed_chain_advance_page(p_chain, &p_chain->p_cons_elem,
+				       &p_chain->cons_idx,
+				       &p_chain->pbl.cons_page_idx);
+	}
+
+	ret = p_chain->p_cons_elem;
+	p_chain->cons_idx++;
+	p_chain->p_cons_elem = (void *)(((u8 *)p_chain->p_cons_elem) +
+					p_chain->elem_size);
+
+	return ret;
+}
+
+/**
+ * @brief qed_chain_reset - Resets the chain to its start state
+ *
+ * @param p_chain pointer to a previously allocted chain
+ */
+static inline void qed_chain_reset(struct qed_chain *p_chain)
+{
+	int i;
+
+	p_chain->prod_idx	= 0;
+	p_chain->cons_idx	= 0;
+	p_chain->p_cons_elem	= p_chain->p_virt_addr;
+	p_chain->p_prod_elem	= p_chain->p_virt_addr;
+
+	if (p_chain->mode == QED_CHAIN_MODE_PBL) {
+		p_chain->pbl.prod_page_idx	= p_chain->page_cnt - 1;
+		p_chain->pbl.cons_page_idx	= p_chain->page_cnt - 1;
+	}
+
+	switch (p_chain->intended_use) {
+	case QED_CHAIN_USE_TO_CONSUME_PRODUCE:
+	case QED_CHAIN_USE_TO_PRODUCE:
+		/* Do nothing */
+		break;
+
+	case QED_CHAIN_USE_TO_CONSUME:
+		/* produce empty elements */
+		for (i = 0; i < p_chain->capacity; i++)
+			qed_chain_recycle_consumed(p_chain);
+		break;
+	}
+}
+
+/**
+ * @brief qed_chain_init - Initalizes a basic chain struct
+ *
+ * @param p_chain
+ * @param p_virt_addr
+ * @param p_phys_addr	physical address of allocated buffer's beginning
+ * @param page_cnt	number of pages in the allocated buffer
+ * @param elem_size	size of each element in the chain
+ * @param intended_use
+ * @param mode
+ */
+static inline void qed_chain_init(struct qed_chain		*p_chain,
+				  void				*p_virt_addr,
+				  dma_addr_t			p_phys_addr,
+				  u16				page_cnt,
+				  u8				elem_size,
+				  enum qed_chain_use_mode	intended_use,
+				  enum qed_chain_mode		mode)
+{
+	/* chain fixed parameters */
+	p_chain->p_virt_addr	= p_virt_addr;
+	p_chain->p_phys_addr	= p_phys_addr;
+	p_chain->elem_size	= elem_size;
+	p_chain->page_cnt	= page_cnt;
+	p_chain->mode		= mode;
+
+	p_chain->intended_use		= intended_use;
+	p_chain->elem_per_page		= ELEMS_PER_PAGE(elem_size);
+	p_chain->usable_per_page =
+		USABLE_ELEMS_PER_PAGE(elem_size, mode);
+	p_chain->capacity		= p_chain->usable_per_page * page_cnt;
+	p_chain->size			= p_chain->elem_per_page * page_cnt;
+	p_chain->elem_per_page_mask	= p_chain->elem_per_page - 1;
+
+	p_chain->elem_unusable = UNUSABLE_ELEMS_PER_PAGE(elem_size, mode);
+
+	p_chain->next_page_mask = (p_chain->usable_per_page &
+				   p_chain->elem_per_page_mask);
+
+	if (mode == QED_CHAIN_MODE_NEXT_PTR) {
+		struct qed_chain_next	*p_next;
+		u16			i;
+
+		for (i = 0; i < page_cnt - 1; i++) {
+			/* Increment mem_phy to the next page. */
+			p_phys_addr += QED_CHAIN_PAGE_SIZE;
+
+			/* Initialize the physical address of the next page. */
+			p_next = (struct qed_chain_next *)((u8 *)p_virt_addr +
+							   elem_size *
+							   p_chain->
+							   usable_per_page);
+
+			p_next->next_phys.lo	= DMA_LO_LE(p_phys_addr);
+			p_next->next_phys.hi	= DMA_HI_LE(p_phys_addr);
+
+			/* Initialize the virtual address of the next page. */
+			p_next->next_virt = (void *)((u8 *)p_virt_addr +
+						     QED_CHAIN_PAGE_SIZE);
+
+			/* Move to the next page. */
+			p_virt_addr = p_next->next_virt;
+		}
+
+		/* Last page's next should point to beginning of the chain */
+		p_next = (struct qed_chain_next *)((u8 *)p_virt_addr +
+						   elem_size *
+						   p_chain->usable_per_page);
+
+		p_next->next_phys.lo	= DMA_LO_LE(p_chain->p_phys_addr);
+		p_next->next_phys.hi	= DMA_HI_LE(p_chain->p_phys_addr);
+		p_next->next_virt	= p_chain->p_virt_addr;
+	}
+	qed_chain_reset(p_chain);
+}
+
+/**
+ * @brief qed_chain_pbl_init - Initalizes a basic pbl chain
+ *        struct
+ * @param p_chain
+ * @param p_virt_addr	virtual address of allocated buffer's beginning
+ * @param p_phys_addr	physical address of allocated buffer's beginning
+ * @param page_cnt	number of pages in the allocated buffer
+ * @param elem_size	size of each element in the chain
+ * @param use_mode
+ * @param p_phys_pbl	pointer to a pre-allocated side table
+ *                      which will hold physical page addresses.
+ * @param p_virt_pbl	pointer to a pre allocated side table
+ *                      which will hold virtual page addresses.
+ */
+static inline void
+qed_chain_pbl_init(struct qed_chain		*p_chain,
+		   void				*p_virt_addr,
+		   dma_addr_t			p_phys_addr,
+		   u16				page_cnt,
+		   u8				elem_size,
+		   enum qed_chain_use_mode	use_mode,
+		   dma_addr_t			p_phys_pbl,
+		   dma_addr_t			*p_virt_pbl)
+{
+	dma_addr_t *p_pbl_dma = p_virt_pbl;
+	int i;
+
+	qed_chain_init(p_chain, p_virt_addr, p_phys_addr, page_cnt,
+		       elem_size, use_mode, QED_CHAIN_MODE_PBL);
+
+	p_chain->pbl.p_phys_table = p_phys_pbl;
+	p_chain->pbl.p_virt_table = p_virt_pbl;
+
+	/* Fill the PBL with physical addresses*/
+	for (i = 0; i < page_cnt; i++) {
+		*p_pbl_dma	= p_phys_addr;
+		p_phys_addr	+= QED_CHAIN_PAGE_SIZE;
+		p_pbl_dma++;
+	}
+}
+
+/**
+ * @brief qed_chain_set_prod - sets the prod to the given
+ *        value
+ *
+ * @param prod_idx
+ * @param p_prod_elem
+ */
+static inline void qed_chain_set_prod(struct qed_chain	*p_chain,
+				      u16		prod_idx,
+				      void		*p_prod_elem)
+{
+	p_chain->prod_idx	= prod_idx;
+	p_chain->p_prod_elem	= p_prod_elem;
+}
+
+/**
+ * @brief qed_chain_get_elem -
+ *
+ * get a pointer to an element represented by absolute idx
+ *
+ * @param p_chain
+ * @assumption p_chain->size is a power of 2
+ *
+ * @return void*, a pointer to next element
+ */
+static inline void *qed_chain_sge_get_elem(struct qed_chain	*p_chain,
+					   u16			idx)
+{
+	void *ret = NULL;
+
+	if (idx >= p_chain->size)
+		return NULL;
+
+	ret = (u8 *)p_chain->p_virt_addr + p_chain->elem_size * idx;
+
+	return ret;
+}
+
+/**
+ * @brief qed_chain_sge_inc_cons_prod
+ *
+ * for sge chains, producer isn't increased serially, the ring
+ * is expected to be full at all times. Once elements are
+ * consumed, they are immediately produced.
+ *
+ * @param p_chain
+ * @param cnt
+ *
+ * @return inline void
+ */
+static inline void
+qed_chain_sge_inc_cons_prod(struct qed_chain	*p_chain,
+			    u16			cnt)
+{
+	p_chain->prod_idx	+= cnt;
+	p_chain->cons_idx	+= cnt;
+}
+
+#endif
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
new file mode 100644
index 0000000..0c40909
--- /dev/null
+++ b/include/linux/qed/qed_if.h
@@ -0,0 +1,497 @@
+/* QLogic qed NIC Driver
+ *
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_IF_H
+#define _QED_IF_H
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/io.h>
+#include <linux/compiler.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/qed/common_hsi.h>
+#include <linux/qed/qed_chain.h>
+
+#define DIRECT_REG_WR(reg_addr, val) writel((u32)val, \
+					    (void __iomem *)(reg_addr))
+
+#define DIRECT_REG_RD(reg_addr) readl((void __iomem *)(reg_addr))
+
+#define QED_COALESCE_MAX 0xFF
+
+/* forward */
+struct qed_dev;
+
+struct qed_eth_pf_params {
+	/* The following parameters are used during HW-init
+	 * and these parameters need to be passed as arguments
+	 * to update_pf_params routine invoked before slowpath start
+	 */
+	u16 num_cons;
+};
+
+struct qed_pf_params {
+	struct qed_eth_pf_params	eth_pf_params;
+};
+
+enum qed_int_mode {
+	QED_INT_MODE_INTA,
+	QED_INT_MODE_MSIX,
+	QED_INT_MODE_MSI,
+	QED_INT_MODE_POLL,
+};
+
+struct qed_sb_info {
+	struct status_block	*sb_virt;
+	dma_addr_t		sb_phys;
+	u32			sb_ack; /* Last given ack */
+	u16			igu_sb_id;
+	void __iomem		*igu_addr;
+	u8			flags;
+#define QED_SB_INFO_INIT        0x1
+#define QED_SB_INFO_SETUP       0x2
+
+	struct qed_dev		*cdev;
+};
+
+struct qed_dev_info {
+	unsigned long	pci_mem_start;
+	unsigned long	pci_mem_end;
+	unsigned int	pci_irq;
+	u8		num_hwfns;
+
+	u8		hw_mac[ETH_ALEN];
+	bool		is_mf;
+
+	/* FW version */
+	u16		fw_major;
+	u16		fw_minor;
+	u16		fw_rev;
+	u16		fw_eng;
+
+	/* MFW version */
+	u32		mfw_rev;
+
+	u32		flash_size;
+	u8		mf_mode;
+};
+
+enum qed_sb_type {
+	QED_SB_TYPE_L2_QUEUE,
+};
+
+enum qed_protocol {
+	QED_PROTOCOL_ETH,
+};
+
+struct qed_link_params {
+	bool	link_up;
+
+#define QED_LINK_OVERRIDE_SPEED_AUTONEG         BIT(0)
+#define QED_LINK_OVERRIDE_SPEED_ADV_SPEEDS      BIT(1)
+#define QED_LINK_OVERRIDE_SPEED_FORCED_SPEED    BIT(2)
+#define QED_LINK_OVERRIDE_PAUSE_CONFIG          BIT(3)
+	u32	override_flags;
+	bool	autoneg;
+	u32	adv_speeds;
+	u32	forced_speed;
+#define QED_LINK_PAUSE_AUTONEG_ENABLE           BIT(0)
+#define QED_LINK_PAUSE_RX_ENABLE                BIT(1)
+#define QED_LINK_PAUSE_TX_ENABLE                BIT(2)
+	u32	pause_config;
+};
+
+struct qed_link_output {
+	bool	link_up;
+
+	u32	supported_caps;         /* In SUPPORTED defs */
+	u32	advertised_caps;        /* In ADVERTISED defs */
+	u32	lp_caps;                /* In ADVERTISED defs */
+	u32	speed;                  /* In Mb/s */
+	u8	duplex;                 /* In DUPLEX defs */
+	u8	port;                   /* In PORT defs */
+	bool	autoneg;
+	u32	pause_config;
+};
+
+#define QED_DRV_VER_STR_SIZE 12
+struct qed_slowpath_params {
+	u32	int_mode;
+	u8	drv_major;
+	u8	drv_minor;
+	u8	drv_rev;
+	u8	drv_eng;
+	u8	name[QED_DRV_VER_STR_SIZE];
+};
+
+#define ILT_PAGE_SIZE_TCFC 0x8000 /* 32KB */
+
+struct qed_int_info {
+	struct msix_entry	*msix;
+	u8			msix_cnt;
+
+	/* This should be updated by the protocol driver */
+	u8			used_cnt;
+};
+
+struct qed_common_cb_ops {
+	void	(*link_update)(void			*dev,
+			       struct qed_link_output	*link);
+};
+
+struct qed_common_ops {
+	struct qed_dev*	(*probe)(struct pci_dev *dev,
+				 enum qed_protocol protocol,
+				 u32 dp_module, u8 dp_level);
+
+	void		(*remove)(struct qed_dev *cdev);
+
+	int		(*set_power_state)(struct qed_dev *cdev,
+					   pci_power_t state);
+
+	void		(*set_id)(struct qed_dev *cdev,
+				  char name[],
+				  char ver_str[]);
+
+	/* Client drivers need to make this call before slowpath_start.
+	 * PF params required for the call before slowpath_start is
+	 * documented within the qed_pf_params structure definition.
+	 */
+	void		(*update_pf_params)(struct qed_dev *cdev,
+					    struct qed_pf_params *params);
+	int		(*slowpath_start)(struct qed_dev *cdev,
+					  struct qed_slowpath_params *params);
+
+	int		(*slowpath_stop)(struct qed_dev *cdev);
+
+	/* Requests to use `cnt' interrupts for fastpath.
+	 * upon success, returns number of interrupts allocated for fastpath.
+	 */
+	int		(*set_fp_int)(struct qed_dev *cdev,
+				      u16 cnt);
+
+	/* Fills `info' with pointers required for utilizing interrupts */
+	int		(*get_fp_int)(struct qed_dev *cdev,
+				      struct qed_int_info *info);
+
+	u32		(*sb_init)(struct qed_dev *cdev,
+				   struct qed_sb_info *sb_info,
+				   void *sb_virt_addr,
+				   dma_addr_t sb_phy_addr,
+				   u16 sb_id,
+				   enum qed_sb_type type);
+
+	u32		(*sb_release)(struct qed_dev *cdev,
+				      struct qed_sb_info *sb_info,
+				      u16 sb_id);
+
+	void		(*simd_handler_config)(struct qed_dev *cdev,
+					       void *token,
+					       int index,
+					       void (*handler)(void *));
+
+	void		(*simd_handler_clean)(struct qed_dev *cdev,
+					      int index);
+/**
+ * @brief set_link - set links according to params
+ *
+ * @param cdev
+ * @param params - values used to override the default link configuration
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int		(*set_link)(struct qed_dev *cdev,
+				    struct qed_link_params *params);
+
+/**
+ * @brief get_link - returns the current link state.
+ *
+ * @param cdev
+ * @param if_link - structure to be filled with current link configuration.
+ */
+	void		(*get_link)(struct qed_dev *cdev,
+				    struct qed_link_output *if_link);
+
+/**
+ * @brief - drains chip in case Tx completions fail to arrive due to pause.
+ *
+ * @param cdev
+ */
+	int		(*drain)(struct qed_dev *cdev);
+
+/**
+ * @brief update_msglvl - update module debug level
+ *
+ * @param cdev
+ * @param dp_module
+ * @param dp_level
+ */
+	void		(*update_msglvl)(struct qed_dev	*cdev,
+					 u32 dp_module,
+					 u8 dp_level);
+
+	int		(*chain_alloc)(struct qed_dev *cdev,
+				       enum qed_chain_use_mode intended_use,
+				       enum qed_chain_mode mode,
+				       u16 num_elems,
+				       size_t elem_size,
+				       struct qed_chain *p_chain);
+
+	void		(*chain_free)(struct qed_dev *cdev,
+				      struct qed_chain *p_chain);
+};
+
+/**
+ * @brief qed_get_protocol_version
+ *
+ * @param protocol
+ *
+ * @return version supported by qed for given protocol driver
+ */
+u32 qed_get_protocol_version(enum qed_protocol protocol);
+
+#define MASK_FIELD(_name, _value) \
+	((_value) &= (_name ## _MASK))
+
+#define FIELD_VALUE(_name, _value) \
+	((_value & _name ## _MASK) << _name ## _SHIFT)
+
+#define SET_FIELD(value, name, flag)			       \
+	do {						       \
+		(value) &= ~(name ## _MASK << name ## _SHIFT); \
+		(value) |= (((u64)flag) << (name ## _SHIFT));  \
+	} while (0)
+
+#define GET_FIELD(value, name) \
+	(((value) >> (name ## _SHIFT)) & name ## _MASK)
+
+/* Debug print definitions */
+#define DP_ERR(cdev, fmt, ...)						     \
+		pr_err("[%s:%d(%s)]" fmt,				     \
+		       __func__, __LINE__,				     \
+		       DP_NAME(cdev) ? DP_NAME(cdev) : "",		     \
+		       ## __VA_ARGS__)					     \
+
+#define DP_NOTICE(cdev, fmt, ...)				      \
+	do {							      \
+		if (unlikely((cdev)->dp_level <= QED_LEVEL_NOTICE)) { \
+			pr_notice("[%s:%d(%s)]" fmt,		      \
+				  __func__, __LINE__,		      \
+				  DP_NAME(cdev) ? DP_NAME(cdev) : "", \
+				  ## __VA_ARGS__);		      \
+								      \
+		}						      \
+	} while (0)
+
+#define DP_INFO(cdev, fmt, ...)					      \
+	do {							      \
+		if (unlikely((cdev)->dp_level <= QED_LEVEL_INFO)) {   \
+			pr_notice("[%s:%d(%s)]" fmt,		      \
+				  __func__, __LINE__,		      \
+				  DP_NAME(cdev) ? DP_NAME(cdev) : "", \
+				  ## __VA_ARGS__);		      \
+		}						      \
+	} while (0)
+
+#define DP_VERBOSE(cdev, module, fmt, ...)				\
+	do {								\
+		if (unlikely(((cdev)->dp_level <= QED_LEVEL_VERBOSE) &&	\
+			     ((cdev)->dp_module & module))) {		\
+			pr_notice("[%s:%d(%s)]" fmt,			\
+				  __func__, __LINE__,			\
+				  DP_NAME(cdev) ? DP_NAME(cdev) : "",	\
+				  ## __VA_ARGS__);			\
+		}							\
+	} while (0)
+
+enum DP_LEVEL {
+	QED_LEVEL_VERBOSE	= 0x0,
+	QED_LEVEL_INFO		= 0x1,
+	QED_LEVEL_NOTICE	= 0x2,
+	QED_LEVEL_ERR		= 0x3,
+};
+
+#define QED_LOG_LEVEL_SHIFT     (30)
+#define QED_LOG_VERBOSE_MASK    (0x3fffffff)
+#define QED_LOG_INFO_MASK       (0x40000000)
+#define QED_LOG_NOTICE_MASK     (0x80000000)
+
+enum DP_MODULE {
+	QED_MSG_SPQ	= 0x10000,
+	QED_MSG_STATS	= 0x20000,
+	QED_MSG_DCB	= 0x40000,
+	QED_MSG_IOV	= 0x80000,
+	QED_MSG_SP	= 0x100000,
+	QED_MSG_STORAGE = 0x200000,
+	QED_MSG_CXT	= 0x800000,
+	QED_MSG_ILT	= 0x2000000,
+	QED_MSG_ROCE	= 0x4000000,
+	QED_MSG_DEBUG	= 0x8000000,
+	/* to be added...up to 0x8000000 */
+};
+
+struct qed_eth_stats {
+	u64	no_buff_discards;
+	u64	packet_too_big_discard;
+	u64	ttl0_discard;
+	u64	rx_ucast_bytes;
+	u64	rx_mcast_bytes;
+	u64	rx_bcast_bytes;
+	u64	rx_ucast_pkts;
+	u64	rx_mcast_pkts;
+	u64	rx_bcast_pkts;
+	u64	mftag_filter_discards;
+	u64	mac_filter_discards;
+	u64	tx_ucast_bytes;
+	u64	tx_mcast_bytes;
+	u64	tx_bcast_bytes;
+	u64	tx_ucast_pkts;
+	u64	tx_mcast_pkts;
+	u64	tx_bcast_pkts;
+	u64	tx_err_drop_pkts;
+	u64	tpa_coalesced_pkts;
+	u64	tpa_coalesced_events;
+	u64	tpa_aborts_num;
+	u64	tpa_not_coalesced_pkts;
+	u64	tpa_coalesced_bytes;
+
+	/* port */
+	u64	rx_64_byte_packets;
+	u64	rx_127_byte_packets;
+	u64	rx_255_byte_packets;
+	u64	rx_511_byte_packets;
+	u64	rx_1023_byte_packets;
+	u64	rx_1518_byte_packets;
+	u64	rx_1522_byte_packets;
+	u64	rx_2047_byte_packets;
+	u64	rx_4095_byte_packets;
+	u64	rx_9216_byte_packets;
+	u64	rx_16383_byte_packets;
+	u64	rx_crc_errors;
+	u64	rx_mac_crtl_frames;
+	u64	rx_pause_frames;
+	u64	rx_pfc_frames;
+	u64	rx_align_errors;
+	u64	rx_carrier_errors;
+	u64	rx_oversize_packets;
+	u64	rx_jabbers;
+	u64	rx_undersize_packets;
+	u64	rx_fragments;
+	u64	tx_64_byte_packets;
+	u64	tx_65_to_127_byte_packets;
+	u64	tx_128_to_255_byte_packets;
+	u64	tx_256_to_511_byte_packets;
+	u64	tx_512_to_1023_byte_packets;
+	u64	tx_1024_to_1518_byte_packets;
+	u64	tx_1519_to_2047_byte_packets;
+	u64	tx_2048_to_4095_byte_packets;
+	u64	tx_4096_to_9216_byte_packets;
+	u64	tx_9217_to_16383_byte_packets;
+	u64	tx_pause_frames;
+	u64	tx_pfc_frames;
+	u64	tx_lpi_entry_count;
+	u64	tx_total_collisions;
+	u64	brb_truncates;
+	u64	brb_discards;
+	u64	rx_mac_bytes;
+	u64	rx_mac_uc_packets;
+	u64	rx_mac_mc_packets;
+	u64	rx_mac_bc_packets;
+	u64	rx_mac_frames_ok;
+	u64	tx_mac_bytes;
+	u64	tx_mac_uc_packets;
+	u64	tx_mac_mc_packets;
+	u64	tx_mac_bc_packets;
+	u64	tx_mac_ctrl_frames;
+};
+
+#define QED_SB_IDX              0x0002
+
+#define RX_PI           0
+#define TX_PI(tc)       (RX_PI + 1 + tc)
+
+static inline u16 qed_sb_update_sb_idx(struct qed_sb_info *sb_info)
+{
+	u32 prod = 0;
+	u16 rc = 0;
+
+	prod = le32_to_cpu(sb_info->sb_virt->prod_index) &
+	       STATUS_BLOCK_PROD_INDEX_MASK;
+	if (sb_info->sb_ack != prod) {
+		sb_info->sb_ack = prod;
+		rc |= QED_SB_IDX;
+	}
+
+	/* Let SB update */
+	mmiowb();
+	return rc;
+}
+
+/**
+ *
+ * @brief This function creates an update command for interrupts that is
+ *        written to the IGU.
+ *
+ * @param sb_info       - This is the structure allocated and
+ *                 initialized per status block. Assumption is
+ *                 that it was initialized using qed_sb_init
+ * @param int_cmd       - Enable/Disable/Nop
+ * @param upd_flg       - whether igu consumer should be
+ *                 updated.
+ *
+ * @return inline void
+ */
+static inline void qed_sb_ack(struct qed_sb_info *sb_info,
+			      enum igu_int_cmd int_cmd,
+			      u8 upd_flg)
+{
+	struct igu_prod_cons_update igu_ack = { 0 };
+
+	igu_ack.sb_id_and_flags =
+		((sb_info->sb_ack << IGU_PROD_CONS_UPDATE_SB_INDEX_SHIFT) |
+		 (upd_flg << IGU_PROD_CONS_UPDATE_UPDATE_FLAG_SHIFT) |
+		 (int_cmd << IGU_PROD_CONS_UPDATE_ENABLE_INT_SHIFT) |
+		 (IGU_SEG_ACCESS_REG <<
+		  IGU_PROD_CONS_UPDATE_SEGMENT_ACCESS_SHIFT));
+
+	DIRECT_REG_WR(sb_info->igu_addr, igu_ack.sb_id_and_flags);
+
+	/* Both segments (interrupts & acks) are written to same place address;
+	 * Need to guarantee all commands will be received (in-order) by HW.
+	 */
+	mmiowb();
+	barrier();
+}
+
+static inline void __internal_ram_wr(void *p_hwfn,
+				     void __iomem *addr,
+				     int size,
+				     u32 *data)
+
+{
+	unsigned int i;
+
+	for (i = 0; i < size / sizeof(*data); i++)
+		DIRECT_REG_WR(&((u32 __iomem *)addr)[i], data[i]);
+}
+
+static inline void internal_ram_wr(void __iomem *addr,
+				   int		size,
+				   u32		*data)
+{
+	__internal_ram_wr(NULL, addr, size, data);
+}
+
+#endif
-- 
1.9.3
