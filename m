From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] mlxsw: spectrum: mark symbols static where possible
Date: Sun, 18 Sep 2016 16:39:47 +0800
Message-ID: <1474187987-12958-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: jiri@mellanox.com, idosch@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 3 warnings when building kernel with W=1:
drivers/net/ethernet/mellanox/mlxsw/spectrum.c:251:29: warning: no previous prototype for 'mlxsw_sp_span_entry_find' [-Wmissing-prototypes]
drivers/net/ethernet/mellanox/mlxsw/spectrum.c:265:29: warning: no previous prototype for 'mlxsw_sp_span_entry_get' [-Wmissing-prototypes]
drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:1749:6: warning: no previous prototype for 'mlxsw_sp_fib_entry_put' [-Wmissing-prototypes]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c        | 6 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 4 ++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1162e04..e680193 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -248,7 +248,8 @@ static void mlxsw_sp_span_entry_destroy(struct mlxsw_sp *mlxsw_sp,
 	span_entry->used = false;
 }
 
-struct mlxsw_sp_span_entry *mlxsw_sp_span_entry_find(struct mlxsw_sp_port *port)
+static struct
+mlxsw_sp_span_entry *mlxsw_sp_span_entry_find(struct mlxsw_sp_port *port)
 {
 	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
 	int i;
@@ -262,7 +263,8 @@ struct mlxsw_sp_span_entry *mlxsw_sp_span_entry_find(struct mlxsw_sp_port *port)
 	return NULL;
 }
 
-struct mlxsw_sp_span_entry *mlxsw_sp_span_entry_get(struct mlxsw_sp_port *port)
+static struct
+mlxsw_sp_span_entry *mlxsw_sp_span_entry_get(struct mlxsw_sp_port *port)
 {
 	struct mlxsw_sp_span_entry *span_entry;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 352259b..82cdeba 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1746,8 +1746,8 @@ mlxsw_sp_fib_entry_find(struct mlxsw_sp *mlxsw_sp,
 					 fib4->fi->fib_dev);
 }
 
-void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
-			    struct mlxsw_sp_fib_entry *fib_entry)
+static void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct mlxsw_sp_vr *vr = fib_entry->vr;
 
-- 
2.7.4
