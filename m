From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter/IPv6: fix DSCP mangle code
Date: Fri, 22 Apr 2011 00:08:38 -0700 (PDT)
Message-ID: <20110422.000838.193727308.davem@davemloft.net>
References: <1303455759.2023.39.camel@nausicaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org
To: fernando@oss.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751746Ab1DVHJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 03:09:13 -0400
In-Reply-To: <1303455759.2023.39.camel@nausicaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Date: Fri, 22 Apr 2011 16:02:39 +0900

> The mask indicates the bits one wants to zero out, so it needs to be
> inverted before applying to the original TOS field.
> 
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> ---

Netfilter patches should be sent to the netfilter developer
list, CC:'d

> diff -urNp linux-2.6.37-orig/net/netfilter/xt_DSCP.c linux-2.6.37/net/netfilter/xt_DSCP.c
> --- linux-2.6.37-orig/net/netfilter/xt_DSCP.c	2011-01-05 09:50:19.000000000 +0900
> +++ linux-2.6.37/net/netfilter/xt_DSCP.c	2011-04-21 16:01:25.801890733 +0900
> @@ -99,7 +99,7 @@ tos_tg6(struct sk_buff *skb, const struc
>  	u_int8_t orig, nv;
>  
>  	orig = ipv6_get_dsfield(iph);
> -	nv   = (orig & info->tos_mask) ^ info->tos_value;
> +	nv   = (orig & ~info->tos_mask) ^ info->tos_value;
>  
>  	if (orig != nv) {
>  		if (!skb_make_writable(skb, sizeof(struct iphdr)))
> 
> 
