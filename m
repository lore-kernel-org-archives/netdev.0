From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: fix compilation error with cpsw driver
Date: Fri, 21 Jun 2013 19:15:09 +0530
Message-ID: <1371822309-13704-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39708 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161361Ab3FUNno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 09:43:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/ethernet/ti/cpsw.c: In function 'cpsw_suspend':
drivers/net/ethernet/ti/cpsw.c:1979:26: error: 'priv' undeclared (first use in this function)
drivers/net/ethernet/ti/cpsw.c:1979:26: note: each undeclared identifier is reported only once for each function it appears in
make[4]: *** [drivers/net/ethernet/ti/cpsw.o] Error 1

The compilation error was introduced by the following commit
6d3d76f (drivers: net: cpsw: fix cpsw clock gating issue across suspend/resume)

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e66a202..d1a769f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1973,6 +1973,7 @@ static int cpsw_suspend(struct device *dev)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
+	struct cpsw_priv	*priv = netdev_priv(ndev);
 
 	if (netif_running(ndev))
 		cpsw_ndo_stop(ndev);
-- 
1.7.9.5
