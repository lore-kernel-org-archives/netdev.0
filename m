From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] cpmac: do not leak struct net_device on phy_connect errors
Date: Sun, 27 Jun 2010 19:05:24 +0200
Message-ID: <201006271905.26506.florian@openwrt.org>
References: <201006211007.49039.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56253 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755411Ab0F0RFR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 13:05:17 -0400
Received: by wyb38 with SMTP id 38so1249064wyb.19
        for <netdev@vger.kernel.org>; Sun, 27 Jun 2010 10:05:15 -0700 (PDT)
In-Reply-To: <201006211007.49039.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

=46orgot to mention that this is relevant for -stable and current net-n=
ext-2.6. Thanks!

Le Monday 21 June 2010 10:07:48,  Fainelli a =C3=A9crit :
> If the call to phy_connect fails, we will return directly instead of
> freeing the previously allocated struct net_device.
>=20
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> CC: stable@kernel.org
> ---
> diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
> index 3c58db5..23786ee 100644
> --- a/drivers/net/cpmac.c
> +++ b/drivers/net/cpmac.c
> @@ -1181,7 +1181,8 @@ static int __devinit cpmac_probe(struct
> platform_device *pdev) if (netif_msg_drv(priv))
>  			printk(KERN_ERR "%s: Could not attach to PHY\n",
>  			       dev->name);
> -		return PTR_ERR(priv->phy);
> +		rc =3D PTR_ERR(priv->phy);
> +		goto fail;
>  	}
>=20
>  	if ((rc =3D register_netdev(dev))) {

