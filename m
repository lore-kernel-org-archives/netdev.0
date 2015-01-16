From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH for-next 1/2] iw_cxgb4: Cleanup register defines/MACROS defined in t4.h
Date: Fri, 16 Jan 2015 09:24:47 +0530
Message-ID: <1421380488-1111-2-git-send-email-hariprasad@chelsio.com>
References: <1421380488-1111-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, praveenm@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14006 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932622AbbAPDtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 22:49:17 -0500
In-Reply-To: <1421380488-1111-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup all the MACROS defined in t4.h and the affected files

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cq.c |   38 ++++++++--------
 drivers/infiniband/hw/cxgb4/qp.c |    2 +-
 drivers/infiniband/hw/cxgb4/t4.h |   90 +++++++++++++++++++-------------------
 3 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index e9fd3a0..39b0da3 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -182,12 +182,12 @@ static void insert_recv_cqe(struct t4_wq *wq, struct t4_cq *cq)
 	PDBG("%s wq %p cq %p sw_cidx %u sw_pidx %u\n", __func__,
 	     wq, cq, cq->sw_cidx, cq->sw_pidx);
 	memset(&cqe, 0, sizeof(cqe));
-	cqe.header = cpu_to_be32(V_CQE_STATUS(T4_ERR_SWFLUSH) |
-				 V_CQE_OPCODE(FW_RI_SEND) |
-				 V_CQE_TYPE(0) |
-				 V_CQE_SWCQE(1) |
-				 V_CQE_QPID(wq->sq.qid));
-	cqe.bits_type_ts = cpu_to_be64(V_CQE_GENBIT((u64)cq->gen));
+	cqe.header = cpu_to_be32(CQE_STATUS_V(T4_ERR_SWFLUSH) |
+				 CQE_OPCODE_V(FW_RI_SEND) |
+				 CQE_TYPE_V(0) |
+				 CQE_SWCQE_V(1) |
+				 CQE_QPID_V(wq->sq.qid));
+	cqe.bits_type_ts = cpu_to_be64(CQE_GENBIT_V((u64)cq->gen));
 	cq->sw_queue[cq->sw_pidx] = cqe;
 	t4_swcq_produce(cq);
 }
@@ -215,13 +215,13 @@ static void insert_sq_cqe(struct t4_wq *wq, struct t4_cq *cq,
 	PDBG("%s wq %p cq %p sw_cidx %u sw_pidx %u\n", __func__,
 	     wq, cq, cq->sw_cidx, cq->sw_pidx);
 	memset(&cqe, 0, sizeof(cqe));
-	cqe.header = cpu_to_be32(V_CQE_STATUS(T4_ERR_SWFLUSH) |
-				 V_CQE_OPCODE(swcqe->opcode) |
-				 V_CQE_TYPE(1) |
-				 V_CQE_SWCQE(1) |
-				 V_CQE_QPID(wq->sq.qid));
+	cqe.header = cpu_to_be32(CQE_STATUS_V(T4_ERR_SWFLUSH) |
+				 CQE_OPCODE_V(swcqe->opcode) |
+				 CQE_TYPE_V(1) |
+				 CQE_SWCQE_V(1) |
+				 CQE_QPID_V(wq->sq.qid));
 	CQE_WRID_SQ_IDX(&cqe) = swcqe->idx;
-	cqe.bits_type_ts = cpu_to_be64(V_CQE_GENBIT((u64)cq->gen));
+	cqe.bits_type_ts = cpu_to_be64(CQE_GENBIT_V((u64)cq->gen));
 	cq->sw_queue[cq->sw_pidx] = cqe;
 	t4_swcq_produce(cq);
 }
@@ -284,7 +284,7 @@ static void flush_completed_wrs(struct t4_wq *wq, struct t4_cq *cq)
 			 */
 			PDBG("%s moving cqe into swcq sq idx %u cq idx %u\n",
 					__func__, cidx, cq->sw_pidx);
