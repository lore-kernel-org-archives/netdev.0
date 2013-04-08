From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH net-next RESEND] stmmac: modified pcs mode support for SGMII
Date: Mon, 08 Apr 2013 12:56:16 +0900
Message-ID: <015701ce340d$052a71d0$0f7f5570$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ks_c_5601-1987
Content-Transfer-Encoding: 7bit
Cc: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>,
	=?ks_c_5601-1987?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>,
	cpgs@samsung.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:19979 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab3DHD4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 23:56:18 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKX005C049GMW80@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 08 Apr 2013 12:56:17 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch modifies the pcs mode support for SGMII. Even though
SGMII does auto-negotiation with phy, it needs stmmac_init_phy and
stmmac_mdio_register function for initializing phy.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6b26d31..3ac9bd7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1504,7 +1504,8 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_check_ether_addr(priv);
 
-	if (!priv->pcs) {
+	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
+	    priv->pcs != STMMAC_PCS_RTBI) {
 		ret = stmmac_init_phy(dev);
 		if (ret) {
 			pr_err("%s: Cannot attach to PHY (error: %d)\n",
@@ -1607,7 +1608,8 @@ static int stmmac_open(struct net_device *dev)
 	/* Using PCS we cannot dial with the phy registers at this stage
 	 * so we do not support extra feature like EEE.
 	 */
-	if (!priv->pcs)
+	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
+	    priv->pcs != STMMAC_PCS_RTBI)
 		priv->eee_enabled = stmmac_eee_init(priv);
 
 	stmmac_init_tx_coalesce(priv);
@@ -2637,7 +2639,8 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 
 	stmmac_check_pcs_mode(priv);
 
-	if (!priv->pcs) {
+	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
+	    priv->pcs != STMMAC_PCS_RTBI) {
 		/* MDIO bus Registration */
 		ret = stmmac_mdio_register(ndev);
 		if (ret < 0) {
@@ -2677,7 +2680,8 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
 	stmmac_set_mac(priv->ioaddr, false);
-	if (!priv->pcs)
+	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
+	    priv->pcs != STMMAC_PCS_RTBI)
 		stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
-- 
1.7.10.4
