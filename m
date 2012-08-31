From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/2] cxgb4: Remove duplicate register definitions
Date: Fri, 31 Aug 2012 14:54:31 +0530
Message-ID: <1346405072-24561-2-git-send-email-vipul@chelsio.com>
References: <1346405072-24561-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, sivasu-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1346405072-24561-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Removed duplicate definition for SGE_PF_KDOORBELL, SGE_INT_ENABLE3,
PCIE_MEM_ACCESS_OFFSET registers.
Moved the register field definitions around the register definition.

Signed-off-by: Santosh Rastapur <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Reviewed-by: Sivakumar Subramani <sivasu-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   18 ++++----
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   12 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   54 +++++-----------------
 4 files changed, 30 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5ed49af..34d510d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2470,8 +2470,8 @@ int cxgb4_sync_txq_pidx(struct net_device *dev, u16 qid, u16 pidx,
 		else
 			delta = size - hw_pidx + pidx;
 		wmb();
-		t4_write_reg(adap, MYPF_REG(A_SGE_PF_KDOORBELL),
-			     V_QID(qid) | V_PIDX(delta));
+		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
+			     QID(qid) | PIDX(delta));
 	}
 out:
 	return ret;
@@ -2579,8 +2579,8 @@ static void sync_txq_pidx(struct adapter *adap, struct sge_txq *q)
 		else
 			delta = q->size - hw_pidx + q->db_pidx;
 		wmb();
-		t4_write_reg(adap, MYPF_REG(A_SGE_PF_KDOORBELL),
-				V_QID(q->cntxt_id) | V_PIDX(delta));
+		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
+			     QID(q->cntxt_id) | PIDX(delta));
 	}
 out:
 	q->db_disabled = 0;
@@ -2617,9 +2617,9 @@ static void process_db_full(struct work_struct *work)
 
 	notify_rdma_uld(adap, CXGB4_CONTROL_DB_FULL);
 	drain_db_fifo(adap, dbfifo_drain_delay);
-	t4_set_reg_field(adap, A_SGE_INT_ENABLE3,
-			F_DBFIFO_HP_INT | F_DBFIFO_LP_INT,
-			F_DBFIFO_HP_INT | F_DBFIFO_LP_INT);
+	t4_set_reg_field(adap, SGE_INT_ENABLE3,
+			 DBFIFO_HP_INT | DBFIFO_LP_INT,
+			 DBFIFO_HP_INT | DBFIFO_LP_INT);
 	notify_rdma_uld(adap, CXGB4_CONTROL_DB_EMPTY);
 }
 
@@ -2639,8 +2639,8 @@ static void process_db_drop(struct work_struct *work)
 
 void t4_db_full(struct adapter *adap)
 {
-	t4_set_reg_field(adap, A_SGE_INT_ENABLE3,
-			F_DBFIFO_HP_INT | F_DBFIFO_LP_INT, 0);
+	t4_set_reg_field(adap, SGE_INT_ENABLE3,
+			 DBFIFO_HP_INT | DBFIFO_LP_INT, 0);
 	queue_work(workq, &adap->db_full_task);
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index d49933e..1fde57d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -769,8 +769,8 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 	wmb();            /* write descriptors before telling HW */
 	spin_lock(&q->db_lock);
 	if (!q->db_disabled) {
-		t4_write_reg(adap, MYPF_REG(A_SGE_PF_KDOORBELL),
-			     V_QID(q->cntxt_id) | V_PIDX(n));
+		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
+			     QID(q->cntxt_id) | PIDX(n));
 	}
 	q->db_pidx = q->pidx;
 	spin_unlock(&q->db_lock);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index fa947df..8e988d6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1018,9 +1018,9 @@ static void sge_intr_handler(struct adapter *adapter)
 		{ ERR_INVALID_CIDX_INC,
 		  "SGE GTS CIDX increment too large", -1, 0 },
 		{ ERR_CPL_OPCODE_0, "SGE received 0-length CPL", -1, 0 },
-		{ F_DBFIFO_LP_INT, NULL, -1, 0, t4_db_full },
-		{ F_DBFIFO_HP_INT, NULL, -1, 0, t4_db_full },
-		{ F_ERR_DROPPED_DB, NULL, -1, 0, t4_db_dropped },
+		{ DBFIFO_LP_INT, NULL, -1, 0, t4_db_full },
+		{ DBFIFO_HP_INT, NULL, -1, 0, t4_db_full },
+		{ ERR_DROPPED_DB, NULL, -1, 0, t4_db_dropped },
 		{ ERR_DATA_CPL_ON_HIGH_QID1 | ERR_DATA_CPL_ON_HIGH_QID0,
 		  "SGE IQID > 1023 received CPL for FL", -1, 0 },
 		{ ERR_BAD_DB_PIDX3, "SGE DBP 3 pidx increment too large", -1,
@@ -1520,7 +1520,7 @@ void t4_intr_enable(struct adapter *adapter)
 		     ERR_BAD_DB_PIDX2 | ERR_BAD_DB_PIDX1 |
 		     ERR_BAD_DB_PIDX0 | ERR_ING_CTXT_PRIO |
 		     ERR_EGR_CTXT_PRIO | INGRESS_SIZE_ERR |
-		     F_DBFIFO_HP_INT | F_DBFIFO_LP_INT |
+		     DBFIFO_HP_INT | DBFIFO_LP_INT |
 		     EGRESS_SIZE_ERR);
 	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE), PF_INTR_MASK);
 	t4_set_reg_field(adapter, PL_INT_MAP0, 0, 1 << pf);
