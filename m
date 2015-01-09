From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 4/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Fri, 09 Jan 2015 15:05:49 +0100
Message-ID: <54AFE03D.5040509@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150105174910.GA6304@linux> <20150105175206.GB6304@linux> <20150105175713.GC6304@linux> <20150105183131.GD6304@linux> <54AE6FC1.6050007@pengutronix.de> <20150109030657.GA1791@vivalin-002>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KF4kD39KBoUua5OAQf1OMwpNjnjsVE3c2"
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150109030657.GA1791@vivalin-002>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KF4kD39KBoUua5OAQf1OMwpNjnjsVE3c2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/09/2015 04:06 AM, Ahmed S. Darwish wrote:
>>>
>>> 		cf->can_id |=3D CAN_ERR_CRTL;
>>> 		cf->data[1] =3D CAN_ERR_CRTL_RX_OVERFLOW;
>>>
>>> 		stats->rx_over_errors++;
>>> 		stats->rx_errors++;
>>>
>>> 		netif_rx(skb);
>>>
>>> 		stats->rx_packets++;
>>> 		stats->rx_bytes +=3D cf->can_dlc;
>>
>> Another patch would be not to touch cf after netif_rx(), please
>> move the stats handling before calling netif_rx(). Same applies to
>> the kvaser_usb_rx_can_msg() function.

> BTW, is it guaranteed from the SocketCAN stack that netif_rx()

netif_rx() is the generic networking stack already.

> will never return NET_RX_DROPPED? Because if no guarantee
> exists, I guess below fragment cannot be completely correct?

No, it's not guaranteed...

>=20
>         stats->rx_packets++;
>         stats->rx_bytes +=3D cf->can_dlc;
>         netif_rx(skb);
>=20
> On the other hand, I don't see evan a single CAN driver checking
> netif_rx() return value, so maybe such a check is an overkill...

A quick look shows that almost no ethernet or wireless drivers take care
about the return value. In case of a RX_DROPPED some increase a drop
counter, though.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--KF4kD39KBoUua5OAQf1OMwpNjnjsVE3c2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUr+A9AAoJECte4hHFiupUUvIP/RPFuWMts6qYX7knfvztzjjd
Ogow3/KZF5H9lLWgxQh3sYZ+S6p/BMaSkVLACrPCR8VXyI/uDiSrtsrBkh6T2fk0
aHu7bxU6UAeBk1cgtMMu3EJZ8aFmLw1r0gi9WQ3TFE68JlFqUQQ63MRVvsEJfMgx
bWHdIIv9maalC01eEmRtfYHonBJuUJw3zahfbJStHxlgTBjdyG/48tDk4y9jPbCh
b4Hv+VekDE+tQ58BB7+oTeCoYWfogpTMtu/N+43o2LGwGleW2UQPt8rCC7/wovJW
Pm4uqpL0kO4B9lpoeLirXxEGhq5m536uqEgWn04obhoTpahRVOWxNUYn2d3wu67L
P2M6PfJc65WNwbdbh+P36rcmuoMSPabVi5gU/a1HZzoy+S00rF9DYmbedDtTdmkL
7vynsNWulwgm9HaAU6Y7w2n7qSpzzV+a7L3TpyCbFHb95LxCtD1a+nAwShPC2+ik
wpHJpxvsS1Ym7hvIRyzpVdVL0P9HO4tEraV1nI1Z5eXUz2czjWJ1c2BmwNirK9Tu
Pj0HAleSUrXAvdSgK3sgtgg01bH6RF1rQPRq0dAPwDdLKBhDm0+UczWeBGvQR9Vt
gEWtsghkXEouFlSudqGUNkRRDMH30n/hyL96pQ1iFh8+KGGI6JnO7tw+mwD8nUL9
wQKIu3jo+dddyBO5RL73
=7GlW
-----END PGP SIGNATURE-----

--KF4kD39KBoUua5OAQf1OMwpNjnjsVE3c2--
