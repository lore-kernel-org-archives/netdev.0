From: Ripduman Sohan <ripduman.sohan@cl.cam.ac.uk>
Subject: [PATCH 2/2] sfc: Report correct tx-usecs-irq value when driver is loaded with separate_tx_channels set
Date: Wed, 31 Aug 2011 10:53:00 +0100
Message-ID: <1314784380-30656-1-git-send-email-ripduman.sohan@cl.cam.ac.uk>
Cc: netdev@vger.kernel.org,
	Ripduman Sohan <ripduman.sohan@cl.cam.ac.uk>
To: linux-net-drivers@solarflare.com, shodgson@solarflare.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.cl.cam.ac.uk ([128.232.25.21]:52229 "EHLO
	mta1.cl.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab1HaJxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 05:53:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver is loaded with the separate_tx_channels parameter set it
incorrectly reports TX moderation as 0 usecs regardless of the current
value.  This patch fixes this oversight.
---
 drivers/net/sfc/ethtool.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 0a52447..dac0a84 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -600,11 +600,8 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 		if (!efx_channel_has_tx_queues(channel))
 			continue;
 		if (channel->irq_moderation < coalesce->tx_coalesce_usecs_irq) {
-			if (channel->channel < efx->n_rx_channels)
-				coalesce->tx_coalesce_usecs_irq =
-					channel->irq_moderation;
-			else
-				coalesce->tx_coalesce_usecs_irq = 0;
+			coalesce->tx_coalesce_usecs_irq =
+				channel->irq_moderation;
 		}
 	}
 
-- 
1.7.1
