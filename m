From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 08/51] DMA-API: net: intel/ixgbevf: fix 32-bit DMA mask
 handling
Date: Fri, 20 Sep 2013 12:51:39 -0700
Message-ID: <1379706699.1972.14.camel@jtkirshe-mobl>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMlqN-0007fw-MQ@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7520913363208302849=="
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
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <E1VMlqN-0007fw-MQ@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org


--===============7520913363208302849==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lefeYEeJBf7y/i8K0Ul/"


--=-lefeYEeJBf7y/i8K0Ul/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-19 at 22:32 +0100, Russell King wrote:
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
>                                 dev_err(&pdev->dev, "No usable DMA "
>                                         "configuration, aborting\n");
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
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   15
> +++++----------
>  1 files changed, 5 insertions(+), 10 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-lefeYEeJBf7y/i8K0Ul/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSPKdLAAoJEOVv75VaS+3Opm4P/Axfj+CMCJQfBxBXYypk3qb+
+nJwp6C07IeuHbmilE4pqiWzl68PUidSbdAgnARntgiUhCRx/PAQbeEWO2FPVxw8
DY9i0wUYpo3ffllzIqOaUc/hlGEQjzbvrP//oKU3r3Zx+eB8IO5VwbqF7aeKp97/
Swlj4HJSHjRblLWIsUDlmvDXZEdZFT9re+NNQSnI3W0n4Fobx2L671hHvm7EQccb
1/hf1lFlvdJWz3CFsmsGjYk1oUhtkn+0wYHb5LRI1cfgsbhUqZCwko8V0V0b3a+D
OXYsDDM0xJDXC7CWxSLf/OgNbim3Imulc5Rmy44xku7mfBNNw/SbIPT5Cd93B5nA
TsDp9iTkr0mjc3d8LHIiE26A99MUHRsP4HPcJBPETUtA4uXP3JQH37hDsbsSmcZj
+fsdrpVbiZF29s5YSy8fWX+3i5YerZCh3v/ItX0chcfAKLuSqWEYV2s/JuQVTgtA
agpTxRpNIgHi58vk8ilVcF1KPMtyKLrvbRD+v6Bni6hpcD7IT5SaXtppLP+FuZ8K
2u160Hns1kFN6ZAIRpbq1nW6ZgYNcdjOF3V3Ea2qliHgDKwhbZgC6zGBOQAFdPXV
sVbVqp6G0ORBU1Fyyjcu0fk/sbQ3aEzVlpzv+xKKb5JyJWV36o/JxjrskJpjF2tf
51e74m3k3ad4cw7ztMYz
=+CYc
-----END PGP SIGNATURE-----

--=-lefeYEeJBf7y/i8K0Ul/--


--===============7520913363208302849==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============7520913363208302849==--
