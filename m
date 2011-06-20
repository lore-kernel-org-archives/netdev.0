From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 09/11] pxa168_eth: enable transmit time stamping.
Date: Mon, 20 Jun 2011 09:51:31 +0200
Message-ID: <5a4bc27e32d3f10685e2e3c54aa610a7cb9a68fb.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sachin Sanap <ssanap@marvell.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>,
	Mark Brown <markb@marvell.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40854 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675Ab1FTHwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:52:00 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so760782fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:51:59 -0700 (PDT)
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
Compile tested only.

Cc: Sachin Sanap <ssanap@marvell.com>
Cc: Zhangfei Gao <zgao6@marvell.com>
Cc: Philip Rakity <prakity@marvell.com>
Cc: Mark Brown <markb@marvell.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/pxa168_eth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 5f597ca..1f97db1 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1267,6 +1267,9 @@ static int pxa168_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	pep->tx_skb[tx_index] = skb;
 	desc->byte_cnt = length;
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
+
+	skb_tx_timestamp(skb);
+
 	wmb();
 	desc->cmd_sts = BUF_OWNED_BY_DMA | TX_GEN_CRC | TX_FIRST_DESC |
 			TX_ZERO_PADDING | TX_LAST_DESC | TX_EN_INT;
-- 
1.7.0.4

