From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 1/3] net/mlx4_en: Replace netdev parameter with priv in XDP xmit function
Date: Wed, 11 Oct 2017 13:17:25 +0300
Message-ID: <1507717047-29255-2-git-send-email-tariqt@mellanox.com>
References: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        kernel-team@fb.com, Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53144 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753117AbdJKKRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 06:17:48 -0400
In-Reply-To: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct net_device parameter was passed only to extract
struct mlx4_en_priv out of it.
Here we pass the priv parameter directly.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 3 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index a7866954d106..92aec17f4b4d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -778,7 +778,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			case XDP_PASS:
 				break;
 			case XDP_TX:
-				if (likely(!mlx4_en_xmit_frame(ring, frags, dev,
+				if (likely(!mlx4_en_xmit_frame(ring, frags, priv,
 							length, cq_ring,
 							&doorbell_pending))) {
 					frags[0].page = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 2cc82dc07397..f16774c9c347 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -1087,10 +1087,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 			       struct mlx4_en_rx_alloc *frame,
-			       struct net_device *dev, unsigned int length,
+			       struct mlx4_en_priv *priv, unsigned int length,
 			       int tx_ind, bool *doorbell_pending)
 {
-	struct mlx4_en_priv *priv = netdev_priv(dev);
 	union mlx4_wqe_qpn_vlan	qpn_vlan = {};
 	struct mlx4_en_tx_desc *tx_desc;
 	struct mlx4_en_tx_info *tx_info;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 245e9ea09ab2..8cad9b4f1936 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -693,7 +693,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 			       struct mlx4_en_rx_alloc *frame,
-			       struct net_device *dev, unsigned int length,
+			       struct mlx4_en_priv *priv, unsigned int length,
 			       int tx_ind, bool *doorbell_pending);
 void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring);
 bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
-- 
1.8.3.1
