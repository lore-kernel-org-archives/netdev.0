From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 16/16] sfc: Fix the initial device operstate
Date: Fri, 24 Aug 2012 20:53:25 +0100
Message-ID: <1345838005.2694.38.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56860 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760165Ab2HXTx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:53:28 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following commit 8f4cccb ('net: Set device operstate at registration
time') it is now correct and preferable to set the carrier off before
registering a device.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 92f0020..a606db4 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2120,6 +2120,9 @@ static int efx_register_netdev(struct efx_nic *efx)
 		goto fail_locked;
 	efx_update_name(efx);
 
+	/* Always start with carrier off; PHY events will detect the link */
+	netif_carrier_off(net_dev);
+
 	rc = register_netdevice(net_dev);
 	if (rc)
 		goto fail_locked;
@@ -2130,9 +2133,6 @@ static int efx_register_netdev(struct efx_nic *efx)
 			efx_init_tx_queue_core_txq(tx_queue);
 	}
 
-	/* Always start with carrier off; PHY events will detect the link */
-	netif_carrier_off(net_dev);
-
 	rtnl_unlock();
 
 	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_type);
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