@@ -2033,8 +2033,8 @@ int t4_mem_win_read_len(struct adapter *adap, u32 addr, __be32 *data, int len)
 	if ((addr & 3) || (len + off) > MEMWIN0_APERTURE)
 		return -EINVAL;
 
-	t4_write_reg(adap, A_PCIE_MEM_ACCESS_OFFSET, addr & ~15);
-	t4_read_reg(adap, A_PCIE_MEM_ACCESS_OFFSET);
+	t4_write_reg(adap, PCIE_MEM_ACCESS_OFFSET, addr & ~15);
+	t4_read_reg(adap, PCIE_MEM_ACCESS_OFFSET);
 
 	for (i = 0; i < len; i += 4)
 		*data++ = t4_read_reg(adap, (MEMWIN0_BASE + off + i));
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 111fc32..8e814bc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -190,58 +190,30 @@
 #define SGE_DEBUG_DATA_LOW 0x10d4
 #define SGE_INGRESS_QUEUES_PER_PAGE_PF 0x10f4
 
-#define S_LP_INT_THRESH    12
-#define V_LP_INT_THRESH(x) ((x) << S_LP_INT_THRESH)
 #define S_HP_INT_THRESH    28
+#define M_HP_INT_THRESH 0xfU
 #define V_HP_INT_THRESH(x) ((x) << S_HP_INT_THRESH)
+#define M_HP_COUNT 0x7ffU
+#define S_HP_COUNT 16
+#define G_HP_COUNT(x) (((x) >> S_HP_COUNT) & M_HP_COUNT)
+#define S_LP_INT_THRESH    12
+#define M_LP_INT_THRESH 0xfU
+#define V_LP_INT_THRESH(x) ((x) << S_LP_INT_THRESH)
+#define M_LP_COUNT 0x7ffU
+#define S_LP_COUNT 0
+#define G_LP_COUNT(x) (((x) >> S_LP_COUNT) & M_LP_COUNT)
 #define A_SGE_DBFIFO_STATUS 0x10a4
 
 #define S_ENABLE_DROP    13
 #define V_ENABLE_DROP(x) ((x) << S_ENABLE_DROP)
 #define F_ENABLE_DROP    V_ENABLE_DROP(1U)
-#define A_SGE_DOORBELL_CONTROL 0x10a8
-
-#define A_SGE_CTXT_CMD 0x11fc
-#define A_SGE_DBQ_CTXT_BADDR 0x1084
-
-#define A_SGE_PF_KDOORBELL 0x0
-
-#define S_QID 15
-#define V_QID(x) ((x) << S_QID)
-
-#define S_PIDX 0
-#define V_PIDX(x) ((x) << S_PIDX)
-
-#define M_LP_COUNT 0x7ffU
-#define S_LP_COUNT 0
-#define G_LP_COUNT(x) (((x) >> S_LP_COUNT) & M_LP_COUNT)
-
-#define M_HP_COUNT 0x7ffU
-#define S_HP_COUNT 16
-#define G_HP_COUNT(x) (((x) >> S_HP_COUNT) & M_HP_COUNT)
-
-#define A_SGE_INT_ENABLE3 0x1040
-
-#define S_DBFIFO_HP_INT 8
-#define V_DBFIFO_HP_INT(x) ((x) << S_DBFIFO_HP_INT)
-#define F_DBFIFO_HP_INT V_DBFIFO_HP_INT(1U)
-
-#define S_DBFIFO_LP_INT 7
-#define V_DBFIFO_LP_INT(x) ((x) << S_DBFIFO_LP_INT)
-#define F_DBFIFO_LP_INT V_DBFIFO_LP_INT(1U)
-
 #define S_DROPPED_DB 0
 #define V_DROPPED_DB(x) ((x) << S_DROPPED_DB)
 #define F_DROPPED_DB V_DROPPED_DB(1U)
+#define A_SGE_DOORBELL_CONTROL 0x10a8
 
-#define S_ERR_DROPPED_DB 18
-#define V_ERR_DROPPED_DB(x) ((x) << S_ERR_DROPPED_DB)
-#define F_ERR_DROPPED_DB V_ERR_DROPPED_DB(1U)
-
-#define A_PCIE_MEM_ACCESS_OFFSET 0x306c
-
-#define M_HP_INT_THRESH 0xfU
-#define M_LP_INT_THRESH 0xfU
+#define A_SGE_CTXT_CMD 0x11fc
+#define A_SGE_DBQ_CTXT_BADDR 0x1084
 
 #define PCIE_PF_CLI 0x44
 #define PCIE_INT_CAUSE 0x3004
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
