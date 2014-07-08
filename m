From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/6] net/mlx4_en: Run loopback test only when port is up
Date: Tue,  8 Jul 2014 11:25:20 +0300
Message-ID: <1404807924-29038-3-git-send-email-amirv@mellanox.com>
References: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44701 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753646AbaGHI0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 04:26:37 -0400
In-Reply-To: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Loopback can't work when port is down.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 03e5f6a..49d5afc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -159,7 +159,8 @@ void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf)
 		if (priv->mdev->dev->caps.flags &
 					MLX4_DEV_CAP_FLAG_UC_LOOPBACK) {
 			buf[3] = mlx4_en_test_registers(priv);
-			buf[4] = mlx4_en_test_loopback(priv);
+			if (priv->port_up)
+				buf[4] = mlx4_en_test_loopback(priv);
 		}
 
 		if (carrier_ok)
-- 
1.8.3.4
