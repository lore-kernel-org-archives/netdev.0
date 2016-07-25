From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Check device state before unregistering it
Date: Mon, 25 Jul 2016 15:42:13 +0300
Message-ID: <1469450533-27494-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Alex Vesker <valex@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47053 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751254AbcGYMmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 08:42:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

Verify that the device state is registered before un-registering it.
This check is required to prevent an OOPS on flows that do
re-registration of the device and its previous state was
unregistered.

Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters")
Signed-off-by: Alex Vesker <valex@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/intf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index dec77d6f0ac9..5aeb6027b70e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -218,6 +218,9 @@ void mlx4_unregister_device(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_interface *intf;
 
+	if (!(dev->persist->interface_state & MLX4_INTERFACE_STATE_UP))
+		return;
+
 	mlx4_stop_catas_poll(dev);
 	mutex_lock(&intf_mutex);
 
-- 
1.8.3.1
