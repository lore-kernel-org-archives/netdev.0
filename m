From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V7 3/3] bfin_can: Merge header file from arch dependent
 location
Date: Fri, 06 Feb 2015 11:26:47 +0100
Message-ID: <54D496E7.2000307@pengutronix.de>
References: <1423217659-27820-1-git-send-email-Aaron.wu@analog.com> <1423217659-27820-3-git-send-email-Aaron.wu@analog.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="gwEmSjnWAnPcQpBfaedkGchIdpvpbNDkT"
To: Aaron Wu <Aaron.wu@analog.com>, wg@grandegger.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-devel@analog.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1423217659-27820-3-git-send-email-Aaron.wu@analog.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gwEmSjnWAnPcQpBfaedkGchIdpvpbNDkT
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/06/2015 11:14 AM, Aaron Wu wrote:
> Header file was in arch dependent location arch/blackfin/include/asm/bf=
in_can.h,
> Now move and merge the useful contents of header file into driver code,=
 note
> the original header file is reserved for full registers set access test=
 by other
> code so it survives.
>=20
> Signed-off-by: Aaron Wu <Aaron.wu@analog.com>
> ---
>  drivers/net/can/bfin_can.c |  110 ++++++++++++++++++++++++++++++++++++=
+++++++-
>  1 file changed, 109 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
> index 259d09a..bb1d480 100644
> --- a/drivers/net/can/bfin_can.c
> +++ b/drivers/net/can/bfin_can.c
> @@ -20,13 +20,121 @@
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
> +#define TRANSMIT_CHL 24
> +#define RECEIVE_STD_CHL 0
> +#define RECEIVE_EXT_CHL 4
> +#define RECEIVE_RTR_CHL 8
> +#define RECEIVE_EXT_RTR_CHL 12
> +#define MAX_CHL_NUMBER 32
> +
> +/* All Blackfin system MMRs are padded to 32bits even if the register
> + * itself is only 16bits.  So use a helper macro to streamline this
> +*/
> +#define __BFP(m) u16 m; u16 __pad_##m
> +
> +/* bfin can registers layout */
> +struct bfin_can_mask_regs {
> +	__BFP(aml);
> +	__BFP(amh);
> +};
> +
> +struct bfin_can_channel_regs {
> +	/* data[0,2,4,6] -> data{0,1,2,3} while data[1,3,5,7] is padding */
> +	u16 data[8];
> +	__BFP(dlc);
> +	__BFP(tsv);
> +	__BFP(id0);
> +	__BFP(id1);
> +};
> +
> +struct bfin_can_regs {
> +	/* global control and status registers */
> +	__BFP(mc1);		/* offset 0x00 */
> +	__BFP(md1);		/* offset 0x04 */
> +	__BFP(trs1);		/* offset 0x08 */
> +	__BFP(trr1);		/* offset 0x0c */
> +	__BFP(ta1);		/* offset 0x10 */
> +	__BFP(aa1);		/* offset 0x14 */
> +	__BFP(rmp1);		/* offset 0x18 */
> +	__BFP(rml1);		/* offset 0x1c */
> +	__BFP(mbtif1);		/* offset 0x20 */
> +	__BFP(mbrif1);		/* offset 0x24 */
> +	__BFP(mbim1);		/* offset 0x28 */
> +	__BFP(rfh1);		/* offset 0x2c */
> +	__BFP(opss1);		/* offset 0x30 */
> +	u32 __pad1[3];
> +	__BFP(mc2);		/* offset 0x40 */
> +	__BFP(md2);		/* offset 0x44 */
> +	__BFP(trs2);		/* offset 0x48 */
> +	__BFP(trr2);		/* offset 0x4c */
> +	__BFP(ta2);		/* offset 0x50 */
> +	__BFP(aa2);		/* offset 0x54 */
> +	__BFP(rmp2);		/* offset 0x58 */
> +	__BFP(rml2);		/* offset 0x5c */
> +	__BFP(mbtif2);		/* offset 0x60 */
> +	__BFP(mbrif2);		/* offset 0x64 */
> +	__BFP(mbim2);		/* offset 0x68 */
> +	__BFP(rfh2);		/* offset 0x6c */
> +	__BFP(opss2);		/* offset 0x70 */
> +	u32 __pad2[3];
> +	__BFP(clock);		/* offset 0x80 */
> +	__BFP(timing);		/* offset 0x84 */
> +	__BFP(debug);		/* offset 0x88 */
> +	__BFP(status);		/* offset 0x8c */
> +	__BFP(cec);		/* offset 0x90 */
> +	__BFP(gis);		/* offset 0x94 */
> +	__BFP(gim);		/* offset 0x98 */
> +	__BFP(gif);		/* offset 0x9c */
> +	__BFP(control);		/* offset 0xa0 */
> +	__BFP(intr);		/* offset 0xa4 */
> +	__BFP(version);		/* offset 0xa8 */
> +	__BFP(mbtd);		/* offset 0xac */
> +	__BFP(ewr);		/* offset 0xb0 */
> +	__BFP(esr);		/* offset 0xb4 */
> +	u32 __pad3[2];
> +	__BFP(ucreg);		/* offset 0xc0 */
> +	__BFP(uccnt);		/* offset 0xc4 */
> +	__BFP(ucrc);		/* offset 0xc8 */
> +	__BFP(uccnf);		/* offset 0xcc */
> +	u32 __pad4[1];
> +	__BFP(version2);	/* offset 0xd4 */
> +	u32 __pad5[10];
> +
> +	/* channel(mailbox) mask and message registers */
> +	struct bfin_can_mask_regs msk[MAX_CHL_NUMBER];    /* offset 0x100 */
> +	struct bfin_can_channel_regs chl[MAX_CHL_NUMBER]; /* offset 0x200 */
> +};
> +
> +#undef __BFP
> +
> +#define SRS	0x0001  /* Software Reset */
              ^^

