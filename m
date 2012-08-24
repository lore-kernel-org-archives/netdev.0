From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/16] sfc: Improve log messages in case we abort
 probe due to a pending reset
Date: Fri, 24 Aug 2012 20:52:10 +0100
Message-ID: <1345837930.2694.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56800 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760132Ab2HXTwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:52:13 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current informational message doesn't properly explain what
happens, and could also appear if we defer a reset during
suspend/resume.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 977fc3a..5555e9f 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2311,11 +2311,8 @@ static void efx_reset_work(struct work_struct *data)
 
 	/* If we're not READY then don't reset. Leave the reset_pending
 	 * flags set so that efx_pci_probe_main will be retried */
-	if (efx->state != STATE_READY) {
-		netif_info(efx, drv, efx->net_dev,
-			   "scheduled reset quenched; NIC not ready\n");
+	if (efx->state != STATE_READY)
 		return;
-	}
 
 	rtnl_lock();
 	(void)efx_reset(efx, fls(pending) - 1);
@@ -2703,6 +2700,8 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	 * probably hosed anyway.
 	 */
 	if (efx->reset_pending) {
+		netif_err(efx, probe, efx->net_dev,
+			  "aborting probe due to scheduled reset\n");
 		rc = -EIO;
 		goto fail4;
 	}
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
