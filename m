From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: use unlikely to optimise in ip_forward
Date: Sun, 09 Mar 2014 23:03:54 -0700
Message-ID: <1394431434.3607.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394428209-9919-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:40661 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaCJGEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 02:04:07 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so6662791pdb.28
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 23:04:04 -0700 (PDT)
In-Reply-To: <1394428209-9919-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 13:10 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The condition that skb->pkt_type is not PACKET_HOST in ip_forward, should never
> happen, so use unlikely to optimise this check
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv4/ip_forward.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
> index be8abe7..b82833a 100644
> --- a/net/ipv4/ip_forward.c
> +++ b/net/ipv4/ip_forward.c
> @@ -128,7 +128,7 @@ int ip_forward(struct sk_buff *skb)
>  	struct ip_options *opt	= &(IPCB(skb)->opt);
>  
>  	/* that should never happen */
> -	if (skb->pkt_type != PACKET_HOST)
> +	if (unlikely(skb->pkt_type != PACKET_HOST))
>  		goto drop;
>  
>  	if (skb_warn_if_lro(skb))

Compilers already do the right thing.

This is one of the reason you see so many goto in the kernel.
