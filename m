From: Tom Herbert <therbert@google.com>
Subject: [PATCH 15/17] net: sfc calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:57:19 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252156170.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:33269 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007Ab3KZF5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:57:20 -0500
Received: by mail-ob0-f202.google.com with SMTP id gq1so1117119obb.3
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:57:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
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
