From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/7] NET: intel/igb/igb_main.c: fix 32-bit DMA mask
 handling
Date: Mon, 10 Jun 2013 16:27:28 -0700
Message-ID: <1370906848.2133.2.camel@jtkirshe-mobl>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	 <E1UmBFW-0006K3-L9@rmk-PC.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7oZcGQp9i+2vbFYMQyWn"
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
Received: from mga14.intel.com ([143.182.124.37]:52483 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546Ab3FJX1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 19:27:30 -0400
In-Reply-To: <E1UmBFW-0006K3-L9@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7oZcGQp9i+2vbFYMQyWn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-06-11 at 00:11 +0100, Russell King wrote:
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
>  drivers/net/ethernet/intel/igb/igb_main.c |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)=20

Thanks Russell, I will add this to my queue.

--=-7oZcGQp9i+2vbFYMQyWn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRtmDgAAoJEOVv75VaS+3OX34P/1/95WJUivgF4/yxi20bEVkf
7qw6Qp6A97nIGSabXbKAhtR9nm4wQ8EpPYLjwmPqE4mOE6wXWfjuRaclKRZKpiEt
VlCoGY5BIRDYhaQhj2Rs9sZye/COsyc43penh7nxh7/xwUpVaNmUPXlMpP+G6x1Y
gXz9TSU5KlgA7ReWb7ksbkJj4ENfQjqAfElZxaz+a8IhahQ6mf4HDWca4qZRWbyY
f9Fj8f4nfi+drA1TZmfkT41jcjOCYTpA0k/xsFaNvcjJNhBT7ke8fw/fdtMaWdod
0i+l2YY3IeQmvRkdw7fQkiZBOgNNCjd80hPNzCgnUbNypnF8uwDwOAsRQ1g8GNtr
POuTbKggObQ9NO4g7FYq6SymWtqpxPaKW5Fa2Xwv0JqhVUsS6PQH8WEhV94Uoj4i
S2S3feJ6ary1TSI8pUH8dd+ZBIWHIHbjPkmabhpApr0bFeXuY/pEyTQRfpQNjbPb
f3wnr7o2BiROErGx6Io+JO6SbhYyMWaHegmopJek4G+d8dQRHdh06SK07EEhsY0Q
v2A3cdXcsaCGg9AXG4cYjySLxLEDKnEo60Syk6voLJtvvX+4D8iZ4W3+dAC47ENh
Fb3Egtu4JuJk+oa7E953oWjm69O1kh3FkVOeqEH03IemmyAzT4aCLX5eDCLa32Pj
+mQjVLYLux0UnColbid6
=/9+P
-----END PGP SIGNATURE-----

--=-7oZcGQp9i+2vbFYMQyWn--
