From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH 1/3] stmmac: if force_thresh_dma_mode is set, pass tc to both txmode and rxmode in tx_hard_error_bump_tc interrupt
Date: Thu, 22 Jan 2015 14:55:56 +0800
Message-ID: <1421909758-31359-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0085.outbound.protection.outlook.com ([65.55.169.85]:61664
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751608AbbAVHOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 02:14:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Dont' pass SF_DMA_MODE to rxmode in this case.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8c6b7c1..5edfc8a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1446,7 +1446,11 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 		/* Try to bump up the dma threshold on this failure */
 		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
 			tc += 64;
-			priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
+			if (priv->plat->force_thresh_dma_mode)
+				priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
+			else
+				priv->hw->dma->dma_mode(priv->ioaddr, tc,
+					SF_DMA_MODE);
 			priv->xstats.threshold = tc;
 		}
 	} else if (unlikely(status == tx_hard_error))
-- 
1.7.9.5
