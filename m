From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 13/16] net: sched: push cls related args into cls_common structure
Date: Mon,  7 Aug 2017 10:15:29 +0200
Message-ID: <20170807081532.32760-14-jiri@resnulli.us>
References: <20170807081532.32760-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35307 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752660AbdHGIP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:56 -0400
Received: by mail-wr0-f195.google.com with SMTP id c24so7109929wra.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:55 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As ndo_setup_tc is generic offload op for whole tc subsystem, does not
really make sense to have cls-specific args. So move them under
cls_common structurure which is embedded in all cls structs.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  1 -
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  1 -
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 14 +++++-------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |  7 +++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h  |  6 ++----
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  1 -
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  1 -
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |  1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 17 ++++++---------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 11 ++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 15 +++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h    |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 25 ++++++++--------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  2 +-
 drivers/net/ethernet/netronome/nfp/bpf/main.c      | 10 +++++----
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  3 +--
 .../net/ethernet/netronome/nfp/flower/offload.c    | 12 ++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  6 ++----
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  6 +-----
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  1 -
 drivers/net/ethernet/sfc/efx.h                     |  1 -
 drivers/net/ethernet/sfc/falcon/efx.h              |  1 -
 drivers/net/ethernet/sfc/falcon/tx.c               |  1 -
 drivers/net/ethernet/sfc/tx.c                      |  1 -
 drivers/net/ethernet/ti/netcp_core.c               |  1 -
 include/linux/netdevice.h                          |  3 ---
 include/net/pkt_cls.h                              | 19 ++++++++++++++++
 net/dsa/slave.c                                    | 14 +++++-------
 net/sched/cls_bpf.c                                |  7 ++----
 net/sched/cls_flower.c                             | 13 ++++++-----
 net/sched/cls_matchall.c                           |  8 +++----
 net/sched/cls_u32.c                                | 20 +++++++----------
 net/sched/sch_mqprio.c                             |  6 ++----
 39 files changed, 101 insertions(+), 144 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 6a6ea3b..bbb7bfe 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1919,7 +1919,6 @@ static void xgbe_poll_controller(struct net_device *netdev)
 #endif /* End CONFIG_NET_POLL_CONTROLLER */
 
 static int xgbe_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-			 u32 handle, u32 chain_index, __be16 proto,
 			 struct tc_to_netdev *tc_to_netdev)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4395d1c..257cf4b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4285,7 +4285,6 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 }
 
 int __bnx2x_setup_tc(struct net_device *dev, enum tc_setup_type type,
-		     u32 handle, u32 chain_index, __be16 proto,
 		     struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 1ac4eb0..04eb950 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -487,7 +487,6 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
 /* setup_tc callback */
 int bnx2x_setup_tc(struct net_device *dev, u8 num_tc);
 int __bnx2x_setup_tc(struct net_device *dev, enum tc_setup_type type,
-		     u32 handle, u32 chain_index, __be16 proto,
 		     struct tc_to_netdev *tc);
 
 int bnx2x_get_vf_config(struct net_device *dev, int vf,
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index b98d9f3..1545b88 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7238,7 +7238,6 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 }
 
 static int bnxt_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			 u32 handle, u32 chain_index, __be16 proto,
 			 struct tc_to_netdev *ntc)
 {
 	if (type != TC_SETUP_MQPRIO)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6512290..1319931 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2890,27 +2890,24 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 }
 
 static int cxgb_setup_tc_cls_u32(struct net_device *dev,
-				 enum tc_setup_type type,
-				 u32 handle, u32 chain_index, __be16 proto,
 				 struct tc_cls_u32_offload *cls_u32)
 {
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
-	    chain_index)
+	if (TC_H_MAJ(cls_u32->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_u32->command) {
 	case TC_CLSU32_NEW_KNODE:
 	case TC_CLSU32_REPLACE_KNODE:
-		return cxgb4_config_knode(dev, proto, cls_u32);
+		return cxgb4_config_knode(dev, cls_u32);
 	case TC_CLSU32_DELETE_KNODE:
-		return cxgb4_delete_knode(dev, proto, cls_u32);
+		return cxgb4_delete_knode(dev, cls_u32);
 	default:
 		return -EOPNOTSUPP;
 	}
 }
 
 static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			 u32 handle, u32 chain_index, __be16 proto,
 			 struct tc_to_netdev *tc)
 {
 	struct port_info *pi = netdev2pinfo(dev);
@@ -2925,8 +2922,7 @@ static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 
 	switch (type) {
 	case TC_SETUP_CLSU32:
-		return cxgb_setup_tc_cls_u32(dev, type, handle, chain_index,
-					     proto, tc->cls_u32);
+		return cxgb_setup_tc_cls_u32(dev, tc->cls_u32);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
index 6f734c5..48970ba 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
@@ -146,11 +146,11 @@ static int fill_action_fields(struct adapter *adap,
 	return 0;
 }
 
-int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
-		       struct tc_cls_u32_offload *cls)
+int cxgb4_config_knode(struct net_device *dev, struct tc_cls_u32_offload *cls)
 {
 	const struct cxgb4_match_field *start, *link_start = NULL;
 	struct adapter *adapter = netdev2adap(dev);
+	__be16 protocol = cls->common.protocol;
 	struct ch_filter_specification fs;
 	struct cxgb4_tc_u32_table *t;
 	struct cxgb4_link *link;
@@ -338,8 +338,7 @@ int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
 	return ret;
 }
 
-int cxgb4_delete_knode(struct net_device *dev, __be16 protocol,
-		       struct tc_cls_u32_offload *cls)
+int cxgb4_delete_knode(struct net_device *dev, struct tc_cls_u32_offload *cls)
 {
 	struct adapter *adapter = netdev2adap(dev);
 	unsigned int filter_id, max_tids, i, j;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
index 021261a..70a07b7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
@@ -44,10 +44,8 @@ static inline bool can_tc_u32_offload(struct net_device *dev)
 	return (dev->features & NETIF_F_HW_TC) && adap->tc_u32 ? true : false;
 }
 
-int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
-		       struct tc_cls_u32_offload *cls);
-int cxgb4_delete_knode(struct net_device *dev, __be16 protocol,
-		       struct tc_cls_u32_offload *cls);
+int cxgb4_config_knode(struct net_device *dev, struct tc_cls_u32_offload *cls);
+int cxgb4_delete_knode(struct net_device *dev, struct tc_cls_u32_offload *cls);
 
 void cxgb4_cleanup_tc_u32(struct adapter *adapter);
 struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap);
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index d86d766..3827608 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -343,7 +343,6 @@ static void dpaa_get_stats64(struct net_device *net_dev,
 }
 
 static int dpaa_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-			 u32 handle, u32 chain_index, __be16 proto,
 			 struct tc_to_netdev *tc)
 {
 	struct dpaa_priv *priv = netdev_priv(net_dev);
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index ef57959..dc64d75 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1220,7 +1220,6 @@ static int hns3_setup_tc(struct net_device *netdev, u8 tc)
 }
 
 static int hns3_nic_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			     u32 handle, u32 chain_index, __be16 protocol,
 			     struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index b301906..71004b8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1266,7 +1266,6 @@ int fm10k_setup_tc(struct net_device *dev, u8 tc)
 }
 
 static int __fm10k_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			    u32 handle, u32 chain_index, __be16 proto,
 			    struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7d47a71..97d8bb2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5657,7 +5657,6 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
 }
 
 static int __i40e_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-			   u32 handle, u32 chain_index, __be16 proto,
 			   struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 35db198..0a35031 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8851,7 +8851,6 @@ static int ixgbe_delete_clsu32(struct ixgbe_adapter *adapter,
 }
 
 static int ixgbe_configure_clsu32_add_hnode(struct ixgbe_adapter *adapter,
-					    __be16 protocol,
 					    struct tc_cls_u32_offload *cls)
 {
 	u32 uhtid = TC_U32_USERHTID(cls->hnode.handle);
@@ -9037,9 +9036,9 @@ static int ixgbe_clsu32_build_input(struct ixgbe_fdir_filter *input,
 }
 
 static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
-				  __be16 protocol,
 				  struct tc_cls_u32_offload *cls)
 {
+	__be16 protocol = cls->common.protocol;
 	u32 loc = cls->knode.handle & 0xfffff;
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_mat_field *field_ptr;
@@ -9227,25 +9226,23 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 }
 
 static int ixgbe_setup_tc_cls_u32(struct net_device *dev,
-				  u32 handle, u32 chain_index, __be16 proto,
 				  struct tc_cls_u32_offload *cls_u32)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
