From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 49/52] sfc: Insert read memory barrier after checking MAC statistics flag
Date: Mon, 1 Sep 2008 12:50:08 +0100
Message-ID: <20080901115007.GP7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35429 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758218AbYIALuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:50:10 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This prevents speculative reading of the statistics before the
completion flag.

From: Neil Turton <nturton@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 70c681e..3a5289f 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1953,8 +1953,10 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
 
 	/* Wait for transfer to complete */
 	for (i = 0; i < 400; i++) {
-		if (*(volatile u32 *)dma_done == FALCON_STATS_DONE)
+		if (*(volatile u32 *)dma_done == FALCON_STATS_DONE) {
+			rmb(); /* Ensure the stats are valid. */
 			return 0;
+		}
 		udelay(10);
 	}
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

