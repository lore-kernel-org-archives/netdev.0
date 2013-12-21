From: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH V2 2/4] misc: xgene: Add base driver for APM X-Gene SoC Queue Manager/Traffic Manager
Date: Fri, 20 Dec 2013 18:57:29 -0800
Message-ID: <1387594651-25771-3-git-send-email-rapatel@apm.com>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org, Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: arnd-r2nGTMty4D4@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1387594651-25771-1-git-send-email-rapatel-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds APM X-Gene SoC Queue Manager/Traffic Manager base driver.
 QMTM is requried by Ethernet, PktDMA (XOR Engine) and Security Engine
 subsystems.

Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
---
 MAINTAINERS                                |    7 +
 drivers/misc/Kconfig                       |    1 +
 drivers/misc/Makefile                      |    1 +
 drivers/misc/xgene/Kconfig                 |    1 +
 drivers/misc/xgene/Makefile                |    5 +
 drivers/misc/xgene/qmtm/Kconfig            |    9 +
 drivers/misc/xgene/qmtm/Makefile           |    7 +
 drivers/misc/xgene/qmtm/xgene_qmtm_main.c  |  761 ++++++++++++++++++++++++++++
 drivers/misc/xgene/qmtm/xgene_qmtm_main.h  |  134 +++++
 drivers/misc/xgene/qmtm/xgene_qmtm_storm.c |  370 ++++++++++++++
 drivers/misc/xgene/qmtm/xgene_qmtm_storm.h |  139 +++++
 include/misc/xgene/xgene_qmtm.h            |  277 ++++++++++
 12 files changed, 1712 insertions(+)
 create mode 100644 drivers/misc/xgene/Kconfig
 create mode 100644 drivers/misc/xgene/Makefile
 create mode 100644 drivers/misc/xgene/qmtm/Kconfig
 create mode 100644 drivers/misc/xgene/qmtm/Makefile
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_main.c
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_main.h
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_storm.c
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_storm.h
 create mode 100644 include/misc/xgene/xgene_qmtm.h

diff --git a/MAINTAINERS b/MAINTAINERS
index f216db8..920cae8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -665,6 +665,13 @@ S:	Maintained
 F:	drivers/net/appletalk/
 F:	net/appletalk/
 
+APPLIEDMICRO (APM) X-GENE SOC QUEUE MANAGER/TRAFFIC MANAGER (QMTM) DRIVER
+M:	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+M:	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+S:	Maintained
+F:	drivers/misc/xgene/
+F:	include/misc/xgene/xgene_qmtm.h
+
 APTINA CAMERA SENSOR PLL
 M:	Laurent Pinchart <Laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
 L:	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index a3e291d..b309553 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -525,4 +525,5 @@ source "drivers/misc/altera-stapl/Kconfig"
 source "drivers/misc/mei/Kconfig"
 source "drivers/misc/vmw_vmci/Kconfig"
 source "drivers/misc/mic/Kconfig"
+source "drivers/misc/xgene/Kconfig"
 endmenu
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index f45473e..0fd3b1b 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -53,3 +53,4 @@ obj-$(CONFIG_VMWARE_VMCI)	+= vmw_vmci/
 obj-$(CONFIG_LATTICE_ECP3_CONFIG)	+= lattice-ecp3-config.o
 obj-$(CONFIG_SRAM)		+= sram.o
 obj-y				+= mic/
