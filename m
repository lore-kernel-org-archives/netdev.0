From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2] mv643xx_eth: fix NAPI weight being > 64
Date: Tue, 14 May 2013 11:54:20 +0200
Message-ID: <1368525260-17556-1-git-send-email-andrew@lunn.ch>
Cc: linux ARM <linux-arm-kernel@lists.infradead.org>,
	netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, Jason Cooper <jason@lakedaemon.net>,
	buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from londo.lunn.ch ([80.238.139.98]:35726 "EHLO londo.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756607Ab3ENJzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 May 2013 05:55:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3.10-rc1 issues the following warning:

netif_napi_add() called with weight 128 on device eth%d

This patch reduce the weight to 64, using NAPI_POLL_WEIGHT.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v1->v2: Use NAPI_POLL_WEIGHT.

 drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d0afeea..8f63c36 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2745,7 +2745,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
 
-	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 128);
+	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, NAPI_POLL_WEIGHT);
 
 	init_timer(&mp->rx_oom);
 	mp->rx_oom.data = (unsigned long)mp;
-- 
1.7.10.4
