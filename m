From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] pcnet32: round off carrier watch timer
Date: Thu, 08 Jan 2009 08:32:47 +0800
Message-ID: <496549AF.3050500@cn.fujitsu.com>
References: <20090107121036.4e16b7cf@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54051 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752117AbZAHAcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 19:32:47 -0500
In-Reply-To: <20090107121036.4e16b7cf@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2009-1-8 4:10:
> The link check watchdog timer on this driver fires every two seconds, but
> since not aligned it causes extra wakeups. It is more important on this
> driver than most because it is the hardware that is emulated by default
> when using network interfaces on VMware.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/pcnet32.c	2009-01-07 12:05:54.218712996 -0800
> +++ b/drivers/net/pcnet32.c	2009-01-07 12:06:37.430288101 -0800
> @@ -2282,7 +2282,7 @@ static int pcnet32_open(struct net_devic
>  	if (lp->chip_version >= PCNET32_79C970A) {
>  		/* Print the link status and start the watchdog */
>  		pcnet32_check_media(dev, 1);
> -		mod_timer(&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
> +		mod_timer(&lp->watchdog_timer, PCNET32_WATCHDOG_TIMEOUT);

should be
+		mod_timer(&lp->watchdog_timer, round_jiffies(PCNET32_WATCHDOG_TIMEOUT));
same as that in pcnet32_watchdog()?

>  	}
>  
>  	i = 0;
> @@ -2917,7 +2917,7 @@ static void pcnet32_watchdog(struct net_
>  	pcnet32_check_media(dev, 0);
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  
> -	mod_timer(&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
> +	mod_timer(&lp->watchdog_timer, round_jiffies(PCNET32_WATCHDOG_TIMEOUT));
>  }
>  
>  static int pcnet32_pm_suspend(struct pci_dev *pdev, pm_message_t state)
