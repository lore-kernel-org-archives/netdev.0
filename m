From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 1/5] fec: kill warnings
Date: Thu, 03 Apr 2008 16:30:48 +1000
Message-ID: <47F47998.1080702@snapgear.com>
References: <20080402204417.597098190@linutronix.de> <20080402210103.046161355@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:38022 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757659AbYDCGav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 02:30:51 -0400
In-Reply-To: <20080402210103.046161355@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sebastian,

Sebastian Siewior wrote:
> linux-2.6-mk68/drivers/net/fec.c: In function 'fec_enet_module_init':
> linux-2.6-mk68/drivers/net/fec.c:2627: warning: unused variable 'j'
> linux-2.6-mk68/drivers/net/fec.c: At top level:
> linux-2.6-mk68/drivers/net/fec.c:2136: warning: 'mii_link_interrupt' defined but not used
> 
> Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -67,6 +67,11 @@
>  #define	FEC_MAX_PORTS	1
>  #endif
>  
> +#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
> +	defined(CONFIG_M520x) || defined(CONFIG_M532x)
> +#define DONT_NEED_mii_link_interrupt

I think using normal positive logic would be clearer, eg:

   HAVE_mii_link_interupt

Very few of the boards I have come across with the FEC silicon
actually hook up the MII interrupt, so the list of devices that
have it will be smaller.

Regards
Greg



> +#endif
> +
>  /*
>   * Define the fixed address of the FEC hardware.
>   */
> @@ -1222,7 +1227,7 @@ static phy_info_t const * const phy_info
>  };
>  
>  /* ------------------------------------------------------------------------- */
> -#if !defined(CONFIG_M532x)
> +#ifndef DONT_NEED_mii_link_interrupt
>  #ifdef CONFIG_RPXCLASSIC
>  static void
>  mii_link_interrupt(void *dev_id);
> @@ -2126,6 +2131,7 @@ mii_discover_phy(uint mii_reg, struct ne
>  
>  /* This interrupt occurs when the PHY detects a link change.
>  */
> +#ifndef DONT_NEED_mii_link_interrupt
>  #ifdef CONFIG_RPXCLASSIC
>  static void
>  mii_link_interrupt(void *dev_id)
> @@ -2148,6 +2154,7 @@ mii_link_interrupt(int irq, void * dev_i
>  
>  	return IRQ_HANDLED;
>  }
> +#endif
>  
>  static int
>  fec_enet_open(struct net_device *dev)
> @@ -2624,7 +2631,7 @@ fec_stop(struct net_device *dev)
>  static int __init fec_enet_module_init(void)
>  {
>  	struct net_device *dev;
> -	int i, j, err;
> +	int i, err;
>  	DECLARE_MAC_BUF(mac);
>  
>  	printk("FEC ENET Version 0.2\n");
> 

-- 
------------------------------------------------------------------------
Greg Ungerer  --  Chief Software Dude       EMAIL:     gerg@snapgear.com
Secure Computing Corporation                PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
