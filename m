From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Fri, 15 Aug 2008 13:58:51 -0700 (PDT)
Message-ID: <20080815.135851.231414180.davem@davemloft.net>
References: <20080815073343.GA20644@gondor.apana.org.au>
	<20080815081442.GA20971@gondor.apana.org.au>
	<20080815103235.GA31963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, kaber@trash.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39019
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751454AbYHOU6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 16:58:51 -0400
In-Reply-To: <20080815103235.GA31963@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 15 Aug 2008 20:32:35 +1000

> loopback: Enable TSO
> 
> This patch enables TSO since the loopback device is naturally
> capable of handling packets of any size.  This also means that
> we won't enable GSO on lo which is good until GSO is fixed to
> preserve netfilter state as netfilter treats loopback packets
> in a special way.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This, effectively, "enables" LRO on loopback.

And sure it's pretty obscure to shape, NAT, and end up forwarding
loopback received packets, but do you want to be the user trying to do
something like that and trying to find this particular patch which is
causing it to not work? :-)

I really don't know whether it's worth worrying about, I just wanted
to mention it.
