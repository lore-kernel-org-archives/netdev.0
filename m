From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 06/10] net/mlx4_en: Fix panic during reboot
Date: Thu, 27 Oct 2016 16:27:18 +0300
Message-ID: <1477574842-29688-7-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57535 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941516AbcJ0NyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:22 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Fix a kernel panic that occurs as a result of an asynchronous event
handled in roce_gid_mgmt:
mlx4_en_get_drvinfo is called and accesses freed resources.

This happens in a shutdown flow only, since pci device is destroyed
while netdevice is still alive.

Fixes: c27a02cd94d6 ("mlx4_en: Add driver for Mellanox ConnectX 10GbE NIC")
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e25c11dff525..314f54c8dbed 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2201,6 +2201,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 
 	if (!shutdown)
 		free_netdev(dev);
+	dev->ethtool_ops = NULL;
 }
 
 static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
-- 
1.8.3.1
