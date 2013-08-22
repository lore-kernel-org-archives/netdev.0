From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH RESEND net-next 03/16] sfc: Use efx_mcdi_mon() to find
 efx_mcdi_mon structure from efx_nic
Date: Thu, 22 Aug 2013 20:25:49 +0100
Message-ID: <1377199549.1703.52.camel@bwh-desktop.uk.level5networks.com>
References: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29750 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab3HVTZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:25:53 -0400
In-Reply-To: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This needs to be done before we separate MCDI from siena_nic_data.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_mon.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index 1d552f0..fe42c3b 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -400,8 +400,7 @@ fail:
 
 void efx_mcdi_mon_remove(struct efx_nic *efx)
 {
-	struct siena_nic_data *nic_data = efx->nic_data;
-	struct efx_mcdi_mon *hwmon = &nic_data->hwmon;
+	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
 	unsigned int i;
 
 	for (i = 0; i < hwmon->n_attrs; i++)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
