From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 6/7] smsc9420: fix race in transmit time stamping.
Date: Sun, 19 Jun 2011 15:31:44 +0200
Message-ID: <8c48b912d467657cd5bd338042d68a9715623cf6.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55555 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab1FSNcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 09:32:17 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so477619fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 06:32:16 -0700 (PDT)
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/smsc9420.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 2d84f92..ae4d60a 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1030,12 +1030,12 @@ static netdev_tx_t smsc9420_hard_start_xmit(struct sk_buff *skb,
 	pd->tx_ring[index].status = TDES0_OWN_;
 	wmb();
 
+	skb_tx_timestamp(skb);
+
 	/* kick the DMA */
 	smsc9420_reg_write(pd, TX_POLL_DEMAND, 1);
 	smsc9420_pci_flush_write(pd);
 
-	skb_tx_timestamp(skb);
-
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.0.4

