From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH] net: stmmac: use netif_set_real_num_{rx,tx}_queues
Date: Mon, 10 Apr 2017 11:32:14 +0100
Message-ID: <f0359c3d65fbb3f5220c23fc2833c4a094bec4a5.1491819975.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>,
        Arnd Bergmann <arnd@arndb.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:33117 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752750AbdDJKcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 06:32:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the submission of the lastest multiple buffer patch set, this fix was lost.
I am sending this patch to put it right again. The fix was originally proposed
by Arnd Bergmann.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a89f76b..85f315e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -4103,8 +4103,8 @@ int stmmac_dvr_probe(struct device *device,
 		goto error_hw_init;
 
 	/* Configure real RX and TX queues */
-	ndev->real_num_rx_queues = priv->plat->rx_queues_to_use;
-	ndev->real_num_tx_queues = priv->plat->tx_queues_to_use;
+	netif_set_real_num_rx_queues(ndev, priv->plat->rx_queues_to_use);
+	netif_set_real_num_tx_queues(ndev, priv->plat->tx_queues_to_use);
 
 	ndev->netdev_ops = &stmmac_netdev_ops;
 
-- 
2.9.3
