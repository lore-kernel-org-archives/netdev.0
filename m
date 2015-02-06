From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V6 3/3] bfin_can: move and merge the content of header
 file into driver body
Date: Fri, 06 Feb 2015 08:51:39 +0100
Message-ID: <54D4728B.90300@pengutronix.de>
References: <1423203952-23004-1-git-send-email-Aaron.wu@analog.com> <1423203952-23004-3-git-send-email-Aaron.wu@analog.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Nph75X3aHmdFP1TE6w5Ql42j5q7bHTmkw"
To: Aaron Wu <Aaron.wu@analog.com>, wg@grandegger.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-devel@analog.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423203952-23004-3-git-send-email-Aaron.wu@analog.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Nph75X3aHmdFP1TE6w5Ql42j5q7bHTmkw
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/06/2015 07:25 AM, Aaron Wu wrote:
> Header file was in arch dependent location arch/blackfin/include/asm/bf=
in_can.h,
> Now move and merge the useful contents of header file into driver code,=
 note
> the original header file is reserved for full register sets access test=
 by other
> code so it survives.  =20
                      ^^^

Trailing whitespace :)

>=20
> Signed-off-by: Aaron Wu <Aaron.wu@analog.com>
> ---
>  drivers/net/can/bfin_can.c |  114 ++++++++++++++++++++++++++++++++++++=
+++++++-
>  1 file changed, 113 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
> index 259d09a..63fab5c 100644
> --- a/drivers/net/can/bfin_can.c
> +++ b/drivers/net/can/bfin_can.c
> @@ -20,13 +20,125 @@
>  #include <linux/can/dev.h>
>  #include <linux/can/error.h>
> =20
> -#include <asm/bfin_can.h>
>  #include <asm/portmux.h>
> =20
>  #define DRV_NAME "bfin_can"
>  #define BFIN_CAN_TIMEOUT 100
>  #define TX_ECHO_SKB_MAX  1
> =20
> +/* transmit and receive channels */
> +
> +#define TRANSMIT_CHL    24
> +#define RECEIVE_STD_CHL    0
> +#define RECEIVE_EXT_CHL    4
> +#define RECEIVE_RTR_CHL    8
> +#define RECEIVE_EXT_RTR_CHL    12
> +#define MAX_CHL_NUMBER    32
                         ^^^^
Please fix the indention, use one space only.

> +
> +/* All Blackfin system MMRs are padded to 32bits even if the register
> + * itself is only 16bits.  So use a helper macro to streamline this
> +*/
> +#define __BFP(m) u16 m; u16 __pad_##m
> +
> + /* bfin can registers layout
> + */
> +struct bfin_can_mask_regs {
> +	__BFP(aml);
> +	__BFP(amh);
> +};
> +
> +struct bfin_can_channel_regs {
> +	/* data[0,2,4,6] -> data{0,1,2,3} while data[1,3,5,7] is padding */
> +	u16 data[8];
> +	 __BFP(dlc);
        ^ please remove that space
> +	__BFP(tsv);
> +	__BFP(id0);
> +	__BFP(id1);
> +};
> +
> +struct bfin_can_regs {
> +	/* global control and status registers
> +	 */
> +	__BFP(mc1);           /* offset 0x00 */
                   ^^^^^^^^^^^
please use tab(s) instead of spaces here.

> +	__BFP(md1);           /* offset 0x04 */
> +	__BFP(trs1);          /* offset 0x08 */
> +	__BFP(trr1);          /* offset 0x0c */
> +	__BFP(ta1);           /* offset 0x10 */
> +	__BFP(aa1);           /* offset 0x14 */
> +	__BFP(rmp1);          /* offset 0x18 */
> +	__BFP(rml1);          /* offset 0x1c */
> +	__BFP(mbtif1);        /* offset 0x20 */
> +	__BFP(mbrif1);        /* offset 0x24 */
> +	__BFP(mbim1);         /* offset 0x28 */
> +	__BFP(rfh1);          /* offset 0x2c */
> +	__BFP(opss1);         /* offset 0x30 */
> +	u32 __pad1[3];
> +	 __BFP(mc2);           /* offset 0x40 */
        ^
please remove that space.

> +	__BFP(md2);           /* offset 0x44 */
> +	__BFP(trs2);          /* offset 0x48 */
> +	__BFP(trr2);          /* offset 0x4c */
> +	__BFP(ta2);           /* offset 0x50 */
> +	__BFP(aa2);           /* offset 0x54 */
> +	__BFP(rmp2);          /* offset 0x58 */
> +	__BFP(rml2);          /* offset 0x5c */
> +	__BFP(mbtif2);        /* offset 0x60 */
> +	__BFP(mbrif2);        /* offset 0x64 */
> +	__BFP(mbim2);         /* offset 0x68 */
> +	__BFP(rfh2);          /* offset 0x6c */
> +	__BFP(opss2);         /* offset 0x70 */
> +	u32 __pad2[3];
> +	 __BFP(clock);         /* offset 0x80 */
        ^
same here

> +	__BFP(timing);        /* offset 0x84 */
> +	__BFP(debug);         /* offset 0x88 */
> +	__BFP(status);        /* offset 0x8c */
> +	__BFP(cec);           /* offset 0x90 */
> +	__BFP(gis);           /* offset 0x94 */
> +	__BFP(gim);           /* offset 0x98 */
> +	__BFP(gif);           /* offset 0x9c */
> +	__BFP(control);       /* offset 0xa0 */
> +	__BFP(intr);          /* offset 0xa4 */
> +	__BFP(version);       /* offset 0xa8 */
> +	__BFP(mbtd);          /* offset 0xac */
> +	__BFP(ewr);           /* offset 0xb0 */
> +	__BFP(esr);           /* offset 0xb4 */
> +	u32 __pad3[2];
> +	 __BFP(ucreg);         /* offset 0xc0 */
        ^
same here
> +	__BFP(uccnt);         /* offset 0xc4 */
> +	__BFP(ucrc);          /* offset 0xc8 */
> +	__BFP(uccnf);         /* offset 0xcc */
> +	u32 __pad4[1];
> +	 __BFP(version2);      /* offset 0xd4 */
        ^
same here
> +	u32 __pad5[10];
> +
> +	/* channel(mailbox) mask and message registers
> +	 */

	/* single line comment should look like this */

> +	struct bfin_can_mask_regs msk[MAX_CHL_NUMBER];    /* offset 0x100 */
> +	struct bfin_can_channel_regs chl[MAX_CHL_NUMBER]; /* offset 0x200 */
> +};
> +
> +#undef __BFP
> +
> +#define SRS	             0x0001  /* Software Reset */
              ^^^^^^^^^^^^^^^      ^^
