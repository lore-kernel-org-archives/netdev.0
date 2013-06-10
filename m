From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 4/7] NET: intel/igbvf/netdev.c: fix 32-bit DMA mask
 handling
Date: Mon, 10 Jun 2013 16:27:44 -0700
Message-ID: <1370906864.2133.3.camel@jtkirshe-mobl>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	 <E1UmBGU-0006K8-Pf@rmk-PC.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GIOzROx9QeQRdx0g6IMT"
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34052 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369Ab3FJX1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 19:27:46 -0400
In-Reply-To: <E1UmBGU-0006K8-Pf@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GIOzROx9QeQRdx0g6IMT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-06-11 at 00:12 +0100, Russell King wrote:
> The fallback to 32-bit DMA mask is rather odd:
>         err =3D dma_set_mask(&pdev->dev, DMA_BIT_MASK(64));
>         if (!err) {
>                 err =3D dma_set_coherent_mask(&pdev->dev,
> DMA_BIT_MASK(64));
>                 if (!err)
>                         pci_using_dac =3D 1;
>         } else {
>                 err =3D dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
>                 if (err) {
>                         err =3D dma_set_coherent_mask(&pdev->dev,
>                                                     DMA_BIT_MASK(32));
>                         if (err) {
>                                 dev_err(&pdev->dev, "No usable DMA "
>                                         "configuration, aborting\n");
>                                 goto err_dma;
>                         }
>                 }
>         }
> This means we only set the coherent DMA mask in the fallback path if
> the DMA mask set failed, which is silly.  This fixes it to set the
> coherent DMA mask only if dma_set_mask() succeeded, and to error out
> if either fails.
>=20
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)=20

Thanks Russell, I will add this to my queue.

--=-GIOzROx9QeQRdx0g6IMT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRtmDwAAoJEOVv75VaS+3OoC4P/0J/KnVUeEZhp4ai1ISHZPUh
fa6EXDEYVLuyXWwhPZ7hKdLp+1AS/DaC8NGkF81DDMUJNOY19Q7JAYx/m127qKBt
s9UOJDzQssLkge0yhFiSDAurWxXmjBLfO7lShZq6FT7lCNdYgpl6iOE6h7p++0xZ
bFMnBiXTo3lGuvlFLDTbpeP+TxzQgGwWz0KCiM2eu6ko35sESE+9Q7/nQZT4fUI0
TR8xSpIXadj2UrmJuQtbI5AVhrdTrHgLb6NMx7rJD9DxmdHUFsQtLCDAT+2BXeel
fxOuLyUJp88KUL5t/2Dch8wYsrUGrvI8yJwMM7RJ1JZTna9/AWALO7RwnL/yviQN
Rx9H+jhP6mP4qNQSvPSRF5NKWavF8fKqu4Igfpi+suwOVVSdfPRRM07hb8CwIYjy
Ndz4O/xas+239piagr7uDHpoZvyKAeDKPF0ev0ZemU8HcPlJyZL3SmThQLGP7Npq
9RVvO1skpR2CZ+4wgyXe+qarl8Xc7Gsqo3tp5NLfwBTMPhxj6iUBn7zIPPxL/Goj
2djC16DKSLc+7rPsFD1aXJjvQ9zKuSrcxaoj6uEevQ38n0KEYOvDIjYP+4kuNKGF
ZpQogK2luGtAM/m7pXe5COH2tfGOyZPQ2M+F/KqGkyDGdfu8Bv4GtCWQdGkBhw5z
E3xMY+FmDtdR39uNy303
=jGBp
-----END PGP SIGNATURE-----

--=-GIOzROx9QeQRdx0g6IMT--
