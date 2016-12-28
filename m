From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 10/12] net/mlx5e: Check ets capability before initializing ets settings
Date: Wed, 28 Dec 2016 14:58:40 +0200
Message-ID: <1482929922-32626-11-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32812 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751593AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

During the initial setup, the ets command is sent to firmware
without checking if the HCA supports ets. This causes the invalid
command error. Add the ets capiblity check before sending firmware
command to initialize ets settings.

Fixes: e207b7e99176 ("net/mlx5e: ConnectX-4 firmware support for DCBX")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 7f6c225..f0b460f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -723,6 +723,9 @@ static void mlx5e_ets_init(struct mlx5e_priv *priv)
 	int i;
 	struct ieee_ets ets;
 
+	if (!MLX5_CAP_GEN(priv->mdev, ets))
+		return;
+
 	memset(&ets, 0, sizeof(ets));
 	ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
 	for (i = 0; i < ets.ets_cap; i++) {
-- 
2.7.4
