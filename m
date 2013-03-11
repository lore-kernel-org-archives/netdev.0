From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 17/22] sfc: Explicitly prefetch RX hash prefix, not
 just Ethernet heade
Date: Mon, 11 Mar 2013 19:56:55 +0000
Message-ID: <1363031815.2608.54.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16841 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621Ab3CKT46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:56:58 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we prefetch from the Ethernet header, but we will also read
the hash prefix.  In practice they should be in the same cache line
and this won't hurt, but it is still pointless to add on the hash
prefix size.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 23d67d1..8e78a2f 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -458,7 +458,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	/* Prefetch nice and early so data will (hopefully) be in cache by
 	 * the time we look at it.
 	 */
-	prefetch(efx_rx_buf_va(rx_buf) + efx->type->rx_buffer_hash_size);
+	prefetch(efx_rx_buf_va(rx_buf));
 
 	/* Pipeline receives so that we give time for packet headers to be
 	 * prefetched into cache.
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
