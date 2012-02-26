From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH, RFC] skge: Fix race in tx path
Date: Sun, 26 Feb 2012 21:27:10 +0100
Message-ID: <20120226202710.GA23874@electric-eye.fr.zoreil.com>
References: <4142816.cJc9u7kBPI@asus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38676 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab2BZUkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2012 15:40:41 -0500
Content-Disposition: inline
In-Reply-To: <4142816.cJc9u7kBPI@asus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bart Van Assche <bvanassche@acm.org> :
[...]
> diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
> index dea0cb4..2d805b9 100644
> --- a/drivers/net/ethernet/marvell/skge.c
> +++ b/drivers/net/ethernet/marvell/skge.c
> @@ -2793,7 +2793,8 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
>  		tf->control |= BMU_EOF | BMU_IRQ_EOF;
>  	}
>  	/* Make sure all the descriptors written */
> -	wmb();
> +	skge->tx_ring.to_use = e->next;
> +	smp_wmb();
>  	td->control = BMU_OWN | BMU_SW | BMU_STF | control | len;
>  	wmb();

With this change it seems possible for skge_tx_done to unmap a buffer before
it is sent when the requests for skge_xmit_frame are close enough.

-- 
Ueimor
