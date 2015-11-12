From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/6] net/mlx5e: Max mtu comparison fix
Date: Thu, 12 Nov 2015 19:35:27 +0200
Message-ID: <1447349730-19832-4-git-send-email-ogerlitz@mellanox.com>
References: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Doron Tsur <doront@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:46720 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752822AbbKLRfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 12:35:55 -0500
In-Reply-To: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doron Tsur <doront@mellanox.com>

On change mtu the driver compares between hardware queried mtu and
software requested mtu. We need to compare between software
representation of the queried mtu and the requested mtu.

Fixes: facc9699f0fe ('net/mlx5e: Fix HW MTU settings')
Signed-off-by: Doron Tsur <doront@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index df00175..1e52db3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1901,6 +1901,8 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 
 	mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
 
+	max_mtu = MLX5E_HW2SW_MTU(max_mtu);
+
 	if (new_mtu > max_mtu) {
 		netdev_err(netdev,
 			   "%s: Bad MTU (%d) > (%d) Max\n",
-- 
2.3.7
