From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH] jme: fix panic on load
Date: Mon, 1 Nov 2010 00:39:14 +0800
Message-ID: <20101031163428.M61655@cooldavid.org>
References: <1288539978.2660.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:34657 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab0JaQNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 12:13:36 -0400
In-Reply-To: <1288539978.2660.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 31 Oct 2010 16:46:18 +0100, Eric Dumazet wrote
> Its now illegal to call netif_stop_queue() before register_netdev()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
> ---
>  drivers/net/jme.c |    4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/net/jme.c b/drivers/net/jme.c
> index d85edf3..c57d9a4 100644
> --- a/drivers/net/jme.c
> +++ b/drivers/net/jme.c
> @@ -2955,11 +2955,7 @@ jme_init_one(struct pci_dev *pdev,
>  	 * Tell stack that we are not ready to work until open()
>  	 */
>  	netif_carrier_off(netdev);
> -	netif_stop_queue(netdev);
> 
> -	/*
> -	 * Register netdev
> -	 */
>  	rc = register_netdev(netdev);
>  	if (rc) {
>  		pr_err("Cannot register net device\n");
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Can this patch be modified to move the netif_stop_queue()
after register_netdev() ?
It seems the __QUEUE_STATE_XOFF is not set after the register_netdev.
The tx_queue was kcalloc() ed without touching state flags.

Guo-Fu Tseng

