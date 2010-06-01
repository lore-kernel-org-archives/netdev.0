From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/12] sfc: Only count bad packets in rx_errors
Date: Tue, 01 Jun 2010 22:21:05 +0100
Message-ID: <1275427265.2114.35.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50852 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757233Ab0FAVVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:21:12 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx_errors is defined as 'bad packets received', but we are currently
including various overflow errors as well.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index aae3347..26b0cc2 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1518,11 +1518,8 @@ static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
 	stats->tx_window_errors = mac_stats->tx_late_collision;
 
 	stats->rx_errors = (stats->rx_length_errors +
-			    stats->rx_over_errors +
 			    stats->rx_crc_errors +
 			    stats->rx_frame_errors +
-			    stats->rx_fifo_errors +
-			    stats->rx_missed_errors +
 			    mac_stats->rx_symbol_error);
 	stats->tx_errors = (stats->tx_window_errors +
 			    mac_stats->tx_bad);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

