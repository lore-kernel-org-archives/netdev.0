From: Rob Sims <rob@robsims.com>
Subject: Re: [RFT] sky2 auto negotiation PHY errata
Date: Tue, 20 Feb 2007 11:42:13 -0700
Message-ID: <20070220184212.GC30164@robsims.com>
References: <20070202112846.31acaa03@freekitty>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="O3RTKUHj+75w1tg5"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dilbert.robsims.com ([209.120.158.98]:51706 "EHLO
	mail.robsims.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030429AbXBTTCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 14:02:16 -0500
Content-Disposition: inline
In-Reply-To: <20070202112846.31acaa03@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--O3RTKUHj+75w1tg5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 02, 2007 at 11:28:46AM -0800, Stephen Hemminger wrote:
> This patch does the Marvell errata before auto negotiation
> (from drivers/phy/marvell.c).  The Yukon II chips have an internal
> version of the same PHY, so perhaps this errata is necessary for them
> as well.
>=20
> For test only, but it may fix some of the hangs. It seems to fix
> the PHY lockups I saw yesterday on Mac Mini.
>=20
> ---
>  drivers/net/sky2.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 822dd0b..4f04ffa 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -387,6 +387,14 @@ static void sky2_phy_init(struct sky2_hw
> =20
>  	if (sky2->autoneg =3D=3D AUTONEG_ENABLE) {
>  		if (sky2_is_copper(hw)) {
> +			/* Errata setup */
> +			gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 0x1f);
> +			gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x200c);
> +			gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 5);
> +			gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0);
> +			gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x100);
> +
> +
>  			if (sky2->advertising & ADVERTISED_1000baseT_Full)
>  				ct1000 |=3D PHY_M_1000C_AFD;
>  			if (sky2->advertising & ADVERTISED_1000baseT_Half)

With this and the
-       sky2->flow_mode =3D FC_BOTH;
+       sky2->flow_mode =3D FC_NONE;
patch applied to the vanilla 2.6.20 kernel, behavior changed from whole
system locks up about once per 4 days to module locks up once per 4 days.
Neither case has any log messages.  Current behavior is "fixed" by a
rmmod/modprobe sequence.  Old behavior requires a hard reset.

Never had an issue with the vendor sk98lin driver.
lspci:
02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gi=
gabit Ethernet Controller (rev 15)
03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gi=
gabit Ethernet Controller (rev 15)

Only 1 controller is in use, and is connected to a Gb switch, though I
also saw issues earlier when hooked to a 100Mb switch.  Motherboard is
an ASUS P5AD2-E-Premium.  I have not tried any of the kernel/module
command line parameters suggested in various sky2 threads.

Just FYI.
--=20
Rob

--O3RTKUHj+75w1tg5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFF20EEnvKppSZW8osRAhPwAJ403I9tK+xHtssZzJMns3nZ9PzziQCgjDpS
YSIhsjSWKIickM8fYt8LS6c=
=faUF
-----END PGP SIGNATURE-----

--O3RTKUHj+75w1tg5--
