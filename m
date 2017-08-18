From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] mlx5: ensure 0 is returned when vport is zero
Date: Fri, 18 Aug 2017 16:25:50 +0100
Message-ID: <20170818152550.18358-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Currently, if vport is zero then then an uninialized return status
in err is returned.  Since the only return status at the end of the
function esw_add_uc_addr is zero for the current set of return paths
we may as well just return 0 rather than err to fix this issue.

Detected by CoverityScan, CID#1452698 ("Uninitialized scalar variable")

Fixes: eeb66cdb6826 ("net/mlx5: Separate between E-Switch and MPFS")
Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
