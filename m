From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ieee802154: dont leak skbs in ieee802154_fake_xmit()
Date: Thu, 19 Nov 2009 12:28:10 +0100
Message-ID: <4B052BCA.4020901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59993 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbZKSL2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 06:28:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ieee802154_fake_xmit() should free skbs since it returns NETDEV_TX_OK

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 96a2959..7c544f7 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -260,15 +260,12 @@ static int ieee802154_fake_close(struct net_device *dev)
 static netdev_tx_t ieee802154_fake_xmit(struct sk_buff *skb,
 					      struct net_device *dev)
 {
-	skb->iif = dev->ifindex;
-	skb->dev = dev;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
-	dev->trans_start = jiffies;
-
 	/* FIXME: do hardware work here ... */
 
+	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
