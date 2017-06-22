From: Martin Habets <mhabets@solarflare.com>
Subject: [PATCH net] sfc: Fix MCDI command size for filter operations
Date: Thu, 22 Jun 2017 10:50:41 +0100
Message-ID: <89eade1b-405f-07f6-3f0b-ffeeb74ea618@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:35841 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751674AbdFVJur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 05:50:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8000 series adapters uses catch-all filters for encapsulated traffic
to support filtering VXLAN, NVGRE and GENEVE traffic.
This new filter functionality requires a longer MCDI command.
This patch increases the size of buffers on stack that were missed, which
fixes a kernel panic from the stack protector.

Fixes: 9b41080125176 ("sfc: insert catch-all filters for encapsulated traffic")
Signed-off-by: Martin Habets <mhabets@solarflare.com>
Acked-by: Edward Cree <ecree@solarflare.com>
Acked-by: Bert Kenward bkenward@solarflare.com
---
 drivers/net/ethernet/sfc/ef10.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 78efb2822b86..a8089667fc5b 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -4172,7 +4172,7 @@ static s32 efx_ef10_filter_insert(struct efx_nic *efx,
 	 * recipients
 	 */
 	if (is_mc_recip) {
-		MCDI_DECLARE_BUF(inbuf, MC_CMD_FILTER_OP_IN_LEN);
+		MCDI_DECLARE_BUF(inbuf, MC_CMD_FILTER_OP_EXT_IN_LEN);
 		unsigned int depth, i;
 
 		memset(inbuf, 0, sizeof(inbuf));
@@ -4320,7 +4320,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 			efx_ef10_filter_set_entry(table, filter_idx, NULL, 0);
 		} else {
 			efx_mcdi_display_error(efx, MC_CMD_FILTER_OP,
-					       MC_CMD_FILTER_OP_IN_LEN,
+					       MC_CMD_FILTER_OP_EXT_IN_LEN,
 					       NULL, 0, rc);
 		}
 	}
@@ -4453,7 +4453,7 @@ static s32 efx_ef10_filter_rfs_insert(struct efx_nic *efx,
 				      struct efx_filter_spec *spec)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_FILTER_OP_IN_LEN);
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_FILTER_OP_EXT_IN_LEN);
 	struct efx_filter_spec *saved_spec;
 	unsigned int hash, i, depth = 1;
 	bool replacing = false;
@@ -4940,7 +4940,7 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_FILTER_OP_IN_LEN);
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_FILTER_OP_EXT_IN_LEN);
 	struct efx_filter_spec *spec;
 	unsigned int filter_idx;
 	int rc;
