From: David Miller <davem@davemloft.net>
Subject: Re: macvlan: optimizing the receive path?
Date: Sat, 04 Oct 2014 20:42:03 -0400 (EDT)
Message-ID: <20141004.204203.2211720828886085354.davem@davemloft.net>
References: <542DB55D.3090601@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaJEAmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:42:05 -0400
In-Reply-To: <542DB55D.3090601@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Thu, 02 Oct 2014 16:28:13 -0400

> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -321,8 +321,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>         skb->dev = dev;
>         skb->pkt_type = PACKET_HOST;
>  
> -       ret = netif_rx(skb);
> -
> +      macvlan_count_rx(vlan, len, true, 0);
> +      return RX_HANDLER_ANOTHER;
>  out:
>         macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
>         return RX_HANDLER_CONSUMED;

That last argument to macvlan_count_rx() is a bool and thus should be
specified as "false".  Yes I know other areas of this file get it
wrong too.

Also, what about GRO?  Won't we get GRO processing if we do this via
netif_rx() but not via the RX_HANDLER_ANOTHER route?  Just curious...
