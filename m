From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v5 05/21] IB/hns: Add initial profile resource
Date: Sat, 23 Apr 2016 18:26:43 +0800
Message-ID: <1461407219-72027-6-git-send-email-oulijun@huawei.com>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461407219-72027-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch mainly configured some profile resoure. for exmaple,
vendor_id, hardware version, and some data structure sizes so on.

Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_common.h | 25 +++++++++
 drivers/infiniband/hw/hns/hns_roce_device.h | 56 ++++++++++++++++++++-
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 78 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 36 +++++++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |  9 ++++
 5 files changed, 203 insertions(+), 1 deletion(-)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_common.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
new file mode 100644
index 0000000..0f90214
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -0,0 +1,25 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_COMMON_H
+#define _HNS_ROCE_COMMON_H
+
+/*************ROCEE_REG DEFINITION****************/
+
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
index 24ac1a8..e3e59d0 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -24,17 +24,65 @@
 #define HNS_ROCE_MAX_IRQ_NUM			34
 #define HNS_ROCE_MAX_PORTS			6
 
+#define HNS_ROCE_COMP_VEC_NUM			32
+
+#define HNS_ROCE_AEQE_VEC_NUM			1
+#define HNS_ROCE_AEQE_OF_VEC_NUM		1
+
+#define ADDR_SHIFT_32				32
+
 struct hns_roce_ib_iboe {
 	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
 	u8			phy_port[HNS_ROCE_MAX_PORTS];
 };
 
 struct hns_roce_caps {
-	u8			num_ports;
+	u64	fw_ver;
+	u8	num_ports;
+	int	gid_table_len[HNS_ROCE_MAX_PORTS];
+	int	pkey_table_len[HNS_ROCE_MAX_PORTS];
+	int	local_ca_ack_delay;
+	int	num_uars;
+	u32	phy_num_uars;
+	u32	max_sq_sg;	/* 2 */
+	u32	max_sq_inline;	/* 32 */
+	u32	max_rq_sg;	/* 2 */
+	int	num_qps;	/* 256k */
+	u32	max_wqes;	/* 16k */
+	u32	max_sq_desc_sz;	/* 64 */
+	u32	max_rq_desc_sz;	/* 64 */
+	int	max_qp_init_rdma;
+	int	max_qp_dest_rdma;
+	int	sqp_start;
+	int	num_cqs;
+	int	max_cqes;
+	int	reserved_cqs;
+	int	num_aeq_vectors;	/* 1 */
+	int	num_comp_vectors;	/* 32 ceq */
+	int	num_other_vectors;
+	int	num_mtpts;
+	u32	num_mtt_segs;
+	int	reserved_mtts;
+	int	reserved_mrws;
+	int	reserved_uars;
+	int	num_pds;
+	int	reserved_pds;
+	u32	mtt_entry_sz;
+	u32	cq_entry_sz;
+	u32	page_size_cap;
+	u32	reserved_lkey;
+	int	mtpt_entry_sz;
+	int	qpc_entry_sz;
+	int	irrl_entry_sz;
+	int	cqc_entry_sz;
+	int	aeqe_depth;
+	int	ceqe_depth[HNS_ROCE_COMP_VEC_NUM];
+	enum ib_mtu	max_mtu;
 };
 
 struct hns_roce_hw {
 	int (*reset)(struct hns_roce_dev *hr_dev, u32 val);
+	void (*hw_profile)(struct hns_roce_dev *hr_dev);
 };
 
 struct hns_roce_dev {
@@ -46,6 +94,12 @@ struct hns_roce_dev {
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
index ea39e56..54831bf 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -17,6 +17,7 @@
 #include <linux/of_address.h>
 #include <linux/of_platform.h>
 #include <linux/platform_device.h>
+#include "hns_roce_common.h"
 #include "hns_roce_device.h"
 #include "hns_roce_hw_v1.h"
 
@@ -49,6 +50,83 @@ int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, u32 val)
 		return ret;
 }
 
