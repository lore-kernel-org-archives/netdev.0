From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] ipv6: Resolve sparce error with fragment id
 selection
Date: Thu, 05 Feb 2015 06:57:56 -0800
Message-ID: <1423148276.31870.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423147297-4757-1-git-send-email-vyasevic@redhat.com>
	 <1423147297-4757-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:59206 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757488AbbBEO56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:57:58 -0500
Received: by mail-ig0-f172.google.com with SMTP id l13so43388876iga.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:57:57 -0800 (PST)
In-Reply-To: <1423147297-4757-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-05 at 09:41 -0500, Vladislav Yasevich wrote:
> Resolve the following sparce error:
>  net/ipv6/output_core.c:57:38: sparse: incorrect type in assignment
>  (different base types)
>    net/ipv6/output_core.c:57:38:    expected restricted __be32
> [usertype] ip6_frag_id
>    net/ipv6/output_core.c:57:38:    got unsigned int [unsigned]
> [assigned] [usertype] id
> 

patch title is misleading.

Lot of 'sparse bugs' are about not using proper types, but here
a bug on little endian arches is fixed.

sparse helped to detect the bug.

> Fixes: 0508c07f5e0c9 (ipv6: Select fragment id during UFO segmentation
> if not set.)

Please do not wrap this line

> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  net/ipv6/output_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
> index 54520a0..a86cf60 100644
> --- a/net/ipv6/output_core.c
> +++ b/net/ipv6/output_core.c
> @@ -54,7 +54,7 @@ void ipv6_proxy_select_ident(struct sk_buff *skb)
>  
>  	id = __ipv6_select_ident(ip6_proxy_idents_hashrnd,
>  				 &addrs[1], &addrs[0]);
> -	skb_shinfo(skb)->ip6_frag_id = id;
> +	skb_shinfo(skb)->ip6_frag_id = htonl(id);
>  }
>  EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
>  
