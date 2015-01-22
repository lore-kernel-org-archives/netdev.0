From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH 2/3] stmmac: hardware TX COE doesn't work when force_thresh_dma_mode is set
Date: Thu, 22 Jan 2015 14:55:57 +0800
Message-ID: <1421909758-31359-2-git-send-email-sonic.adi@gmail.com>
References: <1421909758-31359-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0065.outbound.protection.outlook.com ([65.55.169.65]:64480
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751336AbbAVHa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 02:30:56 -0500
In-Reply-To: <1421909758-31359-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Clear the TX COE bit when force_thresh_dma_mode is set even hardware
dma capability says support.

Tested on BF609.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5edfc8a..7a7385a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2746,7 +2746,11 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		priv->plat->enh_desc = priv->dma_cap.enh_desc;
 		priv->plat->pmt = priv->dma_cap.pmt_remote_wake_up;
 
-		priv->plat->tx_coe = priv->dma_cap.tx_coe;
+		/* TXCOE doesn't work in thresh DMA mode */
+		if (priv->plat->force_thresh_dma_mode)
+			priv->plat->tx_coe = 0;
+		else
+			priv->plat->tx_coe = priv->dma_cap.tx_coe;
 
 		if (priv->dma_cap.rx_coe_type2)
 			priv->plat->rx_coe = STMMAC_RX_COE_TYPE2;
-- 
1.7.9.5
