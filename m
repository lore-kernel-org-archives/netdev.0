From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 3/3] cxgb4: Cleanup macros so they follow the same style and look consistent, part 2
Date: Fri,  7 Nov 2014 09:35:25 +0530
Message-ID: <1415333125-10635-4-git-send-email-hariprasad@chelsio.com>
References: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, hch@infradead.org,
	swise@opengridcomputing.com, leedom@chelsio.com, anish@chelsio.com,
	praveenm@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33612
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751430AbaKGEAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 23:00:31 -0500
In-Reply-To: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various patches have ended up changing the style of the symbolic macros/register
defines to different style.

As a result, the current kernel.org files are a mix of different macro styles.
Since this macro/register defines is used by different drivers a
few patch series have ended up adding duplicate macro/register define entries
with different styles. This makes these register define/macro files a complete
mess and we want to make them clean and consistent. This patch cleans up a part
of it.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                   |   56 ++++----
 drivers/infiniband/hw/cxgb4/cq.c                   |    8 +-
 drivers/infiniband/hw/cxgb4/mem.c                  |   14 +-
 drivers/infiniband/hw/cxgb4/qp.c                   |   26 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h     |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   60 ++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   15 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   32 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  121 +++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  142 +++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   32 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  150 +++++++++---------
 drivers/scsi/csiostor/csio_attr.c                  |    8 +-
 drivers/scsi/csiostor/csio_hw.c                    |   14 +-
 drivers/scsi/csiostor/csio_lnode.c                 |   18 +-
 drivers/scsi/csiostor/csio_mb.c                    |  172 ++++++++++----------
 drivers/scsi/csiostor/csio_scsi.c                  |   24 ++--
 drivers/scsi/csiostor/csio_wr.h                    |    2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |   35 ++--
 21 files changed, 509 insertions(+), 430 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index fb61f66..a07d8e1 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -472,10 +472,10 @@ static void send_flowc(struct c4iw_ep *ep, struct sk_buff *skb)
 	skb = get_skb(skb, flowclen, GFP_KERNEL);
 	flowc = (struct fw_flowc_wr *)__skb_put(skb, flowclen);
 
-	flowc->op_to_nparams = cpu_to_be32(FW_WR_OP(FW_FLOWC_WR) |
-					   FW_FLOWC_WR_NPARAMS(8));
-	flowc->flowid_len16 = cpu_to_be32(FW_WR_LEN16(DIV_ROUND_UP(flowclen,
-					  16)) | FW_WR_FLOWID(ep->hwtid));
+	flowc->op_to_nparams = cpu_to_be32(FW_WR_OP_V(FW_FLOWC_WR) |
+					   FW_FLOWC_WR_NPARAMS_V(8));
+	flowc->flowid_len16 = cpu_to_be32(FW_WR_LEN16_V(DIV_ROUND_UP(flowclen,
+					  16)) | FW_WR_FLOWID_V(ep->hwtid));
 
 	flowc->mnemval[0].mnemonic = FW_FLOWC_MNEM_PFNVFN;
 	flowc->mnemval[0].val = cpu_to_be32(FW_PFVF_CMD_PFN
@@ -803,16 +803,16 @@ static void send_mpa_req(struct c4iw_ep *ep, struct sk_buff *skb,
 	req = (struct fw_ofld_tx_data_wr *)skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
-		FW_WR_OP(FW_OFLD_TX_DATA_WR) |
-		FW_WR_COMPL(1) |
-		FW_WR_IMMDLEN(mpalen));
+		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
+		FW_WR_COMPL_F |
+		FW_WR_IMMDLEN_V(mpalen));
 	req->flowid_len16 = cpu_to_be32(
-		FW_WR_FLOWID(ep->hwtid) |
-		FW_WR_LEN16(wrlen >> 4));
+		FW_WR_FLOWID_V(ep->hwtid) |
+		FW_WR_LEN16_V(wrlen >> 4));
 	req->plen = cpu_to_be32(mpalen);
 	req->tunnel_to_proxy = cpu_to_be32(
-		FW_OFLD_TX_DATA_WR_FLUSH(1) |
-		FW_OFLD_TX_DATA_WR_SHOVE(1));
+		FW_OFLD_TX_DATA_WR_FLUSH_F |
+		FW_OFLD_TX_DATA_WR_SHOVE_F);
 
 	mpa = (struct mpa_message *)(req + 1);
 	memcpy(mpa->key, MPA_KEY_REQ, sizeof(mpa->key));
@@ -897,16 +897,16 @@ static int send_mpa_reject(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	req = (struct fw_ofld_tx_data_wr *)skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
-		FW_WR_OP(FW_OFLD_TX_DATA_WR) |
-		FW_WR_COMPL(1) |
-		FW_WR_IMMDLEN(mpalen));
+		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
+		FW_WR_COMPL_F |
+		FW_WR_IMMDLEN_V(mpalen));
 	req->flowid_len16 = cpu_to_be32(
-		FW_WR_FLOWID(ep->hwtid) |
-		FW_WR_LEN16(wrlen >> 4));
+		FW_WR_FLOWID_V(ep->hwtid) |
+		FW_WR_LEN16_V(wrlen >> 4));
 	req->plen = cpu_to_be32(mpalen);
 	req->tunnel_to_proxy = cpu_to_be32(
-		FW_OFLD_TX_DATA_WR_FLUSH(1) |
-		FW_OFLD_TX_DATA_WR_SHOVE(1));
+		FW_OFLD_TX_DATA_WR_FLUSH_F |
+		FW_OFLD_TX_DATA_WR_SHOVE_F);
 
 	mpa = (struct mpa_message *)(req + 1);
 	memset(mpa, 0, sizeof(*mpa));
@@ -977,16 +977,16 @@ static int send_mpa_reply(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	req = (struct fw_ofld_tx_data_wr *) skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
-		FW_WR_OP(FW_OFLD_TX_DATA_WR) |
-		FW_WR_COMPL(1) |
-		FW_WR_IMMDLEN(mpalen));
+		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
+		FW_WR_COMPL_F |
+		FW_WR_IMMDLEN_V(mpalen));
 	req->flowid_len16 = cpu_to_be32(
-		FW_WR_FLOWID(ep->hwtid) |
-		FW_WR_LEN16(wrlen >> 4));
+		FW_WR_FLOWID_V(ep->hwtid) |
+		FW_WR_LEN16_V(wrlen >> 4));
 	req->plen = cpu_to_be32(mpalen);
 	req->tunnel_to_proxy = cpu_to_be32(
-		FW_OFLD_TX_DATA_WR_FLUSH(1) |
-		FW_OFLD_TX_DATA_WR_SHOVE(1));
+		FW_OFLD_TX_DATA_WR_FLUSH_F |
+		FW_OFLD_TX_DATA_WR_SHOVE_F);
 
 	mpa = (struct mpa_message *)(req + 1);
 	memset(mpa, 0, sizeof(*mpa));
@@ -1751,7 +1751,7 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	req = (struct fw_ofld_connection_wr *)__skb_put(skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
 	req->op_compl = htonl(V_WR_OP(FW_OFLD_CONNECTION_WR));
-	req->len16_pkd = htonl(FW_WR_LEN16(DIV_ROUND_UP(sizeof(*req), 16)));
+	req->len16_pkd = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*req), 16)));
 	req->le.filter = cpu_to_be32(cxgb4_select_ntuple(
 				     ep->com.dev->rdev.lldi.ports[0],
 				     ep->l2t));
@@ -3537,8 +3537,8 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 	req_skb = alloc_skb(sizeof(struct fw_ofld_connection_wr), GFP_KERNEL);
 	req = (struct fw_ofld_connection_wr *)__skb_put(req_skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
-	req->op_compl = htonl(V_WR_OP(FW_OFLD_CONNECTION_WR) | FW_WR_COMPL(1));
-	req->len16_pkd = htonl(FW_WR_LEN16(DIV_ROUND_UP(sizeof(*req), 16)));
+	req->op_compl = htonl(V_WR_OP(FW_OFLD_CONNECTION_WR) | FW_WR_COMPL_F);
+	req->len16_pkd = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*req), 16)));
 	req->le.version_cpl = htonl(F_FW_OFLD_CONNECTION_WR_CPL);
 	req->le.filter = (__force __be32) filter;
 	req->le.lport = lport;
diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index 0f773e7..e9fd3a0 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -51,9 +51,9 @@ static int destroy_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	res_wr = (struct fw_ri_res_wr *)__skb_put(skb, wr_len);
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
-			FW_WR_OP(FW_RI_RES_WR) |
+			FW_WR_OP_V(FW_RI_RES_WR) |
 			V_FW_RI_RES_WR_NRES(1) |
-			FW_WR_COMPL(1));
+			FW_WR_COMPL_F);
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
 	res_wr->cookie = (unsigned long) &wr_wait;
 	res = res_wr->res;
@@ -121,9 +121,9 @@ static int create_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	res_wr = (struct fw_ri_res_wr *)__skb_put(skb, wr_len);
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
-			FW_WR_OP(FW_RI_RES_WR) |
+			FW_WR_OP_V(FW_RI_RES_WR) |
 			V_FW_RI_RES_WR_NRES(1) |
-			FW_WR_COMPL(1));
+			FW_WR_COMPL_F);
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
 	res_wr->cookie = (unsigned long) &wr_wait;
 	res = res_wr->res;
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index ec7a298..9335148 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -74,10 +74,10 @@ static int _c4iw_write_mem_dma_aligned(struct c4iw_rdev *rdev, u32 addr,
 	req = (struct ulp_mem_io *)__skb_put(skb, wr_len);
 	memset(req, 0, wr_len);
 	INIT_ULPTX_WR(req, wr_len, 0, 0);
-	req->wr.wr_hi = cpu_to_be32(FW_WR_OP(FW_ULPTX_WR) |
-			(wait ? FW_WR_COMPL(1) : 0));
+	req->wr.wr_hi = cpu_to_be32(FW_WR_OP_V(FW_ULPTX_WR) |
+			(wait ? FW_WR_COMPL_F : 0));
 	req->wr.wr_lo = wait ? (__force __be64)(unsigned long) &wr_wait : 0L;
-	req->wr.wr_mid = cpu_to_be32(FW_WR_LEN16(DIV_ROUND_UP(wr_len, 16)));
+	req->wr.wr_mid = cpu_to_be32(FW_WR_LEN16_V(DIV_ROUND_UP(wr_len, 16)));
 	req->cmd = cpu_to_be32(ULPTX_CMD(ULP_TX_MEM_WRITE));
 	req->cmd |= cpu_to_be32(V_T5_ULP_MEMIO_ORDER(1));
 	req->dlen = cpu_to_be32(ULP_MEMIO_DATA_LEN(len>>5));
@@ -135,13 +135,13 @@ static int _c4iw_write_mem_inline(struct c4iw_rdev *rdev, u32 addr, u32 len,
 		INIT_ULPTX_WR(req, wr_len, 0, 0);
 
 		if (i == (num_wqe-1)) {
-			req->wr.wr_hi = cpu_to_be32(FW_WR_OP(FW_ULPTX_WR) |
-						    FW_WR_COMPL(1));
+			req->wr.wr_hi = cpu_to_be32(FW_WR_OP_V(FW_ULPTX_WR) |
+						    FW_WR_COMPL_F);
 			req->wr.wr_lo = (__force __be64)(unsigned long) &wr_wait;
 		} else
-			req->wr.wr_hi = cpu_to_be32(FW_WR_OP(FW_ULPTX_WR));
+			req->wr.wr_hi = cpu_to_be32(FW_WR_OP_V(FW_ULPTX_WR));
 		req->wr.wr_mid = cpu_to_be32(
-				       FW_WR_LEN16(DIV_ROUND_UP(wr_len, 16)));
+				       FW_WR_LEN16_V(DIV_ROUND_UP(wr_len, 16)));
 
 		req->cmd = cmd;
 		req->dlen = cpu_to_be32(ULP_MEMIO_DATA_LEN(
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 41cd688..2ed3ece 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -271,9 +271,9 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	res_wr = (struct fw_ri_res_wr *)__skb_put(skb, wr_len);
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
-			FW_WR_OP(FW_RI_RES_WR) |
+			FW_WR_OP_V(FW_RI_RES_WR) |
 			V_FW_RI_RES_WR_NRES(2) |
-			FW_WR_COMPL(1));
+			FW_WR_COMPL_F);
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
 	res_wr->cookie = (unsigned long) &wr_wait;
 	res = res_wr->res;
@@ -1082,10 +1082,10 @@ static void post_terminate(struct c4iw_qp *qhp, struct t4_cqe *err_cqe,
 
 	wqe = (struct fw_ri_wr *)__skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof *wqe);
-	wqe->op_compl = cpu_to_be32(FW_WR_OP(FW_RI_INIT_WR));
+	wqe->op_compl = cpu_to_be32(FW_WR_OP_V(FW_RI_INIT_WR));
 	wqe->flowid_len16 = cpu_to_be32(
-		FW_WR_FLOWID(qhp->ep->hwtid) |
-		FW_WR_LEN16(DIV_ROUND_UP(sizeof *wqe, 16)));
+		FW_WR_FLOWID_V(qhp->ep->hwtid) |
+		FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*wqe), 16)));
 
 	wqe->u.terminate.type = FW_RI_TYPE_TERMINATE;
 	wqe->u.terminate.immdlen = cpu_to_be32(sizeof *term);
@@ -1204,11 +1204,11 @@ static int rdma_fini(struct c4iw_dev *rhp, struct c4iw_qp *qhp,
 	wqe = (struct fw_ri_wr *)__skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof *wqe);
 	wqe->op_compl = cpu_to_be32(
-		FW_WR_OP(FW_RI_INIT_WR) |
-		FW_WR_COMPL(1));
+		FW_WR_OP_V(FW_RI_INIT_WR) |
+		FW_WR_COMPL_F);
 	wqe->flowid_len16 = cpu_to_be32(
-		FW_WR_FLOWID(ep->hwtid) |
-		FW_WR_LEN16(DIV_ROUND_UP(sizeof *wqe, 16)));
+		FW_WR_FLOWID_V(ep->hwtid) |
+		FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*wqe), 16)));
 	wqe->cookie = (unsigned long) &ep->com.wr_wait;
 
 	wqe->u.fini.type = FW_RI_TYPE_FINI;
