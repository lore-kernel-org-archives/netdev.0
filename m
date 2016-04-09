From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] qlge: Replace create_singlethread_workqueue with
 alloc_ordered_workqueue
Date: Sat, 9 Apr 2016 17:27:45 +0530
Message-ID: <20160409115744.GA30104@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tj@kernel.org
To: harish.patil@qlogic.com, sudarsana.kalluru@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace deprecated create_singlethread_workqueue with
alloc_ordered_workqueue.

Work items include getting tx/rx frame sizes, resetting MPI processor,
setting asic recovery bit so ordering seems necessary as only one work
item should be in queue/executing at any given time, hence the use of
alloc_ordered_workqueue.

WQ_MEM_RECLAIM flag has been set since ethernet devices seem to sit in
memory reclaim path, so to guarantee forward progress regardless of 
memory pressure.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Acked-by: Tejun Heo <tj@kernel.org>
---
Not sure if the assumption of requiring ordering of work items
is correct.

 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index b28e73e..83d7210 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4687,7 +4687,7 @@ static int ql_init_device(struct pci_dev *pdev, struct net_device *ndev,
 	/*
 	 * Set up the operating parameters.
 	 */
-	qdev->workqueue = create_singlethread_workqueue(ndev->name);
+	qdev->workqueue = alloc_ordered_workqueue(ndev->name, WQ_MEM_RECLAIM);
 	INIT_DELAYED_WORK(&qdev->asic_reset_work, ql_asic_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
-- 
1.9.1
