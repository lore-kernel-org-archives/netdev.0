From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/13] sfc: Delete redundant page_addr variable
 from efx_init_rx_buffers_page()
Date: Sat, 1 Dec 2012 04:42:05 +0000
Message-ID: <1354336925.2640.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26130 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab2LAEmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:42:08 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 9e0ad1b..d780a0d 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -187,7 +187,6 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 	struct efx_nic *efx = rx_queue->efx;
 	struct efx_rx_buffer *rx_buf;
 	struct page *page;
-	void *page_addr;
 	struct efx_rx_page_state *state;
 	dma_addr_t dma_addr;
 	unsigned index, count;
@@ -207,12 +206,10 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 			__free_pages(page, efx->rx_buffer_order);
 			return -EIO;
 		}
-		page_addr = page_address(page);
-		state = page_addr;
+		state = page_address(page);
 		state->refcnt = 0;
 		state->dma_addr = dma_addr;
 
-		page_addr += sizeof(struct efx_rx_page_state);
 		dma_addr += sizeof(struct efx_rx_page_state);
 
 	split:
@@ -230,7 +227,6 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 			/* Use the second half of the page */
 			get_page(page);
 			dma_addr += (PAGE_SIZE >> 1);
-			page_addr += (PAGE_SIZE >> 1);
 			++count;
 			goto split;
 		}
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
