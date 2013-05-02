From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Thu, 2 May 2013 13:19:10 +1000
Message-ID: <20130502131910.aefc70ed915dc403fa50d808@canb.auug.org.au>
References: <20130404114444.de4e40c24f4e1a0e4c0b7328@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__2_May_2013_13_19_10_+1000_CBqwPkbpgrr770bX"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Gabor Juhos <juhosg@openwrt.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130404114444.de4e40c24f4e1a0e4c0b7328@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__2_May_2013_13_19_10_+1000_CBqwPkbpgrr770bX
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 4 Apr 2013 11:44:44 +1100 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/wireless/rt2x00/rt2x00pci.c between commit 69a2bac8984c
> ("rt2x00: rt2x00pci: fix build error on Ralink RT3x5x SoCs") from the
> wireless tree and commit 1f9061d27d3d ("drivers:net: dma_alloc_coherent:
> use __GFP_ZERO instead of memset(, 0)") from the net-next tree.
>=20
> The former moved the code modified by the latter into a different file,
> so I added the following merge fix patch and can carry the fix as
> necessary (no action is required).
>=20
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 4 Apr 2013 11:42:05 +1100
> Subject: [PATCH] drivers:net: fix up for code movement from rt2x00pci.c
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/wireless/rt2x00/rt2x00mmio.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/wireless/rt2x00/rt2x00mmio.c b/drivers/net/wirel=
ess/rt2x00/rt2x00mmio.c
> index d84a680..9fe9a36 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00mmio.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00mmio.c
> @@ -123,12 +123,10 @@ static int rt2x00pci_alloc_queue_dma(struct rt2x00_=
dev *rt2x00dev,
>  	 */
>  	addr =3D dma_alloc_coherent(rt2x00dev->dev,
>  				  queue->limit * queue->desc_size,
> -				  &dma, GFP_KERNEL);
> +				  &dma, GFP_KERNEL | __GFP_ZERO);
>  	if (!addr)
>  		return -ENOMEM;
> =20
> -	memset(addr, 0, queue->limit * queue->desc_size);
> -
>  	/*
>  	 * Initialize all queue entries to contain valid addresses.
>  	 */

This merge fix patch seems to have got lost somewhere ...
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__2_May_2013_13_19_10_+1000_CBqwPkbpgrr770bX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRgdsuAAoJEECxmPOUX5FE4KYP/jrng8S+hFyiPS/71y59XFb8
b2+lKf6dLc3tZQfaC8kAfFyOTp6P3MyNlMPXhb61bIP/qKtIjkjwqUko9N0LLG0l
HjtWaECjQmtp8h54Bof75gW9XNjZkdH5tinosd05/2n4w3Etp48TeuT8exMpqVrO
RTlP59tpfLOo5sB2UgZS0xXys2EZLE3AQDw3zgBR6QbrV8291jMwD9EHrDJSBos5
2dYwt9pT7eHl9MIc/Wirkb6lhyPQapqhXoCoDpjIFx7yzvFP8aCxH4FiuYh3xUKT
oxceJ3bEhKD1v39CHk3agu/1vi1Pv0FEpUkRSo6cKR2I4y7/ou+eyErv+FChlurT
u/1SgCDs/dJ6ZCBiF+eQri64y7El8ZFxKQDhsJtaFcEG9HI5lfbJzBbc3xmN+zmN
D9lGWG4VvgNSXVoBbBtzH0bMdTV6hQNJaDUZ7Z4GPkGesOVHTDP/HvuSIziesoRO
A/aKb5gNoP7w3ZFdj1jIjLyUgyQsch3WkEN0N/WujiT2ThCaZzu7++hlsUnp6iaO
Uor8D9jU4pFoV3YQCIj8r1NDZ6bGsMKUEwpoqPGy4Xok7Xro5ufcWzZ2ak+IB8BM
1JHA9IR80UX33GQXfkPfpVx4FIMkp6k4H5fKP6u0RsneihBg3g+kLKbQSha0ySvI
m+tAh+CRUUfc3wF+gkgW
=OU0J
-----END PGP SIGNATURE-----

--Signature=_Thu__2_May_2013_13_19_10_+1000_CBqwPkbpgrr770bX--
