From: Tom Herbert <therbert@google.com>
Subject: Subject: [PATCH 03/17] net: bnx2 calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:48:26 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252146130.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f74.google.com ([209.85.128.74]:63332 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670Ab3KZFs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:48:27 -0500
Received: by mail-qe0-f74.google.com with SMTP id b10so263196qen.5
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:48:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index d9980ad..0d7bea2b 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3234,7 +3234,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		if ((bp->dev->features & NETIF_F_RXHASH) &&
 		    ((status & L2_FHDR_STATUS_USE_RXHASH) ==
 		     L2_FHDR_STATUS_USE_RXHASH))
-			skb->rxhash = rx_hdr->l2_fhdr_hash;
+			skb_set_rxhash(skb, rx_hdr->l2_fhdr_hash,
+				       RXHASH_TYPE_L3);
 
 		skb_record_rx_queue(skb, bnapi - &bp->bnx2_napi[0]);
 		napi_gro_receive(&bnapi->napi, skb);
-- 
1.8.4.1
