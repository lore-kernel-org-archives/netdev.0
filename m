From: Doug Maxey <dwm@austin.ibm.com>
Subject: [PATCH 5/5] ehea: fix qmr checkpatch complaints
Date: Thu, 31 Jan 2008 20:20:51 -0600
Message-ID: <1201832451-23634-6-git-send-email-dwm@austin.ibm.com>
References: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux PowerPC List <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>, Jan-Bernd Themann <themann@de.ibm.com>
To: Jeff Garzik <jgarzik@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Cc: Jan-Bernd Themann <themann@de.ibm.com>
Signed-off-by: Doug Maxey <dwm@austin.ibm.com>
---
 drivers/net/ehea/ehea_qmr.c |   32 ++++++++++++++++----------------
 drivers/net/ehea/ehea_qmr.h |   16 ++++++++--------
 2 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 83b7643..d522e90 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -33,8 +33,6 @@
 
 
 struct ehea_busmap ehea_bmap = { 0, 0, NULL };
-extern u64 ehea_driver_flags;
-extern struct work_struct ehea_rereg_mr_task;
 
 
 static void *hw_qpageit_get_inc(struct hw_queue *queue)
@@ -65,7 +63,7 @@ static int hw_queue_ctor(struct hw_queue *queue, const u32 nr_of_pages,
 	}
 
 	queue->queue_length = nr_of_pages * pagesize;
