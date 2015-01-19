From: Felipe Balbi <balbi@ti.com>
Subject: [patch-net-next v3] net: ethernet: ti: cpsw: fix buld break when NET_POLL_CONTROLLER
Date: Mon, 19 Jan 2015 11:52:36 -0600
Message-ID: <1421689956-14369-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tony Lindgren <tony@atomide.com>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:45076 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbbASRxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 12:53:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c03abd84634d (net: ethernet: cpsw: don't requests IRQs we don't
use) left one build breakage when NET_POLL_CONTROLLER is enabled.

Fix this build break by referring to the correct irqs_table array.

Fixes: c03abd84634d (net: ethernet: cpsw: don't requests IRQs we don't use)
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ba09ff3c1695..a0e9a2b384f8 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1625,8 +1625,8 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 
 	cpsw_intr_disable(priv);
 	cpdma_ctlr_int_ctrl(priv->dma, false);
-	cpsw_rx_interrupt(priv->irq[0], priv);
-	cpsw_tx_interrupt(priv->irq[1], priv);
+	cpsw_rx_interrupt(priv->irqs_table[0], priv);
+	cpsw_tx_interrupt(priv->irqs_table[1], priv);
 	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
 }
-- 
2.2.0