@@ -1273,11 +1273,11 @@ static int rdma_init(struct c4iw_dev *rhp, struct c4iw_qp *qhp)
 	wqe = (struct fw_ri_wr *)__skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof *wqe);
 	wqe->op_compl = cpu_to_be32(
-		FW_WR_OP(FW_RI_INIT_WR) |
-		FW_WR_COMPL(1));
+		FW_WR_OP_V(FW_RI_INIT_WR) |
+		FW_WR_COMPL_F);
 	wqe->flowid_len16 = cpu_to_be32(
-		FW_WR_FLOWID(qhp->ep->hwtid) |
-		FW_WR_LEN16(DIV_ROUND_UP(sizeof *wqe, 16)));
+		FW_WR_FLOWID_V(qhp->ep->hwtid) |
+		FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*wqe), 16)));
 
 	wqe->cookie = (unsigned long) &qhp->ep->com.wr_wait;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index dad1ea9..a2196bc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -354,7 +354,7 @@ struct link_config {
 	unsigned char  link_ok;          /* link up? */
 };
 
-#define FW_LEN16(fw_struct) FW_CMD_LEN16(sizeof(fw_struct) / 16)
+#define FW_LEN16(fw_struct) FW_CMD_LEN16_V(sizeof(fw_struct) / 16)
 
 enum {
 	MAX_ETH_QSETS = 32,           /* # of Ethernet Tx/Rx queue sets */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
index 2a6aa88..c0724a5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
@@ -42,9 +42,9 @@
 	do { \
 		memset(&(__pcmd), 0, sizeof(__pcmd)); \
 		(__pcmd).op_to_portid = \
-			cpu_to_be32(FW_CMD_OP(FW_PORT_CMD) | \
-				    FW_CMD_REQUEST | \
-				    FW_CMD_##__op | \
+			cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) | \
+				    FW_CMD_REQUEST_F | \
+				    FW_CMD_##__op##_F | \
 				    FW_PORT_CMD_PORTID(__port)); \
 		(__pcmd).action_to_len16 = \
 			cpu_to_be32(FW_PORT_CMD_ACTION(__action) | \
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a2d6e50..350f9c2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -833,7 +833,7 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 
 #ifdef CONFIG_CHELSIO_T4_DCB
 		const struct fw_port_cmd *pcmd = (const void *)p->data;
-		unsigned int cmd = FW_CMD_OP_GET(ntohl(pcmd->op_to_portid));
+		unsigned int cmd = FW_CMD_OP_G(ntohl(pcmd->op_to_portid));
 		unsigned int action =
 			FW_PORT_CMD_ACTION_GET(ntohl(pcmd->action_to_len16));
 
@@ -1340,8 +1340,8 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
 	 * filter specification structure but for now it's easiest to simply
 	 * put this fairly direct code in line ...
 	 */
-	fwr->op_pkd = htonl(FW_WR_OP(FW_FILTER_WR));
-	fwr->len16_pkd = htonl(FW_WR_LEN16(sizeof(*fwr)/16));
+	fwr->op_pkd = htonl(FW_WR_OP_V(FW_FILTER_WR));
+	fwr->len16_pkd = htonl(FW_WR_LEN16_V(sizeof(*fwr)/16));
 	fwr->tid_to_iq =
 		htonl(V_FW_FILTER_WR_TID(ftid) |
 		      V_FW_FILTER_WR_RQTYPE(f->fs.type) |
@@ -3417,8 +3417,8 @@ int cxgb4_clip_get(const struct net_device *dev,
 
 	adap = netdev2adap(dev);
 	memset(&c, 0, sizeof(c));
-	c.op_to_write = htonl(FW_CMD_OP(FW_CLIP_CMD) |
-			FW_CMD_REQUEST | FW_CMD_WRITE);
+	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
+			FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
 	c.alloc_to_len16 = htonl(F_FW_CLIP_CMD_ALLOC | FW_LEN16(c));
 	c.ip_hi = *(__be64 *)(lip->s6_addr);
 	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
@@ -3434,8 +3434,8 @@ int cxgb4_clip_release(const struct net_device *dev,
 
 	adap = netdev2adap(dev);
 	memset(&c, 0, sizeof(c));
-	c.op_to_write = htonl(FW_CMD_OP(FW_CLIP_CMD) |
-			FW_CMD_REQUEST | FW_CMD_READ);
+	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
+			FW_CMD_REQUEST_F | FW_CMD_READ_F);
 	c.alloc_to_len16 = htonl(F_FW_CLIP_CMD_FREE | FW_LEN16(c));
 	c.ip_hi = *(__be64 *)(lip->s6_addr);
 	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
@@ -4871,9 +4871,9 @@ static u32 t4_read_pcie_cfg4(struct adapter *adap, int reg)
 	 */
 	memset(&ldst_cmd, 0, sizeof(ldst_cmd));
 	ldst_cmd.op_to_addrspace =
-		htonl(FW_CMD_OP(FW_LDST_CMD) |
-		      FW_CMD_REQUEST |
-		      FW_CMD_READ |
+		htonl(FW_CMD_OP_V(FW_LDST_CMD) |
+		      FW_CMD_REQUEST_F |
+		      FW_CMD_READ_F |
 		      FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_FUNC_PCIE));
 	ldst_cmd.cycles_to_len16 = htonl(FW_LEN16(ldst_cmd));
 	ldst_cmd.u.pcie.select_naccess = FW_LDST_CMD_NACCESS(1);
@@ -4965,8 +4965,8 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 
 	/* get device capabilities */
 	memset(c, 0, sizeof(*c));
-	c->op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-			       FW_CMD_REQUEST | FW_CMD_READ);
+	c->op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+			       FW_CMD_REQUEST_F | FW_CMD_READ_F);
 	c->cfvalid_to_len16 = htonl(FW_LEN16(*c));
 	ret = t4_wr_mbox(adap, adap->fn, c, sizeof(*c), c);
 	if (ret < 0)
@@ -4982,8 +4982,8 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 		dev_err(adap->pdev_dev, "virtualization ACLs not supported");
 		return ret;
 	}
-	c->op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-			       FW_CMD_REQUEST | FW_CMD_WRITE);
+	c->op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+			       FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
 	ret = t4_wr_mbox(adap, adap->fn, c, sizeof(*c), NULL);
 	if (ret < 0)
 		return ret;
@@ -5209,9 +5209,9 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 	 */
 	memset(&caps_cmd, 0, sizeof(caps_cmd));
 	caps_cmd.op_to_write =
-		htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-		      FW_CMD_REQUEST |
-		      FW_CMD_READ);
+		htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+		      FW_CMD_REQUEST_F |
+		      FW_CMD_READ_F);
 	caps_cmd.cfvalid_to_len16 =
 		htonl(FW_CAPS_CONFIG_CMD_CFVALID |
 		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF(mtype) |
@@ -5229,9 +5229,9 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 	if (ret == -ENOENT) {
 		memset(&caps_cmd, 0, sizeof(caps_cmd));
 		caps_cmd.op_to_write =
-			htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-					FW_CMD_REQUEST |
-					FW_CMD_READ);
+			htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+					FW_CMD_REQUEST_F |
+					FW_CMD_READ_F);
 		caps_cmd.cfvalid_to_len16 = htonl(FW_LEN16(caps_cmd));
 		ret = t4_wr_mbox(adapter, adapter->mbox, &caps_cmd,
 				sizeof(caps_cmd), &caps_cmd);
@@ -5254,9 +5254,9 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 	 * And now tell the firmware to use the configuration we just loaded.
 	 */
 	caps_cmd.op_to_write =
-		htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-		      FW_CMD_REQUEST |
-		      FW_CMD_WRITE);
+		htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+		      FW_CMD_REQUEST_F |
+		      FW_CMD_WRITE_F);
 	caps_cmd.cfvalid_to_len16 = htonl(FW_LEN16(caps_cmd));
 	ret = t4_wr_mbox(adapter, adapter->mbox, &caps_cmd, sizeof(caps_cmd),
 			 NULL);
@@ -5327,8 +5327,8 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 	 * Get device capabilities and select which we'll be using.
 	 */
 	memset(&caps_cmd, 0, sizeof(caps_cmd));
-	caps_cmd.op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-				     FW_CMD_REQUEST | FW_CMD_READ);
+	caps_cmd.op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+				     FW_CMD_REQUEST_F | FW_CMD_READ_F);
 	caps_cmd.cfvalid_to_len16 = htonl(FW_LEN16(caps_cmd));
 	ret = t4_wr_mbox(adapter, adapter->mbox, &caps_cmd, sizeof(caps_cmd),
 			 &caps_cmd);
@@ -5344,8 +5344,8 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 		dev_err(adapter->pdev_dev, "virtualization ACLs not supported");
 		goto bye;
 	}
-	caps_cmd.op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-			      FW_CMD_REQUEST | FW_CMD_WRITE);
+	caps_cmd.op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+			      FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
 	ret = t4_wr_mbox(adapter, adapter->mbox, &caps_cmd, sizeof(caps_cmd),
 			 NULL);
 	if (ret < 0)
@@ -5713,7 +5713,6 @@ static int adap_init0(struct adapter *adap)
 	} else {
 		dev_info(adap->pdev_dev, "Coming up as MASTER: "\
 			 "Initializing adapter\n");
-
 		/*
 		 * If the firmware doesn't support Configuration
 		 * Files warn user and exit,
@@ -5757,6 +5756,7 @@ static int adap_init0(struct adapter *adap)
 					    "No Configuration File present "
 					    "on adapter. Using hard-wired "
 					    "configuration parameters.\n");
+					goto bye;
 					ret = adap_init0_no_config(adap, reset);
 				}
 			}
@@ -5856,8 +5856,8 @@ static int adap_init0(struct adapter *adap)
 	 * to manage.
 	 */
 	memset(&caps_cmd, 0, sizeof(caps_cmd));
-	caps_cmd.op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-				     FW_CMD_REQUEST | FW_CMD_READ);
+	caps_cmd.op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+				     FW_CMD_REQUEST_F | FW_CMD_READ_F);
 	caps_cmd.cfvalid_to_len16 = htonl(FW_LEN16(caps_cmd));
 	ret = t4_wr_mbox(adap, adap->mbox, &caps_cmd, sizeof(caps_cmd),
 			 &caps_cmd);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 1366ba6..4eba7cb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -52,10 +52,10 @@ enum {
 };
 
 #define INIT_TP_WR(w, tid) do { \
-	(w)->wr.wr_hi = htonl(FW_WR_OP(FW_TP_WR) | \
-			      FW_WR_IMMDLEN(sizeof(*w) - sizeof(w->wr))); \
-	(w)->wr.wr_mid = htonl(FW_WR_LEN16(DIV_ROUND_UP(sizeof(*w), 16)) | \
-			       FW_WR_FLOWID(tid)); \
+	(w)->wr.wr_hi = htonl(FW_WR_OP_V(FW_TP_WR) | \
+			      FW_WR_IMMDLEN_V(sizeof(*w) - sizeof(w->wr))); \
+	(w)->wr.wr_mid = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*w), 16)) | \
+			       FW_WR_FLOWID_V(tid)); \
 	(w)->wr.wr_lo = cpu_to_be64(0); \
 } while (0)
 
@@ -65,9 +65,10 @@ enum {
 } while (0)
 
 #define INIT_ULPTX_WR(w, wrlen, atomic, tid) do { \
-	(w)->wr.wr_hi = htonl(FW_WR_OP(FW_ULPTX_WR) | FW_WR_ATOMIC(atomic)); \
-	(w)->wr.wr_mid = htonl(FW_WR_LEN16(DIV_ROUND_UP(wrlen, 16)) | \
-			       FW_WR_FLOWID(tid)); \
+	(w)->wr.wr_hi = htonl(FW_WR_OP_V(FW_ULPTX_WR) | \
+			      FW_WR_ATOMIC_V(atomic)); \
+	(w)->wr.wr_mid = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(wrlen, 16)) | \
+			       FW_WR_FLOWID_V(tid)); \
 	(w)->wr.wr_lo = cpu_to_be64(0); \
 } while (0)
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 5e1b314..6399e00 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1092,10 +1092,10 @@ out_free:	dev_kfree_skb_any(skb);
 		goto out_free;
 	}
 
-	wr_mid = FW_WR_LEN16(DIV_ROUND_UP(flits, 2));
+	wr_mid = FW_WR_LEN16_V(DIV_ROUND_UP(flits, 2));
 	if (unlikely(credits < ETHTXQ_STOP_THRES)) {
 		eth_txq_stop(q);
-		wr_mid |= FW_WR_EQUEQ | FW_WR_EQUIQ;
+		wr_mid |= FW_WR_EQUEQ_F | FW_WR_EQUIQ_F;
 	}
 
 	wr = (void *)&q->q.desc[q->q.pidx];
@@ -1112,8 +1112,8 @@ out_free:	dev_kfree_skb_any(skb);
 		int eth_xtra_len = skb_network_offset(skb) - ETH_HLEN;
 
 		len += sizeof(*lso);
