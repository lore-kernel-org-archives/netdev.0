From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 10/11] net/mlx5: Fix static checker warning on steering tracepoints code
Date: Thu, 28 Sep 2017 07:41:31 +0300
Message-ID: <20170928044132.30940-11-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54420 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751776AbdI1EmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:06 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Fix this sparse complaint:

drivers/net/ethernet/mellanox/mlx5/core/./diag/fs_tracepoint.h:172:1:
	warning: odd constant _Bool cast (ffffffffffffffff becomes 1)

Fixes: d9fea79171ee ('net/mlx5: Add tracepoints')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h b/drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h
index 1e3a6c3e4132..80eef4163f52 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h
@@ -139,7 +139,7 @@ TRACE_EVENT(mlx5_fs_del_fg,
 	{MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO, "NEXT_PRIO"}
 
 TRACE_EVENT(mlx5_fs_set_fte,
-	    TP_PROTO(const struct fs_fte *fte, bool new_fte),
+	    TP_PROTO(const struct fs_fte *fte, int new_fte),
 	    TP_ARGS(fte, new_fte),
 	    TP_STRUCT__entry(
 		__field(const struct fs_fte *, fte)
@@ -149,7 +149,7 @@ TRACE_EVENT(mlx5_fs_set_fte,
 		__field(u32, action)
 		__field(u32, flow_tag)
 		__field(u8,  mask_enable)
-		__field(bool, new_fte)
+		__field(int, new_fte)
 		__array(u32, mask_outer, MLX5_ST_SZ_DW(fte_match_set_lyr_2_4))
 		__array(u32, mask_inner, MLX5_ST_SZ_DW(fte_match_set_lyr_2_4))
 		__array(u32, mask_misc, MLX5_ST_SZ_DW(fte_match_set_misc))
-- 
2.13.0
