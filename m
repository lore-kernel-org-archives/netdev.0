From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH 2/6] drivers/net/can/softing/softing_main.c: ensure a
 consistent return value in error case
Date: Sun, 15 Jul 2012 22:21:58 +0200
Message-ID: <20120715202158.GA602@vandijck-laurijssen.be>
References: <1342284188-19176-1-git-send-email-Julia.Lawall@lip6.fr>
 <1342284188-19176-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	kernel-janitors@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:43543 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751122Ab2GOUWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 16:22:16 -0400
Content-Disposition: inline
In-Reply-To: <1342284188-19176-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see the problem, and the solution. You may add
Acked-by: Kurt Van Dijck <kurt.van.dijck@eia.be>

On Sat, Jul 14, 2012 at 06:43:04PM +0200, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Typically, the return value desired for the failure of a function with an
> integer return value is a negative integer.  In these cases, the return
> value is sometimes a negative integer and sometimes 0, due to a subsequent
> initialization of the return variable within the loop.
> 
> A simplified version of the semantic match that finds this problem is:
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  drivers/net/can/softing/softing_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
> index a7c77c7..f2a221e 100644
> --- a/drivers/net/can/softing/softing_main.c
> +++ b/drivers/net/can/softing/softing_main.c
> @@ -826,12 +826,12 @@ static __devinit int softing_pdev_probe(struct platform_device *pdev)
>  		goto sysfs_failed;
>  	}
>  
> -	ret = -ENOMEM;
>  	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
>  		card->net[j] = netdev =
>  			softing_netdev_create(card, card->id.chip[j]);
>  		if (!netdev) {
>  			dev_alert(&pdev->dev, "failed to make can[%i]", j);
> +			ret = -ENOMEM;
>  			goto netdev_failed;
>  		}
>  		priv = netdev_priv(card->net[j]);
> 
