From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] qlge: avoid format string exposure in workqueue
Date: Wed, 5 Apr 2017 14:39:03 -0700
Message-ID: <20170405213903.GA4505@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33237 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934004AbdDEVjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 17:39:06 -0400
Received: by mail-pg0-f44.google.com with SMTP id x125so16258727pgb.0
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 14:39:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While unlikely, this makes sure the workqueue name won't be processed
as a format string.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index e9e647072596..1188d420fe53 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4686,7 +4686,8 @@ static int ql_init_device(struct pci_dev *pdev, struct net_device *ndev,
 	/*
 	 * Set up the operating parameters.
 	 */
-	qdev->workqueue = alloc_ordered_workqueue(ndev->name, WQ_MEM_RECLAIM);
+	qdev->workqueue = alloc_ordered_workqueue("%s", WQ_MEM_RECLAIM,
+						  ndev->name);
 	INIT_DELAYED_WORK(&qdev->asic_reset_work, ql_asic_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
