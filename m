From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][KS8695] Mark network interface as running on ifconfig
 up
Date: Tue, 16 Feb 2010 16:06:47 -0800 (PST)
Message-ID: <20100216.160647.208330407.davem@davemloft.net>
References: <4B73E62B.3030305@visionsystems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, avictor.za@gmail.com,
	netdev@vger.kernel.org
To: yegor_sub1@visionsystems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933672Ab0BQAGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 19:06:32 -0500
In-Reply-To: <4B73E62B.3030305@visionsystems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegor_sub1@visionsystems.de>
Date: Thu, 11 Feb 2010 12:12:43 +0100

> [KS8695] Mark network interface as running on ifconfig up
> 
> Without netif_carrier_on() network interface will not transmit any packets
> after ifconfig down and subsequent ifconfig up.
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
> 
> Index: linux-2.6.33-rc7/drivers/net/arm/ks8695net.c
> ===================================================================
> --- linux-2.6.33-rc7.orig/drivers/net/arm/ks8695net.c
> +++ linux-2.6.33-rc7/drivers/net/arm/ks8695net.c
> @@ -1371,6 +1371,7 @@ ks8695_open(struct net_device *ndev)
>  
>  	napi_enable(&ksp->napi);
>  	netif_start_queue(ndev);
> +	netif_carrier_on(ndev);
>  
>  	return 0;
>  }
> 

Only ks8695_link_irq() should be setting the carrier state.

If necessary, reset the PHY on device open so that the link up
interrupt arrives and the code handling that event can set the carrier
status properly.

This is how every other driver handles this situation.

