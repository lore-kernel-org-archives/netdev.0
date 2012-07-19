From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 09/15] ipv4: Cache output routes in fib_info nexthops.
Date: Thu, 19 Jul 2012 13:38:10 +0200
Message-ID: <20120719113810.GM1869@secunet.com>
References: <20120718.112404.1910372180742347127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39923 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab2GSLiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 07:38:18 -0400
Content-Disposition: inline
In-Reply-To: <20120718.112404.1910372180742347127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 18, 2012 at 11:24:04AM -0700, David Miller wrote:
> +
> +static void rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe)
> +{
> +	if (fnhe->fnhe_pmtu) {
> +		unsigned long expires = fnhe->fnhe_expires;
> +		unsigned long diff = jiffies - expires;

This should be diff = expires - jiffies

With that changed, everything seems to work fine :)

> +
> +		if (time_before(jiffies, expires)) {
> +			rt->rt_pmtu = fnhe->fnhe_pmtu;
> +			dst_set_expires(&rt->dst, diff);
>  		}
>  	}
> +	if (fnhe->fnhe_gw) {
> +		rt->rt_flags |= RTCF_REDIRECTED;
> +		rt->rt_gateway = fnhe->fnhe_gw;
> +	}
> +	fnhe->fnhe_stamp = jiffies;
>  }
>  
