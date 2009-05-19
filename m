From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC 1/5] net: bridge - use is_multicast_ether_addr helper
Date: Tue, 19 May 2009 15:18:02 -0700
Message-ID: <20090519151802.22debf54@nehalam>
References: <20090511114639.440944109@openvz.org>
	<20090511125350.555985895@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, xemul@openvz.org,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41238 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754019AbZESWSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:18:17 -0400
In-Reply-To: <20090511125350.555985895@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 May 2009 15:46:40 +0400
Cyrill Gorcunov <gorcunov@openvz.org> wrote:

> Instead of handwritten constrcution it's better 
> to use is_multicast_ether_addr.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>  net/bridge/br_device.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.git/net/bridge/br_device.c
> =====================================================================
> --- linux-2.6.git.orig/net/bridge/br_device.c
> +++ linux-2.6.git/net/bridge/br_device.c
> @@ -32,7 +32,7 @@ int br_dev_xmit(struct sk_buff *skb, str
>  	skb_reset_mac_header(skb);
>  	skb_pull(skb, ETH_HLEN);
>  
> -	if (dest[0] & 1)
> +	if (is_multicast_ether_addr(dest))
>  		br_flood_deliver(br, skb);
>  	else if ((dst = __br_fdb_get(br, dest)) != NULL)
>  		br_deliver(dst->dst, skb);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


This is trivial and fine.
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
