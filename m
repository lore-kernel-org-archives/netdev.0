From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Fri, 15 Apr 2005 07:30:40 +1000
Message-ID: <20050414213040.GA21276@gondor.apana.org.au>
References: <E1DM3QD-00045e-00@gondolin.me.apana.org.au> <OF2DA36C59.2C9530C7-ON88256FE3.00654547-88256FE3.00663E1E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF2DA36C59.2C9530C7-ON88256FE3.00654547-88256FE3.00663E1E@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2005 at 12:36:46PM -0600, David Stevens wrote:
> 
> Below is a piece of my original patch that I've separated out to make sure
> it doesn't get lost in this discussion. It's the fix for the bug that 
> triggered all
> of this and the real cause of the panic for the ordinary raw-socket cases, 
> where
> nr_frags is supposed to be "0". Attached and in-line below.

Thanks.  Actually I did include it in my patch too.

> A couple comments initially on your patch: multiple packet support I don't
> think is needed here (in sendmsg). I agree it's good to put it in for 
> other
> possible uses, but IPV6_CHECKSUM doesn't need it, as far as I can tell.

Multiple packets will exist on the queue when the user has written
more than one MTU worth of data.

> How about a loop instead of a recursive call? If the list is long enough
> and the architecture eats stack a lot of stack space on function calls,
> that could be a problem.

You mean where skb_store_bits calls itself? This can only recurse once
at most.  In fact, in this particular instance it will not recurse at
all since the fragments aren't chained together (the chaining occurs in
ip6_push_pending_frames).  This is how skb_copy_bits works too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
