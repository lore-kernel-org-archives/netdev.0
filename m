From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/2] sfc: Implement 64-bit net device statistics on all
 architectures
Date: Thu, 03 Jun 2010 18:40:41 +0100
Message-ID: <1275586841.2106.24.camel@achroite.uk.solarflarecom.com>
References: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:5134 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab0FCRkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 13:40:45 -0400
In-Reply-To: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This begins step 2 of the transition.  It's a trivial change since sfc
already maintains 64-bit statistics and does not update
net_device::stats asynchronously.

Ben.

 drivers/net/sfc/efx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 26b0cc2..8ad476a 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1492,11 +1492,11 @@ static int efx_net_stop(struct net_device *net_dev)
 }
 
 /* Context: process, dev_base_lock or RTNL held, non-blocking. */
-static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
+static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_mac_stats *mac_stats = &efx->mac_stats;
-	struct net_device_stats *stats = &net_dev->stats;
+	struct rtnl_link_stats64 *stats = &net_dev->stats64;
 
 	spin_lock_bh(&efx->stats_lock);
 	efx->type->update_stats(efx);
@@ -1630,7 +1630,7 @@ static void efx_set_multicast_list(struct net_device *net_dev)
 static const struct net_device_ops efx_netdev_ops = {
 	.ndo_open		= efx_net_open,
 	.ndo_stop		= efx_net_stop,
-	.ndo_get_stats		= efx_net_stats,
+	.ndo_get_stats64	= efx_net_stats,
 	.ndo_tx_timeout		= efx_watchdog,
 	.ndo_start_xmit		= efx_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

