From: Tom Herbert <therbert@google.com>
Subject: [PATCH 14/15] net: sun-niu calls skb_set_hash
Date: Tue, 17 Dec 2013 23:32:00 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172328520.24772@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:45915 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3LRHcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:32:01 -0500
Received: by mail-ob0-f201.google.com with SMTP id wp4so1464967obc.2
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:32:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/sun/niu.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 388540f..8e2266e 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3493,10 +3493,12 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 
 	rh = (struct rx_pkt_hdr1 *) skb->data;
 	if (np->dev->features & NETIF_F_RXHASH)
-		skb->rxhash = ((u32)rh->hashval2_0 << 24 |
-			       (u32)rh->hashval2_1 << 16 |
-			       (u32)rh->hashval1_1 << 8 |
-			       (u32)rh->hashval1_2 << 0);
+		skb_set_hash(skb,
+			     ((u32)rh->hashval2_0 << 24 |
+			      (u32)rh->hashval2_1 << 16 |
+			      (u32)rh->hashval1_1 << 8 |
+			      (u32)rh->hashval1_2 << 0),
+			     PKT_HASH_TYPE_L3);
 	skb_pull(skb, sizeof(*rh));
 
 	rp->rx_packets++;
-- 
1.8.5.1
