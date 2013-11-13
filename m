From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] net: ethernet: ti/cpsw: do not crash on single-MAC machines during resume
Date: Wed, 13 Nov 2013 13:53:00 +0100
Message-ID: <1384347180-3490-1-git-send-email-zonque@gmail.com>
Cc: mugunthanvnm@ti.com, davem@davemloft.net,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:59125 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699Ab3KMMxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 07:53:08 -0500
Received: by mail-bk0-f44.google.com with SMTP id d7so317799bkh.31
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 04:53:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent Oopses, cpsw_suspend() should only soft-reset sliver 1
on dual MAC enabled machines.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index edd3e79..702b063 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2173,8 +2173,11 @@ static int cpsw_suspend(struct device *dev)
 
 	if (netif_running(ndev))
 		cpsw_ndo_stop(ndev);
+
 	soft_reset("sliver 0", &priv->slaves[0].sliver->soft_reset);
-	soft_reset("sliver 1", &priv->slaves[1].sliver->soft_reset);
+	if (priv->data.dual_emac)
+		soft_reset("sliver 1", &priv->slaves[1].sliver->soft_reset);
+
 	pm_runtime_put_sync(&pdev->dev);
 
 	/* Select sleep pin state */
-- 
1.8.4.2
