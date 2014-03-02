From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] b44: always set duplex mode why phy changes
Date: Sun, 02 Mar 2014 10:53:23 -0800
Message-ID: <3128426.BNOxRVW2LW@lenovo>
References: <1393777774-7400-1-git-send-email-hauke@hauke-m.de> <1393777774-7400-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, zambrano@broadcom.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:34350 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbaCBSx0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 13:53:26 -0500
Received: by mail-oa0-f49.google.com with SMTP id g12so4050288oah.36
        for <netdev@vger.kernel.org>; Sun, 02 Mar 2014 10:53:26 -0800 (PST)
In-Reply-To: <1393777774-7400-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 2 mars 2014, 17:29:34 Hauke Mehrtens a =E9crit :
> Without this patch b44_check_phy() was called when the phy called the
> adjust callback. This method only change the mac duplex mode when the
> carrier was off. When the phy changed the duplex mode after the carri=
er
> was on the mac was not changed. This happened when an external phy wa=
s
> used.
>=20
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/b44.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/b44.c
> b/drivers/net/ethernet/broadcom/b44.c index e8046e1..8a7bf7d 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -2229,7 +2229,12 @@ static void b44_adjust_link(struct net_device =
*dev)
>  	}
>=20
>  	if (status_changed) {
> -		b44_check_phy(bp);
> +		u32 val =3D br32(bp, B44_TX_CTRL);
> +		if (bp->flags & B44_FLAG_FULL_DUPLEX)
> +			val |=3D TX_CTRL_DUPLEX;
> +		else
> +			val &=3D ~TX_CTRL_DUPLEX;
> +		bw32(bp, B44_TX_CTRL, val);
>  		phy_print_status(phydev);
>  	}
>  }

--=20
=46lorian
