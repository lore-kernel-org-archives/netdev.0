From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/15] sfc: Initialise efx_ptp_data::phc_clock_info
 from a static template
Date: Sat, 14 Dec 2013 23:01:40 +0000
Message-ID: <1387062100.12172.61.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17278 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab3LNXBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:01:45 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |   30 ++++++++++++++++--------------
 1 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 5b434597ac63..96008202cbc3 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -926,6 +926,21 @@ static void efx_ptp_worker(struct work_struct *work)
 		efx_ptp_process_rx(efx, skb);
 }
 
+static const struct ptp_clock_info efx_phc_clock_info = {
+	.owner		= THIS_MODULE,
+	.name		= "sfc",
+	.max_adj	= MAX_PPB,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.pps		= 1,
+	.adjfreq	= efx_phc_adjfreq,
+	.adjtime	= efx_phc_adjtime,
+	.gettime	= efx_phc_gettime,
+	.settime	= efx_phc_settime,
+	.enable		= efx_phc_enable,
+};
+
 /* Initialise PTP state. */
 int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 {
@@ -964,20 +979,7 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 		list_add(&ptp->rx_evts[pos].link, &ptp->evt_free_list);
 	ptp->evt_overflow = false;
 
-	ptp->phc_clock_info.owner = THIS_MODULE;
-	strlcpy(ptp->phc_clock_info.name, "sfc",
-		sizeof(ptp->phc_clock_info.name));
-	ptp->phc_clock_info.max_adj = MAX_PPB;
-	ptp->phc_clock_info.n_alarm = 0;
-	ptp->phc_clock_info.n_ext_ts = 0;
-	ptp->phc_clock_info.n_per_out = 0;
-	ptp->phc_clock_info.pps = 1;
-	ptp->phc_clock_info.adjfreq = efx_phc_adjfreq;
-	ptp->phc_clock_info.adjtime = efx_phc_adjtime;
-	ptp->phc_clock_info.gettime = efx_phc_gettime;
-	ptp->phc_clock_info.settime = efx_phc_settime;
-	ptp->phc_clock_info.enable = efx_phc_enable;
-
+	ptp->phc_clock_info = efx_phc_clock_info;
 	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
 					    &efx->pci_dev->dev);
 	if (IS_ERR(ptp->phc_clock)) {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
