From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: Use a more sensible cast in
 efx_rx_buf_offset()
Date: Mon, 30 Jan 2012 18:22:19 +0000
Message-ID: <1327947739.2595.9.camel@bwh-desktop>
References: <1327947627.2595.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26056 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753315Ab2A3SWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 13:22:22 -0500
In-Reply-To: <1327947627.2595.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function returns the page offset of the buffer, which can be
calculated based on either its DMA address or its virtual address.  It
used to use the virtual address and we would cast that to unsigned
long, as anything smaller would result in a compiler warning.  Now
that it's using the DMA address we should use unsigned int, matching
the return type.  It is also unnecessary to use __force.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index a33aef2..1dfda5e 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -98,7 +98,7 @@ static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 	/* Offset is always within one page, so we don't need to consider
 	 * the page order.
 	 */
-	return ((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
+	return ((unsigned int) buf->dma_addr & (PAGE_SIZE - 1)) +
 		efx->type->rx_buffer_hash_size;
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
-- 
1.7.7.5


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
