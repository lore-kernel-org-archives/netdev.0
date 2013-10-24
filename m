From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] macsonic: Updated printk() statement to KERN
 style leading argument.
Date: Thu, 24 Oct 2013 15:30:52 -0700
Message-ID: <1382653852.22433.82.camel@joe-AO722>
References: <1382650645-23973-1-git-send-email-zanchm@rpi.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matt Zanchelli <zanchm@rpi.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0107.hostedemail.com ([216.40.44.107]:32950 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754267Ab3JXWaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 18:30:55 -0400
In-Reply-To: <1382650645-23973-1-git-send-email-zanchm@rpi.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 21:37 +0000, Matt Zanchelli wrote:
> Updated prinkt() statement in mac_sonic_probe() function to match current
> convention of using KERN style leading argument.

s/prinkt/printk/

> diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
[]
> @@ -601,7 +601,7 @@ found:
>  	if (err)
>  		goto out;
>  
> -	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
> +	printk(KERN_INFO "%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);

It'd be nicer to use:

	netdev_info(dev, "MAC %pM IRQ %d\n", dev->dev_addr, dev->irq);

Nicer still to convert all the printks in this
file to netdev_<level> where possible.
