From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: Fix transposed ptp_{under,over}size_sync_windows
 statistics
Date: Fri, 17 Jan 2014 19:48:17 +0000
Message-ID: <52D98901.2020201@solarflare.com>
References: <52D98860.4020402@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38223 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbaAQTsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:48:21 -0500
In-Reply-To: <52D98860.4020402@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

Somehow I transposed these two while bringing the original statistics
support upstream.

Fixes: 99691c4ac112 ('sfc: Add PTP counters to ethtool stats')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 7aa0708..eb75fbd 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -753,9 +753,9 @@ efx_ptp_process_times(struct efx_nic *efx, MCDI_DECLARE_STRUCT_PTR(synch_buf),
 		if (window < SYNCHRONISATION_GRANULARITY_NS) {
 			++ptp->invalid_sync_windows;
 		} else if (corrected >= MAX_SYNCHRONISATION_NS) {
-			++ptp->undersize_sync_windows;
-		} else if (corrected < ptp->min_synchronisation_ns) {
 			++ptp->oversize_sync_windows;
+		} else if (corrected < ptp->min_synchronisation_ns) {
+			++ptp->undersize_sync_windows;
 		} else {
 			ngood++;
 			last_good = i;
