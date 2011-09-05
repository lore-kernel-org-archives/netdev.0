From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/5] sfc: Correct error code for unsupported
 interrupt coalescing parameters
Date: Mon, 05 Sep 2011 18:41:27 +0100
Message-ID: <1315244487.3028.13.camel@bwh-desktop>
References: <1315231921.3028.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Ripduman Sohan <ripduman.sohan@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59920 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab1IERla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 13:41:30 -0400
In-Reply-To: <1315231921.3028.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index bc4643a..6de2715 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -628,12 +628,12 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	unsigned tx_usecs, rx_usecs, adaptive;
 
 	if (coalesce->use_adaptive_tx_coalesce)
-		return -EOPNOTSUPP;
+		return -EINVAL;
 
 	if (coalesce->rx_coalesce_usecs || coalesce->tx_coalesce_usecs) {
 		netif_err(efx, drv, efx->net_dev, "invalid coalescing setting. "
 			  "Only rx/tx_coalesce_usecs_irq are supported\n");
-		return -EOPNOTSUPP;
+		return -EINVAL;
 	}
 
 	rx_usecs = coalesce->rx_coalesce_usecs_irq;
@@ -647,7 +647,7 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 		    tx_usecs) {
 			netif_err(efx, drv, efx->net_dev, "Channel is shared. "
 				  "Only RX coalescing may be set\n");
-			return -EOPNOTSUPP;
+			return -EINVAL;
 		}
 	}
 
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
