From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH RESEND net-next 01/16] sfc: Fix lookup of default RX MAC
 filters when steered using ethtool
Date: Thu, 22 Aug 2013 20:25:09 +0100
Message-ID: <1377199509.1703.50.camel@bwh-desktop.uk.level5networks.com>
References: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29732 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123Ab3HVTZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:25:14 -0400
In-Reply-To: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 385904f819e3 ('sfc: Don't use
efx_filter_{build,hash,increment}() for default MAC filters') used the
wrong name to find the index of default RX MAC filters at insertion/
update time.  This could result in memory corruption and would in any
case silently fail to update the filter.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 2a469b2..30d7442 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -675,7 +675,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 		BUILD_BUG_ON(EFX_FILTER_INDEX_UC_DEF != 0);
 		BUILD_BUG_ON(EFX_FILTER_INDEX_MC_DEF !=
 			     EFX_FILTER_MC_DEF - EFX_FILTER_UC_DEF);
-		rep_index = spec->type - EFX_FILTER_INDEX_UC_DEF;
+		rep_index = spec->type - EFX_FILTER_UC_DEF;
 		ins_index = rep_index;
 
 		spin_lock_bh(&state->lock);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