-	    chain_index)
+	if (TC_H_MAJ(cls_u32->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_u32->command) {
 	case TC_CLSU32_NEW_KNODE:
 	case TC_CLSU32_REPLACE_KNODE:
-		return ixgbe_configure_clsu32(adapter, proto, cls_u32);
+		return ixgbe_configure_clsu32(adapter, cls_u32);
 	case TC_CLSU32_DELETE_KNODE:
 		return ixgbe_delete_clsu32(adapter, cls_u32);
 	case TC_CLSU32_NEW_HNODE:
 	case TC_CLSU32_REPLACE_HNODE:
-		return ixgbe_configure_clsu32_add_hnode(adapter, proto,
-							cls_u32);
+		return ixgbe_configure_clsu32_add_hnode(adapter, cls_u32);
 	case TC_CLSU32_DELETE_HNODE:
 		return ixgbe_configure_clsu32_del_hnode(adapter, cls_u32);
 	default:
@@ -9261,13 +9258,11 @@ static int ixgbe_setup_tc_mqprio(struct net_device *dev,
 }
 
 static int __ixgbe_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			    u32 handle, u32 chain_index, __be16 proto,
 			    struct tc_to_netdev *tc)
 {
 	switch (type) {
 	case TC_SETUP_CLSU32:
-		return ixgbe_setup_tc_cls_u32(dev, handle, chain_index, proto,
-					      tc->cls_u32);
+		return ixgbe_setup_tc_cls_u32(dev, tc->cls_u32);
 	case TC_SETUP_MQPRIO:
 		return ixgbe_setup_tc_mqprio(dev, tc->mqprio);
 	default:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 5c33550..e81083e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -131,7 +131,6 @@ int mlx4_en_alloc_tx_queue_per_tc(struct net_device *dev, u8 tc)
 }
 
 static int __mlx4_en_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			      u32 handle, u32 chain_index, __be16 proto,
 			      struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index adf35da..15f2a94 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3032,18 +3032,17 @@ static int mlx5e_setup_tc_mqprio(struct net_device *netdev,
 }
 
 static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
-				     u32 handle, u32 chain_index, __be16 proto,
 				     struct tc_cls_flower_offload *cls_flower)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
-	    chain_index)
+	if (TC_H_MAJ(cls_flower->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_flower->command) {
 	case TC_CLSFLOWER_REPLACE:
-		return mlx5e_configure_flower(priv, proto, cls_flower);
+		return mlx5e_configure_flower(priv, cls_flower);
 	case TC_CLSFLOWER_DESTROY:
 		return mlx5e_delete_flower(priv, cls_flower);
 	case TC_CLSFLOWER_STATS:
@@ -3054,13 +3053,11 @@ static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
 }
 
 static int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			  u32 handle, u32 chain_index, __be16 proto,
 			  struct tc_to_netdev *tc)
 {
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
-		return mlx5e_setup_tc_cls_flower(dev, handle, chain_index,
-						 proto, tc->cls_flower);
+		return mlx5e_setup_tc_cls_flower(dev, tc->cls_flower);
 	case TC_SETUP_MQPRIO:
 		return mlx5e_setup_tc_mqprio(dev, tc->mqprio);
 	default:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index e6cc642..e5cf2e7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -652,15 +652,13 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 }
 
 static int mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