-			swsqe->cqe.header |= htonl(V_CQE_SWCQE(1));
+			swsqe->cqe.header |= htonl(CQE_SWCQE_V(1));
 			cq->sw_queue[cq->sw_pidx] = swsqe->cqe;
 			t4_swcq_produce(cq);
 			swsqe->flushed = 1;
@@ -301,10 +301,10 @@ static void create_read_req_cqe(struct t4_wq *wq, struct t4_cqe *hw_cqe,
 {
 	read_cqe->u.scqe.cidx = wq->sq.oldest_read->idx;
 	read_cqe->len = htonl(wq->sq.oldest_read->read_len);
-	read_cqe->header = htonl(V_CQE_QPID(CQE_QPID(hw_cqe)) |
-			V_CQE_SWCQE(SW_CQE(hw_cqe)) |
-			V_CQE_OPCODE(FW_RI_READ_REQ) |
-			V_CQE_TYPE(1));
+	read_cqe->header = htonl(CQE_QPID_V(CQE_QPID(hw_cqe)) |
+			CQE_SWCQE_V(SW_CQE(hw_cqe)) |
+			CQE_OPCODE_V(FW_RI_READ_REQ) |
+			CQE_TYPE_V(1));
 	read_cqe->bits_type_ts = hw_cqe->bits_type_ts;
 }
 
@@ -400,7 +400,7 @@ void c4iw_flush_hw_cq(struct c4iw_cq *chp)
 		} else {
 			swcqe = &chp->cq.sw_queue[chp->cq.sw_pidx];
 			*swcqe = *hw_cqe;
-			swcqe->header |= cpu_to_be32(V_CQE_SWCQE(1));
+			swcqe->header |= cpu_to_be32(CQE_SWCQE_V(1));
 			t4_swcq_produce(&chp->cq);
 		}
 next_cqe:
@@ -576,7 +576,7 @@ static int poll_cq(struct t4_wq *wq, struct t4_cq *cq, struct t4_cqe *cqe,
 		}
 		if (unlikely((CQE_WRID_MSN(hw_cqe) != (wq->rq.msn)))) {
 			t4_set_wq_in_error(wq);
-			hw_cqe->header |= htonl(V_CQE_STATUS(T4_ERR_MSN));
+			hw_cqe->header |= htonl(CQE_STATUS_V(T4_ERR_MSN));
 			goto proc_cqe;
 		}
 		goto proc_cqe;
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index bb85d47..42238ed 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -1776,7 +1776,7 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 		if (mm5) {
 			mm5->key = uresp.ma_sync_key;
 			mm5->addr = (pci_resource_start(rhp->rdev.lldi.pdev, 0)
-				    + A_PCIE_MA_SYNC) & PAGE_MASK;
+				    + PCIE_MA_SYNC_A) & PAGE_MASK;
 			mm5->len = PAGE_SIZE;
 			insert_mmap(ucontext, mm5);
 		}
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index 29e764e..871cdca 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -41,7 +41,7 @@
 #define T4_PAGESIZE_MASK 0xffff000  /* 4KB-128MB */
 #define T4_STAG_UNSET 0xffffffff
 #define T4_FW_MAJ 0
