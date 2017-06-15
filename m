From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 01/10] net/mlx4_en: Remove unused argument in TX datapath function
Date: Thu, 15 Jun 2017 14:35:31 +0300
Message-ID: <1497526540-30028-2-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36058 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752402AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove owner argument, as it is obsolete and unused.
This also saves the overhead of calculating its value in data-path.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 10 ++++------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  6 +++---
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 6ffd1849a604..37386abea54c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -265,7 +265,7 @@ static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
 
 u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			 struct mlx4_en_tx_ring *ring,
-			 int index, u8 owner, u64 timestamp,
+			 int index, u64 timestamp,
 			 int napi_mode)
 {
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
@@ -344,7 +344,7 @@ u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 
 u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
 			    struct mlx4_en_tx_ring *ring,
-			    int index, u8 owner, u64 timestamp,
+			    int index, u64 timestamp,
 			    int napi_mode)
 {
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
@@ -381,8 +381,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	while (ring->cons != ring->prod) {
 		ring->last_nr_txbb = ring->free_tx_desc(priv, ring,
 						ring->cons & ring->size_mask,
-						!!(ring->cons & ring->size), 0,
-						0 /* Non-NAPI caller */);
+						0, 0 /* Non-NAPI caller */);
 		ring->cons += ring->last_nr_txbb;
 		cnt++;
 	}
@@ -464,8 +463,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 			/* free next descriptor */
 			last_nr_txbb = ring->free_tx_desc(
 					priv, ring, ring_index,
-					!!((ring_cons + txbbs_skipped) &
-					ring->size), timestamp, napi_budget);
+					timestamp, napi_budget);
 
 			mlx4_en_stamp_wqe(priv, ring, stamp_index,
 					  !!((ring_cons + txbbs_stamp) &
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 8c4f63946b14..08b2906a98af 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -276,7 +276,7 @@ struct mlx4_en_tx_ring {
 	struct netdev_queue	*tx_queue;
 	u32			(*free_tx_desc)(struct mlx4_en_priv *priv,
 						struct mlx4_en_tx_ring *ring,
-						int index, u8 owner,
+						int index,
 						u64 timestamp, int napi_mode);
 	struct mlx4_en_rx_ring	*recycle_ring;
 
@@ -723,11 +723,11 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
 int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget);
 u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			 struct mlx4_en_tx_ring *ring,
-			 int index, u8 owner, u64 timestamp,
+			 int index, u64 timestamp,
 			 int napi_mode);
 u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
 			    struct mlx4_en_tx_ring *ring,
-			    int index, u8 owner, u64 timestamp,
+			    int index, u64 timestamp,
 			    int napi_mode);
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 		int is_tx, int rss, int qpn, int cqn, int user_prio,
-- 
1.8.3.1