-					 u32 handle, u32 chain_index,
-					 __be16 proto,
 					 struct tc_to_netdev *tc)
 {
 	struct tc_cls_flower_offload *cls_flower = tc->cls_flower;
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
-	    chain_index)
+	if (TC_H_MAJ(cls_flower->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
 	if (cls_flower->egress_dev) {
@@ -668,13 +666,12 @@ static int mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
 
 		dev = mlx5_eswitch_get_uplink_netdev(esw);
 		return dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-						     handle, chain_index,
-						     proto, tc);
+						     tc);
 	}
 
 	switch (cls_flower->command) {
 	case TC_CLSFLOWER_REPLACE:
-		return mlx5e_configure_flower(priv, proto, cls_flower);
+		return mlx5e_configure_flower(priv, cls_flower);
 	case TC_CLSFLOWER_DESTROY:
 		return mlx5e_delete_flower(priv, cls_flower);
 	case TC_CLSFLOWER_STATS:
@@ -685,13 +682,11 @@ static int mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
 }
 
 static int mlx5e_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			      u32 handle, u32 chain_index, __be16 proto,
 			      struct tc_to_netdev *tc)
 {
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
-		return mlx5e_rep_setup_tc_cls_flower(dev, handle, chain_index,
-						     proto, tc);
+		return mlx5e_rep_setup_tc_cls_flower(dev, tc);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 78f50d9..3b10d3d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1939,7 +1939,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	return err;
 }
 
