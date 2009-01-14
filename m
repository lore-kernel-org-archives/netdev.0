From: Bill Fink <billfink@mindspring.com>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
 2.6.24?
Date: Wed, 14 Jan 2009 04:05:50 -0500
Message-ID: <20090114040550.407c2a0c.billfink@mindspring.com>
References: <20090113063205.GA26047@gondor.apana.org.au>
	<20090113015614.3b815ad7.billfink@mindspring.com>
	<20090113070138.GA26480@gondor.apana.org.au>
	<20090114024341.76ce0dec.billfink@mindspring.com>
	<20090114082910.GC16692@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:59330 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754589AbZANJGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 04:06:10 -0500
In-Reply-To: <20090114082910.GC16692@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2009, Herbert Xu wrote:

> On Wed, Jan 14, 2009 at 02:43:41AM -0500, Bill Fink wrote:
> > 
> > I like that.  If both tcpi_unacked and SIOCOUTQ are zero, that should
> 
> Why do you still need tcpi_unacked? SIOCOUTQ returns the amount
> of all outstanding data so that alone should be good enough.

Well, my man tcp(7) just says:

   SIOCOUTQ
          Returns the amount of unsent data in the socket send queue.  The
          socket must not be in LISTEN state, otherwise an error  (EINVAL)
          is returned.

It's not clear from that that it also includes sent but unacked data.
Perhaps it should be changed to say "the amount of unsent or unacked
data" instead.  On reflection, it makes sense that the send queue
includes sent but unacked as well as never sent data, since the unacked
data may need to be retransmitted.  This all assumes that I'm now
correctly understanding what you're saying/implying (I'm getting tired).

> > The performance argument I gave against INET_DIAG appears to have been
> > bogus.  At least just loading the inet_diag and tcp_diag modules didn't
> > have a significant impact on 10-GigE performance with either 1500-byte
> > packets or 9000-byte jumbo frame packets (CPU usage may have increased
> > slightly but even that's not definite).
> 
> Well if you don't make diag requests diag has zero impact on
> the system.  How much of an impact diag has if you do make requests
> is dependent on the number of open sockets.

Good to know.

						-Bill
