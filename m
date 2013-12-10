From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] bgmac: drop duplicated PHY defines
Date: Tue, 10 Dec 2013 09:10:36 -0800
Message-ID: <CAGVrzcYCT0QUKuRGktH-4xVrXtort-Uy4phvq8yZg3nU8SPFjw@mail.gmail.com>
References: <1386668966-24562-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:37601 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab3LJRLQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:11:16 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so8035541pbc.21
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 09:11:16 -0800 (PST)
In-Reply-To: <1386668966-24562-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Rafal

2013/12/10 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c |    6 ++----
>  drivers/net/ethernet/broadcom/bgmac.h |   21 ---------------------
>  2 files changed, 2 insertions(+), 25 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index 0452937..ad4b2f1 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -725,11 +725,9 @@ static void bgmac_phy_reset(struct bgmac *bgmac)
>         if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
>                 return;
>
> -       bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL,
> -                       BGMAC_PHY_CTL_RESET);
> +       bgmac_phy_write(bgmac, bgmac->phyaddr, MII_BMCR, BMCR_RESET);
>         udelay(100);
> -       if (bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL) &
> -           BGMAC_PHY_CTL_RESET)
> +       if (bgmac_phy_read(bgmac, bgmac->phyaddr, MII_BMCR) & BMCR_RE=
SET)
>                 bgmac_err(bgmac, "PHY reset failed\n");
>         bgmac_phy_init(bgmac);

phy_init_hw() now issues a PHY reset through BMCR_RESET, you might
want to use it instead of this here:

- the 100 microseconds delay might not be sufficient for all PHYs out t=
here
- any PHY fixup (although there are none for BCM47xx yet) would be
wiped out by this "wild" PHY reset

This is quite new, so I do not expect you knew about this.
--
=46lorian
