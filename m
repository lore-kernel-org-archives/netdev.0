From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] Fix phy_init for Marvell network eth driver
Date: Thu, 10 Jan 2013 11:38:07 +0100
Message-ID: <50EE9A0F.8050008@openwrt.org>
References: <1357812298-26399-1-git-send-email-konszert@marvell.com> <1357812298-26399-2-git-send-email-konszert@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, benavi@marvell.com, alior@marvell.com,
	linux-arm-kernel@lists.infradead.org, andrew@lunn.ch
To: Kosta Zertsekel <konszert@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:58186 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984Ab3AJKkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 05:40:43 -0500
Received: by mail-la0-f48.google.com with SMTP id ej20so381401lab.21
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 02:40:42 -0800 (PST)
In-Reply-To: <1357812298-26399-2-git-send-email-konszert@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/10/13 11:04, Kosta Zertsekel a =C3=A9crit :
> At least it fixes DNS323_REV_C1 board case (mach-orion5x/dsn323-setup=
=2Ec file).

This looks right, but a bit more detail would be welcome, such as:

"The D-Link DNS323_REV_C1 board has a specific PHY device fixup using=20
the flag MARVELL_PHY_M1118_DNS323_LEDS which is set by the architecture=
=20
code in arch/arm/mach-orion5x/dns323-setup.c. This flag is unfortunatel=
y=20
lost during the call to phy_attach() in mv643xx_eth and therefore, the=20
underlying Marvell PHY driver cannot make use of this flag to fixup the=
=20
PHY device LEDs. This patch ensures the phy->dev_flags value is passed=20
to the phy_attach() function such that the PHY device driver can=20
actually use it."

>
> Change-Id: I37d64795f79c358f66a211a150cec2263e40e295
> ---
>   drivers/net/ethernet/marvell/mv643xx_eth.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net=
/ethernet/marvell/mv643xx_eth.c
> index 84c1326..7b8c1ac 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -2789,7 +2789,7 @@ static void phy_init(struct mv643xx_eth_private=
 *mp, int speed, int duplex)
>
>   	phy_reset(mp);
>
> -	phy_attach(mp->dev, dev_name(&phy->dev), 0, PHY_INTERFACE_MODE_GMII=
);
> +	phy_attach(mp->dev, dev_name(&phy->dev), phy->dev_flags, PHY_INTERF=
ACE_MODE_GMII);
>
>   	if (speed =3D=3D 0) {
>   		phy->autoneg =3D AUTONEG_ENABLE;
>
