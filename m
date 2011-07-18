From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/2] stmmac: Allow SOCs to use Store forward mode eventhough tx_coe is 0. (V2)
Date: Mon, 18 Jul 2011 08:54:09 +0200
Message-ID: <1310972049-827-2-git-send-email-peppe.cavallaro@st.com>
References: <1310972049-827-1-git-send-email-peppe.cavallaro@st.com>
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:52671 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750745Ab1GRGzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 02:55:01 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 45D99DB
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 06:54:57 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0EAA71939
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 06:54:57 +0000 (GMT)
In-Reply-To: <1310972049-827-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds new field 'force_sf_dma_mode' to plat_stmmacenet_data
struct to allow users to specify if they want to use force store forward
eventhough tx_coe is not available in hw.
without this flag stmmac driver will use cut-thru mode not use
store-forward mode.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    8 +++++---
 include/linux/stmmac.h           |    1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index f3d16d85..0e0134e 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -557,9 +557,11 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
  */
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
-	if (likely((priv->plat->tx_coe) && (!priv->no_csum_insertion))) {
-		/* In case of GMAC, SF mode has to be enabled
-		 * to perform the TX COE. This depends on:
+	if (likely(priv->plat->force_sf_dma_mode ||
+		((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {
+		/*
+		 * In case of GMAC, SF mode can be enabled
+		 * to perform the TX COE in HW. This depends on:
 		 * 1) TX COE if actually supported
 		 * 2) There is no bugged Jumbo frame support
 		 *    that needs to not insert csum in the TDES.
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 9529e49..05d7756 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -40,6 +40,7 @@ struct plat_stmmacenet_data {
 	int tx_coe;
 	int bugged_jumbo;
 	int pmt;
+	int force_sf_dma_mode;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 	int (*init)(struct platform_device *pdev);
-- 
1.7.4.4