+obj-$(CONFIG_ARCH_XGENE)	+= xgene/
diff --git a/drivers/misc/xgene/Kconfig b/drivers/misc/xgene/Kconfig
new file mode 100644
index 0000000..8f38568
--- /dev/null
+++ b/drivers/misc/xgene/Kconfig
@@ -0,0 +1 @@
+source "drivers/misc/xgene/qmtm/Kconfig"
diff --git a/drivers/misc/xgene/Makefile b/drivers/misc/xgene/Makefile
new file mode 100644
index 0000000..198c2e6
--- /dev/null
+++ b/drivers/misc/xgene/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for APM X-GENE misc drivers.
+#
+
+obj-$(CONFIG_XGENE_QMTM)	+= qmtm/
diff --git a/drivers/misc/xgene/qmtm/Kconfig b/drivers/misc/xgene/qmtm/Kconfig
new file mode 100644
index 0000000..8efda4d
--- /dev/null
+++ b/drivers/misc/xgene/qmtm/Kconfig
@@ -0,0 +1,9 @@
+config XGENE_QMTM
+	tristate "APM X-Gene Queue Manager/Traffic Manager driver"
+	depends on ARM64 || COMPILE_TEST
+	default y
+	help
+	  This option enables APM X-Gene Queue Manager Traffic Manager (QMTM)
+	  driver support.
+	  QMTM is required for Ethernet, PktDMA (XOR Engine) and Security
+	  Engine.
diff --git a/drivers/misc/xgene/qmtm/Makefile b/drivers/misc/xgene/qmtm/Makefile
new file mode 100644
index 0000000..68c2a86
--- /dev/null
+++ b/drivers/misc/xgene/qmtm/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for APM X-GENE Queue Manager Traffic Manager driver.
+#
+
+obj-$(CONFIG_XGENE_QMTM) += xgene-qmtm.o
+
+xgene-qmtm-objs := xgene_qmtm_main.o xgene_qmtm_storm.o
diff --git a/drivers/misc/xgene/qmtm/xgene_qmtm_main.c b/drivers/misc/xgene/qmtm/xgene_qmtm_main.c
new file mode 100644
index 0000000..cda63e0
--- /dev/null
+++ b/drivers/misc/xgene/qmtm/xgene_qmtm_main.c
@@ -0,0 +1,761 @@
+/*
+ * AppliedMicro X-Gene SOC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *         Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/io.h>
+#include <linux/clk.h>
+#include <linux/delay.h>
+#include <linux/slab.h>
+#include "xgene_qmtm_main.h"
+
+#define XGENE_QMTM_DRIVER_VER	"1.0"
+#define XGENE_QMTM_DRIVER_NAME	"xgene-qmtm"
+#define XGENE_QMTM_DRIVER_DESC	"APM X-Gene QMTM driver"
+
+/* CSR Address Macros */
+#define CSR_QM_CONFIG_ADDR	0x00000004
+#define  QM_ENABLE_WR(src)	(((u32)(src)<<31) & 0x80000000)
+
+#define CSR_PBM_ADDR		0x00000008
+#define  OVERWRITE_WR(src)	(((u32)(src)<<31) & 0x80000000)
+#define  SLVID_PBN_WR(src)	(((u32)(src)) & 0x000003ff)
+#define  SLAVE_ID_SHIFT		6
+
+#define CSR_PBM_BUF_WR_ADDR	0x0000000c
+#define CSR_PBM_BUF_RD_ADDR	0x00000010
+#define  PB_SIZE_WR(src)	(((u32)(src)<<31) & 0x80000000)
+#define  PREFETCH_BUF_EN_SET(dst, src) \
+	(((dst) & ~0x00200000) | (((u32)(src)<<21) & 0x00200000))
+#define  IS_FREE_POOL_SET(dst, src) \
+	(((dst) & ~0x00100000) | (((u32)(src)<<20) & 0x00100000))
+#define  TLVQ_SET(dst, src) \
+	(((dst) & ~0x00080000) | (((u32)(src)<<19) & 0x00080000))
+#define  CORRESPONDING_QNUM_SET(dst, src) \
+	(((dst) & ~0x0007fe00) | (((u32)(src)<<9) & 0x0007fe00))
+
+#define CSR_PBM_CTICK0_ADDR	0x00000018
+#define  MIN_COAL_TAP		0x0
+#define  MAX_COAL_TAP		0x7
+
+#define CSR_THRESHOLD0_SET1_ADDR	0x00000030
+#define CSR_THRESHOLD1_SET1_ADDR	0x00000034
+#define CSR_HYSTERESIS_ADDR		0x00000068
+#define CSR_QM_MBOX_NE_INT_MODE_ADDR	0x0000017c
+#define CSR_QMLITE_PBN_MAP_0_ADDR	0x00000228
+
+#define CSR_RECOMB_CTRL_0_ADDR		0x00000230
+#define  RECOMB_EN0_SET(dst, src) \
+	(((dst) & ~0x00000001) | (((u32)(src)) & 0x00000001))
+
+/* QMTM Diag CSR */
+#define QM_GLBL_DIAG_CSR_BASE_ADDR_OFFSET	0xd000
+#define QM_CFG_MEM_RAM_SHUTDOWN_ADDR		0x00000070
+#define QM_CFG_MEM_RAM_SHUTDOWN_DEFAULT		0xffffffff
+
+/* PBN macros */
+#define QMTM_MIN_PBN_ID	0
+#define QMTM_MAX_PBN_ID	31
+
+/* Common for Queue ID and PBN */
+#define RES_MASK(nr)	(1UL << ((nr) % 32))
+#define RES_WORD(nr)	((nr) / 32)
+
+void xgene_qmtm_wr32(struct xgene_qmtm *qmtm, u32 offset, u32 data)
+{
+	void *addr = (u8 *)qmtm->csr_vaddr + offset;
+	writel(data, addr);
+}
+
+void xgene_qmtm_rd32(struct xgene_qmtm *qmtm, u32 offset, u32 *data)
+{
+	void *addr = (u8 *)qmtm->csr_vaddr + offset;
+	*data = readl(addr);
+}
+
+/* Get available PBN or Queue Id */
+static int xgene_qmtm_get_resource_id(u32 *resource, u32 start, u32 end)
+{
+	u32 index;
+
+	for (index = start; index < end; index++) {
+		if ((resource[RES_WORD(index)] & RES_MASK(index)) == 0) {
+			resource[RES_WORD(index)] |= RES_MASK(index);
+			return index;
+		}
+	}
+
+	return -ENODEV;
+}
+
+/* Put used PBN or Queue Id */
+static inline void xgene_qmtm_put_resource_id(u32 *resource, u32 index)
+{
+	resource[RES_WORD(index)] &= ~(u32) RES_MASK(index);
+}
+
+static void xgene_qmtm_write_pbm(struct xgene_qmtm_qinfo *qinfo, u32 val)
+{
+	u32 pbm = SLVID_PBN_WR((qinfo->slave_id << SLAVE_ID_SHIFT) |
+				    qinfo->pbn) | OVERWRITE_WR(1);
+
+	xgene_qmtm_wr32(qinfo->qmtm, CSR_PBM_ADDR, pbm);
+
+	if (qinfo->qmtm_ip == QMTM0 || qinfo->qmtm_ip == QMTM2)
+		val |= PB_SIZE_WR(1);
+
+	xgene_qmtm_wr32(qinfo->qmtm, CSR_PBM_BUF_WR_ADDR, val);
+}
+
+static u32 xgene_qmtm_read_pbm(struct xgene_qmtm_qinfo *qinfo)
+{
+	u32 pbm = SLVID_PBN_WR((qinfo->slave_id << SLAVE_ID_SHIFT) |
+				    qinfo->pbn);
+
+	xgene_qmtm_wr32(qinfo->qmtm, CSR_PBM_ADDR, pbm);
+	xgene_qmtm_rd32(qinfo->qmtm, CSR_PBM_BUF_RD_ADDR, &pbm);
+
+	return pbm;
+}
+
+static void xgene_qmtm_set_pbm(struct xgene_qmtm_qinfo *qinfo)
+{
+	u16 is_fp = qinfo->qtype == QTYPE_FP ? 1 : 0;
+	u16 is_vq = qinfo->qtype == QTYPE_VQ ? 1 : 0;
+	u32 val = 0;
+
+	val = CORRESPONDING_QNUM_SET(val, qinfo->queue_id);
+	val = IS_FREE_POOL_SET(val, is_fp);
+	val = TLVQ_SET(val, is_vq);
+	val = PREFETCH_BUF_EN_SET(val, 1);
+	xgene_qmtm_write_pbm(qinfo, val);
+}
+
+static void xgene_qmtm_clr_pbm(struct xgene_qmtm_qinfo *qinfo)
+{
+	xgene_qmtm_write_pbm(qinfo, 0);
+}
+
+/**
+ * xgene_qmtm_set_qinfo - Create and configure a queue
+ * @sdev:	Slave context
+ * @qtype:	Queue type (P_QUEUE or FP_QUEUE)
+ * @qsize:	Queue size see xgene_qmtm_qsize
+ * @qaccess:	Queue access method see xgene_qmtm_qaccess
+ * @flags:	Queue Information flags
+ * @qpaddr:	If Desire Queue Physical Address to use
+ *
+ * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to create and configure a queue.
+ *
+ * Return:	0 on Success or -1 on Failure
+ *		On Success, updates following in qinfo,
+ *		qmtm_ip - QMTM0, QMTM1, QMTM2 or QMTM3
+ *		qmtm - QMTM instance context
+ *		slave - Slave see xgene_slave
+ *		slave_id - Slave ID see xgene_qmtm_slave_id
+ *		pbn - Slave ID's prefetch buffer number
+ *		queue_id - Queue ID
+ *		qdesc - Queue descriptor
+ */
+int xgene_qmtm_set_qinfo(struct xgene_qmtm_qinfo *set)
+{
+	struct xgene_qmtm_sdev *sdev = set->sdev;
+	struct device *dev;
+	struct xgene_qmtm *qmtm;
+	struct xgene_qmtm_qinfo *qinfo;
+	u32 *queue_resource = NULL, *pbn_resource = NULL;
+	int rc;
+	u8 pbn = 0;
+	u16 queue_id = 0;
+
+	qmtm = sdev->qmtm;
+	dev = &qmtm->pdev->dev;
+
+	if (set->flags & XGENE_SLAVE_PB_CONFIGURE) {
+		u8 pbn_start, pbn_count;
+
+		if (set->qtype == QTYPE_FP) {
+			pbn_resource = &sdev->fq_pbn_pool;
+			pbn_start = sdev->fq_pbn_start & ~(u8) 0x20;
+			pbn_count = sdev->fq_pbn_count;
+		} else {
+			pbn_resource = &sdev->wq_pbn_pool;
+			pbn_start = sdev->wq_pbn_start;
+			pbn_count = sdev->wq_pbn_count;
+		}
+
+		rc = xgene_qmtm_get_resource_id(pbn_resource, pbn_start,
+						pbn_start + pbn_count);
+		if (rc < 0) {
+			dev_err(dev, "SETQ: slave %d out of PBN\n",
+				sdev->slave);
+			goto _ret_set_qinfo;
+		}
+
+		pbn = rc;
+	}
+
+	queue_resource = qmtm->queue_pool;
+	rc = xgene_qmtm_get_resource_id(queue_resource, 0, qmtm->max_queues);
+	if (rc < 0) {
+		dev_err(dev, "SETQ: QMTM %d out of Queue ID\n", sdev->qmtm_ip);
+		goto _put_pbn_resource;
+	}
+
+	queue_id = rc;
+	qinfo = kzalloc(sizeof(struct xgene_qmtm_qinfo), GFP_KERNEL);
+	if (qinfo == NULL) {
+		dev_err(dev, "SETQ: Unable to allocate qinfo\n");
+		rc = -ENOMEM;
+		goto _put_queue_resource;
+	}
+
+	qinfo->slave = sdev->slave;
+	qinfo->slave_id = sdev->slave_id;
+	qinfo->qmtm_ip = sdev->qmtm_ip;
+	qinfo->qtype = set->qtype;
+	qinfo->qsize = set->qsize;
+	qinfo->qaccess = set->qaccess;
+	qinfo->flags = set->flags;
+	qinfo->pbn = set->qtype == QTYPE_FP ? (pbn | 0x20) : pbn;
+	qinfo->queue_id = queue_id;
+	qinfo->qpaddr = set->qpaddr;
+	qinfo->qfabric = qmtm->fabric_vaddr + (queue_id << 6);
+	qinfo->sdev = sdev;
+	qinfo->qmtm = qmtm;
+	rc = qmtm->set_qstate(qinfo);
+	if (rc < 0) {
+		dev_err(dev, "SETQ: set_qstate error for %s Queue ID %d\n",
+			sdev->name, queue_id);
+		goto _del_qstate;
+	}
+
+	if (qinfo->qaccess == QACCESS_ALT)
+		qinfo->qdesc->command = qinfo->qfabric + 0x2C;
+
+	if (set->flags & XGENE_SLAVE_PB_CONFIGURE) {
+		xgene_qmtm_set_pbm(qinfo);
+
+		if (set->qaccess == QACCESS_ALT &&
+		    sdev->slave_id == QMTM_SLAVE_ID_CPU &&
+		    set->qtype == QTYPE_PQ) {
+			u32 data;
+
+			xgene_qmtm_rd32(qmtm, CSR_QM_MBOX_NE_INT_MODE_ADDR,
+					&data);
+			data |= (u32) (1 << (31 - pbn));
+			xgene_qmtm_wr32(qmtm, CSR_QM_MBOX_NE_INT_MODE_ADDR,
+					data);
+		}
+
+		if (set->qtype == QTYPE_PQ &&
+		    (sdev->slave_id == QMTM_SLAVE_ID_CPU ||
+		     sdev->slave_id == QMTM_SLAVE_ID_MSLIM))
+			qinfo->qdesc->irq = qmtm->dequeue_irq[pbn];
+	}
+
+	qmtm->qinfo[queue_id] = qinfo;
+	memcpy(set, qinfo, sizeof(struct xgene_qmtm_qinfo));
+	return rc;
+
+_del_qstate:
+	qmtm->clr_qstate(qinfo);
+	kfree(qinfo);
+
+_put_queue_resource:
+	xgene_qmtm_put_resource_id(queue_resource, queue_id);
+
+_put_pbn_resource:
+	if (set->flags & XGENE_SLAVE_PB_CONFIGURE)
+		xgene_qmtm_put_resource_id(pbn_resource, pbn);
+
+_ret_set_qinfo:
+	return rc;
+}
+EXPORT_SYMBOL_GPL(xgene_qmtm_set_qinfo);
+
+/**
+ * xgene_qmtm_clr_qinfo - Unconfigure and delete a queue
+ * @sdev:	Slave context
+ * @queue_id:	Queue ID
+ *
+ * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to unconfigure and delete a queue.
+ */
+void xgene_qmtm_clr_qinfo(struct xgene_qmtm_qinfo *clr)
+{
+	struct xgene_qmtm_sdev *sdev = clr->sdev;
+	struct xgene_qmtm *qmtm;
+	struct xgene_qmtm_qinfo *qinfo;
+	u8 queue_id = clr->queue_id;
+
+	qmtm = sdev->qmtm;
+	qinfo = qmtm->qinfo[queue_id];
+
+	if (qinfo->flags & XGENE_SLAVE_PB_CONFIGURE) {
+		u32 *pbn_resource;
+		u8 qtype = qinfo->qtype;
+		u8 pbn = (qtype == QTYPE_FP) ?
+		    (qinfo->pbn & ~(u8) 0x20) : qinfo->pbn;
+
+		if (qinfo->qaccess == QACCESS_ALT &&
+		    qinfo->slave_id == QMTM_SLAVE_ID_CPU && qtype == QTYPE_PQ) {
+			u32 data;
+
+			xgene_qmtm_rd32(qmtm, CSR_QM_MBOX_NE_INT_MODE_ADDR,
+					&data);
+			data &= ~(u32) (1 << (31 - pbn));
+			xgene_qmtm_wr32(qmtm, CSR_QM_MBOX_NE_INT_MODE_ADDR,
+					data);
+		}
+
+		if (qinfo->qtype == QTYPE_FP)
+			pbn_resource = &sdev->fq_pbn_pool;
+		else
+			pbn_resource = &sdev->wq_pbn_pool;
+
+		xgene_qmtm_clr_pbm(qinfo);
+		xgene_qmtm_put_resource_id(pbn_resource, pbn);
+	}
+
+	qmtm->clr_qstate(qinfo);
+	kfree(qinfo);
+	xgene_qmtm_put_resource_id(qmtm->queue_pool, queue_id);
+	qmtm->qinfo[queue_id] = NULL;
+}
+EXPORT_SYMBOL_GPL(xgene_qmtm_clr_qinfo);
+
+/**
+ * xgene_qmtm_read_qstate - Get Queue State information for a queue
+ * @qmtm:	QMTM instance context
+ * @queue_id:	Queue ID
+ *
+ * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to read queue state of a queue.
+ *
+ * Return:	Updates following in qinfo,
+ *		qstate - Current Queue State in QMTM
+ *		nummsgs - Number os messages in the Queue
+ *		pbm_state - Current prefetch buffer manager state
+ */
+void xgene_qmtm_read_qstate(struct xgene_qmtm_qinfo *qinfo)
+{
+	struct xgene_qmtm *qmtm = qinfo->qmtm;
+	u8 queue_id = qinfo->queue_id;
+
+	memcpy(qinfo, qmtm->qinfo[queue_id], sizeof(struct xgene_qmtm_qinfo));
+	qmtm->read_qstate(qinfo);
+
+	if (qinfo->flags & XGENE_SLAVE_PB_CONFIGURE)
+		qinfo->pbm_state = xgene_qmtm_read_pbm(qinfo);
+}
+EXPORT_SYMBOL_GPL(xgene_qmtm_read_qstate);
+
+/**
+ * xgene_qmtm_intr_coalesce - Set interrupt coalescing for ingrgess queue
+ * @qmtm:	QMTM instance context
+ * @pbn:	CPU's prefetch buffer number corresponding to the interrupt
+ * @tap:	Tap value to set
+ *
+ * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to set interrupt for its ingress queue.
+ *
+ * Return:	0 on Success or -1 on Failure
+ */
+int xgene_qmtm_intr_coalesce(struct xgene_qmtm_qinfo *qinfo, u8 tap)
+{
+	u32 val, offset, mask, shift;
+	u8 pbn = qinfo->pbn;
+
+	if (tap < MIN_COAL_TAP || tap > MAX_COAL_TAP)
+		return -EINVAL;
+
+	if (pbn < QMTM_MIN_PBN_ID || pbn > QMTM_MAX_PBN_ID)
+		return -EINVAL;
+
+	offset = 4 * (pbn / 8);
+	shift = 4 * (7 - (pbn % 8));
+	mask = 7 << shift;
+
+	xgene_qmtm_rd32(qinfo->qmtm, CSR_PBM_CTICK0_ADDR + offset, &val);
+	val = (val & ~(u32) mask) | (((u32) tap << shift) & mask);
+	xgene_qmtm_wr32(qinfo->qmtm, CSR_PBM_CTICK0_ADDR + offset, val);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(xgene_qmtm_intr_coalesce);
+
+/**
+ * xgene_qmtm_fp_dealloc_msg - Fill a buffer in a free pool queue
+ * @qdesc:	Queue descriptor
+ * @msg:	QMTM free pool buffer message to fill in to queue
+ *
+ * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to fill a buffer in its free pool queue.
+ */
+void xgene_qmtm_fp_dealloc_msg(struct xgene_qmtm_qdesc *qdesc,
+			       struct xgene_qmtm_msg16 *msg)
+{
+	u32 qtail = qdesc->qtail;
+	u32 count = qdesc->count;
+	u8 *tailptr = (u8 *)&qdesc->msg16[qtail];
+
+	memcpy(tailptr, msg, 16);
+
+	if (++qtail == count)
+		qtail = 0;
+
+	writel(1, qdesc->command);
+	qdesc->qtail = qtail;
+}
+EXPORT_SYMBOL_GPL(xgene_qmtm_fp_dealloc_msg);
+
+/**
+ * xgene_qmtm_enqueue_msg - Enqueue a work message in subsystem's work queue
+ * @qdesc:	Queue descriptor
+ * @msg:	X-Gene SOC subsystem's work message to enqueue in to queue
+ *
+ * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to enqueue work message in its work queue.
+ */
+void xgene_qmtm_enqueue_msg(struct xgene_qmtm_qdesc *qdesc,
+			    struct xgene_qmtm_msg64 *msg)
+{
+	u32 qtail = qdesc->qtail;
+	u32 count = qdesc->count;
+	u8 *tailptr = (u8 *)&qdesc->msg32[qtail];
+
+	memcpy(tailptr, msg, 32);
+
+	if (++qtail == count)
+		qtail = 0;
+
+	if (!msg->msg32_1.msg16.NV) {
+		writel(1, qdesc->command);
+	} else {
+		memcpy(tailptr + 32, (u8 *) msg + 32, 32);
+
+		if (++qtail == count)
+			qtail = 0;
+
+		writel(2, qdesc->command);
+	}
+
+	qdesc->qtail = qtail;
+}
+EXPORT_SYMBOL_GPL(xgene_qmtm_enqueue_msg);
+
+/**
+ * xgene_qmtm_dequeue_msg - Dequeue a work message from QMTM instance
+ * @qdesc:	Queue descriptor
+ * @msg:	Dequeued work message from X-Gene SOC subsystem to CPU
+ *
+ * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to dequeue work message from its ingress
+ * queue.
+ *
+ * Return:	0 on Success or -1 on Failure
+ */
+int xgene_qmtm_dequeue_msg(struct xgene_qmtm_qdesc *qdesc,
+			   struct xgene_qmtm_msg64 *msg)
+{
+	u32 qhead = qdesc->qhead;
+	u32 count = qdesc->count;
+	u32 *headptr = (u32 *)&qdesc->msg32[qhead];
+
+	if (headptr[EMPTY_SLOT_INDEX] == EMPTY_SLOT)
+		return -EAGAIN;
+
+	memcpy(msg, headptr, 32);
+	headptr[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
+
+	if (++qhead == count)
+		qhead = 0;
+
+	if (!msg->msg32_1.msg16.NV) {
+		writel(0xFFFFFFFF, qdesc->command);
+	} else {
+		headptr += 8;
+
+		if (headptr[EMPTY_SLOT_INDEX] == EMPTY_SLOT)
+			return -EAGAIN;
+
+		memcpy((u8 *) msg + 32, headptr, 32);
+		headptr[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
+
+		if (++qhead == count)
+			qhead = 0;
+
+		writel(0xFFFFFFFE, qdesc->command);
+	}
+
+	qdesc->qhead = qhead;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(xgene_qmtm_dequeue_msg);
+
+/**
+ * xgene_qmtm_get_sdev - Get slave context from slave name
+ * @name:	Slave name
+ *
+ * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to get its slave context from its name.
+ *
+ * Return:	Slave context on Success or NULL on Failure
+ */
+struct xgene_qmtm_sdev *xgene_qmtm_get_sdev(char *name)
+{
+	return storm_qmtm_get_sdev(name);
+}
+EXPORT_SYMBOL_GPL(xgene_qmtm_get_sdev);
+
+static int xgene_qmtm_enable(struct xgene_qmtm *qmtm)
+{
+	struct xgene_qmtm_qinfo qinfo;
+	struct device *dev = &qmtm->pdev->dev;
+	int rc, mwait = 0;
+	u32 val;
+	u32 queue_id;
+
+	qmtm->clk = devm_clk_get(dev, NULL);
+	if (IS_ERR(qmtm->clk)) {
+		dev_err(dev, "can't get clock\n");
+		return PTR_ERR(qmtm->clk);
+	}
+
+	rc = clk_prepare_enable(qmtm->clk);
+	if (rc < 0) {
+		dev_err(dev, "clock prepare enable failed");
+		return rc;
+	}
+
+	xgene_qmtm_wr32(qmtm, QM_GLBL_DIAG_CSR_BASE_ADDR_OFFSET +
+			QM_CFG_MEM_RAM_SHUTDOWN_ADDR, 0);
+	do {
+		/* Wait for Memory to come out of shutdown */
+		usleep_range(1000, 2000);
+		xgene_qmtm_rd32(qmtm, QM_GLBL_DIAG_CSR_BASE_ADDR_OFFSET +
+				QM_CFG_MEM_RAM_SHUTDOWN_ADDR, &val);
+
+		if (mwait++ >= 1000) {
+			rc = -EIO;
+			dev_err(dev, "RAM not out of shutdown %d\n", rc);
+			clk_disable_unprepare(qmtm->clk);
+			return rc;
+		}
+	} while (val == QM_CFG_MEM_RAM_SHUTDOWN_DEFAULT);
+
+	switch (qmtm->qmtm_ip) {
+	case QMTM0:
+	case QMTM2:
+		xgene_qmtm_rd32(qmtm, CSR_RECOMB_CTRL_0_ADDR, &val);
+		val = RECOMB_EN0_SET(val, 1);
+		xgene_qmtm_wr32(qmtm, CSR_RECOMB_CTRL_0_ADDR, val);
+		break;
+	case QMTM3:
+		xgene_qmtm_wr32(qmtm, CSR_QMLITE_PBN_MAP_0_ADDR, 0x00000000);
+	}
+
+	/* program threshold set 1 and all hysteresis */
+	xgene_qmtm_wr32(qmtm, CSR_THRESHOLD0_SET1_ADDR, 100);
+	xgene_qmtm_wr32(qmtm, CSR_THRESHOLD1_SET1_ADDR, 200);
+	xgene_qmtm_wr32(qmtm, CSR_HYSTERESIS_ADDR, 0xFFFFFFFF);
+
+	/* Enable QPcore */
+	xgene_qmtm_wr32(qmtm, CSR_QM_CONFIG_ADDR, QM_ENABLE_WR(1));
+
+	/* Clear all HW queue state in case they were not de-activated */
+	memset(&qinfo, 0, sizeof(qinfo));
+	qinfo.qmtm = qmtm;
+
+	for (queue_id = 0; queue_id < qmtm->max_queues; queue_id++) {
+		qinfo.queue_id = queue_id;
+		qmtm->write_qstate(&qinfo);
+	}
+
+	return rc;
+}
+
+static int xgene_qmtm_disable(struct xgene_qmtm *qmtm)
+{
+	u32 queue_id;
+
+	for (queue_id = 0; queue_id < qmtm->max_queues; queue_id++) {
+		if (qmtm->qinfo[queue_id]) {
+			dev_err(&qmtm->pdev->dev,
+				"QMTM %d Queue ID %d Resource in use\n",
+				qmtm->qmtm_ip, queue_id);
+			return -EAGAIN;
+		}
+	}
+
+	/* Disable QPcore */
+	xgene_qmtm_wr32(qmtm, CSR_QM_CONFIG_ADDR, QM_ENABLE_WR(0));
+	clk_disable_unprepare(qmtm->clk);
+
+	return 0;
+}
+
+static struct xgene_qmtm *xgene_alloc_qmtm(struct platform_device *pdev)
+{
+	struct xgene_qmtm *qmtm;
+	int max_queues, malloc_size;
+
+	qmtm = devm_kzalloc(&pdev->dev, sizeof(struct xgene_qmtm), GFP_KERNEL);
+	if (qmtm == NULL) {
+		dev_err(&pdev->dev, "Unable to allocate QMTM context\n");
+		return NULL;
+	}
+
+	qmtm->pdev = pdev;
+	platform_set_drvdata(pdev, qmtm);
+	max_queues = QMTM_MAX_QUEUES;
+	malloc_size = max_queues * (sizeof(struct xgene_qmtm_info *));
+	qmtm->qinfo = devm_kzalloc(&pdev->dev, malloc_size, GFP_KERNEL);
+	if (qmtm->qinfo == NULL) {
+		dev_err(&pdev->dev, "Unable to allocate QMTM Queue context\n");
+		return NULL;
+	}
+
+	malloc_size = RES_WORD(max_queues + 31) * sizeof(u32);
+	qmtm->queue_pool = devm_kzalloc(&pdev->dev, malloc_size, GFP_KERNEL);
+	if (qmtm->queue_pool == NULL) {
+		dev_err(&pdev->dev, "Unable to allocate QMTM Queue Pool\n");
+		return NULL;
+	}
+
+	qmtm->max_queues = max_queues;
+
+	return qmtm;
+}
+
+static int xgene_get_qmtm(struct xgene_qmtm *qmtm)
+{
+	struct platform_device *pdev = qmtm->pdev;
+	struct resource *res;
+	struct xgene_qmtm_sdev *sdev;
+	const char *name;
+	int rc, inum = 1;
+	u16 pbn;
+
+	/* Retrieve QM CSR register address and size */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "Failed to get QMTM CSR region\n");
+		return -ENODEV;
+	}
+
+	qmtm->csr_vaddr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(qmtm->csr_vaddr)) {
+		dev_err(&pdev->dev, "Invalid QMTM CSR region\n");
+		return PTR_ERR(qmtm->csr_vaddr);
+	}
+
+	/* Retrieve Primary Fabric address and size */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (!res) {
+		dev_err(&pdev->dev, "Failed to get QMTM Fabric region\n");
+		return -ENODEV;
+	}
+
+	qmtm->fabric_vaddr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(qmtm->fabric_vaddr)) {
+		dev_err(&pdev->dev, "Invalid QMTM Fabric region\n");
+		return PTR_ERR(qmtm->fabric_vaddr);
+	}
+
+	rc = of_property_read_string(pdev->dev.of_node, "slave-name", &name);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "Failed to get QMTM Ingress slave-name\n");
+		return rc;
+	}
+
+	sdev = xgene_qmtm_get_sdev((char *)name);
+	if (sdev == NULL) {
+		dev_err(&pdev->dev, "Ingress Slave error\n");
+		return -ENODEV;
+	}
+
+	qmtm->idev = sdev;
+	qmtm->qmtm_ip = sdev->qmtm_ip;
+
+	for (pbn = sdev->wq_pbn_start; pbn < (sdev->wq_pbn_start +
+					      sdev->wq_pbn_count);
+	     pbn++, inum++) {
+		int irq = platform_get_irq(pdev, inum);
+
+		if (irq < 0) {
+			dev_err(&pdev->dev, "Failed to map QMTM%d PBN %d IRQ\n",
+				qmtm->qmtm_ip, pbn);
+			continue;
+		}
+
+		qmtm->dequeue_irq[pbn] = irq;
+	}
+
+	return rc;
+}
+
+static int xgene_qmtm_probe(struct platform_device *pdev)
+{
+	struct xgene_qmtm *qmtm;
+	int rc;
+
+	qmtm = xgene_alloc_qmtm(pdev);
+	if (qmtm == NULL)
+		return -ENOMEM;
+
+	rc = xgene_get_qmtm(qmtm);
+	if (rc)
+		return rc;
+
+	return xgene_qmtm_enable(qmtm);
+}
+
+static int xgene_qmtm_remove(struct platform_device *pdev)
+{
+	struct xgene_qmtm *qmtm = platform_get_drvdata(pdev);
+	return xgene_qmtm_disable(qmtm);
+}
+
+static struct of_device_id xgene_qmtm_match[] = {
+	{.compatible = "apm,xgene-qmtm-xge0",},
+	{.compatible = "apm,xgene-qmtm-soc",},
+	{.compatible = "apm,xgene-qmtm-xge2",},
+	{.compatible = "apm,xgene-qmtm-lite",},
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, xgene_qmtm_match);
+
+static struct platform_driver xgene_qmtm_driver = {
+	.driver = {
+		   .name = XGENE_QMTM_DRIVER_NAME,
+		   .owner = THIS_MODULE,
+		   .of_match_table = xgene_qmtm_match,
+		   },
+	.probe = xgene_qmtm_probe,
+	.remove = xgene_qmtm_remove,
+};
+
+module_platform_driver(xgene_qmtm_driver);
+
+MODULE_VERSION(XGENE_QMTM_DRIVER_VER);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>");
+MODULE_DESCRIPTION(XGENE_QMTM_DRIVER_DESC);
diff --git a/drivers/misc/xgene/qmtm/xgene_qmtm_main.h b/drivers/misc/xgene/qmtm/xgene_qmtm_main.h
new file mode 100644
index 0000000..d937462
--- /dev/null
+++ b/drivers/misc/xgene/qmtm/xgene_qmtm_main.h
@@ -0,0 +1,134 @@
+/*
+ * AppliedMicro X-Gene SOC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *         Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __XGENE_QMTM_MAIN_H__
+#define __XGENE_QMTM_MAIN_H__
+
+#include <linux/of_platform.h>
+#include <misc/xgene/xgene_qmtm.h>
+
+/* QMTM Platform Information */
+enum xgene_qmtm_pinfo {
+	STORM_QMTM,
+	MAX_PLATFORM,
+};
+
+/* QMTM IP Blocks */
+enum xgene_qmtm_ip {
+	QMTM0,
+	QMTM1,
+	QMTM2,
+	QMTM3,
+	QMTM_MAX,
+};
+
+#define QMTM_MAX_QUEUES	1024
+#define QMTM_MAX_PBN	32
+
+struct xgene_qmtm {
+	void *csr_vaddr;
+	void *fabric_vaddr;
+	u16 qmtm_ip;		/* qmtm_ip, see xgene_qmtm_ip */
+	u16 error_irq;
+	u32 max_queues;
+	u16 dequeue_irq[QMTM_MAX_PBN];
+	char error_irq_s[16];
+	char error_queue_irq_s[16];
+	struct xgene_qmtm_sdev *idev;
+	u32 *queue_pool;
+	struct xgene_qmtm_qinfo *(*qinfo);
+	struct xgene_qmtm_qinfo *error_qinfo;
+	struct clk *clk;
+	struct platform_device *pdev;
+	void (*write_qstate) (struct xgene_qmtm_qinfo *qinfo);
+	void (*read_qstate) (struct xgene_qmtm_qinfo *qinfo);
+	int (*set_qstate) (struct xgene_qmtm_qinfo *qinfo);
+	void (*clr_qstate) (struct xgene_qmtm_qinfo *qinfo);
+};
+
+/* QMTM Slave */
+enum xgene_slave {
+	SLAVE_ETH0,
+	SLAVE_ETH1,
+	SLAVE_ETH2,
+	SLAVE_ETH3,
+	SLAVE_XGE0,
+	SLAVE_XGE1,
+	SLAVE_XGE2,
+	SLAVE_XGE3,
+	SLAVE_METH,
+	SLAVE_PKTDMA,
+	SLAVE_CTX_QMTM0,
+	SLAVE_CTX_QMTM1,
+	SLAVE_CTX_QMTM2,
+	SLAVE_SEC,
+	SLAVE_CLASS,
+	SLAVE_MSLIM_QMTM0,
+	SLAVE_MSLIM_QMTM1,
+	SLAVE_MSLIM_QMTM2,
+	SLAVE_MSLIM_QMTM3,
+	SLAVE_PMPRO,
+	SLAVE_SMPRO_QMTM0,
+	SLAVE_SMPRO_QMTM1,
+	SLAVE_SMPRO_QMTM2,
+	SLAVE_SMPRO_QMTM3,
+	SLAVE_CPU_QMTM0,
+	SLAVE_CPU_QMTM1,
+	SLAVE_CPU_QMTM2,
+	SLAVE_CPU_QMTM3,
+	SLAVE_MAX,
+};
+
+/* QMTM Slave IDs */
+enum xgene_qmtm_slave_id {
+	QMTM_SLAVE_ID_ETH0,
+	QMTM_SLAVE_ID_ETH1,
+	QMTM_SLAVE_ID_RES2,
+	QMTM_SLAVE_ID_PKTDMA,
+	QMTM_SLAVE_ID_CTX,
+	QMTM_SLAVE_ID_SEC,
+	QMTM_SLAVE_ID_CLASS,
+	QMTM_SLAVE_ID_MSLIM,
+	QMTM_SLAVE_ID_RES8,
+	QMTM_SLAVE_ID_RES9,
+	QMTM_SLAVE_ID_RESA,
+	QMTM_SLAVE_ID_RESB,
+	QMTM_SLAVE_ID_RESC,
+	QMTM_SLAVE_ID_PMPRO,
+	QMTM_SLAVE_ID_SMPRO,
+	QMTM_SLAVE_ID_CPU,
+	QMTM_SLAVE_ID_MAX,
+};
+
+/* QMTM Free Pool Queue modes */
+enum xgene_qmtm_fp_mode {
+	MSG_NO_CHANGE,
+	ROUND_ADDR,
+	REDUCE_LEN,
+	CHANGE_LEN,
+};
+
+#define VIRT_TO_PHYS(x)	virt_to_phys(x)
+#define PHYS_TO_VIRT(x)	phys_to_virt(x)
+
+/* QMTM CSR read/write routine */
+void xgene_qmtm_wr32(struct xgene_qmtm *qmtm, u32 offset, u32 data);
+void xgene_qmtm_rd32(struct xgene_qmtm *qmtm, u32 offset, u32 *data);
+
+struct xgene_qmtm_sdev *storm_qmtm_get_sdev(char *name);
+
+#endif /* __XGENE_QMTM_MAIN_H__ */
diff --git a/drivers/misc/xgene/qmtm/xgene_qmtm_storm.c b/drivers/misc/xgene/qmtm/xgene_qmtm_storm.c
new file mode 100644
index 0000000..3ec40bd
--- /dev/null
+++ b/drivers/misc/xgene/qmtm/xgene_qmtm_storm.c
@@ -0,0 +1,370 @@
+/**
+ * AppliedMicro X-Gene SOC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *         Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *         Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/slab.h>
+#include "xgene_qmtm_main.h"
+#include "xgene_qmtm_storm.h"
+
+#define CSR_QSTATE_ADDR		0x0000006c
+#define QNUMBER_WR(src)		(((u32)(src)) & 0x000003ff)
+
+#define CSR_QSTATE_WR_0_ADDR	0x00000070
+#define CSR_QSTATE_WR_1_ADDR	0x00000074
+#define CSR_QSTATE_WR_2_ADDR	0x00000078
+#define CSR_QSTATE_WR_3_ADDR	0x0000007c
+#define CSR_QSTATE_WR_4_ADDR	0x00000080
+
+static struct xgene_qmtm_sdev storm_sdev[SLAVE_MAX] = {
+	[SLAVE_ETH0] = {
+			.name = "SGMII0",
+			.compatible = "apm,xgene-qmtm-soc",
+			.slave = SLAVE_ETH0,
+			.qmtm_ip = QMTM1,
+			.slave_id = QMTM_SLAVE_ID_ETH0,
+			.wq_pbn_start = 0x00,
+			.wq_pbn_count = 0x08,
+			.fq_pbn_start = 0x20,
+			.fq_pbn_count = 0x08,
+			},
+	[SLAVE_ETH1] = {
+			.name = "SGMII1",
+			.compatible = "apm,xgene-qmtm-soc",
+			.slave = SLAVE_ETH1,
+			.qmtm_ip = QMTM1,
+			.slave_id = QMTM_SLAVE_ID_ETH0,
+			.wq_pbn_start = 0x08,
+			.wq_pbn_count = 0x08,
+			.fq_pbn_start = 0x28,
+			.fq_pbn_count = 0x08,
+			},
+	[SLAVE_ETH2] = {
+			.name = "SGMII2",
+			.compatible = "apm,xgene-qmtm-soc",
+			.slave = SLAVE_ETH2,
+			.qmtm_ip = QMTM1,
+			.slave_id = QMTM_SLAVE_ID_ETH1,
+			.wq_pbn_start = 0x00,
+			.wq_pbn_count = 0x08,
+			.fq_pbn_start = 0x20,
+			.fq_pbn_count = 0x08,
+			},
+	[SLAVE_ETH3] = {
+			.name = "SGMII3",
+			.compatible = "apm,xgene-qmtm-soc",
+			.slave = SLAVE_ETH3,
+			.qmtm_ip = QMTM1,
+			.slave_id = QMTM_SLAVE_ID_ETH1,
+			.wq_pbn_start = 0x08,
+			.wq_pbn_count = 0x08,
+			.fq_pbn_start = 0x28,
+			.fq_pbn_count = 0x08,
+			},
+	[SLAVE_XGE0] = {
+			.name = "SXGMII0",
+			.compatible = "apm,xgene-qmtm-xge0",
+			.slave = SLAVE_XGE0,
+			.qmtm_ip = QMTM0,
+			.slave_id = QMTM_SLAVE_ID_ETH0,
+			.wq_pbn_start = 0x00,
+			.wq_pbn_count = 0x08,
+			.fq_pbn_start = 0x20,
+			.fq_pbn_count = 0x08,
+			},
+	[SLAVE_XGE1] = {
+			.name = "SXGMII1",
+			.compatible = "apm,xgene-qmtm-xge0",
+			.slave = SLAVE_XGE1,
+			.qmtm_ip = QMTM0,
+			.slave_id = QMTM_SLAVE_ID_ETH1,
+			.wq_pbn_start = 0x00,
+			.wq_pbn_count = 0x08,
+			.fq_pbn_start = 0x20,
+			.fq_pbn_count = 0x08,
+			},
+	[SLAVE_XGE2] = {
+			.name = "SXGMII2",
+			.compatible = "apm,xgene-qmtm-xge2",
+			.slave = SLAVE_XGE2,
+			.qmtm_ip = QMTM2,
+			.slave_id = QMTM_SLAVE_ID_ETH0,
+			.wq_pbn_start = 0x00,
+			.wq_pbn_count = 0x08,
+			.fq_pbn_start = 0x20,
+			.fq_pbn_count = 0x08,
+			},
+	[SLAVE_XGE3] = {
+			.name = "SXGMII3",
+			.compatible = "apm,xgene-qmtm-xge2",
+			.slave = SLAVE_XGE3,
+			.qmtm_ip = QMTM2,
+			.slave_id = QMTM_SLAVE_ID_ETH1,
+			.wq_pbn_start = 0x00,
+			.wq_pbn_count = 0x08,
+			.fq_pbn_start = 0x20,
+			.fq_pbn_count = 0x08,
+			},
+	[SLAVE_METH] = {
+			.name = "RGMII",
+			.compatible = "apm,xgene-qmtm-lite",
+			.slave = SLAVE_METH,
+			.qmtm_ip = QMTM3,
+			.slave_id = QMTM_SLAVE_ID_ETH0,
+			.wq_pbn_start = 0x00,
+			.wq_pbn_count = 0x04,
+			.fq_pbn_start = 0x20,
+			.fq_pbn_count = 0x04,
+			},
+	[SLAVE_PKTDMA] = {
+			  .name = "PKTDMA",
+			  .compatible = "apm,xgene-qmtm-soc",
+			  .slave = SLAVE_PKTDMA,
+			  .qmtm_ip = QMTM1,
+			  .slave_id = QMTM_SLAVE_ID_PKTDMA,
+			  .wq_pbn_start = 0x00,
+			  .wq_pbn_count = 0x04,
+			  .fq_pbn_start = 0x20,
+			  .fq_pbn_count = 0x08,
+			  },
+	[SLAVE_CPU_QMTM0] = {
+			     .name = "CPU_QMTM0",
+			     .compatible = "apm,xgene-qmtm-xge0",
+			     .slave = SLAVE_CPU_QMTM0,
+			     .qmtm_ip = QMTM0,
+			     .slave_id = QMTM_SLAVE_ID_CPU,
+			     .wq_pbn_start = 0x00,
+			     .wq_pbn_count = 0x10,
+			     .fq_pbn_start = 0x20,
+			     .fq_pbn_count = 0x10,
+			     },
+	[SLAVE_CPU_QMTM1] = {
+			     .name = "CPU_QMTM1",
+			     .compatible = "apm,xgene-qmtm-soc",
+			     .slave = SLAVE_CPU_QMTM1,
+			     .qmtm_ip = QMTM1,
+			     .slave_id = QMTM_SLAVE_ID_CPU,
+			     .wq_pbn_start = 0x00,
+			     .wq_pbn_count = 0x20,
+			     .fq_pbn_start = 0x20,
+			     .fq_pbn_count = 0x20,
+			     },
+	[SLAVE_CPU_QMTM2] = {
+			     .name = "CPU_QMTM2",
+			     .compatible = "apm,xgene-qmtm-xge2",
+			     .slave = SLAVE_CPU_QMTM2,
+			     .qmtm_ip = QMTM2,
+			     .slave_id = QMTM_SLAVE_ID_CPU,
+			     .wq_pbn_start = 0x10,
+			     .wq_pbn_count = 0x10,
+			     .fq_pbn_start = 0x30,
+			     .fq_pbn_count = 0x10,
+			     },
+	[SLAVE_CPU_QMTM3] = {
+			     .name = "CPU_QMTM3",
+			     .compatible = "apm,xgene-qmtm-lite",
+			     .slave = SLAVE_CPU_QMTM3,
+			     .qmtm_ip = QMTM3,
+			     .slave_id = QMTM_SLAVE_ID_CPU,
+			     .wq_pbn_start = 0x00,
+			     .wq_pbn_count = 0x01,
+			     .fq_pbn_start = 0x20,
+			     .fq_pbn_count = 0x01,
+			     },
+};
+
+static void storm_qmtm_write_qstate(struct xgene_qmtm_qinfo *qinfo)
+{
+	struct xgene_qmtm *qmtm = qinfo->qmtm;
+	u16 queue_id = qinfo->queue_id;
+	struct storm_qmtm_csr_qstate *csr_qstate =
+	    &((union storm_qmtm_qstate *)qinfo->qstate)->csr;
+
+	/* write queue number */
+	queue_id = QNUMBER_WR(queue_id);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_ADDR, (u32) queue_id);
+
+	/* write queue state */
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_0_ADDR, csr_qstate->w0);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_1_ADDR, csr_qstate->w1);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_2_ADDR, csr_qstate->w2);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_3_ADDR, csr_qstate->w3);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_4_ADDR, csr_qstate->w4);
+}
+
+static void storm_qmtm_read_qstate(struct xgene_qmtm_qinfo *qinfo)
+{
+	struct xgene_qmtm *qmtm = qinfo->qmtm;
+	struct storm_qmtm_csr_qstate *qfabric = (struct storm_qmtm_csr_qstate *)
+	    (qmtm->fabric_vaddr + (qinfo->queue_id << 6));
+	struct storm_qmtm_csr_qstate *csr_qstate =
+	    &((union storm_qmtm_qstate *)qinfo->qstate)->csr;
+	struct storm_qmtm_pq_fp_qstate *pq_fp =
+	    &((union storm_qmtm_qstate *)(qinfo->qstate))->pq;
+
+	/* read queue state */
+	csr_qstate->w0 = readl(&qfabric->w0);
+	csr_qstate->w1 = readl(&qfabric->w1);
+	csr_qstate->w2 = readl(&qfabric->w2);
+	csr_qstate->w3 = readl(&qfabric->w3);
+	csr_qstate->w4 = readl(&qfabric->w4);
+	qinfo->nummsgs = pq_fp->nummsg;
+}
+
+static int storm_qmtm_set_qstate(struct xgene_qmtm_qinfo *qinfo)
+{
+	int rc = 0;
+	struct storm_qmtm_pq_fp_qstate *pq_fp =
+	    &((union storm_qmtm_qstate *)(qinfo->qstate))->pq;
+	u32 qsize = 0;
+	u8 qtype = qinfo->qtype;
+
+	if (qtype != QTYPE_PQ && qtype != QTYPE_FP) {
+		pr_err("Queue type %d is invalid\n", qinfo->qtype);
+		rc = -EINVAL;
+		goto _ret_set_qstate;
+	}
+
+	pq_fp->cfgqtype = qinfo->qtype;
+
+	/* if its a free queue, ask QMTM to set len to 0 when dealloc */
+	if (qtype == QTYPE_FP)
+		pq_fp->fp_mode = CHANGE_LEN;
+
+	if (qinfo->slave >= SLAVE_XGE0 && qinfo->slave <= SLAVE_XGE3) {
+		pq_fp->cfgRecombBuf = 1;
+		pq_fp->cfgRecombBufTimeoutL = 0xf;
+		pq_fp->cfgRecombBufTimeoutH = 0x7;
+	}
+
+	pq_fp->cfgselthrsh = 1;
+
+	/*  Allow the queue to accept message with non-zero LErr */
+	pq_fp->cfgacceptlerr = 1;
+	pq_fp->qcoherent = 1;
+
+	switch (qinfo->qsize) {
+	case QSIZE_512B:
+		qsize = 512;
+		break;
+	case QSIZE_2KB:
+		qsize = 2 * 1024;
+		break;
+	case QSIZE_16KB:
+		qsize = 16 * 1024;
+		break;
+	case QSIZE_64KB:
+		qsize = 64 * 1024;
+		break;
+	case QSIZE_512KB:
+		qsize = 512 * 1024;
+		break;
+	default:
+		pr_err("Queue size %d is invalid\n", qinfo->qsize);
+		rc = -EINVAL;
+		goto _ret_set_qstate;
+	}
+
+	qinfo->qdesc = kzalloc(sizeof(struct xgene_qmtm_qdesc), GFP_KERNEL);
+
+	if (qinfo->qdesc == NULL) {
+		rc = -ENOMEM;
+		goto _ret_set_qstate;
+	}
+
+	qinfo->qdesc->count = (qtype == QTYPE_PQ) ? (qsize / 32) : (qsize / 16);
+
+	if (qinfo->flags & XGENE_SLAVE_Q_ADDR_ALLOC) {
+		qinfo->qdesc->qvaddr = kzalloc(qsize, GFP_KERNEL);
+		if (qinfo->qdesc->qvaddr == NULL) {
+			kfree(qinfo->qdesc);
+			rc = -ENOMEM;
+			goto _ret_set_qstate;
+		}
+
+		qinfo->qpaddr = (u64) VIRT_TO_PHYS(qinfo->qdesc->qvaddr);
+	} else {
+		qinfo->qdesc->qvaddr = PHYS_TO_VIRT(qinfo->qpaddr);
+		memset(qinfo->qdesc->qvaddr, 0, qsize);
+	}
+
+	if ((qtype == QTYPE_PQ) && (qinfo->slave_id == QMTM_SLAVE_ID_CPU ||
+				    qinfo->slave_id == QMTM_SLAVE_ID_MSLIM)) {
+		u32 i;
+
+		for (i = 0; i < qinfo->qdesc->count; i++) {
+			u32 *slot = (u32 *)&qinfo->qdesc->msg32[i];
+
+			slot[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
+		}
+	}
+
+	pq_fp->cfgstartaddr = (u32) (qinfo->qpaddr >> 8);
+	pq_fp->cfgqsize = qinfo->qsize;
+	storm_qmtm_write_qstate(qinfo);
+
+_ret_set_qstate:
+	return rc;
+}
+
+static void storm_qmtm_clr_qstate(struct xgene_qmtm_qinfo *qinfo)
+{
+	memset(qinfo->qstate, 0, sizeof(union storm_qmtm_qstate));
+	storm_qmtm_write_qstate(qinfo);
+
+	if (qinfo->flags & XGENE_SLAVE_Q_ADDR_ALLOC && qinfo->qdesc->qvaddr) {
+		kfree(qinfo->qdesc->qvaddr);
+		qinfo->qdesc->qvaddr = NULL;
+	}
+
+	kfree(qinfo->qdesc);
+}
+
+struct xgene_qmtm_sdev *storm_qmtm_get_sdev(char *name)
+{
+	struct xgene_qmtm *qmtm = NULL;
+	struct xgene_qmtm_sdev *sdev = NULL;
+	struct device_node *np = NULL;
+	struct platform_device *platdev;
+	u8 slave;
+
+	for (slave = 0; slave < SLAVE_MAX; slave++) {
+		sdev = &storm_sdev[slave];
+		if (sdev->name && strcmp(name, sdev->name) == 0) {
+			np = of_find_compatible_node(NULL, NULL,
+				sdev->compatible);
+			break;
+		}
+	}
+
+	if (np == NULL)
+		return NULL;
+
+	platdev = of_find_device_by_node(np);
+	qmtm = platform_get_drvdata(platdev);
+
+	if (!qmtm->write_qstate) {
+		qmtm->write_qstate = storm_qmtm_write_qstate;
+		qmtm->read_qstate = storm_qmtm_read_qstate;
+		qmtm->set_qstate = storm_qmtm_set_qstate;
+		qmtm->clr_qstate = storm_qmtm_clr_qstate;
+	}
+
+	sdev->qmtm = qmtm;
+	sdev->idev = qmtm->idev;
+
+	return sdev;
+}
diff --git a/drivers/misc/xgene/qmtm/xgene_qmtm_storm.h b/drivers/misc/xgene/qmtm/xgene_qmtm_storm.h
new file mode 100644
index 0000000..e6b0828
--- /dev/null
+++ b/drivers/misc/xgene/qmtm/xgene_qmtm_storm.h
@@ -0,0 +1,139 @@
+/*
+ * AppliedMicro X-Gene SOC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *         Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *         Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __XGENE_QMTM_STORM_H__
+#define __XGENE_QMTM_STORM_H__
+
+/* QMTM Queue State */
+struct storm_qmtm_csr_qstate {
+	u32 w0;
+	u32 w1;
+	u32 w2;
+	u32 w3;
+	u32 w4;
+	u32 res;
+} __packed;
+
+/*
+ * Physical or free pool queue state (pq or fp)
+ */
+struct storm_qmtm_pq_fp_qstate {
+	/* word 0 31:0 */
+	u32 resize_qid:10;
+	u32 resize_start:1;
+	u32 resize_done:1;
+	u32 cfgtmvqen:1;	/* enable pq to belong to vq */
+	u32 cfgtmvq:10;		/* parent vq */
+	u32 cfgsaben:1;		/* enable SAB broadcasting */
+	u32 cpu_notify:8;	/* cfgcpusab */
+
+	/* word 1 63:32 */
+	u32 cfgnotifyqne:1;	/* enable queue not empty interrupt */
+	u32 nummsg:16;
+	u32 headptr:15;
+
+	/* word 2 95:64 */
+	u32 cfgcrid:1;
+	u32 rid:3;
+	u32 qcoherent:1;
+	u64 cfgstartaddr:34;	/* 27/7 split */
+
+	/* word 3 127:96 */
+	u32 vc_chanctl:2;
+	u32 vc_chanid:2;
+	u32 slot_pending:6;
+	u32 stashing:1;
+	u32 reserved_0:1;
+	u32 cfgacceptlerr:1;
+	u32 fp_mode:3;		/* free pool mode */
+	u32 cfgqsize:3;		/* queue size, see xgene_qmtm_qsize */
+	u32 qstatelock:1;
+	u32 cfgRecombBuf:1;
+	u32 cfgRecombBufTimeoutL:4;	/* 4/3 split */
+
+	/* word 4 159:128 */
+	u32 cfgRecombBufTimeoutH:3;	/* 4/3 split */
+	u32 cfgselthrsh:3;	/* associated threshold set */
+	u32 resv2:13;
+	u32 cfgqtype:2;		/* queue type, refer xgene_qmtm_qtype */
+	u32 resv1:11;
+} __packed;
+
+struct storm_qmtm_vq_qstate {
+	/* word 0 31:0 */
+	u32 nummsg:18;
+	u32 cfgsaben:1;		/* enable SAB broadcasting */
+	u32 cfgnotifyqne:1;	/* enable queue not empty interrupt */
+	u32 cfgcrid:1;		/* critical rid config */
+	u32 cpu_notify:8;
+	u32 rid:3;		/* curr. region id of queue fill level */
+
+	/* word 1 63:32 */
+	u32 q7selarb:2;
+	u32 q7txallowed:1;
+	u32 q7reqvld:1;
+	u32 q7_sel:10;		/* b45:36 */
+	u32 q6selarb:2;
+	u32 q6txallowed:1;
+	u32 q6reqvld:1;
+	u32 q6_sel:10;		/* b59:50 */
+	u32 q5selarb:2;
+	u32 q5txallowed:1;
+	u32 q5reqvld:1;
+
+	/* word 2 95:64 */
+	u32 q5_sel:10;		/* b73:64 */
+	u32 q4selarb:2;		/* b75:74 */
+	u32 q4txallowed:1;	/* b76 */
+	u32 q4reqvld:1;
+	u32 q4_sel:10;		/* b87:78 */
+	u32 q3selarb:2;
+	u32 q3txallowed:1;
+	u32 q3reqvld:1;		/* b91 */
+	u32 q3_sel_4b:4;	/* b95:92    split 6/4 */
+
+	/* word 3 127:96 */
+	u32 q3_sel_6b:6;	/* b101:96   split 6/4 */
+	u32 q2selarb:2;
+	u32 q2txallowed:1;
+	u32 q2reqvld:1;
+	u32 q2_sel:10;		/* q2_sel_3b */
+	u32 q1selarb:2;
+	u32 q1txallowed:1;
+	u32 q1reqvld:1;
+	u32 q1_sel_8b:8;	/* b127:120  split 2/8 */
+
+	/* word 4 159:128 */
+	u32 q1_sel_2b:2;	/* b129:128  split 2/8 */
+	u32 q0selarb:2;
+	u32 q0txallowed:1;
+	u32 q0reqvld:1;
+	u32 q0_sel:10;
+	u32 cfgselthrsh:3;	/* associated threshold set */
+	u32 cfgqtype:2;		/* queue type, refer xgene_qmtm_qtype */
+	u32 resv1:11;
+};
+
+union storm_qmtm_qstate {
+	struct storm_qmtm_csr_qstate csr;
+	struct storm_qmtm_pq_fp_qstate pq;
+	struct storm_qmtm_pq_fp_qstate fp;
+	struct storm_qmtm_vq_qstate vq;
+} __packed;
+
+#endif /* __XGENE_QMTM_STORM_H__ */
diff --git a/include/misc/xgene/xgene_qmtm.h b/include/misc/xgene/xgene_qmtm.h
new file mode 100644
index 0000000..d7b0930
--- /dev/null
+++ b/include/misc/xgene/xgene_qmtm.h
@@ -0,0 +1,277 @@
+/*
+ * AppliedMicro X-Gene SOC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *         Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *         Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __XGENE_QMTM_H__
+#define __XGENE_QMTM_H__
+
+/* QMTM Queue types */
+enum xgene_qmtm_qtype {
+	QTYPE_DISABLED,		/* Queue Type is un-configured or disabled */
+	QTYPE_PQ,		/* Queue Type is Physical Work Queue */
+	QTYPE_FP,		/* Queue Type is Free Pool Queue */
+	QTYPE_VQ,		/* Queue Type is Virtual Queue */
+	QTYPE_MAX,
+};
+
+/* QMTM Queue possible sizes */
+enum xgene_qmtm_qsize {
+	QSIZE_512B,
+	QSIZE_2KB,
+	QSIZE_16KB,
+	QSIZE_64KB,
+	QSIZE_512KB,
+	QSIZE_MAX,
+};
+
+/* QMTM Queue Access Method */
+enum xgene_qmtm_qaccess {
+	QACCESS_ALT,		/* Alternate enq/deq */
+	QACCESS_QMI,		/* Access using QMI interface */
+	QACCESS_MBOX,		/* Access using mailboxes */
+	QACCESS_MAX,
+};
+
+/* QMTM Data Length encoded as per QM message format */
+enum xgene_qmtm_data_len {
+	DATA_LEN_256B = 0x0100,
+	DATA_LEN_1K = 0x0400,
+	DATA_LEN_2K = 0x0800,
+	DATA_LEN_4K = 0x1000,
+	DATA_LEN_16K = 0x4000,
+};
+
+enum xgene_qmtm_mask_len {
+	MASK_LEN_256B = (DATA_LEN_256B - 1),
+	MASK_LEN_1K = (DATA_LEN_1K - 1),
+	MASK_LEN_2K = (DATA_LEN_2K - 1),
+	MASK_LEN_4K = (DATA_LEN_4K - 1),
+	MASK_LEN_16K = (DATA_LEN_16K - 1),
+};
+
+/* QMTM Buffer Length encoded as per QM message format */
+enum xgene_qmtm_buf_len {
+	BUF_LEN_256B = 0x7000,
+	BUF_LEN_1K = 0x6000,
+	BUF_LEN_2K = 0x5000,
+	BUF_LEN_4K = 0x4000,
+	BUF_LEN_16K = 0x0000,
+};
+
+/* QMTM messaging structures */
+/* 16 byte QMTM message format */
+struct xgene_qmtm_msg16 {
+	u32 UserInfo;
+
+	u32 FPQNum:12;
+	u32 Rv2:2;
+	u32 ELErr:2;
+	u32 LEI:2;
+	u32 NV:1;
+	u32 LL:1;
+	u32 PB:1;
+	u32 HB:1;
+	u32 Rv:1;
+	u32 IN:1;
+	u32 RType:4;
+	u32 LErr:3;
+	u32 HL:1;
+
+	u64 DataAddr:42;	/* 32/10 split */
+	u32 Rv6:6;
+	u32 BufDataLen:15;
+	u32 C:1;
+} __packed;
+
+/* Upper 16 byte portion of 32 byte of QMTM message format */
+struct xgene_qmtm_msg_up16 {
+	u64 H0Info_msb:48;
+	u32 TotDataLengthLinkListLSBs:12;
+	u32 Rv1:1;
+	u32 DR:1;
+	u32 Rv0:1;
+	u32 HR:1;
+
+	u64 H0Info_lsb:48;
+	u32 H0Enq_Num:12;
+	u32 H0FPSel:4;
+} __packed;
+
+/* 8 byte portion of QMTM extended (64B) message format */
+struct xgene_qmtm_msg_ext8 {
+	u64 NxtDataAddr:42;
+	u32 Rv2:2;
+	u32 NxtFPQNum:4;
+	u32 NxtBufDataLength:15;
+	u32 Rv1:1;
+} __packed;
+
+/* 8 byte Link list portion of QMTM extended (64B) message format */
+struct xgene_qmtm_msg_ll8 {
+	u64 NxtDataPtr:42;
+	u32 Rv2:2;
+	u32 NxtFPQNum:4;
+	u8 NxtLinkListength;
+	u8 TotDataLengthLinkListMSBs;
+} __packed;
+
+/* This structure represents 32 byte QMTM message format */
+struct xgene_qmtm_msg32 {
+	struct xgene_qmtm_msg16 msg16;
+	struct xgene_qmtm_msg_up16 msgup16;
+} __packed;
+
+ /* 32 byte of QMTM extended (64B) message format */
+struct xgene_qmtm_msg_ext32 {
+	struct xgene_qmtm_msg_ext8 msg8_2;
+	struct xgene_qmtm_msg_ext8 msg8_1;
+	union {
+		struct xgene_qmtm_msg_ext8 msg8_4;
+		struct xgene_qmtm_msg_ll8 msg8_ll;
+	};
+	struct xgene_qmtm_msg_ext8 msg8_3;
+} __packed;
+
+/* 64 byte QMTM message format */
+struct xgene_qmtm_msg64 {
+	struct xgene_qmtm_msg32 msg32_1;
+	struct xgene_qmtm_msg_ext32 msg32_2;
+} __packed;
+
+/* Empty Slot Soft Signature */
+#define EMPTY_SLOT_INDEX	7
+#define EMPTY_SLOT		0x22222222
+
+/* Destination QM, 2 MSb in work queue, dstqid */
+#define QMTM_QUEUE_ID(qm, qid)	(((u16)(qm) << 10) | qid)
+
+/* QMTM Slave Device Information */
+struct xgene_qmtm_sdev {
+	u8 qmtm_ip;
+	u8 slave;
+	u8 wq_pbn_start;
+	u8 wq_pbn_count;
+	u8 fq_pbn_start;
+	u8 fq_pbn_count;
+	u16 slave_id;		/* slave id see xgene_qmtm_slave_id */
+	u32 wq_pbn_pool;	/* Bit mask indicates in use WQ PBN */
+	u32 fq_pbn_pool;	/* Bit mask indicates in use FP PBN */
+	char *name;
+	char *compatible;
+	struct xgene_qmtm *qmtm;
+	struct xgene_qmtm_sdev *idev;
+};
+
+/* QMTM Queue Information structure */
+/* Per queue descriptor */
+struct xgene_qmtm_qdesc {
+	u16 qhead;
+	u16 qtail;
+	u16 count;
+	u16 irq;
+	void *command;
+	union {
+		void *qvaddr;
+		struct xgene_qmtm_msg16 *msg16;
+		struct xgene_qmtm_msg32 *msg32;
+	};
+};
+
+/* Per queue state database */
+struct xgene_qmtm_qinfo {
+	u8 slave;
+	u8 qtype;
+	u8 qsize;
+	u8 qaccess;
+	u8 flags;
+	u8 qmtm_ip;
+	u8 slave_id;
+	u8 pbn;
+	u16 queue_id;
+	u16 nummsgs;
+	u32 pbm_state;
+	u64 qpaddr;
+	void *qfabric;
+	u32 qstate[6];
+	struct xgene_qmtm_qdesc *qdesc;
+	struct xgene_qmtm_sdev *sdev;
+	struct xgene_qmtm *qmtm;
+};
+
+/* QMTM Queue Information flags */
+#define XGENE_SLAVE_PB_CONFIGURE	0x01
+#define XGENE_SLAVE_Q_ADDR_ALLOC	0x02
+#define XGENE_SLAVE_DEFAULT_FLAGS	(XGENE_SLAVE_PB_CONFIGURE | \
+	XGENE_SLAVE_Q_ADDR_ALLOC)
+
+static inline u16 xgene_qmtm_encode_bufdatalen(u32 len)
+{
+	if (len <= DATA_LEN_256B)
+		return BUF_LEN_256B | (len & MASK_LEN_256B);
+	else if (len <= DATA_LEN_1K)
+		return BUF_LEN_1K | (len & MASK_LEN_1K);
+	else if (len <= DATA_LEN_2K)
+		return BUF_LEN_2K | (len & MASK_LEN_2K);
+	else if (len <= DATA_LEN_4K)
+		return BUF_LEN_4K | (len & MASK_LEN_4K);
+	else if (len < DATA_LEN_16K)
+		return BUF_LEN_16K | (len & MASK_LEN_16K);
+	else
+		return BUF_LEN_16K;
+}
+
+static inline u16 xgene_qmtm_encode_datalen(u32 len)
+{
+	return len & MASK_LEN_16K;
+}
+
+static inline u32 xgene_qmtm_decode_datalen(u16 bufdatalen)
+{
+	switch (bufdatalen & BUF_LEN_256B) {
+	case BUF_LEN_256B:
+		return bufdatalen & MASK_LEN_256B ? : DATA_LEN_256B;
+	case BUF_LEN_1K:
+		return bufdatalen & MASK_LEN_1K ? : DATA_LEN_1K;
+	case BUF_LEN_2K:
+		return bufdatalen & MASK_LEN_2K ? : DATA_LEN_2K;
+	case BUF_LEN_4K:
+		return bufdatalen & MASK_LEN_4K ? : DATA_LEN_4K;
+	default:
+		return bufdatalen & MASK_LEN_16K ? : DATA_LEN_16K;
+	};
+}
+
+struct xgene_qmtm_sdev *xgene_qmtm_get_sdev(char *name);
+
+int xgene_qmtm_set_qinfo(struct xgene_qmtm_qinfo *qinfo);
+
+void xgene_qmtm_clr_qinfo(struct xgene_qmtm_qinfo *qinfo);
+
+void xgene_qmtm_read_qstate(struct xgene_qmtm_qinfo *qinfo);
+
+void xgene_qmtm_fp_dealloc_msg(struct xgene_qmtm_qdesc *qdesc,
+			       struct xgene_qmtm_msg16 *msg);
+
+void xgene_qmtm_enqueue_msg(struct xgene_qmtm_qdesc *qdesc,
+			    struct xgene_qmtm_msg64 *msg);
+
+int xgene_qmtm_dequeue_msg(struct xgene_qmtm_qdesc *qdesc,
+			   struct xgene_qmtm_msg64 *msg);
+
+int xgene_qmtm_intr_coalesce(struct xgene_qmtm_qinfo *qinfo, u8 tap);
+
+#endif /* __XGENE_QMTM_H__ */
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
