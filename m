From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 03/17] net: bnx2 calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:22:47 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260914010.21143@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:50161 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932406Ab3KZRWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:22:48 -0500
Received: by mail-vc0-f201.google.com with SMTP id ie18so631852vcb.2
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:22:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
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
