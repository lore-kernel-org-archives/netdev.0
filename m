From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 20 Jan 2014 22:17:47 +0100
Message-ID: <52DD927B.2060500@pengutronix.de>
References: <52DD0CC1.70205@pengutronix.de>	<CAMuHMdV5sMUnXb1Z1HeRk9+_dCGWrbD-DS62S7T4Be-77HvsvA@mail.gmail.com>	<52DD0F72.1000005@pengutronix.de> <20140120.111614.394228612374217980.davem@davemloft.net> <52DD9F3C.7000408@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="X94qe1MDDFOxoKFEsLSULd3bPca3mhDTt"
Cc: geert@linux-m68k.org, netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <52DD9F3C.7000408@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--X94qe1MDDFOxoKFEsLSULd3bPca3mhDTt
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2014 11:12 PM, Sergei Shtylyov wrote:
[...]

>> I truly think using packed here is rediculous, please remove it unless=

>> you can prove that things won't work without it.
>=20
>    They will. But how about the following 'struct rcar_can_regs'?

The strcuts in question are:

> +/* Mailbox registers structure */
> +struct rcar_can_mbox_regs {
> +	u32 id;		/* IDE and RTR bits, SID and EID */
> +	u8 stub;	/* Not used */
> +	u8 dlc;		/* Data Length Code - bits [0..3] */
> +	u8 data[8];	/* Data Bytes */
> +	u8 tsh;		/* Time Stamp Higher Byte */
> +	u8 tsl;		/* Time Stamp Lower Byte */
> +} __packed;
> +
> +struct rcar_can_regs {
> +	struct rcar_can_mbox_regs mb[RCAR_CAN_N_MBX]; /* Mailbox registers */=

> +	u32 mkr_2_9[8];	/* Mask Registers 2-9 */
> +	u32 fidcr[2];	/* FIFO Received ID Compare Register */
> +	u32 mkivlr1;	/* Mask Invalid Register 1 */
> +	u32 mier1;	/* Mailbox Interrupt Enable Register 1 */
> +	u32 mkr_0_1[2];	/* Mask Registers 0-1 */
> +	u32 mkivlr0;    /* Mask Invalid Register 0*/
> +	u32 mier0;      /* Mailbox Interrupt Enable Register 0 */
> +	u8 pad_440[0x3c0];
> +	u8 mctl[64];	/* Message Control Registers */
> +	u16 ctlr;	/* Control Register */
> +	u16 str;	/* Status register */
> +	u8 bcr[3];	/* Bit Configuration Register */
> +	u8 clkr;	/* Clock Select Register */
> +	u8 rfcr;	/* Receive FIFO Control Register */
> +	u8 rfpcr;	/* Receive FIFO Pointer Control Register */
> +	u8 tfcr;	/* Transmit FIFO Control Register */
> +	u8 tfpcr;       /* Transmit FIFO Pointer Control Register */
> +	u8 eier;	/* Error Interrupt Enable Register */
> +	u8 eifr;	/* Error Interrupt Factor Judge Register */
> +	u8 recr;	/* Receive Error Count Register */
> +	u8 tecr;        /* Transmit Error Count Register */
> +	u8 ecsr;	/* Error Code Store Register */
> +	u8 cssr;	/* Channel Search Support Register */
> +	u8 mssr;	/* Mailbox Search Status Register */
> +	u8 msmr;	/* Mailbox Search Mode Register */
> +	u16 tsr;	/* Time Stamp Register */
> +	u8 afsr;	/* Acceptance Filter Support Register */
> +	u8 pad_857;
> +	u8 tcr;		/* Test Control Register */
> +	u8 pad_859[7];
> +	u8 ier;		/* Interrupt Enable Register */
> +	u8 isr;		/* Interrupt Status Register */
> +	u8 pad_862;
> +	u8 mbsmr;	/* Mailbox Search Mask Register */
> +} __packed;

I think they should work without packed, too.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--X94qe1MDDFOxoKFEsLSULd3bPca3mhDTt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLdknsACgkQjTAFq1RaXHM/PACglbz/ThfOyCmL3FzYLO/tjJ6y
lzYAnieHk/rY7O6f01mrljat8n6T/cre
=pASO
-----END PGP SIGNATURE-----

--X94qe1MDDFOxoKFEsLSULd3bPca3mhDTt--
