From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next 4/8] sfc: Use consistent types for filter IDs,
 indices and search depths
Date: Tue, 3 Jan 2012 22:05:27 +0000
Message-ID: <1325628327.2832.40.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36888 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754891Ab2ACWFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:05:30 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Filter IDs are u32 (but never very large) so an ID/error return
value should have type s32.

Filter indices and search depths are never negative, so should
have type unsigned int.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.h    |    2 +-
 drivers/net/ethernet/sfc/filter.c |   14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 8a5336d..27f0b01 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -61,7 +61,7 @@ extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 extern int efx_probe_filters(struct efx_nic *efx);
 extern void efx_restore_filters(struct efx_nic *efx);
 extern void efx_remove_filters(struct efx_nic *efx);
-extern int efx_filter_insert_filter(struct efx_nic *efx,
+extern s32 efx_filter_insert_filter(struct efx_nic *efx,
 				    struct efx_filter_spec *spec,
 				    bool replace);
 extern int efx_filter_remove_filter(struct efx_nic *efx,
diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 1e079bd..f41ed5b 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -332,7 +332,7 @@ static bool efx_filter_equal(const struct efx_filter_spec *left,
 
 static int efx_filter_search(struct efx_filter_table *table,
 			     struct efx_filter_spec *spec, u32 key,
-			     bool for_insert, int *depth_required)
+			     bool for_insert, unsigned int *depth_required)
 {
 	unsigned hash, incr, filter_idx, depth, depth_max;
 
@@ -417,14 +417,14 @@ static inline u8 efx_filter_id_flags(u32 id)
  * On success, return the filter ID.
  * On failure, return a negative error code.
  */
-int efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
+s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 			     bool replace)
 {
 	struct efx_filter_state *state = efx->filter_state;
 	struct efx_filter_table *table = efx_filter_spec_table(state, spec);
 	struct efx_filter_spec *saved_spec;
 	efx_oword_t filter;
-	int filter_idx, depth;
+	unsigned int filter_idx, depth;
 	u32 key;
 	int rc;
 
@@ -481,7 +481,7 @@ out:
 
 static void efx_filter_table_clear_entry(struct efx_nic *efx,
 					 struct efx_filter_table *table,
-					 int filter_idx)
+					 unsigned int filter_idx)
 {
 	static efx_oword_t filter;
 
@@ -509,7 +509,7 @@ int efx_filter_remove_filter(struct efx_nic *efx, struct efx_filter_spec *spec)
 	struct efx_filter_table *table = efx_filter_spec_table(state, spec);
 	struct efx_filter_spec *saved_spec;
 	efx_oword_t filter;
-	int filter_idx, depth;
+	unsigned int filter_idx, depth;
 	u32 key;
 	int rc;
 
@@ -547,7 +547,7 @@ static void efx_filter_table_clear(struct efx_nic *efx,
 {
 	struct efx_filter_state *state = efx->filter_state;
 	struct efx_filter_table *table = &state->table[table_id];
-	int filter_idx;
+	unsigned int filter_idx;
 
 	spin_lock_bh(&state->lock);
 
@@ -578,7 +578,7 @@ void efx_restore_filters(struct efx_nic *efx)
 	enum efx_filter_table_id table_id;
 	struct efx_filter_table *table;
 	efx_oword_t filter;
-	int filter_idx;
+	unsigned int filter_idx;
 
 	spin_lock_bh(&state->lock);
 
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
