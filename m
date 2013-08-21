From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git] stmmac: remove useless csum flag
Date: Wed, 21 Aug 2013 09:11:14 +0200
Message-ID: <1377069074-4488-1-git-send-email-peppe.cavallaro@st.com>
References: <20130821.000600.1770175220773794518.davem@davemloft.net>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:55792 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752414Ab3HUHRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 03:17:23 -0400
In-Reply-To: <20130821.000600.1770175220773794518.davem@davemloft.net>
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
index 0a9bb9d..be40691 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1224,8 +1224,7 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
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
