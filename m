From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 01/10] sfc: Use MCDI RX_BAD_FCS_PKTS count as
 MAC rx_bad count
Date: Fri, 10 Sep 2010 17:41:00 +0100
Message-ID: <1284136860.2267.95.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25459 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab0IJQlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:41:04 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calculating rx_bad as rx_packets - rx_good is unnecessary and
incorrect, since rx_good does not include control frames (e.g.
pause frames) and rx_packets does.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/siena.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 3fab030..9f53680 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -450,7 +450,7 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 				    mac_stats->rx_bad_bytes);
 	MAC_STAT(rx_packets, RX_PKTS);
 	MAC_STAT(rx_good, RX_GOOD_PKTS);
-	mac_stats->rx_bad = mac_stats->rx_packets - mac_stats->rx_good;
+	MAC_STAT(rx_bad, RX_BAD_FCS_PKTS);
 	MAC_STAT(rx_pause, RX_PAUSE_PKTS);
 	MAC_STAT(rx_control, RX_CONTROL_PKTS);
 	MAC_STAT(rx_unicast, RX_UNICAST_PKTS);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

