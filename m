From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/2] stmmac: remove useless csum flag
Date: Mon, 19 Aug 2013 08:38:08 +0200
Message-ID: <1376894288-31279-2-git-send-email-peppe.cavallaro@st.com>
References: <1376894288-31279-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:52457 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750939Ab3HSGog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 02:44:36 -0400
In-Reply-To: <1376894288-31279-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the no_csum_insertion private parameter that is not used anymore
and, also,  the "likely" annotation from the condition that is not in a critical path.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Sonic Zhang <sonic.zhang@analog.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index c922fde..f16a9bd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -70,7 +70,6 @@ struct stmmac_priv {
 	struct net_device *dev;
 	struct device *device;
 	struct mac_device_info *hw;
-	int no_csum_insertion;
 	spinlock_t lock;
 
 	struct phy_device *phydev ____cacheline_aligned_in_smp;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 75cc2d3..65ae7e6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1239,8 +1239,7 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
  */
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
-	if (likely(priv->plat->force_sf_dma_mode ||
-		   ((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {
+	if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
 		/*
 		 * In case of GMAC, SF mode can be enabled
 		 * to perform the TX COE in HW. This depends on:
-- 
1.7.4.4
