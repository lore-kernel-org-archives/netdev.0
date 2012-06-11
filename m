From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH 1/3] net: lpc_eth: Replace WARN() trace with simple pr_warn()
Date: Mon, 11 Jun 2012 10:03:11 +0200
Message-ID: <1339401793-12258-1-git-send-email-stigge@antcom.de>
Cc: Roland Stigge <stigge@antcom.de>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A WARN() trace indicating a "BUG!" was identified as a "normal" case in the
xmit function in case all TX descriptors are occupied already. In this case,
NETDEV_TX_BUSY is returned, nothing buggy at all.

Signed-off-by: Roland Stigge <stigge@antcom.de>
Tested-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>

---
 drivers/net/ethernet/nxp/lpc_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.orig/drivers/net/ethernet/nxp/lpc_eth.c
+++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1114,7 +1114,7 @@ static int lpc_eth_hard_start_xmit(struc
 		   buffers */
 		netif_stop_queue(ndev);
 		spin_unlock_irq(&pldat->lock);
-		WARN(1, "BUG! TX request when no free TX buffers!\n");
+		pr_warn("Note: TX request when no free TX buffers.\n");
 		return NETDEV_TX_BUSY;
 	}
 
