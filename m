From: akpm@linux-foundation.org
Subject: [patch 3/3] drivers/net/smc911x.c: smc911x_drv_probe() cleanup
Date: Mon, 01 Dec 2008 14:24:46 -0800
Message-ID: <200812012224.mB1MOl2J015252@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	catalin.marinas@arm.com, romit@ti.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52239 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751922AbYLAWZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 17:25:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

Save an ugly ifdef.

Cc: "Dasgupta, Romit" <romit@ti.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Romit Dasgupta <romit@ti.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc911x.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff -puN drivers/net/smc911x.c~netdev-smc911x-fix-for-driver-resume-cleanup drivers/net/smc911x.c
--- a/drivers/net/smc911x.c~netdev-smc911x-fix-for-driver-resume-cleanup
+++ a/drivers/net/smc911x.c
@@ -2050,9 +2050,6 @@ err_out:
  */
 static int __devinit smc911x_drv_probe(struct platform_device *pdev)
 {
-#ifdef SMC_DYNAMIC_BUS_CONFIG
-	struct smc911x_platdata *pd = pdev->dev.platform_data;
-#endif
 	struct net_device *ndev;
 	struct resource *res;
 	struct smc911x_local *lp;
@@ -2087,11 +2084,14 @@ static int __devinit smc911x_drv_probe(s
 	lp = netdev_priv(ndev);
 	lp->netdev = ndev;
 #ifdef SMC_DYNAMIC_BUS_CONFIG
-	if (!pd) {
-		ret = -EINVAL;
-		goto release_both;
+	{
+		struct smc911x_platdata *pd = pdev->dev.platform_data;
+		if (!pd) {
+			ret = -EINVAL;
+			goto release_both;
+		}
+		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
 	}
-	memcpy(&lp->cfg, pd, sizeof(lp->cfg));
 #endif
 
 	addr = ioremap(res->start, SMC911X_IO_EXTENT);
_
