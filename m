From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: fix a potential use after free in ip6_offload.c
Date: Sat, 18 Oct 2014 08:50:39 -0700
Message-ID: <1413647439.27176.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413624462-13106-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:38584 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaJRPul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 11:50:41 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so2427416pdb.21
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 08:50:41 -0700 (PDT)
In-Reply-To: <1413624462-13106-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-10-18 at 17:27 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() maybe change skb->data and make opth pointer oboslete,
> so set the opth again
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/ip6_offload.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 9034f76..91014d3 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -46,6 +46,7 @@ static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
>  		if (unlikely(!pskb_may_pull(skb, len)))
>  			break;
>  
> +		opth = (void *)skb->data;
>  		proto = opth->nexthdr;
>  		__skb_pull(skb, len);
>  	}

Acked-by: Eric Dumazet <edumazet@google.com>
