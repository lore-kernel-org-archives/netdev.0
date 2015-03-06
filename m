From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 2/3] net: bcmgenet: adjust the call to alloc_etherdev_mqs()
Date: Thu,  5 Mar 2015 17:40:12 -0800 (PST)
Message-ID: <20150306014012.DF4D72214B6@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:34099 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbCFBkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 20:40:14 -0500
Received: by padet14 with SMTP id et14so9356033pad.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 17:40:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting multiple Rx queues, adjust the call to
alloc_etherdev_mqs() to allow max GENET_MAX_MQ_CNT + 1 Rx queues.

The actual number of Rx queues in use is correctly adjusted with:
netif_set_real_num_rx_queues(priv->dev, priv->hw_params->rx_queues + 1);

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f56553b..57271f7 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2668,8 +2668,9 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	struct resource *r;
 	int err = -EIO;
 
-	/* Up to GENET_MAX_MQ_CNT + 1 TX queues and a single RX queue */
-	dev = alloc_etherdev_mqs(sizeof(*priv), GENET_MAX_MQ_CNT + 1, 1);
+	/* Up to GENET_MAX_MQ_CNT + 1 TX queues and RX queues */
+	dev = alloc_etherdev_mqs(sizeof(*priv), GENET_MAX_MQ_CNT + 1,
+				 GENET_MAX_MQ_CNT + 1);
 	if (!dev) {
 		dev_err(&pdev->dev, "can't allocate net device\n");
 		return -ENOMEM;
-- 
2.2.0.rc0.207.ga3a616c
