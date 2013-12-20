From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: release dst properly in ipip6_tunnel_xmit
Date: Fri, 20 Dec 2013 06:16:46 -0800
Message-ID: <1387549006.19078.428.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387531212-17034-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:44097 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030197Ab3LTOQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:16:49 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so2558341pdj.22
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:16:48 -0800 (PST)
In-Reply-To: <1387531212-17034-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 17:20 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> if a dst is not attached to anywhere, it should be released before
> exit ipip6_tunnel_xmit, otherwise cause dst memory leakage.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/sit.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 366fbba..d68a224 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -966,8 +966,10 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
>  	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
>  
>  	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
> -	if (IS_ERR(skb))
> +	if (IS_ERR(skb)) {
> +		ip_rt_put(rt);
>  		goto out;
> +	}
>  
>  	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, IPPROTO_IPV6, tos,
>  			    ttl, df, !net_eq(tunnel->net, dev_net(dev)));


Fixes: 61c1db7fae21 ("ipv6: sit: add GSO/TSO support")
Acked-by: Eric Dumazet <edumazet@google.com>

Thanks a lot !
