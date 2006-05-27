From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: CRC16 in rt2x00
Date: Sat, 27 May 2006 16:24:07 +0200
Message-ID: <200605271624.11062.IvDoorn@gmail.com>
References: <200605271327.18879.IvDoorn@gmail.com> <20060527175516.600f450c.vsu@altlinux.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart71801858.esnjWnKngk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:49361 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751535AbWE0OVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 10:21:31 -0400
Received: by nf-out-0910.google.com with SMTP id l36so38275nfa
        for <netdev@vger.kernel.org>; Sat, 27 May 2006 07:21:30 -0700 (PDT)
To: Sergey Vlasov <vsu@altlinux.ru>
In-Reply-To: <20060527175516.600f450c.vsu@altlinux.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart71801858.esnjWnKngk
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 27 May 2006 15:55, Sergey Vlasov wrote:
> On Sat, 27 May 2006 13:27:15 +0200 Ivo van Doorn wrote:
>=20
> > I have a small question about the CRC16 usage in rt2x00
> > and what the netdev preferred method is for this.
> >=20
> > At the moment the rt2x00 drivers in wireless-dev use
> > its own CRC16 table and calculation inside the driver.
> > There already is a CRC16 library in the kernel
> > which uses the 0x8005 table, while rt2x00 uses the
> > 0x1021 polynomial table.
> >=20
> > Is keeping this version of CRC16 inside rt2x00 the most
> > sensible thing to do? Or should it be moved to the lib
> > folder of the kernel so other drivers could make use of it as well?
> > (So far I have not found a driver which makes use
> > of the same CRC16 table)
>=20
> However, fs/udf/crc.c has exactly the same CRC table as rt2x00:
>=20
> static uint16_t crc_table[256] =3D {
>         0x0000U, 0x1021U, 0x2042U, 0x3063U, 0x4084U, 0x50a5U, 0x60c6U, 0x=
70e7U,
> ...
>         0x6e17U, 0x7e36U, 0x4e55U, 0x5e74U, 0x2e93U, 0x3eb2U, 0x0ed1U, 0x=
1ef0U
> };
>=20
> /*     =20
>  * udf_crc
>  *     =20
>  * PURPOSE
>  *      Calculate a 16-bit CRC checksum using ITU-T V.41 polynomial.
>  *     =20
>  * DESCRIPTION
>  *      The OSTA-UDF(tm) 1.50 standard states that using CRCs is mandator=
y.
>  *      The polynomial used is: x^16 + x^12 + x^15 + 1
>  *
>  * PRE-CONDITIONS
>  *      data            Pointer to the data block.
>  *      size            Size of the data block.
>  *
>  * POST-CONDITIONS
>  *      <return>        CRC of the data block.
>  *
>  * HISTORY
>  *      July 21, 1997 - Andrew E. Mileski
>  *      Adapted from OSTA-UDF(tm) 1.50 standard.
>  */
>=20
> This is a bit-reversed form of CRC-CCITT supported by lib/crc-ccitt.c.
> Unfortunately, this does not help much, because converting one form to
> the other is too expensive (you would need to reverse bits in all data
> bytes, and then reverse bits in the 16-bit result).
>=20
> BTW, there is more CRC code duplication in drivers/bluetooth/hci_bcsp.c
> (bcsp_crc_update() seems to give the same result as crc_ccitt_byte()).
>=20
> In drivers/media/dvb/frontends/nxt200x.c, nxt200x_crc() seems to give
> the same result as rt2x00crc_byte() (but without using a table).
>=20
> drivers/net/wan/cycx_drv.c:checksum() is also some mutated version of
> CRC-CCITT (adding two additional zero bytes at the end of data makes it
> return the same result as rt2x00crc()).

Interesting, so it would actually be usefull to move the nxt200x crc16 impl=
emetation
into the crc16 library (Is not using a table preferred over using a table?)
And make rt2x00 and fs/udf/crc.c make use of this library?

And perhaps hci_bcsp could be updated to use crc_ccitt_byte() instead?

Regards,

ivo

--nextPart71801858.esnjWnKngk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEeGELaqndE37Em0gRAgacAJ0fs7mOT/O2BbrMhtyWpkVEmReBDACg2j9h
7b3fZyW+4W3Yr4ZEKouPG1s=
=l1Ik
-----END PGP SIGNATURE-----

--nextPart71801858.esnjWnKngk--
