From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/7] net/mlx4_en: Set carrier to off when a port is stopped
Date: Wed, 16 Jan 2013 17:42:12 +0200
Message-ID: <1358350935-3281-5-git-send-email-amirv@mellanox.com>
References: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:35106 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754096Ab3APPmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 10:42:45 -0500
In-Reply-To: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Under heavy CPU load changing ring size/mtu/etc. could result in transmit
timeout, since stop-start port might take more than 10 sec. Set
netif_carrier_off to prevent tx queue transmit timeout.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 805e242..108c4cf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1212,6 +1212,7 @@ void mlx4_en_stop_port(struct net_device *dev)
 
 	/* Synchronize with tx routine */
 	netif_tx_lock_bh(dev);
+	netif_carrier_off(dev);
 	netif_tx_stop_all_queues(dev);
 	netif_tx_unlock_bh(dev);
 
-- 
1.7.8.2
