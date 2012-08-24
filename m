From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/16] sfc: Remove bogus comment about MTU change
 and RX buffer overrun
Date: Fri, 24 Aug 2012 20:52:56 +0100
Message-ID: <1345837976.2694.36.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56840 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760132Ab2HXTw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:52:59 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX DMA is limited by the length specified in each descriptor and not
by the MAC.  Over-length frames may get into the RX FIFO regardless of
the MAC settings, due to a hardware bug, but they will be truncated by
the packet DMA engine and reported as such in the completion event.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b29db12..4105a666 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1953,8 +1953,6 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
 	mutex_lock(&efx->mac_lock);
-	/* Reconfigure the MAC before enabling the dma queues so that
-	 * the RX buffers don't overflow */
 	net_dev->mtu = new_mtu;
 	efx->type->reconfigure_mac(efx);
 	mutex_unlock(&efx->mac_lock);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
