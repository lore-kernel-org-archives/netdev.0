From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/16] sfc: Initialise IRQ moderation for all NIC
 types from efx_init_eventq()
Date: Fri, 30 Aug 2013 04:40:51 +0100
Message-ID: <1377834051.2552.34.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35004 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab3H3Dkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:40:55 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c   |    4 +++-
 drivers/net/ethernet/sfc/farch.c |    2 --
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 59aa73c..aec6213 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -331,15 +331,17 @@ static int efx_probe_eventq(struct efx_channel *channel)
 /* Prepare channel's event queue */
 static int efx_init_eventq(struct efx_channel *channel)
 {
+	struct efx_nic *efx = channel->efx;
 	int rc;
 
 	EFX_WARN_ON_PARANOID(channel->eventq_init);
 
-	netif_dbg(channel->efx, drv, channel->efx->net_dev,
+	netif_dbg(efx, drv, efx->net_dev,
 		  "chan %d init event queue\n", channel->channel);
 
 	rc = efx_nic_init_eventq(channel);
 	if (rc == 0) {
+		efx->type->push_irq_moderation(channel);
 		channel->eventq_read_ptr = 0;
 		channel->eventq_init = true;
 	}
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 904af5c..eb754cf 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1357,8 +1357,6 @@ int efx_farch_ev_init(struct efx_channel *channel)
 	efx_writeo_table(efx, &reg, efx->type->evq_ptr_tbl_base,
 			 channel->channel);
 
-	efx->type->push_irq_moderation(channel);
-
 	return 0;
 }
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
