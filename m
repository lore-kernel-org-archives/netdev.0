From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/10] net/mlx5e: IPoIB, Get more TX statistics
Date: Tue, 20 Jun 2017 17:13:12 +0300
Message-ID: <20170620141314.25620-9-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Erez Shitrit <erezsh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42066 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751998AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Add misses counters (bytes, packet, gso, xmit_more) in TX flow for ipoib
traffic.

Fixes: 58545449b7b ("net/mlx5e: IPoIB, Xmit flow")
Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 354f474322ce..0433d69429f3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -557,11 +557,16 @@ netdev_tx_t mlx5i_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb,
 	if (skb_is_gso(skb)) {
 		opcode = MLX5_OPCODE_LSO;
 		ihs = mlx5e_txwqe_build_eseg_gso(sq, skb, eseg, &num_bytes);
+		sq->stats.packets += skb_shinfo(skb)->gso_segs;
 	} else {
 		ihs = mlx5e_calc_min_inline(sq->min_inline_mode, skb);
 		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
+		sq->stats.packets++;
 	}
 
+	sq->stats.bytes += num_bytes;
+	sq->stats.xmit_more += skb->xmit_more;
+
 	ds_cnt = sizeof(*wqe) / MLX5_SEND_WQE_DS;
 	if (ihs) {
 		memcpy(eseg->inline_hdr.start, skb_data, ihs);
-- 
2.11.0