-		wr->op_immdlen = htonl(FW_WR_OP(FW_ETH_TX_PKT_WR) |
-				       FW_WR_IMMDLEN(len));
+		wr->op_immdlen = htonl(FW_WR_OP_V(FW_ETH_TX_PKT_WR) |
+				       FW_WR_IMMDLEN_V(len));
 		lso->c.lso_ctrl = htonl(LSO_OPCODE(CPL_TX_PKT_LSO) |
 					LSO_FIRST_SLICE | LSO_LAST_SLICE |
 					LSO_IPV6(v6) |
@@ -1135,8 +1135,8 @@ out_free:	dev_kfree_skb_any(skb);
 		q->tx_cso += ssi->gso_segs;
 	} else {
 		len += sizeof(*cpl);
-		wr->op_immdlen = htonl(FW_WR_OP(FW_ETH_TX_PKT_WR) |
-				       FW_WR_IMMDLEN(len));
+		wr->op_immdlen = htonl(FW_WR_OP_V(FW_ETH_TX_PKT_WR) |
+				       FW_WR_IMMDLEN_V(len));
 		cpl = (void *)(wr + 1);
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS;
@@ -1224,7 +1224,7 @@ static void ctrlq_check_stop(struct sge_ctrl_txq *q, struct fw_wr_hdr *wr)
 {
 	reclaim_completed_tx_imm(&q->q);
 	if (unlikely(txq_avail(&q->q) < TXQ_STOP_THRES)) {
-		wr->lo |= htonl(FW_WR_EQUEQ | FW_WR_EQUIQ);
+		wr->lo |= htonl(FW_WR_EQUEQ_F | FW_WR_EQUIQ_F);
 		q->q.stops++;
 		q->full = 1;
 	}
@@ -1406,7 +1406,7 @@ static void ofldtxq_stop(struct sge_ofld_txq *q, struct sk_buff *skb)
 {
 	struct fw_wr_hdr *wr = (struct fw_wr_hdr *)skb->data;
 
-	wr->lo |= htonl(FW_WR_EQUEQ | FW_WR_EQUIQ);
+	wr->lo |= htonl(FW_WR_EQUEQ_F | FW_WR_EQUIQ_F);
 	q->q.stops++;
 	q->full = 1;
 }
@@ -2297,8 +2297,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		return -ENOMEM;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_IQ_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_WRITE | FW_CMD_EXEC |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
 			    FW_IQ_CMD_PFN(adap->fn) | FW_IQ_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_IQ_CMD_ALLOC | FW_IQ_CMD_IQSTART(1) |
 				 FW_LEN16(c));
@@ -2423,8 +2423,8 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 		return -ENOMEM;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_ETH_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_WRITE | FW_CMD_EXEC |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_ETH_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
 			    FW_EQ_ETH_CMD_PFN(adap->fn) | FW_EQ_ETH_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_ALLOC |
 				 FW_EQ_ETH_CMD_EQSTART | FW_LEN16(c));
@@ -2476,8 +2476,8 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 	if (!txq->q.desc)
 		return -ENOMEM;
 
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_WRITE | FW_CMD_EXEC |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
 			    FW_EQ_CTRL_CMD_PFN(adap->fn) |
 			    FW_EQ_CTRL_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_ALLOC |
@@ -2530,8 +2530,8 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 		return -ENOMEM;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_WRITE | FW_CMD_EXEC |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
 			    FW_EQ_OFLD_CMD_PFN(adap->fn) |
 			    FW_EQ_OFLD_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC |
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 945fd14..2bb4efa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -310,16 +310,17 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 			}
 
 			res = t4_read_reg64(adap, data_reg);
-			if (FW_CMD_OP_GET(res >> 32) == FW_DEBUG_CMD) {
+			if (FW_CMD_OP_G(res >> 32) == FW_DEBUG_CMD) {
 				fw_asrt(adap, data_reg);
-				res = FW_CMD_RETVAL(EIO);
-			} else if (rpl)
+				res = FW_CMD_RETVAL_V(EIO);
+			} else if (rpl) {
 				get_mbox_rpl(adap, rpl, size / 8, data_reg);
+			}
 
-			if (FW_CMD_RETVAL_GET((int)res))
+			if (FW_CMD_RETVAL_G((int)res))
 				dump_mbox(adap, mbox, data_reg);
 			t4_write_reg(adap, ctl_reg, 0);
-			return -FW_CMD_RETVAL_GET((int)res);
+			return -FW_CMD_RETVAL_G((int)res);
 		}
 	}
 
@@ -1245,8 +1246,8 @@ int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
 		fc |= FW_PORT_CAP_FC_TX;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_portid = htonl(FW_CMD_OP(FW_PORT_CMD) | FW_CMD_REQUEST |
-			       FW_CMD_EXEC | FW_PORT_CMD_PORTID(port));
+	c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) | FW_CMD_REQUEST_F |
+			       FW_CMD_EXEC_F | FW_PORT_CMD_PORTID(port));
 	c.action_to_len16 = htonl(FW_PORT_CMD_ACTION(FW_PORT_ACTION_L1_CFG) |
 				  FW_LEN16(c));
 
@@ -1275,8 +1276,8 @@ int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port)
 	struct fw_port_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_portid = htonl(FW_CMD_OP(FW_PORT_CMD) | FW_CMD_REQUEST |
-			       FW_CMD_EXEC | FW_PORT_CMD_PORTID(port));
+	c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) | FW_CMD_REQUEST_F |
+			       FW_CMD_EXEC_F | FW_PORT_CMD_PORTID(port));
 	c.action_to_len16 = htonl(FW_PORT_CMD_ACTION(FW_PORT_ACTION_L1_CFG) |
 				  FW_LEN16(c));
 	c.u.l1cfg.rcap = htonl(FW_PORT_CAP_ANEG);
@@ -2071,8 +2072,8 @@ int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
 	struct fw_rss_ind_tbl_cmd cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = htonl(FW_CMD_OP(FW_RSS_IND_TBL_CMD) |
-			       FW_CMD_REQUEST | FW_CMD_WRITE |
+	cmd.op_to_viid = htonl(FW_CMD_OP_V(FW_RSS_IND_TBL_CMD) |
+			       FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
 			       FW_RSS_IND_TBL_CMD_VIID(viid));
 	cmd.retval_len16 = htonl(FW_LEN16(cmd));
 
@@ -2126,8 +2127,8 @@ int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
 	struct fw_rss_glb_config_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_write = htonl(FW_CMD_OP(FW_RSS_GLB_CONFIG_CMD) |
-			      FW_CMD_REQUEST | FW_CMD_WRITE);
+	c.op_to_write = htonl(FW_CMD_OP_V(FW_RSS_GLB_CONFIG_CMD) |
+			      FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
 	c.retval_len16 = htonl(FW_LEN16(c));
 	if (mode == FW_RSS_GLB_CONFIG_CMD_MODE_MANUAL) {
 		c.u.manual.mode_pkd = htonl(FW_RSS_GLB_CONFIG_CMD_MODE(mode));
@@ -2553,8 +2554,8 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 void t4_mk_filtdelwr(unsigned int ftid, struct fw_filter_wr *wr, int qid)
 {
 	memset(wr, 0, sizeof(*wr));
-	wr->op_pkd = htonl(FW_WR_OP(FW_FILTER_WR));
-	wr->len16_pkd = htonl(FW_WR_LEN16(sizeof(*wr) / 16));
+	wr->op_pkd = htonl(FW_WR_OP_V(FW_FILTER_WR));
+	wr->len16_pkd = htonl(FW_WR_LEN16_V(sizeof(*wr) / 16));
 	wr->tid_to_iq = htonl(V_FW_FILTER_WR_TID(ftid) |
 			V_FW_FILTER_WR_NOREPLY(qid < 0));
 	wr->del_filter_to_l2tix = htonl(F_FW_FILTER_WR_DEL_FILTER);
@@ -2563,8 +2564,8 @@ void t4_mk_filtdelwr(unsigned int ftid, struct fw_filter_wr *wr, int qid)
 }
 
 #define INIT_CMD(var, cmd, rd_wr) do { \
-	(var).op_to_write = htonl(FW_CMD_OP(FW_##cmd##_CMD) | \
-				  FW_CMD_REQUEST | FW_CMD_##rd_wr); \
+	(var).op_to_write = htonl(FW_CMD_OP_V(FW_##cmd##_CMD) | \
+				  FW_CMD_REQUEST_F | FW_CMD_##rd_wr##_F); \
 	(var).retval_len16 = htonl(FW_LEN16(var)); \
 } while (0)
 
@@ -2574,8 +2575,8 @@ int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
 	struct fw_ldst_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_addrspace = htonl(FW_CMD_OP(FW_LDST_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_WRITE |
+	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_WRITE_F |
 			    FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_FIRMWARE));
 	c.cycles_to_len16 = htonl(FW_LEN16(c));
 	c.u.addrval.addr = htonl(addr);
@@ -2602,8 +2603,8 @@ int t4_mdio_rd(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 	struct fw_ldst_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_addrspace = htonl(FW_CMD_OP(FW_LDST_CMD) | FW_CMD_REQUEST |
-		FW_CMD_READ | FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_MDIO));
+	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
+		FW_CMD_READ_F | FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_MDIO));
 	c.cycles_to_len16 = htonl(FW_LEN16(c));
 	c.u.mdio.paddr_mmd = htons(FW_LDST_CMD_PADDR(phy_addr) |
 				   FW_LDST_CMD_MMD(mmd));
@@ -2632,8 +2633,8 @@ int t4_mdio_wr(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 	struct fw_ldst_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_addrspace = htonl(FW_CMD_OP(FW_LDST_CMD) | FW_CMD_REQUEST |
-		FW_CMD_WRITE | FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_MDIO));
+	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
+		FW_CMD_WRITE_F | FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_MDIO));
 	c.cycles_to_len16 = htonl(FW_LEN16(c));
 	c.u.mdio.paddr_mmd = htons(FW_LDST_CMD_PADDR(phy_addr) |
 				   FW_LDST_CMD_MMD(mmd));
@@ -3211,8 +3212,8 @@ int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		return -EINVAL;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_PARAMS_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_READ | FW_PARAMS_CMD_PFN(pf) |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PARAMS_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_READ_F | FW_PARAMS_CMD_PFN(pf) |
 			    FW_PARAMS_CMD_VFN(vf));
 	c.retval_len16 = htonl(FW_LEN16(c));
 	for (i = 0; i < nparams; i++, p += 2)
@@ -3251,8 +3252,8 @@ int t4_set_params_nosleep(struct adapter *adap, unsigned int mbox,
 		return -EINVAL;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_PARAMS_CMD) |
-				FW_CMD_REQUEST | FW_CMD_WRITE |
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
+				FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
 				FW_PARAMS_CMD_PFN(pf) |
 				FW_PARAMS_CMD_VFN(vf));
 	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
@@ -3289,8 +3290,8 @@ int t4_set_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		return -EINVAL;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_PARAMS_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_WRITE | FW_PARAMS_CMD_PFN(pf) |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PARAMS_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_WRITE_F | FW_PARAMS_CMD_PFN(pf) |
 			    FW_PARAMS_CMD_VFN(vf));
 	c.retval_len16 = htonl(FW_LEN16(c));
 	while (nparams--) {
@@ -3331,8 +3332,8 @@ int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_pfvf_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_PFVF_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_WRITE | FW_PFVF_CMD_PFN(pf) |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PFVF_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_WRITE_F | FW_PFVF_CMD_PFN(pf) |
 			    FW_PFVF_CMD_VFN(vf));
 	c.retval_len16 = htonl(FW_LEN16(c));
 	c.niqflint_niq = htonl(FW_PFVF_CMD_NIQFLINT(rxqi) |
@@ -3373,8 +3374,8 @@ int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 	struct fw_vi_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_VI_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_WRITE | FW_CMD_EXEC |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_VI_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
 			    FW_VI_CMD_PFN(pf) | FW_VI_CMD_VFN(vf));
 	c.alloc_to_len16 = htonl(FW_VI_CMD_ALLOC | FW_LEN16(c));
 	c.portid_pkd = FW_VI_CMD_PORTID(port);
@@ -3435,8 +3436,8 @@ int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
 		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_MASK;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP(FW_VI_RXMODE_CMD) | FW_CMD_REQUEST |
-			     FW_CMD_WRITE | FW_VI_RXMODE_CMD_VIID(viid));
+	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_RXMODE_CMD) | FW_CMD_REQUEST_F |
+			     FW_CMD_WRITE_F | FW_VI_RXMODE_CMD_VIID(viid));
 	c.retval_len16 = htonl(FW_LEN16(c));
 	c.mtu_to_vlanexen = htonl(FW_VI_RXMODE_CMD_MTU(mtu) |
 				  FW_VI_RXMODE_CMD_PROMISCEN(promisc) |
@@ -3483,11 +3484,11 @@ int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 		return -EINVAL;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP(FW_VI_MAC_CMD) | FW_CMD_REQUEST |
-			     FW_CMD_WRITE | (free ? FW_CMD_EXEC : 0) |
+	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
+			     FW_CMD_WRITE_F | (free ? FW_CMD_EXEC_F : 0) |
 			     FW_VI_MAC_CMD_VIID(viid));
 	c.freemacs_to_len16 = htonl(FW_VI_MAC_CMD_FREEMACS(free) |
-				    FW_CMD_LEN16((naddr + 2) / 2));
+				    FW_CMD_LEN16_V((naddr + 2) / 2));
 
 	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
 		p->valid_to_idx = htons(FW_VI_MAC_CMD_VALID |
@@ -3546,9 +3547,9 @@ int t4_change_mac(struct adapter *adap, unsigned int mbox, unsigned int viid,
 	mode = add_smt ? FW_VI_MAC_SMT_AND_MPSTCAM : FW_VI_MAC_MPS_TCAM_ENTRY;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP(FW_VI_MAC_CMD) | FW_CMD_REQUEST |
-			     FW_CMD_WRITE | FW_VI_MAC_CMD_VIID(viid));
-	c.freemacs_to_len16 = htonl(FW_CMD_LEN16(1));
+	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
+			     FW_CMD_WRITE_F | FW_VI_MAC_CMD_VIID(viid));
+	c.freemacs_to_len16 = htonl(FW_CMD_LEN16_V(1));
 	p->valid_to_idx = htons(FW_VI_MAC_CMD_VALID |
 				FW_VI_MAC_CMD_SMAC_RESULT(mode) |
 				FW_VI_MAC_CMD_IDX(idx));
@@ -3580,11 +3581,11 @@ int t4_set_addr_hash(struct adapter *adap, unsigned int mbox, unsigned int viid,
 	struct fw_vi_mac_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP(FW_VI_MAC_CMD) | FW_CMD_REQUEST |
-			     FW_CMD_WRITE | FW_VI_ENABLE_CMD_VIID(viid));
+	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
+			     FW_CMD_WRITE_F | FW_VI_ENABLE_CMD_VIID(viid));
 	c.freemacs_to_len16 = htonl(FW_VI_MAC_CMD_HASHVECEN |
 				    FW_VI_MAC_CMD_HASHUNIEN(ucast) |
-				    FW_CMD_LEN16(1));
+				    FW_CMD_LEN16_V(1));
 	c.u.hash.hashvec = cpu_to_be64(vec);
 	return t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), NULL, sleep_ok);
 }
