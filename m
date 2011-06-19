From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 09/11] pxa168_eth: enable transmit time stamping.
Date: Sun, 19 Jun 2011 19:57:02 +0200
Message-ID: <39880a7ab3dc284822de91049f1ce1a05d061dab.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sachin Sanap <ssanap@marvell.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58291 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509Ab1FSR53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 13:57:29 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so546578fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 10:57:28 -0700 (PDT)
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
Compile tested only.

Cc: Sachin Sanap <ssanap@marvell.com>
Cc: Zhangfei Gao <zgao6@marvell.com>
Cc: Philip Rakity <prakity@marvell.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/pxa168_eth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 89f7540..e224740 100644
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

