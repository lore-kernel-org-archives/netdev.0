From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 2/4] can: kvaser_usb: Update error counters before
 exiting on OOM
Date: Fri, 16 Jan 2015 15:39:47 +0100
Message-ID: <54B922B3.1020608@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150111200544.GA8855@linux> <20150111201116.GB8855@linux> <20150111201519.GC8855@linux> <54B3AB6C.8020900@pengutronix.de> <20150112203650.GA11355@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="AtBsdgaKw3vtg7qVq5JfCQrtTMfNTEMTq"
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, andri.yngvason@marel.com
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150112203650.GA11355@linux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--AtBsdgaKw3vtg7qVq5JfCQrtTMfNTEMTq
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/12/2015 09:36 PM, Ahmed S. Darwish wrote:
> On Mon, Jan 12, 2015 at 12:09:32PM +0100, Marc Kleine-Budde wrote:
>> On 01/11/2015 09:15 PM, Ahmed S. Darwish wrote:
>>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>>
>>> Let the error counters be more accurate in case of Out of
>>> Memory conditions.
>>
>> Please have a look at kvaser_usb_rx_error(), the whole state handling =
is
>> omitted in case of OOM.
>>
>=20
> I see. Regarding kvaser_usb_rx_error(), would something like
> below patch be acceptable?=20
>=20
> Kindly note that separating recording interface state from
> error frame packet building leads to duplication of a good
> number of if-conditions. Meanwhile, it truly saves _all_
> of the possible state before any ENOMEM -- the correct thing
> to do.
>=20
> Another solution was to allocate the can frame on the stack,
> and thus avoiding any code duplication. But this only leads
> to calls of "kvaser_usb_simple_msg_async", which can fail
> with -ENOMEM by itself, returning to the very same problem
> again.=20
>=20
> If the patch is acceptable, I'll rebase my USBCAN-II driver
> above it and re-submit the series (minus the merged patch).

Looks good from my point of view, stats and state are handled
independent of the error skb.

Andri can you have a look at the state handling itself?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--AtBsdgaKw3vtg7qVq5JfCQrtTMfNTEMTq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUuSK7AAoJECte4hHFiupUfZYP/jM0kuSDBei+yQ+A0iYf8hem
2B/djBXZwzUlKLSLzrkMgMrMKYXT3PShMFCCSFDLENl9kartGkMPwUES2mEEPvlM
P1/3I8ZBKxFuuy6Gbxpt7su821C5IunkBgRiYHbrdRp4icn8x2h81OwewbZvvykj
PXyytegJcGEAqgtuDdjzqWWtWXx4D58IlgnoViFiTy2bueY9valO4Cr1ooYtSH7U
ldTplZ62kWfToA3b1k6ub/NjfVmZCTu7ENfGx4spWi1BS4R1j3F2vu+VpAasvF2+
9V9ZAtq0rCkAuKl90MdoA0o1qa7c7w92DXhYLdDaXej6+XUQBALBiWLNNAvIbKpL
SVQN0qLkC+Y6O0C1YOja8ZmQkQe1Pb4A6wIvITXm96b9M9dayUEts/dRmh+Z1kco
nuTUsOwFV6DvGzKO831pNCQYpngP26czHyzT3rt7qiEe+CTGgkH50aTQPbcJFWrn
B6oIovcBrFWGz9DZoSqEf9KYacjLkkRsgn+7pQA6wZmayK2fhMQvnjNCvTnhQkqd
dVXWShFLqXHMUO6hn4t6L6j278K73l+/9XyB+nMALCA8HyQQf0bUFU1d4uzs608B
YqtF61P3lAIIcxA51MckfOdfE3vuGmTv9UnsLLEcS3OZ/XjyFKSV1uyMpZbgGV67
IWmhPnKnuWoIscrc2G91
=Dtwe
-----END PGP SIGNATURE-----

--AtBsdgaKw3vtg7qVq5JfCQrtTMfNTEMTq--
