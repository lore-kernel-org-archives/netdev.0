From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 15/17] net: sfc calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:34:24 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260932110.21031@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f74.google.com ([209.85.160.74]:48767 "EHLO
	mail-pb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab3KZReZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:34:25 -0500
Received: by mail-pb0-f74.google.com with SMTP id uo5so842015pbc.5
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:34:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/sfc/rx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8f09e68..b51466e 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -439,7 +439,8 @@ efx_rx_packet_gro(struct efx_channel *channel, struct efx_rx_buffer *rx_buf,
 	}
 
 	if (efx->net_dev->features & NETIF_F_RXHASH)
-		skb->rxhash = efx_rx_buf_hash(efx, eh);
+		skb_set_rxhash(skb, efx_rx_buf_hash(efx, eh),
+			       RXHASH_TYPE_L3);
 	skb->ip_summed = ((rx_buf->flags & EFX_RX_PKT_CSUMMED) ?
 			  CHECKSUM_UNNECESSARY : CHECKSUM_NONE);
 
-- 
1.8.4.1
