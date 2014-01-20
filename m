From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 20 Jan 2014 12:58:42 +0100
Message-ID: <52DD0F72.1000005@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>	<CAMuHMdWZJUvcW9OzM39aB2m+VdKqmZ6EOGR_rZcAdV7Cmwx3kg@mail.gmail.com>	<52DD0CC1.70205@pengutronix.de> <CAMuHMdV5sMUnXb1Z1HeRk9+_dCGWrbD-DS62S7T4Be-77HvsvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="kgDSoo8CwiBQwOnOPDfda7rFU0pXa6oCG"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>, vksavl@gmail.com
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdV5sMUnXb1Z1HeRk9+_dCGWrbD-DS62S7T4Be-77HvsvA@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kgDSoo8CwiBQwOnOPDfda7rFU0pXa6oCG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2014 12:52 PM, Geert Uytterhoeven wrote:
> On Mon, Jan 20, 2014 at 12:47 PM, Marc Kleine-Budde <mkl@pengutronix.de=
> wrote:
>> On 01/20/2014 12:43 PM, Geert Uytterhoeven wrote:
>>> On Thu, Dec 26, 2013 at 10:37 PM, Sergei Shtylyov
>>> <sergei.shtylyov@cogentembedded.com> wrote:
>>>> Changes in version 3:
>>>
>>>> - added '__packed' to 'struct rcar_can_mbox_regs' and 'struct rcar_c=
an_regs';
>>>> - removed unneeded type cast in the probe() method.
>>>
>>>> +/* Mailbox registers structure */
>>>> +struct rcar_can_mbox_regs {
>>>> +       u32 id;         /* IDE and RTR bits, SID and EID */
>>>> +       u8 stub;        /* Not used */
>>>> +       u8 dlc;         /* Data Length Code - bits [0..3] */
>>>> +       u8 data[8];     /* Data Bytes */
>>>> +       u8 tsh;         /* Time Stamp Higher Byte */
>>>> +       u8 tsl;         /* Time Stamp Lower Byte */
>>>> +} __packed;
>>>
>>> Sorry, I missed the earlier discussion, but why the _packed?
>>> One u32 and 12 bytes makes a nice multiple of 4.
>>
>> Better safe than sorry, it's the layout of the registers in hardware,
>> don't let the compiler optimize here.
>=20
> Actually __packed makes it less safe, as the compiler now assumes
> the u32 id member is unaligned, and thus may turn 32-bit accesses into =
4
> byte accesses.
>=20
> Fortunately it won't happen in this case as the code uses writel/readl =
to
> acces the id member.

Yes, as this are registers they must not be accessed directly. However
we can use "__attribute__ ((packed, aligned(4)))" to tell the compiler
that the base address of this struct is always aligned to 4 bytes.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--kgDSoo8CwiBQwOnOPDfda7rFU0pXa6oCG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLdD3IACgkQjTAFq1RaXHPk5gCgh0O/Wc8bVK+ye3hF/vX1a15k
edUAoIRfxWip/fvVOWsdykUirarksgkr
=2cWM
-----END PGP SIGNATURE-----

--kgDSoo8CwiBQwOnOPDfda7rFU0pXa6oCG--
