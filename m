From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4_en: Fix bad use of dev_id
Date: Tue, 25 Feb 2014 18:17:52 +0200
Message-ID: <1393345072-31584-4-git-send-email-amirv@mellanox.com>
References: <1393345072-31584-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43252 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752954AbaBYQSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 11:18:47 -0500
In-Reply-To: <1393345072-31584-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_id should be set for multiple netdev's sharing the same MAC, which
is not the case here.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index caa488a..2c0823b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2341,7 +2341,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netif_set_real_num_rx_queues(dev, prof->rx_ring_num);
 
 	SET_NETDEV_DEV(dev, &mdev->dev->pdev->dev);
-	dev->dev_id =  port - 1;
 	dev->dev_port = port - 1;
 
 	/*
-- 
1.8.3.4
