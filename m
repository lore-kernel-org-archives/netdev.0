From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] flow_diseector: Add support for IPPROTO_IPV6
Date: Mon, 29 Jul 2013 10:10:19 -0700
Message-ID: <1375117819.10515.8.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1307290805030.13533@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:64825 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab3G2RKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 13:10:21 -0400
Received: by mail-pa0-f44.google.com with SMTP id jh10so6074413pab.31
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 10:10:20 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1307290805030.13533@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-29 at 08:06 -0700, Tom Herbert wrote:
> Add support for dissecting flows in IPv6/IPv4 packets.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/flow_dissector.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 00ee068..96901de 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -139,7 +139,11 @@ ipv6:
>  		break;
>  	}
>  	case IPPROTO_IPIP:
> -		goto again;
> +		proto = __constant_htons(ETH_P_IP);
> +		goto ip;
> +	case IPPROTO_IPV6:
> +		proto = __constant_htons(ETH_P_IPV6);
> +		goto ipv6;
>  	default:
>  		break;
>  	}

It seems this patch makes two different changes, but changelog is vague.
(As if we were not dissecting flows in IPv4/IPv6 packets ...)

How about :

1) Fix a problem if IPIP is tunneled into IPv6
   Prior code assumed IPIP was encapsulated into IPv4 only. 

2) Add support for IPPROTO_IPV6

Thanks

BTW it looks like we do not support ETH_P_8021AD yet
