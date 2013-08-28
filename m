From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/16] sfc: Remove early call to
 efx_nic_type::reconfigure_mac in efx_reset_up()
Date: Wed, 28 Aug 2013 16:20:10 +0100
Message-ID: <1377703210.2264.32.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17260 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab3H1PUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:20:14 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_reset_up() calls efx_nic_type::reconfigure_mac once directly,
then again through efx_start_all() -> efx_start_port() ->
efx->type->reconfigure_mac().

This first call is also made too early to work properly on EF10.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index efad5f7..3af28a8 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2202,8 +2202,6 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 				  "could not restore PHY settings\n");
 	}
 
-	efx->type->reconfigure_mac(efx);
-
 	efx_enable_interrupts(efx);
 	efx_restore_filters(efx);
 	efx_sriov_reset(efx);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