-	queue->queue_pages = kmalloc(nr_of_pages * sizeof(void*), GFP_KERNEL);
+	queue->queue_pages = kmalloc(nr_of_pages * sizeof(void *), GFP_KERNEL);
 	if (!queue->queue_pages) {
 		ehea_error("no mem for queue_pages");
 		return -ENOMEM;
@@ -78,11 +76,11 @@ static int hw_queue_ctor(struct hw_queue *queue, const u32 nr_of_pages,
 	 */
 	i = 0;
 	while (i < nr_of_pages) {
-		u8 *kpage = (u8*)get_zeroed_page(GFP_KERNEL);
+		u8 *kpage = (u8 *)get_zeroed_page(GFP_KERNEL);
 		if (!kpage)
 			goto out_nomem;
 		for (k = 0; k < pages_per_kpage && i < nr_of_pages; k++) {
-			(queue->queue_pages)[i] = (struct ehea_page*)kpage;
+			(queue->queue_pages)[i] = (struct ehea_page *)kpage;
 			kpage += pagesize;
 			i++;
 		}
@@ -235,8 +233,8 @@ int ehea_destroy_cq(struct ehea_cq *cq)
 		return 0;
 
 	hcp_epas_dtor(&cq->epas);
-
-	if ((hret = ehea_destroy_cq_res(cq, NORMAL_FREE)) == H_R_STATE) {
+	hret = ehea_destroy_cq_res(cq, NORMAL_FREE);
+	if (hret == H_R_STATE) {
 		ehea_error_data(cq->adapter, cq->fw_handle);
 		hret = ehea_destroy_cq_res(cq, FORCE_FREE);
 	}
@@ -301,13 +299,13 @@ struct ehea_eq *ehea_create_eq(struct ehea_adapter *adapter,
 		if (i == (eq->attr.nr_pages - 1)) {
 			/* last page */
 			vpage = hw_qpageit_get_inc(&eq->hw_queue);
-			if ((hret != H_SUCCESS) || (vpage)) {
+			if ((hret != H_SUCCESS) || (vpage))
 				goto out_kill_hwq;
-			}
+
 		} else {
-			if ((hret != H_PAGE_REGISTERED) || (!vpage)) {
+			if ((hret != H_PAGE_REGISTERED) || (!vpage))
 				goto out_kill_hwq;
-			}
+
 		}
 	}
 
@@ -331,7 +329,7 @@ struct ehea_eqe *ehea_poll_eq(struct ehea_eq *eq)
 	unsigned long flags;
 
 	spin_lock_irqsave(&eq->spinlock, flags);
-	eqe = (struct ehea_eqe*)hw_eqit_eq_get_inc_valid(&eq->hw_queue);
+	eqe = (struct ehea_eqe *)hw_eqit_eq_get_inc_valid(&eq->hw_queue);
 	spin_unlock_irqrestore(&eq->spinlock, flags);
 
 	return eqe;
@@ -364,7 +362,8 @@ int ehea_destroy_eq(struct ehea_eq *eq)
 
 	hcp_epas_dtor(&eq->epas);
 
-	if ((hret = ehea_destroy_eq_res(eq, NORMAL_FREE)) == H_R_STATE) {
+	hret = ehea_destroy_eq_res(eq, NORMAL_FREE);
+	if (hret == H_R_STATE) {
 		ehea_error_data(eq->adapter, eq->fw_handle);
 		hret = ehea_destroy_eq_res(eq, FORCE_FREE);
 	}
@@ -546,7 +545,8 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 
 	hcp_epas_dtor(&qp->epas);
 
-	if ((hret = ehea_destroy_qp_res(qp, NORMAL_FREE)) == H_R_STATE) {
+	hret = ehea_destroy_qp_res(qp, NORMAL_FREE);
+	if (hret == H_R_STATE) {
 		ehea_error_data(qp->adapter, qp->fw_handle);
 		hret = ehea_destroy_qp_res(qp, FORCE_FREE);
 	}
@@ -559,7 +559,7 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	return 0;
 }
 
-int ehea_create_busmap( void )
+int ehea_create_busmap(void)
 {
 	u64 vaddr = EHEA_BUSMAP_START;
 	unsigned long high_section_index = 0;
@@ -595,7 +595,7 @@ int ehea_create_busmap( void )
 	return 0;
 }
 
-void ehea_destroy_busmap( void )
+void ehea_destroy_busmap(void)
 {
 	vfree(ehea_bmap.vaddr);
 }
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index bc62d38..0bb6f92 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -41,8 +41,8 @@
 #define EHEA_SECTSIZE          (1UL << 24)
 #define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> EHEA_PAGESHIFT)
 
-#if (1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE
-#error eHEA module can't work if kernel sectionsize < ehea sectionsize
+#if ((1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE)
+#error eHEA module cannot work if kernel sectionsize < ehea sectionsize
 #endif
 
 /* Some abbreviations used here:
@@ -188,8 +188,8 @@ struct ehea_eqe {
 	u64 entry;
 };
 
-#define ERROR_DATA_LENGTH  EHEA_BMASK_IBM(52,63)
-#define ERROR_DATA_TYPE    EHEA_BMASK_IBM(0,7)
+#define ERROR_DATA_LENGTH  EHEA_BMASK_IBM(52, 63)
+#define ERROR_DATA_TYPE    EHEA_BMASK_IBM(0, 7)
 
 static inline void *hw_qeit_calc(struct hw_queue *queue, u64 q_offset)
 {
@@ -279,7 +279,7 @@ static inline void *hw_qeit_eq_get_inc(struct hw_queue *queue)
 static inline void *hw_eqit_eq_get_inc_valid(struct hw_queue *queue)
 {
 	void *retvalue = hw_qeit_get(queue);
-	u32 qe = *(u8*)retvalue;
+	u32 qe = *(u8 *)retvalue;
 	if ((qe >> 7) == (queue->toggle_state & 1))
 		hw_qeit_eq_get_inc(queue);
 	else
@@ -364,7 +364,7 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter, int cqe,
 
 int ehea_destroy_cq(struct ehea_cq *cq);
 
-struct ehea_qp *ehea_create_qp(struct ehea_adapter * adapter, u32 pd,
+struct ehea_qp *ehea_create_qp(struct ehea_adapter *adapter, u32 pd,
 			       struct ehea_qp_init_attr *init_attr);
 
 int ehea_destroy_qp(struct ehea_qp *qp);
@@ -378,8 +378,8 @@ int ehea_rem_mr(struct ehea_mr *mr);
 
 void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle);
 
-int ehea_create_busmap( void );
-void ehea_destroy_busmap( void );
+int ehea_create_busmap(void);
+void ehea_destroy_busmap(void);
 u64 ehea_map_vaddr(void *caddr);
 
 #endif	/* __EHEA_QMR_H__ */
-- 
1.5.3.8
