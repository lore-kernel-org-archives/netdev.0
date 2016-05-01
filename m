From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] pxa168_eth: fix mdiobus_scan() error check
Date: Sun, 1 May 2016 09:05:42 -0700
Message-ID: <57262956.3060206@gmail.com>
References: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
 <6024241.YxM8l6DPJo@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33429 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbcEAQFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 12:05:44 -0400
Received: by mail-oi0-f45.google.com with SMTP id v145so133930069oie.0
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 09:05:44 -0700 (PDT)
In-Reply-To: <6024241.YxM8l6DPJo@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/04/2016 13:35, Sergei Shtylyov a =C3=A9crit :
> Since mdiobus_scan() returns either an error code or NULL on error, t=
he
> driver should check  for both,  not only for NULL, otherwise a crash =
is
> imminent...
>=20
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
> ---
> The patch is against DaveM's 'net.git' repo.
>=20
>  drivers/net/ethernet/marvell/pxa168_eth.c |    2 ++
>  1 file changed, 2 insertions(+)
>=20
> Index: net/drivers/net/ethernet/marvell/pxa168_eth.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net.orig/drivers/net/ethernet/marvell/pxa168_eth.c
> +++ net/drivers/net/ethernet/marvell/pxa168_eth.c
> @@ -979,6 +979,8 @@ static int pxa168_init_phy(struct net_de
>  		return 0;
> =20
>  	pep->phy =3D mdiobus_scan(pep->smi_bus, pep->phy_addr);
> +	if (IS_ERR(pep->phy))
> +		return PTR_ERR(pep->phy);
>  	if (!pep->phy)
>  		return -ENODEV;

Should not this check be removed too and converted to a
PTR_ERR(pep->phy) !=3D -ENODEV?
--=20
=46lorian
