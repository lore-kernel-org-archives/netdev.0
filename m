From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RESEND PATCH 1/1] can: m_can: fix bitrate setup on latest
 silicon
Date: Mon, 20 Feb 2017 17:50:01 +0100
Message-ID: <ec53dc63-0d41-8e8c-7f2f-24968d14c23a@pengutronix.de>
References: <20170215140819.879-1-quentin.schulz@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="87m1t0IE9aK2IU1wb03QmEdCdX7oDeFC1"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com,
        alexandre.belloni@free-electrons.com, nicolas.ferre@atmel.com
To: Quentin Schulz <quentin.schulz@free-electrons.com>,
        wg@grandegger.com, fvallee@eukrea.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215140819.879-1-quentin.schulz@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--87m1t0IE9aK2IU1wb03QmEdCdX7oDeFC1
Content-Type: multipart/mixed; boundary="Nd5GgknBm9BCHxJ2XUaOD5KWnBB4AtbKD";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Quentin Schulz <quentin.schulz@free-electrons.com>, wg@grandegger.com,
 fvallee@eukrea.fr
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com,
 alexandre.belloni@free-electrons.com, nicolas.ferre@atmel.com
Message-ID: <ec53dc63-0d41-8e8c-7f2f-24968d14c23a@pengutronix.de>
Subject: Re: [RESEND PATCH 1/1] can: m_can: fix bitrate setup on latest
 silicon
References: <20170215140819.879-1-quentin.schulz@free-electrons.com>
In-Reply-To: <20170215140819.879-1-quentin.schulz@free-electrons.com>

--Nd5GgknBm9BCHxJ2XUaOD5KWnBB4AtbKD
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/15/2017 03:08 PM, Quentin Schulz wrote:
> From: Florian Vallee <fvallee@eukrea.fr>
>=20
> According to the m_can user manual changelog the BTP register layout wa=
s
> updated with core revision 3.1.0
>=20
> This change is not backward-compatible and using the current driver alo=
ng
> with a recent IP results in an incorrect bitrate on the wire.
>=20
> Tested with a SAMA5D2 SoC (CREL =3D 0x31040730)
>=20
> Signed-off-by: Florian Vallee <fvallee@eukrea.fr>
> Tested-by: Quentin Schulz <quentin.schulz@free-electrons.com>

Can you please add your S-o-b here, too.

