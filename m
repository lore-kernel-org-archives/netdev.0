From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] net: Don't clear skbuff hash for IP
 fragments
Date: Thu, 20 Mar 2014 18:47:59 -0700
Message-ID: <1395366479.9114.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1403201702170.7148@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:48979 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759424AbaCUBsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 21:48:03 -0400
Received: by mail-pa0-f52.google.com with SMTP id rd3so1753271pab.39
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 18:48:02 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1403201702170.7148@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-20 at 17:09 -0700, Tom Herbert wrote:
> There is nothing to gain by clearing hash, it shouldn't be an L4
> hash anyway.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv4/ip_fragment.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index c10a3ce..10a64de 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -704,7 +704,6 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
>  			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
>  			if (ip_defrag(skb, user))
>  				return NULL;
> -			skb_clear_hash(skb);
>  		}
>  	}
>  	return skb;

It might be worth checking ip_defrag() will set skb->hash to the hash
provided in the first fragment, the one that might give l4 info...
