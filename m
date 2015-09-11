From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH/RFC v2 net-next 1/4] phylib: Add phy_set_max_speed helper
Date: Thu, 10 Sep 2015 21:14:34 -0700
Message-ID: <55F2552A.1010509@gmail.com>
References: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
 <1441936878-18290-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33763 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbIKEOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 00:14:36 -0400
In-Reply-To: <1441936878-18290-2-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/10/15 19:01, Simon Horman a =C3=A9crit :
> Add a helper to allow ethernet drivers to limit the speed of a phy
> (that they are attached to).
>=20
> This mainly involves factoring out the business-end of
> of_set_phy_supported() and exporting a new symbol.
>=20
> This code seems to be open coded in several places, in several differ=
ent
> variants.
>=20
> This code is envisaged this will be used in situations where setting
> the "max-speed" property is not appropriate, e.g. because the maximum
> speed is not a property of the phy hardware.

This looks good to me, one minor comment, see below:

>=20
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>=20
> ---
>=20
> v2
> * First post
> ---
>  drivers/net/phy/phy_device.c | 52 ++++++++++++++++++++++++++++------=
----------
>  include/linux/phy.h          |  1 +
>  2 files changed, 34 insertions(+), 19 deletions(-)
>=20
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index c0f211127274..d9a020095972 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1205,6 +1205,37 @@ static int gen10g_resume(struct phy_device *ph=
ydev)
>  	return 0;
>  }
> =20
> +static void __set_phy_supported(struct phy_device *phydev, u32 max_s=
peed)
> +{
> +	if (!IS_ENABLED(CONFIG_OF_MDIO))
> +		return;

I think that part should be moved to of_set_phy_supported(), since your
are exporting phy_set_max_speed() which should therefore be available
regardless of whether Device Tree is used.

While you are it, it might be nice to either warn or return -ENOTSUPP i=
f
the speed does not match 10, 100 or 1000, but that might be worth a
second patch.

Thanks!
--=20
=46lorian