@@ -3607,8 +3608,8 @@ int t4_enable_vi_params(struct adapter *adap, unsigned int mbox,
 	struct fw_vi_enable_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST |
-			     FW_CMD_EXEC | FW_VI_ENABLE_CMD_VIID(viid));
+	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST_F |
+			     FW_CMD_EXEC_F | FW_VI_ENABLE_CMD_VIID(viid));
 
 	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_IEN(rx_en) |
 			       FW_VI_ENABLE_CMD_EEN(tx_en) | FW_LEN16(c) |
@@ -3647,8 +3648,8 @@ int t4_identify_port(struct adapter *adap, unsigned int mbox, unsigned int viid,
 	struct fw_vi_enable_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST |
-			     FW_CMD_EXEC | FW_VI_ENABLE_CMD_VIID(viid));
+	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST_F |
+			     FW_CMD_EXEC_F | FW_VI_ENABLE_CMD_VIID(viid));
 	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_LED | FW_LEN16(c));
 	c.blinkdur = htons(nblinks);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
@@ -3674,8 +3675,8 @@ int t4_iq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_iq_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_IQ_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_EXEC | FW_IQ_CMD_PFN(pf) |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_EXEC_F | FW_IQ_CMD_PFN(pf) |
 			    FW_IQ_CMD_VFN(vf));
 	c.alloc_to_len16 = htonl(FW_IQ_CMD_FREE | FW_LEN16(c));
 	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE(iqtype));
@@ -3701,8 +3702,8 @@ int t4_eth_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_eq_eth_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_ETH_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_EXEC | FW_EQ_ETH_CMD_PFN(pf) |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_ETH_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_EXEC_F | FW_EQ_ETH_CMD_PFN(pf) |
 			    FW_EQ_ETH_CMD_VFN(vf));
 	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_FREE | FW_LEN16(c));
 	c.eqid_pkd = htonl(FW_EQ_ETH_CMD_EQID(eqid));
@@ -3725,8 +3726,8 @@ int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_eq_ctrl_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_EXEC | FW_EQ_CTRL_CMD_PFN(pf) |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_EXEC_F | FW_EQ_CTRL_CMD_PFN(pf) |
 			    FW_EQ_CTRL_CMD_VFN(vf));
 	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_FREE | FW_LEN16(c));
 	c.cmpliqid_eqid = htonl(FW_EQ_CTRL_CMD_EQID(eqid));
@@ -3749,8 +3750,8 @@ int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_eq_ofld_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST |
-			    FW_CMD_EXEC | FW_EQ_OFLD_CMD_PFN(pf) |
+	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST_F |
+			    FW_CMD_EXEC_F | FW_EQ_OFLD_CMD_PFN(pf) |
 			    FW_EQ_OFLD_CMD_VFN(vf));
 	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_FREE | FW_LEN16(c));
 	c.eqid_pkd = htonl(FW_EQ_OFLD_CMD_EQID(eqid));
@@ -4082,8 +4083,8 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		while ((adap->params.portvec & (1 << j)) == 0)
 			j++;
 
-		c.op_to_portid = htonl(FW_CMD_OP(FW_PORT_CMD) |
-				       FW_CMD_REQUEST | FW_CMD_READ |
+		c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) |
+				       FW_CMD_REQUEST_F | FW_CMD_READ_F |
 				       FW_PORT_CMD_PORTID(j));
 		c.action_to_len16 = htonl(
 			FW_PORT_CMD_ACTION(FW_PORT_ACTION_GET_PORT_INFO) |
@@ -4109,8 +4110,8 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		p->port_type = FW_PORT_CMD_PTYPE_GET(ret);
 		p->mod_type = FW_PORT_MOD_TYPE_NA;
 
-		rvc.op_to_viid = htonl(FW_CMD_OP(FW_RSS_VI_CONFIG_CMD) |
-				       FW_CMD_REQUEST | FW_CMD_READ |
+		rvc.op_to_viid = htonl(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
+				       FW_CMD_REQUEST_F | FW_CMD_READ_F |
 				       FW_RSS_VI_CONFIG_CMD_VIID(p->viid));
 		rvc.retval_len16 = htonl(FW_LEN16(rvc));
 		ret = t4_wr_mbox(adap, mbox, &rvc, sizeof(rvc), &rvc);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 3409756..7cca67f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -109,18 +109,49 @@ struct fw_wr_hdr {
 	__be32 lo;
 };
 
-#define FW_WR_OP(x)	 ((x) << 24)
-#define FW_WR_OP_GET(x)	 (((x) >> 24) & 0xff)
-#define FW_WR_ATOMIC(x)	 ((x) << 23)
-#define FW_WR_FLUSH(x)   ((x) << 22)
-#define FW_WR_COMPL(x)   ((x) << 21)
-#define FW_WR_IMMDLEN_MASK 0xff
-#define FW_WR_IMMDLEN(x) ((x) << 0)
-
-#define FW_WR_EQUIQ	(1U << 31)
-#define FW_WR_EQUEQ	(1U << 30)
-#define FW_WR_FLOWID(x)	((x) << 8)
-#define FW_WR_LEN16(x)	((x) << 0)
+/* work request opcode (hi) */
+#define FW_WR_OP_S	24
+#define FW_WR_OP_M      0xff
+#define FW_WR_OP_V(x)   ((x) << FW_WR_OP_S)
+#define FW_WR_OP_G(x)   (((x) >> FW_WR_OP_S) & FW_WR_OP_M)
+
+/* atomic flag (hi) - firmware encapsulates CPLs in CPL_BARRIER */
+#define FW_WR_ATOMIC_S		23
+#define FW_WR_ATOMIC_V(x)	((x) << FW_WR_ATOMIC_S)
+
+/* flush flag (hi) - firmware flushes flushable work request buffered
+ * in the flow context.
+ */
+#define FW_WR_FLUSH_S     22
+#define FW_WR_FLUSH_V(x)  ((x) << FW_WR_FLUSH_S)
+
+/* completion flag (hi) - firmware generates a cpl_fw6_ack */
+#define FW_WR_COMPL_S     21
+#define FW_WR_COMPL_V(x)  ((x) << FW_WR_COMPL_S)
+#define FW_WR_COMPL_F     FW_WR_COMPL_V(1U)
+
+/* work request immediate data length (hi) */
+#define FW_WR_IMMDLEN_S 0
+#define FW_WR_IMMDLEN_M 0xff
+#define FW_WR_IMMDLEN_V(x)      ((x) << FW_WR_IMMDLEN_S)
+
+/* egress queue status update to associated ingress queue entry (lo) */
+#define FW_WR_EQUIQ_S           31
+#define FW_WR_EQUIQ_V(x)        ((x) << FW_WR_EQUIQ_S)
+#define FW_WR_EQUIQ_F           FW_WR_EQUIQ_V(1U)
+
+/* egress queue status update to egress queue status entry (lo) */
+#define FW_WR_EQUEQ_S           30
+#define FW_WR_EQUEQ_V(x)        ((x) << FW_WR_EQUEQ_S)
+#define FW_WR_EQUEQ_F           FW_WR_EQUEQ_V(1U)
+
+/* flow context identifier (lo) */
+#define FW_WR_FLOWID_S          8
+#define FW_WR_FLOWID_V(x)       ((x) << FW_WR_FLOWID_S)
+
+/* length in units of 16-bytes (lo) */
+#define FW_WR_LEN16_S           0
+#define FW_WR_LEN16_V(x)        ((x) << FW_WR_LEN16_S)
 
 #define HW_TPL_FR_MT_PR_IV_P_FC         0X32B
 #define HW_TPL_FR_MT_PR_OV_P_FC         0X327
@@ -539,26 +570,47 @@ struct fw_flowc_mnemval {
 
 struct fw_flowc_wr {
 	__be32 op_to_nparams;
-#define FW_FLOWC_WR_NPARAMS(x)	((x) << 0)
 	__be32 flowid_len16;
 	struct fw_flowc_mnemval mnemval[0];
 };
 
+#define FW_FLOWC_WR_NPARAMS_S           0
+#define FW_FLOWC_WR_NPARAMS_V(x)        ((x) << FW_FLOWC_WR_NPARAMS_S)
+
 struct fw_ofld_tx_data_wr {
 	__be32 op_to_immdlen;
 	__be32 flowid_len16;
 	__be32 plen;
 	__be32 tunnel_to_proxy;
-#define FW_OFLD_TX_DATA_WR_TUNNEL(x)	 ((x) << 19)
-#define FW_OFLD_TX_DATA_WR_SAVE(x)	 ((x) << 18)
-#define FW_OFLD_TX_DATA_WR_FLUSH(x)	 ((x) << 17)
-#define FW_OFLD_TX_DATA_WR_URGENT(x)	 ((x) << 16)
-#define FW_OFLD_TX_DATA_WR_MORE(x)	 ((x) << 15)
-#define FW_OFLD_TX_DATA_WR_SHOVE(x)	 ((x) << 14)
-#define FW_OFLD_TX_DATA_WR_ULPMODE(x)	 ((x) << 10)
-#define FW_OFLD_TX_DATA_WR_ULPSUBMODE(x) ((x) << 6)
 };
 
+#define FW_OFLD_TX_DATA_WR_TUNNEL_S     19
+#define FW_OFLD_TX_DATA_WR_TUNNEL_V(x)  ((x) << FW_OFLD_TX_DATA_WR_TUNNEL_S)
+
+#define FW_OFLD_TX_DATA_WR_SAVE_S       18
+#define FW_OFLD_TX_DATA_WR_SAVE_V(x)    ((x) << FW_OFLD_TX_DATA_WR_SAVE_S)
+
+#define FW_OFLD_TX_DATA_WR_FLUSH_S      17
+#define FW_OFLD_TX_DATA_WR_FLUSH_V(x)   ((x) << FW_OFLD_TX_DATA_WR_FLUSH_S)
+#define FW_OFLD_TX_DATA_WR_FLUSH_F      FW_OFLD_TX_DATA_WR_FLUSH_V(1U)
+
+#define FW_OFLD_TX_DATA_WR_URGENT_S     16
+#define FW_OFLD_TX_DATA_WR_URGENT_V(x)  ((x) << FW_OFLD_TX_DATA_WR_URGENT_S)
+
+#define FW_OFLD_TX_DATA_WR_MORE_S       15
+#define FW_OFLD_TX_DATA_WR_MORE_V(x)    ((x) << FW_OFLD_TX_DATA_WR_MORE_S)
+
+#define FW_OFLD_TX_DATA_WR_SHOVE_S      14
+#define FW_OFLD_TX_DATA_WR_SHOVE_V(x)   ((x) << FW_OFLD_TX_DATA_WR_SHOVE_S)
+#define FW_OFLD_TX_DATA_WR_SHOVE_F      FW_OFLD_TX_DATA_WR_SHOVE_V(1U)
+
+#define FW_OFLD_TX_DATA_WR_ULPMODE_S    10
+#define FW_OFLD_TX_DATA_WR_ULPMODE_V(x) ((x) << FW_OFLD_TX_DATA_WR_ULPMODE_S)
+
+#define FW_OFLD_TX_DATA_WR_ULPSUBMODE_S         6
+#define FW_OFLD_TX_DATA_WR_ULPSUBMODE_V(x)      \
+	((x) << FW_OFLD_TX_DATA_WR_ULPSUBMODE_S)
+
 struct fw_cmd_wr {
 	__be32 op_dma;
 #define FW_CMD_WR_DMA (1U << 17)
@@ -566,6 +618,9 @@ struct fw_cmd_wr {
 	__be64 cookie_daddr;
 };
 
+#define FW_CMD_WR_DMA_S         17
+#define FW_CMD_WR_DMA_V(x)      ((x) << FW_CMD_WR_DMA_S)
+
 struct fw_eth_tx_pkt_vm_wr {
 	__be32 op_immdlen;
 	__be32 equiq_to_len16;
@@ -641,18 +696,39 @@ struct fw_cmd_hdr {
 	__be32 lo;
 };
 
-#define FW_CMD_OP(x)		((x) << 24)
-#define FW_CMD_OP_GET(x)        (((x) >> 24) & 0xff)
-#define FW_CMD_REQUEST          (1U << 23)
-#define FW_CMD_REQUEST_GET(x)   (((x) >> 23) & 0x1)
-#define FW_CMD_READ		(1U << 22)
-#define FW_CMD_WRITE		(1U << 21)
-#define FW_CMD_EXEC		(1U << 20)
-#define FW_CMD_RAMASK(x)	((x) << 20)
-#define FW_CMD_RETVAL(x)	((x) << 8)
-#define FW_CMD_RETVAL_GET(x)	(((x) >> 8) & 0xff)
-#define FW_CMD_LEN16(x)         ((x) << 0)
-#define FW_LEN16(fw_struct)	FW_CMD_LEN16(sizeof(fw_struct) / 16)
+#define FW_CMD_OP_S             24
+#define FW_CMD_OP_M             0xff
+#define FW_CMD_OP_V(x)          ((x) << FW_CMD_OP_S)
+#define FW_CMD_OP_G(x)          (((x) >> FW_CMD_OP_S) & FW_CMD_OP_M)
+
+#define FW_CMD_REQUEST_S        23
+#define FW_CMD_REQUEST_V(x)     ((x) << FW_CMD_REQUEST_S)
+#define FW_CMD_REQUEST_F        FW_CMD_REQUEST_V(1U)
+
+#define FW_CMD_READ_S           22
+#define FW_CMD_READ_V(x)        ((x) << FW_CMD_READ_S)
+#define FW_CMD_READ_F           FW_CMD_READ_V(1U)
+
+#define FW_CMD_WRITE_S          21
+#define FW_CMD_WRITE_V(x)       ((x) << FW_CMD_WRITE_S)
+#define FW_CMD_WRITE_F          FW_CMD_WRITE_V(1U)
+
+#define FW_CMD_EXEC_S           20
+#define FW_CMD_EXEC_V(x)        ((x) << FW_CMD_EXEC_S)
+#define FW_CMD_EXEC_F           FW_CMD_EXEC_V(1U)
+
+#define FW_CMD_RAMASK_S         20
+#define FW_CMD_RAMASK_V(x)      ((x) << FW_CMD_RAMASK_S)
+
+#define FW_CMD_RETVAL_S         8
+#define FW_CMD_RETVAL_M         0xff
+#define FW_CMD_RETVAL_V(x)      ((x) << FW_CMD_RETVAL_S)
+#define FW_CMD_RETVAL_G(x)      (((x) >> FW_CMD_RETVAL_S) & FW_CMD_RETVAL_M)
+
+#define FW_CMD_LEN16_S          0
+#define FW_CMD_LEN16_V(x)       ((x) << FW_CMD_LEN16_S)
+
+#define FW_LEN16(fw_struct)	FW_CMD_LEN16_V(sizeof(fw_struct) / 16)
 
 enum fw_ldst_addrspc {
 	FW_LDST_ADDRSPC_FIRMWARE  = 0x0001,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 85036e6..0e8d5b7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -132,7 +132,7 @@ enum {
 	 * we can specify for immediate data in the firmware Ethernet TX
 	 * Work Request.
 	 */
-	MAX_IMM_TX_PKT_LEN = FW_WR_IMMDLEN_MASK,
+	MAX_IMM_TX_PKT_LEN = FW_WR_IMMDLEN_M,
 
 	/*
 	 * Max size of a WR sent through a control TX queue.
@@ -1149,7 +1149,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_free;
 	}
 
-	wr_mid = FW_WR_LEN16(DIV_ROUND_UP(flits, 2));
+	wr_mid = FW_WR_LEN16_V(DIV_ROUND_UP(flits, 2));
 	if (unlikely(credits < ETHTXQ_STOP_THRES)) {
 		/*
 		 * After we're done injecting the Work Request for this
@@ -1161,7 +1161,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * has opened up.
 		 */
 		txq_stop(txq);
-		wr_mid |= FW_WR_EQUEQ | FW_WR_EQUIQ;
+		wr_mid |= FW_WR_EQUEQ_F | FW_WR_EQUIQ_F;
 	}
 
 	/*
@@ -1191,9 +1191,9 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		int eth_xtra_len = skb_network_offset(skb) - ETH_HLEN;
 
 		wr->op_immdlen =
-			cpu_to_be32(FW_WR_OP(FW_ETH_TX_PKT_VM_WR) |
-				    FW_WR_IMMDLEN(sizeof(*lso) +
-						  sizeof(*cpl)));
+			cpu_to_be32(FW_WR_OP_V(FW_ETH_TX_PKT_VM_WR) |
+				    FW_WR_IMMDLEN_V(sizeof(*lso) +
+						    sizeof(*cpl)));
 		/*
 		 * Fill in the LSO CPL message.
 		 */
@@ -1228,8 +1228,8 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		len = is_eth_imm(skb) ? skb->len + sizeof(*cpl) : sizeof(*cpl);
 		wr->op_immdlen =
-			cpu_to_be32(FW_WR_OP(FW_ETH_TX_PKT_VM_WR) |
-				    FW_WR_IMMDLEN(len));
+			cpu_to_be32(FW_WR_OP_V(FW_ETH_TX_PKT_VM_WR) |
+				    FW_WR_IMMDLEN_V(len));
 
 		/*
 		 * Set up TX Packet CPL pointer, control word and perform
@@ -2084,10 +2084,10 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 	 * into OS-independent common code ...
 	 */
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_IQ_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_WRITE |
-				    FW_CMD_EXEC);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_IQ_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_WRITE_F |
+				    FW_CMD_EXEC_F);
 	cmd.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_ALLOC |
 					 FW_IQ_CMD_IQSTART(1) |
 					 FW_LEN16(cmd));
@@ -2246,10 +2246,10 @@ int t4vf_sge_alloc_eth_txq(struct adapter *adapter, struct sge_eth_txq *txq,
 	 * into the common code ...
 	 */
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_EQ_ETH_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_WRITE |
-				    FW_CMD_EXEC);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_EQ_ETH_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_WRITE_F |
+				    FW_CMD_EXEC_F);
 	cmd.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_ALLOC |
 					 FW_EQ_ETH_CMD_EQSTART |
 					 FW_LEN16(cmd));
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 95df61d..2cfa439 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -67,7 +67,7 @@ enum chip_type {
 /*
  * The "len16" field of a Firmware Command Structure ...
  */
-#define FW_LEN16(fw_struct) FW_CMD_LEN16(sizeof(fw_struct) / 16)
+#define FW_LEN16(fw_struct) FW_CMD_LEN16_V(sizeof(fw_struct) / 16)
 
 /*
  * Per-VF statistics.
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index e984fdc..570b895 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -204,20 +204,20 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 
 			/* return value in low-order little-endian word */
 			v = t4_read_reg(adapter, mbox_data);
-			if (FW_CMD_RETVAL_GET(v))
+			if (FW_CMD_RETVAL_G(v))
 				dump_mbox(adapter, "FW Error", mbox_data);
 
 			if (rpl) {
 				/* request bit in high-order BE word */
 				WARN_ON((be32_to_cpu(*(const u32 *)cmd)
-					 & FW_CMD_REQUEST) == 0);
+					 & FW_CMD_REQUEST_F) == 0);
 				get_mbox_rpl(adapter, rpl, size, mbox_data);
 				WARN_ON((be32_to_cpu(*(u32 *)rpl)
-					 & FW_CMD_REQUEST) != 0);
+					 & FW_CMD_REQUEST_F) != 0);
 			}
 			t4_write_reg(adapter, mbox_ctl,
 				     MBOWNER(MBOX_OWNER_NONE));
