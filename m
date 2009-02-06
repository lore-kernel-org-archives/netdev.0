From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 6 Feb 2009 20:22:18 +1100
Message-ID: <20090206092218.GB6645@gondor.apana.org.au>
References: <20090205234318.GA1929@gondor.apana.org.au> <20090206.005034.193709323.davem@davemloft.net> <20090206085406.GA6540@gondor.apana.org.au> <20090206.010559.157790037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40990 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752536AbZBFJWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:22:30 -0500
Content-Disposition: inline
In-Reply-To: <20090206.010559.157790037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 01:05:59AM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 6 Feb 2009 19:54:06 +1100
> 
> > This should eliminate the backtrace as reported, but it'll just
> > show up somewhere else.  In particular, the control message (see
> > sys_sendmsg) itself is copied to kernel memory via kmalloc and
> > it's limited to INT_MAX :)
> 
> Can you be more specific, do you mean this is happening
> via datagram_send_ctl()?

Well the data that led to the back trace came from a cmsg, I was
merely pointing out that the cmsg itself is kmalloced and copied
by sys_sendmsg and it's only limited to INT_MAX.

So even if you throw away the message in IPv6, sys_sendmsg will
still do an even bigger allocation on that message which is just
as likely to fail.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
