From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] net, can, ti_hecc: fix a run time warn_on.
Date: Tue, 20 Oct 2015 21:11:19 +0200
Message-ID: <562691D7.30602@pengutronix.de>
References: <1445351968-18956-1-git-send-email-anton.a.glukhov@gmail.com>
 <562653CD.5040101@pengutronix.de> <56266C0B.1040006@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="c288c2gQfuAXuBbpIA9sxW3ITIwavfeDL"
Cc: hs@denx.de, netdev@vger.kernel.org
To: "Anton.Glukhov" <anton.a.glukhov@gmail.com>,
	linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:44120 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbJTTL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 15:11:28 -0400
In-Reply-To: <56266C0B.1040006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--c288c2gQfuAXuBbpIA9sxW3ITIwavfeDL
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/20/2015 06:30 PM, Anton.Glukhov wrote:
>>> +	clk_disable_unprepare(priv->clk);
>>> +	priv->clk =3D NULL;
>>>  	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>>  	iounmap(priv->base);
>>>  	release_mem_region(res->start, resource_size(res));
>>> @@ -1009,7 +1010,7 @@ static int ti_hecc_suspend(struct platform_devi=
ce *pdev, pm_message_t state)
>>>  	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>>>  	priv->can.state =3D CAN_STATE_SLEEPING;
>>> =20
>>> -	clk_disable(priv->clk);
>>> +	clk_disable_unprepare(priv->clk);
>>> =20
>>>  	return 0;
>>>  }
>>> @@ -1019,7 +1020,7 @@ static int ti_hecc_resume(struct platform_devic=
e *pdev)
>>>  	struct net_device *dev =3D platform_get_drvdata(pdev);
>>>  	struct ti_hecc_priv *priv =3D netdev_priv(dev);
>>> =20
>>> -	clk_enable(priv->clk);
>>> +	clk_prepare_enable(priv->clk);
>>
>> please add error checking.
>>
>=20
> Why it wasn't added with clk_enable? Is it bug? I'm confused here, beca=
use in so many drivers
> there is no checking err after clk_enable or clk_prepare_enable. Maybe =
I missed something...
> Could you clarify this part please?

I wouldn't call it a bug in the original driver, it probably slipped
through the review or I didn't know better.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--c288c2gQfuAXuBbpIA9sxW3ITIwavfeDL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWJpHXAAoJEP5prqPJtc/HZXgH/0nG4Ba0nCHUN6oMG4W4Sb/p
72TS/EjeOiMmZsp33R2tyq0qm5i557cBkIcM3QG9i3MXC9Vf7zneIYfkbYi8dBTo
PB7DghpG7qjNq+g99ouDCpDzxwZrHq5pbYqiQH0CuJXInMdGHTvwfrwPdufttsZh
x1CMCGudEI0BZaGpTcX5WKaMA64XApBt0s3ftNIk+VuD71pvBLVkesO9QecldjyH
M8HJYuXZj2n4XfZECv2cBgUJ9K7pcFB3rlUb4Pwf4Yr6vQ3XOIe4jNNHaoiPA6S2
XZfUUY46gLx+V8sIz4OQaZfDsyOQ+nE6m84ewnKSKMJdQCijR8x/xRuqEgvxpR4=
=7AqL
-----END PGP SIGNATURE-----

--c288c2gQfuAXuBbpIA9sxW3ITIwavfeDL--
