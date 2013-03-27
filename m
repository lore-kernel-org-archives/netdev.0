From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/2] drivers: net: ethernet: cpsw: use
 netif_wake_queue() while restarting tx queue
Date: Wed, 27 Mar 2013 07:55:42 -0700
Message-ID: <1364396142.15753.10.camel@edumazet-glaptop>
References: <1364395320-14973-1-git-send-email-mugunthanvnm@ti.com>
	 <1364395320-14973-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35965 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab3C0Ozp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 10:55:45 -0400
In-Reply-To: <1364395320-14973-2-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 20:11 +0530, Mugunthan V N wrote:
> To restart tx queue use netif_wake_queue() intead of netif_start_queue()
> so that net schedule will restart transmission immediately which will
> increase network performance while doing huge data transfers.
> 
> Reported-by: Dan Franke <dan.franke@schneider-electric.com>
> Suggested-by: Sriramakrishnan A G <srk@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index f4be85b..61ecebf 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -458,7 +458,7 @@ static void cpsw_tx_handler(void *token, int len, int status)
>  	 * queue is stopped then start the queue as we have free desc for tx
>  	 */
>  	if (unlikely(netif_queue_stopped(ndev)))
> -		netif_start_queue(ndev);
> +		netif_wake_queue(ndev);
>  	cpts_tx_timestamp(priv->cpts, skb);
>  	priv->stats.tx_packets++;
>  	priv->stats.tx_bytes += len;


Its a bug fix, suitable for net tree

Acked-by: Eric Dumazet <edumazet@google.com>

BTW, it seems cpsw_ndo_start_xmit() can race with cpsw_tx_handler().
