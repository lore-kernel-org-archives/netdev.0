From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 2/3] ipv6: reuse rt6_need_strict
Date: Fri, 28 Mar 2014 08:41:10 +0100
Message-ID: <20140328074110.GC11063@order.stressinduktion.org>
References: <1395979303-7668-1-git-send-email-wangyufen@huawei.com> <1395979303-7668-3-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, ioe@perches.com,
	kuznet@ms2.inr.ac.ru
To: Wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36696 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbaC1HlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 03:41:12 -0400
Content-Disposition: inline
In-Reply-To: <1395979303-7668-3-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2014 at 12:01:42PM +0800, Wangyufen wrote:
> From: Wang Yufen <wangyufen@huawei.com>
> 
> Modify the rt6_need_strict, so that it can be reused
> 
> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
> ---
>  include/net/ip6_route.h | 1 +
>  net/ipv6/route.c        | 2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index 00e3f12..d9c316e 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h
> @@ -51,6 +51,7 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
>  	return (flags >> 3) & 7;
>  }
>  
> +bool rt6_need_strict(const struct in6_addr *daddr);
>  
>  void ip6_route_input(struct sk_buff *skb);
>  
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index fba54a4..f5fdccc 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -373,7 +373,7 @@ static bool rt6_check_expired(const struct rt6_info *rt)
>  	return false;
>  }
>  
> -static bool rt6_need_strict(const struct in6_addr *daddr)
> +bool rt6_need_strict(const struct in6_addr *daddr)
>  {
>  	return ipv6_addr_type(daddr) &
>  		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);

Just a small suggestion:
I think we can move the whole function as static inline into the header.

Thanks,

  Hannes
