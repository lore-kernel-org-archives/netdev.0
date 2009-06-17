From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink: make netns aware
Date: Wed, 17 Jun 2009 23:54:53 +0200
Message-ID: <1245275693.31588.55.camel@johannes.local>
References: <1245267218.31588.41.camel@johannes.local>
	 <m18wjqwoca.fsf@fess.ebiederm.org>
	 <1245274620.31588.49.camel@johannes.local>
	 <m1hbyev8d1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-buqM6RE78JsQYrCZXqyP"
Cc: Netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:39561 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbZFQVzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 17:55:22 -0400
In-Reply-To: <m1hbyev8d1.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-buqM6RE78JsQYrCZXqyP
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-17 at 14:49 -0700, Eric W. Biederman wrote:
> Johannes Berg <johannes@sipsolutions.net> writes:
>=20
> > On Wed, 2009-06-17 at 14:19 -0700, Eric W. Biederman wrote:
> >
> >> Nothing at first glance looks wrong.
> >
> > Will review locking :) Not sure I hold enough locks at the correct
> > places here.
>=20
> grr. At first glance NOTHING looks wrong.
> I have a bad habit of skipping the most important word in my sentences
> sometimes.

My autocorrection kicked in and did actually read "nothing looks wrong",
but locking is still wrong :)

> Probably.  As even genetlink has those kinds of users.  The kernel
> receive path is easy now.  Yeah for synchronous processing. It is
> which socket do you transmit on that is interesting.

Indeed. But genlmsg_reply() will automatically reply to the correct
netns now, so no big deal there. Multicast is more interesting, one
thing I may need to figure out is multicasting to _all_ namespaces.
Actually, hmm, let me change the API so that genlmsg_multicast() sends
to all network namespaces, and genmlsg_multicast_ns() sends to just a
specific netns.

I'm thinking that most genl users should enable netns but not do
anything different, so their services can be used regardless of what
netns the tool using them lives in, since many genl services don't
actually care about networking. Those that do, like nl80211, will have
to be updated differently.

johannes

--=-buqM6RE78JsQYrCZXqyP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOWYoAAoJEODzc/N7+Qma56UP/jIZRzgQLqggwcc666BSKX09
V9ixPOJToX6KhWDIZU55fr0nSFRQclval0KGXDZ7GIkGkV7EyKYGmkMGv20DzFeE
60zpQB3LVwCGVQHvK+WqjMGGvD8xFdNk2gsSbuuNE0n7erGWw6zwpJ15x1F3W1jx
BhRK36VOo4+zyynxD6xuQDveBLfR0Vbgbt5VpqQREwWc7hYRadfnOL4FklEjZ/td
lqxRijon6/5I8L8gq9Fm+3UXenEVyktXrLo4lT5z5hwdKGq9XVHRfaSRHFvgi5SL
EpFZ2U1pJF4tQrFGPxdkEcNmdMbW7ZJdxNhstIc3ldQ8piuLqCRYz7I4bYSPZM6y
Nx/Bxlg/TLvLKwJUgGvm+O6TExue6OJ+2lWu0IVKtRLWmEG7jdgU+8GYZEJhmHdB
321NLIv2ox9UbAhoC/tWIAqQZKAVFf5pajoP748zVUFNdE+GVw6VETCh7h9BA6LW
YRQM90Taz0z/08ddNsqZSqENkaATwp1NaIiuutsB+C7QfeuBATCH/2phedloCQPt
caK9PFMzxNsZS5uZmw4wkVTa6SQnG/RBVLYsXEVrPuq6hBpOvNMdTXgYtubKbp6r
vvZCLvC4Xz4Lj1u7/gs50rjfvV2e7YF0ha/nBgLmJ7H6wWe/N9pU6rUguweEHYQY
LGJlzT9s/SswGd52LMvM
=nOXs
-----END PGP SIGNATURE-----

--=-buqM6RE78JsQYrCZXqyP--

