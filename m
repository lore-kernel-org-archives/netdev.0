From: Tom Herbert <therbert@google.com>
Subject: [PATCH 01/15] net: bnx2 calls skb_set_hash
Date: Tue, 17 Dec 2013 23:22:57 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172316170.24380@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:41431 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3LRHW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:22:59 -0500
Received: by mail-qc0-f201.google.com with SMTP id r5so736001qcx.4
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:22:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index d9980ad..0ced358 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3234,7 +3234,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		if ((bp->dev->features & NETIF_F_RXHASH) &&
 		    ((status & L2_FHDR_STATUS_USE_RXHASH) ==
 		     L2_FHDR_STATUS_USE_RXHASH))
-			skb->rxhash = rx_hdr->l2_fhdr_hash;
+			skb_set_hash(skb, rx_hdr->l2_fhdr_hash,
+				     PKT_HASH_TYPE_L3);
 
 		skb_record_rx_queue(skb, bnapi - &bp->bnx2_napi[0]);
 		napi_gro_receive(&bnapi->napi, skb);
-- 
1.8.5.1
