From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] gianfar: use netif_tx_queue_stopped
 instead of __netif_subqueue_stopped
Date: Sun, 18 Mar 2012 14:55:41 -0700
Message-ID: <1332107741.9397.27.camel@edumazet-glaptop>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
	 <1332106761-18293-1-git-send-email-paul.gortmaker@windriver.com>
	 <1332106761-18293-5-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:64456 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582Ab2CRVzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 17:55:43 -0400
Received: by dajr28 with SMTP id r28so8930147daj.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 14:55:43 -0700 (PDT)
In-Reply-To: <1332106761-18293-5-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-03-18 at 17:39 -0400, Paul Gortmaker wrote:
> The __netif_subqueue_stopped() just does the following:
> 
>         struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
>         return netif_tx_queue_stopped(txq);
> 
> and since we already have the txq in scope, we can just call that
> directly in this case.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 6e66cc3..d9428f0 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -2565,7 +2565,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>  	}
>  
>  	/* If we freed a buffer, we can restart transmission, if necessary */
> -	if (__netif_subqueue_stopped(dev, tqi) && tx_queue->num_txbdfree)
> +	if (netif_tx_queue_stopped(txq) && tx_queue->num_txbdfree)
>  		netif_wake_subqueue(dev, tqi);
>  
>  	/* Update dirty indicators */

Please change netif_wake_subqueue() as well ;)
