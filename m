From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] sfc: Fix efx_rx_buf_offset() for recycled
 pages
Date: Sun, 20 Oct 2013 13:52:28 +0100
Message-ID: <1382273543.2794.100.camel@deadeye.wl.decadent.org.uk>
References: <1379607231.1514.13.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-Szj1dY/dq+7IWhtLLlV6"
Cc: stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1379607231.1514.13.camel@bwh-desktop.uk.level5networks.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Szj1dY/dq+7IWhtLLlV6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-19 at 17:13 +0100, Ben Hutchings wrote:
> [Re-sending with cc to the current stable address.  I still had the old
> address in contacts, though I've definitely sent to the current address
> previously...]
>=20
> This bug fix is only for stable branches older than 3.10.  The bug was
> fixed upstream by commit 2768935a4660 ('sfc: reuse pages to avoid DMA
> mapping/unmapping costs'), but that change is totally unsuitable for
> stable.
>=20
> Commit b590ace09d51 ('sfc: Fix efx_rx_buf_offset() in the presence of
> swiotlb') added an explicit page_offset member to struct
> efx_rx_buffer, which must be set consistently with the u.page and
> dma_addr fields.  However, it failed to add the necessary assignment
> in efx_resurrect_rx_buffer().  It also did not correct the calculation
> of efx_rx_buffer::dma_addr in efx_resurrect_rx_buffer(), which assumes
> that DMA-mapping a page will result in a page-aligned DMA address
> (exactly what swiotlb violates).
>=20
> Add the assignment of efx_rx_buffer::page_offset and change the
> calculation of dma_addr to make use of it.
>=20
> I'm attaching the patches for 3.0.y, 3.2.y and 3.4.y (the last of which
> should also be applicable to the later unofficial stable branches).

Queued up for 3.2.

Ben.

--=20
Ben Hutchings
Tomorrow will be cancelled due to lack of interest.

--=-Szj1dY/dq+7IWhtLLlV6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIVAwUAUmPSB+e/yOyVhhEJAQr+6A//ftX0I6967Ov9AqprNFgSPU1uF+Dkg7SW
261TWZ7K0OfmC2vIC06s6+x99TgzK9J7bC/VdKA4h2M/8PuNGZnRhL1bx7TF2xen
VLLnao+RWZfk5wg1EnYdl1Sjz8Y8iksBeljtCJX1DyId0M0WX3MIpFJ9E7QLn8cx
M2O/pNMrKsfLbF70KbtDdQa3wdIN6Tzv1UCjZGiA7RY+xYg2mLYh1ESKBLrsvoiL
RJCHhHXpX/Lo6gvJNCpYYugtzLrpLQW64BoDx5f8azCRgkk1zlAuC2vSYE9DGOJX
sBL7YoOLHksv8kUsrvC/VN2LdIHnDxISXsKn1gHzj4qnWC9jZQSHx32JoLe4/skv
tzNcf+f/rwoRsMRre7BC/lQjg+qBaAPzP2bQt/A6uOWwy2WekPx00Gl0kJdQupEj
3G1h5mQcbL9Fy9ADwssxT1Vkhd7jwCCVJTe9R+y706lJ3kDKHIWJpuRMjmiQDqUZ
UlI1rbQ7+aiHiVsMKb/8szfubSNrOMIO0C3enVdDhzILppbBtps+BvpUgd2fAe/i
vTXlhouAjpBotMnCS4qpg/ce+4IerhB0k9LNP4D6yyJAl7CZP9h2cCmUMAus/VjE
CVz4YoMCA0G5GCzLhbpiQU5PYHGzFeeaIDRI3rC7mICOFYAE/VGI8GOqNTR/2P0l
iBdVR816BNI=
=XKJN
-----END PGP SIGNATURE-----

--=-Szj1dY/dq+7IWhtLLlV6--
