From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH net-next] tg3: fix return value in tg3_get_stats64
Date: Wed, 13 Aug 2014 13:52:42 -0700
Message-ID: <1407963162.19680.1.camel@prashant>
References: <1407915296-12692-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <mchan@broadcom.com>,
	<netdev@vger.kernel.org>
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:8249 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbaHMVAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 17:00:47 -0400
In-Reply-To: <1407915296-12692-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-13 at 13:04 +0530, Govindarajulu Varadarajan wrote:
> When tp->hw_stats is 0, tg3_get_stats64 should display previously
> recorded stats. So it returns &tp->net_stats_prev. But the caller,
> dev_get_stats, ignores the return value.
> 
> Fix this by assigning tp->net_stats_prev to stats and returning stats.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Acked-by: Prashant Sreedharan <prashant@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index a3dd5dc..4296b3d26 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -14093,8 +14093,9 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
>  
>  	spin_lock_bh(&tp->lock);
>  	if (!tp->hw_stats) {
> +		*stats = tp->net_stats_prev;
>  		spin_unlock_bh(&tp->lock);
> -		return &tp->net_stats_prev;
> +		return stats;
>  	}
>  
>  	tg3_get_nstats(tp, stats);
