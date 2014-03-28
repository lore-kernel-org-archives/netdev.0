From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v5 2/3] ipv6: reuse rt6_need_strict
Date: Fri, 28 Mar 2014 17:40:35 +0400
Message-ID: <53357BD3.1060105@cogentembedded.com>
References: <1395998427-7532-1-git-send-email-wangyufen@huawei.com> <1395998427-7532-3-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru
To: Wangyufen <wangyufen@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:58769 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaC1Nkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 09:40:32 -0400
Received: by mail-lb0-f179.google.com with SMTP id p9so3757596lbv.10
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 06:40:31 -0700 (PDT)
In-Reply-To: <1395998427-7532-3-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 28-03-2014 13:20, Wangyufen wrote:

> From: Wang Yufen <wangyufen@huawei.com>

> Move the whole rt6_need_strict as static inline into ip6_route.h,
> so that it can be reused

> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
> ---
>   include/net/ip6_route.h | 5 +++++
>   net/ipv6/route.c        | 6 ------
>   2 files changed, 5 insertions(+), 6 deletions(-)

> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index 00e3f12..33e8694 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h
> @@ -51,6 +51,11 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
>   	return (flags >> 3) & 7;
>   }
>
> +static inline bool rt6_need_strict(const struct in6_addr *daddr)
> +{
> +	return ipv6_addr_type(daddr) &
> +		IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);

    I don't think removing parens was correct here: & should have more 
priority than |.

> +}
>
>   void ip6_route_input(struct sk_buff *skb);
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index b93ae6a..5015c50 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -374,12 +374,6 @@ static bool rt6_check_expired(const struct rt6_info *rt)
>   	return false;
>   }
>
> -static bool rt6_need_strict(const struct in6_addr *daddr)
> -{
> -	return ipv6_addr_type(daddr) &
> -		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
> -}
> -
>   /* Multipath route selection:
>    *   Hash based function using packet header and flowlabel.
>    * Adapted from fib_info_hashfn()

WBR, Sergei
