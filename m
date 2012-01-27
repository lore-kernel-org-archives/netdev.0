From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/32] sfc: Remove parentheses around return
 expressions, reported by checkpatch
Date: Fri, 27 Jan 2012 20:42:56 +0000
Message-ID: <1327696976.2503.10.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63477 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751936Ab2A0Um7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:42:59 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following error:

ERROR: return is not a function, parentheses are not required

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index aca3498..3572c34 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -98,8 +98,8 @@ static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 	/* Offset is always within one page, so we don't need to consider
 	 * the page order.
 	 */
-	return (((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
-		efx->type->rx_buffer_hash_size);
+	return ((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
+		efx->type->rx_buffer_hash_size;
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 {
@@ -111,8 +111,7 @@ static u8 *efx_rx_buf_eh(struct efx_nic *efx, struct efx_rx_buffer *buf)
 	if (buf->is_page)
 		return page_address(buf->u.page) + efx_rx_buf_offset(efx, buf);
 	else
-		return ((u8 *)buf->u.skb->data +
-			efx->type->rx_buffer_hash_size);
+		return (u8 *)buf->u.skb->data + efx->type->rx_buffer_hash_size;
 }
 
 static inline u32 efx_rx_buf_hash(const u8 *eh)
@@ -122,10 +121,10 @@ static inline u32 efx_rx_buf_hash(const u8 *eh)
 	return __le32_to_cpup((const __le32 *)(eh - 4));
 #else
 	const u8 *data = eh - 4;
-	return ((u32)data[0]       |
-		(u32)data[1] << 8  |
-		(u32)data[2] << 16 |
-		(u32)data[3] << 24);
+	return (u32)data[0]	  |
+	       (u32)data[1] << 8  |
+	       (u32)data[2] << 16 |
+	       (u32)data[3] << 24;
 #endif
 }
 
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
