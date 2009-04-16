From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Thu, 16 Apr 2009 11:07:53 +0200
Message-ID: <20090416110753.5c75b805@hskinnemoen-d830>
References: <20090415154658.40e3639a@surf>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Michael Opdenacker <michael@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:57468 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbZDPJIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 05:08:01 -0400
In-Reply-To: <20090415154658.40e3639a@surf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Petazzoni wrote:
> macb: Add support of the netpoll API
> 
> With this patch in place, I'm successfully able to use the netconsole
> mechanism with the Calao USB-A9263 board, which uses the AT91SAM9263
> CPU, which in terms of Ethernet controller is supported by the macb
> driver.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  drivers/net/macb.c |   16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> Index: linux/drivers/net/macb.c
> ===================================================================
> --- linux.orig/drivers/net/macb.c
> +++ linux/drivers/net/macb.c
> @@ -616,6 +616,19 @@
>  	return IRQ_HANDLED;
>  }
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +/*
> + * Polling receive - used by netconsole and other diagnostic tools
> + * to allow network i/o with interrupts disabled.
> + */
> +static void macb_poll_controller(struct net_device *dev)
> +{
> +	disable_irq(dev->irq);

Hmm...is this safe? What if printk() is called from the macb interrupt
handler?

Haavard
