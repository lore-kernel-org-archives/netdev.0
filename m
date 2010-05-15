From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/3] cxgb4i_v3: main driver files
Date: Sat, 15 May 2010 22:54:08 +0530
Message-ID: <1273944249-311-3-git-send-email-rakesh@chelsio.com>
References: <1273944249-311-1-git-send-email-rakesh@chelsio.com>
 <1273944249-311-2-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>, Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        Rakesh Ranjan <rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: NETDEVML <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, SCSIDEVML <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        OISCSIML <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <open-iscsi+bncCKnrzee6GxCysrvfBBoE1Uvw2Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1273944249-311-2-git-send-email-rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>,
	<mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Rakesh Ranjan <rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>


Signed-off-by: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/scsi/cxgb4i/cxgb4i.h         |  101 ++
 drivers/scsi/cxgb4i/cxgb4i_ddp.c     |  678 +++++++++++++
 drivers/scsi/cxgb4i/cxgb4i_ddp.h     |  118 +++
 drivers/scsi/cxgb4i/cxgb4i_offload.c | 1846 ++++++++++++++++++++++++++++++++++
 drivers/scsi/cxgb4i/cxgb4i_offload.h |   91 ++
 drivers/scsi/cxgb4i/cxgb4i_snic.c    |  260 +++++
 6 files changed, 3094 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/cxgb4i/cxgb4i.h
 create mode 100644 drivers/scsi/cxgb4i/cxgb4i_ddp.c
 create mode 100644 drivers/scsi/cxgb4i/cxgb4i_ddp.h
 create mode 100644 drivers/scsi/cxgb4i/cxgb4i_offload.c
 create mode 100644 drivers/scsi/cxgb4i/cxgb4i_offload.h
 create mode 100644 drivers/scsi/cxgb4i/cxgb4i_snic.c

