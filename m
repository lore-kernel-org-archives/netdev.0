From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 2/3] ser_gigaset: fix deallocation of platform device
 structure
Date: Sat, 12 Dec 2015 18:52:36 +0100
Message-ID: <566C5EE4.6040402@imap.cc>
References: <cover.1449570042.git.tilman@imap.cc>
 <83c4ab9bbca911aad62343154eabfa1af077b021.1449570042.git.tilman@imap.cc>
 <1449616321.2384.36.camel@tiscali.nl> <56680C25.1050704@imap.cc>
 <5669866F.6040407@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="06t8tLkxjk3Gsd7MECHrsvjDa1e8eTSit"
Cc: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5669866F.6040407@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--06t8tLkxjk3Gsd7MECHrsvjDa1e8eTSit
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Peter,

Am 10.12.2015 um 15:04 schrieb Peter Hurley:

>>>> --- a/drivers/isdn/gigaset/ser-gigaset.c
>>>> +++ b/drivers/isdn/gigaset/ser-gigaset.c
>>>> @@ -370,19 +370,23 @@ static void gigaset_freecshw(struct cardstate
>>>> *cs)
>>>>  	tasklet_kill(&cs->write_tasklet);
>>>>  	if (!cs->hw.ser)
>>>>  		return;
>>>> -	dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
>>>>  	platform_device_unregister(&cs->hw.ser->dev);
>>>> -	kfree(cs->hw.ser);
>>>> -	cs->hw.ser =3D NULL;
>>>>  }
>>>> =20
>>>>  static void gigaset_device_release(struct device *dev)
>>>>  {
>>>>  	struct platform_device *pdev =3D to_platform_device(dev);
>>>> +	struct cardstate *cs =3D dev_get_drvdata(dev);
>>>> =20
>>>>  	/* adapted from platform_device_release() in
>>>> drivers/base/platform.c */
>>>>  	kfree(dev->platform_data);
>>>>  	kfree(pdev->resource);
>>>> +
>>>> +	if (!cs)
>>>> +		return;
>>>> +	dev_set_drvdata(dev, NULL);
>=20
> This is of marginal value and (I think) unnecessary; it implies
> the core will use the device after release, which would trigger
> many problems if true.

Agreed, but I'm just moving existing code here. Dropping the
dev_set_drvdata() call would be an unrelated change which should be done
in a separate patch if I understand the rules correctly.

Regards,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--06t8tLkxjk3Gsd7MECHrsvjDa1e8eTSit
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWbF70AAoJEFPuqx0v+F+qAQAH/1u4di4itW3HkcPQ2zfi/GbB
zsuCKZ3lvDpiq9b9svbQM8LzlPVJCGeus6SxuU/tADY0dZIgGRUXtDIvxCmCg/xQ
R0e+Pe6xCSZRVds/dAWux6OegZ1vLJHPp0rkbUtbvxrA6obfZ8QG1LVeGXnBPK0D
MdeIOZi97t/uUzs7VvKueFJ0tw/bNZOGnbqgDUcLcNpJYnw5X072DhM/QGgZPuUk
Bd5fkDpIXrZPh3PJLhycaXxUb6G5vqb+NVsL10/0pkAPMb+fAmek1CD0/lojc3Ut
EdSWEjIjSynVEYruemfstuQSVOpZjx1sngNHDitbCg9h4EEPnYsHAJAu7QCutWg=
=69AB
-----END PGP SIGNATURE-----

--06t8tLkxjk3Gsd7MECHrsvjDa1e8eTSit--
