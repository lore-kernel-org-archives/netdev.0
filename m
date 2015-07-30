From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169:Place dma_alloc_coherent on interrupt
 context
Date: Thu, 30 Jul 2015 13:45:25 -0700 (PDT)
Message-ID: <20150730.134525.824837450657122732.davem@davemloft.net>
References: <1438284801-4188-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbbG3Up1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 16:45:27 -0400
In-Reply-To: <1438284801-4188-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <corcodel.marian@gmail.com>
Date: Thu, 30 Jul 2015 22:33:21 +0300

>    According to this doc
>  https://www.kernel.org/doc/Documentation/DMA-API.txt   dma_alloc_coherent
>  must run on interrupt context, and flush the chip before use.
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 3df51fa..edce264 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7535,15 +7535,15 @@ static void rtl8169_down(struct net_device *dev)
>  	rtl_pll_power_down(tp);
>  }
>  
> -static int rtl8169_close(struct net_device *dev)
> +/*static int rtl8169_close(struct net_device *dev)

This really isn't acceptable.
