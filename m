From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/19] sfc: Use proper function to test for RX
 channel in efx_poll()
Date: Thu, 16 Feb 2012 00:48:22 +0000
Message-ID: <1329353302.2565.37.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27623 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756642Ab2BPAsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:48:25 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index ccfb43c..eda2272 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -279,7 +279,7 @@ static int efx_poll(struct napi_struct *napi, int budget)
 	spent = efx_process_channel(channel, budget);
 
 	if (spent < budget) {
-		if (channel->channel < efx->n_rx_channels &&
+		if (efx_channel_has_rx_queue(channel) &&
 		    efx->irq_rx_adaptive &&
 		    unlikely(++channel->irq_count == 1000)) {
 			if (unlikely(channel->irq_mod_score <
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
