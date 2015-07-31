From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipsec:Fix error handling in the function xfrm6_get_addr
Date: Fri, 31 Jul 2015 08:00:19 +0800
Message-ID: <20150731000019.GA22464@gondor.apana.org.au>
References: <1438273240-15493-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438273240-15493-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 30, 2015 at 12:20:40PM -0400, Nicholas Krause wrote:
>
> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> index ed0583c..f60c670 100644
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -61,7 +61,9 @@ static int xfrm6_get_saddr(struct net *net,
>  		return -EHOSTUNREACH;
>  
>  	dev = ip6_dst_idev(dst)->dev;
> -	ipv6_dev_get_saddr(dev_net(dev), dev, &daddr->in6, 0, &saddr->in6);
> +	if (ipv6_dev_get_saddr(dev_net(dev), dev, &daddr->in6, 0, &saddr->in6))
> +		return -EADDRNOTAVAIL;
> +
>  	dst_release(dst);

You're leaking dst.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
