From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 3/3] net/mlx5e: Fix TX carrier errors report in get stats ndo
Date: Fri, 30 Jun 2017 10:12:29 +0300
Message-ID: <20170630071229.20357-4-saeedm@mellanox.com>
References: <20170630071229.20357-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44945 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751605AbdF3HNi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 03:13:38 -0400
In-Reply-To: <20170630071229.20357-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Symbol error during carrier counter from PPCNT was mistakenly reported as
TX carrier errors in get_stats ndo, although it's an RX counter.

Fixes: 269e6b3af3bf ("net/mlx5e: Report additional error statistics in get stats ndo")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 277f4de30375..7819fe9ede22 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3053,8 +3053,6 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		PPORT_802_3_GET(pstats, a_frame_check_sequence_errors);
 	stats->rx_frame_errors = PPORT_802_3_GET(pstats, a_alignment_errors);
 	stats->tx_aborted_errors = PPORT_2863_GET(pstats, if_out_discards);
-	stats->tx_carrier_errors =
-		PPORT_802_3_GET(pstats, a_symbol_error_during_carrier);
 	stats->rx_errors = stats->rx_length_errors + stats->rx_crc_errors +
 			   stats->rx_frame_errors;
 	stats->tx_errors = stats->tx_aborted_errors + stats->tx_carrier_errors;
-- 
2.11.0
