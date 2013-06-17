From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net: cpsw: check for cpts pointer after its allocation
Date: Mon, 17 Jun 2013 19:31:52 +0200
Message-ID: <1371490312-27905-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:43616 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910Ab3FQRb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 13:31:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

after priv->cpts got allocated then this pointer should check to determine
if the allocation succeeded or not.

Cc: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5143552..cc5358a 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1682,7 +1682,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	priv->rx_packet_max = max(rx_packet_max, 128);
 	priv->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL);
 	priv->irq_enabled = true;
-	if (!ndev) {
+	if (!priv->cpts) {
 		pr_err("error allocating cpts\n");
 		goto clean_ndev_ret;
 	}
-- 
1.8.3.1
