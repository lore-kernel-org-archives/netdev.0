From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix
Date: Thu, 07 Feb 2008 11:24:17 +0100
Message-ID: <47AADC51.8060401@eptar.com>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <47A9EA42.3080800@eptar.com> <20080206173342.21CDF8E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay04.albacom.net ([217.220.57.147]:33957 "EHLO
	fe-relay04.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbYBGKXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 05:23:11 -0500
In-Reply-To: <20080206173342.21CDF8E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> Prevent oops on enc28j60 packet RX:  make sure buffers are aligned.
> Not all architectures support unaligned accesses in kernel space.
>
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
>   

Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>

> ---
>  drivers/net/enc28j60.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletion(-)
>
> --- a/drivers/net/enc28j60.c	2008-02-06 09:29:00.000000000 -0800
> +++ b/drivers/net/enc28j60.c	2008-02-06 09:30:03.000000000 -0800
> @@ -900,7 +900,7 @@ static void enc28j60_hw_rx(struct net_de
>  		if (RSV_GETBIT(rxstat, RSV_LENCHECKERR))
>  			ndev->stats.rx_frame_errors++;
>  	} else {
> -		skb = dev_alloc_skb(len);
> +		skb = dev_alloc_skb(len + NET_IP_ALIGN);
>  		if (!skb) {
>  			if (netif_msg_rx_err(priv))
>  				dev_err(&ndev->dev,
> @@ -908,6 +908,7 @@ static void enc28j60_hw_rx(struct net_de
>  			ndev->stats.rx_dropped++;
>  		} else {
>  			skb->dev = ndev;
> +			skb_reserve(skb, NET_IP_ALIGN);
>  			/* copy the packet from the receive buffer */
>  			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
>  					len, skb_put(skb, len));
>
>
>   

