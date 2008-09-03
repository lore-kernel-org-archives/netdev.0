From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: wan/hdlc_x25.c: fix a NULL dereference
Date: Wed, 03 Sep 2008 18:21:56 +0200
Message-ID: <m37i9tkxnf.fsf_-_@maximus.localdomain>
References: <20080827220549.GS11734@cs181140183.pp.htv.fi>
	<m3bpz9glik.fsf@maximus.localdomain> <48BE9B52.8050003@garzik.org>
	<m3bpz5kxzj.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@kernel.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:51202 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351AbYICQV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 12:21:58 -0400
In-Reply-To: <m3bpz5kxzj.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Wed\, 03 Sep 2008 18\:14\:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WAN: fixes a NULL dereference in hdlc_x25.

Reported-by: Adrian Bunk <bunk@kernel.org>.
Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index 8b7e5d2..cbcbf6f 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -163,15 +163,17 @@ static void x25_close(struct net_device *dev)
 
 static int x25_rx(struct sk_buff *skb)
 {
+	struct net_device *dev = skb->dev;
+
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		skb->dev->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return NET_RX_DROP;
 	}
 
-	if (lapb_data_received(skb->dev, skb) == LAPB_OK)
+	if (lapb_data_received(dev, skb) == LAPB_OK)
 		return NET_RX_SUCCESS;
 
-	skb->dev->stats.rx_errors++;
+	dev->stats.rx_errors++;
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
