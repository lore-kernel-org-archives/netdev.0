From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Sat, 15 Jan 2005 07:34:52 +1100
Message-ID: <20050114203452.GA1277@gondor.apana.org.au>
References: <20050113171234.3fde0925.davem@davemloft.net> <20050114012504.GF6309@krispykreme.ozlabs.ibm.com> <20050113201914.46b7c4a2.davem@davemloft.net> <20050114111648.GA27964@gondor.apana.org.au> <20050114120322.GA28449@gondor.apana.org.au> <20050114110352.23c94ab9.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050114110352.23c94ab9.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2005 at 11:03:52AM -0800, David S. Miller wrote:
> 
> Herbert, this patch doesn't fix the bug.  We still have
> to do the adjustments gradually just like sendmsg().
> That's the whole problem.
> 
> If sendmsg() creates the SKB, then sendpages() adds paged
> data onto the end, we don't make skb->truesize big enough.

My reasoning is as follows:

The size of the skb is bounded by the MSS.  Therefore it can
never grow beyond that.  So if we allocated that much memory
then we can tack bits on as long as we don't exceed the original
MSS that was used.

The problem before was that the MSS could've changed between
sendpages calls.  If it increased then we may exceed the
amount of memory allocated originally.

My idea is to remember the original MSS so that we never exceed
it.  Did I missing something?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
