From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: sja1000: fix compilation on x86
Date: Fri, 14 Dec 2012 23:17:03 +0100
Message-ID: <50CBA55F.6030300@pengutronix.de>
References: <1355520824-23175-1-git-send-email-mkl@pengutronix.de> <1355520824-23175-2-git-send-email-mkl@pengutronix.de> <20121214.163758.465958297963655994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB2CAD71E3628C5C5B7E3250B"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	sfr@canb.auug.org.au, andreas@gaisler.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20121214.163758.465958297963655994.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB2CAD71E3628C5C5B7E3250B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/14/2012 10:37 PM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Fri, 14 Dec 2012 22:33:44 +0100
>=20
>> @@ -121,7 +121,7 @@ static int sja1000_ofp_probe(struct platform_devic=
e *ofdev)
>>  	}
>> =20
>>  	irq =3D irq_of_parse_and_map(np, 0);
>> -	if (irq =3D=3D NO_IRQ) {
>> +	if (irq <=3D 0) {
>>  		dev_err(&ofdev->dev, "no irq found\n");
>>  		err =3D -ENODEV;
>>  		goto exit_unmap_mem;
>=20
> I don't see anything existing which says this is the proper
> transformation.
>=20
> There is no consistency at all for the tests of the return
> value of irq_of_parse_and_map().

Right. And the current status of NO_IRQ doesn't help much.

> And if anything testing against zero is the correct thing to
> do, universally.

I've looked at the implementation of irq_of_parse_and_map() (both the
generic and sparc one), they both return 0 on failure. Because there are
some arch that define NO_IRQ being not 0, sparc (0xffffffff) and arm
(-1), I though testing against <=3D 0 would be a good idea.

> I'm not applying this or pulling from your tree, sorry.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigB2CAD71E3628C5C5B7E3250B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlDLpWIACgkQjTAFq1RaXHOzqACfTZb962NINMQY1AUmkyxrOfrw
mAgAn0r3mNh8pntJMKU+3r8b7JCyu5X3
=m5+K
-----END PGP SIGNATURE-----

--------------enigB2CAD71E3628C5C5B7E3250B--
