From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single
 CAN frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 11:50:15 +0200
Message-ID: <55191C57.7060906@pengutronix.de>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="C346D0uG5VBuDK9X45fVuMikDnoVL6WIl"
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60179 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242AbbC3JuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 05:50:22 -0400
In-Reply-To: <1427652564-32181-2-git-send-email-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--C346D0uG5VBuDK9X45fVuMikDnoVL6WIl
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/29/2015 08:09 PM, Oliver Hartkopp wrote:
> The CAN_RAW socket can set multiple CAN identifier specific filters tha=
t lead
> to multiple filters in the af_can.c filter processing. These filters ar=
e
> indenpendent from each other which leads to logical OR'ed filters when =
applied.
>=20
> This patch makes sure that every CAN frame which is filtered for a spec=
ific
> socket is only delivered once to the user space. This is independent fr=
om the
> number of matching CAN filters of this socket.
>=20
> As the can_raw() function is executed from NET_RX softirq the introduce=
d
> variables are implemented as per-CPU variables to avoid extensive locki=
ng at
> CAN frame reception time.
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> ---
>  net/can/raw.c | 28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
>=20
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 00c13ef..866a9b3 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -86,6 +86,8 @@ struct raw_sock {
>  	struct can_filter dfilter; /* default/single filter */
>  	struct can_filter *filter; /* pointer to filter(s) */
>  	can_err_mask_t err_mask;
> +	struct sk_buff __percpu **uniq_skb;
> +	ktime_t __percpu *uniq_tstamp;

What about creating a struct to hold the ktime_t and the skb? BTW: the
pointer to the skb can be marked as const.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--C346D0uG5VBuDK9X45fVuMikDnoVL6WIl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVGRxaAAoJECte4hHFiupUqxkP/3bKuvcRsBuCSZd/FMghf+/a
XjNNJZ+ROpNPErS6CnvtSNeT1BQNfgnbSIR8TK5CpIUQyU6X+t1E25vtAlyFv7VO
ch/ZIrHabkwb57rZeEAZpTk/wNaCKD5BHFQ6cUNUkLCbXStVZNZt1Vqbc1e8mcyT
8x7E/C4GxvO6fXhxj/Fgb/298gdoEkLw03ctm8fIblEO1H0z7wE0XBnwKBoQfhnS
qOU+Ssj9HJylTNwh5dsS14jMkHDjxFh+pcTmbXMhAplmv4zzvlGrfx/eA+NuvKDC
DeYMOek5wdlueyUfJK9X+AdT+H18pKDdxzDArHPIeQDDtgbMT4EQA/ysSqVIeVoX
ghRZIUOz/OBjDZtrOIaEKlEQBXb4C9Elp/uFA5GMdFYb6SXNE60ePfDpqPP+8fuU
nRiPKCwDxgI/YXIBdx7M/CluPPjHh8YHIucD8KeKefs2+IDAyygu0H6ahbQjiTsB
CefCinmyxcJRVgIxLC5suXUzJpP35KWfVocIIWfRINpIrxYlkFUXMAZCFoOEEeGy
Itoq204Dcu3x5fopyNbD4T2CZSMFHhcZGrrhwpWk87OPmPduzpsVy3eoaCx1fiSy
7s/5vyBcabCtln+umSvs80vEtT8X0ORJB9M7S4F9wKmZxb9iCowPzqcjlsZVFc0Q
tIxQjRb01945UQBv+/pU
=Z9tj
-----END PGP SIGNATURE-----

--C346D0uG5VBuDK9X45fVuMikDnoVL6WIl--