single space here                  probably one tab here
> +#define SER	             0x0008  /* Stuff Error */
> +#define BOIM	            0x0008  /* Enable Bus Off Interrupt */
> +#define CCR	             0x0080  /* CAN Configuration Mode Request */
> +#define CCA	             0x0080  /* Configuration Mode Acknowledge */
> +#define SAM	             0x0080  /* Sampling */
> +#define AME	             0x8000  /* Acceptance Mask Enable */
> +#define RMLIM	           0x0080  /* Enable RX Message Lost Interrupt *=
/
> +#define RMLIS	           0x0080  /* RX Message Lost IRQ Status */
> +#define RTR	             0x4000  /* Remote Frame Transmission Request =
*/
> +#define BOIS	            0x0008  /* Bus Off IRQ Status */
> +#define IDE	             0x2000  /* Identifier Extension */
> +#define EPIS	            0x0004  /* Error-Passive Mode IRQ Status */
> +#define EPIM	            0x0004  /* Enable Error-Passive Mode Interrup=
t */
> +#define EWTIS	           0x0001  /* TX Error Count IRQ Status */
> +#define EWRIS	           0x0002  /* RX Error Count IRQ Status */
> +#define BEF	             0x0040  /* Bit Error Flag */
> +#define FER	             0x0080  /* Form Error Flag */
> +#define SMR		   0x0020	/* Sleep Mode Request */
> +#define SMACK		   0x0008	/* Sleep Mode Acknowledge */
> +
>  /*
>   * bfin can private data
>   */
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Nph75X3aHmdFP1TE6w5Ql42j5q7bHTmkw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU1HKPAAoJECte4hHFiupUBpAP/jZLPrINax21f8afC+l/OMe8
3bFY48qvY+TNbAAf9uOR5k+zKl1KejwkoapJ8YxiAaU4W6bgcHd2SrnIPX0WiLZz
TNmw1hktBugMRn5Gqd0Es82FmeazdbRuTw2k4ILwQGEmhcT3ThqNmqJhLbcBYgJy
xX9CoPdwCzM+kciGui0rSqnvNHuztwYuEl3QNmqqDJ7IQGueDMttYA88zun62mzh
35KP7BpoFCjJ/YeIdtGQG3tnQITRDy9YcEx0YYfsSwbnCKDX1tJ6tEsGpA5kewr5
9f4IahwsAOgqZveCtsvnX8apN60C3+55eY1gbtN43Nyn7RgkoR4l3Jj1V3nRw/xj
Ud5iAQ4pd/5l16W/jaf50JLbiPs+ODG1G5e/RP3YeJGZH+XXnUUNe9poOueTw38N
U7KKzlWP7NpJY8trSWB17Cjg/LTnjY1FGBdKuVncJBDO55isRcKlyMMAtEjCQPRG
IOH5RjYnk+EhPStbV/0+l7xZJ9omeixsyMgiAdfqeiJ5eP5Clsu7asLvuOm94Ebw
ElU68fy58pifuZkb+CszJG3iK3y5UT3ZYSgyEXYY6Xa3m1g4/tjukHMWg4DYBbja
WCbhJEOVE/ZKo2c7qkp4JpQN4u+CuyAUk7nVr1rdT8iiMPjvuaHYIpMg+k1y5zx0
r2gSEhlYH14i8HGnbOB0
=tDCa
-----END PGP SIGNATURE-----

--Nph75X3aHmdFP1TE6w5Ql42j5q7bHTmkw--
