From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 2/2] fs_enet: MDIO on GPIO support
Date: Mon, 16 Jun 2008 10:57:02 +0200
Message-ID: <200806161057.03158.laurentp@cse-semaphore.com>
References: <200805261152.37636.laurentp@cse-semaphore.com> <200805261153.46131.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2581888.IHSIfX5t83";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com, vbordug@ru.mvista.com,
	pantelis.antoniou@gmail.com
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:34479 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754914AbYFPI5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 04:57:05 -0400
In-Reply-To: <200805261153.46131.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2581888.IHSIfX5t83
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 26 May 2008 11:53, Laurent Pinchart wrote:
> Port the fs_enet driver to support the MDIO on GPIO driver for PHY access
> in addition to the mii-bitbang driver.

Now that 1/2 has been applied by Jeff, could this one make it to=20
powerpc-next ?

> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |   31 ++++++++++++++++++++-----------
>  1 files changed, 20 insertions(+), 11 deletions(-)
>=20
> diff --git a/drivers/net/fs_enet/fs_enet-main.c=20
b/drivers/net/fs_enet/fs_enet-main.c
> index 67b4b07..b0eb1d2 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -43,6 +43,7 @@
>  #include <asm/uaccess.h>
> =20
>  #ifdef CONFIG_PPC_CPM_NEW_BINDING
> +#include <linux/of_gpio.h>
>  #include <asm/of_platform.h>
>  #endif
> =20
> @@ -1172,8 +1173,7 @@ static int __devinit find_phy(struct device_node *n=
p,
>                                struct fs_platform_info *fpi)
>  {
>  	struct device_node *phynode, *mdionode;
> -	struct resource res;
> -	int ret =3D 0, len;
> +	int ret =3D 0, len, bus_id;
>  	const u32 *data;
> =20
>  	data  =3D of_get_property(np, "fixed-link", NULL);
> @@ -1190,19 +1190,28 @@ static int __devinit find_phy(struct device_node=
=20
*np,
>  	if (!phynode)
>  		return -EINVAL;
> =20
> -	mdionode =3D of_get_parent(phynode);
> -	if (!mdionode)
> +	data =3D of_get_property(phynode, "reg", &len);
> +	if (!data || len !=3D 4) {
> +		ret =3D -EINVAL;
>  		goto out_put_phy;
> +	}
> =20
> -	ret =3D of_address_to_resource(mdionode, 0, &res);
> -	if (ret)
> -		goto out_put_mdio;
> +	mdionode =3D of_get_parent(phynode);
> +	if (!mdionode) {
> +		ret =3D -EINVAL;
> +		goto out_put_phy;
> +	}
> =20
> -	data =3D of_get_property(phynode, "reg", &len);
> -	if (!data || len !=3D 4)
> -		goto out_put_mdio;
> +	bus_id =3D of_get_gpio(mdionode, 0);
> +	if (bus_id < 0) {
> +		struct resource res;
> +		ret =3D of_address_to_resource(mdionode, 0, &res);
> +		if (ret)
> +			goto out_put_mdio;
> +		bus_id =3D res.start;
> +	}
> =20
> -	snprintf(fpi->bus_id, 16, "%x:%02x", res.start, *data);
> +	snprintf(fpi->bus_id, 16, "%x:%02x", bus_id, *data);
> =20
>  out_put_mdio:
>  	of_node_put(mdionode);
> --=20
> 1.5.0
>=20
>=20

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart2581888.IHSIfX5t83
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIVirf8y9gWxC9vpcRApF2AKDCMnoCkuGXu4iicN/vHSZXUAU+ewCeJabu
u7XDDbA+DNgrfzGu7fnhElg=
=TU17
-----END PGP SIGNATURE-----

--nextPart2581888.IHSIfX5t83--
