From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Fri, 15 Apr 2005 10:41:02 +1000
Message-ID: <20050415004102.GA23462@gondor.apana.org.au>
References: <20050414232227.GB22721@gondor.apana.org.au> <OF8E587AEF.C9490192-ON88256FE3.0081CF1A-88256FE4.0002E57F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF8E587AEF.C9490192-ON88256FE3.0081CF1A-88256FE4.0002E57F@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2005 at 05:31:38PM -0700, David Stevens wrote:
> 
> > In fact with your patch we can end up calling ip6_flush_pending_frames
> > twice.  Granted that it is currently harmless but it isn't nice.
> 
>         I don't see this. My original patch only calls
> ip6_flush_pending_frames() once, since the original code already only

You called ip6_flush_pending_frames() when rawv6_push_pending_frames
returned an error.  However rawv6_push_pending_frames can return an
error that was in turn returned by ip6_push_pending_frames.

As you know ip6_push_pending_frames always frees the cork buffer so
this is tantamount to calling ip6_flush_pending_frames twice.
 
>         I saw that in the code, but I also saw a 2K single skb when the
> MTU is 1500. A piece I looked at appeared to be allocating space for

That's definitely wrong.  Please give us a test case (or patch :) so
that this can be fixed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
