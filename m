From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 4/5]S2io: Check for CARD_DOWN before handling traffic
Date: Fri, 31 Aug 2007 09:03:55 -0400
Message-ID: <46D811BB.5060007@garzik.org>
References: <1187223149.23940.337.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53775 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399AbXHaND4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:03:56 -0400
In-Reply-To: <1187223149.23940.337.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
> - Added check to return from the traffic handling function, if the card status 
>   is DOWN.
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -Nurp patch3/drivers/net/s2io.c patch4/drivers/net/s2io.c
> --- patch3/drivers/net/s2io.c	2007-08-15 08:57:32.000000000 -0700
> +++ patch4/drivers/net/s2io.c	2007-08-15 08:42:14.000000000 -0700
> @@ -2927,6 +2927,11 @@ static int s2io_poll(struct net_device *
>  	int i;
>  
>  	atomic_inc(&nic->isr_cnt);
> +	if (unlikely(atomic_read(&nic->card_state) == CARD_DOWN)) {
> +		atomic_dec(&nic->isr_cnt);
> +		return IRQ_NONE;
> +	}
> +
>  	mac_control = &nic->mac_control;
>  	config = &nic->config;
>  

invalid return value, for this function

Overall, this looks quite racy -- why does the card state differ from 
net_device state in the first place?

