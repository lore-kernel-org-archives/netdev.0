From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/mlx4_core: Fix build failure introduced by the EQ pool changes
Date: Tue,  2 Jun 2015 10:29:48 +0300
Message-ID: <1433230188-29726-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, mpe@ellerman.id.au,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:46014 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752972AbbFBHaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 03:30:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_RFS_ACCEL or SMP aren't set, we fail to build, fix it.

Also, avoid build warning as of unused function on that setup.

Fixes: c66fa19c405a ('net/mlx4: Add EQ pool')
Reported-by: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 1116882..aae13ad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -221,6 +221,7 @@ static void mlx4_slave_event(struct mlx4_dev *dev, int slave,
 	slave_event(dev, slave, eqe);
 }
 
+#if defined(CONFIG_SMP)
 static void mlx4_set_eq_affinity_hint(struct mlx4_priv *priv, int vec)
 {
 	int hint_err;
@@ -234,6 +235,7 @@ static void mlx4_set_eq_affinity_hint(struct mlx4_priv *priv, int vec)
 	if (hint_err)
 		mlx4_warn(dev, "irq_set_affinity_hint failed, err %d\n", hint_err);
 }
+#endif
 
 int mlx4_gen_pkey_eqe(struct mlx4_dev *dev, int slave, u8 port)
 {
@@ -1207,8 +1209,8 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 					     MLX4_NUM_ASYNC_EQE + MLX4_NUM_SPARE_EQE,
 					     0, &priv->eq_table.eq[MLX4_EQ_ASYNC]);
 		} else {
-#ifdef CONFIG_RFS_ACCEL
 			struct mlx4_eq	*eq = &priv->eq_table.eq[i];
+#ifdef CONFIG_RFS_ACCEL
 			int port = find_first_bit(eq->actv_ports.ports,
 						  dev->caps.num_ports) + 1;
 
-- 
1.7.1
