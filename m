From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH net-2.6.24] cxgb3 sparse warning fixes
Date: Mon, 8 Oct 2007 16:22:29 -0700
Message-ID: <20071008162229.65237a88@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52892 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751300AbXJHXXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 19:23:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix warnings from sparse related to shadowed variables and routines
that should be declared static.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
  CHECK   drivers/net/cxgb3/cxgb3_main.c
drivers/net/cxgb3/cxgb3_main.c:1773:20: warning: symbol 'pi' shadows an earlier one
drivers/net/cxgb3/cxgb3_main.c:1664:19: originally declared here
drivers/net/cxgb3/cxgb3_main.c:1805:20: warning: symbol 'pi' shadows an earlier one
drivers/net/cxgb3/cxgb3_main.c:1664:19: originally declared here
drivers/net/cxgb3/cxgb3_main.c:743:5: warning: symbol 'update_tpsram' was not declared. Should it be static?
  CHECK   drivers/net/cxgb3/t3_hw.c
drivers/net/cxgb3/t3_hw.c:122:6: warning: symbol 't3_read_indirect' was not declared. Should it be static?
drivers/net/cxgb3/t3_hw.c:3410:5: warning: symbol 't3_reset_adapter' was not declared. Should it be static?
  CHECK   drivers/net/cxgb3/xgmac.c
drivers/net/cxgb3/xgmac.c:145:5: warning: symbol 't3b2_mac_reset' was not declared. Should it be static?
  CHECK   drivers/net/cxgb3/sge.c
include/linux/mm.h:587:9: warning: potentially expensive pointer subtraction
drivers/net/cxgb3/sge.c:547:6: warning: symbol 't3_free_qset' was not declared. Should it be static?
include/linux/mm.h:587:9: warning: potentially expensive pointer subtraction
include/linux/mm.h:587:9: warning: potentially expensive pointer subtraction
drivers/net/cxgb3/sge.c:2218:13: warning: symbol 't3_sge_intr_msix_napi' was not declared. Should it be static?
drivers/net/cxgb3/sge.c:2287:13: warning: symbol 't3_intr_msi_napi' was not declared. Should it be static?
  CHECK   drivers/net/cxgb3/cxgb3_offload.c
drivers/net/cxgb3/cxgb3_offload.c:226:20: warning: symbol 'req' shadows an earlier one
drivers/net/cxgb3/cxgb3_offload.c:220:64: originally declared here
drivers/net/cxgb3/cxgb3_offload.c:245:21: warning: symbol 'req' shadows an earlier one
drivers/net/cxgb3/cxgb3_offload.c:220:64: originally declared here
drivers/net/cxgb3/cxgb3_offload.c:277:24: warning: symbol 'req' shadows an earlier one
drivers/net/cxgb3/cxgb3_offload.c:220:64: originally declared here
drivers/net/cxgb3/cxgb3_offload.c:295:28: warning: symbol 'req' shadows an earlier one
drivers/net/cxgb3/cxgb3_offload.c:220:64: originally declared here


 drivers/net/cxgb3/cxgb3_main.c    |    4 ---
 drivers/net/cxgb3/cxgb3_offload.c |   44 +++++++++++++++++++-------------------
 drivers/net/cxgb3/sge.c           |    6 ++---
 drivers/net/cxgb3/t3_hw.c         |    8 +++---
 drivers/net/cxgb3/xgmac.c         |    2 -
 5 files changed, 31 insertions(+), 33 deletions(-)

--- a/drivers/net/cxgb3/cxgb3_main.c	2007-10-08 15:34:39.000000000 -0700
+++ b/drivers/net/cxgb3/cxgb3_main.c	2007-10-08 16:10:45.000000000 -0700
@@ -740,7 +740,7 @@ static inline char t3rev2char(struct ada
 	return rev;
 }
 
