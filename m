From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/16] sfc: Remove unused filter_flags variables
 and efx_farch_filter_id_flags()
Date: Tue, 27 Aug 2013 21:39:28 +0100
Message-ID: <1377635968.13272.73.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62555 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab3H0Ujb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:39:31 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index fb01fdb..a588c95 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -609,16 +609,6 @@ static inline unsigned int efx_filter_id_index(u32 id)
 	return id & EFX_FILTER_INDEX_MASK;
 }
 
-static inline u8 efx_filter_id_flags(u32 id)
-{
-	unsigned int range = id >> EFX_FILTER_INDEX_WIDTH;
-
-	if (range < EFX_FILTER_MATCH_PRI_COUNT)
-		return EFX_FILTER_FLAG_RX;
-	else
-		return EFX_FILTER_FLAG_TX;
-}
-
 u32 efx_filter_get_rx_id_limit(struct efx_nic *efx)
 {
 	struct efx_filter_state *state = efx->filter_state;
@@ -829,7 +819,6 @@ int efx_filter_remove_id_safe(struct efx_nic *efx,
 	struct efx_filter_table *table;
 	unsigned int filter_idx;
 	struct efx_filter_spec *spec;
-	u8 filter_flags;
 	int rc;
 
 	table_id = efx_filter_id_table_id(filter_id);
@@ -842,8 +831,6 @@ int efx_filter_remove_id_safe(struct efx_nic *efx,
 		return -ENOENT;
 	spec = &table->spec[filter_idx];
 
-	filter_flags = efx_filter_id_flags(filter_id);
-
 	spin_lock_bh(&state->lock);
 
 	if (test_bit(filter_idx, table->used_bitmap) &&
@@ -880,7 +867,6 @@ int efx_filter_get_filter_safe(struct efx_nic *efx,
 	struct efx_filter_table *table;
 	struct efx_filter_spec *spec;
 	unsigned int filter_idx;
-	u8 filter_flags;
 	int rc;
 
 	table_id = efx_filter_id_table_id(filter_id);
@@ -893,8 +879,6 @@ int efx_filter_get_filter_safe(struct efx_nic *efx,
 		return -ENOENT;
 	spec = &table->spec[filter_idx];
 
-	filter_flags = efx_filter_id_flags(filter_id);
-
 	spin_lock_bh(&state->lock);
 
 	if (test_bit(filter_idx, table->used_bitmap) &&


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
