From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Thu, 12 May 2005 08:24:21 +1000
Message-ID: <20050511222421.GA21331@gondor.apana.org.au>
References: <428284D6.9000804@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <428284D6.9000804@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 12:19:02AM +0200, Tommy Christensen wrote:
>
> diff -ru linux-2.6.12-rc4/net/netlink/af_netlink.c linux-2.6.12-work/net/netlink/af_netlink.c
> --- linux-2.6.12-rc4/net/netlink/af_netlink.c	2005-05-11 11:10:20.000000000 +0200
> +++ linux-2.6.12-work/net/netlink/af_netlink.c	2005-05-12 00:11:08.990990172 +0200
> @@ -785,11 +785,12 @@
>  	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
>  		do_one_broadcast(sk, &info);
>  
> +	kfree_skb(skb);
> +
>  	netlink_unlock_table();
>  
>  	if (info.skb2)
>  		kfree_skb(info.skb2);
> -	kfree_skb(skb);

Good catch.  But doesn't this affect skb2 as well?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
