From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH 2/3] xfrm: Increase the garbage collector threshold
Date: Mon, 16 Dec 2013 15:29:50 +0100
Message-ID: <1387204190.25449.68.camel@sakura.staff.proxad.net>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
	 <1383294107-7509-3-git-send-email-steffen.klassert@secunet.com>
	 <1386686323.22947.26.camel@sakura.staff.proxad.net>
	 <20131213101203.GO31491@secunet.com>
	 <1386951209.25449.61.camel@sakura.staff.proxad.net>
	 <20131216115145.GH31491@secunet.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:43701 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781Ab3LPO3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 09:29:51 -0500
In-Reply-To: <20131216115145.GH31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2013-12-16 at 12:51 +0100, Steffen Klassert wrote:

> >   while :; do wget -O /dev/null http://remote_host/; done
> > 
> > I was surprised to see it fails after only 1024 requests (ENOBUF on
> > connect), and how long I had to wait to be able to do new requests.
> > 
> > After debugging I saw that the xfrm gc was called but was not able to
> > release anything.
> > 
> > after running "ip route flush cache", which forces all ipv4 dst entries
> > to be released, suddenly the xfrm gc had something to free, and xfrm
> > entry count went to zero.
> 
> Well, "ip route flush cache" bumps the rt_genid what marks all
> routes as invalid. The xfrm garbage collector will notice this
> on the next run and deletes all invalid cached routes.
> 
> Garbage collecting is different from flushing, it only removes
> stale routes and keeps everything that was used recently. That's
> the whole point of this caching, we cache recently used IPsec
> routes to avoid a slow path lookup.

ok I don't know this part of the code at all.

but if it is only a *cache*, then it should not limit any new
allocations for the reason that the cache is full, it should take slow
path instead.

-- 
Maxime
