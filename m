From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH for-next 2/2] iw_cxgb4: Cleanup register defines/MACROS defined in t4fw_ri_api.h
Date: Fri, 16 Jan 2015 09:24:48 +0530
Message-ID: <1421380488-1111-3-git-send-email-hariprasad@chelsio.com>
References: <1421380488-1111-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, praveenm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421380488-1111-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cleanup all the MACROS that are defined in t4fw_ri_api.h and affected files

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c          |   30 +-
 drivers/infiniband/hw/cxgb4/cq.c          |   22 +-
 drivers/infiniband/hw/cxgb4/device.c      |   12 +-
 drivers/infiniband/hw/cxgb4/ev.c          |   12 +-
 drivers/infiniband/hw/cxgb4/mem.c         |   18 +-
 drivers/infiniband/hw/cxgb4/qp.c          |   60 ++--
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h |  812 ++++++++++++++--------------
 7 files changed, 483 insertions(+), 483 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 694e030..57176dd 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -674,7 +674,7 @@ static int send_connect(struct c4iw_ep *ep)
 		opt2 |= WND_SCALE_EN_F;
 	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
 		opt2 |= T5_OPT_2_VALID_F;
-		opt2 |= V_CONG_CNTRL(CONG_ALG_TAHOE);
+		opt2 |= CONG_CNTRL_V(CONG_ALG_TAHOE);
 		opt2 |= CONG_CNTRL_VALID; /* OPT_2_ISS for T5 */
 	}
 	t4_set_arp_err_handler(skb, ep, act_open_req_arp_failure);
@@ -1258,8 +1258,8 @@ static int update_rx_credits(struct c4iw_ep *ep, u32 credits)
 	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_RX_DATA_ACK,
 						    ep->hwtid));
 	req->credit_dack = cpu_to_be32(credits | RX_FORCE_ACK_F |
-				       F_RX_DACK_CHANGE |
-				       V_RX_DACK_MODE(dack_mode));
+				       RX_DACK_CHANGE_F |
+				       RX_DACK_MODE_V(dack_mode));
 	set_wr_txq(skb, CPL_PRIORITY_ACK, ep->ctrlq_idx);
 	c4iw_ofld_send(&ep->com.dev->rdev, skb);
 	return credits;
@@ -2205,15 +2205,15 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 		const struct tcphdr *tcph;
 		u32 hlen = ntohl(req->hdr_len);
 
-		tcph = (const void *)(req + 1) + G_ETH_HDR_LEN(hlen) +
-			G_IP_HDR_LEN(hlen);
+		tcph = (const void *)(req + 1) + ETH_HDR_LEN_G(hlen) +
+			IP_HDR_LEN_G(hlen);
 		if (tcph->ece && tcph->cwr)
 			opt2 |= CCTRL_ECN_V(1);
 	}
 	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
 		u32 isn = (prandom_u32() & ~7UL) - 1;
 		opt2 |= T5_OPT_2_VALID_F;
-		opt2 |= V_CONG_CNTRL(CONG_ALG_TAHOE);
+		opt2 |= CONG_CNTRL_V(CONG_ALG_TAHOE);
 		opt2 |= CONG_CNTRL_VALID; /* OPT_2_ISS for T5 */
 		rpl5 = (void *)rpl;
 		memset(&rpl5->iss, 0, roundup(sizeof(*rpl5)-sizeof(*rpl), 16));
@@ -2245,8 +2245,8 @@ static void get_4tuple(struct cpl_pass_accept_req *req, int *iptype,
 		       __u8 *local_ip, __u8 *peer_ip,
 		       __be16 *local_port, __be16 *peer_port)
 {
-	int eth_len = G_ETH_HDR_LEN(be32_to_cpu(req->hdr_len));
-	int ip_len = G_IP_HDR_LEN(be32_to_cpu(req->hdr_len));
+	int eth_len = ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len));
+	int ip_len = IP_HDR_LEN_G(be32_to_cpu(req->hdr_len));
 	struct iphdr *ip = (struct iphdr *)((u8 *)(req + 1) + eth_len);
 	struct ipv6hdr *ip6 = (struct ipv6hdr *)((u8 *)(req + 1) + eth_len);
 	struct tcphdr *tcp = (struct tcphdr *)
