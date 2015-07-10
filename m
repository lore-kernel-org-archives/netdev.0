From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Pass mdix ethtool setting through to phy driver
Date: Thu, 09 Jul 2015 19:33:08 -0700
Message-ID: <559F2EE4.9050702@gmail.com>
References: <1436493414-16248-1-git-send-email-david.thomson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Thomson <david.thomson@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36167 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbbGJCdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 22:33:13 -0400
Received: by oibp128 with SMTP id p128so41208050oib.3
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 19:33:12 -0700 (PDT)
In-Reply-To: <1436493414-16248-1-git-send-email-david.thomson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/09/15 18:56, David Thomson a =C3=A9crit :
> Pass the mdix setting from ethtool down to the phy driver, to allow
> driver specific implementations of manually setting the polarity.
>=20
> Signed-off-by: David Thomson <david.thomson@alliedtelesis.co.nz>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Looking forwarding to see an user of this!

> ---
>  drivers/net/phy/phy.c | 2 ++
>  include/linux/phy.h   | 2 ++
>  2 files changed, 4 insertions(+)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index b2197b5..47693a9 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -353,6 +353,8 @@ int phy_ethtool_sset(struct phy_device *phydev, s=
truct ethtool_cmd *cmd)
> =20
>  	phydev->duplex =3D cmd->duplex;
> =20
> +	phydev->mdix =3D cmd->eth_tp_mdix_ctrl;
> +
>  	/* Restart the PHY */
>  	phy_start_aneg(phydev);
> =20
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index a26c3f8..e5fb1d4 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -424,6 +424,8 @@ struct phy_device {
> =20
>  	struct net_device *attached_dev;
> =20
> +	u8 mdix;
> +
>  	void (*adjust_link)(struct net_device *dev);
>  };
>  #define to_phy_device(d) container_of(d, struct phy_device, dev)
>=20


--=20
=46lorian
