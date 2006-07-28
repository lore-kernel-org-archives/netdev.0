From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Fri, 28 Jul 2006 12:22:29 +1000
Message-ID: <20060728022229.GA2106@gondor.apana.org.au>
References: <44C8B0B8.2010408@miyazawa.org> <E1G6Fic-0005py-00@gondolin.me.apana.org.au> <20060727.183415.104032934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:19218 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750786AbWG1CWs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 22:22:48 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060727.183415.104032934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27, 2006 at 06:34:15PM -0700, David Miller wrote:
> 
> I have severe doubts actually in this area.  And I have practical
> experience to back up these doubts in this specific case.

OK.

> Just moving the ipv6 address add/delete out of software interrupt
> context broke the TAHI and other ipv6 testsuites.
> 
> The reason was simple.  Consider a simple test case that emits an
> NDISC packet that should cause an interface address to be added, and
> then it sends a packet which makes sure that host responds to that
> address.  We have those two packets in our queue, as packet "A" and
> "B".

I'd like to know more about this test.  On the face of it this test seems
to be broken.  What if packet A was lost? Surely this shouldn't be used
as an indication that the target IPv6 stack is out-of-spec.

If we're really going to guarantee that NDISC processing is always going
to be synchronous, this imposes fairly nasty restrictions on what we can
do in future.  For instance, this would rule out having the NIC distribute
flows across CPUs as this would break the synchronocity of NDISC processing
vs. TCP processing.

> As a secondary reason not to even consider this, it's in the kernel
> already and therefore it is totally impractical to try and remove it.
> When considering new protocols or features, the "user vs.  kernel"
> argument is something to validly consider.  But when it's already
> there, it will have to live there basically for eternity.  It is not
> like some arbitrary internal kernel module symbol or interface we
> can deprecate over a 6 month period or something like that.

Fair enough.  I suppose another case in point is IPv4 autoconf which
is *still* in the kernel after all these years.

However, to draw an analogy we're kind of stuck in a bog here.  So
while we can't extricate ourselves easily, we should attempt to come
up with ways of eventually lifting us out.  We should also try to
avoid any actions that'll cause us to sink deeper :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
