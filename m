From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: resolve tx multiqueue bug
Date: Fri, 18 Jul 2008 17:04:42 -0700
Message-ID: <9929d2390807181704u4e969d2bpb39683b7160b4939@mail.gmail.com>
References: <20080718.033947.193705552.davem@davemloft.net>
	 <20080718165128.GC10471@solarflare.com>
	 <20080718170529.GD10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:14071 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756795AbYGSAEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 20:04:42 -0400
Received: by rv-out-0506.google.com with SMTP id k40so501962rvb.1
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 17:04:42 -0700 (PDT)
In-Reply-To: <20080718170529.GD10471@solarflare.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 10:05 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> With the recent changes to tx mutiqueue, e1000 was not calling
> netif_start_queue() before calling netif_wake_queue().
> This causes an oops during loading of the driver.
>
> (Based on commit d55b53fff0c2ddb639dca04c3f5a0854f292d982.)
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index f8df8bd..cf12b05 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1472,6 +1472,8 @@ e1000_open(struct net_device *netdev)
>
>        e1000_irq_enable(adapter);
>
> +       netif_start_queue(netdev);
> +
>        /* fire a link status change interrupt to start the watchdog */
>        E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
>
> --

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
