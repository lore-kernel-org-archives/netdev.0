From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 8/8] net: mvneta: Remove unneeded 'weigth' field
Date: Thu, 22 May 2014 20:07:03 -0300
Message-ID: <1400800023-1562-9-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49735 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753217AbaEVXIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 19:08:23 -0400
In-Reply-To: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'weight' field is only used to pass the weigth to napi initialization
function. This commit removes the field, and instead uses a fixed value to
initialize the napi context.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 02dd075..b8919fa 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -283,9 +283,6 @@ struct mvneta_port {
 	u32 cause_rx_tx;
 	struct napi_struct napi;
 
-	/* Napi weight */
-	int weight;
-
 	/* Core clock */
 	struct clk *clk;
 	u8 mcast_count[256];
@@ -2968,8 +2965,6 @@ static int mvneta_probe(struct platform_device *pdev)
 	dev->ethtool_ops = &mvneta_eth_tool_ops;
 
 	pp = netdev_priv(dev);
-
-	pp->weight = MVNETA_RX_POLL_WEIGHT;
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
 
@@ -3030,7 +3025,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	if (dram_target_info)
 		mvneta_conf_mbus_windows(pp, dram_target_info);
 
-	netif_napi_add(dev, &pp->napi, mvneta_poll, pp->weight);
+	netif_napi_add(dev, &pp->napi, mvneta_poll, MVNETA_RX_POLL_WEIGHT);
 
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
-- 
1.9.1