-int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
+int mlx5e_configure_flower(struct mlx5e_priv *priv,
 			   struct tc_cls_flower_offload *f)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index ecbe30d..5a0f4a4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -38,7 +38,7 @@
 int mlx5e_tc_init(struct mlx5e_priv *priv);
 void mlx5e_tc_cleanup(struct mlx5e_priv *priv);
 
-int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
+int mlx5e_configure_flower(struct mlx5e_priv *priv,
 			   struct tc_cls_flower_offload *f);
 int mlx5e_delete_flower(struct mlx5e_priv *priv,
 			struct tc_cls_flower_offload *f);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f333d08..1ca3204 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1617,11 +1617,11 @@ mlxsw_sp_port_del_cls_matchall_sample(struct mlxsw_sp_port *mlxsw_sp_port)
 }
 
 static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
-					  __be16 protocol,
 					  struct tc_cls_matchall_offload *f,
 					  bool ingress)
 {
 	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
+	__be16 protocol = f->common.protocol;
 	const struct tc_action *a;
 	LIST_HEAD(actions);
 	int err;
@@ -1694,18 +1694,16 @@ static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int mlxsw_sp_setup_tc_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
-					  u32 handle, u32 chain_index,
-					  __be16 proto,
 					  struct tc_cls_matchall_offload *f)
 {
-	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
+	bool ingress = TC_H_MAJ(f->common.handle) == TC_H_MAJ(TC_H_INGRESS);
 
-	if (chain_index)
+	if (f->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (f->command) {
 	case TC_CLSMATCHALL_REPLACE:
-		return mlxsw_sp_port_add_cls_matchall(mlxsw_sp_port, proto, f,
+		return mlxsw_sp_port_add_cls_matchall(mlxsw_sp_port, f,
 						      ingress);
 	case TC_CLSMATCHALL_DESTROY:
 		mlxsw_sp_port_del_cls_matchall(mlxsw_sp_port, f);
@@ -1717,18 +1715,16 @@ static int mlxsw_sp_setup_tc_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 
 static int
 mlxsw_sp_setup_tc_cls_flower(struct mlxsw_sp_port *mlxsw_sp_port,
-			     u32 handle, u32 chain_index, __be16 proto,
 			     struct tc_cls_flower_offload *f)
 {
-	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
+	bool ingress = TC_H_MAJ(f->common.handle) == TC_H_MAJ(TC_H_INGRESS);
 
-	if (chain_index)
+	if (f->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (f->command) {
 	case TC_CLSFLOWER_REPLACE:
-		return mlxsw_sp_flower_replace(mlxsw_sp_port, ingress,
-					       proto, f);
+		return mlxsw_sp_flower_replace(mlxsw_sp_port, ingress, f);
 	case TC_CLSFLOWER_DESTROY:
 		mlxsw_sp_flower_destroy(mlxsw_sp_port, ingress, f);
 		return 0;
@@ -1740,19 +1736,16 @@ mlxsw_sp_setup_tc_cls_flower(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			     u32 handle, u32 chain_index, __be16 proto,
 			     struct tc_to_netdev *tc)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
-		return mlxsw_sp_setup_tc_cls_matchall(mlxsw_sp_port, handle,
-						      chain_index, proto,
+		return mlxsw_sp_setup_tc_cls_matchall(mlxsw_sp_port,
 						      tc->cls_mall);
 	case TC_SETUP_CLSFLOWER:
-		return mlxsw_sp_setup_tc_cls_flower(mlxsw_sp_port, handle,
-						    chain_index, proto,
+		return mlxsw_sp_setup_tc_cls_flower(mlxsw_sp_port,
 						    tc->cls_flower);
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index e848f06..8452d1d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -508,7 +508,7 @@ extern const struct mlxsw_sp_acl_ops mlxsw_sp_acl_tcam_ops;
 
 /* spectrum_flower.c */
 int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
-			    __be16 protocol, struct tc_cls_flower_offload *f);
+			    struct tc_cls_flower_offload *f);
 void mlxsw_sp_flower_destroy(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			     struct tc_cls_flower_offload *f);
 int mlxsw_sp_flower_stats(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 9be48d2e..021b6c0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -368,7 +368,7 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 }
 
 int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
-			    __be16 protocol, struct tc_cls_flower_offload *f)
+			    struct tc_cls_flower_offload *f)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct net_device *dev = mlxsw_sp_port->dev;
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index d7975dc..152a7ab 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -121,20 +121,22 @@ static void nfp_bpf_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
 }
 
 static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			    enum tc_setup_type type, u32 handle, __be16 proto,
+			    enum tc_setup_type type,
 			    struct tc_to_netdev *tc)
 {
+	struct tc_cls_bpf_offload *cls_bpf = tc->cls_bpf;
 	struct nfp_net *nn = netdev_priv(netdev);
 
 	if (type != TC_SETUP_CLSBPF || !nfp_net_ebpf_capable(nn) ||
-	    TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
-	    proto != htons(ETH_P_ALL))
+	    TC_H_MAJ(cls_bpf->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    cls_bpf->common.protocol != htons(ETH_P_ALL) ||
+	    cls_bpf->common.chain_index)
 		return -EOPNOTSUPP;
 
 	if (nn->dp.bpf_offload_xdp)
 		return -EBUSY;
 
-	return nfp_net_bpf_offload(nn, tc->cls_bpf);
+	return nfp_net_bpf_offload(nn, cls_bpf);
 }
 
 static bool nfp_bpf_tc_busy(struct nfp_app *app, struct nfp_net *nn)
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
index 314e6e8..eb94d08 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -135,8 +135,7 @@ int nfp_flower_metadata_init(struct nfp_app *app);
 void nfp_flower_metadata_cleanup(struct nfp_app *app);
 
 int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			enum tc_setup_type type, u32 handle, __be16 proto,
-			struct tc_to_netdev *tc);
+			enum tc_setup_type type, struct tc_to_netdev *tc);
 int nfp_flower_compile_flow_match(struct tc_cls_flower_offload *flow,
 				  struct nfp_fl_key_ls *key_ls,
 				  struct net_device *netdev,
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 58af438..8197836 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -385,13 +385,15 @@ nfp_flower_repr_offload(struct nfp_app *app, struct net_device *netdev,
 }
 
 int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			enum tc_setup_type type, u32 handle, __be16 proto,
-			struct tc_to_netdev *tc)
+			enum tc_setup_type type, struct tc_to_netdev *tc)
 {
+	struct tc_cls_flower_offload *cls_flower = tc->cls_flower;
+
 	if (type != TC_SETUP_CLSFLOWER ||
-	    TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
-	    !eth_proto_is_802_3(proto))
+	    TC_H_MAJ(cls_flower->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    !eth_proto_is_802_3(cls_flower->common.protocol) ||
+	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
-	return nfp_flower_repr_offload(app, netdev, tc->cls_flower);
+	return nfp_flower_repr_offload(app, netdev, cls_flower);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index b3b03bb9..7a2f950 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -109,8 +109,7 @@ struct nfp_app_type {
 	void (*ctrl_msg_rx)(struct nfp_app *app, struct sk_buff *skb);
 
 	int (*setup_tc)(struct nfp_app *app, struct net_device *netdev,
-			enum tc_setup_type type, u32 handle, __be16 proto,
-			struct tc_to_netdev *tc);
+			enum tc_setup_type type, struct tc_to_netdev *tc);
 	bool (*tc_busy)(struct nfp_app *app, struct nfp_net *nn);
 	int (*xdp_offload)(struct nfp_app *app, struct nfp_net *nn,
 			   struct bpf_prog *prog);
@@ -240,12 +239,11 @@ static inline bool nfp_app_tc_busy(struct nfp_app *app, struct nfp_net *nn)
 static inline int nfp_app_setup_tc(struct nfp_app *app,
 				   struct net_device *netdev,
 				   enum tc_setup_type type,
-				   u32 handle, __be16 proto,
 				   struct tc_to_netdev *tc)
 {
 	if (!app || !app->type->setup_tc)
 		return -EOPNOTSUPP;
-	return app->type->setup_tc(app, netdev, type, handle, proto, tc);
+	return app->type->setup_tc(app, netdev, type, tc);
 }
 
 static inline int nfp_app_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 9d776f9..e8abab2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -89,19 +89,15 @@ const struct switchdev_ops nfp_port_switchdev_ops = {
 };
 
 int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-		      u32 handle, u32 chain_index, __be16 proto,
 		      struct tc_to_netdev *tc)
 {
 	struct nfp_port *port;
 
-	if (chain_index)
-		return -EOPNOTSUPP;
-
 	port = nfp_port_from_netdev(netdev);
 	if (!port)
 		return -EOPNOTSUPP;
 
-	return nfp_app_setup_tc(port->app, netdev, type, handle, proto, tc);
+	return nfp_app_setup_tc(port->app, netdev, type, tc);
 }
 
 struct nfp_port *
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 239c540..252f06d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -110,7 +110,6 @@ struct nfp_port {
 extern const struct switchdev_ops nfp_port_switchdev_ops;
 
 int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-		      u32 handle, u32 chain_index, __be16 proto,
 		      struct tc_to_netdev *tc);
 
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index e41a717..b0c6004 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -33,7 +33,6 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-		 u32 handle, u32 chain_index, __be16 proto,
 		 struct tc_to_netdev *tc);
 unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
 extern unsigned int efx_piobuf_size;
