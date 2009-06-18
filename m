From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Wed, 17 Jun 2009 22:10:08 -0400
Message-ID: <4A39A200.20603@hp.com>
References: <4A37E715.4060504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:17156 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447AbZFRCKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:10:06 -0400
In-Reply-To: <4A37E715.4060504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote:
> Ensure that index `code' remains within array tab_unreach[]
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 36dff88..8f850de 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -923,7 +923,7 @@ int icmpv6_err_convert(int type, int code, int *err)
>  	switch (type) {
>  	case ICMPV6_DEST_UNREACH:
>  		fatal = 1;
> -		if (code <= ICMPV6_PORT_UNREACH) {
> +		if (code <= ICMPV6_PORT_UNREACH && code >= 0) {
>  			*err  = tab_unreach[code].err;
>  			fatal = tab_unreach[code].fatal;
>  		}

The code value in the ICMPv6 header is a u8, so should always be positive, right?
It doesn't hurt I guess though.

-Brian
