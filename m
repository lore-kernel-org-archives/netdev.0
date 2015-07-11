From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] gianfar: Fix and cleanup rxbd status
 handling
Date: Fri, 10 Jul 2015 18:25:16 -0700 (PDT)
Message-ID: <20150710.182516.1107515769111345392.davem@davemloft.net>
References: <1436459084-14103-1-git-send-email-claudiu.manoil@freescale.com>
	<1436459084-14103-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632AbbGKGKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:10:30 -0400
In-Reply-To: <1436459084-14103-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 9 Jul 2015 19:24:42 +0300

> @@ -2921,6 +2921,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>  	i = rx_queue->next_to_clean;
>  
>  	while (rx_work_limit--) {
> +		unsigned long lstatus;
>  
>  		if (cleaned_cnt >= GFAR_RX_BUFF_ALLOC) {
>  			gfar_alloc_rx_buffs(rx_queue, cleaned_cnt);
> @@ -2928,7 +2929,8 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>  		}
>  
>  		bdp = &rx_queue->rx_bd_base[i];
> -		if (be16_to_cpu(bdp->status) & RXBD_EMPTY)
> +		lstatus = be32_to_cpu(bdp->lstatus);
> +		if (lstatus & BD_LFLAG(RXBD_EMPTY))
>  			break;
>  
>  		/* order rx buffer descriptor reads */

"lstatus" is not an "unsigned long", it's a "u32".

Don't use ambiguous types for objects with exact known sizes.
