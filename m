From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 3/3] drivers: net: ethernet: stmmac: fix resume function
Date: Tue, 22 May 2012 15:38:56 +0800
Message-ID: <1337672336-7378-3-git-send-email-lliubbo@gmail.com>
References: <1337672336-7378-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <francesco.virlinzi@st.com>,
	<rayagond@vayavyalabs.com>, <sr@denx.de>, <netdev@vger.kernel.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>,
	Bob Liu <lliubbo@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:6895
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755307Ab2EVHig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 03:38:36 -0400
In-Reply-To: <1337672336-7378-1-git-send-email-lliubbo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After wake up from mem, ping fails to work.
This patch fix the resume function in stmmac driver.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 714faa2..22243a5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1952,6 +1952,15 @@ int stmmac_resume(struct net_device *ndev)
 		priv->hw->mac->pmt(priv->ioaddr, 0);
 
 	netif_device_attach(ndev);
+	priv->dirty_tx = 0;
+	priv->cur_tx = 0;
+	priv->cur_rx = 0;
+	priv->dirty_rx = 0;
+
+	/* DMA initialization and SW reset */
+	priv->hw->dma->init(priv->ioaddr, priv->plat->pbl,
+			priv->dma_tx_phy, priv->dma_rx_phy);
+	priv->hw->mac->core_init(priv->ioaddr);
 
 	/* Enable the MAC and DMA */
 	stmmac_set_mac(priv->ioaddr, true);
-- 
1.7.0.4
