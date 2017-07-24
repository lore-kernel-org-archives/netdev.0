From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] mlx4_en: remove unnecessary returned value
Date: Sun, 23 Jul 2017 23:02:53 -0400
Message-ID: <1500865373-32411-1-git-send-email-yanjun.zhu@oracle.com>
To: tariqt@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, yuval.shaia@oracle.com, leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18066 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751853AbdGXDA5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 23:00:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function mlx4_en_arm_cq always returns zero. So change the
return type of the function mlx4_en_arm_cq to void.

CC: Joe Jin <joe.jin@oracle.com>
CC: Junxiao Bi <junxiao.bi@oracle.com>
Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c   | 4 +---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 85fe17e..87d1f4d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -208,12 +208,10 @@ int mlx4_en_set_cq_moder(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 			      cq->moder_cnt, cq->moder_time);
 }
 
-int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
+void mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
 	mlx4_cq_arm(&cq->mcq, MLX4_CQ_DB_REQ_NOT, priv->mdev->uar_map,
 		    &priv->mdev->uar_lock);
-
-	return 0;
 }
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d350b21..fdb3ad0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -685,7 +685,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 			int cq_idx);
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 int mlx4_en_set_cq_moder(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
-int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
+void mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 
 void mlx4_en_tx_irq(struct mlx4_cq *mcq);
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
-- 
2.7.4
