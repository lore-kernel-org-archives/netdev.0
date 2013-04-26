From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Fri, 26 Apr 2013 17:32:02 +0800
Message-ID: <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51189 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264Ab3DZJcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 05:32:03 -0400
Received: by mail-wg0-f44.google.com with SMTP id a12so2001862wgh.35
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 02:32:02 -0700 (PDT)
In-Reply-To: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/26 Lucas Stach <l.stach@pengutronix.de>:
> This reverts commit 3f104c38259dcb3e5443c246f0805bc04d887cc3.
>
> In preparaton to revert the other NAPI related changes.
>
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

David:

Please hold apply this patch for some days.
Let me found a good way to fix the issue that lucas met.

This patch may cause spin_lock dead lock when using 1588 ptp.

best regards
Frank Li

> ---
>  drivers/net/ethernet/freescale/fec.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 73195f6..afb52eb 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1490,7 +1490,6 @@ fec_enet_close(struct net_device *ndev)
>         struct fec_enet_private *fep = netdev_priv(ndev);
>
>         /* Don't know what to do yet. */
> -       napi_disable(&fep->napi);
>         fep->opened = 0;
>         netif_stop_queue(ndev);
>         fec_stop(ndev);
> --
> 1.8.2.rc2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
