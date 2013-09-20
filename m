From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 06/51] DMA-API: net: intel/ixgb: fix 32-bit DMA mask
 handling
Date: Fri, 20 Sep 2013 12:50:20 -0700
Message-ID: <1379706620.1972.12.camel@jtkirshe-mobl>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMloR-0007fk-Ei@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4400471880575976367=="
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
In-Reply-To: <E1VMloR-0007fk-Ei@rmk-PC.arm.linux.org.uk>
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


--===============4400471880575976367==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MUY2DG7OmU/pFZL57idu"


--=-MUY2DG7OmU/pFZL57idu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-19 at 22:30 +0100, Russell King wrote:
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
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c |   16 +++++-----------
>  1 files changed, 5 insertions(+), 11 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-MUY2DG7OmU/pFZL57idu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSPKb8AAoJEOVv75VaS+3On7oQAIe+Fa8h3cTiTJ1rDCD6GUbO
BA4m1b6FwfAF6GzbD2yd38wEFihy9v9vzaZ6D2CEYLwDxpEVRJBaETWnAEMxbzKM
P70hpFdA0qvG4XOP1b7YdH4BIFOzbpV+rOsOakp2uFjAV7Zv5FNzUTMhvk3t5IXM
RJ9TS5DHxLGQuFqbVJKMTBFBP86e/19q3Q5cUUx70lJvWWcSuiguxvYPgs7ARqSz
YDcfupFJ6/2wautcZ0GzfCh+spc/kbY+arkwzv7OIRItylBQGW+KRT6xvsaO0A5H
dR9yk+ZzdgpcLrZDwAa/STHW8orP2713/G+4wspv9Q7KsnQi8o4GgkdOQn9FXIG3
9fmsx7nYG5hU3czIlXpc7Kt7aOYUWmIBlurd5jH5aQZqsHL93EfmpfvFhm8jowkr
WvY4XVYBhfw5/NFQ9nBPaDCn5CAZXXveWq/garePbHk1zMl4WRqpELFNp0xjcK7a
tBIY/CC1/+1kGkZO5hcLrAmK5dSmOAT1kRfg+02HWA5yK3vFdjHdpCBwcM5AVA/Z
3M+rxN6rVNGTc5AZahPD/ifwdSrFwGb6T6vlYtIhNB5EcTL6bID0gF8Z+fvtxSD4
HpiUHuMhmCRt6XoiNvSEwpzOxR8h4BPWBrl93owKHXObBrMs5Wrt+RZn2Ds5B9Pz
pZFOorVgrMGTH3HXG2TR
=sgmB
-----END PGP SIGNATURE-----

--=-MUY2DG7OmU/pFZL57idu--


--===============4400471880575976367==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============4400471880575976367==--
