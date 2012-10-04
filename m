From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH 10/11] net: ll_temac: Simplify xmit
Date: Thu,  4 Oct 2012 20:14:56 +0200
Message-ID: <1349374497-9540-10-git-send-email-monstr@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use one return statement instead of two.

Signed-off-by: Michal Simek <monstr@monstr.eu>
CC: Anirudha Sarangi <anirudh@xilinx.com>
CC: John Linn <John.Linn@xilinx.com>
CC: Grant Likely <grant.likely@secretlab.ca>
CC: Rob Herring <rob.herring@calxeda.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index fec42d9..58b2869 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -690,10 +690,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
 
 	if (temac_check_tx_bd_space(lp, num_frag)) {
-		if (!netif_queue_stopped(ndev)) {
+		if (!netif_queue_stopped(ndev))
 			netif_stop_queue(ndev);
-			return NETDEV_TX_BUSY;
-		}
 		return NETDEV_TX_BUSY;
 	}
 
-- 
1.7.0.4
