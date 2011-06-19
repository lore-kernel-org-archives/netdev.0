From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 06/11] macb: enable transmit time stamping.
Date: Sun, 19 Jun 2011 19:56:59 +0200
Message-ID: <3ca7dbb040dca718efcbab6e2d8d76e656698ed8.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49063 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416Ab1FSR5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 13:57:18 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so1751766bwz.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 10:57:17 -0700 (PDT)
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
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

