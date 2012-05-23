From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/4] stmmac: remove two useless initialisation
Date: Wed, 23 May 2012 08:36:01 +0200
Message-ID: <1337754964-21754-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:42134 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755607Ab2EWGgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 02:36:15 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C63B674
	for <netdev@vger.kernel.org>; Wed, 23 May 2012 06:36:13 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0DF601E8E
	for <netdev@vger.kernel.org>; Wed, 23 May 2012 06:36:13 +0000 (GMT)
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
