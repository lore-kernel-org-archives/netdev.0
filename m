From: kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Subject: [PATCH 1/4] cxgbi: renamed alloc_cpl to alloc_wr
Date: Thu, 23 Sep 2010 16:43:23 -0700
Message-ID: <201009232343.o8NNhNGJ006461@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncCNvLk8fsDxCmzO_kBBoEi8W44Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

[PATCH 1/4] cxgbi: renamed alloc_cpl to alloc_wr
          
From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
          
This patch renamed alloc_cpl() to alloc_wr().

Signed-off-by: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---

 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c |   18 +++++++++---------
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   28 ++++++++++++++--------------
 drivers/scsi/cxgbi/libcxgbi.h      |    5 ++---
 3 files changed, 25 insertions(+), 26 deletions(-)


diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index a01c1e2..a2c207f 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -320,7 +320,7 @@ static u32 send_rx_credits(struct cxgbi_sock *csk, u32 credits)
 		"csk 0x%p,%u,0x%lx,%u, credit %u, dack %u.\n",
 		csk, csk->state, csk->flags, csk->tid, credits, dack);
 
-	skb = alloc_cpl(sizeof(*req), 0, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(*req), 0, GFP_ATOMIC);
 	if (!skb) {
 		pr_info("csk 0x%p, credit %u, OOM.\n", csk, credits);
 		return 0;
@@ -572,7 +572,7 @@ static void act_open_retry_timer(unsigned long data)
 
 	cxgbi_sock_get(csk);
 	spin_lock_bh(&csk->lock);
-	skb = alloc_cpl(sizeof(struct cpl_act_open_req), 0, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(struct cpl_act_open_req), 0, GFP_ATOMIC);
 	if (!skb)
 		cxgbi_sock_fail_act_open(csk, -ENOMEM);
 	else {
@@ -881,16 +881,16 @@ static int do_wr_ack(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
  */
 static int alloc_cpls(struct cxgbi_sock *csk)
 {
-	csk->cpl_close = alloc_cpl(sizeof(struct cpl_close_con_req), 0,
+	csk->cpl_close = alloc_wr(sizeof(struct cpl_close_con_req), 0,
 					GFP_KERNEL);
 	if (!csk->cpl_close)
 		return -ENOMEM;
-	csk->cpl_abort_req = alloc_cpl(sizeof(struct cpl_abort_req), 0,
+	csk->cpl_abort_req = alloc_wr(sizeof(struct cpl_abort_req), 0,
 					GFP_KERNEL);
 	if (!csk->cpl_abort_req)
 		goto free_cpl_skbs;
 
-	csk->cpl_abort_rpl = alloc_cpl(sizeof(struct cpl_abort_rpl), 0,
+	csk->cpl_abort_rpl = alloc_wr(sizeof(struct cpl_abort_rpl), 0,
 					GFP_KERNEL);
 	if (!csk->cpl_abort_rpl)
 		goto free_cpl_skbs;
@@ -972,7 +972,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
 
-	skb = alloc_cpl(sizeof(struct cpl_act_open_req), 0, GFP_KERNEL);
+	skb = alloc_wr(sizeof(struct cpl_act_open_req), 0, GFP_KERNEL);
 	if (!skb)
 		goto rel_resource;
 	skb->sk = (struct sock *)csk;
@@ -1141,7 +1141,7 @@ static int ddp_alloc_gl_skb(struct cxgbi_ddp_info *ddp, int idx,
 		"ddp 0x%p, idx %d, cnt %d.\n", ddp, idx, cnt);
 
 	for (i = 0; i < cnt; i++) {
-		struct sk_buff *skb = alloc_cpl(sizeof(struct ulp_mem_io) +
+		struct sk_buff *skb = alloc_wr(sizeof(struct ulp_mem_io) +
 						PPOD_SIZE, 0, gfp);
 		if (skb) {
 			ddp->gl_skb[idx + i] = skb;
@@ -1156,7 +1156,7 @@ static int ddp_alloc_gl_skb(struct cxgbi_ddp_info *ddp, int idx,
 static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk,
 				       unsigned int tid, int pg_idx, bool reply)
 {
-	struct sk_buff *skb = alloc_cpl(sizeof(struct cpl_set_tcb_field), 0,
+	struct sk_buff *skb = alloc_wr(sizeof(struct cpl_set_tcb_field), 0,
 					GFP_KERNEL);
 	struct cpl_set_tcb_field *req;
 	u64 val = pg_idx < DDP_PGIDX_MAX ? pg_idx : 0;
@@ -1193,7 +1193,7 @@ static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk,
 static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 			     int hcrc, int dcrc, int reply)
 {
-	struct sk_buff *skb = alloc_cpl(sizeof(struct cpl_set_tcb_field), 0,
+	struct sk_buff *skb = alloc_wr(sizeof(struct cpl_set_tcb_field), 0,
 					GFP_KERNEL);
 	struct cpl_set_tcb_field *req;
 	u64 val = (hcrc ? 1 : 0) | (dcrc ? 2 : 0);
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index b375a68..1056d97 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -332,7 +332,7 @@ static u32 send_rx_credits(struct cxgbi_sock *csk, u32 credits)
 		"csk 0x%p,%u,0x%lx,%u, credit %u.\n",
 		csk, csk->state, csk->flags, csk->tid, credits);
 
-	skb = alloc_cpl(sizeof(*req), 0, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(*req), 0, GFP_ATOMIC);
 	if (!skb) {
 		pr_info("csk 0x%p, credit %u, OOM.\n", csk, credits);
 		return 0;
@@ -388,7 +388,7 @@ static inline void send_tx_flowc_wr(struct cxgbi_sock *csk)
 	int flowclen, i;
 
 	flowclen = 80;
-	skb = alloc_cpl(flowclen, 0, GFP_ATOMIC);
+	skb = alloc_wr(flowclen, 0, GFP_ATOMIC);
 	flowc = (struct fw_flowc_wr *)skb->head;
 	flowc->op_to_nparams =
 		htonl(FW_WR_OP(FW_FLOWC_WR) | FW_FLOWC_WR_NPARAMS(8));
@@ -651,7 +651,7 @@ static void csk_act_open_retry_timer(unsigned long data)
 
 	cxgbi_sock_get(csk);
 	spin_lock_bh(&csk->lock);
-	skb = alloc_cpl(sizeof(struct cpl_act_open_req), 0, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(struct cpl_act_open_req), 0, GFP_ATOMIC);
 	if (!skb)
 		cxgbi_sock_fail_act_open(csk, -ENOMEM);
 	else {
@@ -1073,18 +1073,18 @@ static void do_set_tcb_rpl(struct cxgbi_device *cdev, struct sk_buff *skb)
 
 static int alloc_cpls(struct cxgbi_sock *csk)
 {
-	csk->cpl_close = alloc_cpl(sizeof(struct cpl_close_con_req),
-					0, GFP_NOIO);
+	csk->cpl_close = alloc_wr(sizeof(struct cpl_close_con_req),
+					0, GFP_KERNEL);
 	if (!csk->cpl_close)
 		return -ENOMEM;
 
-	csk->cpl_abort_req = alloc_cpl(sizeof(struct cpl_abort_req),
-					0, GFP_NOIO);
+	csk->cpl_abort_req = alloc_wr(sizeof(struct cpl_abort_req),
+					0, GFP_KERNEL);
 	if (!csk->cpl_abort_req)
 		goto free_cpls;
 
-	csk->cpl_abort_rpl = alloc_cpl(sizeof(struct cpl_abort_rpl),
-					0, GFP_NOIO);
+	csk->cpl_abort_rpl = alloc_wr(sizeof(struct cpl_abort_rpl),
+					0, GFP_KERNEL);
 	if (!csk->cpl_abort_rpl)
 		goto free_cpls;
 	return 0;
@@ -1158,7 +1158,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	}
 	cxgbi_sock_get(csk);
 
-	skb = alloc_cpl(sizeof(struct cpl_act_open_req), 0, GFP_NOIO);
+	skb = alloc_wr(sizeof(struct cpl_act_open_req), 0, GFP_KERNEL);
 	if (!skb)
 		goto rel_resource;
 	skb->sk = (struct sock *)csk;
@@ -1268,7 +1268,7 @@ static int ddp_ppod_write_sgl(struct cxgbi_device *cdev, unsigned int port_id,
 	dlen = PPOD_SIZE * npods;
 	pm_addr = idx * PPOD_SIZE + ddp->llimit;
 
-	skb = alloc_cpl(sizeof(*req) + sizeof(*sgl), dlen, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(*req) + sizeof(*sgl), dlen, GFP_ATOMIC);
 	if (!skb) {
 		pr_err("cdev 0x%p, idx %u, npods %u, OOM.\n",
 			cdev, idx, npods);
@@ -1339,7 +1339,7 @@ static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk, unsigned int tid,
 	if (!pg_idx)
 		return 0;
 
-	skb = alloc_cpl(sizeof(*req), 0, GFP_KERNEL);
+	skb = alloc_wr(sizeof(*req), 0, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 
@@ -1373,7 +1373,7 @@ static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 	val = TCB_ULP_RAW(val);
 	val |= TCB_ULP_TYPE(ULP2_MODE_ISCSI);
 
-	skb = alloc_cpl(sizeof(*req), 0, GFP_KERNEL);
+	skb = alloc_wr(sizeof(*req), 0, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 
@@ -1516,7 +1516,7 @@ static int t4_uld_rx_handler(void *handle, const __be64 *rsp,
 	if (pgl == NULL) {
 		unsigned int len = 64 - sizeof(struct rsp_ctrl) - 8;
 
-		skb = alloc_cpl(len, 0, GFP_ATOMIC);
+		skb = alloc_wr(len, 0, GFP_ATOMIC);
 		if (!skb)
 			goto nomem;
 		skb_copy_to_linear_data(skb, &rsp[1], len);
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 40551f3..2f2485b 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -410,16 +410,15 @@ static inline unsigned int cxgbi_sock_compute_wscale(unsigned int win)
 	return wscale;
 }
 
-static inline struct sk_buff *alloc_cpl(int cpl_len, int dlen, gfp_t gfp)
+static inline struct sk_buff *alloc_wr(int wrlen, int dlen, gfp_t gfp)
 {
-	int wrlen = roundup(cpl_len, 16);
 	struct sk_buff *skb = alloc_skb(wrlen + dlen, gfp);
 
 	if (skb) {
 		__skb_put(skb, wrlen);
 		memset(skb->head, 0, wrlen + dlen);
 	} else
-		pr_info("alloc cpl skb %u+%u, OOM.\n", cpl_len, dlen);
+		pr_info("alloc cpl wr skb %u+%u, OOM.\n", wrlen, dlen);
 	return skb;
 }
 

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
