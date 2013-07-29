From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] flow_diseector: Add support for IPPROTO_IPV6
Date: Mon, 29 Jul 2013 08:37:35 -0700
Message-ID: <20130729083735.25ccdaae@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.02.1307290805030.13533@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:65449 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab3G2Phj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 11:37:39 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so1846554pdj.40
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 08:37:38 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1307290805030.13533@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Jul 2013 08:06:51 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

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

The __constant_htons() is unnecessary, the simple macro htons()
is smart enough to figure out what is constant. The current style
preference is to use htons() instead; shorter is better.
