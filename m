From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 5/7] NET: intel/ixgb/ixgb_main.c: fix 32-bit DMA mask
 handling
Date: Mon, 10 Jun 2013 16:27:57 -0700
Message-ID: <1370906877.2133.4.camel@jtkirshe-mobl>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	 <E1UmBHS-0006KE-Tm@rmk-PC.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-srPlgPMfM3G5nzFpfj7F"
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
Received: from mga03.intel.com ([143.182.124.21]:30671 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386Ab3FJX2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 19:28:03 -0400
In-Reply-To: <E1UmBHS-0006KE-Tm@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-srPlgPMfM3G5nzFpfj7F
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-06-11 at 00:13 +0100, Russell King wrote:
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
>                                 pr_err("No usable DMA configuration,
> aborting\n");
>                                 goto err_dma_mask;
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
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)=20

Thanks Russell, I will add this to my queue.

--=-srPlgPMfM3G5nzFpfj7F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRtmD9AAoJEOVv75VaS+3OXxoP/ilsYqM3Aduer73IVsktsw/5
7Bz9CLVaUQiNNz05Gv7db/78MSpZhHE/fjTF2/8zCBSMtSHkVVCyBeS1T2k/7/va
cUA+PE0nV4WFnqVMdHFrS49dJOEWwDQGM6Xm94OLR1rFX/Hy7QI8VcCcKgjOB/y1
7DfxB92iWtoJUiR5prRN9f3m2ATAck26YTPLNlR8+E6QnWpDXgUkgO5ks/gMCHzn
O4MI5p6B97qFg3bewvL3utTbB9FZKisXFq7hCVxvaMTDr5LfT0KNyu9YQ2UbQzEB
zi0X86BykFm4Rungs0RvMwvQLOZrbteUR+KdJT7m17qj2cqHn2kf9mr4HVRxZazT
VvQe+2nkZ0Xb72vMW5rTkyT9x9evOky6etWgGQZgm4hKDnmAkvD9+1zKoVllZMC9
QSfUJRxzCNFExBnPP4EVUu4TRq4B1ThSebRaxu5ZViYDFDasMy+Viz+qMJnxMRCa
mgdj+BZr58u8/1a4tfVxj1V9kxmwYqRK0+lJqcuISizJBz1pVdqgG7xicNc6SXkS
7FHMsPxbhqHUbXGamfdltrEAGgblxXDopPygUDI+q6BctCG/+9QFaZjTN/NMg1Ob
0OZe08DdB6NBS7iVqd65lu2QYpEDt6Rz1QjKS2ZJwIraH3fYc/uF7U1trjOuVmV/
cTc0qVyQcSi9D+VjybGY
=KUFs
-----END PGP SIGNATURE-----

--=-srPlgPMfM3G5nzFpfj7F--
