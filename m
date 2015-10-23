From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Fri, 23 Oct 2015 12:40:03 +0200
Message-ID: <1445596803.3268.31.camel@redhat.com>
References: <20151021164613.24650836@griffin>
	 <20151021.083214.534622235927401863.davem@davemloft.net>
	 <20151021172502.63220dbb@griffin>
	 <20151021.085635.1582760365341524949.davem@davemloft.net>
	 <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
	 <5628F81D.1070009@6wind.com> <20151022170100.1e45a8b8@griffin>
	 <20151022164558.GH23554@pox.localdomain>
	 <1445534516.240647.417579361.507D42D3@webmail.messagingengine.com>
	 <20151022185629.GI23554@pox.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-wW9b76peFTZaovAfaUqc"
Cc: Jiri Benc <jbenc@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52852 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbbJWKkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 06:40:08 -0400
In-Reply-To: <20151022185629.GI23554@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wW9b76peFTZaovAfaUqc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-10-22 at 20:56 +0200, Thomas Graf wrote:
> On 10/22/15 at 07:21pm, Hannes Frederic Sowa wrote:
> > Hi Thomas,
> >=20
> > On Thu, Oct 22, 2015, at 18:45, Thomas Graf wrote:
> > > I understand the race but when does it occur? Whoever creates
> > > the original interface owns it and is responsible for its
> > > lifecycle. *Iff* for some reason multiple entities manipulate
> > > the interface, then it's probably a lot safer to just use flock
> > > or something similar to serialize access entirely in user space.
> >=20
> > This only works if all networking configuration programs would
> > standardize on the same flock. Also, under memory pressure we lose
> > netlink monitor messages, so we need to deal with timeouts and
> > retries
> > and manual sync up on the networking configuration, which makes
> > this
> > scheme a lot harder. For normal socket io, where we specify e.g.
> > ifindex
> > in sin6_addr, this is not really usable at all.
>=20
> Again, what is the scenario where this happens? Is this being
> hit or are we talking theoretical races? I'd like to understand
> the background of this.

  ip netns add N1
  ip netns add N2

  ip netns exec N1 ip link add type dummy
  ip netns exec N2 ip link add type dummy

  ip netns exec N1 ip monitor &

  ip netns exec N1 ip link delete dummy0
  ip netns exec N2 ip link set dummy0 netns N1


Honestly, I didn't experience a concrete bug due to this.

But it's common to treat the ifindex as unique identifier.
By reusing the ifindex immediately as in the example above, it
could happen to mix up interfaces.


Thomas
--=-wW9b76peFTZaovAfaUqc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJWKg6DAAoJECnCNm5N/FcoCYwP/0EmIZ56bTV3exm3Xbqkdj9L
TCUKVdC2e5EOwCGhyZIHZn+NNHVa3G0E3q/GVfeWvCFg1alirypJSCb17tIRSrLx
d7/B3BP/zwsAQuJIr6sCbGTlfYrYCjytrvWi5fyE8oBXuWS9bjNlEvdtWKX5Spef
xJHSVqCv3JDoZY/1gid7WqdEcZJOvfn/O6q4Ss88VN1R3yJE4jTOjH9Z7YXSL5au
9raJ01WSv0pJ65wDQ2POR1h6WlB0EFEN5EGPh7j1M3426qbrCGgVMTmb2n8Re0ow
SUAMeqxlbpcN6WRPahUuEuKDB4OoF//1uSVlH1PljGerRj3ptQ1ySyWoPuycDA/j
rIkVeivuVUNEmusg1b4GThHrDih4K3TvxJPIK7v0HfTlR6SkoeJY9XysNSvxfcPq
i3vrgIzxwa1Xg2ic5hV1w2qV2+UO4XXyrpIHNCZcVMYJ6EMQsy2KDYD2VxlrF0hb
rzN2WsWJara3T8GX9w4jqu1wkEFid5PZCVifRtjfsTWSKiahJu2dQjNPK8N2f6P3
gEQGfMbMclhDMI73Q56idqGK0phSc72CxaacnCJWc5gSBqlgMaRs7hShEU0KttCm
CTtZNN5mwwST3bHpXjY/SbMy+VoL70dLRczUYLpBTczMqQCBvpofj5TU6vQJtCCS
51dIYP31D6n3rNi86NVa
=5Fg7
-----END PGP SIGNATURE-----

--=-wW9b76peFTZaovAfaUqc--
