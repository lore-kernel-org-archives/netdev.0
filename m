From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 2/2] sfc: Correct efx_rx_buffer::page_offset when
 EFX_PAGE_IP_ALIGN != 0
Date: Wed, 6 Mar 2013 19:29:11 +0000
Message-ID: <1362598151.3126.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362597261.3126.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55970 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab3CFT3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:29:14 -0500
In-Reply-To: <1362597261.3126.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX DMA buffers start at an offset of EFX_PAGE_IP_ALIGN bytes from the
start of a cache line.  This offset obviously needs to be included in
the virtual address, but this was missed in commit b590ace09d51
('sfc: Fix efx_rx_buf_offset() in the presence of swiotlb') since
EFX_PAGE_IP_ALIGN is equal to 0 on both x86 and powerpc.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 879ff58..bb579a6 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -215,7 +215,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->u.page = page;
-		rx_buf->page_offset = page_offset;
+		rx_buf->page_offset = page_offset + EFX_PAGE_IP_ALIGN;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
 		rx_buf->flags = EFX_RX_BUF_PAGE;
 		++rx_queue->added_count;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
