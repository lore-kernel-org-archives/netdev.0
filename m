From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next v2 1/4] ipv6: introduce new type ipv6_addr_props
 to hold ipv6 address type and scope
Date: Sun, 17 Feb 2013 08:18:16 +0900
Message-ID: <512013B8.3000608@linux-ipv6.org>
References: <20130216191008.GA23272@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, brian.haley@hp.com,
	hannes@stressinduktion.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56605 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754687Ab3BPXSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 18:18:17 -0500
In-Reply-To: <20130216191008.GA23272@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> This simplifies ipv6 address type handling. The old implementation had
> the problem that scope and type where both squeezed into one int. Because
> of this it was dangerous to do comparisons on it or check for scope while
> it is actually being stripped out. This patch mainly improves type safety.
> 
> v2:
> a) Incorportated feedback from Brian Haley
> b) fix style in addrconf_core.c:__ipv6_addr_props
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: Brian Haley <brian.haley@hp.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/ipv6.h       | 20 ++++++----
>  net/ipv6/addrconf.c      | 28 +++++++-------
>  net/ipv6/addrconf_core.c | 99 +++++++++++++++++++++++++++++++-----------------
>  net/ipv6/datagram.c      | 12 +++---
>  4 files changed, 99 insertions(+), 60 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 851d541..a14700c 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -298,25 +298,31 @@ static inline int ip6_frag_mem(struct net *net)
>  #define IPV6_FRAG_LOW_THRESH	(3 * 1024*1024)	/* 3145728 */
>  #define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
>  
> -extern int __ipv6_addr_type(const struct in6_addr *addr);
> -static inline int ipv6_addr_type(const struct in6_addr *addr)
> +struct ipv6_addr_props {
> +	u16 type;
> +	s16 scope;
> +};
> +
> +extern struct ipv6_addr_props __ipv6_addr_props(const struct in6_addr *addr);
> +static inline unsigned int ipv6_addr_type(const struct in6_addr *addr)
>  {
> -	return __ipv6_addr_type(addr) & 0xffff;
> +	return __ipv6_addr_props(addr).type;
>  }
>  
>  static inline int ipv6_addr_scope(const struct in6_addr *addr)
>  {
> -	return __ipv6_addr_type(addr) & IPV6_ADDR_SCOPE_MASK;
> +	return __ipv6_addr_props(addr).scope;
>  }
>  

NAK.  This does not return correct value as before.
If you are going to covert this, please do not try to
change usage of inlines.  

--yoshfuji
