From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 02/10] sfc: Accumulate RX_NODESC_DROP count in
 rx_dropped, not rx_over_errors
Date: Fri, 10 Sep 2010 17:41:06 +0100
Message-ID: <1284136866.2267.96.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25488 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755781Ab0IJQlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:41:09 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx_over_errors appears to be intended as a count of packets that
overflow a packet buffer in the NIC.  Given that we implement a
cut-through receive path, this should always be 0.

rx_dropped appears to be the correct counter for packets dropped due
to lack of host buffers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ba674c5..b385f89 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1546,11 +1546,11 @@ static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_dev, struc
 	stats->tx_packets = mac_stats->tx_packets;
 	stats->rx_bytes = mac_stats->rx_bytes;
 	stats->tx_bytes = mac_stats->tx_bytes;
+	stats->rx_dropped = efx->n_rx_nodesc_drop_cnt;
 	stats->multicast = mac_stats->rx_multicast;
 	stats->collisions = mac_stats->tx_collision;
 	stats->rx_length_errors = (mac_stats->rx_gtjumbo +
 				   mac_stats->rx_length_error);
-	stats->rx_over_errors = efx->n_rx_nodesc_drop_cnt;
 	stats->rx_crc_errors = mac_stats->rx_bad;
 	stats->rx_frame_errors = mac_stats->rx_align_error;
 	stats->rx_fifo_errors = mac_stats->rx_overflow;
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

