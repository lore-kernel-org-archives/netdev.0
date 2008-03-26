From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.25 1/2]S2io: Handle TX completions on the same CPU
 as the sender for MIS-X interrupts
Date: Tue, 25 Mar 2008 23:20:56 -0400
Message-ID: <47E9C118.40207@garzik.org>
References: <Pine.GSO.4.10.10803251510470.22948-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43460 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755346AbYCZDU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:20:58 -0400
In-Reply-To: <Pine.GSO.4.10.10803251510470.22948-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Handling TX completions on the same cpu as the sender.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> ---
> diff -Nurp 2-0-26-19/drivers/net/s2io.c 2-0-26-21-1/drivers/net/s2io.c
> --- 2-0-26-19/drivers/net/s2io.c	2008-03-20 09:22:03.000000000 +0530
> +++ 2-0-26-21-1/drivers/net/s2io.c	2008-03-20 10:22:25.000000000 +0530
> @@ -4344,6 +4344,9 @@ static int s2io_xmit(struct sk_buff *skb
>  	dev->trans_start = jiffies;
>  	spin_unlock_irqrestore(&fifo->tx_lock, flags);
>  
> +	if (sp->config.intr_type == MSI_X)
> +		tx_intr_handler(fifo);
> +
>  	return 0;
>  pci_map_failed:
>  	stats->pci_map_fail_cnt++;

applied