please use a single space here (and below), as in the rest of the file.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--gwEmSjnWAnPcQpBfaedkGchIdpvpbNDkT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU1JbqAAoJECte4hHFiupU5p0QAKc7sr827kYDotzNLIEkgWD5
SlYnZTH+yuBOp4SbjeylZmYo+V7Jw4LmLgZ60TAR8bFmR0tmN4BHzhY0yxQazMK9
TAzjcecT91o/QQqEk7qQLhPOXXOlVhPCqo46Tb9VK56KaiQftKVbJ59YtWemBUyP
3mpOlIj03g+ci7dxpbwYm+lefijGAKfrXpb3k9TJ1mRaYFpsitCQh4DOYpiT5zZK
GuZIybggx8+fCbce1E1q+GaJDkX+pnTdMKPHAGehDxl9u4z8L/K6b2qOaZ7fpM4Y
wUMrJdvqxk3571bgyu6yW1ParUz1PKXNnx3R5AIPnCklvWYVTUcuEYAJIbRnjcr8
kclUoZD60pHZR5DIVj9ELiawjygaaUwUGoI1h+trBnwLCJ45rrO2XWpZ8AuZDkU6
SErQ5USt7s9XCwzPfREelCaIKMhmFU9cMsCG4EK3CEQukl+a2gG60FljphGCN9D/
h3Ovb4gaLyyfS0/Ci9vNmWAnBXrh1voKShC6gOl5NZB+/XHc5IBumITxZZjRl1CW
rtKZFYEkXCCORezi7tT4pa/fDmprlR8hJcXvO0gzhZiQfYv2IjgTMWoEL63wsucO
eF8qyQtdonLfS9fpWn2IbbgJgKiwlH6wdYr5Ot3EaJUlPTuVNjc5mWmvlbbXwd1P
o8X1cYvgHBedhtf1iYjh
=tJGK
-----END PGP SIGNATURE-----

--gwEmSjnWAnPcQpBfaedkGchIdpvpbNDkT--
