From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] dwc_eth_qos: Remove deprecated create_singlethread_workqueue
Date: Sat, 16 Jul 2016 13:53:28 +0530
Message-ID: <20160716082328.GA7254@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35345 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbcGPIXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 04:23:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_workqueue replaces deprecated create_singlethread_workqueue().

A dedicated workqueue has been used since the workitem viz
lp->txtimeout_reinit is involved in reinitialization if a TX timeout
occurs, which is necessary to guarantee forward progress in packet
processing. As a network device can be used during memory reclaim, the
workqueue needs forward progress guarantee under memory pressure.
WQ_MEM_RECLAIM has been set to ensure this.

Since there is only a single work item, explicit concurrency limit is
unnecessary here.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 158213c..44c4cd6 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2934,7 +2934,8 @@ static int dwceqos_probe(struct platform_device *pdev)
 		     (unsigned long)ndev);
 	tasklet_disable(&lp->tx_bdreclaim_tasklet);

-	lp->txtimeout_handler_wq = create_singlethread_workqueue(DRIVER_NAME);
+	lp->txtimeout_handler_wq = alloc_workqueue(DRIVER_NAME,
+						   WQ_MEM_RECLAIM, 0);
 	INIT_WORK(&lp->txtimeout_reinit, dwceqos_reinit_for_txtimeout);

 	platform_set_drvdata(pdev, ndev);
