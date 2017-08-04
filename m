From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 03/20] net: sched: change names of action number helpers to be aligned with the rest
Date: Fri,  4 Aug 2017 14:28:58 +0200
Message-ID: <20170804122915.15177-4-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32779 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752069AbdHDM3X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:23 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so2903749wrd.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:22 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The rest of the helpers are named tcf_exts_*, so change the name of
the action number helpers to be aligned. While at it, change to inline
functions.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  4 +--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  2 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  2 +-
 drivers/net/ethernet/netronome/nfp/bpf/offload.c   |  4 +--
 include/net/pkt_cls.h                              | 36 ++++++++++++++++------
 net/dsa/slave.c                                    |  2 +-
 net/sched/cls_api.c                                |  2 +-
 9 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
index ef06ce8..6f734c5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
@@ -96,7 +96,7 @@ static int fill_action_fields(struct adapter *adap,
 	LIST_HEAD(actions);
 
 	exts = cls->knode.exts;
-	if (tc_no_actions(exts))
+	if (!tcf_exts_has_actions(exts))
 		return -EINVAL;
 
 	tcf_exts_to_list(exts, &actions);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 96606e3..091fcc7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8953,7 +8953,7 @@ static int parse_tc_actions(struct ixgbe_adapter *adapter,
 	LIST_HEAD(actions);
 	int err;
 
-	if (tc_no_actions(exts))
+	if (!tcf_exts_has_actions(exts))
 		return -EINVAL;
 
 	tcf_exts_to_list(exts, &actions);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3c536f5..78f50d9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1326,7 +1326,7 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	LIST_HEAD(actions);
 	int err;
 
-	if (tc_no_actions(exts))
+	if (!tcf_exts_has_actions(exts))
 		return -EINVAL;
 
 	attr->flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
@@ -1839,7 +1839,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	bool encap = false;
 	int err = 0;
 
-	if (tc_no_actions(exts))
+	if (!tcf_exts_has_actions(exts))
 		return -EINVAL;
 
 	memset(attr, 0, sizeof(*attr));
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 88b668b..66d511d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1626,7 +1626,7 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 	LIST_HEAD(actions);
 	int err;
 
-	if (!tc_single_action(cls->exts)) {
+	if (!tcf_exts_has_one_action(cls->exts)) {
 		netdev_err(mlxsw_sp_port->dev, "only singular actions are supported\n");
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 400ad40..9be48d2e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -53,7 +53,7 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 	LIST_HEAD(actions);
 	int err;
 
-	if (tc_no_actions(exts))
+	if (!tcf_exts_has_actions(exts))
 		return 0;
 
 	/* Count action is inserted first */
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index 78d80a3..a88bb5b 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -115,14 +115,14 @@ nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 
 	/* TC direct action */
 	if (cls_bpf->exts_integrated) {
-		if (tc_no_actions(cls_bpf->exts))
+		if (!tcf_exts_has_actions(cls_bpf->exts))
 			return NN_ACT_DIRECT;
 
 		return -EOPNOTSUPP;
 	}
 
 	/* TC legacy mode */
-	if (!tc_single_action(cls_bpf->exts))
+	if (!tcf_exts_has_one_action(cls_bpf->exts))
 		return -EOPNOTSUPP;
 
 	tcf_exts_to_list(cls_bpf->exts, &actions);
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index f4462ec..7f25636 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -199,17 +199,35 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	return 0;
 }
 
+/**
+ * tcf_exts_has_actions - check if at least one action is present
+ * @exts: tc filter extensions handle
+ *
+ * Returns true if at least one action is present.
+ */
+static inline bool tcf_exts_has_actions(struct tcf_exts *exts)
+{
 #ifdef CONFIG_NET_CLS_ACT
+	return exts->nr_actions;
+#else
+	return false;
+#endif
+}
 
-#define tc_no_actions(_exts)  ((_exts)->nr_actions == 0)
-#define tc_single_action(_exts) ((_exts)->nr_actions == 1)
-
-#else /* CONFIG_NET_CLS_ACT */
-
-#define tc_no_actions(_exts) true
-#define tc_single_action(_exts) false
-
-#endif /* CONFIG_NET_CLS_ACT */
+/**
+ * tcf_exts_has_one_action - check if exactly one action is present
+ * @exts: tc filter extensions handle
+ *
+ * Returns true if exactly one action is present.
+ */
+static inline bool tcf_exts_has_one_action(struct tcf_exts *exts)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	return exts->nr_actions == 1;
+#else
+	return false;
+#endif
+}
 
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e196562..83252e8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -779,7 +779,7 @@ static int dsa_slave_add_cls_matchall(struct net_device *dev,
 	if (!ds->ops->port_mirror_add)
 		return err;
 
-	if (!tc_single_action(cls->exts))
+	if (!tcf_exts_has_one_action(cls->exts))
 		return err;
 
 	tcf_exts_to_list(cls->exts, &actions);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 39da0c5..287ae6c 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -972,7 +972,7 @@ int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
 	const struct tc_action *a;
 	LIST_HEAD(actions);
 
-	if (tc_no_actions(exts))
+	if (!tcf_exts_has_actions(exts))
 		return -EINVAL;
 
 	tcf_exts_to_list(exts, &actions);
-- 
2.9.3
