From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7 3/3] can: Allwinner A10/A20 CAN Controller support -
 Kernel module
Date: Tue, 15 Sep 2015 16:46:33 +0200
Message-ID: <55F82F49.8020901@pengutronix.de>
References: <1442272632-20251-1-git-send-email-info@gerhard-bertelsmann.de>
 <1442272632-20251-4-git-send-email-info@gerhard-bertelsmann.de>
 <20150915142810.GM4684@lukather>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="6i72tfPk8AUCbcn46mLRah1aTajN3R01M"
Cc: wg@grandegger.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>,
	Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43621 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbbIOOqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 10:46:45 -0400
In-Reply-To: <20150915142810.GM4684@lukather>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6i72tfPk8AUCbcn46mLRah1aTajN3R01M
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 09/15/2015 04:28 PM, Maxime Ripard wrote:
>> +static int sunxican_get_berr_counter(const struct net_device *dev,
>> +				     struct can_berr_counter *bec)
>> +{
>> +	struct sunxican_priv *priv =3D netdev_priv(dev);
>> +	u32 errors;
>> +	int err;
>> +
>> +	err =3D clk_prepare_enable(priv->clk);
>> +	if (err) {
>> +		netdev_err(dev, "could not enable clock\n");
>> +		return err;
>> +	}
>=20
> Can this function be called if the device is closed? If not, then this
> clock calls are useless.

Yes, that's why there are there.

>=20
>> +	errors =3D readl(priv->base + SUNXI_REG_ERRC_ADDR);
>> +
>> +	bec->txerr =3D errors & 0xFF;
>> +	bec->rxerr =3D (errors >> 16) & 0xFF;
>> +
>> +	clk_disable_unprepare(priv->clk);
>> +
>> +	return 0;
>> +}

[...]

>> +static int sunxican_open(struct net_device *dev)
>> +{
>> +	struct sunxican_priv *priv =3D netdev_priv(dev);
>> +	int err;
>> +
>> +	/* common open */
>> +	err =3D open_candev(dev);
>> +	if (err)
>> +		return err;
>> +
>> +	/* register interrupt handler */
>> +	err =3D request_irq(dev->irq, sunxi_can_interrupt, IRQF_SHARED,
>=20
> We don't have any shared interrupt as far as I know, do you really
> need this flag?

Not needed, but the IRQ handler properly returns HANDLED or NONE. So
it's better to remove this flag then?

>=20
>> +			  dev->name, dev);
>> +	if (err) {
>> +		netdev_err(dev, "request_irq err: %d\n", err);
>> +		goto exit_irq;
>> +	}
>> +
>> +	/* turn on clocking for CAN peripheral block */
>> +	err =3D clk_prepare_enable(priv->clk);
>> +	if (err) {
>> +		netdev_err(dev, "could not enable CAN peripheral clock\n");
>> +		goto exit_clock;
>> +	}
>> +
>> +	err =3D sunxi_can_start(dev);
>> +	if (err) {
>> +		netdev_err(dev, "could not start CAN peripheral\n");
>> +		goto exit_can_start;
>> +	}
>> +
>> +	can_led_event(dev, CAN_LED_EVENT_OPEN);
>> +	netif_start_queue(dev);
>> +
>> +	return 0;
>> +
>> +exit_can_start:
>> +	clk_disable_unprepare(priv->clk);
>> +exit_clock:
>> +	free_irq(dev->irq, dev);
>> +exit_irq:
>> +	close_candev(dev);
>> +	return err;
>> +}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--6i72tfPk8AUCbcn46mLRah1aTajN3R01M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV+C9JAAoJEP5prqPJtc/HY+QH/Rgl5AIBi03s6o4yhr/TikqL
DrykxhSC3yRREJRxyRZz0TqFhzgIKecEyMHDkEc8qtXh6HYV8Zq6g3tVakp5N9Ig
oskkAKJXxW3bYd2u9POnpl6FUS+B6fEcz8mkLkq0GaLFmdAVifLEkw82UrK9aNvY
UeS71cTYo9DBE5nUxyqCyF+a39KRIN02MXLjC++B72E6vuTUPp5zGpiSUzSc+JSz
/u6+aEOuZjFsinaeG0TWx7+LqKUNGA4/1VTFK3aVmcVMq6EsZ5aROpNUZK7gtVry
jl6zfCEk1l7W8PU0+zYE0qhIdqe34uKnJghAKzaFIb5xmjoJs7mSh9Dq7FJy17s=
=PKKI
-----END PGP SIGNATURE-----

--6i72tfPk8AUCbcn46mLRah1aTajN3R01M--
