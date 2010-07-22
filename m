From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: macvtap: Limit packet queue length
Date: Thu, 22 Jul 2010 11:30:53 +0200
Message-ID: <201007221130.53612.arnd@arndb.de>
References: <20100722064157.GA25913@gondor.apana.org.au> <20100722074431.GA26744@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mark Wagner <mwagner@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:51305 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab0GVJbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 05:31:19 -0400
In-Reply-To: <20100722074431.GA26744@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 July 2010, Herbert Xu wrote:
> On Thu, Jul 22, 2010 at 02:41:57PM +0800, Herbert Xu wrote:
> > Hi:
> > 
> > macvtap: Limit packet queue length
> 
> Chris has informed me that he's already tried a similar patch
> and it only makes the problem worse :)
> 
> The issue is that the macvtap TX queue length defaults to zero.
> 
> So here is an updated patch which addresses this:

Thanks for debugging this and coming up with a solution.
I'm currently travelling, so I can't easily work on it myself.

> Please note that macvtap currently has no way of giving congestion
> notification, that means the software device TX queue cannot be
> used and packets will always be dropped once the macvtap driver
> queue fills up.

This is something I was planning to look into for doing it right,
and then I forgot about it. I'll investigate what could be done
to get proper flow control once I get back to the office.

> Chris Wright noticed that for this patch to work, we need a
> non-zero TX queue length.  This patch includes his work to change
> the default macvtap TX queue length to 500.

The only problem I can see with this patch is making it depend on
the *TX* queue length. The point is that unlike tun/tap, the
macvtap network interface's point of view is that this is the
receive queue, not the transmit queue.

In the TX direction, we really don't queue, since we simply forward
to the lowerdev tx queue, so exposing the tunable to user space
as the tx queue length is a little bit awkward, as well as inconsistent
between macvtap and macvlan.

> Reported-by: Mark Wagner <mwagner@redhat.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

As long as we're missing a better solution,

Acked-by: Arnd Bergmann <arnd@arndb.de>
