From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Fix user prio field in XDP forward
Date: Thu, 22 Dec 2016 14:32:58 +0200
Message-ID: <1482409978-17590-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59201 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965418AbcLVMdV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 07:33:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The user prio field is wrong (and overflows) in the XDP forward
flow.
This is a result of a bad value for num_tx_rings_p_up, which should
account all XDP TX rings, as they operate for the same user prio.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reported-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index bcd955339058..edbe200ac2fa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1638,7 +1638,8 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	/* Configure tx cq's and rings */
 	for (t = 0 ; t < MLX4_EN_NUM_TX_TYPES; t++) {
-		u8 num_tx_rings_p_up = t == TX ? priv->num_tx_rings_p_up : 1;
+		u8 num_tx_rings_p_up = t == TX ?
+			priv->num_tx_rings_p_up : priv->tx_ring_num[t];
 
 		for (i = 0; i < priv->tx_ring_num[t]; i++) {
 			/* Configure cq */
-- 
1.8.3.1
