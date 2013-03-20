From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] chelsio: use netdev_alloc_skb
Date: Wed, 20 Mar 2013 11:42:32 -0700
Message-ID: <1363804952.3333.29.camel@edumazet-glaptop>
References: <1363797199.3333.18.camel@edumazet-glaptop>
	 <20130320113024.00377b99@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:36075 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933065Ab3CTSmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:42:35 -0400
Received: by mail-pb0-f53.google.com with SMTP id un1so1568613pbc.40
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:42:35 -0700 (PDT)
In-Reply-To: <20130320113024.00377b99@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 11:30 -0700, Stephen Hemminger wrote:
> This extends on Eric's patch. It uses netdev_alloc_skb which fixes a couple of
> other issues.
>   * driver was never setting skb->dev on the received buffer
>   * copybreak allocation wasn't padding buffer
>   * copybreak assumed that ip alignment padding was always 2 (it is platform dependent)
> 
> Compile tested only, don't have this hardware.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> 
> --- a/drivers/net/ethernet/chelsio/cxgb/sge.c	2013-03-20 11:13:47.950986878 -0700
> +++ b/drivers/net/ethernet/chelsio/cxgb/sge.c	2013-03-20 11:24:26.942722757 -0700
> @@ -835,7 +835,7 @@ static void refill_free_list(struct sge
>  		struct sk_buff *skb;
>  		dma_addr_t mapping;
>  
> -		skb = dev_alloc_skb(q->rx_buffer_size);
> +		skb = netdev_alloc_skb(sge->netdev, q->rx_buffer_size);
>  		if (!skb)
>  			break;

Well, this (skb->dev = dev) is done in eth_type_trans()

Many drivers use dev_alloc_skb(), I am not sure we really want to change
them.
