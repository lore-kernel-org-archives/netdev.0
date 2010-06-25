From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 4/4] sfc: Log clearer error messages for
 hardware monitor
Date: Fri, 25 Jun 2010 18:06:29 +0100
Message-ID: <1277485589.2094.17.camel@achroite.uk.solarflarecom.com>
References: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jesper Dangaard Brouer <jdb@comx.dk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20412 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab0FYRGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 13:06:32 -0400
In-Reply-To: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_boards.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 92b35e3..3d950c2 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -108,10 +108,15 @@ static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
 	if (alarms1 || alarms2) {
 		netif_err(efx, hw, efx->net_dev,
 			  "LM87 detected a hardware failure (status %02x:%02x)"
-			  "%s%s\n",
+			  "%s%s%s\n",
 			  alarms1, alarms2,
-			  (alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
-			  (alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
+			  (alarms1 & LM87_ALARM_TEMP_INT) ?
+			  "; board is overheating" : "",
+			  (alarms1 & LM87_ALARM_TEMP_EXT1) ?
+			  "; controller is overheating" : "",
+			  (alarms1 & ~(LM87_ALARM_TEMP_INT | LM87_ALARM_TEMP_EXT1)
+			   || alarms2) ?
+			  "; electrical fault" : "");
 		return -ERANGE;
 	}
 
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

