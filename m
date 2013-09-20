From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 03/51] DMA-API: net: intel/e1000e: fix 32-bit DMA mask
 handling
Date: Fri, 20 Sep 2013 12:48:19 -0700
Message-ID: <1379706499.1972.9.camel@jtkirshe-mobl>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMllX-0007fP-33@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1359985586041472676=="
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
In-Reply-To: <E1VMllX-0007fP-33@rmk-PC.arm.linux.org.uk>
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


--===============1359985586041472676==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3xsX+KprzK1PFrdJx4iH"


--=-3xsX+KprzK1PFrdJx4iH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-19 at 22:27 +0100, Russell King wrote:
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
>  drivers/net/ethernet/intel/e1000e/netdev.c |   18 ++++++------------
>  1 files changed, 6 insertions(+), 12 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-3xsX+KprzK1PFrdJx4iH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSPKaDAAoJEOVv75VaS+3OjN4QAJS1KrQfi4MJeW8+QDc3iWrU
hiwb7Ow5UdcyBYyX1IiOYG7tt0zo4P4VXekcKwnq0Oujg1VBXmnI/lZZLOhLHncB
EuOzeIAS10mlRaJqou7C5sgJDeVMbxDjOOA/F/1aep592FDyhGLRyCWsT1q0CJh8
7PagLEwYDgyv2PwBssTmUTiouj0SRdBcRcmyNvTIa8Vxk35ld1/wxwYXse6EwenX
JjPiZHvbusSzkvZDxZEAhsVAmaDgztFfNUwnr02xIDaw9uaPgx0PnjgBuHKpVIpx
arrBYbektin9ofhkQmqQyvM4unyxCsoY0tE6ZenjageRRfNXC4pfNKstILNhBAt9
Qb0kcTyjlRUwYhn13dgU4oxZShuwbbtGACoRK89d0ldjO8ddVXa2rYrQUl9AnCCU
qMwQoaz0vbEo2g1QrMnzJMIfqWZSeJv7dwYvAj31GQaggBbq8XBP1ATWN3gIaE7G
sCY650ASK0WJTBOyTA1Oo3aUj4hr0KPBL3paenSyCLN4BDL5FZpMEs5fVzuCsjyz
AryEjnJQ/8ja1ynjOd3KA8kle2+JG8PCwQpOSv2kmaW2N55PmjWpxVU+LGew2KPY
Z7UD2yPyjFjKyyAH7DbaTQKdz2CzVeXTBXvecOvML6u0DKgN0rn+DqKmy2cHzz/S
97+emkT0DMotA8fGsNAt
=7gjN
-----END PGP SIGNATURE-----

--=-3xsX+KprzK1PFrdJx4iH--


--===============1359985586041472676==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============1359985586041472676==--
