From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH RFC 1/2] ipv6: introdcue __ipv6_addr_needs_scope_id and
 ipv6_iface_scope_id helper functions
Date: Mon, 11 Feb 2013 22:36:35 +0900
Message-ID: <5118F3E3.2080808@linux-ipv6.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org> <5116595E.2080601@linux-ipv6.org> <20130210153230.GA21377@order.stressinduktion.org> <5117EA2D.1020106@linux-ipv6.org> <20130210184918.GB20897@order.stressinduktion.org> <20130211111303.GA23991@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39212 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757218Ab3BKNgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 08:36:37 -0500
In-Reply-To: <20130211111303.GA23991@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> This strictly a RFC only (I also left out my signed-off). This patch
> introduces helper functions to set and check for the need of scope ids.
> 
> Suggested-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  include/net/ipv6.h | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 851d541..1f61dc9 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -319,6 +319,19 @@ static inline int ipv6_addr_src_scope(const struct in6_addr *addr)
>  	return __ipv6_addr_src_scope(__ipv6_addr_type(addr));
>  }
>  
> +static inline bool __ipv6_addr_needs_scope_id(int type)
> +{
> +	return type != IPV6_ADDR_ANY &&
> +	       !(type & IPV6_ADDR_LOOPBACK && type & IPV6_ADDR_UNICAST) &&
> +	       __ipv6_addr_src_scope(type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
> +}
> +
> +static inline __u32 ipv6_iface_scope_id(const struct in6_addr *addr,
> +					unsigned int iface)
> +{
> +	return __ipv6_addr_needs_scope_id(__ipv6_addr_type(addr)) ? iface : 0;
> +}
> +
>  static inline int ipv6_addr_cmp(const struct in6_addr *a1, const struct in6_addr *a2)
>  {
>  	return memcmp(a1, a2, sizeof(struct in6_addr));
> 

Yes, something like that.    

--yoshfuji
