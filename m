From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [patch 1/6] pasemi_mac: Move RX/TX section enablement to
	dma_lib
Date: Tue, 26 Feb 2008 22:46:06 +1100
Message-ID: <1204026366.7203.9.camel@concordia>
References: <20080221025753.903665000@lixom.net>
	 <20080221025929.082348000@lixom.net>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mwKwnmm86Lx4mQHMYku+"
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, pasemi-linux@ozlabs.org,
	linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50795 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755358AbYBZLqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 06:46:10 -0500
In-Reply-To: <20080221025929.082348000@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mwKwnmm86Lx4mQHMYku+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-02-20 at 20:57 -0600, Olof Johansson wrote:
> plain text document attachment (in-progress)
> Also stop both rx and tx sections before changing the configuration of
> the dma device during init.
>=20
> Signed-off-by: Olof Johansson <olof@lixom.net>
>=20
> Index: k.org/arch/powerpc/platforms/pasemi/dma_lib.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- k.org.orig/arch/powerpc/platforms/pasemi/dma_lib.c
> +++ k.org/arch/powerpc/platforms/pasemi/dma_lib.c
> @@ -478,6 +478,30 @@ int pasemi_dma_init(void)
>  	for (i =3D 0; i < MAX_RXCH; i++)
>  		__set_bit(i, rxch_free);
> =20
> +	i =3D 1000;
> +	pasemi_write_dma_reg(PAS_DMA_COM_RXCMD, 0);
> +	while ((i > 0) && (pasemi_read_dma_reg(PAS_DMA_COM_RXSTA) & 1))
> +		i--;
> +	if (i < 0)
> +		printk(KERN_INFO "Warning: Could not disable RX section\n");
> +
> +	i =3D 1000;
> +	pasemi_write_dma_reg(PAS_DMA_COM_TXCMD, 0);
> +	while ((i > 0) && (pasemi_read_dma_reg(PAS_DMA_COM_TXSTA) & 1))
> +		i--;

This kind of caught my eye, is it still going to work when the next core
is twice as fast?

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-mwKwnmm86Lx4mQHMYku+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHw/v+dSjSd0sB4dIRAhVHAJoCdo3re9BOushlTDbGDjxt7m2EpQCgq1Yz
gmpPrlHuTZ1Dv2O23HwB67U=
=1kwx
-----END PGP SIGNATURE-----

--=-mwKwnmm86Lx4mQHMYku+--

