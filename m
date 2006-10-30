From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,try2 2/3] ep93xx_eth: fix unlikely(x) > y test
Date: Mon, 30 Oct 2006 19:52:54 +0100
Message-ID: <20061030185254.GC14805@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ray Lehtiniemi <rayl@mail.com>,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:48051 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1030575AbWJ3Swz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:52:55 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix unlikely(x) > y test in ep93xx_eth.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Index: linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
===================================================================
--- linux-2.6.19-rc3.orig/drivers/net/arm/ep93xx_eth.c
+++ linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
@@ -334,7 +334,7 @@ static int ep93xx_xmit(struct sk_buff *s
 	struct ep93xx_priv *ep = netdev_priv(dev);
 	int entry;
 
-	if (unlikely(skb->len) > MAX_PKT_SIZE) {
+	if (unlikely(skb->len > MAX_PKT_SIZE)) {
 		ep->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
