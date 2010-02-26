From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] isa-skelton: Remove a wrong netif_wake_queue() call
Date: Fri, 26 Feb 2010 12:03:47 -0500
Message-ID: <4B87FEF3.5020809@garzik.org>
References: <1267027217-7812-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:49470 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965375Ab0BZRDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 12:03:54 -0500
Received: by gyh20 with SMTP id 20so136545gyh.19
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 09:03:53 -0800 (PST)
In-Reply-To: <1267027217-7812-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2010 11:00 AM, Atsushi Nemoto wrote:
> The netif_wake_queue() is called correctly (i.e. only on !txfull
> condition) from net_tx().  So Unconditional call to the
> netif_wake_queue() here is wrong.  This might cause calling of
> start_xmit routine on txfull state and trigger tx-ring overflow.
>
> This fix is ported from commit 662a96bd6f020782dfbdc0d0bd177c7dbb556687.
>
> Signed-off-by: Atsushi Nemoto<anemo@mba.ocn.ne.jp>
> ---
>   drivers/net/isa-skeleton.c |    1 -
>   1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
> index 04d0502..3f33c90 100644
> --- a/drivers/net/isa-skeleton.c
> +++ b/drivers/net/isa-skeleton.c
> @@ -536,7 +536,6 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
>   		/* Transmit complete. */
>   		net_tx(dev);
>   		np->stats.tx_packets++;
> -		netif_wake_queue(dev);
>   	}
>   #endif

I would suggest deleting this "driver" entirely...  Any new drivers 
remotely like ISA would use the platform API and look more like a PCI 
driver.

	Jeff



