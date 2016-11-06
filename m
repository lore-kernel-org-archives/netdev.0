From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] Revert "net/mlx4_en: Fix panic during reboot"
Date: Sun,  6 Nov 2016 18:05:06 +0200
Message-ID: <1478448306-28738-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50600 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751872AbcKFQFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 11:05:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 9d2afba058722d40cc02f430229c91611c0e8d16.

The original issue would possibly exist if an external module
tried calling our "ethtool_ops" without checking if it still
exists.

The right way of solving it is by simply doing the check in
the caller side.
Currently, no action is required as there's no such use case.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 12c99a2655f2..3a47e83d3e07 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2202,7 +2202,6 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 
 	if (!shutdown)
 		free_netdev(dev);
-	dev->ethtool_ops = NULL;
 }
 
 static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
-- 
1.8.3.1
