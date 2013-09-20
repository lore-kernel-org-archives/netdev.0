From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 37/51] DMA-API: usb: use new dma_coerce_mask_and_coherent()
Date: Fri, 20 Sep 2013 08:10:02 -0500
Message-ID: <20130920131002.GN26101@radagast>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMmIV-0007jw-Gq@rmk-PC.arm.linux.org.uk>
Reply-To: balbi@ti.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2399579260979124827=="
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
In-Reply-To: <E1VMmIV-0007jw-Gq@rmk-PC.arm.linux.org.uk>
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

--===============2399579260979124827==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qi3SIpffvxS/TM8d"
Content-Disposition: inline

--qi3SIpffvxS/TM8d
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Sep 19, 2013 at 11:02:03PM +0100, Russell King wrote:
> diff --git a/drivers/usb/dwc3/dwc3-exynos.c b/drivers/usb/dwc3/dwc3-exyno=
s.c
> index c10b324..8b20c70 100644
> --- a/drivers/usb/dwc3/dwc3-exynos.c
> +++ b/drivers/usb/dwc3/dwc3-exynos.c
> @@ -119,9 +119,7 @@ static int dwc3_exynos_probe(struct platform_device *=
pdev)
>  	 * Since shared usb code relies on it, set it here for now.
>  	 * Once we move to full device tree support this will vanish off.
>  	 */
> -	if (!dev->dma_mask)
> -		dev->dma_mask =3D &dev->coherent_dma_mask;
> -	ret =3D dma_set_coherent_mask(dev, DMA_BIT_MASK(32));
> +	ret =3D dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(32));
>  	if (ret)
>  		goto err1;
> =20
> diff --git a/drivers/usb/host/ehci-omap.c b/drivers/usb/host/ehci-omap.c
> index d0759c5..6fa82d6 100644
> --- a/drivers/usb/host/ehci-omap.c
> +++ b/drivers/usb/host/ehci-omap.c
> @@ -144,9 +144,7 @@ static int ehci_hcd_omap_probe(struct platform_device=
 *pdev)
>  	 * Since shared usb code relies on it, set it here for now.
>  	 * Once we have dma capability bindings this can go away.
>  	 */
> -	if (!dev->dma_mask)
> -		dev->dma_mask =3D &dev->coherent_dma_mask;
> -	ret =3D dma_set_coherent_mask(dev, DMA_BIT_MASK(32));
> +	ret =3D dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(32));
>  	if (ret)
>  		return ret;

for dwc3 and ehci-omap:

Acked-by: Felipe Balbi <balbi@ti.com>

--=20
balbi

--qi3SIpffvxS/TM8d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSPEkpAAoJEIaOsuA1yqRE5YIP/31lUrjWWK0BZtKztgAZ5fjJ
Be481Py022caHmi1k4ibHD/MCXINrJ4bt1/HqPUtS4dM9nS8xrpjawm0hyz1NpFd
t3GyrpAJNpblpx8XSs4e2s0+06tAYbjPHBDLONoQbjfD9cT65f1Qury4tb3T6wN+
Md3Jbe4JFUNwV2kmR63YUzE7/NZx7y9NZimdcKHOhUNMIfGcTsab0p7wWsbQKtJM
+udKsbptMOCBWlYn7YWxr6vbCR7FWZxPFUq9gBX9tmOahSMNqoCPfl97RvGK8Exw
lp6eXRZwnO8e1KQ3KKYtzeT+bSCakLdXhMc19A9EpxEhAk0Y/X+whVf+WvGyevtC
AlDHUv6RXBabTl1iaNcM7HUWIVAuf1Byae+B89N7HS7KLkxMR3bEVeehIG8+41w5
xFk654AIzRYJyDuuGgD5vlgoYEpV7uPdXRkFjI05K8YME0CCpmI7Zg3y/uhHwbgu
Lo6PQQSeIqAKccQbHhlznagC9JeDSsygfoGXXc+K1jRw+FaJoRa2ClCtFUcI9W13
RcM0Z6AYLflavmpTROakVySBtm8oc3VMD7FZwfqyfmdmb8jcalZItJ4ZbijSwo18
H10HE6b4tqLxYQWnedPdwOuzHUb8unfQNpsuenGRRGJWrFu4Imx239V3+15m5biM
WV1kb+UfNj6WuHNIFGbk
=Y+4c
-----END PGP SIGNATURE-----

--qi3SIpffvxS/TM8d--


--===============2399579260979124827==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============2399579260979124827==--
