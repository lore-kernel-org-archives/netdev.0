From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/3] stmmac: fix a bug while checking the HW cap reg
Date: Wed, 26 Oct 2011 15:55:37 +0200
Message-ID: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
Cc: keguang.zhang@gmail.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:37544 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932247Ab1JZNzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 09:55:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes a bug while checking the HW cap reg
on old MAC10/100 where this feature is not available.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index aeaa15b..fcdd5a2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -812,9 +812,10 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
  */
 static int stmmac_get_hw_features(struct stmmac_priv *priv)
 {
-	u32 hw_cap = priv->hw->dma->get_hw_feature(priv->ioaddr);
+	u32 hw_cap = 0;
+	if (priv->hw->dma->get_hw_feature) {
+		hw_cap = priv->hw->dma->get_hw_feature(priv->ioaddr);
 
-	if (likely(hw_cap)) {
 		priv->dma_cap.mbps_10_100 = (hw_cap & DMA_HW_FEAT_MIISEL);
 		priv->dma_cap.mbps_1000 = (hw_cap & DMA_HW_FEAT_GMIISEL) >> 1;
 		priv->dma_cap.half_duplex = (hw_cap & DMA_HW_FEAT_HDSEL) >> 2;
-- 
1.7.4.4
