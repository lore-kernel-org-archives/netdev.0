From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sat, 25 Sep 2004 08:06:51 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924220651.GA6096@gondor.apana.org.au>
References: <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040922105221.59a67d4b.davem@davemloft.net> <4152EE68.4030803@eurodev.net> <20040923121651.51a58cf2.davem@davemloft.net> <20040924032830.GC6384@gondor.apana.org.au> <20040923223909.6f4da27f.davem@davemloft.net> <20040924062604.GA7393@gondor.apana.org.au> <20040924105855.0e1aecd0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@eurodev.net, hadi@cyberus.ca, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040924105855.0e1aecd0.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 24, 2004 at 10:58:55AM -0700, David S. Miller wrote:
> On Fri, 24 Sep 2004 16:26:04 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > It also means those responders that can calculate the correct size
> > of the reply doesn't need to go through this copy process.
> 
> This is the crux of the problem, you don't know how big
> the response will be until you look at the whole object
> you are returning.

I understand.  What I'm saying is that some of these places already know
how big it is going to be.  See tcp_diag.c for an example.  So we shouldn't
impose the copy over head on everyone.

> This is why I suggested the PAGE_SIZE scratchpad, you build
> the response fully into there, then you know the exact size
> SKB you need so you allocate it and copy into it from the
> scratch pad.

I agree completely.  I'm just saying that the current NLM_GOODSIZE
skb is the perfect scratch-pad so we don't need a new one.  All we
need to do is to insert a helper call just before netlink_unicast
to copy and trim the packet in the places that need it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