diff --git a/drivers/net/ethernet/sfc/falcon/efx.h b/drivers/net/ethernet/sfc/falcon/efx.h
index f3bc67e..4497511 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.h
+++ b/drivers/net/ethernet/sfc/falcon/efx.h
@@ -33,7 +33,6 @@ netdev_tx_t ef4_hard_start_xmit(struct sk_buff *skb,
 netdev_tx_t ef4_enqueue_skb(struct ef4_tx_queue *tx_queue, struct sk_buff *skb);
 void ef4_xmit_done(struct ef4_tx_queue *tx_queue, unsigned int index);
 int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-		 u32 handle, u32 chain_index, __be16 proto,
 		 struct tc_to_netdev *tc);
 unsigned int ef4_tx_max_skb_descs(struct ef4_nic *efx);
 extern bool ef4_separate_tx_channels;
diff --git a/drivers/net/ethernet/sfc/falcon/tx.c b/drivers/net/ethernet/sfc/falcon/tx.c
index 6c47526..447519a 100644
--- a/drivers/net/ethernet/sfc/falcon/tx.c
+++ b/drivers/net/ethernet/sfc/falcon/tx.c
@@ -426,7 +426,6 @@ void ef4_init_tx_queue_core_txq(struct ef4_tx_queue *tx_queue)
 }
 
 int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-		 u32 handle, u32 chain_index, __be16 proto,
 		 struct tc_to_netdev *ntc)
 {
 	struct ef4_nic *efx = netdev_priv(net_dev);
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 0c08c10..d17af91 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -654,7 +654,6 @@ void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue)
 }
 
 int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-		 u32 handle, u32 chain_index, __be16 proto,
 		 struct tc_to_netdev *ntc)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index cb21742..14f91b2 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1878,7 +1878,6 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 }
 
 static int netcp_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			  u32 handle, u32 chain_index, __be16 proto,
 			  struct tc_to_netdev *tc)
 {
 	u8 num_tc;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bd49dba..6e2f7e3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -977,7 +977,6 @@ struct xfrmdev_ops {
  * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
  * int (*ndo_setup_tc)(struct net_device *dev, enum tc_setup_type type,
- *		       u32 handle, u32 chain_index, __be16 protocol,
  *		       struct tc_to_netdev *tc);
  *	Called to setup any 'tc' scheduler, classifier or action on @dev.
  *	This is always called from the stack with the rtnl lock held and netif
@@ -1227,8 +1226,6 @@ struct net_device_ops {
 						   int vf, bool setting);
 	int			(*ndo_setup_tc)(struct net_device *dev,
 						enum tc_setup_type type,
-						u32 handle, u32 chain_index,
-						__be16 protocol,
 						struct tc_to_netdev *tc);
 #if IS_ENABLED(CONFIG_FCOE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 8213acd..ffaddf7 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -405,6 +405,21 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
 }
 #endif /* CONFIG_NET_CLS_IND */
 
+struct tc_cls_common_offload {
+	u32 handle;
+	u32 chain_index;
+	__be16 protocol;
+};
+
+static inline void
+tc_cls_common_offload_init(struct tc_cls_common_offload *cls_common,
+			   const struct tcf_proto *tp)
+{
+	cls_common->handle = tp->q->handle;
+	cls_common->chain_index = tp->chain->index;
+	cls_common->protocol = tp->protocol;
+}
+
 struct tc_cls_u32_knode {
 	struct tcf_exts *exts;
 	struct tc_u32_sel *sel;
@@ -431,6 +446,7 @@ enum tc_clsu32_command {
 };
 
 struct tc_cls_u32_offload {
+	struct tc_cls_common_offload common;
 	/* knode values */
 	enum tc_clsu32_command command;
 	union {
@@ -497,6 +513,7 @@ enum tc_fl_command {
 };
 
 struct tc_cls_flower_offload {
+	struct tc_cls_common_offload common;
 	enum tc_fl_command command;
 	u32 prio;
 	unsigned long cookie;
@@ -513,6 +530,7 @@ enum tc_matchall_command {
 };
 
 struct tc_cls_matchall_offload {
+	struct tc_cls_common_offload common;
 	enum tc_matchall_command command;
 	struct tcf_exts *exts;
 	unsigned long cookie;
@@ -526,6 +544,7 @@ enum tc_clsbpf_command {
 };
 
 struct tc_cls_bpf_offload {
+	struct tc_cls_common_offload common;
 	enum tc_clsbpf_command command;
 	struct tcf_exts *exts;
 	struct bpf_prog *prog;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e76d576..5e01e92 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -774,12 +774,12 @@ dsa_slave_mall_tc_entry_find(struct dsa_slave_priv *p,
 }
 
 static int dsa_slave_add_cls_matchall(struct net_device *dev,
-				      __be16 protocol,
 				      struct tc_cls_matchall_offload *cls,
 				      bool ingress)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_mall_tc_entry *mall_tc_entry;
+	__be16 protocol = cls->common.protocol;
 	struct dsa_switch *ds = p->dp->ds;
 	struct net *net = dev_net(dev);
 	struct dsa_slave_priv *to_p;
@@ -864,18 +864,16 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
 }
 
 static int dsa_slave_setup_tc_cls_matchall(struct net_device *dev,
-					   u32 handle, u32 chain_index,
-					   __be16 protocol,
 					   struct tc_cls_matchall_offload *cls)
 {
-	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
+	bool ingress = TC_H_MAJ(cls->common.handle) == TC_H_MAJ(TC_H_INGRESS);
 
-	if (chain_index)
+	if (cls->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls->command) {
 	case TC_CLSMATCHALL_REPLACE:
-		return dsa_slave_add_cls_matchall(dev, protocol, cls, ingress);
+		return dsa_slave_add_cls_matchall(dev, cls, ingress);
 	case TC_CLSMATCHALL_DESTROY:
 		dsa_slave_del_cls_matchall(dev, cls);
 		return 0;
@@ -885,13 +883,11 @@ static int dsa_slave_setup_tc_cls_matchall(struct net_device *dev,
 }
 
 static int dsa_slave_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			      u32 handle, u32 chain_index, __be16 protocol,
 			      struct tc_to_netdev *tc)
 {
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
-		return dsa_slave_setup_tc_cls_matchall(dev, handle, chain_index,
-						       protocol, tc->cls_mall);
+		return dsa_slave_setup_tc_cls_matchall(dev, tc->cls_mall);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index e2bf275..dde8efd 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -153,6 +153,7 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 
 	offload.cls_bpf = &bpf_offload;
 
+	tc_cls_common_offload_init(&bpf_offload.common, tp);
 	bpf_offload.command = cmd;
 	bpf_offload.exts = &prog->exts;
 	bpf_offload.prog = prog->filter;
@@ -160,11 +161,7 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	bpf_offload.exts_integrated = prog->exts_integrated;
 	bpf_offload.gen_flags = prog->gen_flags;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF,
-					    tp->q->handle,
-					    tp->chain->index,
-					    tp->protocol, &offload);
-
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF, &offload);
 	if (!err && (cmd == TC_CLSBPF_ADD || cmd == TC_CLSBPF_REPLACE))
 		prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 52deeed..1fdf288 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -232,14 +232,14 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 	if (!tc_can_offload(dev, tp))
 		return;
 
+	tc_cls_common_offload_init(&offload.common, tp);
 	offload.command = TC_CLSFLOWER_DESTROY;
 	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
 
 	tc->cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, tp->q->handle,
-				      tp->chain->index, tp->protocol, tc);
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, tc);
 }
 
 static int fl_hw_replace_filter(struct tcf_proto *tp,
@@ -264,6 +264,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 		f->hw_dev = dev;
 	}
 
+	tc_cls_common_offload_init(&offload.common, tp);
 	offload.command = TC_CLSFLOWER_REPLACE;
 	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
@@ -274,9 +275,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 
 	tc->cls_flower = &offload;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-					    tp->q->handle, tp->chain->index,
-					    tp->protocol, tc);
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, tc);
 	if (!err)
 		f->flags |= TCA_CLS_FLAGS_IN_HW;
 
@@ -294,6 +293,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	if (!tc_can_offload(dev, tp))
 		return;
 
+	tc_cls_common_offload_init(&offload.common, tp);
 	offload.command = TC_CLSFLOWER_STATS;
 	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
@@ -301,8 +301,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 
 	tc->cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_CLSFLOWER_STATS, tp->q->handle,
-				      tp->chain->index, tp->protocol, tc);
+	dev->netdev_ops->ndo_setup_tc(dev, TC_CLSFLOWER_STATS, tc);
 }
 
 static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index a8853ad..174c700 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -58,14 +58,14 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 	struct tc_cls_matchall_offload mall_offload = {0};
 	int err;
 
