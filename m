From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next v3 1/4] ipv6: introdcue __ipv6_addr_needs_scope_id
 and ipv6_iface_scope_id helper functions
Date: Fri, 08 Mar 2013 11:21:10 +0900
Message-ID: <51394B16.7010108@linux-ipv6.org>
References: <20130307210529.GA23621@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40184 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752314Ab3CHCVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 21:21:11 -0500
In-Reply-To: <20130307210529.GA23621@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> __ipv6_addr_needs_scope_id checks if an ipv6 address needs to supply
> a 'sin6_scope_id != 0'. 'sin6_scope_id != 0' was enforced in case
> of link-local addresses. To support interface-local multicast these
> checks had to be enhanced and are now consolidated into these new helper
> functions.
> 
> v2:
> a) migrated to struct ipv6_addr_props
> 
> v3:
> a) reverted changes for ipv6_addr_props
> b) test for address type instead of comparing scope
> 
> Suggested-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/ipv6.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 64d12e7..e11d304 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -320,6 +320,18 @@ static inline int ipv6_addr_src_scope(const struct in6_addr *addr)
>  	return __ipv6_addr_src_scope(__ipv6_addr_type(addr));
>  }
>  
> +static inline bool __ipv6_addr_needs_scope_id(int type)
> +{
> +	return type & IPV6_ADDR_LINKLOCAL ||
> +	       (type & IPV6_ADDR_MULTICAST &&
> +		(type & (IPV6_ADDR_LOOPBACK|IPV6_ADDR_LINKLOCAL)));
> +}
> +
> +static inline __u32 ipv6_iface_scope_id(const struct in6_addr *addr, int iface)
> +{
> +	return __ipv6_addr_needs_scope_id(__ipv6_addr_type(addr)) ? iface : 0;
> +}
> +
>  static inline int ipv6_addr_cmp(const struct in6_addr *a1, const struct in6_addr *a2)
>  {
>  	return memcmp(a1, a2, sizeof(struct in6_addr));
> 

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
