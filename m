From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Fri, 24 Sep 2004 16:26:04 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924062604.GA7393@gondor.apana.org.au>
References: <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040922105221.59a67d4b.davem@davemloft.net> <4152EE68.4030803@eurodev.net> <20040923121651.51a58cf2.davem@davemloft.net> <20040924032830.GC6384@gondor.apana.org.au> <20040923223909.6f4da27f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@eurodev.net, hadi@cyberus.ca, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040923223909.6f4da27f.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2004 at 10:39:09PM -0700, David S. Miller wrote:
> 
> It's moreso for the "give me a single entry" requests
> than for dumps.  NLMSG_GOODSIZE is used for all cases.

I see.  NLMSG_GOODSIZE is definitely a waste in that case.

> Simpler would be:
> 
> 1) For each netlink socket, allocate a page, much like TCP sockets
>    do.

I'd let the responder allocate that page skb as they do now.
After all what we lack is space on the receive queue, not
kernel memory.  So long as that page doesn't end up on the
queue, it should be fine.

It also means those responders that can calculate the correct size
of the reply doesn't need to go through this copy process.

> 2) Construct the netlink response in this page sized buffer,
>    keeping track of how much of the page is actually used.

The size is in the NL header so that's easy.

> 3) At the end, allocate the skb with the necessary length,
>    copy into the skb from the page buffer.

We can put that into a helper function and then those netlink
responders which use GOODSIZE (most of them for now) can call
it.

Putting it in a helper means that we can have implementations
in future that don't need to do this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
