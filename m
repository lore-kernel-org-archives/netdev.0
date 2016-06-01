From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v9 05/22] IB/hns: Add initial profile resource
Date: Wed, 1 Jun 2016 23:37:47 +0800
Message-ID: <1464795484-77395-6-git-send-email-oulijun@huawei.com>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mainly configured some profile resoure. For example,
vendor_id, hardware version, and some data structure sizes so on.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_common.h | 49 +++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_device.h | 55 ++++++++++++++++++++-
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 76 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 38 ++++++++++++++-
 drivers/infiniband/hw/hns/hns_roce_main.c   |  7 +++
 5 files changed, 223 insertions(+), 2 deletions(-)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_common.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
new file mode 100644
index 0000000..4cc4761
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -0,0 +1,49 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _HNS_ROCE_COMMON_H
+#define _HNS_ROCE_COMMON_H
+
+#define roce_read(dev, reg)		readl((dev)->reg_base + (reg))
+
+/*************ROCEE_REG DEFINITION****************/
+#define ROCEE_VENDOR_ID_REG			0x0
+#define ROCEE_VENDOR_PART_ID_REG		0x4
+
+#define ROCEE_HW_VERSION_REG			0x8
+
+#define ROCEE_SYS_IMAGE_GUID_L_REG		0xC
+#define ROCEE_SYS_IMAGE_GUID_H_REG		0x10
+
+#define ROCEE_ACK_DELAY_REG			0x14
+
+#endif /* _HNS_ROCE_COMMON_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 2e18488..5a93670 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -45,6 +45,12 @@
 #define DRV_NAME "hns_roce"
 
 #define HNS_ROCE_MAX_IRQ_NUM			34
