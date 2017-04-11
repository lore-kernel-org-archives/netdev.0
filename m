From: Fugang Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 3/6] net: fec: pass ->dev to dma_alloc__coherent() API
Date: Tue, 11 Apr 2017 19:13:05 +0800
Message-ID: <1491909188-8971-4-git-send-email-fugang.duan@nxp.com>
References: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
        <stephen@networkplumber.org>, <fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0041.outbound.protection.outlook.com ([104.47.33.41]:61643
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754637AbdDKLPe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:15:34 -0400
In-Reply-To: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In aarch64 system, it requires to trasfer ->dev to dma_alloc_coherent()
API, otherwise allocate failed and print kernel warning.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 172624c..bcf8675 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2651,7 +2651,7 @@ static void fec_enet_free_queue(struct net_device *ndev)
 	for (i = 0; i < fep->num_tx_queues; i++)
 		if (fep->tx_queue[i] && fep->tx_queue[i]->tso_hdrs) {
 			txq = fep->tx_queue[i];
-			dma_free_coherent(NULL,
+			dma_free_coherent(&fep->pdev->dev,
 					  txq->bd.ring_size * TSO_HEADER_SIZE,
 					  txq->tso_hdrs,
 					  txq->tso_hdrs_dma);
@@ -2685,7 +2685,7 @@ static int fec_enet_alloc_queue(struct net_device *ndev)
 		txq->tx_wake_threshold =
 			(txq->bd.ring_size - txq->tx_stop_threshold) / 2;
 
-		txq->tso_hdrs = dma_alloc_coherent(NULL,
+		txq->tso_hdrs = dma_alloc_coherent(&fep->pdev->dev,
 					txq->bd.ring_size * TSO_HEADER_SIZE,
 					&txq->tso_hdrs_dma,
 					GFP_KERNEL);
-- 
1.9.1
