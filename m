From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] irda: Convert function pointer arrays and uses to const
Date: Wed, 10 Dec 2014 19:32:59 +0000
Message-ID: <3333024A-D21C-41E2-80ED-7590CE6E9BD1@intel.com>
References: <1418236138.18092.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_86845D3D-172B-4286-B9E8-16D4A7BF3A4A";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7739 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376AbaLJTdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 14:33:38 -0500
In-Reply-To: <1418236138.18092.13.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_86845D3D-172B-4286-B9E8-16D4A7BF3A4A
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1

On Dec 10, 2014, at 10:28 AM, Joe Perches <joe@perches.com> wrote:

> Making things const is a good thing.
>=20
> (x86-64 defconfig with all irda)
> $ size net/irda/built-in.o*
>   text	   data	    bss	    dec	    hex	filename
> 109276	   1868	    244	 111388	  1b31c	net/irda/built-in.o.new
> 108828	   2316	    244	 111388	  1b31c	net/irda/built-in.o.old
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> include/net/irda/parameters.h  | 6 +++---
> net/irda/ircomm/ircomm_param.c | 8 ++++----
> net/irda/irttp.c               | 6 ++++--
> net/irda/parameters.c          | 8 ++++----
> net/irda/qos.c                 | 6 +++---
> 5 files changed, 18 insertions(+), 16 deletions(-)
>=20
> diff --git a/include/net/irda/parameters.h =
b/include/net/irda/parameters.h
> index 42713c9..2d9cd00 100644
> --- a/include/net/irda/parameters.h
> +++ b/include/net/irda/parameters.h
> @@ -71,17 +71,17 @@ typedef int (*PV_HANDLER)(void *self, __u8 *buf, =
int len, __u8 pi,
> 			  PV_TYPE type, PI_HANDLER func);
>=20
> typedef struct {
> -	PI_HANDLER func;  /* Handler for this parameter identifier */
> +	const PI_HANDLER func;  /* Handler for this parameter identifier =
*/
> 	PV_TYPE    type;  /* Data type for this parameter */
> } pi_minor_info_t;
>=20
> typedef struct {
> -	pi_minor_info_t *pi_minor_call_table;
> +	const pi_minor_info_t *pi_minor_call_table;

Might you want to go a little further and make it:
	const pi_minor_into_t * const pi_minor_call_table;
so that the pointer itself is also constant? That could apply to some =
others below as well.

> 	int len;
> } pi_major_info_t;
>=20
> typedef struct {
> -	pi_major_info_t *tables;
> +	const pi_major_info_t *tables;
> 	int              len;
> 	__u8             pi_mask;
> 	int              pi_major_offset;
> diff --git a/net/irda/ircomm/ircomm_param.c =
b/net/irda/ircomm/ircomm_param.c
> index 27be782..3c4caa6 100644
> --- a/net/irda/ircomm/ircomm_param.c
> +++ b/net/irda/ircomm/ircomm_param.c
> @@ -61,12 +61,12 @@ static int ircomm_param_dte(void *instance, =
irda_param_t *param, int get);
> static int ircomm_param_dce(void *instance, irda_param_t *param, int =
get);
> static int ircomm_param_poll(void *instance, irda_param_t *param, int =
get);
>=20
> -static pi_minor_info_t pi_minor_call_table_common[] =3D {
> +static const pi_minor_info_t pi_minor_call_table_common[] =3D {
> 	{ ircomm_param_service_type, PV_INT_8_BITS },
> 	{ ircomm_param_port_type,    PV_INT_8_BITS },
> 	{ ircomm_param_port_name,    PV_STRING }
> };
> -static pi_minor_info_t pi_minor_call_table_non_raw[] =3D {
> +static const pi_minor_info_t pi_minor_call_table_non_raw[] =3D {
> 	{ ircomm_param_data_rate,    PV_INT_32_BITS | PV_BIG_ENDIAN },
> 	{ ircomm_param_data_format,  PV_INT_8_BITS },
> 	{ ircomm_param_flow_control, PV_INT_8_BITS },
> @@ -74,13 +74,13 @@ static pi_minor_info_t =
pi_minor_call_table_non_raw[] =3D {
> 	{ ircomm_param_enq_ack,      PV_INT_16_BITS },
> 	{ ircomm_param_line_status,  PV_INT_8_BITS }
> };
> -static pi_minor_info_t pi_minor_call_table_9_wire[] =3D {
> +static const pi_minor_info_t pi_minor_call_table_9_wire[] =3D {
> 	{ ircomm_param_dte,          PV_INT_8_BITS },
> 	{ ircomm_param_dce,          PV_INT_8_BITS },
> 	{ ircomm_param_poll,         PV_NO_VALUE },
> };
>=20
> -static pi_major_info_t pi_major_call_table[] =3D {
> +static const pi_major_info_t pi_major_call_table[] =3D {
> 	{ pi_minor_call_table_common,  3 },
> 	{ pi_minor_call_table_non_raw, 6 },
> 	{ pi_minor_call_table_9_wire,  3 }
> diff --git a/net/irda/irttp.c b/net/irda/irttp.c
> index 3ef0b08..b6ab41d 100644
> --- a/net/irda/irttp.c
> +++ b/net/irda/irttp.c
> @@ -71,11 +71,13 @@ static void irttp_status_indication(void =
*instance,
> 				    LINK_STATUS link, LOCK_STATUS lock);
>=20
> /* Information for parsing parameters in IrTTP */
> -static pi_minor_info_t pi_minor_call_table[] =3D {
> +static const pi_minor_info_t pi_minor_call_table[] =3D {
> 	{ NULL, 0 },                                             /* 0x00 =
*/
> 	{ irttp_param_max_sdu_size, PV_INTEGER | PV_BIG_ENDIAN } /* 0x01 =
*/
> };
> -static pi_major_info_t pi_major_call_table[] =3D { { =
pi_minor_call_table, 2 } };
> +static const pi_major_info_t pi_major_call_table[] =3D {
> +	{ pi_minor_call_table, 2 }
> +};
> static pi_param_info_t param_info =3D { pi_major_call_table, 1, 0x0f, =
4 };
>=20
> /************************ GLOBAL PROCEDURES ************************/
> diff --git a/net/irda/parameters.c b/net/irda/parameters.c
> index 006786b..16ce32f 100644
> --- a/net/irda/parameters.c
> +++ b/net/irda/parameters.c
> @@ -52,7 +52,7 @@ static int irda_insert_no_value(void *self, __u8 =
*buf, int len, __u8 pi,
> static int irda_param_unpack(__u8 *buf, char *fmt, ...);
>=20
> /* Parameter value call table. Must match PV_TYPE */
> -static PV_HANDLER pv_extract_table[] =3D {
> +static const PV_HANDLER pv_extract_table[] =3D {
> 	irda_extract_integer, /* Handler for any length integers */
> 	irda_extract_integer, /* Handler for 8  bits integers */
> 	irda_extract_integer, /* Handler for 16 bits integers */
> @@ -62,7 +62,7 @@ static PV_HANDLER pv_extract_table[] =3D {
> 	irda_extract_no_value /* Handler for no value parameters */
> };
>=20
> -static PV_HANDLER pv_insert_table[] =3D {
> +static const PV_HANDLER pv_insert_table[] =3D {
> 	irda_insert_integer, /* Handler for any length integers */
> 	irda_insert_integer, /* Handler for 8  bits integers */
> 	irda_insert_integer, /* Handler for 16 bits integers */
> @@ -449,7 +449,7 @@ static int irda_param_unpack(__u8 *buf, char *fmt, =
...)
> int irda_param_insert(void *self, __u8 pi, __u8 *buf, int len,
> 		      pi_param_info_t *info)
> {
> -	pi_minor_info_t *pi_minor_info;
> +	const pi_minor_info_t *pi_minor_info;
> 	__u8 pi_minor;
> 	__u8 pi_major;
> 	int type;
> @@ -504,7 +504,7 @@ EXPORT_SYMBOL(irda_param_insert);
> static int irda_param_extract(void *self, __u8 *buf, int len,
> 			      pi_param_info_t *info)
> {
> -	pi_minor_info_t *pi_minor_info;
> +	const pi_minor_info_t *pi_minor_info;
> 	__u8 pi_minor;
> 	__u8 pi_major;
> 	int type;
> diff --git a/net/irda/qos.c b/net/irda/qos.c
> index 5ed6c9a..25ba850 100644
> --- a/net/irda/qos.c
> +++ b/net/irda/qos.c
> @@ -122,7 +122,7 @@ static __u32 max_line_capacities[10][4] =3D {
> 	{ 800000, 400000, 160000, 80000 }, /* 16000000 bps */
> };
>=20
> -static pi_minor_info_t pi_minor_call_table_type_0[] =3D {
> +static const pi_minor_info_t pi_minor_call_table_type_0[] =3D {
> 	{ NULL, 0 },
> /* 01 */{ irlap_param_baud_rate,       PV_INTEGER | PV_LITTLE_ENDIAN =
},
> 	{ NULL, 0 },
> @@ -134,7 +134,7 @@ static pi_minor_info_t =
pi_minor_call_table_type_0[] =3D {
> /* 08 */{ irlap_param_link_disconnect, PV_INT_8_BITS }
> };
>=20
> -static pi_minor_info_t pi_minor_call_table_type_1[] =3D {
> +static const pi_minor_info_t pi_minor_call_table_type_1[] =3D {
> 	{ NULL, 0 },
> 	{ NULL, 0 },
> /* 82 */{ irlap_param_max_turn_time,   PV_INT_8_BITS },
> @@ -144,7 +144,7 @@ static pi_minor_info_t =
pi_minor_call_table_type_1[] =3D {
> /* 86 */{ irlap_param_min_turn_time,   PV_INT_8_BITS },
> };
>=20
> -static pi_major_info_t pi_major_call_table[] =3D {
> +static const pi_major_info_t pi_major_call_table[] =3D {
> 	{ pi_minor_call_table_type_0, 9 },
> 	{ pi_minor_call_table_type_1, 7 },
> };
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_86845D3D-172B-4286-B9E8-16D4A7BF3A4A
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJUiJ/qAAoJEDwO/+eO4+5u8sIP/0I6M09V5FF4ryNSGcWbOHrK
sp/ecu+olhOX0xoRS/NyCDUiReuLnvESba6uDIZKgG/p+mJqb6k55U7TpCiKQrq8
rEUrYXof7C06c5BV5FWdJBn0gCjY7IMYeGlCadlp1Rkh4XKyDac63nH85EsF+Cnf
SncRettJzNYAPNnm/QdaV6bmLmQldEiM5RfkwCTwHiO4h3W9EWH3cGaNlPd2wKQ2
KYMIiuUnNOWMtFXgMIMrj7CAr6WsI3ND6U1bXs7bWyYnFpftOSzf78iy8lBLJY95
VSe79CPdePLdtkJX5UTcHj3W+Mg3425/mOjaWPU3g+b0zvLncvhTNwEH0ZTku1kj
AeJqcY0bKI+g6zVU+BVHJMlubTf9bs2//FPcKIULTwPkR0mj79PnhATS5EWvcGOz
p3CE3OUZW363GldK7I07UZbr7t3pfirvUp0J90V1AMHl2MaXn7sC+CBX29+84nM6
Rv3QBgOtW2z63czd1et4wedZJsjlaC8kxIJjOt+XLxh/QP+sJHZyCNb/uNAqokh5
EF3IeQKAx7sbAMERG4hwN6F6iMn/SIr3BK1jcHRaIbC8/Wgbs+f4ocufIq+CjLlb
yVUTwTFbplQ31FxYqP7/O9d+IbhPhEGQ1DKFE0TPsawQNe6R9TcNuJEEL0R5YFXF
ekRszgwm98V+bbzSn9+E
=RWSQ
-----END PGP SIGNATURE-----

--Apple-Mail=_86845D3D-172B-4286-B9E8-16D4A7BF3A4A--
