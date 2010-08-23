From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] net: copy_rtnl_link_stats64()
 simplification
Date: Mon, 23 Aug 2010 10:47:04 -0700
Message-ID: <1282585624.1879.103.camel@Joe-Laptop>
References: <1282583676.2486.525.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1289 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811Ab0HWRrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 13:47:07 -0400
In-Reply-To: <1282583676.2486.525.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-23 at 19:14 +0200, Eric Dumazet wrote:
> No need to use a temporary struct rtnl_link_stats64 variable,
> just copy the source to skb buffer.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Maybe it's better to use the same argument style as copy_rtnl_link_stats

 net/core/rtnetlink.c |   36 ++++--------------------------------
 1 files changed, 4 insertions(+), 32 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f78d821..f8781db 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -610,38 +610,10 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 	a->tx_compressed = b->tx_compressed;
 }
 
-static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
+static void copy_rtnl_link_stats64(struct rtnl_link_stats64 *a,
+				   const struct rtnl_link_stats64 *b)
 {
-	struct rtnl_link_stats64 a;
-
-	a.rx_packets = b->rx_packets;
-	a.tx_packets = b->tx_packets;
-	a.rx_bytes = b->rx_bytes;
-	a.tx_bytes = b->tx_bytes;
-	a.rx_errors = b->rx_errors;
-	a.tx_errors = b->tx_errors;
-	a.rx_dropped = b->rx_dropped;
-	a.tx_dropped = b->tx_dropped;
-
-	a.multicast = b->multicast;
-	a.collisions = b->collisions;
-
-	a.rx_length_errors = b->rx_length_errors;
-	a.rx_over_errors = b->rx_over_errors;
-	a.rx_crc_errors = b->rx_crc_errors;
-	a.rx_frame_errors = b->rx_frame_errors;
-	a.rx_fifo_errors = b->rx_fifo_errors;
-	a.rx_missed_errors = b->rx_missed_errors;
-
-	a.tx_aborted_errors = b->tx_aborted_errors;
-	a.tx_carrier_errors = b->tx_carrier_errors;
-	a.tx_fifo_errors = b->tx_fifo_errors;
-	a.tx_heartbeat_errors = b->tx_heartbeat_errors;
-	a.tx_window_errors = b->tx_window_errors;
-
-	a.rx_compressed = b->rx_compressed;
-	a.tx_compressed = b->tx_compressed;
-	memcpy(v, &a, sizeof(a));
+	memcpy(a, b, sizeof(*b));
 }
 
 /* All VF info */


