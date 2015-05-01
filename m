From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #3 7/8] via-rhine: dma_wmb transmit barrier.
Date: Fri,  1 May 2015 22:14:44 +0200
Message-ID: <93280ce9b75e6837d3690354fc05441a2f93d27e.1430509434.git.romieu@fr.zoreil.com>
References: <cover.1430509434.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>, Nix <nix@esperi.org.uk>,
	Roger.Luethi.rl@hellgate.ch,
	Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51000 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbbEAUPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 16:15:12 -0400
In-Reply-To: <cover.1430509434.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1430509434.git.romieu@fr.zoreil.com>
References: <cover.1430509434.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow the now usual transmit descriptor update path:
1. content change
2. dma_wmb
3. ownership change

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 8195fcd..86ca8b2 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1849,7 +1849,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 
 	netdev_sent_queue(dev, skb->len);
 	/* lock eth irq */
-	wmb();
+	dma_wmb();
 	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
 	wmb();
 
-- 
Ueimor