-			return -FW_CMD_RETVAL_GET(v);
+			return -FW_CMD_RETVAL_G(v);
 		}
 	}
 
@@ -287,9 +287,9 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
 	 * like MAC address, etc.
 	 */
 	memset(&vi_cmd, 0, sizeof(vi_cmd));
-	vi_cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_VI_CMD) |
-				       FW_CMD_REQUEST |
-				       FW_CMD_READ);
+	vi_cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_VI_CMD) |
+				       FW_CMD_REQUEST_F |
+				       FW_CMD_READ_F);
 	vi_cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(vi_cmd));
 	vi_cmd.type_viid = cpu_to_be16(FW_VI_CMD_VIID(pi->viid));
 	v = t4vf_wr_mbox(adapter, &vi_cmd, sizeof(vi_cmd), &vi_rpl);
@@ -308,9 +308,9 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
 		return 0;
 
 	memset(&port_cmd, 0, sizeof(port_cmd));
-	port_cmd.op_to_portid = cpu_to_be32(FW_CMD_OP(FW_PORT_CMD) |
-					    FW_CMD_REQUEST |
-					    FW_CMD_READ |
+	port_cmd.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
+					    FW_CMD_REQUEST_F |
+					    FW_CMD_READ_F |
 					    FW_PORT_CMD_PORTID(pi->port_id));
 	port_cmd.action_to_len16 =
 		cpu_to_be32(FW_PORT_CMD_ACTION(FW_PORT_ACTION_GET_PORT_INFO) |
@@ -349,8 +349,8 @@ int t4vf_fw_reset(struct adapter *adapter)
 	struct fw_reset_cmd cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_write = cpu_to_be32(FW_CMD_OP(FW_RESET_CMD) |
-				      FW_CMD_WRITE);
+	cmd.op_to_write = cpu_to_be32(FW_CMD_OP_V(FW_RESET_CMD) |
+				      FW_CMD_WRITE_F);
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
 }
@@ -377,12 +377,12 @@ static int t4vf_query_params(struct adapter *adapter, unsigned int nparams,
 		return -EINVAL;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_PARAMS_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_READ);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_READ_F);
 	len16 = DIV_ROUND_UP(offsetof(struct fw_params_cmd,
 				      param[nparams].mnem), 16);
-	cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16(len16));
+	cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(len16));
 	for (i = 0, p = &cmd.param[0]; i < nparams; i++, p++)
 		p->mnem = htonl(*params++);
 
@@ -415,12 +415,12 @@ int t4vf_set_params(struct adapter *adapter, unsigned int nparams,
 		return -EINVAL;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_PARAMS_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_WRITE);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_WRITE_F);
 	len16 = DIV_ROUND_UP(offsetof(struct fw_params_cmd,
 				      param[nparams]), 16);
-	cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16(len16));
+	cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(len16));
 	for (i = 0, p = &cmd.param[0]; i < nparams; i++, p++) {
 		p->mnem = cpu_to_be32(*params++);
 		p->val = cpu_to_be32(*vals++);
@@ -545,9 +545,9 @@ int t4vf_get_rss_glb_config(struct adapter *adapter)
 	 * our RSS configuration.
 	 */
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_write = cpu_to_be32(FW_CMD_OP(FW_RSS_GLB_CONFIG_CMD) |
-				      FW_CMD_REQUEST |
-				      FW_CMD_READ);
+	cmd.op_to_write = cpu_to_be32(FW_CMD_OP_V(FW_RSS_GLB_CONFIG_CMD) |
+				      FW_CMD_REQUEST_F |
+				      FW_CMD_READ_F);
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 	v = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
 	if (v)
@@ -621,9 +621,9 @@ int t4vf_get_vfres(struct adapter *adapter)
 	 * with error on command failure.
 	 */
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_PFVF_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_READ);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PFVF_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_READ_F);
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 	v = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
 	if (v)
@@ -669,9 +669,9 @@ int t4vf_read_rss_vi_config(struct adapter *adapter, unsigned int viid,
 	int v;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_RSS_VI_CONFIG_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_READ |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_READ_F |
 				     FW_RSS_VI_CONFIG_CMD_VIID(viid));
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 	v = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
@@ -719,9 +719,9 @@ int t4vf_write_rss_vi_config(struct adapter *adapter, unsigned int viid,
 	struct fw_rss_vi_config_cmd cmd, rpl;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_RSS_VI_CONFIG_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_WRITE |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
 				     FW_RSS_VI_CONFIG_CMD_VIID(viid));
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 	switch (adapter->params.rss.mode) {
@@ -777,9 +777,9 @@ int t4vf_config_rss_range(struct adapter *adapter, unsigned int viid,
 	 * Initialize firmware command template to write the RSS table.
 	 */
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_RSS_IND_TBL_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_WRITE |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_RSS_IND_TBL_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
 				     FW_RSS_IND_TBL_CMD_VIID(viid));
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 
@@ -866,10 +866,10 @@ int t4vf_alloc_vi(struct adapter *adapter, int port_id)
 	 * VIID.
 	 */
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_VI_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_WRITE |
-				    FW_CMD_EXEC);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_VI_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_WRITE_F |
+				    FW_CMD_EXEC_F);
 	cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(cmd) |
 					 FW_VI_CMD_ALLOC);
 	cmd.portid_pkd = FW_VI_CMD_PORTID(port_id);
@@ -896,9 +896,9 @@ int t4vf_free_vi(struct adapter *adapter, int viid)
 	 * Execute a VI command to free the Virtual Interface.
 	 */
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_VI_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_EXEC);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_VI_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_EXEC_F);
 	cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(cmd) |
 					 FW_VI_CMD_FREE);
 	cmd.type_viid = cpu_to_be16(FW_VI_CMD_VIID(viid));
@@ -920,9 +920,9 @@ int t4vf_enable_vi(struct adapter *adapter, unsigned int viid,
 	struct fw_vi_enable_cmd cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_ENABLE_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_EXEC |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_ENABLE_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_EXEC_F |
 				     FW_VI_ENABLE_CMD_VIID(viid));
 	cmd.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_IEN(rx_en) |
 				       FW_VI_ENABLE_CMD_EEN(tx_en) |
@@ -944,9 +944,9 @@ int t4vf_identify_port(struct adapter *adapter, unsigned int viid,
 	struct fw_vi_enable_cmd cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_ENABLE_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_EXEC |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_ENABLE_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_EXEC_F |
 				     FW_VI_ENABLE_CMD_VIID(viid));
 	cmd.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_LED |
 				       FW_LEN16(cmd));
@@ -986,9 +986,9 @@ int t4vf_set_rxmode(struct adapter *adapter, unsigned int viid,
 		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_MASK;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_RXMODE_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_WRITE |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_RXMODE_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
 				     FW_VI_RXMODE_CMD_VIID(viid));
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 	cmd.mtu_to_vlanexen =
@@ -1046,14 +1046,14 @@ int t4vf_alloc_mac_filt(struct adapter *adapter, unsigned int viid, bool free,
 		int i;
 
 		memset(&cmd, 0, sizeof(cmd));
-		cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_MAC_CMD) |
-					     FW_CMD_REQUEST |
-					     FW_CMD_WRITE |
-					     (free ? FW_CMD_EXEC : 0) |
+		cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+					     FW_CMD_REQUEST_F |
+					     FW_CMD_WRITE_F |
+					     (free ? FW_CMD_EXEC_F : 0) |
 					     FW_VI_MAC_CMD_VIID(viid));
 		cmd.freemacs_to_len16 =
 			cpu_to_be32(FW_VI_MAC_CMD_FREEMACS(free) |
-				    FW_CMD_LEN16(len16));
+				    FW_CMD_LEN16_V(len16));
 
 		for (i = 0, p = cmd.u.exact; i < fw_naddr; i++, p++) {
 			p->valid_to_idx = cpu_to_be16(
@@ -1135,11 +1135,11 @@ int t4vf_change_mac(struct adapter *adapter, unsigned int viid,
 		idx = persist ? FW_VI_MAC_ADD_PERSIST_MAC : FW_VI_MAC_ADD_MAC;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_MAC_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_WRITE |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
 				     FW_VI_MAC_CMD_VIID(viid));
-	cmd.freemacs_to_len16 = cpu_to_be32(FW_CMD_LEN16(len16));
+	cmd.freemacs_to_len16 = cpu_to_be32(FW_CMD_LEN16_V(len16));
 	p->valid_to_idx = cpu_to_be16(FW_VI_MAC_CMD_VALID |
 				      FW_VI_MAC_CMD_IDX(idx));
 	memcpy(p->macaddr, addr, sizeof(p->macaddr));
@@ -1172,13 +1172,13 @@ int t4vf_set_addr_hash(struct adapter *adapter, unsigned int viid,
 					     u.exact[0]), 16);
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_MAC_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_WRITE |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
 				     FW_VI_ENABLE_CMD_VIID(viid));
 	cmd.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_HASHVECEN |
 					    FW_VI_MAC_CMD_HASHUNIEN(ucast) |
