From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v2 net-next 3/4] net/sched: tc_mirred: Rename public predicates 'is_tcf_mirred_redirect' and 'is_tcf_mirred_mirror'
Date: Tue, 27 Sep 2016 23:59:34 +0300
Message-ID: <1475009975-30332-4-git-send-email-shmulik.ladkani@gmail.com>
References: <1475009975-30332-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Hariprasad S <hariprasad@chelsio.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36205 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936435AbcI0VAe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 17:00:34 -0400
Received: by mail-wm0-f67.google.com with SMTP id b184so2955010wma.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 14:00:33 -0700 (PDT)
In-Reply-To: <1475009975-30332-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These accessors are used in various drivers that support tc offloading,
to detect properties of a given 'tc_action'.

'is_tcf_mirred_redirect' tests that the action is TCA_EGRESS_REDIR.
'is_tcf_mirred_mirror' tests that the action is TCA_EGRESS_MIRROR.

As a prep towards supporting INGRESS redir/mirror, rename these
predicates to reflect their true meaning:
  s/is_tcf_mirred_redirect/is_tcf_mirred_egress_redirect/
  s/is_tcf_mirred_mirror/is_tcf_mirred_egress_mirror/

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Cc: Ido Schimmel <idosch@mellanox.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c    | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c      | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c       | 4 +++-
 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c | 2 +-
 include/net/tc_act/tc_mirred.h                       | 4 ++--
 6 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
index 49d2debb33..52af62e0ec 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
@@ -113,7 +113,7 @@ static int fill_action_fields(struct adapter *adap,
 		}
 
 		/* Re-direct to specified port in hardware. */
-		if (is_tcf_mirred_redirect(a)) {
+		if (is_tcf_mirred_egress_redirect(a)) {
 			struct net_device *n_dev;
 			unsigned int i, index;
 			bool found = false;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a244d9a672..784b0b98ab 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8410,7 +8410,7 @@ static int parse_tc_actions(struct ixgbe_adapter *adapter,
 		}
 
 		/* Redirect to a VF or a offloaded macvlan */
-		if (is_tcf_mirred_redirect(a)) {
+		if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 
 			err = handle_redirect_action(adapter, ifindex, queue,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index a350b7171e..957a464489 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -404,7 +404,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			continue;
 		}
 
-		if (is_tcf_mirred_redirect(a)) {
+		if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev;
 			struct mlx5e_priv *out_priv;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index fd74d1064f..6a4f9c4664 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1237,8 +1237,10 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	tcf_exts_to_list(cls->exts, &actions);
 	list_for_each_entry(a, &actions, list) {
-		if (!is_tcf_mirred_mirror(a) || protocol != htons(ETH_P_ALL))
+		if (!is_tcf_mirred_egress_mirror(a) ||
+		    protocol != htons(ETH_P_ALL)) {
 			return -ENOTSUPP;
+		}
 
 		err = mlxsw_sp_port_add_cls_matchall_mirror(mlxsw_sp_port, cls,
 							    a, ingress);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index 8acfb631a0..cfed40c0e3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -128,7 +128,7 @@ nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 		if (is_tcf_gact_shot(a))
 			return NN_ACT_TC_DROP;
 
-		if (is_tcf_mirred_redirect(a) &&
+		if (is_tcf_mirred_egress_redirect(a) &&
 		    tcf_mirred_ifindex(a) == nn->netdev->ifindex)
 			return NN_ACT_TC_REDIR;
 	}
diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index 95431092c4..604bc31e23 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -14,7 +14,7 @@ struct tcf_mirred {
 };
 #define to_mirred(a) ((struct tcf_mirred *)a)
 
-static inline bool is_tcf_mirred_redirect(const struct tc_action *a)
+static inline bool is_tcf_mirred_egress_redirect(const struct tc_action *a)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (a->ops && a->ops->type == TCA_ACT_MIRRED)
@@ -23,7 +23,7 @@ static inline bool is_tcf_mirred_redirect(const struct tc_action *a)
 	return false;
 }
 
-static inline bool is_tcf_mirred_mirror(const struct tc_action *a)
+static inline bool is_tcf_mirred_egress_mirror(const struct tc_action *a)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (a->ops && a->ops->type == TCA_ACT_MIRRED)
-- 
2.7.4
