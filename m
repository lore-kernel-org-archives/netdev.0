From: Robert Dolca <robert.dolca@intel.com>
Subject: Re: [PATCH v2 2/2] NFC: Add ACPI support for NXP PN544
Date: Thu, 12 Feb 2015 19:48:43 +0200
Message-ID: <20150212174843.GA4007@rdolca-desk.ger.corp.intel.com>
References: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
 <1422270817-10950-3-git-send-email-robert.dolca@intel.com>
 <20150212081459.GA28954@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-nfc@ml01.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Berg Johannes <johannes.berg@intel.com>,
	Clement Perrochaud <clement.perrochaud@nxp.com>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150212081459.GA28954@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe,

On Thu, Feb 12, 2015 at 09:14:59AM +0100, Uwe Kleine-K=F6nig wrote:
> On Mon, Jan 26, 2015 at 01:13:37PM +0200, Robert Dolca wrote:
> > +	/* Get EN GPIO from ACPI */
> > +	gpiod_en =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_EN, 1);
> Actually devm_gpiod_get_index takes 4 arguments. In your case you sho=
uld
> also pass GPIOD_OUT_LOW, then you can skip the gpiod_direction_output
> part below.
>=20
> > +	if (IS_ERR(gpiod_en)) {
> > +		nfc_err(dev,
> > +			"Unable to get EN GPIO\n");
> > +		return -ENODEV;
> > +	}
> > +
> > +	phy->gpio_en  =3D desc_to_gpio(gpiod_en);
> Why don't you save a reference to the gpiod instead? Mixing usage of =
raw
> and gpiod might result in surprising results. For example
>=20
> 	gpiod_direction_output(gpiod_en, 0);
>=20
> might actually have the same result as
>=20
> 	gpio_direction_output(gpio_en, 1);
>=20
> if the matching gpio is marked as active low.
>=20
> > +
> > +	/* Configuration EN GPIO */
> > +	ret =3D gpiod_direction_output(gpiod_en, 0);
> > +	if (ret) {
> > +		nfc_err(dev, "Fail EN pin direction\n");
> > +		return ret;
> > +	}
> > +
> > +	/* Get FW GPIO from ACPI */
> > +	gpiod_fw =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_FW, 2);
> > +	if (IS_ERR(gpiod_fw)) {
> > +		nfc_err(dev,
> > +			"Unable to get FW GPIO\n");
> > +		return -ENODEV;
> > +	}
> > +
> > +	phy->gpio_fw  =3D desc_to_gpio(gpiod_fw);
> > +
> > +	/* Configuration FW GPIO */
> > +	ret =3D gpiod_direction_output(gpiod_fw, 0);
> > +	if (ret) {
> > +		nfc_err(dev, "Fail FW pin direction\n");
> > +		return ret;
> > +	}
> The same comments apply here.
>=20
> > +
> > +	/* Get IRQ GPIO */
> > +	gpiod_irq =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_IRQ, 0);
> > +	if (IS_ERR(gpiod_irq)) {
> > +		nfc_err(dev,
> > +			"Unable to get IRQ GPIO\n");
> > +		return -ENODEV;
> > +	}
> > +
> > +	phy->gpio_irq =3D desc_to_gpio(gpiod_irq);
> > +
> > +	/* Configure IRQ GPIO */
> > +	ret =3D gpiod_direction_input(gpiod_irq);
> > +	if (ret) {
> > +		nfc_err(dev, "Fail IRQ pin direction\n");
> > +		return ret;
> > +	}
> > +
> > +	/* Map the pin to an IRQ */
> > +	ret =3D gpiod_to_irq(gpiod_irq);
> > +	if (ret < 0) {
> > +		nfc_err(dev, "Fail pin IRQ mapping\n");
> > +		return ret;
> > +	}
> and here.

I didn't use gpiod_* functions because the existing enumeration method =
for
platform init and device tree was using gpio_* functions.

Also as far as I know the device tree implementation will not give you =
the
gpiod data structure. It gives you only the gpio index.

Keeping both gpiod and gpio depending on the enumeration method is unsc=
allable
so I didn't choose that.

Regards,
Robert
