From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Sat, 15 Jan 2005 08:38:29 +1100
Message-ID: <20050114213829.GA12454@gondor.apana.org.au>
References: <20050113171234.3fde0925.davem@davemloft.net> <20050114012504.GF6309@krispykreme.ozlabs.ibm.com> <20050113201914.46b7c4a2.davem@davemloft.net> <20050114111648.GA27964@gondor.apana.org.au> <20050114120322.GA28449@gondor.apana.org.au> <20050114110352.23c94ab9.davem@davemloft.net> <20050114203452.GA1277@gondor.apana.org.au> <20050114132757.4ca3153a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050114132757.4ca3153a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2005 at 01:27:57PM -0800, David S. Miller wrote:
> 
> You missed the whole problem.
> 
> It has nothing to do with the MSS changing.

However if the MSS does change then it can cause the same symptoms.
In fact the MSS can easily increase when TSO is enabled since it
increases as the RCV window is opened up.

> The bug case is when _SEND_MSG_ creates the SKB, and a subsequent
> _SEND_PAGE_ call adds pages onto that SKB in the queue.
> 
> Unlike _SEND_PAGE_, _SEND_MSG_ does not do the "allocate tp->mss_cache"
> thingy.  Instead, it adjusts the queueing allocation values as it copies
> the data into the SKB.
> 
> Therefore my change aims to make _SEND_PAGE_ use _SEND_MSG_'s accounting
> scheme (adjust as we actually add the data) so that it all works out.

I understand your point about sendmsg followed by sendpages.  My patch
addresses that as well by making sure that we don't tack on more bits
than what's allowed by skb->truesize.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
