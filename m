From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.19] AT91RM9200 Ethernet update 2
Date: Mon, 4 Dec 2006 10:01:24 -0800
Message-ID: <20061204100124.619de892@freekitty>
References: <1165236128.4606.104.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:46141 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758992AbWLDSBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 13:01:43 -0500
To: Andrew Victor <andrew@sanpeople.com>
In-Reply-To: <1165236128.4606.104.camel@fuzzie.sanpeople.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04 Dec 2006 14:42:08 +0200
Andrew Victor <andrew@sanpeople.com> wrote:

> This patch adds NetPoll / NetConsole support to the Atmel AT91RM9200
> Ethernet driver.
> 
> Original patch from Bill Gatliff.
> 
> 
> Signed-off-by: Andrew Victor <andrew@sanpeople.com>
> 
> 
> diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
> --- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Mon Dec  4 14:27:21 2006
> +++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Mon Dec  4 14:33:35 2006
> @@ -925,6 +925,17 @@
>  	return IRQ_HANDLED;
>  }
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void at91ether_poll_controller(struct net_device *dev)
> +{
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	at91ether_interrupt(dev->irq, dev, NULL);
> +	local_irq_restore(flags);
> +}
> +#endif

poll_controller is always called with interrupts already disabled.

The third argument to interrupt routines was dropped (struct pt_regs) in 2.6.19.
Maybe that never got fixed in ARM?

-- 
Stephen Hemminger <shemminger@osdl.org>
