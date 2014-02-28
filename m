From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 12:37:25 +0100
Message-ID: <531074F5.8090702@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com> <52DCE9E4.7010209@pengutronix.de> <52E3148E.2010608@cogentembedded.com> <52FCB6C5.6020001@pengutronix.de> <53069445.80408@cogentembedded.com> <5310521E.6000708@pengutronix.de> <53107007.7050802@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="DWVLCl8JPmFMBfSgmKlT2pquGIiGEOGPJ"
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <53107007.7050802@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DWVLCl8JPmFMBfSgmKlT2pquGIiGEOGPJ
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/28/2014 12:16 PM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 28-02-2014 13:08, Marc Kleine-Budde wrote:
>=20
>>>>> 1. According to documentation BCR is the 24-bit register.
>>>>> Actually we can consider some 32-bit register that combines BCR and=

>>>>> CLKR but according to documentation there are two separate register=
s.
>>>>> 2. BCR has 8- ,16-, and 32-bit access (according to documentation).=

>>>>> 3. This is the algorithm that the documentation suggests.
>>>>> 4. We had a driver version with byte access but 32-bit access seems=

>>>>> shorter.
>=20
>>>> Please use a normal read-modify-write 32 bit access.
>=20
>>>     IMO, reading 32-bits is futile, as we're going to completely
>>> overwrite those 24 bits that constitute BCR. So I kept the 8-bit CLKR=

>>> read but removed the CLKR write in the end. I've also added a comment=

>>> clarifying why CLKR is positioned in the LSBs of 32-bit word (while i=
t's
>>> address would assume MSBs).
>>> The host bus is big-endian but byte-swaps at least 16- and 32-bit
>>> accesses, so that read[wl]()/write[wl]() work. 8-bit accesses are not=

>>> byte swapped, despite what the figure in the manual shows.
>=20
>> A 32 bit read/modify/write is a standard operation, nothing special, n=
o
>> need to worry about byte swapping or anything like this.
>=20
>    Oh, really? 8-)
>    Don't you know that read[bwlq]() assume little-endian memory layout
> and to read from big-endian 32-bit register one normally needs readl_be=
()?

I assume you are on little endian ARM only (for now).

If you use a standard 32 bit read, then modify the correct bits in that
32 bit word and write it back, with the corresponding 32 bit write
everything should be fine. For this usecase you just have yo figure out
which 24 of the 32 bit are the one you have to change and which are the
8 that must not be modified.

Looking at the register layout:

> +	u8 bcr[3];	/* Bit Configuration Register */
> +	u8 clkr;	/* Clock Select Register */

I think clkr would be the lowest 8 bit and bcr[] are the upper 24.
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--DWVLCl8JPmFMBfSgmKlT2pquGIiGEOGPJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMQdPUACgkQjTAFq1RaXHP/BQCgmOR7elbQHACc/W2R3G/N88ql
lUAAnjyFiUHE3qFtAvyN7TQ1FEYakCyz
=CkbC
-----END PGP SIGNATURE-----

--DWVLCl8JPmFMBfSgmKlT2pquGIiGEOGPJ--
