From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/4] Fix addrconf race conditions
Date: Tue, 18 May 2010 21:02:43 +1000
Message-ID: <20100518110243.GA7750@gondor.apana.org.au>
References: <20100422.004324.67422011.davem@davemloft.net> <20100422142506.GA15858@gondor.apana.org.au> <20100422154908.GA31568@midget.suse.cz> <20100422.185400.71096585.davem@davemloft.net> <20100423021000.GA21777@gondor.apana.org.au> <20100423150540.GA26611@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42297 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755560Ab0ERLCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 07:02:54 -0400
Content-Disposition: inline
In-Reply-To: <20100423150540.GA26611@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 23, 2010 at 11:05:40PM +0800, Herbert Xu wrote:
>
> This stuff is more broken than I thought.  For example, we perform
> a number of actions when DAD succeeds, e.g., joining an anycast
> group.  However, this is not synchronised with respect to address
> deletion at all, so if DAD succeeds just as someone deletes the
> address, you can easily get stuck on that anycast group.
> 
> I will try to untangle this mess tomorrow.

Tomorrow took a while to arrive :)

Here is a first batch of patches.  Note that this is by no means
a comprehensive fix for all the ndisc/addrconf race conditions.
It is just a first step in trying to address the problems.

The patchset revolves around a new lock, ifp->state_lock.  I
added it instead of trying to reuse the existing ifp->lock because
the latter has serious nesting issues that prevent it from easily
being used.  My long term plan is to restructure the locking and
eventually phase out ifp->lock in favour of ifp->state_lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
