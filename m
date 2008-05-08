From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Thu, 08 May 2008 11:00:30 +0200
Message-ID: <1210237230.3547.35.camel@johannes.berg>
References: <20080507130548.GA26977@gondor.apana.org.au>
	 <200805071548.06693.mb@bu3sch.de>
	 <20080508032208.GA401@gondor.apana.org.au>
	 <20080507.202606.242037993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Un9wz/dxjpXOKf97hvmx"
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080507.202606.242037993.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-Un9wz/dxjpXOKf97hvmx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-05-07 at 20:26 -0700, David Miller wrote:

> > You're supposed to stop the queue before the ring overflows.
>=20
> Right, and this is why drivers choose a TX wakeup threshold such
> that they can accept an arbitrarily sized TSO frame.
>=20
> For example, from drivers/net/tg3.c's ->hard_start_xmit():
>=20
> 	if (unlikely(tg3_tx_avail(tp) <=3D (MAX_SKB_FRAGS + 1))) {
> 		netif_stop_queue(dev);
> 		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
> 			netif_wake_queue(tp->dev);
> 	}
>=20
> The driver is responsible for stopping the queue _before_ it
> enters a state where there is not enough space in the queue
> to accept a packet.

Yes yes yes I know :) It's just quite awkward to handle when your
hard_start_xmit() actually increases the number of packets, you don't
really know how deep the queue is etc. I'll add an assertion like that
to mac80211 for the non-fragmented case and clean up the fragmented case
to retry by itself without upper layer involvement after the tx->cb
patch.

johannes

--=-Un9wz/dxjpXOKf97hvmx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCLBLaVg1VMiehFYAQIrSxAAsLTLB0w33ETzgW9RDm36f34scQnMa+of
OG5fL0atoZ97vX7ajxB+FPopAKMuL+301Phsn2JcrodoU8XmqgZ2VjxuZ9Zh6hw2
q16QuvPiaucjOoZg1yR5qAwBl+nImagZZl6eHDXyscfX4FdVXti8tIqyNBUUx0tc
nc5cTX/S8+ZrbLXn7Huo3PqYySSO+aQeAXoaK7TFe6TFDjp9ZstuZySwYm4ybBJd
SLeYS7HivTt+Yx38tgwk5kga28ITy27ZART8SjwV0PbNSO07ECJF5VOq3G4msFCS
Q4U9L5DvIb+KOLnueZGiB+Zc25f0ThlDM+7SiaJ49fb2cCBI71xEBSFf96b4FbEK
yZFsaE7Y9w47Np/73bObC9memh4gIydsgi+vb2HhyN0ggz/8pbq+ADCN8GDTJWFn
myvjqT8FN0hi3sjKADDXLOhfyCPeS5Vlayub0dvKPw8EaxTs+gRWjkA/QNWfARK2
ybsj4GCfG8Pi8/KBp4NfIT2sneFxpDW3mh511rfTXbm9+HH600oP7+kvwDDpc+kc
TVh2u9TnJ2663MO9UtMLD1XC8qQl0mKuOP8QHE2n3+JwxSVMsK64+GxyTQnzmlYl
doKxb04kabG+sf8rFbmlCyHw+A17Y0Oq1VZ991YjnNemSD2VnZZ36cgVMeUS4Gax
7jb3beGn5gc=
=CihV
-----END PGP SIGNATURE-----

--=-Un9wz/dxjpXOKf97hvmx--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
