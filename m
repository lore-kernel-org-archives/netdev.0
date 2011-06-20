From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 06/11] macb: enable transmit time stamping.
Date: Mon, 20 Jun 2011 09:51:28 +0200
Message-ID: <d8594c4c04ad91e27fb676d90a9dde2e12ad3aac.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40854 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764Ab1FTHvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:51:50 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so760782fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:51:49 -0700 (PDT)
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
Compile tested only.

Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/macb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 6c6a028..fab63bf 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -669,6 +669,8 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	entry = NEXT_TX(entry);
 	bp->tx_head = entry;
 
+	skb_tx_timestamp(skb);
+
 	macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(TSTART));
 
 	if (TX_BUFFS_AVAIL(bp) < 1)
-- 
1.7.0.4