+	tc_cls_common_offload_init(&mall_offload.common, tp);
 	offload.cls_mall = &mall_offload;
 	offload.cls_mall->command = TC_CLSMATCHALL_REPLACE;
 	offload.cls_mall->exts = &head->exts;
 	offload.cls_mall->cookie = cookie;
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL,
-					    tp->q->handle, tp->chain->index,
-					    tp->protocol, &offload);
+					    &offload);
 	if (!err)
 		head->flags |= TCA_CLS_FLAGS_IN_HW;
 
@@ -80,13 +80,13 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 	struct tc_to_netdev offload;
 	struct tc_cls_matchall_offload mall_offload = {0};
 
+	tc_cls_common_offload_init(&mall_offload.common, tp);
 	offload.cls_mall = &mall_offload;
 	offload.cls_mall->command = TC_CLSMATCHALL_DESTROY;
 	offload.cls_mall->exts = NULL;
 	offload.cls_mall->cookie = cookie;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL, tp->q->handle,
-				      tp->chain->index, tp->protocol, &offload);
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL, &offload);
 }
 
 static void mall_destroy(struct tcf_proto *tp)
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index d1bae4c..c0f59c4 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -437,11 +437,10 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	offload.cls_u32 = &u32_offload;
 
 	if (tc_should_offload(dev, tp, 0)) {
+		tc_cls_common_offload_init(&u32_offload.common, tp);
 		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
 		offload.cls_u32->knode.handle = handle;
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32,
-					      tp->q->handle, tp->chain->index,
-					      tp->protocol, &offload);
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &offload);
 	}
 }
 
