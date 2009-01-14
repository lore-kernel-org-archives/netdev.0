From: Bill Fink <billfink@mindspring.com>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
 2.6.24?
Date: Wed, 14 Jan 2009 03:32:43 -0500
Message-ID: <20090114033243.49c54c19.billfink@mindspring.com>
References: <20090113063205.GA26047@gondor.apana.org.au>
	<20090113015614.3b815ad7.billfink@mindspring.com>
	<496C3D5C.7080407@hp.com>
	<20090114030531.a29680c6.billfink@mindspring.com>
	<496D9D8A.8080804@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:37939
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756950AbZANIc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 03:32:57 -0500
In-Reply-To: <496D9D8A.8080804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2009, Rick Jones wrote:

> >>How likely is it that the "additional small delay" above would be much 
> >>less than waiting for a read return of zero after a shutdown(SHUT_WR) call?
> > 
> > 
> > I'm not sure I understand what you're getting at.  I did consider doing
> > something like what you suggested, but in the end decided it was simpler
> > to deal with a fully ESTABLISHED connection, than worrying about possible
> > races with a socket being (partially or fully) closed.
> 
> Ostensibly, using a shutdown(SHUT_WR) and then a wait for a recv return 
> of zero would take about the same length of time as polling local 
> connection stats to see that there were no ostensibly unacked data - 
> both will take one RTT right?  and shutdown/read has the added property 
> that it will deal with zero windows automagically.

With the shutdown(SHUT_WR)/read() approach, I would have had to set
a timeout on the read, to handle the case where the peer just went
away, whereas currently I just check elapsed time (I strive to make
nuttcp robust in such cases to allow it to be used reliably within
scripts run for example from cron).

Also, I was (perhaps unncessarily) worried that after the zero read(),
the socket would effectively be closed, and I wasn't sure then about
the reliability of using tcp_info to get the tcpi_total_retrans at that
point.

As with most things, there's more than one way to skin a cat.

						-Bill
