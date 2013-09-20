From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 36/51] DMA-API: usb: use dma_set_coherent_mask()
Date: Fri, 20 Sep 2013 08:08:53 -0500
Message-ID: <20130920130853.GM26101@radagast>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMmHX-0007jq-Cj@rmk-PC.arm.linux.org.uk>
Reply-To: balbi@ti.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0451828914513341728=="
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 linux-mmc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 Alan Stern <stern@rowland.harvard.edu>, b43-dev@lists.infradead.org,
 linux-media@vger.kernel.org, devicetree@vger.kernel.org,
 Stephen Warren <swarren@wwwdotorg.org>, Kukjin Kim <kgene.kim@samsung.com>,
 dri-devel@lists.freedesktop.org, linux-tegra@vger.kernel.org,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, Felipe Balbi <balbi@ti.com>,
 linux-crypto@vger.ker
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <E1VMmHX-0007jq-Cj@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

--===============0451828914513341728==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yklP1rR72f9kjNtc"
Content-Disposition: inline

--yklP1rR72f9kjNtc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Sep 19, 2013 at 11:01:03PM +0100, Russell King wrote:
> diff --git a/drivers/usb/dwc3/dwc3-exynos.c b/drivers/usb/dwc3/dwc3-exyno=
s.c
> index 2f2e88a..c10b324 100644
> --- a/drivers/usb/dwc3/dwc3-exynos.c
> +++ b/drivers/usb/dwc3/dwc3-exynos.c
> @@ -121,8 +121,9 @@ static int dwc3_exynos_probe(struct platform_device *=
pdev)
>  	 */
>  	if (!dev->dma_mask)
>  		dev->dma_mask =3D &dev->coherent_dma_mask;
> -	if (!dev->coherent_dma_mask)
> -		dev->coherent_dma_mask =3D DMA_BIT_MASK(32);
> +	ret =3D dma_set_coherent_mask(dev, DMA_BIT_MASK(32));
> +	if (ret)
> +		goto err1;
> =20
>  	platform_set_drvdata(pdev, exynos);
> =20
> diff --git a/drivers/usb/gadget/lpc32xx_udc.c b/drivers/usb/gadget/lpc32x=
x_udc.c
> index 67128be..6a2a65a 100644
> --- a/drivers/usb/gadget/lpc32xx_udc.c
> +++ b/drivers/usb/gadget/lpc32xx_udc.c
> @@ -3078,7 +3078,9 @@ static int __init lpc32xx_udc_probe(struct platform=
_device *pdev)
>  		 udc->isp1301_i2c_client->addr);
> =20
>  	pdev->dev.dma_mask =3D &lpc32xx_usbd_dmamask;
> -	pdev->dev.coherent_dma_mask =3D DMA_BIT_MASK(32);
> +	retval =3D dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> +	if (retval)
> +		goto resource_fail;
> =20
>  	udc->board =3D &lpc32xx_usbddata;
> =20

for dwc3 and drivers/usb/gadget:

Acked-by: Felipe Balbi <balbi@ti.com>

pretty cool work :-)

--=20
balbi

--yklP1rR72f9kjNtc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSPEjkAAoJEIaOsuA1yqREi4UP/RtNfhTaLiwG1IPM6JFQIBsp
g0KIkkpfatnb1Y0ZIrpkAflrtCr9tk3BphPeLD7gLiEaPqxVYHvbcwCPoDxAQwZl
jZYYmJ4VbLkyOy/6s3iR/ua0cmcTGKS6I7pgPI6CS277JzVbrQo/psFfwzcSdhzR
Q/vekMxH8U9X+gxh4J/HlqZ+noWRcwAsn0VO01QfXKYRTvdRUq5oGuecodBKULFS
VmEkaqmVvJTf/mgklNRinlOmNowSXpCvq+UJiekgCX6PHGr6P8pCkbA1R8xp309c
kiVGYG2eHXr8v+pu+P6qw7O9fvPvaWFLlTAa9qER+wXGav7x7OnTI7P+jbJW4m33
jJ1omoug/9ICdX8c2yDZJT7En6NCZ3hdPItldM9BXE9KNpT+IBkTliC0wI1OCRqc
NkSNSPkIy929ySMiJJlBmtdT9VA+mEfZwU07wSLysc6e1488GPvyJSyCNY+yezQz
9ZVrQiNjleQFyX6antWscqPWaV+tBoSqzfikHD8z00atcbhozkLl0v9ZTY5du5rK
CD/nCBO4D0QjiF0WBtJrzm3oyXhmcRd7xBMCTfRveuoC7PueEztK3Ep37yJc8Pv+
llxV9lXRXl/XG6ZnhFSIlsLqxRqdd6clqekX0GSRiJb1p86ZubJEZOdvNCRFUoA+
UYeUNzefDjsfW9TOC48T
=UOs/
-----END PGP SIGNATURE-----

--yklP1rR72f9kjNtc--


--===============0451828914513341728==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============0451828914513341728==--
