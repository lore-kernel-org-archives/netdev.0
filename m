From: "Wei Hu(Xavier)" <xavier.huwei@huawei.com>
Subject: [PATCH 3/4] infiniband: hns: add Hisilicon RoCE support(driver code)
Date: Fri, 4 Mar 2016 16:41:16 +0800
Message-ID: <1457080877-13456-4-git-send-email-xavier.huwei@huawei.com>
References: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<lisheng011@huawei.com>, <charles.chenxin@huawei.com>,
	<linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver for Hisilicon RoCE is a platform driver.
The driver will support mulitple versions of hardware. Currently only "v1"
for hip06 SOC is supported.
The driver includes two parts: common driver and hardware-specific
operations. hns_roce_v1_hw.c and hns_roce_v1_hw.h are files for
hardware-specific operations only for v1 engine, and other files(.c and .h)
for common algorithm and common hardware operations.

Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Znlong <zhaonenglong@huawei.com>
Signed-off-by: oulijun <oulijun@huawei.com>
---
 drivers/infiniband/hw/Makefile                     |    1 +
 drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
 drivers/infiniband/hw/hisilicon/hns/Makefile       |    9 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c  |  114 +
 .../infiniband/hw/hisilicon/hns/hns_roce_alloc.c   |  256 ++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c |  370 +++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h |  173 ++
 .../infiniband/hw/hisilicon/hns/hns_roce_common.h  |  704 +++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c  |  481 +++
 .../infiniband/hw/hisilicon/hns/hns_roce_device.h  |  870 ++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c  |  835 ++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h  |  138 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c |  637 ++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h |  130 +
 .../infiniband/hw/hisilicon/hns/hns_roce_main.c    | 1147 +++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c  |  671 +++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c  |  130 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c  |  945 ++++++
 .../infiniband/hw/hisilicon/hns/hns_roce_user.h    |   31 +
 .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 3146 ++++++++++++++++++++
 .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   | 1071 +++++++
 21 files changed, 11869 insertions(+)
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/Kconfig
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/Makefile
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h

diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index aded2a5..ddbbf715 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -7,3 +7,4 @@ obj-$(CONFIG_MLX5_INFINIBAND)		+= mlx5/
 obj-$(CONFIG_INFINIBAND_NES)		+= nes/
 obj-$(CONFIG_INFINIBAND_OCRDMA)		+= ocrdma/
 obj-$(CONFIG_INFINIBAND_USNIC)		+= usnic/
+obj-$(CONFIG_INFINIBAND_HISILICON_HNS) 	+= hisilicon/hns/
diff --git a/drivers/infiniband/hw/hisilicon/hns/Kconfig b/drivers/infiniband/hw/hisilicon/hns/Kconfig
new file mode 100644
index 0000000..e253db9
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/Kconfig
@@ -0,0 +1,10 @@
+config INFINIBAND_HISILICON_HNS
+	tristate "Hisilicon Hns ROCE Driver"
+	depends on NET_VENDOR_HISILICON
+	depends on HNS && HNS_DSAF && HNS_ENET
+	---help---
+	  This is a ROCE/RDMA driver for the Hisilicon RoCE engine. The engine
+	  is used in Hisilicon Hi1610 and more further ICT SoC.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called roce.
diff --git a/drivers/infiniband/hw/hisilicon/hns/Makefile b/drivers/infiniband/hw/hisilicon/hns/Makefile
new file mode 100644
index 0000000..bdf58ce
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for the HISILICON RoCE drivers.
+#
+
+obj-$(CONFIG_INFINIBAND_HISILICON_HNS) += roce.o
+roce-objs := hns_roce_main.o hns_roce_cmd.o hns_roce_eq.o hns_roce_pd.o \
+	hns_roce_ah.o hns_roce_icm.o hns_roce_mr.o hns_roce_qp.o \
+	hns_roce_cq.o hns_roce_alloc.o hns_roce_v1_hw.o
+
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
new file mode 100644
index 0000000..9b7784c
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
@@ -0,0 +1,114 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/inet.h>
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <rdma/ib_addr.h>
+#include <rdma/ib_cache.h>
+
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+
+#define HNS_ROCE_PORT_NUM_SHIFT		24
+#define HNS_ROCE_VLAN_SL_BIT_MASK	7
+#define HNS_ROCE_VLAN_SL_SHIFT		13
+
+struct ib_ah *hns_roce_create_ah(
+					struct ib_pd *ibpd,
+					struct ib_ah_attr *ah_attr)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibpd->device);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct ib_gid_attr gid_attr;
+	struct hns_roce_ah *ah;
+	u16 vlan_tag = 0xffff;
+	struct in6_addr in6;
+	union ib_gid sgid;
+	int ret;
+
+	ah = kzalloc(sizeof(*ah), GFP_ATOMIC);
+	if (!ah)
+		return ERR_PTR(-ENOMEM);
+
+	/* Get mac address */
+	memcpy(&in6, ah_attr->grh.dgid.raw, sizeof(in6));
+	if (rdma_is_multicast_addr(&in6))
+		rdma_get_mcast_mac(&in6, ah->av.mac);
+	else
+		memcpy(ah->av.mac, ah_attr->dmac, sizeof(ah_attr->dmac));
+
+	/* Get source gid */
+	ret = ib_get_cached_gid(ibpd->device, ah_attr->port_num,
+			ah_attr->grh.sgid_index, &sgid, &gid_attr);
+	if (ret) {
+		dev_err(dev, "get sgid failed! ret = %d\n", ret);
+		kfree(ah);
+		return ERR_PTR(ret);
+	}
+
+	if (gid_attr.ndev) {
+		if (is_vlan_dev(gid_attr.ndev))
+			vlan_tag = vlan_dev_vlan_id(gid_attr.ndev);
+		dev_put(gid_attr.ndev);
+	}
+
+	if (vlan_tag < 0x1000)
+		vlan_tag |= (ah_attr->sl & HNS_ROCE_VLAN_SL_BIT_MASK) <<
+				HNS_ROCE_VLAN_SL_SHIFT;
+
+	ah->av.port_pd = cpu_to_be32(to_hr_pd(ibpd)->pdn
+		| (ah_attr->port_num << HNS_ROCE_PORT_NUM_SHIFT));
+	ah->av.gid_index = ah_attr->grh.sgid_index;
+	ah->av.vlan = cpu_to_le16(vlan_tag);
+	dev_dbg(dev, "gid_index = 0x%x,vlan = 0x%x\n",
+		ah->av.gid_index, ah->av.vlan);
+
+	if (ah_attr->static_rate)
+		ah->av.stat_rate = IB_RATE_10_GBPS;
+
+	memcpy(ah->av.dgid, ah_attr->grh.dgid.raw, HNS_ROCE_GID_SIZE);
+	ah->av.sl_tclass_flowlabel =
+		cpu_to_le32(ah_attr->sl << HNS_ROCE_SL_SHIFT);
+
+	return &ah->ibah;
+}
+
+int hns_roce_query_ah(struct ib_ah *ibah, struct ib_ah_attr *ah_attr)
+{
+	struct hns_roce_ah *ah = to_hr_ah(ibah);
+
+	memset(ah_attr, 0, sizeof(*ah_attr));
+
+	ah_attr->sl = le32_to_cpu(ah->av.sl_tclass_flowlabel) >>
+			HNS_ROCE_SL_SHIFT;
+	ah_attr->port_num = le32_to_cpu(ah->av.port_pd) >>
+				HNS_ROCE_PORT_NUM_SHIFT;
+	ah_attr->dlid = 0;
+	ah_attr->static_rate = ah->av.stat_rate;
+
+	ah_attr->ah_flags = IB_AH_GRH;
+	ah_attr->grh.traffic_class = le32_to_cpu(ah->av.sl_tclass_flowlabel) >>
+					HNS_ROCE_TCLASS_SHIFT;
+	ah_attr->grh.flow_label = le32_to_cpu(ah->av.sl_tclass_flowlabel) &
+					HNS_ROCE_FLOW_LABLE_MASK;
+	ah_attr->grh.hop_limit  = ah->av.hop_limit;
+	ah_attr->grh.sgid_index = ah->av.gid_index;
+	memcpy(ah_attr->grh.dgid.raw, ah->av.dgid, HNS_ROCE_GID_SIZE);
+
+	return 0;
+}
+
+int hns_roce_destroy_ah(struct ib_ah *ah)
+{
+	kfree(to_hr_ah(ah));
+	return 0;
+}
+
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c
new file mode 100644
index 0000000..31a1ba4
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c
@@ -0,0 +1,256 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/bitmap.h>
+#include <linux/dma-mapping.h>
+#include <linux/errno.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+
+#include "hns_roce_device.h"
+
+u32 hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap)
+{
+	u32 obj;
+
+	spin_lock(&bitmap->lock);
+
+	obj = find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
+	if (obj >= bitmap->max) {
+		bitmap->top = (bitmap->top + bitmap->max +
+				bitmap->reserved_top) & bitmap->mask;
+		obj = find_first_zero_bit(bitmap->table, bitmap->max);
+	}
+
+	if (obj < bitmap->max) {
+		set_bit(obj, bitmap->table);
+		bitmap->last = (obj + 1);
+		if (bitmap->last == bitmap->max)
+			bitmap->last = 0;
+		obj |= bitmap->top;
+	} else {
+		obj = -1;
+	}
+
+	spin_unlock(&bitmap->lock);
+
+	return obj;
+}
+
+void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, u32 obj)
+{
+	hns_roce_bitmap_free_range(bitmap, obj, 1);
+}
+
+u32 hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap,
+					int cnt, int align)
+{
+	u32 obj, i;
+
+	if (likely(cnt == 1 && align == 1))
+		return hns_roce_bitmap_alloc(bitmap);
+
+	spin_lock(&bitmap->lock);
+
+	obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
+				bitmap->last, cnt, align - 1);
+	if (obj >= bitmap->max) {
+		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
+				& bitmap->mask;
+		obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
+						0, cnt, align - 1);
+	}
+
+	if (obj < bitmap->max) {
+		for (i = 0; i < cnt; i++)
+			set_bit(obj + i, bitmap->table);
+
+		if (obj == bitmap->last) {
+			bitmap->last = (obj + cnt);
+			if (bitmap->last >= bitmap->max)
+				bitmap->last = 0;
+		}
+		obj |= bitmap->top;
+	} else {
+		obj = -1;
+	}
+
+	spin_unlock(&bitmap->lock);
+
+	return obj;
+}
+
+void hns_roce_bitmap_free_range(
+					struct hns_roce_bitmap *bitmap,
+					u32 obj,
+					int cnt)
+{
+	u32 i;
+
+	obj &= bitmap->max + bitmap->reserved_top - 1;
+
+	spin_lock(&bitmap->lock);
+	for (i = 0; i < cnt; i++)
+		clear_bit(obj + i, bitmap->table);
+
+	bitmap->last = min(bitmap->last, obj);
+	bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
+			& bitmap->mask;
+	spin_unlock(&bitmap->lock);
+}
+
+int hns_roce_bitmap_init(
+				struct hns_roce_bitmap *bitmap, u32 num,
+				u32 mask, u32 reserved_bot,
+				u32 reserved_top)
+{
+	int i;
+
+	if (num != roundup_pow_of_two(num))
+		return -EINVAL;
+
+	bitmap->last = 0;
+	bitmap->top  = 0;
+	bitmap->max  = num - reserved_top;
+	bitmap->mask = mask;
+	bitmap->reserved_top = reserved_top;
+	spin_lock_init(&bitmap->lock);
+	bitmap->table =
+		kzalloc(BITS_TO_LONGS(bitmap->max) * sizeof(long), GFP_KERNEL);
+	if (!bitmap->table)
+		return -ENOMEM;
+
+	for (i = 0; i < reserved_bot; ++i)
+		set_bit(i, bitmap->table);
+
+	return 0;
+}
+
+void hns_roce_bitmap_cleanup(struct hns_roce_bitmap *bitmap)
+{
+	kfree(bitmap->table);
+}
+
+void hns_roce_buf_free(
+			struct hns_roce_dev *hr_dev,
+			int size, struct hns_roce_buf *buf)
+{
+	int i;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	if (buf->nbufs == 1) {
+		dma_free_coherent(dev, size, buf->direct.buf,
+				  buf->direct.map);
+	} else {
+		if (BITS_PER_LONG == 64)
+			vunmap(buf->direct.buf);
+
+		for (i = 0; i < buf->nbufs; ++i)
+			if (buf->page_list[i].buf)
+				dma_free_coherent(&hr_dev->pdev->dev,
+						PAGE_SIZE,
+						buf->page_list[i].buf,
+						buf->page_list[i].map);
+		kfree(buf->page_list);
+	}
+}
+
+int hns_roce_buf_alloc(
+			struct hns_roce_dev *hr_dev,
+			int size, int max_direct,
+			struct hns_roce_buf *buf)
+{
+	int i = 0;
+	dma_addr_t t;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* SQ/RQ buf lease than one page, SQ + RQ = 8K */
+	if (size <= max_direct) {
+		buf->nbufs      = 1;
+		/* Npages calculated by page_size */
+		buf->npages     = 1 << get_order(size);
+		buf->page_shift = PAGE_SHIFT;
+		/* MTT PA must be recorded in 4k alignment, t is 4k aligned */
+		buf->direct.buf = dma_alloc_coherent(
+						dev, size, &t,
+						GFP_KERNEL);
+		if (!buf->direct.buf)
+			return -ENOMEM;
+
+		buf->direct.map = t;
+
+		while (t & ((1UL << buf->page_shift) - 1)) {
+			--buf->page_shift;
+			buf->npages *= 2;
+		}
+
+		memset(buf->direct.buf, 0, size);
+	} else {
+		buf->nbufs       = (size + PAGE_SIZE - 1) / PAGE_SIZE;
+		buf->npages      = buf->nbufs;
+		buf->page_shift  = PAGE_SHIFT;
+		buf->page_list   =
+			kzalloc(buf->nbufs * sizeof(*buf->page_list),
+				GFP_KERNEL);
+
+		if (!buf->page_list)
+			return -ENOMEM;
+
+		for (i = 0; i < buf->nbufs; ++i) {
+			buf->page_list[i].buf =
+				dma_alloc_coherent(
+						dev, PAGE_SIZE, &t,
+						GFP_KERNEL);
+
+			if (!buf->page_list[i].buf)
+				goto err_free;
+
+			buf->page_list[i].map = t;
+			memset(buf->page_list[i].buf, 0, PAGE_SIZE);
+		}
+
+		if (BITS_PER_LONG == 64) {
+			struct page **pages;
+
+			pages =
+				kmalloc(sizeof(*pages) * buf->nbufs,
+					GFP_KERNEL);
+			if (!pages)
+				goto err_free;
+
+			for (i = 0; i < buf->nbufs; ++i)
+				pages[i] = virt_to_page(buf->page_list[i].buf);
+
+			buf->direct.buf = vmap(
+						pages, buf->nbufs, VM_MAP,
+						PAGE_KERNEL);
+			kfree(pages);
+			if (!buf->direct.buf)
+				goto err_free;
+		}
+	}
+
+	return 0;
+
+err_free:
+	hns_roce_buf_free(hr_dev, size, buf);
+
+	return -ENOMEM;
+}
+
+void hns_roce_cleanup_bitmap(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_cleanup_qp_table(hr_dev);
+	hns_roce_cleanup_cq_table(hr_dev);
+	hns_roce_cleanup_mr_table(hr_dev);
+	hns_roce_cleanup_pd_table(hr_dev);
+	hns_roce_cleanup_uar_table(hr_dev);
+}
+
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c
new file mode 100644
index 0000000..3989bce
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c
@@ -0,0 +1,370 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/dma-mapping.h>
+#include <linux/dmapool.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/list.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+#include "hns_roce_eq.h"
+
+#define CMD_POLL_TOKEN		0xffff
+#define CMD_MAX_NUM		32
+#define STATUS_MASK		0xff
+
+enum {
+	HCR_IN_PARAM_OFFSET	= 0x00,
+	HCR_OUT_PARAM_OFFSET	= 0x08,
+	HCR_IN_MODIFIER_OFFSET	= 0x10,
+	HCR_TOKEN_OFFSET	= 0x14,
+	HCR_STATUS_OFFSET	= 0x18,
+	HCR_GO_BIT		= 15,
+};
+
+enum {
+	GO_BIT_TIMEOUT_MSECS	= 10000
+};
+
+static int hns_roce_status_to_errno(u8 orig_status)
+{
+	if (orig_status == HNS_ROCE_CMD_SUCCESS)
+		return 0;
+	else
+		return -EIO;
+}
+
+static int cmd_pending(struct hns_roce_dev *hr_dev)
+{
+	u32 status = roce_readl(hr_dev->cmd.hcr + HCR_TOKEN_OFFSET);
+
+	return (!!(status & (1 << HCR_GO_BIT)));
+}
+
+static int hns_roce_cmd_post(
+				struct hns_roce_dev *hr_dev,
+				u64 in_param, u64 out_param,
+				u32 in_modifier, u8 op_modifier,
+				u16 op, u16 token, int event)
+{
+	struct hns_roce_cmdq *cmd = &hr_dev->cmd;
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 __iomem *hcr = cmd->hcr;
+	int ret = -EAGAIN;
+	unsigned long end;
+	u32 val = 0;
+
+	mutex_lock(&cmd->hcr_mutex);
+
+	end = msecs_to_jiffies(GO_BIT_TIMEOUT_MSECS) + jiffies;
+	while (cmd_pending(hr_dev)) {
+		if (time_after(jiffies, end)) {
+			dev_dbg(dev,
+				"jiffies=%d end=%d\n", (int)jiffies, (int)end);
+			goto out;
+		}
+		cond_resched();
+	}
+
+	roce_set_field(val,
+		ROCEE_MB6_ROCEE_MB_CMD_M,
+		ROCEE_MB6_ROCEE_MB_CMD_S,
+		op);
+	roce_set_field(val,
+		ROCEE_MB6_ROCEE_MB_CMD_MDF_M,
+		ROCEE_MB6_ROCEE_MB_CMD_MDF_S,
+		op_modifier);
+	roce_set_bit(val, ROCEE_MB6_ROCEE_MB_EVENT_S, event);
+	roce_set_bit(val, ROCEE_MB6_ROCEE_MB_HW_RUN_S, 1);
+	roce_set_field(val,
+		ROCEE_MB6_ROCEE_MB_TOKEN_M,
+		ROCEE_MB6_ROCEE_MB_TOKEN_S,
+		token);
+
+	__raw_writeq(cpu_to_le64(in_param),  hcr + 0);
+	__raw_writeq(cpu_to_le64(out_param), hcr + 2);
+	__raw_writel(cpu_to_le32(in_modifier), hcr + 4);
+	/* Memory barrier */
+	wmb();
+
+	__raw_writel(cpu_to_le32(val), hcr + 5);
+
+	mmiowb();
+	ret = 0;
+
+out:
+	mutex_unlock(&cmd->hcr_mutex);
+	return ret;
+}
+
+static int hns_roce_cmd_poll(
+				struct hns_roce_dev *hr_dev,
+				u64 in_param, u64 *out_param,
+				int out_is_imm, u32 in_modifier,
+				u8 op_modifier, u16 op,
+				unsigned long timeout)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	void __iomem *hcr = hr_dev->cmd.hcr;
+	unsigned long end = 0;
+	u32 status = 0;
+	int ret;
+
+	down(&hr_dev->cmd.poll_sem);
+
+	ret = hns_roce_cmd_post(hr_dev, in_param,
+				out_param ? *out_param : 0,
+				in_modifier, op_modifier,
+				op, CMD_POLL_TOKEN, 0);
+	if (ret) {
+		dev_err(dev, "[cmd_poll]hns_roce_cmd_post failed\n");
+		goto out;
+	}
+
+	end = msecs_to_jiffies(timeout) + jiffies;
+	while (cmd_pending(hr_dev) && time_before(jiffies, end))
+		cond_resched();
+
+	if (cmd_pending(hr_dev)) {
+		dev_err(dev, "[cmd_poll]hw run cmd TIMEDOUT!\n");
+		ret = -ETIMEDOUT;
+		goto out;
+	}
+
+	if (out_is_imm)
+		*out_param =
+			(u64) le32_to_cpu((__force __be32)
+				__raw_readl(hcr + HCR_OUT_PARAM_OFFSET)) << 32 |
+			(u64) le32_to_cpu((__force __be32)
+				__raw_readl(hcr + HCR_OUT_PARAM_OFFSET + 4));
+
+	status = le32_to_cpu((__force __be32)
+				__raw_readl(hcr + HCR_STATUS_OFFSET));
+	if ((status & STATUS_MASK) != 0x1) {
+		dev_err(dev, "mailbox status 0x%x!\n", status);
+		ret = -EBUSY;
+		goto out;
+	}
+
+out:
+	up(&hr_dev->cmd.poll_sem);
+
+	return ret;
+}
+
+void hns_roce_cmd_event(
+				struct hns_roce_dev *hr_dev,
+				u16 token, u8 status,
+				u64 out_param)
+{
+	struct hns_roce_cmd_context *context =
+		&hr_dev->cmd.context[token & hr_dev->cmd.token_mask];
+
+	if (token != context->token)
+		return;
+
+	context->result    = hns_roce_status_to_errno(status);
+	context->out_param = out_param;
+	complete(&context->done);
+}
+
+static int hns_roce_cmd_wait(
+				struct hns_roce_dev *hr_dev,
+				u64 in_param,
+				u64 *out_param,
+				int out_is_imm,
+				u32 in_modifier,
+				u8 op_modifier,
+				u16 op,
+				unsigned long timeout)
+{
+	struct hns_roce_cmdq *cmd = &hr_dev->cmd;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_cmd_context *context;
+	int ret = 0;
+
+	down(&cmd->event_sem);
+
+	spin_lock(&cmd->context_lock);
+	BUG_ON(cmd->free_head < 0);
+	context = &cmd->context[cmd->free_head];
+	context->token += cmd->token_mask + 1;
+	cmd->free_head = context->next;
+	spin_unlock(&cmd->context_lock);
+
+	init_completion(&context->done);
+
+	hns_roce_cmd_post(
+			hr_dev, in_param, out_param ? *out_param : 0,
+			in_modifier, op_modifier, op, context->token, 1);
+
+	/*
+	* It is timeout when wait_for_completion_timeout return 0
+	* The return value is the time limit set in advance
+	* how many seconds showing
+	*/
+	if (!wait_for_completion_timeout(&context->done,
+				msecs_to_jiffies(timeout))) {
+		dev_err(dev, "[cmd]wait_for_completion_timeout timeout\n");
+		ret = -EBUSY;
+		goto out;
+	}
+
+	ret = context->result;
+	if (ret) {
+		dev_err(dev,
+			"[cmd]event mod cmd process error!err=%d\n", ret);
+		goto out;
+	}
+
+	if (out_is_imm)
+		*out_param = context->out_param;
+
+out:
+	spin_lock(&cmd->context_lock);
+	context->next = cmd->free_head;
+	cmd->free_head = context - cmd->context;
+	spin_unlock(&cmd->context_lock);
+
+	up(&cmd->event_sem);
+
+	return ret;
+}
+
+int __hns_roce_cmd(
+			struct hns_roce_dev *hr_dev,
+			u64 in_param, u64 *out_param,
+			int out_is_imm, u32 in_modifier,
+			u8 op_modifier, u16 op,
+			unsigned long timeout)
+{
+	if (hr_dev->cmd.use_events)
+		return hns_roce_cmd_wait(hr_dev, in_param, out_param,
+					out_is_imm, in_modifier,
+					op_modifier, op, timeout);
+	else
+		return hns_roce_cmd_poll(hr_dev, in_param, out_param,
+					out_is_imm, in_modifier,
+					op_modifier, op, timeout);
+}
+
+int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+
+	mutex_init(&hr_dev->cmd.hcr_mutex);
+	sema_init(&hr_dev->cmd.poll_sem, 1);
+	hr_dev->cmd.use_events = 0;
+	hr_dev->cmd.toggle     = 1;
+	hr_dev->cmd.max_cmds = CMD_MAX_NUM;
+	hr_dev->cmd.hcr = hr_dev->reg_base + ROCEE_MB1_REG;
+
+	hr_dev->cmd.pool = dma_pool_create("hns_roce_cmd", dev,
+					 HNS_ROCE_MAILBOX_SIZE,
+					 HNS_ROCE_MAILBOX_SIZE,
+					 0);
+	if (!hr_dev->cmd.pool) {
+		dev_err(dev, "Couldn't create mailbox pool for cmd.\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+void hns_roce_cmd_cleanup(struct hns_roce_dev *hr_dev)
+{
+	dma_pool_destroy(hr_dev->cmd.pool);
+}
+
+int hns_roce_cmd_use_events(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_cmdq *hr_cmd = &hr_dev->cmd;
+	int i;
+
+	hr_cmd->context = kmalloc(hr_cmd->max_cmds *
+				   sizeof(struct hns_roce_cmd_context),
+				   GFP_KERNEL);
+	if (!hr_cmd->context)
+		return -ENOMEM;
+
+	for (i = 0; i < hr_cmd->max_cmds; ++i) {
+		hr_cmd->context[i].token = i;
+		hr_cmd->context[i].next  = i + 1;
+	}
+
+	hr_cmd->context[hr_cmd->max_cmds - 1].next = -1;
+	hr_cmd->free_head = 0;
+
+	sema_init(&hr_cmd->event_sem, hr_cmd->max_cmds);
+	spin_lock_init(&hr_cmd->context_lock);
+
+	for (hr_cmd->token_mask = 1;
+	     hr_cmd->token_mask < hr_cmd->max_cmds;
+	     hr_cmd->token_mask <<= 1)
+		;
+	--hr_cmd->token_mask;
+
+	hr_cmd->use_events = 1;
+
+	down(&hr_cmd->poll_sem);
+
+	return 0;
+}
+
+void hns_roce_cmd_use_polling(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_cmdq *hr_cmd = &hr_dev->cmd;
+	int i;
+
+	hr_cmd->use_events = 0;
+
+	for (i = 0; i < hr_cmd->max_cmds; ++i)
+		down(&hr_cmd->event_sem);
+
+	kfree(hr_cmd->context);
+	up(&hr_cmd->poll_sem);
+}
+
+struct hns_roce_cmd_mailbox *hns_roce_alloc_cmd_mailbox(
+					struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_cmd_mailbox *mailbox;
+
+	mailbox = kmalloc(sizeof(*mailbox), GFP_KERNEL);
+	if (!mailbox)
+		return ERR_PTR(-ENOMEM);
+
+	mailbox->buf = dma_pool_alloc(
+					hr_dev->cmd.pool, GFP_KERNEL,
+					&mailbox->dma);
+	if (!mailbox->buf) {
+		kfree(mailbox);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	return mailbox;
+}
+
+void hns_roce_free_cmd_mailbox(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_cmd_mailbox *mailbox)
+{
+	if (!mailbox)
+		return;
+
+	dma_pool_free(hr_dev->cmd.pool, mailbox->buf, mailbox->dma);
+	kfree(mailbox);
+}
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h b/drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h
new file mode 100644
index 0000000..15011f8
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h
@@ -0,0 +1,173 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_CMD_H
+#define _HNS_ROCE_CMD_H
+
+#include <linux/dma-mapping.h>
+
+enum {
+	/* Initialization and general commands */
+	HNS_ROCE_CMD_SYS_EN		= 0x1,
+	HNS_ROCE_CMD_SYS_DIS		= 0x2,
+	HNS_ROCE_CMD_MAP_FA		= 0xfff,
+	HNS_ROCE_CMD_UNMAP_FA		= 0xffe,
+	HNS_ROCE_CMD_RUN_FW		= 0xff6,
+	HNS_ROCE_CMD_MOD_STAT_CFG	= 0x34,
+	HNS_ROCE_CMD_QUERY_DEV_CAP	= 0x3,
+	HNS_ROCE_CMD_QUERY_FW		= 0x4,
+	HNS_ROCE_CMD_ENABLE_LAM		= 0xff8,
+	HNS_ROCE_CMD_DISABLE_LAM	= 0xff7,
+	HNS_ROCE_CMD_QUERY_DDR		= 0x5,
+	HNS_ROCE_CMD_QUERY_ADAPTER	= 0x6,
+	HNS_ROCE_CMD_INIT_HCA		= 0x7,
+	HNS_ROCE_CMD_CLOSE_HCA		= 0x8,
+	HNS_ROCE_CMD_INIT_PORT		= 0x9,
+	HNS_ROCE_CMD_CLOSE_PORT		= 0xa,
+	HNS_ROCE_CMD_QUERY_HCA		= 0xb,
+	HNS_ROCE_CMD_QUERY_PORT		= 0x43,
+	HNS_ROCE_CMD_SENSE_PORT		= 0x4d,
+	HNS_ROCE_CMD_SET_PORT		= 0xc,
+	HNS_ROCE_CMD_ACCESS_DDR		= 0x2e,
+	HNS_ROCE_CMD_MAP_ICM		= 0xffa,
+	HNS_ROCE_CMD_UNMAP_ICM		= 0xff9,
+	HNS_ROCE_CMD_MAP_ICM_AUX	= 0xffc,
+	HNS_ROCE_CMD_UNMAP_ICM_AUX	= 0xffb,
+	HNS_ROCE_CMD_SET_ICM_SIZE	= 0xffd,
+
+	/* TPT commands */
+	HNS_ROCE_CMD_SW2HW_MPT		= 0xd,
+	HNS_ROCE_CMD_QUERY_MPT		= 0xe,
+	HNS_ROCE_CMD_HW2SW_MPT		= 0xf,
+	HNS_ROCE_CMD_READ_MTT		= 0x10,
+	HNS_ROCE_CMD_WRITE_MTT		= 0x11,
+	HNS_ROCE_CMD_SYNC_TPT		= 0x2f,
+
+	/* EQ commands */
+	HNS_ROCE_CMD_MAP_EQ		= 0x12,
+	HNS_ROCE_CMD_SW2HW_EQ		= 0x13,
+	HNS_ROCE_CMD_HW2SW_EQ		= 0x14,
+	HNS_ROCE_CMD_QUERY_EQ		= 0x15,
+
+	/* CQ commands */
+	HNS_ROCE_CMD_SW2HW_CQ		= 0x16,
+	HNS_ROCE_CMD_HW2SW_CQ		= 0x17,
+	HNS_ROCE_CMD_QUERY_CQ		= 0x18,
+	HNS_ROCE_CMD_MODIFY_CQ		= 0x2c,
+
+	/* SRQ commands */
+	HNS_ROCE_CMD_SW2HW_SRQ		= 0x35,
+	HNS_ROCE_CMD_HW2SW_SRQ		= 0x36,
+	HNS_ROCE_CMD_QUERY_SRQ		= 0x37,
+	HNS_ROCE_CMD_ARM_SRQ		= 0x40,
+
+	/* QP/EE commands */
+	HNS_ROCE_CMD_RST2INIT_QP	= 0x19,
+	HNS_ROCE_CMD_INIT2RTR_QP	= 0x1a,
+	HNS_ROCE_CMD_RTR2RTS_QP		= 0x1b,
+	HNS_ROCE_CMD_RTS2RTS_QP		= 0x1c,
+	HNS_ROCE_CMD_SQERR2RTS_QP	= 0x1d,
+	HNS_ROCE_CMD_2ERR_QP		= 0x1e,
+	HNS_ROCE_CMD_RTS2SQD_QP		= 0x1f,
+	HNS_ROCE_CMD_SQD2SQD_QP		= 0x38,
+	HNS_ROCE_CMD_SQD2RTS_QP		= 0x20,
+	HNS_ROCE_CMD_2RST_QP		= 0x21,
+	HNS_ROCE_CMD_QUERY_QP		= 0x22,
+	HNS_ROCE_CMD_INIT2INIT_QP	= 0x2d,
+	HNS_ROCE_CMD_SUSPEND_QP		= 0x32,
+	HNS_ROCE_CMD_UNSUSPEND_QP	= 0x33,
+
+	/* Special QP and management commands */
+	HNS_ROCE_CMD_CONF_SPECIAL_QP	= 0x23,
+	HNS_ROCE_CMD_MAD_IFC		= 0x24,
+
+	/* Multicast commands */
+	HNS_ROCE_CMD_READ_MCG		= 0x25,
+	HNS_ROCE_CMD_WRITE_MCG		= 0x26,
+	HNS_ROCE_CMD_MGID_HASH		= 0x27,
+
+	/* Miscellaneous commands */
+	HNS_ROCE_CMD_DIAG_RPRT		= 0x30,
+	HNS_ROCE_CMD_NOP		= 0x31,
+
+	/* Debug commands */
+	HNS_ROCE_CMD_QUERY_DEBUG_MSG	= 0x2a,
+	HNS_ROCE_CMD_SET_DEBUG_MSG	= 0x2b,
+};
+
+enum {
+	HNS_ROCE_CMD_TIME_CLASS_A	= 10000,
+	HNS_ROCE_CMD_TIME_CLASS_B	= 10000,
+	HNS_ROCE_CMD_TIME_CLASS_C	= 10000,
+};
+
+enum {
+	HNS_ROCE_MAILBOX_SIZE		=  4096
+};
+
+struct hns_roce_cmd_mailbox {
+	void		       *buf;
+	dma_addr_t		dma;
+};
+
+int __hns_roce_cmd(
+			struct hns_roce_dev *hr_dev, u64 in_param,
+			u64 *out_param, int out_is_imm,
+			u32 in_modifier, u8 op_modifier,
+			u16 op, unsigned long timeout);
+
+/* Invoke a command with no output parameter */
+static inline int hns_roce_cmd(
+				struct hns_roce_dev *hr_dev,
+				u64 in_param, u32 in_modifier,
+				u8 op_modifier, u16 op,
+				unsigned long timeout)
+{
+	return __hns_roce_cmd(
+			hr_dev, in_param, NULL, 0,
+			in_modifier, op_modifier,
+			op, timeout);
+}
+
+/* Invoke a command with an output mailbox */
+static inline int hns_roce_cmd_box(
+				struct hns_roce_dev *hr_dev,
+				u64 in_param, u64 out_param,
+				u32 in_modifier, u8 op_modifier,
+				u16 op, unsigned long timeout)
+{
+	return __hns_roce_cmd(
+			hr_dev, in_param, &out_param, 0,
+			in_modifier, op_modifier,
+			op, timeout);
+}
+
+/*
+ * Invoke a command with an immediate output parameter (and copy the
+ * output into the caller's out_param pointer after the command
+ * executes).
+ */
+static inline int hns_roce_cmd_imm(
+					struct hns_roce_dev *hr_dev,
+					u64 in_param, u64 *out_param,
+					u32 in_modifier, u8 op_modifier,
+					u16 op, unsigned long timeout)
+{
+	return __hns_roce_cmd(
+			hr_dev, in_param, out_param, 1, in_modifier,
+			op_modifier, op, timeout);
+}
+
+struct hns_roce_cmd_mailbox *hns_roce_alloc_cmd_mailbox(
+				struct hns_roce_dev *hr_dev);
+void hns_roce_free_cmd_mailbox(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_cmd_mailbox *mailbox);
+
+#endif /* _HNS_ROCE_CMD_H */
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h b/drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h
new file mode 100644
index 0000000..55a1843
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h
@@ -0,0 +1,704 @@
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
+#ifndef assert
+#define assert(cond)
+#endif
+
+#define roce_writel(value, addr)     writel((value), (addr))
+#define roce_readl(addr)            readl((addr))
+#define roce_raw_write(value, addr) \
+	__raw_writel((__force u32)cpu_to_le32(value), (addr))
+
+#define roce_get_field(origin, mask, shift) \
+	(((origin) & (mask)) >> (shift))
+
+#define roce_get_bit(origin, shift) \
+	roce_get_field((origin), (1ul << (shift)), (shift))
+
+#define roce_set_field(origin, mask, shift, val) \
+	do { \
+		(origin) &= (~(mask)); \
+		(origin) |= (((val) << (shift)) & (mask)); \
+	} while (0)
+
+#define roce_set_bit(origin, shift, val) \
+	roce_set_field((origin), (1ul << (shift)), (shift), (val))
+
+#define ROCEE_GLB_CFG_ROCEE_DB_SQ_MODE_S 3
+
+#define ROCEE_GLB_CFG_ROCEE_DB_OTH_MODE_S 4
+
+#define ROCEE_GLB_CFG_SQ_EXT_DB_MODE_S 5
+
+#define ROCEE_GLB_CFG_OTH_EXT_DB_MODE_S 6
+
+#define ROCEE_GLB_CFG_ROCEE_PORT_ST_S 10
+#define ROCEE_GLB_CFG_ROCEE_PORT_ST_M  \
+	(((1UL << 6) - 1) << ROCEE_GLB_CFG_ROCEE_PORT_ST_S)
+
+#define ROCEE_GLB_CFG_TRP_RAQ_DROP_EN_S 16
+
+#define ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S 0
+#define ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_M  \
+	(((1UL << 24) - 1) << ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S)
+
+#define ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S 24
+#define ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_M  \
+	(((1UL << 4) - 1) << ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S)
+
+#define ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S 0
+#define ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_M   \
+	(((1UL << 24) - 1) << ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S)
+
+#define ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S 24
+#define ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_M   \
+	(((1UL << 4) - 1) << ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S)
+
+#define ROCEE_CAEP_CEQ_AEQ_WL_CAEP_AEQ_WL_S 0
+#define ROCEE_CAEP_CEQ_AEQ_WL_CAEP_AEQ_WL_M   \
+	(((1UL << 16) - 1) << ROCEE_CAEP_CEQ_AEQ_WL_CAEP_AEQ_WL_S)
+
+#define ROCEE_CAEP_CEQ_AEQ_WL_CAEP_CEQ_WL_S 16
+#define ROCEE_CAEP_CEQ_AEQ_WL_CAEP_CEQ_WL_M   \
+	(((1UL << 16) - 1) << ROCEE_CAEP_CEQ_AEQ_WL_CAEP_CEQ_WL_S)
+
+#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S 0
+#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_M   \
+	(((1UL << 16) - 1) << ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S)
+
+#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S 16
+#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_M   \
+	(((1UL << 16) - 1) << ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S)
+
+#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S 0
+#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_M   \
+	(((1UL << 16) - 1) << ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S)
+
+#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S 16
+#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_M   \
+	(((1UL << 16) - 1) << ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S)
+
+#define ROCEE_RAQ_WL_ROCEE_RAQ_WL_S 0
+#define ROCEE_RAQ_WL_ROCEE_RAQ_WL_M   \
+	(((1UL << 8) - 1) << ROCEE_RAQ_WL_ROCEE_RAQ_WL_S)
+
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S 0
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_M   \
+	(((1UL << 15) - 1) << \
+	ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S)
+
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S 16
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_M   \
+	(((1UL << 4) - 1) << \
+	ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S)
+
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_EN_S 20
+
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_EXT_RAQ_MODE 21
+
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S 0
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S)
+
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S 5
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S)
+
+#define ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S 0
+#define ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S)
+
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S 5
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S)
+
+#define ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S 0
+#define ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S)
+
+#define ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S 8
+#define ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S)
+
+#define ROCEE_CAEP_CE_BURST_NUM_CFG_CAEP_CE_BURST_NUM_CFG_S 0
+#define ROCEE_CAEP_CE_BURST_NUM_CFG_CAEP_CE_BURST_NUM_CFG_M   \
+	(((1UL << 16) - 1) << \
+	ROCEE_CAEP_CE_BURST_NUM_CFG_CAEP_CE_BURST_NUM_CFG_S)
+
+#define ROCEE_CAEP_CE_BURST_NUM_CFG_CAEP_CE_INTERVAL_MIN_S 16
+#define ROCEE_CAEP_CE_BURST_NUM_CFG_CAEP_CE_INTERVAL_MIN_M   \
+	(((1UL << 16) - 1) << \
+	ROCEE_CAEP_CE_BURST_NUM_CFG_CAEP_CE_INTERVAL_MIN_S)
+
+#define ROCEE_TSP_RR_CFG_ROCEE_TSP_SL_SP_WEIGTH_S 0
+#define ROCEE_TSP_RR_CFG_ROCEE_TSP_SL_SP_WEIGTH_M   \
+	(((1UL << 16) - 1) << \
+	ROCEE_TSP_RR_CFG_ROCEE_TSP_SL_SP_WEIGTH_S)
+
+#define ROCEE_TSP_RR_CFG_ROCEE_TSP_SL_SP_PORT_S 16
+#define ROCEE_TSP_RR_CFG_ROCEE_TSP_SL_SP_PORT_M   \
+	(((1UL << 4) - 1) << ROCEE_TSP_RR_CFG_ROCEE_TSP_SL_SP_PORT_S)
+
+#define ROCEE_TSP_RR_CFG_ROCEE_TSP_SL_SP_EN_S 20
+
+#define ROCEE_TSP_RR_CFG_ROCEE_TSP_WA_SP_PORT_S 21
+#define ROCEE_TSP_RR_CFG_ROCEE_TSP_WA_SP_PORT_M   \
+	(((1UL << 2) - 1) << ROCEE_TSP_RR_CFG_ROCEE_TSP_WA_SP_PORT_S)
+
+#define ROCEE_TSP_RR_CFG_ROCEE_TSP_WA_SP_EN_S 23
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S 0
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M   \
+	(((1UL << 19) - 1) << ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S)
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_S 19
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S 20
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M   \
+	(((1UL << 2) - 1) << ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S)
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_S 22
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_M   \
+	(((1UL << 5) - 1) << ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_S)
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_HW_SYNS_S 31
+
+#define ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_S 0
+#define ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_M   \
+	(((1UL << 3) - 1) << ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_S)
+
+#define ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_S 0
+#define ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_M   \
+	(((1UL << 15) - 1) << ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_S)
+
+#define ROCEE_MB6_ROCEE_MB_CMD_S 0
+#define ROCEE_MB6_ROCEE_MB_CMD_M   \
+	(((1UL << 8) - 1) << ROCEE_MB6_ROCEE_MB_CMD_S)
+
+#define ROCEE_MB6_ROCEE_MB_CMD_MDF_S 8
+#define ROCEE_MB6_ROCEE_MB_CMD_MDF_M   \
+	(((1UL << 4) - 1) << ROCEE_MB6_ROCEE_MB_CMD_MDF_S)
+
+#define ROCEE_MB6_ROCEE_MB_EVENT_S 14
+
+#define ROCEE_MB6_ROCEE_MB_HW_RUN_S 15
+
+#define ROCEE_MB6_ROCEE_MB_TOKEN_S 16
+#define ROCEE_MB6_ROCEE_MB_TOKEN_M   \
+	(((1UL << 16) - 1) << ROCEE_MB6_ROCEE_MB_TOKEN_S)
+
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_S 0
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_M   \
+	(((1UL << 24) - 1) << ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_S)
+
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_S 24
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_M   \
+	(((1UL << 4) - 1) << ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_S)
+
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S 28
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_M   \
+	(((1UL << 3) - 1) << ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S)
+
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S 31
+
+#define ROCEE_SMAC_H_ROCEE_SMAC_H_S 0
+#define ROCEE_SMAC_H_ROCEE_SMAC_H_M   \
+	(((1UL << 16) - 1) << ROCEE_SMAC_H_ROCEE_SMAC_H_S)
+
+#define ROCEE_SMAC_H_ROCEE_PORT_MTU_S 16
+#define ROCEE_SMAC_H_ROCEE_PORT_MTU_M   \
+	(((1UL << 4) - 1) << ROCEE_SMAC_H_ROCEE_PORT_MTU_S)
+
+#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S 0
+#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M   \
+	(((1UL << 2) - 1) << \
+	ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S)
+
+#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_S 8
+#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_M   \
+	(((1UL << 4) - 1) << \
+	ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_S)
+
+#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AE_IRQ_PEND_S 16
+
+#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQ_ALM_OVF_INT_ST_S 17
+
+#define ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_S 0
+#define ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_M   \
+	(((1UL << 5) - 1) << ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_S)
+
+#define ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_S 16
+#define ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_M   \
+	(((1UL << 16) - 1) << \
+	ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_S)
+
+#define ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_S 0
+#define ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_M   \
+	(((1UL << 16) - 1) << \
+	ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_S)
+
+#define ROCEE_CAEP_CEQC_SHIFT_CAEP_CEQC_CEQE_SHIFT_S 8
+#define ROCEE_CAEP_CEQC_SHIFT_CAEP_CEQC_CEQE_SHIFT_M   \
+	(((1UL << 4) - 1) << ROCEE_CAEP_CEQC_SHIFT_CAEP_CEQC_CEQE_SHIFT_S)
+
+#define ROCEE_CAEP_CEQC_SHIFT_CAEP_CEQ_ALM_OVF_INT_ST_S 16
+
+#define ROCEE_CAEP_CEQC_SHIFT_CAEP_CE_IRQ_ST_S 30
+
+#define ROCEE_CAEP_CEQC_CUR_IDX_CAEP_CEQE_CUR_IDX_S 16
+#define ROCEE_CAEP_CEQC_CUR_IDX_CAEP_CEQE_CUR_IDX_M   \
+	(((1UL << 16) - 1) << \
+	ROCEE_CAEP_CEQC_CUR_IDX_CAEP_CEQE_CUR_IDX_S)
+
+#define ROCEE_CAEP_CEQC_CONS_IDX_CAEP_CEQE_CONS_IDX_S 0
+#define ROCEE_CAEP_CEQC_CONS_IDX_CAEP_CEQE_CONS_IDX_M   \
+	(((1UL << 16) - 1) << \
+	ROCEE_CAEP_CEQC_CONS_IDX_CAEP_CEQE_CONS_IDX_S)
+
+#define ROCEE_CAEP_CE_IRQ_MASK_CAEP_CE_IRQ_MASK_S 0
+
+#define ROCEE_CAEP_CE_IRQ_MASK_CAEP_CEQ_ALM_OVF_MASK_S 1
+
+#define ROCEE_CAEP_CEQ_ALM_OVF_CAEP_CEQ_ALM_OVF_S 0
+
+#define ROCEE_CAEP_AE_MASK_CAEP_AEQ_ALM_OVF_MASK_S 0
+
+#define ROCEE_CAEP_AE_MASK_CAEP_AE_IRQ_MASK_S 1
+
+#define ROCEE_CAEP_AE_ST_CAEP_AEQ_ALM_OVF_S 0
+
+#define ROCEE_CAEP_AE_ST_CAEP_AE_IRQ_ST_S 1
+
+#define ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_CNT_S 0
+#define ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_CNT_M   \
+	(((1UL << 16) - 1) << ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_CNT_S)
+
+#define ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_TYPE_S 16
+#define ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_TYPE_M   \
+	(((1UL << 6) - 1) << ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_TYPE_S)
+
+#define ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_EN_S 22
+#define ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_EN_M   \
+	(((1UL << 6) - 1) << ROCEE_TRP_RX_DROP_CFG_TRP_RX_DROP_EN_S)
+
+#define ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_S 0
+#define ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_M   \
+	(((1UL << 28) - 1) << ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_S)
+
+#define ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S 0
+#define ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M   \
+	(((1UL << 28) - 1) << ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S)
+
+#define ROCEE_DB_SQ_ST_ROCEE_DB_SQ_ALM_OVF_S 0
+
+#define ROCEE_DB_SQ_ST_ROCEE_DB_SQ_OV_S 1
+
+#define ROCEE_DB_SQ_ST_ROCEE_DB_SQ_ALM_EMPTY_S 2
+
+#define ROCEE_DB_OTHERS_ST_ROCEE_DB_OTH_ALM_OVF_S 0
+
+#define ROCEE_DB_OTHERS_ST_ROCEE_DB_OTH_OV_S 1
+
+#define ROCEE_DB_OTHERS_ST_ROCEE_DB_OTH_ALM_EMPTY_S 2
+
+#define ROCEE_EXT_DB_ALM_SQ_BRESP_ERR_ST_S 0
+#define ROCEE_EXT_DB_ALM_SQ_BRESP_ERR_ST_M   \
+	(((1UL << 3) - 1) << ROCEE_EXT_DB_ALM_SQ_BRESP_ERR_ST_S)
+
+#define ROCEE_EXT_DB_ALM_SQ_RRESP_ERR_ST_S 3
+#define ROCEE_EXT_DB_ALM_SQ_RRESP_ERR_ST_M   \
+	(((1UL << 3) - 1) << ROCEE_EXT_DB_ALM_SQ_RRESP_ERR_ST_S)
+
+#define ROCEE_EXT_DB_ALM_SQ_CMD_XOFF_S 6
+
+#define ROCEE_EXT_DB_ALM_OTH_BRESP_ERR_ST_S 8
+#define ROCEE_EXT_DB_ALM_OTH_BRESP_ERR_ST_M   \
+	(((1UL << 3) - 1) << ROCEE_EXT_DB_ALM_OTH_BRESP_ERR_ST_S)
+
+#define ROCEE_EXT_DB_ALM_OTH_RRESP_ERR_ST_S 11
+#define ROCEE_EXT_DB_ALM_OTH_RRESP_ERR_ST_M   \
+	(((1UL << 3) - 1) << ROCEE_EXT_DB_ALM_OTH_RRESP_ERR_ST_S)
+
+#define ROCEE_EXT_DB_ALM_OTH_CMD_XOFF_S 14
+
+#define ROCEE_EXT_DB_ALM_RAQ_BRESP_ERR_ST_S 16
+#define ROCEE_EXT_DB_ALM_RAQ_BRESP_ERR_ST_M   \
+	(((1UL << 3) - 1) << ROCEE_EXT_DB_ALM_RAQ_BRESP_ERR_ST_S)
+
+#define ROCEE_EXT_DB_ALM_RAQ_RRESP_ERR_ST_S 19
+#define ROCEE_EXT_DB_ALM_RAQ_RRESP_ERR_ST_M   \
+	(((1UL << 3) - 1) << ROCEE_EXT_DB_ALM_RAQ_RRESP_ERR_ST_S)
+
+#define ROCEE_CQ_MAX_ROCEE_CQ_MAX_S 0
+#define ROCEE_CQ_MAX_ROCEE_CQ_MAX_M   \
+	(((1UL << 16) - 1) << ROCEE_CQ_MAX_ROCEE_CQ_MAX_S)
+
+#define ROCEE_CQ_MAX_ROCEE_CQ_MAX_VLD_S 31
+
+#define ROCEE_MR_MAX_ROCEE_MR_MAX_S 0
+#define ROCEE_MR_MAX_ROCEE_MR_MAX_M   \
+	(((1UL << 24) - 1) << ROCEE_MR_MAX_ROCEE_MR_MAX_S)
+
+#define ROCEE_MR_MAX_ROCEE_MR_MAX_VLD_S 31
+
+#define ROCEE_QP_MAX_ROCEE_QP_MAX_S 0
+#define ROCEE_QP_MAX_ROCEE_QP_MAX_M   \
+	(((1UL << 24) - 1) << ROCEE_QP_MAX_ROCEE_QP_MAX_S)
+
+#define ROCEE_SDB_INV_CNT_SDB_INV_CNT_S 0
+#define ROCEE_SDB_INV_CNT_SDB_INV_CNT_M   \
+	(((1UL << 16) - 1) << ROCEE_SDB_INV_CNT_SDB_INV_CNT_S)
+
+#define ROCEE_QMM_CACHE_CLR_QPC_CACHE_UNCLR_S 0
+
+#define ROCEE_QMM_CACHE_CLR_MTPT_CACHE_UNCLR_S 1
+
+#define ROCEE_QMM_CACHE_CLR_CQC_CACHE_UNCLR_S 2
+
+#define ROCEE_QMM_CACHE_REFRESH_QPC_CACHE_REFRESH_S 0
+
+#define ROCEE_QMM_CACHE_REPLACE_QPC_CACHE_REPLACE_S 0
+
+#define AM_CTRL_GLOBAL_CTRL_LAT_STAT_RD_EN_S 1
+#define AM_CTRL_GLOBAL_CTRL_LAT_STAT_WR_EN_S 2
+
+#define AM_CTRL_LATENCY_SEL_CTRL_LAT_RD_PORT_SEL_S 0
+#define AM_CTRL_LATENCY_SEL_CTRL_LAT_RD_PORT_SEL_M   \
+	(((1UL << 4) - 1) << \
+	AM_CTRL_LATENCY_SEL_CTRL_LAT_RD_PORT_SEL_S)
+
+#define AM_CTRL_LATENCY_SEL_CTRL_LAT_WR_PORT_SEL_S 8
+#define AM_CTRL_LATENCY_SEL_CTRL_LAT_WR_PORT_SEL_M   \
+	(((1UL << 4) - 1) << \
+	AM_CTRL_LATENCY_SEL_CTRL_LAT_WR_PORT_SEL_S)
+
+#define AM_CFG_MAX_TRANS_CFG_MAX_RD_TRANS_S 0
+#define AM_CFG_MAX_TRANS_CFG_MAX_RD_TRANS_M   \
+	(((1UL << 7) - 1) << AM_CFG_MAX_TRANS_CFG_MAX_RD_TRANS_S)
+
+#define AM_CFG_MAX_TRANS_CFG_MAX_WR_TRANS_S 8
+#define AM_CFG_MAX_TRANS_CFG_MAX_WR_TRANS_M   \
+	(((1UL << 7) - 1) << AM_CFG_MAX_TRANS_CFG_MAX_WR_TRANS_S)
+
+#define AM_CFG_SINGLE_PORT_MAX_TRANS_CFG_MAX_SGL_PORT_RD_TRANS_S 0
+#define AM_CFG_SINGLE_PORT_MAX_TRANS_CFG_MAX_SGL_PORT_RD_TRANS_M   \
+	(((1UL << 7) - 1) << \
+	AM_CFG_SINGLE_PORT_MAX_TRANS_CFG_MAX_SGL_PORT_RD_TRANS_S)
+
+#define AM_CFG_SINGLE_PORT_MAX_TRANS_CFG_MAX_SGL_PORT_WR_TRANS_S 8
+#define AM_CFG_SINGLE_PORT_MAX_TRANS_CFG_MAX_SGL_PORT_WR_TRANS_M   \
+	(((1UL << 7) - 1) << \
+	AM_CFG_SINGLE_PORT_MAX_TRANS_CFG_MAX_SGL_PORT_WR_TRANS_S)
+
+#define AM_CURR_PORT_STS_CURR_RD_PORT_STS_S 0
+#define AM_CURR_PORT_STS_CURR_RD_PORT_STS_M   \
+	(((1UL << 16) - 1) << AM_CURR_PORT_STS_CURR_RD_PORT_STS_S)
+
+#define AM_CURR_PORT_STS_CURR_WR_PORT_STS_S 16
+#define AM_CURR_PORT_STS_CURR_WR_PORT_STS_M   \
+	(((1UL << 16) - 1) << AM_CURR_PORT_STS_CURR_WR_PORT_STS_S)
+
+#define ROCEE_TSP_DROP_CFG0_TSP_DROP_INTERVAL_CFG_S 0
+#define ROCEE_TSP_DROP_CFG0_TSP_DROP_INTERVAL_CFG_M   \
+	(((1UL << 24) - 1) << ROCEE_TSP_DROP_CFG0_TSP_DROP_INTERVAL_CFG_S)
+
+#define ROCEE_TSP_DROP_CFG0_TSP_DROP_NUM_CFG_S 24
+#define ROCEE_TSP_DROP_CFG0_TSP_DROP_NUM_CFG_M   \
+	(((1UL << 8) - 1) << ROCEE_TSP_DROP_CFG0_TSP_DROP_NUM_CFG_S)
+
+#define ROCEE_TSP_DROP_CFG1_TSP_DROP_EN_S 0
+#define ROCEE_TSP_DROP_CFG1_TSP_DROP_EN_M   \
+	(((1UL << 5) - 1) << ROCEE_TSP_DROP_CFG1_TSP_DROP_EN_S)
+
+#define ROCEE_TSP_DROP_CFG1_TSP_DROP_MODE_S 7
+
+#define SBM_ROCEE_CFG_REG_SBM_CFG_EN_ROCEE_S 1
+#define SBM_ROCEE_CFG_REG_SBM_CFG_CRD_EN_ROCEE_S 2
+
+#define ROCE_DEV_IOBASE				(0xc4000000)
+
+/**********ROCEE_REG DEFINITION****************/
+
+#define ROCEE_VENDOR_ID_REG			0x0
+#define ROCEE_VENDOR_PART_ID_REG		0x4
+
+#define ROCEE_HW_VERSION_REG			0x8
+
+#define ROCEE_SYS_IMAGE_GUID_L_REG		0xC
+#define ROCEE_SYS_IMAGE_GUID_H_REG		0x10
+
+#define ROCEE_PORT_MSG_SIZE_REG			0x4C
+
+#define ROCEE_PORT_GID_L_0_REG			0x50
+#define ROCEE_PORT_GID_ML_0_REG			0x54
+#define ROCEE_PORT_GID_MH_0_REG			0x58
+#define ROCEE_PORT_GID_H_0_REG			0x5C
+
+#define ROCEE_BT_CMD_H_REG			0x204
+
+#define ROCEE_SMAC_L_0_REG			0x240
+#define ROCEE_SMAC_H_0_REG			0x244
+
+#define ROCEE_QP1C_CFG3_0_REG			0x27C
+
+#define ROCEE_CAEP_AEQE_CONS_IDX_REG		0x3AC
+#define ROCEE_CAEP_CEQC_CONS_IDX_0_REG		0x3BC
+
+#define ROCEE_ECC_UCERR_ALM1_REG		0xB38
+#define ROCEE_ECC_UCERR_ALM2_REG		0xB3C
+
+#define ROCEE_ECC_CERR_ALM1_REG			0xB44
+#define ROCEE_ECC_CERR_ALM2_REG			0xB48
+
+#define ROCEE_ACK_DELAY_REG			0x14
+#define ROCEE_GLB_CFG_REG			0x18
+
+#define ROCEE_DMAE_USER_CFG0_REG		0x3C
+#define ROCEE_DMAE_USER_CFG1_REG		0x40
+#define ROCEE_DMAE_USER_CFG2_REG		0x44
+#define ROCEE_DMAE_USER_CFG3_REG		0x48
+
+#define ROCEE_DB_SQ_WL_REG			0x154
+#define ROCEE_DB_OTHERS_WL_REG			0x158
+#define ROCEE_RAQ_WL_REG			0x15C
+#define ROCEE_WRMS_POL_TIME_INTERVAL_REG	0x160
+#define ROCEE_EXT_DB_SQ_REG			0x164
+#define ROCEE_EXT_DB_SQ_H_REG			0x168
+#define ROCEE_EXT_DB_OTH_REG			0x16C
+
+#define ROCEE_EXT_DB_OTH_H_REG			0x170
+#define ROCEE_EXT_DB_SQ_WL_EMPTY_REG		0x174
+#define ROCEE_EXT_DB_SQ_WL_REG			0x178
+#define ROCEE_EXT_DB_OTHERS_WL_EMPTY_REG	0x17C
+#define ROCEE_EXT_DB_OTHERS_WL_REG		0x180
+#define ROCEE_EXT_RAQ_REG			0x184
+#define ROCEE_EXT_RAQ_H_REG			0x188
+
+#define ROCEE_CAEP_CE_INTERVAL_CFG_REG		0x190
+#define ROCEE_CAEP_CE_BURST_NUM_CFG_REG		0x194
+#define ROCEE_QMM_TB_CFG_REG			0x198
+#define ROCEE_TSP_RR_CFG_REG			0x19C
+#define ROCEE_BT_CMD_L_REG			0x200
+
+#define ROCEE_MB1_REG				0x210
+#define ROCEE_MB2_REG				0x214
+#define ROCEE_MB3_REG				0x218
+#define ROCEE_MB4_REG				0x21C
+#define ROCEE_MB5_REG				0x220
+#define ROCEE_MB6_REG				0x224
+#define ROCEE_MB7_REG				0x228
+#define ROCEE_DB_SQ_L_0_REG			0x230
+#define ROCEE_DB_SQ_H_0_REG			0x234
+
+#define ROCEE_DB_OTHERS_L_0_REG			0x238
+#define ROCEE_DB_OTHERS_H_0_REG			0x23C
+
+#define ROCEE_QP1C_CFG0_0_REG			0x270
+
+#define ROCEE_CAEP_AEQC_AEQE_SHIFT_REG		0x3A0
+#define ROCEE_CAEP_CEQC_SHIFT_0_REG		0x3B0
+
+#define ROCEE_CAEP_CE_IRQ_MASK_0_REG		0x3C0
+
+#define ROCEE_CAEP_CEQ_ALM_OVF_0_REG		0x3C4
+
+#define ROCEE_CAEP_AE_MASK_REG			0x6C8
+#define ROCEE_CAEP_AE_ST_REG			0x6CC
+#define ROCEE_TRP_RX_DROP_CFG_REG		0x6D0
+#define ROCEE_ODB_DEPTH_REG			0x700
+#define ROCEE_TSQ_DEPTH_REG			0x704
+#define ROCEE_RAQ_DEPTH_REG			0x708
+
+#define ROCEE_DB_QUE_ST0_REG			0x750
+#define ROCEE_DB_QUE_ST1_REG			0x754
+#define ROCEE_SDB_ISSUE_PTR_REG			0x758
+#define ROCEE_SDB_SEND_PTR_REG			0x75C
+#define ROCEE_EXT_SQ_ST0_REG			0x760
+#define ROCEE_EXT_SQ_ST1_REG			0x764
+#define ROCEE_EXT_RAQ_ST0_REG			0x768
+#define ROCEE_EXT_RAQ_ST1_REG			0x76C
+#define ROCEE_WRMS_ACKQ_OVF_FLG_REG		0x770
+#define ROCEE_DB_SQ_ST_REG			0x774
+#define ROCEE_DB_OTHERS_ST_REG			0x778
+#define ROCEE_EXT_DB_ALM_REG			0x77C
+#define ROCEE_CQ_MAX_REG			0x780
+#define ROCEE_MR_MAX_REG			0x784
+#define ROCEE_QP_MAX_REG			0x788
+#define ROCEE_RETRY_QP_CNT_REG			0x78C
+#define ROCEE_WRMS_RETY_HDK_REG			0x794
+#define ROCEE_WRMS_MEM_INIT_RDY_REG		0x798
+#define ROCEE_DIRECT_WQE_ST_REG			0x79C
+#define ROCEE_TSP_THC_LL_REG			0x7A0
+#define ROCEE_TSP_CREDIT_CNT0_REG		0x7A4
+#define ROCEE_TSP_CREDIT_CNT1_REG		0x7A8
+
+#define ROCEE_CAEP_WR_REQ_REG			0x818
+#define ROCEE_TRP_ERR_PKT_CNT_0_REG		0x81C
+
+#define ROCEE_TRP_INTERNAL_DATA_FIFO_EMPTY_REG	0x848
+#define ROCEE_TRP_INTERNAL_DATA_FIFO_FULL_REG	0x84C
+#define ROCEE_CAEP_INTERNAL_FIFO_FULL_REG	0x850
+#define ROCEE_TRP_PIPE_FSM_REG			0x854
+#define ROCEE_TRP_RX_PKT_CNT_0_REG		0x880
+
+#define ROCEE_TRP_RX_UD_CNT_0_REG		0x898
+#define ROCEE_TRP_RX_RC_CNT_0_REG		0x8B0
+
+#define ROCEE_CAEP_CE_CNT_REG			0x8C8
+#define ROCEE_CAEP_WR_CQE_CNT_REG		0x8D0
+#define ROCEE_CAEP_AE_CNT_REG			0x8D4
+#define ROCEE_MBX_ISSUE_CNT_REG			0x980
+#define ROCEE_MBX_EXEC_CNT_REG			0x984
+#define ROCEE_SDB_ISSUE_CNT_REG			0x988
+#define ROCEE_SDB_ENQ_CNT_REG			0x98C
+#define ROCEE_SDB_DEQ_CNT_REG			0x990
+#define ROCEE_ODB_ISSUE_CNT_REG			0x994
+#define ROCEE_ODB_ENQ_CNT_REG			0x998
+#define ROCEE_ODB_DEQ_CNT_REG			0x99C
+#define ROCEE_MBX_INV_CNT_REG			0x9A0
+#define ROCEE_SDB_INV_CNT_REG			0x9A4
+#define ROCEE_ODB_INV_CNT_REG			0x9A8
+#define ROCEE_SDB_RETRY_CNT_REG			0x9AC
+#define ROCEE_SDB_OV_CNT_REG			0x9B0
+#define ROCEE_ODB_OV_CNT_REG			0x9B4
+#define ROCEE_TRP_PKT_ERR_FLG_0_REG		0x9B8
+
+#define ROCEE_TSP_HDK_ST_REG			0x9E8
+#define ROCEE_TSP_BP_ST_REG			0x9EC
+#define ROCEE_TSP_RETRY_CNT_REG			0x9F0
+#define ROCEE_TSP_CSDB_DBBK_CNT_REG		0x9F4
+#define ROCEE_TSP_TGM_CSDB_CNT_REG		0x9F8
+#define ROCEE_TSP_P0_PKT_CNT_REG		0x9FC
+
+#define ROCEE_AXI_ERR_ALM0_REG			0xB00
+#define ROCEE_AXI_ERR_ALM1_REG			0xB04
+
+#define ROCEE_ECC_UCERR_ALM0_REG		0xB34
+#define ROCEE_ECC_CERR_ALM0_REG			0xB40
+
+#define ROCEE_QMM_CHK_CMD_VLD_REG		0x1000
+#define ROCEE_QMM_CFG_FIFO_LEVEL_REG		0x1004
+#define ROCEE_QMM_QPC_MISS_CNT_REG		0x1010
+#define ROCEE_QMM_QPC_HIT_CNT_REG		0x1014
+#define ROCEE_QMM_QPC_REPLACE_IND_REG		0x1018
+#define ROCEE_QMM_QPC_SRH_STATUS_REG		0x101C
+#define ROCEE_QMM_QPC_SRH_TAG_REG		0x1020
+#define ROCEE_QMM_MTPT_MISS_CNT_REG		0x1030
+#define ROCEE_QMM_MTPT_HIT_CNT_REG		0x1034
+#define ROCEE_QMM_MTPT_REPLACE_IND_REG		0x1038
+#define ROCEE_QMM_MTPT_SRH_STATUS_REG		0x103C
+#define ROCEE_QMM_MTPT_SRH_TAG_REG		0x1040
+#define ROCEE_QMM_CQC_MISS_CNT_REG		0x1050
+#define ROCEE_QMM_CQC_HIT_CNT_REG		0x1054
+#define ROCEE_QMM_CQC_REPLACE_IND_REG		0x1058
+#define ROCEE_QMM_CQC_SRH_STATUS_REG		0x105C
+#define ROCEE_QMM_CQC_SRH_TAG_REG		0x1060
+#define ROCEE_QPC_CACHE_RW_STATUS_REG		0x1070
+#define ROCEE_MTPT_CACHE_RW_STATUS_REG		0x1074
+#define ROCEE_CQC_CACHE_RW_STATUS_REG		0x1078
+#define ROCEE_QMM_CACHE_CLR_REG			0x1080
+
+#define ROCEE_QMM_CACHE_REFRESH_REG		0x1088
+#define ROCEE_QPC_DMAE_STATUS_REG		0x108C
+#define ROCEE_MTPT_DMAE_STATUS_REG		0x1090
+#define ROCEE_CQC_DMAE_STATUS_REG		0x1094
+#define ROCEE_QMM_CACHE_REPLACE_REG		0x1098
+#define ROCEE_QMM_QPC_DIRTY0_REG		0x109C
+
+#define ROCEE_QMM_MTPT_DIRTY0_REG		0x10AC
+#define ROCEE_QMM_CQC_DIRTY0_REG		0x10B4
+
+#define ROCEE_AXI_MST_A_DFX_REG			0xFC00
+#define ROCEE_AXI_MST_B_DFX_REG			0xFE00
+
+#define ROCEE_OOOA_CFG_BASE		(ROCEE_AXI_MST_A_DFX_REG)
+#define ROCEE_OOOB_CFG_BASE		(ROCEE_AXI_MST_B_DFX_REG)
+
+#define ROCEE_OOOA_CFG_AM_CTRL_GLOBAL_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x0)
+#define ROCEE_OOOA_CFG_AM_CTRL_LATENCY_SEL_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x4)
+#define ROCEE_OOOA_CFG_AM_CFG_MAX_TRANS_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x10)
+#define ROCEE_OOOA_CFG_AM_CFG_SINGLE_PORT_MAX_TRANS_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x14)
+#define ROCEE_OOOA_CFG_AM_CURR_PORT_STS_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x100)
+#define ROCEE_OOOA_CFG_AM_CURR_ROB_ECC_ERR_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x10C)
+#define ROCEE_OOOA_CFG_AM_CURR_MAX_RD_LATENCY_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x110)
+#define ROCEE_OOOA_CFG_AM_CURR_AVA_RD_LATENCY_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x114)
+#define ROCEE_OOOA_CFG_AM_CURR_RD_LATENCY_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x118)
+#define ROCEE_OOOA_CFG_AM_CURR_MAX_WR_LATENCY_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x130)
+#define ROCEE_OOOA_CFG_AM_CURR_AVA_WR_LATENCY_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x134)
+#define ROCEE_OOOA_CFG_AM_CURR_WR_LATENCY_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x138)
+
+#define ROCEE_OOOA_CFG_AM_CURR_RD_TXID_STS_L_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x160)
+#define ROCEE_OOOA_CFG_AM_CURR_RD_TXID_STS_H_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x164)
+#define ROCEE_OOOA_CFG_AM_CURR_WR_TXID_STS_L_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x170)
+#define ROCEE_OOOA_CFG_AM_CURR_WR_TXID_STS_H_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x174)
+#define ROCEE_OOOA_CFG_AM_ALARM_RRESP_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x180)
+#define ROCEE_OOOA_CFG_AM_ALARM_BRESP_REG \
+				(ROCEE_OOOA_CFG_BASE + 0x184)
+
+#define ROCEE_OOOB_CFG_AM_CTRL_GLOBAL_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x0)
+#define ROCEE_OOOB_CFG_AM_CTRL_LATENCY_SEL_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x4)
+#define ROCEE_OOOB_CFG_AM_CFG_MAX_TRANS_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x10)
+#define ROCEE_OOOB_CFG_AM_CFG_SINGLE_PORT_MAX_TRANS_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x14)
+
+#define ROCEE_OOOB_CFG_AM_CURR_PORT_STS_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x100)
+#define ROCEE_OOOB_CFG_AM_CURR_ROB_ECC_ERR_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x10C)
+#define ROCEE_OOOB_CFG_AM_CURR_MAX_RD_LATENCY_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x110)
+#define ROCEE_OOOB_CFG_AM_CURR_AVA_RD_LATENCY_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x114)
+#define ROCEE_OOOB_CFG_AM_CURR_RD_LATENCY_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x118)
+#define ROCEE_OOOB_CFG_AM_CURR_MAX_WR_LATENCY_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x130)
+#define ROCEE_OOOB_CFG_AM_CURR_AVA_WR_LATENCY_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x134)
+#define ROCEE_OOOB_CFG_AM_CURR_WR_LATENCY_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x138)
+
+#define ROCEE_OOOB_CFG_AM_CURR_RD_TXID_STS_L_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x160)
+#define ROCEE_OOOB_CFG_AM_CURR_RD_TXID_STS_H_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x164)
+#define ROCEE_OOOB_CFG_AM_CURR_WR_TXID_STS_L_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x170)
+#define ROCEE_OOOB_CFG_AM_CURR_WR_TXID_STS_H_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x174)
+#define ROCEE_OOOB_CFG_AM_ALARM_RRESP_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x180)
+#define ROCEE_OOOB_CFG_AM_ALARM_BRESP_REG \
+				(ROCEE_OOOB_CFG_BASE + 0x184)
+
+#endif /* _HNS_ROCE_COMMON_H */
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c
new file mode 100644
index 0000000..c73970e
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c
@@ -0,0 +1,481 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/hardirq.h>
+#include <linux/log2.h>
+#include <linux/slab.h>
+
+#include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+#include "hns_roce_icm.h"
+#include "hns_roce_user.h"
+#include "hns_roce_common.h"
+
+#define PAGE_OFFSET_4K			0x1000
+
+static void hns_roce_ib_cq_comp(struct hns_roce_cq *hr_cq)
+{
+	struct ib_cq *ibcq = &hr_cq->ib_cq;
+
+	ibcq->comp_handler(ibcq, ibcq->cq_context);
+}
+
+static void hns_roce_ib_cq_event(
+					struct hns_roce_cq *hr_cq,
+					enum hns_roce_event event_type)
+{
+	struct hns_roce_dev *hr_dev;
+	struct ib_event event;
+	struct ib_cq *ibcq;
+
+	ibcq = &hr_cq->ib_cq;
+	hr_dev = to_hr_dev(ibcq->device);
+
+	if (
+		event_type != HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID &&
+		event_type != HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR &&
+		event_type != HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW) {
+		dev_err(&hr_dev->pdev->dev,
+			"hns_roce_ib: Unexpected event type 0x%x on CQ %06x\n",
+			event_type, hr_cq->cqn);
+		return;
+	}
+
+	if (ibcq->event_handler) {
+		event.device     = ibcq->device;
+		event.event      = IB_EVENT_CQ_ERR;
+		event.element.cq = ibcq;
+		ibcq->event_handler(&event, ibcq->cq_context);
+	}
+}
+
+static int hns_roce_sw2hw_cq(
+				struct hns_roce_dev *dev,
+				struct hns_roce_cmd_mailbox *mailbox,
+				int cq_num)
+{
+	return hns_roce_cmd(
+			dev, mailbox->dma, cq_num, 0,
+			HNS_ROCE_CMD_SW2HW_CQ,
+			HNS_ROCE_CMD_TIME_CLASS_A);
+}
+
+static int hns_roce_cq_alloc(
+			struct hns_roce_dev *hr_dev, int nent,
+			struct hns_roce_mtt *hr_mtt,
+			struct hns_roce_uar *hr_uar,
+			struct hns_roce_cq *hr_cq,
+			unsigned vector,
+			int collapsed)
+{
+	struct hns_roce_cmd_mailbox *mailbox = NULL;
+	struct hns_roce_cq_table *cq_table = NULL;
+	struct device *dev = &hr_dev->pdev->dev;
+	dma_addr_t dma_handle;
+	u64 *mtts = NULL;
+	int ret = 0;
+
+	cq_table = &hr_dev->cq_table;
+
+	/* Get the physical address of cq buf */
+	mtts = hns_roce_table_find(&hr_dev->mr_table.mtt_table,
+				hr_mtt->first_seg, &dma_handle);
+	if (!mtts) {
+		dev_err(dev,
+			"CQ alloc.Failed to find cq buf addr.\n");
+		return -EINVAL;
+	}
+
+	if (vector >= hr_dev->caps.num_comp_vectors) {
+		dev_err(dev, "CQ alloc.Invalid vector.\n");
+		return -EINVAL;
+	}
+	hr_cq->vector = vector;
+
+	hr_cq->cqn = hns_roce_bitmap_alloc(&cq_table->bitmap);
+	if (hr_cq->cqn == -1) {
+		dev_err(dev, "CQ alloc.Failed to alloc index.\n");
+		return -ENOMEM;
+	}
+
+	/* Get CQC memory icm table */
+	ret = hns_roce_table_get(hr_dev, &cq_table->table, hr_cq->cqn);
+	if (ret) {
+		dev_err(dev, "CQ alloc.Failed to get context mem.\n");
+		goto err_out;
+	}
+
+	/* The cq insert radix tree */
+	spin_lock_irq(&cq_table->lock);
+	/* Radix_tree: The associated pointer and long integer key value like */
+	ret = radix_tree_insert(&cq_table->tree, hr_cq->cqn, hr_cq);
+	spin_unlock_irq(&cq_table->lock);
+	if (ret) {
+		dev_err(dev, "CQ alloc.Failed to radix_tree_insert.\n");
+		goto err_put;
+	}
+
+	/* Applicate mailbox memory */
+	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
+	if (IS_ERR(mailbox)) {
+		dev_err(dev, "CQ alloc.Failed to alloc mailbox.\n");
+		ret = PTR_ERR(mailbox);
+		goto err_radix;
+	}
+
+	hr_dev->hw->write_cqc(hr_dev, hr_cq, mailbox->buf, mtts,
+			dma_handle, nent, vector);
+
+	/* CQ instructions which sw send to hw be transimited via mailbox */
+	ret = hns_roce_sw2hw_cq(hr_dev, mailbox, hr_cq->cqn);
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+	if (ret) {
+		dev_err(dev, "CQ alloc.Failed to cmd mailbox.\n");
+		goto err_radix;
+	}
+
+	hr_cq->cons_index = 0;
+	hr_cq->uar        = hr_uar;
+
+	return 0;
+
+err_radix:
+	spin_lock_irq(&cq_table->lock);
+	radix_tree_delete(&cq_table->tree, hr_cq->cqn);
+	spin_unlock_irq(&cq_table->lock);
+
+err_put:
+	hns_roce_table_put(hr_dev, &cq_table->table, hr_cq->cqn);
+
+err_out:
+	hns_roce_bitmap_free(&cq_table->bitmap, hr_cq->cqn);
+
+	return ret;
+}
+
+static int hns_roce_hw2sw_cq(
+				struct hns_roce_dev *dev,
+				struct hns_roce_cmd_mailbox *mailbox,
+				int cq_num)
+{
+	return hns_roce_cmd_box(dev, 0, mailbox ? mailbox->dma : 0, cq_num,
+				mailbox ? 0 : 1, HNS_ROCE_CMD_HW2SW_CQ,
+				HNS_ROCE_CMD_TIME_CLASS_A);
+}
+
+void hns_roce_free_cq(struct hns_roce_dev *hr_dev, struct hns_roce_cq *hr_cq)
+{
+	struct hns_roce_cq_table *cq_table = &hr_dev->cq_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret;
+
+	ret = hns_roce_hw2sw_cq(hr_dev, NULL, hr_cq->cqn);
+	if (ret)
+		dev_err(dev,
+			"HW2SW_CQ failed (%d) for CQN %06x\n", ret, hr_cq->cqn);
+
+	/* Waiting interrupt process procedure carried out */
+	synchronize_irq(hr_dev->eq_table.eq[hr_cq->vector].irq);
+
+	spin_lock_irq(&cq_table->lock);
+	radix_tree_delete(&cq_table->tree, hr_cq->cqn);
+	spin_unlock_irq(&cq_table->lock);
+
+	hns_roce_table_put(hr_dev, &cq_table->table, hr_cq->cqn);
+	hns_roce_bitmap_free(&cq_table->bitmap, hr_cq->cqn);
+}
+
+static int hns_roce_ib_get_cq_umem(
+					struct hns_roce_dev *hr_dev,
+					struct ib_ucontext *context,
+					struct hns_roce_cq_buf *buf,
+					struct ib_umem **umem,
+					u64 buf_addr, int cqe)
+{
+	int ret;
+
+	/* Get and mapping user space */
+	*umem = ib_umem_get(context, buf_addr,
+			cqe * hr_dev->caps.cq_entry_sz,
+			IB_ACCESS_LOCAL_WRITE, 1);
+	if (IS_ERR(*umem))
+		return PTR_ERR(*umem);
+
+	ret = hns_roce_mtt_init(hr_dev, ib_umem_page_count(*umem),
+			ilog2((*umem)->page_size), &buf->hr_mtt);
+	if (ret)
+		goto err_buf;
+
+	ret = hns_roce_ib_umem_write_mtt(hr_dev, &buf->hr_mtt, *umem);
+	if (ret)
+		goto err_mtt;
+
+	return 0;
+
+err_mtt:
+	hns_roce_mtt_cleanup(hr_dev, &buf->hr_mtt);
+err_buf:
+	ib_umem_release(*umem);
+
+	return ret;
+}
+
+static int hns_roce_ib_alloc_cq_buf(
+					struct hns_roce_dev *hr_dev,
+					struct hns_roce_cq_buf *buf,
+					int nent)
+{
+	int ret;
+
+	ret = hns_roce_buf_alloc(hr_dev, nent * hr_dev->caps.cq_entry_sz,
+				PAGE_SIZE * 2, &buf->hr_buf);
+	if (ret)
+		goto out;
+
+
+	ret = hns_roce_mtt_init(hr_dev, buf->hr_buf.npages,
+			buf->hr_buf.page_shift, &buf->hr_mtt);
+	if (ret)
+		goto err_buf;
+
+	ret = hns_roce_buf_write_mtt(hr_dev, &buf->hr_mtt, &buf->hr_buf);
+	if (ret)
+		goto err_mtt;
+
+	return 0;
+
+err_mtt:
+	hns_roce_mtt_cleanup(hr_dev, &buf->hr_mtt);
+
+err_buf:
+	hns_roce_buf_free(hr_dev, nent * hr_dev->caps.cq_entry_sz,
+		&buf->hr_buf);
+
+out:
+	return ret;
+}
+
+static void hns_roce_ib_free_cq_buf(
+					struct hns_roce_dev *hr_dev,
+					struct hns_roce_cq_buf *buf,
+					int cqe)
+{
+	hns_roce_buf_free(
+			hr_dev,
+			(cqe + 1) * hr_dev->caps.cq_entry_sz,
+			&buf->hr_buf);
+}
+
+struct ib_cq *hns_roce_ib_create_cq(
+					struct ib_device *ib_dev,
+					const struct ib_cq_init_attr *attr,
+					struct ib_ucontext *context,
+					struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_ib_create_cq ucmd;
+	struct hns_roce_cq *hr_cq = NULL;
+	struct hns_roce_uar *uar = NULL;
+	int vector = attr->comp_vector;
+	int cq_entries = attr->cqe;
+	int ret = 0;
+
+	if (cq_entries < 1 || cq_entries > hr_dev->caps.max_cqes) {
+		dev_err(dev,
+			"Creat CQ failed. entries=%d, max=%d\n",
+			cq_entries, hr_dev->caps.max_cqes);
+		return ERR_PTR(-EINVAL);
+	}
+
+	hr_cq = kmalloc(sizeof(*hr_cq), GFP_KERNEL);
+	if (!hr_cq)
+		return ERR_PTR(-ENOMEM);
+
+	/* In v1 engine, parameter verification */
+	if (cq_entries < HNS_ROCE_MIN_CQE_NUM)
+		cq_entries = HNS_ROCE_MIN_CQE_NUM;
+
+	cq_entries = roundup_pow_of_two(cq_entries);
+
+	hr_cq->ib_cq.cqe = cq_entries - 1;
+	mutex_init(&hr_cq->resize_mutex);
+	spin_lock_init(&hr_cq->lock);
+	hr_cq->hr_resize_buf = NULL;
+	hr_cq->resize_umem = NULL;
+
+	if (context) {
+		if (ib_copy_from_udata(&ucmd, udata, sizeof(ucmd))) {
+			dev_err(dev, "Failed to copy_from_udata.\n");
+			ret = -EFAULT;
+			goto err_cq;
+		}
+
+		/* Get user space address, write it into mtt table */
+		ret = hns_roce_ib_get_cq_umem(
+					hr_dev, context,
+					&hr_cq->hr_buf,
+					&hr_cq->umem,
+					ucmd.buf_addr,
+					cq_entries);
+		if (ret) {
+			dev_err(dev, "Failed to get_cq_umem.\n");
+			goto err_cq;
+		}
+
+		/* Get user space parameters */
+		uar = &to_hr_ucontext(context)->uar;
+	} else {
+		/* Init mmt table and write buff address to mtt table */
+		ret = hns_roce_ib_alloc_cq_buf(
+					hr_dev, &hr_cq->hr_buf,
+					cq_entries);
+		if (ret) {
+			dev_err(dev, "Failed to alloc_cq_buf.\n");
+			goto err_cq;
+		}
+
+		uar = &hr_dev->priv_uar;
+
+		hr_cq->cq_db_l = hr_dev->reg_base + ROCEE_DB_OTHERS_L_0_REG +
+				PAGE_OFFSET_4K * uar->index;
+	}
+
+	/* Allocate cq index, fill cq_context */
+	ret = hns_roce_cq_alloc(
+			hr_dev, cq_entries, &hr_cq->hr_buf.hr_mtt,
+			uar, hr_cq, vector, 0);
+	if (ret) {
+		dev_err(dev, "Creat CQ .Failed to cq_alloc.\n");
+		goto err_mtt;
+	}
+
+	/* Get created cq handler and carry out event */
+	hr_cq->comp  = hns_roce_ib_cq_comp;
+	hr_cq->event = hns_roce_ib_cq_event;
+
+	hr_cq->cq_depth = cq_entries;
+
+	if (context) {
+		if (ib_copy_to_udata(
+			udata, &(hr_cq->cqn),
+			sizeof(__u32))) {
+			ret = -EFAULT;
+			goto err_mtt;
+		}
+	}
+
+	return &hr_cq->ib_cq;
+
+err_mtt:
+	hns_roce_mtt_cleanup(hr_dev, &hr_cq->hr_buf.hr_mtt);
+
+	if (context)
+		ib_umem_release(hr_cq->umem);
+	else
+		hns_roce_ib_free_cq_buf(hr_dev,
+					&hr_cq->hr_buf,
+					hr_cq->ib_cq.cqe);
+
+err_cq:
+	kfree(hr_cq);
+	return ERR_PTR(ret);
+}
+
+int hns_roce_ib_destroy_cq(struct ib_cq *ib_cq)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_cq->device);
+	struct hns_roce_cq *hr_cq = to_hr_cq(ib_cq);
+
+	hns_roce_free_cq(hr_dev, hr_cq);
+	hns_roce_mtt_cleanup(hr_dev, &hr_cq->hr_buf.hr_mtt);
+
+	if (ib_cq->uobject)
+		ib_umem_release(hr_cq->umem);
+	else
+		/* Free the buff of stored cq */
+		hns_roce_ib_free_cq_buf(hr_dev,
+					&hr_cq->hr_buf,
+					ib_cq->cqe);
+
+	kfree(hr_cq);
+
+	return 0;
+}
+
+void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_cq *cq;
+
+	cq = radix_tree_lookup(
+				&hr_dev->cq_table.tree,
+				cqn & (hr_dev->caps.num_cqs - 1));
+	if (!cq) {
+		dev_warn(dev, "Completion event for bogus CQ 0x%08x\n", cqn);
+		return;
+	}
+
+	cq->comp(cq);
+}
+
+void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type)
+{
+	struct hns_roce_cq_table *cq_table = &hr_dev->cq_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_cq *cq;
+
+	spin_lock(&cq_table->lock);
+
+	cq = radix_tree_lookup(
+				&cq_table->tree,
+				cqn & (hr_dev->caps.num_cqs - 1));
+	if (cq)
+		atomic_inc(&cq->refcount);
+
+	spin_unlock(&cq_table->lock);
+
+	if (!cq) {
+		dev_warn(dev, "Async event for bogus CQ %08x\n", cqn);
+		return;
+	}
+
+	cq->event(cq, event_type);
+
+	if (atomic_dec_and_test(&cq->refcount))
+		complete(&cq->free);
+}
+
+int hns_roce_init_cq_table(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	struct hns_roce_cq_table *cq_table = &hr_dev->cq_table;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	spin_lock_init(&cq_table->lock);
+	INIT_RADIX_TREE(&cq_table->tree, GFP_ATOMIC);
+
+	ret = hns_roce_bitmap_init(
+				&cq_table->bitmap, hr_dev->caps.num_cqs,
+				hr_dev->caps.num_cqs - 1,
+				hr_dev->caps.reserved_cqs,
+				0);
+	if (ret) {
+		dev_err(dev, "init_cq_table.Failed to bitmap_init.\n");
+		return ret;
+	}
+
+	return 0;
+}
+
+void hns_roce_cleanup_cq_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->cq_table.bitmap);
+}
+
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h b/drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h
new file mode 100644
index 0000000..a4a0c59
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h
@@ -0,0 +1,870 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_DEVICE_H
+#define _HNS_ROCE_DEVICE_H
+
+#include <linux/platform_device.h>
+#include <linux/radix-tree.h>
+#include <linux/semaphore.h>
+
+#include <rdma/ib_addr.h>
+#include <rdma/ib_smi.h>
+#include <rdma/ib_umem.h>
+#include <rdma/ib_user_verbs.h>
+#include <rdma/ib_verbs.h>
+
+#define DRV_NAME "hns_roce"
+
+#define ROCE_VERSION_1 ('1' << 24 | '6' << 16 | '1' << 8 | '0')
+#define ROCE_VERSION_2 ('1' << 24 | '6' << 16 | '2' << 8 | '0')
+#define ROCE_IS_VER2(ver) ((ver) == ROCE_VERSION_1)
+
+#define MAC_ADDR_OCTET_NUM			6
+#define HNS_ROCE_MAX_MSG_LEN			0x80000000
+
+#define HNS_ROCE_ALOGN_UP(a, b) ((((a) + (b) - 1) / (b)) * (b))
+
+#define HNS_ROCE_IB_MIN_SQ_STRIDE		6
+
+#define HNS_ROCE_BA_SIZE			(32 * 4096)
+
+/* Hardware specification only for v1 engine */
+#define HNS_ROCE_MIN_CQE_NUM			0x40
+#define HNS_ROCE_MIN_WQE_NUM			0x20
+
+/* Hardware specification only for v1 engine */
+#define HNS_ROCE_MAX_INNER_MTPT_NUM		0x7
+#define HNS_ROCE_MAX_MTPT_PBL_NUM		0x100000
+
+#define HNS_ROCE_MAX_IRQ_NUM			34
+#define HNS_ROCE_COMP_VEC_NUM			32
+#define HNS_ROCE_AEQE_VEC_NUM			1
+#define HNS_ROCE_AEQE_OF_VEC_NUM		1
+
+/* 4G/4K = 1M */
+#define HNS_ROCE_SL_SHIFT			29
+#define HNS_ROCE_TCLASS_SHIFT			20
+#define HNS_ROCE_FLOW_LABLE_MASK		0xfffff
+
+#define HNS_ROCE_MAX_PORTS			6
+#define HNS_ROCE_MAX_GID_NUM			16
+#define HNS_ROCE_GID_SIZE			16
+
+#define MR_TYPE_MR				0x00
+#define MR_TYPE_PMR				0x01
+#define MR_TYPE_MW				0x02
+#define MR_TYPE_DMA				0x03
+
+#define PKEY_ID					0xffff
+#define NODE_DESC_SIZE				64
+
+#define SERV_TYPE_RC				0
+#define SERV_TYPE_RD				1
+#define SERV_TYPE_UC				2
+#define SERV_TYPE_UD				3
+
+#define ADDR_SHIFT_12				12
+#define ADDR_SHIFT_32				32
+#define ADDR_SHIFT_44				44
+
+#define PAGES_SHIFT_8				8
+#define PAGES_SHIFT_16				16
+#define PAGES_SHIFT_24				24
+#define PAGES_SHIFT_32				32
+
+enum hns_roce_qp_state {
+	HNS_ROCE_QP_STATE_RST            = 0,
+	HNS_ROCE_QP_STATE_INIT           = 1,
+	HNS_ROCE_QP_STATE_RTR            = 2,
+	HNS_ROCE_QP_STATE_RTS            = 3,
+	HNS_ROCE_QP_STATE_SQD            = 4,
+	HNS_ROCE_QP_STATE_ERR            = 5,
+	HNS_ROCE_QP_NUM_STATE
+};
+
+enum hns_roce_event {
+	HNS_ROCE_EVENT_TYPE_PATH_MIG                  = 0x01,
+	HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED           = 0x02,
+	HNS_ROCE_EVENT_TYPE_COMM_EST                  = 0x03,
+	HNS_ROCE_EVENT_TYPE_SQ_DRAINED                = 0x04,
+	HNS_ROCE_EVENT_TYPE_WQ_CATAS_ERROR            = 0x05,
+	HNS_ROCE_EVENT_TYPE_INV_REQ_LOCAL_WQ_ERROR    = 0x06,
+	HNS_ROCE_EVENT_TYPE_LOCAL_WQ_ACCESS_ERROR     = 0x07,
+	HNS_ROCE_EVENT_TYPE_SRQ_LIMIT_REACH           = 0x08,
+	HNS_ROCE_EVENT_TYPE_SRQ_LAST_WQE_REACH        = 0x09,
+	HNS_ROCE_EVENT_TYPE_SRQ_CATAS_ERROR           = 0x0a,
+	HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR           = 0x0b,
+	HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW               = 0x0c,
+	HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID             = 0x0d,
+	HNS_ROCE_EVENT_TYPE_PORT_ACTIVE               = 0x0e,
+	HNS_ROCE_EVENT_TYPE_PORT_CHANGE               = 0x0f,
+	HNS_ROCE_EVENT_TYPE_LOCAL_CATAS_ERROR         = 0x10,
+	HNS_ROCE_EVENT_TYPE_PORT_ERROR                = 0x11,
+	HNS_ROCE_EVENT_TYPE_DB_OVERFLOW               = 0x12,
+	HNS_ROCE_EVENT_TYPE_MB                        = 0x13,
+	HNS_ROCE_EVENT_TYPE_CEQ_OVERFLOW              = 0x14
+};
+
+/* Local Work Queue Catastrophic Error,SUBTYPE 0x5 */
+enum {
+	HNS_ROCE_LWQCE_QPC_ERROR		= 1,
+	HNS_ROCE_LWQCE_MTU_ERROR		= 2,
+	HNS_ROCE_LWQCE_WQE_BA_ADDR_ERROR	= 3,
+	HNS_ROCE_LWQCE_WQE_ADDR_ERROR		= 4,
+	HNS_ROCE_LWQCE_SQ_WQE_SHIFT_ERROR	= 5,
+	HNS_ROCE_LWQCE_SL_ERROR			= 6,
+	HNS_ROCE_LWQCE_PORT_ERROR		= 7
+};
+
+/* Local Access Violation Work Queue Error,SUBTYPE 0x7 */
+enum {
+	HNS_ROCE_LAVWQE_R_KEY_VIOLATION		= 1,
+	HNS_ROCE_LAVWQE_LENGTH_ERROR		= 2,
+	HNS_ROCE_LAVWQE_VA_ERROR		= 3,
+	HNS_ROCE_LAVWQE_PD_ERROR		= 4,
+	HNS_ROCE_LAVWQE_RW_ACC_ERROR		= 5,
+	HNS_ROCE_LAVWQE_KEY_STATE_ERROR		= 6,
+	HNS_ROCE_LAVWQE_MR_OPERATION_ERROR	= 7
+};
+
+/* DOORBELL overflow subtype */
+enum {
+	HNS_ROCE_DB_SUBTYPE_SDB_OVF		= 1,
+	HNS_ROCE_DB_SUBTYPE_SDB_ALM_OVF		= 2,
+	HNS_ROCE_DB_SUBTYPE_ODB_OVF		= 3,
+	HNS_ROCE_DB_SUBTYPE_ODB_ALM_OVF		= 4,
+	HNS_ROCE_DB_SUBTYPE_SDB_ALM_EMP		= 5,
+	HNS_ROCE_DB_SUBTYPE_ODB_ALM_EMP		= 6
+};
+
+enum {
+	HNS_ROCE_CMD_FALSE			= 0,
+	HNS_ROCE_CMD_SUCCESS			= 1
+};
+
+enum {
+	HNS_ROCE_OPCODE_NOP			= 0x00,
+	HNS_ROCE_OPCODE_SEND_INVAL		= 0x01,
+	HNS_ROCE_OPCODE_RDMA_WRITE		= 0x08,
+	HNS_ROCE_OPCODE_SEND			= 0x0a,
+	/* Large Send Off-load Segment */
+	HNS_ROCE_OPCODE_LSO			= 0x0e,
+	HNS_ROCE_OPCODE_RDMA_READ		= 0x10,
+	HNS_ROCE_OPCODE_BIND_MW			= 0x11,
+	HNS_ROCE_OPCODE_FMR			= 0x12,
+	/* Local invalidate header included mem_key, operate local memory */
+	HNS_ROCE_OPCODE_LOCAL_INVAL		= 0x1b,
+	HNS_ROCE_OPCODE_CONFIG_CMD		= 0x1f,
+
+	/* RQ&SRQ related operations */
+	HNS_ROCE_OPCODE_SEND_DATA_RECEIVE	= 0x06,
+	HNS_ROCE_OPCODE_RDMA_WITH_IMM_RECEIVE	= 0x07,
+
+	/* CQ related operation */
+	HNS_ROCE_CQE_OPCODE_ERROR		= 0x1e,
+};
+
+#define HNS_ROCE_PORT_DOWN		0
+#define HNS_ROCE_PORT_UP		1
+
+#define HNS_ROCE_MTT_ENTRY_PER_SEG	8
+
+#define PAGE_ADDR_SHIFT			12
+
+struct hns_roce_uar {
+	u64 pfn;
+	u32 index;
+};
+
+struct hns_roce_ucontext {
+	struct ib_ucontext	ibucontext;
+	struct hns_roce_uar	uar;
+};
+
+struct hns_roce_pd {
+	struct ib_pd ibpd;
+	u32          pdn;
+};
+
+struct hns_roce_bitmap {
+	/* Bitmap Traversal last a bit which is 1 */
+	u32            last;
+	u32            top;
+	u32            max;
+	u32            reserved_top;
+	u32            mask;
+	spinlock_t     lock;
+	unsigned long *table;
+};
+
+/* Order bitmap length -- bit num compute formula: 1 << (max_order - order) */
+/* Order = 0: bitmap is biggest, order = max bitmap is least (only a bit) */
+/* Every bit repesent to a partner free/used status in bitmap */
+/*
+* Initial, bits of other bitmap are all 0 except that a bit of max_order is 1
+* Bit = 1 represent to idle and available; bit = 0: not available
+*/
+struct hns_roce_buddy {
+	/* Members point to every order level bitmap */
+	unsigned long **bits;
+	/* Represent to avail bits of the order level bitmap */
+	u32            *num_free;
+	int             max_order;
+	spinlock_t      lock;
+};
+
+struct hns_roce_icm_table {
+	/* ICM type: 0 = qpc 1 = mtt 2 = cqc 3 = srq 4 = other */
+	u32            type;
+	/* ICM array elment num */
+	int            num_icm;
+	/* ICM entry record obj total num */
+	int            num_obj;
+	/*Single obj size */
+	int            obj_size;
+	int            lowmem;
+	int            coherent;
+	struct mutex   mutex;
+	struct hns_roce_icm **icm;
+};
+
+struct hns_roce_mtt {
+	u32            first_seg;
+	int            order;
+	int            page_shift;
+};
+
+/* Only support 4K page size for mr register */
+#define MR_SIZE_4K 0
+
+struct hns_roce_mr {
+	struct ib_mr		ibmr;
+	struct ib_umem		*umem;
+	struct hns_roce_mtt	mtt; /* MTT entry of mr */
+	u64			iova; /* MR's virtual orignal addr */
+	u64			size; /* Address range of MR */
+	u32			key; /* Key of MR */
+	u32			pd;   /* PD num of MR */
+	u32			access;/* Access permission of MR */
+	int			enabled; /* MR's active status */
+	int			type;	/* MR's register type */
+	u64			*pbl_buf;/* MR's PBL space */
+	dma_addr_t		pbl_dma_addr;	/* MR's PBL space PA */
+};
+
+struct hns_roce_mr_table {
+	struct hns_roce_bitmap		mtpt_bitmap;
+	struct hns_roce_buddy		mtt_buddy;
+	u64				mtt_base;
+	u64				mtpt_base;
+	struct hns_roce_icm_table	mtt_table;
+	struct hns_roce_icm_table	mtpt_table;
+};
+
+struct hns_roce_wq {
+	u64          *wrid;     /* Work request ID */
+	spinlock_t    lock;
+	int           wqe_cnt;  /* WQE num*/
+	int           max_post;
+	int           max_gs;
+	int           offset;
+	int           wqe_shift;/* WQE size */
+	unsigned      head;
+	unsigned      tail;
+	void __iomem *db_reg_l;
+	void __iomem *db_reg_h;
+};
+
+struct hns_roce_buf_list {
+	void		*buf;
+	dma_addr_t	map;
+};
+
+struct hns_roce_buf {
+	struct hns_roce_buf_list	direct;
+	struct hns_roce_buf_list	*page_list;
+	int				nbufs;
+	int				npages;
+	int				page_shift;
+};
+
+struct hns_roce_cq_buf {
+	struct hns_roce_buf hr_buf;
+	struct hns_roce_mtt hr_mtt;
+};
+
+struct hns_roce_cq_resize {
+	struct hns_roce_cq_buf	hr_buf;
+	int			cqe;
+};
+
+struct hns_roce_cq {
+	struct ib_cq			ib_cq;
+	struct hns_roce_cq_buf		hr_buf;
+	/* pointer to store information after resize*/
+	struct hns_roce_cq_resize	*hr_resize_buf;
+	spinlock_t			lock;
+	struct mutex			resize_mutex;
+	struct ib_umem			*umem;
+	struct ib_umem			*resize_umem;
+	void (*comp)(struct hns_roce_cq *);
+	void (*event)(struct hns_roce_cq *, enum hns_roce_event);
+
+	struct hns_roce_uar *uar;
+	u32				cq_depth;
+	u32				cons_index;
+	void __iomem			*cq_db_l;
+	void __iomem			*tptr_addr;
+	int				cqn;
+	unsigned			vector;
+	atomic_t			refcount;
+	struct completion		free;
+};
+
+struct hns_roce_srq_table {
+	struct hns_roce_bitmap		bitmap;
+	spinlock_t			lock;
+	struct radix_tree_root		tree;
+	struct hns_roce_icm_table	table;
+};
+
+struct hns_roce_srq {
+	struct ib_srq		ibsrq;
+	struct hns_roce_buf	buf;
+	void __iomem		*db;
+	u64			*wrid;
+	spinlock_t		lock;
+	int			head;
+	int			tail;
+	u16			wqe_ctr;
+	struct ib_umem		*umem;
+	struct mutex		mutex;
+
+	void (*event)(struct hns_roce_srq *, enum hns_roce_event);
+
+	int			srqn;
+	int			max;	/* Max wr nums*/
+	int			max_gs;	/* Max sge nums */
+	int			wqe_shift;
+
+	atomic_t		refcount;
+	struct completion	free;
+};
+
+struct hns_roce_uar_table {
+	struct hns_roce_bitmap bitmap;
+};
+
+struct hns_roce_qp_table {
+	struct hns_roce_bitmap		bitmap;
+	u32				rdmarcbase;
+	int				rdmarcshift;
+	spinlock_t			lock;
+	struct hns_roce_icm_table	qp_table;
+	struct hns_roce_icm_table  irrl_table;/* Initiator RDMA Read List */
+};
+
+struct hns_roce_cq_table {
+	struct hns_roce_bitmap		bitmap;
+	spinlock_t			lock;
+	struct radix_tree_root		tree;
+	struct hns_roce_icm_table	table;
+};
+
+struct hns_roce_raq_table {
+	int				e_raq_depth;
+	void __iomem			*e_raq_addr;
+	void __iomem			*e_raq_wl_addr;
+	void __iomem			*e_raq_shift_addr;
+	struct hns_roce_buf_list	*e_raq_buf;
+};
+
+struct hns_roce_av {
+	__le32      port_pd;
+	u8          reserved1;
+	u8          smac_index;
+	u16         reserved2;
+	u8          reserved3;
+	u8          gid_index;
+	u8          stat_rate;
+	u8          hop_limit;
+	__le32      sl_tclass_flowlabel;
+	u8          dgid[HNS_ROCE_GID_SIZE];
+	u32         reserved4[2];
+	u8          mac[6];
+	__le16      vlan;
+};
+
+struct hns_roce_ah {
+	struct ib_ah		ibah;
+	struct hns_roce_av	av;
+};
+
+struct hns_roce_cmd_context {
+	struct completion	done;
+	int			result;
+	int			next;
+	u64			out_param;
+	u16			token;
+};
+
+struct hns_roce_cmdq {
+	struct dma_pool  *pool;
+	void __iomem     *hcr;
+	struct mutex      hcr_mutex;
+	struct semaphore  poll_sem;
+	/*
+	* Event mode: cmd register mutex protection,
+	* ensure to not exceed max_cmds and user use limit region
+	*/
+	struct semaphore  event_sem;
+	int               max_cmds;
+	spinlock_t        context_lock;
+	int               free_head;
+	struct hns_roce_cmd_context *context;
+	/*
+	* Result of get integer part
+	* which max_comds compute according a power of 2
+	*/
+	u16               token_mask;
+	/*
+	* Process whether use event mode, init default non-zero
+	* After the event queue of cmd event ready,
+	* can switch into event mode
+	* close device, switch into poll mode(non event mode)
+	*/
+	u8                use_events;
+	u8                toggle;
+};
+
+struct hns_roce_dev;
+
+struct hns_roce_qp {
+	struct ib_qp		ibqp;
+	struct hns_roce_buf	hr_buf;
+	struct hns_roce_wq	rq;
+	__le32			doorbell_qpn;
+	__le32			sq_signal_bits;
+	unsigned		sq_next_wqe;
+	int			sq_max_wqes_per_wr;
+	int			sq_spare_wqes;
+	struct hns_roce_wq	sq;
+
+	struct ib_umem		*umem;
+	struct hns_roce_mtt	mtt;
+	int			buff_size;
+	struct mutex		mutex;
+	u32			flags;
+	u8			port;
+	u8			sl;
+	u8			alt_port;
+	u8			atomic_rd_en;
+	u8			resp_depth;
+	u8			sq_no_prefetch;
+	u8			state;
+	u32			access_flags;
+	u32			pkey_index;
+	void			(*event)(
+					struct hns_roce_qp *,
+					enum hns_roce_event);
+	int			qpn;
+
+	atomic_t		refcount;
+	struct completion	free;
+};
+
+struct hns_roce_sqp {
+	struct hns_roce_qp	hr_qp;
+	u32			send_psn;
+};
+
+struct hns_roce_ib_iboe {
+	spinlock_t		lock;
+	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
+	struct notifier_block	nb;
+	struct notifier_block	nb_inet;
+	struct notifier_block	nb_inet6;
+	/* 16 GID is shared by 6 port in v1 engine. */
+	union ib_gid		gid_table[HNS_ROCE_MAX_GID_NUM];
+	u8			phy_port[HNS_ROCE_MAX_PORTS];
+};
+
+struct hns_roce_eq {
+	struct hns_roce_dev		*hr_dev;
+	void __iomem			*doorbell;
+
+	int				type_flag;/* Aeq:1 ceq:0 */
+	int				eqn;
+	int				entries;
+	int				log_entries;
+	int				eqe_size;
+	int				irq;
+	u16				have_irq;
+	int				log_page_size;
+	int				cons_index;
+	struct hns_roce_buf_list	*buf_list;
+};
+
+struct hns_roce_eq_table {
+	char			*irq_names;
+	struct hns_roce_eq	*eq;
+	void __iomem		**eqc_base;
+	int			have_irq;
+};
+
+struct hns_roce_caps {
+	u64	fw_ver;
+	u8	num_ports;
+	int	gid_table_len[HNS_ROCE_MAX_PORTS];
+	int	pkey_table_len[HNS_ROCE_MAX_PORTS];
+	int	local_ca_ack_delay;
+	int	num_uars;
+	int	phy_num_uars;
+	int	max_sq_sg;	/* 2 */
+	int	max_sq_inline;	/* 32 */
+	int	max_rq_sg;	/* 2 */
+	int	num_qps;	/* 256k */
+	int	max_wqes;	/* 16k */
+	int	max_sq_desc_sz;	/* 64 */
+	int	max_rq_desc_sz;	/* 64 */
+	int	max_qp_init_rdma;
+	int	max_qp_dest_rdma;
+	int	sqp_start;
+	int	num_srqs;
+	int	max_srq_wqes;
+	int	max_srq_sge;
+	int	reserved_srqs;
+	int	num_cqs;
+	int	max_cqes;
+	int	reserved_cqs;
+	int	num_aeq_vectors;	/* 1 */
+	int	num_comp_vectors;	/* 32 ceq */
+	int	num_other_vectors;
+	int	num_mtpts;
+	int	num_mtt_segs;
+	int	fmr_reserved_mtts;
+	int	reserved_mtts;
+	int	reserved_mrws;
+	int	reserved_uars;
+	int	num_pds;
+	int	reserved_pds;
+	int	mtt_entry_sz;
+	int	cq_entry_sz;
+	u32	max_msg_sz;
+	u32	page_size_cap;
+	u32	flags;
+	u32	reserved_lkey;
+	u16	stat_rate_support;
+	u8	port_width_cap[HNS_ROCE_MAX_PORTS];
+	int	max_gso_sz;
+	int	reserved_qps_cnt;
+	int	reserved_qps;
+	int	reserved_qps_base;
+	int	log_num_macs;
+	int	log_num_prios;
+
+	int	mtpt_entry_sz;
+	int	qpc_entry_sz;
+	int	irrl_entry_sz;
+	int	cqc_entry_sz;
+	int	aeqe_depth;
+	int	ceqe_depth[HNS_ROCE_COMP_VEC_NUM];
+	enum ib_mtu max_mtu;
+};
+
+struct hns_roce_hw {
+	int (*reset)(struct hns_roce_dev *hr_dev, u32 val);
+	void (*hw_profile)(struct hns_roce_dev *hr_dev);
+	int (*hw_init)(struct hns_roce_dev *hr_dev);
+	void (*hw_uninit)(struct hns_roce_dev *hr_dev);
+	void (*set_gid)(struct hns_roce_dev *hr_dev, u8 port,
+			int gid_index, union ib_gid *gid);
+	void (*set_mac)(struct hns_roce_dev *hr_dev, u8 phy_port, u8 *addr);
+	void (*set_mtu)(struct hns_roce_dev *hr_dev, u8 phy_port,
+			enum ib_mtu mtu);
+	int (*write_mtpt)(
+			void *mb_buf,
+			struct hns_roce_mr *mr,
+			int mtpt_idx);
+	void (*write_cqc)(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_cq *hr_cq,
+			void *mb_buf,
+			u64 *mtts,
+			dma_addr_t dma_handle,
+			int nent,
+			unsigned vector);
+	int (*query_qp)(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
+			int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr);
+	int (*modify_qp)(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
+			int attr_mask, enum ib_qp_state cur_state,
+			enum ib_qp_state new_state);
+	int (*destroy_qp)(struct ib_qp *ibqp);
+	int (*post_send)(struct ib_qp *ibqp, struct ib_send_wr *wr,
+					struct ib_send_wr **bad_wr);
+	int (*post_recv)(struct ib_qp *qp, struct ib_recv_wr *recv_wr,
+					struct ib_recv_wr **bad_recv_wr);
+	int (*req_notify_cq)(struct ib_cq *ibcq, enum ib_cq_notify_flags flags);
+	int (*poll_cq)(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc);
+	void	*priv;
+};
+
+struct hns_roce_dev {
+	struct ib_device	ib_dev;
+	struct platform_device  *pdev;
+	struct hns_roce_uar     priv_uar;
+	struct ib_mad_agent	*send_agent[HNS_ROCE_MAX_PORTS][2];
+	struct ib_ah		*sm_ah[HNS_ROCE_MAX_PORTS];
+	spinlock_t		sm_lock;
+	spinlock_t		cq_db_lock;
+	spinlock_t		bt_cmd_lock;
+	struct hns_roce_ib_iboe iboe;
+
+	int	irq[HNS_ROCE_MAX_IRQ_NUM];
+	void __iomem            *reg_base;
+	struct hns_roce_caps	caps;
+	struct radix_tree_root  qp_table_tree;
+
+	unsigned char
+		dev_addr[HNS_ROCE_MAX_PORTS][MAC_ADDR_OCTET_NUM];
+	u64                     fw_ver;
+	u64			sys_image_guid;
+	u32                     vendor_id;
+	u32                     vendor_part_id;
+	u32                     hw_rev;
+	void __iomem            *priv_addr;
+
+	struct hns_roce_cmdq      cmd;
+	struct hns_roce_bitmap    pd_bitmap;
+	struct hns_roce_uar_table uar_table;
+	struct hns_roce_mr_table  mr_table;
+	struct hns_roce_cq_table  cq_table;
+	struct hns_roce_qp_table  qp_table;
+	struct hns_roce_eq_table  eq_table;
+
+	int    cmd_mod;
+	int    loop_idc;
+
+	u32	ver;
+	struct hns_roce_hw *hw;
+};
+
+static inline struct hns_roce_dev *to_hr_dev(struct ib_device *ib_dev)
+{
+	return container_of(ib_dev, struct hns_roce_dev, ib_dev);
+}
+
+static inline struct hns_roce_ucontext *to_hr_ucontext(
+				struct ib_ucontext *ibucontext)
+{
+	return container_of(
+			ibucontext, struct hns_roce_ucontext,
+			ibucontext);
+}
+
+static inline struct hns_roce_pd *to_hr_pd(struct ib_pd *ibpd)
+{
+	return container_of(ibpd, struct hns_roce_pd, ibpd);
+}
+
+static inline struct hns_roce_ah *to_hr_ah(struct ib_ah *ibah)
+{
+	return container_of(ibah, struct hns_roce_ah, ibah);
+}
+
+static inline struct hns_roce_mr *to_hr_mr(struct ib_mr *ibmr)
+{
+	return container_of(ibmr, struct hns_roce_mr, ibmr);
+}
+
+static inline struct hns_roce_qp *to_hr_qp(struct ib_qp *ibqp)
+{
+	return container_of(ibqp, struct hns_roce_qp, ibqp);
+}
+
+static inline struct hns_roce_cq *to_hr_cq(struct ib_cq *ib_cq)
+{
+	return container_of(ib_cq, struct hns_roce_cq, ib_cq);
+}
+
+static inline struct hns_roce_srq *to_hr_srq(struct ib_srq *ibsrq)
+{
+	return container_of(ibsrq, struct hns_roce_srq, ibsrq);
+}
+
+static inline struct hns_roce_sqp *hr_to_hr_sqp(
+					struct hns_roce_qp *hr_qp)
+{
+	return container_of(hr_qp, struct hns_roce_sqp, hr_qp);
+}
+
+
+static inline void hns_roce_write64_k(__be32 val[2], void __iomem *dest)
+{
+	__raw_writeq(*(u64 *) val, dest);
+}
+
+static inline struct hns_roce_qp *__hns_roce_qp_lookup(
+			struct hns_roce_dev *hr_dev, u32 qpn)
+{
+	return radix_tree_lookup(&hr_dev->qp_table_tree,
+				qpn & (hr_dev->caps.num_qps - 1));
+}
+
+static inline void *hns_roce_buf_offset(struct hns_roce_buf *buf, int offset)
+{
+	if (BITS_PER_LONG == 64 || buf->nbufs == 1)
+		return (char *)(buf->direct.buf) + offset;
+	else
+		return (char *)(buf->page_list[offset >> PAGE_SHIFT].buf) +
+			(offset & (PAGE_SIZE - 1));
+}
+
+int hns_roce_init_uar_table(struct hns_roce_dev *dev);
+int hns_roce_uar_alloc(
+			struct hns_roce_dev *dev,
+			struct hns_roce_uar *uar);
+void hns_roce_uar_free(
+			struct hns_roce_dev *dev,
+			struct hns_roce_uar *uar);
+void hns_roce_cleanup_uar_table(struct hns_roce_dev *dev);
+
+int hns_roce_cmd_init(struct hns_roce_dev *hr_dev);
+void hns_roce_cmd_cleanup(struct hns_roce_dev *hr_dev);
+void hns_roce_cmd_event(struct hns_roce_dev *hr_dev,
+			u16 token, u8 status,
+			u64 out_param);
+int hns_roce_cmd_use_events(struct hns_roce_dev *hr_dev);
+void hns_roce_cmd_use_polling(struct hns_roce_dev *hr_dev);
+
+int hns_roce_mtt_init(
+			struct hns_roce_dev *hr_dev, int npages,
+			int page_shift, struct hns_roce_mtt *mtt);
+void hns_roce_mtt_cleanup(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_mtt *mtt);
+int hns_roce_buf_write_mtt(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_mtt *mtt,
+				struct hns_roce_buf *buf);
+
+int hns_roce_init_pd_table(struct hns_roce_dev *hr_dev);
+int hns_roce_init_mr_table(struct hns_roce_dev *hr_dev);
+int hns_roce_init_eq_table(struct hns_roce_dev *hr_dev);
+int hns_roce_init_cq_table(struct hns_roce_dev *hr_dev);
+int hns_roce_init_qp_table(struct hns_roce_dev *hr_dev);
+
+void hns_roce_cleanup_pd_table(struct hns_roce_dev *hr_dev);
+void hns_roce_cleanup_mr_table(struct hns_roce_dev *hr_dev);
+void hns_roce_cleanup_eq_table(struct hns_roce_dev *hr_dev);
+void hns_roce_cleanup_cq_table(struct hns_roce_dev *hr_dev);
+void hns_roce_cleanup_qp_table(struct hns_roce_dev *hr_dev);
+
+u32 hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap);
+void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, u32 obj);
+int hns_roce_bitmap_init(
+				struct hns_roce_bitmap *bitmap, u32 num,
+				u32 mask, u32 reserved_bot,
+				u32 resetrved_top);
+void hns_roce_bitmap_cleanup(struct hns_roce_bitmap *bitmap);
+void hns_roce_cleanup_bitmap(struct hns_roce_dev *hr_dev);
+u32 hns_roce_bitmap_alloc_range(
+				struct hns_roce_bitmap *bitmap,
+				int cnt, int align);
+void hns_roce_bitmap_free_range(
+				struct hns_roce_bitmap *bitmap,
+				u32 obj, int cnt);
+
+struct ib_ah *hns_roce_create_ah(
+				struct ib_pd *pd,
+				struct ib_ah_attr *ah_attr);
+int hns_roce_query_ah(struct ib_ah *ibah, struct ib_ah_attr *ah_attr);
+int hns_roce_destroy_ah(struct ib_ah *ah);
+
+struct ib_pd *hns_roce_alloc_pd(
+				struct ib_device *ib_dev,
+				struct ib_ucontext *context,
+				struct ib_udata *udata);
+int hns_roce_pd_alloc(struct hns_roce_dev *hr_dev, u32 *pdn);
+void hns_roce_pd_free(struct hns_roce_dev *hr_dev, u32 pdn);
+int hns_roce_dealloc_pd(struct ib_pd *pd);
+
+struct ib_mr *hns_roce_get_dma_mr(struct ib_pd *pd, int acc);
+struct ib_mr *hns_roce_reg_user_mr(
+					struct ib_pd *pd, u64 start,
+					u64 length, u64 virt_addr,
+					int access_flags,
+					struct ib_udata *udata);
+int hns_roce_dereg_mr(struct ib_mr *ibmr);
+
+void hns_roce_buf_free(
+			struct hns_roce_dev *hr_dev, int size,
+			struct hns_roce_buf *buf);
+int hns_roce_buf_alloc(
+			struct hns_roce_dev *hr_dev,
+			int size,
+			int max_direct,
+			struct hns_roce_buf *buf);
+
+int hns_roce_ib_umem_write_mtt(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_mtt *mtt,
+			struct ib_umem *umem);
+
+struct ib_qp *hns_roce_create_qp(
+			struct ib_pd *ib_pd,
+			struct ib_qp_init_attr *init_attr,
+			struct ib_udata *udata);
+int hns_roce_modify_qp(
+			struct ib_qp *ibqp,
+			struct ib_qp_attr *attr,
+			int attr_mask,
+			struct ib_udata *udata);
+void *get_recv_wqe(struct hns_roce_qp *hr_qp, int n);
+void *get_send_wqe(struct hns_roce_qp *hr_qp, int n);
+bool hns_roce_wq_overflow(
+			struct hns_roce_wq *hr_wq,
+			int nreq,
+			struct ib_cq *ib_cq);
+enum hns_roce_qp_state to_hns_roce_state(enum ib_qp_state state);
+void hns_roce_lock_cqs(
+			struct hns_roce_cq *send_cq,
+			struct hns_roce_cq *recv_cq);
+void hns_roce_unlock_cqs(
+				struct hns_roce_cq *send_cq,
+				struct hns_roce_cq *recv_cq);
+void hns_roce_qp_remove(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_qp *hr_qp);
+void hns_roce_qp_free(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_qp *hr_qp);
+void hns_roce_release_range_qp(
+				struct hns_roce_dev *hr_dev,
+				int base_qpn, int cnt);
+__be32 send_ieth(struct ib_send_wr *wr);
+int to_hr_qp_type(int qp_type);
+
+struct ib_cq *hns_roce_ib_create_cq(
+					struct ib_device *ib_dev,
+					const struct ib_cq_init_attr *attr,
+					struct ib_ucontext *context,
+					struct ib_udata *udata);
+int hns_roce_ib_destroy_cq(struct ib_cq *ib_cq);
+
+void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
+void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type);
+void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type);
+void hns_roce_srq_event(struct hns_roce_dev *hr_dev, u32 srqn, int event_type);
+int hns_get_gid_index(struct hns_roce_dev *hr_dev, u8 port, int gid_index);
+
+extern struct hns_roce_hw hns_roce_v1_hw;
+
+#endif /* _HNS_ROCE_DEVICE_H */
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c
new file mode 100644
index 0000000..39e53ed
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c
@@ -0,0 +1,835 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/dma-mapping.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+#include "hns_roce_eq.h"
+
+static void eq_set_cons_index(struct hns_roce_eq *eq, int req_not)
+{
+	__raw_writel((__force u32)
+		cpu_to_le32((eq->cons_index & CONS_INDEX_MASK) |
+		(req_not << eq->log_entries)), eq->doorbell);
+	/* Memory barrier */
+	mb();
+}
+
+static struct hns_roce_aeqe *get_aeqe(struct hns_roce_eq *eq, u32 entry)
+{
+	unsigned long off =
+		(entry & (eq->entries - 1)) * HNS_ROCE_AEQ_ENTRY_SIZE;
+
+	return eq->buf_list[off / HNS_ROCE_BA_SIZE].buf +
+		off % HNS_ROCE_BA_SIZE;
+}
+
+static struct hns_roce_aeqe *next_aeqe_sw(struct hns_roce_eq *eq)
+{
+	struct hns_roce_aeqe *aeqe = get_aeqe(eq, eq->cons_index);
+
+	return (!!(roce_get_bit(aeqe->asyn, HNS_ROCE_AEQE_U32_4_OWNER_S)) ^
+		!!(eq->cons_index & eq->entries)) ? aeqe : NULL;
+}
+
+static int hns_roce_aeq_int(struct hns_roce_dev *hr_dev, struct hns_roce_eq *eq)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_aeqe *aeqe;
+	int aeqes_found = 0;
+	int set_ci = 0;
+	int port = 0;
+	int qpn = 0;
+
+	while ((aeqe = next_aeqe_sw(eq))) {
+		dev_dbg(dev,
+			"aeqe = %p, aeqe->asyn.event_type = 0x%lx\n", aeqe,
+			roce_get_field(aeqe->asyn,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
+		/* Memory barrier */
+		rmb();
+
+		switch (roce_get_field(aeqe->asyn,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S)) {
+		case HNS_ROCE_EVENT_TYPE_PATH_MIG:
+			dev_warn(dev, "PATH MIG not supported\n");
+			break;
+		case HNS_ROCE_EVENT_TYPE_COMM_EST:
+			dev_warn(dev, "COMMUNICATION ESTABLISHED\n");
+			break;
+		case HNS_ROCE_EVENT_TYPE_SQ_DRAINED:
+			dev_warn(dev, "SQ DRAINED not supported\n");
+			break;
+		case HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED:
+			dev_warn(dev, "PATH MIG FAILED\n");
+			break;
+		case HNS_ROCE_EVENT_TYPE_INV_REQ_LOCAL_WQ_ERROR:
+			dev_warn(dev, "qpn = 0x%lx\n",
+			roce_get_field(aeqe->event.qp_event.qp,
+				HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
+				HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S));
+			hns_roce_qp_event(hr_dev,
+				roce_get_field(aeqe->event.qp_event.qp,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S),
+				roce_get_field(aeqe->asyn,
+					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_WQ_CATAS_ERROR:
+			qpn = roce_get_field(aeqe->event.qp_event.qp,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S);
+			dev_warn(dev,
+				"Local Work Queue Catastrophic Error.\n");
+			switch (roce_get_field(aeqe->asyn,
+					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_M,
+					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S)) {
+			case HNS_ROCE_LWQCE_QPC_ERROR:
+				dev_warn(dev,
+					"QP %d, QPC error.\n", qpn);
+				break;
+			case HNS_ROCE_LWQCE_MTU_ERROR:
+				dev_warn(dev,
+					"QP %d, MTU error.\n", qpn);
+				break;
+			case HNS_ROCE_LWQCE_WQE_BA_ADDR_ERROR:
+				dev_warn(dev,
+					"QP %d, WQE BA addr error.\n", qpn);
+				break;
+			case HNS_ROCE_LWQCE_WQE_ADDR_ERROR:
+				dev_warn(dev, "QP %d, WQE addr error.\n", qpn);
+				break;
+			case HNS_ROCE_LWQCE_SQ_WQE_SHIFT_ERROR:
+				dev_warn(dev, "QP %d, WQE shift error\n", qpn);
+				break;
+			case HNS_ROCE_LWQCE_SL_ERROR:
+				dev_warn(dev, "QP %d, SL error.\n", qpn);
+				break;
+			case HNS_ROCE_LWQCE_PORT_ERROR:
+				dev_warn(dev, "QP %d, port error.\n", qpn);
+				break;
+			default:
+				break;
+			}
+
+			hns_roce_qp_event(hr_dev,
+				roce_get_field(aeqe->event.qp_event.qp,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S),
+				roce_get_field(aeqe->asyn,
+					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_LOCAL_WQ_ACCESS_ERROR:
+			qpn = roce_get_field(aeqe->event.qp_event.qp,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S);
+			dev_warn(dev,
+				"Local Access Violation Work Queue Error.\n");
+			switch (roce_get_field(aeqe->asyn,
+					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_M,
+					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S)) {
+			case HNS_ROCE_LAVWQE_R_KEY_VIOLATION:
+				dev_warn(dev, "QP %d, R_key violation.\n", qpn);
+				break;
+			case HNS_ROCE_LAVWQE_LENGTH_ERROR:
+				dev_warn(dev, "QP %d, length error.\n", qpn);
+				break;
+			case HNS_ROCE_LAVWQE_VA_ERROR:
+				dev_warn(dev, "QP %d, VA error.\n", qpn);
+				break;
+			case HNS_ROCE_LAVWQE_PD_ERROR:
+				dev_err(dev, "QP %d, PD error.\n", qpn);
+				break;
+			case HNS_ROCE_LAVWQE_RW_ACC_ERROR:
+				dev_warn(dev, "QP %d, rw acc error.\n", qpn);
+				break;
+			case HNS_ROCE_LAVWQE_KEY_STATE_ERROR:
+				dev_warn(dev, "QP %d, key state error.\n", qpn);
+				break;
+			case HNS_ROCE_LAVWQE_MR_OPERATION_ERROR:
+				dev_warn(dev,
+					"QP %d, MR operation error.\n", qpn);
+				break;
+			default:
+				break;
+			}
+
+			hns_roce_qp_event(hr_dev,
+				roce_get_field(aeqe->event.qp_event.qp,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
+					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S),
+				roce_get_field(aeqe->asyn,
+					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_SRQ_LIMIT_REACH:
+		case HNS_ROCE_EVENT_TYPE_SRQ_CATAS_ERROR:
+		case HNS_ROCE_EVENT_TYPE_SRQ_LAST_WQE_REACH:
+			dev_warn(dev, "SRQ not support!\n");
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR:
+			dev_warn(dev, "CQ 0x%lx access err.\n",
+			roce_get_field(aeqe->event.cq_event.cq,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S));
+			hns_roce_cq_event(hr_dev,
+			le32_to_cpu(roce_get_field(aeqe->event.cq_event.cq,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S)),
+			roce_get_field(aeqe->asyn,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW:
+			dev_warn(dev, "CQ 0x%lx overflow\n",
+			roce_get_field(aeqe->event.cq_event.cq,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S));
+			hns_roce_cq_event(hr_dev,
+			le32_to_cpu(roce_get_field(aeqe->event.cq_event.cq,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S)),
+			roce_get_field(aeqe->asyn,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID:
+			dev_warn(dev, "CQ ID invalid.\n");
+			hns_roce_cq_event(hr_dev,
+			le32_to_cpu(roce_get_field(aeqe->event.cq_event.cq,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
+				HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S)),
+			roce_get_field(aeqe->asyn,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+				HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_PORT_CHANGE:
+			dev_warn(dev, "port change.\n");
+			port = le32_to_cpu(
+			roce_get_field(aeqe->event.port_event.port,
+				HNS_ROCE_AEQE_EVENT_PORT_EVENT_PORT_PORT_NUM_M,
+				HNS_ROCE_AEQE_EVENT_PORT_EVENT_PORT_PORT_NUM_S)
+				);
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_MB:
+			hns_roce_cmd_event(
+					hr_dev,
+					le16_to_cpu(aeqe->event.cmd.token),
+					aeqe->event.cmd.status,
+					le64_to_cpu(aeqe->event.cmd.out_param));
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_DB_OVERFLOW:
+			switch (roce_get_field(aeqe->asyn,
+					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_M,
+					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S)) {
+			case HNS_ROCE_DB_SUBTYPE_SDB_OVF:
+				dev_warn(dev, "SDB overflow.\n");
+				break;
+
+			case HNS_ROCE_DB_SUBTYPE_SDB_ALM_OVF:
+				dev_warn(dev, "SDB almost overflow.\n");
+				break;
+
+			case HNS_ROCE_DB_SUBTYPE_SDB_ALM_EMP:
+				dev_warn(dev, "SDB almost empty.\n");
+				break;
+
+			case HNS_ROCE_DB_SUBTYPE_ODB_OVF:
+				dev_warn(dev, "ODB overflow.\n");
+				break;
+
+			case HNS_ROCE_DB_SUBTYPE_ODB_ALM_OVF:
+				dev_warn(dev, "ODB almost overflow.\n");
+				break;
+
+			case HNS_ROCE_DB_SUBTYPE_ODB_ALM_EMP:
+				dev_warn(dev, "SDB almost empty.\n");
+				break;
+			default:
+				break;
+			}
+
+			break;
+
+		case HNS_ROCE_EVENT_TYPE_CEQ_OVERFLOW:
+			dev_warn(dev, "CEQ 0x%lx OVERFLOW EVENT.\n",
+			roce_get_field(aeqe->event.ce_event.ceqe,
+				HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_M,
+				HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_S));
+			break;
+
+		default:
+			dev_warn(dev,
+				"Unhandled event 0x%lx on EQ %d at index %u\n",
+				roce_get_field(aeqe->asyn,
+					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
+					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S),
+				eq->eqn, eq->cons_index);
+			break;
+		};
+
+		eq->cons_index++;
+		aeqes_found = 1;
+		set_ci++;
+
+		if (eq->cons_index > 2 * hr_dev->caps.aeqe_depth - 1) {
+			dev_warn(dev,
+				"cons_index overflow, set back to zero\n");
+			eq->cons_index = 0;
+			set_ci = 0;
+		}
+	}
+
+	eq_set_cons_index(eq, 0);
+
+	return aeqes_found;
+}
+
+static struct hns_roce_ceqe *get_ceqe(struct hns_roce_eq *eq, u32 entry)
+{
+	unsigned long off = (entry & (eq->entries - 1)) *
+			HNS_ROCE_CEQ_ENTRY_SIZE;
+
+	return (struct hns_roce_ceqe *)(
+			(u8 *)(eq->buf_list[off / HNS_ROCE_BA_SIZE].buf) +
+			off % HNS_ROCE_BA_SIZE);
+}
+
+static struct hns_roce_ceqe *next_ceqe_sw(struct hns_roce_eq *eq)
+{
+	struct hns_roce_ceqe *ceqe = get_ceqe(eq, eq->cons_index);
+
+	return ((!!(roce_get_bit(ceqe->ceqe.comp,
+		HNS_ROCE_CEQE_CEQE_COMP_OWNER_S))) ^
+		(!!(eq->cons_index & eq->entries)) ? ceqe : NULL);
+}
+
+static int hns_roce_ceq_int(struct hns_roce_dev *hr_dev, struct hns_roce_eq *eq)
+{
+	struct hns_roce_ceqe *ceqe;
+	int ceqes_found = 0;
+	int set_ci = 0;
+	int cqn;
+
+	while ((ceqe = next_ceqe_sw(eq))) {
+		/* Memory barrier */
+		rmb();
+		cqn = roce_get_field(ceqe->ceqe.comp,
+			HNS_ROCE_CEQE_CEQE_COMP_CQN_M,
+			HNS_ROCE_CEQE_CEQE_COMP_CQN_S);
+		hns_roce_cq_completion(hr_dev, cqn);
+
+		++eq->cons_index;
+		ceqes_found = 1;
+		++set_ci;
+
+		if (eq->cons_index > 2 * hr_dev->caps.ceqe_depth[eq->eqn] - 1) {
+			dev_warn(&eq->hr_dev->pdev->dev,
+				"cons_index overflow, set back to zero\n");
+			eq->cons_index = 0;
+			set_ci = 0;
+		}
+	}
+
+	eq_set_cons_index(eq, 0);
+
+	return ceqes_found;
+
+}
+
+static int hns_roce_aeq_ovf_int(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_eq *eq)
+{
+	struct device *dev = &eq->hr_dev->pdev->dev;
+	int eqovf_found = 0;
+	u32 caepaemask_val;
+	u32 cealmovf_val;
+	u32 caepaest_val;
+	u32 aeshift_val;
+	u32 ceshift_val;
+	u32 cemask_val;
+	int i = 0;
+
+	/**
+	* AEQ overflow ECC mult bit err CEQ overflow alarm
+	* must clear interrupt, mask irq, clear irq, cancel mask operation
+	*/
+	aeshift_val = roce_readl(hr_dev->reg_base +
+				ROCEE_CAEP_AEQC_AEQE_SHIFT_REG);
+
+	if (roce_get_bit(aeshift_val,
+		ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQ_ALM_OVF_INT_ST_S) ==
+		1) {
+		dev_warn(dev, "AEQ overflow!\n");
+
+		/* Set mask */
+		caepaemask_val = roce_readl(hr_dev->reg_base +
+			ROCEE_CAEP_AE_MASK_REG);
+		roce_set_bit(caepaemask_val,
+			ROCEE_CAEP_AE_MASK_CAEP_AEQ_ALM_OVF_MASK_S,
+			HNS_ROCE_INT_MASK_ENABLE);
+		roce_writel(
+			caepaemask_val,
+			hr_dev->reg_base + ROCEE_CAEP_AE_MASK_REG);
+
+		/* Clear int state(INT_WC : write 1 clear) */
+		caepaest_val = roce_readl(hr_dev->reg_base +
+			ROCEE_CAEP_AE_ST_REG);
+		roce_set_bit(caepaest_val,
+			ROCEE_CAEP_AE_ST_CAEP_AEQ_ALM_OVF_S, 1);
+		roce_writel(caepaest_val, hr_dev->reg_base +
+			ROCEE_CAEP_AE_ST_REG);
+
+		/* Clear mask */
+		caepaemask_val = roce_readl(hr_dev->reg_base +
+			ROCEE_CAEP_AE_MASK_REG);
+		roce_set_bit(caepaemask_val,
+			ROCEE_CAEP_AE_MASK_CAEP_AEQ_ALM_OVF_MASK_S,
+			HNS_ROCE_INT_MASK_DISABLE);
+		roce_writel(caepaemask_val, hr_dev->reg_base +
+			ROCEE_CAEP_AE_MASK_REG);
+	}
+
+	/* CEQ almost overflow */
+	for (i = 0; i < hr_dev->caps.num_comp_vectors; i++) {
+		ceshift_val = roce_readl(hr_dev->reg_base +
+			ROCEE_CAEP_CEQC_SHIFT_0_REG + i * CEQ_REG_OFFSET);
+		if (roce_get_bit(ceshift_val,
+		ROCEE_CAEP_CEQC_SHIFT_CAEP_CEQ_ALM_OVF_INT_ST_S) == 1) {
+			dev_warn(dev, "CEQ[%d] almost overflow!\n", i);
+			eqovf_found++;
+
+			/* Set mask */
+			cemask_val = roce_readl(hr_dev->reg_base +
+				ROCEE_CAEP_CE_IRQ_MASK_0_REG +
+				i * CEQ_REG_OFFSET);
+			roce_set_bit(cemask_val,
+			ROCEE_CAEP_CE_IRQ_MASK_CAEP_CEQ_ALM_OVF_MASK_S,
+			HNS_ROCE_INT_MASK_ENABLE);
+			roce_writel(
+				cemask_val, hr_dev->reg_base +
+				ROCEE_CAEP_CE_IRQ_MASK_0_REG +
+				i * CEQ_REG_OFFSET);
+
+			/* Clear int state(INT_WC : write 1 clear) */
+			cealmovf_val = roce_readl(hr_dev->reg_base +
+				ROCEE_CAEP_CEQ_ALM_OVF_0_REG +
+				i * CEQ_REG_OFFSET);
+			roce_set_bit(cealmovf_val,
+			ROCEE_CAEP_CEQ_ALM_OVF_CAEP_CEQ_ALM_OVF_S, 1);
+			roce_writel(cealmovf_val, hr_dev->reg_base +
+				ROCEE_CAEP_CEQ_ALM_OVF_0_REG +
+				i * CEQ_REG_OFFSET);
+
+			/* Clear mask */
+			cemask_val = roce_readl(hr_dev->reg_base +
+				ROCEE_CAEP_CE_IRQ_MASK_0_REG +
+				i * CEQ_REG_OFFSET);
+			roce_set_bit(cemask_val,
+			ROCEE_CAEP_CE_IRQ_MASK_CAEP_CEQ_ALM_OVF_MASK_S,
+			HNS_ROCE_INT_MASK_DISABLE);
+			roce_writel(cemask_val, hr_dev->reg_base +
+				ROCEE_CAEP_CE_IRQ_MASK_0_REG +
+				i * CEQ_REG_OFFSET);
+		}
+	}
+
+	/* ECC multi-bit error alarm */
+	dev_warn(dev, "ECC UCERR ALARM: 0x%x, 0x%x, 0x%x\n",
+		roce_readl(hr_dev->reg_base + ROCEE_ECC_UCERR_ALM0_REG),
+		roce_readl(hr_dev->reg_base + ROCEE_ECC_UCERR_ALM1_REG),
+		roce_readl(hr_dev->reg_base + ROCEE_ECC_UCERR_ALM2_REG));
+	dev_warn(dev, "ECC CERR ALARM: 0x%x, 0x%x, 0x%x\n",
+		roce_readl(hr_dev->reg_base + ROCEE_ECC_CERR_ALM0_REG),
+		roce_readl(hr_dev->reg_base + ROCEE_ECC_CERR_ALM1_REG),
+		roce_readl(hr_dev->reg_base + ROCEE_ECC_CERR_ALM2_REG));
+
+	return eqovf_found;
+}
+
+static int hns_roce_eq_int(struct hns_roce_dev *hr_dev, struct hns_roce_eq *eq)
+{
+	int eqes_found = 0;
+
+	if (likely(eq->type_flag == HNS_ROCE_CEQ))
+		/* CEQ irq routine, CEQ is pulse irq, not clear */
+		eqes_found = hns_roce_ceq_int(hr_dev, eq);
+	else if (likely(eq->type_flag == HNS_ROCE_AEQ))
+		/* AEQ irq routine, AEQ is pulse irq, not clear */
+		eqes_found = hns_roce_aeq_int(hr_dev, eq);
+	else
+		/* AEQ queue overflow irq */
+		eqes_found = hns_roce_aeq_ovf_int(hr_dev, eq);
+
+	return eqes_found;
+}
+
+static irqreturn_t hns_roce_msi_x_interrupt(int irq, void *eq_ptr)
+{
+	struct hns_roce_eq  *eq  = eq_ptr;
+	struct hns_roce_dev *hr_dev = eq->hr_dev;
+
+	hns_roce_eq_int(hr_dev, eq);
+
+	return IRQ_HANDLED;
+}
+
+static void hns_roce_enable_eq(
+					struct hns_roce_dev *hr_dev,
+					int eq_num,
+					int enable_flag)
+{
+	void __iomem *eqc = hr_dev->eq_table.eqc_base[eq_num];
+	u32 val;
+
+	val = roce_readl(eqc);
+	if (enable_flag)
+		roce_set_field(val,
+			ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M,
+			ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S,
+			HNS_ROCE_EQ_STAT_VALID);
+	else
+		roce_set_field(val,
+			ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M,
+			ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S,
+			HNS_ROCE_EQ_STAT_INVALID);
+	roce_writel(val, eqc);
+}
+
+static int hns_roce_create_eq(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_eq *eq)
+{
+	void __iomem *eqc = hr_dev->eq_table.eqc_base[eq->eqn];
+	struct device *dev = &hr_dev->pdev->dev;
+	dma_addr_t tmp_dma_addr;
+	u32 eqconsindx_val = 0;
+	u32 eqcuridx_val = 0;
+	u32 eqshift_val = 0;
+	int num_bas = 0;
+	int ret;
+	int i;
+
+	num_bas = (PAGE_ALIGN(eq->entries * eq->eqe_size) +
+		HNS_ROCE_BA_SIZE - 1) / HNS_ROCE_BA_SIZE;
+
+	if ((eq->entries * eq->eqe_size) > HNS_ROCE_BA_SIZE) {
+		dev_err(dev,
+			"[error]eq buf %d gt ba size(%d) need bas=%d\n",
+			(eq->entries * eq->eqe_size),
+			HNS_ROCE_BA_SIZE, num_bas);
+		dev_err(dev, "only support 32k CQ use CEQ!\n");
+		return -EINVAL;
+	}
+
+	eq->buf_list =
+		kzalloc(num_bas * sizeof(*eq->buf_list), GFP_KERNEL);
+	if (!eq->buf_list) {
+		dev_err(dev, "eq buf_list alloc failed\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < num_bas; ++i) {
+		eq->buf_list[i].buf =
+			dma_alloc_coherent(
+					dev, HNS_ROCE_BA_SIZE,
+					&tmp_dma_addr,
+					GFP_KERNEL);
+		if (!eq->buf_list[i].buf) {
+			ret = -ENOMEM;
+			dev_err(dev, "eq buf_list buf alloc failed!\n");
+			goto err_out_free_pages;
+		}
+
+		eq->buf_list[i].map = tmp_dma_addr;
+		memset(eq->buf_list[i].buf, 0, HNS_ROCE_BA_SIZE);
+	}
+
+	eq->cons_index = 0;
+	roce_set_field(eqshift_val,
+		ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M,
+		ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S,
+		HNS_ROCE_EQ_STAT_INVALID);
+	roce_set_field(eqshift_val,
+		ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_M,
+		ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_S,
+		eq->log_entries);
+	roce_writel(eqshift_val, eqc);
+
+	/* Configure eq extended address 12~44bit */
+	roce_writel((u32)
+		(eq->buf_list[0].map >> ADDR_SHIFT_12), eqc + 4);
+
+	/* Configure eq extended address 45~49 bit, producer index */
+	roce_set_field(eqcuridx_val,
+		ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_M,
+		ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_S,
+		eq->buf_list[0].map >> ADDR_SHIFT_44);
+	roce_set_field(eqcuridx_val,
+		ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_M,
+		ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_S,
+		0);
+	roce_writel(eqcuridx_val, eqc + 8);
+
+	/* Configure eq consumer index */
+	roce_set_field(eqconsindx_val,
+		ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_M,
+		ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_S,
+		0);
+	roce_writel(eqconsindx_val, eqc + 0xc);
+	return 0;
+
+err_out_free_pages:
+	for (i = 0; i < num_bas; ++i)
+		if (eq->buf_list[i].buf)
+			dma_free_coherent(
+				dev, HNS_ROCE_BA_SIZE,
+				eq->buf_list[i].buf,
+				eq->buf_list[i].map);
+
+	kfree(eq->buf_list);
+
+	return ret;
+}
+
+static void hns_roce_free_eq(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_eq *eq)
+{
+	int i = 0;
+	int npages = (PAGE_ALIGN(eq->eqe_size * eq->entries) +
+		HNS_ROCE_BA_SIZE - 1) / HNS_ROCE_BA_SIZE;
+
+	if (!eq->buf_list)
+		return;
+
+	for (i = 0; i < npages; ++i)
+		if (eq->buf_list[i].buf)
+			dma_free_coherent(&(hr_dev->pdev->dev),
+				HNS_ROCE_BA_SIZE,
+				eq->buf_list[i].buf, eq->buf_list[i].map);
+
+	kfree(eq->buf_list);
+}
+
+void hns_roce_int_mask_en(struct hns_roce_dev *hr_dev)
+{
+	void __iomem *reg_caepceirqmsk;
+	void __iomem *reg_caepaemsk;
+	int i = 0;
+	u32 aemask_val;
+	u32 cemask_val;
+	int masken = 0;
+
+	/* AEQ INT */
+	reg_caepaemsk = (void *)((char *)hr_dev->reg_base +
+			ROCEE_CAEP_AE_MASK_REG);
+
+	aemask_val = roce_readl(reg_caepaemsk);
+	roce_set_bit(aemask_val,
+		ROCEE_CAEP_AE_MASK_CAEP_AEQ_ALM_OVF_MASK_S, masken);
+	roce_set_bit(aemask_val,
+		ROCEE_CAEP_AE_MASK_CAEP_AE_IRQ_MASK_S, masken);
+	roce_writel(aemask_val, reg_caepaemsk);
+
+	/* CEQ INT */
+	for (i = 0; i < hr_dev->caps.num_comp_vectors; i++) {
+
+		/* IRQ mask */
+		reg_caepceirqmsk = (void *)((char *)hr_dev->reg_base +
+			ROCEE_CAEP_CE_IRQ_MASK_0_REG + i * CEQ_REG_OFFSET);
+		cemask_val = roce_readl(reg_caepceirqmsk);
+		roce_set_bit(cemask_val,
+			ROCEE_CAEP_CE_IRQ_MASK_CAEP_CE_IRQ_MASK_S,
+			masken);
+		roce_set_bit(cemask_val,
+			ROCEE_CAEP_CE_IRQ_MASK_CAEP_CEQ_ALM_OVF_MASK_S,
+			masken);
+		roce_writel(masken, reg_caepceirqmsk);
+	}
+}
+
+void hns_roce_ce_int_default_cfg(struct hns_roce_dev *hr_dev)
+{
+	/* Configure ce int interval */
+	roce_writel(
+		HNS_ROCE_CEQ_DEFAULT_INTERVAL,
+		hr_dev->reg_base + ROCEE_CAEP_CE_INTERVAL_CFG_REG);
+
+	/* Configure ce int burst num */
+	roce_writel(
+		HNS_ROCE_CEQ_DEFAULT_BURST_NUM,
+		hr_dev->reg_base + ROCEE_CAEP_CE_BURST_NUM_CFG_REG);
+}
+
+int hns_roce_init_eq_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_eq_table *eq_table = &hr_dev->eq_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_eq *eq = NULL;
+	const char *eq_name = NULL;
+	int eq_num = 0;
+	int ret = 0;
+	int i = 0;
+
+	eq_num = hr_dev->caps.num_comp_vectors + hr_dev->caps.num_aeq_vectors;
+	eq_table->eq =
+		kzalloc(eq_num * sizeof(*eq_table->eq),
+			GFP_KERNEL);
+	if (!eq_table->eq) {
+		dev_err(dev, "eq alloc failed!\n");
+		return -ENOMEM;
+	}
+
+	eq_table->eqc_base =
+		kzalloc(eq_num * sizeof(*eq_table->eqc_base),
+			GFP_KERNEL);
+	if (!eq_table->eqc_base) {
+		ret = -ENOMEM;
+		dev_err(dev, "eqc_base alloc failed!\n");
+		goto err_eqc_base_alloc_fail;
+	}
+
+	eq_table->irq_names = kzalloc(eq_num * IRQ_NAMES_LEN, GFP_KERNEL);
+	if (!eq_table->irq_names) {
+		ret = -ENOMEM;
+		dev_err(dev, "irq_names alloc failed!\n");
+		goto err_irq_name_alloc_fail;
+	}
+
+	for (i = 0; i < eq_num; i++) {
+		eq = &eq_table->eq[i];
+		eq->hr_dev = hr_dev;
+		eq->eqn = i;
+		eq->irq = hr_dev->irq[i];
+		eq->log_page_size = PAGE_SHIFT;
+
+		if (i < hr_dev->caps.num_comp_vectors) {
+			/* CEQ */
+			eq_table->eqc_base[i] = hr_dev->reg_base +
+				ROCEE_CAEP_CEQC_SHIFT_0_REG +
+				HNS_ROCE_CEQC_REG_OFFSET * i;
+			snprintf(eq_table->irq_names + i * IRQ_NAMES_LEN,
+				IRQ_NAMES_LEN,
+				"hns-roce-comp-%d", i);
+			eq->type_flag = HNS_ROCE_CEQ;
+			eq->doorbell = hr_dev->reg_base +
+				ROCEE_CAEP_CEQC_CONS_IDX_0_REG +
+				HNS_ROCE_CEQC_REG_OFFSET * i;
+			eq->entries = hr_dev->caps.ceqe_depth[i];
+			eq->log_entries = ilog2(eq->entries);
+			eq->eqe_size = sizeof(struct hns_roce_ceqe);
+		} else {
+			/* AEQ */
+			eq_table->eqc_base[i] = hr_dev->reg_base +
+				ROCEE_CAEP_AEQC_AEQE_SHIFT_REG;
+			snprintf(eq_table->irq_names + i * IRQ_NAMES_LEN,
+				IRQ_NAMES_LEN,
+				"hns-roce-async-%d",
+				i - hr_dev->caps.num_comp_vectors);
+			eq->type_flag = HNS_ROCE_AEQ;
+			eq->doorbell = hr_dev->reg_base +
+				ROCEE_CAEP_AEQE_CONS_IDX_REG;
+			eq->entries = hr_dev->caps.aeqe_depth;
+			eq->log_entries = ilog2(eq->entries);
+			eq->eqe_size = sizeof(struct hns_roce_aeqe);
+		}
+	}
+
+	/* Disable irq */
+	hns_roce_int_mask_en(hr_dev);
+
+	/* Configure CE irq interval and burst num */
+	hns_roce_ce_int_default_cfg(hr_dev);
+
+	for (i = 0; i < eq_num; i++) {
+		ret = hns_roce_create_eq(hr_dev, &eq_table->eq[i]);
+		if (ret) {
+			dev_err(dev, "eq create failed\n");
+			goto err_create_eq_fail;
+		}
+
+		eq_name = eq_table->irq_names + i * IRQ_NAMES_LEN;
+		ret = request_irq(eq_table->eq[i].irq,
+				  hns_roce_msi_x_interrupt, 0, eq_name,
+				  eq_table->eq + i);
+		if (ret) {
+			dev_err(dev, "request irq error!\n");
+			goto err_create_eq_fail;
+		}
+
+		eq_table->eq[i].have_irq = 1;
+
+		hns_roce_enable_eq(hr_dev, i, EQ_ENABLE);
+	}
+
+	return 0;
+
+err_create_eq_fail:
+	for (i = 0; i < eq_num; i++) {
+		/* Disable EQ */
+		hns_roce_enable_eq(hr_dev, i, EQ_DISABLE);
+
+		if (eq_table->eq[i].have_irq)
+			free_irq(eq_table->eq[i].irq, eq_table->eq + i);
+
+		hns_roce_free_eq(hr_dev, &eq_table->eq[i]);
+	}
+
+	kfree(eq_table->irq_names);
+
+err_irq_name_alloc_fail:
+	kfree(eq_table->eqc_base);
+
+err_eqc_base_alloc_fail:
+	kfree(eq_table->eq);
+
+	return ret;
+}
+
+void hns_roce_cleanup_eq_table(struct hns_roce_dev *hr_dev)
+{
+	int i;
+	int eq_num;
+	struct hns_roce_eq_table *eq_table = &hr_dev->eq_table;
+
+	eq_num = hr_dev->caps.num_comp_vectors + hr_dev->caps.num_aeq_vectors;
+	for (i = 0; i < eq_num; i++) {
+		/* Disable EQ */
+		hns_roce_enable_eq(hr_dev, i, EQ_DISABLE);
+
+		if (eq_table->eq[i].have_irq)
+			free_irq(eq_table->eq[i].irq, eq_table->eq + i);
+
+		hns_roce_free_eq(hr_dev, &eq_table->eq[i]);
+	}
+
+	kfree(eq_table->irq_names);
+	kfree(eq_table->eqc_base);
+	kfree(eq_table->eq);
+}
+
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h b/drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h
new file mode 100644
index 0000000..a92e4ac
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h
@@ -0,0 +1,138 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_EQ_H
+#define _HNS_ROCE_EQ_H
+
+#define HNS_ROCE_CEQ		1
+#define HNS_ROCE_AEQ		2
+#define HNS_ROCE_AEQ_OVF	3
+
+#define	HNS_ROCE_NUM_SPARE_EQE		0x80
+#define	HNS_ROCE_CEQ_ENTRY_SIZE		0x4
+#define	HNS_ROCE_AEQ_ENTRY_SIZE		0x10
+#define	HNS_ROCE_CEQC_REG_OFFSET	0x18
+
+#define HNS_ROCE_CEQ_DEFAULT_INTERVAL    0x10
+#define HNS_ROCE_CEQ_DEFAULT_BURST_NUM   0x10
+
+#define HNS_ROCE_ASYNC_EVENT_MASK  \
+		((1ULL << HNS_ROCE_EVENT_TYPE_PATH_MIG)			| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_COMM_EST)			| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_SQ_DRAINED)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_WQ_CATAS_ERROR)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_INV_REQ_LOCAL_WQ_ERROR)	| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_LOCAL_WQ_ACCESS_ERROR)	| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_SRQ_LIMIT_REACH)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_SRQ_LAST_WQE_REACH)	| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_SRQ_CATAS_ERROR)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_PORT_ACTIVE)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_PORT_CHANGE)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_LOCAL_CATAS_ERROR)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_PORT_ERROR)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_DB_OVERFLOW)		| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_MB)			| \
+		(1ULL << HNS_ROCE_EVENT_TYPE_CEQ_OVERFLOW))
+
+#define	HNS_ROCE_INT_MASK_DISABLE	0
+#define	HNS_ROCE_INT_MASK_ENABLE	1
+
+#define IRQ_NAMES_LEN			32
+#define EQ_ENABLE			1
+#define EQ_DISABLE			0
+#define CONS_INDEX_MASK			0xffff
+
+#define CEQ_REG_OFFSET			0x18
+
+enum {
+	HNS_ROCE_EQ_STAT_INVALID  = 0,
+	HNS_ROCE_EQ_STAT_RESD     = 1,
+	HNS_ROCE_EQ_STAT_VALID    = 2,
+	HNS_ROCE_EQ_STAT_ERR      = 3
+};
+
+struct hns_roce_aeqe {
+
+	u32 asyn;
+	union {
+		struct {
+			u32 qp;
+			u32 rsv0;
+			u32 rsv1;
+		} qp_event;
+
+		struct {
+			u32 cq;
+			u32 rsv0;
+			u32 rsv1;
+		} cq_event;
+
+		struct {
+			u32 port;
+			u32 rsv0;
+			u32 rsv1;
+		} port_event;
+
+		struct {
+			u32 ceqe;
+			u32 rsv0;
+			u32 rsv1;
+		} ce_event;
+
+		struct {
+			__le64  out_param;
+			__le16  token;
+			u8	status;
+			u8	rsv0;
+		} __packed cmd;
+	 } event;
+};
+#define HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S 16
+#define HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M   \
+	(((1UL << 8) - 1) << HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S)
+
+#define HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S 24
+#define HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_M   \
+	(((1UL << 7) - 1) << HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S)
+
+#define HNS_ROCE_AEQE_U32_4_OWNER_S 31
+
+#define HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S 0
+#define HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M   \
+	(((1UL << 24) - 1) << HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S)
+
+#define HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S 0
+#define HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M   \
+	(((1UL << 16) - 1) << HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S)
+
+#define HNS_ROCE_AEQE_EVENT_PORT_EVENT_PORT_PORT_NUM_S 0
+#define HNS_ROCE_AEQE_EVENT_PORT_EVENT_PORT_PORT_NUM_M   \
+	(((1UL << 3) - 1) << HNS_ROCE_AEQE_EVENT_PORT_EVENT_PORT_PORT_NUM_S)
+
+#define HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_S 0
+#define HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_M   \
+	(((1UL << 5) - 1) << HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_S)
+
+struct hns_roce_ceqe {
+	union {
+		int		raw[1];
+		int		comp;
+	} ceqe;
+};
+
+#define HNS_ROCE_CEQE_CEQE_COMP_OWNER_S	0
+
+#define HNS_ROCE_CEQE_CEQE_COMP_CQN_S 16
+#define HNS_ROCE_CEQE_CEQE_COMP_CQN_M   \
+	(((1UL << 16) - 1) << HNS_ROCE_CEQE_CEQE_COMP_CQN_S)
+#endif /* _HNS_ROCE_EQ_H */
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c
new file mode 100644
index 0000000..110a128
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c
@@ -0,0 +1,637 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <linux/scatterlist.h>
+
+#include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+#include "hns_roce_icm.h"
+#include "hns_roce_common.h"
+
+#define HW_SYNC_TIMEOUT_MSECS		500
+
+#define HNS_ROCE_ICM_ALLOC_SIZE		(1 << 17)
+#define HNS_ROCE_TABLE_CHUNK_SIZE	(1 << 17)
+
+#define DMA_ADDR_T_SHIFT		12
+#define BT_CMD_SYNC_SHIFT		31
+#define BT_BA_SHIFT			32
+
+static void hns_roce_free_icm_pages(
+					struct hns_roce_dev *hr_dev,
+					struct hns_roce_icm_chunk *chunk)
+{
+	int i;
+
+	if (chunk->nsg > 0)
+		dma_unmap_sg(&(hr_dev->pdev->dev), chunk->mem, chunk->npages,
+			     0);
+
+	for (i = 0; i < chunk->npages; ++i)
+		__free_pages(sg_page(&chunk->mem[i]),
+			     get_order(chunk->mem[i].length));
+}
+
+static void hns_roce_free_icm_coherent(
+					struct hns_roce_dev *hr_dev,
+					struct hns_roce_icm_chunk *chunk)
+{
+	int i;
+
+	for (i = 0; i < chunk->npages; ++i)
+		dma_free_coherent(&hr_dev->pdev->dev, chunk->mem[i].length,
+				  lowmem_page_address(sg_page(&chunk->mem[i])),
+				  sg_dma_address(&chunk->mem[i]));
+}
+
+void hns_roce_free_icm(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm *icm, int coherent)
+{
+	struct hns_roce_icm_chunk *chunk, *tmp;
+
+	if (!icm)
+		return;
+
+	list_for_each_entry_safe(chunk, tmp, &icm->chunk_list, list) {
+		if (coherent)
+			hns_roce_free_icm_coherent(hr_dev, chunk);
+		else
+			hns_roce_free_icm_pages(hr_dev, chunk);
+
+		kfree(chunk);
+	}
+
+	kfree(icm);
+}
+
+static int hns_roce_alloc_icm_pages(
+					struct scatterlist *mem,
+					int order, gfp_t gfp_mask)
+{
+	struct page *page;
+
+	page = alloc_pages(gfp_mask, order);
+	if (!page)
+		return -ENOMEM;
+
+	sg_set_page(mem, page, PAGE_SIZE << order, 0);
+
+	return 0;
+}
+
+static int hns_roce_alloc_icm_coherent(
+					struct device *dev,
+					struct scatterlist *mem,
+					int order, gfp_t gfp_mask)
+{
+	void *buf = dma_alloc_coherent(dev, PAGE_SIZE << order,
+				       &sg_dma_address(mem),
+				       gfp_mask);
+	if (!buf) {
+		dev_err(dev, "alloc coherent icm pages failed.\n");
+		return -ENOMEM;
+	}
+
+	sg_set_buf(mem, buf, PAGE_SIZE << order);
+	BUG_ON(mem->offset);
+	sg_dma_len(mem) = PAGE_SIZE << order;
+	return 0;
+}
+
+struct hns_roce_icm *hns_roce_alloc_icm(
+					struct hns_roce_dev *hr_dev,
+					int npages, gfp_t gfp_mask,
+					int coherent)
+{
+	struct hns_roce_icm_chunk *chunk = NULL;
+	struct hns_roce_icm *icm;
+	int cur_order;
+	int ret;
+
+	BUG_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
+
+	icm =
+	kmalloc(sizeof(*icm), gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
+	if (!icm)
+		return NULL;
+
+	icm->refcount = 0;
+	INIT_LIST_HEAD(&icm->chunk_list);
+
+	cur_order = get_order(HNS_ROCE_ICM_ALLOC_SIZE);
+
+	while (npages > 0) {
+		if (!chunk) {
+			chunk =
+			kmalloc(sizeof(*chunk),
+				gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
+			if (!chunk)
+				goto fail;
+
+			sg_init_table(chunk->mem, HNS_ROCE_ICM_CHUNK_LEN);
+			chunk->npages = 0;
+			chunk->nsg    = 0;
+			list_add_tail(&chunk->list, &icm->chunk_list);
+		}
+
+		while (1 << cur_order > npages)
+			--cur_order;
+
+		if (coherent)
+			ret = hns_roce_alloc_icm_coherent(
+						&hr_dev->pdev->dev,
+						&chunk->mem[chunk->npages],
+						cur_order, gfp_mask);
+		else
+			ret =
+			hns_roce_alloc_icm_pages(
+						&chunk->mem[chunk->npages],
+						cur_order, gfp_mask);
+
+		if (!ret) {
+			++chunk->npages;
+
+			if (coherent) {
+				++chunk->nsg;
+			} else if (chunk->npages == HNS_ROCE_ICM_CHUNK_LEN) {
+				chunk->nsg = dma_map_sg(
+						&hr_dev->pdev->dev,
+						chunk->mem, chunk->npages, 0);
+
+				if (chunk->nsg <= 0)
+					goto fail;
+
+				chunk = NULL;
+			}
+			npages -= 1 << cur_order;
+		} else {
+			/*
+			* If failed on alloc 128k memory one time,
+			* no alloc small block memory,
+			* directly return fail
+			*/
+			dev_err(&hr_dev->pdev->dev, "**alloc 128K phy mem failed**\n");
+			goto fail;
+		}
+	}
+
+	if (!coherent && chunk) {
+		chunk->nsg = dma_map_sg(
+				&hr_dev->pdev->dev, chunk->mem, chunk->npages,
+				0);
+
+		if (chunk->nsg <= 0)
+			goto fail;
+	}
+
+	return icm;
+
+fail:
+	hns_roce_free_icm(hr_dev, icm, coherent);
+	return NULL;
+}
+
+int hns_roce_map_icm(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table,
+			int obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	spinlock_t *lock = &hr_dev->bt_cmd_lock;
+	unsigned long end = 0, flags = 0;
+	struct hns_roce_icm_iter iter;
+	void __iomem *bt_cmd = NULL;
+	u32 bt_cmd_h_val = 0;
+	u32 bt_cmd_val[2];
+	u32 bt_cmd_l = 0;
+	u64 bt_ba = 0;
+	int ret = 0;
+
+	/* Find the icm entry */
+	int i = (obj & (table->num_obj - 1)) /
+		(HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size);
+
+	switch (table->type) {
+	case ICM_TYPE_QPC:
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			ICM_TYPE_QPC);
+		break;
+	case ICM_TYPE_MTPT:
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			ICM_TYPE_MTPT);
+		break;
+	case ICM_TYPE_CQC:
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			ICM_TYPE_CQC);
+		break;
+	case ICM_TYPE_SRQC:
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			ICM_TYPE_SRQC);
+		break;
+	default:
+		return ret;
+	}
+	roce_set_field(bt_cmd_h_val,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S, obj);
+	roce_set_bit(bt_cmd_h_val,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_S, 0);
+	roce_set_bit(bt_cmd_h_val,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_HW_SYNS_S,
+		1);
+
+	/* Currently iter only a chunk */
+	for (hns_roce_icm_first(table->icm[i], &iter);
+		!hns_roce_icm_last(&iter);
+		hns_roce_icm_next(&iter)) {
+		bt_ba = hns_roce_icm_addr(&iter) >> DMA_ADDR_T_SHIFT;
+
+		spin_lock_irqsave(lock, flags);
+
+		bt_cmd = hr_dev->reg_base + ROCEE_BT_CMD_H_REG;
+
+		end = msecs_to_jiffies(HW_SYNC_TIMEOUT_MSECS) + jiffies;
+		while (1) {
+			if (roce_readl(bt_cmd) >> BT_CMD_SYNC_SHIFT) {
+				if (!(time_before(jiffies, end))) {
+					dev_err(dev,
+						"Write bt_cmd err,hw_sync is not zero.\n");
+					spin_unlock_irqrestore(lock, flags);
+					ret = -EBUSY;
+					return ret;
+				}
+			} else {
+				break;
+			}
+		}
+
+		bt_cmd_l = (u32)bt_ba;
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_S,
+			bt_ba >> BT_BA_SHIFT);
+
+		bt_cmd_val[0] = bt_cmd_l;
+		bt_cmd_val[1] = bt_cmd_h_val;
+		hns_roce_write64_k(
+				bt_cmd_val,
+				hr_dev->reg_base + ROCEE_BT_CMD_L_REG);
+		spin_unlock_irqrestore(lock, flags);
+	}
+
+	return ret;
+}
+
+int hns_roce_unmap_icm(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_icm_table *table,
+				int obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned long end = 0, flags = 0;
+	void __iomem *bt_cmd = NULL;
+	uint32_t bt_cmd_val[2];
+	u32 bt_cmd_h_val = 0;
+	int ret = 0;
+
+	switch (table->type) {
+	case ICM_TYPE_QPC:
+		dev_dbg(dev, "UNMAP QPC BT  :\n");
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			ICM_TYPE_QPC);
+		break;
+	case ICM_TYPE_MTPT:
+		dev_dbg(dev, "UNMAP MTPT BT :\n");
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			ICM_TYPE_MTPT);
+		break;
+	case ICM_TYPE_CQC:
+		dev_dbg(dev, "UNMAP CQC BT  :\n");
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			ICM_TYPE_CQC);
+		break;
+	case ICM_TYPE_SRQC:
+		roce_set_field(bt_cmd_h_val,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			ICM_TYPE_SRQC);
+		break;
+	default:
+		return ret;
+	}
+	roce_set_field(bt_cmd_h_val,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S, obj);
+	roce_set_bit(bt_cmd_h_val,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_S, 1);
+	roce_set_bit(bt_cmd_h_val,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_HW_SYNS_S, 1);
+	roce_set_field(bt_cmd_h_val,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_M,
+		ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_S, 0);
+
+	spin_lock_irqsave(&hr_dev->bt_cmd_lock, flags);
+
+	bt_cmd = hr_dev->reg_base + ROCEE_BT_CMD_H_REG;
+
+	end = msecs_to_jiffies(HW_SYNC_TIMEOUT_MSECS) + jiffies;
+	while (1) {
+		if (roce_readl(bt_cmd) >> BT_CMD_SYNC_SHIFT) {
+			if (!(time_before(jiffies, end))) {
+				dev_err(dev,
+					"Write bt_cmd err,hw_sync is not zero.\n");
+				spin_unlock_irqrestore(
+					&hr_dev->bt_cmd_lock, flags);
+				return -EBUSY;
+			}
+		} else {
+			break;
+		}
+	}
+
+	bt_cmd_val[0] = 0;
+	bt_cmd_val[1] = bt_cmd_h_val;
+	hns_roce_write64_k(bt_cmd_val, hr_dev->reg_base + ROCEE_BT_CMD_L_REG);
+	spin_unlock_irqrestore(&hr_dev->bt_cmd_lock, flags);
+
+	return ret;
+}
+
+int hns_roce_table_get(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table,
+			int obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret = 0;
+	int i;
+
+	i = (obj & (table->num_obj - 1)) /
+		(HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size);
+
+	mutex_lock(&table->mutex);
+
+	if (table->icm[i]) {
+		++table->icm[i]->refcount;
+		goto out;
+	}
+
+	table->icm[i] = hns_roce_alloc_icm(hr_dev,
+		HNS_ROCE_TABLE_CHUNK_SIZE >> PAGE_SHIFT,
+		(table->lowmem ? GFP_KERNEL : GFP_HIGHUSER) | __GFP_NOWARN,
+		table->coherent);
+	if (!table->icm[i]) {
+		ret = -ENOMEM;
+		dev_err(dev, "hns_roce_alloc_icm failed\n");
+		goto out;
+	}
+
+	/* Inform icm entry mem pa(128K/page, pa starting address)for hw */
+	if (hns_roce_map_icm(hr_dev, table, obj)) {
+		ret = -ENODEV;
+		dev_err(dev, "map icm table failed.\n");
+		goto out;
+	}
+
+	++table->icm[i]->refcount;
+
+out:
+	mutex_unlock(&table->mutex);
+	return ret;
+}
+
+void hns_roce_table_put(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table,
+			int obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	int i;
+
+	i = (obj & (table->num_obj - 1)) /
+		(HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size);
+
+	mutex_lock(&table->mutex);
+
+	if (--table->icm[i]->refcount == 0) {
+		/* Clear base address table */
+		if (hns_roce_unmap_icm(hr_dev, table, obj))
+			dev_warn(dev, "unmap icm table failed.\n");
+
+		hns_roce_free_icm(hr_dev, table->icm[i], table->coherent);
+		table->icm[i] = NULL;
+	}
+
+	mutex_unlock(&table->mutex);
+}
+
+void *hns_roce_table_find(
+				struct hns_roce_icm_table *table,
+				int obj, dma_addr_t *dma_handle)
+{
+	struct hns_roce_icm_chunk *chunk;
+	int idx, offset, dma_offset, i;
+	struct hns_roce_icm *icm;
+	struct page *page = NULL;
+
+	if (!table->lowmem)
+		return NULL;
+
+	mutex_lock(&table->mutex);
+
+	idx = (obj & (table->num_obj - 1)) * table->obj_size;
+	icm = table->icm[idx / HNS_ROCE_TABLE_CHUNK_SIZE];
+	dma_offset = offset = idx % HNS_ROCE_TABLE_CHUNK_SIZE;
+
+	if (!icm)
+		goto out;
+
+	list_for_each_entry(chunk, &icm->chunk_list, list) {
+		for (i = 0; i < chunk->npages; ++i) {
+			if (dma_handle && dma_offset >= 0) {
+				if (sg_dma_len(&chunk->mem[i]) > dma_offset)
+					*dma_handle =
+					sg_dma_address(&chunk->mem[i]) +
+							dma_offset;
+				dma_offset -= sg_dma_len(&chunk->mem[i]);
+			}
+
+			if (chunk->mem[i].length > offset) {
+				page = sg_page(&chunk->mem[i]);
+				goto out;
+			}
+			offset -= chunk->mem[i].length;
+		}
+	}
+
+out:
+	mutex_unlock(&table->mutex);
+	return page ? lowmem_page_address(page) + offset : NULL;
+}
+
+int hns_roce_table_get_range(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_icm_table *table,
+				int start, int end)
+{
+	int inc = HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size;
+	int i = 0, ret = 0;
+
+	/* Allocate MTT entry memory according to chunk(128K) */
+	for (i = start; i <= end; i += inc) {
+		ret = hns_roce_table_get(hr_dev, table, i);
+		if (ret)
+			goto fail;
+	}
+
+	return 0;
+
+fail:
+	while (i > start) {
+		i -= inc;
+		hns_roce_table_put(hr_dev, table, i);
+	}
+
+	return ret;
+}
+
+void hns_roce_table_put_range(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_icm_table *table,
+				int start, int end)
+{
+	int i;
+
+	for (i = start; i <= end;
+		i += HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size)
+		hns_roce_table_put(hr_dev, table, i);
+}
+
+int hns_roce_init_icm_table(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_icm_table *table,
+				u32 type, int obj_size, int nobj,
+				int reserved, int use_lowmem,
+				int use_coherent)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned chunk_size;
+	int obj_per_chunk;
+	int num_icm;
+	int i;
+
+	obj_per_chunk = HNS_ROCE_TABLE_CHUNK_SIZE / obj_size;
+	num_icm = (nobj + obj_per_chunk - 1) / obj_per_chunk;
+
+	table->icm = kcalloc(num_icm, sizeof(*table->icm), GFP_KERNEL);
+	if (!table->icm)
+		return -ENOMEM;
+
+	table->type     = type;
+	table->num_icm  = num_icm;
+	table->num_obj  = nobj;
+	table->obj_size = obj_size;
+	table->lowmem   = use_lowmem;
+	table->coherent = use_coherent;
+	mutex_init(&table->mutex);
+
+	for (i = 0;
+	i * HNS_ROCE_TABLE_CHUNK_SIZE < reserved * obj_size; ++i) {
+		chunk_size = HNS_ROCE_TABLE_CHUNK_SIZE;
+		if ((i + 1) * HNS_ROCE_TABLE_CHUNK_SIZE > nobj * obj_size)
+			chunk_size = PAGE_ALIGN(
+					nobj * obj_size -
+					i * HNS_ROCE_TABLE_CHUNK_SIZE);
+
+		table->icm[i] = hns_roce_alloc_icm(hr_dev,
+				chunk_size >> PAGE_SHIFT,
+				(use_lowmem ?
+				GFP_KERNEL : GFP_HIGHUSER) | __GFP_NOWARN,
+				use_coherent);
+		if (!table->icm[i])
+			goto _error_failed_alloc_icm;
+
+		if (hns_roce_map_icm(hr_dev, table,
+			i * HNS_ROCE_TABLE_CHUNK_SIZE/obj_size)) {
+			dev_err(dev, "map icm table failed.\n");
+			goto _error_failed_map_icm;
+		}
+
+		/*
+		 * Add a reference to this ICM chunk so that it never
+		 * Gets freed (since it contains reserved firmware objects).
+		 */
+		++table->icm[i]->refcount;
+	}
+
+	return 0;
+
+_error_failed_map_icm:
+_error_failed_alloc_icm:
+	for (i = 0; i < num_icm; ++i)
+		if (table->icm[i]) {
+			if (hns_roce_unmap_icm(hr_dev, table,
+				i * HNS_ROCE_TABLE_CHUNK_SIZE/obj_size))
+				dev_err(dev, "unmap icm table failed.\n");
+
+			hns_roce_free_icm(hr_dev, table->icm[i], use_coherent);
+		}
+
+	return -ENOMEM;
+}
+
+void hns_roce_cleanup_icm_table(
+					struct hns_roce_dev *hr_dev,
+					struct hns_roce_icm_table *table)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	int i;
+
+	for (i = 0; i < table->num_icm; ++i)
+		if (table->icm[i]) {
+			if (hns_roce_unmap_icm(hr_dev, table,
+			i * HNS_ROCE_TABLE_CHUNK_SIZE/table->obj_size))
+				dev_err(dev, "unmap icm table failed.\n");
+
+			hns_roce_free_icm(hr_dev,
+					table->icm[i], table->coherent);
+		}
+
+	kfree(table->icm);
+}
+
+void hns_roce_cleanup_icm(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->cq_table.table);
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->qp_table.irrl_table);
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->qp_table.qp_table);
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->mr_table.mtpt_table);
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->mr_table.mtt_table);
+
+}
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h b/drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h
new file mode 100644
index 0000000..7a7b3fb
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h
@@ -0,0 +1,130 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_ICM_H
+#define _HNS_ROCE_ICM_H
+
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/pci.h>
+
+enum {
+	/* MAP ICM */
+	ICM_TYPE_QPC = 0,
+	ICM_TYPE_MTPT,
+	ICM_TYPE_CQC,
+	ICM_TYPE_SRQC,
+
+	/* UNMAP ICM */
+	ICM_TYPE_MTT,
+	ICM_TYPE_IRRL,
+};
+
+#define HNS_ROCE_ICM_CHUNK_LEN	\
+	((256 - sizeof(struct list_head) - 2 * sizeof(int)) /	\
+	(sizeof(struct scatterlist)))
+
+enum {
+	HNS_ROCE_ICM_PAGE_SHIFT	= 12,
+	HNS_ROCE_ICM_PAGE_SIZE	= 1 << HNS_ROCE_ICM_PAGE_SHIFT,
+};
+
+struct hns_roce_icm_chunk {
+	struct list_head	list;
+	int			npages;
+	int			nsg;
+	struct scatterlist	mem[HNS_ROCE_ICM_CHUNK_LEN];
+};
+
+struct hns_roce_icm {
+	struct list_head	chunk_list;
+	int			refcount;
+};
+
+struct hns_roce_icm_iter {
+	struct hns_roce_icm	        *icm;
+	struct hns_roce_icm_chunk	*chunk;
+	int				page_idx;
+};
+
+void hns_roce_free_icm(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm *icm,
+			int coherent);
+int hns_roce_table_get(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table,
+			int obj);
+void hns_roce_table_put(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table,
+			int obj);
+void *hns_roce_table_find(
+			struct hns_roce_icm_table *table,
+			int obj, dma_addr_t *dma_handle);
+int hns_roce_table_get_range(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table,
+			int start, int end);
+void hns_roce_table_put_range(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table,
+			int start, int end);
+int hns_roce_init_icm_table(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table,
+			u32 type, int obj_size, int nobj,
+			int reserved, int use_lowmem,
+			int use_coherent);
+void hns_roce_cleanup_icm_table(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table);
+void hns_roce_cleanup_icm(struct hns_roce_dev *hr_dev);
+
+static inline void hns_roce_icm_first(
+			struct hns_roce_icm *icm,
+			struct hns_roce_icm_iter *iter)
+{
+	iter->icm      = icm;
+	iter->chunk    = list_empty(&icm->chunk_list) ? NULL :
+			list_entry(icm->chunk_list.next,
+				struct hns_roce_icm_chunk, list);
+	iter->page_idx = 0;
+}
+
+static inline int hns_roce_icm_last(struct hns_roce_icm_iter *iter)
+{
+	return !iter->chunk;
+}
+
+static inline void hns_roce_icm_next(struct hns_roce_icm_iter *iter)
+{
+	if (++iter->page_idx >= iter->chunk->nsg) {
+		if (iter->chunk->list.next == &iter->icm->chunk_list) {
+			iter->chunk = NULL;
+			return;
+		}
+
+		iter->chunk = list_entry(iter->chunk->list.next,
+				struct hns_roce_icm_chunk, list);
+		iter->page_idx = 0;
+	}
+}
+
+static inline dma_addr_t hns_roce_icm_addr(struct hns_roce_icm_iter *iter)
+{
+	return sg_dma_address(&iter->chunk->mem[iter->page_idx]);
+}
+
+static inline unsigned long hns_roce_icm_size(struct hns_roce_icm_iter *iter)
+{
+	return sg_dma_len(&iter->chunk->mem[iter->page_idx]);
+}
+
+#endif /*_HNS_ROCE_ICM_H*/
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c
new file mode 100644
index 0000000..75b2820
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c
@@ -0,0 +1,1147 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * Authors: Wei Hu <xavier.huwei@huawei.com>
+ * Authors: Znlong <zhaonenglong@hisilicon.com>
+ * Authors: oulijun <oulijun@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/cdev.h>
+#include <linux/delay.h>
+#include <linux/device.h>
+#include <linux/dma-mapping.h>
+#include <linux/ethtool.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_net.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+#include <rdma/ib_addr.h>
+#include <rdma/ib_smi.h>
+#include <rdma/ib_umem.h>
+#include <rdma/ib_user_verbs.h>
+#include <rdma/ib_verbs.h>
+
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+#include "hns_roce_user.h"
+#include "hns_roce_icm.h"
+
+/**
+ * hns_roce_addrconf_ifid_eui48 - Get default gid.
+ * @eui: eui.
+ * @vlan_id:  gid
+ * @dev:  net device
+ * Description:
+ *    MAC convert to GID
+ *        gid[0..7] = fe80 0000 0000 0000
+ *        gid[8] = mac[0] ^ 2
+ *        gid[9] = mac[1]
+ *        gid[10] = mac[2]
+ *        gid[11] = ff        (VLAN ID high byte (4 MS bits))
+ *        gid[12] = fe        (VLAN ID low byte)
+ *        gid[13] = mac[3]
+ *        gid[14] = mac[4]
+ *        gid[15] = mac[5]
+ */
+static void hns_roce_addrconf_ifid_eui48(u8 *eui, u16 vlan_id,
+				     struct net_device *dev)
+{
+	memcpy(eui, dev->dev_addr, 3);
+	memcpy(eui + 5, dev->dev_addr + 3, 3);
+	if (vlan_id < 0x1000) {
+		eui[3] = vlan_id >> 8;
+		eui[4] = vlan_id & 0xff;
+	} else {
+		eui[3] = 0xff;
+		eui[4] = 0xfe;
+	}
+	eui[0] ^= 2;
+}
+
+void hns_roce_make_default_gid(struct net_device *dev, union ib_gid *gid)
+{
+	gid->global.subnet_prefix = cpu_to_be64(0xfe80000000000000LL);
+	hns_roce_addrconf_ifid_eui48(&gid->raw[8], 0xffff, dev);
+}
+
+/**
+ * hns_get_gid_index - Get gid index.
+ * @hr_dev: pointer to structure hns_roce_dev.
+ * @port:  port, value range: 0 ~ MAX
+ * @gid_index:  gid_index, value range: 0 ~ MAX
+ * Description:
+ *    N ports shared gids, allocation method as follow:
+ *		GID[0][0], GID[1][0],.....GID[N - 1][0],
+ *		GID[0][0], GID[1][0],.....GID[N - 1][0],
+ *		And so on
+ */
+int hns_get_gid_index(struct hns_roce_dev *hr_dev, u8 port, int gid_index)
+{
+	return gid_index * hr_dev->caps.num_ports + port;
+}
+
+int hns_roce_set_gid(
+			struct hns_roce_dev *hr_dev,
+			u8 port, int gid_index,
+			union ib_gid *gid)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u8 gid_idx = 0;
+
+	if (gid_index >= hr_dev->caps.gid_table_len[port]) {
+		dev_err(dev,
+			"gid_index %d illegal, port %d gid range: 0~%d\n",
+			gid_index, port, hr_dev->caps.gid_table_len[port]-1);
+		return -EINVAL;
+	}
+
+	gid_idx = hns_get_gid_index(hr_dev, port, gid_index);
+
+	if (!memcmp(gid, &hr_dev->iboe.gid_table[gid_idx], sizeof(*gid)))
+		return -EINVAL;
+
+	memcpy(&hr_dev->iboe.gid_table[gid_idx], gid, sizeof(*gid));
+
+	hr_dev->hw->set_gid(hr_dev, port, gid_index, gid);
+
+	return 0;
+}
+
+void hns_roce_set_mac(struct hns_roce_dev *hr_dev, u8 port, u8 *addr)
+{
+	u8 phy_port;
+	u32 i = 0;
+
+	if (!memcmp(hr_dev->dev_addr[port], addr, MAC_ADDR_OCTET_NUM))
+		return;
+
+	for (i = 0; i < MAC_ADDR_OCTET_NUM; i++)
+		hr_dev->dev_addr[port][i] = addr[i];
+
+	phy_port = hr_dev->iboe.phy_port[port];
+
+	hr_dev->hw->set_mac(hr_dev, phy_port, addr);
+}
+
+void hns_roce_set_mtu(struct hns_roce_dev *hr_dev, u8 port, u32 mtu)
+{
+	u8 phy_port = hr_dev->iboe.phy_port[port];
+	enum ib_mtu tmp;
+
+	tmp = iboe_get_mtu(mtu);
+	if (!tmp)
+		tmp = IB_MTU_256;
+
+	hr_dev->hw->set_mtu(hr_dev, phy_port, tmp);
+}
+
+int hns_roce_update_gids(struct hns_roce_dev *hr_dev, int port)
+{
+	struct ib_event event;
+
+	/* Refresh gid in ib_cache */
+	event.device = &hr_dev->ib_dev;
+	event.element.port_num = port + 1;
+	event.event = IB_EVENT_GID_CHANGE;
+	ib_dispatch_event(&event);
+
+	return 0;
+}
+
+static int handle_en_event(
+				struct hns_roce_dev *hr_dev,
+				u8 port,
+				unsigned long event)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct net_device *netdev;
+	unsigned long flags;
+	union ib_gid gid;
+	int ret = 0;
+
+	netdev = hr_dev->iboe.netdevs[port];
+	if (!netdev) {
+		dev_err(dev, "port(%d) can't find netdev\n", port);
+		return -ENODEV;
+	}
+
+	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+
+	switch (event) {
+	case NETDEV_UP:
+	case NETDEV_CHANGE:
+	case NETDEV_REGISTER:
+	case NETDEV_CHANGEADDR:
+		hns_roce_set_mac(hr_dev, port, netdev->dev_addr);
+		hns_roce_make_default_gid(netdev, &gid);
+		ret = hns_roce_set_gid(hr_dev, port, 0, &gid);
+		if (!ret)
+			hns_roce_update_gids(hr_dev, port);
+		break;
+	case NETDEV_DOWN:
+		/*
+		* In v1 engine, only support all ports closed together.
+		*/
+		break;
+	default:
+		dev_dbg(dev, "NETDEV event = 0x%x!\n", (u32)(event));
+		break;
+	}
+
+	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+	return ret;
+}
+
+static int hns_roce_netdev_event(
+					struct notifier_block *self,
+					unsigned long event,
+					void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct hns_roce_ib_iboe *iboe = NULL;
+	struct hns_roce_dev *hr_dev = NULL;
+	u8 port = 0;
+
+	hr_dev = container_of(self, struct hns_roce_dev, iboe.nb);
+	iboe = &hr_dev->iboe;
+
+	for (port = 0; port < hr_dev->caps.num_ports; port++) {
+		if (dev == iboe->netdevs[port]) {
+			handle_en_event(hr_dev, port, event);
+			break;
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
+static void hns_roce_addr_event(
+				int event, struct net_device *event_netdev,
+				struct hns_roce_dev *hr_dev,
+				union ib_gid *gid)
+{
+	struct hns_roce_ib_iboe *iboe = NULL;
+	int gid_table_len = 0;
+	unsigned long flags;
+	union ib_gid zgid;
+	u8 gid_idx = 0;
+	u8 port = 0;
+	int i = 0;
+	int free;
+	struct net_device *real_dev = rdma_vlan_dev_real_dev(event_netdev) ?
+				rdma_vlan_dev_real_dev(event_netdev) :
+				event_netdev;
+
+	if (event != NETDEV_UP && event != NETDEV_DOWN)
+		return;
+
+	iboe = &hr_dev->iboe;
+	while (port < hr_dev->caps.num_ports) {
+		if (real_dev == iboe->netdevs[port])
+			break;
+		port++;
+	}
+
+	if (port >= hr_dev->caps.num_ports) {
+		dev_dbg(&hr_dev->pdev->dev, "can't find netdev\n");
+		return;
+	}
+
+	memset(zgid.raw, 0, sizeof(zgid.raw));
+	free = -1;
+	gid_table_len = hr_dev->caps.gid_table_len[port];
+
+	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+
+	for (i = 0; i < gid_table_len; i++) {
+		gid_idx = hns_get_gid_index(hr_dev, port, i);
+		if (!memcmp(gid->raw,
+			iboe->gid_table[gid_idx].raw, sizeof(gid->raw)))
+			break;
+		if (free < 0 && !memcmp(zgid.raw,
+			iboe->gid_table[gid_idx].raw, sizeof(zgid.raw)))
+			free = i;
+	}
+
+	if (i >= gid_table_len) {
+		if (free < 0) {
+			spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+			dev_dbg(&hr_dev->pdev->dev,
+				"gid_index overflow, port(%d)\n", port);
+			return;
+		}
+		if (!hns_roce_set_gid(hr_dev, port, free, gid))
+			hns_roce_update_gids(hr_dev, port);
+	} else if (event == NETDEV_DOWN) {
+		if (!hns_roce_set_gid(hr_dev, port, i, &zgid))
+			hns_roce_update_gids(hr_dev, port);
+	}
+
+	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+}
+
+static int hns_roce_inet_event(
+				struct notifier_block *self,
+				unsigned long event,
+				void *ptr)
+{
+	struct in_ifaddr *ifa = ptr;
+	struct hns_roce_dev *hr_dev;
+	struct net_device *dev = ifa->ifa_dev->dev;
+	union ib_gid gid;
+
+	ipv6_addr_set_v4mapped(ifa->ifa_address, (struct in6_addr *)&gid);
+
+	hr_dev = container_of(self, struct hns_roce_dev, iboe.nb_inet);
+
+	hns_roce_addr_event(event, dev, hr_dev, &gid);
+	return NOTIFY_DONE;
+}
+
+int hns_roce_setup_mtu_gids(struct hns_roce_dev  *hr_dev)
+{
+	struct in_ifaddr *ifa_list = NULL;
+	union ib_gid gid = {{0} };
+	u32 ipaddr = 0;
+	int index = 0;
+	u8 i = 0;
+
+	for (i = 0; i < hr_dev->caps.num_ports; i++) {
+		hns_roce_set_mtu(hr_dev, i, hr_dev->caps.max_mtu);
+		hns_roce_set_mac(hr_dev, i, hr_dev->iboe.netdevs[i]->dev_addr);
+
+		if (hr_dev->iboe.netdevs[i]->ip_ptr) {
+			ifa_list = hr_dev->iboe.netdevs[i]->ip_ptr->ifa_list;
+			index = 1;
+			while (ifa_list) {
+				ipaddr = ifa_list->ifa_address;
+				ipv6_addr_set_v4mapped(
+						ipaddr,
+						(struct in6_addr *)&gid);
+				hns_roce_set_gid(hr_dev, i, index, &gid);
+				index++;
+				ifa_list = ifa_list->ifa_next;
+			}
+			hns_roce_update_gids(hr_dev, i);
+		}
+	}
+
+	return 0;
+}
+
+static int hns_roce_query_device(
+				struct ib_device *ib_dev,
+				struct ib_device_attr *props,
+				struct ib_udata *uhw)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+
+	memset(props, 0, sizeof(*props));
+
+	props->fw_ver = hr_dev->fw_ver;
+	props->sys_image_guid = hr_dev->sys_image_guid;
+	props->max_mr_size = (u64)(~(0ULL));
+	props->page_size_cap = hr_dev->caps.page_size_cap;
+	props->vendor_id = hr_dev->vendor_id;
+	props->vendor_part_id = hr_dev->vendor_part_id;
+	props->hw_ver = hr_dev->hw_rev;
+	props->max_qp = hr_dev->caps.num_qps;
+	props->max_qp_wr = hr_dev->caps.max_wqes;
+	props->device_cap_flags = IB_DEVICE_PORT_ACTIVE_EVENT
+		|IB_DEVICE_RC_RNR_NAK_GEN
+		|IB_DEVICE_LOCAL_DMA_LKEY;
+	props->max_sge = hr_dev->caps.max_sq_sg;
+	props->max_sge_rd = 1;
+	props->max_cq = hr_dev->caps.num_cqs;
+	props->max_cqe = hr_dev->caps.max_cqes;
+	props->max_mr = hr_dev->caps.num_mtpts;
+	props->max_pd = hr_dev->caps.num_pds;
+	props->max_qp_rd_atom = hr_dev->caps.max_qp_dest_rdma;
+	props->max_ee_rd_atom = 0;
+	props->max_res_rd_atom = 0;
+	props->max_qp_init_rd_atom = hr_dev->caps.max_qp_init_rdma;
+	props->max_ee_init_rd_atom = 0;
+	props->atomic_cap = IB_ATOMIC_NONE;
+	props->max_ee = 0;
+	props->max_rdd = 0;
+	props->max_mw = 0;
+	props->max_raw_ipv6_qp = 0;
+	props->max_raw_ethy_qp = 0;
+	props->max_mcast_grp = 0;
+	props->max_mcast_qp_attach = 0;
+	props->max_total_mcast_qp_attach = 0;
+	props->max_ah = 0;
+	props->max_fmr = 0;
+	props->max_map_per_fmr = 0;
+	props->max_srq = 0;
+	props->max_srq_wr = 0;
+	props->max_srq_sge = 0;
+	props->max_fast_reg_page_list_len = 0;
+	props->max_pkeys = 1;
+	props->local_ca_ack_delay = hr_dev->caps.local_ca_ack_delay;
+
+	return 0;
+}
+
+static int hns_roce_query_port(
+				struct ib_device *ib_dev, u8 port_num,
+				struct ib_port_attr *props)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct net_device *net_dev;
+	unsigned long flags;
+	enum ib_mtu mtu;
+	u8 port;
+
+	assert(port_num > 0);
+	port = port_num - 1;
+
+	memset(props, 0, sizeof(*props));
+
+	props->max_mtu          = hr_dev->caps.max_mtu;
+	props->gid_tbl_len	= hr_dev->caps.gid_table_len[port];
+	props->port_cap_flags   = IB_PORT_CM_SUP | IB_PORT_REINIT_SUP |
+		IB_PORT_VENDOR_CLASS_SUP | IB_PORT_BOOT_MGMT_SUP;
+	props->max_msg_sz       = HNS_ROCE_MAX_MSG_LEN;
+	props->bad_pkey_cntr	= 0;
+	props->qkey_viol_cntr	= 0;
+	props->pkey_tbl_len	= 1;
+	props->lid		= 0;
+	props->sm_lid		= 0;
+	props->lmc		= 0;
+	props->max_vl_num	= 0;
+	props->sm_sl		= 0;
+	props->subnet_timeout	= 0;
+	props->init_type_reply	= 0;
+	props->active_width	= IB_WIDTH_4X;
+	props->active_speed	= 1;
+
+	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+
+	net_dev = hr_dev->iboe.netdevs[port];
+	if (!net_dev) {
+		spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+		dev_err(dev, "find netdev %d failed!\r\n", port);
+		return -EINVAL;
+	}
+
+	mtu = iboe_get_mtu(net_dev->mtu);
+	props->active_mtu = mtu ? min(props->max_mtu, mtu) : IB_MTU_256;
+	props->state =
+		(netif_running(net_dev) && netif_carrier_ok(net_dev)) ?
+		IB_PORT_ACTIVE : IB_PORT_DOWN;
+	props->phys_state = (props->state == IB_PORT_ACTIVE) ? 5 : 3;
+
+	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+
+	return 0;
+}
+
+static enum rdma_link_layer hns_roce_get_link_layer(
+			struct ib_device *device, u8 port_num)
+{
+	return IB_LINK_LAYER_ETHERNET;
+}
+
+static int hns_roce_query_gid(
+				struct ib_device *ib_dev,
+				u8 port_num, int index,
+				union ib_gid *gid)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+	struct device *dev = &hr_dev->pdev->dev;
+	u8 gid_idx = 0;
+	u8 port;
+
+	if (port_num == 0 ||
+	port_num > hr_dev->caps.num_ports ||
+	index >= hr_dev->caps.gid_table_len[port_num-1]) {
+		dev_err(dev,
+		"port_num %d index %d illegal! correct range: port_num 1~%d index 0~%d!\n",
+		port_num, index, hr_dev->caps.num_ports,
+		hr_dev->caps.gid_table_len[port_num-1]-1);
+		return -EINVAL;
+	}
+
+	port = port_num - 1;
+	gid_idx = hns_get_gid_index(hr_dev, port, index);
+	if (gid_idx >= HNS_ROCE_MAX_GID_NUM) {
+		dev_err(dev,
+			"port_num %d index %d illegal! total gid num %d!\n",
+			port_num, index, HNS_ROCE_MAX_GID_NUM);
+		return -EINVAL;
+	}
+
+	memcpy(
+		gid->raw, hr_dev->iboe.gid_table[gid_idx].raw,
+		HNS_ROCE_GID_SIZE);
+
+	return 0;
+}
+
+static int hns_roce_query_pkey(
+				struct ib_device *ib_dev,
+				u8 port, u16 index,
+				u16 *pkey)
+{
+	*pkey = PKEY_ID;
+
+	return 0;
+}
+
+static int hns_roce_modify_device(
+					struct ib_device *ib_dev,
+					int mask,
+					struct ib_device_modify *props)
+{
+	unsigned long flags;
+
+	if (mask & ~IB_DEVICE_MODIFY_NODE_DESC)
+		return -EOPNOTSUPP;
+
+	if (mask & IB_DEVICE_MODIFY_NODE_DESC) {
+		spin_lock_irqsave(&to_hr_dev(ib_dev)->sm_lock, flags);
+		memcpy(ib_dev->node_desc, props->node_desc, NODE_DESC_SIZE);
+		spin_unlock_irqrestore(&to_hr_dev(ib_dev)->sm_lock, flags);
+	}
+
+	return 0;
+}
+
+static int hns_roce_modify_port(
+					struct ib_device *ib_dev,
+					u8 port_num, int mask,
+					struct ib_port_modify *props)
+{
+	return 0;
+}
+
+static struct ib_ucontext *hns_roce_alloc_ucontext(
+						struct ib_device *ib_dev,
+						struct ib_udata *udata)
+{
+	int ret = 0;
+	struct hns_roce_ucontext *context;
+	struct hns_roce_ib_alloc_ucontext_resp resp;
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+
+	resp.qp_tab_size      = hr_dev->caps.num_qps;
+
+	context = kmalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		return ERR_PTR(-ENOMEM);
+
+	ret = hns_roce_uar_alloc(hr_dev, &context->uar);
+	if (ret) {
+		kfree(context);
+		return ERR_PTR(ret);
+	}
+
+	ret = ib_copy_to_udata(udata, &resp, sizeof(resp));
+	if (ret) {
+		kfree(context);
+		return ERR_PTR(-EFAULT);
+	}
+
+	return &context->ibucontext;
+}
+
+static int hns_roce_dealloc_ucontext(struct ib_ucontext *ibcontext)
+{
+	struct hns_roce_ucontext *context = to_hr_ucontext(ibcontext);
+
+	hns_roce_uar_free(to_hr_dev(ibcontext->device), &context->uar);
+
+	kfree(context);
+	return 0;
+}
+
+static int hns_roce_mmap(
+				struct ib_ucontext *context,
+				struct vm_area_struct *vma)
+{
+	if (((vma->vm_end - vma->vm_start) % PAGE_SIZE) != 0)
+		return -EINVAL;
+
+	if (vma->vm_pgoff == 0) {
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+		if (io_remap_pfn_range(vma, vma->vm_start,
+			to_hr_ucontext(context)->uar.pfn,
+			PAGE_SIZE, vma->vm_page_prot))
+			return -EAGAIN;
+
+	} else {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_ib_iboe *iboe = &hr_dev->iboe;
+
+	unregister_inetaddr_notifier(&iboe->nb_inet);
+	unregister_netdevice_notifier(&iboe->nb);
+	ib_unregister_device(&hr_dev->ib_dev);
+}
+
+int hns_roce_register_device(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	struct hns_roce_ib_iboe *iboe = NULL;
+	struct ib_device *ib_dev = NULL;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	iboe = &hr_dev->iboe;
+
+	ib_dev = &hr_dev->ib_dev;
+	strlcpy(ib_dev->name, "hisi_%d", IB_DEVICE_NAME_MAX);
+
+	ib_dev->owner			= THIS_MODULE;
+	ib_dev->node_type		= RDMA_NODE_IB_CA;
+	ib_dev->dma_device		= dev;
+
+	ib_dev->phys_port_cnt		= hr_dev->caps.num_ports;
+	ib_dev->local_dma_lkey		= hr_dev->caps.reserved_lkey;
+	ib_dev->num_comp_vectors	= hr_dev->caps.num_comp_vectors;
+	ib_dev->uverbs_abi_ver		= 1;
+	ib_dev->uverbs_cmd_mask		=
+		(1ULL << IB_USER_VERBS_CMD_GET_CONTEXT) |
+		(1ULL << IB_USER_VERBS_CMD_QUERY_DEVICE) |
+		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT) |
+		(1ULL << IB_USER_VERBS_CMD_ALLOC_PD) |
+		(1ULL << IB_USER_VERBS_CMD_DEALLOC_PD) |
+		(1ULL << IB_USER_VERBS_CMD_REG_MR) |
+		(1ULL << IB_USER_VERBS_CMD_DEREG_MR) |
+		(1ULL << IB_USER_VERBS_CMD_CREATE_COMP_CHANNEL) |
+		(1ULL << IB_USER_VERBS_CMD_CREATE_CQ) |
+		(1ULL << IB_USER_VERBS_CMD_DESTROY_CQ) |
+		(1ULL << IB_USER_VERBS_CMD_CREATE_QP) |
+		(1ULL << IB_USER_VERBS_CMD_MODIFY_QP) |
+		(1ULL << IB_USER_VERBS_CMD_QUERY_QP) |
+		(1ULL << IB_USER_VERBS_CMD_DESTROY_QP);
+
+	/* HCA||device||port */
+	ib_dev->modify_device		= hns_roce_modify_device;
+	ib_dev->query_device		= hns_roce_query_device;
+
+	ib_dev->query_port		= hns_roce_query_port;
+	ib_dev->modify_port		= hns_roce_modify_port;
+
+	ib_dev->get_link_layer	= hns_roce_get_link_layer;
+	ib_dev->query_gid		= hns_roce_query_gid;
+	ib_dev->query_pkey		= hns_roce_query_pkey;
+
+	ib_dev->alloc_ucontext		= hns_roce_alloc_ucontext;
+	ib_dev->dealloc_ucontext	= hns_roce_dealloc_ucontext;
+	ib_dev->mmap			= hns_roce_mmap;
+
+	/* PD */
+	ib_dev->alloc_pd		= hns_roce_alloc_pd;
+	ib_dev->dealloc_pd		= hns_roce_dealloc_pd;
+
+	/* AH */
+	ib_dev->create_ah		= hns_roce_create_ah;
+	ib_dev->query_ah		= hns_roce_query_ah;
+	ib_dev->destroy_ah		= hns_roce_destroy_ah;
+
+	/* QP */
+	ib_dev->create_qp		= hns_roce_create_qp;
+	ib_dev->modify_qp		= hns_roce_modify_qp;
+	ib_dev->query_qp		= hr_dev->hw->query_qp;
+	ib_dev->destroy_qp		= hr_dev->hw->destroy_qp;
+	ib_dev->post_send		= hr_dev->hw->post_send;
+	ib_dev->post_recv		= hr_dev->hw->post_recv;
+
+	/* CQ */
+	ib_dev->create_cq		= hns_roce_ib_create_cq;
+	ib_dev->destroy_cq		= hns_roce_ib_destroy_cq;
+	ib_dev->req_notify_cq	= hr_dev->hw->req_notify_cq;
+	ib_dev->poll_cq			= hr_dev->hw->poll_cq;
+
+	/* MR */
+	ib_dev->get_dma_mr		= hns_roce_get_dma_mr;
+	ib_dev->reg_user_mr		= hns_roce_reg_user_mr;
+	ib_dev->dereg_mr		= hns_roce_dereg_mr;
+
+	ret = ib_register_device(ib_dev, NULL);
+	if (ret) {
+		dev_err(dev, "ib_register_device failed!\n");
+		return ret;
+	}
+
+	ret = hns_roce_setup_mtu_gids(hr_dev);
+	if (ret) {
+		dev_err(dev, "roce_setup_mtu_gids failed!\n");
+		goto _error_failed_setup_mtu_gids;
+	}
+
+	spin_lock_init(&iboe->lock);
+
+	iboe->nb.notifier_call = hns_roce_netdev_event;
+	ret = register_netdevice_notifier(&iboe->nb);
+	if (ret) {
+		dev_err(dev, "register_netdevice_notifier failed!\n");
+		goto _error_failed_register_netdevice_notifier;
+	}
+
+	iboe->nb_inet.notifier_call = hns_roce_inet_event;
+	ret = register_inetaddr_notifier(&iboe->nb_inet);
+	if (ret) {
+		dev_err(dev, "register inet addr notifier failed!\n");
+		goto _error_failed_register_inetaddr_notifier;
+	}
+
+	return 0;
+
+_error_failed_register_inetaddr_notifier:
+	unregister_netdevice_notifier(&iboe->nb);
+
+_error_failed_register_netdevice_notifier:
+_error_failed_setup_mtu_gids:
+	ib_unregister_device(ib_dev);
+
+	return ret;
+}
+
+int hns_roce_get_cfg(struct hns_roce_dev  *hr_dev)
+{
+	int i;
+	int ret = 0;
+	u8 phy_port;
+	int port_cnt = 0;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct device_node *np = dev->of_node;
+	struct device_node *net_node;
+	struct net_device *netdev = NULL;
+	struct platform_device *pdev = NULL;
+
+	if (of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
+		hr_dev->ver = ROCE_VERSION_1;
+		hr_dev->hw = &hns_roce_v1_hw;
+	} else {
+		dev_err(dev, "device no compatible!\n");
+		return -EINVAL;
+	}
+
+	hr_dev->reg_base = of_iomap(np, 0);
+	if (!hr_dev->reg_base) {
+		dev_err(dev, "of_iomap failed!\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < HNS_ROCE_MAX_PORTS; i++) {
+		net_node = of_parse_phandle(np, "eth-handle", i);
+		if (net_node) {
+			pdev = of_find_device_by_node(net_node);
+			netdev = platform_get_drvdata(pdev);
+			phy_port = (u8)i;
+			if (netdev) {
+				hr_dev->iboe.netdevs[port_cnt] = netdev;
+				hr_dev->iboe.phy_port[port_cnt] = phy_port;
+			} else {
+				ret = -ENODEV;
+				goto unmap_base_addr;
+			}
+			port_cnt++;
+		}
+	}
+
+	hr_dev->caps.num_ports = port_cnt;
+
+	/* Cmd issue mode: 0 is poll, 1 is event */
+	hr_dev->cmd_mod = 1;
+	hr_dev->loop_idc = 0;
+
+	for (i = 0; i < HNS_ROCE_MAX_IRQ_NUM; i++) {
+		hr_dev->irq[i] = platform_get_irq(hr_dev->pdev, i);
+		if (hr_dev->irq[i] <= 0) {
+			dev_err(dev, "Get No.%d irq resource failed!\n", i);
+			ret = -EINVAL;
+			goto unmap_base_addr;
+		}
+	}
+
+	return 0;
+
+unmap_base_addr:
+	if (hr_dev->reg_base)
+		iounmap(hr_dev->reg_base);
+
+	return ret;
+}
+
+void hns_roce_free_cfg(struct hns_roce_dev  *hr_dev)
+{
+	if (hr_dev->reg_base)
+		iounmap(hr_dev->reg_base);
+}
+
+int hns_roce_engine_reset(struct hns_roce_dev  *hr_dev, u32 val)
+{
+	return hr_dev->hw->reset(hr_dev, val);
+}
+
+void hns_roce_profile_init(struct hns_roce_dev  *hr_dev)
+{
+	hr_dev->hw->hw_profile(hr_dev);
+}
+
+int hns_roce_init_icm(struct hns_roce_dev  *hr_dev)
+{
+	int ret;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	ret = hns_roce_init_icm_table(
+					hr_dev,
+					(void *)&hr_dev->mr_table.mtt_table,
+					ICM_TYPE_MTT,
+					hr_dev->caps.mtt_entry_sz,
+					hr_dev->caps.num_mtt_segs,
+					0, 1, 0);
+	if (ret) {
+		dev_err(dev, "Failed to map MTT context memory, aborting.\n");
+		return ret;
+	}
+
+	ret = hns_roce_init_icm_table(
+					hr_dev,
+					(void *)&hr_dev->mr_table.mtpt_table,
+					ICM_TYPE_MTPT,
+					hr_dev->caps.mtpt_entry_sz,
+					hr_dev->caps.num_mtpts,
+					0, 1, 1);
+	if (ret) {
+		dev_err(dev, "Failed to map dMPT context memory, aborting.\n");
+		goto err_unmap_mtt;
+	}
+
+	ret = hns_roce_init_icm_table(
+					hr_dev,
+					(void *)&hr_dev->qp_table.qp_table,
+					ICM_TYPE_QPC,
+					hr_dev->caps.qpc_entry_sz,
+					hr_dev->caps.num_qps,
+					0, 1, 0);
+	if (ret) {
+		dev_err(dev, "Failed to map QP context memory, aborting.\n");
+		goto err_unmap_dmpt;
+	}
+
+	ret = hns_roce_init_icm_table(
+					hr_dev,
+					(void *)&hr_dev->qp_table.irrl_table,
+					ICM_TYPE_IRRL,
+					hr_dev->caps.irrl_entry_sz *
+					hr_dev->caps.max_qp_init_rdma,
+					hr_dev->caps.num_qps,
+					0, 1, 0);
+	if (ret) {
+		dev_err(dev, "Failed to map irrl_table memory, aborting.\n");
+		goto err_unmap_qp;
+	}
+
+	ret = hns_roce_init_icm_table(
+					hr_dev,
+					(void *)&hr_dev->cq_table.table,
+					ICM_TYPE_CQC,
+					hr_dev->caps.cqc_entry_sz,
+					hr_dev->caps.num_cqs,
+					0, 1, 0);
+	if (ret) {
+		dev_err(dev, "Failed to map CQ context memory, aborting.\n");
+		goto err_unmap_irrl;
+	}
+
+	return 0;
+
+err_unmap_irrl:
+	hns_roce_cleanup_icm_table(hr_dev,
+			(void *)&hr_dev->qp_table.irrl_table);
+
+err_unmap_qp:
+	hns_roce_cleanup_icm_table(hr_dev,
+			(void *)&hr_dev->qp_table.qp_table);
+
+err_unmap_dmpt:
+	hns_roce_cleanup_icm_table(hr_dev,
+			(void *)&hr_dev->mr_table.mtpt_table);
+
+err_unmap_mtt:
+	hns_roce_cleanup_icm_table(hr_dev,
+			(void *)&hr_dev->mr_table.mtt_table);
+
+	return ret;
+}
+
+int hns_roce_engine_init(struct hns_roce_dev  *hr_dev)
+{
+	return hr_dev->hw->hw_init(hr_dev);
+}
+
+void hns_roce_engine_uninit(struct hns_roce_dev  *hr_dev)
+{
+	hr_dev->hw->hw_uninit(hr_dev);
+}
+
+/**
+* hns_roce_setup_hca - setup host channel adapter
+* @hr_dev: pointer to hns roce device
+* Return : int
+*/
+int hns_roce_setup_hca(struct hns_roce_dev  *hr_dev)
+{
+	int ret;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	spin_lock_init(&hr_dev->sm_lock);
+	spin_lock_init(&hr_dev->cq_db_lock);
+	spin_lock_init(&hr_dev->bt_cmd_lock);
+
+	ret = hns_roce_init_uar_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to initialize uar table. aborting\n");
+		return ret;
+	}
+
+	ret = hns_roce_uar_alloc(hr_dev, &hr_dev->priv_uar);
+	if (ret) {
+		dev_err(dev, "Failed to allocate priv_uar.\n");
+		goto err_uar_table_free;
+	}
+
+	ret = hns_roce_init_pd_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to init protected domain table.\n");
+		goto err_uar_alloc_free;
+	}
+
+	ret = hns_roce_init_mr_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to init memory region table.\n");
+		goto err_pd_table_free;
+	}
+
+	ret = hns_roce_init_cq_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to init completion queue table.\n");
+		goto err_mr_table_free;
+	}
+
+	ret = hns_roce_init_qp_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to init queue pair table.\n");
+		goto err_cq_table_free;
+	}
+
+	return 0;
+
+err_cq_table_free:
+	hns_roce_cleanup_cq_table(hr_dev);
+
+err_mr_table_free:
+	hns_roce_cleanup_mr_table(hr_dev);
+
+err_pd_table_free:
+	hns_roce_cleanup_pd_table(hr_dev);
+
+err_uar_alloc_free:
+	hns_roce_uar_free(hr_dev, &hr_dev->priv_uar);
+
+err_uar_table_free:
+	hns_roce_cleanup_uar_table(hr_dev);
+
+	return ret;
+}
+
+/**
+* hns_roce_probe - RoCE driver entrance
+* @pdev: pointer to platform device
+* Return : int
+*
+*/
+int hns_roce_probe(struct platform_device *pdev)
+{
+	int ret;
+	struct hns_roce_dev *hr_dev;
+	struct device *dev = &pdev->dev;
+
+	hr_dev = (struct hns_roce_dev *)ib_alloc_device(sizeof(*hr_dev));
+	if (!hr_dev) {
+		dev_err(dev, "Device struct alloc failed, aborting.\n");
+		return -ENOMEM;
+	}
+
+	memset((void *)hr_dev + sizeof(struct ib_device),
+		0,
+		sizeof(struct hns_roce_dev) - sizeof(struct ib_device));
+
+	hr_dev->pdev = pdev;
+	platform_set_drvdata(pdev, hr_dev);
+
+	if (!dma_set_mask_and_coherent(dev, (u64)DMA_BIT_MASK(64ULL)))
+		dev_info(dev, "set mask to 64bit\n");
+	else
+		dev_err(dev, "set mask to 64bit fail!\n");
+
+	ret = hns_roce_get_cfg(hr_dev);
+	if (ret) {
+		dev_err(dev, "Get Configuration failed!\n");
+		goto _error_failed_get_cfg;
+	}
+
+	ret = hns_roce_engine_reset(hr_dev, 1);
+	if (ret) {
+		dev_err(dev, "Reset roce engine failed!\n");
+		goto _error_failed_reset_engine;
+	}
+
+	hns_roce_profile_init(hr_dev);
+
+	ret = hns_roce_cmd_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "cmd init failed!\n");
+		goto _error_failed_cmd_init;
+	}
+
+	ret = hns_roce_init_eq_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "eq init failed!\n");
+		goto _error_failed_eq_tabel;
+	}
+
+	if (hr_dev->cmd_mod) {
+		ret = hns_roce_cmd_use_events(hr_dev);
+		if (ret) {
+			dev_err(dev, "Switch to event-driven cmd failed!\n");
+			goto _error_failed_use_event;
+		}
+	}
+
+	ret = hns_roce_init_icm(hr_dev);
+	if (ret) {
+		dev_err(dev, "init icm fail!\n");
+		goto _error_failed_init_icm;
+	}
+
+	ret = hns_roce_setup_hca(hr_dev);
+	if (ret) {
+		dev_err(dev, "setup hca fail!\n");
+		goto _error_failed_setup_hca;
+	}
+
+	ret = hns_roce_engine_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "hw_init failed!\n");
+		goto _error_failed_engine_init;
+	}
+
+	ret = hns_roce_register_device(hr_dev);
+	if (ret) {
+		dev_err(dev, "register_device failed!\n");
+		goto _error_failed_register_device;
+	}
+
+	return 0;
+
+_error_failed_register_device:
+	hns_roce_engine_uninit(hr_dev);
+
+_error_failed_engine_init:
+	hns_roce_cleanup_bitmap(hr_dev);
+
+_error_failed_setup_hca:
+	hns_roce_cleanup_icm(hr_dev);
+
+_error_failed_init_icm:
+	if (hr_dev->cmd_mod)
+		hns_roce_cmd_use_polling(hr_dev);
+
+_error_failed_use_event:
+	hns_roce_cleanup_eq_table(hr_dev);
+
+_error_failed_eq_tabel:
+	hns_roce_cmd_cleanup(hr_dev);
+
+_error_failed_cmd_init:
+	(void)hns_roce_engine_reset(hr_dev, 0);
+
+_error_failed_reset_engine:
+	hns_roce_free_cfg(hr_dev);
+
+_error_failed_get_cfg:
+	ib_dealloc_device(&hr_dev->ib_dev);
+
+	return ret;
+}
+
+/**
+* hns_roce_remove - remove roce device
+* @pdev: pointer to platform device
+*/
+int hns_roce_remove(struct platform_device *pdev)
+{
+	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
+
+	hns_roce_unregister_device(hr_dev);
+	hns_roce_engine_uninit(hr_dev);
+	hns_roce_cleanup_bitmap(hr_dev);
+	hns_roce_cleanup_icm(hr_dev);
+
+	if (hr_dev->cmd_mod)
+		hns_roce_cmd_use_polling(hr_dev);
+
+	hns_roce_cleanup_eq_table(hr_dev);
+	hns_roce_cmd_cleanup(hr_dev);
+
+	(void)hns_roce_engine_reset(hr_dev, 0);
+	hns_roce_free_cfg(hr_dev);
+	ib_dealloc_device(&hr_dev->ib_dev);
+
+	return 0;
+}
+
+static const struct of_device_id hns_roce_of_match[] = {
+	{ .compatible = "hisilicon,hns-roce-v1",},
+	{},
+};
+MODULE_DEVICE_TABLE(of, hns_roce_of_match);
+
+static struct platform_driver hns_roce_driver = {
+	.probe = hns_roce_probe,
+	.remove = hns_roce_remove,
+	.driver = {
+		.name = DRV_NAME,
+		.of_match_table = hns_roce_of_match,
+	},
+};
+
+module_platform_driver(hns_roce_driver);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Wei Hu <xavier.huwei@huawei.com>");
+MODULE_AUTHOR("Znlong <zhaonenglong@hisilicon.com>");
+MODULE_AUTHOR("oulijun <oulijun@huawei.com>");
+MODULE_DESCRIPTION("HISILICON RoCE driver");
+MODULE_ALIAS("platform:" DRV_NAME);
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c
new file mode 100644
index 0000000..5597de8
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c
@@ -0,0 +1,671 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/platform_device.h>
+
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+#include "hns_roce_icm.h"
+
+static u32 hw_index_to_key(u32 ind)
+{
+	return (ind >> 24) | (ind << 8);
+}
+
+static u32 key_to_hw_index(u32 key)
+{
+	return (key << 24) | (key >> 8);
+}
+
+static int hns_roce_sw2hw_mpt(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_cmd_mailbox *mailbox,
+				int mpt_index)
+{
+	return hns_roce_cmd(
+				hr_dev, mailbox->dma, mpt_index, 0,
+				HNS_ROCE_CMD_SW2HW_MPT,
+				HNS_ROCE_CMD_TIME_CLASS_B);
+}
+
+static int hns_roce_hw2sw_mpt(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_cmd_mailbox *mailbox,
+			int mpt_index)
+{
+	return hns_roce_cmd_box(
+			hr_dev, 0, mailbox ? mailbox->dma : 0,
+			mpt_index, !mailbox,
+			HNS_ROCE_CMD_HW2SW_MPT,
+			HNS_ROCE_CMD_TIME_CLASS_B);
+}
+
+static u32 hns_roce_buddy_alloc(struct hns_roce_buddy *buddy, int order)
+{
+	int o;
+	int m;
+	u32 seg;
+
+	spin_lock(&buddy->lock);
+
+	for (o = order; o <= buddy->max_order; ++o) {
+		if (buddy->num_free[o]) {
+			m = 1 << (buddy->max_order - o);
+			seg = find_first_bit(buddy->bits[o], m);
+			if (seg < m)
+				goto found;
+		}
+	}
+	spin_unlock(&buddy->lock);
+	return -1;
+
+ found:
+	clear_bit(seg, buddy->bits[o]);
+	--buddy->num_free[o];
+
+	while (o > order) {
+		--o;
+		seg <<= 1;
+		set_bit(seg ^ 1, buddy->bits[o]);
+		++buddy->num_free[o];
+	}
+
+	spin_unlock(&buddy->lock);
+
+	seg <<= order;
+
+	return seg;
+}
+
+static void hns_roce_buddy_free(
+				struct hns_roce_buddy *buddy,
+				u32 seg, int order)
+{
+	seg >>= order;
+
+	spin_lock(&buddy->lock);
+
+	while (test_bit(seg ^ 1, buddy->bits[order])) {
+		clear_bit(seg ^ 1, buddy->bits[order]);
+		--buddy->num_free[order];
+		seg >>= 1;
+		++order;
+	}
+
+	set_bit(seg, buddy->bits[order]);
+	++buddy->num_free[order];
+
+	spin_unlock(&buddy->lock);
+}
+
+static int hns_roce_buddy_init(
+				struct hns_roce_buddy *buddy,
+				int max_order)
+{
+	int i, s;
+
+	buddy->max_order = max_order;
+	spin_lock_init(&buddy->lock);
+
+	buddy->bits =
+		kzalloc((buddy->max_order + 1) * sizeof(long *),
+			GFP_KERNEL);
+	buddy->num_free =
+		kzalloc((buddy->max_order + 1) * sizeof(int *),
+			GFP_KERNEL);
+	if (!buddy->bits || !buddy->num_free)
+		goto err_out;
+
+	for (i = 0; i <= buddy->max_order; ++i) {
+		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
+		buddy->bits[i] =
+			kmalloc(s * sizeof(long), GFP_KERNEL);
+		if (!buddy->bits[i])
+			goto err_out_free;
+
+		bitmap_zero(buddy->bits[i],
+			1 << (buddy->max_order - i));
+	}
+
+	set_bit(0, buddy->bits[buddy->max_order]);
+	buddy->num_free[buddy->max_order] = 1;
+
+	return 0;
+
+err_out_free:
+	for (i = 0; i <= buddy->max_order; ++i)
+		kfree(buddy->bits[i]);
+
+err_out:
+	kfree(buddy->bits);
+	kfree(buddy->num_free);
+
+	return -ENOMEM;
+}
+
+static void hns_roce_buddy_cleanup(struct hns_roce_buddy *buddy)
+{
+	int i;
+
+	for (i = 0; i <= buddy->max_order; ++i)
+		kfree(buddy->bits[i]);
+
+	kfree(buddy->bits);
+	kfree(buddy->num_free);
+}
+
+static u32 hns_roce_alloc_mtt_range(
+					struct hns_roce_dev *hr_dev,
+					int order)
+{
+	u32 seg = 0;
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+
+	seg = hns_roce_buddy_alloc(&mr_table->mtt_buddy, order);
+	if (seg == -1)
+		return -1;
+
+	if (hns_roce_table_get_range(hr_dev,
+		&mr_table->mtt_table, seg, seg + (1 << order) - 1)) {
+		hns_roce_buddy_free(&mr_table->mtt_buddy, seg, order);
+		return -1;
+	}
+
+	return seg;
+}
+
+int hns_roce_mtt_init(
+			struct hns_roce_dev *hr_dev,
+			int npages, int page_shift,
+			struct hns_roce_mtt *mtt)
+{
+	int i;
+
+	/* Page num is zero, correspond to DMA memory register */
+	if (!npages) {
+		mtt->order      = -1;
+		mtt->page_shift = HNS_ROCE_ICM_PAGE_SHIFT;
+		return 0;
+	}
+
+	/* Note: if page_shift is zero, FAST memory regsiter */
+	mtt->page_shift = page_shift;
+
+	/* Compute MTT entry necessary */
+	for (mtt->order = 0, i = HNS_ROCE_MTT_ENTRY_PER_SEG;
+		i < npages; i <<= 1)
+		++mtt->order;
+
+	/* Allocate MTT entry */
+	mtt->first_seg = hns_roce_alloc_mtt_range(
+						hr_dev,
+						mtt->order);
+	if (mtt->first_seg == -1)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void hns_roce_mtt_cleanup(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_mtt *mtt)
+{
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+
+	if (mtt->order < 0)
+		return;
+
+	hns_roce_buddy_free(
+		&mr_table->mtt_buddy, mtt->first_seg, mtt->order);
+	hns_roce_table_put_range(
+		hr_dev, &mr_table->mtt_table, mtt->first_seg,
+		mtt->first_seg + (1 << mtt->order) - 1);
+}
+
+u64 hns_roce_mtt_addr(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_mtt *mtt)
+{
+	return (u64) mtt->first_seg * hr_dev->caps.mtt_entry_sz;
+}
+
+int hns_roce_mr_alloc(
+			struct hns_roce_dev *hr_dev, u32 pd,
+			u64 iova, u64 size, u32 access,
+			int npages, struct hns_roce_mr *mr)
+{
+	u32 index = 0;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* Allocate a key for mr from mr_table */
+	index = hns_roce_bitmap_alloc(&hr_dev->mr_table.mtpt_bitmap);
+	if (index == -1)
+		return -ENOMEM;
+
+	mr->iova    = iova;                      /* MR va starting addr */
+	mr->size    = size;                      /* MR addr range */
+	mr->pd	    = pd;                        /* MR num */
+	mr->access  = access;                    /* MR access permit */
+	mr->enabled = 0;                         /* MR active status */
+	mr->key	    = hw_index_to_key(index);    /* MR key */
+
+	if (size == ~0ull) {
+		mr->type	= MR_TYPE_DMA;
+		mr->pbl_buf     = NULL;
+		mr->pbl_dma_addr = 0;
+	} else {
+		mr->type        = MR_TYPE_MR;
+		mr->pbl_buf     =
+			dma_alloc_coherent(
+				dev, npages * 8, &(mr->pbl_dma_addr),
+				GFP_KERNEL);
+		if (!mr->pbl_buf) {
+			dev_err(dev,
+				"alloc coherent pbl pages failed.\n");
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
+void hns_roce_mr_free(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_mr *mr)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret;
+
+	if (mr->enabled) {
+		ret = hns_roce_hw2sw_mpt(
+				hr_dev, NULL,
+				key_to_hw_index(mr->key) &
+				(hr_dev->caps.num_mtpts - 1));
+		if (ret)
+			dev_warn(dev,
+				"HW2SW_MPT failed (%d)\n", ret);
+	}
+
+	hns_roce_bitmap_free(
+				&hr_dev->mr_table.mtpt_bitmap,
+				key_to_hw_index(mr->key));
+}
+
+int hns_roce_mr_enable(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_mr *mr)
+{
+	int ret;
+	int mtpt_idx = key_to_hw_index(mr->key);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_cmd_mailbox *mailbox;
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+
+	/* Prepare ICM entry memory */
+	ret = hns_roce_table_get(
+			hr_dev, &mr_table->mtpt_table, mtpt_idx);
+	if (ret)
+		return ret;
+
+	/* Applicate mailbox memory */
+	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
+	if (IS_ERR(mailbox)) {
+		ret = PTR_ERR(mailbox);
+		goto err_table;
+	}
+
+	ret = hr_dev->hw->write_mtpt(mailbox->buf, mr, mtpt_idx);
+	if (ret) {
+		dev_err(dev, "Write mtpt fail!\n");
+		goto err_page;
+	}
+
+	ret = hns_roce_sw2hw_mpt(
+			hr_dev, mailbox,
+			mtpt_idx & (hr_dev->caps.num_mtpts - 1));
+	if (ret) {
+		dev_err(dev, "SW2HW_MPT failed (%d)\n", ret);
+		goto err_cmd;
+	}
+
+	mr->enabled = 1;
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+
+	return 0;
+
+err_cmd:
+err_page:
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+
+err_table:
+	hns_roce_table_put(hr_dev, &mr_table->mtpt_table, mtpt_idx);
+	return ret;
+}
+
+static int hns_roce_write_mtt_chunk(
+					struct hns_roce_dev *hr_dev,
+					struct hns_roce_mtt *mtt,
+					int start_index, int npages,
+					u64 *page_list)
+{
+	int i = 0;
+	__le64 *mtts = NULL;
+	dma_addr_t dma_handle;
+	int s = start_index * sizeof(u64);
+
+	/* All MTTs must fit in the same page */
+	if (start_index / (PAGE_SIZE / sizeof(u64)) !=
+		(start_index + npages - 1) / (PAGE_SIZE / sizeof(u64)))
+		return -EINVAL;
+
+	if (start_index & (HNS_ROCE_MTT_ENTRY_PER_SEG - 1))
+		return -EINVAL;
+
+	mtts = hns_roce_table_find(&hr_dev->mr_table.mtt_table,
+		mtt->first_seg + s / hr_dev->caps.mtt_entry_sz, &dma_handle);
+	if (!mtts)
+		return -ENOMEM;
+
+	/* Save page addr, low 12 bits : 0 */
+	for (i = 0; i < npages; ++i)
+		mtts[i] = (cpu_to_le64(page_list[i])) >> PAGE_ADDR_SHIFT;
+
+	return 0;
+}
+
+int hns_roce_write_mtt(struct hns_roce_dev *hr_dev,
+			struct hns_roce_mtt *mtt,
+			int start_index,
+			int npages,
+			u64 *page_list)
+{
+	int chunk;
+	int ret;
+
+	if (mtt->order < 0)
+		return -EINVAL;
+
+	while (npages > 0) {
+		chunk = min_t(int, PAGE_SIZE / sizeof(u64), npages);
+
+		ret = hns_roce_write_mtt_chunk(
+			hr_dev, mtt, start_index, chunk, page_list);
+		if (ret)
+			return ret;
+
+		npages      -= chunk;
+		start_index += chunk;
+		page_list   += chunk;
+	}
+
+	return 0;
+}
+
+int hns_roce_buf_write_mtt(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_mtt *mtt,
+				struct hns_roce_buf *buf)
+{
+	int i = 0, ret = 0;
+	u64 *page_list = NULL;
+
+	page_list =
+		kmalloc(buf->npages * sizeof(*page_list),
+			GFP_KERNEL);
+	if (!page_list)
+		return -ENOMEM;
+
+
+	for (i = 0; i < buf->npages; ++i) {
+		if (buf->nbufs == 1)
+			page_list[i] =
+				buf->direct.map + (i << buf->page_shift);
+		else
+			page_list[i] = buf->page_list[i].map;
+
+	}
+	ret = hns_roce_write_mtt(hr_dev, mtt, 0, buf->npages, page_list);
+
+	kfree(page_list);
+
+	return ret;
+}
+
+int hns_roce_init_mr_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret = 0;
+
+	ret = hns_roce_bitmap_init(
+				&mr_table->mtpt_bitmap,
+				hr_dev->caps.num_mtpts,
+				hr_dev->caps.num_mtpts - 1,
+				hr_dev->caps.reserved_mrws, 0);
+	if (ret)
+		return ret;
+
+	ret = hns_roce_buddy_init(
+				&mr_table->mtt_buddy,
+				ilog2(hr_dev->caps.num_mtt_segs));
+	if (ret)
+		goto err_buddy;
+
+	if (hr_dev->caps.reserved_mtts) {
+		if (hns_roce_alloc_mtt_range(hr_dev,
+			fls(hr_dev->caps.reserved_mtts - 1)) == -1) {
+			dev_err(dev,
+				"MTT table of order %d is too small.\n",
+				mr_table->mtt_buddy.max_order);
+			ret = -ENOMEM;
+			goto err_reserve_mtts;
+		}
+	}
+
+	return 0;
+
+err_reserve_mtts:
+	hns_roce_buddy_cleanup(&mr_table->mtt_buddy);
+
+err_buddy:
+	hns_roce_bitmap_cleanup(&mr_table->mtpt_bitmap);
+
+	return ret;
+}
+
+void hns_roce_cleanup_mr_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+
+	hns_roce_buddy_cleanup(&mr_table->mtt_buddy);
+	hns_roce_bitmap_cleanup(&mr_table->mtpt_bitmap);
+}
+
+struct ib_mr *hns_roce_get_dma_mr(struct ib_pd *pd, int acc)
+{
+	int ret = 0;
+	struct hns_roce_mr *mr = NULL;
+
+	mr = kmalloc(sizeof(*mr), GFP_KERNEL);
+	if (mr == NULL)
+		return  ERR_PTR(-ENOMEM);
+
+	/* Allocate memory region key */
+	ret = hns_roce_mr_alloc(
+				to_hr_dev(pd->device),
+				to_hr_pd(pd)->pdn, 0,
+				~0ULL, acc, 0, mr);
+	if (ret)
+		goto err_free;
+
+	ret = hns_roce_mr_enable(to_hr_dev(pd->device), mr);
+	if (ret)
+		goto err_mr;
+
+	mr->ibmr.rkey = mr->ibmr.lkey = mr->key;
+	mr->umem = NULL;
+
+	return &mr->ibmr;
+
+err_mr:
+	hns_roce_mr_free(to_hr_dev(pd->device), mr);
+
+err_free:
+	kfree(mr);
+
+	return ERR_PTR(ret);
+}
+
+int hns_roce_ib_umem_write_mtt(
+					struct hns_roce_dev *hr_dev,
+					struct hns_roce_mtt *mtt,
+					struct ib_umem *umem)
+{
+	struct scatterlist *sg;
+	int i, k, entry;
+	int ret = 0;
+	u64 *pages;
+	int n;
+	int len;
+
+	pages = (u64 *) __get_free_page(GFP_KERNEL);
+	if (!pages)
+		return -ENOMEM;
+
+	i = n = 0;
+
+	for_each_sg(umem->sg_head.sgl, sg, umem->nmap, entry) {
+		len = sg_dma_len(sg) >> mtt->page_shift;
+		for (k = 0; k < len; ++k) {
+			pages[i++] = sg_dma_address(sg) + umem->page_size * k;
+
+			if (i == PAGE_SIZE / sizeof(u64)) {
+				ret = hns_roce_write_mtt(
+						hr_dev, mtt, n, i, pages);
+				if (ret)
+					goto out;
+				n += i;
+				i = 0;
+			}
+		}
+	}
+
+	if (i)
+		ret = hns_roce_write_mtt(hr_dev, mtt, n, i, pages);
+
+out:
+	free_page((unsigned long) pages);
+	return ret;
+}
+
+static int hns_roce_ib_umem_write_mr(
+					struct hns_roce_mr *mr,
+					struct ib_umem *umem)
+{
+	int i = 0;
+	int entry;
+	struct scatterlist *sg;
+
+	for_each_sg(umem->sg_head.sgl, sg, umem->nmap, entry) {
+		mr->pbl_buf[i] = ((u64)sg_dma_address(sg)) >> 12;
+		i++;
+	}
+
+	/* Memory barrier */
+	mb();
+
+	return 0;
+}
+
+struct ib_mr *hns_roce_reg_user_mr(
+					struct ib_pd *pd, u64 start,
+					u64 length, u64 virt_addr,
+					int access_flags,
+					struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(pd->device);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_mr *mr = NULL;
+	int shift = 0;
+	int ret = 0;
+	int n = 0;
+
+	mr = kmalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(-ENOMEM);
+
+	mr->umem = ib_umem_get(pd->uobject->context,
+			start, length, access_flags, 0);
+	if (IS_ERR(mr->umem)) {
+		ret = PTR_ERR(mr->umem);
+		goto err_free;
+	}
+
+	n = ib_umem_page_count(mr->umem);
+	shift = ilog2(mr->umem->page_size);
+	if (mr->umem->page_size != HNS_ROCE_ICM_PAGE_SIZE) {
+		dev_err(dev,
+			"Just support 4K page size but is 0x%x now!\n",
+			mr->umem->page_size);
+	}
+
+	if (n > HNS_ROCE_MAX_MTPT_PBL_NUM) {
+		dev_err(dev,
+			" MR len %lld err. MR is limited to 4G at most!\n",
+			length);
+		goto err_free;
+	}
+
+	ret = hns_roce_mr_alloc(
+				hr_dev, to_hr_pd(pd)->pdn, virt_addr,
+				length, access_flags, n, mr);
+	if (ret)
+		goto err_umem;
+
+	ret = hns_roce_ib_umem_write_mr(mr, mr->umem);
+	if (ret)
+		goto err_mr;
+
+	ret = hns_roce_mr_enable(hr_dev, mr);
+	if (ret)
+		goto err_mr;
+
+	mr->ibmr.rkey = mr->ibmr.lkey = mr->key;
+
+	return &mr->ibmr;
+
+err_mr:
+	hns_roce_mr_free(hr_dev, mr);
+
+err_umem:
+	ib_umem_release(mr->umem);
+
+err_free:
+	kfree(mr);
+
+	return ERR_PTR(ret);
+}
+
+
+int hns_roce_dereg_mr(struct ib_mr *ibmr)
+{
+	struct hns_roce_mr *mr = to_hr_mr(ibmr);
+
+	hns_roce_mr_free(to_hr_dev(ibmr->device), mr);
+	if (mr->umem)
+		ib_umem_release(mr->umem);
+
+	kfree(mr);
+
+	return 0;
+}
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c
new file mode 100644
index 0000000..bd851d5
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c
@@ -0,0 +1,130 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <asm/page.h>
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <rdma/ib_smi.h>
+#include <rdma/ib_umem.h>
+#include <rdma/ib_user_verbs.h>
+
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+
+int hns_roce_pd_alloc(struct hns_roce_dev *hr_dev, u32 *pdn)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 pd_number;
+
+	pd_number = hns_roce_bitmap_alloc(&hr_dev->pd_bitmap);
+	if (pd_number == -1) {
+		dev_err(dev, "alloc pdn from pdbitmap failed\n");
+		return -ENOMEM;
+	}
+
+	*pdn = pd_number;
+
+	return 0;
+}
+
+void hns_roce_pd_free(struct hns_roce_dev *hr_dev, u32 pdn)
+{
+	hns_roce_bitmap_free(&hr_dev->pd_bitmap, pdn);
+}
+
+int hns_roce_init_pd_table(struct hns_roce_dev *hr_dev)
+{
+	return hns_roce_bitmap_init(
+				&hr_dev->pd_bitmap,
+				hr_dev->caps.num_pds,
+				hr_dev->caps.num_pds - 1,
+				hr_dev->caps.reserved_pds, 0);
+}
+
+void hns_roce_cleanup_pd_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->pd_bitmap);
+}
+
+struct ib_pd *hns_roce_alloc_pd(
+				struct ib_device *ib_dev,
+				struct ib_ucontext *context,
+				struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_pd *pd;
+	int ret;
+
+	pd = kmalloc(sizeof(*pd), GFP_KERNEL);
+	if (!pd)
+		return ERR_PTR(-ENOMEM);
+
+	ret = hns_roce_pd_alloc(to_hr_dev(ib_dev), &pd->pdn);
+	if (ret) {
+		kfree(pd);
+		dev_err(dev, "[alloc_pd]hns_roce_pd_alloc failed!\n");
+		return ERR_PTR(ret);
+	}
+
+	if (context) {
+		if (ib_copy_to_udata(udata, &pd->pdn, sizeof(__u32))) {
+			hns_roce_pd_free(to_hr_dev(ib_dev), pd->pdn);
+			dev_err(dev, "[alloc_pd]ib_copy_to_udata failed!\n");
+			kfree(pd);
+			return ERR_PTR(-EFAULT);
+		}
+	}
+
+	return &pd->ibpd;
+}
+
+int hns_roce_dealloc_pd(struct ib_pd *pd)
+{
+	hns_roce_pd_free(to_hr_dev(pd->device), to_hr_pd(pd)->pdn);
+	kfree(to_hr_pd(pd));
+
+	return 0;
+}
+
+int hns_roce_uar_alloc(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_uar *uar)
+{
+	/* Using bitmap to manager UAR index */
+	uar->index = hns_roce_bitmap_alloc(&hr_dev->uar_table.bitmap);
+	if (uar->index == -1)
+		return -ENOMEM;
+
+	uar->index = (uar->index - 1) % hr_dev->caps.phy_num_uars + 1;
+	uar->pfn = (ROCE_DEV_IOBASE >> PAGE_SHIFT) + uar->index;
+
+	return 0;
+}
+
+void hns_roce_uar_free(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_uar *uar)
+{
+	hns_roce_bitmap_free(&(hr_dev)->uar_table.bitmap, uar->index);
+}
+
+int hns_roce_init_uar_table(struct hns_roce_dev *hr_dev)
+{
+	return hns_roce_bitmap_init(&hr_dev->uar_table.bitmap,
+			hr_dev->caps.num_uars, hr_dev->caps.num_uars - 1,
+			hr_dev->caps.reserved_uars, 0);
+}
+
+void hns_roce_cleanup_uar_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->uar_table.bitmap);
+}
+
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c
new file mode 100644
index 0000000..324008d
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c
@@ -0,0 +1,945 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/log2.h>
+#include <linux/slab.h>
+#include <rdma/ib_cache.h>
+#include <rdma/ib_pack.h>
+
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+#include "hns_roce_icm.h"
+#include "hns_roce_user.h"
+
+#define DB_REG_OFFSET			0x1000
+#define SQP_NUM				12
+
+void hns_roce_qp_event(
+			struct hns_roce_dev *hr_dev,
+			u32 qpn, int event_type)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_qp *qp;
+
+	spin_lock(&qp_table->lock);
+
+	qp = __hns_roce_qp_lookup(hr_dev, qpn);
+	if (qp)
+		atomic_inc(&qp->refcount);
+
+	spin_unlock(&qp_table->lock);
+
+	if (!qp) {
+		dev_warn(dev, "Async event for bogus QP %08x\n", qpn);
+		return;
+	}
+
+	qp->event(qp, event_type);
+
+	if (atomic_dec_and_test(&qp->refcount))
+		complete(&qp->free);
+}
+
+static void hns_roce_ib_qp_event(struct hns_roce_qp *hr_qp,
+					enum hns_roce_event type)
+{
+	struct ib_event event;
+	struct ib_qp *ibqp = &hr_qp->ibqp;
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct device *dev = &hr_dev->pdev->dev;
+
+	if (ibqp->event_handler) {
+		event.device     = ibqp->device;
+		event.element.qp = ibqp;
+		switch (type) {
+		case HNS_ROCE_EVENT_TYPE_PATH_MIG:
+			event.event = IB_EVENT_PATH_MIG;
+			break;
+		case HNS_ROCE_EVENT_TYPE_COMM_EST:
+			event.event = IB_EVENT_COMM_EST;
+			break;
+		case HNS_ROCE_EVENT_TYPE_SQ_DRAINED:
+			event.event = IB_EVENT_SQ_DRAINED;
+			break;
+		case HNS_ROCE_EVENT_TYPE_SRQ_LAST_WQE_REACH:
+			event.event = IB_EVENT_QP_LAST_WQE_REACHED;
+			break;
+		case HNS_ROCE_EVENT_TYPE_WQ_CATAS_ERROR:
+			event.event = IB_EVENT_QP_FATAL;
+			break;
+		case HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED:
+			event.event = IB_EVENT_PATH_MIG_ERR;
+			break;
+		case HNS_ROCE_EVENT_TYPE_INV_REQ_LOCAL_WQ_ERROR:
+			event.event = IB_EVENT_QP_REQ_ERR;
+			break;
+		case HNS_ROCE_EVENT_TYPE_LOCAL_WQ_ACCESS_ERROR:
+			event.event = IB_EVENT_QP_ACCESS_ERR;
+			break;
+		default:
+			dev_dbg(dev,
+				"roce_ib: Unexpected event type %d on QP %06x\n",
+				type, hr_qp->qpn);
+			return;
+		}
+
+		ibqp->event_handler(&event, ibqp->qp_context);
+	}
+}
+
+int hns_roce_reserve_range_qp(
+					struct hns_roce_dev *hr_dev,
+					int cnt, int align,
+					int *base)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	int qpn;
+
+	qpn = hns_roce_bitmap_alloc_range(&qp_table->bitmap, cnt, align);
+	if (qpn == -1)
+		return -ENOMEM;
+
+	*base = qpn;
+
+	return 0;
+}
+
+enum hns_roce_qp_state to_hns_roce_state(enum ib_qp_state state)
+{
+	switch (state) {
+	case IB_QPS_RESET:
+		return HNS_ROCE_QP_STATE_RST;
+	case IB_QPS_INIT:
+		return HNS_ROCE_QP_STATE_INIT;
+	case IB_QPS_RTR:
+		return HNS_ROCE_QP_STATE_RTR;
+	case IB_QPS_RTS:
+		return HNS_ROCE_QP_STATE_RTS;
+	case IB_QPS_SQD:
+		return HNS_ROCE_QP_STATE_SQD;
+	case IB_QPS_ERR:
+		return HNS_ROCE_QP_STATE_ERR;
+	default:
+		return -1;
+	}
+}
+
+int hns_roce_gsi_qp_alloc(
+				struct hns_roce_dev *hr_dev, int qpn,
+				struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	int ret;
+
+	if (!qpn)
+		return -EINVAL;
+
+	hr_qp->qpn = qpn;
+
+	spin_lock_irq(&qp_table->lock);
+	ret = radix_tree_insert(
+				&hr_dev->qp_table_tree,
+				hr_qp->qpn & (hr_dev->caps.num_qps - 1),
+				hr_qp);
+	spin_unlock_irq(&qp_table->lock);
+	if (ret) {
+		dev_err(&hr_dev->pdev->dev, "QPC radix_tree_insert failed\n");
+		goto err_put_irrl;
+	}
+
+	atomic_set(&hr_qp->refcount, 1);
+	init_completion(&hr_qp->free);
+
+	return 0;
+
+err_put_irrl:
+
+	return ret;
+}
+
+int hns_roce_qp_alloc(
+			struct hns_roce_dev *hr_dev, int qpn,
+			struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret;
+
+	if (!qpn)
+		return -EINVAL;
+
+	hr_qp->qpn = qpn;
+
+	/* Alloc memory for QPC */
+	ret = hns_roce_table_get(
+			hr_dev, &qp_table->qp_table, hr_qp->qpn);
+	if (ret) {
+		dev_err(dev, "QPC table get failed\n");
+		goto err_out;
+	}
+
+	/* Alloc memory for IRRL */
+	ret = hns_roce_table_get(
+				hr_dev, &qp_table->irrl_table,
+				hr_qp->qpn);
+	if (ret) {
+		dev_err(dev, "IRRL table get failed\n");
+		goto err_put_qp;
+	}
+
+	spin_lock_irq(&qp_table->lock);
+	ret = radix_tree_insert(
+				&hr_dev->qp_table_tree,
+				hr_qp->qpn & (hr_dev->caps.num_qps - 1),
+				hr_qp);
+	spin_unlock_irq(&qp_table->lock);
+	if (ret) {
+		dev_err(dev, "QPC radix_tree_insert failed\n");
+		goto err_put_irrl;
+	}
+
+	atomic_set(&hr_qp->refcount, 1);
+	init_completion(&hr_qp->free);
+
+	return 0;
+
+err_put_irrl:
+	hns_roce_table_put(hr_dev, &qp_table->irrl_table, hr_qp->qpn);
+
+err_put_qp:
+	hns_roce_table_put(hr_dev, &qp_table->qp_table, hr_qp->qpn);
+
+err_out:
+	return ret;
+}
+
+void hns_roce_qp_remove(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	unsigned long flags;
+
+	spin_lock_irqsave(&qp_table->lock, flags);
+	radix_tree_delete(
+			&hr_dev->qp_table_tree,
+			hr_qp->qpn & (hr_dev->caps.num_qps - 1));
+	spin_unlock_irqrestore(&qp_table->lock, flags);
+}
+
+void hns_roce_qp_free(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+
+	if (atomic_dec_and_test(&hr_qp->refcount))
+		complete(&hr_qp->free);
+	wait_for_completion(&hr_qp->free);
+
+	if ((hr_qp->ibqp.qp_type) != IB_QPT_GSI) {
+		hns_roce_table_put(
+			hr_dev, &qp_table->irrl_table, hr_qp->qpn);
+		hns_roce_table_put(
+			hr_dev, &qp_table->qp_table, hr_qp->qpn);
+	}
+}
+
+void hns_roce_release_range_qp(
+				struct hns_roce_dev *hr_dev,
+				int base_qpn, int cnt)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+
+	if (base_qpn < (hr_dev->caps.sqp_start + 2 * hr_dev->caps.num_ports))
+		return;
+
+	hns_roce_bitmap_free_range(&qp_table->bitmap, base_qpn, cnt);
+}
+
+int hns_roce_set_rq_size(
+			struct hns_roce_dev *hr_dev,
+			struct ib_qp_cap *cap,
+			int is_user,
+			int has_srq,
+			struct hns_roce_qp *hr_qp)
+{
+	u32 max_cnt;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* Check the validity of QP support capacity */
+	if (cap->max_recv_wr  > hr_dev->caps.max_wqes  ||
+		cap->max_recv_sge > hr_dev->caps.max_rq_sg) {
+		dev_err(dev,
+			"RQ WR or sge error!max_recv_wr=%d max_recv_sge=%d\n",
+		cap->max_recv_wr, cap->max_recv_sge);
+		return -EINVAL;
+	}
+
+	/* If srq exit, set zero for relative number of rq */
+	if (has_srq) {
+		if (cap->max_recv_wr) {
+			dev_dbg(dev, "srq no need config max_recv_wr\n");
+			return -EINVAL;
+		}
+
+		hr_qp->rq.wqe_cnt = hr_qp->rq.max_gs = 0;
+	} else {
+		if (is_user && (!cap->max_recv_wr || !cap->max_recv_sge)) {
+			dev_err(dev,
+				"user space no need config max_recv_wr max_recv_sge\n");
+			return -EINVAL;
+		}
+
+		/* In v1 engine, parameter verification procession */
+		max_cnt = cap->max_recv_wr > HNS_ROCE_MIN_WQE_NUM ?
+			cap->max_recv_wr : HNS_ROCE_MIN_WQE_NUM;
+		hr_qp->rq.wqe_cnt   = roundup_pow_of_two(max_cnt);
+
+		if (hr_qp->rq.wqe_cnt > hr_dev->caps.max_wqes) {
+			dev_err(dev, "hns_roce_set_rq_size rq.wqe_cnt too large\n");
+			return -EINVAL;
+		}
+
+		max_cnt = max(1U, cap->max_recv_sge);
+		hr_qp->rq.max_gs = roundup_pow_of_two(max_cnt);
+		/* WQE is fixed for 64B */
+		hr_qp->rq.wqe_shift = ilog2(hr_dev->caps.max_rq_desc_sz);
+	}
+
+	cap->max_recv_wr  = hr_qp->rq.max_post = hr_qp->rq.wqe_cnt;
+	cap->max_recv_sge = hr_qp->rq.max_gs;
+
+	return 0;
+}
+
+int hns_roce_set_user_sq_size(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_qp *hr_qp,
+				struct hns_roce_ib_create_qp *ucmd)
+{
+	u32 roundup_sq_stride =
+		roundup_pow_of_two(hr_dev->caps.max_sq_desc_sz);
+	u8 max_sq_stride = ilog2(roundup_sq_stride);
+
+	/* Sanity check SQ size before proceeding */
+	if ((1 << ucmd->log_sq_bb_count) > hr_dev->caps.max_wqes ||
+		ucmd->log_sq_stride > max_sq_stride ||
+		ucmd->log_sq_stride < HNS_ROCE_IB_MIN_SQ_STRIDE) {
+		dev_err(&hr_dev->pdev->dev, "check SQ size error!\n");
+		return -EINVAL;
+	}
+
+	hr_qp->sq.wqe_cnt   = 1 << ucmd->log_sq_bb_count;
+	hr_qp->sq.wqe_shift = ucmd->log_sq_stride;
+
+	/* Get buf size, SQ and RQ  are aligned to page_szie */
+	hr_qp->buff_size =
+	HNS_ROCE_ALOGN_UP(
+			(hr_qp->rq.wqe_cnt << hr_qp->rq.wqe_shift),
+			PAGE_SIZE) +
+	HNS_ROCE_ALOGN_UP(
+			(hr_qp->sq.wqe_cnt << hr_qp->sq.wqe_shift),
+			PAGE_SIZE);
+
+	hr_qp->sq.offset = 0;
+	hr_qp->rq.offset =
+	HNS_ROCE_ALOGN_UP(
+			(hr_qp->sq.wqe_cnt << hr_qp->sq.wqe_shift),
+			PAGE_SIZE);
+
+	return 0;
+}
+
+int hns_roce_set_kernel_sq_size(
+					struct hns_roce_dev *hr_dev,
+					struct ib_qp_cap *cap,
+					enum ib_qp_type type,
+					struct hns_roce_qp *hr_qp)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 max_cnt;
+
+	(void)type;
+
+	if (cap->max_send_wr  > hr_dev->caps.max_wqes  ||
+		cap->max_send_sge > hr_dev->caps.max_sq_sg ||
+		cap->max_inline_data > hr_dev->caps.max_sq_inline) {
+		dev_err(dev, "hns_roce_set_kernel_sq_size error1\n");
+		return -EINVAL;
+	}
+
+	hr_qp->sq.wqe_shift = ilog2(hr_dev->caps.max_sq_desc_sz);
+	hr_qp->sq_max_wqes_per_wr = 1;
+	hr_qp->sq_spare_wqes = 0;
+
+	/* In v1 engine, parameter verification procession */
+	max_cnt = cap->max_send_wr > HNS_ROCE_MIN_WQE_NUM ?
+		cap->max_send_wr : HNS_ROCE_MIN_WQE_NUM;
+	hr_qp->sq.wqe_cnt = roundup_pow_of_two(max_cnt);
+
+	if (hr_qp->sq.wqe_cnt > hr_dev->caps.max_wqes) {
+		dev_err(dev,
+			"hns_roce_set_kernel_sq_size sq.wqe_cnt too large\n");
+		return -EINVAL;
+	}
+
+	/* Get data_seg numbers */
+	max_cnt = max(1U, cap->max_send_sge);
+	hr_qp->sq.max_gs = roundup_pow_of_two(max_cnt);
+
+	/* Get buf size, SQ and RQ  are aligned to page_szie */
+	hr_qp->buff_size =
+	HNS_ROCE_ALOGN_UP(
+			(hr_qp->rq.wqe_cnt << hr_qp->rq.wqe_shift),
+			PAGE_SIZE) +
+	HNS_ROCE_ALOGN_UP(
+			(hr_qp->sq.wqe_cnt << hr_qp->sq.wqe_shift),
+			PAGE_SIZE);
+
+	hr_qp->sq.offset = 0;
+	hr_qp->rq.offset =
+	HNS_ROCE_ALOGN_UP(
+			(hr_qp->sq.wqe_cnt << hr_qp->sq.wqe_shift),
+			PAGE_SIZE);
+
+	/* Get wr and sge number which send */
+	cap->max_send_wr  = hr_qp->sq.max_post = hr_qp->sq.wqe_cnt;
+	cap->max_send_sge = hr_qp->sq.max_gs;
+
+	/* We don't support inline sends for kernel QPs (yet) */
+	cap->max_inline_data = 0;
+
+	return 0;
+}
+
+static int hns_roce_create_qp_common(
+					struct hns_roce_dev *hr_dev,
+					struct ib_pd *ib_pd,
+					struct ib_qp_init_attr *init_attr,
+					struct ib_udata *udata, int sqpn,
+					struct hns_roce_qp *hr_qp)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	int qpn = 0;
+	int ret = 0;
+
+	mutex_init(&hr_qp->mutex);
+	spin_lock_init(&hr_qp->sq.lock);
+	spin_lock_init(&hr_qp->rq.lock);
+
+	hr_qp->state = IB_QPS_RESET;
+
+	if (init_attr->sq_sig_type == IB_SIGNAL_ALL_WR)
+		hr_qp->sq_signal_bits = IB_SIGNAL_ALL_WR;
+	else
+		hr_qp->sq_signal_bits = IB_SIGNAL_REQ_WR;
+
+	ret = hns_roce_set_rq_size(
+				hr_dev, &init_attr->cap,
+				!!ib_pd->uobject,
+				!!init_attr->srq,
+				hr_qp);
+
+	if (ret) {
+		dev_err(dev, "hns_roce_set_rq_size failed\n");
+		goto err_out;
+	}
+
+	if (ib_pd->uobject) {
+		struct hns_roce_ib_create_qp ucmd;
+
+		if (ib_copy_from_udata(&ucmd, udata, sizeof(ucmd))) {
+			dev_err(dev, "ib_copy_from_udata error for create qp\n");
+			ret = -EFAULT;
+			goto err_out;
+		}
+
+		ret = hns_roce_set_user_sq_size(hr_dev, hr_qp, &ucmd);
+		if (ret) {
+			dev_err(dev,
+				"hns_roce_set_user_sq_size error for create qp\n");
+			goto err_out;
+		}
+
+		hr_qp->umem = ib_umem_get(
+					ib_pd->uobject->context,
+					ucmd.buf_addr,
+					hr_qp->buff_size,
+					0, 0);
+		if (IS_ERR(hr_qp->umem)) {
+			dev_err(dev, "ib_umem_get error for create qp\n");
+			ret = PTR_ERR(hr_qp->umem);
+			goto err_out;
+		}
+
+		ret = hns_roce_mtt_init(
+					hr_dev,
+					ib_umem_page_count(hr_qp->umem),
+					ilog2(hr_qp->umem->page_size),
+					&hr_qp->mtt);
+
+		if (ret) {
+			dev_err(dev, "hns_roce_mtt_init error for create qp\n");
+			goto err_buf;
+		}
+
+		ret = hns_roce_ib_umem_write_mtt(
+					hr_dev, &hr_qp->mtt, hr_qp->umem);
+		if (ret) {
+			dev_err(dev,
+				"hns_roce_ib_umem_write_mtt error for create qp\n");
+			goto err_mtt;
+		}
+	} else {
+		if (init_attr->create_flags &
+			IB_QP_CREATE_BLOCK_MULTICAST_LOOPBACK) {
+			dev_err(dev, "init_attr->create_flags error!\n");
+			ret = -EINVAL;
+			goto err_out;
+		}
+
+		if (init_attr->create_flags & IB_QP_CREATE_IPOIB_UD_LSO) {
+			dev_err(dev, "init_attr->create_flags error!\n");
+			ret = -EINVAL;
+			goto err_out;
+		}
+
+		/* Set SQ size */
+		ret = hns_roce_set_kernel_sq_size(
+						hr_dev, &init_attr->cap,
+						init_attr->qp_type,
+						hr_qp);
+		if (ret) {
+			dev_err(dev, "hns_roce_set_kernel_sq_size error!\n");
+			goto err_out;
+		}
+
+		/* QP doorbell register address */
+		hr_qp->sq.db_reg_l = hr_dev->reg_base + ROCEE_DB_SQ_L_0_REG
+				+ DB_REG_OFFSET * hr_dev->priv_uar.index;
+		hr_qp->rq.db_reg_l = hr_dev->reg_base +
+				ROCEE_DB_OTHERS_L_0_REG
+				+ DB_REG_OFFSET * hr_dev->priv_uar.index;
+
+		/* Allocate QP buf */
+		if (hns_roce_buf_alloc(hr_dev,
+			hr_qp->buff_size,
+			PAGE_SIZE * 2,
+			&hr_qp->hr_buf)) {
+			dev_err(dev, "hns_roce_buf_alloc error!\n");
+			ret = -ENOMEM;
+			goto err_out;
+		}
+
+		/* Write MTT */
+		ret = hns_roce_mtt_init(
+					hr_dev, hr_qp->hr_buf.npages,
+					hr_qp->hr_buf.page_shift,
+					&hr_qp->mtt);
+		if (ret) {
+			dev_err(dev,
+				"hns_roce_mtt_init error for kernel create qp\n");
+			goto err_buf;
+		}
+
+		ret = hns_roce_buf_write_mtt(
+					hr_dev, &hr_qp->mtt, &hr_qp->hr_buf);
+		if (ret) {
+			dev_err(dev,
+				"hns_roce_buf_write_mtt error for kernel create qp\n");
+			goto err_mtt;
+		}
+
+		hr_qp->sq.wrid  =
+			kmalloc(hr_qp->sq.wqe_cnt * sizeof(u64),
+				GFP_KERNEL);
+		hr_qp->rq.wrid  =
+			kmalloc(hr_qp->rq.wqe_cnt * sizeof(u64),
+				GFP_KERNEL);
+
+		if (!hr_qp->sq.wrid || !hr_qp->rq.wrid) {
+			ret = -ENOMEM;
+			dev_err(dev, "wrid buf alloc failed!\n");
+			goto err_wrid;
+		}
+	}
+
+	if (sqpn) {
+		qpn = sqpn;
+	} else {
+		/* Get QPN */
+		ret = hns_roce_reserve_range_qp(hr_dev, 1, 1, &qpn);
+		if (ret) {
+			dev_err(dev,
+				"hns_roce_reserve_range_qp alloc qpn error\n");
+			goto err_wrid;
+		}
+	}
+
+	if ((init_attr->qp_type) == IB_QPT_GSI) {
+		ret = hns_roce_gsi_qp_alloc(hr_dev, qpn, hr_qp);
+		if (ret) {
+			dev_err(dev, "hns_roce_qp_alloc failed!\n");
+			goto err_qpn;
+		}
+	} else {
+		ret = hns_roce_qp_alloc(hr_dev, qpn, hr_qp);
+		if (ret) {
+			dev_err(dev, "hns_roce_qp_alloc failed!\n");
+			goto err_qpn;
+		}
+	}
+
+	if (sqpn)
+		hr_qp->doorbell_qpn = 1;
+	else
+		hr_qp->doorbell_qpn = cpu_to_le32(hr_qp->qpn);
+
+	hr_qp->event = hns_roce_ib_qp_event;
+
+	return 0;
+
+err_qpn:
+	if (!sqpn)
+		hns_roce_release_range_qp(hr_dev, qpn, 1);
+
+err_wrid:
+	kfree(hr_qp->sq.wrid);
+	kfree(hr_qp->rq.wrid);
+
+err_mtt:
+	hns_roce_mtt_cleanup(hr_dev, &hr_qp->mtt);
+
+err_buf:
+	if (ib_pd->uobject)
+		ib_umem_release(hr_qp->umem);
+	else
+		hns_roce_buf_free(
+				hr_dev, hr_qp->buff_size,
+				&hr_qp->hr_buf);
+
+err_out:
+	return ret;
+}
+
+struct ib_qp *hns_roce_create_qp(
+					struct ib_pd *pd,
+					struct ib_qp_init_attr *init_attr,
+					struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(pd->device);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_sqp *hr_sqp;
+	struct hns_roce_qp *hr_qp;
+	int ret;
+
+	switch (init_attr->qp_type) {
+	case IB_QPT_RC: {
+		hr_qp = kzalloc(sizeof(*hr_qp), GFP_KERNEL);
+		if (!hr_qp) {
+			dev_err(dev, "hr_qp alloc failed!\n");
+			return ERR_PTR(-ENOMEM);
+		}
+
+		ret = hns_roce_create_qp_common(
+					hr_dev, pd, init_attr,
+					udata, 0, hr_qp);
+
+		if (ret) {
+			dev_err(dev, "Create RC QP failed\n");
+			kfree(hr_qp);
+			return ERR_PTR(ret);
+		}
+
+		hr_qp->ibqp.qp_num = hr_qp->qpn;
+
+		break;
+	}
+
+	case IB_QPT_GSI: {
+		/* Userspace is not allowed to create special QPs: */
+		if (pd->uobject) {
+			dev_err(dev, "not support usr space GSI\n");
+			return ERR_PTR(-EINVAL);
+		}
+
+		hr_sqp = kzalloc(sizeof(*hr_sqp), GFP_KERNEL);
+		if (!hr_sqp)
+			return ERR_PTR(-ENOMEM);
+
+		hr_qp = &hr_sqp->hr_qp;
+
+		ret = hns_roce_create_qp_common(
+					hr_dev, pd, init_attr, udata,
+					hr_dev->caps.sqp_start +
+					hr_dev->caps.num_ports +
+					init_attr->port_num - 1,
+					hr_qp);
+		if (ret) {
+			dev_err(dev, "Create GSI QP failed!\n");
+			kfree(hr_sqp);
+			return ERR_PTR(ret);
+		}
+
+		hr_qp->port = (init_attr->port_num - 1);
+		hr_qp->ibqp.qp_num = hr_dev->caps.sqp_start +
+					hr_dev->caps.num_ports +
+					init_attr->port_num - 1;
+		break;
+	}
+	default:{
+		dev_err(dev, "not support QP type %d\n", init_attr->qp_type);
+		return ERR_PTR(-EINVAL);
+	}
+	}
+
+	return &hr_qp->ibqp;
+}
+
+int to_hr_qp_type(int qp_type)
+{
+	int transport_type;
+
+	if (qp_type == IB_QPT_RC)
+		transport_type = SERV_TYPE_RC;
+	else if (qp_type == IB_QPT_UC)
+		transport_type = SERV_TYPE_UC;
+	else if (qp_type == IB_QPT_UD)
+		transport_type = SERV_TYPE_UD;
+	else if (qp_type == IB_QPT_GSI)
+		transport_type = SERV_TYPE_UD;
+	else
+		transport_type = -1;
+
+	return transport_type;
+}
+
+int hns_roce_modify_qp(
+			struct ib_qp *ibqp,
+			struct ib_qp_attr *attr,
+			int attr_mask,
+			struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	enum ib_qp_state cur_state, new_state;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret = -EINVAL;
+	int p;
+
+	mutex_lock(&hr_qp->mutex);
+
+	cur_state = attr_mask & IB_QP_CUR_STATE ?
+		attr->cur_qp_state : hr_qp->state;
+	new_state = attr_mask & IB_QP_STATE ?
+		attr->qp_state : cur_state;
+
+	if (!ib_modify_qp_is_ok(
+			cur_state, new_state, ibqp->qp_type,
+			attr_mask, IB_LINK_LAYER_ETHERNET)) {
+		dev_err(dev, "ib_modify_qp_is_ok failed\n");
+		goto out;
+	}
+
+	if ((attr_mask & IB_QP_PORT) &&
+		(attr->port_num == 0 ||
+		attr->port_num > hr_dev->caps.num_ports)) {
+		dev_err(dev,
+			"attr port_num invalid.attr->port_num=%d\n",
+			attr->port_num);
+		goto out;
+	}
+
+	if (attr_mask & IB_QP_PKEY_INDEX) {
+
+		p = attr_mask & IB_QP_PORT ? attr->port_num :
+			(hr_qp->port + 1);
+		if (attr->pkey_index >= hr_dev->caps.pkey_table_len[p]) {
+			dev_dbg(dev,
+				"attr pkey_index invalid.attr->pkey_index=%d\n",
+				attr->pkey_index);
+			goto out;
+		}
+	}
+
+	if (attr_mask & IB_QP_MAX_QP_RD_ATOMIC &&
+		attr->max_rd_atomic > hr_dev->caps.max_qp_init_rdma) {
+		dev_dbg(dev,
+			"attr max_rd_atomic invalid.attr->max_rd_atomic=%d\n",
+			attr->max_rd_atomic);
+		goto out;
+	}
+
+	if (attr_mask & IB_QP_MAX_DEST_RD_ATOMIC &&
+		attr->max_dest_rd_atomic > hr_dev->caps.max_qp_dest_rdma) {
+		dev_dbg(dev,
+			"attr max_dest_rd_atomic invalid.attr->max_dest_rd_atomic=%d\n",
+			attr->max_dest_rd_atomic);
+		goto out;
+	}
+
+	if (cur_state == new_state && cur_state == IB_QPS_RESET) {
+		ret = -EPERM;
+		dev_dbg(dev, "cur_state=%d new_state=%d\n",
+			cur_state, new_state);
+		goto out;
+	}
+
+	ret = hr_dev->hw->modify_qp(
+				ibqp, attr, attr_mask, cur_state,
+				new_state);
+
+out:
+	mutex_unlock(&hr_qp->mutex);
+
+	return ret;
+}
+
+void hns_roce_lock_cqs(
+			struct hns_roce_cq *send_cq,
+			struct hns_roce_cq *recv_cq)
+			__acquires(&send_cq->lock)
+			__acquires(&recv_cq->lock)
+{
+	if (send_cq == recv_cq) {
+		spin_lock_irq(&send_cq->lock);
+		__acquire(&recv_cq->lock);
+	} else if (send_cq->cqn < recv_cq->cqn) {
+		spin_lock_irq(&send_cq->lock);
+		spin_lock_nested(&recv_cq->lock, SINGLE_DEPTH_NESTING);
+	} else {
+		spin_lock_irq(&recv_cq->lock);
+		spin_lock_nested(&send_cq->lock, SINGLE_DEPTH_NESTING);
+	}
+}
+
+void hns_roce_unlock_cqs(
+				struct hns_roce_cq *send_cq,
+				struct hns_roce_cq *recv_cq)
+				__releases(&send_cq->lock)
+				__releases(&recv_cq->lock)
+{
+	if (send_cq == recv_cq) {
+		__release(&recv_cq->lock);
+		spin_unlock_irq(&send_cq->lock);
+	} else if (send_cq->cqn < recv_cq->cqn) {
+		spin_unlock(&recv_cq->lock);
+		spin_unlock_irq(&send_cq->lock);
+	} else {
+		spin_unlock(&send_cq->lock);
+		spin_unlock_irq(&recv_cq->lock);
+	}
+}
+
+__be32 send_ieth(struct ib_send_wr *wr)
+{
+	switch (wr->opcode) {
+	case IB_WR_SEND_WITH_IMM:
+	case IB_WR_RDMA_WRITE_WITH_IMM:
+		return cpu_to_le32(wr->ex.imm_data);
+
+	case IB_WR_SEND_WITH_INV:
+		return cpu_to_le32(wr->ex.invalidate_rkey);
+
+	default:
+		return 0;
+	}
+}
+
+static void *get_wqe(struct hns_roce_qp *hr_qp, int offset)
+{
+
+	return hns_roce_buf_offset(&hr_qp->hr_buf, offset);
+}
+
+void *get_recv_wqe(struct hns_roce_qp *hr_qp, int n)
+{
+	struct ib_qp *ibqp = &hr_qp->ibqp;
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+
+	if ((n < 0) || (n > hr_qp->rq.wqe_cnt)) {
+		dev_err(&hr_dev->pdev->dev,
+			"rq wqe index:%d,rq wqe cnt:%d\r\n",
+			n, hr_qp->rq.wqe_cnt);
+		return NULL;
+	}
+
+	return get_wqe(
+			hr_qp, hr_qp->rq.offset +
+			(n << hr_qp->rq.wqe_shift));
+}
+
+void *get_send_wqe(struct hns_roce_qp *hr_qp, int n)
+{
+	struct ib_qp *ibqp = &hr_qp->ibqp;
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+
+	if ((n < 0) || (n > hr_qp->sq.wqe_cnt)) {
+		dev_err(&hr_dev->pdev->dev,
+			"sq wqe index:%d,sq wqe cnt:%d\r\n",
+			n, hr_qp->sq.wqe_cnt);
+		return NULL;
+	}
+
+	return get_wqe(
+			hr_qp, hr_qp->sq.offset +
+			(n << hr_qp->sq.wqe_shift));
+}
+
+bool hns_roce_wq_overflow(struct hns_roce_wq *hr_wq,
+				int nreq, struct ib_cq *ib_cq)
+{
+	struct hns_roce_cq *hr_cq;
+	unsigned cur;
+
+	cur = hr_wq->head - hr_wq->tail;
+	if (likely(cur + nreq < hr_wq->max_post))
+		return 0;
+
+	hr_cq = to_hr_cq(ib_cq);
+	spin_lock(&hr_cq->lock);
+	cur = hr_wq->head - hr_wq->tail;
+	spin_unlock(&hr_cq->lock);
+
+	return cur + nreq >= hr_wq->max_post;
+}
+
+int hns_roce_init_qp_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	int reserved_from_top = 0;
+	int ret;
+
+	spin_lock_init(&qp_table->lock);
+	INIT_RADIX_TREE(&hr_dev->qp_table_tree, GFP_ATOMIC);
+
+	/* A port include two SQP, six port total 12 */
+	ret = hns_roce_bitmap_init(
+				&qp_table->bitmap,
+				hr_dev->caps.num_qps,
+				hr_dev->caps.num_qps - 1,
+				hr_dev->caps.sqp_start + SQP_NUM,
+				reserved_from_top);
+	if (ret) {
+		dev_err(&hr_dev->pdev->dev,
+			"qp bitmap init failed!error=%d\n", ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+void hns_roce_cleanup_qp_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->qp_table.bitmap);
+}
+
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h b/drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h
new file mode 100644
index 0000000..0db9a35
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h
@@ -0,0 +1,31 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_USER_H
+#define _HNS_ROCE_USER_H
+
+struct hns_roce_ib_create_cq {
+	__u64   buf_addr;
+	__u64   db_addr;
+};
+
+struct hns_roce_ib_create_qp {
+	__u64	buf_addr;
+	__u64	db_addr;
+	__u8    log_sq_bb_count;
+	__u8    log_sq_stride;
+	__u8    sq_no_prefetch;
+	__u8    reserved[5];
+};
+
+struct hns_roce_ib_alloc_ucontext_resp {
+	__u32	qp_tab_size;
+};
+
+#endif /*_HNS_ROCE_USER_H */
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c b/drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c
new file mode 100644
index 0000000..7d76573
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c
@@ -0,0 +1,3146 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * Authors: Wei Hu <xavier.huwei@huawei.com>
+ * Authors: Znlong <zhaonenglong@hisilicon.com>
+ * Authors: oulijun <oulijun@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+#include "hns_roce_icm.h"
+#include "hns_roce_v1_hw.h"
+
+static void set_data_seg(
+			struct hns_roce_wqe_data_seg *dseg,
+			struct ib_sge *sg)
+{
+	dseg->lkey = cpu_to_le32(sg->lkey);
+	dseg->addr = cpu_to_le64(sg->addr);
+	dseg->len  = cpu_to_le32(sg->length);
+}
+
+static void set_raddr_seg(
+			struct hns_roce_wqe_raddr_seg *rseg,
+			u64 remote_addr, u32 rkey)
+{
+	rseg->raddr = cpu_to_le64(remote_addr);
+	rseg->rkey  = cpu_to_le32(rkey);
+	rseg->len   = 0;
+}
+
+int hns_roce_v1_post_send(
+			struct ib_qp *ibqp,
+			struct ib_send_wr *wr,
+			struct ib_send_wr **bad_wr)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_ah *ah = to_hr_ah(ud_wr(wr)->ah);
+	struct hns_roce_ud_send_wqe *ud_sq_wqe = NULL;
+	struct hns_roce_wqe_ctrl_seg *ctrl = NULL;
+	struct hns_roce_wqe_data_seg *dseg = NULL;
+	struct hns_roce_qp *qp = to_hr_qp(ibqp);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_sq_db sq_db;
+	int ps_opcode = 0, i = 0;
+	unsigned long flags = 0;
+	unsigned ind = 0;
+	void *wqe = NULL;
+	u32 doorbell[2];
+	int nreq = 0;
+	int ret = 0;
+
+	spin_lock_irqsave(&qp->sq.lock, flags);
+
+	ind = qp->sq_next_wqe;
+	for (nreq = 0; wr; ++nreq, wr = wr->next) {
+		if (hns_roce_wq_overflow(
+				&qp->sq, nreq, qp->ibqp.send_cq)) {
+			dev_err(dev, "hns_roce_wq_overflow error\n");
+			ret = -ENOMEM;
+			*bad_wr = wr;
+			goto out;
+		}
+
+		if (unlikely(wr->num_sge > qp->sq.max_gs)) {
+			dev_err(dev, "num_sge=%d > qp->sq.max_gs=%d\n",
+				wr->num_sge, qp->sq.max_gs);
+			ret = -EINVAL;
+			*bad_wr = wr;
+			goto out;
+		}
+
+		wqe = get_send_wqe(qp, ind & (qp->sq.wqe_cnt - 1));
+		qp->sq.wrid[(qp->sq.head + nreq) & (qp->sq.wqe_cnt - 1)] =
+							wr->wr_id;
+
+		/* Corresponding to the RC and RD type wqe process separately */
+		if (ibqp->qp_type == IB_QPT_GSI) {
+			ud_sq_wqe = wqe;
+			roce_set_field(ud_sq_wqe->dmac_h,
+				UD_SEND_WQE_U32_4_DMAC_0_M,
+				UD_SEND_WQE_U32_4_DMAC_0_S,
+				ah->av.mac[0]);
+			roce_set_field(ud_sq_wqe->dmac_h,
+				UD_SEND_WQE_U32_4_DMAC_1_M,
+				UD_SEND_WQE_U32_4_DMAC_1_S,
+				ah->av.mac[1]);
+			roce_set_field(ud_sq_wqe->dmac_h,
+				UD_SEND_WQE_U32_4_DMAC_2_M,
+				UD_SEND_WQE_U32_4_DMAC_2_S,
+				ah->av.mac[2]);
+			roce_set_field(ud_sq_wqe->dmac_h,
+				UD_SEND_WQE_U32_4_DMAC_3_M,
+				UD_SEND_WQE_U32_4_DMAC_3_S,
+				ah->av.mac[3]);
+
+			roce_set_field(ud_sq_wqe->u32_8,
+				UD_SEND_WQE_U32_8_DMAC_4_M,
+				UD_SEND_WQE_U32_8_DMAC_4_S,
+				ah->av.mac[4]);
+			roce_set_field(ud_sq_wqe->u32_8,
+				UD_SEND_WQE_U32_8_DMAC_5_M,
+				UD_SEND_WQE_U32_8_DMAC_5_S,
+				ah->av.mac[5]);
+			roce_set_field(ud_sq_wqe->u32_8,
+				UD_SEND_WQE_U32_8_OPERATION_TYPE_M,
+				UD_SEND_WQE_U32_8_OPERATION_TYPE_S,
+				HNS_ROCE_WQE_OPCODE_SEND);
+			roce_set_field(ud_sq_wqe->u32_8,
+				UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_M,
+				UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_S,
+				2);
+			roce_set_bit(ud_sq_wqe->u32_8,
+				UD_SEND_WQE_U32_8_SEND_GL_ROUTING_HDR_FLAG_S,
+				1);
+
+			ud_sq_wqe->u32_8 |=
+				(wr->send_flags & IB_SEND_SIGNALED ?
+				cpu_to_le32(HNS_ROCE_WQE_CQ_NOTIFY) : 0) |
+				(wr->send_flags & IB_SEND_SOLICITED ?
+				cpu_to_le32(HNS_ROCE_WQE_SE) : 0) |
+				((wr->opcode == IB_WR_SEND_WITH_IMM) ?
+				cpu_to_le32(HNS_ROCE_WQE_IMM) : 0);
+
+			roce_set_field(ud_sq_wqe->u32_16,
+				UD_SEND_WQE_U32_16_DEST_QP_M,
+				UD_SEND_WQE_U32_16_DEST_QP_S,
+				ud_wr(wr)->remote_qpn);
+			roce_set_field(ud_sq_wqe->u32_16,
+				UD_SEND_WQE_U32_16_MAX_STATIC_RATE_M,
+				UD_SEND_WQE_U32_16_MAX_STATIC_RATE_S,
+			ah->av.stat_rate);
+
+			roce_set_field(ud_sq_wqe->u32_36,
+				UD_SEND_WQE_U32_36_FLOW_LABEL_M,
+				UD_SEND_WQE_U32_36_FLOW_LABEL_S,
+				0);
+			roce_set_field(ud_sq_wqe->u32_36,
+				UD_SEND_WQE_U32_36_PRIORITY_M,
+				UD_SEND_WQE_U32_36_PRIORITY_S,
+				ah->av.sl_tclass_flowlabel >>
+					HNS_ROCE_SL_SHIFT);
+			roce_set_field(ud_sq_wqe->u32_36,
+				UD_SEND_WQE_U32_36_SGID_INDEX_M,
+				UD_SEND_WQE_U32_36_SGID_INDEX_S,
+			hns_get_gid_index(hr_dev, qp->port, ah->av.gid_index));
+
+			roce_set_field(ud_sq_wqe->u32_40,
+				UD_SEND_WQE_U32_40_HOP_LIMIT_M,
+				UD_SEND_WQE_U32_40_HOP_LIMIT_S,
+				ah->av.hop_limit);
+			roce_set_field(ud_sq_wqe->u32_40,
+				UD_SEND_WQE_U32_40_TRAFFIC_CLASS_M,
+				UD_SEND_WQE_U32_40_TRAFFIC_CLASS_S,
+				0);
+
+			memcpy(&ud_sq_wqe->dgid[0], &ah->av.dgid[0], GID_LEN);
+
+			ud_sq_wqe->va0_l = (u32)wr->sg_list[0].addr;
+			ud_sq_wqe->va0_h =
+					(wr->sg_list[0].addr) >> ADDR_SHIFT_32;
+			ud_sq_wqe->l_key0 = wr->sg_list[0].lkey;
+
+			ud_sq_wqe->va1_l = (u32)wr->sg_list[1].addr;
+			ud_sq_wqe->va1_h =
+					(wr->sg_list[1].addr) >> ADDR_SHIFT_32;
+			ud_sq_wqe->l_key1 = wr->sg_list[1].lkey;
+			ind++;
+		} else if (ibqp->qp_type == IB_QPT_RC) {
+			ctrl = wqe;
+			memset(ctrl, 0, sizeof(struct hns_roce_wqe_ctrl_seg));
+			for (i = 0; i < wr->num_sge; i++)
+				ctrl->msg_length += wr->sg_list[i].length;
+
+			ctrl->sgl_pa_h = 0;
+			ctrl->flag     = 0;
+			ctrl->imm_data = send_ieth(wr);
+
+			/*Ctrl field, ctrl set type: sig, solic, imm, fence */
+			/* SO wait for conforming application scenarios */
+			ctrl->flag |=
+				(wr->send_flags & IB_SEND_SIGNALED ?
+				cpu_to_le32(HNS_ROCE_WQE_CQ_NOTIFY) : 0) |
+				(wr->send_flags & IB_SEND_SOLICITED ?
+				cpu_to_le32(HNS_ROCE_WQE_SE) : 0) |
+				((wr->opcode == IB_WR_SEND_WITH_IMM ||
+				wr->opcode == IB_WR_RDMA_WRITE_WITH_IMM) ?
+				cpu_to_le32(HNS_ROCE_WQE_IMM) : 0) |
+				(wr->send_flags & IB_SEND_FENCE ?
+				(cpu_to_le32(HNS_ROCE_WQE_FENCE)) : 0);
+
+			wqe += sizeof(struct hns_roce_wqe_ctrl_seg);
+
+			switch (wr->opcode) {
+			case IB_WR_RDMA_READ:
+				ps_opcode = HNS_ROCE_WQE_OPCODE_RDMA_READ;
+				set_raddr_seg(
+					wqe, atomic_wr(wr)->remote_addr,
+					atomic_wr(wr)->rkey);
+				break;
+			case IB_WR_RDMA_WRITE:
+			case IB_WR_RDMA_WRITE_WITH_IMM:
+				ps_opcode = HNS_ROCE_WQE_OPCODE_RDMA_WRITE;
+				set_raddr_seg(
+					wqe, atomic_wr(wr)->remote_addr,
+					atomic_wr(wr)->rkey);
+				break;
+			case IB_WR_SEND:
+			case IB_WR_SEND_WITH_INV:
+			case IB_WR_SEND_WITH_IMM:
+				ps_opcode = HNS_ROCE_WQE_OPCODE_SEND;
+				break;
+			case IB_WR_LOCAL_INV:
+				break;
+			case IB_WR_ATOMIC_CMP_AND_SWP:
+			case IB_WR_ATOMIC_FETCH_AND_ADD:
+			case IB_WR_LSO:
+			default:
+				ps_opcode = HNS_ROCE_WQE_OPCODE_MASK;
+				break;
+			}
+			ctrl->flag |= cpu_to_le32(ps_opcode);
+			wqe  += sizeof(struct hns_roce_wqe_raddr_seg);
+
+			dseg = wqe;
+			if (wr->send_flags & IB_SEND_INLINE && wr->num_sge) {
+				if (ctrl->msg_length >
+					hr_dev->caps.max_sq_inline) {
+					ret = -EINVAL;
+					*bad_wr = wr;
+					dev_err(dev,
+						"inline len(1-%d)=%d, illegal",
+						ctrl->msg_length,
+						hr_dev->caps.max_sq_inline);
+					goto out;
+				}
+
+				for (i = 0; i < wr->num_sge; i++) {
+					memcpy(
+						wqe, ((void *) (uintptr_t)
+						wr->sg_list[i].addr),
+						wr->sg_list[i].length);
+					wqe = wqe + wr->sg_list[i].length;
+				}
+
+				ctrl->flag |= HNS_ROCE_WQE_INLINE;
+			} else {
+				/*sqe num is two */
+				for (i = 0; i < wr->num_sge; i++)
+					set_data_seg(
+						dseg + i, wr->sg_list + i);
+
+				ctrl->flag |=
+					cpu_to_le32(wr->num_sge <<
+					HNS_ROCE_WQE_SGE_NUM_BIT);
+			}
+			ind++;
+		} else {
+			dev_dbg(dev, "unSupported QP type\n");
+			break;
+		}
+	}
+
+out:
+	/* Set DB return */
+	if (likely(nreq)) {
+		qp->sq.head += nreq;
+		/* Memory barrier */
+		wmb();
+
+		sq_db.u32_4 = 0;
+		sq_db.u32_8 = 0;
+		roce_set_field(sq_db.u32_4,
+			SQ_DOORBELL_U32_4_SQ_HEAD_M,
+			SQ_DOORBELL_U32_4_SQ_HEAD_S,
+			(qp->sq.head & ((qp->sq.wqe_cnt << 1) - 1)));
+		roce_set_field(sq_db.u32_4,
+			SQ_DOORBELL_U32_4_PORT_M,
+			SQ_DOORBELL_U32_4_PORT_S,
+			qp->port);
+		roce_set_field(sq_db.u32_8,
+			SQ_DOORBELL_U32_8_QPN_M,
+			SQ_DOORBELL_U32_8_QPN_S,
+			qp->doorbell_qpn);
+		roce_set_bit(sq_db.u32_8,
+			SQ_DOORBELL_HW_SYNC_S,
+			1);
+
+		doorbell[0] = sq_db.u32_4;
+		doorbell[1] = sq_db.u32_8;
+
+		hns_roce_write64_k(doorbell, qp->sq.db_reg_l);
+		qp->sq_next_wqe = ind;
+	}
+
+	spin_unlock_irqrestore(&qp->sq.lock, flags);
+
+	return ret;
+}
+
+int hns_roce_v1_post_recv(
+			struct ib_qp *ibqp,
+			struct ib_recv_wr *wr,
+			struct ib_recv_wr **bad_wr)
+{
+	int ret = 0;
+	int nreq = 0;
+	int ind = 0;
+	int i = 0;
+	u32 reg_val = 0;
+	u32 *addr = NULL;
+	unsigned long flags = 0;
+	struct hns_roce_rq_wqe_ctrl *ctrl = NULL;
+	struct hns_roce_wqe_data_seg *scat = NULL;
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct device *dev = &hr_dev->pdev->dev;
+
+	spin_lock_irqsave(&hr_qp->rq.lock, flags);
+	ind = hr_qp->rq.head & (hr_qp->rq.wqe_cnt - 1);
+
+	for (nreq = 0; wr; ++nreq, wr = wr->next) {
+		if (hns_roce_wq_overflow(&hr_qp->rq, nreq,
+			hr_qp->ibqp.recv_cq)) {
+			dev_err(dev, "hns_roce_wq_overflow error\n");
+			ret = -ENOMEM;
+			*bad_wr = wr;
+			goto out;
+		}
+
+		if (unlikely(wr->num_sge > hr_qp->rq.max_gs)) {
+			dev_err(dev, "rq:num_sge=%d > qp->sq.max_gs=%d\n",
+				wr->num_sge, hr_qp->rq.max_gs);
+			ret = -EINVAL;
+			*bad_wr = wr;
+			goto out;
+		}
+
+		ctrl = get_recv_wqe(hr_qp, ind);
+
+		roce_set_field(ctrl->rwqe_byte_12,
+			RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_M,
+			RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_S,
+			wr->num_sge);
+
+		scat = (struct hns_roce_wqe_data_seg *)(ctrl + 1);
+
+		for (i = 0; i < wr->num_sge; i++)
+			set_data_seg(scat + i, wr->sg_list + i);
+
+		hr_qp->rq.wrid[ind] = wr->wr_id;
+
+		ind = (ind + 1) & (hr_qp->rq.wqe_cnt - 1);
+	}
+
+out:
+	if (likely(nreq)) {
+		hr_qp->rq.head += nreq;
+		/* Memory barrier */
+		wmb();
+
+		if (ibqp->qp_type == IB_QPT_GSI) {
+			/* SW update GSI rq header */
+			addr = (u32 *)(to_hr_dev(ibqp->device)->reg_base +
+					ROCEE_QP1C_CFG3_0_REG +
+					QP1C_CFGN_OFFSET * hr_qp->port);
+			reg_val = roce_readl(addr);
+			roce_set_field(reg_val,
+				ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_M,
+				ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_S,
+				hr_qp->rq.head);
+			roce_writel(reg_val, addr);
+		} else {
+			uint32_t doorbell[2] = {0};
+			struct hns_roce_rq_db rq_db;
+
+			rq_db.u32_4 = 0;
+			rq_db.u32_8 = 0;
+
+			roce_set_field(rq_db.u32_4,
+				RQ_DOORBELL_U32_4_RQ_HEAD_M,
+				RQ_DOORBELL_U32_4_RQ_HEAD_S,
+				hr_qp->rq.head);
+			roce_set_field(rq_db.u32_8,
+				RQ_DOORBELL_U32_8_QPN_M,
+				RQ_DOORBELL_U32_8_QPN_S,
+				hr_qp->qpn);
+			roce_set_field(rq_db.u32_8,
+				RQ_DOORBELL_U32_8_CMD_M,
+				RQ_DOORBELL_U32_8_CMD_S,
+				1);
+			roce_set_bit(rq_db.u32_8,
+				RQ_DOORBELL_U32_8_HW_SYNC_S,
+				1);
+
+			doorbell[0] = rq_db.u32_4;
+			doorbell[1] = rq_db.u32_8;
+
+			hns_roce_write64_k(doorbell, hr_qp->rq.db_reg_l);
+		}
+	}
+	spin_unlock_irqrestore(&hr_qp->rq.lock, flags);
+
+	return ret;
+}
+
+void hns_roce_set_db_event_mode(
+					struct hns_roce_dev *hr_dev,
+					int sdb_mode,
+					int odb_mode)
+{
+	u32 val;
+
+	val = roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+	roce_set_bit(val, ROCEE_GLB_CFG_ROCEE_DB_SQ_MODE_S, sdb_mode);
+	roce_set_bit(val, ROCEE_GLB_CFG_ROCEE_DB_OTH_MODE_S, odb_mode);
+	roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+}
+
+void hns_roce_set_db_ext_mode(
+				struct hns_roce_dev *hr_dev,
+				u32 sdb_mode, u32 odb_mode)
+{
+	u32 val;
+
+	/* Configure SDB/ODB extend mode */
+	val = roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+	roce_set_bit(val, ROCEE_GLB_CFG_SQ_EXT_DB_MODE_S, sdb_mode);
+	roce_set_bit(val, ROCEE_GLB_CFG_OTH_EXT_DB_MODE_S, odb_mode);
+	roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+}
+
+void hns_roce_set_sdb(
+			struct hns_roce_dev *hr_dev,
+			u32 sdb_alept, u32 sdb_alful)
+{
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	u32 val;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	db->sdb_almept = sdb_alept;
+	db->sdb_almful = sdb_alful;
+
+	/* Configure SDB */
+	val = roce_readl(hr_dev->reg_base + ROCEE_DB_SQ_WL_REG);
+	roce_set_field(val,
+		ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_M,
+		ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S,
+		db->sdb_almful);
+	roce_set_field(val,
+		ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_M,
+		ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S,
+		db->sdb_almept);
+	roce_writel(val, hr_dev->reg_base + ROCEE_DB_SQ_WL_REG);
+}
+
+void hns_roce_set_odb(
+			struct hns_roce_dev *hr_dev,
+			u32 odb_alept, u32 odb_alful)
+{
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	u32 val;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	db->odb_almept = odb_alept;
+	db->odb_almful = odb_alful;
+
+	/* Configure ODB */
+	val = roce_readl(hr_dev->reg_base + ROCEE_DB_OTHERS_WL_REG);
+	roce_set_field(val,
+		ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_M,
+		ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S,
+		db->odb_almful);
+	roce_set_field(val,
+		ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_M,
+		ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S,
+		db->odb_almept);
+	roce_writel(val, hr_dev->reg_base + ROCEE_DB_OTHERS_WL_REG);
+}
+
+void hns_roce_set_sdb_ext(
+			struct hns_roce_dev *hr_dev,
+			u32 ext_sdb_alept,
+			u32 ext_sdb_alful)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	dma_addr_t sdb_dma_addr;
+	u32 val;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	db->ext_db->esdb_almept = ext_sdb_alept;
+	db->ext_db->esdb_alful = ext_sdb_alful;
+
+	/* Configure extend SDB threshold */
+	roce_writel(
+		db->ext_db->esdb_almept,
+		hr_dev->reg_base + ROCEE_EXT_DB_SQ_WL_EMPTY_REG);
+	roce_writel(
+		db->ext_db->esdb_alful,
+		hr_dev->reg_base + ROCEE_EXT_DB_SQ_WL_REG);
+
+	/* Configure extend SDB base addr */
+	sdb_dma_addr = db->ext_db->sdb_buf_list->map;
+	roce_writel(
+		(u32)(sdb_dma_addr >> ADDR_SHIFT_12),
+		hr_dev->reg_base + ROCEE_EXT_DB_SQ_REG);
+
+	/* Configure extend SDB depth */
+	val = roce_readl(hr_dev->reg_base + ROCEE_EXT_DB_SQ_H_REG);
+	roce_set_field(val,
+		ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_M,
+		ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S,
+		db->ext_db->esdb_dep);
+	roce_set_field(val,
+		ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_M,
+		ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S,
+		sdb_dma_addr >> ADDR_SHIFT_44);
+	roce_writel(val, hr_dev->reg_base + ROCEE_EXT_DB_SQ_H_REG);
+
+	dev_dbg(dev, "ext SDB depth: 0x%x\n", db->ext_db->esdb_dep);
+	dev_dbg(dev, "ext SDB threshold: epmty: 0x%x, ful: 0x%x\n",
+		db->ext_db->esdb_almept, db->ext_db->esdb_alful);
+}
+
+void hns_roce_set_odb_ext(
+			struct hns_roce_dev *hr_dev,
+			u32 ext_odb_alept,
+			u32 ext_odb_alful)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	dma_addr_t odb_dma_addr;
+	u32 val;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	db->ext_db->eodb_almept = ext_odb_alept;
+	db->ext_db->eodb_alful = ext_odb_alful;
+
+	/* Configure extend ODB threshold */
+	roce_writel(
+		db->ext_db->eodb_almept,
+		hr_dev->reg_base + ROCEE_EXT_DB_OTHERS_WL_EMPTY_REG);
+	roce_writel(
+		db->ext_db->eodb_alful,
+		hr_dev->reg_base + ROCEE_EXT_DB_OTHERS_WL_REG);
+
+	/* Configure extend ODB base addr */
+	odb_dma_addr = db->ext_db->odb_buf_list->map;
+	roce_writel(
+		(u32)(odb_dma_addr >> ADDR_SHIFT_12),
+		hr_dev->reg_base + ROCEE_EXT_DB_OTH_REG);
+
+	/* Configure extend ODB depth */
+	val = roce_readl(hr_dev->reg_base + ROCEE_EXT_DB_OTH_H_REG);
+	roce_set_field(val,
+		ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_M,
+		ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S,
+		db->ext_db->eodb_dep);
+	roce_set_field(val,
+		ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_M,
+		ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S,
+		db->ext_db->eodb_dep);
+	roce_writel(val, hr_dev->reg_base + ROCEE_EXT_DB_OTH_H_REG);
+
+	dev_dbg(dev, "ext ODB depth: 0x%x\n", db->ext_db->eodb_dep);
+	dev_dbg(dev, "ext ODB threshold: empty: 0x%x, ful: 0x%x\n",
+		db->ext_db->eodb_almept, db->ext_db->eodb_alful);
+}
+
+int hns_roce_db_ext_init(
+			struct hns_roce_dev *hr_dev,
+			u32 sdb_ext_mod,
+			u32 odb_ext_mod)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	dma_addr_t sdb_dma_addr;
+	dma_addr_t odb_dma_addr;
+	int ret = 0;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	db->ext_db = kmalloc(sizeof(*db->ext_db), GFP_KERNEL);
+	if (!db->ext_db) {
+		ret = -ENOMEM;
+		dev_err(dev, "extend db buf alloc fail\n");
+		return ret;
+	}
+
+	if (sdb_ext_mod) {
+		db->ext_db->sdb_buf_list =
+			kmalloc(sizeof(*db->ext_db->sdb_buf_list), GFP_KERNEL);
+		if (!db->ext_db->sdb_buf_list) {
+			ret = -ENOMEM;
+			dev_err(dev, "sdb buf alloc failed\n");
+			goto ext_sdb_buf_fail_out;
+		}
+
+		db->ext_db->sdb_buf_list->buf =
+			dma_alloc_coherent(
+					dev, HNS_ROCE_V1_EXT_SDB_SIZE,
+					&sdb_dma_addr, GFP_KERNEL);
+		if (!db->ext_db->sdb_buf_list->buf) {
+			ret = -ENOMEM;
+			dev_err(dev, "Send queue db buf alloc fail\n");
+			goto _alloc_sq_db_buf_fail;
+		}
+		db->ext_db->sdb_buf_list->map = sdb_dma_addr;
+
+		db->ext_db->esdb_dep = ilog2(HNS_ROCE_V1_EXT_SDB_DEPTH);
+		hns_roce_set_sdb_ext(
+				hr_dev, HNS_ROCE_V1_EXT_SDB_ALEPT,
+				HNS_ROCE_V1_EXT_SDB_ALFUL);
+	} else
+		hns_roce_set_sdb(
+				hr_dev, HNS_ROCE_V1_SDB_ALEPT,
+				HNS_ROCE_V1_SDB_ALFUL);
+
+	if (odb_ext_mod) {
+		db->ext_db->odb_buf_list =
+			kmalloc(sizeof(*db->ext_db->odb_buf_list), GFP_KERNEL);
+		if (!db->ext_db->odb_buf_list) {
+			ret = -ENOMEM;
+			dev_err(dev, "odb buf alloc failed\n");
+			goto ext_odb_buf_fail_out;
+		}
+
+		db->ext_db->odb_buf_list->buf = dma_alloc_coherent(
+						dev,
+						HNS_ROCE_V1_EXT_ODB_SIZE,
+						&odb_dma_addr,
+						GFP_KERNEL);
+		if (!db->ext_db->odb_buf_list->buf) {
+			ret = -ENOMEM;
+			dev_err(dev, "Other queue db buf alloc fail\n");
+			goto _alloc_otr_db_buf_fail;
+		}
+		db->ext_db->odb_buf_list->map = odb_dma_addr;
+
+		db->ext_db->eodb_dep = ilog2(HNS_ROCE_V1_EXT_ODB_DEPTH);
+		hns_roce_set_odb_ext(
+					hr_dev, HNS_ROCE_V1_EXT_ODB_ALEPT,
+					HNS_ROCE_V1_EXT_ODB_ALFUL);
+	} else
+		hns_roce_set_odb(
+				hr_dev, HNS_ROCE_V1_ODB_ALEPT,
+				HNS_ROCE_V1_ODB_ALFUL);
+
+	hns_roce_set_db_ext_mode(hr_dev, sdb_ext_mod, odb_ext_mod);
+
+	return 0;
+
+_alloc_otr_db_buf_fail:
+	kfree(db->ext_db->odb_buf_list);
+
+ext_odb_buf_fail_out:
+	if (sdb_ext_mod) {
+		dma_free_coherent(
+				dev, HNS_ROCE_V1_EXT_SDB_SIZE,
+				db->ext_db->sdb_buf_list->buf,
+				db->ext_db->sdb_buf_list->map);
+	}
+
+_alloc_sq_db_buf_fail:
+	if (sdb_ext_mod)
+		kfree(db->ext_db->sdb_buf_list);
+
+ext_sdb_buf_fail_out:
+	kfree(db->ext_db);
+
+	return ret;
+}
+
+int hns_roce_db_init(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	u32 sdb_ext_mod;
+	u32 odb_ext_mod;
+	u32 sdb_evt_mod;
+	u32 odb_evt_mod;
+	int ret = 0;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	memset(db, 0, sizeof(*db));
+
+	/* Default DB mode */
+	sdb_ext_mod = HNS_ROCE_SDB_EXTEND_MODE;
+	odb_ext_mod = HNS_ROCE_ODB_EXTEND_MODE;
+	sdb_evt_mod = HNS_ROCE_SDB_NORMAL_MODE;
+	odb_evt_mod = HNS_ROCE_ODB_POLL_MODE;
+
+	db->sdb_ext_mod = sdb_ext_mod;
+	db->odb_ext_mod = odb_ext_mod;
+
+	/* Init extend DB */
+	ret = hns_roce_db_ext_init(
+				hr_dev, sdb_ext_mod,
+				odb_ext_mod);
+	if (ret) {
+		dev_err(dev, "Failed in extend DB configuration.\n");
+		return ret;
+	}
+
+	hns_roce_set_db_event_mode(hr_dev, sdb_evt_mod, odb_evt_mod);
+
+	return 0;
+}
+
+void hns_roce_db_free(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	if (db->sdb_ext_mod) {
+		dma_free_coherent(
+				dev, HNS_ROCE_V1_EXT_SDB_SIZE,
+				db->ext_db->sdb_buf_list->buf,
+				db->ext_db->sdb_buf_list->map);
+		kfree(db->ext_db->sdb_buf_list);
+	}
+
+	if (db->odb_ext_mod) {
+		dma_free_coherent(
+				dev, HNS_ROCE_V1_EXT_ODB_SIZE,
+				db->ext_db->odb_buf_list->buf,
+				db->ext_db->odb_buf_list->map);
+		kfree(db->ext_db->odb_buf_list);
+	}
+
+	kfree(db->ext_db);
+}
+
+int hns_roce_raq_init(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	int raq_shift = 0;
+	dma_addr_t addr;
+	u32 val;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_raq_table *raq;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	raq = &priv->raq_table;
+
+	raq->e_raq_addr = hr_dev->reg_base + ROCEE_EXT_RAQ_REG;
+	raq->e_raq_wl_addr = hr_dev->reg_base + ROCEE_RAQ_WL_REG;
+	raq->e_raq_shift_addr = hr_dev->reg_base + ROCEE_EXT_RAQ_H_REG;
+
+	raq->e_raq_buf = kzalloc(sizeof(*(raq->e_raq_buf)), GFP_KERNEL);
+	if (!raq->e_raq_buf) {
+		ret = -ENOMEM;
+		dev_err(dev, "Failed to alloc raq buf, Aborting.\n");
+		return ret;
+	}
+
+	raq->e_raq_buf->buf =
+		dma_alloc_coherent(
+				dev, HNS_ROCE_V1_RAQ_SIZE, &addr,
+				GFP_KERNEL);
+	if (!raq->e_raq_buf->buf) {
+		ret = -ENOMEM;
+		dev_err(dev, "Failed to dma_alloc ext raq buf.\n");
+		goto _err_dma_alloc_raq;
+	}
+	raq->e_raq_buf->map = addr;
+
+	/* Configure raq extended address. 48bit 4K align*/
+	roce_writel(
+		raq->e_raq_buf->map >> ADDR_SHIFT_12,
+		raq->e_raq_addr);
+
+	/* Configure raq_shift */
+	raq_shift = ilog2(HNS_ROCE_V1_RAQ_SIZE / HNS_ROCE_V1_RAQ_ENTRY);
+	val = roce_readl(raq->e_raq_shift_addr);
+	roce_set_field(val,
+		ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_M,
+		ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S,
+		raq_shift);
+	roce_set_field(val,
+		ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_M,
+		ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S,
+		raq->e_raq_buf->map >> ADDR_SHIFT_44);
+	roce_writel(val, raq->e_raq_shift_addr);
+	dev_dbg(dev, "Configure raq_shift 0x%x.\n", val);
+
+	/* Configure raq threshold */
+	val = roce_readl(raq->e_raq_wl_addr);
+	roce_set_field(val,
+		ROCEE_RAQ_WL_ROCEE_RAQ_WL_M,
+		ROCEE_RAQ_WL_ROCEE_RAQ_WL_S,
+		HNS_ROCE_V1_EXT_RAQ_WF);
+	roce_writel(val, raq->e_raq_wl_addr);
+	dev_dbg(dev, "Configure raq_wl 0x%x.\n", val);
+
+	/* Enable extend raq */
+	val = roce_readl(hr_dev->reg_base +
+		ROCEE_WRMS_POL_TIME_INTERVAL_REG);
+	roce_set_field(val,
+		ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_M,
+		ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S,
+		POL_TIME_INTERVAL_VAL);
+	roce_set_bit(val,
+		ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_EXT_RAQ_MODE,
+		1);
+	roce_set_field(val,
+		ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_M,
+		ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S,
+		2);
+	roce_set_bit(val,
+		ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_EN_S,
+		1);
+	roce_writel(
+		val,
+		hr_dev->reg_base + ROCEE_WRMS_POL_TIME_INTERVAL_REG);
+	dev_dbg(dev, "Configure WrmsPolTimeInterval 0x%x.\n", val);
+
+	/* Enable raq drop */
+	val = roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+	roce_set_bit(val,
+		ROCEE_GLB_CFG_TRP_RAQ_DROP_EN_S,
+		1);
+	roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+	dev_dbg(dev, "Configure GlbCfg = 0x%x.\n", val);
+
+	return 0;
+
+_err_dma_alloc_raq:
+	kfree(raq->e_raq_buf);
+
+	return ret;
+}
+
+void hns_roce_raq_free(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_raq_table *raq;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	raq = &priv->raq_table;
+
+	dma_free_coherent(
+			dev, HNS_ROCE_V1_RAQ_SIZE,
+			raq->e_raq_buf->buf,
+			raq->e_raq_buf->map);
+	kfree(raq->e_raq_buf);
+}
+
+void hns_roce_port_enable(struct hns_roce_dev  *hr_dev, int enable_flag)
+{
+	u32 val;
+
+	if (enable_flag) {
+		val = roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+		 /* Open all ports */
+		roce_set_field(val,
+			ROCEE_GLB_CFG_ROCEE_PORT_ST_M,
+			ROCEE_GLB_CFG_ROCEE_PORT_ST_S,
+			ALL_PORT_VAL_OPEN);
+		roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+	} else {
+		val = roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+		/* Close all ports */
+		roce_set_field(val,
+			ROCEE_GLB_CFG_ROCEE_PORT_ST_M,
+			ROCEE_GLB_CFG_ROCEE_PORT_ST_S,
+			0x0);
+		roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
+	}
+}
+
+/**
+ * hns_roce_v1_reset - reset roce
+ * @hr_dev: roce device struct pointer
+ * @val: 1 -- drop reset, 0 -- reset
+ * return 0 - success , negative --fail
+ */
+int hns_roce_v1_reset(struct hns_roce_dev  *hr_dev, u32 val)
+{
+	struct device_node *dsaf_node;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct device_node *np = dev->of_node;
+	int ret;
+
+	dsaf_node = of_parse_phandle(np, "dsaf-handle", 0);
+
+	if (!val) {
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, 0);
+	} else {
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, 0);
+		if (ret)
+			return ret;
+
+		msleep(SLEEP_TIME_INTERVAL);
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, 1);
+	}
+
+	return ret;
+}
+
+void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
+{
+	int i = 0;
+	struct hns_roce_caps *caps = &hr_dev->caps;
+
+	hr_dev->vendor_id =
+		le32_to_cpu(roce_readl((hr_dev->reg_base +
+			ROCEE_VENDOR_ID_REG)));
+	hr_dev->vendor_part_id =
+		le32_to_cpu(roce_readl((hr_dev->reg_base +
+			ROCEE_VENDOR_PART_ID_REG)));
+	hr_dev->hw_rev =
+		le32_to_cpu(roce_readl((hr_dev->reg_base +
+			ROCEE_HW_VERSION_REG)));
+	hr_dev->fw_ver = 0;
+
+	hr_dev->sys_image_guid = le32_to_cpu(roce_readl(hr_dev->reg_base +
+			ROCEE_SYS_IMAGE_GUID_L_REG))
+			| ((u64)le32_to_cpu(roce_readl(hr_dev->reg_base +
+			ROCEE_SYS_IMAGE_GUID_H_REG)) << ADDR_SHIFT_32);
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
+	caps->reserved_qps_base	= 0;
+	caps->reserved_qps	= 0;
+	caps->reserved_qps_cnt	= 0;
+	caps->reserved_lkey	= 0;
+	caps->reserved_pds	= 0;
+	caps->reserved_mrws	= 1;
+	caps->reserved_mtts	= 0;
+	caps->reserved_uars	= 0;
+	caps->reserved_cqs	= 0;
+	caps->fmr_reserved_mtts	= 0;
+	caps->flags	= IB_DEVICE_PORT_ACTIVE_EVENT |
+				IB_DEVICE_RC_RNR_NAK_GEN|
+				IB_DEVICE_LOCAL_DMA_LKEY;
+
+	for (i = 0; i < caps->num_ports; i++)
+		caps->pkey_table_len[i] = 1;
+
+	for (i = 0; i < caps->num_ports; i++) {
+		/* Six ports shared 16 GID in v1 engine */
+		if (i >= (HNS_ROCE_V1_GID_NUM % caps->num_ports))
+			caps->gid_table_len[i] =
+				HNS_ROCE_V1_GID_NUM / caps->num_ports;
+		else
+			caps->gid_table_len[i] =
+				HNS_ROCE_V1_GID_NUM / caps->num_ports + 1;
+	}
+
+	for (i = 0; i < caps->num_comp_vectors; i++)
+		caps->ceqe_depth[i] = HNS_ROCE_V1_NUM_COMP_EQE;
+
+	caps->aeqe_depth = HNS_ROCE_V1_NUM_ASYNC_EQE;
+
+	caps->local_ca_ack_delay =
+		le32_to_cpu(roce_readl((hr_dev->reg_base +
+			ROCEE_ACK_DELAY_REG)));
+	caps->max_mtu = ib_mtu_enum_to_int(IB_MTU_2048);
+}
+
+int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	u32 val;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* DMAE user config */
+	val = roce_readl(hr_dev->reg_base + ROCEE_DMAE_USER_CFG1_REG);
+	roce_set_field(val,
+		ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_M,
+		ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S,
+		0xf);
+	roce_set_field(val,
+		ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_M,
+		ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S,
+		1 << PAGES_SHIFT_16);
+	roce_writel(val, hr_dev->reg_base + ROCEE_DMAE_USER_CFG1_REG);
+
+	val = roce_readl(hr_dev->reg_base + ROCEE_DMAE_USER_CFG2_REG);
+	roce_set_field(val,
+		ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_M,
+		ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S,
+		0xf);
+	roce_set_field(val,
+		ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_M,
+		ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S,
+		1 << PAGES_SHIFT_16);
+
+	ret = hns_roce_db_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "doorbell init failed!\n");
+		return ret;
+	}
+
+	ret = hns_roce_raq_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "raq init failed!\n");
+		goto _error_failed_raq_init;
+	}
+
+	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_UP);
+
+	return 0;
+
+_error_failed_raq_init:
+	hns_roce_db_free(hr_dev);
+
+	return ret;
+}
+
+void hns_roce_v1_uninit(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
+	hns_roce_raq_free(hr_dev);
+	hns_roce_db_free(hr_dev);
+}
+
+void hns_roce_v1_set_gid(
+			struct hns_roce_dev *hr_dev,
+			u8 port, int gid_index,
+			union ib_gid *gid)
+{
+	u32 *p = NULL;
+	u8 gid_idx = 0;
+
+	gid_idx = hns_get_gid_index(hr_dev, port, gid_index);
+
+	p = (u32 *)&gid->raw[0];
+	roce_raw_write(*p,
+		hr_dev->reg_base + ROCEE_PORT_GID_L_0_REG +
+		(HNS_ROCE_V1_GID_NUM * gid_idx));
+
+	p = (u32 *)&gid->raw[4];
+	roce_raw_write(*p,
+		hr_dev->reg_base + ROCEE_PORT_GID_ML_0_REG +
+		(HNS_ROCE_V1_GID_NUM * gid_idx));
+
+	p = (u32 *)&gid->raw[8];
+	roce_raw_write(*p,
+		hr_dev->reg_base + ROCEE_PORT_GID_MH_0_REG +
+		(HNS_ROCE_V1_GID_NUM * gid_idx));
+
+	p = (u32 *)&gid->raw[0xc];
+	roce_raw_write(*p,
+		hr_dev->reg_base + ROCEE_PORT_GID_H_0_REG +
+		(HNS_ROCE_V1_GID_NUM * gid_idx));
+}
+
+void hns_roce_v1_set_mac(struct hns_roce_dev *hr_dev, u8 phy_port, u8 *addr)
+{
+	u32 reg_smac_l;
+	u16 reg_smac_h;
+	u16 *p_h;
+	u32 *p;
+	u32 val;
+
+	p = (u32 *)(&addr[0]);
+	reg_smac_l = *p;
+	roce_raw_write(
+			reg_smac_l,
+			hr_dev->reg_base + ROCEE_SMAC_L_0_REG +
+			PHY_PORT_OFFSET * phy_port);
+
+	val = roce_readl(
+			hr_dev->reg_base + ROCEE_SMAC_H_0_REG +
+			phy_port * PHY_PORT_OFFSET);
+	p_h = (u16 *)(&addr[4]);
+	reg_smac_h  = *p_h;
+	roce_set_field(val,
+		ROCEE_SMAC_H_ROCEE_SMAC_H_M,
+		ROCEE_SMAC_H_ROCEE_SMAC_H_S,
+		reg_smac_h);
+	roce_writel(val,
+		hr_dev->reg_base + ROCEE_SMAC_H_0_REG +
+		phy_port * PHY_PORT_OFFSET);
+}
+
+void hns_roce_v1_set_mtu(struct hns_roce_dev  *hr_dev,
+				u8 phy_port,
+				enum ib_mtu mtu)
+{
+	u32 val;
+
+	val = roce_readl(hr_dev->reg_base + ROCEE_SMAC_H_0_REG +
+			phy_port * PHY_PORT_OFFSET);
+	roce_set_field(val,
+		ROCEE_SMAC_H_ROCEE_PORT_MTU_M,
+		ROCEE_SMAC_H_ROCEE_PORT_MTU_S,
+		mtu);
+	roce_writel(val,
+		hr_dev->reg_base + ROCEE_SMAC_H_0_REG +
+		phy_port * PHY_PORT_OFFSET);
+}
+
+int hns_roce_v1_write_mtpt(
+				void *mb_buf,
+				struct hns_roce_mr *mr,
+				int mtpt_idx
+				)
+{
+	struct hns_roce_v1_mpt_entry *mpt_entry;
+	struct scatterlist *sg;
+	u64 *pages;
+	int entry;
+	int i;
+
+	/* MPT filled into mailbox buf */
+	mpt_entry = (struct hns_roce_v1_mpt_entry *)mb_buf;
+	memset(mpt_entry, 0, sizeof(*mpt_entry));
+
+	roce_set_field(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_KEY_STATE_M,
+		MPT_BYTE_4_KEY_STATE_S,
+		KEY_VALID);
+	roce_set_field(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_KEY_M,
+		MPT_BYTE_4_KEY_S,
+		mr->key);
+	roce_set_field(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_PAGE_SIZE_M,
+		MPT_BYTE_4_PAGE_SIZE_S,
+		MR_SIZE_4K);
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_MW_TYPE_S,
+		0);
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_MW_BIND_ENABLE_S,
+		(mr->access & IB_ACCESS_MW_BIND ? 1 : 0));
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_OWN_S,
+		0);
+	roce_set_field(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_MEMORY_LOCATION_TYPE_M,
+		MPT_BYTE_4_MEMORY_LOCATION_TYPE_S,
+		mr->type);
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_REMOTE_ATOMIC_S,
+		0);
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_LOCAL_WRITE_S,
+		(mr->access & IB_ACCESS_LOCAL_WRITE ? 1 : 0));
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_REMOTE_WRITE_S,
+		(mr->access & IB_ACCESS_REMOTE_WRITE ? 1 : 0));
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_REMOTE_READ_S,
+		(mr->access & IB_ACCESS_REMOTE_READ ? 1 : 0));
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_REMOTE_INVAL_ENABLE_S,
+		0);
+	roce_set_bit(mpt_entry->mpt_byte_4,
+		MPT_BYTE_4_ADDRESS_TYPE_S,
+		0);
+
+	mpt_entry->pbl_addr_l = 0;
+
+	roce_set_field(mpt_entry->mpt_byte_12,
+		MPT_BYTE_12_PBL_ADDR_H_M,
+		MPT_BYTE_12_PBL_ADDR_H_S,
+		0);
+	roce_set_field(mpt_entry->mpt_byte_12,
+		MPT_BYTE_12_MW_BIND_COUNTER_M,
+		MPT_BYTE_12_MW_BIND_COUNTER_S,
+		0);
+
+	mpt_entry->virt_addr_l = (u32)mr->iova;
+	mpt_entry->virt_addr_h = (u32)(mr->iova >> ADDR_SHIFT_32);
+	mpt_entry->length = (u32)mr->size;
+
+	roce_set_field(mpt_entry->mpt_byte_28,
+		MPT_BYTE_28_PD_M,
+		MPT_BYTE_28_PD_S,
+		mr->pd);
+	roce_set_field(mpt_entry->mpt_byte_28,
+		MPT_BYTE_28_L_KEY_IDX_L_M,
+		MPT_BYTE_28_L_KEY_IDX_L_S,
+		mtpt_idx);
+	roce_set_field(mpt_entry->mpt_byte_64,
+		MPT_BYTE_64_L_KEY_IDX_H_M,
+		MPT_BYTE_64_L_KEY_IDX_H_S,
+		mtpt_idx >> MTPT_IDX_SHIFT);
+
+	/* DMA momery regsiter */
+	if (mr->type == MR_TYPE_DMA)
+		return 0;
+
+	pages = (u64 *) __get_free_page(GFP_KERNEL);
+	if (!pages)
+		return -ENOMEM;
+
+	i = 0;
+	for_each_sg(
+		mr->umem->sg_head.sgl, sg,
+		mr->umem->nmap, entry) {
+		pages[i] = ((u64)sg_dma_address(sg)) >> ADDR_SHIFT_12;
+
+		/* Directly record to MTPT table firstly 7 entry */
+		if (i >= HNS_ROCE_MAX_INNER_MTPT_NUM)
+			break;
+		i++;
+	}
+
+	/* Register user mr */
+	for (i = 0; i < HNS_ROCE_MAX_INNER_MTPT_NUM; i++) {
+		switch (i) {
+		case 0:
+			mpt_entry->pa0_l =
+				cpu_to_le32((u32)(pages[i]));
+			roce_set_field(mpt_entry->mpt_byte_36,
+				MPT_BYTE_36_PA0_H_M,
+				MPT_BYTE_36_PA0_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_32)));
+			break;
+		case 1:
+			roce_set_field(mpt_entry->mpt_byte_36,
+				MPT_BYTE_36_PA1_L_M,
+				MPT_BYTE_36_PA1_L_S,
+				cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_40,
+				MPT_BYTE_40_PA1_H_M,
+				MPT_BYTE_40_PA1_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_24)));
+			break;
+		case 2:
+			roce_set_field(mpt_entry->mpt_byte_40,
+				MPT_BYTE_40_PA2_L_M,
+				MPT_BYTE_40_PA2_L_S,
+				cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_44,
+				MPT_BYTE_44_PA2_H_M,
+				MPT_BYTE_44_PA2_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_16)));
+			break;
+		case 3:
+			roce_set_field(mpt_entry->mpt_byte_44,
+				MPT_BYTE_44_PA3_L_M,
+				MPT_BYTE_44_PA3_L_S,
+				cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_48,
+				MPT_BYTE_48_PA3_H_M,
+				MPT_BYTE_48_PA3_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_8)));
+			break;
+		case 4:
+			mpt_entry->pa4_l =
+				cpu_to_le32((u32)(pages[i]));
+			roce_set_field(mpt_entry->mpt_byte_56,
+				MPT_BYTE_56_PA4_H_M,
+				MPT_BYTE_56_PA4_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_32)));
+			break;
+		case 5:
+			roce_set_field(mpt_entry->mpt_byte_56,
+				MPT_BYTE_56_PA5_L_M,
+				MPT_BYTE_56_PA5_L_S,
+				cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_60,
+				MPT_BYTE_60_PA5_H_M,
+				MPT_BYTE_60_PA5_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_24)));
+			break;
+		case 6:
+			roce_set_field(mpt_entry->mpt_byte_60,
+				MPT_BYTE_60_PA6_L_M,
+				MPT_BYTE_60_PA6_L_S,
+				cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_64,
+				MPT_BYTE_64_PA6_H_M,
+				MPT_BYTE_64_PA6_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_16)));
+			break;
+		default:
+			break;
+		}
+	}
+
+	free_page((unsigned long) pages);
+
+	mpt_entry->pbl_addr_l = (u32)(mr->pbl_dma_addr);
+
+	roce_set_field(mpt_entry->mpt_byte_12,
+		MPT_BYTE_12_PBL_ADDR_H_M,
+		MPT_BYTE_12_PBL_ADDR_H_S,
+		((u32)(mr->pbl_dma_addr >> ADDR_SHIFT_32)));
+
+	return 0;
+}
+
+static void *get_cqe(struct hns_roce_cq *hr_cq, int n)
+{
+	return hns_roce_buf_offset(
+				&hr_cq->hr_buf.hr_buf,
+				n * HNS_ROCE_V1_CQE_ENTRY_SIZE);
+}
+
+static void *get_sw_cqe(struct hns_roce_cq *hr_cq, int n)
+{
+	struct hns_roce_cqe *hr_cqe = get_cqe(
+					hr_cq,
+					n & hr_cq->ib_cq.cqe);
+
+	/* Get cqe when Owner bit is Conversely with the MSB of cons_idx */
+	return (!!roce_get_bit(
+				hr_cqe->cqe_byte_4,
+				CQE_BYTE_4_OWNER_S) ^
+		!!(n & (hr_cq->ib_cq.cqe + 1))) ? hr_cqe : NULL;
+}
+
+static struct hns_roce_cqe *next_cqe_sw(struct hns_roce_cq *hr_cq)
+{
+	return get_sw_cqe(hr_cq, hr_cq->cons_index);
+}
+
+void hns_roce_v1_cq_set_ci(
+			struct hns_roce_cq *hr_cq,
+			u32 cons_index,
+			spinlock_t *doorbell_lock)
+
+{
+	u32 doorbell[2];
+
+	doorbell[0] = cons_index & ((hr_cq->cq_depth << 1) - 1);
+	roce_set_bit(doorbell[1],
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S, 1);
+	roce_set_field(doorbell[1],
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_M,
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S, 3);
+	roce_set_field(doorbell[1],
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_M,
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_S, 0);
+	roce_set_field(doorbell[1],
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_M,
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_S,
+		hr_cq->cqn);
+
+	hns_roce_write64_k(doorbell, hr_cq->cq_db_l);
+
+}
+
+static void hns_roce_v1_clean_cq(
+				struct hns_roce_cq *hr_cq, u32 qpn,
+				struct hns_roce_srq *srq)
+{
+	struct hns_roce_cqe *cqe, *dest;
+	u32 prod_index;
+	int nfreed = 0;
+	u8 owner_bit;
+
+	for (prod_index = hr_cq->cons_index;
+		get_sw_cqe(hr_cq, prod_index); ++prod_index) {
+		if (prod_index == hr_cq->cons_index +
+				hr_cq->ib_cq.cqe)
+			break;
+	}
+
+	/*
+	* Now backwards through the CQ, removing CQ entries
+	* that match our QP by overwriting them with next entries.
+	*/
+	while ((int) --prod_index - (int) hr_cq->cons_index >= 0) {
+		cqe = get_cqe(hr_cq, prod_index & hr_cq->ib_cq.cqe);
+		if ((roce_get_field(cqe->cqe_byte_16,
+				CQE_BYTE_16_LOCAL_QPN_M,
+				CQE_BYTE_16_LOCAL_QPN_S) &
+				HNS_ROCE_CQE_QPN_MASK) == qpn) {
+			/* In v1 engine, not support SRQ */
+			++nfreed;
+		} else if (nfreed) {
+			dest = get_cqe(
+					hr_cq,
+					(prod_index + nfreed) &
+					hr_cq->ib_cq.cqe);
+			owner_bit = roce_get_bit(dest->cqe_byte_4,
+					CQE_BYTE_4_OWNER_S);
+			memcpy(dest, cqe, sizeof(*cqe));
+			roce_set_bit(dest->cqe_byte_4,
+					CQE_BYTE_4_OWNER_S,
+					owner_bit);
+		}
+	}
+
+	if (nfreed) {
+		hr_cq->cons_index += nfreed;
+		/*
+		* Make sure update of buffer contents is done before
+		* updating consumer index.
+		*/
+		wmb();
+
+		hns_roce_v1_cq_set_ci(
+				hr_cq, hr_cq->cons_index,
+				&to_hr_dev(hr_cq->ib_cq.device)->cq_db_lock);
+	}
+}
+
+static void hns_roce_v1_cq_clean(
+				struct hns_roce_cq *hr_cq, u32 qpn,
+				struct hns_roce_srq *srq)
+{
+	spin_lock_irq(&hr_cq->lock);
+	hns_roce_v1_clean_cq(hr_cq, qpn, srq);
+	spin_unlock_irq(&hr_cq->lock);
+}
+
+void hns_roce_v1_write_cqc(
+				struct hns_roce_dev *hr_dev,
+				struct hns_roce_cq *hr_cq,
+				void *mb_buf,
+				u64 *mtts,
+				dma_addr_t dma_handle,
+				int nent,
+				unsigned vector)
+{
+	struct hns_roce_cq_context *cq_context = NULL;
+	void __iomem *tptr_addr;
+
+	cq_context = mb_buf;
+	memset(cq_context, 0, sizeof(*cq_context));
+
+	tptr_addr = 0;
+	hr_dev->priv_addr = tptr_addr;
+	hr_cq->tptr_addr = tptr_addr;
+
+	/* Register cq_context members */
+	roce_set_field(cq_context->cqc_byte_4,
+		CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_M,
+		CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_S,
+		CQ_STATE_VALID);
+	roce_set_field(cq_context->cqc_byte_4,
+		CQ_CONTEXT_CQC_BYTE_4_CQN_M,
+		CQ_CONTEXT_CQC_BYTE_4_CQN_S,
+		hr_cq->cqn);
+	cq_context->cqc_byte_4 = cpu_to_le32(cq_context->cqc_byte_4);
+
+	cq_context->cq_bt_l = (u32)dma_handle;
+	cq_context->cq_bt_l = cpu_to_le32(cq_context->cq_bt_l);
+
+	roce_set_field(cq_context->cqc_byte_12,
+		CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_M,
+		CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_S,
+		((u64)dma_handle >> ADDR_SHIFT_32));
+	roce_set_field(cq_context->cqc_byte_12,
+		CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_M,
+		CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_S,
+		ilog2(nent));
+	roce_set_field(cq_context->cqc_byte_12,
+		CQ_CONTEXT_CQC_BYTE_12_CEQN_M,
+		CQ_CONTEXT_CQC_BYTE_12_CEQN_S,
+		vector);
+	cq_context->cqc_byte_12 = cpu_to_le32(cq_context->cqc_byte_12);
+
+	cq_context->cur_cqe_ba0_l = (u32)(mtts[0]);
+	cq_context->cur_cqe_ba0_l = cpu_to_le32(cq_context->cur_cqe_ba0_l);
+
+	roce_set_field(cq_context->cqc_byte_20,
+		CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_M,
+		CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_S,
+		cpu_to_le32((mtts[0]) >> ADDR_SHIFT_32));
+	/* Dedicated hardware, directly set 0 */
+	roce_set_field(cq_context->cqc_byte_20,
+		CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_M,
+		CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_S, 0);
+	roce_set_field(cq_context->cqc_byte_20,
+		CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_M,
+		CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_S,
+		(u64)tptr_addr >> ADDR_SHIFT_44);
+	cq_context->cqc_byte_20 = cpu_to_le32(cq_context->cqc_byte_20);
+
+	cq_context->cqe_tptr_addr_l = (u32)((u64)tptr_addr >> ADDR_SHIFT_12);
+
+	cq_context->cur_cqe_ba1_l = 0;
+
+	roce_set_field(cq_context->cqc_byte_32,
+		CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_M,
+		CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_S, 0);
+	roce_set_bit(cq_context->cqc_byte_32,
+		CQ_CONTEXT_CQC_BYTE_32_SE_FLAG_S, 0);
+	roce_set_bit(cq_context->cqc_byte_32,
+		CQ_CONTEXT_CQC_BYTE_32_CE_FLAG_S, 0);
+	roce_set_bit(cq_context->cqc_byte_32,
+		CQ_CONTEXT_CQC_BYTE_32_NOTIFICATION_FLAG_S, 0);
+	roce_set_bit(cq_context->cqc_byte_32,
+		CQ_CQNTEXT_CQC_BYTE_32_TYPE_OF_COMPLETION_NOTIFICATION_S,
+		0);
+	/*The initial value of cq's ci is 0 */
+	roce_set_field(cq_context->cqc_byte_32,
+		CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_M,
+		CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_S, 0);
+	cq_context->cqc_byte_32 = cpu_to_le32(cq_context->cqc_byte_32);
+}
+
+int hns_roce_v1_req_notify_cq(struct ib_cq *ibcq,
+				enum ib_cq_notify_flags flags)
+{
+	struct hns_roce_cq *hr_cq = to_hr_cq(ibcq);
+	u32 notification_flag;
+	u32 doorbell[2];
+	int ret = 0;
+
+	notification_flag = (flags & IB_CQ_SOLICITED_MASK) == IB_CQ_SOLICITED ?
+		CQ_DB_REQ_NOT : CQ_DB_REQ_NOT_SOL;
+
+	/*
+	* flags = 0; Notification Flag = 1, next
+	* flags = 1; Notification Flag = 0, solocited
+	*/
+	doorbell[0] = hr_cq->cons_index & ((hr_cq->cq_depth << 1) - 1);
+	roce_set_bit(doorbell[1],
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S, 1);
+	roce_set_field(doorbell[1],
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_M,
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S, 3);
+	roce_set_field(doorbell[1],
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_M,
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_S, 1);
+	roce_set_field(doorbell[1],
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_M,
+		ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_S,
+		hr_cq->cqn | notification_flag);
+
+	hns_roce_write64_k(doorbell, hr_cq->cq_db_l);
+
+	return ret;
+}
+
+static int hns_roce_v1_poll_one(
+				struct hns_roce_cq *hr_cq,
+				struct hns_roce_qp **cur_qp,
+				struct ib_wc *wc)
+{
+	int qpn;
+	int is_send;
+	u16 wqe_ctr;
+	u32 status;
+	u32 opcode;
+	struct hns_roce_cqe *cqe;
+	struct hns_roce_qp *hr_qp;
+	struct hns_roce_wq *wq;
+	struct hns_roce_wqe_ctrl_seg *sq_wqe;
+	struct hns_roce_dev *hr_dev = to_hr_dev(hr_cq->ib_cq.device);
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* Find cqe according consumer index */
+	cqe = next_cqe_sw(hr_cq);
+	if (!cqe)
+		return -EAGAIN;
+
+	++hr_cq->cons_index;
+	/* Memory barrier */
+	rmb();
+	/* 0->SQ, 1->RQ */
+	is_send  = !(roce_get_bit(cqe->cqe_byte_4,
+				CQE_BYTE_4_SQ_RQ_FLAG_S));
+
+	/* Local_qpn in UD cqe is always 1, so it needs to compute new qpn */
+	if (roce_get_field(cqe->cqe_byte_16,
+			CQE_BYTE_16_LOCAL_QPN_M,
+			CQE_BYTE_16_LOCAL_QPN_S) <= 1) {
+		qpn = roce_get_field(cqe->cqe_byte_20,
+				CQE_BYTE_20_PORT_NUM_M,
+				CQE_BYTE_20_PORT_NUM_S) +
+			roce_get_field(cqe->cqe_byte_16,
+				CQE_BYTE_16_LOCAL_QPN_M,
+				CQE_BYTE_16_LOCAL_QPN_S) *
+			HNS_ROCE_MAX_PORTS;
+	} else {
+		qpn = roce_get_field(cqe->cqe_byte_16,
+				CQE_BYTE_16_LOCAL_QPN_M,
+				CQE_BYTE_16_LOCAL_QPN_S);
+	}
+
+	if (!*cur_qp || (qpn & HNS_ROCE_CQE_QPN_MASK) !=
+		(*cur_qp)->qpn) {
+		hr_qp = __hns_roce_qp_lookup(hr_dev, qpn);
+		if (unlikely(!hr_qp)) {
+			dev_err(dev,
+				"CQ %06x with entry for unknown QPN %06x\n",
+				hr_cq->cqn, (qpn & HNS_ROCE_CQE_QPN_MASK));
+			return -EINVAL;
+		}
+
+		*cur_qp = hr_qp;
+	}
+
+	wc->qp = &(*cur_qp)->ibqp;
+	wc->vendor_err = 0;
+
+	status = roce_get_field(cqe->cqe_byte_4,
+			CQE_BYTE_4_STATUS_OF_THE_OPERATION_M,
+			CQE_BYTE_4_STATUS_OF_THE_OPERATION_S) &
+			HNS_ROCE_CQE_STATUS_MASK;
+	switch (status) {
+	case HNS_ROCE_CQE_SUCCESS:
+		wc->status = IB_WC_SUCCESS;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_LOCAL_LENGTH_ERR:
+		wc->status = IB_WC_LOC_LEN_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_LOCAL_QP_OP_ERR:
+		wc->status = IB_WC_LOC_QP_OP_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_LOCAL_PROT_ERR:
+		wc->status = IB_WC_LOC_PROT_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_WR_FLUSH_ERR:
+		wc->status = IB_WC_WR_FLUSH_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_MEM_MANAGE_OPERATE_ERR:
+		wc->status = IB_WC_MW_BIND_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_BAD_RESP_ERR:
+		wc->status = IB_WC_BAD_RESP_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_LOCAL_ACCESS_ERR:
+		wc->status = IB_WC_LOC_ACCESS_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_REMOTE_INVAL_REQ_ERR:
+		wc->status = IB_WC_REM_INV_REQ_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_REMOTE_ACCESS_ERR:
+		wc->status = IB_WC_REM_ACCESS_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_REMOTE_OP_ERR:
+		wc->status = IB_WC_REM_OP_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_TRANSPORT_RETRY_EXC_ERR:
+		wc->status = IB_WC_RETRY_EXC_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_RNR_RETRY_EXC_ERR:
+		wc->status = IB_WC_RNR_RETRY_EXC_ERR;
+		break;
+	default:
+		wc->status = IB_WC_GENERAL_ERR;
+		break;
+	}
+
+	/* CQE status error, directly return */
+	if (wc->status != IB_WC_SUCCESS)
+		return 0;
+
+	if (is_send) {
+		/* SQ conrespond to CQE */
+		sq_wqe = get_send_wqe(*cur_qp, roce_get_field(cqe->cqe_byte_4,
+					CQE_BYTE_4_WQE_INDEX_M,
+					CQE_BYTE_4_WQE_INDEX_S));
+		switch (sq_wqe->flag & HNS_ROCE_WQE_OPCODE_MASK) {
+		case HNS_ROCE_WQE_OPCODE_SEND:
+			wc->opcode = IB_WC_SEND;
+			break;
+		case HNS_ROCE_WQE_OPCODE_RDMA_READ:
+			wc->opcode = IB_WC_RDMA_READ;
+			wc->byte_len = le32_to_cpu(cqe->byte_cnt);
+			break;
+		case HNS_ROCE_WQE_OPCODE_RDMA_WRITE:
+			wc->opcode = IB_WC_RDMA_WRITE;
+			break;
+		case HNS_ROCE_WQE_OPCODE_LOCAL_INV:
+			wc->opcode = IB_WC_LOCAL_INV;
+			break;
+		case HNS_ROCE_WQE_OPCODE_UD_SEND:
+			wc->opcode = IB_WC_SEND;
+			break;
+		default:
+			wc->status = IB_WC_GENERAL_ERR;
+			break;
+		}
+		wc->wc_flags =
+			(sq_wqe->flag & HNS_ROCE_WQE_IMM ?
+			IB_WC_WITH_IMM : 0);
+
+		wq = &(*cur_qp)->sq;
+		if ((*cur_qp)->sq_signal_bits) {
+			/*
+			* If sg_signal_bit is 1,
+			* firstly tail pointer updated to wqe
+			* which current cqe correspond to
+			*/
+			wqe_ctr = (u16)roce_get_field(cqe->cqe_byte_4,
+					CQE_BYTE_4_WQE_INDEX_M,
+					CQE_BYTE_4_WQE_INDEX_S);
+			wq->tail +=
+				(wqe_ctr - (u16)wq->tail) & (wq->wqe_cnt - 1);
+		}
+		wc->wr_id = wq->wrid[wq->tail & (wq->wqe_cnt - 1)];
+		++wq->tail;
+		} else {
+		/* RQ conrespond to CQE */
+		wc->byte_len = le32_to_cpu(cqe->byte_cnt);
+		opcode = roce_get_field(cqe->cqe_byte_4,
+				CQE_BYTE_4_OPERATION_TYPE_M,
+				CQE_BYTE_4_OPERATION_TYPE_S) &
+				HNS_ROCE_CQE_OPCODE_MASK;
+		switch (opcode) {
+		case HNS_ROCE_OPCODE_RDMA_WITH_IMM_RECEIVE:
+			wc->opcode = IB_WC_RECV_RDMA_WITH_IMM;
+			wc->wc_flags = IB_WC_WITH_IMM;
+			wc->ex.imm_data = le32_to_cpu(cqe->immediate_data);
+			break;
+		case HNS_ROCE_OPCODE_SEND_DATA_RECEIVE:
+			if (roce_get_bit(cqe->cqe_byte_4,
+				CQE_BYTE_4_IMM_INDICATOR_S)) {
+				wc->opcode   = IB_WC_RECV;
+				wc->wc_flags = IB_WC_WITH_IMM;
+				wc->ex.imm_data =
+					le32_to_cpu(cqe->immediate_data);
+			} else {
+				wc->opcode   = IB_WC_RECV;
+				wc->wc_flags = 0;
+			}
+			break;
+		default:
+			wc->status = IB_WC_GENERAL_ERR;
+			break;
+		}
+
+		/* Update tail pointer, record wr_id */
+		wq = &(*cur_qp)->rq;
+		wc->wr_id = wq->wrid[wq->tail & (wq->wqe_cnt - 1)];
+		++wq->tail;
+		wc->sl         = (u8)roce_get_field(cqe->cqe_byte_20,
+					CQE_BYTE_20_SL_M,
+					CQE_BYTE_20_SL_S);
+		wc->src_qp     = (u8)roce_get_field(cqe->cqe_byte_20,
+					CQE_BYTE_20_REMOTE_QPN_M,
+					CQE_BYTE_20_REMOTE_QPN_S);
+		wc->wc_flags   |= (roce_get_bit(cqe->cqe_byte_20,
+					CQE_BYTE_20_GRH_PRESENT_S) ?
+					IB_WC_GRH : 0);
+		wc->pkey_index = (u16)roce_get_field(cqe->cqe_byte_28,
+					CQE_BYTE_28_P_KEY_IDX_M,
+					CQE_BYTE_28_P_KEY_IDX_S);
+	}
+
+	return 0;
+}
+
+int hns_roce_v1_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
+{
+	struct hns_roce_cq *hr_cq = to_hr_cq(ibcq);
+	struct hns_roce_qp *cur_qp = NULL;
+	unsigned long flags;
+	int npolled;
+	int ret = 0;
+
+	spin_lock_irqsave(&hr_cq->lock, flags);
+
+	for (npolled = 0; npolled < num_entries; ++npolled) {
+		ret = hns_roce_v1_poll_one(hr_cq, &cur_qp, wc + npolled);
+		if (ret)
+			break;
+	}
+
+	if (npolled) {
+		hns_roce_v1_cq_set_ci(hr_cq,
+				hr_cq->cons_index,
+				&to_hr_dev(ibcq->device)->cq_db_lock);
+	}
+
+	spin_unlock_irqrestore(&hr_cq->lock, flags);
+
+	if (ret == 0 || ret == -EAGAIN)
+		return npolled;
+	else
+		return ret;
+}
+
+static int hns_roce_v1_qp_modify(struct hns_roce_dev *hr_dev,
+			struct hns_roce_mtt *mtt,
+			enum hns_roce_qp_state cur_state,
+			enum hns_roce_qp_state new_state,
+			struct hns_roce_qp_context *context,
+			struct hns_roce_qp *hr_qp)
+{
+	static const u16
+	op[HNS_ROCE_QP_NUM_STATE][HNS_ROCE_QP_NUM_STATE] = {
+		[HNS_ROCE_QP_STATE_RST] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		[HNS_ROCE_QP_STATE_INIT] = HNS_ROCE_CMD_RST2INIT_QP,
+		},
+		[HNS_ROCE_QP_STATE_INIT] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		/* Note: In v1 engine, HW doesn't support RST2INIT.
+		 * We use RST2INIT cmd instead of INIT2INIT.
+		 */
+		[HNS_ROCE_QP_STATE_INIT] = HNS_ROCE_CMD_RST2INIT_QP,
+		[HNS_ROCE_QP_STATE_RTR] = HNS_ROCE_CMD_INIT2RTR_QP,
+		},
+		[HNS_ROCE_QP_STATE_RTR] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		[HNS_ROCE_QP_STATE_RTS] = HNS_ROCE_CMD_RTR2RTS_QP,
+		},
+		[HNS_ROCE_QP_STATE_RTS] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		[HNS_ROCE_QP_STATE_RTS] = HNS_ROCE_CMD_RTS2RTS_QP,
+		[HNS_ROCE_QP_STATE_SQD] = HNS_ROCE_CMD_RTS2SQD_QP,
+		},
+		[HNS_ROCE_QP_STATE_SQD] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		[HNS_ROCE_QP_STATE_RTS] = HNS_ROCE_CMD_SQD2RTS_QP,
+		[HNS_ROCE_QP_STATE_SQD] = HNS_ROCE_CMD_SQD2SQD_QP,
+		},
+		[HNS_ROCE_QP_STATE_ERR] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		}
+	};
+
+	struct hns_roce_cmd_mailbox *mailbox;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret = 0;
+
+	if (cur_state >= HNS_ROCE_QP_NUM_STATE ||
+		new_state >= HNS_ROCE_QP_NUM_STATE ||
+		!op[cur_state][new_state]) {
+		dev_err(dev, "[modify_qp]not support state %d to %d\n",
+			cur_state, new_state);
+		return -EINVAL;
+	}
+
+	if (op[cur_state][new_state] == HNS_ROCE_CMD_2RST_QP)
+		return hns_roce_cmd(
+				hr_dev, 0, hr_qp->qpn, 2,
+				HNS_ROCE_CMD_2RST_QP,
+				HNS_ROCE_CMD_TIME_CLASS_A);
+
+	if (op[cur_state][new_state] == HNS_ROCE_CMD_2ERR_QP)
+		return hns_roce_cmd(
+				hr_dev, 0, hr_qp->qpn, 2,
+				HNS_ROCE_CMD_2ERR_QP,
+				HNS_ROCE_CMD_TIME_CLASS_A);
+
+	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
+	if (IS_ERR(mailbox)) {
+		dev_err(dev, "[modify_qp]mailboc alloc failed!\n");
+		return PTR_ERR(mailbox);
+	}
+
+	memcpy(mailbox->buf, context, sizeof(*context));
+
+	ret = hns_roce_cmd(
+			hr_dev, mailbox->dma, hr_qp->qpn,
+			0, op[cur_state][new_state],
+			HNS_ROCE_CMD_TIME_CLASS_C);
+
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+	return ret;
+}
+
+static int hns_roce_v1_m_sqp(
+					struct ib_qp *ibqp,
+					const struct ib_qp_attr *attr,
+					int attr_mask,
+					enum ib_qp_state cur_state,
+					enum ib_qp_state new_state)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct hns_roce_sqp_context *context;
+	struct device *dev = &hr_dev->pdev->dev;
+	dma_addr_t dma_handle = 0;
+	u32 rq_pa_start, reg_val;
+	u64 *mtts;
+	u32 *addr;
+
+	context = kzalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		return -ENOMEM;
+
+	/* Search QP buf's MTTs */
+	mtts = hns_roce_table_find(&hr_dev->mr_table.mtt_table,
+			hr_qp->mtt.first_seg, &dma_handle);
+	if (!mtts) {
+		dev_err(dev, "qp buf pa find failed\n");
+		goto out;
+	}
+
+	if (cur_state == IB_QPS_RESET && new_state == IB_QPS_INIT) {
+		roce_set_field(context->qp1c_bytes_4,
+			QP1C_BYTES_4_SQ_WQE_SHIFT_M,
+			QP1C_BYTES_4_SQ_WQE_SHIFT_S,
+			ilog2(hr_qp->sq.wqe_cnt));
+		roce_set_field(context->qp1c_bytes_4,
+			QP1C_BYTES_4_RQ_WQE_SHIFT_M,
+			QP1C_BYTES_4_RQ_WQE_SHIFT_S,
+			ilog2(hr_qp->rq.wqe_cnt));
+		roce_set_field(context->qp1c_bytes_4,
+			QP1C_BYTES_4_PD_M,
+			QP1C_BYTES_4_PD_S,
+			to_hr_pd(ibqp->pd)->pdn);
+
+		context->sq_rq_bt_l = (u32)(dma_handle);
+		roce_set_field(context->qp1c_bytes_12,
+			QP1C_BYTES_12_SQ_RQ_BT_H_M,
+			QP1C_BYTES_12_SQ_RQ_BT_H_S,
+			((u32)(dma_handle >> ADDR_SHIFT_32)));
+
+		roce_set_field(context->qp1c_bytes_16,
+			QP1C_BYTES_16_RQ_HEAD_M,
+			QP1C_BYTES_16_RQ_HEAD_S,
+			hr_qp->rq.head);
+		roce_set_field(context->qp1c_bytes_16,
+			QP1C_BYTES_16_PORT_NUM_M,
+			QP1C_BYTES_16_PORT_NUM_S,
+			hr_qp->port);
+		roce_set_bit(context->qp1c_bytes_16,
+			QP1C_BYTES_16_SIGNALING_TYPE_S,
+			hr_qp->sq_signal_bits);
+		roce_set_bit(context->qp1c_bytes_16,
+			QP1C_BYTES_16_LOCAL_ENABLE_E2E_CREDIT_S,
+			hr_qp->sq_signal_bits);
+		roce_set_bit(context->qp1c_bytes_16,
+			QP1C_BYTES_16_RQ_BA_FLG_S, 1);
+		roce_set_bit(context->qp1c_bytes_16,
+			QP1C_BYTES_16_SQ_BA_FLG_S, 1);
+		roce_set_bit(context->qp1c_bytes_16,
+			QP1C_BYTES_16_QP1_ERR_S, 0);
+
+		roce_set_field(context->qp1c_bytes_20,
+			QP1C_BYTES_20_SQ_HEAD_M,
+			QP1C_BYTES_20_SQ_HEAD_S,
+			hr_qp->sq.head);
+		roce_set_field(context->qp1c_bytes_20,
+			QP1C_BYTES_20_PKEY_IDX_M,
+			QP1C_BYTES_20_PKEY_IDX_S,
+			attr->pkey_index);
+
+		rq_pa_start = hr_qp->rq.offset / PAGE_SIZE;
+		context->cur_rq_wqe_ba_l = (u32)(mtts[rq_pa_start]);
+
+		roce_set_field(context->qp1c_bytes_28,
+			QP1C_BYTES_28_CUR_RQ_WQE_BA_H_M,
+			QP1C_BYTES_28_CUR_RQ_WQE_BA_H_S,
+			(mtts[rq_pa_start]) >> ADDR_SHIFT_32);
+		roce_set_field(context->qp1c_bytes_28,
+			QP1C_BYTES_28_RQ_CUR_IDX_M,
+			QP1C_BYTES_28_RQ_CUR_IDX_S,
+			0);
+
+		roce_set_field(context->qp1c_bytes_32,
+			QP1C_BYTES_32_RX_CQ_NUM_M,
+			QP1C_BYTES_32_RX_CQ_NUM_S,
+			to_hr_cq(ibqp->recv_cq)->cqn);
+		roce_set_field(context->qp1c_bytes_32,
+			QP1C_BYTES_32_TX_CQ_NUM_M,
+			QP1C_BYTES_32_TX_CQ_NUM_S,
+			to_hr_cq(ibqp->send_cq)->cqn);
+
+		context->cur_sq_wqe_ba_l  = (u32)mtts[0];
+
+		roce_set_field(context->qp1c_bytes_40,
+			QP1C_BYTES_40_CUR_SQ_WQE_BA_H_M,
+			QP1C_BYTES_40_CUR_SQ_WQE_BA_H_S,
+			(mtts[0]) >> ADDR_SHIFT_32);
+		roce_set_field(context->qp1c_bytes_40,
+			QP1C_BYTES_40_SQ_CUR_IDX_M,
+			QP1C_BYTES_40_SQ_CUR_IDX_S,
+			0);
+
+		/* Copy context to QP1C register */
+		addr = (u32 *)(hr_dev->reg_base + ROCEE_QP1C_CFG0_0_REG +
+			hr_qp->port * sizeof(*context));
+
+		roce_writel(context->qp1c_bytes_4, addr);
+		roce_writel(context->sq_rq_bt_l, addr + 1);
+		roce_writel(context->qp1c_bytes_12, addr + 2);
+		roce_writel(context->qp1c_bytes_16, addr + 3);
+		roce_writel(context->qp1c_bytes_20, addr + 4);
+		roce_writel(context->cur_rq_wqe_ba_l, addr + 5);
+		roce_writel(context->qp1c_bytes_28, addr + 6);
+		roce_writel(context->qp1c_bytes_32, addr + 7);
+		roce_writel(context->cur_sq_wqe_ba_l, addr + 8);
+	}
+
+	/* Modify QP1C status */
+	addr = (u32 *)(hr_dev->reg_base + ROCEE_QP1C_CFG0_0_REG +
+		hr_qp->port * sizeof(*context));
+	reg_val = roce_readl(addr);
+	roce_set_field(reg_val,
+		ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_M,
+		ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_S,
+		new_state);
+	roce_writel(reg_val, addr);
+
+	hr_qp->state = new_state;
+	if (new_state == IB_QPS_RESET) {
+		hns_roce_v1_cq_clean(
+				to_hr_cq(ibqp->recv_cq),
+				hr_qp->qpn,
+				ibqp->srq ? to_hr_srq(ibqp->srq) : NULL);
+		if (ibqp->send_cq != ibqp->recv_cq)
+			hns_roce_v1_cq_clean(
+				to_hr_cq(ibqp->send_cq),
+				hr_qp->qpn, NULL);
+
+		hr_qp->rq.head = 0;
+		hr_qp->rq.tail = 0;
+		hr_qp->sq.head = 0;
+		hr_qp->sq.tail = 0;
+		hr_qp->sq_next_wqe = 0;
+	}
+
+	kfree(context);
+	return 0;
+
+out:
+	kfree(context);
+	return -EINVAL;
+}
+
+static int hns_roce_v1_m_qp(
+				struct ib_qp *ibqp,
+				const struct ib_qp_attr *attr,
+				int attr_mask,
+				enum ib_qp_state cur_state,
+				enum ib_qp_state new_state)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_qp_context *context;
+	dma_addr_t dma_handle_2 = 0;
+	dma_addr_t dma_handle = 0;
+	int rq_pa_start = 0;
+	u64 *mtts_2 = NULL;
+	int ret = -EINVAL;
+	u64 *mtts = NULL;
+	int port;
+	u8 *dmac;
+	u8 *smac;
+
+	context = kzalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		return -ENOMEM;
+
+	/* Search qp buf's mtts */
+	mtts = hns_roce_table_find(&hr_dev->mr_table.mtt_table,
+			hr_qp->mtt.first_seg, &dma_handle);
+	if (mtts == NULL) {
+		dev_err(dev, "qp buf pa find failed\n");
+		goto out;
+	}
+
+	/* Search IRRL's mtts */
+	mtts_2 = hns_roce_table_find(
+				&hr_dev->qp_table.irrl_table,
+				hr_qp->qpn, &dma_handle_2);
+	if (mtts_2 == NULL) {
+		dev_err(dev, "qp irrl_table find failed\n");
+		goto out;
+	}
+
+	/*
+	*Reset to init
+	*	Mandatory param:
+	*	IB_QP_STATE | IB_QP_PKEY_INDEX | IB_QP_PORT | IB_QP_ACCESS_FLAGS
+	*	Optional param: NA
+	*/
+	if (cur_state == IB_QPS_RESET && new_state == IB_QPS_INIT) {
+		roce_set_field(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_M,
+			QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_S,
+			to_hr_qp_type(hr_qp->ibqp.qp_type));
+
+		roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_ENABLE_FPMR_S, 0);
+		roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S,
+			!!(attr->qp_access_flags & IB_ACCESS_REMOTE_READ));
+		roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S,
+			!!(attr->qp_access_flags & IB_ACCESS_REMOTE_WRITE));
+		roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_ATOMIC_OPERATION_ENABLE_S,
+			!!(attr->qp_access_flags & IB_ACCESS_REMOTE_ATOMIC));
+		roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMAR_USE_S, 1);
+		roce_set_field(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_M,
+			QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_S,
+			ilog2(hr_qp->sq.wqe_cnt));
+		roce_set_field(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_M,
+			QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_S,
+			ilog2(hr_qp->rq.wqe_cnt));
+		roce_set_field(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTES_4_PD_M,
+			QP_CONTEXT_QPC_BYTES_4_PD_S,
+			to_hr_pd(ibqp->pd)->pdn);
+		hr_qp->access_flags = attr->qp_access_flags;
+		roce_set_field(context->qpc_bytes_8,
+			QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_M,
+			QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_S,
+			to_hr_cq(ibqp->send_cq)->cqn);
+		roce_set_field(context->qpc_bytes_8,
+			QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_M,
+			QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_S,
+			to_hr_cq(ibqp->recv_cq)->cqn);
+
+		if (ibqp->srq)
+			roce_set_field(context->qpc_bytes_12,
+				QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_M,
+				QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_S,
+				to_hr_srq(ibqp->srq)->srqn);
+
+		roce_set_field(context->qpc_bytes_12,
+				QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
+				QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S,
+				attr->pkey_index);
+		hr_qp->pkey_index = attr->pkey_index;
+		roce_set_field(context->qpc_bytes_16,
+				QP_CONTEXT_QPC_BYTES_16_QP_NUM_M,
+				QP_CONTEXT_QPC_BYTES_16_QP_NUM_S,
+				hr_qp->qpn);
+
+	} else if (cur_state == IB_QPS_INIT &&
+		new_state == IB_QPS_INIT) {
+		roce_set_field(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_M,
+			QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_S,
+			to_hr_qp_type(hr_qp->ibqp.qp_type));
+		roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_ENABLE_FPMR_S,
+			0);
+		if (attr_mask & IB_QP_ACCESS_FLAGS) {
+			roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S,
+			!!(attr->qp_access_flags & IB_ACCESS_REMOTE_READ));
+			roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S,
+			!!(attr->qp_access_flags & IB_ACCESS_REMOTE_WRITE));
+		} else {
+			roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S,
+			!!(hr_qp->access_flags & IB_ACCESS_REMOTE_READ));
+			roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S,
+			!!(hr_qp->access_flags & IB_ACCESS_REMOTE_WRITE));
+		}
+
+		roce_set_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMAR_USE_S,
+			1);
+		roce_set_field(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_M,
+			QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_S,
+			ilog2(hr_qp->sq.wqe_cnt));
+		roce_set_field(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_M,
+			QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_S,
+			ilog2(hr_qp->rq.wqe_cnt));
+		roce_set_field(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTES_4_PD_M,
+			QP_CONTEXT_QPC_BYTES_4_PD_S,
+			to_hr_pd(ibqp->pd)->pdn);
+
+		roce_set_field(context->qpc_bytes_8,
+			QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_M,
+			QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_S,
+			to_hr_cq(ibqp->send_cq)->cqn);
+		roce_set_field(context->qpc_bytes_8,
+			QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_M,
+			QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_S,
+			to_hr_cq(ibqp->recv_cq)->cqn);
+
+		if (ibqp->srq)
+			roce_set_field(context->qpc_bytes_12,
+			QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_M,
+			QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_S,
+			to_hr_srq(ibqp->srq)->srqn);
+		if (attr_mask & IB_QP_PKEY_INDEX)
+			roce_set_field(context->qpc_bytes_12,
+			QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S,
+			attr->pkey_index);
+		else
+			roce_set_field(context->qpc_bytes_12,
+			QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S,
+			hr_qp->pkey_index);
+
+		roce_set_field(context->qpc_bytes_16,
+			QP_CONTEXT_QPC_BYTES_16_QP_NUM_M,
+			QP_CONTEXT_QPC_BYTES_16_QP_NUM_S,
+			hr_qp->qpn);
+	} else if (cur_state == IB_QPS_INIT &&
+		new_state == IB_QPS_RTR) {
+		if ((attr_mask & IB_QP_ALT_PATH) ||
+			(attr_mask & IB_QP_ACCESS_FLAGS) ||
+			(attr_mask & IB_QP_PKEY_INDEX) ||
+			(attr_mask & IB_QP_QKEY)) {
+			dev_err(dev, "INIT2RTR attr_mask error\n");
+			goto out;
+		}
+
+		dmac = (u8 *)attr->ah_attr.dmac;
+
+		context->sq_rq_bt_l = (u32)(dma_handle);
+		roce_set_field(context->qpc_bytes_24,
+			QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_M,
+			QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_S,
+			((u32)(dma_handle >> ADDR_SHIFT_32)));
+		roce_set_bit(context->qpc_bytes_24,
+			QP_CONTEXT_QPC_BYTE_24_REMOTE_ENABLE_E2E_CREDITS_S,
+			1);
+		roce_set_field(context->qpc_bytes_24,
+			QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_M,
+			QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_S,
+			attr->min_rnr_timer);
+		context->irrl_ba_l = (u32)(dma_handle_2);
+		roce_set_field(context->qpc_bytes_32,
+			QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_M,
+			QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_S,
+			((u32)(dma_handle_2 >> 32)) &
+			QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_M);
+		roce_set_field(context->qpc_bytes_32,
+			QP_CONTEXT_QPC_BYTES_32_MIG_STATE_M,
+			QP_CONTEXT_QPC_BYTES_32_MIG_STATE_S, 0);
+		roce_set_bit(context->qpc_bytes_32,
+			QP_CONTEXT_QPC_BYTE_32_LOCAL_ENABLE_E2E_CREDITS_S,
+			1);
+		roce_set_bit(context->qpc_bytes_32,
+			QP_CONTEXT_QPC_BYTE_32_SIGNALING_TYPE_S,
+			hr_qp->sq_signal_bits);
+
+		for (port = 0; port < hr_dev->caps.num_ports; port++) {
+			smac = (u8 *)hr_dev->dev_addr[port];
+			dev_dbg(dev, "smac: %2x: %2x: %2x: %2x: %2x: %2x\n",
+				smac[0], smac[1], smac[2], smac[3],
+				smac[4], smac[5]);
+			if ((dmac[0] == smac[0]) &&
+				(dmac[1] == smac[1]) &&
+				(dmac[2] == smac[2]) &&
+				(dmac[3] == smac[3]) &&
+				(dmac[4] == smac[4]) &&
+				(dmac[5] == smac[5])) {
+				roce_set_bit(context->qpc_bytes_32,
+				QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S,
+				1);
+				break;
+			}
+		}
+
+		if (hr_dev->loop_idc == 0x1)
+			roce_set_bit(context->qpc_bytes_32,
+				QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S,
+				1);
+
+		roce_set_bit(context->qpc_bytes_32,
+			QP_CONTEXT_QPC_BYTE_32_GLOBAL_HEADER_S,
+			attr->ah_attr.ah_flags);
+		roce_set_field(context->qpc_bytes_32,
+			QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_M,
+			QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_S,
+			ilog2(attr->max_dest_rd_atomic));
+
+		roce_set_field(context->qpc_bytes_36,
+			QP_CONTEXT_QPC_BYTES_36_DEST_QP_M,
+			QP_CONTEXT_QPC_BYTES_36_DEST_QP_S,
+			attr->dest_qp_num);
+
+		/* Configure GID index */
+		roce_set_field(context->qpc_bytes_36,
+			QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_S,
+			hns_get_gid_index(hr_dev, attr->ah_attr.port_num - 1,
+			attr->ah_attr.grh.sgid_index));
+
+		memcpy(&(context->dmac_l), dmac, 4);
+
+		roce_set_field(context->qpc_bytes_44,
+			QP_CONTEXT_QPC_BYTES_44_DMAC_H_M,
+			QP_CONTEXT_QPC_BYTES_44_DMAC_H_S,
+			*((u16 *)(&dmac[4])));
+		roce_set_field(context->qpc_bytes_44,
+			QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_M,
+			QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_S,
+			attr->ah_attr.static_rate);
+		roce_set_field(context->qpc_bytes_44,
+			QP_CONTEXT_QPC_BYTES_44_HOPLMT_M,
+			QP_CONTEXT_QPC_BYTES_44_HOPLMT_S,
+			attr->ah_attr.grh.hop_limit);
+
+		roce_set_field(context->qpc_bytes_48,
+			QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_M,
+			QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_S,
+			attr->ah_attr.grh.flow_label);
+		roce_set_field(context->qpc_bytes_48,
+			QP_CONTEXT_QPC_BYTES_48_TCLASS_M,
+			QP_CONTEXT_QPC_BYTES_48_TCLASS_S,
+			attr->ah_attr.grh.traffic_class);
+		roce_set_field(context->qpc_bytes_48,
+			QP_CONTEXT_QPC_BYTES_48_MTU_M,
+			QP_CONTEXT_QPC_BYTES_48_MTU_S,
+			attr->path_mtu);
+
+		memcpy(context->dgid,
+			attr->ah_attr.grh.dgid.raw,
+			sizeof(attr->ah_attr.grh.dgid.raw));
+
+		dev_dbg(dev, "dmac:%x :%lx\n", context->dmac_l,
+			roce_get_field(context->qpc_bytes_44,
+			QP_CONTEXT_QPC_BYTES_44_DMAC_H_M,
+			QP_CONTEXT_QPC_BYTES_44_DMAC_H_S));
+
+		roce_set_field(context->qpc_bytes_68,
+			QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_M,
+			QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_S,
+			0);
+		roce_set_field(context->qpc_bytes_68,
+			QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_S,
+			0);
+
+		rq_pa_start = hr_qp->rq.offset / PAGE_SIZE;
+		context->cur_rq_wqe_ba_l = (u32)(mtts[rq_pa_start]);
+
+		roce_set_field(context->qpc_bytes_76,
+			QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_M,
+			QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_S,
+			mtts[rq_pa_start] >> ADDR_SHIFT_32);
+		roce_set_field(context->qpc_bytes_76,
+			QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_M,
+			QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_S,
+			0);
+
+		context->rx_rnr_time = 0;
+
+		roce_set_field(context->qpc_bytes_84,
+			QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_M,
+			QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_S,
+			attr->rq_psn - 1);
+		roce_set_field(context->qpc_bytes_84,
+			QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_M,
+			QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_S,
+			0);
+
+		roce_set_field(context->qpc_bytes_88,
+			QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_M,
+			QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_S,
+			attr->rq_psn);
+		roce_set_bit(context->qpc_bytes_88,
+			QP_CONTEXT_QPC_BYTES_88_RX_REQ_PSN_ERR_FLAG_S,
+			0);
+		roce_set_bit(context->qpc_bytes_88,
+			QP_CONTEXT_QPC_BYTES_88_RX_LAST_OPCODE_FLG_S,
+			0);
+		roce_set_field(context->qpc_bytes_88,
+			QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_M,
+			QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_S,
+			0);
+		roce_set_field(context->qpc_bytes_88,
+			QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_M,
+			QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_S,
+			0);
+
+		context->dma_length = 0;
+		context->r_key = 0;
+		context->va_l = 0;
+		context->va_h = 0;
+
+		roce_set_field(context->qpc_bytes_108,
+			QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_M,
+			QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_S,
+			0);
+		roce_set_bit(context->qpc_bytes_108,
+			QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_FLG_S,
+			0);
+		roce_set_bit(context->qpc_bytes_108,
+			QP_CONTEXT_QPC_BYTES_108_TRRL_TDB_PSN_FLG_S,
+			0);
+
+		roce_set_field(context->qpc_bytes_112,
+			QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_M,
+			QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_S,
+			0);
+		roce_set_field(context->qpc_bytes_112,
+			QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_M,
+			QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_S,
+			0);
+
+		/* For chip resp ack */
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M,
+			QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S,
+			hr_qp->port);
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_SL_M,
+			QP_CONTEXT_QPC_BYTES_156_SL_S,
+			attr->ah_attr.sl);
+		hr_qp->sl = attr->ah_attr.sl;
+	} else if (cur_state == IB_QPS_RTR &&
+		new_state == IB_QPS_RTS) {
+		/* If exist optional param, return error */
+		if ((attr_mask & IB_QP_ALT_PATH) ||
+			(attr_mask & IB_QP_ACCESS_FLAGS) ||
+			(attr_mask & IB_QP_QKEY) ||
+			(attr_mask & IB_QP_PATH_MIG_STATE) ||
+			(attr_mask & IB_QP_CUR_STATE) ||
+			(attr_mask & IB_QP_MIN_RNR_TIMER)) {
+			dev_err(dev, "RTR2RTS attr_mask error\n");
+			goto out;
+		}
+
+		context->rx_cur_sq_wqe_ba_l = (u32)(mtts[0]);
+
+		roce_set_field(context->qpc_bytes_120,
+			QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_M,
+			QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_S,
+			(mtts[0]) >> ADDR_SHIFT_32);
+
+		roce_set_field(context->qpc_bytes_124,
+			QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_M,
+			QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_S,
+			0);
+		roce_set_field(context->qpc_bytes_124,
+			QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_M,
+			QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_S,
+			0);
+
+		roce_set_field(context->qpc_bytes_128,
+			QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_M,
+			QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_S,
+			attr->sq_psn);
+		roce_set_bit(context->qpc_bytes_128,
+			QP_CONTEXT_QPC_BYTES_128_RX_ACK_PSN_ERR_FLG_S,
+			0);
+		roce_set_field(context->qpc_bytes_128,
+			QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_M,
+			QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_S,
+			0);
+		roce_set_bit(context->qpc_bytes_128,
+			QP_CONTEXT_QPC_BYTES_128_IRRL_PSN_VLD_FLG_S,
+			0);
+
+		roce_set_field(context->qpc_bytes_132,
+			QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_M,
+			QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_S,
+			0);
+		roce_set_field(context->qpc_bytes_132,
+			QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_M,
+			QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_S,
+			0);
+
+		roce_set_field(context->qpc_bytes_136,
+			QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_M,
+			QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_S,
+			attr->sq_psn);
+		roce_set_field(context->qpc_bytes_136,
+			QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_M,
+			QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_S,
+			attr->sq_psn);
+
+		roce_set_field(context->qpc_bytes_140,
+			QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_M,
+			QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_S,
+			(attr->sq_psn >> SQ_PSN_SHIFT));
+		roce_set_field(context->qpc_bytes_140,
+			QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_M,
+			QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_S,
+			0);
+		roce_set_bit(context->qpc_bytes_140,
+			QP_CONTEXT_QPC_BYTES_140_RNR_RETRY_FLG_S,
+			0);
+
+		roce_set_field(context->qpc_bytes_144,
+			QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
+			QP_CONTEXT_QPC_BYTES_144_QP_STATE_S,
+			attr->qp_state);
+
+		roce_set_field(context->qpc_bytes_148,
+			QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_M,
+			QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_S,
+			0);
+		roce_set_field(context->qpc_bytes_148,
+			QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_M,
+			QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_S,
+			0);
+		roce_set_field(context->qpc_bytes_148,
+			QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_M,
+			QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_S,
+			0);
+		roce_set_field(context->qpc_bytes_148,
+			QP_CONTEXT_QPC_BYTES_148_LSN_M,
+			QP_CONTEXT_QPC_BYTES_148_LSN_S,
+			0x100);
+
+		context->rnr_retry = 0;
+
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_M,
+			QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_S,
+			attr->retry_cnt);
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_M,
+			QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_S,
+			attr->timeout);
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_M,
+			QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_S,
+			attr->rnr_retry);
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M,
+			QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S,
+			hr_qp->port);
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_SL_M,
+			QP_CONTEXT_QPC_BYTES_156_SL_S,
+			attr->ah_attr.sl);
+		hr_qp->sl = attr->ah_attr.sl;
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_M,
+			QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_S,
+			ilog2(attr->max_rd_atomic));
+		roce_set_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_M,
+			QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_S,
+			0);
+		context->pkt_use_len = 0;
+
+		roce_set_field(context->qpc_bytes_164,
+			QP_CONTEXT_QPC_BYTES_164_SQ_PSN_M,
+			QP_CONTEXT_QPC_BYTES_164_SQ_PSN_S,
+			attr->sq_psn);
+		roce_set_field(context->qpc_bytes_164,
+			QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_M,
+			QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_S,
+			0);
+
+		roce_set_field(context->qpc_bytes_168,
+			QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_M,
+			QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_S,
+			attr->sq_psn);
+		roce_set_field(context->qpc_bytes_168,
+			QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_M,
+			QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_S,
+			0);
+		roce_set_field(context->qpc_bytes_168,
+			QP_CONTEXT_QPC_BYTES_168_DB_TYPE_M,
+			QP_CONTEXT_QPC_BYTES_168_DB_TYPE_S,
+			0);
+		roce_set_bit(context->qpc_bytes_168,
+			QP_CONTEXT_QPC_BYTES_168_MSG_LP_IND_S,
+			0);
+		roce_set_bit(context->qpc_bytes_168,
+			QP_CONTEXT_QPC_BYTES_168_CSDB_LP_IND_S,
+			0);
+		roce_set_bit(context->qpc_bytes_168,
+			QP_CONTEXT_QPC_BYTES_168_QP_ERR_FLG_S,
+			0);
+		context->sge_use_len = 0;
+
+		roce_set_field(context->qpc_bytes_176,
+			QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_S,
+			0);
+		roce_set_field(context->qpc_bytes_176,
+			QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_S,
+			0);
+
+		roce_set_field(context->qpc_bytes_180,
+			QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_S,
+			0);
+		roce_set_field(context->qpc_bytes_180,
+			QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_M,
+			QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_S,
+			0);
+
+		context->tx_cur_sq_wqe_ba_l = (u32)(mtts[0]);
+
+		roce_set_field(context->qpc_bytes_188,
+			QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_M,
+			QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_S,
+			(mtts[0]) >> ADDR_SHIFT_32);
+		roce_set_bit(context->qpc_bytes_188,
+			QP_CONTEXT_QPC_BYTES_188_PKT_RETRY_FLG_S,
+			0);
+		roce_set_field(context->qpc_bytes_188,
+			QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_S,
+			0);
+	} else if ((cur_state == IB_QPS_INIT && new_state == IB_QPS_RESET) ||
+		(cur_state == IB_QPS_INIT && new_state == IB_QPS_ERR) ||
+		(cur_state == IB_QPS_RTR && new_state == IB_QPS_RESET) ||
+		(cur_state == IB_QPS_RTR && new_state == IB_QPS_ERR) ||
+		(cur_state == IB_QPS_RTS && new_state == IB_QPS_RESET) ||
+		(cur_state == IB_QPS_RTS && new_state == IB_QPS_ERR) ||
+		(cur_state == IB_QPS_ERR && new_state == IB_QPS_RESET) ||
+		(cur_state == IB_QPS_ERR && new_state == IB_QPS_ERR)) {
+		roce_set_field(context->qpc_bytes_144,
+			QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
+			QP_CONTEXT_QPC_BYTES_144_QP_STATE_S,
+			attr->qp_state);
+
+	} else {
+		dev_err(dev, "not support this modify\n");
+		goto out;
+	}
+
+	/* Every status migrate must change state */
+	roce_set_field(context->qpc_bytes_144,
+			QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
+			QP_CONTEXT_QPC_BYTES_144_QP_STATE_S,
+			attr->qp_state);
+
+	/* SW pass context to HW */
+	ret = hns_roce_v1_qp_modify(
+				hr_dev, &hr_qp->mtt,
+				to_hns_roce_state(cur_state),
+				to_hns_roce_state(new_state),
+				context,
+				hr_qp);
+	if (ret) {
+		dev_err(dev, "hns_roce_qp_modify failed\n");
+		goto out;
+	}
+
+	/*
+	* Use rst2init to instead of init2init with drv,
+	* need to hw to flash RQ HEAD by DB again
+	*/
+	if (cur_state == IB_QPS_INIT && new_state == IB_QPS_INIT) {
+		u32 reg_val = 0;
+		u32 *addr = NULL;
+
+		/* Memory barrier */
+		wmb();
+		if (hr_qp->ibqp.qp_type == IB_QPT_GSI) {
+			/* SW update GSI rq header */
+			addr = (u32 *)(hr_dev->reg_base +
+				ROCEE_QP1C_CFG3_0_REG +
+				QP1C_CFGN_OFFSET * hr_qp->port);
+			reg_val = roce_readl(addr);
+			roce_set_field(reg_val,
+				ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_M,
+				ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_S,
+				hr_qp->rq.head);
+			roce_writel(reg_val, addr);
+		} else {
+			uint32_t doorbell[2] = {0};
+
+			struct hns_roce_rq_db rq_db;
+
+			rq_db.u32_4 = 0;
+			rq_db.u32_8 = 0;
+
+			roce_set_field(rq_db.u32_4,
+				RQ_DOORBELL_U32_4_RQ_HEAD_M,
+				RQ_DOORBELL_U32_4_RQ_HEAD_S,
+				hr_qp->rq.head);
+			roce_set_field(rq_db.u32_8,
+				RQ_DOORBELL_U32_8_QPN_M,
+				RQ_DOORBELL_U32_8_QPN_S,
+				hr_qp->qpn);
+			roce_set_field(rq_db.u32_8,
+				RQ_DOORBELL_U32_8_CMD_M,
+				RQ_DOORBELL_U32_8_CMD_S,
+				1);
+			roce_set_bit(rq_db.u32_8,
+				RQ_DOORBELL_U32_8_HW_SYNC_S,
+				1);
+
+			doorbell[0] = rq_db.u32_4;
+			doorbell[1] = rq_db.u32_8;
+
+			hns_roce_write64_k(doorbell, hr_qp->rq.db_reg_l);
+		}
+	}
+
+	hr_qp->state = new_state;
+
+	if (attr_mask & IB_QP_MAX_DEST_RD_ATOMIC)
+		hr_qp->resp_depth = attr->max_dest_rd_atomic;
+	if (attr_mask & IB_QP_PORT)
+		hr_qp->port = (attr->port_num - 1);
+
+	if (new_state == IB_QPS_RESET && !ibqp->uobject) {
+		hns_roce_v1_cq_clean(to_hr_cq(ibqp->recv_cq),
+			hr_qp->qpn, ibqp->srq ?
+			to_hr_srq(ibqp->srq) : NULL);
+		if (ibqp->send_cq != ibqp->recv_cq)
+			hns_roce_v1_cq_clean(to_hr_cq(ibqp->send_cq),
+			hr_qp->qpn, NULL);
+
+		hr_qp->rq.head = 0;
+		hr_qp->rq.tail = 0;
+		hr_qp->sq.head = 0;
+		hr_qp->sq.tail = 0;
+		hr_qp->sq_next_wqe = 0;
+	}
+
+out:
+	kfree(context);
+	return ret;
+}
+
+int hns_roce_v1_modify_qp(
+			struct ib_qp *ibqp, const struct ib_qp_attr *attr,
+			int attr_mask, enum ib_qp_state cur_state,
+			enum ib_qp_state new_state)
+{
+
+	if (ibqp->qp_type == IB_QPT_GSI || ibqp->qp_type == IB_QPT_SMI)
+		return hns_roce_v1_m_sqp(
+			ibqp, attr, attr_mask, cur_state, new_state);
+	else
+		return hns_roce_v1_m_qp(
+			ibqp, attr, attr_mask, cur_state, new_state);
+}
+
+static enum ib_qp_state to_ib_qp_state(enum hns_roce_qp_state state)
+{
+	switch (state) {
+	case HNS_ROCE_QP_STATE_RST:
+		return IB_QPS_RESET;
+	case HNS_ROCE_QP_STATE_INIT:
+		return IB_QPS_INIT;
+	case HNS_ROCE_QP_STATE_RTR:
+		return IB_QPS_RTR;
+	case HNS_ROCE_QP_STATE_RTS:
+		return IB_QPS_RTS;
+	case HNS_ROCE_QP_STATE_SQD:
+		return IB_QPS_SQD;
+	case HNS_ROCE_QP_STATE_ERR:
+		return IB_QPS_ERR;
+	default:
+		return -1;
+	}
+}
+
+static int hns_roce_v1_query_qpc(
+			struct hns_roce_dev *hr_dev,
+			struct hns_roce_qp *hr_qp,
+			struct hns_roce_qp_context *hr_context)
+{
+	struct hns_roce_cmd_mailbox *mailbox;
+	int ret;
+
+	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
+	if (IS_ERR(mailbox)) {
+		dev_err(&hr_dev->pdev->dev,
+			"Alloc mailbox failed\n");
+		return PTR_ERR(mailbox);
+	}
+
+	ret = hns_roce_cmd_box(
+			hr_dev, 0, mailbox->dma, hr_qp->qpn, 0,
+			HNS_ROCE_CMD_QUERY_QP,
+			HNS_ROCE_CMD_TIME_CLASS_A);
+	if (!ret)
+		memcpy(hr_context, mailbox->buf, sizeof(*hr_context));
+	else
+		dev_err(&hr_dev->pdev->dev,
+			"QUERY QP cmd process error\n");
+
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+
+	return ret;
+}
+
+int hns_roce_v1_query_qp(
+			struct ib_qp *ibqp,
+			struct ib_qp_attr *qp_attr,
+			int qp_attr_mask,
+			struct ib_qp_init_attr *qp_init_attr)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_qp_context *context;
+	int state;
+	int ret = 0;
+	int tmp_qp_state = 0;
+
+	context = kzalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		return -ENOMEM;
+
+	memset(qp_attr, 0, sizeof(*qp_attr));
+	memset(qp_init_attr, 0, sizeof(*qp_init_attr));
+
+	mutex_lock(&hr_qp->mutex);
+
+	if (hr_qp->state == IB_QPS_RESET) {
+		qp_attr->qp_state = IB_QPS_RESET;
+		goto done;
+	}
+
+	ret = hns_roce_v1_query_qpc(hr_dev, hr_qp, context);
+	if (ret) {
+		dev_err(dev, "query qpc error\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	state = roce_get_field(context->qpc_bytes_144,
+			QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
+			QP_CONTEXT_QPC_BYTES_144_QP_STATE_S);
+	tmp_qp_state = to_ib_qp_state(state);
+	if (tmp_qp_state == -1) {
+		dev_err(dev, "to_ib_qp_state error\n");
+		ret = -EINVAL;
+		goto out;
+	}
+	hr_qp->state = (u8)tmp_qp_state;
+	qp_attr->qp_state = hr_qp->state;
+	qp_attr->path_mtu = (u8)roce_get_field(context->qpc_bytes_48,
+			QP_CONTEXT_QPC_BYTES_48_MTU_M,
+			QP_CONTEXT_QPC_BYTES_48_MTU_S);
+	qp_attr->path_mig_state = IB_MIG_ARMED;
+	if (hr_qp->ibqp.qp_type == IB_QPT_UD)
+		qp_attr->qkey = QKEY_VAL;
+	else
+		qp_attr->qkey = 0;
+
+	qp_attr->rq_psn = roce_get_field(context->qpc_bytes_88,
+			QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_M,
+			QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_S);
+	qp_attr->sq_psn = (u32)roce_get_field(context->qpc_bytes_164,
+			QP_CONTEXT_QPC_BYTES_164_SQ_PSN_M,
+			QP_CONTEXT_QPC_BYTES_164_SQ_PSN_S);
+	qp_attr->dest_qp_num = (u8)roce_get_field(context->qpc_bytes_36,
+			QP_CONTEXT_QPC_BYTES_36_DEST_QP_M,
+			QP_CONTEXT_QPC_BYTES_36_DEST_QP_S);
+	qp_attr->qp_access_flags =
+	((roce_get_bit(context->qpc_bytes_4,
+		QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S)) << 2) |
+	((roce_get_bit(context->qpc_bytes_4,
+		QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S)) << 1) |
+	((roce_get_bit(context->qpc_bytes_4,
+		QP_CONTEXT_QPC_BYTE_4_ATOMIC_OPERATION_ENABLE_S)) << 3);
+
+	if (hr_qp->ibqp.qp_type == IB_QPT_RC ||
+		hr_qp->ibqp.qp_type == IB_QPT_UC) {
+		qp_attr->ah_attr.sl =
+			roce_get_field(context->qpc_bytes_156,
+			QP_CONTEXT_QPC_BYTES_156_SL_M,
+			QP_CONTEXT_QPC_BYTES_156_SL_S);
+
+		qp_attr->ah_attr.grh.flow_label =
+			roce_get_field(context->qpc_bytes_48,
+			QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_M,
+			QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_S);
+		qp_attr->ah_attr.grh.sgid_index =
+			roce_get_field(context->qpc_bytes_36,
+			QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_M,
+			QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_S);
+		qp_attr->ah_attr.grh.hop_limit =
+			roce_get_field(context->qpc_bytes_44,
+			QP_CONTEXT_QPC_BYTES_44_HOPLMT_M,
+			QP_CONTEXT_QPC_BYTES_44_HOPLMT_S);
+		qp_attr->ah_attr.grh.traffic_class =
+			roce_get_field(context->qpc_bytes_48,
+			QP_CONTEXT_QPC_BYTES_48_TCLASS_M,
+			QP_CONTEXT_QPC_BYTES_48_TCLASS_S);
+
+		memcpy(qp_attr->ah_attr.grh.dgid.raw, context->dgid,
+			sizeof(qp_attr->ah_attr.grh.dgid.raw));
+		qp_attr->alt_pkey_index = 0;
+		qp_attr->alt_port_num   = 0;
+	}
+
+	qp_attr->pkey_index = roce_get_field(context->qpc_bytes_12,
+		QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
+		QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S);
+	qp_attr->port_num   = (u8)roce_get_field(context->qpc_bytes_156,
+		QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M,
+		QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S) + 1;
+	qp_attr->sq_draining = 0;
+	qp_attr->max_rd_atomic = roce_get_field(context->qpc_bytes_156,
+		QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_M,
+		QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_S);
+	qp_attr->max_dest_rd_atomic = roce_get_field(context->qpc_bytes_32,
+		QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_M,
+		QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_S);
+	qp_attr->min_rnr_timer = (u8)(roce_get_field(context->qpc_bytes_24,
+		QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_M,
+		QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_S));
+	qp_attr->timeout       = (u8)(roce_get_field(context->qpc_bytes_156,
+		QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_M,
+		QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_S));
+	qp_attr->retry_cnt     = roce_get_field(context->qpc_bytes_148,
+		QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_M,
+		QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_S);
+	qp_attr->rnr_retry     = context->rnr_retry;
+	qp_attr->alt_timeout   = 0;
+
+done:
+	qp_attr->cur_qp_state     = qp_attr->qp_state;
+	qp_attr->cap.max_recv_wr  = hr_qp->rq.wqe_cnt;
+	qp_attr->cap.max_recv_sge = hr_qp->rq.max_gs;
+
+	if (!ibqp->uobject) {
+		qp_attr->cap.max_send_wr  = hr_qp->sq.wqe_cnt;
+		qp_attr->cap.max_send_sge = hr_qp->sq.max_gs;
+	} else {
+		qp_attr->cap.max_send_wr  = 0;
+		qp_attr->cap.max_send_sge = 0;
+	}
+
+	qp_attr->cap.max_inline_data = 0;
+
+	qp_init_attr->cap         = qp_attr->cap;
+
+	qp_init_attr->create_flags = 0;
+
+out:
+	mutex_unlock(&hr_qp->mutex);
+
+	kfree(context);
+
+	return ret;
+}
+
+static void hns_roce_v1_destroy_qp_common(
+					struct hns_roce_dev *hr_dev,
+					struct hns_roce_qp *hr_qp,
+					int is_user)
+{
+	u32 sdbinvcnt;
+	unsigned long end = 0;
+	u32 sdbinvcnt_val;
+	u32 sdbsendptr_val;
+	u32 sdbisusepr_val;
+	struct hns_roce_cq *send_cq, *recv_cq;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	if (hr_qp->ibqp.qp_type == IB_QPT_RC) {
+		if (hr_qp->state != IB_QPS_RESET) {
+			/*
+			* Set qp to ERR,
+			* waiting for hw complete processing all dbs
+			*/
+			if (hns_roce_v1_qp_modify(hr_dev, NULL,
+				to_hns_roce_state(hr_qp->state),
+				HNS_ROCE_QP_STATE_ERR, NULL,
+				hr_qp))
+				dev_err(dev, "modify QP %06x to ERR failed.\n",
+					hr_qp->qpn);
+
+			/* Record issued doorbell */
+			sdbisusepr_val = roce_readl(hr_dev->reg_base +
+				ROCEE_SDB_ISSUE_PTR_REG);
+			/*
+			* Query db process status,
+			* until hw process completely
+			*/
+			end =
+			msecs_to_jiffies(HNS_ROCE_QP_DESTROY_TIMEOUT_MSECS) +
+			jiffies;
+			do {
+				sdbsendptr_val = roce_readl(hr_dev->reg_base +
+					ROCEE_SDB_SEND_PTR_REG);
+				if (!time_before(jiffies, end)) {
+					dev_err(dev,
+						"destroy qp(0x%x) timeout!!!",
+						hr_qp->qpn);
+					break;
+				}
+			} while ((short)(roce_get_field(sdbsendptr_val,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S) -
+				roce_get_field(sdbisusepr_val,
+					ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_M,
+					ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_S)
+				) < 0);
+
+			/* Get list pointer */
+			sdbinvcnt = roce_readl(hr_dev->reg_base +
+				ROCEE_SDB_INV_CNT_REG);
+
+			/* Query db's list status, until hw reversal */
+			do {
+				sdbinvcnt_val = roce_readl(hr_dev->reg_base +
+					ROCEE_SDB_INV_CNT_REG);
+				if (!time_before(jiffies, end)) {
+					dev_err(dev,
+						"destroy qp(0x%x) timeout!!!",
+						hr_qp->qpn);
+					dev_err(dev, "SdbInvCnt = 0x%x\n",
+						sdbinvcnt_val);
+					break;
+				}
+			} while ((short)(roce_get_field(sdbinvcnt_val,
+				ROCEE_SDB_INV_CNT_SDB_INV_CNT_M,
+				ROCEE_SDB_INV_CNT_SDB_INV_CNT_S) -
+				(sdbinvcnt + SDB_INV_CNT_OFFSET)) < 0);
+
+			/* Modify qp to reset before destroying qp */
+			if (hns_roce_v1_qp_modify(hr_dev, NULL,
+				to_hns_roce_state(hr_qp->state),
+				HNS_ROCE_QP_STATE_RST, NULL, hr_qp))
+				dev_err(dev, "modify QP %06x to RESET failed.\n",
+					hr_qp->qpn);
+		}
+	}
+
+	send_cq = to_hr_cq(hr_qp->ibqp.send_cq);
+	recv_cq = to_hr_cq(hr_qp->ibqp.recv_cq);
+
+	hns_roce_lock_cqs(send_cq, recv_cq);
+
+	if (!is_user) {
+		hns_roce_v1_clean_cq(recv_cq, hr_qp->qpn,
+			hr_qp->ibqp.srq ? to_hr_srq(hr_qp->ibqp.srq) : NULL);
+		if (send_cq != recv_cq)
+			hns_roce_v1_clean_cq(send_cq,
+					hr_qp->qpn, NULL);
+	}
+
+	hns_roce_qp_remove(hr_dev, hr_qp);
+
+	hns_roce_unlock_cqs(send_cq, recv_cq);
+
+	hns_roce_qp_free(hr_dev, hr_qp);
+
+	/* Not special_QP, free their QPN */
+	if ((hr_qp->ibqp.qp_type == IB_QPT_RC)
+		|| (hr_qp->ibqp.qp_type == IB_QPT_UC)
+		|| (hr_qp->ibqp.qp_type == IB_QPT_UD))
+		hns_roce_release_range_qp(hr_dev,
+				hr_qp->qpn, 1);
+
+	hns_roce_mtt_cleanup(hr_dev, &hr_qp->mtt);
+
+	if (is_user) {
+		if (!hr_qp->ibqp.srq)
+			/* SRQ not support */
+			;
+		ib_umem_release(hr_qp->umem);
+	} else {
+		kfree(hr_qp->sq.wrid);
+		kfree(hr_qp->rq.wrid);
+		hns_roce_buf_free(hr_dev, hr_qp->buff_size,
+				&hr_qp->hr_buf);
+	}
+}
+
+int hns_roce_v1_destroy_qp(struct ib_qp *ibqp)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+
+	hns_roce_v1_destroy_qp_common(hr_dev,
+			hr_qp, !!ibqp->pd->uobject);
+
+	if (hr_qp->ibqp.qp_type == IB_QPT_GSI)
+		kfree(hr_to_hr_sqp(hr_qp));
+	else
+		kfree(hr_qp);
+
+	return 0;
+}
+
+struct hns_roce_v1_priv hr_v1_priv;
+
+struct hns_roce_hw hns_roce_v1_hw = {
+	.reset = hns_roce_v1_reset,
+	.hw_profile = hns_roce_v1_profile,
+	.hw_init = hns_roce_v1_init,
+	.hw_uninit = hns_roce_v1_uninit,
+	.set_gid = hns_roce_v1_set_gid,
+	.set_mac = hns_roce_v1_set_mac,
+	.set_mtu = hns_roce_v1_set_mtu,
+	.write_mtpt = hns_roce_v1_write_mtpt,
+	.write_cqc = hns_roce_v1_write_cqc,
+	.modify_qp = hns_roce_v1_modify_qp,
+	.query_qp = hns_roce_v1_query_qp,
+	.destroy_qp = hns_roce_v1_destroy_qp,
+	.post_send = hns_roce_v1_post_send,
+	.post_recv = hns_roce_v1_post_recv,
+	.req_notify_cq = hns_roce_v1_req_notify_cq,
+	.poll_cq = hns_roce_v1_poll_cq,
+	.priv = &hr_v1_priv,
+};
+
diff --git a/drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h b/drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h
new file mode 100644
index 0000000..a7a281d
--- /dev/null
+++ b/drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h
@@ -0,0 +1,1071 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_V1_HW_H
+#define _HNS_ROCE_V1_HW_H
+
+#define CQ_STATE_INVALID    0
+#define CQ_STATE_RESERV     1
+#define CQ_STATE_VALID      2
+#define CQ_STATE_ERR        3
+
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
+#define HNS_ROCE_V1_CEQC_ENTRY_SIZE		16
+#define HNS_ROCE_V1_AEQC_ENTRY_SIZE		16
+
+#define HNS_ROCE_V1_CQE_ENTRY_SIZE		32
+#define HNS_ROCE_V1_WQE_ENTRY_SIZE		64
+#define HNS_ROCE_V1_CEQE_ENTRY_SIZE		4
+#define HNS_ROCE_V1_AEQE_ENTRY_SIZE		16
+
+#define HNS_ROCE_V1_PAGE_SIZE_SUPPORT		0xFFFFF000
+#define HNS_ROCE_V1_DEFAULT_MTU			IB_MTU_1024
+#define HNS_ROCE_V1_DEFAULT_SL_WEIGHT		0xf
+
+#define HNS_ROCE_V1_EXT_RAQ_WF			8
+#define HNS_ROCE_V1_RAQ_ENTRY			64
+#define HNS_ROCE_V1_RAQ_DEPTH			32768
+#define HNS_ROCE_V1_RAQ_SIZE	\
+	(HNS_ROCE_V1_RAQ_ENTRY * HNS_ROCE_V1_RAQ_DEPTH)
+#define HNS_ROCE_V1_POL_TIME			1
+
+#define HNS_ROCE_V1_SDB_DEPTH			0x400
+#define HNS_ROCE_V1_ODB_DEPTH			0x400
+
+#define HNS_ROCE_V1_DB_RSVD			0x80
+
+#define HNS_ROCE_V1_SDB_ALEPT			HNS_ROCE_V1_DB_RSVD
+#define HNS_ROCE_V1_SDB_ALFUL	\
+	(HNS_ROCE_V1_SDB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+#define HNS_ROCE_V1_ODB_ALEPT			HNS_ROCE_V1_DB_RSVD
+#define HNS_ROCE_V1_ODB_ALFUL	\
+	(HNS_ROCE_V1_ODB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+#define HNS_ROCE_V1_SDB_OVFL	\
+	(HNS_ROCE_V1_SDB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+
+#define HNS_ROCE_V1_EXT_SDB_DEPTH		0x4000
+#define HNS_ROCE_V1_EXT_ODB_DEPTH		0x4000
+#define HNS_ROCE_V1_EXT_SDB_ENTRY		16
+#define HNS_ROCE_V1_EXT_ODB_ENTRY		16
+#define HNS_ROCE_V1_EXT_SDB_SIZE  \
+	(HNS_ROCE_V1_EXT_SDB_DEPTH * HNS_ROCE_V1_EXT_SDB_ENTRY)
+#define HNS_ROCE_V1_EXT_ODB_SIZE  \
+	(HNS_ROCE_V1_EXT_ODB_DEPTH * HNS_ROCE_V1_EXT_ODB_ENTRY)
+
+#define HNS_ROCE_V1_EXT_SDB_ALEPT		HNS_ROCE_V1_DB_RSVD
+#define HNS_ROCE_V1_EXT_SDB_ALFUL  \
+	(HNS_ROCE_V1_EXT_SDB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+#define HNS_ROCE_V1_EXT_ODB_ALEPT		HNS_ROCE_V1_DB_RSVD
+#define HNS_ROCE_V1_EXT_ODB_ALFUL	\
+	(HNS_ROCE_V1_EXT_ODB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+
+#define HNS_ROCE_SDB_POLL_MODE		0
+#define HNS_ROCE_SDB_EVENT_MODE		1
+
+#define HNS_ROCE_ODB_POLL_MODE		0
+#define HNS_ROCE_ODB_EVENT_MODE		1
+
+#define HNS_ROCE_SDB_NORMAL_MODE	0
+#define HNS_ROCE_SDB_EXTEND_MODE	1
+
+#define HNS_ROCE_ODB_NORMAL_MODE	0
+#define HNS_ROCE_ODB_EXTEND_MODE	1
+
+#define KEY_INVALIDE			0x00
+#define KEY_FREE			0x01
+#define KEY_VALID			0x02
+
+#define HNS_ROCE_CQE_QPN_MASK		0x3ffff
+#define HNS_ROCE_CQE_STATUS_MASK	0x1f
+#define HNS_ROCE_CQE_OPCODE_MASK	0xf
+
+#define HNS_ROCE_CQE_SUCCESS				0x00
+#define HNS_ROCE_CQE_SYNDROME_LOCAL_LENGTH_ERR		0x01
+#define HNS_ROCE_CQE_SYNDROME_LOCAL_QP_OP_ERR		0x02
+#define HNS_ROCE_CQE_SYNDROME_LOCAL_PROT_ERR		0x03
+#define HNS_ROCE_CQE_SYNDROME_WR_FLUSH_ERR		0x04
+#define HNS_ROCE_CQE_SYNDROME_MEM_MANAGE_OPERATE_ERR	0x05
+#define HNS_ROCE_CQE_SYNDROME_BAD_RESP_ERR		0x06
+#define HNS_ROCE_CQE_SYNDROME_LOCAL_ACCESS_ERR		0x07
+#define HNS_ROCE_CQE_SYNDROME_REMOTE_INVAL_REQ_ERR	0x08
+#define HNS_ROCE_CQE_SYNDROME_REMOTE_ACCESS_ERR		0x09
+#define HNS_ROCE_CQE_SYNDROME_REMOTE_OP_ERR		0x0a
+#define HNS_ROCE_CQE_SYNDROME_TRANSPORT_RETRY_EXC_ERR	0x0b
+#define HNS_ROCE_CQE_SYNDROME_RNR_RETRY_EXC_ERR		0x0c
+
+#define QP1C_CFGN_OFFSET		0x28
+#define PHY_PORT_OFFSET			0x8
+#define MTPT_IDX_SHIFT			16
+#define ALL_PORT_VAL_OPEN		0x3f
+#define POL_TIME_INTERVAL_VAL		0x80
+#define SLEEP_TIME_INTERVAL		20
+#define SQ_PSN_SHIFT			8
+#define QKEY_VAL			0x80010000
+#define SDB_INV_CNT_OFFSET		8
+
+struct hns_roce_cq_context {
+	u32 cqc_byte_4;
+	u32 cq_bt_l;
+	u32 cqc_byte_12;
+	u32 cur_cqe_ba0_l;
+	u32 cqc_byte_20;
+	u32 cqe_tptr_addr_l;
+	u32 cur_cqe_ba1_l;
+	u32 cqc_byte_32;
+};
+
+#define CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_S 0
+#define CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_M   \
+	(((1UL << 2) - 1) << CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_S)
+
+#define CQ_CONTEXT_CQC_BYTE_4_CQN_S 16
+#define CQ_CONTEXT_CQC_BYTE_4_CQN_M   \
+	(((1UL << 16) - 1) << CQ_CONTEXT_CQC_BYTE_4_CQN_S)
+
+#define CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_S 0
+#define CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_M   \
+	(((1UL << 17) - 1) << CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_S)
+
+#define CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_S 20
+#define CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_M   \
+	(((1UL << 4) - 1) << CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_S)
+
+#define CQ_CONTEXT_CQC_BYTE_12_CEQN_S 24
+#define CQ_CONTEXT_CQC_BYTE_12_CEQN_M   \
+	(((1UL << 5) - 1) << CQ_CONTEXT_CQC_BYTE_12_CEQN_S)
+
+#define CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_S 0
+#define CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_M   \
+	(((1UL << 5) - 1) << CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_S)
+
+#define CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_S 16
+#define CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_M   \
+	(((1UL << 16) - 1) << CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_S)
+
+#define CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_S 8
+#define CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_M   \
+	(((1UL << 5) - 1) << CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_S)
+
+#define CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_S 0
+#define CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_M   \
+	(((1UL << 5) - 1) << CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_S)
+
+#define CQ_CONTEXT_CQC_BYTE_32_SE_FLAG_S 9
+
+#define CQ_CONTEXT_CQC_BYTE_32_CE_FLAG_S 8
+
+#define CQ_CONTEXT_CQC_BYTE_32_NOTIFICATION_FLAG_S 14
+
+#define CQ_CQNTEXT_CQC_BYTE_32_TYPE_OF_COMPLETION_NOTIFICATION_S 15
+
+#define CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_S 16
+#define CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_M   \
+	(((1UL << 16) - 1) << CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_S)
+
+struct hns_roce_cqe {
+	u32 cqe_byte_4;
+	union {
+		u32 r_key;
+		u32 immediate_data;
+	};
+	u32 byte_cnt;
+	u32 cqe_byte_16;
+	u32 cqe_byte_20;
+	u32 s_mac_l;
+	u32 cqe_byte_28;
+	u32 reserved;
+};
+
+#define CQE_BYTE_4_OWNER_S 7
+#define CQE_BYTE_4_SQ_RQ_FLAG_S 14
+
+#define CQE_BYTE_4_STATUS_OF_THE_OPERATION_S 8
+#define CQE_BYTE_4_STATUS_OF_THE_OPERATION_M   \
+	(((1UL << 5) - 1) << CQE_BYTE_4_STATUS_OF_THE_OPERATION_S)
+
+#define CQE_BYTE_4_WQE_INDEX_S 16
+#define CQE_BYTE_4_WQE_INDEX_M   \
+	(((1UL << 14) - 1) << CQE_BYTE_4_WQE_INDEX_S)
+
+#define CQE_BYTE_4_OPERATION_TYPE_S 0
+#define CQE_BYTE_4_OPERATION_TYPE_M   \
+	(((1UL << 4) - 1) << CQE_BYTE_4_OPERATION_TYPE_S)
+
+#define CQE_BYTE_4_IMM_INDICATOR_S 15
+
+#define CQE_BYTE_16_LOCAL_QPN_S 0
+#define CQE_BYTE_16_LOCAL_QPN_M   \
+	(((1UL << 24) - 1) << CQE_BYTE_16_LOCAL_QPN_S)
+
+#define CQE_BYTE_20_PORT_NUM_S 26
+#define CQE_BYTE_20_PORT_NUM_M   \
+	(((1UL << 3) - 1) << CQE_BYTE_20_PORT_NUM_S)
+
+#define CQE_BYTE_20_SL_S 24
+#define CQE_BYTE_20_SL_M   \
+	(((1UL << 2) - 1) << CQE_BYTE_20_SL_S)
+
+#define CQE_BYTE_20_REMOTE_QPN_S 0
+#define CQE_BYTE_20_REMOTE_QPN_M   \
+	(((1UL << 24) - 1) << CQE_BYTE_20_REMOTE_QPN_S)
+
+#define CQE_BYTE_20_GRH_PRESENT_S 29
+
+#define CQE_BYTE_28_P_KEY_IDX_S 16
+#define CQE_BYTE_28_P_KEY_IDX_M   \
+	(((1UL << 16) - 1) << CQE_BYTE_28_P_KEY_IDX_S)
+
+#define CQ_DB_REQ_NOT_SOL	0
+#define CQ_DB_REQ_NOT		(1 << 16)
+
+struct hns_roce_v1_mpt_entry {
+	u32  mpt_byte_4;
+	u32  pbl_addr_l;
+	u32  mpt_byte_12;
+	u32  virt_addr_l;
+	u32  virt_addr_h;
+	u32  length;
+	u32  mpt_byte_28;
+	u32  pa0_l;
+	u32  mpt_byte_36;
+	u32  mpt_byte_40;
+	u32  mpt_byte_44;
+	u32  mpt_byte_48;
+	u32  pa4_l;
+	u32  mpt_byte_56;
+	u32  mpt_byte_60;
+	u32  mpt_byte_64;
+};
+
+#define MPT_BYTE_4_KEY_STATE_S 0
+#define MPT_BYTE_4_KEY_STATE_M   \
+	(((1UL << 2) - 1) << MPT_BYTE_4_KEY_STATE_S)
+
+#define MPT_BYTE_4_KEY_S 8
+#define MPT_BYTE_4_KEY_M   \
+	(((1UL << 8) - 1) << MPT_BYTE_4_KEY_S)
+
+#define MPT_BYTE_4_PAGE_SIZE_S 16
+#define MPT_BYTE_4_PAGE_SIZE_M   \
+	(((1UL << 2) - 1) << MPT_BYTE_4_PAGE_SIZE_S)
+
+#define MPT_BYTE_4_MW_TYPE_S 20
+
+#define MPT_BYTE_4_MW_BIND_ENABLE_S 21
+
+#define MPT_BYTE_4_OWN_S 22
+
+#define MPT_BYTE_4_MEMORY_LOCATION_TYPE_S 24
+#define MPT_BYTE_4_MEMORY_LOCATION_TYPE_M   \
+	(((1UL << 2) - 1) << \
+	MPT_BYTE_4_MEMORY_LOCATION_TYPE_S)
+
+#define MPT_BYTE_4_REMOTE_ATOMIC_S 26
+#define MPT_BYTE_4_LOCAL_WRITE_S 27
+#define MPT_BYTE_4_REMOTE_WRITE_S 28
+#define MPT_BYTE_4_REMOTE_READ_S 29
+#define MPT_BYTE_4_REMOTE_INVAL_ENABLE_S 30
+#define MPT_BYTE_4_ADDRESS_TYPE_S 31
+
+#define MPT_BYTE_12_PBL_ADDR_H_S 0
+#define MPT_BYTE_12_PBL_ADDR_H_M   \
+	(((1UL << 17) - 1) << MPT_BYTE_12_PBL_ADDR_H_S)
+
+#define MPT_BYTE_12_MW_BIND_COUNTER_S 17
+#define MPT_BYTE_12_MW_BIND_COUNTER_M   \
+	(((1UL << 15) - 1) << MPT_BYTE_12_MW_BIND_COUNTER_S)
+
+#define MPT_BYTE_28_PD_S 0
+#define MPT_BYTE_28_PD_M   \
+	(((1UL << 16) - 1) << MPT_BYTE_28_PD_S)
+
+#define MPT_BYTE_28_L_KEY_IDX_L_S 16
+#define MPT_BYTE_28_L_KEY_IDX_L_M   \
+	(((1UL << 16) - 1) << MPT_BYTE_28_L_KEY_IDX_L_S)
+
+#define MPT_BYTE_36_PA0_H_S 0
+#define MPT_BYTE_36_PA0_H_M   \
+	(((1UL << 5) - 1) << MPT_BYTE_36_PA0_H_S)
+
+#define MPT_BYTE_36_PA1_L_S 8
+#define MPT_BYTE_36_PA1_L_M   \
+	(((1UL << 24) - 1) << MPT_BYTE_36_PA1_L_S)
+
+#define MPT_BYTE_40_PA1_H_S 0
+#define MPT_BYTE_40_PA1_H_M   \
+	(((1UL << 13) - 1) << MPT_BYTE_40_PA1_H_S)
+
+#define MPT_BYTE_40_PA2_L_S 16
+#define MPT_BYTE_40_PA2_L_M   \
+	(((1UL << 16) - 1) << MPT_BYTE_40_PA2_L_S)
+
+
+#define MPT_BYTE_44_PA2_H_S 0
+#define MPT_BYTE_44_PA2_H_M   \
+	(((1UL << 21) - 1) << MPT_BYTE_44_PA2_H_S)
+
+#define MPT_BYTE_44_PA3_L_S 24
+#define MPT_BYTE_44_PA3_L_M   \
+	(((1UL << 8) - 1) << MPT_BYTE_44_PA3_L_S)
+
+#define MPT_BYTE_48_PA3_H_S 0
+#define MPT_BYTE_48_PA3_H_M   \
+	(((1UL << 29) - 1) << MPT_BYTE_48_PA3_H_S)
+
+#define MPT_BYTE_56_PA4_H_S 0
+#define MPT_BYTE_56_PA4_H_M   \
+	(((1UL << 5) - 1) << MPT_BYTE_56_PA4_H_S)
+
+#define MPT_BYTE_56_PA5_L_S 8
+#define MPT_BYTE_56_PA5_L_M   \
+	(((1UL << 24) - 1) << MPT_BYTE_56_PA5_L_S)
+
+#define MPT_BYTE_60_PA5_H_S 0
+#define MPT_BYTE_60_PA5_H_M   \
+	(((1UL << 13) - 1) << MPT_BYTE_60_PA5_H_S)
+
+#define MPT_BYTE_60_PA6_L_S 16
+#define MPT_BYTE_60_PA6_L_M   \
+	(((1UL << 16) - 1) << MPT_BYTE_60_PA6_L_S)
+
+#define MPT_BYTE_64_PA6_H_S 0
+#define MPT_BYTE_64_PA6_H_M   \
+	(((1UL << 21) - 1) << MPT_BYTE_64_PA6_H_S)
+
+#define MPT_BYTE_64_L_KEY_IDX_H_S 24
+#define MPT_BYTE_64_L_KEY_IDX_H_M   \
+	(((1UL << 8) - 1) << MPT_BYTE_64_L_KEY_IDX_H_S)
+
+struct hns_roce_wqe_ctrl_seg {
+	__be32 sgl_pa_h;
+	__be32 flag;
+	__be32 imm_data;
+	__be32 msg_length;
+};
+
+struct hns_roce_wqe_data_seg {
+	__be64    addr;
+	__be32    lkey;
+	__be32    len;
+};
+
+struct hns_roce_wqe_raddr_seg {
+	__be32 rkey;
+	__be32 len;/* reserved */
+	__be64 raddr;
+};
+
+struct hns_roce_wqe_local_inval_seg {
+	u32        reserved;
+	__be32    flags;
+	__be32    rkey;
+	__be32    lkey;
+};
+
+struct hns_roce_rq_wqe_ctrl {
+
+	u32 rwqe_byte_4;
+	u32 rocee_sgl_ba_l;
+	u32 rwqe_byte_12;
+	u32 reserved[5];
+};
+
+#define RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_S 16
+#define RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_M   \
+	(((1UL << 6) - 1) << RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_S)
+
+#define HNS_ROCE_QP_DESTROY_TIMEOUT_MSECS	10000
+
+#define GID_LEN 16
+
+struct hns_roce_ud_send_wqe {
+	u32 dmac_h;
+	u32 u32_8;
+	u32 immediate_data;
+
+	u32 u32_16;
+	union {
+		unsigned char dgid[GID_LEN];
+		struct {
+			u32 u32_20;
+			u32 u32_24;
+			u32 u32_28;
+			u32 u32_32;
+		};
+	};
+
+	u32 u32_36;
+	u32 u32_40;
+
+	u32 va0_l;
+	u32 va0_h;
+	u32 l_key0;
+
+	u32 va1_l;
+	u32 va1_h;
+	u32 l_key1;
+};
+
+#define UD_SEND_WQE_U32_4_DMAC_0_S 0
+#define UD_SEND_WQE_U32_4_DMAC_0_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_4_DMAC_0_S)
+
+#define UD_SEND_WQE_U32_4_DMAC_1_S 8
+#define UD_SEND_WQE_U32_4_DMAC_1_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_4_DMAC_1_S)
+
+#define UD_SEND_WQE_U32_4_DMAC_2_S 16
+#define UD_SEND_WQE_U32_4_DMAC_2_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_4_DMAC_2_S)
+
+#define UD_SEND_WQE_U32_4_DMAC_3_S 24
+#define UD_SEND_WQE_U32_4_DMAC_3_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_4_DMAC_3_S)
+
+
+#define UD_SEND_WQE_U32_8_DMAC_4_S 0
+#define UD_SEND_WQE_U32_8_DMAC_4_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_8_DMAC_4_S)
+
+#define UD_SEND_WQE_U32_8_DMAC_5_S 8
+#define UD_SEND_WQE_U32_8_DMAC_5_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_8_DMAC_5_S)
+
+#define UD_SEND_WQE_U32_8_OPERATION_TYPE_S 16
+#define UD_SEND_WQE_U32_8_OPERATION_TYPE_M   \
+	(((1UL << 4) - 1) << UD_SEND_WQE_U32_8_OPERATION_TYPE_S)
+
+#define UD_SEND_WQE_U32_8_COMPLETION_NOTIFICATION_INDICATOR_S 20
+#define UD_SEND_WQE_U32_8_LOOPBACK_INDICATOR_S 22
+#define UD_SEND_WQE_U32_8_IMMEDIATE_DATA_INDICATOR_S 23
+
+#define UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_S 24
+#define UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_M   \
+	(((1UL << 6) - 1) << UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_S)
+
+#define UD_SEND_WQE_U32_8_SOLICITED_EVENT_S 30
+#define UD_SEND_WQE_U32_8_SEND_GL_ROUTING_HDR_FLAG_S 31
+
+#define UD_SEND_WQE_U32_16_DEST_QP_S 0
+#define UD_SEND_WQE_U32_16_DEST_QP_M   \
+	(((1UL << 24) - 1) << UD_SEND_WQE_U32_16_DEST_QP_S)
+
+#define UD_SEND_WQE_U32_16_MAX_STATIC_RATE_S 24
+#define UD_SEND_WQE_U32_16_MAX_STATIC_RATE_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_16_MAX_STATIC_RATE_S)
+
+#define UD_SEND_WQE_U32_36_FLOW_LABEL_S 0
+#define UD_SEND_WQE_U32_36_FLOW_LABEL_M   \
+	(((1UL << 20) - 1) << UD_SEND_WQE_U32_36_FLOW_LABEL_S)
+
+#define UD_SEND_WQE_U32_36_PRIORITY_S 20
+#define UD_SEND_WQE_U32_36_PRIORITY_M   \
+	(((1UL << 4) - 1) << UD_SEND_WQE_U32_36_PRIORITY_S)
+
+#define UD_SEND_WQE_U32_36_SGID_INDEX_S 24
+#define UD_SEND_WQE_U32_36_SGID_INDEX_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_36_SGID_INDEX_S)
+
+
+#define UD_SEND_WQE_U32_40_HOP_LIMIT_S 0
+#define UD_SEND_WQE_U32_40_HOP_LIMIT_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_40_HOP_LIMIT_S)
+
+#define UD_SEND_WQE_U32_40_TRAFFIC_CLASS_S 8
+#define UD_SEND_WQE_U32_40_TRAFFIC_CLASS_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_40_TRAFFIC_CLASS_S)
+
+struct hns_roce_sqp_context {
+	u32 qp1c_bytes_4;
+	u32 sq_rq_bt_l;
+	u32 qp1c_bytes_12;
+	u32 qp1c_bytes_16;
+	u32 qp1c_bytes_20;
+	u32 qp1c_bytes_28;
+	u32 cur_rq_wqe_ba_l;
+	u32 qp1c_bytes_32;
+	u32 cur_sq_wqe_ba_l;
+	u32 qp1c_bytes_40;
+};
+
+#define QP1C_BYTES_4_QP_STATE_S 0
+#define QP1C_BYTES_4_QP_STATE_M   \
+	(((1UL << 3) - 1) << QP1C_BYTES_4_QP_STATE_S)
+
+#define QP1C_BYTES_4_SQ_WQE_SHIFT_S 8
+#define QP1C_BYTES_4_SQ_WQE_SHIFT_M   \
+	(((1UL << 4) - 1) << QP1C_BYTES_4_SQ_WQE_SHIFT_S)
+
+#define QP1C_BYTES_4_RQ_WQE_SHIFT_S 12
+#define QP1C_BYTES_4_RQ_WQE_SHIFT_M   \
+	(((1UL << 4) - 1) << QP1C_BYTES_4_RQ_WQE_SHIFT_S)
+
+#define QP1C_BYTES_4_PD_S 16
+#define QP1C_BYTES_4_PD_M   \
+	(((1UL << 16) - 1) << QP1C_BYTES_4_PD_S)
+
+#define QP1C_BYTES_12_SQ_RQ_BT_H_S 0
+#define QP1C_BYTES_12_SQ_RQ_BT_H_M   \
+	(((1UL << 17) - 1) << QP1C_BYTES_12_SQ_RQ_BT_H_S)
+
+#define QP1C_BYTES_16_RQ_HEAD_S 0
+#define QP1C_BYTES_16_RQ_HEAD_M   \
+	(((1UL << 15) - 1) << QP1C_BYTES_16_RQ_HEAD_S)
+
+#define QP1C_BYTES_16_PORT_NUM_S 16
+#define QP1C_BYTES_16_PORT_NUM_M   \
+	(((1UL << 3) - 1) << QP1C_BYTES_16_PORT_NUM_S)
+
+#define QP1C_BYTES_16_SIGNALING_TYPE_S 27
+#define QP1C_BYTES_16_LOCAL_ENABLE_E2E_CREDIT_S 28
+#define QP1C_BYTES_16_RQ_BA_FLG_S 29
+#define QP1C_BYTES_16_SQ_BA_FLG_S 30
+#define QP1C_BYTES_16_QP1_ERR_S 31
+
+#define QP1C_BYTES_20_SQ_HEAD_S 0
+#define QP1C_BYTES_20_SQ_HEAD_M   \
+	(((1UL << 15) - 1) << QP1C_BYTES_20_SQ_HEAD_S)
+
+#define QP1C_BYTES_20_PKEY_IDX_S 16
+#define QP1C_BYTES_20_PKEY_IDX_M   \
+	(((1UL << 16) - 1) << QP1C_BYTES_20_PKEY_IDX_S)
+
+#define QP1C_BYTES_28_CUR_RQ_WQE_BA_H_S 0
+#define QP1C_BYTES_28_CUR_RQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << \
+	QP1C_BYTES_28_CUR_RQ_WQE_BA_H_S)
+
+#define QP1C_BYTES_28_RQ_CUR_IDX_S 16
+#define QP1C_BYTES_28_RQ_CUR_IDX_M   \
+	(((1UL << 15) - 1) << QP1C_BYTES_28_RQ_CUR_IDX_S)
+
+#define QP1C_BYTES_32_TX_CQ_NUM_S 0
+#define QP1C_BYTES_32_TX_CQ_NUM_M   \
+	(((1UL << 16) - 1) << QP1C_BYTES_32_TX_CQ_NUM_S)
+
+#define QP1C_BYTES_32_RX_CQ_NUM_S 16
+#define QP1C_BYTES_32_RX_CQ_NUM_M   \
+	(((1UL << 16) - 1) << QP1C_BYTES_32_RX_CQ_NUM_S)
+
+#define QP1C_BYTES_40_CUR_SQ_WQE_BA_H_S 0
+#define QP1C_BYTES_40_CUR_SQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << \
+	QP1C_BYTES_40_CUR_SQ_WQE_BA_H_S)
+
+#define QP1C_BYTES_40_SQ_CUR_IDX_S 16
+#define QP1C_BYTES_40_SQ_CUR_IDX_M   \
+	(((1UL << 15) - 1) << QP1C_BYTES_40_SQ_CUR_IDX_S)
+
+#define HNS_ROCE_WQE_INLINE		(1UL<<31)
+#define HNS_ROCE_WQE_SE			(1UL<<30)
+
+#define HNS_ROCE_WQE_SGE_NUM_BIT	24
+#define HNS_ROCE_WQE_IMM		(1UL<<23)
+#define HNS_ROCE_WQE_INV_RKEY		(1UL<<22)
+#define HNS_ROCE_WQE_FENCE		(1UL<<21)
+#define HNS_ROCE_WQE_CQ_NOTIFY		(1UL<<20)
+
+#define HNS_ROCE_WQE_OPCODE_SEND	(0<<16)
+#define HNS_ROCE_WQE_OPCODE_RDMA_READ	(1<<16)
+#define HNS_ROCE_WQE_OPCODE_RDMA_WRITE	(2<<16)
+#define HNS_ROCE_WQE_OPCODE_FAST_REG_MR	(3<<16)
+#define HNS_ROCE_WQE_OPCODE_LOCAL_INV	(4<<16)
+#define HNS_ROCE_WQE_OPCODE_BIND_MW1	(5<<16)
+#define HNS_ROCE_WQE_OPCODE_BIND_MW2	(6<<16)
+#define HNS_ROCE_WQE_OPCODE_UD_SEND	(7<<16)
+#define HNS_ROCE_WQE_OPCODE_MASK	(15<<16)
+
+struct hns_roce_qp_context {
+	u32 qpc_bytes_4;
+	u32 qpc_bytes_8;
+	u32 qpc_bytes_12;
+	u32 qpc_bytes_16;
+	u32 sq_rq_bt_l;
+	u32 qpc_bytes_24;
+	u32 irrl_ba_l;
+	u32 qpc_bytes_32;
+	u32 qpc_bytes_36;
+	u32 dmac_l;
+	u32 qpc_bytes_44;
+	u32 qpc_bytes_48;
+	u8 dgid[16];
+	u32 qpc_bytes_68;
+	u32 cur_rq_wqe_ba_l;
+	u32 qpc_bytes_76;
+	u32 rx_rnr_time;
+	u32 qpc_bytes_84;
+	u32 qpc_bytes_88;
+	union {
+		u32 rx_sge_len;
+		u32 dma_length;
+	};
+	union {
+		u32 rx_sge_num;
+		u32 rx_send_pktn;
+		u32 r_key;
+	};
+	u32 va_l;
+	u32 va_h;
+	u32 qpc_bytes_108;
+	u32 qpc_bytes_112;
+	u32 rx_cur_sq_wqe_ba_l;
+	u32 qpc_bytes_120;
+	u32 qpc_bytes_124;
+	u32 qpc_bytes_128;
+	u32 qpc_bytes_132;
+	u32 qpc_bytes_136;
+	u32 qpc_bytes_140;
+	u32 qpc_bytes_144;
+	u32 qpc_bytes_148;
+	union {
+		u32 rnr_retry;
+		u32 ack_time;
+	};
+	u32 qpc_bytes_156;
+	u32 pkt_use_len;
+	u32 qpc_bytes_164;
+	u32 qpc_bytes_168;
+	union {
+		u32 sge_use_len;
+		u32 pa_use_len;
+	};
+	u32 qpc_bytes_176;
+	u32 qpc_bytes_180;
+	u32 tx_cur_sq_wqe_ba_l;
+	u32 qpc_bytes_188;
+	u32 rvd21;
+};
+
+#define QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_S 0
+#define QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_M   \
+	(((1UL << 3) - 1) << \
+	QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_S)
+
+#define QP_CONTEXT_QPC_BYTE_4_ENABLE_FPMR_S 3
+#define QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S 4
+#define QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S 5
+#define QP_CONTEXT_QPC_BYTE_4_ATOMIC_OPERATION_ENABLE_S 6
+#define QP_CONTEXT_QPC_BYTE_4_RDMAR_USE_S 7
+
+#define QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_S 8
+#define QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_M   \
+	(((1UL << 4) - 1) << \
+	QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_S)
+
+#define QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_S 12
+#define QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_M   \
+	(((1UL << 4) - 1) << \
+	QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_S)
+
+#define QP_CONTEXT_QPC_BYTES_4_PD_S 16
+#define QP_CONTEXT_QPC_BYTES_4_PD_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_4_PD_S)
+
+#define QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_S 0
+#define QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_S)
+
+#define QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_S 16
+#define QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_S)
+
+#define QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_S 0
+#define QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_S)
+
+#define QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_16_QP_NUM_S 0
+#define QP_CONTEXT_QPC_BYTES_16_QP_NUM_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_16_QP_NUM_S)
+
+#define QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_S 0
+#define QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_M   \
+	(((1UL << 17) - 1) << QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_S 18
+#define QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_M   \
+	(((1UL << 5) - 1) << \
+	QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_S)
+
+#define QP_CONTEXT_QPC_BYTE_24_REMOTE_ENABLE_E2E_CREDITS_S 23
+
+#define QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_S 0
+#define QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_M   \
+	(((1UL << 17) - 1) << QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_32_MIG_STATE_S 18
+#define QP_CONTEXT_QPC_BYTES_32_MIG_STATE_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_32_MIG_STATE_S)
+
+#define QP_CONTEXT_QPC_BYTE_32_LOCAL_ENABLE_E2E_CREDITS_S 20
+#define QP_CONTEXT_QPC_BYTE_32_SIGNALING_TYPE_S 21
+#define QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S 22
+#define QP_CONTEXT_QPC_BYTE_32_GLOBAL_HEADER_S 23
+
+#define QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_S 24
+#define QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_M   \
+	(((1UL << 8) - 1) << \
+	QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_S)
+
+#define QP_CONTEXT_QPC_BYTES_36_DEST_QP_S 0
+#define QP_CONTEXT_QPC_BYTES_36_DEST_QP_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_36_DEST_QP_S)
+
+#define QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_S 24
+#define QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_44_DMAC_H_S 0
+#define QP_CONTEXT_QPC_BYTES_44_DMAC_H_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_44_DMAC_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_S 16
+#define QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_M   \
+	(((1UL << 8) - 1) << \
+	QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_S)
+
+#define QP_CONTEXT_QPC_BYTES_44_HOPLMT_S 24
+#define QP_CONTEXT_QPC_BYTES_44_HOPLMT_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_44_HOPLMT_S)
+
+#define QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_S 0
+#define QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_M   \
+	(((1UL << 20) - 1) << QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_S)
+
+#define QP_CONTEXT_QPC_BYTES_48_TCLASS_S 20
+#define QP_CONTEXT_QPC_BYTES_48_TCLASS_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_48_TCLASS_S)
+
+#define QP_CONTEXT_QPC_BYTES_48_MTU_S 28
+#define QP_CONTEXT_QPC_BYTES_48_MTU_M   \
+	(((1UL << 4) - 1) << QP_CONTEXT_QPC_BYTES_48_MTU_S)
+
+#define QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_S 0
+#define QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_S)
+
+#define QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_S 0
+#define QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_S 8
+#define QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_S 24
+#define QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_S)
+
+#define QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_S 0
+#define QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_88_RX_REQ_PSN_ERR_FLAG_S 24
+#define QP_CONTEXT_QPC_BYTES_88_RX_LAST_OPCODE_FLG_S 25
+
+#define QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_S 26
+#define QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_M   \
+	(((1UL << 2) - 1) << \
+	QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_S)
+
+#define QP_CONTEXT_QPC_BYTES_88_RX_RNR_TIME_FLG_S 28
+
+#define QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_S 29
+#define QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_M   \
+	(((1UL << 2) - 1) << \
+	QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_S)
+
+#define QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_FLG_S 24
+#define QP_CONTEXT_QPC_BYTES_108_TRRL_TDB_PSN_FLG_S 25
+
+#define QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_S 24
+#define QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_S)
+
+#define QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_S 0
+#define QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << \
+	QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_S 0
+#define QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_S 16
+#define QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_S)
+
+#define QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_S 0
+#define QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_128_RX_ACK_PSN_ERR_FLG_S 24
+
+#define QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_S 25
+#define QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_M   \
+	(((1UL << 2) - 1) << \
+	QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_S)
+
+#define QP_CONTEXT_QPC_BYTES_128_IRRL_PSN_VLD_FLG_S 27
+
+#define QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_S 24
+#define QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_S)
+
+#define QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_S 24
+#define QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_M   \
+	(((1UL << 8) - 1) << \
+	QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_S)
+
+#define QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_S 0
+#define QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_M   \
+	(((1UL << 16) - 1) << \
+	QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_S 16
+#define QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_M   \
+	(((1UL << 15) - 1) << \
+	QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_140_RNR_RETRY_FLG_S 31
+
+#define QP_CONTEXT_QPC_BYTES_144_QP_STATE_S 0
+#define QP_CONTEXT_QPC_BYTES_144_QP_STATE_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_144_QP_STATE_S)
+
+#define QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_S 0
+#define QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_S)
+
+#define QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_S 2
+#define QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_S)
+
+#define QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_S 5
+#define QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_M   \
+	(((1UL << 3) - 1) << \
+	QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_S)
+
+#define QP_CONTEXT_QPC_BYTES_148_LSN_S 8
+#define QP_CONTEXT_QPC_BYTES_148_LSN_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_148_LSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_S 0
+#define QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_M   \
+	(((1UL << 3) - 1) << \
+	QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_S 3
+#define QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_M   \
+	(((1UL << 5) - 1) << QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_S 8
+#define QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_M   \
+	(((1UL << 3) - 1) << \
+	QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S 11
+#define QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_SL_S 14
+#define QP_CONTEXT_QPC_BYTES_156_SL_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_156_SL_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_S 16
+#define QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_M   \
+	(((1UL << 8) - 1) << \
+	QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_S 24
+#define QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_S)
+
+#define QP_CONTEXT_QPC_BYTES_164_SQ_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_164_SQ_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_164_SQ_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_S 24
+#define QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_S)
+
+#define QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_S 24
+#define QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_S)
+
+#define QP_CONTEXT_QPC_BYTES_168_DB_TYPE_S 26
+#define QP_CONTEXT_QPC_BYTES_168_DB_TYPE_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_168_DB_TYPE_S)
+
+#define QP_CONTEXT_QPC_BYTES_168_MSG_LP_IND_S 28
+#define QP_CONTEXT_QPC_BYTES_168_CSDB_LP_IND_S 29
+#define QP_CONTEXT_QPC_BYTES_168_QP_ERR_FLG_S 30
+
+#define QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_S 0
+#define QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << \
+	QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_S 0
+#define QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_S)
+
+#define QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_S 0
+#define QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << \
+	QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_188_PKT_RETRY_FLG_S 8
+
+#define QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << \
+	QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_S)
+
+struct hns_roce_rq_db {
+	u32    u32_4;
+	u32    u32_8;
+};
+
+#define RQ_DOORBELL_U32_4_RQ_HEAD_S 0
+#define RQ_DOORBELL_U32_4_RQ_HEAD_M   \
+	(((1UL << 15) - 1) << RQ_DOORBELL_U32_4_RQ_HEAD_S)
+
+#define RQ_DOORBELL_U32_8_QPN_S 0
+#define RQ_DOORBELL_U32_8_QPN_M   \
+	(((1UL << 24) - 1) << RQ_DOORBELL_U32_8_QPN_S)
+
+#define RQ_DOORBELL_U32_8_CMD_S 28
+#define RQ_DOORBELL_U32_8_CMD_M   \
+	(((1UL << 3) - 1) << RQ_DOORBELL_U32_8_CMD_S)
+
+#define RQ_DOORBELL_U32_8_HW_SYNC_S 31
+
+struct hns_roce_sq_db {
+	u32    u32_4;
+	u32    u32_8;
+};
+
+#define SQ_DOORBELL_U32_4_SQ_HEAD_S 0
+#define SQ_DOORBELL_U32_4_SQ_HEAD_M   \
+	(((1UL << 15) - 1) << SQ_DOORBELL_U32_4_SQ_HEAD_S)
+
+#define SQ_DOORBELL_U32_4_PORT_S 18
+#define SQ_DOORBELL_U32_4_PORT_M   \
+	(((1UL << 3) - 1) << SQ_DOORBELL_U32_4_PORT_S)
+
+#define SQ_DOORBELL_U32_8_QPN_S 0
+#define SQ_DOORBELL_U32_8_QPN_M   \
+	(((1UL << 24) - 1) << SQ_DOORBELL_U32_8_QPN_S)
+
+#define SQ_DOORBELL_HW_SYNC_S 31
+
+struct hns_roce_ext_db {
+	int esdb_almept;
+	int esdb_alful;
+	int eodb_almept;
+	int eodb_alful;
+	int esdb_dep;
+	int eodb_dep;
+	struct hns_roce_buf_list *sdb_buf_list;
+	struct hns_roce_buf_list *odb_buf_list;
+};
+
+struct hns_roce_db_table {
+	int  sdb_ext_mod;
+	int  odb_ext_mod;
+	int  sdb_almept;
+	int  sdb_almful;
+	int  odb_almept;
+	int  odb_almful;
+	struct hns_roce_ext_db *ext_db;
+};
+
+struct hns_roce_v1_priv {
+	struct hns_roce_db_table  db_table;
+	struct hns_roce_raq_table raq_table;
+};
+
+extern int hns_roce_probe(
+			struct platform_device *pdev,
+			struct hns_roce_hw *hw);
+extern int hns_roce_remove(struct platform_device *pdev);
+extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, u32 val);
+#endif
+
-- 
1.9.1
