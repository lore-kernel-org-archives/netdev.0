From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/3] sfc: Use skb_fill_page_desc() to simplify
 passing of page buffers to GRO
Date: Fri, 16 Dec 2011 20:12:46 +0000
Message-ID: <1324066366.2798.22.camel@bwh-desktop>
References: <1324066213.2798.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26441 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932649Ab1LPUMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:12:49 -0500
In-Reply-To: <1324066213.2798.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 955b149..aca3498 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -479,11 +479,8 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 		if (efx->net_dev->features & NETIF_F_RXHASH)
 			skb->rxhash = efx_rx_buf_hash(eh);
 
-		skb_frag_set_page(skb, 0, page);
-		skb_shinfo(skb)->frags[0].page_offset =
-			efx_rx_buf_offset(efx, rx_buf);
-		skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx_buf->len);
-		skb_shinfo(skb)->nr_frags = 1;
+		skb_fill_page_desc(skb, 0, page,
+				   efx_rx_buf_offset(efx, rx_buf), rx_buf->len);
 
 		skb->len = rx_buf->len;
 		skb->data_len = rx_buf->len;
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
