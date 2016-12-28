From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 04/12] net/mlx5: Avoid shadowing numa_node
Date: Wed, 28 Dec 2016 14:58:34 +0200
Message-ID: <1482929922-32626-5-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32800 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751549AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Avoid using a local variable named numa_node to avoid shadowing a public
one.

Fixes: db058a186f98 ('net/mlx5_core: Set irq affinity hints')
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 0b49739..6547f22 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -582,7 +582,6 @@ static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
 	struct mlx5_priv *priv  = &mdev->priv;
 	struct msix_entry *msix = priv->msix_arr;
 	int irq                 = msix[i + MLX5_EQ_VEC_COMP_BASE].vector;
-	int numa_node           = priv->numa_node;
 	int err;
 
 	if (!zalloc_cpumask_var(&priv->irq_info[i].mask, GFP_KERNEL)) {
@@ -590,7 +589,7 @@ static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
 		return -ENOMEM;
 	}
 
-	cpumask_set_cpu(cpumask_local_spread(i, numa_node),
+	cpumask_set_cpu(cpumask_local_spread(i, priv->numa_node),
 			priv->irq_info[i].mask);
 
 	err = irq_set_affinity_hint(irq, priv->irq_info[i].mask);
-- 
2.7.4
