From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.25 1/2]S2io: Fix memory leak during free_tx_buffers
Date: Fri, 25 Apr 2008 01:48:08 -0400
Message-ID: <48117098.3090500@garzik.org>
References: <Pine.GSO.4.10.10804231326590.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46817 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754568AbYDYFsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 01:48:10 -0400
In-Reply-To: <Pine.GSO.4.10.10804231326590.10279-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Fix the memory leak during free_tx_buffers.
>  
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -Nurp 2.0.26.20/drivers/net/s2io.c 2.0.26.22-1/drivers/net/s2io.c
> --- 2.0.26.20/drivers/net/s2io.c	2008-04-22 15:02:38.000000000 -0700
> +++ 2.0.26.22-1/drivers/net/s2io.c	2008-04-22 15:12:25.000000000 -0700
> @@ -2339,7 +2339,7 @@ static void free_tx_buffers(struct s2io_
>  	for (i = 0; i < config->tx_fifo_num; i++) {
>  		unsigned long flags;
>  		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags);
> -		for (j = 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
> +		for (j = 0; j < config->tx_cfg[i].fifo_len; j++) {
>  			txdp = (struct TxD *) \
>  			mac_control->fifos[i].list_info[j].list_virt_addr;

applied 1-2 to upstream

since 2.6.25 was released, we need to put in a separate request to 
stable@kernel.org



