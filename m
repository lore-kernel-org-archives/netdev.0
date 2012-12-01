From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/13] sfc: Fix check for failure of
 MC_CMD_FLUSH_RX_QUEUES
Date: Sat, 1 Dec 2012 04:42:14 +0000
Message-ID: <1354336934.2640.44.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26143 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab2LAEmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:42:17 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_mcdi_rpc_start() returns a negative value on error or zero on
success.  However one caller that can't properly handle failure then
does WARN_ON(rc > 0).  Change it to WARN_ON(rc < 0).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index aea43cb..e1967fb 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1216,7 +1216,7 @@ int efx_mcdi_flush_rxqs(struct efx_nic *efx)
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_FLUSH_RX_QUEUES, (u8 *)qid,
 			  count * sizeof(*qid), NULL, 0, NULL);
-	WARN_ON(rc > 0);
+	WARN_ON(rc < 0);
 
 	kfree(qid);
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
