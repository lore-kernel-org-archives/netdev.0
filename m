From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 31/52] sfc: Do not call netif_{stop,wake}_queue() before register_netdev
Date: Mon, 1 Sep 2008 12:48:20 +0100
Message-ID: <20080901114819.GY7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:58087 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758627AbYIALsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:23 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d41a6e3..be9382f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1027,7 +1027,8 @@ static void efx_start_all(struct efx_nic *efx)
 	/* Mark the port as enabled so port reconfigurations can start, then
 	 * restart the transmit interface early so the watchdog timer stops */
 	efx_start_port(efx);
-	efx_wake_queue(efx);
+	if (efx_dev_registered(efx))
+		efx_wake_queue(efx);
 
 	efx_for_each_channel(channel, efx)
 		efx_start_channel(channel);
@@ -1102,8 +1103,8 @@ static void efx_stop_all(struct efx_nic *efx)
 
 	/* Stop the kernel transmit interface late, so the watchdog
 	 * timer isn't ticking over the flush */
-	efx_stop_queue(efx);
 	if (efx_dev_registered(efx)) {
+		efx_stop_queue(efx);
 		netif_tx_lock_bh(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

