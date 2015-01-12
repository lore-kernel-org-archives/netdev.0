From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 4/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Mon, 12 Jan 2015 12:51:49 +0100
Message-ID: <54B3B555.5010804@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150105174910.GA6304@linux> <20150105175206.GB6304@linux> <20150105175713.GC6304@linux> <20150105183131.GD6304@linux> <54AE6FC1.6050007@pengutronix.de> <20150108151901.GA11398@vivalin-002>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="tg8oUDEVCPOEpFf6VU1aof2MrQIwatXwt"
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150108151901.GA11398@vivalin-002>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--tg8oUDEVCPOEpFf6VU1aof2MrQIwatXwt
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/08/2015 04:19 PM, Ahmed S. Darwish wrote:

[...]

>>>  MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
>>> @@ -463,7 +631,18 @@ static int kvaser_usb_get_software_info(struct k=
vaser_usb *dev)
>>>  	if (err)
>>>  		return err;
>>> =20
>>> -	dev->fw_version =3D le32_to_cpu(msg.u.softinfo.fw_version);
>>> +	switch (dev->family) {
>>> +	case KVASER_LEAF:
>>> +		dev->fw_version =3D le32_to_cpu(msg.u.leaf.softinfo.fw_version);
>>> +		break;
>>> +	case KVASER_USBCAN:
>>> +		dev->fw_version =3D le32_to_cpu(msg.u.usbcan.softinfo.fw_version);=

>>> +		break;
>>> +	default:
>>> +		dev_err(dev->udev->dev.parent,
>>> +			"Invalid device family (%d)\n", dev->family);
>>> +		return -EINVAL;
>>
>> The default case should not happen. I think you can remove it.

> It's true, it _should_ never happen. But I only add such checks if
> the follow-up code critically depends on a certain `dev->family`
> behavior. So it's kind of a defensive check against any possible
> bug in driver or memory.
>=20
> What do you think?

The kernel is full of callback functions, if you have a bit flip there
you're in trouble anyways. A bug in the driver (or other parts of the
kernel) might overwrite the memory of dev->family, but if this happens,
more things will break.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--tg8oUDEVCPOEpFf6VU1aof2MrQIwatXwt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUs7VWAAoJECte4hHFiupUeWcP/1BpoQ4OpdhCt9ofjwBeRcfh
stpoxMN7y4iIoiCLRnZYrzDD1V/az96ToZNenOk7TlfMp0+Ulh+lH0FJ/8nEYflU
fj+Zkx7EFAFdjQgmL6aPQ34PyVmUBiTGdigWIC6jRuttIxa6IegODwyxNeHxKz2W
WWyU4fX0Slm18Upgytd/8m6h3fOBo66GPBCxPJBbXN/EqCHepsXitMuM3TvLt2+9
MKZ84h4z4ngLAQQisMAAEYJGYXEgAP8Kw6EPunPFHvJLn1iZsfE+qSOmPTo8jKhu
wjD2dIP30w3sp70Q0ZznKCJvYdwbTJgSTqUONN2lW4CMSHMhLQneh8fPV1+JyQlD
zmC49fo36X+pxHCrIFQ9uZljkvRpMI9F3mfqQQfU5lUzOUO/WBpK55BvB8gowhrY
dE3TsGS8Z8L7IaICCMXeuyJmONpKZK5kFLWd84kO/C9cJVI8hgs/BFihPX/YGm64
UIiTjKcy8fNIAyiAzN9YNmSoAC3vm54cH3jQd2ytxOmCcaYmaD4/VeurNFL2EDRk
xUHh/BQkFvePL6quYgmTe4v/3Ob926fgLJK+VuQZ/PbAG7x9o9th75163Yi6UzZf
02yGKkHseTQIDnYOXFhBUdVDyRqUH4VIrlXoVsaN2ZTisgnbILjDGS/957fQI9mw
H/IeWv/QyHef2Oyxy04N
=YvLD
-----END PGP SIGNATURE-----

--tg8oUDEVCPOEpFf6VU1aof2MrQIwatXwt--