-#define A_PCIE_MA_SYNC 0x30b4
+#define PCIE_MA_SYNC_A 0x30b4
 
 struct t4_status_page {
 	__be32 rsvd1;	/* flit 0 - hw owns */
@@ -184,44 +184,44 @@ struct t4_cqe {
 
 /* macros for flit 0 of the cqe */
 
-#define S_CQE_QPID        12
-#define M_CQE_QPID        0xFFFFF
-#define G_CQE_QPID(x)     ((((x) >> S_CQE_QPID)) & M_CQE_QPID)
-#define V_CQE_QPID(x)	  ((x)<<S_CQE_QPID)
-
-#define S_CQE_SWCQE       11
-#define M_CQE_SWCQE       0x1
-#define G_CQE_SWCQE(x)    ((((x) >> S_CQE_SWCQE)) & M_CQE_SWCQE)
-#define V_CQE_SWCQE(x)	  ((x)<<S_CQE_SWCQE)
-
-#define S_CQE_STATUS      5
-#define M_CQE_STATUS      0x1F
-#define G_CQE_STATUS(x)   ((((x) >> S_CQE_STATUS)) & M_CQE_STATUS)
-#define V_CQE_STATUS(x)   ((x)<<S_CQE_STATUS)
-
-#define S_CQE_TYPE        4
-#define M_CQE_TYPE        0x1
-#define G_CQE_TYPE(x)     ((((x) >> S_CQE_TYPE)) & M_CQE_TYPE)
-#define V_CQE_TYPE(x)     ((x)<<S_CQE_TYPE)
-
-#define S_CQE_OPCODE      0
-#define M_CQE_OPCODE      0xF
-#define G_CQE_OPCODE(x)   ((((x) >> S_CQE_OPCODE)) & M_CQE_OPCODE)
-#define V_CQE_OPCODE(x)   ((x)<<S_CQE_OPCODE)
-
-#define SW_CQE(x)         (G_CQE_SWCQE(be32_to_cpu((x)->header)))
-#define CQE_QPID(x)       (G_CQE_QPID(be32_to_cpu((x)->header)))
-#define CQE_TYPE(x)       (G_CQE_TYPE(be32_to_cpu((x)->header)))
+#define CQE_QPID_S        12
+#define CQE_QPID_M        0xFFFFF
+#define CQE_QPID_G(x)     ((((x) >> CQE_QPID_S)) & CQE_QPID_M)
+#define CQE_QPID_V(x)	  ((x)<<CQE_QPID_S)
+
+#define CQE_SWCQE_S       11
+#define CQE_SWCQE_M       0x1
+#define CQE_SWCQE_G(x)    ((((x) >> CQE_SWCQE_S)) & CQE_SWCQE_M)
+#define CQE_SWCQE_V(x)	  ((x)<<CQE_SWCQE_S)
+
+#define CQE_STATUS_S      5
+#define CQE_STATUS_M      0x1F
+#define CQE_STATUS_G(x)   ((((x) >> CQE_STATUS_S)) & CQE_STATUS_M)
+#define CQE_STATUS_V(x)   ((x)<<CQE_STATUS_S)
+
+#define CQE_TYPE_S        4
+#define CQE_TYPE_M        0x1
+#define CQE_TYPE_G(x)     ((((x) >> CQE_TYPE_S)) & CQE_TYPE_M)
+#define CQE_TYPE_V(x)     ((x)<<CQE_TYPE_S)
+
+#define CQE_OPCODE_S      0
+#define CQE_OPCODE_M      0xF
+#define CQE_OPCODE_G(x)   ((((x) >> CQE_OPCODE_S)) & CQE_OPCODE_M)
+#define CQE_OPCODE_V(x)   ((x)<<CQE_OPCODE_S)
+
+#define SW_CQE(x)         (CQE_SWCQE_G(be32_to_cpu((x)->header)))
+#define CQE_QPID(x)       (CQE_QPID_G(be32_to_cpu((x)->header)))
+#define CQE_TYPE(x)       (CQE_TYPE_G(be32_to_cpu((x)->header)))
 #define SQ_TYPE(x)	  (CQE_TYPE((x)))
 #define RQ_TYPE(x)	  (!CQE_TYPE((x)))
-#define CQE_STATUS(x)     (G_CQE_STATUS(be32_to_cpu((x)->header)))
-#define CQE_OPCODE(x)     (G_CQE_OPCODE(be32_to_cpu((x)->header)))
+#define CQE_STATUS(x)     (CQE_STATUS_G(be32_to_cpu((x)->header)))
+#define CQE_OPCODE(x)     (CQE_OPCODE_G(be32_to_cpu((x)->header)))
 
 #define CQE_SEND_OPCODE(x)( \
-	(G_CQE_OPCODE(be32_to_cpu((x)->header)) == FW_RI_SEND) || \
-	(G_CQE_OPCODE(be32_to_cpu((x)->header)) == FW_RI_SEND_WITH_SE) || \
-	(G_CQE_OPCODE(be32_to_cpu((x)->header)) == FW_RI_SEND_WITH_INV) || \
-	(G_CQE_OPCODE(be32_to_cpu((x)->header)) == FW_RI_SEND_WITH_SE_INV))
+	(CQE_OPCODE_G(be32_to_cpu((x)->header)) == FW_RI_SEND) || \
+	(CQE_OPCODE_G(be32_to_cpu((x)->header)) == FW_RI_SEND_WITH_SE) || \
+	(CQE_OPCODE_G(be32_to_cpu((x)->header)) == FW_RI_SEND_WITH_INV) || \
+	(CQE_OPCODE_G(be32_to_cpu((x)->header)) == FW_RI_SEND_WITH_SE_INV))
 
 #define CQE_LEN(x)        (be32_to_cpu((x)->len))
 
