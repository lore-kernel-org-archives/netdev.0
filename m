From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] au1000_eth: possible NULL dereference of aup->mii_bus->irq in au1000_probe()
Date: Mon, 31 Aug 2009 14:38:55 +0200
Message-ID: <200908311439.01781.f.fainelli@gmail.com>
References: <4A9B8C6F.3040503@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:35581 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbZHaMjE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 08:39:04 -0400
Received: by ewy2 with SMTP id 2so260403ewy.17
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 05:39:05 -0700 (PDT)
In-Reply-To: <4A9B8C6F.3040503@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Roel,

Le lundi 31 ao=FBt 2009 10:40:15, Roel Kluin a =E9crit :
> aup->mii_bus->irq allocation may fail, prevent a dereference of NULL.

Good catch.

>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Acked-by: Florian Fainelli <florian@openwrt.org>

> ---
> diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> index d3c734f..02e4be0 100644
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c
> @@ -1157,6 +1157,9 @@ static struct net_device * au1000_probe(int por=
t_num)
>  	aup->mii_bus->name =3D "au1000_eth_mii";
>  	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
>  	aup->mii_bus->irq =3D kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL)=
;
> +	if (aup->mii_bus->irq =3D=3D NULL)
> +		goto err_out;
> +
>  	for(i =3D 0; i < PHY_MAX_ADDR; ++i)
>  		aup->mii_bus->irq[i] =3D PHY_POLL;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Cordialement, Florian Fainelli
------------------------------
