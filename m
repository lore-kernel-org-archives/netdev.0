From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [RFC] gianfar: Fix stats support
Date: Thu, 10 Dec 2009 18:11:37 +0300
Message-ID: <20091210151137.GB17851@oksana.dev.rtsoft.ru>
References: <1260423764-21210-1-git-send-email-Sandeep.Kumar@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:53964 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751161AbZLJPLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 10:11:31 -0500
Content-Disposition: inline
In-Reply-To: <1260423764-21210-1-git-send-email-Sandeep.Kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2009 at 11:12:44AM +0530, Sandeep Gopalpet wrote:
> This patch updates the per rx/tx queue stats.
> To update the per rx queue stats a new structure has been
> introduced rx_q_stats.
> The per tx queue stats are updated via the netdev_queue
> structure itself.
> 
> Note that we update only the tx_packtes, tx_bytes, rx_packets,
> rx_bytes and rx_dropped stats on a per queue basis.
> 
> Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
> ---
[...]
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 73ccb07..7e6f4e4 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -143,6 +143,7 @@ void gfar_start(struct net_device *dev);
>  static void gfar_clear_exact_match(struct net_device *dev);
>  static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
>  static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
> +static struct net_device_stats *gfar_get_stats(struct net_device *dev);

Just a cosmetic nitpick: please avoid adding new forward
declarations.

In this case I think you could easily move this function before
gfar_netdev_ops.

>  u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb);
>  
>  MODULE_AUTHOR("Freescale Semiconductor, Inc");
> @@ -426,6 +427,7 @@ static const struct net_device_ops gfar_netdev_ops = {
>  	.ndo_tx_timeout = gfar_timeout,
>  	.ndo_do_ioctl = gfar_ioctl,
>  	.ndo_select_queue = gfar_select_queue,
> +	.ndo_get_stats = gfar_get_stats,
[...]
> +static struct net_device_stats *gfar_get_stats(struct net_device *dev)
> +{
> +	struct gfar_private *priv = netdev_priv(dev);

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