@@ -3500,20 +3500,20 @@ static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 
 	req = (struct cpl_pass_accept_req *)__skb_push(skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
-	req->l2info = cpu_to_be16(V_SYN_INTF(intf) |
-			 V_SYN_MAC_IDX(RX_MACIDX_G(
+	req->l2info = cpu_to_be16(SYN_INTF_V(intf) |
+			 SYN_MAC_IDX_V(RX_MACIDX_G(
 			 (__force int) htonl(l2info))) |
-			 F_SYN_XACT_MATCH);
+			 SYN_XACT_MATCH_F);
 	eth_hdr_len = is_t4(dev->rdev.lldi.adapter_type) ?
 			    RX_ETHHDR_LEN_G((__force int)htonl(l2info)) :
 			    RX_T5_ETHHDR_LEN_G((__force int)htonl(l2info));
-	req->hdr_len = cpu_to_be32(V_SYN_RX_CHAN(RX_CHAN_G(
+	req->hdr_len = cpu_to_be32(SYN_RX_CHAN_V(RX_CHAN_G(
 					(__force int) htonl(l2info))) |
-				   V_TCP_HDR_LEN(RX_TCPHDR_LEN_G(
+				   TCP_HDR_LEN_V(RX_TCPHDR_LEN_G(
 					(__force int) htons(hdr_len))) |
-				   V_IP_HDR_LEN(RX_IPHDR_LEN_G(
+				   IP_HDR_LEN_V(RX_IPHDR_LEN_G(
 					(__force int) htons(hdr_len))) |
-				   V_ETH_HDR_LEN(RX_ETHHDR_LEN_G(eth_hdr_len)));
+				   ETH_HDR_LEN_V(RX_ETHHDR_LEN_G(eth_hdr_len)));
 	req->vlan = (__force __be16) vlantag;
 	req->len = (__force __be16) len;
 	req->tos_stid = cpu_to_be32(PASS_OPEN_TID_V(stid) |
diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index 39b0da3..ab7692a 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -52,7 +52,7 @@ static int destroy_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
-			V_FW_RI_RES_WR_NRES(1) |
+			FW_RI_RES_WR_NRES_V(1) |
 			FW_WR_COMPL_F);
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
 	res_wr->cookie = (unsigned long) &wr_wait;
@@ -122,7 +122,7 @@ static int create_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
-			V_FW_RI_RES_WR_NRES(1) |
+			FW_RI_RES_WR_NRES_V(1) |
 			FW_WR_COMPL_F);
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
 	res_wr->cookie = (unsigned long) &wr_wait;
@@ -131,17 +131,17 @@ static int create_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	res->u.cq.op = FW_RI_RES_OP_WRITE;
 	res->u.cq.iqid = cpu_to_be32(cq->cqid);
 	res->u.cq.iqandst_to_iqandstindex = cpu_to_be32(
-			V_FW_RI_RES_WR_IQANUS(0) |
-			V_FW_RI_RES_WR_IQANUD(1) |
-			F_FW_RI_RES_WR_IQANDST |
-			V_FW_RI_RES_WR_IQANDSTINDEX(
+			FW_RI_RES_WR_IQANUS_V(0) |
+			FW_RI_RES_WR_IQANUD_V(1) |
+			FW_RI_RES_WR_IQANDST_F |
+			FW_RI_RES_WR_IQANDSTINDEX_V(
 				rdev->lldi.ciq_ids[cq->vector]));
 	res->u.cq.iqdroprss_to_iqesize = cpu_to_be16(
-			F_FW_RI_RES_WR_IQDROPRSS |
-			V_FW_RI_RES_WR_IQPCIECH(2) |
-			V_FW_RI_RES_WR_IQINTCNTTHRESH(0) |
-			F_FW_RI_RES_WR_IQO |
-			V_FW_RI_RES_WR_IQESIZE(1));
+			FW_RI_RES_WR_IQDROPRSS_F |
+			FW_RI_RES_WR_IQPCIECH_V(2) |
+			FW_RI_RES_WR_IQINTCNTTHRESH_V(0) |
+			FW_RI_RES_WR_IQO_F |
+			FW_RI_RES_WR_IQESIZE_V(1));
 	res->u.cq.iqsize = cpu_to_be16(cq->size);
 	res->u.cq.iqaddr = cpu_to_be64(cq->dma_addr);
 
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index eb5df4e..aafdbcd 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -380,12 +380,12 @@ static int dump_stag(int id, void *p, void *data)
 		      "stag: idx 0x%x valid %d key 0x%x state %d pdid %d "
 		      "perm 0x%x ps %d len 0x%llx va 0x%llx\n",
 		      (u32)id<<8,
-		      G_FW_RI_TPTE_VALID(ntohl(tpte.valid_to_pdid)),
-		      G_FW_RI_TPTE_STAGKEY(ntohl(tpte.valid_to_pdid)),
-		      G_FW_RI_TPTE_STAGSTATE(ntohl(tpte.valid_to_pdid)),
-		      G_FW_RI_TPTE_PDID(ntohl(tpte.valid_to_pdid)),
-		      G_FW_RI_TPTE_PERM(ntohl(tpte.locread_to_qpid)),
-		      G_FW_RI_TPTE_PS(ntohl(tpte.locread_to_qpid)),
+		      FW_RI_TPTE_VALID_G(ntohl(tpte.valid_to_pdid)),
+		      FW_RI_TPTE_STAGKEY_G(ntohl(tpte.valid_to_pdid)),
+		      FW_RI_TPTE_STAGSTATE_G(ntohl(tpte.valid_to_pdid)),
+		      FW_RI_TPTE_PDID_G(ntohl(tpte.valid_to_pdid)),
+		      FW_RI_TPTE_PERM_G(ntohl(tpte.locread_to_qpid)),
+		      FW_RI_TPTE_PS_G(ntohl(tpte.locread_to_qpid)),
 		      ((u64)ntohl(tpte.len_hi) << 32) | ntohl(tpte.len_lo),
 		      ((u64)ntohl(tpte.va_hi) << 32) | ntohl(tpte.va_lo_fbo));
 	if (cc < space)
diff --git a/drivers/infiniband/hw/cxgb4/ev.c b/drivers/infiniband/hw/cxgb4/ev.c
index c9df054..794555d 100644
--- a/drivers/infiniband/hw/cxgb4/ev.c
+++ b/drivers/infiniband/hw/cxgb4/ev.c
@@ -50,12 +50,12 @@ static void print_tpte(struct c4iw_dev *dev, u32 stag)
 	PDBG("stag idx 0x%x valid %d key 0x%x state %d pdid %d "
 	       "perm 0x%x ps %d len 0x%llx va 0x%llx\n",
 	       stag & 0xffffff00,
-	       G_FW_RI_TPTE_VALID(ntohl(tpte.valid_to_pdid)),
-	       G_FW_RI_TPTE_STAGKEY(ntohl(tpte.valid_to_pdid)),
-	       G_FW_RI_TPTE_STAGSTATE(ntohl(tpte.valid_to_pdid)),
-	       G_FW_RI_TPTE_PDID(ntohl(tpte.valid_to_pdid)),
-	       G_FW_RI_TPTE_PERM(ntohl(tpte.locread_to_qpid)),
-	       G_FW_RI_TPTE_PS(ntohl(tpte.locread_to_qpid)),
+	       FW_RI_TPTE_VALID_G(ntohl(tpte.valid_to_pdid)),
+	       FW_RI_TPTE_STAGKEY_G(ntohl(tpte.valid_to_pdid)),
+	       FW_RI_TPTE_STAGSTATE_G(ntohl(tpte.valid_to_pdid)),
+	       FW_RI_TPTE_PDID_G(ntohl(tpte.valid_to_pdid)),
+	       FW_RI_TPTE_PERM_G(ntohl(tpte.locread_to_qpid)),
+	       FW_RI_TPTE_PS_G(ntohl(tpte.locread_to_qpid)),
 	       ((u64)ntohl(tpte.len_hi) << 32) | ntohl(tpte.len_lo),
 	       ((u64)ntohl(tpte.va_hi) << 32) | ntohl(tpte.va_lo_fbo));
 }
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index b9dc9fc..6791fd1 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -286,17 +286,17 @@ static int write_tpt_entry(struct c4iw_rdev *rdev, u32 reset_tpt_entry,
 	if (reset_tpt_entry)
 		memset(&tpt, 0, sizeof(tpt));
 	else {
-		tpt.valid_to_pdid = cpu_to_be32(F_FW_RI_TPTE_VALID |
-			V_FW_RI_TPTE_STAGKEY((*stag & M_FW_RI_TPTE_STAGKEY)) |
-			V_FW_RI_TPTE_STAGSTATE(stag_state) |
-			V_FW_RI_TPTE_STAGTYPE(type) | V_FW_RI_TPTE_PDID(pdid));
-		tpt.locread_to_qpid = cpu_to_be32(V_FW_RI_TPTE_PERM(perm) |
-			(bind_enabled ? F_FW_RI_TPTE_MWBINDEN : 0) |
-			V_FW_RI_TPTE_ADDRTYPE((zbva ? FW_RI_ZERO_BASED_TO :
+		tpt.valid_to_pdid = cpu_to_be32(FW_RI_TPTE_VALID_F |
+			FW_RI_TPTE_STAGKEY_V((*stag & FW_RI_TPTE_STAGKEY_M)) |
+			FW_RI_TPTE_STAGSTATE_V(stag_state) |
+			FW_RI_TPTE_STAGTYPE_V(type) | FW_RI_TPTE_PDID_V(pdid));
+		tpt.locread_to_qpid = cpu_to_be32(FW_RI_TPTE_PERM_V(perm) |
+			(bind_enabled ? FW_RI_TPTE_MWBINDEN_F : 0) |
+			FW_RI_TPTE_ADDRTYPE_V((zbva ? FW_RI_ZERO_BASED_TO :
 						      FW_RI_VA_BASED_TO))|
-			V_FW_RI_TPTE_PS(page_size));
+			FW_RI_TPTE_PS_V(page_size));
 		tpt.nosnoop_pbladdr = !pbl_size ? 0 : cpu_to_be32(
-			V_FW_RI_TPTE_PBLADDR(PBL_OFF(rdev, pbl_addr)>>3));
+			FW_RI_TPTE_PBLADDR_V(PBL_OFF(rdev, pbl_addr)>>3));
 		tpt.len_lo = cpu_to_be32((u32)(len & 0xffffffffUL));
 		tpt.va_hi = cpu_to_be32((u32)(to >> 32));
 		tpt.va_lo_fbo = cpu_to_be32((u32)(to & 0xffffffffUL));
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 42238ed..15cae5a 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -272,7 +272,7 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
-			V_FW_RI_RES_WR_NRES(2) |
+			FW_RI_RES_WR_NRES_V(2) |
 			FW_WR_COMPL_F);
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
 	res_wr->cookie = (unsigned long) &wr_wait;
@@ -287,19 +287,19 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 		rdev->hw_queue.t4_eq_status_entries;
 
 	res->u.sqrq.fetchszm_to_iqid = cpu_to_be32(
-		V_FW_RI_RES_WR_HOSTFCMODE(0) |	/* no host cidx updates */
-		V_FW_RI_RES_WR_CPRIO(0) |	/* don't keep in chip cache */
-		V_FW_RI_RES_WR_PCIECHN(0) |	/* set by uP at ri_init time */
-		(t4_sq_onchip(&wq->sq) ? F_FW_RI_RES_WR_ONCHIP : 0) |
-		V_FW_RI_RES_WR_IQID(scq->cqid));
+		FW_RI_RES_WR_HOSTFCMODE_V(0) |	/* no host cidx updates */
+		FW_RI_RES_WR_CPRIO_V(0) |	/* don't keep in chip cache */
+		FW_RI_RES_WR_PCIECHN_V(0) |	/* set by uP at ri_init time */
+		(t4_sq_onchip(&wq->sq) ? FW_RI_RES_WR_ONCHIP_F : 0) |
+		FW_RI_RES_WR_IQID_V(scq->cqid));
 	res->u.sqrq.dcaen_to_eqsize = cpu_to_be32(
-		V_FW_RI_RES_WR_DCAEN(0) |
-		V_FW_RI_RES_WR_DCACPU(0) |
-		V_FW_RI_RES_WR_FBMIN(2) |
-		V_FW_RI_RES_WR_FBMAX(2) |
-		V_FW_RI_RES_WR_CIDXFTHRESHO(0) |
-		V_FW_RI_RES_WR_CIDXFTHRESH(0) |
-		V_FW_RI_RES_WR_EQSIZE(eqsize));
+		FW_RI_RES_WR_DCAEN_V(0) |
+		FW_RI_RES_WR_DCACPU_V(0) |
+		FW_RI_RES_WR_FBMIN_V(2) |
+		FW_RI_RES_WR_FBMAX_V(2) |
+		FW_RI_RES_WR_CIDXFTHRESHO_V(0) |
+		FW_RI_RES_WR_CIDXFTHRESH_V(0) |
+		FW_RI_RES_WR_EQSIZE_V(eqsize));
 	res->u.sqrq.eqid = cpu_to_be32(wq->sq.qid);
 	res->u.sqrq.eqaddr = cpu_to_be64(wq->sq.dma_addr);
 	res++;
@@ -312,18 +312,18 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	eqsize = wq->rq.size * T4_RQ_NUM_SLOTS +
 		rdev->hw_queue.t4_eq_status_entries;
 	res->u.sqrq.fetchszm_to_iqid = cpu_to_be32(
-		V_FW_RI_RES_WR_HOSTFCMODE(0) |	/* no host cidx updates */
-		V_FW_RI_RES_WR_CPRIO(0) |	/* don't keep in chip cache */
-		V_FW_RI_RES_WR_PCIECHN(0) |	/* set by uP at ri_init time */
-		V_FW_RI_RES_WR_IQID(rcq->cqid));
+		FW_RI_RES_WR_HOSTFCMODE_V(0) |	/* no host cidx updates */
+		FW_RI_RES_WR_CPRIO_V(0) |	/* don't keep in chip cache */
+		FW_RI_RES_WR_PCIECHN_V(0) |	/* set by uP at ri_init time */
+		FW_RI_RES_WR_IQID_V(rcq->cqid));
 	res->u.sqrq.dcaen_to_eqsize = cpu_to_be32(
-		V_FW_RI_RES_WR_DCAEN(0) |
-		V_FW_RI_RES_WR_DCACPU(0) |
-		V_FW_RI_RES_WR_FBMIN(2) |
-		V_FW_RI_RES_WR_FBMAX(2) |
-		V_FW_RI_RES_WR_CIDXFTHRESHO(0) |
-		V_FW_RI_RES_WR_CIDXFTHRESH(0) |
-		V_FW_RI_RES_WR_EQSIZE(eqsize));
+		FW_RI_RES_WR_DCAEN_V(0) |
+		FW_RI_RES_WR_DCACPU_V(0) |
+		FW_RI_RES_WR_FBMIN_V(2) |
+		FW_RI_RES_WR_FBMAX_V(2) |
+		FW_RI_RES_WR_CIDXFTHRESHO_V(0) |
+		FW_RI_RES_WR_CIDXFTHRESH_V(0) |
+		FW_RI_RES_WR_EQSIZE_V(eqsize));
 	res->u.sqrq.eqid = cpu_to_be32(wq->rq.qid);
 	res->u.sqrq.eqaddr = cpu_to_be64(wq->rq.dma_addr);
 
@@ -444,19 +444,19 @@ static int build_rdma_send(struct t4_sq *sq, union t4_wr *wqe,
 	case IB_WR_SEND:
 		if (wr->send_flags & IB_SEND_SOLICITED)
 			wqe->send.sendop_pkd = cpu_to_be32(
-				V_FW_RI_SEND_WR_SENDOP(FW_RI_SEND_WITH_SE));
+				FW_RI_SEND_WR_SENDOP_V(FW_RI_SEND_WITH_SE));
 		else
 			wqe->send.sendop_pkd = cpu_to_be32(
-				V_FW_RI_SEND_WR_SENDOP(FW_RI_SEND));
+				FW_RI_SEND_WR_SENDOP_V(FW_RI_SEND));
 		wqe->send.stag_inv = 0;
 		break;
 	case IB_WR_SEND_WITH_INV:
 		if (wr->send_flags & IB_SEND_SOLICITED)
 			wqe->send.sendop_pkd = cpu_to_be32(
-				V_FW_RI_SEND_WR_SENDOP(FW_RI_SEND_WITH_SE_INV));
+				FW_RI_SEND_WR_SENDOP_V(FW_RI_SEND_WITH_SE_INV));
 		else
 			wqe->send.sendop_pkd = cpu_to_be32(
-				V_FW_RI_SEND_WR_SENDOP(FW_RI_SEND_WITH_INV));
+				FW_RI_SEND_WR_SENDOP_V(FW_RI_SEND_WITH_INV));
 		wqe->send.stag_inv = cpu_to_be32(wr->ex.invalidate_rkey);
 		break;
 
@@ -1283,8 +1283,8 @@ static int rdma_init(struct c4iw_dev *rhp, struct c4iw_qp *qhp)
 
 	wqe->u.init.type = FW_RI_TYPE_INIT;
 	wqe->u.init.mpareqbit_p2ptype =
-		V_FW_RI_WR_MPAREQBIT(qhp->attr.mpa_attr.initiator) |
-		V_FW_RI_WR_P2PTYPE(qhp->attr.mpa_attr.p2p_type);
+		FW_RI_WR_MPAREQBIT_V(qhp->attr.mpa_attr.initiator) |
+		FW_RI_WR_P2PTYPE_V(qhp->attr.mpa_attr.p2p_type);
 	wqe->u.init.mpa_attrs = FW_RI_MPA_IETF_ENABLE;
 	if (qhp->attr.mpa_attr.recv_marker_enabled)
 		wqe->u.init.mpa_attrs |= FW_RI_MPA_RX_MARKER_ENABLE;
diff --git a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
index 5709e77..5e53327 100644
--- a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
+++ b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
@@ -162,102 +162,102 @@ struct fw_ri_tpte {
 	__be32 len_hi;
 };
 
-#define S_FW_RI_TPTE_VALID		31
-#define M_FW_RI_TPTE_VALID		0x1
-#define V_FW_RI_TPTE_VALID(x)		((x) << S_FW_RI_TPTE_VALID)
-#define G_FW_RI_TPTE_VALID(x)		\
-    (((x) >> S_FW_RI_TPTE_VALID) & M_FW_RI_TPTE_VALID)
-#define F_FW_RI_TPTE_VALID		V_FW_RI_TPTE_VALID(1U)
-
-#define S_FW_RI_TPTE_STAGKEY		23
-#define M_FW_RI_TPTE_STAGKEY		0xff
-#define V_FW_RI_TPTE_STAGKEY(x)		((x) << S_FW_RI_TPTE_STAGKEY)
-#define G_FW_RI_TPTE_STAGKEY(x)		\
-    (((x) >> S_FW_RI_TPTE_STAGKEY) & M_FW_RI_TPTE_STAGKEY)
-
-#define S_FW_RI_TPTE_STAGSTATE		22
-#define M_FW_RI_TPTE_STAGSTATE		0x1
-#define V_FW_RI_TPTE_STAGSTATE(x)	((x) << S_FW_RI_TPTE_STAGSTATE)
-#define G_FW_RI_TPTE_STAGSTATE(x)	\
-    (((x) >> S_FW_RI_TPTE_STAGSTATE) & M_FW_RI_TPTE_STAGSTATE)
-#define F_FW_RI_TPTE_STAGSTATE		V_FW_RI_TPTE_STAGSTATE(1U)
-
-#define S_FW_RI_TPTE_STAGTYPE		20
-#define M_FW_RI_TPTE_STAGTYPE		0x3
-#define V_FW_RI_TPTE_STAGTYPE(x)	((x) << S_FW_RI_TPTE_STAGTYPE)
-#define G_FW_RI_TPTE_STAGTYPE(x)	\
-    (((x) >> S_FW_RI_TPTE_STAGTYPE) & M_FW_RI_TPTE_STAGTYPE)
-
-#define S_FW_RI_TPTE_PDID		0
-#define M_FW_RI_TPTE_PDID		0xfffff
-#define V_FW_RI_TPTE_PDID(x)		((x) << S_FW_RI_TPTE_PDID)
-#define G_FW_RI_TPTE_PDID(x)		\
-    (((x) >> S_FW_RI_TPTE_PDID) & M_FW_RI_TPTE_PDID)
-
-#define S_FW_RI_TPTE_PERM		28
-#define M_FW_RI_TPTE_PERM		0xf
-#define V_FW_RI_TPTE_PERM(x)		((x) << S_FW_RI_TPTE_PERM)
-#define G_FW_RI_TPTE_PERM(x)		\
-    (((x) >> S_FW_RI_TPTE_PERM) & M_FW_RI_TPTE_PERM)
-
-#define S_FW_RI_TPTE_REMINVDIS		27
-#define M_FW_RI_TPTE_REMINVDIS		0x1
-#define V_FW_RI_TPTE_REMINVDIS(x)	((x) << S_FW_RI_TPTE_REMINVDIS)
-#define G_FW_RI_TPTE_REMINVDIS(x)	\
-    (((x) >> S_FW_RI_TPTE_REMINVDIS) & M_FW_RI_TPTE_REMINVDIS)
-#define F_FW_RI_TPTE_REMINVDIS		V_FW_RI_TPTE_REMINVDIS(1U)
-
-#define S_FW_RI_TPTE_ADDRTYPE		26
-#define M_FW_RI_TPTE_ADDRTYPE		1
-#define V_FW_RI_TPTE_ADDRTYPE(x)	((x) << S_FW_RI_TPTE_ADDRTYPE)
-#define G_FW_RI_TPTE_ADDRTYPE(x)	\
-    (((x) >> S_FW_RI_TPTE_ADDRTYPE) & M_FW_RI_TPTE_ADDRTYPE)
-#define F_FW_RI_TPTE_ADDRTYPE		V_FW_RI_TPTE_ADDRTYPE(1U)
-
-#define S_FW_RI_TPTE_MWBINDEN		25
-#define M_FW_RI_TPTE_MWBINDEN		0x1
-#define V_FW_RI_TPTE_MWBINDEN(x)	((x) << S_FW_RI_TPTE_MWBINDEN)
-#define G_FW_RI_TPTE_MWBINDEN(x)	\
-    (((x) >> S_FW_RI_TPTE_MWBINDEN) & M_FW_RI_TPTE_MWBINDEN)
-#define F_FW_RI_TPTE_MWBINDEN		V_FW_RI_TPTE_MWBINDEN(1U)
-
-#define S_FW_RI_TPTE_PS			20
-#define M_FW_RI_TPTE_PS			0x1f
-#define V_FW_RI_TPTE_PS(x)		((x) << S_FW_RI_TPTE_PS)
-#define G_FW_RI_TPTE_PS(x)		\
-    (((x) >> S_FW_RI_TPTE_PS) & M_FW_RI_TPTE_PS)
-
-#define S_FW_RI_TPTE_QPID		0
-#define M_FW_RI_TPTE_QPID		0xfffff
-#define V_FW_RI_TPTE_QPID(x)		((x) << S_FW_RI_TPTE_QPID)
-#define G_FW_RI_TPTE_QPID(x)		\
-    (((x) >> S_FW_RI_TPTE_QPID) & M_FW_RI_TPTE_QPID)
-
-#define S_FW_RI_TPTE_NOSNOOP		30
-#define M_FW_RI_TPTE_NOSNOOP		0x1
-#define V_FW_RI_TPTE_NOSNOOP(x)		((x) << S_FW_RI_TPTE_NOSNOOP)
-#define G_FW_RI_TPTE_NOSNOOP(x)		\
-    (((x) >> S_FW_RI_TPTE_NOSNOOP) & M_FW_RI_TPTE_NOSNOOP)
-#define F_FW_RI_TPTE_NOSNOOP		V_FW_RI_TPTE_NOSNOOP(1U)
-
-#define S_FW_RI_TPTE_PBLADDR		0
-#define M_FW_RI_TPTE_PBLADDR		0x1fffffff
-#define V_FW_RI_TPTE_PBLADDR(x)		((x) << S_FW_RI_TPTE_PBLADDR)
-#define G_FW_RI_TPTE_PBLADDR(x)		\
-    (((x) >> S_FW_RI_TPTE_PBLADDR) & M_FW_RI_TPTE_PBLADDR)
-
-#define S_FW_RI_TPTE_DCA		24
-#define M_FW_RI_TPTE_DCA		0x1f
-#define V_FW_RI_TPTE_DCA(x)		((x) << S_FW_RI_TPTE_DCA)
-#define G_FW_RI_TPTE_DCA(x)		\
-    (((x) >> S_FW_RI_TPTE_DCA) & M_FW_RI_TPTE_DCA)
-
-#define S_FW_RI_TPTE_MWBCNT_PSTAG	0
-#define M_FW_RI_TPTE_MWBCNT_PSTAG	0xffffff
-#define V_FW_RI_TPTE_MWBCNT_PSTAT(x)	\
-    ((x) << S_FW_RI_TPTE_MWBCNT_PSTAG)
-#define G_FW_RI_TPTE_MWBCNT_PSTAG(x)	\
-    (((x) >> S_FW_RI_TPTE_MWBCNT_PSTAG) & M_FW_RI_TPTE_MWBCNT_PSTAG)
+#define FW_RI_TPTE_VALID_S		31
+#define FW_RI_TPTE_VALID_M		0x1
+#define FW_RI_TPTE_VALID_V(x)		((x) << FW_RI_TPTE_VALID_S)
+#define FW_RI_TPTE_VALID_G(x)		\
+	(((x) >> FW_RI_TPTE_VALID_S) & FW_RI_TPTE_VALID_M)
+#define FW_RI_TPTE_VALID_F		FW_RI_TPTE_VALID_V(1U)
+
+#define FW_RI_TPTE_STAGKEY_S		23
+#define FW_RI_TPTE_STAGKEY_M		0xff
+#define FW_RI_TPTE_STAGKEY_V(x)		((x) << FW_RI_TPTE_STAGKEY_S)
+#define FW_RI_TPTE_STAGKEY_G(x)		\
+	(((x) >> FW_RI_TPTE_STAGKEY_S) & FW_RI_TPTE_STAGKEY_M)
+
+#define FW_RI_TPTE_STAGSTATE_S		22
+#define FW_RI_TPTE_STAGSTATE_M		0x1
+#define FW_RI_TPTE_STAGSTATE_V(x)	((x) << FW_RI_TPTE_STAGSTATE_S)
+#define FW_RI_TPTE_STAGSTATE_G(x)	\
+	(((x) >> FW_RI_TPTE_STAGSTATE_S) & FW_RI_TPTE_STAGSTATE_M)
+#define FW_RI_TPTE_STAGSTATE_F		FW_RI_TPTE_STAGSTATE_V(1U)
+
+#define FW_RI_TPTE_STAGTYPE_S		20
+#define FW_RI_TPTE_STAGTYPE_M		0x3
+#define FW_RI_TPTE_STAGTYPE_V(x)	((x) << FW_RI_TPTE_STAGTYPE_S)
+#define FW_RI_TPTE_STAGTYPE_G(x)	\
+	(((x) >> FW_RI_TPTE_STAGTYPE_S) & FW_RI_TPTE_STAGTYPE_M)
+
+#define FW_RI_TPTE_PDID_S		0
+#define FW_RI_TPTE_PDID_M		0xfffff
+#define FW_RI_TPTE_PDID_V(x)		((x) << FW_RI_TPTE_PDID_S)
+#define FW_RI_TPTE_PDID_G(x)		\
+	(((x) >> FW_RI_TPTE_PDID_S) & FW_RI_TPTE_PDID_M)
+
+#define FW_RI_TPTE_PERM_S		28
+#define FW_RI_TPTE_PERM_M		0xf
+#define FW_RI_TPTE_PERM_V(x)		((x) << FW_RI_TPTE_PERM_S)
+#define FW_RI_TPTE_PERM_G(x)		\
+	(((x) >> FW_RI_TPTE_PERM_S) & FW_RI_TPTE_PERM_M)
+
+#define FW_RI_TPTE_REMINVDIS_S		27
+#define FW_RI_TPTE_REMINVDIS_M		0x1
+#define FW_RI_TPTE_REMINVDIS_V(x)	((x) << FW_RI_TPTE_REMINVDIS_S)
+#define FW_RI_TPTE_REMINVDIS_G(x)	\
+	(((x) >> FW_RI_TPTE_REMINVDIS_S) & FW_RI_TPTE_REMINVDIS_M)
+#define FW_RI_TPTE_REMINVDIS_F		FW_RI_TPTE_REMINVDIS_V(1U)
+
+#define FW_RI_TPTE_ADDRTYPE_S		26
+#define FW_RI_TPTE_ADDRTYPE_M		1
+#define FW_RI_TPTE_ADDRTYPE_V(x)	((x) << FW_RI_TPTE_ADDRTYPE_S)
+#define FW_RI_TPTE_ADDRTYPE_G(x)	\
+	(((x) >> FW_RI_TPTE_ADDRTYPE_S) & FW_RI_TPTE_ADDRTYPE_M)
+#define FW_RI_TPTE_ADDRTYPE_F		FW_RI_TPTE_ADDRTYPE_V(1U)
+
+#define FW_RI_TPTE_MWBINDEN_S		25
+#define FW_RI_TPTE_MWBINDEN_M		0x1
+#define FW_RI_TPTE_MWBINDEN_V(x)	((x) << FW_RI_TPTE_MWBINDEN_S)
+#define FW_RI_TPTE_MWBINDEN_G(x)	\
+	(((x) >> FW_RI_TPTE_MWBINDEN_S) & FW_RI_TPTE_MWBINDEN_M)
+#define FW_RI_TPTE_MWBINDEN_F		FW_RI_TPTE_MWBINDEN_V(1U)
+
+#define FW_RI_TPTE_PS_S			20
+#define FW_RI_TPTE_PS_M			0x1f
+#define FW_RI_TPTE_PS_V(x)		((x) << FW_RI_TPTE_PS_S)
+#define FW_RI_TPTE_PS_G(x)		\
+	(((x) >> FW_RI_TPTE_PS_S) & FW_RI_TPTE_PS_M)
+
+#define FW_RI_TPTE_QPID_S		0
+#define FW_RI_TPTE_QPID_M		0xfffff
+#define FW_RI_TPTE_QPID_V(x)		((x) << FW_RI_TPTE_QPID_S)
+#define FW_RI_TPTE_QPID_G(x)		\
+	(((x) >> FW_RI_TPTE_QPID_S) & FW_RI_TPTE_QPID_M)
+
+#define FW_RI_TPTE_NOSNOOP_S		30
+#define FW_RI_TPTE_NOSNOOP_M		0x1
+#define FW_RI_TPTE_NOSNOOP_V(x)		((x) << FW_RI_TPTE_NOSNOOP_S)
+#define FW_RI_TPTE_NOSNOOP_G(x)		\
+	(((x) >> FW_RI_TPTE_NOSNOOP_S) & FW_RI_TPTE_NOSNOOP_M)
+#define FW_RI_TPTE_NOSNOOP_F		FW_RI_TPTE_NOSNOOP_V(1U)
+
+#define FW_RI_TPTE_PBLADDR_S		0
+#define FW_RI_TPTE_PBLADDR_M		0x1fffffff
+#define FW_RI_TPTE_PBLADDR_V(x)		((x) << FW_RI_TPTE_PBLADDR_S)
+#define FW_RI_TPTE_PBLADDR_G(x)		\
+	(((x) >> FW_RI_TPTE_PBLADDR_S) & FW_RI_TPTE_PBLADDR_M)
+
+#define FW_RI_TPTE_DCA_S		24
+#define FW_RI_TPTE_DCA_M		0x1f
+#define FW_RI_TPTE_DCA_V(x)		((x) << FW_RI_TPTE_DCA_S)
+#define FW_RI_TPTE_DCA_G(x)		\
+	(((x) >> FW_RI_TPTE_DCA_S) & FW_RI_TPTE_DCA_M)
+
+#define FW_RI_TPTE_MWBCNT_PSTAG_S	0
+#define FW_RI_TPTE_MWBCNT_PSTAG_M	0xffffff
+#define FW_RI_TPTE_MWBCNT_PSTAT_V(x)	\
+	((x) << FW_RI_TPTE_MWBCNT_PSTAG_S)
+#define FW_RI_TPTE_MWBCNT_PSTAG_G(x)	\
+	(((x) >> FW_RI_TPTE_MWBCNT_PSTAG_S) & FW_RI_TPTE_MWBCNT_PSTAG_M)
 
 enum fw_ri_res_type {
 	FW_RI_RES_TYPE_SQ,
@@ -308,222 +308,222 @@ struct fw_ri_res_wr {
 #endif
 };
 
-#define S_FW_RI_RES_WR_NRES	0
-#define M_FW_RI_RES_WR_NRES	0xff
-#define V_FW_RI_RES_WR_NRES(x)	((x) << S_FW_RI_RES_WR_NRES)
-#define G_FW_RI_RES_WR_NRES(x)	\
-    (((x) >> S_FW_RI_RES_WR_NRES) & M_FW_RI_RES_WR_NRES)
-
-#define S_FW_RI_RES_WR_FETCHSZM		26
-#define M_FW_RI_RES_WR_FETCHSZM		0x1
-#define V_FW_RI_RES_WR_FETCHSZM(x)	((x) << S_FW_RI_RES_WR_FETCHSZM)
-#define G_FW_RI_RES_WR_FETCHSZM(x)	\
-    (((x) >> S_FW_RI_RES_WR_FETCHSZM) & M_FW_RI_RES_WR_FETCHSZM)
-#define F_FW_RI_RES_WR_FETCHSZM	V_FW_RI_RES_WR_FETCHSZM(1U)
-
-#define S_FW_RI_RES_WR_STATUSPGNS	25
-#define M_FW_RI_RES_WR_STATUSPGNS	0x1
-#define V_FW_RI_RES_WR_STATUSPGNS(x)	((x) << S_FW_RI_RES_WR_STATUSPGNS)
-#define G_FW_RI_RES_WR_STATUSPGNS(x)	\
-    (((x) >> S_FW_RI_RES_WR_STATUSPGNS) & M_FW_RI_RES_WR_STATUSPGNS)
-#define F_FW_RI_RES_WR_STATUSPGNS	V_FW_RI_RES_WR_STATUSPGNS(1U)
-
-#define S_FW_RI_RES_WR_STATUSPGRO	24
-#define M_FW_RI_RES_WR_STATUSPGRO	0x1
-#define V_FW_RI_RES_WR_STATUSPGRO(x)	((x) << S_FW_RI_RES_WR_STATUSPGRO)
-#define G_FW_RI_RES_WR_STATUSPGRO(x)	\
-    (((x) >> S_FW_RI_RES_WR_STATUSPGRO) & M_FW_RI_RES_WR_STATUSPGRO)
-#define F_FW_RI_RES_WR_STATUSPGRO	V_FW_RI_RES_WR_STATUSPGRO(1U)
-
-#define S_FW_RI_RES_WR_FETCHNS		23
-#define M_FW_RI_RES_WR_FETCHNS		0x1
-#define V_FW_RI_RES_WR_FETCHNS(x)	((x) << S_FW_RI_RES_WR_FETCHNS)
-#define G_FW_RI_RES_WR_FETCHNS(x)	\
-    (((x) >> S_FW_RI_RES_WR_FETCHNS) & M_FW_RI_RES_WR_FETCHNS)
-#define F_FW_RI_RES_WR_FETCHNS	V_FW_RI_RES_WR_FETCHNS(1U)
-
-#define S_FW_RI_RES_WR_FETCHRO		22
-#define M_FW_RI_RES_WR_FETCHRO		0x1
-#define V_FW_RI_RES_WR_FETCHRO(x)	((x) << S_FW_RI_RES_WR_FETCHRO)
-#define G_FW_RI_RES_WR_FETCHRO(x)	\
-    (((x) >> S_FW_RI_RES_WR_FETCHRO) & M_FW_RI_RES_WR_FETCHRO)
-#define F_FW_RI_RES_WR_FETCHRO	V_FW_RI_RES_WR_FETCHRO(1U)
-
-#define S_FW_RI_RES_WR_HOSTFCMODE	20
-#define M_FW_RI_RES_WR_HOSTFCMODE	0x3
-#define V_FW_RI_RES_WR_HOSTFCMODE(x)	((x) << S_FW_RI_RES_WR_HOSTFCMODE)
-#define G_FW_RI_RES_WR_HOSTFCMODE(x)	\
-    (((x) >> S_FW_RI_RES_WR_HOSTFCMODE) & M_FW_RI_RES_WR_HOSTFCMODE)
-
-#define S_FW_RI_RES_WR_CPRIO	19
-#define M_FW_RI_RES_WR_CPRIO	0x1
-#define V_FW_RI_RES_WR_CPRIO(x)	((x) << S_FW_RI_RES_WR_CPRIO)
-#define G_FW_RI_RES_WR_CPRIO(x)	\
-    (((x) >> S_FW_RI_RES_WR_CPRIO) & M_FW_RI_RES_WR_CPRIO)
-#define F_FW_RI_RES_WR_CPRIO	V_FW_RI_RES_WR_CPRIO(1U)
-
-#define S_FW_RI_RES_WR_ONCHIP		18
-#define M_FW_RI_RES_WR_ONCHIP		0x1
-#define V_FW_RI_RES_WR_ONCHIP(x)	((x) << S_FW_RI_RES_WR_ONCHIP)
-#define G_FW_RI_RES_WR_ONCHIP(x)	\
-    (((x) >> S_FW_RI_RES_WR_ONCHIP) & M_FW_RI_RES_WR_ONCHIP)
-#define F_FW_RI_RES_WR_ONCHIP	V_FW_RI_RES_WR_ONCHIP(1U)
-
-#define S_FW_RI_RES_WR_PCIECHN		16
-#define M_FW_RI_RES_WR_PCIECHN		0x3
-#define V_FW_RI_RES_WR_PCIECHN(x)	((x) << S_FW_RI_RES_WR_PCIECHN)
-#define G_FW_RI_RES_WR_PCIECHN(x)	\
-    (((x) >> S_FW_RI_RES_WR_PCIECHN) & M_FW_RI_RES_WR_PCIECHN)
-
-#define S_FW_RI_RES_WR_IQID	0
-#define M_FW_RI_RES_WR_IQID	0xffff
-#define V_FW_RI_RES_WR_IQID(x)	((x) << S_FW_RI_RES_WR_IQID)
-#define G_FW_RI_RES_WR_IQID(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQID) & M_FW_RI_RES_WR_IQID)
-
-#define S_FW_RI_RES_WR_DCAEN	31
-#define M_FW_RI_RES_WR_DCAEN	0x1
-#define V_FW_RI_RES_WR_DCAEN(x)	((x) << S_FW_RI_RES_WR_DCAEN)
-#define G_FW_RI_RES_WR_DCAEN(x)	\
-    (((x) >> S_FW_RI_RES_WR_DCAEN) & M_FW_RI_RES_WR_DCAEN)
-#define F_FW_RI_RES_WR_DCAEN	V_FW_RI_RES_WR_DCAEN(1U)
-
-#define S_FW_RI_RES_WR_DCACPU		26
-#define M_FW_RI_RES_WR_DCACPU		0x1f
-#define V_FW_RI_RES_WR_DCACPU(x)	((x) << S_FW_RI_RES_WR_DCACPU)
-#define G_FW_RI_RES_WR_DCACPU(x)	\
-    (((x) >> S_FW_RI_RES_WR_DCACPU) & M_FW_RI_RES_WR_DCACPU)
-
-#define S_FW_RI_RES_WR_FBMIN	23
-#define M_FW_RI_RES_WR_FBMIN	0x7
-#define V_FW_RI_RES_WR_FBMIN(x)	((x) << S_FW_RI_RES_WR_FBMIN)
-#define G_FW_RI_RES_WR_FBMIN(x)	\
-    (((x) >> S_FW_RI_RES_WR_FBMIN) & M_FW_RI_RES_WR_FBMIN)
-
-#define S_FW_RI_RES_WR_FBMAX	20
-#define M_FW_RI_RES_WR_FBMAX	0x7
-#define V_FW_RI_RES_WR_FBMAX(x)	((x) << S_FW_RI_RES_WR_FBMAX)
-#define G_FW_RI_RES_WR_FBMAX(x)	\
-    (((x) >> S_FW_RI_RES_WR_FBMAX) & M_FW_RI_RES_WR_FBMAX)
-
-#define S_FW_RI_RES_WR_CIDXFTHRESHO	19
-#define M_FW_RI_RES_WR_CIDXFTHRESHO	0x1
-#define V_FW_RI_RES_WR_CIDXFTHRESHO(x)	((x) << S_FW_RI_RES_WR_CIDXFTHRESHO)
-#define G_FW_RI_RES_WR_CIDXFTHRESHO(x)	\
-    (((x) >> S_FW_RI_RES_WR_CIDXFTHRESHO) & M_FW_RI_RES_WR_CIDXFTHRESHO)
-#define F_FW_RI_RES_WR_CIDXFTHRESHO	V_FW_RI_RES_WR_CIDXFTHRESHO(1U)
-
-#define S_FW_RI_RES_WR_CIDXFTHRESH	16
-#define M_FW_RI_RES_WR_CIDXFTHRESH	0x7
-#define V_FW_RI_RES_WR_CIDXFTHRESH(x)	((x) << S_FW_RI_RES_WR_CIDXFTHRESH)
-#define G_FW_RI_RES_WR_CIDXFTHRESH(x)	\
-    (((x) >> S_FW_RI_RES_WR_CIDXFTHRESH) & M_FW_RI_RES_WR_CIDXFTHRESH)
-
-#define S_FW_RI_RES_WR_EQSIZE		0
-#define M_FW_RI_RES_WR_EQSIZE		0xffff
-#define V_FW_RI_RES_WR_EQSIZE(x)	((x) << S_FW_RI_RES_WR_EQSIZE)
-#define G_FW_RI_RES_WR_EQSIZE(x)	\
-    (((x) >> S_FW_RI_RES_WR_EQSIZE) & M_FW_RI_RES_WR_EQSIZE)
-
-#define S_FW_RI_RES_WR_IQANDST		15
-#define M_FW_RI_RES_WR_IQANDST		0x1
-#define V_FW_RI_RES_WR_IQANDST(x)	((x) << S_FW_RI_RES_WR_IQANDST)
-#define G_FW_RI_RES_WR_IQANDST(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQANDST) & M_FW_RI_RES_WR_IQANDST)
-#define F_FW_RI_RES_WR_IQANDST	V_FW_RI_RES_WR_IQANDST(1U)
-
-#define S_FW_RI_RES_WR_IQANUS		14
-#define M_FW_RI_RES_WR_IQANUS		0x1
-#define V_FW_RI_RES_WR_IQANUS(x)	((x) << S_FW_RI_RES_WR_IQANUS)
-#define G_FW_RI_RES_WR_IQANUS(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQANUS) & M_FW_RI_RES_WR_IQANUS)
-#define F_FW_RI_RES_WR_IQANUS	V_FW_RI_RES_WR_IQANUS(1U)
-
-#define S_FW_RI_RES_WR_IQANUD		12
-#define M_FW_RI_RES_WR_IQANUD		0x3
-#define V_FW_RI_RES_WR_IQANUD(x)	((x) << S_FW_RI_RES_WR_IQANUD)
-#define G_FW_RI_RES_WR_IQANUD(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQANUD) & M_FW_RI_RES_WR_IQANUD)
-
-#define S_FW_RI_RES_WR_IQANDSTINDEX	0
-#define M_FW_RI_RES_WR_IQANDSTINDEX	0xfff
-#define V_FW_RI_RES_WR_IQANDSTINDEX(x)	((x) << S_FW_RI_RES_WR_IQANDSTINDEX)
-#define G_FW_RI_RES_WR_IQANDSTINDEX(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQANDSTINDEX) & M_FW_RI_RES_WR_IQANDSTINDEX)
-
-#define S_FW_RI_RES_WR_IQDROPRSS	15
-#define M_FW_RI_RES_WR_IQDROPRSS	0x1
-#define V_FW_RI_RES_WR_IQDROPRSS(x)	((x) << S_FW_RI_RES_WR_IQDROPRSS)
-#define G_FW_RI_RES_WR_IQDROPRSS(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQDROPRSS) & M_FW_RI_RES_WR_IQDROPRSS)
-#define F_FW_RI_RES_WR_IQDROPRSS	V_FW_RI_RES_WR_IQDROPRSS(1U)
-
-#define S_FW_RI_RES_WR_IQGTSMODE	14
-#define M_FW_RI_RES_WR_IQGTSMODE	0x1
-#define V_FW_RI_RES_WR_IQGTSMODE(x)	((x) << S_FW_RI_RES_WR_IQGTSMODE)
-#define G_FW_RI_RES_WR_IQGTSMODE(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQGTSMODE) & M_FW_RI_RES_WR_IQGTSMODE)
-#define F_FW_RI_RES_WR_IQGTSMODE	V_FW_RI_RES_WR_IQGTSMODE(1U)
-
-#define S_FW_RI_RES_WR_IQPCIECH		12
-#define M_FW_RI_RES_WR_IQPCIECH		0x3
-#define V_FW_RI_RES_WR_IQPCIECH(x)	((x) << S_FW_RI_RES_WR_IQPCIECH)
-#define G_FW_RI_RES_WR_IQPCIECH(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQPCIECH) & M_FW_RI_RES_WR_IQPCIECH)
-
-#define S_FW_RI_RES_WR_IQDCAEN		11
-#define M_FW_RI_RES_WR_IQDCAEN		0x1
-#define V_FW_RI_RES_WR_IQDCAEN(x)	((x) << S_FW_RI_RES_WR_IQDCAEN)
-#define G_FW_RI_RES_WR_IQDCAEN(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQDCAEN) & M_FW_RI_RES_WR_IQDCAEN)
-#define F_FW_RI_RES_WR_IQDCAEN	V_FW_RI_RES_WR_IQDCAEN(1U)
-
-#define S_FW_RI_RES_WR_IQDCACPU		6
-#define M_FW_RI_RES_WR_IQDCACPU		0x1f
-#define V_FW_RI_RES_WR_IQDCACPU(x)	((x) << S_FW_RI_RES_WR_IQDCACPU)
-#define G_FW_RI_RES_WR_IQDCACPU(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQDCACPU) & M_FW_RI_RES_WR_IQDCACPU)
-
-#define S_FW_RI_RES_WR_IQINTCNTTHRESH		4
-#define M_FW_RI_RES_WR_IQINTCNTTHRESH		0x3
-#define V_FW_RI_RES_WR_IQINTCNTTHRESH(x)	\
-    ((x) << S_FW_RI_RES_WR_IQINTCNTTHRESH)
-#define G_FW_RI_RES_WR_IQINTCNTTHRESH(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQINTCNTTHRESH) & M_FW_RI_RES_WR_IQINTCNTTHRESH)
-
-#define S_FW_RI_RES_WR_IQO	3
-#define M_FW_RI_RES_WR_IQO	0x1
-#define V_FW_RI_RES_WR_IQO(x)	((x) << S_FW_RI_RES_WR_IQO)
-#define G_FW_RI_RES_WR_IQO(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQO) & M_FW_RI_RES_WR_IQO)
-#define F_FW_RI_RES_WR_IQO	V_FW_RI_RES_WR_IQO(1U)
-
-#define S_FW_RI_RES_WR_IQCPRIO		2
-#define M_FW_RI_RES_WR_IQCPRIO		0x1
-#define V_FW_RI_RES_WR_IQCPRIO(x)	((x) << S_FW_RI_RES_WR_IQCPRIO)
-#define G_FW_RI_RES_WR_IQCPRIO(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQCPRIO) & M_FW_RI_RES_WR_IQCPRIO)
-#define F_FW_RI_RES_WR_IQCPRIO	V_FW_RI_RES_WR_IQCPRIO(1U)
-
-#define S_FW_RI_RES_WR_IQESIZE		0
-#define M_FW_RI_RES_WR_IQESIZE		0x3
-#define V_FW_RI_RES_WR_IQESIZE(x)	((x) << S_FW_RI_RES_WR_IQESIZE)
-#define G_FW_RI_RES_WR_IQESIZE(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQESIZE) & M_FW_RI_RES_WR_IQESIZE)
-
-#define S_FW_RI_RES_WR_IQNS	31
-#define M_FW_RI_RES_WR_IQNS	0x1
-#define V_FW_RI_RES_WR_IQNS(x)	((x) << S_FW_RI_RES_WR_IQNS)
-#define G_FW_RI_RES_WR_IQNS(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQNS) & M_FW_RI_RES_WR_IQNS)
-#define F_FW_RI_RES_WR_IQNS	V_FW_RI_RES_WR_IQNS(1U)
-
-#define S_FW_RI_RES_WR_IQRO	30
-#define M_FW_RI_RES_WR_IQRO	0x1
-#define V_FW_RI_RES_WR_IQRO(x)	((x) << S_FW_RI_RES_WR_IQRO)
-#define G_FW_RI_RES_WR_IQRO(x)	\
-    (((x) >> S_FW_RI_RES_WR_IQRO) & M_FW_RI_RES_WR_IQRO)
-#define F_FW_RI_RES_WR_IQRO	V_FW_RI_RES_WR_IQRO(1U)
+#define FW_RI_RES_WR_NRES_S	0
+#define FW_RI_RES_WR_NRES_M	0xff
+#define FW_RI_RES_WR_NRES_V(x)	((x) << FW_RI_RES_WR_NRES_S)
+#define FW_RI_RES_WR_NRES_G(x)	\
+	(((x) >> FW_RI_RES_WR_NRES_S) & FW_RI_RES_WR_NRES_M)
+
+#define FW_RI_RES_WR_FETCHSZM_S		26
+#define FW_RI_RES_WR_FETCHSZM_M		0x1
+#define FW_RI_RES_WR_FETCHSZM_V(x)	((x) << FW_RI_RES_WR_FETCHSZM_S)
+#define FW_RI_RES_WR_FETCHSZM_G(x)	\
+	(((x) >> FW_RI_RES_WR_FETCHSZM_S) & FW_RI_RES_WR_FETCHSZM_M)
+#define FW_RI_RES_WR_FETCHSZM_F	FW_RI_RES_WR_FETCHSZM_V(1U)
+
+#define FW_RI_RES_WR_STATUSPGNS_S	25
+#define FW_RI_RES_WR_STATUSPGNS_M	0x1
+#define FW_RI_RES_WR_STATUSPGNS_V(x)	((x) << FW_RI_RES_WR_STATUSPGNS_S)
+#define FW_RI_RES_WR_STATUSPGNS_G(x)	\
+	(((x) >> FW_RI_RES_WR_STATUSPGNS_S) & FW_RI_RES_WR_STATUSPGNS_M)
+#define FW_RI_RES_WR_STATUSPGNS_F	FW_RI_RES_WR_STATUSPGNS_V(1U)
+
+#define FW_RI_RES_WR_STATUSPGRO_S	24
+#define FW_RI_RES_WR_STATUSPGRO_M	0x1
+#define FW_RI_RES_WR_STATUSPGRO_V(x)	((x) << FW_RI_RES_WR_STATUSPGRO_S)
+#define FW_RI_RES_WR_STATUSPGRO_G(x)	\
+	(((x) >> FW_RI_RES_WR_STATUSPGRO_S) & FW_RI_RES_WR_STATUSPGRO_M)
+#define FW_RI_RES_WR_STATUSPGRO_F	FW_RI_RES_WR_STATUSPGRO_V(1U)
+
+#define FW_RI_RES_WR_FETCHNS_S		23
+#define FW_RI_RES_WR_FETCHNS_M		0x1
+#define FW_RI_RES_WR_FETCHNS_V(x)	((x) << FW_RI_RES_WR_FETCHNS_S)
+#define FW_RI_RES_WR_FETCHNS_G(x)	\
+	(((x) >> FW_RI_RES_WR_FETCHNS_S) & FW_RI_RES_WR_FETCHNS_M)
+#define FW_RI_RES_WR_FETCHNS_F	FW_RI_RES_WR_FETCHNS_V(1U)
+
+#define FW_RI_RES_WR_FETCHRO_S		22
+#define FW_RI_RES_WR_FETCHRO_M		0x1
+#define FW_RI_RES_WR_FETCHRO_V(x)	((x) << FW_RI_RES_WR_FETCHRO_S)
+#define FW_RI_RES_WR_FETCHRO_G(x)	\
+	(((x) >> FW_RI_RES_WR_FETCHRO_S) & FW_RI_RES_WR_FETCHRO_M)
+#define FW_RI_RES_WR_FETCHRO_F	FW_RI_RES_WR_FETCHRO_V(1U)
+
+#define FW_RI_RES_WR_HOSTFCMODE_S	20
+#define FW_RI_RES_WR_HOSTFCMODE_M	0x3
+#define FW_RI_RES_WR_HOSTFCMODE_V(x)	((x) << FW_RI_RES_WR_HOSTFCMODE_S)
+#define FW_RI_RES_WR_HOSTFCMODE_G(x)	\
+	(((x) >> FW_RI_RES_WR_HOSTFCMODE_S) & FW_RI_RES_WR_HOSTFCMODE_M)
+
+#define FW_RI_RES_WR_CPRIO_S	19
+#define FW_RI_RES_WR_CPRIO_M	0x1
+#define FW_RI_RES_WR_CPRIO_V(x)	((x) << FW_RI_RES_WR_CPRIO_S)
+#define FW_RI_RES_WR_CPRIO_G(x)	\
+	(((x) >> FW_RI_RES_WR_CPRIO_S) & FW_RI_RES_WR_CPRIO_M)
+#define FW_RI_RES_WR_CPRIO_F	FW_RI_RES_WR_CPRIO_V(1U)
+
+#define FW_RI_RES_WR_ONCHIP_S		18
+#define FW_RI_RES_WR_ONCHIP_M		0x1
+#define FW_RI_RES_WR_ONCHIP_V(x)	((x) << FW_RI_RES_WR_ONCHIP_S)
+#define FW_RI_RES_WR_ONCHIP_G(x)	\
+	(((x) >> FW_RI_RES_WR_ONCHIP_S) & FW_RI_RES_WR_ONCHIP_M)
+#define FW_RI_RES_WR_ONCHIP_F	FW_RI_RES_WR_ONCHIP_V(1U)
+
+#define FW_RI_RES_WR_PCIECHN_S		16
+#define FW_RI_RES_WR_PCIECHN_M		0x3
+#define FW_RI_RES_WR_PCIECHN_V(x)	((x) << FW_RI_RES_WR_PCIECHN_S)
+#define FW_RI_RES_WR_PCIECHN_G(x)	\
+	(((x) >> FW_RI_RES_WR_PCIECHN_S) & FW_RI_RES_WR_PCIECHN_M)
+
+#define FW_RI_RES_WR_IQID_S	0
+#define FW_RI_RES_WR_IQID_M	0xffff
+#define FW_RI_RES_WR_IQID_V(x)	((x) << FW_RI_RES_WR_IQID_S)
+#define FW_RI_RES_WR_IQID_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQID_S) & FW_RI_RES_WR_IQID_M)
+
+#define FW_RI_RES_WR_DCAEN_S	31
+#define FW_RI_RES_WR_DCAEN_M	0x1
+#define FW_RI_RES_WR_DCAEN_V(x)	((x) << FW_RI_RES_WR_DCAEN_S)
+#define FW_RI_RES_WR_DCAEN_G(x)	\
+	(((x) >> FW_RI_RES_WR_DCAEN_S) & FW_RI_RES_WR_DCAEN_M)
+#define FW_RI_RES_WR_DCAEN_F	FW_RI_RES_WR_DCAEN_V(1U)
+
+#define FW_RI_RES_WR_DCACPU_S		26
+#define FW_RI_RES_WR_DCACPU_M		0x1f
+#define FW_RI_RES_WR_DCACPU_V(x)	((x) << FW_RI_RES_WR_DCACPU_S)
+#define FW_RI_RES_WR_DCACPU_G(x)	\
+	(((x) >> FW_RI_RES_WR_DCACPU_S) & FW_RI_RES_WR_DCACPU_M)
+
+#define FW_RI_RES_WR_FBMIN_S	23
+#define FW_RI_RES_WR_FBMIN_M	0x7
+#define FW_RI_RES_WR_FBMIN_V(x)	((x) << FW_RI_RES_WR_FBMIN_S)
+#define FW_RI_RES_WR_FBMIN_G(x)	\
+	(((x) >> FW_RI_RES_WR_FBMIN_S) & FW_RI_RES_WR_FBMIN_M)
+
+#define FW_RI_RES_WR_FBMAX_S	20
+#define FW_RI_RES_WR_FBMAX_M	0x7
+#define FW_RI_RES_WR_FBMAX_V(x)	((x) << FW_RI_RES_WR_FBMAX_S)
+#define FW_RI_RES_WR_FBMAX_G(x)	\
+	(((x) >> FW_RI_RES_WR_FBMAX_S) & FW_RI_RES_WR_FBMAX_M)
+
+#define FW_RI_RES_WR_CIDXFTHRESHO_S	19
+#define FW_RI_RES_WR_CIDXFTHRESHO_M	0x1
+#define FW_RI_RES_WR_CIDXFTHRESHO_V(x)	((x) << FW_RI_RES_WR_CIDXFTHRESHO_S)
+#define FW_RI_RES_WR_CIDXFTHRESHO_G(x)	\
+	(((x) >> FW_RI_RES_WR_CIDXFTHRESHO_S) & FW_RI_RES_WR_CIDXFTHRESHO_M)
+#define FW_RI_RES_WR_CIDXFTHRESHO_F	FW_RI_RES_WR_CIDXFTHRESHO_V(1U)
+
+#define FW_RI_RES_WR_CIDXFTHRESH_S	16
+#define FW_RI_RES_WR_CIDXFTHRESH_M	0x7
+#define FW_RI_RES_WR_CIDXFTHRESH_V(x)	((x) << FW_RI_RES_WR_CIDXFTHRESH_S)
+#define FW_RI_RES_WR_CIDXFTHRESH_G(x)	\
+	(((x) >> FW_RI_RES_WR_CIDXFTHRESH_S) & FW_RI_RES_WR_CIDXFTHRESH_M)
+
+#define FW_RI_RES_WR_EQSIZE_S		0
+#define FW_RI_RES_WR_EQSIZE_M		0xffff
+#define FW_RI_RES_WR_EQSIZE_V(x)	((x) << FW_RI_RES_WR_EQSIZE_S)
+#define FW_RI_RES_WR_EQSIZE_G(x)	\
+	(((x) >> FW_RI_RES_WR_EQSIZE_S) & FW_RI_RES_WR_EQSIZE_M)
+
+#define FW_RI_RES_WR_IQANDST_S		15
+#define FW_RI_RES_WR_IQANDST_M		0x1
+#define FW_RI_RES_WR_IQANDST_V(x)	((x) << FW_RI_RES_WR_IQANDST_S)
+#define FW_RI_RES_WR_IQANDST_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQANDST_S) & FW_RI_RES_WR_IQANDST_M)
+#define FW_RI_RES_WR_IQANDST_F	FW_RI_RES_WR_IQANDST_V(1U)
+
+#define FW_RI_RES_WR_IQANUS_S		14
+#define FW_RI_RES_WR_IQANUS_M		0x1
+#define FW_RI_RES_WR_IQANUS_V(x)	((x) << FW_RI_RES_WR_IQANUS_S)
+#define FW_RI_RES_WR_IQANUS_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQANUS_S) & FW_RI_RES_WR_IQANUS_M)
+#define FW_RI_RES_WR_IQANUS_F	FW_RI_RES_WR_IQANUS_V(1U)
+
+#define FW_RI_RES_WR_IQANUD_S		12
+#define FW_RI_RES_WR_IQANUD_M		0x3
+#define FW_RI_RES_WR_IQANUD_V(x)	((x) << FW_RI_RES_WR_IQANUD_S)
+#define FW_RI_RES_WR_IQANUD_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQANUD_S) & FW_RI_RES_WR_IQANUD_M)
+
+#define FW_RI_RES_WR_IQANDSTINDEX_S	0
+#define FW_RI_RES_WR_IQANDSTINDEX_M	0xfff
+#define FW_RI_RES_WR_IQANDSTINDEX_V(x)	((x) << FW_RI_RES_WR_IQANDSTINDEX_S)
+#define FW_RI_RES_WR_IQANDSTINDEX_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQANDSTINDEX_S) & FW_RI_RES_WR_IQANDSTINDEX_M)
+
+#define FW_RI_RES_WR_IQDROPRSS_S	15
+#define FW_RI_RES_WR_IQDROPRSS_M	0x1
+#define FW_RI_RES_WR_IQDROPRSS_V(x)	((x) << FW_RI_RES_WR_IQDROPRSS_S)
+#define FW_RI_RES_WR_IQDROPRSS_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQDROPRSS_S) & FW_RI_RES_WR_IQDROPRSS_M)
+#define FW_RI_RES_WR_IQDROPRSS_F	FW_RI_RES_WR_IQDROPRSS_V(1U)
+
+#define FW_RI_RES_WR_IQGTSMODE_S	14
+#define FW_RI_RES_WR_IQGTSMODE_M	0x1
+#define FW_RI_RES_WR_IQGTSMODE_V(x)	((x) << FW_RI_RES_WR_IQGTSMODE_S)
+#define FW_RI_RES_WR_IQGTSMODE_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQGTSMODE_S) & FW_RI_RES_WR_IQGTSMODE_M)
+#define FW_RI_RES_WR_IQGTSMODE_F	FW_RI_RES_WR_IQGTSMODE_V(1U)
+
+#define FW_RI_RES_WR_IQPCIECH_S		12
+#define FW_RI_RES_WR_IQPCIECH_M		0x3
+#define FW_RI_RES_WR_IQPCIECH_V(x)	((x) << FW_RI_RES_WR_IQPCIECH_S)
+#define FW_RI_RES_WR_IQPCIECH_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQPCIECH_S) & FW_RI_RES_WR_IQPCIECH_M)
+
+#define FW_RI_RES_WR_IQDCAEN_S		11
+#define FW_RI_RES_WR_IQDCAEN_M		0x1
+#define FW_RI_RES_WR_IQDCAEN_V(x)	((x) << FW_RI_RES_WR_IQDCAEN_S)
+#define FW_RI_RES_WR_IQDCAEN_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQDCAEN_S) & FW_RI_RES_WR_IQDCAEN_M)
+#define FW_RI_RES_WR_IQDCAEN_F	FW_RI_RES_WR_IQDCAEN_V(1U)
+
+#define FW_RI_RES_WR_IQDCACPU_S		6
+#define FW_RI_RES_WR_IQDCACPU_M		0x1f
+#define FW_RI_RES_WR_IQDCACPU_V(x)	((x) << FW_RI_RES_WR_IQDCACPU_S)
+#define FW_RI_RES_WR_IQDCACPU_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQDCACPU_S) & FW_RI_RES_WR_IQDCACPU_M)
+
+#define FW_RI_RES_WR_IQINTCNTTHRESH_S		4
+#define FW_RI_RES_WR_IQINTCNTTHRESH_M		0x3
+#define FW_RI_RES_WR_IQINTCNTTHRESH_V(x)	\
+	((x) << FW_RI_RES_WR_IQINTCNTTHRESH_S)
+#define FW_RI_RES_WR_IQINTCNTTHRESH_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQINTCNTTHRESH_S) & FW_RI_RES_WR_IQINTCNTTHRESH_M)
+
+#define FW_RI_RES_WR_IQO_S	3
+#define FW_RI_RES_WR_IQO_M	0x1
+#define FW_RI_RES_WR_IQO_V(x)	((x) << FW_RI_RES_WR_IQO_S)
+#define FW_RI_RES_WR_IQO_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQO_S) & FW_RI_RES_WR_IQO_M)
+#define FW_RI_RES_WR_IQO_F	FW_RI_RES_WR_IQO_V(1U)
+
+#define FW_RI_RES_WR_IQCPRIO_S		2
+#define FW_RI_RES_WR_IQCPRIO_M		0x1
+#define FW_RI_RES_WR_IQCPRIO_V(x)	((x) << FW_RI_RES_WR_IQCPRIO_S)
+#define FW_RI_RES_WR_IQCPRIO_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQCPRIO_S) & FW_RI_RES_WR_IQCPRIO_M)
+#define FW_RI_RES_WR_IQCPRIO_F	FW_RI_RES_WR_IQCPRIO_V(1U)
+
+#define FW_RI_RES_WR_IQESIZE_S		0
+#define FW_RI_RES_WR_IQESIZE_M		0x3
+#define FW_RI_RES_WR_IQESIZE_V(x)	((x) << FW_RI_RES_WR_IQESIZE_S)
+#define FW_RI_RES_WR_IQESIZE_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQESIZE_S) & FW_RI_RES_WR_IQESIZE_M)
+
+#define FW_RI_RES_WR_IQNS_S	31
+#define FW_RI_RES_WR_IQNS_M	0x1
+#define FW_RI_RES_WR_IQNS_V(x)	((x) << FW_RI_RES_WR_IQNS_S)
+#define FW_RI_RES_WR_IQNS_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQNS_S) & FW_RI_RES_WR_IQNS_M)
+#define FW_RI_RES_WR_IQNS_F	FW_RI_RES_WR_IQNS_V(1U)
+
+#define FW_RI_RES_WR_IQRO_S	30
+#define FW_RI_RES_WR_IQRO_M	0x1
+#define FW_RI_RES_WR_IQRO_V(x)	((x) << FW_RI_RES_WR_IQRO_S)
+#define FW_RI_RES_WR_IQRO_G(x)	\
+	(((x) >> FW_RI_RES_WR_IQRO_S) & FW_RI_RES_WR_IQRO_M)
+#define FW_RI_RES_WR_IQRO_F	FW_RI_RES_WR_IQRO_V(1U)
 
 struct fw_ri_rdma_write_wr {
 	__u8   opcode;
@@ -562,11 +562,11 @@ struct fw_ri_send_wr {
 #endif
 };
 
-#define S_FW_RI_SEND_WR_SENDOP		0
-#define M_FW_RI_SEND_WR_SENDOP		0xf
-#define V_FW_RI_SEND_WR_SENDOP(x)	((x) << S_FW_RI_SEND_WR_SENDOP)
-#define G_FW_RI_SEND_WR_SENDOP(x)	\
-    (((x) >> S_FW_RI_SEND_WR_SENDOP) & M_FW_RI_SEND_WR_SENDOP)
+#define FW_RI_SEND_WR_SENDOP_S		0
+#define FW_RI_SEND_WR_SENDOP_M		0xf
+#define FW_RI_SEND_WR_SENDOP_V(x)	((x) << FW_RI_SEND_WR_SENDOP_S)
+#define FW_RI_SEND_WR_SENDOP_G(x)	\
+	(((x) >> FW_RI_SEND_WR_SENDOP_S) & FW_RI_SEND_WR_SENDOP_M)
 
 struct fw_ri_rdma_read_wr {
 	__u8   opcode;
@@ -612,25 +612,25 @@ struct fw_ri_bind_mw_wr {
 	__be64 r4;
 };
 
-#define S_FW_RI_BIND_MW_WR_QPBINDE	6
-#define M_FW_RI_BIND_MW_WR_QPBINDE	0x1
-#define V_FW_RI_BIND_MW_WR_QPBINDE(x)	((x) << S_FW_RI_BIND_MW_WR_QPBINDE)
-#define G_FW_RI_BIND_MW_WR_QPBINDE(x)	\
-    (((x) >> S_FW_RI_BIND_MW_WR_QPBINDE) & M_FW_RI_BIND_MW_WR_QPBINDE)
-#define F_FW_RI_BIND_MW_WR_QPBINDE	V_FW_RI_BIND_MW_WR_QPBINDE(1U)
+#define FW_RI_BIND_MW_WR_QPBINDE_S	6
+#define FW_RI_BIND_MW_WR_QPBINDE_M	0x1
+#define FW_RI_BIND_MW_WR_QPBINDE_V(x)	((x) << FW_RI_BIND_MW_WR_QPBINDE_S)
+#define FW_RI_BIND_MW_WR_QPBINDE_G(x)	\
+	(((x) >> FW_RI_BIND_MW_WR_QPBINDE_S) & FW_RI_BIND_MW_WR_QPBINDE_M)
+#define FW_RI_BIND_MW_WR_QPBINDE_F	FW_RI_BIND_MW_WR_QPBINDE_V(1U)
 
-#define S_FW_RI_BIND_MW_WR_NS		5
-#define M_FW_RI_BIND_MW_WR_NS		0x1
-#define V_FW_RI_BIND_MW_WR_NS(x)	((x) << S_FW_RI_BIND_MW_WR_NS)
-#define G_FW_RI_BIND_MW_WR_NS(x)	\
-    (((x) >> S_FW_RI_BIND_MW_WR_NS) & M_FW_RI_BIND_MW_WR_NS)
-#define F_FW_RI_BIND_MW_WR_NS	V_FW_RI_BIND_MW_WR_NS(1U)
+#define FW_RI_BIND_MW_WR_NS_S		5
+#define FW_RI_BIND_MW_WR_NS_M		0x1
+#define FW_RI_BIND_MW_WR_NS_V(x)	((x) << FW_RI_BIND_MW_WR_NS_S)
+#define FW_RI_BIND_MW_WR_NS_G(x)	\
+	(((x) >> FW_RI_BIND_MW_WR_NS_S) & FW_RI_BIND_MW_WR_NS_M)
+#define FW_RI_BIND_MW_WR_NS_F	FW_RI_BIND_MW_WR_NS_V(1U)
 
-#define S_FW_RI_BIND_MW_WR_DCACPU	0
-#define M_FW_RI_BIND_MW_WR_DCACPU	0x1f
-#define V_FW_RI_BIND_MW_WR_DCACPU(x)	((x) << S_FW_RI_BIND_MW_WR_DCACPU)
-#define G_FW_RI_BIND_MW_WR_DCACPU(x)	\
-    (((x) >> S_FW_RI_BIND_MW_WR_DCACPU) & M_FW_RI_BIND_MW_WR_DCACPU)
+#define FW_RI_BIND_MW_WR_DCACPU_S	0
+#define FW_RI_BIND_MW_WR_DCACPU_M	0x1f
+#define FW_RI_BIND_MW_WR_DCACPU_V(x)	((x) << FW_RI_BIND_MW_WR_DCACPU_S)
+#define FW_RI_BIND_MW_WR_DCACPU_G(x)	\
+	(((x) >> FW_RI_BIND_MW_WR_DCACPU_S) & FW_RI_BIND_MW_WR_DCACPU_M)
 
 struct fw_ri_fr_nsmr_wr {
 	__u8   opcode;
@@ -649,25 +649,25 @@ struct fw_ri_fr_nsmr_wr {
 	__be32 va_lo_fbo;
 };
 
-#define S_FW_RI_FR_NSMR_WR_QPBINDE	6
-#define M_FW_RI_FR_NSMR_WR_QPBINDE	0x1
-#define V_FW_RI_FR_NSMR_WR_QPBINDE(x)	((x) << S_FW_RI_FR_NSMR_WR_QPBINDE)
-#define G_FW_RI_FR_NSMR_WR_QPBINDE(x)	\
-    (((x) >> S_FW_RI_FR_NSMR_WR_QPBINDE) & M_FW_RI_FR_NSMR_WR_QPBINDE)
-#define F_FW_RI_FR_NSMR_WR_QPBINDE	V_FW_RI_FR_NSMR_WR_QPBINDE(1U)
+#define FW_RI_FR_NSMR_WR_QPBINDE_S	6
+#define FW_RI_FR_NSMR_WR_QPBINDE_M	0x1
+#define FW_RI_FR_NSMR_WR_QPBINDE_V(x)	((x) << FW_RI_FR_NSMR_WR_QPBINDE_S)
+#define FW_RI_FR_NSMR_WR_QPBINDE_G(x)	\
+	(((x) >> FW_RI_FR_NSMR_WR_QPBINDE_S) & FW_RI_FR_NSMR_WR_QPBINDE_M)
+#define FW_RI_FR_NSMR_WR_QPBINDE_F	FW_RI_FR_NSMR_WR_QPBINDE_V(1U)
 
-#define S_FW_RI_FR_NSMR_WR_NS		5
-#define M_FW_RI_FR_NSMR_WR_NS		0x1
-#define V_FW_RI_FR_NSMR_WR_NS(x)	((x) << S_FW_RI_FR_NSMR_WR_NS)
-#define G_FW_RI_FR_NSMR_WR_NS(x)	\
-    (((x) >> S_FW_RI_FR_NSMR_WR_NS) & M_FW_RI_FR_NSMR_WR_NS)
-#define F_FW_RI_FR_NSMR_WR_NS	V_FW_RI_FR_NSMR_WR_NS(1U)
+#define FW_RI_FR_NSMR_WR_NS_S		5
+#define FW_RI_FR_NSMR_WR_NS_M		0x1
+#define FW_RI_FR_NSMR_WR_NS_V(x)	((x) << FW_RI_FR_NSMR_WR_NS_S)
+#define FW_RI_FR_NSMR_WR_NS_G(x)	\
+	(((x) >> FW_RI_FR_NSMR_WR_NS_S) & FW_RI_FR_NSMR_WR_NS_M)
+#define FW_RI_FR_NSMR_WR_NS_F	FW_RI_FR_NSMR_WR_NS_V(1U)
 
-#define S_FW_RI_FR_NSMR_WR_DCACPU	0
-#define M_FW_RI_FR_NSMR_WR_DCACPU	0x1f
-#define V_FW_RI_FR_NSMR_WR_DCACPU(x)	((x) << S_FW_RI_FR_NSMR_WR_DCACPU)
-#define G_FW_RI_FR_NSMR_WR_DCACPU(x)	\
-    (((x) >> S_FW_RI_FR_NSMR_WR_DCACPU) & M_FW_RI_FR_NSMR_WR_DCACPU)
+#define FW_RI_FR_NSMR_WR_DCACPU_S	0
+#define FW_RI_FR_NSMR_WR_DCACPU_M	0x1f
+#define FW_RI_FR_NSMR_WR_DCACPU_V(x)	((x) << FW_RI_FR_NSMR_WR_DCACPU_S)
+#define FW_RI_FR_NSMR_WR_DCACPU_G(x)	\
+	(((x) >> FW_RI_FR_NSMR_WR_DCACPU_S) & FW_RI_FR_NSMR_WR_DCACPU_M)
 
 struct fw_ri_inv_lstag_wr {
 	__u8   opcode;
@@ -740,18 +740,18 @@ struct fw_ri_wr {
 	} u;
 };
 
-#define S_FW_RI_WR_MPAREQBIT	7
-#define M_FW_RI_WR_MPAREQBIT	0x1
-#define V_FW_RI_WR_MPAREQBIT(x)	((x) << S_FW_RI_WR_MPAREQBIT)
-#define G_FW_RI_WR_MPAREQBIT(x)	\
-    (((x) >> S_FW_RI_WR_MPAREQBIT) & M_FW_RI_WR_MPAREQBIT)
-#define F_FW_RI_WR_MPAREQBIT	V_FW_RI_WR_MPAREQBIT(1U)
+#define FW_RI_WR_MPAREQBIT_S	7
+#define FW_RI_WR_MPAREQBIT_M	0x1
+#define FW_RI_WR_MPAREQBIT_V(x)	((x) << FW_RI_WR_MPAREQBIT_S)
+#define FW_RI_WR_MPAREQBIT_G(x)	\
+	(((x) >> FW_RI_WR_MPAREQBIT_S) & FW_RI_WR_MPAREQBIT_M)
+#define FW_RI_WR_MPAREQBIT_F	FW_RI_WR_MPAREQBIT_V(1U)
 
-#define S_FW_RI_WR_P2PTYPE	0
-#define M_FW_RI_WR_P2PTYPE	0xf
-#define V_FW_RI_WR_P2PTYPE(x)	((x) << S_FW_RI_WR_P2PTYPE)
-#define G_FW_RI_WR_P2PTYPE(x)	\
-    (((x) >> S_FW_RI_WR_P2PTYPE) & M_FW_RI_WR_P2PTYPE)
+#define FW_RI_WR_P2PTYPE_S	0
+#define FW_RI_WR_P2PTYPE_M	0xf
+#define FW_RI_WR_P2PTYPE_V(x)	((x) << FW_RI_WR_P2PTYPE_S)
+#define FW_RI_WR_P2PTYPE_G(x)	\
+	(((x) >> FW_RI_WR_P2PTYPE_S) & FW_RI_WR_P2PTYPE_M)
 
 struct tcp_options {
 	__be16 mss;
@@ -783,58 +783,58 @@ struct cpl_pass_accept_req {
 };
 
 /* cpl_pass_accept_req.hdr_len fields */
-#define S_SYN_RX_CHAN    0
-#define M_SYN_RX_CHAN    0xF
-#define V_SYN_RX_CHAN(x) ((x) << S_SYN_RX_CHAN)
-#define G_SYN_RX_CHAN(x) (((x) >> S_SYN_RX_CHAN) & M_SYN_RX_CHAN)
-
-#define S_TCP_HDR_LEN    10
-#define M_TCP_HDR_LEN    0x3F
-#define V_TCP_HDR_LEN(x) ((x) << S_TCP_HDR_LEN)
-#define G_TCP_HDR_LEN(x) (((x) >> S_TCP_HDR_LEN) & M_TCP_HDR_LEN)
-
-#define S_IP_HDR_LEN    16
-#define M_IP_HDR_LEN    0x3FF
-#define V_IP_HDR_LEN(x) ((x) << S_IP_HDR_LEN)
-#define G_IP_HDR_LEN(x) (((x) >> S_IP_HDR_LEN) & M_IP_HDR_LEN)
-
-#define S_ETH_HDR_LEN    26
-#define M_ETH_HDR_LEN    0x1F
-#define V_ETH_HDR_LEN(x) ((x) << S_ETH_HDR_LEN)
-#define G_ETH_HDR_LEN(x) (((x) >> S_ETH_HDR_LEN) & M_ETH_HDR_LEN)
+#define SYN_RX_CHAN_S    0
+#define SYN_RX_CHAN_M    0xF
+#define SYN_RX_CHAN_V(x) ((x) << SYN_RX_CHAN_S)
+#define SYN_RX_CHAN_G(x) (((x) >> SYN_RX_CHAN_S) & SYN_RX_CHAN_M)
+
+#define TCP_HDR_LEN_S    10
+#define TCP_HDR_LEN_M    0x3F
+#define TCP_HDR_LEN_V(x) ((x) << TCP_HDR_LEN_S)
+#define TCP_HDR_LEN_G(x) (((x) >> TCP_HDR_LEN_S) & TCP_HDR_LEN_M)
+
+#define IP_HDR_LEN_S    16
+#define IP_HDR_LEN_M    0x3FF
+#define IP_HDR_LEN_V(x) ((x) << IP_HDR_LEN_S)
+#define IP_HDR_LEN_G(x) (((x) >> IP_HDR_LEN_S) & IP_HDR_LEN_M)
+
+#define ETH_HDR_LEN_S    26
+#define ETH_HDR_LEN_M    0x1F
+#define ETH_HDR_LEN_V(x) ((x) << ETH_HDR_LEN_S)
+#define ETH_HDR_LEN_G(x) (((x) >> ETH_HDR_LEN_S) & ETH_HDR_LEN_M)
 
 /* cpl_pass_accept_req.l2info fields */
-#define S_SYN_MAC_IDX    0
-#define M_SYN_MAC_IDX    0x1FF
-#define V_SYN_MAC_IDX(x) ((x) << S_SYN_MAC_IDX)
-#define G_SYN_MAC_IDX(x) (((x) >> S_SYN_MAC_IDX) & M_SYN_MAC_IDX)
+#define SYN_MAC_IDX_S    0
+#define SYN_MAC_IDX_M    0x1FF
+#define SYN_MAC_IDX_V(x) ((x) << SYN_MAC_IDX_S)
+#define SYN_MAC_IDX_G(x) (((x) >> SYN_MAC_IDX_S) & SYN_MAC_IDX_M)
 
-#define S_SYN_XACT_MATCH    9
-#define V_SYN_XACT_MATCH(x) ((x) << S_SYN_XACT_MATCH)
-#define F_SYN_XACT_MATCH    V_SYN_XACT_MATCH(1U)
+#define SYN_XACT_MATCH_S    9
+#define SYN_XACT_MATCH_V(x) ((x) << SYN_XACT_MATCH_S)
+#define SYN_XACT_MATCH_F    SYN_XACT_MATCH_V(1U)
 
-#define S_SYN_INTF    12
-#define M_SYN_INTF    0xF
-#define V_SYN_INTF(x) ((x) << S_SYN_INTF)
-#define G_SYN_INTF(x) (((x) >> S_SYN_INTF) & M_SYN_INTF)
+#define SYN_INTF_S    12
+#define SYN_INTF_M    0xF
+#define SYN_INTF_V(x) ((x) << SYN_INTF_S)
+#define SYN_INTF_G(x) (((x) >> SYN_INTF_S) & SYN_INTF_M)
 
 struct ulptx_idata {
 	__be32 cmd_more;
 	__be32 len;
 };
 
-#define S_ULPTX_NSGE    0
-#define M_ULPTX_NSGE    0xFFFF
-#define V_ULPTX_NSGE(x) ((x) << S_ULPTX_NSGE)
+#define ULPTX_NSGE_S    0
+#define ULPTX_NSGE_M    0xFFFF
+#define ULPTX_NSGE_V(x) ((x) << ULPTX_NSGE_S)
 
-#define S_RX_DACK_MODE    29
-#define M_RX_DACK_MODE    0x3
-#define V_RX_DACK_MODE(x) ((x) << S_RX_DACK_MODE)
-#define G_RX_DACK_MODE(x) (((x) >> S_RX_DACK_MODE) & M_RX_DACK_MODE)
+#define RX_DACK_MODE_S    29
+#define RX_DACK_MODE_M    0x3
+#define RX_DACK_MODE_V(x) ((x) << RX_DACK_MODE_S)
+#define RX_DACK_MODE_G(x) (((x) >> RX_DACK_MODE_S) & RX_DACK_MODE_M)
 
-#define S_RX_DACK_CHANGE    31
-#define V_RX_DACK_CHANGE(x) ((x) << S_RX_DACK_CHANGE)
-#define F_RX_DACK_CHANGE    V_RX_DACK_CHANGE(1U)
+#define RX_DACK_CHANGE_S    31
+#define RX_DACK_CHANGE_V(x) ((x) << RX_DACK_CHANGE_S)
+#define RX_DACK_CHANGE_F    RX_DACK_CHANGE_V(1U)
 
 enum {                     /* TCP congestion control algorithms */
 	CONG_ALG_RENO,
@@ -843,10 +843,10 @@ enum {                     /* TCP congestion control algorithms */
 	CONG_ALG_HIGHSPEED
 };
 
-#define S_CONG_CNTRL    14
-#define M_CONG_CNTRL    0x3
-#define V_CONG_CNTRL(x) ((x) << S_CONG_CNTRL)
-#define G_CONG_CNTRL(x) (((x) >> S_CONG_CNTRL) & M_CONG_CNTRL)
+#define CONG_CNTRL_S    14
+#define CONG_CNTRL_M    0x3
+#define CONG_CNTRL_V(x) ((x) << CONG_CNTRL_S)
+#define CONG_CNTRL_G(x) (((x) >> CONG_CNTRL_S) & CONG_CNTRL_M)
 
 #define CONG_CNTRL_VALID   (1 << 18)
 
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
