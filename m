From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/3] stmmac: fix a bug while checking the HW cap reg (v2)
Date: Thu, 27 Oct 2011 07:43:07 +0200
Message-ID: <1319694189-25223-1-git-send-email-peppe.cavallaro@st.com>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:43979 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751118Ab1J0FnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 01:43:19 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8A5F2BE
	for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 05:43:17 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 37BD11324
	for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 05:43:17 +0000 (GMT)
In-Reply-To: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
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
