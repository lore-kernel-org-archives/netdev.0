From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 11:08:11 -0800 (PST)
Message-ID: <20160129.110811.1595768260535944996.davem@davemloft.net>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454092810.7627.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbcA2TIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:08:11 -0500
In-Reply-To: <1454092810.7627.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jan 2016 10:40:10 -0800

> I would try following ixgbe fix (sorry, totally untested, but you get
> the idea...)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index c4003a88bbf6..7ba64ed463a6 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1525,7 +1525,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
>  
>  	bi->dma = dma;
>  	bi->page = page;
> -	bi->page_offset = 0;
> +	bi->page_offset = NET_IP_ALIGN;
>  
>  	return true;
>  }

Hmmm, wouldn't this waste 2 bytes on all pages?  Or just the head one with the headers?
