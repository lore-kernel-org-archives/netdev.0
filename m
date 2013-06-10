From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 6/7] NET: intel/ixgbe/ixgbe_main.c: fix 32-bit DMA mask
 handling
Date: Mon, 10 Jun 2013 16:28:14 -0700
Message-ID: <1370906894.2133.5.camel@jtkirshe-mobl>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	 <E1UmBIR-0006KM-1m@rmk-PC.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IU+7Bkqzl7SKKhkI7/IT"
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
Received: from mga03.intel.com ([143.182.124.21]:23226 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027Ab3FJX2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 19:28:16 -0400
In-Reply-To: <E1UmBIR-0006KM-1m@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IU+7Bkqzl7SKKhkI7/IT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-06-11 at 00:14 +0100, Russell King wrote:
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
>                                 dev_err(&pdev->dev,
>                                         "No usable DMA configuration,
> aborting\n");
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
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)=20

Thanks Russell, I will add this to my queue.

--=-IU+7Bkqzl7SKKhkI7/IT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRtmEOAAoJEOVv75VaS+3OQw8P/jDVwWPWqTk/AlzAK5o5SIg7
4LDi2Y/tPS29szk6rzgwWu58pAILsv4ZEp9N2gS6EMx+/t//zBSjgvgZl2CBBCKK
cpkzOFENjShIqGG899KWbVkZwqGZ3mW5a05BD3UupgeZ2O2S1w3r1/UwUvp1AZbn
4pU8NH/3Hnb4PNR+W+GSBrPyKPF4ZviIQEqvTE1+uiN7fpExnkX7uXC6gHQg5B0e
in1jAYymcO/mr3UTd36L4hbUR10M31LwL9iUhi25ce4LnRBnG9Omw5J32T7mgovz
WW/POzBL24yiZb8tulk+bmSGZ292Z38X8R7sUyavhbn/112Ize5ZLDhWiIQVxbOF
eB7EFXOa6jULRpQ4OL4lQH3WUsNPG+72dFEtjYcT3S/OmhZNDVikK782BEmxrS3G
TwQuWdad6Tu5o/2rhxneHAO6TtI/WVPJ+cMeIH2+01IlrnuBH2h47wHkoehiR/Uo
Dv10skus3De+xl/SLLk47eDgZXsK8flUIDeH5moafLW0FlX+puIgkN7ffbyerY4p
nexwlBzmaU7e8gT3K+IGiIyo8L3TBfxqjVUZvBnvlHSnvw/Wtb9q3sm0YX8WJp67
lpw0c1vx8uRpfhMDF4nf0eUPvrF1lwx/ZdICsVXeMeblbNwK/4NkFb+iqtBpBh1e
S/uxWiZX66J5qZsr2iII
=oycJ
-----END PGP SIGNATURE-----

--=-IU+7Bkqzl7SKKhkI7/IT--
