From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mlx5: ensure 0 is returned when vport is zero
Date: Fri, 18 Aug 2017 14:49:25 +0100
Message-ID: <20170818134925.16604-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Currently, if vport is zero then then an uninialized return status
in err is returned.  Since the only return status at the end of the
function esw_add_uc_addr is zero for the current set of return paths
we may as well just return 0 rather than err to fix this issue.

Detected by CoverityScan, CID#1452698 ("Uninitialized scalar variable")

Fixes: eeb66cdb6826 ("net/mlx5: Separate between E-Switch and MPFS")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 6d9fb6ac6e9b..c77f4c0c7769 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -401,7 +401,7 @@ static int esw_add_uc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
 	esw_debug(esw->dev, "\tADDED UC MAC: vport[%d] %pM fr(%p)\n",
 		  vport, mac, vaddr->flow_rule);
 
-	return err;
+	return 0;
 }
 
 static int esw_del_uc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
-- 
2.11.0
