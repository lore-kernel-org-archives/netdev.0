From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH net-next] net: split rt_genid for ipv4 and ipv6
Date: Mon, 22 Jul 2013 12:53:55 +0200
Message-ID: <20130722105355.GP3109@secunet.com>
References: <51E8B273.1090002@windriver.com>
 <20130718.203100.1960741588589171145.davem@davemloft.net>
 <51E8EFBC.6040902@windriver.com>
 <20130719.023318.2201887768706444746.davem@davemloft.net>
 <51ECC682.1030409@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37431 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932363Ab3GVKx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 06:53:59 -0400
Content-Disposition: inline
In-Reply-To: <51ECC682.1030409@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 01:43:30PM +0800, Fan Du wrote:
> 
> -static inline void rt_genid_bump(struct net *net)
> +#if IS_ENABLED(CONFIG_IPV6)
> +static inline int rt_genid_ipv6(struct net *net)
>  {
> -	atomic_inc(&net->rt_genid);
> +	return atomic_read(&net->rt_genid_ipv6);
> +}
> +
> +static inline void rt_genid_bump_ipv6(struct net *net)
> +{
> +	atomic_inc(&net->rt_genid_ipv6);
> +}
> +#endif
> +

I think this will introduce a compile error if ipv6 is
not enabled because you use rt_genid_bump_ipv6() in
the generic IPsec code.

> +static inline void rt_genid_bump_all(struct net *net)
> +{
> +	atomic_inc(&net->rt_genid_ipv4);
> +#if IS_ENABLED(CONFIG_IPV6)
> +	atomic_inc(&net->rt_genid_ipv6);
> +#endif
>  }
> 

Function is unused.

The rest looks ok.
