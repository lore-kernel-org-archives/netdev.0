From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/16] sfc: Merged efx_page_offset() into efx_rx_buf_offset()
Date: Fri, 16 May 2008 21:16:31 +0100
Message-ID: <20080516201631.GZ28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53588 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757085AbYEPUW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:22:26 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index f15d332..88f87ef 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -86,16 +86,12 @@ static unsigned int rx_refill_limit = 95;
  */
 #define EFX_RXD_HEAD_ROOM 2
 
-static inline unsigned int efx_page_offset(void *p)
-{
-	return (__force unsigned int)p & (PAGE_SIZE - 1);
-}
 static inline unsigned int efx_rx_buf_offset(struct efx_rx_buffer *buf)
 {
 	/* Offset is always within one page, so we don't need to consider
 	 * the page order.
 	 */
-	return efx_page_offset(buf->data);
+	return (__force unsigned long) buf->data & (PAGE_SIZE - 1);
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 {
@@ -291,10 +287,10 @@ static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
 				      EFX_PAGE_IP_ALIGN);
 	}
 
-	offset = efx_page_offset(rx_queue->buf_data);
 	rx_buf->len = bytes;
-	rx_buf->dma_addr = rx_queue->buf_dma_addr + offset;
 	rx_buf->data = rx_queue->buf_data;
+	offset = efx_rx_buf_offset(rx_buf);
+	rx_buf->dma_addr = rx_queue->buf_dma_addr + offset;
 
 	/* Try to pack multiple buffers per page */
 	if (efx->rx_buffer_order == 0) {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
