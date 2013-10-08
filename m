From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/6] sfc: Add rmb() between reading stats and
 generation count to ensure consistency
Date: Tue, 8 Oct 2013 18:42:43 +0100
Message-ID: <1381254163.1530.10.camel@bwh-desktop.uk.level5networks.com>
References: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56405 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab3JHRmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:42:47 -0400
In-Reply-To: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 9f18ae9..a4fbb38 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -545,6 +545,7 @@ static int efx_ef10_try_update_nic_stats(struct efx_nic *efx)
 	rmb();
 	efx_nic_update_stats(efx_ef10_stat_desc, EF10_STAT_COUNT, stats_mask,
 			     stats, efx->stats_buffer.addr, false);
+	rmb();
 	generation_start = dma_stats[MC_CMD_MAC_GENERATION_START];
 	if (generation_end != generation_start)
 		return -EAGAIN;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
