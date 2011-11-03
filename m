From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 2/2] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Thu, 03 Nov 2011 11:03:46 +0100
Message-ID: <4EB26702.60506@hartkopp.net>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT> <1320313675-30749-1-git-send-email-mkl@pengutronix.de> <1320313675-30749-3-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kurt.van.dijck@eia.be, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:27225 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740Ab1KCKEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 06:04:11 -0400
In-Reply-To: <1320313675-30749-3-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.11.2011 10:47, Marc Kleine-Budde wrote:

> @@ -609,9 +605,10 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
>  
>  	/* transmission complete interrupt */
>  	if (reg_iflag1 & (1 << FLEXCAN_TX_BUF_ID)) {
> -		/* tx_bytes is incremented in flexcan_start_xmit */
> +		stats->tx_bytes += can_get_echo_skb(dev, 0);
>  		stats->tx_packets++;
>  		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
> +		can_get_echo_skb(dev, 0);
>  		netif_wake_queue(dev);
>  	}


What's the reason for the second can_get_echo_skb() here?

IIRC the skb is already netif_rx'ed and consumed by the first attempt.

Regards,
Oliver
