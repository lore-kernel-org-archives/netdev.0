From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 3/6] net/mlx4_en: Use the correct netif lock on ndo_set_rx_mode
Date: Thu, 17 Jan 2013 13:47:18 +0200
Message-ID: <1358423241-2452-4-git-send-email-amirv@mellanox.com>
References: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:36730 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753969Ab3AQLrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 06:47:36 -0500
In-Reply-To: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

The device multicast list is protected by netif_addr_lock_bh in the networking core, we should
use this locking practice in mlx4_en too.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index bab8cec..805e242 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -767,9 +767,9 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 
 		/* Update multicast list - we cache all addresses so they won't
 		 * change while HW is updated holding the command semaphor */
-		netif_tx_lock_bh(dev);
+		netif_addr_lock_bh(dev);
 		mlx4_en_cache_mclist(dev);
-		netif_tx_unlock_bh(dev);
+		netif_addr_unlock_bh(dev);
 		list_for_each_entry(mclist, &priv->mc_list, list) {
 			mcast_addr = mlx4_en_mac_to_u64(mclist->addr);
 			mlx4_SET_MCAST_FLTR(mdev->dev, priv->port,
-- 
1.7.8.2