+
+#define HNS_ROCE_COMP_VEC_NUM			32
+
+#define HNS_ROCE_AEQE_VEC_NUM			1
+#define HNS_ROCE_AEQE_OF_VEC_NUM		1
+
 #define HNS_ROCE_MAX_PORTS			6
 
 struct hns_roce_ib_iboe {
@@ -53,11 +59,52 @@ struct hns_roce_ib_iboe {
 };
 
 struct hns_roce_caps {
-	u8			num_ports;
+	u64		fw_ver;
+	u8		num_ports;
+	int		gid_table_len[HNS_ROCE_MAX_PORTS];
+	int		pkey_table_len[HNS_ROCE_MAX_PORTS];
+	int		local_ca_ack_delay;
+	int		num_uars;
+	u32		phy_num_uars;
+	u32		max_sq_sg;	/* 2 */
+	u32		max_sq_inline;	/* 32 */
+	u32		max_rq_sg;	/* 2 */
+	int		num_qps;	/* 256k */
+	u32		max_wqes;	/* 16k */
+	u32		max_sq_desc_sz;	/* 64 */
+	u32		max_rq_desc_sz;	/* 64 */
+	int		max_qp_init_rdma;
+	int		max_qp_dest_rdma;
+	int		sqp_start;
+	int		num_cqs;
+	int		max_cqes;
+	int		reserved_cqs;
+	int		num_aeq_vectors;	/* 1 */
+	int		num_comp_vectors;	/* 32 ceq */
+	int		num_other_vectors;
+	int		num_mtpts;
+	u32		num_mtt_segs;
+	int		reserved_mtts;
+	int		reserved_mrws;
+	int		reserved_uars;
+	int		num_pds;
+	int		reserved_pds;
+	u32		mtt_entry_sz;
+	u32		cq_entry_sz;
+	u32		page_size_cap;
+	u32		reserved_lkey;
+	int		mtpt_entry_sz;
+	int		qpc_entry_sz;
+	int		irrl_entry_sz;
+	int		cqc_entry_sz;
+	int		aeqe_depth;
+	int		ceqe_depth[HNS_ROCE_COMP_VEC_NUM];
+	enum ib_mtu	max_mtu;
 };
 
 struct hns_roce_hw {
 	int (*reset)(struct hns_roce_dev *hr_dev, bool enable);
+	void (*hw_profile)(struct hns_roce_dev *hr_dev);
 };
 
 struct hns_roce_dev {
@@ -69,6 +116,12 @@ struct hns_roce_dev {
 	u8 __iomem		*reg_base;
 	struct hns_roce_caps	caps;
 
+	u64                     fw_ver;
+	u64			sys_image_guid;
+	u32                     vendor_id;
+	u32                     vendor_part_id;
+	u32                     hw_rev;
+
 	int			cmd_mod;
 	int			loop_idc;
 	struct hns_roce_hw	*hw;
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 198be3b..ca89e34 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -35,6 +35,7 @@
 #include <linux/of_address.h>
 #include <linux/of_platform.h>
 #include <linux/platform_device.h>
+#include "hns_roce_common.h"
 #include "hns_roce_device.h"
 #include "hns_roce_hw_v1.h"
 
@@ -67,6 +68,81 @@ int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, bool enable)
 		return ret;
 }
 
+void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
+{
+	int i = 0;
+	struct hns_roce_caps *caps = &hr_dev->caps;
+
+	hr_dev->vendor_id = le32_to_cpu(roce_read(hr_dev, ROCEE_VENDOR_ID_REG));
+	hr_dev->vendor_part_id = le32_to_cpu(roce_read(hr_dev,
+					     ROCEE_VENDOR_PART_ID_REG));
+	hr_dev->hw_rev = le32_to_cpu(roce_read(hr_dev, ROCEE_HW_VERSION_REG));
+	hr_dev->fw_ver = 0;
+
+	hr_dev->sys_image_guid = le32_to_cpu(roce_read(hr_dev,
+					     ROCEE_SYS_IMAGE_GUID_L_REG)) |
+				((u64)le32_to_cpu(roce_read(hr_dev,
+					    ROCEE_SYS_IMAGE_GUID_H_REG)) << 32);
+
+	caps->fw_ver		= hr_dev->hw_rev;
+	caps->num_qps		= HNS_ROCE_V1_MAX_QP_NUM;
+	caps->max_wqes		= HNS_ROCE_V1_MAX_WQE_NUM;
+	caps->num_cqs		= HNS_ROCE_V1_MAX_CQ_NUM;
+	caps->max_cqes		= HNS_ROCE_V1_MAX_CQE_NUM;
+	caps->max_sq_sg		= HNS_ROCE_V1_SG_NUM;
+	caps->max_rq_sg		= HNS_ROCE_V1_SG_NUM;
+	caps->max_sq_inline	= HNS_ROCE_V1_INLINE_SIZE;
+	caps->num_uars		= HNS_ROCE_V1_UAR_NUM;
+	caps->phy_num_uars	= HNS_ROCE_V1_PHY_UAR_NUM;
+	caps->num_aeq_vectors	= HNS_ROCE_AEQE_VEC_NUM;
+	caps->num_comp_vectors	= HNS_ROCE_COMP_VEC_NUM;
+	caps->num_other_vectors	= HNS_ROCE_AEQE_OF_VEC_NUM;
+	caps->num_mtpts		= HNS_ROCE_V1_MAX_MTPT_NUM;
+	caps->num_mtt_segs	= HNS_ROCE_V1_MAX_MTT_SEGS;
+	caps->num_pds		= HNS_ROCE_V1_MAX_PD_NUM;
+	caps->max_qp_init_rdma	= HNS_ROCE_V1_MAX_QP_INIT_RDMA;
+	caps->max_qp_dest_rdma	= HNS_ROCE_V1_MAX_QP_DEST_RDMA;
+	caps->max_sq_desc_sz	= HNS_ROCE_V1_MAX_SQ_DESC_SZ;
+	caps->max_rq_desc_sz	= HNS_ROCE_V1_MAX_RQ_DESC_SZ;
+	caps->qpc_entry_sz	= HNS_ROCE_V1_QPC_ENTRY_SIZE;
+	caps->irrl_entry_sz	= HNS_ROCE_V1_IRRL_ENTRY_SIZE;
+	caps->cqc_entry_sz	= HNS_ROCE_V1_CQC_ENTRY_SIZE;
+	caps->mtpt_entry_sz	= HNS_ROCE_V1_MTPT_ENTRY_SIZE;
+	caps->mtt_entry_sz	= HNS_ROCE_V1_MTT_ENTRY_SIZE;
+	caps->cq_entry_sz	= HNS_ROCE_V1_CQE_ENTRY_SIZE;
+	caps->page_size_cap	= HNS_ROCE_V1_PAGE_SIZE_SUPPORT;
+	caps->sqp_start		= 0;
+	caps->reserved_lkey	= 0;
+	caps->reserved_pds	= 0;
+	caps->reserved_mrws	= 1;
+	caps->reserved_mtts	= 0;
+	caps->reserved_uars	= 0;
+	caps->reserved_cqs	= 0;
+
+	for (i = 0; i < caps->num_ports; i++)
+		caps->pkey_table_len[i] = 1;
+
+	for (i = 0; i < caps->num_ports; i++) {
+		/* Six ports shared 16 GID in v1 engine */
+		if (i >= (HNS_ROCE_V1_GID_NUM % caps->num_ports))
+			caps->gid_table_len[i] = HNS_ROCE_V1_GID_NUM /
+						 caps->num_ports;
+		else
+			caps->gid_table_len[i] = HNS_ROCE_V1_GID_NUM /
+						 caps->num_ports + 1;
+	}
+
+	for (i = 0; i < caps->num_comp_vectors; i++)
+		caps->ceqe_depth[i] = HNS_ROCE_V1_NUM_COMP_EQE;
+
+	caps->aeqe_depth = HNS_ROCE_V1_NUM_ASYNC_EQE;
+	caps->local_ca_ack_delay = le32_to_cpu(roce_read(hr_dev,
+							 ROCEE_ACK_DELAY_REG));
+
+	caps->max_mtu = IB_MTU_2048;
+}
+
 struct hns_roce_hw hns_roce_hw_v1 = {
 	.reset = hns_roce_v1_reset,
+	.hw_profile = hns_roce_v1_profile,
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index ca69d0b..9c5491e 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -33,7 +33,43 @@
 #ifndef _HNS_ROCE_HW_V1_H
 #define _HNS_ROCE_HW_V1_H
 
-#define SLEEP_TIME_INTERVAL		20
+#define HNS_ROCE_V1_MAX_PD_NUM				0x8000
+#define HNS_ROCE_V1_MAX_CQ_NUM				0x10000
+#define HNS_ROCE_V1_MAX_CQE_NUM				0x8000
+
+#define HNS_ROCE_V1_MAX_QP_NUM				0x40000
+#define HNS_ROCE_V1_MAX_WQE_NUM				0x4000
+
+#define HNS_ROCE_V1_MAX_MTPT_NUM			0x80000
+
+#define HNS_ROCE_V1_MAX_MTT_SEGS			0x100000
+
+#define HNS_ROCE_V1_MAX_QP_INIT_RDMA			128
+#define HNS_ROCE_V1_MAX_QP_DEST_RDMA			128
+
+#define HNS_ROCE_V1_MAX_SQ_DESC_SZ			64
+#define HNS_ROCE_V1_MAX_RQ_DESC_SZ			64
+#define HNS_ROCE_V1_SG_NUM				2
+#define HNS_ROCE_V1_INLINE_SIZE				32
+
+#define HNS_ROCE_V1_UAR_NUM				256
+#define HNS_ROCE_V1_PHY_UAR_NUM				8
+
+#define HNS_ROCE_V1_GID_NUM				16
+
+#define HNS_ROCE_V1_NUM_COMP_EQE			0x8000
+#define	HNS_ROCE_V1_NUM_ASYNC_EQE			0x400
+
+#define HNS_ROCE_V1_QPC_ENTRY_SIZE			256
+#define HNS_ROCE_V1_IRRL_ENTRY_SIZE			8
+#define HNS_ROCE_V1_CQC_ENTRY_SIZE			64
+#define HNS_ROCE_V1_MTPT_ENTRY_SIZE			64
+#define HNS_ROCE_V1_MTT_ENTRY_SIZE			64
+
+#define HNS_ROCE_V1_CQE_ENTRY_SIZE			32
+#define HNS_ROCE_V1_PAGE_SIZE_SUPPORT			0xFFFFF000
+
+#define SLEEP_TIME_INTERVAL				20
 
 extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable);
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index c9afcb8..705c01d 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -122,6 +122,11 @@ int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, bool enable)
 	return hr_dev->hw->reset(hr_dev, enable);
 }
 
+void hns_roce_profile_init(struct hns_roce_dev *hr_dev)
+{
+	hr_dev->hw->hw_profile(hr_dev);
+}
+
 /**
 * hns_roce_probe - RoCE driver entrance
 * @pdev: pointer to platform device
@@ -166,6 +171,8 @@ static int hns_roce_probe(struct platform_device *pdev)
 		goto error_failed_get_cfg;
 	}
 
+	hns_roce_profile_init(hr_dev);
+
 error_failed_get_cfg:
 	ib_dealloc_device(&hr_dev->ib_dev);
 
-- 
1.9.1
