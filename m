From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 04/51] DMA-API: net: intel/igb: fix 32-bit DMA mask
 handling
Date: Fri, 20 Sep 2013 12:49:04 -0700
Message-ID: <1379706544.1972.10.camel@jtkirshe-mobl>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMlmV-0007fU-75@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3083578769676017423=="
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
In-Reply-To: <E1VMlmV-0007fU-75@rmk-PC.arm.linux.org.uk>
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


--===============3083578769676017423==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Rnl4LjLMi+p2ia0gVncK"


--=-Rnl4LjLMi+p2ia0gVncK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-19 at 22:28 +0100, Russell King wrote:
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
>  drivers/net/ethernet/intel/igb/igb_main.c |   18 ++++++------------
>  1 files changed, 6 insertions(+), 12 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-Rnl4LjLMi+p2ia0gVncK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSPKawAAoJEOVv75VaS+3OXf0QAJHAY4P/bVO2lTdf8B6FIcu9
4jWg0P/TphXZJ34YiM/lihN3ROBL0xh97DFVU7naSgH6AaCxXaQw7bxridfl05DS
itZ6iJjdlcQOYZQWxdDPzNCgBoLQOMNjC82REH26QQY64qfvdOH+F1HsUpqLsuI5
1rAAq3NGS++Y7ieyyWhz4u4BT5oR32QT3xrrC7Uzky7pWzbV7f2RhZETJ97YNa1k
L1QAUApwpCRSToy/rzROs+g8tGcntXwktWt9t/y9U61a0XTMR9MYm9dUKSaxlTSp
KmSjXbsp+fxmhbPYaCeYabk37A4PuULX+eAxrGiPgzuXDbnEr+Lx4BMCVNY9BNSV
JAgEd90lGzfK9d5fYjpAggW8BZXv/QcrGiDxwvDcGg7AP+WBYmdGpcjJR08Hm0Ob
zx2k9lZViO7pJNwwojz4Za1ojPyS4pmAVRjf9HuzSVN72ItM2Qnd7e5yHd2IHDhs
itYHTSZZkJn/97BSjpExYdlYyWBEYl4Eh7ZfVkH/Q7K8JXak9Rr2v1/p7Zw/ehsx
VpKO9E1GVn+nLXU56LRc35Ji+hnWSvxsiMfLSEwn4IigL+I6CjlV1JhGsqThqe2Y
gGeQz/trK0FQXlPjnMMuumOyXKGKMdESnbBjbytC8FTZhMxLYuBBpspLv79dvDJZ
yt2KMg8iyQF4nmKpfHje
=x2Sq
-----END PGP SIGNATURE-----

--=-Rnl4LjLMi+p2ia0gVncK--


--===============3083578769676017423==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============3083578769676017423==--
