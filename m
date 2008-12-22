From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] [PATCH 3/9] mlx4_en: Removed redundant cq->armed flag
Date: Mon, 22 Dec 2008 12:00:31 +0200
Message-ID: <494F653F.2010806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_cq.c   |    1 -
 drivers/net/mlx4/en_tx.c   |    5 ++---
 drivers/net/mlx4/mlx4_en.h |    1 -
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mlx4/en_cq.c b/drivers/net/mlx4/en_cq.c
index 4aa3b0f..04a2804 100644
--- a/drivers/net/mlx4/en_cq.c
+++ b/drivers/net/mlx4/en_cq.c
@@ -140,7 +140,6 @@ int mlx4_en_set_cq_moder(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)

 int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
-	cq->armed = 1;
 	mlx4_cq_arm(&cq->mcq, MLX4_CQ_DB_REQ_NOT, priv->mdev->uar_map,
 		    &priv->mdev->uar_lock);

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 1f25821..ff4d752 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -379,8 +379,8 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)

 	/* Wakeup Tx queue if this ring stopped it */
 	if (unlikely(ring->blocked)) {
-		if (((u32) (ring->prod - ring->cons) <=
-		     ring->size - HEADROOM - MAX_DESC_TXBBS) && !cq->armed) {
+		if ((u32) (ring->prod - ring->cons) <=
+		     ring->size - HEADROOM - MAX_DESC_TXBBS) {

 			/* TODO: support multiqueue netdevs. Currently, we block
 			 * when *any* ring is full. Note that:
@@ -404,7 +404,6 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 	struct mlx4_en_tx_ring *ring = &priv->tx_ring[cq->ring];

-	cq->armed = 0;
 	if (!spin_trylock(&ring->comp_lock))
 		return;
 	mlx4_en_process_tx_cq(cq->dev, cq);
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 98ddc08..45b975f 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -311,7 +311,6 @@ struct mlx4_en_cq {
 	enum cq_type is_tx;
 	u16 moder_time;
 	u16 moder_cnt;
-	int armed;
 	struct mlx4_cqe *buf;
 #define MLX4_EN_OPCODE_ERROR	0x1e
 };
-- 
1.5.4
