From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Fwd: [PATCH] Spinlock initialisation au1000_eth.c]
Date: Sat, 13 Sep 2008 15:55:32 -0400
Message-ID: <48CC1AB4.6020200@pobox.com>
References: <4886E059.9000106@alpha-bit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Martin Gebert <martin.gebert@alpha-bit.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52786 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553AbYIMTzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:55:37 -0400
In-Reply-To: <4886E059.9000106@alpha-bit.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Gebert wrote:
> Seems like the spinlock for the AU1x00 ethernet device is initialised too
> late, as it is already used in enable_mac(), which is called via
> mii_probe() before the init takes place.
> The attached patch is working here for a Linux Au1100 2.6.22.6 kernel,
> and as far as I checked should also be applicable to the current head
> (just line numbers differ).
> 
> Signed-off-by: Martin Gebert <Martin.Gebert@alpha-bit.de>
> 
> --- drivers/net/au1000_eth.c    2008-06-26 14:21:53.000000000 +0200
> +++ drivers/net/au1000_eth.c    2008-06-26 14:23:00.000000000 +0200
> @@ -656,6 +656,7 @@
>         dev->name, base, irq);
> 
>     aup = dev->priv;
> +    spin_lock_init(&aup->lock);
> 
>     /* Allocate the data buffers */
>     /* Snooping works fine with eth on all au1xxx */
> @@ -766,7 +767,6 @@
>         aup->tx_db_inuse[i] = pDB;
>     }
> 
> -    spin_lock_init(&aup->lock);
>     dev->base_addr = base;
>     dev->irq = irq;

applied