+void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
+{
+	int i = 0;
+	struct hns_roce_caps *caps = &hr_dev->caps;
+
+	hr_dev->vendor_id = le32_to_cpu(roce_readl((hr_dev->reg_base +
+			    ROCEE_VENDOR_ID_REG)));
+	hr_dev->vendor_part_id = le32_to_cpu(roce_readl((hr_dev->reg_base +
+				 ROCEE_VENDOR_PART_ID_REG)));
+	hr_dev->hw_rev = le32_to_cpu(roce_readl((hr_dev->reg_base +
+			 ROCEE_HW_VERSION_REG)));
+	hr_dev->fw_ver = 0;
+
+	hr_dev->sys_image_guid = le32_to_cpu(roce_readl(hr_dev->reg_base +
+					     ROCEE_SYS_IMAGE_GUID_L_REG)) |
+				((u64)le32_to_cpu(roce_readl(hr_dev->reg_base +
+					     ROCEE_SYS_IMAGE_GUID_H_REG)) <<
+					     ADDR_SHIFT_32);
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
+	caps->local_ca_ack_delay = le32_to_cpu(roce_readl((hr_dev->reg_base +
+				   ROCEE_ACK_DELAY_REG)));
+	caps->max_mtu = IB_MTU_2048;
+}
+
 struct hns_roce_hw hns_roce_hw_v1 = {
 	.reset = hns_roce_v1_reset,
+	.hw_profile = hns_roce_v1_profile,
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index 164041d..6468386 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -10,6 +10,42 @@
 #ifndef _HNS_ROCE_HW_V1_H
 #define _HNS_ROCE_HW_V1_H
 
+#define HNS_ROCE_V1_MAX_PD_NUM			0x8000
+#define HNS_ROCE_V1_MAX_CQ_NUM			0x10000
+#define HNS_ROCE_V1_MAX_CQE_NUM			0x8000
+
+#define HNS_ROCE_V1_MAX_QP_NUM			0x40000
+#define HNS_ROCE_V1_MAX_WQE_NUM			0x4000
+
+#define HNS_ROCE_V1_MAX_MTPT_NUM		0x80000
+
+#define HNS_ROCE_V1_MAX_MTT_SEGS		0x100000
+
+#define HNS_ROCE_V1_MAX_QP_INIT_RDMA		128
+#define HNS_ROCE_V1_MAX_QP_DEST_RDMA		128
+
+#define HNS_ROCE_V1_MAX_SQ_DESC_SZ		64
+#define HNS_ROCE_V1_MAX_RQ_DESC_SZ		64
+#define HNS_ROCE_V1_SG_NUM			2
+#define HNS_ROCE_V1_INLINE_SIZE			32
+
+#define HNS_ROCE_V1_UAR_NUM			256
+#define HNS_ROCE_V1_PHY_UAR_NUM			8
+
+#define HNS_ROCE_V1_GID_NUM			16
+
+#define HNS_ROCE_V1_NUM_COMP_EQE		0x8000
+#define	HNS_ROCE_V1_NUM_ASYNC_EQE		0x400
+
+#define HNS_ROCE_V1_QPC_ENTRY_SIZE		256
+#define HNS_ROCE_V1_IRRL_ENTRY_SIZE		8
+#define HNS_ROCE_V1_CQC_ENTRY_SIZE		64
+#define HNS_ROCE_V1_MTPT_ENTRY_SIZE		64
+#define HNS_ROCE_V1_MTT_ENTRY_SIZE		64
+
+#define HNS_ROCE_V1_CQE_ENTRY_SIZE		32
+#define HNS_ROCE_V1_PAGE_SIZE_SUPPORT		0xFFFFF000
+
 #define SLEEP_TIME_INTERVAL		20
 
 extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, u32 val);
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index df3116f..05cbc4e 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -104,6 +104,12 @@ int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, u32 val)
 {
 	return hr_dev->hw->reset(hr_dev, val);
 }
+
+void hns_roce_profile_init(struct hns_roce_dev *hr_dev)
+{
+	hr_dev->hw->hw_profile(hr_dev);
+}
+
 /**
 * hns_roce_probe - RoCE driver entrance
 * @pdev: pointer to platform device
@@ -149,6 +155,8 @@ static int hns_roce_probe(struct platform_device *pdev)
 		goto error_failed_get_cfg;
 	}
 
+	hns_roce_profile_init(hr_dev);
+
 error_failed_get_cfg:
 	ib_dealloc_device(&hr_dev->ib_dev);
 	return ret;
@@ -166,6 +174,7 @@ static int hns_roce_remove(struct platform_device *pdev)
 	ret = hns_roce_engine_reset(hr_dev, 0);
 	if (ret)
 		return ret;
+
 	ib_dealloc_device(&hr_dev->ib_dev);
 
 	return ret;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
