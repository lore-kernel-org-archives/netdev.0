From: Martijn van Oosterhout <kleptog@svana.org>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Fri, 24 Sep 2004 04:34:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923183355.GB13753@svana.org>
References: <E1CA4kn-0005jn-00@gondolin.me.apana.org.au> <1095888533.4151ee95ed23c@www.katalix.com>
Reply-To: Martijn van Oosterhout <kleptog@svana.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, bcrl@kvack.org,
        davem@davemloft.net, netdev@oss.sgi.com, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: James Chapman <jchapman@katalix.com>
Content-Disposition: inline
In-Reply-To: <1095888533.4151ee95ed23c@www.katalix.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 22, 2004 at 10:28:53PM +0100, James Chapman wrote:
> Hi Herbert,
>=20
> Quoting Herbert Xu <herbert@gondor.apana.org.au>:
>=20
> > James Chapman <jchapman@katalix.com> wrote:
> > >
> > > The biggest difference in our approaches is that Martijn and I use a
> > > PPPoL2TP socket per session bound through a plain AF_INET UDP tunnel
> > > socket while Ben uses a new AF_L2TP tunnel socket and no separate
> > > socket per session. Both have their merits.
> >
> > Can you elaborate on the merits of having a socket? It would seem to me
> > that not having a socket is a lot more scalable.  After all IPsec doesn=
't
> > carry a socket around per session.
>=20
> What I meant by "both have their merits" is that both general
> approaches have their merits. It's a shame Martijn isn't available
> right now (he's moving home to a new country) as he came up with the
> initial kernel driver concept. Anyway, I'm sure he'll chime in later.

Ok, I've just cut off the power connector of my laptop and whacked a
new one on, so I'm just beginning ot catch up. I'd just like to comment
that the socket-per-connection is part of the kernel generic-PPP
support. The PPP packets not handled by the kernel need to be
transported somewhere and I guess the decision was made to pass it
though a PPPoX socket.

If you want to get away from the one socket per session model, you
can't use PPPoX sockets. You need something in the kernel to hold the
ppp generic data structure. I imagine Ben's uses an array in the kernel
and passes stuff to userspace in a way so the user-space daemon can
identify the session it belongs to.

I don't see why this PPPoX solution won't scale to thousands of
sessions. Sure, you get one socket per session plus one socket per
tunnel, but IRC servers run with thousands of sockets and the costs
here aren't much more. Sure, someone needs to write a PPP daemon that
can handle multiple simultaneous connections, but that's orthoginal to
the issue at hand.

If you want to remove the one socket per session requirement, someone
needs to redo the PPPoX support. In fact, the whole PPPoX idea seems to
have been a bit of a dud since even with it there it seems to be better
to just invent your own character device/protocal family/etc than use
it. When I started I just used the PPPoX stuff since I figured that was
going to be the "supported" way to use the in-kernel PPP stuff.

Also, if Ben's stuff is handling the case of taking seperate L2TP
sessions and merging them through to another LNS server, then it is a
completely orthoginal system, since that doesn't require full PPP
support anyway...

Have a nice day,
--=20
Martijn van Oosterhout   <kleptog@svana.org>   http://svana.org/kleptog/
> Patent. n. Genius is 5% inspiration and 95% perspiration. A patent is a
> tool for doing 5% of the work and then sitting around waiting for someone
> else to do the other 95% so you can sue them.

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQFBUxcTY5Twig3Ge+YRApikAKDZMJAQ26cZmDmcGfIhXr/fZfaf3gCeItzA
tbK+5tvpBzM7zlzy3nJjXI0=
=MlDW
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--
