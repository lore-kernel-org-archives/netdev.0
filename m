From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH] driver:net:stmmac: Disable DMA store and forward mode if platform data force_sf_dma_mode is negative.
Date: Thu, 15 Aug 2013 15:37:36 +0800
Message-ID: <1376552256-7421-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:45829
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757891Ab3HOHcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 03:32:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Some synopsys ip implementation doesn't support DMA store and forward mode,
such as BF60x. So, define force_sf_dma_mode negative to use DMA thresholds only.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f2ccb36..b0e003a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1157,7 +1157,9 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
  */
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
-	if (likely(priv->plat->force_sf_dma_mode ||
+	if (priv->plat->force_sf_dma_mode < 0)
+		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
+	else if (likely(priv->plat->force_sf_dma_mode > 0 ||
 		   ((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {
 		/*
 		 * In case of GMAC, SF mode can be enabled
-- 
1.8.2.3
