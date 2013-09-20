From: Malahal Naineni <malahal@us.ibm.com>
Subject: [PATCH v2] qlge: call ql_core_dump() only if dump memory was allocated.
Date: Fri, 20 Sep 2013 16:21:17 -0500
Message-ID: <1379712077-31750-1-git-send-email-malahal@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:59483 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027Ab3ITVV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 17:21:26 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 20 Sep 2013 17:21:25 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C8A4438C803B
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 17:21:21 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8KLLMXN54460596
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 21:21:22 GMT
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8KLLLrF021904
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 18:21:21 -0300
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r8KLLI8x021636
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 18:21:18 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also changed a log message to indicate that memory was not allocated
instead of memory not available!

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c | 4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_mpi.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
index 10093f0..6bc5db7 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
@@ -740,8 +740,8 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	int i;
 
 	if (!mpi_coredump) {
-		netif_err(qdev, drv, qdev->ndev, "No memory available\n");
-		return -ENOMEM;
+		netif_err(qdev, drv, qdev->ndev, "No memory allocated\n");
+		return -EINVAL;
 	}
 
 	/* Try to get the spinlock, but dont worry if
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
index ff2bf8a..7ad1460 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
@@ -1274,7 +1274,7 @@ void ql_mpi_reset_work(struct work_struct *work)
 		return;
 	}
 
-	if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
+	if (qdev->mpi_coredump && !ql_core_dump(qdev, qdev->mpi_coredump)) {
 		netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
 		qdev->core_is_dumped = 1;
 		queue_delayed_work(qdev->workqueue,
-- 
1.7.11.7
