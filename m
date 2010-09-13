From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 9/9] net: davinci_emac: extended register dumps on tx timeout
Date: Mon, 13 Sep 2010 14:07:31 -0400
Message-ID: <1284401251-8846-10-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Cc: michael.williamson@criticallink.com, caglarakyuz@gmail.com,
	bparrot@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:57539 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754665Ab0IMSHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 14:07:40 -0400
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch hooks up the emac_dump_regs() function to use cpdma dump routines.
Further, we dump registers on transmit timeout, to make such timeouts
debuggable.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Michael Williamson <michael.williamson@criticallink.com>
Signed-off-by: Caglar Akyuz <caglarakyuz@gmail.com>
---
 drivers/net/davinci_emac.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 9e866ae..2a628d1 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -460,6 +460,8 @@ static void emac_dump_regs(struct emac_priv *priv)
 		emac_read(EMAC_RXMOFOVERRUNS));
 	dev_info(emac_dev, "EMAC: rx_dma_overruns:%d\n",
 		emac_read(EMAC_RXDMAOVERRUNS));
+
+	cpdma_ctlr_dump(priv->dma);
 }
 
 /**
@@ -1115,6 +1117,8 @@ static void emac_dev_tx_timeout(struct net_device *ndev)
 	if (netif_msg_tx_err(priv))
 		dev_err(emac_dev, "DaVinci EMAC: xmit timeout, restarting TX");
 
+	emac_dump_regs(priv);
+
 	ndev->stats.tx_errors++;
 	emac_int_disable(priv);
 	cpdma_chan_stop(priv->txchan);
-- 
1.7.0.4

