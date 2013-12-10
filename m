From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] bgmac: start/stop PHY on netdev open/stop
Date: Tue, 10 Dec 2013 09:07:01 -0800
Message-ID: <CAGVrzcbGte8-30e8QG9UX2aOyfSJFN40b9Un_0Lc00d75_AapA@mail.gmail.com>
References: <1386692379-16648-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:60653 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab3LJRHm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:07:42 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so8016404pbc.25
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 09:07:42 -0800 (PST)
In-Reply-To: <1386692379-16648-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/10 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> I've realized that I need to call ethtool command to get Ethernet
> working after booting. Ex call: ethtool -s eth0 autoneg on
> It was fixing Ethernet even if auto-negotiation was already on.
>
> Adding calls to phy_start and phy_stop look like a real solution.

I kind of missed that too during the review, thanks for fixing this! I
wonder if we could somehow
issue a warning in libphy if we manage to go past ndo_start_xmit() and
we have not yet started the PHY state machine.

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index db71d75..055204e 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1139,6 +1139,8 @@ static int bgmac_open(struct net_device *net_de=
v)
>         }
>         napi_enable(&bgmac->napi);
>
> +       phy_start(bgmac->phy_dev);
> +
>         netif_carrier_on(net_dev);
>
>  err_out:
> @@ -1151,6 +1153,8 @@ static int bgmac_stop(struct net_device *net_de=
v)
>
>         netif_carrier_off(net_dev);
>
> +       phy_stop(bgmac->phy_dev);
> +
>         napi_disable(&bgmac->napi);
>         bgmac_chip_intrs_off(bgmac);
>         free_irq(bgmac->core->irq, net_dev);
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
=46lorian
