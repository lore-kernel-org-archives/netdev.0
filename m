From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: fix race condition regarding dst->expires and dst->from.
Date: Wed, 20 Feb 2013 19:25:19 +0900
Message-ID: <5124A48F.3060907@linux-ipv6.org>
References: <51249F42.3030908@linux-ipv6.org> <5124A2B9.9060806@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	netdev <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:35151 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758703Ab3BTKZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 05:25:20 -0500
In-Reply-To: <5124A2B9.9060806@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:

> -static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
> +static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
>  {
> -	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
> -		if (rt->dst.from)
> -			dst_release(rt->dst.from);
> -		/* dst_set_expires relies on expires == 0 
> -		 * if it has not been set previously.
> -		 */
> -		rt->dst.expires = 0;
> -	}
> -
> -	dst_set_expires(&rt->dst, timeout);
> -	rt->rt6i_flags |= RTF_EXPIRES;
> +	struct rt6_info *rt;
> +
> +	for (rt = rt0; rt && !(rt->rt6i_flags & RTF_EXPIRES); rt = rt->dst.from);
> +	if (rt && rt != rt0)
> +		rt0->dst.expires = rt->dst.expires;
> +
> +	dst_set_expires(&rt0->dst, timeout);
> +	rt0->rt6i_flags |= RTF_EXPIRES;
>  }
>  

Oops, I sent wrong version, will resend.

--yoshfuji
