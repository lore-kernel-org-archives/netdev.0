From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 10:08:46 +0100
Message-ID: <5310521E.6000708@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com> <52DCE9E4.7010209@pengutronix.de> <52E3148E.2010608@cogentembedded.com> <52FCB6C5.6020001@pengutronix.de> <53069445.80408@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="vdwRBM0BKrMlqF48DM2shFAeuhRovLXH7"
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <53069445.80408@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vdwRBM0BKrMlqF48DM2shFAeuhRovLXH7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/21/2014 12:48 AM, Sergei Shtylyov wrote:

>>> 1. According to documentation BCR is the 24-bit register.
>>> Actually we can consider some 32-bit register that combines BCR and
>>> CLKR but according to documentation there are two separate registers.=

>>> 2. BCR has 8- ,16-, and 32-bit access (according to documentation).
>>> 3. This is the algorithm that the documentation suggests.
>>> 4. We had a driver version with byte access but 32-bit access seems
>>> shorter.
>=20
>> Please use a normal read-modify-write 32 bit access.
>=20
>    IMO, reading 32-bits is futile, as we're going to completely
> overwrite those 24 bits that constitute BCR. So I kept the 8-bit CLKR
> read but removed the CLKR write in the end. I've also added a comment
> clarifying why CLKR is positioned in the LSBs of 32-bit word (while it'=
s
> address would assume MSBs).
> The host bus is big-endian but byte-swaps at least 16- and 32-bit
> accesses, so that read[wl]()/write[wl]() work. 8-bit accesses are not
> byte swapped, despite what the figure in the manual shows.

A 32 bit read/modify/write is a standard operation, nothing special, no
need to worry about byte swapping or anything like this.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--vdwRBM0BKrMlqF48DM2shFAeuhRovLXH7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMQUh4ACgkQjTAFq1RaXHOL/gCfVB0CQCS8bxPFZ+p3BfueID+p
upcAnjsmpW/BuEcxMuH7RdSP2dHoZAO9
=1Abm
-----END PGP SIGNATURE-----

--vdwRBM0BKrMlqF48DM2shFAeuhRovLXH7--
