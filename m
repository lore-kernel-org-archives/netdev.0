From: Matt Corallo <linux@bluematt.me>
Subject: [PATCH] net: stmmac: Fix null-function call in ISR on stmmac1000
Date: Thu, 30 Jun 2016 19:46:16 +0000
Message-ID: <4B218985-EF8E-47C0-A682-A3E41BE90003@bluematt.me>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: martin.blumenstingl@googlemail.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: linux-amlogic@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bluematt.me ([192.241.179.72]:46084 "EHLO mail.bluematt.me"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbcF3Trh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 15:47:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resent due to overhelpful mail client corrupting patch)

At least on Meson GXBB, the CORE_IRQ_MTL_RX_OVERFLOW interrupt is thrown
with the stmmac1000 driver, which does not support set_rx_tail_ptr. With
this patch and the clock fixes, 1G ethernet works on ODROID-C2.

Signed-off-by: Matt Corallo <git@bluematt.me>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a473c18..e407126 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2804,7 +2804,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 				priv->tx_path_in_lpi_mode = true;
 			if (status & CORE_IRQ_TX_PATH_EXIT_LPI_MODE)
 				priv->tx_path_in_lpi_mode = false;
-			if (status & CORE_IRQ_MTL_RX_OVERFLOW)
+			if (status & CORE_IRQ_MTL_RX_OVERFLOW && priv->hw->dma->set_rx_tail_ptr)
 				priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
 							priv->rx_tail_addr,
 							STMMAC_CHAN0);
-- 
2.1.4
