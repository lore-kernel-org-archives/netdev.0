From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 14/17] net/mlx5e: Slightly increase RX page-cache size
Date: Sun,  3 Sep 2017 07:21:14 +0300
Message-ID: <20170903042117.28923-15-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60156 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751196AbdICEWR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:17 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In XDP_TX flow, we now get back quicker to each page in page-cache,
and on some occasions refcount does not get back to 1 on time, causing
some costly page allocations.
Slightly increase the size of RX page-cache to significantly decrease
the chances for this to happen.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e55d9439bc12..9c0c07ffe557 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -501,7 +501,7 @@ struct mlx5e_rx_am { /* Adaptive Moderation */
  */
 #define MLX5E_CACHE_UNIT	(MLX5_MPWRQ_PAGES_PER_WQE > NAPI_POLL_WEIGHT ? \
 				 MLX5_MPWRQ_PAGES_PER_WQE : NAPI_POLL_WEIGHT)
-#define MLX5E_CACHE_SIZE	(2 * roundup_pow_of_two(MLX5E_CACHE_UNIT))
+#define MLX5E_CACHE_SIZE	(4 * roundup_pow_of_two(MLX5E_CACHE_UNIT))
 struct mlx5e_page_cache {
 	u32 head;
 	u32 tail;
-- 
2.13.0
