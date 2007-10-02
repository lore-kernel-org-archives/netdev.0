From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 09:34:01 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0710020930250.3579@woody.linux-foundation.org>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
 <20071002150935.GC17418@bitmover.com>
 <20071002154137.GD17418@bitmover.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Larry McVoy <lm@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36425 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbXJBQe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 12:34:56 -0400
In-Reply-To: <20071002154137.GD17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 2 Oct 2007, Larry McVoy wrote:

> Interesting data point.  My test case is like this:
> 
> server
> 	bind
> 	listen
> 	while (newsock = accept...)
> 		transfer()
> 
> client
> 	connect
> 	transfer
> 
> If the server side is the source of the data, i.e, it's transfer is a 
> write loop, then I get the bad behaviour.  If I switch them so the data
> flows in the other direction, then it works, I go from about 14K pkt/sec
> to 43K pkt/sec.

Sounds like accept() possibly initializes slightly different socket 
parameters than connect() does. 

On the other hand, different network cards will simply have different 
behaviour (some due to hardware, some due to driver differences), so I 
hope you also switched the processes around and/or used identically 
configured machines (and the port configuration on switches could matter, 
of course, so it's really best to switch the processes around, to make 
sure that the *only* difference is whether the socket was set up by 
accept() vs connect()).

> So is this a bug or intentional?

Sounds like a bug to me, modulo the above caveat of making sure that it's 
not some hw/driver/switch kind of difference.

			Linus
