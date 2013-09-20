From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 07/51] DMA-API: net: intel/ixgbe: fix 32-bit DMA mask
 handling
Date: Fri, 20 Sep 2013 12:51:07 -0700
Message-ID: <1379706667.1972.13.camel@jtkirshe-mobl>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMlpP-0007fp-IC@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8577962717221832919=="
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-mmc@vger.kernel.org,
 Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
 linux-fbdev@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-ide@vger.kernel.org, Carolyn Wyborny <carolyn.wyborny@intel.com>,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 Don Skidmore <donald.c.skidmore@intel.com>,
 Jesse Brandeburg <jesse.brandeburg@intel.com>, b43-dev@lists.infradead.org,
 linux-media@vger.kernel.org, Alex Duyck <alexander.h.duyck@intel.com>,
 devicetree@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>,
 dri-devel@lists.freedesktop.org, linux-tegra@vger.kernel.org,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <E1VMlpP-0007fp-IC@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org


--===============8577962717221832919==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ffnl3xLzjnyC7fSFea2u"


--=-Ffnl3xLzjnyC7fSFea2u
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-19 at 22:31 +0100, Russell King wrote:
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
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   15 +++++----------
>  1 files changed, 5 insertions(+), 10 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-Ffnl3xLzjnyC7fSFea2u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSPKcrAAoJEOVv75VaS+3O5wkQAJl6vEbpRaqMs6YHrykXxtT3
KlYAmYfZgASG3sUQpLwSAVQ3kmQ3+peW+gXzjftqiiarDD3bOiKK/Ax0Vaa54NwT
i/HwlhahUj7jPN4KISXEsyoGSEvFg9lJ9I4P2Tdobe46WcW2SxX7GLe/O9GNuqkS
t/OyfLmZEhEuSXrEUnzeYPJFZs5r6yB+hYrtYx24fkzqeZ5V1r16TSMQ64uhP6YQ
9WY8VC7oY+CnXFB1fEs3ZtD8v1SmqpYl/Tre5ZEIxBb6tVZnK2gSxWdnQyM1FXHk
R5df8zkrNwDTuqwV4GJ0H1FDgoPBAg02ieCgn5rTErge9eTknJSMxsF5Sybok85Z
nxGjG+B/qyrh4PPKakhpQXIi5i8CMNpTiQvimCNNztXIacrJVzXtaouP9XLkw44W
I/RXTP5LN8v1bPqd0jo2dHQR0mb70XqPivZhtXMbRyjk6UzLWOHqZkjSlSiGzSHn
2XiqFdCLj3qPCRKhQV+TECQBNBI3dTAA1oZmt/5oOYML3QJ4E1Kad5826ScXg/Jx
74WZVoy4wv+g2NyiY+F703VpWHtaf0zKCiDnMDgwNRIginDaXqTp80WoLhWNMDqd
6dOWdcceVlUyg8iEBEJ7+MTgIECCGVQxxB5lJ5Z8bftA11eN8D0xplpf9JfsC1p/
BWN/CuOShCgKe3ju3DNB
=NF+f
-----END PGP SIGNATURE-----

--=-Ffnl3xLzjnyC7fSFea2u--


--===============8577962717221832919==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============8577962717221832919==--
