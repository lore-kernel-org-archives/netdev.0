From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/17] sfc: Record RX queue number on GRO path
Date: Tue, 24 Nov 2009 02:02:40 +0000
Message-ID: <1259028160.14645.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34619 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757785AbZKXCCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:02:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 9e33391..9f22d15 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -473,6 +473,8 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 		skb->ip_summed =
 			checksummed ? CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 
+		skb_record_rx_queue(skb, channel->channel);
+
 		gro_result = napi_gro_frags(napi);
 	} else {
 		struct sk_buff *skb = rx_buf->skb;
@@ -578,6 +580,8 @@ void __efx_rx_packet(struct efx_channel *channel,
 		 * at the ethernet header */
 		rx_buf->skb->protocol = eth_type_trans(rx_buf->skb,
 						       efx->net_dev);
+
+		skb_record_rx_queue(rx_buf->skb, channel->channel);
 	}
 
 	if (likely(checksummed || rx_buf->page)) {
@@ -593,8 +597,6 @@ void __efx_rx_packet(struct efx_channel *channel,
 	/* Set the SKB flags */
 	skb->ip_summed = CHECKSUM_NONE;
 
-	skb_record_rx_queue(skb, channel->channel);
-
 	/* Pass the packet up */
 	netif_receive_skb(skb);
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