-					    FW_CMD_LEN16(len16));
+					    FW_CMD_LEN16_V(len16));
 	cmd.u.hash.hashvec = cpu_to_be64(vec);
 	return t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), NULL, sleep_ok);
 }
@@ -1214,11 +1214,11 @@ int t4vf_get_port_stats(struct adapter *adapter, int pidx,
 		int ret;
 
 		memset(&cmd, 0, sizeof(cmd));
-		cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_STATS_CMD) |
+		cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_STATS_CMD) |
 					     FW_VI_STATS_CMD_VIID(pi->viid) |
-					     FW_CMD_REQUEST |
-					     FW_CMD_READ);
-		cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16(len16));
+					     FW_CMD_REQUEST_F |
+					     FW_CMD_READ_F);
+		cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(len16));
 		cmd.u.ctl.nstats_ix =
 			cpu_to_be16(FW_VI_STATS_CMD_IX(ix) |
 				    FW_VI_STATS_CMD_NSTATS(nstats));
@@ -1273,9 +1273,9 @@ int t4vf_iq_free(struct adapter *adapter, unsigned int iqtype,
 	struct fw_iq_cmd cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_IQ_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_EXEC);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_IQ_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_EXEC_F);
 	cmd.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_FREE |
 					 FW_LEN16(cmd));
 	cmd.type_to_iqandstindex =
@@ -1299,9 +1299,9 @@ int t4vf_eth_eq_free(struct adapter *adapter, unsigned int eqid)
 	struct fw_eq_eth_cmd cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_EQ_ETH_CMD) |
-				    FW_CMD_REQUEST |
-				    FW_CMD_EXEC);
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_EQ_ETH_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_EXEC_F);
 	cmd.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_FREE |
 					 FW_LEN16(cmd));
 	cmd.eqid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_EQID(eqid));
