From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] 8390 : Replace ei_debug with
 msg_enable/NETIF_MSG_* feature
Date: Wed, 06 Nov 2013 15:49:13 -0800
Message-ID: <1383781753.7940.38.camel@joe-AO722>
References: <1383771418-28616-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matthew Whitehead <tedheadster@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0015.hostedemail.com ([216.40.44.15]:42602 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750717Ab3KFXtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 18:49:10 -0500
In-Reply-To: <1383771418-28616-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 15:56 -0500, Matthew Whitehead wrote:
> Removed the shared ei_debug variable. Replaced it by adding u32 msg_enable to
> the private struct ei_device. Now each 8390 ethernet instance has a per-device
> logging variable.
> 
> Changed printk() calls to netdev_(dbg|info|warn|err) when possible.

Hello Matthew.

Ideally, some of these would use:

	netif_<level>(struct ei_device *, type, struct net_device *, fmt, ...)

> @@ -352,10 +360,12 @@ static void
[]
> +    if (ei_local->msg_enable & NETIF_MSG_HW)
> +		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);

	netif_dbg(ei_local, hw, dev, "resetting the 8390 t=%...\n", jiffies);

> +++ b/drivers/net/ethernet/8390/ax88796.c
> @@ -147,8 +149,8 @@ static void ax_reset_8390(struct net_device *dev)
>  	unsigned long reset_start_time = jiffies;
>  	void __iomem *addr = (void __iomem *)dev->base_addr;
>  
> -	if (ei_debug > 1)
> -		netdev_dbg(dev, "resetting the 8390 t=%ld\n", jiffies);
> +	if (ei_local->msg_enable & NETIF_MSG_HW)
> +		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);

	netif_dbg(ei_local, hw, dev, "resetting" etc...);
