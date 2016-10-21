From: <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 7/7] qede: Fix incorrrect usage of APIs for un-mapping DMA memory
Date: Fri, 21 Oct 2016 04:43:45 -0400
Message-ID: <1477039425-31341-8-git-send-email-sudarsana.kalluru@cavium.com>
References: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@cavium.com>,
        <Yuval.Mintz@cavium.com>, <manish.chopra@cavium.com>,
        Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49047 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934495AbcJUJaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 05:30:02 -0400
In-Reply-To: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

Driver uses incorrect APIs to unmap DMA memory which were
mapped using dma_map_single(). This patch fixes it to use
appropriate APIs for un-mapping DMA memory.

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 4 ++--
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index d47bdaa..12251a1 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -1199,8 +1199,8 @@ static int qede_selftest_transmit_traffic(struct qede_dev *edev,
 	}
 
 	first_bd = (struct eth_tx_1st_bd *)qed_chain_consume(&txq->tx_pbl);
-	dma_unmap_page(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
-		       BD_UNMAP_LEN(first_bd), DMA_TO_DEVICE);
+	dma_unmap_single(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
+			 BD_UNMAP_LEN(first_bd), DMA_TO_DEVICE);
 	txq->sw_tx_cons++;
 	txq->sw_tx_ring[idx].skb = NULL;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index da8ef69..444b271 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -313,8 +313,8 @@ static int qede_free_tx_pkt(struct qede_dev *edev,
 		split_bd_len = BD_UNMAP_LEN(split);
 		bds_consumed++;
 	}
-	dma_unmap_page(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
-		       BD_UNMAP_LEN(first_bd) + split_bd_len, DMA_TO_DEVICE);
+	dma_unmap_single(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
+			 BD_UNMAP_LEN(first_bd) + split_bd_len, DMA_TO_DEVICE);
 
 	/* Unmap the data of the skb frags */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++, bds_consumed++) {
@@ -359,8 +359,8 @@ static void qede_free_failed_tx_pkt(struct qede_dev *edev,
 		nbd--;
 	}
 
-	dma_unmap_page(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
-		       BD_UNMAP_LEN(first_bd) + split_bd_len, DMA_TO_DEVICE);
+	dma_unmap_single(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
+			 BD_UNMAP_LEN(first_bd) + split_bd_len, DMA_TO_DEVICE);
 
 	/* Unmap the data of the skb frags */
 	for (i = 0; i < nbd; i++) {
-- 
1.8.3.1
