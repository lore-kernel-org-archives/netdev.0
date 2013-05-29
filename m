From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: ethernet: xilinx_emaclite: keep protocol selector
 bits by reading ANAR
Date: Wed, 29 May 2013 17:23:56 +0200
Message-ID: <51A61D8C.6090100@monstr.eu>
References: <51A4D6FE.3080308@efe-gmbh.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2HQMHSANLNTPXCPLABBCD"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:58562 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205Ab3E2PYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 11:24:06 -0400
Received: by mail-wi0-f171.google.com with SMTP id hq7so3650273wib.16
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 08:24:03 -0700 (PDT)
In-Reply-To: <51A4D6FE.3080308@efe-gmbh.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2HQMHSANLNTPXCPLABBCD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/28/2013 06:10 PM, Jens Renner (EFE) wrote:
> This patch reads the PHY's MII_ADVERTISE register (ANAR) before modifyi=
ng it.
> Hence, the protocol selector bits (4:0) which indicate IEEE 803.3u supp=
ort are
> prevented from being cleared. While the selector bits are fixed / read-=
only on
> some PHYs, not setting them correctly on others (like TI DP83630) makes=
 the
> PHY fall back to 10/half mode which should be avoided.
>=20
> Signed-off-by: Jens Renner <renner@efe-gmbh.de>
> ---
> drivers/net/ethernet/xilinx/xilinx_emaclite.c               |    7 ++++=
+--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/ne=
t/ethernet/xilinx/xilinx_emaclite.c
> index 919b983..4a67af1 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -922,7 +922,7 @@ void xemaclite_adjust_link(struct net_device *ndev)=

>  static int xemaclite_open(struct net_device *dev)
>  {
>         struct net_local *lp =3D netdev_priv(dev);
> -       int retval;
> +       int retval, adv;
>=20
>         /* Just to be safe, stop the device first */
>         xemaclite_disable_interrupts(lp);
> @@ -946,7 +946,10 @@ static int xemaclite_open(struct net_device *dev)
>                 phy_write(lp->phy_dev, MII_CTRL1000, 0);
>=20
>                 /* Advertise only 10 and 100mbps full/half duplex speed=
s */
> -               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL);
> +               adv =3D phy_read(lp->phy_dev, MII_ADVERTISE);
> +               if (adv < 0)
> +                       return adv;
> +               phy_write(lp->phy_dev, MII_ADVERTISE, adv | ADVERTISE_A=
LL);
>=20
>                 /* Restart auto negotiation */
>                 bmcr =3D phy_read(lp->phy_dev, MII_BMCR);

Acked-by: Michal Simek <monstr@monstr.eu>

Thanks,
Michal


--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2HQMHSANLNTPXCPLABBCD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGmHYwACgkQykllyylKDCFH7gCgmjyzHt9QcEDZgATdKdvz1kFk
GrIAn2D4PnqTOmHzbqfyzboRe17eWlqT
=O5wz
-----END PGP SIGNATURE-----

------enig2HQMHSANLNTPXCPLABBCD--
