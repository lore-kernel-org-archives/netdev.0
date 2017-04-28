From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/6] nfp: replace -ENOTSUPP with -EOPNOTSUPP
Date: Thu, 27 Apr 2017 21:06:15 -0700
Message-ID: <20170428040620.8256-2-jakub.kicinski@netronome.com>
References: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:32832 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdD1EG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 00:06:58 -0400
Received: by mail-pg0-f42.google.com with SMTP id y4so3025402pge.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 21:06:58 -0700 (PDT)
In-Reply-To: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Or points out in commit 423b3aecf290 ("net/mlx4: Change ENOTSUPP
to EOPNOTSUPP"), ENOTSUPP is NFS specific error.  Replace it with
EOPNOTSUPP.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   | 24 +++++++++++-----------
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  4 ++--
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  2 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   | 12 +++++------
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index 335beb8b8b45..97a8f00674d0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -798,7 +798,7 @@ wrp_test_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	const struct bpf_insn *insn = &meta->insn;
 
 	if (insn->off < 0) /* TODO */
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	wrp_test_reg_one(nfp_prog, insn->dst_reg * 2, alu_op,
 			 insn->src_reg * 2, br_mask, insn->off);
@@ -818,7 +818,7 @@ wrp_cmp_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	u32 tmp_reg;
 
 	if (insn->off < 0) /* TODO */
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	tmp_reg = ur_load_imm_any(nfp_prog, imm & ~0U, imm_b(nfp_prog));
 	if (!swap)
@@ -847,7 +847,7 @@ wrp_cmp_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	u8 areg = insn->src_reg * 2, breg = insn->dst_reg * 2;
 
 	if (insn->off < 0) /* TODO */
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (swap) {
 		areg ^= breg;
@@ -1132,7 +1132,7 @@ static int mem_ldx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 		emit_alu(nfp_prog, reg_both(meta->insn.dst_reg * 2),
 			 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_LEN);
 	else
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	return 0;
 }
@@ -1143,7 +1143,7 @@ static int mem_ldx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 
 	if (meta->insn.off != offsetof(struct xdp_md, data) &&
 	    meta->insn.off != offsetof(struct xdp_md, data_end))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	emit_alu(nfp_prog, dst, reg_none(), ALU_OP_NONE, NFP_BPF_ABI_PKT);
 
@@ -1174,12 +1174,12 @@ static int mem_stx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	if (meta->insn.off == offsetof(struct sk_buff, mark))
 		return wrp_set_mark(nfp_prog, meta->insn.src_reg * 2);
 
-	return -ENOTSUPP;
+	return -EOPNOTSUPP;
 }
 
 static int mem_stx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return -ENOTSUPP;
+	return -EOPNOTSUPP;
 }
 
 static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
@@ -1192,7 +1192,7 @@ static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 static int jump(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	if (meta->insn.off < 0) /* TODO */
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	emit_br(nfp_prog, BR_UNC, meta->insn.off, 0);
 
 	return 0;
@@ -1206,7 +1206,7 @@ static int jeq_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	u32 tmp_reg;
 
 	if (insn->off < 0) /* TODO */
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (imm & ~0U) {
 		tmp_reg = ur_load_imm_any(nfp_prog, imm & ~0U, imm_b(nfp_prog));
@@ -1245,7 +1245,7 @@ static int jset_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	u32 tmp_reg;
 
 	if (insn->off < 0) /* TODO */
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (!imm) {
 		meta->skip = true;
@@ -1276,7 +1276,7 @@ static int jne_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	u32 tmp_reg;
 
 	if (insn->off < 0) /* TODO */
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (!imm) {
 		emit_alu(nfp_prog, reg_none(), reg_a(insn->dst_reg * 2),
@@ -1302,7 +1302,7 @@ static int jeq_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	const struct bpf_insn *insn = &meta->insn;
 
 	if (insn->off < 0) /* TODO */
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	emit_alu(nfp_prog, imm_a(nfp_prog), reg_a(insn->dst_reg * 2),
 		 ALU_OP_XOR, reg_b(insn->src_reg * 2));
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 8a9b74305493..0e87b446e98f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2651,9 +2651,9 @@ nfp_net_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
 	struct nfp_net *nn = netdev_priv(netdev);
 
 	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	if (proto != htons(ETH_P_ALL))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (tc->type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn)) {
 		if (!nn->dp.bpf_offload_xdp)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 6e27d1281425..a704efd4e314 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -791,7 +791,7 @@ static int nfp_net_set_coalesce(struct net_device *netdev,
 	    ec->tx_coalesce_usecs_high ||
 	    ec->tx_max_coalesced_frames_high ||
 	    ec->rate_sample_interval)
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	/* Compute factor used to convert coalesce '_usecs' parameters to
 	 * ME timestamp ticks.  There are 16 ME clock cycles for each timestamp
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index 0089799d8dd1..2fa7b67d0c6f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -112,12 +112,12 @@ nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 		if (tc_no_actions(cls_bpf->exts))
 			return NN_ACT_DIRECT;
 
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 
 	/* TC legacy mode */
 	if (!tc_single_action(cls_bpf->exts))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	tcf_exts_to_list(cls_bpf->exts, &actions);
 	list_for_each_entry(a, &actions, list) {
@@ -129,7 +129,7 @@ nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 			return NN_ACT_TC_REDIR;
 	}
 
-	return -ENOTSUPP;
+	return -EOPNOTSUPP;
 }
 
 static int
@@ -145,7 +145,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	int ret;
 
 	if (!IS_ENABLED(CONFIG_BPF_SYSCALL))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	ret = nfp_net_bpf_get_act(nn, cls_bpf);
 	if (ret < 0)
@@ -155,7 +155,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	max_mtu = nn_readb(nn, NFP_NET_CFG_BPF_INL_MTU) * 64 - 32;
 	if (max_mtu < nn->dp.netdev->mtu) {
 		nn_info(nn, "BPF offload not supported with MTU larger than HW packet split boundary\n");
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 
 	start_off = nn_readw(nn, NFP_NET_CFG_BPF_START);
@@ -282,6 +282,6 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 		return nfp_net_bpf_stats_update(nn, cls_bpf);
 
 	default:
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 }
-- 
2.11.0
