From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] sfc: Use proper functions to set core RX
 and TX queue counts
Date: Thu, 23 Sep 2010 21:20:09 +0100
Message-ID: <1285273209.7794.25.camel@achroite.uk.solarflarecom.com>
References: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49091 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756586Ab0IWUUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 16:20:12 -0400
In-Reply-To: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call netif_real_num_tx_queues() instead of setting
net_device::real_num_tx_queues directly.

Also call the new netif_real_num_rx_queues() function to set the
core RX queue count correctly for RPS.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 5be71f4..fa6e020 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1315,7 +1315,8 @@ static int efx_probe_nic(struct efx_nic *efx)
 		efx->rx_indir_table[i] = i % efx->n_rx_channels;
 
 	efx_set_channels(efx);
-	efx->net_dev->real_num_tx_queues = efx->n_tx_channels;
+	netif_set_real_num_tx_queues(efx->net_dev, efx->n_tx_channels);
+	netif_set_real_num_rx_queues(efx->net_dev, efx->n_rx_channels);
 
 	/* Initialise the interrupt moderation settings */
 	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true);
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

