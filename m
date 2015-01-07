From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: Convert to runtime_pm
Date: Wed, 07 Jan 2015 17:30:11 +0100
Message-ID: <54AD5F13.1020107@pengutronix.de>
References: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl> <54AD267C.4060004@pengutronix.de> <a868331b44ce4b2a80b572399530f1f9@BN1BFFO11FD043.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="OWo51QjMmBw5UudRFBwODqMbhe8teBlxh"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <a868331b44ce4b2a80b572399530f1f9@BN1BFFO11FD043.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OWo51QjMmBw5UudRFBwODqMbhe8teBlxh
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/07/2015 04:58 PM, S=C3=B6ren Brinkmann wrote:
>> I think you have to convert the _remove() function, too. Have a look a=
t
>> the gpio-zynq.c driver:
>>
>>> static int zynq_gpio_remove(struct platform_device *pdev)
>>> {
>>> 	struct zynq_gpio *gpio =3D platform_get_drvdata(pdev);
>>>
>>> 	pm_runtime_get_sync(&pdev->dev);
>>
>> However I don't understand why the get_sync() is here. Maybe S=C3=B6re=
n can help?
>=20
> IIRC, the concern was that the remove function may be called while the =
device is
> runtime suspended. Hence the remove function needs to resume the device=
 since the
> remove function may access the HW.

What about the corresponding runtime_put()? Would some counter be
unbalanced upon device removal?

Without having tested it, unloading and loading, i.e. reloading a CAN
driver is easier than reloading the gpio driver on an average embedded
system. Kedareswara please test your driver with something like:
modprobe; ifconfig up; cansend; ifconfig down; rmmod in a loop.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--OWo51QjMmBw5UudRFBwODqMbhe8teBlxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUrV8TAAoJECte4hHFiupU39sP/j+wOgZt9YoAOJMnKfVoXBhe
8hgX2SAJuK1nrUzhDa1ZjH/R+LuSwh7j9eggz/IQVhCHfCa2PbIx+79AzLUOp65J
XsLFWJoy6mes1t4rEyXFWbttLZ/MZNpfVglOLaCYaAErzG6yyWvSxECNDuPItR3k
Ta4L2wkbMD54iDAh+JBRxNopXYnuFtAhvOpATmGAim0clFvhDu1Wr64MTOifNdze
CyOG8KkJdRJR2OCB5fM5P0D4KNJhFWlIOP5yDa4oBz+6awDwpsnD/F7kZlJDiLzr
x7Cgbmp1eWG+svDK60oETJOwMJb8dWXvUJedQXuymF5OCJHhJTUCr9AY3onWndlY
/XYiJ4vFPbLyB8EprjRMflEbTOeLtHP/RmHw3h8Qa1K4UsmntXbZ8rl3KeJWdage
mneb9dDesAiY6tVa2SnUolitajxklqMN09aK6YTwR1LQXGH76AICeE6a/tNyydc8
ZN+NggmrwFMZPgWJuix5dZlrXgZ/wsnHZlFBDEz8NwKm+cVPh+DQVNkba93KbQoL
/5GWT+ktICkrOEf4XUVYaMdGCIX1lNku56nTq5GRDZ1zB0n7WSTTxZFN4K8Zx9x6
Oqk9oNtW9KG9+XLNXAA5fFmopNWnpFmcX/uXkWRnQokQai3EIYTToSetbQ3Znn+4
HQMXe6VRBft5aHC8KQy8
=yKPv
-----END PGP SIGNATURE-----

--OWo51QjMmBw5UudRFBwODqMbhe8teBlxh--
