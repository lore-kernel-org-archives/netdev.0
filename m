From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH] net: mvneta: remove useless RX descriptor prefetch
Date: Thu, 31 Mar 2016 14:36:30 +0800
Message-ID: <1459406190-2334-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>,
	<gregory.clement@free-electrons.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:21515 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752674AbcCaGk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 02:40:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rx descriptors are allocated using dma_alloc_coherent, so prefetch
doesn't really happen at all.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 5880871..6c09a27 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -757,7 +757,6 @@ mvneta_rxq_next_desc_get(struct mvneta_rx_queue *rxq)
 	int rx_desc = rxq->next_desc_to_proc;
 
 	rxq->next_desc_to_proc = MVNETA_QUEUE_NEXT_DESC(rxq, rx_desc);
-	prefetch(rxq->descs + rxq->next_desc_to_proc);
 	return rxq->descs + rx_desc;
 }
 
-- 
2.8.0.rc3
