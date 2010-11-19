From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3] can: Topcliff: PCH_CAN driver: Add Flow
	control,
Date: Fri, 19 Nov 2010 10:20:39 +0100
Message-ID: <4CE64167.2030405@pengutronix.de>
References: <4CE2434B.5050701@dsn.okisemi.com>	<4CE27796.2000206@pengutronix.de>
	<007401cb87b1$a773b3d0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8038944472932531440=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <007401cb87b1$a773b3d0$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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
--===============8038944472932531440==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig481C658EA4710B7EF4A365C4"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig481C658EA4710B7EF4A365C4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/19/2010 07:18 AM, Tomoya MORINAGA wrote:
> On Tuesday, November 16, 2010 9:22 PM, Marc Kleine-Budde wrote :
>=20
> Except the following, I have updated/resubmitted already .
>=20
>>>  static int pch_can_rx_poll(struct napi_struct *napi, int quota)
>>>  {
>>>   struct net_device *ndev =3D napi->dev;
>>>   struct pch_can_priv *priv =3D netdev_priv(ndev);
>>> - struct net_device_stats *stats =3D &(priv->ndev->stats);
>>> - u32 dlc;
>>>   u32 int_stat;
>>>   int rcv_pkts =3D 0;
>                     ^^^^
>> can be removed...if you remove the +=3D below
> Since there is "goto" code, "=3D0" is better.

The compiler would complain, if there's an unused variable.

>>> - spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>>> + pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
>> Still we have the busy waiting in the TX path. Maybe you can move the
>> waiting before accessing the if[1] and remove the busy waiting here.
> I can't understand your saying.
> For transmitting data, calling pch_can_rw_msg_obj is mandatory.

Yes, but the busy wait is not needed. It should be enough to do the
busy-waiting _before_ accessing the if[1].

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig481C658EA4710B7EF4A365C4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzmQWsACgkQjTAFq1RaXHPkwwCfdeoXbCQXNSFKlyoVdbVS88NR
psYAnA1lODl3wx4Au1rUCythjd8CYMBU
=9P+L
-----END PGP SIGNATURE-----

--------------enig481C658EA4710B7EF4A365C4--

--===============8038944472932531440==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8038944472932531440==--
