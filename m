From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: avoid ufo handling on IP payload compression
 packets
Date: Tue, 07 Mar 2017 13:46:18 -0800 (PST)
Message-ID: <20170307.134618.1090919290354374776.davem@davemloft.net>
References: <1488544652-28475-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756180AbdCGWlH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:41:07 -0500
In-Reply-To: <1488544652-28475-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Fri,  3 Mar 2017 15:37:32 +0300

> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index b67719f..18383ef 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -960,7 +960,10 @@ static int __ip_append_data(struct sock *sk,
>  	cork->length += length;
>  	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
>  	    (sk->sk_protocol == IPPROTO_UDP) &&
> -	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
> +	    (rt->dst.dev->features & NETIF_F_UFO) &&
> +#ifdef CONFIG_XFRM
> +	    !rt->dst.xfrm &&
> +#endif

As Steffen has suggested, please use dst_xfrm().
