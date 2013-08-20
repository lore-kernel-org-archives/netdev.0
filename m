From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 4/4] net/mlx4_en: Reduce scope of local variables in mlx4_en_xmit
Date: Tue, 20 Aug 2013 18:42:49 +0300
Message-ID: <1377013369-14711-5-git-send-email-amirv@mellanox.com>
References: <1377013369-14711-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39438 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751616Ab3HTPnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 11:43:13 -0400
In-Reply-To: <1377013369-14711-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some variables could have their scope reduced.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c28868b..0698c82 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -592,14 +592,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mlx4_en_tx_ring *ring;
 	struct mlx4_en_tx_desc *tx_desc;
 	struct mlx4_wqe_data_seg *data;
-	struct skb_frag_struct *frag;
 	struct mlx4_en_tx_info *tx_info;
-	struct ethhdr *ethh;
 	int tx_ind = 0;
 	int nr_txbb;
 	int desc_size;
 	int real_size;
-	dma_addr_t dma;
 	u32 index, bf_index;
 	__be32 op_own;
 	u16 vlan_tag = 0;
@@ -694,6 +691,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else {
 		/* Map fragments */
 		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
+			struct skb_frag_struct *frag;
+			dma_addr_t dma;
+
 			frag = &skb_shinfo(skb)->frags[i];
 			dma = skb_frag_dma_map(ddev, frag,
 					       0, skb_frag_size(frag),
@@ -711,6 +711,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* Map linear part */
 		if (tx_info->linear) {
 			u32 byte_count = skb_headlen(skb) - lso_header_size;
+			dma_addr_t dma;
+
 			dma = dma_map_single(ddev, skb->data +
 					     lso_header_size, byte_count,
 					     PCI_DMA_TODEVICE);
@@ -749,6 +751,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (priv->flags & MLX4_EN_FLAG_ENABLE_HW_LOOPBACK) {
+		struct ethhdr *ethh;
+
 		/* Copy dst mac address to wqe. This allows loopback in eSwitch,
 		 * so that VFs and PF can communicate with each other
 		 */
-- 
1.8.3.4
