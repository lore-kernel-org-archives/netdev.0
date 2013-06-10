From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 7/7] NET: intel/ixgbevf/ixgbevf_main.c: fix 32-bit DMA
 mask handling
Date: Mon, 10 Jun 2013 16:28:29 -0700
Message-ID: <1370906909.2133.6.camel@jtkirshe-mobl>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	 <E1UmBJP-0006KR-5h@rmk-PC.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RBUkAwPQsjV4ARrV4m6h"
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
Received: from mga14.intel.com ([143.182.124.37]:21796 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753485Ab3FJX2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 19:28:31 -0400
In-Reply-To: <E1UmBJP-0006KR-5h@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RBUkAwPQsjV4ARrV4m6h
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-06-11 at 00:15 +0100, Russell King wrote:
>=20
> The fallback to 32-bit DMA mask is rather odd:
>         if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
>             !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
>                 pci_using_dac =3D 1;
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
>                 pci_using_dac =3D 0;
>         }
> This means we only set the coherent DMA mask in the fallback path if
> the DMA mask set failed, which is silly.  This fixes it to set the
> coherent DMA mask only if dma_set_mask() succeeded, and to error out
> if either fails.
>=20
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)=20

Thanks Russell, I will add this to my queue.

--=-RBUkAwPQsjV4ARrV4m6h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRtmEdAAoJEOVv75VaS+3OHW8QAIDV2WsKv3nMNyXgnZrImI46
3xuber1jHlobWcWm3Mcuct1pIRtkOBy8lger3czU9/hRKuXi2fCXEQ4ccKiPrWpD
H6Im5YJDwnA7uhxa0vLCYpHL2cetKmBzM7y288QeMg8PE1ACrGVF6Hnxy4vd6qlR
y2AbZrTJWIupNKjWxqNkPYpzqyHJBaqSNg+CIt2wwh8CiCGuAQxgOCHPtxGQhHYa
AjmcNms88e7FcUOmZh4B+4SLuJFz+VV+DWdX61/zR+FW6lJKARN3BXciuAfRHYYE
SfKyl8hWdbHShSzv9Hoiix3wEc6/cv6HRQ99zZlDEpCEADg1OYiXX02eF82gtAec
fZwggY4+kAo98FNPRMV1B+ujI3yqP8BbFIFceRXwrGbO0DvsscPvqqrJVTxHMCq4
ky2XqzG9bHjpGbEHd5GU4dMBdTI/3Cs1RliCrGJnh/ZPFhioTXdE6hX1Lo37FKkW
y8iuF7VQE3HrbKSY5pwGXYTwwv8HrilWw5fH4ZvTQOoZInZ34hYLyDpEtZdLv4aV
sfb+1G0zrwn4VkRurvmOFo+i8pGzFHdOL8SrBdChqZWk2c8dOsjH0ioDIzhHuM8O
0fzmXWh06QvxRS5iv0nPrkjZnsBhuTOfYnz8tDiWgLbaQywLoA4WJh+PF8hATXpI
yXAzAUEblS823vJ7+LJL
=1IkG
-----END PGP SIGNATURE-----

--=-RBUkAwPQsjV4ARrV4m6h--
