From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mlxsw: spectrum: fix swapped order of arguments packets and bytes
Date: Mon, 20 Mar 2017 11:37:22 +0000
Message-ID: <20170320113722.30311-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The arguments packets and bytes to call mlxsw_sp_acl_rule_get_stats are
in the wrong order. Fix this by swapping them.

Detected by CoverityScan, CID#1419705 ("Arguments in wrong order")

Fixes: 7c1b8eb175b69add8ea ("mlxsw: spectrum: Add support for TC flower offload statistics")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index e724c6266247..3e7a0bcbba72 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -375,7 +375,7 @@ int mlxsw_sp_flower_stats(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 	if (!rule)
 		return -EINVAL;
 
-	err = mlxsw_sp_acl_rule_get_stats(mlxsw_sp, rule, &bytes, &packets,
+	err = mlxsw_sp_acl_rule_get_stats(mlxsw_sp, rule, &packets, &bytes,
 					  &lastuse);
 	if (err)
 		goto err_rule_get_stats;
-- 
2.11.0
