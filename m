From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Fix compile regression caused by 09f75cd7
Date: Tue, 16 Oct 2007 00:41:08 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0710160040120.21722@gate.crashing.org>
References: <1192197233-24958-1-git-send-email-leoli@freescale.com>
 <1192197233-24958-2-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36262 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758871AbXJPFlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 01:41:15 -0400
In-Reply-To: <1192197233-24958-2-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 12 Oct 2007, Li Yang wrote:

> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
>  drivers/net/gianfar.c |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)

this patch got lost.

- k

>
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 2b758fa..6d1456a 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -1228,8 +1228,6 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
>   * starting over will fix the problem. */
>  static void gfar_timeout(struct net_device *dev)
>  {
> -	struct gfar_private *priv = netdev_priv(dev);
> -
>  	dev->stats.tx_errors++;
>
>  	if (dev->flags & IFF_UP) {
> @@ -1335,8 +1333,9 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
>  	return skb;
>  }
>
> -static inline void count_errors(unsigned short status, struct gfar_private *priv)
> +static inline void count_errors(unsigned short status, struct net_device *dev)
>  {
> +	struct gfar_private *priv = netdev_priv(dev);
>  	struct net_device_stats *stats = &dev->stats;
>  	struct gfar_extra_stats *estats = &priv->extra_stats;
>
> @@ -1530,7 +1529,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
>
>  			dev->stats.rx_bytes += pkt_len;
>  		} else {
> -			count_errors(bdp->status, priv);
> +			count_errors(bdp->status, dev);
>
>  			if (skb)
>  				dev_kfree_skb_any(skb);
> --
> 1.5.3.2.104.g41ef
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