@@ -237,25 +237,25 @@ struct t4_cqe {
 #define CQE_WRID_LOW(x)		(be32_to_cpu((x)->u.gen.wrid_low))
 
 /* macros for flit 3 of the cqe */
-#define S_CQE_GENBIT	63
-#define M_CQE_GENBIT	0x1
-#define G_CQE_GENBIT(x)	(((x) >> S_CQE_GENBIT) & M_CQE_GENBIT)
-#define V_CQE_GENBIT(x) ((x)<<S_CQE_GENBIT)
+#define CQE_GENBIT_S	63
+#define CQE_GENBIT_M	0x1
+#define CQE_GENBIT_G(x)	(((x) >> CQE_GENBIT_S) & CQE_GENBIT_M)
+#define CQE_GENBIT_V(x) ((x)<<CQE_GENBIT_S)
 
-#define S_CQE_OVFBIT	62
-#define M_CQE_OVFBIT	0x1
-#define G_CQE_OVFBIT(x)	((((x) >> S_CQE_OVFBIT)) & M_CQE_OVFBIT)
+#define CQE_OVFBIT_S	62
+#define CQE_OVFBIT_M	0x1
+#define CQE_OVFBIT_G(x)	((((x) >> CQE_OVFBIT_S)) & CQE_OVFBIT_M)
 
-#define S_CQE_IQTYPE	60
-#define M_CQE_IQTYPE	0x3
-#define G_CQE_IQTYPE(x)	((((x) >> S_CQE_IQTYPE)) & M_CQE_IQTYPE)
+#define CQE_IQTYPE_S	60
+#define CQE_IQTYPE_M	0x3
+#define CQE_IQTYPE_G(x)	((((x) >> CQE_IQTYPE_S)) & CQE_IQTYPE_M)
 
-#define M_CQE_TS	0x0fffffffffffffffULL
-#define G_CQE_TS(x)	((x) & M_CQE_TS)
+#define CQE_TS_M	0x0fffffffffffffffULL
+#define CQE_TS_G(x)	((x) & CQE_TS_M)
 
-#define CQE_OVFBIT(x)	((unsigned)G_CQE_OVFBIT(be64_to_cpu((x)->bits_type_ts)))
-#define CQE_GENBIT(x)	((unsigned)G_CQE_GENBIT(be64_to_cpu((x)->bits_type_ts)))
-#define CQE_TS(x)	(G_CQE_TS(be64_to_cpu((x)->bits_type_ts)))
+#define CQE_OVFBIT(x)	((unsigned)CQE_OVFBIT_G(be64_to_cpu((x)->bits_type_ts)))
+#define CQE_GENBIT(x)	((unsigned)CQE_GENBIT_G(be64_to_cpu((x)->bits_type_ts)))
+#define CQE_TS(x)	(CQE_TS_G(be64_to_cpu((x)->bits_type_ts)))
 
 struct t4_swsqe {
 	u64			wr_id;
-- 
1.7.1
