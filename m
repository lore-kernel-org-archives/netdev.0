From: David Miller <davem@davemloft.net>
Subject: Re: Kernel problem
Date: Fri, 27 Feb 2009 00:59:07 -0800 (PST)
Message-ID: <20090227.005907.94994126.davem@davemloft.net>
References: <20090226130631.GA14125@gondor.apana.org.au>
	<20090227041136.GA21468@gondor.apana.org.au>
	<20090227084109.GA4156@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ash@sevsky.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46247
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752521AbZB0I7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 03:59:23 -0500
In-Reply-To: <20090227084109.GA4156@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 27 Feb 2009 08:41:10 +0000

> Probably I miss something, but I'm not sure it's really necessary in
> all (non-VLAN) entry points. Of course it's an optimization to drop
> these things early, but there is a lot off mess with replicating
> various parts of netif_receive_skb() in so many places.
> 
> As a matter of fact, I wonder why it can't be done in one place, e.g.
> netif_nit_deliver(), which was created partly for similar problems.

I think we do need to hit all possible entry points.

How would you be able to handle it in netif_nit_deliver()?
Functions like netif_receive_skb() open-code the delivery to
network taps, they don't actually call netif_receive_skb().
