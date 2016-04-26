From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] pch_gbe: fix bogus trylock conversion
Date: Tue, 26 Apr 2016 23:14:30 +0200
Message-ID: <1461705270-29849-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36477 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751980AbcDZVOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:14:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should have converted 'if (trylock)' to 'lock'.

Fixes: a6086a893718db ("drivers: net: remove NETDEV_TX_LOCKED")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 I re-checked the series and this was the only place where I messed up.

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 4475dcc..ca4add7 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2137,7 +2137,7 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
 	unsigned long flags;
 
-	spin_trylock_irqsave(&tx_ring->tx_lock, flags);
+	spin_lock_irqsave(&tx_ring->tx_lock, flags);
 
 	if (unlikely(!PCH_GBE_DESC_UNUSED(tx_ring))) {
 		netif_stop_queue(netdev);
-- 
2.7.3
