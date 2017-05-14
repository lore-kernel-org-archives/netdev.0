From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 3/5] net/mlx5e: Fix setup TC ndo
Date: Sun, 14 May 2017 13:43:09 +0300
Message-ID: <20170514104311.2081-4-saeedm@mellanox.com>
References: <20170514104311.2081-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48617 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751662AbdENKnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 06:43:25 -0400
In-Reply-To: <20170514104311.2081-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fail-safe support patches introduced a trivial bug,
setup tc callback is doing a wrong check of the netdevice state,
the fix is simply to invert the condition.

Fixes: 6f9485af4020 ("net/mlx5e: Fail safe tc setup")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a61b71b6fff3..41cd22a223dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2976,7 +2976,7 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 	new_channels.params = priv->channels.params;
 	new_channels.params.num_tc = tc ? tc : 1;
 
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
 		priv->channels.params = new_channels.params;
 		goto out;
 	}
-- 
2.11.0
