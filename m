From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] can: mcp251x: Replace create_freezable_workqueue with
 alloc_workqueue
Date: Fri, 8 Apr 2016 21:02:10 +0530
Message-ID: <20160408153210.GA15068@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tj@kernel.org
To: wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace scheduled to be removed create_freezable_workqueue with
alloc_workqueue.

priv->wq should be explicitly set as freezable to ensure it is frozen
in the suspend sequence and work items are drained so that no new work
item starts execution until thawed. Thus, use of WQ_FREEZABLE flag
here is required.

WQ_MEM_RECLAIM flag has been set here to ensure forward progress
regardless of memory pressure.

The order of execution is not important so set @max_active as 0.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Acked-by: Tejun Heo <tj@kernel.org>
---
 drivers/net/can/spi/mcp251x.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/spi/mcp251x.c b/drivers/net/can/spi/mcp251x.c
index 74a7dfe..cf36d26 100644
--- a/drivers/net/can/spi/mcp251x.c
+++ b/drivers/net/can/spi/mcp251x.c
@@ -961,7 +961,8 @@ static int mcp251x_open(struct net_device *net)
 		goto open_unlock;
 	}
 
-	priv->wq = create_freezable_workqueue("mcp251x_wq");
+	priv->wq = alloc_workqueue("mcp251x_wq", WQ_FREEZABLE | WQ_MEM_RECLAIM,
+				   0);
 	INIT_WORK(&priv->tx_work, mcp251x_tx_work_handler);
 	INIT_WORK(&priv->restart_work, mcp251x_restart_work_handler);
 
-- 
1.9.1