@@ -1318,7 +1318,7 @@ int t4vf_eth_eq_free(struct adapter *adapter, unsigned int eqid)
 int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 {
 	const struct fw_cmd_hdr *cmd_hdr = (const struct fw_cmd_hdr *)rpl;
-	u8 opcode = FW_CMD_OP_GET(be32_to_cpu(cmd_hdr->hi));
+	u8 opcode = FW_CMD_OP_G(be32_to_cpu(cmd_hdr->hi));
 
 	switch (opcode) {
 	case FW_PORT_CMD: {
diff --git a/drivers/scsi/csiostor/csio_attr.c b/drivers/scsi/csiostor/csio_attr.c
index 065a87a..2d1c4eb 100644
--- a/drivers/scsi/csiostor/csio_attr.c
+++ b/drivers/scsi/csiostor/csio_attr.c
@@ -451,9 +451,9 @@ csio_fcoe_alloc_vnp(struct csio_hw *hw, struct csio_lnode *ln)
 
 	/* Process Mbox response of VNP command */
 	rsp = (struct fw_fcoe_vnp_cmd *)(mbp->mb);
-	if (FW_CMD_RETVAL_GET(ntohl(rsp->alloc_to_len16)) != FW_SUCCESS) {
+	if (FW_CMD_RETVAL_G(ntohl(rsp->alloc_to_len16)) != FW_SUCCESS) {
 		csio_ln_err(ln, "FCOE VNP ALLOC cmd returned 0x%x!\n",
-			    FW_CMD_RETVAL_GET(ntohl(rsp->alloc_to_len16)));
+			    FW_CMD_RETVAL_G(ntohl(rsp->alloc_to_len16)));
 		ret = -EINVAL;
 		goto out_free;
 	}
@@ -526,9 +526,9 @@ csio_fcoe_free_vnp(struct csio_hw *hw, struct csio_lnode *ln)
 
 	/* Process Mbox response of VNP command */
 	rsp = (struct fw_fcoe_vnp_cmd *)(mbp->mb);
-	if (FW_CMD_RETVAL_GET(ntohl(rsp->alloc_to_len16)) != FW_SUCCESS) {
+	if (FW_CMD_RETVAL_G(ntohl(rsp->alloc_to_len16)) != FW_SUCCESS) {
 		csio_ln_err(ln, "FCOE VNP FREE cmd returned 0x%x!\n",
-			    FW_CMD_RETVAL_GET(ntohl(rsp->alloc_to_len16)));
+			    FW_CMD_RETVAL_G(ntohl(rsp->alloc_to_len16)));
 		ret = -EINVAL;
 	}
 
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 0eaec47..5f06877 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -1370,9 +1370,9 @@ csio_hw_fw_config_file(struct csio_hw *hw,
 	caps_cmd = (struct fw_caps_config_cmd *)(mbp->mb);
 	CSIO_INIT_MBP(mbp, caps_cmd, CSIO_MB_DEFAULT_TMO, hw, NULL, 1);
 	caps_cmd->op_to_write =
-		htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-		      FW_CMD_REQUEST |
-		      FW_CMD_READ);
+		htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+		      FW_CMD_REQUEST_F |
+		      FW_CMD_READ_F);
 	caps_cmd->cfvalid_to_len16 =
 		htonl(FW_CAPS_CONFIG_CMD_CFVALID |
 		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF(mtype) |
@@ -1407,9 +1407,9 @@ csio_hw_fw_config_file(struct csio_hw *hw,
 	 * And now tell the firmware to use the configuration we just loaded.
 	 */
 	caps_cmd->op_to_write =
-		htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-		      FW_CMD_REQUEST |
-		      FW_CMD_WRITE);
+		htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+		      FW_CMD_REQUEST_F |
+		      FW_CMD_WRITE_F);
 	caps_cmd->cfvalid_to_len16 = htonl(FW_LEN16(*caps_cmd));
 
 	if (csio_mb_issue(hw, mbp)) {
@@ -1678,7 +1678,7 @@ csio_get_fcoe_resinfo(struct csio_hw *hw)
 	}
 
 	rsp = (struct fw_fcoe_res_info_cmd *)(mbp->mb);
-	retval = FW_CMD_RETVAL_GET(ntohl(rsp->retval_len16));
+	retval = FW_CMD_RETVAL_G(ntohl(rsp->retval_len16));
 	if (retval != FW_SUCCESS) {
 		csio_err(hw, "FW_FCOE_RES_INFO_CMD failed with ret x%x\n",
 			 retval);
diff --git a/drivers/scsi/csiostor/csio_lnode.c b/drivers/scsi/csiostor/csio_lnode.c
index ffe9be0..48e45b1 100644
--- a/drivers/scsi/csiostor/csio_lnode.c
+++ b/drivers/scsi/csiostor/csio_lnode.c
@@ -603,7 +603,7 @@ csio_ln_vnp_read_cbfn(struct csio_hw *hw, struct csio_mb *mbp)
 	enum fw_retval retval;
 	__be32 nport_id;
 
-	retval = FW_CMD_RETVAL_GET(ntohl(rsp->alloc_to_len16));
+	retval = FW_CMD_RETVAL_G(ntohl(rsp->alloc_to_len16));
 	if (retval != FW_SUCCESS) {
 		csio_err(hw, "FCOE VNP read cmd returned error:0x%x\n", retval);
 		mempool_free(mbp, hw->mb_mempool);
@@ -770,7 +770,7 @@ csio_ln_read_fcf_cbfn(struct csio_hw *hw, struct csio_mb *mbp)
 				(struct fw_fcoe_fcf_cmd *)(mbp->mb);
 	enum fw_retval retval;
 
-	retval = FW_CMD_RETVAL_GET(ntohl(rsp->retval_len16));
+	retval = FW_CMD_RETVAL_G(ntohl(rsp->retval_len16));
 	if (retval != FW_SUCCESS) {
 		csio_ln_err(ln, "FCOE FCF cmd failed with ret x%x\n",
 				retval);
@@ -1506,7 +1506,7 @@ csio_fcoe_fwevt_handler(struct csio_hw *hw, __u8 cpl_op, __be64 *cmd)
 		}
 	} else if (cpl_op == CPL_FW6_PLD) {
 		wr = (struct fw_wr_hdr *) (cmd + 4);
-		if (FW_WR_OP_GET(be32_to_cpu(wr->hi))
+		if (FW_WR_OP_G(be32_to_cpu(wr->hi))
 			== FW_RDEV_WR) {
 
 			rdev_wr = (struct fw_rdev_wr *) (cmd + 4);
@@ -1574,17 +1574,17 @@ out_pld:
 			return;
 		} else {
 			csio_warn(hw, "unexpected WR op(0x%x) recv\n",
-				FW_WR_OP_GET(be32_to_cpu((wr->hi))));
+				  FW_WR_OP_G(be32_to_cpu((wr->hi))));
 			CSIO_INC_STATS(hw, n_cpl_unexp);
 		}
 	} else if (cpl_op == CPL_FW6_MSG) {
 		wr = (struct fw_wr_hdr *) (cmd);
-		if (FW_WR_OP_GET(be32_to_cpu(wr->hi)) == FW_FCOE_ELS_CT_WR) {
+		if (FW_WR_OP_G(be32_to_cpu(wr->hi)) == FW_FCOE_ELS_CT_WR) {
 			csio_ln_mgmt_wr_handler(hw, wr,
 					sizeof(struct fw_fcoe_els_ct_wr));
 		} else {
 			csio_warn(hw, "unexpected WR op(0x%x) recv\n",
-				FW_WR_OP_GET(be32_to_cpu((wr->hi))));
+				  FW_WR_OP_G(be32_to_cpu((wr->hi))));
 			CSIO_INC_STATS(hw, n_cpl_unexp);
 		}
 	} else {
@@ -1668,12 +1668,12 @@ csio_ln_prep_ecwr(struct csio_ioreq *io_req, uint32_t wr_len,
 	__be32 port_id;
 
 	wr  = (struct fw_fcoe_els_ct_wr *)fw_wr;
-	wr->op_immdlen = cpu_to_be32(FW_WR_OP(FW_FCOE_ELS_CT_WR) |
+	wr->op_immdlen = cpu_to_be32(FW_WR_OP_V(FW_FCOE_ELS_CT_WR) |
 				     FW_FCOE_ELS_CT_WR_IMMDLEN(immd_len));
 
 	wr_len =  DIV_ROUND_UP(wr_len, 16);
-	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID(flow_id) |
-					  FW_WR_LEN16(wr_len));
+	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID_V(flow_id) |
+				       FW_WR_LEN16_V(wr_len));
 	wr->els_ct_type = sub_op;
 	wr->ctl_pri = 0;
 	wr->cp_en_class = 0;
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index 15b6351..ffa8489 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -59,7 +59,7 @@ csio_mb_fw_retval(struct csio_mb *mbp)
 
 	hdr = (struct fw_cmd_hdr *)(mbp->mb);
 
-	return FW_CMD_RETVAL_GET(ntohl(hdr->lo));
+	return FW_CMD_RETVAL_G(ntohl(hdr->lo));
 }
 
 /*
@@ -81,9 +81,9 @@ csio_mb_hello(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 
 	CSIO_INIT_MBP(mbp, cmdp, tmo, hw, cbfn, 1);
 
-	cmdp->op_to_write = htonl(FW_CMD_OP(FW_HELLO_CMD) |
-				       FW_CMD_REQUEST | FW_CMD_WRITE);
-	cmdp->retval_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->op_to_write = htonl(FW_CMD_OP_V(FW_HELLO_CMD) |
+				       FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
+	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->err_to_clearinit = htonl(
 		FW_HELLO_CMD_MASTERDIS(master == CSIO_MASTER_CANT)	|
 		FW_HELLO_CMD_MASTERFORCE(master == CSIO_MASTER_MUST)	|
@@ -112,7 +112,7 @@ csio_mb_process_hello_rsp(struct csio_hw *hw, struct csio_mb *mbp,
 	struct fw_hello_cmd *rsp = (struct fw_hello_cmd *)(mbp->mb);
 	uint32_t value;
 
-	*retval = FW_CMD_RETVAL_GET(ntohl(rsp->retval_len16));
+	*retval = FW_CMD_RETVAL_G(ntohl(rsp->retval_len16));
 
 	if (*retval == FW_SUCCESS) {
 		hw->fwrev = ntohl(rsp->fwrev);
@@ -144,9 +144,9 @@ csio_mb_bye(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 
 	CSIO_INIT_MBP(mbp, cmdp, tmo, hw, cbfn, 1);
 
-	cmdp->op_to_write = htonl(FW_CMD_OP(FW_BYE_CMD) |
-				       FW_CMD_REQUEST | FW_CMD_WRITE);
-	cmdp->retval_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->op_to_write = htonl(FW_CMD_OP_V(FW_BYE_CMD) |
+				       FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
+	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 }
 
@@ -167,9 +167,9 @@ csio_mb_reset(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 
 	CSIO_INIT_MBP(mbp, cmdp, tmo, hw, cbfn, 1);
 
-	cmdp->op_to_write = htonl(FW_CMD_OP(FW_RESET_CMD) |
-				  FW_CMD_REQUEST | FW_CMD_WRITE);
-	cmdp->retval_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->op_to_write = htonl(FW_CMD_OP_V(FW_RESET_CMD) |
+				  FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
+	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->val = htonl(reset);
 	cmdp->halt_pkd = htonl(halt);
 
@@ -202,12 +202,12 @@ csio_mb_params(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 
 	CSIO_INIT_MBP(mbp, cmdp, tmo, hw, cbfn, 1);
 
-	cmdp->op_to_vfn = htonl(FW_CMD_OP(FW_PARAMS_CMD)		|
-				FW_CMD_REQUEST				|
-				(wr ? FW_CMD_WRITE : FW_CMD_READ)	|
+	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_PARAMS_CMD)		|
+				FW_CMD_REQUEST_F			|
+				(wr ? FW_CMD_WRITE_F : FW_CMD_READ_F)	|
 				FW_PARAMS_CMD_PFN(pf)			|
 				FW_PARAMS_CMD_VFN(vf));
-	cmdp->retval_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	/* Write Params */
 	if (wr) {
@@ -245,7 +245,7 @@ csio_mb_process_read_params_rsp(struct csio_hw *hw, struct csio_mb *mbp,
 	uint32_t i;
 	__be32 *p = &rsp->param[0].val;
 
-	*retval = FW_CMD_RETVAL_GET(ntohl(rsp->retval_len16));
+	*retval = FW_CMD_RETVAL_G(ntohl(rsp->retval_len16));
 
 	if (*retval == FW_SUCCESS)
 		for (i = 0; i < nparams; i++, p += 2)
@@ -271,9 +271,9 @@ csio_mb_ldst(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo, int reg)
 	 * specified PCI-E Configuration Space register.
 	 */
 	ldst_cmd->op_to_addrspace =
-			htonl(FW_CMD_OP(FW_LDST_CMD)	|
-			FW_CMD_REQUEST			|
-			FW_CMD_READ			|
+			htonl(FW_CMD_OP_V(FW_LDST_CMD)	|
+			FW_CMD_REQUEST_F			|
+			FW_CMD_READ_F			|
 			FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_FUNC_PCIE));
 	ldst_cmd->cycles_to_len16 = htonl(FW_LEN16(struct fw_ldst_cmd));
 	ldst_cmd->u.pcie.select_naccess = FW_LDST_CMD_NACCESS(1);
@@ -306,10 +306,10 @@ csio_mb_caps_config(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 
 	CSIO_INIT_MBP(mbp, cmdp, tmo, hw, cbfn, wr ? 0 : 1);
 
-	cmdp->op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-				  FW_CMD_REQUEST		|
-				  (wr ? FW_CMD_WRITE : FW_CMD_READ));
-	cmdp->cfvalid_to_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+				  FW_CMD_REQUEST_F		|
+				  (wr ? FW_CMD_WRITE_F : FW_CMD_READ_F));
+	cmdp->cfvalid_to_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	/* Read config */
 	if (!wr)
@@ -351,21 +351,21 @@ csio_mb_port(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 
 	CSIO_INIT_MBP(mbp, cmdp, tmo, hw, cbfn,  1);
 
-	cmdp->op_to_portid = htonl(FW_CMD_OP(FW_PORT_CMD)		|
-				   FW_CMD_REQUEST			|
-				   (wr ? FW_CMD_EXEC : FW_CMD_READ)	|
+	cmdp->op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD)		|
+				   FW_CMD_REQUEST_F			|
+				   (wr ? FW_CMD_EXEC_F : FW_CMD_READ_F)	|
 				   FW_PORT_CMD_PORTID(portid));
 	if (!wr) {
 		cmdp->action_to_len16 = htonl(
 			FW_PORT_CMD_ACTION(FW_PORT_ACTION_GET_PORT_INFO) |
-			FW_CMD_LEN16(sizeof(*cmdp) / 16));
+			FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 		return;
 	}
 
 	/* Set port */
 	cmdp->action_to_len16 = htonl(
 			FW_PORT_CMD_ACTION(FW_PORT_ACTION_L1_CFG) |
-			FW_CMD_LEN16(sizeof(*cmdp) / 16));
+			FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	if (fc & PAUSE_RX)
 		lfc |= FW_PORT_CAP_FC_RX;
@@ -393,7 +393,7 @@ csio_mb_process_read_port_rsp(struct csio_hw *hw, struct csio_mb *mbp,
 {
 	struct fw_port_cmd *rsp = (struct fw_port_cmd *)(mbp->mb);
 
-	*retval = FW_CMD_RETVAL_GET(ntohl(rsp->action_to_len16));
+	*retval = FW_CMD_RETVAL_G(ntohl(rsp->action_to_len16));
 
 	if (*retval == FW_SUCCESS)
 		*caps = ntohs(rsp->u.info.pcap);
@@ -415,9 +415,9 @@ csio_mb_initialize(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 
 	CSIO_INIT_MBP(mbp, cmdp, tmo, hw, cbfn, 1);
 
-	cmdp->op_to_write = htonl(FW_CMD_OP(FW_INITIALIZE_CMD)	|
-				  FW_CMD_REQUEST | FW_CMD_WRITE);
-	cmdp->retval_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->op_to_write = htonl(FW_CMD_OP_V(FW_INITIALIZE_CMD)	|
+				  FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
+	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 }
 
@@ -443,13 +443,13 @@ csio_mb_iq_alloc(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, priv, cbfn, 1);
 
-	cmdp->op_to_vfn = htonl(FW_CMD_OP(FW_IQ_CMD)		|
-				FW_CMD_REQUEST | FW_CMD_EXEC	|
+	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD)		|
+				FW_CMD_REQUEST_F | FW_CMD_EXEC_F	|
 				FW_IQ_CMD_PFN(iq_params->pfn)	|
 				FW_IQ_CMD_VFN(iq_params->vfn));
 
 	cmdp->alloc_to_len16 = htonl(FW_IQ_CMD_ALLOC		|
-				FW_CMD_LEN16(sizeof(*cmdp) / 16));
+				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	cmdp->type_to_iqandstindex = htonl(
 				FW_IQ_CMD_VIID(iq_params->viid)	|
@@ -499,12 +499,12 @@ csio_mb_iq_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 	if (!cascaded_req)
 		CSIO_INIT_MBP(mbp, cmdp, mb_tmo, priv, cbfn, 1);
 
-	cmdp->op_to_vfn |= htonl(FW_CMD_OP(FW_IQ_CMD)		|
-				FW_CMD_REQUEST | FW_CMD_WRITE	|
+	cmdp->op_to_vfn |= htonl(FW_CMD_OP_V(FW_IQ_CMD)		|
+				FW_CMD_REQUEST_F | FW_CMD_WRITE_F	|
 				FW_IQ_CMD_PFN(iq_params->pfn)	|
 				FW_IQ_CMD_VFN(iq_params->vfn));
 	cmdp->alloc_to_len16 |= htonl(iq_start_stop |
-				FW_CMD_LEN16(sizeof(*cmdp) / 16));
+				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->iqid |= htons(iq_params->iqid);
 	cmdp->fl0id |= htons(iq_params->fl0id);
 	cmdp->fl1id |= htons(iq_params->fl1id);
@@ -588,7 +588,7 @@ csio_mb_iq_alloc_write_rsp(struct csio_hw *hw, struct csio_mb *mbp,
 {
 	struct fw_iq_cmd *rsp = (struct fw_iq_cmd *)(mbp->mb);
 
-	*ret_val = FW_CMD_RETVAL_GET(ntohl(rsp->alloc_to_len16));
+	*ret_val = FW_CMD_RETVAL_G(ntohl(rsp->alloc_to_len16));
 	if (*ret_val == FW_SUCCESS) {
 		iq_params->physiqid = ntohs(rsp->physiqid);
 		iq_params->iqid = ntohs(rsp->iqid);
@@ -622,12 +622,12 @@ csio_mb_iq_free(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, priv, cbfn, 1);
 
-	cmdp->op_to_vfn = htonl(FW_CMD_OP(FW_IQ_CMD)		|
-				FW_CMD_REQUEST | FW_CMD_EXEC	|
+	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD)		|
+				FW_CMD_REQUEST_F | FW_CMD_EXEC_F	|
 				FW_IQ_CMD_PFN(iq_params->pfn)	|
 				FW_IQ_CMD_VFN(iq_params->vfn));
 	cmdp->alloc_to_len16 = htonl(FW_IQ_CMD_FREE		|
-				FW_CMD_LEN16(sizeof(*cmdp) / 16));
+				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE(iq_params->type));
 
 	cmdp->iqid = htons(iq_params->iqid);
@@ -657,12 +657,12 @@ csio_mb_eq_ofld_alloc(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 	struct fw_eq_ofld_cmd *cmdp = (struct fw_eq_ofld_cmd *)(mbp->mb);
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, priv, cbfn, 1);
-	cmdp->op_to_vfn = htonl(FW_CMD_OP(FW_EQ_OFLD_CMD)		|
-				FW_CMD_REQUEST | FW_CMD_EXEC		|
+	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD)		|
+				FW_CMD_REQUEST_F | FW_CMD_EXEC_F	|
 				FW_EQ_OFLD_CMD_PFN(eq_ofld_params->pfn) |
 				FW_EQ_OFLD_CMD_VFN(eq_ofld_params->vfn));
 	cmdp->alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC	|
-				FW_CMD_LEN16(sizeof(*cmdp) / 16));
+				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 } /* csio_mb_eq_ofld_alloc */
 
@@ -704,12 +704,12 @@ csio_mb_eq_ofld_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 	if (!cascaded_req)
 		CSIO_INIT_MBP(mbp, cmdp, mb_tmo, priv, cbfn, 1);
 
-	cmdp->op_to_vfn |= htonl(FW_CMD_OP(FW_EQ_OFLD_CMD)	|
-				FW_CMD_REQUEST | FW_CMD_WRITE	|
+	cmdp->op_to_vfn |= htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD)	|
+				FW_CMD_REQUEST_F | FW_CMD_WRITE_F	|
 				FW_EQ_OFLD_CMD_PFN(eq_ofld_params->pfn) |
 				FW_EQ_OFLD_CMD_VFN(eq_ofld_params->vfn));
 	cmdp->alloc_to_len16 |= htonl(eq_start_stop		|
-				      FW_CMD_LEN16(sizeof(*cmdp) / 16));
+				      FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	cmdp->eqid_pkd |= htonl(FW_EQ_OFLD_CMD_EQID(eq_ofld_params->eqid));
 
@@ -773,7 +773,7 @@ csio_mb_eq_ofld_alloc_write_rsp(struct csio_hw *hw,
 {
 	struct fw_eq_ofld_cmd *rsp = (struct fw_eq_ofld_cmd *)(mbp->mb);
 
-	*ret_val = FW_CMD_RETVAL_GET(ntohl(rsp->alloc_to_len16));
+	*ret_val = FW_CMD_RETVAL_G(ntohl(rsp->alloc_to_len16));
 
 	if (*ret_val == FW_SUCCESS) {
 		eq_ofld_params->eqid = FW_EQ_OFLD_CMD_EQID_GET(
@@ -807,12 +807,12 @@ csio_mb_eq_ofld_free(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, priv, cbfn, 1);
 
-	cmdp->op_to_vfn = htonl(FW_CMD_OP(FW_EQ_OFLD_CMD)	|
-				FW_CMD_REQUEST | FW_CMD_EXEC	|
+	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD)	|
+				FW_CMD_REQUEST_F | FW_CMD_EXEC_F	|
 				FW_EQ_OFLD_CMD_PFN(eq_ofld_params->pfn) |
 				FW_EQ_OFLD_CMD_VFN(eq_ofld_params->vfn));
 	cmdp->alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_FREE |
-				FW_CMD_LEN16(sizeof(*cmdp) / 16));
+				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->eqid_pkd = htonl(FW_EQ_OFLD_CMD_EQID(eq_ofld_params->eqid));
 
 } /* csio_mb_eq_ofld_free */
@@ -840,15 +840,15 @@ csio_write_fcoe_link_cond_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, ln, cbfn, 1);
 
 	cmdp->op_to_portid = htonl((
-			FW_CMD_OP(FW_FCOE_LINK_CMD)		|
-			FW_CMD_REQUEST				|
-			FW_CMD_WRITE				|
+			FW_CMD_OP_V(FW_FCOE_LINK_CMD)		|
+			FW_CMD_REQUEST_F				|
+			FW_CMD_WRITE_F				|
 			FW_FCOE_LINK_CMD_PORTID(port_id)));
 	cmdp->sub_opcode_fcfi = htonl(
 			FW_FCOE_LINK_CMD_SUB_OPCODE(sub_opcode)	|
 			FW_FCOE_LINK_CMD_FCFI(fcfi));
 	cmdp->lstatus = link_status;
-	cmdp->retval_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 } /* csio_write_fcoe_link_cond_init_mb */
 
@@ -873,11 +873,11 @@ csio_fcoe_read_res_info_init_mb(struct csio_hw *hw, struct csio_mb *mbp,
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, hw, cbfn, 1);
 
-	cmdp->op_to_read = htonl((FW_CMD_OP(FW_FCOE_RES_INFO_CMD)	|
-				  FW_CMD_REQUEST			|
-				  FW_CMD_READ));
+	cmdp->op_to_read = htonl((FW_CMD_OP_V(FW_FCOE_RES_INFO_CMD)	|
+				  FW_CMD_REQUEST_F			|
+				  FW_CMD_READ_F));
 
-	cmdp->retval_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 } /* csio_fcoe_read_res_info_init_mb */
 
@@ -908,13 +908,13 @@ csio_fcoe_vnp_alloc_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, ln, cbfn, 1);
 
-	cmdp->op_to_fcfi = htonl((FW_CMD_OP(FW_FCOE_VNP_CMD)		|
-				  FW_CMD_REQUEST			|
-				  FW_CMD_EXEC				|
+	cmdp->op_to_fcfi = htonl((FW_CMD_OP_V(FW_FCOE_VNP_CMD)		|
+				  FW_CMD_REQUEST_F			|
+				  FW_CMD_EXEC_F				|
 				  FW_FCOE_VNP_CMD_FCFI(fcfi)));
 
 	cmdp->alloc_to_len16 = htonl(FW_FCOE_VNP_CMD_ALLOC		|
-				     FW_CMD_LEN16(sizeof(*cmdp) / 16));
+				     FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	cmdp->gen_wwn_to_vnpi = htonl(FW_FCOE_VNP_CMD_VNPI(vnpi));
 
@@ -948,11 +948,11 @@ csio_fcoe_vnp_read_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 			(struct fw_fcoe_vnp_cmd *)(mbp->mb);
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, ln, cbfn, 1);
-	cmdp->op_to_fcfi = htonl(FW_CMD_OP(FW_FCOE_VNP_CMD)	|
-				 FW_CMD_REQUEST			|
-				 FW_CMD_READ			|
+	cmdp->op_to_fcfi = htonl(FW_CMD_OP_V(FW_FCOE_VNP_CMD)	|
+				 FW_CMD_REQUEST_F			|
+				 FW_CMD_READ_F			|
 				 FW_FCOE_VNP_CMD_FCFI(fcfi));
-	cmdp->alloc_to_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->alloc_to_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->gen_wwn_to_vnpi = htonl(FW_FCOE_VNP_CMD_VNPI(vnpi));
 }
 
@@ -978,12 +978,12 @@ csio_fcoe_vnp_free_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, ln, cbfn, 1);
 
-	cmdp->op_to_fcfi = htonl(FW_CMD_OP(FW_FCOE_VNP_CMD)	|
-				 FW_CMD_REQUEST			|
-				 FW_CMD_EXEC			|
+	cmdp->op_to_fcfi = htonl(FW_CMD_OP_V(FW_FCOE_VNP_CMD)	|
+				 FW_CMD_REQUEST_F			|
+				 FW_CMD_EXEC_F			|
 				 FW_FCOE_VNP_CMD_FCFI(fcfi));
 	cmdp->alloc_to_len16 = htonl(FW_FCOE_VNP_CMD_FREE	|
-				     FW_CMD_LEN16(sizeof(*cmdp) / 16));
+				     FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->gen_wwn_to_vnpi = htonl(FW_FCOE_VNP_CMD_VNPI(vnpi));
 }
 
@@ -1009,11 +1009,11 @@ csio_fcoe_read_fcf_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, ln, cbfn, 1);
 
-	cmdp->op_to_fcfi = htonl(FW_CMD_OP(FW_FCOE_FCF_CMD)	|
-				 FW_CMD_REQUEST			|
-				 FW_CMD_READ			|
+	cmdp->op_to_fcfi = htonl(FW_CMD_OP_V(FW_FCOE_FCF_CMD)	|
+				 FW_CMD_REQUEST_F			|
+				 FW_CMD_READ_F			|
 				 FW_FCOE_FCF_CMD_FCFI(fcfi));
-	cmdp->retval_len16 = htonl(FW_CMD_LEN16(sizeof(*cmdp) / 16));
+	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 } /* csio_fcoe_read_fcf_init_mb */
 
@@ -1029,9 +1029,9 @@ csio_fcoe_read_portparams_init_mb(struct csio_hw *hw, struct csio_mb *mbp,
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, hw, cbfn, 1);
 	mbp->mb_size = 64;
 
-	cmdp->op_to_flowid = htonl(FW_CMD_OP(FW_FCOE_STATS_CMD)         |
-				   FW_CMD_REQUEST | FW_CMD_READ);
-	cmdp->free_to_len16 = htonl(FW_CMD_LEN16(CSIO_MAX_MB_SIZE/16));
+	cmdp->op_to_flowid = htonl(FW_CMD_OP_V(FW_FCOE_STATS_CMD)         |
+				   FW_CMD_REQUEST_F | FW_CMD_READ_F);
+	cmdp->free_to_len16 = htonl(FW_CMD_LEN16_V(CSIO_MAX_MB_SIZE/16));
 
 	cmdp->u.ctl.nstats_port = FW_FCOE_STATS_CMD_NSTATS(portparams->nstats) |
 				  FW_FCOE_STATS_CMD_PORT(portparams->portid);
@@ -1053,7 +1053,7 @@ csio_mb_process_portparams_rsp(struct csio_hw *hw,
 	uint8_t *src;
 	uint8_t *dst;
 
-	*retval = FW_CMD_RETVAL_GET(ntohl(rsp->free_to_len16));
+	*retval = FW_CMD_RETVAL_G(ntohl(rsp->free_to_len16));
 
 	memset(&stats, 0, sizeof(struct fw_fcoe_port_stats));
 
@@ -1305,7 +1305,7 @@ csio_mb_issue(struct csio_hw *hw, struct csio_mb *mbp)
 			hdr = cpu_to_be64(csio_rd_reg64(hw, data_reg));
 			fw_hdr = (struct fw_cmd_hdr *)&hdr;
 
-			switch (FW_CMD_OP_GET(ntohl(fw_hdr->hi))) {
+			switch (FW_CMD_OP_G(ntohl(fw_hdr->hi))) {
 			case FW_DEBUG_CMD:
 				csio_mb_debug_cmd_handler(hw);
 				continue;
@@ -1498,7 +1498,7 @@ csio_mb_isr_handler(struct csio_hw *hw)
 		hdr = cpu_to_be64(csio_rd_reg64(hw, data_reg));
 		fw_hdr = (struct fw_cmd_hdr *)&hdr;
 
-		switch (FW_CMD_OP_GET(ntohl(fw_hdr->hi))) {
+		switch (FW_CMD_OP_G(ntohl(fw_hdr->hi))) {
 		case FW_DEBUG_CMD:
 			csio_mb_debug_cmd_handler(hw);
 			return -EINVAL;
@@ -1571,11 +1571,11 @@ csio_mb_tmo_handler(struct csio_hw *hw)
 	fw_hdr = (struct fw_cmd_hdr *)(mbp->mb);
 
 	csio_dbg(hw, "Mailbox num:%x op:0x%x timed out\n", hw->pfn,
-		    FW_CMD_OP_GET(ntohl(fw_hdr->hi)));
+		    FW_CMD_OP_G(ntohl(fw_hdr->hi)));
 
 	mbm->mcurrent = NULL;
 	CSIO_INC_STATS(mbm, n_tmo);
-	fw_hdr->lo = htonl(FW_CMD_RETVAL(FW_ETIMEDOUT));
+	fw_hdr->lo = htonl(FW_CMD_RETVAL_V(FW_ETIMEDOUT));
 
 	return mbp;
 }
@@ -1624,10 +1624,10 @@ csio_mb_cancel_all(struct csio_hw *hw, struct list_head *cbfn_q)
 		hdr = (struct fw_cmd_hdr *)(mbp->mb);
 
 		csio_dbg(hw, "Cancelling pending mailbox num %x op:%x\n",
-			    hw->pfn, FW_CMD_OP_GET(ntohl(hdr->hi)));
+			    hw->pfn, FW_CMD_OP_G(ntohl(hdr->hi)));
 
 		CSIO_INC_STATS(mbm, n_cancel);
-		hdr->lo = htonl(FW_CMD_RETVAL(FW_HOSTERROR));
+		hdr->lo = htonl(FW_CMD_RETVAL_V(FW_HOSTERROR));
 	}
 }
 
diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
index 86103c8..b37c69a 100644
--- a/drivers/scsi/csiostor/csio_scsi.c
+++ b/drivers/scsi/csiostor/csio_scsi.c
@@ -230,10 +230,10 @@ csio_scsi_init_cmd_wr(struct csio_ioreq *req, void *addr, uint32_t size)
 	struct csio_dma_buf *dma_buf;
 	uint8_t imm = csio_hw_to_scsim(hw)->proto_cmd_len;
 
-	wr->op_immdlen = cpu_to_be32(FW_WR_OP(FW_SCSI_CMD_WR) |
+	wr->op_immdlen = cpu_to_be32(FW_WR_OP_V(FW_SCSI_CMD_WR) |
 					  FW_SCSI_CMD_WR_IMMDLEN(imm));
-	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID(rn->flowid) |
-					    FW_WR_LEN16(
+	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID_V(rn->flowid) |
+					    FW_WR_LEN16_V(
 						DIV_ROUND_UP(size, 16)));
 
 	wr->cookie = (uintptr_t) req;
@@ -391,10 +391,10 @@ csio_scsi_init_read_wr(struct csio_ioreq *req, void *wrp, uint32_t size)
 	uint8_t imm = csio_hw_to_scsim(hw)->proto_cmd_len;
 	struct scsi_cmnd *scmnd = csio_scsi_cmnd(req);
 
-	wr->op_immdlen = cpu_to_be32(FW_WR_OP(FW_SCSI_READ_WR) |
+	wr->op_immdlen = cpu_to_be32(FW_WR_OP_V(FW_SCSI_READ_WR) |
 				     FW_SCSI_READ_WR_IMMDLEN(imm));
-	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID(rn->flowid) |
-				       FW_WR_LEN16(DIV_ROUND_UP(size, 16)));
+	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID_V(rn->flowid) |
+				       FW_WR_LEN16_V(DIV_ROUND_UP(size, 16)));
 	wr->cookie = (uintptr_t)req;
 	wr->iqid = cpu_to_be16(csio_q_physiqid(hw, req->iq_idx));
 	wr->tmo_val = (uint8_t)(req->tmo);
@@ -444,10 +444,10 @@ csio_scsi_init_write_wr(struct csio_ioreq *req, void *wrp, uint32_t size)
 	uint8_t imm = csio_hw_to_scsim(hw)->proto_cmd_len;
 	struct scsi_cmnd *scmnd = csio_scsi_cmnd(req);
 
-	wr->op_immdlen = cpu_to_be32(FW_WR_OP(FW_SCSI_WRITE_WR) |
+	wr->op_immdlen = cpu_to_be32(FW_WR_OP_V(FW_SCSI_WRITE_WR) |
 				     FW_SCSI_WRITE_WR_IMMDLEN(imm));
-	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID(rn->flowid) |
-				       FW_WR_LEN16(DIV_ROUND_UP(size, 16)));
+	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID_V(rn->flowid) |
+				       FW_WR_LEN16_V(DIV_ROUND_UP(size, 16)));
 	wr->cookie = (uintptr_t)req;
 	wr->iqid = cpu_to_be16(csio_q_physiqid(hw, req->iq_idx));
 	wr->tmo_val = (uint8_t)(req->tmo);
