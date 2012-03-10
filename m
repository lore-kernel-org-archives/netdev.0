From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/10] sfc: Update comments on efx_rx_packet_gro()
Date: Sat, 10 Mar 2012 00:49:33 +0000
Message-ID: <1331340573.2537.13.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51233 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758793Ab2CJAtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:49:36 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The in-tree driver has never supported Driverlink.  The rest of the
comments are rather redundant, but we can usefully state what the
requirements are on the buffer state.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 1ba290d..763fa2f 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -449,10 +449,8 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 	efx_rx_queue_channel(rx_queue)->n_rx_overlength++;
 }
 
-/* Pass a received packet up through the generic GRO stack
- *
- * Handles driverlink veto, and passes the fragment up via
- * the appropriate GRO method
+/* Pass a received packet up through GRO.  GRO can handle pages
+ * regardless of checksum state and skbs with a good checksum.
  */
 static void efx_rx_packet_gro(struct efx_channel *channel,
 			      struct efx_rx_buffer *rx_buf,
@@ -461,7 +459,6 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 	struct napi_struct *napi = &channel->napi_str;
 	gro_result_t gro_result;
 
-	/* Pass the skb/page into the GRO engine */
 	if (rx_buf->flags & EFX_RX_BUF_PAGE) {
 		struct efx_nic *efx = channel->efx;
 		struct page *page = rx_buf->u.page;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
