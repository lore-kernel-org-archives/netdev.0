From: Tom Herbert <therbert@google.com>
Subject: [PATCH 13/15] net: sfc calls skb_set_hash
Date: Tue, 17 Dec 2013 23:31:50 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172329300.24419@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f73.google.com ([209.85.128.73]:62619 "EHLO
	mail-qe0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3LRHbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:31:51 -0500
Received: by mail-qe0-f73.google.com with SMTP id 5so735565qeb.2
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:31:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/sfc/rx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 1fde9b8..48588dd 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -440,7 +440,8 @@ efx_rx_packet_gro(struct efx_channel *channel, struct efx_rx_buffer *rx_buf,
 	}
 
 	if (efx->net_dev->features & NETIF_F_RXHASH)
-		skb->rxhash = efx_rx_buf_hash(efx, eh);
+		skb_set_hash(skb, efx_rx_buf_hash(efx, eh),
+			     PKT_HASH_TYPE_L3);
 	skb->ip_summed = ((rx_buf->flags & EFX_RX_PKT_CSUMMED) ?
 			  CHECKSUM_UNNECESSARY : CHECKSUM_NONE);
 
-- 
1.8.5.1
