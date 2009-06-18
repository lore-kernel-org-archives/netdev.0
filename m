From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink: make netns aware
Date: Thu, 18 Jun 2009 04:16:28 +0200
Message-ID: <1245291388.31588.80.camel@johannes.local>
References: <1245267218.31588.41.camel@johannes.local>
	 <4A39A22C.6080005@hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-wDLtXBvugODIZutx+1M0"
Cc: Netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52636 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030AbZFRCQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:16:56 -0400
In-Reply-To: <4A39A22C.6080005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wDLtXBvugODIZutx+1M0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-17 at 22:10 -0400, Brian Haley wrote:
> Johannes Berg wrote:
> > This makes generic netlink network namespace aware.
> > No actual generic netlink families are made namespace
> > aware, they need to be checked one by one and then
> > set the family->netnsok member to true.
> >=20
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ...
> > --- wireless-testing.orig/include/net/net_namespace.h	2009-06-17 20:36:=
59.000000000 +0200
> > +++ wireless-testing/include/net/net_namespace.h	2009-06-17 21:05:52.00=
0000000 +0200
> > @@ -26,6 +26,7 @@ struct net_device;
> >  struct sock;
> >  struct ctl_table_header;
> >  struct net_generic;
> > +struct sock;
> > =20
> >  struct net {
> >  	atomic_t		count;		/* To decided when the network
> > @@ -63,6 +64,7 @@ struct net {
> >  	struct netns_packet	packet;
> >  	struct netns_unix	unx;
> >  	struct netns_ipv4	ipv4;
> > +	struct sock		*genl_sock;
> >  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> >  	struct netns_ipv6	ipv6;
> >  #endif
>=20
> Maybe you want to move *genl_sock up near the *rtnl sock?  Just seemed
> strange to be stuck in the middle here to me.

Heh I dunno, doesn't matter to me. I just didn't want to stick it at the
end because I'd stuck wext there.

> > @@ -429,6 +450,10 @@ static int genl_rcv_msg(struct sk_buff *
> >  	if (family =3D=3D NULL)
> >  		return -ENOENT;
> > =20
> > +	/* this family doesn't exist in this netns */
> > +	if (!family->netnsok && net !=3D &init_net)
> > +		return -ENOENT;
>=20
> I know there's a net_eq() inline that exists, and actually becomes a no-o=
p
> when namespaces aren't built-in, so it might be worthwhile to change it
> throughout, even if the rest of networking isn't consistent in using it.

Good catch.

johannes

--=-wDLtXBvugODIZutx+1M0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOaN3AAoJEODzc/N7+QmaqK0QAMvlWY/78C6zlBM/ryuJn+ze
bipyeO7pJ23hvCHmre5TuUXm39fudOMG0LZJgnGV6u/tRrjlI0Nnutg6l0AhUXQ/
mM0xFpMJe7YcTWXGZSGUYgO7qv/gMYkIX7pJRGQFW+pqAvpCR89gglXO0Jvdj/GX
dDVnQxrGeFZsKSiIgONXZ99VnaDwVU/sckLJtsVWNGanDp7wL+mpU4PgkyKiEkuP
LkNOAxI8qONQ3nPO9KA3cC4sZBoNkaCyHsoMfFkZQfNwOKOkrI5iEEI/kGmUCm4N
lNdy8JmNdNXUy+oVsbu+IFvLXkFFRek+56WY+IylWRYd5CDcY3W+R5l8cqfFiYzf
CYj1FfHhG3HYjS3txu3OEaOzAWYFv92T3VKLwCV1rpacKUjZ6oRKq4TdGtjd6pQW
4p0ORqBj320a7ZhGUCpxqImAKi2IBQB+9FinlIYf5vNRLocTNU/BrWAWyXtQr/py
7gRqrk+ULfvRRZB2fFp6zwNQ/NNAWfYA41juOofb8oEbpVWCBCjSs1ctEA/bV7Pv
fzlEFfDrMwculJApNszPoTigW7b41dQcOBuW2N1T7ig3s+arForwXtOR14ZKnTHP
/HB5f1N4p2S778vMzBylWsnTjP6AuvabIUv5I9SbxOy5h8QmBxOcLCJZ/ObtMo2n
IZzJFLUDF1DeMtthUfig
=kFVy
-----END PGP SIGNATURE-----

--=-wDLtXBvugODIZutx+1M0--

