From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/2] drivers: net: ethernet: davinci_emac: use
 netif_wake_queue() while restarting tx queue
Date: Wed, 27 Mar 2013 07:57:02 -0700
Message-ID: <1364396222.15753.11.camel@edumazet-glaptop>
References: <1364395320-14973-1-git-send-email-mugunthanvnm@ti.com>
	 <1364395320-14973-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f173.google.com ([209.85.210.173]:41429 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538Ab3C0O5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 10:57:04 -0400
In-Reply-To: <1364395320-14973-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 20:12 +0530, Mugunthan V N wrote:
> To restart tx queue use netif_wake_queue() intead of netif_start_queue()
> so that net schedule will restart transmission immediately which will
> increase network performance while doing huge data transfers.
> 
> Reported-by: Dan Franke <dan.franke@schneider-electric.com>
> Suggested-by: Sriramakrishnan A G <srk@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  drivers/net/ethernet/ti/davinci_emac.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index 8121a3d..6a0b477 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1053,7 +1053,7 @@ static void emac_tx_handler(void *token, int len, int status)
>  	 * queue is stopped then start the queue as we have free desc for tx
>  	 */
>  	if (unlikely(netif_queue_stopped(ndev)))
> -		netif_start_queue(ndev);
> +		netif_wake_queue(ndev);
>  	ndev->stats.tx_packets++;
>  	ndev->stats.tx_bytes += len;
>  	dev_kfree_skb_any(skb);


same remark here, its a bug fix

Acked-by: Eric Dumazet <edumazet@google.com>
