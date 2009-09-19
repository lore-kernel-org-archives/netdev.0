From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] cpmac: fix compilation errors against undeclared BUS_ID_SIZE
Date: Sat, 19 Sep 2009 12:43:08 +0200
Message-ID: <200909191243.09166.florian@openwrt.org>
References: <200909160944.24265.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:42910 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbZISKnQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2009 06:43:16 -0400
Received: by ewy2 with SMTP id 2so1943327ewy.17
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2009 03:43:19 -0700 (PDT)
In-Reply-To: <200909160944.24265.florian@openwrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Ping ? This fixes a build failure. Thank you very much !

Le mercredi 16 septembre 2009 09:44:22, Florian Fainelli a =C3=A9crit :
> Hi David,
>
> This is relevant for 2.6.32-rc0, thanks !
> --
> From: Florian Fainelli <florian@openwrt.org>
> Subject: [PATCH] cpmac: fix compilation errors against undeclared
> BUS_ID_SIZE
>
> With the removal of BUS_ID_SIZE, cpmac was not fully
> converted to use MII_BUS_ID_SIZE as it ought to. This
> patch fixes the following cpmac build failure:
>  CC      drivers/net/cpmac.o
> drivers/net/cpmac.c: In function 'cpmac_start_xmit':
> drivers/net/cpmac.c:563: warning: comparison of distinct pointer type=
s
> lacks a cast drivers/net/cpmac.c: In function 'cpmac_probe':
> drivers/net/cpmac.c:1112: error: 'BUS_ID_SIZE' undeclared (first use =
in
> this function) drivers/net/cpmac.c:1112: error: (Each undeclared iden=
tifier
> is reported only once drivers/net/cpmac.c:1112: error: for each funct=
ion it
> appears in.)
>
> Reported-by: Ralf Baechle <ralf@linux-mips.org>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
> index 3e3fab8..61f9da2 100644
> --- a/drivers/net/cpmac.c
> +++ b/drivers/net/cpmac.c
> @@ -1109,7 +1109,7 @@ static int external_switch;
>  static int __devinit cpmac_probe(struct platform_device *pdev)
>  {
>  	int rc, phy_id;
> -	char mdio_bus_id[BUS_ID_SIZE];
> +	char mdio_bus_id[MII_BUS_ID_SIZE];
>  	struct resource *mem;
>  	struct cpmac_priv *priv;
>  	struct net_device *dev;
> @@ -1118,7 +1118,7 @@ static int __devinit cpmac_probe(struct
> platform_device *pdev) pdata =3D pdev->dev.platform_data;
>
>  	if (external_switch || dumb_switch) {
> -		strncpy(mdio_bus_id, "0", BUS_ID_SIZE); /* fixed phys bus */
> +		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE); /* fixed phys bus */
>  		phy_id =3D pdev->id;
>  	} else {
>  		for (phy_id =3D 0; phy_id < PHY_MAX_ADDR; phy_id++) {
> @@ -1126,7 +1126,7 @@ static int __devinit cpmac_probe(struct
> platform_device *pdev) continue;
>  			if (!cpmac_mii->phy_map[phy_id])
>  				continue;
> -			strncpy(mdio_bus_id, cpmac_mii->id, BUS_ID_SIZE);
> +			strncpy(mdio_bus_id, cpmac_mii->id, MII_BUS_ID_SIZE);
>  			break;
>  		}
>  	}
> @@ -1167,7 +1167,7 @@ static int __devinit cpmac_probe(struct
> platform_device *pdev) priv->msg_enable =3D netif_msg_init(debug_leve=
l,
> 0xff);
>  	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
>
> -	snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_=
id);
> +	snprintf(priv->phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id,
> phy_id);
>
>  	priv->phy =3D phy_connect(dev, priv->phy_name, &cpmac_adjust_link, =
0,
>  						PHY_INTERFACE_MODE_MII);

--=20
Best regards, Florian Fainelli
Email: florian@openwrt.org
Web: http://openwrt.org
IRC: [florian] on irc.freenode.net
-------------------------------