diff --git a/drivers/scsi/cxgb4i/cxgb4i.h b/drivers/scsi/cxgb4i/cxgb4i.h
new file mode 100644
index 0000000..fbf7699
--- /dev/null
+++ b/drivers/scsi/cxgb4i/cxgb4i.h
@@ -0,0 +1,101 @@
+/*
+ * cxgb4i.h: Chelsio T4 iSCSI driver.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#ifndef	__CXGB4I_H__
+#define	__CXGB4I_H__
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/scatterlist.h>
+#include <linux/skbuff.h>
+#include <scsi/libiscsi_tcp.h>
+
+#include "t4fw_api.h"
+#include "t4_msg.h"
+#include "l2t.h"
+#include "cxgb4.h"
+#include "cxgb4_uld.h"
+
+#include "libcxgbi.h"
+#include "cxgb4i_ddp.h"
+#include "cxgb4i_offload.h"
+
+#define	CXGB4I_SCSI_HOST_QDEPTH	1024
+#define	CXGB4I_MAX_TARGET	CXGB4I_MAX_CONN
+#define	CXGB4I_MAX_LUN		512
+#define	ISCSI_PDU_NONPAYLOAD_MAX \
+	(sizeof(struct iscsi_hdr) + ISCSI_MAX_AHS_SIZE + \
+	 (2 * ISCSI_DIGEST_SIZE))
+
+struct cxgb4i_snic;
+struct cxgb4i_host;
+struct cxgb4i_endpoint;
+typedef int (*cxgb4i_cplhandler_func)(struct cxgb4i_snic *, struct sk_buff *);
+
+struct cxgb4i_snic {
+	struct list_head list_head;
+	spinlock_t lock;
+	struct cxgbi_device cdev;
+	struct cxgbi_hba *hba[MAX_NPORTS];
+	unsigned char hba_cnt;
+	unsigned int flags;
+	unsigned int tx_max_size;
+	unsigned int rx_max_size;
+	struct cxgb4_lld_info lldi;
+	struct cxgb4i_ddp_info *ddp;
+	cxgb4i_cplhandler_func *handlers;
+};
+
+int cxgb4i_ofld_init(struct cxgb4i_snic *);
+void cxgb4i_ofld_cleanup(struct cxgb4i_snic *);
+struct cxgb4i_snic *cxgb4i_find_snic(struct net_device *, __be32);
+struct cxgbi_hba *cxgb4i_hba_find_by_netdev(struct net_device *);
+struct cxgbi_hba *cxgb4i_hba_add(struct cxgb4i_snic *, struct net_device *);
+void cxgb4i_hba_remove(struct cxgbi_hba *);
+int cxgb4i_iscsi_init(void);
+void cxgb4i_iscsi_cleanup(void);
+
+static inline void cxgb4i_set_iscsi_ipv4(struct cxgbi_hba *chba, __be32 ipaddr)
+{
+	chba->ipv4addr = ipaddr;
+}
+
+static inline __be32 cxgb4i_get_iscsi_ipv4(struct cxgbi_hba *chba)
+{
+	return chba->ipv4addr;
+}
+
+static inline struct cxgb4i_snic *cxgb4i_get_snic(struct cxgbi_device *cdev)
+{
+	return (struct cxgb4i_snic *)cdev->dd_data;
+}
+
+
+#define W_TCB_ULP_TYPE          0
+#define TCB_ULP_TYPE_SHIFT      0
+#define TCB_ULP_TYPE_MASK       0xfULL
+#define TCB_ULP_TYPE(x)         ((x) << TCB_ULP_TYPE_SHIFT)
+
+#define W_TCB_ULP_RAW           0
+#define TCB_ULP_RAW_SHIFT       4
+#define TCB_ULP_RAW_MASK        0xffULL
+#define TCB_ULP_RAW(x)          ((x) << TCB_ULP_RAW_SHIFT)
+
+
+#endif	/* __CXGB4I_H__ */
+
diff --git a/drivers/scsi/cxgb4i/cxgb4i_ddp.c b/drivers/scsi/cxgb4i/cxgb4i_ddp.c
new file mode 100644
index 0000000..1e53c0e
--- /dev/null
+++ b/drivers/scsi/cxgb4i/cxgb4i_ddp.c
@@ -0,0 +1,678 @@
+/*
+ * cxgb4i_ddp.c: Chelsio T4 iSCSI driver.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#include <linux/skbuff.h>
+#include <linux/scatterlist.h>
+
+
+#include "libcxgbi.h"
+#include "cxgb4i.h"
+#include "cxgb4i_ddp.h"
+
+#define DDP_PGIDX_MAX	4
+#define DDP_THRESHOLD	2048
+
+static unsigned char ddp_page_order[DDP_PGIDX_MAX] = {0, 1, 2, 4};
+static unsigned char ddp_page_shift[DDP_PGIDX_MAX] = {12, 13, 14, 16};
+static unsigned char page_idx = DDP_PGIDX_MAX;
+
+static unsigned char sw_tag_idx_bits;
+static unsigned char sw_tag_age_bits;
+
+
+static inline void cxgb4i_ddp_ppod_set(struct pagepod *ppod,
+					struct pagepod_hdr *hdr,
+					struct cxgbi_gather_list *gl,
+					unsigned int pidx)
+{
+	int i;
+
+	memcpy(ppod, hdr, sizeof(*hdr));
+	for (i = 0; i < (PPOD_PAGES_MAX + 1); i++, pidx++) {
+		ppod->addr[i] = pidx < gl->nelem ?
+			cpu_to_be64(gl->phys_addr[pidx]) : 0ULL;
+	}
+}
+
+static inline void cxgb4i_ddp_ppod_clear(struct pagepod *ppod)
+{
+	memset(ppod, 0, sizeof(*ppod));
+}
+
+static inline void cxgb4i_ddp_ulp_mem_io_set_hdr(struct ulp_mem_io *req,
+					unsigned int wr_len, unsigned int dlen,
+					unsigned int pm_addr)
+{
+	struct ulptx_sgl *sgl;
+
+	INIT_ULPTX_WR(req, wr_len, 0, 0);
+	req->cmd = htonl(ULPTX_CMD(ULP_TX_MEM_WRITE));
+	req->dlen = htonl(ULP_MEMIO_DATA_LEN(dlen >> 5));
+	req->len16 = htonl(DIV_ROUND_UP(wr_len - sizeof(req->wr), 16));
+	req->lock_addr = htonl(ULP_MEMIO_ADDR(pm_addr >> 5));
+
+	sgl = (struct ulptx_sgl *)(req + 1);
+	sgl->cmd_nsge = htonl(ULPTX_CMD(ULP_TX_SC_DSGL) | ULPTX_NSGE(1));
+	sgl->len0 = htonl(dlen);
+}
+
+static int cxgb4i_ddp_ppod_write_sgl(struct cxgb4i_ddp_info *ddp,
+					struct pagepod_hdr *hdr,
+					unsigned int idx,
+					unsigned int npods,
+					struct cxgbi_gather_list *gl,
+					unsigned int gl_pidx)
+{
+	unsigned int dlen = PPOD_SIZE * npods;
+	unsigned int pm_addr = idx * PPOD_SIZE + ddp->llimit;
+	unsigned int wr_len = roundup(sizeof(struct ulp_mem_io) +
+					sizeof(struct ulptx_sgl), 16);
+	struct sk_buff *skb = alloc_skb(wr_len + dlen, GFP_ATOMIC);
+	struct ulp_mem_io *req;
+	struct ulptx_sgl *sgl;
+	struct pagepod *ppod;
+	unsigned int i;
+
+	if (!skb) {
+		cxgbi_log_error("snic 0x%p, idx %u, npods %u, OOM\n",
+				ddp->snic, idx, npods);
+		return -ENOMEM;
+	}
+
+	memset(skb->data, 0, wr_len + dlen);
+	skb->queue_mapping = CPL_PRIORITY_CONTROL;
+
+	req = (struct ulp_mem_io *)__skb_put(skb, wr_len);
+	cxgb4i_ddp_ulp_mem_io_set_hdr(req, wr_len, dlen, pm_addr);
+	sgl = (struct ulptx_sgl *)(req + 1);
+	ppod = (struct pagepod *)(sgl + 1);
+	sgl->addr0 = cpu_to_be64(virt_to_phys(ppod));
+
+	for (i = 0; i < npods; i++, ppod++, gl_pidx += PPOD_PAGES_MAX) {
+		if (!hdr && !gl)
+			cxgb4i_ddp_ppod_clear(ppod);
+		else
+			cxgb4i_ddp_ppod_set(ppod, hdr, gl, gl_pidx);
+
+	}
+
+	cxgb4_ofld_send(ddp->snic->lldi.ports[0], skb);
+
+	return 0;
+}
+
+static int cxgb4i_ddp_set_map(struct cxgb4i_ddp_info *ddp,
+					struct pagepod_hdr *hdr,
+					unsigned int idx,
+					unsigned int npods,
+					struct cxgbi_gather_list *gl)
+{
+	unsigned int pidx = 0;
+	unsigned int w_npods = 0;
+	unsigned int cnt;
+	int err = 0;
+
+	for (; w_npods < npods; idx += cnt, w_npods += cnt,
+					pidx += PPOD_PAGES_MAX) {
+		cnt = npods - w_npods;
+		if (cnt > ULPMEM_DSGL_MAX_NPPODS)
+			cnt = ULPMEM_DSGL_MAX_NPPODS;
+		err = cxgb4i_ddp_ppod_write_sgl(ddp, hdr, idx, cnt, gl, pidx);
+
+		if (err < 0)
+			break;
+	}
+
+	return err;
+}
+
+static void cxgb4i_ddp_clear_map(struct cxgb4i_ddp_info *ddp,
+						unsigned int tag,
+						unsigned int idx,
+						unsigned int npods)
+{
+	int err;
+	unsigned int w_npods = 0;
+	unsigned int cnt;
+
+	for (; w_npods < npods; idx += cnt, w_npods += cnt) {
+		cnt = npods - w_npods;
+
+		if (cnt > ULPMEM_DSGL_MAX_NPPODS)
+			cnt = ULPMEM_DSGL_MAX_NPPODS;
+		err = cxgb4i_ddp_ppod_write_sgl(ddp, NULL, idx, cnt, NULL, 0);
+
+		if (err < 0)
+			break;
+	}
+}
+
+static inline int cxgb4i_ddp_find_unused_entries(struct cxgb4i_ddp_info *ddp,
+					unsigned int start, unsigned int max,
+					unsigned int count,
+					struct cxgbi_gather_list *gl)
+{
+	unsigned int i, j, k;
+
+	/*  not enough entries */
+	if ((max - start) < count)
+		return -EBUSY;
+
+	max -= count;
+	spin_lock(&ddp->map_lock);
+	for (i = start; i < max;) {
+		for (j = 0, k = i; j < count; j++, k++) {
+			if (ddp->gl_map[k])
+				break;
+		}
+		if (j == count) {
+			for (j = 0, k = i; j < count; j++, k++)
+				ddp->gl_map[k] = gl;
+			spin_unlock(&ddp->map_lock);
+			return i;
+		}
+		i += j + 1;
+	}
+	spin_unlock(&ddp->map_lock);
+	return -EBUSY;
+}
+
+static inline void cxgb4i_ddp_unmark_entries(struct cxgb4i_ddp_info *ddp,
+							int start, int count)
+{
+	spin_lock(&ddp->map_lock);
+	memset(&ddp->gl_map[start], 0,
+			count * sizeof(struct cxgbi_gather_list *));
+	spin_unlock(&ddp->map_lock);
+}
+
+static int cxgb4i_ddp_find_page_index(unsigned long pgsz)
+{
+	int i;
+
+	for (i = 0; i < DDP_PGIDX_MAX; i++) {
+		if (pgsz == (1UL << ddp_page_shift[i]))
+			return i;
+	}
+	cxgbi_log_debug("ddp page size 0x%lx not supported\n", pgsz);
+
+	return DDP_PGIDX_MAX;
+}
+
+static int cxgb4i_ddp_adjust_page_table(void)
+{
+	int i;
+	unsigned int base_order, order;
+
+	if (PAGE_SIZE < (1UL << ddp_page_shift[0])) {
+		cxgbi_log_info("PAGE_SIZE 0x%lx too small, min 0x%lx\n",
+				PAGE_SIZE, 1UL << ddp_page_shift[0]);
+		return -EINVAL;
+	}
+
+	base_order = get_order(1UL << ddp_page_shift[0]);
+	order = get_order(1UL << PAGE_SHIFT);
+
+	for (i = 0; i < DDP_PGIDX_MAX; i++) {
+		/* first is the kernel page size, then just doubling the size */
+		ddp_page_order[i] = order - base_order + i;
+		ddp_page_shift[i] = PAGE_SHIFT + i;
+	}
+
+	return 0;
+}
+
+static inline void cxgb4i_ddp_gl_unmap(struct pci_dev *pdev,
+					struct cxgbi_gather_list *gl)
+{
+	int i;
+
+	for (i = 0; i < gl->nelem; i++)
+		dma_unmap_page(&pdev->dev, gl->phys_addr[i], PAGE_SIZE,
+				PCI_DMA_FROMDEVICE);
+}
+
+static inline int cxgb4i_ddp_gl_map(struct pci_dev *pdev,
+				struct cxgbi_gather_list *gl)
+{
+	int i;
+
+	for (i = 0; i < gl->nelem; i++) {
+		gl->phys_addr[i] = dma_map_page(&pdev->dev, gl->pages[i], 0,
+						PAGE_SIZE,
+						PCI_DMA_FROMDEVICE);
+		if (unlikely(dma_mapping_error(&pdev->dev, gl->phys_addr[i])))
+			goto unmap;
+	}
+
+	return i;
+
+unmap:
+	if (i) {
+		unsigned int nelem = gl->nelem;
+
+		gl->nelem = i;
+		cxgb4i_ddp_gl_unmap(pdev, gl);
+		gl->nelem = nelem;
+	}
+	return -ENOMEM;
+}
+
+
+void cxgb4i_ddp_release_gl(struct cxgbi_gather_list *gl,
+				struct pci_dev *pdev)
+{
+	cxgb4i_ddp_gl_unmap(pdev, gl);
+	kfree(gl);
+}
+
+struct cxgbi_gather_list *cxgb4i_ddp_make_gl(unsigned int xferlen,
+						struct scatterlist *sgl,
+						unsigned int sgcnt,
+						struct pci_dev *pdev,
+						gfp_t gfp)
+{
+	struct cxgbi_gather_list *gl;
+	struct scatterlist *sg = sgl;
+	struct page *sgpage = sg_page(sg);
+	unsigned int sglen = sg->length;
+	unsigned int sgoffset = sg->offset;
+	unsigned int npages = (xferlen + sgoffset + PAGE_SIZE - 1) >>
+				PAGE_SHIFT;
+	int i = 1, j = 0;
+
+	if (xferlen < DDP_THRESHOLD) {
+		cxgbi_log_debug("xfer %u < threshold %u, no ddp.\n",
+				xferlen, DDP_THRESHOLD);
+		return NULL;
+	}
+
+	gl = kzalloc(sizeof(struct cxgbi_gather_list) +
+			npages * (sizeof(dma_addr_t) + sizeof(struct page *)),
+			gfp);
+	if (!gl)
+		return NULL;
+
+	gl->pages = (struct page **)&gl->phys_addr[npages];
+	gl->length = xferlen;
+	gl->offset = sgoffset;
+	gl->pages[0] = sgpage;
+
+	sg = sg_next(sg);
+	while (sg) {
+		struct page *page = sg_page(sg);
+
+		if (sgpage == page && sg->offset == sgoffset + sglen)
+			sglen += sg->length;
+		else {
+			/*  make sure the sgl is fit for ddp:
+			 *  each has the same page size, and
+			 *  all of the middle pages are used completely
+			 */
+			if ((j && sgoffset) || ((i != sgcnt - 1) &&
+					 ((sglen + sgoffset) & ~PAGE_MASK)))
+				goto error_out;
+
+			j++;
+			if (j == gl->nelem || sg->offset)
+				goto error_out;
+			gl->pages[j] = page;
+			sglen = sg->length;
+			sgoffset = sg->offset;
+			sgpage = page;
+		}
+		i++;
+		sg = sg_next(sg);
+	}
+	gl->nelem = ++j;
+
+	if (cxgb4i_ddp_gl_map(pdev, gl) < 0)
+		goto error_out;
+
+	return gl;
+
+error_out:
+	kfree(gl);
+	return NULL;
+}
+
+
+static void cxgb4i_ddp_tag_release(struct cxgbi_device *cdev, u32 tag)
+{
+	struct cxgb4i_snic *snic = cxgb4i_get_snic(cdev);
+	struct cxgb4i_ddp_info *ddp = snic->ddp;
+	u32 idx;
+
+	if (!ddp) {
+		cxgbi_log_error("release ddp tag 0x%x, ddp NULL.\n", tag);
+		return;
+	}
+
+	idx = (tag >> PPOD_IDX_SHIFT) & ddp->idx_mask;
+	if (idx < ddp->nppods) {
+		struct cxgbi_gather_list *gl = ddp->gl_map[idx];
+		unsigned int npods;
+
+		if (!gl || !gl->nelem) {
+			cxgbi_log_error("rel 0x%x, idx 0x%x, gl 0x%p, %u\n",
+					tag, idx, gl, gl ? gl->nelem : 0);
+			return;
+		}
+		npods = (gl->nelem + PPOD_PAGES_MAX - 1) >> PPOD_PAGES_SHIFT;
+		cxgbi_log_debug("ddp tag 0x%x, release idx 0x%x, npods %u.\n",
+				tag, idx, npods);
+		cxgb4i_ddp_clear_map(ddp, tag, idx, npods);
+		cxgb4i_ddp_unmark_entries(ddp, idx, npods);
+		cxgb4i_ddp_release_gl(gl, ddp->pdev);
+	} else
+		cxgbi_log_error("ddp tag 0x%x, idx 0x%x > max 0x%x.\n",
+				tag, idx, ddp->nppods);
+}
+
+static int cxgb4i_ddp_tag_reserve(struct cxgbi_device *cdev, unsigned int tid,
+				struct cxgbi_tag_format *tformat, u32 *tagp,
+				struct cxgbi_gather_list *gl, gfp_t gfp)
+{
+	struct cxgb4i_snic *snic = cxgb4i_get_snic(cdev);
+	struct cxgb4i_ddp_info *ddp = snic->ddp;
+	struct pagepod_hdr hdr;
+	unsigned int npods;
+	int idx = -1;
+	int err = -ENOMEM;
+	u32 sw_tag = *tagp;
+	u32 tag;
+
+	if (page_idx >= DDP_PGIDX_MAX || !ddp || !gl || !gl->nelem ||
+			gl->length < DDP_THRESHOLD) {
+		cxgbi_log_debug("pgidx %u, xfer %u/%u, NO ddp.\n",
+				page_idx, gl->length, DDP_THRESHOLD);
+		return -EINVAL;
+	}
+
+	npods = (gl->nelem + PPOD_PAGES_MAX - 1) >> PPOD_PAGES_SHIFT;
+
+	if (ddp->idx_last == ddp->nppods)
+		idx = cxgb4i_ddp_find_unused_entries(ddp, 0, ddp->nppods,
+							npods, gl);
+	else {
+		idx = cxgb4i_ddp_find_unused_entries(ddp, ddp->idx_last + 1,
+							ddp->nppods, npods,
+							gl);
+		if (idx < 0 && ddp->idx_last >= npods) {
+			idx = cxgb4i_ddp_find_unused_entries(ddp, 0,
+				min(ddp->idx_last + npods, ddp->nppods),
+							npods, gl);
+		}
+	}
+	if (idx < 0) {
+		cxgbi_log_debug("xferlen %u, gl %u, npods %u NO DDP.\n",
+				gl->length, gl->nelem, npods);
+		return idx;
+	}
+
+	tag = cxgbi_ddp_tag_base(tformat, sw_tag);
+	tag |= idx << PPOD_IDX_SHIFT;
+
+	hdr.rsvd = 0;
+	hdr.vld_tid = htonl(PPOD_VALID_FLAG | PPOD_TID(tid));
+	hdr.pgsz_tag_clr = htonl(tag & ddp->rsvd_tag_mask);
+	hdr.max_offset = htonl(gl->length);
+	hdr.page_offset = htonl(gl->offset);
+
+	err = cxgb4i_ddp_set_map(ddp, &hdr, idx, npods, gl);
+	if (err < 0)
+		goto unmark_entries;
+
+	ddp->idx_last = idx;
+	cxgbi_log_debug("xfer %u, gl %u,%u, tid 0x%x, 0x%x -> 0x%x(%u,%u).\n",
+			gl->length, gl->nelem, gl->offset, tid, sw_tag, tag,
+			idx, npods);
+	*tagp = tag;
+	return 0;
+
+unmark_entries:
+	cxgb4i_ddp_unmark_entries(ddp, idx, npods);
+	return err;
+}
+
+
+static int cxgb4i_ddp_setup_conn_pgidx(struct cxgbi_sock *csk,
+					unsigned int tid, int pg_idx,
+					bool reply)
+{
+	struct sk_buff *skb = alloc_skb(sizeof(struct cpl_set_tcb_field),
+					GFP_KERNEL);
+	struct cpl_set_tcb_field *req;
+	u64 val = pg_idx < DDP_PGIDX_MAX ? pg_idx : 0;
+
+	if (!skb)
+		return -ENOMEM;
+
+	/*  set up ulp submode and page size */
+	val = (val & 0x03) << 2;
+	val |= TCB_ULP_TYPE(ULP_MODE_ISCSI);
+	req = (struct cpl_set_tcb_field *)skb_put(skb, sizeof(*req));
+	INIT_TP_WR(req, tid);
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, csk->hwtid));
+	req->reply_ctrl = htons(NO_REPLY(reply) | QUEUENO(csk->rss_qid));
+	req->word_cookie = htons(TCB_WORD(W_TCB_ULP_RAW));
+	req->mask = cpu_to_be64(TCB_ULP_TYPE(TCB_ULP_TYPE_MASK));
+	req->val = cpu_to_be64(val);
+
+	skb->queue_mapping = CPL_PRIORITY_CONTROL;
+
+	cxgb4_ofld_send(cxgb4i_get_snic(csk->cdev)->lldi.ports[0], skb);
+	return 0;
+}
+
+int cxgb4i_ddp_setup_conn_host_pagesize(struct cxgbi_sock *csk,
+						unsigned int tid,
+						int reply)
+{
+	return cxgb4i_ddp_setup_conn_pgidx(csk, tid, page_idx, reply);
+}
+
+int cxgb4i_ddp_setup_conn_pagesize(struct cxgbi_sock *csk, unsigned int tid,
+					int reply, unsigned long pgsz)
+{
+	int pgidx = cxgb4i_ddp_find_page_index(pgsz);
+
+	return cxgb4i_ddp_setup_conn_pgidx(csk, tid, pgidx, reply);
+}
+
+int cxgb4i_ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
+				int hcrc, int dcrc, int reply)
+{
+	struct sk_buff *skb = alloc_skb(sizeof(struct cpl_set_tcb_field),
+					GFP_KERNEL);
+	struct cpl_set_tcb_field *req;
+	u64 val = (hcrc ? ULP_CRC_HEADER : 0) | (dcrc ? ULP_CRC_DATA : 0);
+	val = TCB_ULP_RAW(val);
+	val |= TCB_ULP_TYPE(ULP_MODE_ISCSI);
+
+	if (!skb)
+		return -ENOMEM;
+
+	/*  set up ulp submode and page size */
+	req = (struct cpl_set_tcb_field *)skb_put(skb, sizeof(*req));
+	INIT_TP_WR(req, tid);
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, tid));
+	req->reply_ctrl = htons(NO_REPLY(reply) | QUEUENO(csk->rss_qid));
+	req->word_cookie = htons(TCB_WORD(W_TCB_ULP_RAW));
+	req->mask = cpu_to_be64(TCB_ULP_RAW(TCB_ULP_RAW_MASK));
+	req->val = cpu_to_be64(val);
+
+	skb->queue_mapping = CPL_PRIORITY_CONTROL;
+
+	cxgb4_ofld_send(cxgb4i_get_snic(csk->cdev)->lldi.ports[0], skb);
+	return 0;
+}
+
+static void __cxgb4i_ddp_cleanup(struct kref *kref)
+{
+	int i = 0;
+	struct cxgb4i_ddp_info *ddp = container_of(kref,
+						struct cxgb4i_ddp_info,
+						refcnt);
+
+	cxgbi_log_info("kref release ddp 0x%p, snic 0x%p\n", ddp, ddp->snic);
+
+	ddp->snic->ddp = NULL;
+
+	while (i < ddp->nppods) {
+		struct cxgbi_gather_list *gl = ddp->gl_map[i];
+
+		if (gl) {
+			int npods = (gl->nelem + PPOD_PAGES_MAX - 1) >>
+							PPOD_PAGES_SHIFT;
+			cxgbi_log_info("snic 0x%p, ddp %d + %d\n",
+						ddp->snic, i, npods);
+			kfree(gl);
+			i += npods;
+		} else
+			i++;
+	}
+	cxgbi_free_big_mem(ddp);
+}
+
+
+static void __cxgb4i_ddp_init(struct cxgb4i_snic *snic)
+{
+	struct cxgb4i_ddp_info *ddp = snic->ddp;
+	unsigned int ppmax, bits, tagmask, pgsz_factor[4];
+	int i;
+
+	if (ddp) {
+		kref_get(&ddp->refcnt);
+		cxgbi_log_warn("snic 0x%p, ddp 0x%p already set up\n",
+				snic, snic->ddp);
+		return;
+	}
+
+	sw_tag_idx_bits = (__ilog2_u32(ISCSI_ITT_MASK)) + 1;
+	sw_tag_age_bits = (__ilog2_u32(ISCSI_AGE_MASK)) + 1;
+	snic->cdev.tag_format.sw_bits = sw_tag_idx_bits + sw_tag_age_bits;
+
+	cxgbi_log_info("tag itt 0x%x, %u bits, age 0x%x, %u bits\n",
+			ISCSI_ITT_MASK, sw_tag_idx_bits,
+			ISCSI_AGE_MASK, sw_tag_age_bits);
+
+	ppmax = (snic->lldi.vr->iscsi.size >> PPOD_SIZE_SHIFT);
+	bits = __ilog2_u32(ppmax) + 1;
+	if (bits > PPOD_IDX_MAX_SIZE)
+		bits = PPOD_IDX_MAX_SIZE;
+	ppmax = (1 << (bits - 1)) - 1;
+
+	ddp = cxgbi_alloc_big_mem(sizeof(struct cxgb4i_ddp_info) +
+			ppmax * (sizeof(struct cxgbi_gather_list *) +
+				sizeof(struct sk_buff *)),
+				GFP_KERNEL);
+	if (!ddp) {
+		cxgbi_log_warn("snic 0x%p unable to alloc ddp 0x%d, "
+			       "ddp disabled\n", snic, ppmax);
+		return;
+	}
+
+	ddp->gl_map = (struct cxgbi_gather_list **)(ddp + 1);
+	spin_lock_init(&ddp->map_lock);
+	kref_init(&ddp->refcnt);
+
+	ddp->snic = snic;
+	ddp->pdev = snic->lldi.pdev;
+	ddp->max_txsz = min_t(unsigned int,
+				snic->lldi.iscsi_iolen,
+				ULP2_MAX_PKT_SIZE);
+	ddp->max_rxsz = min_t(unsigned int,
+				snic->lldi.iscsi_iolen,
+				ULP2_MAX_PKT_SIZE);
+	ddp->llimit = snic->lldi.vr->iscsi.start;
+	ddp->ulimit = ddp->llimit + snic->lldi.vr->iscsi.size;
+	ddp->nppods = ppmax;
+	ddp->idx_last = ppmax;
+	ddp->idx_bits = bits;
+	ddp->idx_mask = (1 << bits) - 1;
+	ddp->rsvd_tag_mask = (1 << (bits + PPOD_IDX_SHIFT)) - 1;
+
+	tagmask = ddp->idx_mask << PPOD_IDX_SHIFT;
+	for (i = 0; i < DDP_PGIDX_MAX; i++)
+		pgsz_factor[i] = ddp_page_order[i];
+
+	cxgb4_iscsi_init(snic->lldi.ports[0], tagmask, pgsz_factor);
+	snic->ddp = ddp;
+
+	snic->cdev.tag_format.rsvd_bits = ddp->idx_bits;
+	snic->cdev.tag_format.rsvd_shift = PPOD_IDX_SHIFT;
+	snic->cdev.tag_format.rsvd_mask =
+		((1 << snic->cdev.tag_format.rsvd_bits) - 1);
+
+	cxgbi_log_info("tag format: sw %u, rsvd %u,%u, mask 0x%x.\n",
+			snic->cdev.tag_format.sw_bits,
+			snic->cdev.tag_format.rsvd_bits,
+			snic->cdev.tag_format.rsvd_shift,
+			snic->cdev.tag_format.rsvd_mask);
+
+	snic->tx_max_size = min_t(unsigned int, ULP2_MAX_PDU_PAYLOAD,
+				ddp->max_txsz - ISCSI_PDU_NONPAYLOAD_LEN);
+	snic->rx_max_size = min_t(unsigned int, ULP2_MAX_PDU_PAYLOAD,
+				ddp->max_rxsz - ISCSI_PDU_NONPAYLOAD_LEN);
+
+	cxgbi_log_info("max payload size: %u/%u, %u/%u.\n",
+			snic->tx_max_size, ddp->max_txsz,
+			snic->rx_max_size, ddp->max_rxsz);
+
+	cxgbi_log_info("snic 0x%p, nppods %u, bits %u, mask 0x%x,0x%x "
+			"pkt %u/%u, %u/%u\n",
+			snic, ppmax, ddp->idx_bits, ddp->idx_mask,
+			ddp->rsvd_tag_mask, ddp->max_txsz,
+			snic->lldi.iscsi_iolen,
+			ddp->max_rxsz, snic->lldi.iscsi_iolen);
+
+	return;
+}
+
+void cxgb4i_ddp_init(struct cxgb4i_snic *snic)
+{
+	if (page_idx == DDP_PGIDX_MAX) {
+		page_idx = cxgb4i_ddp_find_page_index(PAGE_SIZE);
+
+		if (page_idx == DDP_PGIDX_MAX) {
+			cxgbi_log_info("system PAGE_SIZE %lu, update hw\n",
+					PAGE_SIZE);
+
+			if (cxgb4i_ddp_adjust_page_table()) {
+				cxgbi_log_info("PAGE_SIZE %lu, ddp disabled\n",
+						PAGE_SIZE);
+				return;
+			}
+			page_idx = cxgb4i_ddp_find_page_index(PAGE_SIZE);
+		}
+		cxgbi_log_info("system PAGE_SIZE %lu, ddp idx %u\n",
+				PAGE_SIZE, page_idx);
+	}
+
+	__cxgb4i_ddp_init(snic);
+	snic->cdev.ddp_make_gl = cxgb4i_ddp_make_gl;
+	snic->cdev.ddp_release_gl = cxgb4i_ddp_release_gl;
+	snic->cdev.ddp_tag_reserve = cxgb4i_ddp_tag_reserve;
+	snic->cdev.ddp_tag_release = cxgb4i_ddp_tag_release;
+}
+
+void cxgb4i_ddp_cleanup(struct cxgb4i_snic *snic)
+{
+	struct cxgb4i_ddp_info *ddp = snic->ddp;
+
+	cxgbi_log_info("snic 0x%p, release ddp 0x%p\n", snic, ddp);
+	if (ddp)
+		kref_put(&ddp->refcnt, __cxgb4i_ddp_cleanup);
+}
+
diff --git a/drivers/scsi/cxgb4i/cxgb4i_ddp.h b/drivers/scsi/cxgb4i/cxgb4i_ddp.h
new file mode 100644
index 0000000..f51cb37
--- /dev/null
+++ b/drivers/scsi/cxgb4i/cxgb4i_ddp.h
@@ -0,0 +1,118 @@
+/*
+ * cxgb4i_ddp.h: Chelsio T4 iSCSI driver.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#ifndef	__CXGB4I_DDP_H__
+#define	__CXGB4I_DDP_H__
+
+#include <linux/vmalloc.h>
+
+#include "libcxgbi.h"
+
+struct cxgbi_sock;
+
+struct cxgb4i_ddp_info {
+	struct list_head list;
+	struct kref refcnt;
+	struct cxgb4i_snic *snic;
+	struct pci_dev *pdev;
+	unsigned int max_txsz;
+	unsigned int max_rxsz;
+	unsigned int llimit;
+	unsigned int ulimit;
+	unsigned int nppods;
+	unsigned int idx_last;
+	unsigned char idx_bits;
+	unsigned char filler[3];
+	unsigned int idx_mask;
+	unsigned int rsvd_tag_mask;
+	spinlock_t map_lock;
+	struct cxgbi_gather_list **gl_map;
+};
+
+struct pagepod_hdr {
+	unsigned int vld_tid;
+	unsigned int pgsz_tag_clr;
+	unsigned int max_offset;
+	unsigned int page_offset;
+	unsigned long long rsvd;
+};
+
+struct pagepod {
+	struct pagepod_hdr hdr;
+	unsigned long long addr[PPOD_PAGES_MAX + 1];
+};
+
+struct cpl_rx_data_ddp {
+	union opcode_tid ot;
+	__be16 urg;
+	__be16 len;
+	__be32 seq;
+	union {
+		__be32 nxt_seq;
+		__be32 ddp_report;
+	};
+	__be32 ulp_crc;
+	__be32 ddpvld;
+};
+
+#define PPOD_SIZE               sizeof(struct pagepod)  /*  64 */
+#define PPOD_SIZE_SHIFT         6
+
+#define ULPMEM_DSGL_MAX_NPPODS	16	/*  1024/PPOD_SIZE */
+#define ULPMEM_IDATA_MAX_NPPODS	4	/*  256/PPOD_SIZE */
+#define PCIE_MEMWIN_MAX_NPPODS	16	/*  1024/PPOD_SIZE */
+
+#define PPOD_COLOR_SHIFT	0
+#define PPOD_COLOR_MASK		0x3F
+#define PPOD_COLOR_SIZE         6
+#define PPOD_COLOR(x)		((x) << PPOD_COLOR_SHIFT)
+
+#define PPOD_TAG_SHIFT	6
+#define PPOD_TAG_MASK	0xFFFFFF
+#define PPOD_TAG(x)	((x) << PPOD_TAG_SHIFT)
+
+#define PPOD_PGSZ_SHIFT	30
+#define PPOD_PGSZ_MASK	0x3
+#define PPOD_PGSZ(x)	((x) << PPOD_PGSZ_SHIFT)
+
+#define PPOD_TID_SHIFT	32
+#define PPOD_TID_MASK	0xFFFFFF
+#define PPOD_TID(x)	((__u64)(x) << PPOD_TID_SHIFT)
+
+#define PPOD_VALID_SHIFT	56
+#define PPOD_VALID(x)	((__u64)(x) << PPOD_VALID_SHIFT)
+#define PPOD_VALID_FLAG	PPOD_VALID(1ULL)
+
+#define PPOD_LEN_SHIFT	32
+#define PPOD_LEN_MASK	0xFFFFFFFF
+#define PPOD_LEN(x)	((__u64)(x) << PPOD_LEN_SHIFT)
+
+#define PPOD_OFST_SHIFT	0
+#define PPOD_OFST_MASK	0xFFFFFFFF
+#define PPOD_OFST(x)	((x) << PPOD_OFST_SHIFT)
+
+#define PPOD_IDX_SHIFT          PPOD_COLOR_SIZE
+#define PPOD_IDX_MAX_SIZE       24
+
+int cxgb4i_ddp_setup_conn_host_pagesize(struct cxgbi_sock*, unsigned int,
+					int);
+int cxgb4i_ddp_setup_conn_digest(struct cxgbi_sock *, unsigned int,
+				int, int, int);
+int cxgb4i_snic_ddp_info(struct cxgb4i_snic *, struct cxgbi_tag_format *,
+			unsigned int *, unsigned int *);
+
+void cxgb4i_ddp_init(struct cxgb4i_snic *);
+void cxgb4i_ddp_cleanup(struct cxgb4i_snic *);
+
+#endif	/* __CXGB4I_DDP_H__ */
+
diff --git a/drivers/scsi/cxgb4i/cxgb4i_offload.c b/drivers/scsi/cxgb4i/cxgb4i_offload.c
new file mode 100644
index 0000000..87edb14
--- /dev/null
+++ b/drivers/scsi/cxgb4i/cxgb4i_offload.c
@@ -0,0 +1,1846 @@
+/*
+ * cxgb4i_offload.c: Chelsio T4 iSCSI driver.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#include <linux/if_vlan.h>
+#include <net/dst.h>
+#include <net/route.h>
+#include <net/tcp.h>
+
+#include "libcxgbi.h"
+#include "cxgb4i.h"
+#include "cxgb4i_offload.h"
+
+static int cxgb4i_rcv_win = 256 * 1024;
+module_param(cxgb4i_rcv_win, int, 0644);
+MODULE_PARM_DESC(cxgb4i_rcv_win, "TCP reveive window in bytes");
+
+static int cxgb4i_snd_win = 128 * 1024;
+module_param(cxgb4i_snd_win, int, 0644);
+MODULE_PARM_DESC(cxgb4i_snd_win, "TCP send window in bytes");
+
+static int cxgb4i_rx_credit_thres = 10 * 1024;
+module_param(cxgb4i_rx_credit_thres, int, 0644);
+MODULE_PARM_DESC(cxgb4i_rx_credit_thres,
+		"RX credits return threshold in bytes (default=10KB)");
+
+static unsigned int cxgb4i_max_connect = (8 * 1024);
+module_param(cxgb4i_max_connect, uint, 0644);
+MODULE_PARM_DESC(cxgb4i_max_connect, "Maximum number of connections");
+
+static unsigned short cxgb4i_sport_base = 20000;
+module_param(cxgb4i_sport_base, ushort, 0644);
+MODULE_PARM_DESC(cxgb4i_sport_base, "Starting port number (default 20000)");
+
+#define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
+#define RCV_BUFSIZ_MASK	0x3FFU
+
+static void cxgb4i_sock_release_offload_resources(struct cxgbi_sock *);
+static void cxgbi_sock_conn_closing(struct cxgbi_sock *);
+static int cxgb4i_sock_push_tx_frames(struct cxgbi_sock *, int);
+
+
+#define MAX_IMM_TX_PKT_LEN 128
+
+/*
+ * is_ofld_imm - check whether a packet can be sent as immediate data
+ * @skb: the packet
+ *
+ * Returns true if a packet can be sent as an offload WR with immediate
+ * data.  We currently use the same limit as for Ethernet packets.
+ */
+static inline int is_ofld_imm(const struct sk_buff *skb)
+{
+	return skb->len <= (MAX_IMM_TX_PKT_LEN -
+			sizeof(struct fw_ofld_tx_data_wr));
+}
+
+static void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
+{
+	struct sk_buff *skb;
+	unsigned int read = 0;
+	struct iscsi_conn *conn = csk->user_data;
+	int err = 0;
+
+	cxgbi_rx_debug("csk 0x%p.\n", csk);
+
+	read_lock(&csk->callback_lock);
+	if (unlikely(!conn || conn->suspend_rx)) {
+		cxgbi_rx_debug("conn 0x%p, id %d, suspend_rx %lu!\n",
+				conn, conn ? conn->id : 0xFF,
+				conn ? conn->suspend_rx : 0xFF);
+		read_unlock(&csk->callback_lock);
+		return;
+	}
+	skb = skb_peek(&csk->receive_queue);
+	while (!err && skb) {
+		__skb_unlink(skb, &csk->receive_queue);
+		read += cxgb4i_skb_rx_pdulen(skb);
+		cxgbi_rx_debug("conn 0x%p, csk 0x%p, rx skb 0x%p, pdulen %u\n",
+				conn, csk, skb, cxgb4i_skb_rx_pdulen(skb));
+		if (cxgb4i_skb_flags(skb) & CXGB4I_SKCB_FLAG_HDR_RCVD)
+			err = cxgbi_conn_read_bhs_pdu_skb(conn, skb);
+		else if (cxgb4i_skb_flags(skb) == CXGB4I_SKCB_FLAG_DATA_RCVD)
+			err = cxgbi_conn_read_data_pdu_skb(conn, skb);
+		__kfree_skb(skb);
+		skb = skb_peek(&csk->receive_queue);
+	}
+	read_unlock(&csk->callback_lock);
+	csk->copied_seq += read;
+	cxgb4i_sock_rx_credits(csk, read);
+	conn->rxdata_octets += read;
+
+	if (err) {
+		cxgbi_log_info("conn 0x%p rx failed err %d.\n", conn, err);
+		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
+	}
+}
+
+static void cxgb4i_sock_closed(struct cxgbi_sock *csk)
+{
+	cxgbi_conn_debug("csk 0x%p, state %u, flags 0x%lx\n",
+			csk, csk->state, csk->flags);
+
+	cxgbi_sock_put_port(csk);
+	cxgb4i_sock_release_offload_resources(csk);
+	cxgbi_sock_set_state(csk, CXGBI_CSK_ST_CLOSED);
+	cxgbi_sock_conn_closing(csk);
+}
+
+static unsigned int cxgb4i_find_best_mtu(struct cxgb4i_snic *snic,
+						unsigned short mtu)
+{
+	int i = 0;
+
+	while (i < NMTUS - 1 && snic->lldi.mtus[i + 1] <= mtu)
+		++i;
+
+	return i;
+}
+
+static unsigned int cxgb4i_select_mss(struct cxgbi_sock *csk,
+						unsigned int pmtu)
+{
+	unsigned int idx;
+	struct dst_entry *dst = csk->dst;
+	u16 advmss = dst_metric(dst, RTAX_ADVMSS);
+
+	if (advmss > pmtu - 40)
+		advmss = pmtu - 40;
+	if (advmss < cxgb4i_get_snic(csk->cdev)->lldi.mtus[0] - 40)
+		advmss = cxgb4i_get_snic(csk->cdev)->lldi.mtus[0] - 40;
+	idx = cxgb4i_find_best_mtu(cxgb4i_get_snic(csk->cdev), advmss + 40);
+
+	return idx;
+}
+
+static inline int cxgb4i_sock_compute_wscale(int win)
+{
+	int wscale = 0;
+
+	while (wscale < 14 && (65535 << wscale) < win)
+		wscale++;
+
+	return wscale;
+}
+
+static void cxgb4i_sock_make_act_open_req(struct cxgbi_sock *csk,
+					   struct sk_buff *skb,
+					   unsigned int qid_atid,
+					   struct l2t_entry *e)
+{
+	struct cpl_act_open_req *req;
+	unsigned long long opt0;
+	unsigned int opt2;
+	int wscale;
+
+	cxgbi_conn_debug("csk 0x%p, atid 0x%x\n", csk, qid_atid);
+
+	wscale = cxgb4i_sock_compute_wscale(csk->mss_idx);
+
+	opt0 = KEEP_ALIVE(1) |
+		WND_SCALE(wscale) |
+		MSS_IDX(csk->mss_idx) |
+		L2T_IDX(((struct l2t_entry *)csk->l2t)->idx) |
+		TX_CHAN(csk->tx_chan) |
+		SMAC_SEL(csk->smac_idx) |
+		RCV_BUFSIZ(cxgb4i_rcv_win >> 10);
+
+	opt2 = RX_CHANNEL(0) |
+		RSS_QUEUE_VALID |
+		RSS_QUEUE(csk->rss_qid);
+
+	skb->queue_mapping = CPL_PRIORITY_SETUP;
+	req = (struct cpl_act_open_req *)__skb_put(skb, sizeof(*req));
+	INIT_TP_WR(req, 0);
+	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
+					qid_atid));
+	req->local_port = csk->saddr.sin_port;
+	req->peer_port = csk->daddr.sin_port;
+	req->local_ip = csk->saddr.sin_addr.s_addr;
+	req->peer_ip = csk->daddr.sin_addr.s_addr;
+	req->opt0 = cpu_to_be64(opt0);
+	req->params = 0;
+	req->opt2 = cpu_to_be32(opt2);
+}
+
+static void cxgb4i_fail_act_open(struct cxgbi_sock *csk, int errno)
+{
+	cxgbi_conn_debug("csk 0%p, state %u, flag 0x%lx\n", csk,
+			csk->state, csk->flags);
+	csk->err = errno;
+	cxgb4i_sock_closed(csk);
+}
+
+static void cxgb4i_act_open_req_arp_failure(void *handle, struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk = (struct cxgbi_sock *)skb->sk;
+
+	cxgbi_sock_hold(csk);
+	spin_lock_bh(&csk->lock);
+	if (csk->state == CXGBI_CSK_ST_CONNECTING)
+		cxgb4i_fail_act_open(csk, -EHOSTUNREACH);
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+	__kfree_skb(skb);
+}
+
+static void cxgb4i_sock_skb_entail(struct cxgbi_sock *csk,
+					struct sk_buff *skb,
+					int flags)
+{
+	cxgb4i_skb_tcp_seq(skb) = csk->write_seq;
+	cxgb4i_skb_flags(skb) = flags;
+	__skb_queue_tail(&csk->write_queue, skb);
+}
+
+static void cxgb4i_sock_send_close_req(struct cxgbi_sock *csk)
+{
+	struct sk_buff *skb = csk->cpl_close;
+	struct cpl_close_con_req *req = (struct cpl_close_con_req *)skb->head;
+	unsigned int tid = csk->hwtid;
+
+	csk->cpl_close = NULL;
+
+	skb->queue_mapping = CPL_PRIORITY_DATA;
+	INIT_TP_WR(req, tid);
+
+	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_CLOSE_CON_REQ, tid));
+	req->rsvd = 0;
+
+	cxgb4i_sock_skb_entail(csk, skb, CXGB4I_SKCB_FLAG_NO_APPEND);
+	if (csk->state != CXGBI_CSK_ST_CONNECTING)
+		cxgb4i_sock_push_tx_frames(csk, 1);
+}
+
+static void cxgb4i_sock_abort_arp_failure(void *handle, struct sk_buff *skb)
+{
+	struct cpl_abort_req *req = cplhdr(skb);
+	struct cxgbi_sock *csk = (struct cxgbi_sock *)handle;
+	struct cxgb4i_snic *snic = cxgb4i_get_snic(csk->cdev);
+
+	req->cmd = CPL_ABORT_NO_RST;
+	cxgb4_ofld_send(snic->lldi.ports[csk->port_id], skb);
+}
+
+static inline void cxgb4i_sock_purge_write_queue(struct cxgbi_sock *csk)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(&csk->write_queue)))
+		__kfree_skb(skb);
+}
+
+static void cxgb4i_sock_send_abort_req(struct cxgbi_sock *csk)
+{
+	struct cpl_abort_req *req;
+	struct sk_buff *skb = csk->cpl_abort_req;
+	struct cxgb4i_snic *snic = cxgb4i_get_snic(csk->cdev);
+
+	if (unlikely(csk->state == CXGBI_CSK_ST_ABORTING) ||
+			!skb || !csk->cdev)
+		return;
+
+	cxgbi_sock_set_state(csk, CXGBI_CSK_ST_ABORTING);
+
+	cxgbi_conn_debug("csk 0x%p, flag ABORT_RPL + ABORT_SHUT\n", csk);
+
+	cxgbi_sock_set_state(csk, CXGBI_CSK_FL_ABORT_RPL_PENDING);
+
+	cxgb4i_sock_purge_write_queue(csk);
+
+	csk->cpl_abort_req = NULL;
+	req = (struct cpl_abort_req *)skb->head;
+
+	skb->queue_mapping = CPL_PRIORITY_DATA;
+	t4_set_arp_err_handler(skb, csk, cxgb4i_sock_abort_arp_failure);
+	INIT_TP_WR(req, csk->hwtid);
+	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_REQ, csk->hwtid));
+	req->rsvd0 = htonl(csk->snd_nxt);
+	req->rsvd1 = !cxgbi_sock_flag(csk, CXGBI_CSK_FL_TX_DATA_SENT);
+	req->cmd = CPL_ABORT_SEND_RST;
+
+	cxgb4_l2t_send(snic->lldi.ports[csk->port_id], skb, csk->l2t);
+}
+
+static void cxgb4i_sock_send_abort_rpl(struct cxgbi_sock *csk, int rst_status)
+{
+	struct sk_buff *skb = csk->cpl_abort_rpl;
+	struct cpl_abort_rpl *rpl = (struct cpl_abort_rpl *)skb->head;
+	struct cxgb4i_snic *snic = cxgb4i_get_snic(csk->cdev);
+
+	csk->cpl_abort_rpl = NULL;
+
+	skb->queue_mapping = CPL_PRIORITY_DATA;
+	INIT_TP_WR(rpl, csk->hwtid);
+	OPCODE_TID(rpl) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_RPL, csk->hwtid));
+	rpl->cmd = rst_status;
+
+	cxgb4_ofld_send(snic->lldi.ports[csk->port_id], skb);
+}
+
+static u32 cxgb4i_csk_send_rx_credits(struct cxgbi_sock *csk, u32 credits)
+{
+	struct sk_buff *skb;
+	struct cpl_rx_data_ack *req;
+	int wrlen = roundup(sizeof(*req), 16);
+	struct cxgb4i_snic *snic = cxgb4i_get_snic(csk->cdev);
+
+	skb = alloc_skb(wrlen, GFP_ATOMIC);
+	if (!skb)
+		return 0;
+
+	req = (struct cpl_rx_data_ack *)__skb_put(skb, wrlen);
+	memset(req, 0, wrlen);
+	skb->queue_mapping = CPL_PRIORITY_ACK;
+	INIT_TP_WR(req, csk->hwtid);
+	OPCODE_TID(req) =
+		cpu_to_be32(MK_OPCODE_TID(CPL_RX_DATA_ACK, csk->hwtid));
+	req->credit_dack = cpu_to_be32(RX_CREDITS(credits) | RX_FORCE_ACK(1));
+	cxgb4_ofld_send(snic->lldi.ports[csk->port_id], skb);
+	return credits;
+}
+
+
+#define SKB_WR_LIST_SIZE	(MAX_SKB_FRAGS + 2)
+
+static const unsigned int cxgb4i_ulp_extra_len[] = { 0, 4, 4, 8 };
+static inline unsigned int ulp_extra_len(const struct sk_buff *skb)
+{
+	return cxgb4i_ulp_extra_len[cxgb4i_skb_ulp_mode(skb) & 3];
+}
+
+static inline void cxgb4i_sock_reset_wr_list(struct cxgbi_sock *csk)
+{
+	csk->wr_pending_head = csk->wr_pending_tail = NULL;
+}
+
+static inline void cxgb4i_sock_enqueue_wr(struct cxgbi_sock *csk,
+						struct sk_buff *skb)
+{
+	cxgb4i_skb_tx_wr_next(skb) = NULL;
+
+	/*
+	 * We want to take an extra reference since both us and the driver
+	 * need to free the packet before it's really freed. We know there's
+	 * just one user currently so we use atomic_set rather than skb_get
+	 * to avoid the atomic op.
+	 */
+	atomic_set(&skb->users, 2);
+
+	if (!csk->wr_pending_head)
+		csk->wr_pending_head = skb;
+
+	else
+		cxgb4i_skb_tx_wr_next(csk->wr_pending_tail) = skb;
+
+	csk->wr_pending_tail = skb;
+}
+
+static int cxgb4i_sock_count_pending_wrs(const struct cxgbi_sock *csk)
+{
+	int n = 0;
+	const struct sk_buff *skb = csk->wr_pending_head;
+
+	while (skb) {
+		n += skb->csum;
+		skb = cxgb4i_skb_tx_wr_next(skb);
+	}
+	return n;
+}
+
+static inline struct sk_buff *cxgb4i_sock_peek_wr(const struct cxgbi_sock *csk)
+{
+	return csk->wr_pending_head;
+}
+
+static inline void cxgb4i_sock_free_wr_skb(struct sk_buff *skb)
+{
+	kfree_skb(skb);
+}
+
+static inline struct sk_buff *cxgb4i_sock_dequeue_wr(struct cxgbi_sock *csk)
+{
+	struct sk_buff *skb = csk->wr_pending_head;
+
+	if (likely(skb)) {
+		csk->wr_pending_head = cxgb4i_skb_tx_wr_next(skb);
+		cxgb4i_skb_tx_wr_next(skb) = NULL;
+	}
+	return skb;
+}
+
+static void cxgb4i_sock_purge_wr_queue(struct cxgbi_sock *csk)
+{
+	struct sk_buff *skb;
+
+	while ((skb = cxgb4i_sock_dequeue_wr(csk)) != NULL)
+		cxgb4i_sock_free_wr_skb(skb);
+}
+
+/*
+ * sgl_len - calculates the size of an SGL of the given capacity
+ * @n: the number of SGL entries
+ * Calculates the number of flits needed for a scatter/gather list that
+ * can hold the given number of entries.
+ */
+static inline unsigned int sgl_len(unsigned int n)
+{
+	n--;
+	return (3 * n) / 2 + (n & 1) + 2;
+}
+
+/*
+ * calc_tx_flits_ofld - calculate # of flits for an offload packet
+ * @skb: the packet
+ *
+ * Returns the number of flits needed for the given offload packet.
+ * These packets are already fully constructed and no additional headers
+ * will be added.
+ */
+static inline unsigned int calc_tx_flits_ofld(const struct sk_buff *skb)
+{
+	unsigned int flits, cnt;
+
+	if (is_ofld_imm(skb))
+		return DIV_ROUND_UP(skb->len, 8);
+
+	flits = skb_transport_offset(skb) / 8;
+	cnt = skb_shinfo(skb)->nr_frags;
+	if (skb->tail != skb->transport_header)
+		cnt++;
+	return flits + sgl_len(cnt);
+}
+
+static inline void cxgb4i_sock_send_tx_flowc_wr(struct cxgbi_sock *csk)
+{
+	struct sk_buff *skb;
+	struct fw_flowc_wr *flowc;
+	int flowclen, i;
+	struct cxgb4i_snic *snic = cxgb4i_get_snic(csk->cdev);
+
+	flowclen = 80;
+	skb = alloc_skb(flowclen, GFP_ATOMIC);
+	flowc = (struct fw_flowc_wr *)__skb_put(skb, flowclen);
+
+	flowc->op_to_nparams =
+		htonl(FW_WR_OP(FW_FLOWC_WR) | FW_FLOWC_WR_NPARAMS(8));
+	flowc->flowid_len16 =
+		htonl(FW_WR_LEN16(DIV_ROUND_UP(72, 16)) |
+				FW_WR_FLOWID(csk->hwtid));
+
+	flowc->mnemval[0].mnemonic = FW_FLOWC_MNEM_PFNVFN;
+	flowc->mnemval[0].val = htonl(0);
+	flowc->mnemval[1].mnemonic = FW_FLOWC_MNEM_CH;
+	flowc->mnemval[1].val = htonl(csk->tx_chan);
+	flowc->mnemval[2].mnemonic = FW_FLOWC_MNEM_PORT;
+	flowc->mnemval[2].val = htonl(csk->tx_chan);
+	flowc->mnemval[3].mnemonic = FW_FLOWC_MNEM_IQID;
+	flowc->mnemval[3].val = htonl(csk->rss_qid);
+	flowc->mnemval[4].mnemonic = FW_FLOWC_MNEM_SNDNXT;
+	flowc->mnemval[4].val = htonl(csk->snd_nxt);
+	flowc->mnemval[5].mnemonic = FW_FLOWC_MNEM_RCVNXT;
+	flowc->mnemval[5].val = htonl(csk->rcv_nxt);
+	flowc->mnemval[6].mnemonic = FW_FLOWC_MNEM_SNDBUF;
+	flowc->mnemval[6].val = htonl(cxgb4i_snd_win);
+	flowc->mnemval[7].mnemonic = FW_FLOWC_MNEM_MSS;
+	flowc->mnemval[7].val = htonl(csk->mss_idx);
+	flowc->mnemval[8].mnemonic = 0;
+	flowc->mnemval[8].val = 0;
+	for (i = 0; i < 9; i++) {
+		flowc->mnemval[i].r4[0] = 0;
+		flowc->mnemval[i].r4[1] = 0;
+		flowc->mnemval[i].r4[2] = 0;
+	}
+
+	skb->queue_mapping = CPL_PRIORITY_DATA;
+
+	cxgb4_ofld_send(snic->lldi.ports[csk->port_id], skb);
+}
+
+static inline void cxgb4i_sock_make_tx_data_wr(struct cxgbi_sock *csk,
+						struct sk_buff *skb, int dlen,
+						int len, u32 credits,
+						int req_completion)
+{
+	struct fw_ofld_tx_data_wr *req;
+	unsigned int wr_ulp_mode;
+
+	if (is_ofld_imm(skb)) {
+			req = (struct fw_ofld_tx_data_wr *)
+				__skb_push(skb, sizeof(*req));
+			req->op_to_immdlen =
+				cpu_to_be32(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
+					FW_WR_COMPL(req_completion) |
+					FW_WR_IMMDLEN(dlen));
+			req->flowid_len16 =
+				cpu_to_be32(FW_WR_FLOWID(csk->hwtid) |
+						FW_WR_LEN16(credits));
+	} else {
+		req = (struct fw_ofld_tx_data_wr *)
+			__skb_push(skb, sizeof(*req));
+		req->op_to_immdlen =
+			cpu_to_be32(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
+					FW_WR_COMPL(req_completion) |
+					FW_WR_IMMDLEN(0));
+		req->flowid_len16 =
+			cpu_to_be32(FW_WR_FLOWID(csk->hwtid) |
+					FW_WR_LEN16(credits));
+	}
+
+	wr_ulp_mode =
+		FW_OFLD_TX_DATA_WR_ULPMODE(cxgb4i_skb_ulp_mode(skb) >> 4) |
+		FW_OFLD_TX_DATA_WR_ULPSUBMODE(cxgb4i_skb_ulp_mode(skb) & 3);
+
+	req->tunnel_to_proxy = cpu_to_be32(wr_ulp_mode) |
+		FW_OFLD_TX_DATA_WR_SHOVE(skb_peek(&csk->write_queue) ? 0 : 1);
+
+	req->plen = cpu_to_be32(len);
+
+	if (!cxgbi_sock_flag(csk, CXGBI_CSK_FL_TX_DATA_SENT))
+		cxgbi_sock_set_flag(csk, CXGBI_CSK_FL_TX_DATA_SENT);
+}
+
+static void cxgb4i_sock_arp_failure_discard(void *handle, struct sk_buff *skb)
+{
+	kfree_skb(skb);
+}
+
+static int cxgb4i_sock_push_tx_frames(struct cxgbi_sock *csk,
+						int req_completion)
+{
+	int total_size = 0;
+	struct sk_buff *skb;
+	struct cxgb4i_snic *snic;
+
+	if (unlikely(csk->state == CXGBI_CSK_ST_CONNECTING ||
+				csk->state == CXGBI_CSK_ST_CLOSE_WAIT_1 ||
+				csk->state >= CXGBI_CSK_ST_ABORTING)) {
+		cxgbi_tx_debug("csk 0x%p, in closing state %u.\n",
+				csk, csk->state);
+		return 0;
+	}
+
+	snic = cxgb4i_get_snic(csk->cdev);
+
+	while (csk->wr_cred
+			&& (skb = skb_peek(&csk->write_queue)) != NULL) {
+		int dlen;
+		int len;
+		unsigned int credits_needed;
+
+		dlen = len = skb->len;
+		skb_reset_transport_header(skb);
+
+		if (is_ofld_imm(skb))
+			credits_needed = DIV_ROUND_UP(dlen +
+					sizeof(struct fw_ofld_tx_data_wr), 16);
+		else
+			credits_needed = DIV_ROUND_UP(8 *
+					calc_tx_flits_ofld(skb)+
+					sizeof(struct fw_ofld_tx_data_wr), 16);
+
+		if (csk->wr_cred < credits_needed) {
+			cxgbi_tx_debug("csk 0x%p, skb len %u/%u, "
+					"wr %d < %u.\n",
+					csk, skb->len, skb->data_len,
+					credits_needed, csk->wr_cred);
+			break;
+		}
+
+		__skb_unlink(skb, &csk->write_queue);
+		skb->queue_mapping = CPL_PRIORITY_DATA;
+		skb->csum = credits_needed; /* remember this until the WR_ACK */
+		csk->wr_cred -= credits_needed;
+		csk->wr_una_cred += credits_needed;
+		cxgb4i_sock_enqueue_wr(csk, skb);
+
+		cxgbi_tx_debug("csk 0x%p, enqueue, skb len %u/%u, "
+				"wr %d, left %u, unack %u.\n",
+				csk, skb->len, skb->data_len,
+				credits_needed, csk->wr_cred,
+				csk->wr_una_cred);
+
+
+		if (likely(cxgb4i_skb_flags(skb) &
+					CXGB4I_SKCB_FLAG_NEED_HDR)) {
+			len += ulp_extra_len(skb);
+			if (!cxgbi_sock_flag(csk,
+						CXGBI_CSK_FL_TX_DATA_SENT)) {
+				cxgb4i_sock_send_tx_flowc_wr(csk);
+				skb->csum += 5;
+				csk->wr_cred -= 5;
+				csk->wr_una_cred += 5;
+			}
+
+			if ((req_completion &&
+				csk->wr_una_cred == credits_needed) ||
+				(cxgb4i_skb_flags(skb) &
+				  CXGB4I_SKCB_FLAG_COMPL) ||
+				csk->wr_una_cred >= csk->wr_max_cred / 2) {
+				req_completion = 1;
+				csk->wr_una_cred = 0;
+			}
+			cxgb4i_sock_make_tx_data_wr(csk, skb, dlen, len,
+							credits_needed,
+							req_completion);
+			csk->snd_nxt += len;
+
+			if (req_completion)
+				cxgb4i_skb_flags(skb) &=
+					~CXGB4I_SKCB_FLAG_NEED_HDR;
+		}
+
+		total_size += skb->truesize;
+		t4_set_arp_err_handler(skb, csk,
+					cxgb4i_sock_arp_failure_discard);
+		cxgb4_l2t_send(snic->lldi.ports[csk->port_id], skb, csk->l2t);
+	}
+	return total_size;
+}
+
+static inline void cxgb4i_sock_free_atid(struct cxgbi_sock *csk)
+{
+	cxgb4_free_atid(cxgb4i_get_snic(csk->cdev)->lldi.tids, csk->atid);
+	cxgbi_sock_put(csk);
+}
+
+static void cxgb4i_sock_established(struct cxgbi_sock *csk, u32 snd_isn,
+					unsigned int opt)
+{
+	cxgbi_conn_debug("csk 0x%p, state %u.\n", csk, csk->state);
+
+	csk->write_seq = csk->snd_nxt = csk->snd_una = snd_isn;
+
+	/*
+	 * Causes the first RX_DATA_ACK to supply any Rx credits we couldn't
+	 * pass through opt0.
+	 */
+	if (cxgb4i_rcv_win > (RCV_BUFSIZ_MASK << 10))
+		csk->rcv_wup -= cxgb4i_rcv_win - (RCV_BUFSIZ_MASK << 10);
+
+	dst_confirm(csk->dst);
+
+	smp_mb();
+
+	cxgbi_sock_set_state(csk, CXGBI_CSK_ST_ESTABLISHED);
+}
+
+static int cxgb4i_cpl_act_establish(struct cxgb4i_snic *snic,
+						struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_act_establish *req = cplhdr(skb);
+	unsigned int hwtid = GET_TID(req);
+	unsigned int atid = GET_TID_TID(ntohl(req->tos_atid));
+	struct tid_info *t = snic->lldi.tids;
+	u32 rcv_isn = be32_to_cpu(req->rcv_isn);
+
+	csk = lookup_atid(t, atid);
+
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	cxgbi_conn_debug("csk 0x%p, state %u, flag 0x%lx\n",
+				csk, csk->state, csk->flags);
+	csk->hwtid = hwtid;
+	cxgbi_sock_hold(csk);
+	cxgb4_insert_tid(snic->lldi.tids, csk, hwtid);
+	cxgb4_free_atid(snic->lldi.tids, atid);
+
+	spin_lock_bh(&csk->lock);
+
+	if (unlikely(csk->state != CXGBI_CSK_ST_CONNECTING))
+		cxgbi_log_error("TID %u expected SYN_SENT, got EST., s %u\n",
+				csk->hwtid, csk->state);
+
+	csk->copied_seq = csk->rcv_wup = csk->rcv_nxt = rcv_isn;
+	cxgb4i_sock_established(csk, ntohl(req->snd_isn), ntohs(req->tcp_opt));
+
+	__kfree_skb(skb);
+
+	if (unlikely(cxgbi_sock_flag(csk, CXGBI_CSK_FL_ACTIVE_CLOSE_NEEDED)))
+		cxgb4i_sock_send_abort_req(csk);
+	else {
+		if (skb_queue_len(&csk->write_queue))
+			cxgb4i_sock_push_tx_frames(csk, 1);
+
+		cxgbi_conn_tx_open(csk);
+	}
+
+	spin_unlock_bh(&csk->lock);
+
+	return 0;
+}
+
+static int act_open_rpl_status_to_errno(int status)
+{
+	switch (status) {
+	case CPL_ERR_CONN_RESET:
+		return -ECONNREFUSED;
+	case CPL_ERR_ARP_MISS:
+		return -EHOSTUNREACH;
+	case CPL_ERR_CONN_TIMEDOUT:
+		return -ETIMEDOUT;
+	case CPL_ERR_TCAM_FULL:
+		return -ENOMEM;
+	case CPL_ERR_CONN_EXIST:
+		cxgbi_log_error("ACTIVE_OPEN_RPL: 4-tuple in use\n");
+		return -EADDRINUSE;
+	default:
+		return -EIO;
+	}
+}
+
+/*
+ * Return whether a failed active open has allocated a TID
+ */
+static inline int act_open_has_tid(int status)
+{
+	return status != CPL_ERR_TCAM_FULL && status != CPL_ERR_CONN_EXIST &&
+		status != CPL_ERR_ARP_MISS;
+}
+
+static void cxgb4i_sock_act_open_retry_timer(unsigned long data)
+{
+	struct sk_buff *skb;
+	struct cxgbi_sock *csk = (struct cxgbi_sock *)data;
+	struct cxgb4i_snic *snic = cxgb4i_get_snic(csk->cdev);
+
+	cxgbi_conn_debug("csk 0x%p, state %u.\n", csk, csk->state);
+
+	spin_lock_bh(&csk->lock);
+	skb = alloc_skb(sizeof(struct cpl_act_open_req), GFP_ATOMIC);
+	if (!skb)
+		cxgb4i_fail_act_open(csk, -ENOMEM);
+	else {
+		unsigned int qid_atid  = csk->rss_qid << 14;
+		qid_atid |= (unsigned int)csk->atid;
+		skb->sk = (struct sock *)csk;
+		t4_set_arp_err_handler(skb, csk,
+					cxgb4i_act_open_req_arp_failure);
+		cxgb4i_sock_make_act_open_req(csk, skb, qid_atid, csk->l2t);
+		cxgb4_l2t_send(snic->lldi.ports[csk->port_id], skb, csk->l2t);
+	}
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+}
+
+static int cxgb4i_cpl_act_open_rpl(struct cxgb4i_snic *snic,
+						struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_act_open_rpl *rpl = cplhdr(skb);
+	unsigned int atid =
+		GET_TID_TID(GET_AOPEN_ATID(be32_to_cpu(rpl->atid_status)));
+	struct tid_info *t = snic->lldi.tids;
+	unsigned int status = GET_AOPEN_STATUS(be32_to_cpu(rpl->atid_status));
+
+	csk = lookup_atid(t, atid);
+
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", atid);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	cxgbi_sock_hold(csk);
+	spin_lock_bh(&csk->lock);
+
+	cxgbi_conn_debug("rcv, status 0x%x, csk 0x%p, csk->state %u, "
+			"csk->flag 0x%lx, csk->atid %u.\n",
+			status, csk, csk->state, csk->flags, csk->hwtid);
+
+	if (status & act_open_has_tid(status))
+		cxgb4_remove_tid(snic->lldi.tids, csk->port_id, GET_TID(rpl));
+
+	if (status == CPL_ERR_CONN_EXIST &&
+			csk->retry_timer.function !=
+			cxgb4i_sock_act_open_retry_timer) {
+		csk->retry_timer.function = cxgb4i_sock_act_open_retry_timer;
+		if (!mod_timer(&csk->retry_timer, jiffies + HZ / 2))
+			cxgbi_sock_hold(csk);
+	} else
+
+		cxgb4i_fail_act_open(csk, act_open_rpl_status_to_errno(status));
+
+	__kfree_skb(skb);
+
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+
+	return 0;
+}
+
+static int cxgb4i_cpl_peer_close(struct cxgb4i_snic *snic, struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_peer_close *req = cplhdr(skb);
+	unsigned int hwtid = GET_TID(req);
+	struct tid_info *t = snic->lldi.tids;
+
+	csk = lookup_tid(t, hwtid);
+
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	cxgbi_sock_hold(csk);
+	spin_lock_bh(&csk->lock);
+
+	if (cxgbi_sock_flag(csk, CXGBI_CSK_FL_ABORT_RPL_PENDING))
+		goto out;
+
+	switch (csk->state) {
+	case CXGBI_CSK_ST_ESTABLISHED:
+		cxgbi_sock_set_state(csk, CXGBI_CSK_ST_PASSIVE_CLOSE);
+		break;
+	case CXGBI_CSK_ST_ACTIVE_CLOSE:
+		cxgbi_sock_set_state(csk, CXGBI_CSK_ST_CLOSE_WAIT_2);
+		break;
+	case CXGBI_CSK_ST_CLOSE_WAIT_1:
+		cxgb4i_sock_closed(csk);
+		break;
+	case CXGBI_CSK_ST_ABORTING:
+		break;
+	default:
+		cxgbi_log_error("peer close, TID %u in bad state %u\n",
+				csk->hwtid, csk->state);
+	}
+
+	cxgbi_sock_conn_closing(csk);
+
+out:
+	__kfree_skb(skb);
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+
+	return 0;
+}
+
+static int cxgb4i_cpl_close_con_rpl(struct cxgb4i_snic *snic,
+						struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_close_con_rpl *rpl = cplhdr(skb);
+	unsigned int hwtid = GET_TID(rpl);
+	struct tid_info *t = snic->lldi.tids;
+
+	csk = lookup_tid(t, hwtid);
+
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	cxgbi_sock_hold(csk);
+	spin_lock_bh(&csk->lock);
+
+	cxgbi_conn_debug("csk 0x%p, state %u, flag 0x%lx.\n",
+			csk, csk->state, csk->flags);
+
+	csk->snd_una = ntohl(rpl->snd_nxt) - 1;
+
+	if (cxgbi_sock_flag(csk, CXGBI_CSK_FL_ABORT_RPL_PENDING))
+		goto out;
+
+	switch (csk->state) {
+	case CXGBI_CSK_ST_ACTIVE_CLOSE:
+		cxgbi_sock_set_state(csk, CXGBI_CSK_ST_CLOSE_WAIT_1);
+		break;
+	case CXGBI_CSK_ST_CLOSE_WAIT_1:
+	case CXGBI_CSK_ST_CLOSE_WAIT_2:
+		cxgb4i_sock_closed(csk);
+		break;
+	case CXGBI_CSK_ST_ABORTING:
+		break;
+	default:
+		cxgbi_log_error("close_rpl, TID %u in bad state %u\n",
+				csk->hwtid, csk->state);
+	}
+out:
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+	kfree_skb(skb);
+
+	return 0;
+}
+
+static int abort_status_to_errno(struct cxgbi_sock *csk, int abort_reason,
+								int *need_rst)
+{
+	switch (abort_reason) {
+	case CPL_ERR_BAD_SYN: /* fall through */
+	case CPL_ERR_CONN_RESET:
+		return csk->state > CXGBI_CSK_ST_ESTABLISHED ?
+			-EPIPE : -ECONNRESET;
+	case CPL_ERR_XMIT_TIMEDOUT:
+	case CPL_ERR_PERSIST_TIMEDOUT:
+	case CPL_ERR_FINWAIT2_TIMEDOUT:
+	case CPL_ERR_KEEPALIVE_TIMEDOUT:
+		return -ETIMEDOUT;
+	default:
+		return -EIO;
+	}
+}
+
+/*
+ * Returns whether an ABORT_REQ_RSS message is a negative advice.
+ */
+static inline int is_neg_adv_abort(unsigned int status)
+{
+	return status == CPL_ERR_RTX_NEG_ADVICE ||
+		status == CPL_ERR_PERSIST_NEG_ADVICE;
+}
+
+static int cxgb4i_cpl_abort_req_rss(struct cxgb4i_snic *snic,
+						struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_abort_req_rss *req = cplhdr(skb);
+	unsigned int hwtid = GET_TID(req);
+	struct tid_info *t = snic->lldi.tids;
+	int rst_status = CPL_ABORT_NO_RST;
+
+	csk = lookup_tid(t, hwtid);
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	cxgbi_sock_hold(csk);
+	spin_lock_bh(&csk->lock);
+
+	if (is_neg_adv_abort(req->status)) {
+		__kfree_skb(skb);
+		return 0;
+	}
+
+	if (!cxgbi_sock_flag(csk, CXGBI_CSK_FL_ABORT_REQ_RCVD)) {
+		cxgbi_sock_set_flag(csk, CXGBI_CSK_FL_ABORT_REQ_RCVD);
+		cxgbi_sock_set_state(csk, CXGBI_CSK_ST_ABORTING);
+		__kfree_skb(skb);
+		return 0;
+	}
+
+	cxgbi_sock_clear_flag(csk, CXGBI_CSK_FL_ABORT_REQ_RCVD);
+	cxgb4i_sock_send_abort_rpl(csk, rst_status);
+
+	if (!cxgbi_sock_flag(csk, CXGBI_CSK_FL_ABORT_RPL_PENDING)) {
+		csk->err = abort_status_to_errno(csk, req->status,
+							&rst_status);
+		cxgb4i_sock_closed(csk);
+	}
+
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+
+	return 0;
+}
+
+static int cxgb4i_cpl_abort_rpl_rss(struct cxgb4i_snic *snic,
+						struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_abort_rpl_rss *rpl = cplhdr(skb);
+	unsigned int hwtid = GET_TID(rpl);
+	struct tid_info *t = snic->lldi.tids;
+
+	if (rpl->status == CPL_ERR_ABORT_FAILED)
+		goto out;
+
+	csk = lookup_tid(t, hwtid);
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		goto out;
+	}
+
+	cxgbi_sock_hold(csk);
+	spin_lock_bh(&csk->lock);
+
+	if (cxgbi_sock_flag(csk, CXGBI_CSK_FL_ABORT_RPL_PENDING)) {
+		if (!cxgbi_sock_flag(csk, CXGBI_CSK_FL_ABORT_RPL_RCVD))
+			cxgbi_sock_set_flag(csk,
+						CXGBI_CSK_FL_ABORT_RPL_RCVD);
+		else {
+			cxgbi_sock_clear_flag(csk,
+						CXGBI_CSK_FL_ABORT_RPL_RCVD);
+			cxgbi_sock_clear_flag(csk,
+					CXGBI_CSK_FL_ABORT_RPL_PENDING);
+
+			if (cxgbi_sock_flag(csk,
+						CXGBI_CSK_FL_ABORT_REQ_RCVD))
+				cxgbi_log_error("tid %u, ABORT_RPL_RSS\n",
+						csk->hwtid);
+
+			cxgb4i_sock_closed(csk);
+		}
+	}
+
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+
+out:
+	__kfree_skb(skb);
+	return 0;
+}
+
+static int cxgb4i_cpl_iscsi_hdr(struct cxgb4i_snic *snic, struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_iscsi_hdr *cpl = cplhdr(skb);
+	unsigned int hwtid = GET_TID(cpl);
+	struct tid_info *t = snic->lldi.tids;
+	struct sk_buff *lskb;
+
+	csk = lookup_tid(t, hwtid);
+
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	spin_lock_bh(&csk->lock);
+
+	if (unlikely(csk->state >= CXGBI_CSK_ST_PASSIVE_CLOSE)) {
+		if (csk->state != CXGBI_CSK_ST_ABORTING)
+			goto abort_conn;
+	}
+
+	cxgb4i_skb_tcp_seq(skb) = ntohl(cpl->seq);
+	cxgb4i_skb_flags(skb) = 0;
+
+	skb_reset_transport_header(skb);
+	__skb_pull(skb, sizeof(*cpl));
+	__pskb_trim(skb, ntohs(cpl->len));
+
+	if (!csk->skb_ulp_lhdr) {
+		unsigned char *byte;
+		csk->skb_ulp_lhdr = skb;
+		lskb = csk->skb_ulp_lhdr;
+
+		cxgb4i_skb_flags(lskb) = CXGB4I_SKCB_FLAG_HDR_RCVD;
+
+		if (cxgb4i_skb_tcp_seq(lskb) != csk->rcv_nxt) {
+			cxgbi_log_error("tid 0x%x, CPL_ISCSI_HDR, bad seq got "
+					"0x%x, exp 0x%x\n",
+					csk->hwtid,
+					cxgb4i_skb_tcp_seq(lskb),
+					csk->rcv_nxt);
+		}
+
+		byte = skb->data;
+		cxgb4i_skb_rx_pdulen(skb) = ntohs(cpl->pdu_len_ddp) - 40;
+		csk->rcv_nxt += cxgb4i_skb_rx_pdulen(lskb);
+	} else {
+		lskb = csk->skb_ulp_lhdr;
+		cxgb4i_skb_flags(lskb) |= CXGB4I_SKCB_FLAG_DATA_RCVD;
+		cxgb4i_skb_flags(skb) = CXGB4I_SKCB_FLAG_DATA_RCVD;
+		cxgbi_log_debug("csk 0x%p, tid 0x%x skb 0x%p, pdu data, "
+				" header 0x%p.\n",
+				csk, csk->hwtid, skb, lskb);
+	}
+
+	__skb_queue_tail(&csk->receive_queue, skb);
+
+	spin_unlock_bh(&csk->lock);
+
+	return 0;
+
+abort_conn:
+	cxgb4i_sock_send_abort_req(csk);
+	__kfree_skb(skb);
+	spin_unlock_bh(&csk->lock);
+
+	return -EINVAL;
+}
+
+static int cxgb4i_cpl_rx_data_ddp(struct cxgb4i_snic *snic, struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct sk_buff *lskb;
+	struct cpl_rx_data_ddp *rpl = cplhdr(skb);
+	unsigned int hwtid = GET_TID(rpl);
+	struct tid_info *t = snic->lldi.tids;
+	unsigned int status;
+
+	csk = lookup_tid(t, hwtid);
+
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	spin_lock_bh(&csk->lock);
+
+	if (unlikely(csk->state >= CXGBI_CSK_ST_PASSIVE_CLOSE)) {
+		if (csk->state != CXGBI_CSK_ST_ABORTING)
+			goto abort_conn;
+	}
+
+	if (!csk->skb_ulp_lhdr) {
+		cxgbi_log_error("tid 0x%x, rcv RX_DATA_DDP w/o pdu header\n",
+				csk->hwtid);
+		goto abort_conn;
+	}
+
+	lskb = csk->skb_ulp_lhdr;
+	cxgb4i_skb_flags(lskb) |= CXGB4I_SKCB_FLAG_STATUS_RCVD;
+
+	if (ntohs(rpl->len) != cxgb4i_skb_rx_pdulen(lskb)) {
+		cxgbi_log_error("tid 0x%x, RX_DATA_DDP pdulen %u != %u.\n",
+				csk->hwtid, ntohs(rpl->len),
+				cxgb4i_skb_rx_pdulen(lskb));
+	}
+
+	cxgb4i_skb_rx_ddigest(lskb) = ntohl(rpl->ulp_crc);
+	status = ntohl(rpl->ddpvld);
+
+	if (status & (1 << RX_DDP_STATUS_HCRC_SHIFT))
+		cxgb4i_skb_ulp_mode(skb) |= ULP2_FLAG_HCRC_ERROR;
+	if (status & (1 << RX_DDP_STATUS_DCRC_SHIFT))
+		cxgb4i_skb_ulp_mode(skb) |= ULP2_FLAG_DCRC_ERROR;
+	if (status & (1 << RX_DDP_STATUS_PAD_SHIFT))
+		cxgb4i_skb_ulp_mode(skb) |= ULP2_FLAG_PAD_ERROR;
+	if ((cxgb4i_skb_flags(lskb) & ULP2_FLAG_DATA_READY))
+		cxgb4i_skb_ulp_mode(skb) |= ULP2_FLAG_DATA_DDPED;
+
+	csk->skb_ulp_lhdr = NULL;
+
+	__kfree_skb(skb);
+	cxgbi_conn_pdu_ready(csk);
+	spin_unlock_bh(&csk->lock);
+
+	return 0;
+
+abort_conn:
+	cxgb4i_sock_send_abort_req(csk);
+	__kfree_skb(skb);
+	spin_unlock_bh(&csk->lock);
+	return -EINVAL;
+}
+
+static void check_wr_invariants(const struct cxgbi_sock *csk)
+{
+	int pending = cxgb4i_sock_count_pending_wrs(csk);
+
+	if (unlikely(csk->wr_cred + pending != csk->wr_max_cred))
+		printk(KERN_ERR "TID %u: credit imbalance: avail %u, "
+				"pending %u, total should be %u\n",
+				csk->hwtid,
+				csk->wr_cred,
+				pending,
+				csk->wr_max_cred);
+}
+
+static int cxgb4i_cpl_fw4_ack(struct cxgb4i_snic *snic, struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_fw4_ack *rpl = cplhdr(skb);
+	unsigned int hwtid = GET_TID(rpl);
+	struct tid_info *t = snic->lldi.tids;
+	unsigned char credits;
+	unsigned int snd_una;
+
+	csk = lookup_tid(t, hwtid);
+	if (unlikely(!csk)) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		kfree_skb(skb);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	cxgbi_sock_hold(csk);
+	spin_lock_bh(&csk->lock);
+
+	credits = rpl->credits;
+	snd_una = be32_to_cpu(rpl->snd_una);
+
+	cxgbi_tx_debug("%u WR credits, avail %u, unack %u, TID %u, state %u\n",
+				credits, csk->wr_cred, csk->wr_una_cred,
+						csk->hwtid, csk->state);
+
+	csk->wr_cred += credits;
+
+	if (csk->wr_una_cred > csk->wr_max_cred - csk->wr_cred)
+		csk->wr_una_cred = csk->wr_max_cred - csk->wr_cred;
+
+	while (credits) {
+		struct sk_buff *p = cxgb4i_sock_peek_wr(csk);
+
+		if (unlikely(!p)) {
+			cxgbi_log_error("%u WR_ACK credits for TID %u with "
+					"nothing pending, state %u\n",
+					credits, csk->hwtid, csk->state);
+			break;
+		}
+
+		if (unlikely(credits < p->csum)) {
+			p->csum -= credits;
+		} else {
+			cxgb4i_sock_dequeue_wr(csk);
+			credits -= p->csum;
+			cxgb4i_sock_free_wr_skb(p);
+		}
+	}
+
+	check_wr_invariants(csk);
+
+	if (rpl->seq_vld) {
+		if (unlikely(before(snd_una, csk->snd_una))) {
+			cxgbi_log_error("TID %u, unexpected sequence # %u "
+					"in WR_ACK snd_una %u\n",
+					csk->hwtid, snd_una, csk->snd_una);
+			goto out_free;
+		}
+	}
+
+	if (csk->snd_una != snd_una) {
+		csk->snd_una = snd_una;
+		dst_confirm(csk->dst);
+	}
+
+	if (skb_queue_len(&csk->write_queue)) {
+		if (cxgb4i_sock_push_tx_frames(csk, 0))
+			cxgbi_conn_tx_open(csk);
+	} else
+		cxgbi_conn_tx_open(csk);
+
+	goto out;
+
+out_free:
+
+	__kfree_skb(skb);
+
+out:
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+
+	return 0;
+}
+
+static int cxgb4i_cpl_set_tcb_rpl(struct cxgb4i_snic *snic, struct sk_buff *skb)
+{
+	struct cpl_set_tcb_rpl *rpl = cplhdr(skb);
+	unsigned int hwtid = GET_TID(rpl);
+	struct tid_info *t = snic->lldi.tids;
+	struct cxgbi_sock *csk;
+
+	csk = lookup_tid(t, hwtid);
+
+	if (!csk) {
+		cxgbi_log_error("can't find connection for tid %u\n", hwtid);
+		__kfree_skb(skb);
+		return CPL_RET_UNKNOWN_TID;
+	}
+
+	spin_lock_bh(&csk->lock);
+
+	if (rpl->status != CPL_ERR_NONE) {
+		cxgbi_log_error("Unexpected SET_TCB_RPL status %u "
+				 "for tid %u\n", rpl->status, GET_TID(rpl));
+	}
+
+	__kfree_skb(skb);
+	spin_unlock_bh(&csk->lock);
+
+	return 0;
+}
+
+static void cxgb4i_sock_free_cpl_skbs(struct cxgbi_sock *csk)
+{
+	if (csk->cpl_close)
+		kfree_skb(csk->cpl_close);
+	if (csk->cpl_abort_req)
+		kfree_skb(csk->cpl_abort_req);
+	if (csk->cpl_abort_rpl)
+		kfree_skb(csk->cpl_abort_rpl);
+}
+
+static int cxgb4i_alloc_cpl_skbs(struct cxgbi_sock *csk)
+{
+	csk->cpl_close = alloc_skb(sizeof(struct cpl_close_con_req),
+					GFP_KERNEL);
+	if (!csk->cpl_close)
+		return -ENOMEM;
+	skb_put(csk->cpl_close, sizeof(struct cpl_close_con_req));
+
+	csk->cpl_abort_req = alloc_skb(sizeof(struct cpl_abort_req),
+					GFP_KERNEL);
+	if (!csk->cpl_abort_req)
+		goto free_cpl_skbs;
+	skb_put(csk->cpl_abort_req, sizeof(struct cpl_abort_req));
+
+	csk->cpl_abort_rpl = alloc_skb(sizeof(struct cpl_abort_rpl),
+					GFP_KERNEL);
+	if (!csk->cpl_abort_rpl)
+		goto free_cpl_skbs;
+	skb_put(csk->cpl_abort_rpl, sizeof(struct cpl_abort_rpl));
+
+	return 0;
+
+free_cpl_skbs:
+	cxgb4i_sock_free_cpl_skbs(csk);
+	return -ENOMEM;
+}
+
+static void cxgb4i_sock_release_offload_resources(struct cxgbi_sock *csk)
+{
+
+	cxgb4i_sock_free_cpl_skbs(csk);
+
+	if (csk->wr_cred != csk->wr_max_cred) {
+		cxgb4i_sock_purge_wr_queue(csk);
+		cxgb4i_sock_reset_wr_list(csk);
+	}
+
+	if (csk->l2t) {
+		cxgb4_l2t_release(csk->l2t);
+		csk->l2t = NULL;
+	}
+
+	if (csk->state == CXGBI_CSK_ST_CONNECTING)
+		cxgb4i_sock_free_atid(csk);
+	else {
+		cxgb4_remove_tid(cxgb4i_get_snic(csk->cdev)->lldi.tids, 0,
+				csk->hwtid);
+		cxgbi_sock_put(csk);
+	}
+
+	csk->dst = NULL;
+	csk->cdev = NULL;
+}
+
+struct cxgbi_sock *cxgb4i_sock_create(struct cxgb4i_snic *snic)
+{
+	struct cxgbi_sock *csk = NULL;
+
+	csk = kzalloc(sizeof(*csk), GFP_KERNEL);
+	if (!csk)
+		return NULL;
+
+	if (cxgb4i_alloc_cpl_skbs(csk) < 0)
+		goto free_csk;
+
+	cxgbi_conn_debug("alloc csk: 0x%p\n", csk);
+
+	csk->flags = 0;
+	spin_lock_init(&csk->lock);
+	atomic_set(&csk->refcnt, 1);
+	skb_queue_head_init(&csk->receive_queue);
+	skb_queue_head_init(&csk->write_queue);
+	setup_timer(&csk->retry_timer, NULL, (unsigned long)csk);
+	rwlock_init(&csk->callback_lock);
+	csk->cdev = &snic->cdev;
+
+	return csk;
+
+free_csk:
+	cxgbi_api_debug("csk alloc failed %p, baling out\n", csk);
+	kfree(csk);
+	return NULL;
+}
+
+static void cxgb4i_sock_active_close(struct cxgbi_sock *csk)
+{
+	int data_lost;
+	int close_req = 0;
+
+	cxgbi_conn_debug("csk 0x%p, state %u, flags %lu\n",
+			csk, csk->state, csk->flags);
+
+	dst_confirm(csk->dst);
+
+	cxgbi_sock_hold(csk);
+	spin_lock_bh(&csk->lock);
+
+	data_lost = skb_queue_len(&csk->receive_queue);
+	__skb_queue_purge(&csk->receive_queue);
+
+	switch (csk->state) {
+	case CXGBI_CSK_ST_CLOSED:
+	case CXGBI_CSK_ST_ACTIVE_CLOSE:
+	case CXGBI_CSK_ST_CLOSE_WAIT_1:
+	case CXGBI_CSK_ST_CLOSE_WAIT_2:
+	case CXGBI_CSK_ST_ABORTING:
+		break;
+
+	case CXGBI_CSK_ST_CONNECTING:
+		cxgbi_sock_set_flag(csk, CXGBI_CSK_FL_ACTIVE_CLOSE_NEEDED);
+		break;
+	case CXGBI_CSK_ST_ESTABLISHED:
+		close_req = 1;
+		cxgbi_sock_set_flag(csk, CXGBI_CSK_ST_CLOSE_WAIT_2);
+		break;
+	}
+
+	if (close_req) {
+		if (data_lost)
+			cxgb4i_sock_send_abort_req(csk);
+		else
+			cxgb4i_sock_send_close_req(csk);
+	}
+
+	spin_unlock_bh(&csk->lock);
+	cxgbi_sock_put(csk);
+}
+
+void cxgb4i_sock_release(struct cxgbi_sock *csk)
+{
+	cxgbi_conn_debug("csk 0x%p, state %u, flags %lu\n",
+			csk, csk->state, csk->flags);
+
+	if (unlikely(csk->state == CXGBI_CSK_ST_CONNECTING))
+		cxgbi_sock_set_state(csk,
+				CXGBI_CSK_FL_ACTIVE_CLOSE_NEEDED);
+	else if (likely(csk->state != CXGBI_CSK_ST_CLOSED))
+		cxgb4i_sock_active_close(csk);
+
+	cxgbi_sock_put(csk);
+}
+
+static int is_cxgb4_dev(struct net_device *dev, struct cxgb4i_snic *snic)
+{
+	struct net_device *ndev = dev;
+	int i;
+
+	if (dev->priv_flags & IFF_802_1Q_VLAN)
+		ndev = vlan_dev_real_dev(dev);
+
+	for (i = 0; i < snic->lldi.nports; i++) {
+		if (ndev == snic->lldi.ports[i])
+			return 1;
+	}
+
+	return 0;
+}
+
+static struct net_device *cxgb4i_find_egress_dev(struct net_device *root_dev,
+						struct cxgb4i_snic *snic)
+{
+	while (root_dev) {
+		if (root_dev->priv_flags & IFF_802_1Q_VLAN)
+			root_dev = vlan_dev_real_dev(root_dev);
+		else if (is_cxgb4_dev(root_dev, snic))
+			return root_dev;
+		else
+			return NULL;
+	}
+
+	return NULL;
+}
+
+static struct rtable *find_route(struct net_device *dev,
+				__be32 saddr, __be32 daddr,
+				__be16 sport, __be16 dport,
+				u8 tos)
+{
+	struct rtable *rt;
+	struct flowi fl = {
+		.oif = dev ? dev->ifindex : 0,
+		.nl_u = {
+			.ip4_u = {
+				.daddr = daddr,
+				.saddr = saddr,
+				.tos = tos }
+			},
+		.proto = IPPROTO_TCP,
+		.uli_u = {
+			.ports = {
+				.sport = sport,
+				.dport = dport }
+			}
+	};
+
+	if (ip_route_output_flow(dev ? dev_net(dev) : &init_net,
+					&rt, &fl, NULL, 0))
+		return NULL;
+
+	return rt;
+}
+
+static int cxgb4i_init_act_open(struct cxgbi_sock *csk,
+					struct net_device *dev)
+{
+	struct dst_entry *dst = csk->dst;
+	struct sk_buff *skb;
+	struct port_info *pi = netdev_priv(dev);
+
+	cxgbi_conn_debug("csk 0x%p, state %u, flags 0x%lx\n",
+			csk, csk->state, csk->flags);
+
+	csk->atid = cxgb4_alloc_atid(cxgb4i_get_snic(csk->cdev)->lldi.tids,
+					csk);
+	if (csk->atid == -1) {
+		cxgbi_log_error("cannot alloc atid\n");
+		goto out_err;
+	}
+
+	csk->l2t = cxgb4_l2t_get(cxgb4i_get_snic(csk->cdev)->lldi.l2t,
+				csk->dst->neighbour, dev, 0);
+	if (!csk->l2t) {
+		cxgbi_log_error("cannot alloc l2t\n");
+		goto free_atid;
+	}
+
+	skb = alloc_skb(sizeof(struct cpl_act_open_req), GFP_KERNEL);
+	if (!skb)
+		goto free_l2t;
+
+	skb->sk = (struct sock *)csk;
+	t4_set_arp_err_handler(skb, csk, cxgb4i_act_open_req_arp_failure);
+
+	cxgbi_sock_hold(csk);
+
+	csk->wr_max_cred = csk->wr_cred =
+		cxgb4i_get_snic(csk->cdev)->lldi.wr_cred;
+	csk->port_id = pi->port_id;
+	csk->rss_qid = cxgb4i_get_snic(csk->cdev)->lldi.rxq_ids[csk->port_id];
+	csk->tx_chan = pi->tx_chan;
+	csk->smac_idx = csk->tx_chan << 1;
+	csk->wr_una_cred = 0;
+	csk->mss_idx = cxgb4i_select_mss(csk, dst_mtu(dst));
+	csk->err = 0;
+
+	cxgb4i_sock_reset_wr_list(csk);
+
+	cxgb4i_sock_make_act_open_req(csk, skb,
+					((csk->rss_qid << 14) |
+					 (csk->atid)), csk->l2t);
+	cxgb4_l2t_send(cxgb4i_get_snic(csk->cdev)->lldi.ports[csk->port_id],
+					skb, csk->l2t);
+	return 0;
+
+free_l2t:
+	cxgb4_l2t_release(csk->l2t);
+
+free_atid:
+	cxgb4_free_atid(cxgb4i_get_snic(csk->cdev)->lldi.tids, csk->atid);
+
+out_err:
+
+	return -EINVAL;;
+}
+
+static struct net_device *cxgb4i_find_dev(struct net_device *dev,
+							__be32 ipaddr)
+{
+	struct flowi fl;
+	struct rtable *rt;
+	int err;
+
+	memset(&fl, 0, sizeof(fl));
+	fl.nl_u.ip4_u.daddr = ipaddr;
+
+	err = ip_route_output_key(dev ? dev_net(dev) : &init_net, &rt, &fl);
+	if (!err)
+		return (&rt->u.dst)->dev;
+
+	return NULL;
+}
+
+int cxgb4i_sock_connect(struct net_device *dev, struct cxgbi_sock *csk,
+						struct sockaddr_in *sin)
+{
+	struct rtable *rt;
+	__be32 sipv4 = 0;
+	struct net_device *dstdev;
+	struct cxgbi_hba *chba = NULL;
+	int err;
+
+	cxgbi_conn_debug("csk 0x%p, dev 0x%p\n", csk, dev);
+
+	if (sin->sin_family != AF_INET)
+		return -EAFNOSUPPORT;
+
+	csk->daddr.sin_port = sin->sin_port;
+	csk->daddr.sin_addr.s_addr = sin->sin_addr.s_addr;
+
+	dstdev = cxgb4i_find_dev(dev, sin->sin_addr.s_addr);
+	if (!dstdev || !is_cxgb4_dev(dstdev, cxgb4i_get_snic(csk->cdev)))
+		return -ENETUNREACH;
+
+	if (dstdev->priv_flags & IFF_802_1Q_VLAN)
+		dev = dstdev;
+
+	rt = find_route(dev, csk->saddr.sin_addr.s_addr,
+			csk->daddr.sin_addr.s_addr,
+			csk->saddr.sin_port,
+			csk->daddr.sin_port,
+			0);
+	if (rt == NULL) {
+		cxgbi_conn_debug("no route to %pI4, port %u, dev %s, "
+					"snic 0x%p\n",
+					&csk->daddr.sin_addr.s_addr,
+					ntohs(csk->daddr.sin_port),
+					dev ? dev->name : "any",
+					csk->snic);
+		return -ENETUNREACH;
+	}
+
+	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
+		cxgbi_conn_debug("multi-cast route to %pI4, port %u, "
+					"dev %s, snic 0x%p\n",
+					&csk->daddr.sin_addr.s_addr,
+					ntohs(csk->daddr.sin_port),
+					dev ? dev->name : "any",
+					csk->snic);
+		ip_rt_put(rt);
+		return -ENETUNREACH;
+	}
+
+	if (!csk->saddr.sin_addr.s_addr)
+		csk->saddr.sin_addr.s_addr = rt->rt_src;
+
+	csk->dst = &rt->u.dst;
+
+	dev = cxgb4i_find_egress_dev(csk->dst->dev,
+					cxgb4i_get_snic(csk->cdev));
+	if (dev == NULL) {
+		cxgbi_conn_debug("csk: 0x%p, egress dev NULL\n", csk);
+		return -ENETUNREACH;
+	}
+
+	err = cxgbi_sock_get_port(csk);
+	if (err)
+		return err;
+
+	cxgbi_conn_debug("csk: 0x%p get port: %u\n",
+			csk, ntohs(csk->saddr.sin_port));
+
+	chba = cxgb4i_hba_find_by_netdev(csk->dst->dev);
+
+	sipv4 = cxgb4i_get_iscsi_ipv4(chba);
+	if (!sipv4) {
+		cxgbi_conn_debug("csk: 0x%p, iscsi is not configured\n", csk);
+		sipv4 = csk->saddr.sin_addr.s_addr;
+		cxgb4i_set_iscsi_ipv4(chba, sipv4);
+	} else
+		csk->saddr.sin_addr.s_addr = sipv4;
+
+	cxgbi_conn_debug("csk: 0x%p, %pI4:[%u], %pI4:[%u] SYN_SENT\n",
+				csk,
+				&csk->saddr.sin_addr.s_addr,
+				ntohs(csk->saddr.sin_port),
+				&csk->daddr.sin_addr.s_addr,
+				ntohs(csk->daddr.sin_port));
+
+	cxgbi_sock_set_state(csk, CXGBI_CSK_ST_CONNECTING);
+
+	if (!cxgb4i_init_act_open(csk, dev))
+		return 0;
+
+	err = -ENOTSUPP;
+
+	cxgbi_conn_debug("csk 0x%p -> closed\n", csk);
+	cxgbi_sock_set_state(csk, CXGBI_CSK_ST_CLOSED);
+	ip_rt_put(rt);
+	cxgbi_sock_put_port(csk);
+
+	return err;
+}
+
+void cxgb4i_sock_rx_credits(struct cxgbi_sock *csk, int copied)
+{
+	int must_send;
+	u32 credits;
+
+	if (csk->state != CXGBI_CSK_ST_ESTABLISHED)
+		return;
+
+	credits = csk->copied_seq - csk->rcv_wup;
+	if (unlikely(!credits))
+		return;
+
+	if (unlikely(cxgb4i_rx_credit_thres == 0))
+		return;
+
+	must_send = credits + 16384 >= cxgb4i_rcv_win;
+
+	if (must_send || credits >= cxgb4i_rx_credit_thres)
+		csk->rcv_wup += cxgb4i_csk_send_rx_credits(csk, credits);
+}
+
+int cxgb4i_sock_send_pdus(struct cxgbi_sock *csk, struct sk_buff *skb)
+{
+	struct sk_buff *next;
+	int err, copied = 0;
+
+	spin_lock_bh(&csk->lock);
+
+	if (csk->state != CXGBI_CSK_ST_ESTABLISHED) {
+		cxgbi_tx_debug("csk 0x%p, not in est. state %u.\n",
+			      csk, csk->state);
+		err = -EAGAIN;
+		goto out_err;
+	}
+
+	if (csk->err) {
+		cxgbi_tx_debug("csk 0x%p, err %d.\n", csk, csk->err);
+		err = -EPIPE;
+		goto out_err;
+	}
+
+	if (csk->write_seq - csk->snd_una >= cxgb4i_snd_win) {
+		cxgbi_tx_debug("csk 0x%p, snd %u - %u > %u.\n",
+				csk, csk->write_seq, csk->snd_una,
+				cxgb4i_snd_win);
+		err = -ENOBUFS;
+		goto out_err;
+	}
+
+	while (skb) {
+		int frags = skb_shinfo(skb)->nr_frags +
+				(skb->len != skb->data_len);
+
+		if (unlikely(skb_headroom(skb) < CXGB4I_TX_HEADER_LEN)) {
+			cxgbi_tx_debug("csk 0x%p, skb head.\n", csk);
+			err = -EINVAL;
+			goto out_err;
+		}
+
+		if (frags >= SKB_WR_LIST_SIZE) {
+			cxgbi_log_error("csk 0x%p, tx frags %d, len %u,%u.\n",
+					 csk, skb_shinfo(skb)->nr_frags,
+					 skb->len, skb->data_len);
+			err = -EINVAL;
+			goto out_err;
+		}
+
+		next = skb->next;
+		skb->next = NULL;
+		cxgb4i_sock_skb_entail(csk, skb,
+				CXGB4I_SKCB_FLAG_NO_APPEND |
+				CXGB4I_SKCB_FLAG_NEED_HDR);
+		copied += skb->len;
+		csk->write_seq += skb->len + ulp_extra_len(skb);
+		skb = next;
+	}
+done:
+	if (likely(skb_queue_len(&csk->write_queue)))
+		cxgb4i_sock_push_tx_frames(csk, 1);
+	spin_unlock_bh(&csk->lock);
+	return copied;
+
+out_err:
+	if (copied == 0 && err == -EPIPE)
+		copied = csk->err ? csk->err : -EPIPE;
+	else
+		copied = err;
+	goto done;
+}
+
+static void cxgbi_sock_conn_closing(struct cxgbi_sock *csk)
+{
+	struct iscsi_conn *conn = csk->user_data;
+
+	read_lock(&csk->callback_lock);
+	if (conn && csk->state != CXGBI_CSK_ST_ESTABLISHED)
+		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
+	read_unlock(&csk->callback_lock);
+}
+
+static void tx_skb_setmode(struct sk_buff *skb, int hcrc, int dcrc)
+{
+	u8 submode = 0;
+
+	if (hcrc)
+		submode |= 1;
+	if (dcrc)
+		submode |= 2;
+	cxgb4i_skb_ulp_mode(skb) = (ULP_MODE_ISCSI << 4) | submode;
+}
+
+static inline __u16 get_skb_ulp_mode(struct sk_buff *skb)
+{
+	return cxgb4i_skb_ulp_mode(skb);
+}
+
+static cxgb4i_cplhandler_func cxgb4i_cplhandlers[NUM_CPL_CMDS] = {
+	[CPL_ACT_ESTABLISH] = cxgb4i_cpl_act_establish,
+	[CPL_ACT_OPEN_RPL] = cxgb4i_cpl_act_open_rpl,
+	[CPL_PEER_CLOSE] = cxgb4i_cpl_peer_close,
+	[CPL_ABORT_REQ_RSS] = cxgb4i_cpl_abort_req_rss,
+	[CPL_ABORT_RPL_RSS] = cxgb4i_cpl_abort_rpl_rss,
+	[CPL_CLOSE_CON_RPL] = cxgb4i_cpl_close_con_rpl,
+	[CPL_FW4_ACK] = cxgb4i_cpl_fw4_ack,
+	[CPL_ISCSI_HDR] = cxgb4i_cpl_iscsi_hdr,
+	[CPL_SET_TCB_RPL] = cxgb4i_cpl_set_tcb_rpl,
+	[CPL_RX_DATA_DDP] = cxgb4i_cpl_rx_data_ddp
+};
+
+int cxgb4i_ofld_init(struct cxgb4i_snic *snic)
+{
+	struct cxgbi_ports_map *ports;
+	int mapsize;
+
+	if (cxgb4i_max_connect > CXGB4I_MAX_CONN)
+		cxgb4i_max_connect = CXGB4I_MAX_CONN;
+
+	mapsize = (cxgb4i_max_connect * sizeof(struct cxgbi_sock));
+	ports = cxgbi_alloc_big_mem(sizeof(*ports) + mapsize, GFP_KERNEL);
+	if (!ports)
+		return -ENOMEM;
+
+	spin_lock_init(&ports->lock);
+	snic->cdev.pmap = ports;
+	snic->cdev.pmap->max_connect = cxgb4i_max_connect;
+	snic->cdev.pmap->sport_base = cxgb4i_sport_base;
+
+	snic->cdev.tx_skb_setmode = tx_skb_setmode;
+	snic->cdev.sock_send_pdus = cxgb4i_sock_send_pdus;
+	snic->cdev.get_skb_ulp_mode = get_skb_ulp_mode;
+
+	snic->handlers = cxgb4i_cplhandlers;
+
+	return 0;
+}
+
+void cxgb4i_ofld_cleanup(struct cxgb4i_snic *snic)
+{
+	struct cxgbi_sock *csk;
+	int i;
+
+	for (i = 0; i < snic->cdev.pmap->max_connect; i++) {
+		if (snic->cdev.pmap->port_csk[i]) {
+			csk = snic->cdev.pmap->port_csk[i];
+			snic->cdev.pmap->port_csk[i] = NULL;
+
+			spin_lock_bh(&csk->lock);
+			cxgb4i_sock_closed(csk);
+			spin_unlock_bh(&csk->lock);
+		}
+	}
+	cxgbi_free_big_mem(snic->cdev.pmap);
+}
+
diff --git a/drivers/scsi/cxgb4i/cxgb4i_offload.h b/drivers/scsi/cxgb4i/cxgb4i_offload.h
new file mode 100644
index 0000000..afd50d9
--- /dev/null
+++ b/drivers/scsi/cxgb4i/cxgb4i_offload.h
@@ -0,0 +1,91 @@
+/*
+ * cxgb4i_offload.h: Chelsio T4 iSCSI driver.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#ifndef	__CXGB4I_OFFLOAD_H__
+#define	__CXGB4I_OFFLOAD_H__
+
+#include <linux/skbuff.h>
+#include <linux/in.h>
+
+#include "libcxgbi.h"
+
+#define	CXGB4I_MAX_CONN	16384
+
+enum {
+	CPL_RET_BUF_DONE = 1,
+	CPL_RET_BAD_MSG = 2,
+	CPL_RET_UNKNOWN_TID = 4
+};
+
+struct cxgbi_sock *cxgb4i_sock_create(struct cxgb4i_snic *);
+void cxgb4i_sock_release(struct cxgbi_sock *);
+int cxgb4i_sock_connect(struct net_device *, struct cxgbi_sock *,
+			struct sockaddr_in *);
+void cxgb4i_sock_rx_credits(struct cxgbi_sock *, int);
+int cxgb4i_sock_send_pdus(struct cxgbi_sock *, struct sk_buff *);
+
+struct cxgb4i_skb_rx_cb {
+	__u32 ddigest;
+	__u32 pdulen;
+};
+
+struct cxgb4i_skb_tx_cb {
+	struct l2t_skb_cb l2t;
+	struct sk_buff *wr_next;
+};
+
+struct cxgb4i_skb_cb {
+	__u16 flags;
+	__u16 ulp_mode;
+	__u32 seq;
+
+	union {
+		struct cxgb4i_skb_rx_cb rx;
+		struct cxgb4i_skb_tx_cb tx;
+	};
+};
+
+#define CXGB4I_SKB_CB(skb)	((struct cxgb4i_skb_cb *)&((skb)->cb[0]))
+#define cxgb4i_skb_flags(skb)	(CXGB4I_SKB_CB(skb)->flags)
+#define cxgb4i_skb_ulp_mode(skb)	(CXGB4I_SKB_CB(skb)->ulp_mode)
+#define cxgb4i_skb_tcp_seq(skb)		(CXGB4I_SKB_CB(skb)->seq)
+#define cxgb4i_skb_rx_ddigest(skb)	(CXGB4I_SKB_CB(skb)->rx.ddigest)
+#define cxgb4i_skb_rx_pdulen(skb)	(CXGB4I_SKB_CB(skb)->rx.pdulen)
+#define cxgb4i_skb_tx_wr_next(skb)	(CXGB4I_SKB_CB(skb)->tx.wr_next)
+
+enum cxgb4i_skcb_flags {
+	CXGB4I_SKCB_FLAG_NEED_HDR = 1 << 0,	/* packet needs a header */
+	CXGB4I_SKCB_FLAG_NO_APPEND = 1 << 1,	/* don't grow this skb */
+	CXGB4I_SKCB_FLAG_COMPL = 1 << 2,	/* request WR completion */
+	CXGB4I_SKCB_FLAG_HDR_RCVD = 1 << 3,	/* recieved header pdu */
+	CXGB4I_SKCB_FLAG_DATA_RCVD = 1 << 4,	/*  recieved data pdu */
+	CXGB4I_SKCB_FLAG_STATUS_RCVD = 1 << 5,	/* recieved ddp status */
+};
+
+/*
+ * sge_opaque_hdr -
+ * Opaque version of structure the SGE stores at skb->head of TX_DATA packets
+ * and for which we must reserve space.
+ */
+struct sge_opaque_hdr {
+	void *dev;
+	dma_addr_t addr[MAX_SKB_FRAGS + 1];
+};
+
+/* for TX: a skb must have a headroom of at least TX_HEADER_LEN bytes */
+#define CXGB4I_TX_HEADER_LEN \
+	(sizeof(struct fw_ofld_tx_data_wr) + sizeof(struct sge_opaque_hdr))
+#define SKB_TX_HEADROOM	SKB_MAX_HEAD(CXGB4I_TX_HEADER_LEN)
+
+#endif	/* __CXGB4I_OFFLOAD_H__ */
+
diff --git a/drivers/scsi/cxgb4i/cxgb4i_snic.c b/drivers/scsi/cxgb4i/cxgb4i_snic.c
new file mode 100644
index 0000000..68cdae5
--- /dev/null
+++ b/drivers/scsi/cxgb4i/cxgb4i_snic.c
@@ -0,0 +1,260 @@
+/*
+ * cxgb4i_snic.c: Chelsio T4 iSCSI driver.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ * Written by: Rakesh Ranjan (rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org)
+ */
+
+#include <net/route.h>
+
+#include "cxgb4i.h"
+
+#define	DRV_MODULE_NAME		"cxgb4i"
+#define	DRV_MODULE_VERSION	"0.90"
+#define	DRV_MODULE_RELDATE	"04/08/2010"
+
+static char version[] =
+	"Chelsio T4 iSCSI driver " DRV_MODULE_NAME
+	" v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
+
+MODULE_AUTHOR("Chelsio Communications");
+MODULE_DESCRIPTION("Chelsio T4 iSCSI driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_MODULE_VERSION);
+
+static LIST_HEAD(snic_list);
+static DEFINE_MUTEX(snic_rwlock);
+
+static void *cxgb4i_uld_add(const struct cxgb4_lld_info *linfo);
+static int cxgb4i_uld_rx_handler(void *handle, const __be64 *rsp,
+				const struct pkt_gl *pgl);
+static int cxgb4i_uld_state_change(void *handle, enum cxgb4_state state);
+
+static struct cxgb4i_snic *cxgb4i_snic_init(const struct cxgb4_lld_info *);
+static void cxgb4i_snic_cleanup(void);
+
+
+static struct cxgb4_uld_info cxgb4i_uld_info = {
+	.name = "cxgb4i",
+	.add = cxgb4i_uld_add,
+	.rx_handler = cxgb4i_uld_rx_handler,
+	.state_change = cxgb4i_uld_state_change,
+};
+
+
+struct cxgbi_hba *cxgb4i_hba_find_by_netdev(struct net_device *dev)
+{
+	int i;
+	struct cxgb4i_snic *snic = NULL;;
+
+	if (dev->priv_flags & IFF_802_1Q_VLAN)
+		dev = vlan_dev_real_dev(dev);
+
+	mutex_lock(&snic_rwlock);
+	list_for_each_entry(snic, &snic_list, list_head) {
+		for (i = 0; i < snic->hba_cnt; i++) {
+			if (snic->hba[i]->ndev == dev) {
+				mutex_unlock(&snic_rwlock);
+				return snic->hba[i];
+			}
+		}
+	}
+	mutex_unlock(&snic_rwlock);
+	return NULL;
+}
+
+struct cxgb4i_snic *cxgb4i_find_snic(struct net_device *dev, __be32 ipaddr)
+{
+	struct flowi fl;
+	struct rtable *rt;
+	struct net_device *sdev = NULL;
+	struct cxgb4i_snic *snic = NULL, *tmp;
+	int err, i;
+
+	memset(&fl, 0, sizeof(fl));
+	fl.nl_u.ip4_u.daddr = ipaddr;
+
+	err = ip_route_output_key(dev ? dev_net(dev) : &init_net, &rt, &fl);
+	if (err)
+		goto out;
+
+	sdev = (&rt->u.dst)->dev;
+	mutex_lock(&snic_rwlock);
+	list_for_each_entry_safe(snic, tmp, &snic_list, list_head) {
+		if (snic) {
+			for (i = 0; i < snic->lldi.nports; i++) {
+				if (sdev == snic->lldi.ports[i]) {
+					mutex_unlock(&snic_rwlock);
+					return snic;
+				}
+			}
+		}
+	}
+	mutex_unlock(&snic_rwlock);
+
+out:
+	snic = NULL;
+	return snic;
+}
+
+void cxgb4i_snic_add(struct list_head *list_head)
+{
+	mutex_lock(&snic_rwlock);
+	list_add_tail(list_head, &snic_list);
+	mutex_unlock(&snic_rwlock);
+}
+
+struct cxgb4i_snic *cxgb4i_snic_init(const struct cxgb4_lld_info *linfo)
+{
+	struct cxgb4i_snic *snic;
+	int i;
+
+	snic = kzalloc(sizeof(*snic), GFP_KERNEL);
+	if (snic) {
+
+		spin_lock_init(&snic->lock);
+		snic->lldi = *linfo;
+		snic->hba_cnt = snic->lldi.nports;
+		snic->cdev.dd_data = snic;
+		snic->cdev.pdev = snic->lldi.pdev;
+		snic->cdev.skb_tx_headroom = SKB_MAX_HEAD(CXGB4I_TX_HEADER_LEN);
+
+		cxgb4i_iscsi_init();
+		cxgbi_pdu_init(&snic->cdev);
+		cxgb4i_ddp_init(snic);
+		cxgb4i_ofld_init(snic);
+
+		for (i = 0; i < snic->hba_cnt; i++) {
+			snic->hba[i] = cxgb4i_hba_add(snic,
+						snic->lldi.ports[i]);
+			if (!snic->hba[i]) {
+				kfree(snic);
+				snic = ERR_PTR(-ENOMEM);
+				goto out;
+			}
+		}
+		cxgb4i_snic_add(&snic->list_head);
+	} else
+out :
+	snic = ERR_PTR(-ENOMEM);
+
+	return snic;
+}
+
+void cxgb4i_snic_cleanup(void)
+{
+	struct cxgb4i_snic *snic, *tmp;
+	int i;
+
+	mutex_lock(&snic_rwlock);
+	list_for_each_entry_safe(snic, tmp, &snic_list, list_head) {
+		list_del(&snic->list_head);
+
+		for (i = 0; i < snic->hba_cnt; i++) {
+			if (snic->hba[i]) {
+				cxgb4i_hba_remove(snic->hba[i]);
+				snic->hba[i] = NULL;
+			}
+		}
+		cxgb4i_ofld_cleanup(snic);
+		cxgb4i_ddp_cleanup(snic);
+		cxgbi_pdu_cleanup(&snic->cdev);
+		cxgbi_log_info("snic 0x%p, %u scsi hosts removed.\n",
+				snic, snic->hba_cnt);
+
+		kfree(snic);
+	}
+	mutex_unlock(&snic_rwlock);
+	cxgb4i_iscsi_cleanup();
+}
+
+static void *cxgb4i_uld_add(const struct cxgb4_lld_info *linfo)
+{
+	struct cxgb4i_snic *snic;
+
+	cxgbi_log_info("%s", version);
+
+	snic = cxgb4i_snic_init(linfo);
+	if (!snic)
+		goto out;
+out:
+	return snic;
+}
+
+static int cxgb4i_uld_rx_handler(void *handle, const __be64 *rsp,
+				const struct pkt_gl *pgl)
+{
+	struct cxgb4i_snic *snic = handle;
+	struct sk_buff *skb;
+	const struct cpl_act_establish *rpl;
+	unsigned int opcode;
+
+	if (pgl == NULL) {
+		unsigned int len = 64 - sizeof(struct rsp_ctrl) - 8;
+
+		skb = alloc_skb(256, GFP_ATOMIC);
+		if (!skb)
+			goto nomem;
+		__skb_put(skb, len);
+		skb_copy_to_linear_data(skb, &rsp[1], len);
+
+	} else if (pgl == CXGB4_MSG_AN) {
+
+		return 0;
+
+	} else {
+
+		skb = cxgb4_pktgl_to_skb(pgl, 256, 256);
+		if (unlikely(!skb))
+			goto nomem;
+	}
+
+	rpl = cplhdr(skb);
+	opcode = rpl->ot.opcode;
+
+	cxgbi_api_debug("snic %p, opcode 0x%x, skb %p\n",
+			 snic, opcode, skb);
+
+	BUG_ON(!snic->handlers[opcode]);
+
+	if (snic->handlers[opcode]) {
+		snic->handlers[opcode](snic, skb);
+	} else
+		cxgbi_log_error("No handler for opcode 0x%x\n",
+				opcode);
+
+	return 0;
+
+nomem:
+	cxgbi_api_debug("OOM bailing out\n");
+	return 1;
+}
+
+static int cxgb4i_uld_state_change(void *handle, enum cxgb4_state state)
+{
+	return 0;
+}
+
+static int __init cxgb4i_init_module(void)
+{
+	cxgb4_register_uld(CXGB4_ULD_ISCSI, &cxgb4i_uld_info);
+
+	return 0;
+}
+
+static void __exit cxgb4i_exit_module(void)
+{
+
+	cxgb4_unregister_uld(CXGB4_ULD_ISCSI);
+	cxgb4i_snic_cleanup();
+}
+
+module_init(cxgb4i_init_module);
+module_exit(cxgb4i_exit_module);
+
-- 
1.6.6.1

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
