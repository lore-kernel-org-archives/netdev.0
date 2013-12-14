From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/15] sfc: Do not use MAC address as clock name
Date: Sat, 14 Dec 2013 23:01:22 +0000
Message-ID: <1387062082.12172.60.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17268 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab3LNXB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:01:26 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll be sharing clocks between multiple functions with their own MAC
addresses.  The name field is now documented as 'A short "friendly
name" to identify the clock ...' and '... not meant to be a unique
id.'  So use the name 'sfc'.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index aa4876edaac6..5b434597ac63 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -965,9 +965,8 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 	ptp->evt_overflow = false;
 
 	ptp->phc_clock_info.owner = THIS_MODULE;
-	snprintf(ptp->phc_clock_info.name,
-		 sizeof(ptp->phc_clock_info.name),
-		 "%pm", efx->net_dev->perm_addr);
+	strlcpy(ptp->phc_clock_info.name, "sfc",
+		sizeof(ptp->phc_clock_info.name));
 	ptp->phc_clock_info.max_adj = MAX_PPB;
 	ptp->phc_clock_info.n_alarm = 0;
 	ptp->phc_clock_info.n_ext_ts = 0;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
