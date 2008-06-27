From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/4] e1000: remove e1000_clean_tx_irq call from e1000_netpoll
Date: Fri, 27 Jun 2008 02:08:53 -0400
Message-ID: <486483F5.9040201@garzik.org>
References: <20080619211912.GF22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50258 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755494AbYF0GI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 02:08:56 -0400
In-Reply-To: <20080619211912.GF22981@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> The call to e1000_clean_tx_irq in e1000_netpoll can race with the call
> to e1000_clean_tx_irq in e1000_clean.  With a small bit of tweaking to
> to netpoll_send_skb to simulate a system that was under extreme stress,
> I was able to reproduce these concurrent calls.  This can result in
> multiple frees to the skbs on the tx ring buffer.
> 
> Dropping this call from e1000_netpoll should be fine since we can rely
> on the calls in e1000_clean to do what is needed since napi will poll
> the hardware just after calling poll_controller.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/e1000/e1000_main.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 0dc1ef0..047028f 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -5277,7 +5277,6 @@ e1000_netpoll(struct net_device *netdev)
>  
>  	disable_irq(adapter->pdev->irq);
>  	e1000_intr(adapter->pdev->irq, netdev);
> -	e1000_clean_tx_irq(adapter, adapter->tx_ring);
>  #ifndef CONFIG_E1000_NAPI

applied (2.6.27)


