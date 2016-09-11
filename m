From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] drivers: net: phy: xgene: Fix 'remove' function
Date: Sun, 11 Sep 2016 21:43:34 +0200
Message-ID: <1473623014-7801-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: isubramanian@apm.com, kchudgar@apm.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp01.smtpout.orange.fr ([80.12.242.123]:37083 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756310AbcIKTno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 15:43:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If 'IS_ERR(pdata->clk)' is true, then 'clk_disable_unprepare(pdata->clk)'
will do nothing.

It is likely that 'if (!IS_ERR(pdata->clk))' was expected here.
In fact, the test can even be removed because 'clk_disable_unprepare'
already handles such cases.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/phy/mdio-xgene.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio-xgene.c b/drivers/net/phy/mdio-xgene.c
index 775674808249..92af182951be 100644
--- a/drivers/net/phy/mdio-xgene.c
+++ b/drivers/net/phy/mdio-xgene.c
@@ -424,10 +424,8 @@ static int xgene_mdio_remove(struct platform_device *pdev)
 	mdiobus_unregister(mdio_bus);
 	mdiobus_free(mdio_bus);
 
-	if (dev->of_node) {
-		if (IS_ERR(pdata->clk))
-			clk_disable_unprepare(pdata->clk);
-	}
+	if (dev->of_node)
+		clk_disable_unprepare(pdata->clk);
 
 	return 0;
 }
-- 
2.7.4
