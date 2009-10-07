From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: Nested function in drivers/of/of_mdio.c
Date: Wed, 7 Oct 2009 08:55:57 -0600
Message-ID: <fa686aa40910070755s519b479xa29aa7b9cccb2f84@mail.gmail.com>
References: <200910071629.15804.jezz@sysmic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?J=E9r=F4me_Pouiller?= <jezz@sysmic.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f204.google.com ([209.85.210.204]:62627 "EHLO
	mail-yx0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973AbZJGO4x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 10:56:53 -0400
Received: by yxe42 with SMTP id 42so178980yxe.22
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 07:56:17 -0700 (PDT)
In-Reply-To: <200910071629.15804.jezz@sysmic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please resend your question with both linuxppc-dev@lists.ozlabs.org
and netdev@vger.kernel.org added to the cc: list.

g.

On Wed, Oct 7, 2009 at 8:29 AM, J=E9r=F4me Pouiller <jezz@sysmic.org> w=
rote:
> Dear,
>
> I have a problem with commit 8bc487d150b939e69830c39322df4ee486efe381
> in file drivers/of/of_mdio.c in function of_phy_find_device.
>
> As you see, this function define match() as a nested function. My
> compiler (powerpc-e500-linux-gnu-gcc-3.4.1) raise an error during lin=
k
> due to this nested definition:
> =A0drivers/built-in.o(.text+0x5e2a4): In function `of_phy_find_device=
': /home/jezz/linux-next/drivers/of/of_mdio.c:107:
> undefined reference to `__trampoline_setup'
>
> I am sure I could solve problem by rebuilding my toolchain.
> Nevertheless, I think nested function definition is not perfectly
> supported by all compilers. Also, I suggest to place function match()
> outside of scope of of_phy_find_device as in following patch.
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index bacaa53..c7b2e26 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -97,6 +97,10 @@ int of_mdiobus_register(struct mii_bus *mdio, stru=
ct device_node *np)
> =A0}
> =A0EXPORT_SYMBOL(of_mdiobus_register);
>
> +static int match(struct device *dev, void *phy_np)
> +{
> + =A0 =A0 =A0 return dev_archdata_get_node(&dev->archdata) =3D=3D phy=
_np;
> +}
> =A0/**
> =A0* of_phy_find_device - Give a PHY node, find the phy_device
> =A0* @phy_np: Pointer to the phy's device tree node
> @@ -106,11 +110,6 @@ EXPORT_SYMBOL(of_mdiobus_register);
> =A0struct phy_device *of_phy_find_device(struct device_node *phy_np)
> =A0{
> =A0 =A0 =A0 =A0struct device *d;
> - =A0 =A0 =A0 int match(struct device *dev, void *phy_np)
> - =A0 =A0 =A0 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev_archdata_get_node(&dev->arch=
data) =3D=3D phy_np;
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0if (!phy_np)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
>
> What do you think about it?
>
> Best regards,
>
> --
> J=E9r=F4me Pouiller (jezz AT sysmic DOT org)
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
