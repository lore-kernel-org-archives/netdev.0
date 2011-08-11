From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v11 5/6] flexcan: Prefer device tree clock frequency if
	available.
Date: Thu, 11 Aug 2011 18:18:20 +0200
Message-ID: <4E4400CC.3020704@pengutronix.de>
References: <1313078831-2511-1-git-send-email-holt@sgi.com>
	<1313078831-2511-6-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4560017407036391765=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1313078831-2511-6-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============4560017407036391765==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4F69796CAE2007D8F2EAC4EE"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4F69796CAE2007D8F2EAC4EE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/11/2011 06:07 PM, Robin Holt wrote:
> If our CAN device's device tree node has a clock-frequency property,
> then use that value for the can devices clock frequency.  If not, fall
> back to asking the platform/mach code for the clock frequency associate=
d
> with the flexcan device.

nitpicking follows inline:

> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> To: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
> Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> ---
>  .../devicetree/bindings/net/can/fsl-flexcan.txt    |    2 +
>  drivers/net/can/flexcan.c                          |   33 ++++++++++++=
+++-----
>  2 files changed, 27 insertions(+), 8 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt =
b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> index c78dcbb..a4382c7 100644
> --- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> +++ b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> @@ -11,6 +11,7 @@ Required properties:
> =20
>  - reg : Offset and length of the register set for this device
>  - interrupts : Interrupt tuple for this device
> +- clock-frequency : The oscillator frequency driving the flexcan devic=
e
> =20
>  Example:
> =20
> @@ -19,4 +20,5 @@ Example:
>            reg =3D <0x1c000 0x1000>;
>            interrupts =3D <48 0x2>;
>            interrupt-parent =3D <&mpic>;
> +          clock-frequency =3D <0x0bebc1fc>;

Does the device tree support dec coded integers? IMHO a frequency is
best expressed in decimal.


>    };
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index 662f832..d40c38e 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -33,6 +33,7 @@
>  #include <linux/kernel.h>
>  #include <linux/list.h>
>  #include <linux/module.h>
> +#include <linux/of.h>
>  #include <linux/platform_device.h>
> =20
>  #define DRV_NAME			"flexcan"
> @@ -929,12 +930,26 @@ static int __devinit flexcan_probe(struct platfor=
m_device *pdev)
>  	void __iomem *base;
>  	resource_size_t mem_size;
>  	int err, irq;
> +	u32 clock_freq =3D 0;
> =20
> -	clk =3D clk_get(&pdev->dev, NULL);
> -	if (IS_ERR(clk)) {
> -		dev_err(&pdev->dev, "no clock defined\n");
> -		err =3D PTR_ERR(clk);
> -		goto failed_clock;
> +	if (pdev->dev.of_node) {
> +		const u32 *clock_freq_p;
> +
> +		clk =3D NULL;

Hmmm - what about moving the clk =3D NULL into the definition of clk?

> +		clock_freq_p =3D of_get_property(pdev->dev.of_node,
> +						"clock-frequency", NULL);
> +		if (clock_freq_p)
> +			clock_freq =3D *clock_freq_p;
> +	}
> +
> +	if (!clock_freq) {
> +		clk =3D clk_get(&pdev->dev, NULL);
> +		if (IS_ERR(clk)) {
> +			dev_err(&pdev->dev, "no clock defined\n");
> +			err =3D PTR_ERR(clk);
> +			goto failed_clock;
> +		}
> +		clock_freq =3D clk_get_rate(clk);
>  	}
> =20
>  	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> @@ -967,7 +982,7 @@ static int __devinit flexcan_probe(struct platform_=
device *pdev)
>  	dev->flags |=3D IFF_ECHO; /* we support local echo in hardware */
> =20
>  	priv =3D netdev_priv(dev);
> -	priv->can.clock.freq =3D clk_get_rate(clk);
> +	priv->can.clock.freq =3D clock_freq;
>  	priv->can.bittiming_const =3D &flexcan_bittiming_const;
>  	priv->can.do_set_mode =3D flexcan_set_mode;
>  	priv->can.do_get_berr_counter =3D flexcan_get_berr_counter;
> @@ -1002,7 +1017,8 @@ static int __devinit flexcan_probe(struct platfor=
m_device *pdev)
>   failed_map:
>  	release_mem_region(mem->start, mem_size);
>   failed_get:
> -	clk_put(clk);
> +	if (clk)
> +		clk_put(clk);
>   failed_clock:
>  	return err;
>  }
> @@ -1020,7 +1036,8 @@ static int __devexit flexcan_remove(struct platfo=
rm_device *pdev)
>  	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	release_mem_region(mem->start, resource_size(mem));
> =20
> -	clk_put(priv->clk);
> +	if (priv->clk)
> +		clk_put(priv->clk);
> =20
>  	free_candev(dev);
> =20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig4F69796CAE2007D8F2EAC4EE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5EAM8ACgkQjTAFq1RaXHM61ACfVom0M2yBZPaGi4epL1VoeaFT
fnAAniQTRH9EfjtaniR6uuNly7YwGl/8
=yPPQ
-----END PGP SIGNATURE-----

--------------enig4F69796CAE2007D8F2EAC4EE--

--===============4560017407036391765==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4560017407036391765==--
