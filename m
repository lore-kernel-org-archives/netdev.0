From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Fri, 24 Sep 2004 13:28:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924032830.GC6384@gondor.apana.org.au>
References: <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040922105221.59a67d4b.davem@davemloft.net> <4152EE68.4030803@eurodev.net> <20040923121651.51a58cf2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, hadi@cyberus.ca, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040923121651.51a58cf2.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2004 at 12:16:51PM -0700, David S. Miller wrote:
> 
> Simpler would be:
> 
> 1) For each netlink socket, allocate a page, much like TCP sockets
>    do.
> 
> 2) Construct the netlink response in this page sized buffer,
>    keeping track of how much of the page is actually used.
> 
> 3) At the end, allocate the skb with the necessary length,
>    copy into the skb from the page buffer.
> 
> 4) Since the RTNL semaphore is held during the length of these
>    operations, the per-socket page needs no locking.

Can someone please tell me why we need to do this at all?

Most of the dump messages should be close to PAGE_SIZE anyway, no?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
