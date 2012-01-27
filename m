From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 29/32] sfc: Rename implementation of ndo_set_rx_mode
Date: Fri, 27 Jan 2012 20:52:02 +0000
Message-ID: <1327697522.2503.36.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63835 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753147Ab2A0UwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:52:05 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename efx_set_multicast_list() to efx_set_rx_mode(), in line
with the operation name net_device_ops::ndo_set_rx_mode.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index fce42f4..a352c55 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -852,7 +852,7 @@ int __efx_reconfigure_port(struct efx_nic *efx)
 
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 
-	/* Serialise the promiscuous flag with efx_set_multicast_list. */
+	/* Serialise the promiscuous flag with efx_set_rx_mode. */
 	netif_addr_lock_bh(efx->net_dev);
 	netif_addr_unlock_bh(efx->net_dev);
 
@@ -1844,7 +1844,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 }
 
 /* Context: netif_addr_lock held, BHs disabled. */
-static void efx_set_multicast_list(struct net_device *net_dev)
+static void efx_set_rx_mode(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct netdev_hw_addr *ha;
@@ -1898,7 +1898,7 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_do_ioctl		= efx_ioctl,
 	.ndo_change_mtu		= efx_change_mtu,
 	.ndo_set_mac_address	= efx_set_mac_address,
-	.ndo_set_rx_mode	= efx_set_multicast_list,
+	.ndo_set_rx_mode	= efx_set_rx_mode,
 	.ndo_set_features	= efx_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
