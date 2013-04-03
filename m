From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 1/7] stmmac: review napi gro support
Date: Wed,  3 Apr 2013 07:41:23 +0200
Message-ID: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:47258 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755689Ab3DCFlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 01:41:49 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DABF5A6
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 05:41:38 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8CCF425F6
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 05:41:38 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to:
o use napi_gro_flush() before calling __napi_complete()
o turn on NETIF_F_GRO by default

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6b26d31..8b69e3b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2046,7 +2046,8 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 
 	work_done = stmmac_rx(priv, budget);
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_gro_flush(napi, false);
+		__napi_complete(napi);
 		stmmac_enable_dma_irq(priv);
 	}
 	return work_done;
@@ -2586,7 +2587,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 
 	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			    NETIF_F_RXCSUM;
-	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
+	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA | NETIF_F_GRO;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
 	/* Both mac100 and gmac support receive VLAN tag detection */
-- 
1.7.4.4
