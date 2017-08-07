From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 15/16] net: sched: change return value of ndo_setup_tc for driver supporting mqprio only
Date: Mon,  7 Aug 2017 10:15:31 +0200
Message-ID: <20170807081532.32760-16-jiri@resnulli.us>
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
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34040 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751837AbdHGIQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:16:00 -0400
Received: by mail-wr0-f193.google.com with SMTP id o33so7139419wrb.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:59 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Change the return value from -EINVAL to -EOPNOTSUPP. The rest of the
drivers have it like that, so be aligned.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c               | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c        | 2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c              | 2 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c         | 2 +-
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c        | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c            | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c         | 2 +-
 drivers/net/ethernet/sfc/falcon/tx.c                   | 2 +-
 drivers/net/ethernet/sfc/tx.c                          | 2 +-
 drivers/net/ethernet/ti/netcp_core.c                   | 2 +-
 11 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index bbb7bfe..37d3e5b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1925,7 +1925,7 @@ static int xgbe_setup_tc(struct net_device *netdev, enum tc_setup_type type,
 	u8 tc;
 
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	tc_to_netdev->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 	tc = tc_to_netdev->mqprio->num_tc;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 257cf4b..8687afc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4288,7 +4288,7 @@ int __bnx2x_setup_tc(struct net_device *dev, enum tc_setup_type type,
 		     struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 1545b88..a78f72a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7241,7 +7241,7 @@ static int bnxt_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			 struct tc_to_netdev *ntc)
 {
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	ntc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 3827608..bfb44c9 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -350,7 +350,7 @@ static int dpaa_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
 	int i;
 
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 	num_tc = tc->mqprio->num_tc;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index dc64d75..aa43ebd 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1223,7 +1223,7 @@ static int hns3_nic_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			     struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	return hns3_setup_tc(dev, tc->mqprio->num_tc);
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 71004b8..7088812 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1269,7 +1269,7 @@ static int __fm10k_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			    struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 97d8bb2..1f46338 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5660,7 +5660,7 @@ static int __i40e_setup_tc(struct net_device *netdev, enum tc_setup_type type,
 			   struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e81083e..1667e86 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -134,7 +134,7 @@ static int __mlx4_en_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			      struct tc_to_netdev *tc)
 {
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	if (tc->mqprio->num_tc && tc->mqprio->num_tc != MLX4_EN_NUM_UP_HIGH)
 		return -EINVAL;
diff --git a/drivers/net/ethernet/sfc/falcon/tx.c b/drivers/net/ethernet/sfc/falcon/tx.c
index 447519a..0f125e1 100644
--- a/drivers/net/ethernet/sfc/falcon/tx.c
+++ b/drivers/net/ethernet/sfc/falcon/tx.c
@@ -435,7 +435,7 @@ int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
 	int rc;
 
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	num_tc = ntc->mqprio->num_tc;
 
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index d17af91..53ba30c 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -663,7 +663,7 @@ int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
 	int rc;
 
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	num_tc = ntc->mqprio->num_tc;
 
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 14f91b2..caba0ab 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1887,7 +1887,7 @@ static int netcp_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	ASSERT_RTNL();
 
 	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 	num_tc = tc->mqprio->num_tc;
-- 
2.9.3
