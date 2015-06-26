From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net PATCH 1/1] net: phy: fix phy link up when limiting speed
 via device tree
Date: Thu, 25 Jun 2015 20:03:49 -0700
Message-ID: <558CC115.7000301@gmail.com>
References: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35902 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbbFZDDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 23:03:51 -0400
Received: by obctg8 with SMTP id tg8so59165476obc.3
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 20:03:51 -0700 (PDT)
In-Reply-To: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/25/15 09:51, Mugunthan V N a =C3=A9crit :
> When limiting phy link speed using "max-speed" to 100mbps or less on =
a
> giga bit phy, phy never completes auto negotiation and phy state
> machine is held in PHY_AN. Fixing this issue by comparing the giga
> bit advertise though phydev->supported doesn't have it but phy has
> BMSR_ESTATEN set. So that auto negotiation is restarted as old and
> new advertise are different and link comes up fine.
>=20
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/phy_device.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index bdfe51f..d551df6 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -796,10 +796,11 @@ static int genphy_config_advert(struct phy_devi=
ce *phydev)
>  	if (phydev->supported & (SUPPORTED_1000baseT_Half |
>  				 SUPPORTED_1000baseT_Full)) {
>  		adv |=3D ethtool_adv_to_mii_ctrl1000_t(advertise);
> -		if (adv !=3D oldadv)
> -			changed =3D 1;
>  	}
> =20
> +	if (adv !=3D oldadv)
> +		changed =3D 1;
> +
>  	err =3D phy_write(phydev, MII_CTRL1000, adv);
>  	if (err < 0)
>  		return err;
>=20


--=20
=46lorian
