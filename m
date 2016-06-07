From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] mlxsw: core: Remove deprecated create_workqueue
Date: Wed, 8 Jun 2016 01:29:46 +0530
Message-ID: <20160607195946.GA11743@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_workqueue replaces deprecated create_workqueue().

A dedicated workqueue has been used since the workqueue
mlxsw_wq is used for FDB notif. processing with workitems that are
involved in normal device operation && because it's a network device
which can be depended upon during memory reclaim.

Workitems &trans->timeout_dw and &mlxsw_sp->fdb_notify.dw,
map to mlxsw_sp_fdb_notify_work (processes FDB notifications from the
underlying device and resolves the netdev to which the entry points to
and notifies the bridge using the switchdev notifier) and
mlxsw_emad_trans_timeout_work (provides async EMAD register access)
respectively. They require forward progress under memory pressure and
hence, WQ_MEM_RECLAIM has been set.

Since there are only a fixed number of work items, explicit concurrency
limit is unnecessary here.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index b0a0b01..01ae548 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1736,7 +1736,7 @@ static int __init mlxsw_core_module_init(void)
 {
 	int err;

-	mlxsw_wq = create_workqueue(mlxsw_core_driver_name);
+	mlxsw_wq = alloc_workqueue(mlxsw_core_driver_name, WQ_MEM_RECLAIM, 0);
 	if (!mlxsw_wq)
 		return -ENOMEM;
 	mlxsw_core_dbg_root = debugfs_create_dir(mlxsw_core_driver_name, NULL);
