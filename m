From: =?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>
Subject: [PATCH] mlxsw: spectrum_router: Fix use after free
Date: Sun, 14 Aug 2016 15:38:29 +0200
Message-ID: <1471181909-22187-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In mlxsw_sp_router_fib4_add_info_destroy(), the fib_entry pointer is used
after it has been freed by mlxsw_sp_fib_entry_destroy(). Use a temporary
variable to fix this.

Fixes: 61c503f976b5449e ("mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops")
Signed-off-by: Vincent Stehlé <vincent.stehle@laposte.net>
Cc: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 81418d6..90bb93b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1651,9 +1651,10 @@ static void mlxsw_sp_router_fib4_add_info_destroy(void const *data)
 	const struct mlxsw_sp_router_fib4_add_info *info = data;
 	struct mlxsw_sp_fib_entry *fib_entry = info->fib_entry;
 	struct mlxsw_sp *mlxsw_sp = info->mlxsw_sp;
+	struct mlxsw_sp_vr *vr = fib_entry->vr;
 
 	mlxsw_sp_fib_entry_destroy(fib_entry);
-	mlxsw_sp_vr_put(mlxsw_sp, fib_entry->vr);
+	mlxsw_sp_vr_put(mlxsw_sp, vr);
 	kfree(info);
 }
 
-- 
2.8.1
