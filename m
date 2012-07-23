From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/16] ipv4: Cache input routes in fib_info nexthops.
Date: Mon, 23 Jul 2012 12:58:37 -0700 (PDT)
Message-ID: <20120723.125837.2165279339112720363.davem@davemloft.net>
References: <20120720.142622.1447419081262029885.davem@davemloft.net>
	<alpine.LFD.2.00.1207231157590.1626@ja.ssi.bg>
	<alpine.LFD.2.00.1207232245230.1619@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160Ab2GWT6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 15:58:40 -0400
In-Reply-To: <alpine.LFD.2.00.1207232245230.1619@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 23 Jul 2012 23:00:57 +0300 (EEST)

> 	May be we can replace rt_iif with skb->dev->ifindex ?
> If we have dst, there must be skb->dev ? Only for
> output routes we should check places that rely on
> inet_iif().

Right, just as I was drinking my first coffee after reading
your previous email I was thinking about this.

The only time skb->dev->ifindex can change from rt->rt_iif is when we
demux a tunnel, but at that point we would first reinject and do
another route lookup, at which point rt->rt_iif would match again.

And this is the intended semantic of this field anyways.

I'll look into what we can do here, and I'll also try to come up
with some ideas wrt. the DIRECTSRC issue as well.

Thanks Julian.
