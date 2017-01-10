From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 09/10] net/mlx5e: Remove WARN_ONCE from adaptive moderation code
Date: Tue, 10 Jan 2017 22:33:38 +0200
Message-ID: <1484080419-24256-10-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gil Rockah <gilr@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52048 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751105AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gil Rockah <gilr@mellanox.com>

When trying to do interface down or changing interface configuration
under heavy traffic, some of the adaptive moderation corner cases can
occur and leave a WARN_ONCE call trace in the kernel log.

Those WARN_ONCE are meant for debug only, and should have been inserted
only under debug. We avoid such call traces by removing those WARN_ONCE.

Fixes: cb3c7fd4f839 ("net/mlx5e: Support adaptive RX coalescing")
Signed-off-by: Gil Rockah <gilr@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
index 1fffe48..cbfac06 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
@@ -109,7 +109,6 @@ static bool mlx5e_am_on_top(struct mlx5e_rx_am *am)
 	switch (am->tune_state) {
 	case MLX5E_AM_PARKING_ON_TOP:
 	case MLX5E_AM_PARKING_TIRED:
-		WARN_ONCE(true, "mlx5e_am_on_top: PARKING\n");
 		return true;
 	case MLX5E_AM_GOING_RIGHT:
 		return (am->steps_left > 1) && (am->steps_right == 1);
@@ -123,7 +122,6 @@ static void mlx5e_am_turn(struct mlx5e_rx_am *am)
 	switch (am->tune_state) {
 	case MLX5E_AM_PARKING_ON_TOP:
 	case MLX5E_AM_PARKING_TIRED:
-		WARN_ONCE(true, "mlx5e_am_turn: PARKING\n");
 		break;
 	case MLX5E_AM_GOING_RIGHT:
 		am->tune_state = MLX5E_AM_GOING_LEFT;
@@ -144,7 +142,6 @@ static int mlx5e_am_step(struct mlx5e_rx_am *am)
 	switch (am->tune_state) {
 	case MLX5E_AM_PARKING_ON_TOP:
 	case MLX5E_AM_PARKING_TIRED:
-		WARN_ONCE(true, "mlx5e_am_step: PARKING\n");
 		break;
 	case MLX5E_AM_GOING_RIGHT:
 		if (am->profile_ix == (MLX5E_PARAMS_AM_NUM_PROFILES - 1))
@@ -282,10 +279,8 @@ static void mlx5e_am_calc_stats(struct mlx5e_rx_am_sample *start,
 	u32 delta_us = ktime_us_delta(end->time, start->time);
 	unsigned int npkts = end->pkt_ctr - start->pkt_ctr;
 
-	if (!delta_us) {
-		WARN_ONCE(true, "mlx5e_am_calc_stats: delta_us=0\n");
+	if (!delta_us)
 		return;
-	}
 
 	curr_stats->ppms =            (npkts * USEC_PER_MSEC) / delta_us;
 	curr_stats->epms = (MLX5E_AM_NEVENTS * USEC_PER_MSEC) / delta_us;
-- 
2.7.4
