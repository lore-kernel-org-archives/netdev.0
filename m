From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Set truesize in pskb_expand_head
Date: Fri, 24 Sep 2004 16:45:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924164540.2d750572.davem@davemloft.net>
References: <20040924232053.GA7807@gondor.apana.org.au>
	<20040924163328.7597352c.davem@davemloft.net>
	<20040924233555.GA7962@gondor.apana.org.au>
	<20040924233713.GA8001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040924233713.GA8001@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 25 Sep 2004 09:37:13 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Sep 25, 2004 at 09:35:55AM +1000, herbert wrote:
> > 
> > Dave, it hasn't been charged yet...
> 
> Well at least not in the netlink case.  But you're that we can't do this
> in general.  I'll adjust it right after the pskb_expand_head call then.

I still am hesitant about your idea.

You're willing to do a very likely re-alloc every transaction
where as I'm suggesting a single allocation for the socket at
creation time which is used for every transaction on that
socket.

Let's talk more precisely, perhaps I'm missing something,
my scheme:

   Single PAGE_SIZE scratch buffer per socket, results in one
   allocation at socket creation time, and one SKB allocation
   while building a response.

your scheme:

   Allocate full PAGE_SIZE SKB for each netlink transaction,
   reallocate data area at end of building each transaction.

So, two data area kmalloc()'s per netlink response compared
to one for mine.

Your scheme doesn't even avoid the copy.  What's the advantage?
Furthermore my per-socket PAGE_SIZE scratch area is likely to
get very good cache hit rates making the copy very inexpensive.

Comments?
