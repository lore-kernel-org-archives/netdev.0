From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 05/51] DMA-API: net: intel/igbvf: fix 32-bit DMA mask
 handling
Date: Fri, 20 Sep 2013 12:49:40 -0700
Message-ID: <1379706580.1972.11.camel@jtkirshe-mobl>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMlnT-0007fa-Al@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3415061052081935880=="
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
In-Reply-To: <E1VMlnT-0007fa-Al@rmk-PC.arm.linux.org.uk>
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


--===============3415061052081935880==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7jFuS+NpTCfv3tvsyHEV"


--=-7jFuS+NpTCfv3tvsyHEV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-19 at 22:29 +0100, Russell King wrote:
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
>                                 dev_err(&pdev->dev, "No usable DMA "
>                                         "configuration, aborting\n");
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
>  drivers/net/ethernet/intel/igbvf/netdev.c |   18 ++++++------------
>  1 files changed, 6 insertions(+), 12 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-7jFuS+NpTCfv3tvsyHEV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSPKbUAAoJEOVv75VaS+3OwPkP/jpOhpzIvEZZqSdBK0aO0RuC
7QLNl2TQ0DzlpxOrnQUr2cSKk0X0H5Ft9e7uWP7J3i4/Z2UfwnmsNgtr9dg1JV8X
7MNSTMz6MMjXBeb4JQzHU3HtP+zSFQhBukOpxQpylaqt6IiCWMokebQr4offqJxM
pBMehfZx74aFomOHLBZna2O3G0bn4C6T60Z6VAnTNefMbFly6SRFTMmM4Xcvaj7H
DHk1NgSa3NHF1pSoP6VRsAR+rrVGNLxFzNwL2CbX06c58DiMclKAmRYFpoGQH33k
DfaRpp5e9YZpb/92m5YSe6ragg/4CPNuG5Jcnq3aEC8o3H3l46Qad80R+9MXCToX
+1yXj6utyAYK/xDGZShhF5pBfKe1al2URed6+TsmTY2BuYy2CeVYB5d5sTLQOI5T
5t1K8prPMEPRLZY/KGYUS/MS9utzmznFc1QkSaRScDO02VM1fAKwTxhVPUyEJS05
58mHkIQjNAv13cma3zfj+mjjr4IVeLp7KxsD+dqRy6fe/GS1WgcUJ3EmOwWe9Kqg
dArIqm3W5vWzAJTjuJCyUjXtnXOHEtn5WjfhKppw6Qxa3fj22xgLNcwgUg6kBNQf
dYIN3hbsjuHh2ZN39EvoTWfPby/+FDClkgt3vFkwdLZFdESnuyFWtVuDCXzTGvMg
LNhtVLCSE6b3F1qwUue0
=9kBn
-----END PGP SIGNATURE-----

--=-7jFuS+NpTCfv3tvsyHEV--


--===============3415061052081935880==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============3415061052081935880==--
