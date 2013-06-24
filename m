From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/9] sfc: Enable RX checksum offload for packets
 not handled by GRO
Date: Mon, 24 Jun 2013 21:13:04 +0100
Message-ID: <1372104784.1896.31.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17281 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab3FXUNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:13:08 -0400
In-Reply-To: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index a7dfe36..b915e09 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -598,6 +598,8 @@ static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
 
 	/* Set the SKB flags */
 	skb_checksum_none_assert(skb);
+	if (likely(rx_buf->flags & EFX_RX_PKT_CSUMMED))
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	if (channel->type->receive_skb)
 		if (channel->type->receive_skb(channel, skb))


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
