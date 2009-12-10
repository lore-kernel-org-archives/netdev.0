From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v3] add the driver for Analog Devices Blackfin on-chip
	CAN controllers
Date: Thu, 10 Dec 2009 11:21:45 +0100
Message-ID: <20091210102145.GA3097@pengutronix.de>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com>
	<4B20BB36.50509@grandegger.com>
	<3c17e3570912100214k4b3eb038u1108c82bfa346389@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1395840974=="
Cc: "H.J. Oertel" <oe-pJ9TYRvN+WE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <3c17e3570912100214k4b3eb038u1108c82bfa346389-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============1395840974==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
Content-Disposition: inline


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> >> + =A0 =A0 if (status) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 priv->can.can_stats.bus_error++;
> >> +
> >> + =A0 =A0 =A0 =A0 =A0 =A0 cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSER=
ROR;
> >> +
> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (status & BEF)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cf->data[2] |=3D CAN_ERR_PRO=
T_BIT;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 else if (status & FER)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cf->data[2] |=3D CAN_ERR_PRO=
T_FORM;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 else if (status & SER)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cf->data[2] |=3D CAN_ERR_PRO=
T_STUFF;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 else
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cf->data[2] |=3D CAN_ERR_PRO=
T_UNSPEC;
> >> + =A0 =A0 }
> >
> > Add {} here as well.
> {} will cause checkpatch warning if it is given to only one line.

Right, no need for braces here, because it is always one statement after
if/else.


> >> + =A0 =A0 if ((irq =3D=3D priv->tx_irq) && readw(&reg->mbtif2)) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 /* transmission complete interrupt */
> >> + =A0 =A0 =A0 =A0 =A0 =A0 writew(0xFFFF, &reg->mbtif2);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_packets++;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_bytes +=3D bfin_can_read_dlc(priv,=
 TRANSMIT_CHL);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 can_get_echo_skb(dev, 0);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(dev);
> >> + =A0 =A0 } else if ((irq =3D=3D priv->rx_irq) && readw(&reg->mbrif1))=
 {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 /* receive interrupt */
> >> + =A0 =A0 =A0 =A0 =A0 =A0 isrc =3D readw(&reg->mbrif1);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 writew(0xFFFF, &reg->mbrif1);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 bfin_can_rx(dev, isrc);
> >> + =A0 =A0 } else if ((irq =3D=3D priv->err_irq) && readw(&reg->gis)) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 /* error interrupt */
> >> + =A0 =A0 =A0 =A0 =A0 =A0 isrc =3D readw(&reg->gis);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 status =3D readw(&reg->esr);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 writew(0x7FF, &reg->gis);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 bfin_can_err(dev, isrc, status);
> >> + =A0 =A0 } else
> >> + =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_NONE;
> >
> > Use {} here as well.
> {} will cause checkpatch warning if it is given to only one line.

Then again, here braces are suggested. If the 'if'-block has braces, the
'else'-block should have braces, too. If checkpatch really complains about =
it,
this is a bug in checkpatch.

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksgy7kACgkQD27XaX1/VRuNlwCgsSRFNBn9ZOhqnQrNuO8T+jGD
0IcAnj31td4yugsGcccmKyPPkNTogzGt
=u741
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--

--===============1395840974==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1395840974==--
