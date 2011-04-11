From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/3] stmmac: fix Transmit Underflow error
Date: Mon, 11 Apr 2011 11:16:46 +0200
Message-ID: <1302513406-3758-3-git-send-email-peppe.cavallaro@st.com>
References: <1302513406-3758-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:52567 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753907Ab1DKJRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 05:17:11 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 018FE14E
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 09:17:08 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9B4E21A5F
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 09:17:08 +0000 (GMT)
In-Reply-To: <1302513406-3758-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some old MAC chips without COE sometime the
Transmit Underflow error is issued.

The driver aborted all the transmission process
and initialized it from scratch.
This breaks the network activity as raised by Nachiketa
on a SPEAr board.

The patch is to fix this rare underflow event.
The driver will only clear the interrupt and the Tx
DMA will go out the Suspend state as soon as the
descriptor is fetched again.
The driver will continue to bump-up the DMA FIFO threshold
that, indeed, helped somebody to prevent this kind of error
in the past as well.

Reported-by: Nachiketa Prachanda <nprachanda@ncomputing.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 442a7ca..ba9daec 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -749,7 +749,6 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 			priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
 			priv->xstats.threshold = tc;
 		}
-		stmmac_tx_err(priv);
 	} else if (unlikely(status == tx_hard_error))
 		stmmac_tx_err(priv);
 }
-- 
1.7.4.2

