From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] macb: fix mdiobus_scan() error check
Date: Mon, 2 May 2016 09:39:52 +0200
Message-ID: <57270448.2040006@atmel.com>
References: <2317306.aZN9iKAKYz@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:26207 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbcEBHjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 03:39:36 -0400
In-Reply-To: <2317306.aZN9iKAKYz@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/05/2016 00:47, Sergei Shtylyov a =E9crit :
> Now mdiobus_scan() returns ERR_PTR(-ENODEV) instead of NULL if the PH=
Y
> device ID was read as all ones. As this was not  an error before, thi=
s
> value  should be filtered out now in this driver.
>=20
> Fixes: b74766a0a0fe ("phylib: don't return NULL from get_phy_device()=
")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks.

>=20
> ---
> The patch is against DaveM's 'net-next.git' repo.
>=20
>  drivers/net/ethernet/cadence/macb.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> Index: net-next/drivers/net/ethernet/cadence/macb.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next.orig/drivers/net/ethernet/cadence/macb.c
> +++ net-next/drivers/net/ethernet/cadence/macb.c
> @@ -458,7 +458,8 @@ static int macb_mii_init(struct macb *bp
>  				struct phy_device *phydev;
> =20
>  				phydev =3D mdiobus_scan(bp->mii_bus, i);
> -				if (IS_ERR(phydev)) {
> +				if (IS_ERR(phydev) &&
> +				    PTR_ERR(phydev) !=3D -ENODEV) {
>  					err =3D PTR_ERR(phydev);
>  					break;
>  				}
>=20
>=20


--=20
Nicolas Ferre
