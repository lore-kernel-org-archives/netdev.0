From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [Cbe-oss-dev] [PATCH 4/10] spidernet: zero out a pointer.
Date: Thu, 17 May 2007 09:32:56 +1000
Message-ID: <1179358376.4142.4.camel@concordia.ozlabs.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
	 <20070516220928.GD4997@austin.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/OATJ4Hwp9r+YVd+Q1SP"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49183 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756728AbXEPXc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 19:32:57 -0400
In-Reply-To: <20070516220928.GD4997@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/OATJ4Hwp9r+YVd+Q1SP
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-05-16 at 17:09 -0500, Linas Vepstas wrote:
> Invalidate a pointer as its pci_unmap'ed; this is a bit of=20
> paranoia to make sure hardware doesn't continue trying to=20
> DMA to it.
>=20
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
>=20
> ----
>  drivers/net/spider_net.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> Index: linux-2.6.22-rc1/drivers/net/spider_net.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-15 13:31:11.00=
0000000 -0500
> +++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-15 13:31:16.0000000=
00 -0500
> @@ -1081,7 +1082,9 @@ spider_net_decode_one_descr(struct spide
>  	chain->tail =3D descr->next;
> =20
>  	/* unmap descriptor */
> -	pci_unmap_single(card->pdev, hwdescr->buf_addr,
> +	hw_buf_addr =3D hwdescr->buf_addr;
> +	hwdescr->buf_addr =3D 0x0;

If you're going to be paranoid, shouldn't you do something here to make
sure the value's hit the device?

> +	pci_unmap_single(card->pdev, hw_buf_addr,
>  			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
> =20

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-/OATJ4Hwp9r+YVd+Q1SP
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGS5SodSjSd0sB4dIRAld8AKCBuUeL8in8aWGqCY6YqeghsUZh7gCeLNEb
GT3pN2CsEv6J4gzvkh3AW/Y=
=g9F2
-----END PGP SIGNATURE-----

--=-/OATJ4Hwp9r+YVd+Q1SP--

