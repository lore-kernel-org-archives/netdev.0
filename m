From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/11] sfc: Fix RX drop filters for EF10
Date: Mon, 16 Dec 2013 21:35:05 +0000
Message-ID: <1387229705.1799.54.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8677 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab3LPVfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:35:09 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we insert an filter, the firmware checks that the given RX queue
index is in range even if it will not be used.  In case we're
inserting a drop filter, pass the value 0.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index d352bdc4e53e..4dfc2296600d 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2245,7 +2245,9 @@ static void efx_ef10_filter_push_prep(struct efx_nic *efx,
 		       MC_CMD_FILTER_OP_IN_RX_DEST_HOST);
 	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_TX_DEST,
 		       MC_CMD_FILTER_OP_IN_TX_DEST_DEFAULT);
-	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_RX_QUEUE, spec->dmaq_id);
+	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_RX_QUEUE,
+		       spec->dmaq_id == EFX_FILTER_RX_DMAQ_ID_DROP ?
+		       0 : spec->dmaq_id);
 	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_RX_MODE,
 		       (spec->flags & EFX_FILTER_FLAG_RX_RSS) ?
 		       MC_CMD_FILTER_OP_IN_RX_MODE_RSS :

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