@@ -458,14 +457,13 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 
 	offload.cls_u32 = &u32_offload;
 
+	tc_cls_common_offload_init(&u32_offload.common, tp);
 	offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
 	offload.cls_u32->hnode.divisor = h->divisor;
 	offload.cls_u32->hnode.handle = h->handle;
 	offload.cls_u32->hnode.prio = h->prio;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, tp->q->handle,
-					    tp->chain->index, tp->protocol,
-					    &offload);
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &offload);
 	if (tc_skip_sw(flags))
 		return err;
 
@@ -481,14 +479,13 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	offload.cls_u32 = &u32_offload;
 
 	if (tc_should_offload(dev, tp, 0)) {
+		tc_cls_common_offload_init(&u32_offload.common, tp);
 		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
 		offload.cls_u32->hnode.prio = h->prio;
 
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32,
-					      tp->q->handle, tp->chain->index,
-					      tp->protocol, &offload);
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &offload);
 	}
 }
 
@@ -505,6 +502,7 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 	if (!tc_should_offload(dev, tp, flags))
 		return tc_skip_sw(flags) ? -EINVAL : 0;
 
+	tc_cls_common_offload_init(&u32_offload.common, tp);
 	offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
 	offload.cls_u32->knode.handle = n->handle;
 	offload.cls_u32->knode.fshift = n->fshift;
@@ -520,9 +518,7 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 	if (n->ht_down)
 		offload.cls_u32->knode.link_handle = n->ht_down->handle;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, tp->q->handle,
-					    tp->chain->index, tp->protocol,
-					    &offload);
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &offload);
 
 	if (!err)
 		n->flags |= TCA_CLS_FLAGS_IN_HW;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 329610c..09b577d 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -42,8 +42,7 @@ static void mqprio_destroy(struct Qdisc *sch)
 		struct tc_mqprio_qopt offload = { 0 };
 		struct tc_to_netdev tc = { { .mqprio = &offload } };
 
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO,
-					      sch->handle, 0, 0, &tc);
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO, &tc);
 	} else {
 		netdev_set_num_tc(dev, 0);
 	}
@@ -151,8 +150,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 		struct tc_mqprio_qopt offload = *qopt;
 		struct tc_to_netdev tc = { { .mqprio = &offload } };
 
-		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO,
-						    sch->handle, 0, 0, &tc);
+		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO, &tc);
 		if (err)
 			return err;
 
-- 
2.9.3
