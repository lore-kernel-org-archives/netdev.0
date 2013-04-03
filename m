From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 7/7] stmmac: prefetch all dma_erx when use extend_desc
Date: Wed,  3 Apr 2013 07:41:29 +0200
Message-ID: <1364967689-11155-7-git-send-email-peppe.cavallaro@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:42628 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762320Ab3DCFmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 01:42:15 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1F2C5B0
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 05:42:13 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0369B25FC
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 05:42:13 +0000 (GMT)
In-Reply-To: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to prefetch, in the stmmac_rx, the whole
dma_erx descriptor in case of using the extended descriptors.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 16f5d73..5c6520f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2001,7 +2001,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 #endif
 	while (count < limit) {
 		int status;
-		struct dma_desc *p, *p_next;
+		struct dma_desc *p;
 
 		if (priv->extend_desc)
 			p = (struct dma_desc *)(priv->dma_erx + entry);
@@ -2015,12 +2015,9 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
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
