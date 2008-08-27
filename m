From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] wan/hdlc_x25.c: fix a NULL dereference
Date: Thu, 28 Aug 2008 01:05:49 +0300
Message-ID: <20080827220549.GS11734@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Krzysztof =?utf-8?Q?Ha=C5=82asa?= <khc@pm.waw.pl>,
	Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40325 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbYH0WGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 18:06:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I doubt stats matter much in this case, and this anyway was a
NULL dereference.

Reported-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
28711620a5326efc71d5228eeff5a28fed9355be 
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index 8b7e5d2..7599e37 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -163,10 +163,8 @@ static void x25_close(struct net_device *dev)
 
 static int x25_rx(struct sk_buff *skb)
 {
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		skb->dev->stats.rx_dropped++;
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
 		return NET_RX_DROP;
-	}
 
 	if (lapb_data_received(skb->dev, skb) == LAPB_OK)
 		return NET_RX_SUCCESS;

