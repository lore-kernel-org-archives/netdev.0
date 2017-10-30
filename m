From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/9] net_sch: mqprio: Change TC_SETUP_MQPRIO to TC_SETUP_QDISC_MQPRIO
Date: Mon, 30 Oct 2017 09:56:06 +0100
Message-ID: <20171030085613.8697-3-jiri@resnulli.us>
References: <20171030085613.8697-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:49904 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752636AbdJ3I4S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 04:56:18 -0400
Received: by mail-wr0-f195.google.com with SMTP id g90so11722079wrd.6
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 01:56:17 -0700 (PDT)
In-Reply-To: <20171030085613.8697-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Change TC_SETUP_MQPRIO to TC_SETUP_QDISC_MQPRIO to match the new
convention.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c               | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c        | 2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c              | 2 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c         | 2 +-
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c        | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c            | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c          | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c         | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c      | 2 +-
 drivers/net/ethernet/sfc/falcon/tx.c                   | 2 +-
 drivers/net/ethernet/sfc/tx.c                          | 2 +-
 drivers/net/ethernet/ti/netcp_core.c                   | 2 +-
 include/linux/netdevice.h                              | 2 +-
 net/sched/sch_mqprio.c                                 | 5 +++--
 15 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 3d53153..a74a8fb 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -2206,7 +2206,7 @@ static int xgbe_setup_tc(struct net_device *netdev, enum tc_setup_type type,
 	struct tc_mqprio_qopt *mqprio = type_data;
 	u8 tc;
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 1216c1f..4c739d5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4289,7 +4289,7 @@ int __bnx2x_setup_tc(struct net_device *dev, enum tc_setup_type type,
 {
 	struct tc_mqprio_qopt *mqprio = type_data;
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5ce9506..9ab2785 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7384,7 +7384,7 @@ static int bnxt_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	switch (type) {
 	case TC_SETUP_BLOCK:
 		return bnxt_setup_tc_block(dev, type_data);
-	case TC_SETUP_MQPRIO: {
+	case TC_SETUP_QDISC_MQPRIO: {
 		struct tc_mqprio_qopt *mqprio = type_data;
 
 		mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index a8d0be8..c9ab893 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -351,7 +351,7 @@ static int dpaa_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
 	u8 num_tc;
 	int i;
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index c6c5b2a..39d93e6 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1250,7 +1250,7 @@ static int hns3_setup_tc(struct net_device *netdev, void *type_data)
 static int hns3_nic_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			     void *type_data)
 {
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	return hns3_setup_tc(dev, type_data);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 81e4425..adc62fb 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1389,7 +1389,7 @@ static int __fm10k_setup_tc(struct net_device *dev, enum tc_setup_type type,
 {
 	struct tc_mqprio_qopt *mqprio = type_data;
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 54ff34f..97b2a82 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6751,7 +6751,7 @@ static int i40e_setup_tc(struct net_device *netdev, void *type_data)
 static int __i40e_setup_tc(struct net_device *netdev, enum tc_setup_type type,
 			   void *type_data)
 {
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	return i40e_setup_tc(netdev, type_data);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7f503d3..1d176a8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9434,7 +9434,7 @@ static int __ixgbe_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	switch (type) {
 	case TC_SETUP_BLOCK:
 		return ixgbe_setup_tc_block(dev, type_data);
-	case TC_SETUP_MQPRIO:
+	case TC_SETUP_QDISC_MQPRIO:
 		return ixgbe_setup_tc_mqprio(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index d611df2..9f3a9f9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -135,7 +135,7 @@ static int __mlx4_en_setup_tc(struct net_device *dev, enum tc_setup_type type,
 {
 	struct tc_mqprio_qopt *mqprio = type_data;
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	if (mqprio->num_tc && mqprio->num_tc != MLX4_EN_NUM_UP_HIGH)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 560b208..6f47b8b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3144,7 +3144,7 @@ int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	case TC_SETUP_BLOCK:
 		return mlx5e_setup_tc_block(dev, type_data);
 #endif
-	case TC_SETUP_MQPRIO:
+	case TC_SETUP_QDISC_MQPRIO:
 		return mlx5e_setup_tc_mqprio(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/sfc/falcon/tx.c b/drivers/net/ethernet/sfc/falcon/tx.c
index 6a75f41..1b978d6 100644
--- a/drivers/net/ethernet/sfc/falcon/tx.c
+++ b/drivers/net/ethernet/sfc/falcon/tx.c
@@ -435,7 +435,7 @@ int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
 	unsigned tc, num_tc;
 	int rc;
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	num_tc = mqprio->num_tc;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 32bf1fe..ea27b8a 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -663,7 +663,7 @@ int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
 	unsigned tc, num_tc;
 	int rc;
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	num_tc = mqprio->num_tc;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 437d362..15e2e30 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1887,7 +1887,7 @@ static int netcp_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	/* setup tc must be called under rtnl lock */
 	ASSERT_RTNL();
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_QDISC_MQPRIO)
 		return -EOPNOTSUPP;
 
 	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1dc9833..732e2dc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -770,7 +770,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
 enum tc_setup_type {
-	TC_SETUP_MQPRIO,
+	TC_SETUP_QDISC_MQPRIO,
 	TC_SETUP_CLSU32,
 	TC_SETUP_CLSFLOWER,
 	TC_SETUP_CLSMATCHALL,
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 4d5ed45..b85885a9 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -50,7 +50,8 @@ static void mqprio_destroy(struct Qdisc *sch)
 		switch (priv->mode) {
 		case TC_MQPRIO_MODE_DCB:
 		case TC_MQPRIO_MODE_CHANNEL:
-			dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO,
+			dev->netdev_ops->ndo_setup_tc(dev,
+						      TC_SETUP_QDISC_MQPRIO,
 						      &mqprio);
 			break;
 		default:
@@ -265,7 +266,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 			return -EINVAL;
 		}
 		err = dev->netdev_ops->ndo_setup_tc(dev,
-						    TC_SETUP_MQPRIO,
+						    TC_SETUP_QDISC_MQPRIO,
 						    &mqprio);
 		if (err)
 			return err;
-- 
2.9.5
