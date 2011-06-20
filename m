From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/2] pxa168_eth: fix race in transmit path.
Date: Mon, 20 Jun 2011 09:48:06 +0200
Message-ID: <180237f9f567de29068e51b1442629509bb03e43.1308555865.git.richard.cochran@omicron.at>
References: <cover.1308555865.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, stable@kernel.org,
	Sachin Sanap <ssanap@marvell.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41474 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab1FTHsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:48:05 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so759177fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:48:04 -0700 (PDT)
In-Reply-To: <cover.1308555865.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308555865.git.richard.cochran@omicron.at>
References: <cover.1308555865.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the socket buffer is freed in the completion interrupt, it is not
safe to access it after submitting it to the hardware.

Cc: stable@kernel.org
Cc: Sachin Sanap <ssanap@marvell.com>
Cc: Zhangfei Gao <zgao6@marvell.com>
Cc: Philip Rakity <prakity@marvell.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/pxa168_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 89f7540..5f597ca 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1273,7 +1273,7 @@ static int pxa168_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	wmb();
 	wrl(pep, SDMA_CMD, SDMA_CMD_TXDH | SDMA_CMD_ERD);
 
-	stats->tx_bytes += skb->len;
+	stats->tx_bytes += length;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 	if (pep->tx_ring_size - pep->tx_desc_count <= 1) {
-- 
1.7.0.4