@@ -674,9 +674,9 @@ csio_scsi_init_abrt_cls_wr(struct csio_ioreq *req, void *addr, uint32_t size,
 	struct csio_rnode *rn = req->rnode;
 	struct fw_scsi_abrt_cls_wr *wr = (struct fw_scsi_abrt_cls_wr *)addr;
 
-	wr->op_immdlen = cpu_to_be32(FW_WR_OP(FW_SCSI_ABRT_CLS_WR));
-	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID(rn->flowid) |
-					    FW_WR_LEN16(
+	wr->op_immdlen = cpu_to_be32(FW_WR_OP_V(FW_SCSI_ABRT_CLS_WR));
+	wr->flowid_len16 = cpu_to_be32(FW_WR_FLOWID_V(rn->flowid) |
+					    FW_WR_LEN16_V(
 						DIV_ROUND_UP(size, 16)));
 
 	wr->cookie = (uintptr_t) req;
diff --git a/drivers/scsi/csiostor/csio_wr.h b/drivers/scsi/csiostor/csio_wr.h
index 8d30e7a..0c0dd9a 100644
--- a/drivers/scsi/csiostor/csio_wr.h
+++ b/drivers/scsi/csiostor/csio_wr.h
@@ -101,7 +101,7 @@
 
 /* WR status is at the same position as retval in a CMD header */
 #define csio_wr_status(_wr)		\
-		(FW_CMD_RETVAL_GET(ntohl(((struct fw_cmd_hdr *)(_wr))->lo)))
+		(FW_CMD_RETVAL_G(ntohl(((struct fw_cmd_hdr *)(_wr))->lo)))
 
 struct csio_hw;
 
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 3e0a0d3..ccacf09 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -499,10 +499,10 @@ static inline void send_tx_flowc_wr(struct cxgbi_sock *csk)
 	skb = alloc_wr(flowclen, 0, GFP_ATOMIC);
 	flowc = (struct fw_flowc_wr *)skb->head;
 	flowc->op_to_nparams =
-		htonl(FW_WR_OP(FW_FLOWC_WR) | FW_FLOWC_WR_NPARAMS(8));
+		htonl(FW_WR_OP_V(FW_FLOWC_WR) | FW_FLOWC_WR_NPARAMS_V(8));
 	flowc->flowid_len16 =
-		htonl(FW_WR_LEN16(DIV_ROUND_UP(72, 16)) |
-				FW_WR_FLOWID(csk->tid));
+		htonl(FW_WR_LEN16_V(DIV_ROUND_UP(72, 16)) |
+				FW_WR_FLOWID_V(csk->tid));
 	flowc->mnemval[0].mnemonic = FW_FLOWC_MNEM_PFNVFN;
 	flowc->mnemval[0].val = htonl(csk->cdev->pfvf);
 	flowc->mnemval[1].mnemonic = FW_FLOWC_MNEM_CH;
@@ -542,30 +542,31 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
 {
 	struct fw_ofld_tx_data_wr *req;
 	unsigned int submode = cxgbi_skcb_ulp_mode(skb) & 3;
-	unsigned int wr_ulp_mode = 0;
+	unsigned int wr_ulp_mode = 0, val;
 
 	req = (struct fw_ofld_tx_data_wr *)__skb_push(skb, sizeof(*req));
 
 	if (is_ofld_imm(skb)) {
-		req->op_to_immdlen = htonl(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
-					FW_WR_COMPL(1) |
-					FW_WR_IMMDLEN(dlen));
-		req->flowid_len16 = htonl(FW_WR_FLOWID(csk->tid) |
-						FW_WR_LEN16(credits));
+		req->op_to_immdlen = htonl(FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
+					FW_WR_COMPL_F |
+					FW_WR_IMMDLEN_V(dlen));
+		req->flowid_len16 = htonl(FW_WR_FLOWID_V(csk->tid) |
+						FW_WR_LEN16_V(credits));
 	} else {
 		req->op_to_immdlen =
-			cpu_to_be32(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
-					FW_WR_COMPL(1) |
-					FW_WR_IMMDLEN(0));
+			cpu_to_be32(FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
+					FW_WR_COMPL_F |
+					FW_WR_IMMDLEN_V(0));
 		req->flowid_len16 =
-			cpu_to_be32(FW_WR_FLOWID(csk->tid) |
-					FW_WR_LEN16(credits));
+			cpu_to_be32(FW_WR_FLOWID_V(csk->tid) |
+					FW_WR_LEN16_V(credits));
 	}
 	if (submode)
-		wr_ulp_mode = FW_OFLD_TX_DATA_WR_ULPMODE(ULP2_MODE_ISCSI) |
-				FW_OFLD_TX_DATA_WR_ULPSUBMODE(submode);
+		wr_ulp_mode = FW_OFLD_TX_DATA_WR_ULPMODE_V(ULP2_MODE_ISCSI) |
+				FW_OFLD_TX_DATA_WR_ULPSUBMODE_V(submode);
+	val = skb_peek(&csk->write_queue) ? 0 : 1;
 	req->tunnel_to_proxy = htonl(wr_ulp_mode |
-		 FW_OFLD_TX_DATA_WR_SHOVE(skb_peek(&csk->write_queue) ? 0 : 1));
+				     FW_OFLD_TX_DATA_WR_SHOVE_V(val));
 	req->plen = htonl(len);
 	if (!cxgbi_sock_flag(csk, CTPF_TX_DATA_SENT))
 		cxgbi_sock_set_flag(csk, CTPF_TX_DATA_SENT);
-- 
1.7.1
