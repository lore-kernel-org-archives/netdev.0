From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCHv2 net-next 2/2] sunvnet: Use one Tx queue per vnet_port
Date: Thu, 06 Nov 2014 16:32:44 +0000
Message-ID: <1415291564.3398.66.camel@decadent.org.uk>
References: <20141030164609.GG650@oracle.com>
	 <1415290773.3398.61.camel@decadent.org.uk>
	 <20141106162822.GL15665@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tZf4U9F1Er/c/7AURwK4"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60431 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751594AbaKFQc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:32:58 -0500
In-Reply-To: <20141106162822.GL15665@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tZf4U9F1Er/c/7AURwK4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-06 at 11:28 -0500, Sowmini Varadhan wrote:
> On (11/06/14 16:19), Ben Hutchings wrote:
> > > +	txq =3D netdev_get_tx_queue(port->vp->dev, port->q_index);
> > > +	__netif_tx_lock(txq, smp_processor_id());
> > > +	if (likely(netif_tx_queue_stopped(txq))) {
> > > +		struct vio_dring_state *dr;
> > > +
> > > +		dr =3D &port->vio.drings[VIO_DRIVER_TX_RING];
> >=20
> > You seem to have dropped the condition for the netif_tx_wake_queue(),
> > which I would guess based on the old code should be:
> >=20
> > 		if (vnet_tx_dring_avail(dr) >=3D VNET_TX_WAKEUP_THRESH(dr))
> >=20
> > > +			netif_tx_wake_queue(txq);
>=20
> yes, this was deliberate.
>=20
> As I indicated in the comments:
>=20
> /* Got back a STOPPED LDC message on port. If the queue is stopped,
>  * wake it up so that we'll send out another START message at the
>  * next TX.
>  */
>=20
> We only call maybe_tx_wakeup() if the peer has sent us a STOPPED
> ack (meaning that the peer is no longer reading the descriptor rings).
> So if our tx queue is full and stopped, we need to poke the peer
> on the next TX with a start message. (otherwise we'd never wake up!)

OK, then the indentation of the following line is wrong.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-tZf4U9F1Er/c/7AURwK4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVFuisOe/yOyVhhEJAQqr4g//dHZKFo7hoqALcA7HWeiD39uKdE1h9mvr
p+YtTvH61AYY3WJ+zj+qh2J8X4rIvLBceXnz+E+9PyEkCr3TDCvqoQbfrkXfcbC8
DRe8z8TOzesa4lqXBouvsMhrIPoFVxdjhMmYySMZZhDWyXxH/g6XzmNo8cvbxw2t
qthN2KlRV3coI5+AgpBvBTs/htfAoW/KbjLkqPySSLc8OPV0d/PQ9/MU2bnO9W1X
ovFg60cik9sGe/vOGj76+n4ZUPwBtQ06Ek3MFOFZsf6oGkJzSfa/bTPjFHybHtjA
DtRl2kqEAjOysWPS1LOL1maa/Q3xL+yVn2IydJKAGDpoX2WL9GCRkCMfRZu8QzDh
/Ljq7pVLOVBVhAOBd4qRDwg5eenp6vasW0B8V80n3HEXH6bjw8twPfcbgWxh/01Q
Ueuf3N365I+yrAZQ4ynbawblPLYsGLDFEC1R447QkIfLhkwZWqz1ZA5zoGq5eb+c
YSGdQvNLwf0nH+3hstJ1V+ORLy3fds6jHl8UuSAhziwjkb6N0+iSRzj9lg+NI8pU
qExtGBNBDStVsPXGfocDv+tnEnFlp171dm6XSu84xX/frvzG+bdd2Ac318FIzS5l
joHryTrGSlvog8O2Ke1YHa8COuO0NwZ70DNvNXELmOWpe27MQj4a4dFGSJzc5htZ
D53OSlzAIMQ=
=WrWQ
-----END PGP SIGNATURE-----

--=-tZf4U9F1Er/c/7AURwK4--
