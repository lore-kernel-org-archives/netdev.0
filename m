From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 6 Feb 2009 19:54:06 +1100
Message-ID: <20090206085406.GA6540@gondor.apana.org.au>
References: <20090205143143.GA18734@alice> <adafxisjzel.fsf@cisco.com> <20090205234318.GA1929@gondor.apana.org.au> <20090206.005034.193709323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55990 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752211AbZBFIyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 03:54:23 -0500
Content-Disposition: inline
In-Reply-To: <20090206.005034.193709323.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 12:50:34AM -0800, David Miller wrote:
>
> ipv6: Disallow rediculious flowlabel option sizes.
> 
> Just like PKTINFO, limit the options area to 64K.
> 
> Based upon report by Eric Sesterhenn and analysis by
> Roland Dreier.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

This should eliminate the backtrace as reported, but it'll just
show up somewhere else.  In particular, the control message (see
sys_sendmsg) itself is copied to kernel memory via kmalloc and
it's limited to INT_MAX :)

(The option we're discussing here is stored in the control message).

We either need to vmalloc it or have everyone read the user
memory directly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
