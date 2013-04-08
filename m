From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 5/5] stmmac: prefetch all dma_erx when use extend_desc
Date: Mon,  8 Apr 2013 14:10:03 +0200
Message-ID: <1365423003-23959-6-git-send-email-peppe.cavallaro@st.com>
References: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shiraz.hashim@st.com, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:42000 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935417Ab3DHMKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 08:10:39 -0400
In-Reply-To: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to prefetch, in the stmmac_rx, the whole
dma_erx descriptor in case of using the extended descriptors.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5d336e7..384fc90 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2004,7 +2004,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 #endif
 	while (count < limit) {
 		int status;
-		struct dma_desc *p, *p_next;
+		struct dma_desc *p;
 
 		if (priv->extend_desc)
 			p = (struct dma_desc *)(priv->dma_erx + entry);
@@ -2018,12 +2018,9 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 		next_entry = (++priv->cur_rx) % rxsize;
 		if (priv->extend_desc)
-			p_next = (struct dma_desc *)(priv->dma_erx +
-						     next_entry);
+			prefetch(priv->dma_erx + next_entry);
 		else
-			p_next = priv->dma_rx + next_entry;
-
-		prefetch(p_next);
+			prefetch(priv->dma_rx + next_entry);
 
 		/* read the status of the incoming frame */
 		status = priv->hw->desc->rx_status(&priv->dev->stats,
-- 
1.7.4.4
