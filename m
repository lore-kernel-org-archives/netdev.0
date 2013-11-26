From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 16/17] net: sun-niu calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:34:32 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260932120.21138@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:64102 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab3KZRee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:34:34 -0500
Received: by mail-vb0-f74.google.com with SMTP id w8so633080vbj.5
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:34:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/sun/niu.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 388540f..805808d 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3493,10 +3493,12 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 
 	rh = (struct rx_pkt_hdr1 *) skb->data;
 	if (np->dev->features & NETIF_F_RXHASH)
-		skb->rxhash = ((u32)rh->hashval2_0 << 24 |
-			       (u32)rh->hashval2_1 << 16 |
-			       (u32)rh->hashval1_1 << 8 |
-			       (u32)rh->hashval1_2 << 0);
+		skb_set_rxhash(skb,
+			       ((u32)rh->hashval2_0 << 24 |
+				(u32)rh->hashval2_1 << 16 |
+				(u32)rh->hashval1_1 << 8 |
+				(u32)rh->hashval1_2 << 0),
+			       RXHASH_TYPE_L3);
 	skb_pull(skb, sizeof(*rh));
 
 	rp->rx_packets++;
-- 
1.8.4.1
