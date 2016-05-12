From: Nishanth Menon <nm@ti.com>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Thu, 12 May 2016 08:50:34 -0500
Message-ID: <57348A2A.8070806@ti.com>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kernel@pengutronix.de>, "Andrew F . Davis" <afd@ti.com>,
	Roger Quadros <rogerq@ti.com>, Sekhar Nori <nsekhar@ti.com>,
	Suman Anna <s-anna@ti.com>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:43910 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbcELNup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 09:50:45 -0400
In-Reply-To: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2016 05:00 AM, Uwe Kleine-K=C3=B6nig wrote:
> The framework only asserts (for now) that the reset gpio is not activ=
e.
>=20
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> ---
>  Documentation/devicetree/bindings/net/phy.txt | 3 +++
>  drivers/net/phy/phy_device.c                  | 8 ++++++++
>  2 files changed, 11 insertions(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Document=
ation/devicetree/bindings/net/phy.txt
> index bc1c3c8bf8fa..c00a9a894547 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -35,6 +35,8 @@ Optional Properties:
>  - broken-turn-around: If set, indicates the PHY device does not corr=
ectly
>    release the turn around line low at the end of a MDIO transaction.
> =20
> +- reset-gpios: Reference to a GPIO used to reset the phy.
> +
>  Example:
> =20
>  ethernet-phy@0 {
> @@ -42,4 +44,5 @@ ethernet-phy@0 {
>  	interrupt-parent =3D <40000>;
>  	interrupts =3D <35 1>;
>  	reg =3D <0>;
> +	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
>  };
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index e551f3a89cfd..7d666ab47271 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -34,6 +34,7 @@
>  #include <linux/io.h>
>  #include <linux/uaccess.h>
>  #include <linux/of.h>
> +#include <linux/gpio/consumer.h>
> =20
>  #include <asm/irq.h>
> =20
> @@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
>  	struct device_driver *drv =3D phydev->mdio.dev.driver;
>  	struct phy_driver *phydrv =3D to_phy_driver(drv);
>  	int err =3D 0;
> +	struct gpio_descs *reset_gpios;
> =20
>  	phydev->drv =3D phydrv;
> =20
> +	/* take phy out of reset */
> +	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
> +						    GPIOD_OUT_LOW);
> +	if (IS_ERR(reset_gpios))
> +		return PTR_ERR(reset_gpios);
> +
>  	/* Disable the interrupt if the PHY doesn't support it
>  	 * but the interrupt is still a valid one
>  	 */
>=20

This looks like the right approach to me at least: I see that TI EVMs
will also benefit with this approach.

--=20
Regards,
Nishanth Menon
