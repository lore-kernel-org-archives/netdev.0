From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 08/10] net/mlx4_en: Increase default TX ring size
Date: Thu, 15 Jun 2017 14:35:38 +0300
Message-ID: <1497526540-30028-9-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36072 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752352AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase the default TX ring size (from 512 to 1024) to match
the RX ring size.
This gives the XDP TX ring a better chance to keep up with the
rate of its RX ring in case of a high load of XDP_TX actions.

Tested:
Ethtool counter rx_xdp_tx_full used to increase, after applying this
patch it stopped.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index bde3bc869b70..7f61b5829709 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -115,8 +115,8 @@
 #define MLX4_EN_MIN_TX_RING_P_UP	1
 #define MLX4_EN_MAX_TX_RING_P_UP	32
 #define MLX4_EN_NUM_UP			8
-#define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
+#define MLX4_EN_DEF_TX_RING_SIZE	MLX4_EN_DEF_RX_RING_SIZE
 #define MAX_TX_RINGS			(MLX4_EN_MAX_TX_RING_P_UP * \
 					 MLX4_EN_NUM_UP)
 
-- 
1.8.3.1
