From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] ipip: Add room for custom tunnel header
Date: Thu, 08 Aug 2013 09:00:58 -0700
Message-ID: <1375977658.4004.106.camel@edumazet-glaptop>
References: <1375969927-22235-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f170.google.com ([209.85.213.170]:62824 "EHLO
	mail-ye0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab3HHQBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 12:01:08 -0400
Received: by mail-ye0-f170.google.com with SMTP id g12so953802yee.15
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 09:01:07 -0700 (PDT)
In-Reply-To: <1375969927-22235-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 15:52 +0200, Kristian Evensen wrote:
> Hello,

...

> Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
> ---
>  include/uapi/linux/if_tunnel.h |    1 +
>  net/ipv4/ipip.c                |    5 ++++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
> index aee73d0..039bbc3 100644
> --- a/include/uapi/linux/if_tunnel.h
> +++ b/include/uapi/linux/if_tunnel.h
> @@ -35,6 +35,7 @@ struct ip_tunnel_parm {
>  	__be32			i_key;
>  	__be32			o_key;
>  	struct iphdr		iph;
> +	int                     hlen;
>  };
>  
>  enum {
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index 51fc2a1..9705aa1 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -226,6 +226,9 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>  		skb->encapsulation = 1;
>  	}
>  
> +	if (tunnel->hlen > 0)
> +		skb_push(skb, tunnel->hlen);


What happens if hlen is bigger than available headroom ?

hlen comes from userspace and there is no safety check, right ?

What guarantee do we have _something_ will fill the bytes ?
(We do not want to leak prior content of those bytes to the wire)
