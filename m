From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/4] stmmac: remove two useless initialisation
Date: Mon,  4 Jun 2012 17:37:47 +0200
Message-ID: <1338824270-9222-2-git-send-email-peppe.cavallaro@st.com>
References: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:46277 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760825Ab2FDPiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:38:21 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AD924125
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:38:05 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 665494639
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:38:05 +0000 (GMT)
In-Reply-To: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes two useful initialisation in the
stmmac_rx and stmmac_tx function.
In the former, count var was already reset and in the
stmmac_tx we only need to increment the dirty pointer
w/o setting the entry var.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7096633..0caae72 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -677,7 +677,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 
 		priv->hw->desc->release_tx_desc(p);
 
-		entry = (++priv->dirty_tx) % txsize;
+		priv->dirty_tx++;
 	}
 	if (unlikely(netif_queue_stopped(priv->dev) &&
 		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv))) {
@@ -1307,7 +1307,6 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		display_ring(priv->dma_rx, rxsize);
 	}
 #endif
-	count = 0;
 	while (!priv->hw->desc->get_rx_owner(p)) {
 		int status;
 
-- 
1.7.4.4