> ---
>  drivers/net/can/m_can/m_can.c | 38 +++++++++++++++++++++++++++++++++++=
---
>  1 file changed, 35 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_ca=
n.c
> index 195f15e..246584e 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -105,6 +105,10 @@ enum m_can_mram_cfg {
>  	MRAM_CFG_NUM,
>  };
> =20
> +/* Core Release Register (CREL) */
> +#define CRR_REL_MASK		0xfff
> +#define CRR_REL_SHIFT		20
> +
>  /* Fast Bit Timing & Prescaler Register (FBTP) */
>  #define FBTR_FBRP_MASK		0x1f
>  #define FBTR_FBRP_SHIFT		16
> @@ -136,7 +140,7 @@ enum m_can_mram_cfg {
>  #define CCCR_INIT		BIT(0)
>  #define CCCR_CANFD		0x10
> =20
> -/* Bit Timing & Prescaler Register (BTP) */
> +/* Bit Timing & Prescaler Register (BTP) (M_CAN IP < 3.1.0) */
>  #define BTR_BRP_MASK		0x3ff
>  #define BTR_BRP_SHIFT		16
>  #define BTR_TSEG1_SHIFT		8
> @@ -146,6 +150,16 @@ enum m_can_mram_cfg {
>  #define BTR_SJW_SHIFT		0
>  #define BTR_SJW_MASK		0xf
> =20
> +/* Nominal Bit Timing & Prescaler Register (NBTP) (M_CAN IP >=3D 3.1.0=
) */
> +#define NBTR_SJW_SHIFT		25
> +#define NBTR_SJW_MASK		(0x7f << NBTR_SJW_SHIFT)
> +#define NBTR_BRP_SHIFT		16
> +#define NBTR_BRP_MASK		(0x3ff << NBTR_BRP_SHIFT)
> +#define NBTR_TSEG1_SHIFT	8
> +#define NBTR_TSEG1_MASK		(0xff << NBTR_TSEG1_SHIFT)
> +#define NBTR_TSEG2_SHIFT	0
> +#define NBTR_TSEG2_MASK		(0x7f << NBTR_TSEG2_SHIFT)

Use BTR_310_ as a prefix here.

> +
>  /* Error Counter Register(ECR) */
>  #define ECR_RP			BIT(15)
>  #define ECR_REC_SHIFT		8
> @@ -200,6 +214,9 @@ enum m_can_mram_cfg {
>  			 IR_RF1L | IR_RF0L)
>  #define IR_ERR_ALL	(IR_ERR_STATE | IR_ERR_BUS)
> =20
> +/* Core Version */
> +#define M_CAN_COREREL_3_1_0	0x310

_310 should be fine

> +
>  /* Interrupt Line Select (ILS) */
>  #define ILS_ALL_INT0	0x0
>  #define ILS_ALL_INT1	0xFFFFFFFF
> @@ -357,6 +374,13 @@ static inline void m_can_disable_all_interrupts(co=
nst struct m_can_priv *priv)
>  	m_can_write(priv, M_CAN_ILE, 0x0);
>  }
> =20
> +static inline int m_can_read_core_rev(const struct m_can_priv *priv)

make it an u16

> +{
> +	u32 reg =3D m_can_read(priv, M_CAN_CREL);
> +
> +	return ((reg >> CRR_REL_SHIFT) & CRR_REL_MASK);
> +}
> +
>  static void m_can_read_fifo(struct net_device *dev, u32 rxfs)
>  {
>  	struct net_device_stats *stats =3D &dev->stats;
> @@ -811,8 +835,16 @@ static int m_can_set_bittiming(struct net_device *=
dev)
>  	sjw =3D bt->sjw - 1;
>  	tseg1 =3D bt->prop_seg + bt->phase_seg1 - 1;
>  	tseg2 =3D bt->phase_seg2 - 1;
> -	reg_btp =3D (brp << BTR_BRP_SHIFT) | (sjw << BTR_SJW_SHIFT) |
> -			(tseg1 << BTR_TSEG1_SHIFT) | (tseg2 << BTR_TSEG2_SHIFT);
> +
> +	if (m_can_read_core_rev(priv) < M_CAN_COREREL_3_1_0)
> +		reg_btp =3D (brp << BTR_BRP_SHIFT) | (sjw << BTR_SJW_SHIFT) |
> +				(tseg1 << BTR_TSEG1_SHIFT) |
> +				(tseg2 << BTR_TSEG2_SHIFT);
> +	else
> +		reg_btp =3D (brp << NBTR_BRP_SHIFT) | (sjw << NBTR_SJW_SHIFT) |
> +				(tseg1 << NBTR_TSEG1_SHIFT) |
> +				(tseg2 << NBTR_TSEG2_SHIFT);
> +
>  	m_can_write(priv, M_CAN_BTP, reg_btp);
> =20
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Nd5GgknBm9BCHxJ2XUaOD5KWnBB4AtbKD--

--87m1t0IE9aK2IU1wb03QmEdCdX7oDeFC1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlirHjkACgkQHv7KIOw4
HPb3kQgAsZ3EzzPWwJ/EfvDw7IRjm5Qiwnv2gRzRyXwqf9+CBU59e/AzozsW3G/K
9s6y9HjC3fNhwcmyQ1scdOfp3PSWnLRojwYtYY2sIiOfkSINoC7fc4arIuga15El
R3QQD56tia06psbYX4ILC8VekZ/XnX6UYRzyJKv4+YJLqiRQac/Jma4T7eLLHfGn
yUN6jBp/shWRDZxvVv+z9p4QwqRzd/30O/VQH87JO8HVBWdLB1MfqLD4Wj9tlGiU
O3D63JOwd+OYR0N0wfqO00FbMO44iTDsvMhj7bTdJlHUMlCqsYLAXQIzgaX++UYX
D/+Jjps1gkek6rKadGAOWveSrfKzLw==
=CEcH
-----END PGP SIGNATURE-----

--87m1t0IE9aK2IU1wb03QmEdCdX7oDeFC1--
