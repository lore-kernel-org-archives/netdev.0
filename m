From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: fix cpsw clock gating issue across suspend/resume
Date: Tue, 18 Jun 2013 15:04:35 +0530
Message-ID: <1371548076-22035-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:53523 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480Ab3FRJdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 05:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to some hardware integration issue, CPSW sliver modules requires a
reset across suspend/resume cycle for a successful clock gating to
CPGMAC (CPSW and Davinci MDIO) in AM335x PG1.0.
This issue is fixed in PG2.x, though to support suspend/resume on PG1.0
this reset is required.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 2fd69db..e66a202 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1976,6 +1976,8 @@ static int cpsw_suspend(struct device *dev)
 
 	if (netif_running(ndev))
 		cpsw_ndo_stop(ndev);
+	soft_reset("sliver 0", &priv->slaves[0].sliver->soft_reset);
+	soft_reset("sliver 1", &priv->slaves[1].sliver->soft_reset);
 	pm_runtime_put_sync(&pdev->dev);
 
 	return 0;
-- 
1.7.9.5
