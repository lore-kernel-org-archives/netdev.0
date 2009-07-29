From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [IPV4]: Buffer overflow
Date: Thu, 30 Jul 2009 00:02:39 +0200
Message-ID: <4A70C6FF.9060302@gmail.com>
References: <4A702A02.30509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f228.google.com ([209.85.220.228]:61447 "EHLO
	mail-fx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbZG2WCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 18:02:48 -0400
Received: by fxm28 with SMTP id 28so277945fxm.17
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 15:02:47 -0700 (PDT)
In-Reply-To: <4A702A02.30509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote, On 07/29/2009 12:52 PM:

> If arp_format_neigh_entry() can be called with n->dev->addr_len == 0, then a
> write to hbuffer[-1] occurs.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Found with Parfait, http://research.sun.com/projects/parfait/
> 
> It's not clear whether this can happen or not.
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index c29d75d..252336f 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -1304,7 +1304,8 @@ static void arp_format_neigh_entry(struct seq_file *seq,
>  		hbuffer[k++] = hex_asc_lo(n->ha[j]);
>  		hbuffer[k++] = ':';
>  	}
> -	hbuffer[--k] = 0;
> +	if (k != 0)
> +		hbuffer[--k] = 0;


I guess for k == 0 we need hbuffer[0] = 0 too.

Jarek P.

>  #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
>  	}
>  #endif
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


