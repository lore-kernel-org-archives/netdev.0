From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/17] sfc: Remove redundant gotos from __efx_rx_packet()
Date: Tue, 24 Nov 2009 02:01:44 +0000
Message-ID: <1259028104.14645.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34531 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757457AbZKXCBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:01:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function no longer has any common cleanup code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index a60c718..32cfe40 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -564,7 +564,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 	if (unlikely(efx->loopback_selftest)) {
 		efx_loopback_rx_packet(efx, rx_buf->data, rx_buf->len);
 		efx_free_rx_buffer(efx, rx_buf);
-		goto done;
+		return;
 	}
 
 	if (rx_buf->skb) {
@@ -580,7 +580,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 
 	if (likely(checksummed || rx_buf->page)) {
 		efx_rx_packet_lro(channel, rx_buf, checksummed);
-		goto done;
+		return;
 	}
 
 	/* We now own the SKB */
@@ -601,9 +601,6 @@ void __efx_rx_packet(struct efx_channel *channel,
 
 	/* Update allocation strategy method */
 	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
-
-done:
-	;
 }
 
 void efx_rx_strategy(struct efx_channel *channel)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

