From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 11:03:52 -0800
Message-ID: <20050114110352.23c94ab9.davem@davemloft.net>
References: <20050113171234.3fde0925.davem@davemloft.net>
	<20050114012504.GF6309@krispykreme.ozlabs.ibm.com>
	<20050113201914.46b7c4a2.davem@davemloft.net>
	<20050114111648.GA27964@gondor.apana.org.au>
	<20050114120322.GA28449@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050114120322.GA28449@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 Jan 2005 23:03:22 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> What we need to do is to remember mss_now across sendpage calls.  
> Luckily the value of truesize lets us deduce the value of mss_now.
> To complicate the picture the mss might have been reduced between
> sendpages calls.  So we take the minimum of the remembered mss
> and the current mss.
> 
> Any brave souls out there to try this?

Herbert, this patch doesn't fix the bug.  We still have
to do the adjustments gradually just like sendmsg().
That's the whole problem.

If sendmsg() creates the SKB, then sendpages() adds paged
data onto the end, we don't make skb->truesize big enough.
