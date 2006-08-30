From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG] in skge.c on 2.6.18-rc5
Date: Wed, 30 Aug 2006 09:17:14 -0700
Message-ID: <20060830091714.6fa70274@localhost.localdomain>
References: <7d01f9f00608300830j74871672o31b9ce126ee8c07d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49613 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751106AbWH3QS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 12:18:27 -0400
To: "Thibaut VARENE" <T-Bone@parisc-linux.org>
In-Reply-To: <7d01f9f00608300830j74871672o31b9ce126ee8c07d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 17:30:46 +0200
"Thibaut VARENE" <T-Bone@parisc-linux.org> wrote:

> Hi,
> 
> The following commit:
> 
> commit 239e44e1f05e2163ee066c07a753f9fb445979b2
> Author: Edgar E. Iglesias <edgar.iglesias@axis.com>
> Date:   Mon Aug 14 23:00:24 2006 -0700
> 
>     [PATCH] skge: remember to run netif_poll_disable()
> 
>     Signed-off-by: Edgar E. Iglesias <edgar.iglesias@axis.com>
>     Cc: Stephen Hemminger <shemminger@osdl.org>
>     Cc: Jeff Garzik <jeff@garzik.org>
>     Signed-off-by: Andrew Morton <akpm@osdl.org>
>     Signed-off-by: Jeff Garzik <jeff@garzik.org>
> 
> diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> index 7de9a07..ad878df 100644
> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c
> @@ -2211,6 +2211,7 @@ static int skge_up(struct net_device *de
>         skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START |
> CSR_IRQ_CL_F);        skge_led(skge, LED_MODE_ON);
> 
> +       netif_poll_enable(dev);
>         return 0;
> 
>   free_rx_ring:
> @@ -2279,6 +2280,7 @@ static int skge_down(struct net_device *
> 
>         skge_led(skge, LED_MODE_OFF);
> 
> +       netif_poll_disable(dev);
>         skge_tx_clean(skge);
>         skge_rx_clean(skge);
> 
> 
> panics my 2.6.18-rc5 kernel on my em64t box apparently on first
> network activity (eg 'ping'). Reverting it gets me back to a
> functional kernel

How are you bringing the network up, are you using autonegotiation?

-- 
Stephen Hemminger <shemminger@osdl.org>
