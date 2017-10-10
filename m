From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4_en: Increase number of default RX rings
Date: Tue, 10 Oct 2017 12:28:35 +0300
Message-ID: <1507627715-25487-4-git-send-email-tariqt@mellanox.com>
References: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Inbar Karmy <inbark@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48110 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755985AbdJJJ2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 05:28:52 -0400
In-Reply-To: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inbar Karmy <inbark@mellanox.com>

Remove limitation of netif_get_num_default_rss_queues()
from logic of RX rings default number.

Signed-off-by: Inbar Karmy <inbark@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 8f9cb8abc497..a7866954d106 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -254,8 +254,7 @@ void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
 					 DEF_RX_RINGS));
 
 		num_rx_rings = mlx4_low_memory_profile() ? MIN_RX_RINGS :
-			min_t(int, num_of_eqs,
-			      netif_get_num_default_rss_queues());
+			min_t(int, num_of_eqs, num_online_cpus());
 		mdev->profile.prof[i].rx_ring_num =
 			rounddown_pow_of_two(num_rx_rings);
 	}
-- 
1.8.3.1
