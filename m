From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 00:26:23 -0700 (PDT)
Message-ID: <20100422.002623.00784210.davem@davemloft.net>
References: <1271920233.7895.4723.camel@edumazet-laptop>
	<20100422.001625.200862474.davem@davemloft.net>
	<1271921045.7895.4763.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752275Ab0DVH0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:26:19 -0400
In-Reply-To: <1271921045.7895.4763.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Apr 2010 09:24:05 +0200

> Hmm... are you sure we want to call destructor for each skb ?
> 
> Should'nt we do it before initial skb is split ?

Good idea, therefore you mean something like this?

diff --git a/net/core/dev.c b/net/core/dev.c
index 3ba774b..f3c3885 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1865,6 +1865,7 @@ static int dev_gso_segment(struct sk_buff *skb)
 	int features = dev->features & ~(illegal_highdma(dev, skb) ?
 					 NETIF_F_SG : 0);
 
+	skb_orphan_try(skb);
 	segs = skb_gso_segment(skb, features);
 
 	/* Verifying header integrity only. */
