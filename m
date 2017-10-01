From: Colin King <colin.king@canonical.com>
Subject: [PATCH][next] mlxsw: spectrum: fix uninitialized value in err
Date: Sun,  1 Oct 2017 17:27:35 +0100
Message-ID: <20171001162735.8091-1-colin.king@canonical.com>
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

In the unlikely event that mfc->mfc_un.res.ttls[i] is 255 for all
values of i from 0 to MAXIVS-1, the err is not set at all and hence
has a garbage value on the error return at the end of the function,
so initialize it to 0.  Also, the error return check on err and goto
to err: inside the for loop makes it impossible for err to be zero
at the end of the for loop, so we can remove the redundant err check
at the end of the loop.

Detected by CoverityScan CID#1457207 ("Unitialized scalar value")

Fixes: c011ec1bbfd6 ("mlxsw: spectrum: Add the multicast routing offloading logic")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
index 09120259a45d..4aaf6ca1be7c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
@@ -349,7 +349,7 @@ mlxsw_sp_mr_route4_create(struct mlxsw_sp_mr_table *mr_table,
 {
 	struct mlxsw_sp_mr_route_vif_entry *rve, *tmp;
 	struct mlxsw_sp_mr_route *mr_route;
-	int err;
+	int err = 0;
 	int i;
 
 	/* Allocate and init a new route and fill it with parameters */
@@ -376,8 +376,6 @@ mlxsw_sp_mr_route4_create(struct mlxsw_sp_mr_table *mr_table,
 		}
 	}
 	mlxsw_sp_mr_route_ivif_link(mr_route, &mr_table->vifs[mfc->mfc_parent]);
-	if (err)
-		goto err;
 
 	mr_route->route_action = mlxsw_sp_mr_route_action(mr_route);
 	return mr_route;
-- 
2.14.1
