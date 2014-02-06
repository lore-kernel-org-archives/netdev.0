From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCHv1 net] tg3: fix deadlock in tg3_change_mtu()
Date: Thu, 6 Feb 2014 10:43:49 +0000
Message-ID: <52F36765.6050403@citrix.com>
References: <1391540487-31207-1-git-send-email-david.vrabel@citrix.com> <52F2B6B2.1020901@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25192 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813AbaBFKnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 05:43:51 -0500
In-Reply-To: <52F2B6B2.1020901@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/14 22:09, Nithin Nayak Sujir wrote:
> 
> David,
> Rather than doing it this way, I think it's sufficient to move the call
> to tg3_set_mtu() between tg3_netif_stop() and tg3_full_lock().
> 
> Before tg3 started using set_bit() for flags, tg3_set_mtu() needed to be
> under a lock, but that's not the case anymore.
> 
> Can you try this patch?

That looks better.

Tested-by: David Vrabel <david.vrabel@citrix.com>

Thanks.

David

> diff --git a/drivers/net/ethernet/broadcom/tg3.c
> b/drivers/net/ethernet/broadcom/tg3.c
> index e2ca03e..0bb79b8 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -14113,12 +14113,12 @@ static int tg3_change_mtu(struct net_device
> *dev, int new_mtu)
> 
>         tg3_netif_stop(tp);
> 
> +       tg3_set_mtu(dev, tp, new_mtu);
> +
>         tg3_full_lock(tp, 1);
> 
>         tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
> 
> -       tg3_set_mtu(dev, tp, new_mtu);
> -
>         /* Reset PHY, otherwise the read DMA engine will be in a mode that
>          * breaks all requests to 256 bytes.
>          */
> 
> Nithin.
