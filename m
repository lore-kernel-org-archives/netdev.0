From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 27 Apr 2011 15:21:56 +0200
Message-ID: <4DB81874.1060904@pengutronix.de>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>	<1303474267-6344-2-git-send-email-subhasish@mistralsolutions.com>
	<4DB1A3B7.7060300@pengutronix.de> <4DB5D452.9050500@grandegger.com>
	<46D523E49EFF489F9B088AE7B9CD7286@subhasishg>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0746241567975700610=="
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, m-watkins-l0cyMroinI0@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <46D523E49EFF489F9B088AE7B9CD7286@subhasishg>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============0746241567975700610==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig457819A39003E5994EC492FA"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig457819A39003E5994EC492FA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/27/2011 03:08 PM, Subhasish Ghosh wrote:

>>>> +static u32 pruss_intc_init[19][3] =3D {
>>>> + {PRUSS_INTC_POLARITY0, PRU_INTC_REGMAP_MASK, 0xFFFFFFFF},
>>>> + {PRUSS_INTC_POLARITY1, PRU_INTC_REGMAP_MASK, 0xFFFFFFFF},
>>>> + {PRUSS_INTC_TYPE0, PRU_INTC_REGMAP_MASK, 0x1C000000},
>>>> + {PRUSS_INTC_TYPE1, PRU_INTC_REGMAP_MASK, 0},
>>>> + {PRUSS_INTC_GLBLEN, 0, 1},
>>>> + {PRUSS_INTC_HOSTMAP0, PRU_INTC_REGMAP_MASK, 0x03020100},
>>>> + {PRUSS_INTC_HOSTMAP1, PRU_INTC_REGMAP_MASK, 0x07060504},
>>>> + {PRUSS_INTC_HOSTMAP2, PRU_INTC_REGMAP_MASK, 0x0000908},
>>>> + {PRUSS_INTC_CHANMAP0, PRU_INTC_REGMAP_MASK, 0},
>>>> + {PRUSS_INTC_CHANMAP8, PRU_INTC_REGMAP_MASK, 0x00020200},
>>>> + {PRUSS_INTC_STATIDXCLR, 0, 32},
>>>> + {PRUSS_INTC_STATIDXCLR, 0, 19},
>>>> + {PRUSS_INTC_ENIDXSET, 0, 19},
>>>> + {PRUSS_INTC_STATIDXCLR, 0, 18},
>>>> + {PRUSS_INTC_ENIDXSET, 0, 18},
>>>> + {PRUSS_INTC_STATIDXCLR, 0, 34},
>>>> + {PRUSS_INTC_ENIDXSET, 0, 34},
>>>> + {PRUSS_INTC_ENIDXSET, 0, 32},
>>>> + {PRUSS_INTC_HOSTINTEN, 0, 5}
>>>
>>> please add ","
>>
>> Also a struct to describe each entry would improve readability.
>> Then you could also use ARRAY_SIZE.
>=20
> SG _ I could not follow this, are you recommending that I create a
> structure with three variables and then create
>            an array for it.
> something like:
>=20
> const static struct [] =3D {
>    {
>    unsigned int reg_base;
>    unsigned int reg_mask;
>    unsigned int reg_val;
>    },
> ...
> };

I think this isn't valid C. It should look like this:

struct pruss_intc_init {
	unsigned long reg_base;
	u32 reg_mask;
	u32 reg+val;
};

static const struct pruss_intc_init pruss_initc_init[] =3D {
	{ .reg_base =3D 0xdeadbeef, .reg_mask =3D 0xaa, .reg_val =3D 0x55 },
	...
};

I'm not sure about the datatype of reg_base. I haven't looked at the
code that uses this array.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig457819A39003E5994EC492FA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk24GHcACgkQjTAFq1RaXHNamACeIPjcWMJsbNRFgTpwVzPVrdnW
OcsAoIrkJR0hCIzse0P53HXDqmq13Ddc
=gr7V
-----END PGP SIGNATURE-----

--------------enig457819A39003E5994EC492FA--

--===============0746241567975700610==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0746241567975700610==--
