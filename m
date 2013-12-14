From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/15] sfc: PTP - tidy up unused/useless variables
Date: Sat, 14 Dec 2013 23:02:19 +0000
Message-ID: <1387062139.12172.63.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17306 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab3LNXCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:02:23 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurence Evans <levans@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index be7ed4e1c96c..82d8e27e8a58 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -237,9 +237,6 @@ struct efx_ptp_timeset {
  * @evt_code: Last event code
  * @start: Address at which MC indicates ready for synchronisation
  * @host_time_pps: Host time at last PPS
- * @last_sync_ns: Last number of nanoseconds between readings when synchronising
- * @base_sync_ns: Number of nanoseconds for last synchronisation.
- * @base_sync_valid: Whether base_sync_time is valid.
  * @current_adjfreq: Current ppb adjustment.
  * @phc_clock: Pointer to registered phc device
  * @phc_clock_info: Registration structure for phc device
@@ -274,9 +271,6 @@ struct efx_ptp_data {
 	int evt_code;
 	struct efx_buffer start;
 	struct pps_event_time host_time_pps;
-	unsigned last_sync_ns;
-	unsigned base_sync_ns;
-	bool base_sync_valid;
 	s64 current_adjfreq;
 	struct ptp_clock *phc_clock;
 	struct ptp_clock_info phc_clock_info;
@@ -482,18 +476,10 @@ efx_ptp_process_times(struct efx_nic *efx, MCDI_DECLARE_STRUCT_PTR(synch_buf),
 
 	if (ngood == 0) {
 		netif_warn(efx, drv, efx->net_dev,
-			   "PTP no suitable synchronisations %dns\n",
-			   ptp->base_sync_ns);
+			   "PTP no suitable synchronisations\n");
 		return -EAGAIN;
 	}
 
-	/* Average minimum this synchronisation */
-	ptp->last_sync_ns = DIV_ROUND_UP(total, ngood);
-	if (!ptp->base_sync_valid || (ptp->last_sync_ns < ptp->base_sync_ns)) {
-		ptp->base_sync_valid = true;
-		ptp->base_sync_ns = ptp->last_sync_ns;
-	}
-
 	/* Calculate delay from actual PPS to last_time */
 	delta.tv_nsec =
 		ptp->timeset[last_good].nanoseconds +


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
