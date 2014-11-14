From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V4 2/3] can: m_can: update to support CAN FD features
Date: Fri, 14 Nov 2014 10:24:23 +0100
Message-ID: <5465CA47.4020802@pengutronix.de>
References: <1415349914-9145-1-git-send-email-b29396@freescale.com> <1415349914-9145-2-git-send-email-b29396@freescale.com> <54648382.9080105@pengutronix.de> <5464E2D7.7010906@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="BQIn7E2fRmCxX6Uqa7J2wpvSQ8R8OSF6s"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5464E2D7.7010906@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--BQIn7E2fRmCxX6Uqa7J2wpvSQ8R8OSF6s
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/13/2014 05:56 PM, Oliver Hartkopp wrote:
> On 11/13/2014 11:10 AM, Marc Kleine-Budde wrote:
>> On 11/07/2014 09:45 AM, Dong Aisheng wrote:
>=20
>>> =20
>>> -	if (id & RX_BUF_RTR) {
>>> +	if (id & RX_BUF_ESI) {
>>> +		cf->flags |=3D CANFD_ESI;
>>> +		netdev_dbg(dev, "ESI Error\n");
>>> +	}
>>> +
>>> +	if (!(dlc & RX_BUF_EDL) && (id & RX_BUF_RTR)) {
>>>  		cf->can_id |=3D CAN_RTR_FLAG;
>>
>> I just noticed, that you don't set the cf->dlc (or cf->len) in the RTR=

>> case. Please create a separate patch that fixes this problem.
>>
>>>  	} else {
>>>  		id =3D m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
>>> -		cf->can_dlc =3D get_can_dlc((id >> 16) & 0x0F);
>>> -		*(u32 *)(cf->data + 0) =3D m_can_fifo_read(priv, fgi,
>>> -							 M_CAN_FIFO_DATA(0));
>>> -		*(u32 *)(cf->data + 4) =3D m_can_fifo_read(priv, fgi,
>>> -							 M_CAN_FIFO_DATA(1));
>>> +		if (dlc & RX_BUF_EDL)
>>> +			cf->len =3D can_dlc2len((id >> 16) & 0x0F);
>>> +		else
>>> +			cf->len =3D get_can_dlc((id >> 16) & 0x0F);
>>> +
>=20
> Grr. I missed that one too :-(
>=20
> Thanks for catching it.
>=20
> As you committed patch 1 & 3 you expect a new single patch containing t=
he
> (fixed) content of this patch 2, right?

No, please make it two patches:

First the Bugfix: One setting the cf->dlc in the RTR case, too.
Then the new feature: The other one adding CAN-FD support.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--BQIn7E2fRmCxX6Uqa7J2wpvSQ8R8OSF6s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZcpHAAoJECte4hHFiupUJksP/jOeNEMnKC2vEl8+v+c0Gj07
o6Pa/ijqSIPbB+nXakF2Lef8WcHVeoklmbCnYirDIRD9mIfQgB4hDtixybA1/9l4
td5HhRGC3Qy2ds669Z0LQs6U0OxUbGqC6jcpcD5IO9/v9ITUY6C/uwugVvZO4yC2
Mu3fTNrIz3J8am9igqrh540lIYbYPIrtwKe2giO7vaThpioO84BIhczMQcIbW+2z
y2Bv2rfjrPFsYbqrVODoNxzmSIyhWCwmeL8WufGTbR3cP873QcsifSA3C9QEka3Q
mCT5F6n3Euqqftsp20HNx49zOUS5QW7Hana5EuPtV9+Cm0EWIwucPgHOxCgiqt+C
mSUxebPheQG+0+Upv/0xeF6Gv455lGXNOuJG0Iw6qX+rJ0kvGsxzt0dajxuqdr18
xzFnY7qfz3zuy0FqFFSI2AwEuQww/HkIRVejVEx0jYzZ1ibdNUXcLLXFSf9u5Uv4
QnyUCVl/mPinFcARx1TkMrucvPMk6cqKnIggbrAkXBrLDKxknShMh/ZR/NfQjH9P
GCavjPiz66drRzv2yCNWyQneF5jjC1rLRbZLgUU8lg21wB0hqN4NwmI1+RGPi+gX
JpA9HyCflSVTyM0eQPSEUNQ8j4/A8yIjua4pD6CGgBKMM2f2bYI3W+TIfhkFK/tL
3o0V+qvHjAYnVXKxmSM1
=w+nt
-----END PGP SIGNATURE-----

--BQIn7E2fRmCxX6Uqa7J2wpvSQ8R8OSF6s--
