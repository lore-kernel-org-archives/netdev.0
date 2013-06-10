From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/7] NET: intel/e1000e/netdev.c: fix 32-bit DMA mask
 handling
Date: Mon, 10 Jun 2013 16:27:05 -0700
Message-ID: <1370906825.2133.1.camel@jtkirshe-mobl>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	 <E1UmBEY-0006Jy-GO@rmk-PC.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-U80G4bhWlud7Rjc4Wkda"
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
Received: from mga14.intel.com ([143.182.124.37]:50898 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546Ab3FJX1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 19:27:15 -0400
In-Reply-To: <E1UmBEY-0006Jy-GO@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-U80G4bhWlud7Rjc4Wkda
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-06-11 at 00:10 +0100, Russell King wrote:
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
>                                 dev_err(&pdev->dev,
>                                         "No usable DMA configuration,
> aborting\n");
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
>  drivers/net/ethernet/intel/e1000e/netdev.c |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)=20

Thanks Russell, I will add this to my queue.

--=-U80G4bhWlud7Rjc4Wkda
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRtmDJAAoJEOVv75VaS+3OWcYP/2thxlvNlwUsvgIqaeNFg2cI
iPMUUFFwKhNPnfWgPYcJtE8IBPPSVrhRkeiju/EhE4DBmLW1H12mQWeEXPB3TZOm
IAeNhKsW6t05iZIYnTgXUDB6FuL8Fw/yjXHIXjhxlsWtvMzZkxttp74S06BaaFor
gmh2GXlNOXo3LR4tTJEMKqFKwxBy2AJwZw4dZDipcNbALc+EDj8jh4BlakHEVhvN
4x2+UvNtbuPMcKkYt0pKgpTuomkEHHVQvBta7YLuIX7VJwg9QdOmAHfyn7dBZClc
ZCplg1Z+7ccQ3hzqkJhI7qCu17nPMTcJ4SBt4Xn2FKQj5/yAGVl0rc2/CUdaKlqy
7G7No2qa19Q7AKBhrZbYbPQfg3Nd7LY7Dc58i/gsaLFHXhH/wCK9GTb9a8qt6VZ+
7VeQagohxDZMPryzfyDy5lTWrh/YBE6UZis+anEC+UfVW6yLFrY+pWi6m5cAC/m6
V7VSvdxbYLdy8q5hfVaXgSe6Iks1V3/sZPTB/Xixgq3YW06pi89fqhNQGS/SQbDN
wClmomit9ExYEClVQkfr2CBJfth/X7qQBHcf2a93/v7yLU89xEuMUiMl1V+tH47a
VrhCNLyKK6L5pw5g1pp4kS7G46S7KTlxNA8VTgFClTkJMcWTSGKCcttPe1uEzcFU
mdgWzBNC2dkHMS2iQfnK
=vNm8
-----END PGP SIGNATURE-----

--=-U80G4bhWlud7Rjc4Wkda--