-int update_tpsram(struct adapter *adap)
+static int update_tpsram(struct adapter *adap)
 {
 	const struct firmware *tpsram;
 	char buf[64];
@@ -1770,7 +1770,6 @@ static int cxgb_extension_ioctl(struct n
 	}
 	case CHELSIO_SET_QSET_NUM:{
 		struct ch_reg edata;
-		struct port_info *pi = netdev_priv(dev);
 		unsigned int i, first_qset = 0, other_qsets = 0;
 
 		if (!capable(CAP_NET_ADMIN))
@@ -1802,7 +1801,6 @@ static int cxgb_extension_ioctl(struct n
 	}
 	case CHELSIO_GET_QSET_NUM:{
 		struct ch_reg edata;
-		struct port_info *pi = netdev_priv(dev);
 
 		edata.cmd = CHELSIO_GET_QSET_NUM;
 		edata.val = pi->nqsets;
--- a/drivers/net/cxgb3/cxgb3_offload.c	2007-10-04 09:33:28.000000000 -0700
+++ b/drivers/net/cxgb3/cxgb3_offload.c	2007-10-08 16:13:03.000000000 -0700
@@ -222,32 +222,32 @@ static int cxgb_rdma_ctl(struct adapter 
 	int ret = 0;
 
 	switch (req) {
-	case RDMA_GET_PARAMS:{
-		struct rdma_info *req = data;
+	case RDMA_GET_PARAMS: {
+		struct rdma_info *rdma = data;
 		struct pci_dev *pdev = adapter->pdev;
 
-		req->udbell_physbase = pci_resource_start(pdev, 2);
-		req->udbell_len = pci_resource_len(pdev, 2);
-		req->tpt_base =
+		rdma->udbell_physbase = pci_resource_start(pdev, 2);
+		rdma->udbell_len = pci_resource_len(pdev, 2);
+		rdma->tpt_base =
 			t3_read_reg(adapter, A_ULPTX_TPT_LLIMIT);
-		req->tpt_top = t3_read_reg(adapter, A_ULPTX_TPT_ULIMIT);
-		req->pbl_base =
+		rdma->tpt_top = t3_read_reg(adapter, A_ULPTX_TPT_ULIMIT);
+		rdma->pbl_base =
 			t3_read_reg(adapter, A_ULPTX_PBL_LLIMIT);
-		req->pbl_top = t3_read_reg(adapter, A_ULPTX_PBL_ULIMIT);
-		req->rqt_base = t3_read_reg(adapter, A_ULPRX_RQ_LLIMIT);
-		req->rqt_top = t3_read_reg(adapter, A_ULPRX_RQ_ULIMIT);
-		req->kdb_addr = adapter->regs + A_SG_KDOORBELL;
-		req->pdev = pdev;
+		rdma->pbl_top = t3_read_reg(adapter, A_ULPTX_PBL_ULIMIT);
+		rdma->rqt_base = t3_read_reg(adapter, A_ULPRX_RQ_LLIMIT);
+		rdma->rqt_top = t3_read_reg(adapter, A_ULPRX_RQ_ULIMIT);
+		rdma->kdb_addr = adapter->regs + A_SG_KDOORBELL;
+		rdma->pdev = pdev;
 		break;
 	}
 	case RDMA_CQ_OP:{
 		unsigned long flags;
-		struct rdma_cq_op *req = data;
+		struct rdma_cq_op *rdma = data;
 
 		/* may be called in any context */
 		spin_lock_irqsave(&adapter->sge.reg_lock, flags);
-		ret = t3_sge_cqcntxt_op(adapter, req->id, req->op,
-					req->credits);
+		ret = t3_sge_cqcntxt_op(adapter, rdma->id, rdma->op,
+					rdma->credits);
 		spin_unlock_irqrestore(&adapter->sge.reg_lock, flags);
 		break;
 	}
@@ -274,15 +274,15 @@ static int cxgb_rdma_ctl(struct adapter 
 		break;
 	}
 	case RDMA_CQ_SETUP:{
-		struct rdma_cq_setup *req = data;
+		struct rdma_cq_setup *rdma = data;
 
 		spin_lock_irq(&adapter->sge.reg_lock);
 		ret =
-			t3_sge_init_cqcntxt(adapter, req->id,
-					req->base_addr, req->size,
+			t3_sge_init_cqcntxt(adapter, rdma->id,
+					rdma->base_addr, rdma->size,
 					ASYNC_NOTIF_RSPQ,
-					req->ovfl_mode, req->credits,
-					req->credit_thres);
+					rdma->ovfl_mode, rdma->credits,
+					rdma->credit_thres);
 		spin_unlock_irq(&adapter->sge.reg_lock);
 		break;
 	}
@@ -292,13 +292,13 @@ static int cxgb_rdma_ctl(struct adapter 
 		spin_unlock_irq(&adapter->sge.reg_lock);
 		break;
 	case RDMA_CTRL_QP_SETUP:{
-		struct rdma_ctrlqp_setup *req = data;
+		struct rdma_ctrlqp_setup *rdma = data;
 
 		spin_lock_irq(&adapter->sge.reg_lock);
 		ret = t3_sge_init_ecntxt(adapter, FW_RI_SGEEC_START, 0,
 						SGE_CNTXT_RDMA,
 						ASYNC_NOTIF_RSPQ,
-						req->base_addr, req->size,
+						rdma->base_addr, rdma->size,
 						FW_RI_TID_START, 1, 0);
 		spin_unlock_irq(&adapter->sge.reg_lock);
 		break;
--- a/drivers/net/cxgb3/sge.c	2007-10-08 15:35:18.000000000 -0700
+++ b/drivers/net/cxgb3/sge.c	2007-10-08 16:11:57.000000000 -0700
@@ -544,7 +544,7 @@ static void *alloc_ring(struct pci_dev *
  *	as HW contexts, packet buffers, and descriptor rings.  Traffic to the
  *	queue set must be quiesced prior to calling this.
  */
-void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
+static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 {
 	int i;
 	struct pci_dev *pdev = adapter->pdev;
@@ -2215,7 +2215,7 @@ irqreturn_t t3_sge_intr_msix(int irq, vo
  * The MSI-X interrupt handler for an SGE response queue for the NAPI case
  * (i.e., response queue serviced by NAPI polling).
  */
-irqreturn_t t3_sge_intr_msix_napi(int irq, void *cookie)
+static irqreturn_t t3_sge_intr_msix_napi(int irq, void *cookie)
 {
 	struct sge_qset *qs = cookie;
 	struct sge_rspq *q = &qs->rspq;
@@ -2284,7 +2284,7 @@ static int rspq_check_napi(struct sge_qs
  * one SGE response queue per port in this mode and protect all response
  * queues with queue 0's lock.
  */
-irqreturn_t t3_intr_msi_napi(int irq, void *cookie)
+static irqreturn_t t3_intr_msi_napi(int irq, void *cookie)
 {
 	int new_packets;
 	struct adapter *adap = cookie;
--- a/drivers/net/cxgb3/t3_hw.c	2007-10-04 09:33:28.000000000 -0700
+++ b/drivers/net/cxgb3/t3_hw.c	2007-10-08 16:11:24.000000000 -0700
@@ -119,9 +119,9 @@ void t3_set_reg_field(struct adapter *ad
  *	Reads registers that are accessed indirectly through an address/data
  *	register pair.
  */
-void t3_read_indirect(struct adapter *adap, unsigned int addr_reg,
-		      unsigned int data_reg, u32 *vals, unsigned int nregs,
-		      unsigned int start_idx)
+static void t3_read_indirect(struct adapter *adap, unsigned int addr_reg,
+			     unsigned int data_reg, u32 *vals,
+			     unsigned int nregs, unsigned int start_idx)
 {
 	while (nregs--) {
 		t3_write_reg(adap, addr_reg, start_idx);
@@ -3407,7 +3407,7 @@ void early_hw_init(struct adapter *adapt
  * Older PCIe cards lose their config space during reset, PCI-X
  * ones don't.
  */
-int t3_reset_adapter(struct adapter *adapter)
+static int t3_reset_adapter(struct adapter *adapter)
 {
 	int i, save_and_restore_pcie = 
 	    adapter->params.rev < T3_REV_B2 && is_pcie(adapter);
--- a/drivers/net/cxgb3/xgmac.c	2007-10-04 09:33:28.000000000 -0700
+++ b/drivers/net/cxgb3/xgmac.c	2007-10-08 16:11:34.000000000 -0700
@@ -142,7 +142,7 @@ int t3_mac_reset(struct cmac *mac)
 	return 0;
 }
 
-int t3b2_mac_reset(struct cmac *mac)
+static int t3b2_mac_reset(struct cmac *mac)
 {
 	struct adapter *adap = mac->adapter;
 	unsigned int oft = mac->offset;
