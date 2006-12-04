From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.19] AT91RM9200 Ethernet update 1
Date: Mon, 4 Dec 2006 10:00:04 -0800
Message-ID: <20061204100004.3538d7ff@freekitty>
References: <1165235217.4525.100.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:46035 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758916AbWLDSAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 13:00:34 -0500
To: Andrew Victor <andrew@sanpeople.com>
In-Reply-To: <1165235217.4525.100.camel@fuzzie.sanpeople.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04 Dec 2006 14:26:57 +0200
Andrew Victor <andrew@sanpeople.com> wrote:

> This patch is an update to the Atmel AT91RM9200 Ethernet driver.
> 
> 1. Remove the global 'at91_dev' variable. 
> 2. Move the global 'check_timer' variable into the private data
> structure.
> 
> 
> Signed-off-by: Andrew Victor <andrew@sanpeople.com>
> 
> 
> diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
> --- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Sat Dec  2 17:28:27 2006
> +++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Mon Dec  4 14:13:01 2006
> @@ -41,9 +41,6 @@
>  #define DRV_NAME	"at91_ether"
>  #define DRV_VERSION	"1.0"
>  
> -static struct net_device *at91_dev;
> -
> -static struct timer_list check_timer;
>  #define LINK_POLL_INTERVAL	(HZ)
>  
>  /* ..................................................................... */
> @@ -252,8 +249,8 @@
>  		 * PHY doesn't have an IRQ pin (RTL8201, DP83847, AC101L),
>  		 * or board does not have it connected.
>  		 */
> -		check_timer.expires = jiffies + LINK_POLL_INTERVAL;
> -		add_timer(&check_timer);
> +		lp->check_timer.expires = jiffies + LINK_POLL_INTERVAL;
> +		add_timer(&lp->check_timer);
>  		return;
>  	}
>  
> @@ -300,7 +297,7 @@
>  
>  	irq_number = lp->board_data.phy_irq_pin;
>  	if (!irq_number) {
> -		del_timer_sync(&check_timer);
> +		del_timer_sync(&lp->check_timer);
>  		return;
>  	}
>  
> @@ -362,13 +359,14 @@
>  static void at91ether_check_link(unsigned long dev_id)
>  {
>  	struct net_device *dev = (struct net_device *) dev_id;
> +	struct at91_private *lp = (struct at91_private *) dev->priv;

No cast needed.
Use netdev_priv(dev) rather than dev->priv.  netdev_priv() is a constant
offset so the compiler can save a register.


-- 
Stephen Hemminger <shemminger@osdl.org>
