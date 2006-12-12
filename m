From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2.6.19] e100: replace kmalloc with kcalloc
Date: Tue, 12 Dec 2006 10:34:26 -0800
Message-ID: <457EF632.4060106@intel.com>
References: <1165942531.5611.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org,
	john.ronciak@intel.com, NetDev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26448 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539AbWLLSeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 13:34:31 -0500
To: Yan Burman <burman.yan@gmail.com>
In-Reply-To: <1165942531.5611.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yan Burman wrote:
> Replace kmalloc+memset with kcalloc

ACK, fine with me.

> Signed-off-by: Yan Burman <burman.yan@gmail.com>
> 
> diff -rubp linux-2.6.19-rc5_orig/drivers/net/e100.c linux-2.6.19-rc5_kzalloc/drivers/net/e100.c
> --- linux-2.6.19-rc5_orig/drivers/net/e100.c	2006-11-09 12:16:21.000000000 +0200
> +++ linux-2.6.19-rc5_kzalloc/drivers/net/e100.c	2006-11-11 22:44:04.000000000 +0200
> @@ -1930,9 +1930,8 @@ static int e100_rx_alloc_list(struct nic
>  	nic->rx_to_use = nic->rx_to_clean = NULL;
>  	nic->ru_running = RU_UNINITIALIZED;
>  
> -	if(!(nic->rxs = kmalloc(sizeof(struct rx) * count, GFP_ATOMIC)))
> +	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
>  		return -ENOMEM;
> -	memset(nic->rxs, 0, sizeof(struct rx) * count);
>  
>  	for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
>  		rx->next = (i + 1 < count) ? rx + 1 : nic->rxs;
> 
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
