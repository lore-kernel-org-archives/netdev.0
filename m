From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 20 Jan 2014 13:35:26 +0100
Message-ID: <52DD180E.7080107@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>	<CAMuHMdWZJUvcW9OzM39aB2m+VdKqmZ6EOGR_rZcAdV7Cmwx3kg@mail.gmail.com>	<52DD0CC1.70205@pengutronix.de> <CAMuHMdV5sMUnXb1Z1HeRk9+_dCGWrbD-DS62S7T4Be-77HvsvA@mail.gmail.com> <52DD0F72.1000005@pengutronix.de> <52DD1058.4090205@codethink.co.uk> <063D6719AE5E284EB5DD2968C1650D6D460082@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="72JqxuNcCCK8G819IgppQt4aIUw3NnEjN"
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"vksavl@gmail.com" <vksavl@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	'Ben Dooks' <ben.dooks@codethink.co.uk>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D460082@AcuExch.aculab.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--72JqxuNcCCK8G819IgppQt4aIUw3NnEjN
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2014 01:13 PM, David Laight wrote:
> From:=20
>> On 20/01/14 11:58, Marc Kleine-Budde wrote:
>>> On 01/20/2014 12:52 PM, Geert Uytterhoeven wrote:
>>>> On Mon, Jan 20, 2014 at 12:47 PM, Marc Kleine-Budde <mkl@pengutronix=
=2Ede> wrote:
>>>>> On 01/20/2014 12:43 PM, Geert Uytterhoeven wrote:
>>>>>> On Thu, Dec 26, 2013 at 10:37 PM, Sergei Shtylyov
>>>>>> <sergei.shtylyov@cogentembedded.com> wrote:
>>>>>>> Changes in version 3:
>>>>>>
>>>>>>> - added '__packed' to 'struct rcar_can_mbox_regs' and 'struct rca=
r_can_regs';
>>>>>>> - removed unneeded type cast in the probe() method.
>>>>>>
>>>>>>> +/* Mailbox registers structure */
>>>>>>> +struct rcar_can_mbox_regs {
>>>>>>> +       u32 id;         /* IDE and RTR bits, SID and EID */
>>>>>>> +       u8 stub;        /* Not used */
>>>>>>> +       u8 dlc;         /* Data Length Code - bits [0..3] */
>>>>>>> +       u8 data[8];     /* Data Bytes */
>>>>>>> +       u8 tsh;         /* Time Stamp Higher Byte */
>>>>>>> +       u8 tsl;         /* Time Stamp Lower Byte */
>>>>>>> +} __packed;
>>>>>>
>>>>>> Sorry, I missed the earlier discussion, but why the _packed?
>>>>>> One u32 and 12 bytes makes a nice multiple of 4.
>>>>>
>>>>> Better safe than sorry, it's the layout of the registers in hardwar=
e,
>>>>> don't let the compiler optimize here.
>=20
> Why not just add a compile time check against the size of the
> structure - that will ensure that no padding is accidentally added.

And what do when the check fails? Add an the __packed (again)? :D

>>>> Actually __packed makes it less safe, as the compiler now assumes
>>>> the u32 id member is unaligned, and thus may turn 32-bit accesses in=
to 4
>>>> byte accesses.
>>>>
>>>> Fortunately it won't happen in this case as the code uses writel/rea=
dl to
>>>> acces the id member.
>=20
> Which means that it will be aligned (and must be aligned).
> So the packed is completely useless and pointless.

Then we'll remove the packed.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--72JqxuNcCCK8G819IgppQt4aIUw3NnEjN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLdGA4ACgkQjTAFq1RaXHO6IACfSs4KwPd0UgUx+EBc2PedPufR
aKAAniYodamu99Iohpeo9ivbXerePEJU
=p++2
-----END PGP SIGNATURE-----

--72JqxuNcCCK8G819IgppQt4aIUw3NnEjN--
