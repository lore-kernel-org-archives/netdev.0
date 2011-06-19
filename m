From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 4/7] r6040: fix race in transmit time stamping.
Date: Sun, 19 Jun 2011 15:31:42 +0200
Message-ID: <9e41f2b592070feccdf5300d34ac21fde5085ba2.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55555 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877Ab1FSNcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 09:32:05 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so477619fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 06:32:04 -0700 (PDT)
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/r6040.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 5ee5f8f..00f06e9 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -836,6 +836,9 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 	descptr->buf = cpu_to_le32(pci_map_single(lp->pdev,
 		skb->data, skb->len, PCI_DMA_TODEVICE));
 	descptr->status = DSC_OWNER_MAC;
+
+	skb_tx_timestamp(skb);
+
 	/* Trigger the MAC to check the TX descriptor */
 	iowrite16(0x01, ioaddr + MTPR);
 	lp->tx_insert_ptr = descptr->vndescp;
@@ -846,8 +849,6 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	skb_tx_timestamp(skb);
-
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.0.4

