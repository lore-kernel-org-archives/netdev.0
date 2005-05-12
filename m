From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (122)
Date: Thu, 12 May 2005 20:42:29 +1000
Message-ID: <20050512104229.GB25631@gondor.apana.org.au>
References: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp> <20050510220751.GA459@gondor.apana.org.au> <20050511005836.GA1674@gondor.apana.org.au> <4282846F.6070403@tpack.net> <20050511231751.GA21781@gondor.apana.org.au> <1115891887.30106.89.camel@tsc-6.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <1115891887.30106.89.camel@tsc-6.cph.tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 11:58:07AM +0200, Tommy Christensen wrote:
> 
> Yes, I like this better.  Good idea.

I see that you've given up on the minimalism :)

> Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>

It looks good to me too except for that comment of yours :)

> diff -ru linux-2.6.12-rc4/net/netlink/af_netlink.c linux-2.6.12-work/net/netlink/af_netlink.c
> --- linux-2.6.12-rc4/net/netlink/af_netlink.c	2005-05-11 11:10:20.000000000 +0200
> +++ linux-2.6.12-work/net/netlink/af_netlink.c	2005-05-12 11:51:57.427312857 +0200
> @@ -735,11 +735,13 @@
>  
>  	sock_hold(sk);
>  	if (p->skb2 == NULL) {
> -		if (atomic_read(&p->skb->users) != 1) {
> +		if (skb_shared(p->skb)) {
>  			p->skb2 = skb_clone(p->skb, p->allocation);
>  		} else {
> -			p->skb2 = p->skb;
> -			atomic_inc(&p->skb->users);
> +			p->skb2 = skb_get(p->skb);
> +			/* skb ownership may have been set when
> +			   delivered to a previous socket. */

For new comments please use the following style which is more standard
in the kernel these days:

/*
 * blah blah blah ....
 * for comments that don't fit on a single line.
 */

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
