From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 2/4] net: add ipv6_select_ident_by_addr() API
Date: Mon, 09 Mar 2015 08:03:55 -0700
Message-ID: <1425913435.8261.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
	 <1425888098-21875-3-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:39055 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbbCIPD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 11:03:58 -0400
Received: by igdh15 with SMTP id h15so21583180igd.4
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 08:03:57 -0700 (PDT)
In-Reply-To: <1425888098-21875-3-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 01:01 -0700, Andy Zhou wrote:
> In case the route information is not available but IPv6 identification
> field needs to be calaulated, for example, in ipv6 fragmentation.

typo ? -> calculated

>  This
> new API can used.
> 
> The current ipv6_select_idenet() is kept as is. Its implementation now

typo ? -> ipv6_select_ident()

> calls the new API.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---
>  include/net/ipv6.h     |  3 +++
>  net/ipv6/output_core.c | 13 ++++++++++---
>  2 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index b767306..780c098 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -672,6 +672,9 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
>  }
>  
>  void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
> +void ipv6_select_ident_by_addr(struct frag_hdr *fhdr,
> +			       const struct in6_addr *dst,
> +			       const struct in6_addr *src);
>  void ipv6_proxy_select_ident(struct sk_buff *skb);
>  
>  int ip6_dst_hoplimit(struct dst_entry *dst);
> diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
> index 86ff1cf..710c966 100644
> --- a/net/ipv6/output_core.c
> +++ b/net/ipv6/output_core.c
> @@ -59,17 +59,24 @@ void ipv6_proxy_select_ident(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
>  
> -void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
> +void ipv6_select_ident_by_addr(struct frag_hdr *fhdr,
> +			       const struct in6_addr *dst,
> +			       const struct in6_addr *src)
>  {
>  	static u32 ip6_idents_hashrnd __read_mostly;
>  	u32 id;
>  
>  	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
>  
> -	id = __ipv6_select_ident(ip6_idents_hashrnd, &rt->rt6i_dst.addr,
> -				 &rt->rt6i_src.addr);
> +	id = __ipv6_select_ident(ip6_idents_hashrnd, dst, src);
>  	fhdr->identification = htonl(id);
>  }
> +EXPORT_SYMBOL(ipv6_select_ident_by_addr);
> +
> +void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)

const struct rt6_info *rt

No need to add const later in a follow up patch.
