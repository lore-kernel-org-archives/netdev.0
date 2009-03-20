From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: remove useless prefetch() call
Date: Fri, 20 Mar 2009 09:32:53 +0100
Message-ID: <49C354B5.3060404@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55443 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693AbZCTIdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:33:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no point to use prefetch() call here.
start_xmit() is a function like others...

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/core/dev.c b/net/core/dev.c
index c013031..c97e27d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1670,7 +1670,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc;
 
-	prefetch(&dev->netdev_ops->ndo_start_xmit);
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
