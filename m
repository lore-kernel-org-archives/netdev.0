From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 29 Sep 2004 09:19:06 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928231906.GA25293@gondor.apana.org.au>
References: <1096289189.1075.37.camel@jzny.localdomain> <20040927213607.GD7243@gondor.apana.org.au> <1096339407.8660.33.camel@jzny.localdomain> <20040928024614.GA9911@gondor.apana.org.au> <1096340772.8659.51.camel@jzny.localdomain> <20040928032321.GB10116@gondor.apana.org.au> <1096343125.8661.96.camel@jzny.localdomain> <20040928035921.GA10675@gondor.apana.org.au> <1096367787.8662.146.camel@jzny.localdomain> <4159D278.4060809@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <4159D278.4060809@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 28, 2004 at 11:07:04PM +0200, Pablo Neira wrote:
> 
> If buffer overruns we lost all the messages which are enqueued, so 

This is not true.  You will get an ENOBUFS error but the packets
that have already been queued are still on the queue if you want
to read them.

> ===== net/netlink/af_netlink.c 1.58 vs edited =====
> --- 1.58/net/netlink/af_netlink.c	Sat Sep 25 17:43:43 2004
> +++ edited/net/netlink/af_netlink.c	Tue Sep 28 22:23:44 2004
> @@ -475,7 +475,7 @@
>  	if (nlk->handler)
>  		return 0;
>  #endif
> -	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
> +	if (atomic_read(&sk->sk_rmem_alloc) + skb->len > sk->sk_rcvbuf ||

I don't see the point of this patch.  All it does is make the overrun
happen one packet earlier.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
