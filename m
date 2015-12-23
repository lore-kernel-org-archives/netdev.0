From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 06/28] net: dsa: Have the switch driver allocate there
 own private memory
Date: Wed, 23 Dec 2015 12:39:19 -0800
Message-ID: <567B0677.60306@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-7-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34682 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509AbbLWUjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:39:22 -0500
Received: by mail-oi0-f42.google.com with SMTP id o124so129292351oia.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:39:21 -0800 (PST)
In-Reply-To: <1450875402-20740-7-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> Now the switch devices have a dev pointer, make use if it for allocat=
ing
> the drivers private data structures using a devm_kzalloc().
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/bcm_sf2.c   |  7 +++++--
>  drivers/net/dsa/mv88e6123.c |  6 +++---
>  drivers/net/dsa/mv88e6131.c |  6 +++---
>  drivers/net/dsa/mv88e6171.c |  6 +++---
>  drivers/net/dsa/mv88e6352.c |  6 +++---
>  drivers/net/dsa/mv88e6xxx.c | 13 ++++++++++---
>  drivers/net/dsa/mv88e6xxx.h |  5 ++++-
>  include/net/dsa.h           |  8 +++++++-
>  8 files changed, 38 insertions(+), 19 deletions(-)
>=20
> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
> index 6925b3c13895..23326c2a01b8 100644
> --- a/drivers/net/dsa/bcm_sf2.c
> +++ b/drivers/net/dsa/bcm_sf2.c
> @@ -929,7 +929,7 @@ static void bcm_sf2_identify_ports(struct bcm_sf2=
_priv *priv,
>  static int bcm_sf2_sw_setup(struct dsa_switch *ds, struct device *de=
v)
>  {
>  	const char *reg_names[BCM_SF2_REGS_NUM] =3D BCM_SF2_REGS_NAME;
> -	struct bcm_sf2_priv *priv =3D ds_to_priv(ds);
> +	struct bcm_sf2_priv *priv;
>  	struct device_node *dn;
>  	void __iomem **base;
>  	unsigned int port;
> @@ -937,6 +937,10 @@ static int bcm_sf2_sw_setup(struct dsa_switch *d=
s, struct device *dev)
>  	u32 reg, rev;
>  	int ret;
> =20
> +	priv =3D devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
> +	if (!priv)
> +		return -ENOMEM;

This looks fine overall, except that part, there is an earlier priv =3D
ds_to_priv() in the function so we might be missing a ds->priv =3D priv
here once the allocation is successful.

With that fixed: Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
