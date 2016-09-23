From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mlxsw: spectrum: remove redundant check if err is zero
Date: Fri, 23 Sep 2016 12:02:45 +0100
Message-ID: <20160923110245.18977-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

There is an earlier check and return if err is non-zero, so
the check to see if it is zero is redundant in every iteration
of the loop and hence the check can be removed.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 80f27b5..fd74d10 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1664,7 +1664,7 @@ static void __mlxsw_sp_port_get_stats(struct net_device *dev,
 		return;
 	mlxsw_sp_port_get_stats_raw(dev, grp, prio, ppcnt_pl);
 	for (i = 0; i < len; i++)
-		data[data_index + i] = !err ? hw_stats[i].getter(ppcnt_pl) : 0;
+		data[data_index + i] = hw_stats[i].getter(ppcnt_pl);
 }
 
 static void mlxsw_sp_port_get_stats(struct net_device *dev,
-- 
2.9.3
