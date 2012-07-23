From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 11/16] ipv4: Cache input routes in fib_info nexthops.
Date: Mon, 23 Jul 2012 23:00:57 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207232245230.1619@ja.ssi.bg>
References: <20120720.142622.1447419081262029885.davem@davemloft.net> <alpine.LFD.2.00.1207231157590.1626@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43176 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754160Ab2GWTxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 15:53:24 -0400
In-Reply-To: <alpine.LFD.2.00.1207231157590.1626@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 23 Jul 2012, Julian Anastasov wrote:

> 	The problem with rt_iif is worse. May be we
> can cache only the first iif, other packets will see
> different iif in nh_rth_input and will get non-cached
> result. For boxes with 2 or more interfaces only one
> can use the cache. One setup can have large traffic
> from LAN, other can be server for remote clients.

	May be we can replace rt_iif with skb->dev->ifindex ?
If we have dst, there must be skb->dev ? Only for
output routes we should check places that rely on
inet_iif().

Regards

--
Julian Anastasov <ja@ssi.bg>
