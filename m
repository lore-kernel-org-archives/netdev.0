From: Bill Fink <billfink@mindspring.com>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
 2.6.24?
Date: Wed, 14 Jan 2009 03:05:31 -0500
Message-ID: <20090114030531.a29680c6.billfink@mindspring.com>
References: <20090113063205.GA26047@gondor.apana.org.au>
	<20090113015614.3b815ad7.billfink@mindspring.com>
	<496C3D5C.7080407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:38923 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752569AbZANIFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 03:05:45 -0500
In-Reply-To: <496C3D5C.7080407@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jan 2009, Rick Jones wrote:

> Bill Fink wrote:
> > On Tue, 13 Jan 2009, Herbert Xu wrote:
> > 
> > 
> >>Bill Fink <billfink@mindspring.com> wrote:
> >>
> >>>If I understand you correctly, to hit this corner case, just after
> >>>the final TCP write, there would have to be no packets in flight
> >>>together with a zero TCP window.  To make it more bullet-proof, I
> >>>guess after seeing a zero tcpi_unacked, an additional small delay
> >>>should be performed, and then rechecking for a zero tcpi_unacked.
> >>>I don't see anything else obvious (to me anyway) in the tcp_info
> >>>that would be particularly helpful in handling this.
> >>
> >>What's wrong with idiag_wqueue? Isn't that a much more direct
> >>way to get this?
> > 
> > 
> > I'm not familiar with idiag_wqueue, but it sounds like it has something
> > to do with INET_DIAG/INET_TCP_DIAG.  It was a long time ago, but I seem
> > to recall that using INET_DIAG had a negative impact on performance,
> > and since the main point of nuttcp is to measure TCP/UDP performance,
> > that would be contrary to its primary purpose.  Also, I don't want to
> > rely on something that's not guaranteed to be part of the running kernel.
> 
> How likely is it that the "additional small delay" above would be much 
> less than waiting for a read return of zero after a shutdown(SHUT_WR) call?

I'm not sure I understand what you're getting at.  I did consider doing
something like what you suggested, but in the end decided it was simpler
to deal with a fully ESTABLISHED connection, than worrying about possible
races with a socket being (partially or fully) closed.

						-Bill
