From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] net/mlx5_core/pagealloc: Remove deprecated
 create_singlethread_workqueue
Date: Thu, 28 Jul 2016 13:49:49 +0530
Message-ID: <20160728081949.GA5561@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>
To: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A dedicated workqueue has been used since the work items are being used
on a memory reclaim path. WQ_MEM_RECLAIM has been set to guarantee forward
progress under memory pressure.

The workqueue has a single work item. Hence, alloc_workqueue() is used
instead of alloc_ordered_workqueue() since ordering is unnecessary when
there's only one work item.

Explicit concurrency limit is unnecessary here since there are only a
fixed number of work items.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index 9eeee05..7c85262 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -552,7 +552,8 @@ void mlx5_pagealloc_cleanup(struct mlx5_core_dev *dev)

 int mlx5_pagealloc_start(struct mlx5_core_dev *dev)
 {
-	dev->priv.pg_wq = create_singlethread_workqueue("mlx5_page_allocator");
+	dev->priv.pg_wq = alloc_workqueue("mlx5_page_allocator",
+					  WQ_MEM_RECLAIM, 0);
 	if (!dev->priv.pg_wq)
 		return -ENOMEM;

--
2.1.4
