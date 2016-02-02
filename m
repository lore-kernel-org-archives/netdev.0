From: Rabin Vincent <rabin.vincent@axis.com>
Subject: [PATCH] dwc_eth_qos: Reset hardware before PHY start
Date: Tue, 2 Feb 2016 09:39:02 +0100
Message-ID: <1454402342-20477-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <larper@axis.com>, <netdev@vger.kernel.org>,
	Rabin Vincent <rabinv@axis.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:42077 "EHLO
	bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110AbcBBIjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 03:39:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabinv@axis.com>

The hardware reset is currently done after phy_start() is called,
leading to a race where we can lose the link status if the phy state
machine calls dwceqos_adjust_link() before we reset the MAC registers.

Acked-by: Lars Persson <larper@axis.com>
Signed-off-by: Rabin Vincent <rabinv@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 70814b7..fc8bbff 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -1880,9 +1880,9 @@ static int dwceqos_open(struct net_device *ndev)
 	}
 	netdev_reset_queue(ndev);
 
+	dwceqos_init_hw(lp);
 	napi_enable(&lp->napi);
 	phy_start(lp->phy_dev);
-	dwceqos_init_hw(lp);
 
 	netif_start_queue(ndev);
 	tasklet_enable(&lp->tx_bdreclaim_tasklet);
-- 
2.7.0
