From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2 4/6] net/mlx5e: Don't notify HW when filling the edge of ICO SQ
Date: Tue,  6 Dec 2016 17:32:46 +0200
Message-ID: <1481038368-29677-5-git-send-email-saeedm@mellanox.com>
References: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55469 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753341AbcLFPdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:33:40 -0500
In-Reply-To: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are going to do this a couple of steps ahead anyway.

Fixes: d3c9bc2743dc ("net/mlx5e: Added ICO SQs")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index c6de6fb..e9abb6d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -340,7 +340,7 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
 		sq->db.ico_wqe[pi].opcode = MLX5_OPCODE_NOP;
 		sq->db.ico_wqe[pi].num_wqebbs = 1;
-		mlx5e_send_nop(sq, true);
+		mlx5e_send_nop(sq, false);
 	}
 
 	wqe = mlx5_wq_cyc_get_wqe(wq, pi);
-- 
2.7.4
