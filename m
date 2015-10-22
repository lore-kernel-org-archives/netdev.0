From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Thu, 22 Oct 2015 17:21:52 +0200
Message-ID: <1445527312.7084.47.camel@redhat.com>
References: <20151021164613.24650836@griffin>
	 <20151021.083214.534622235927401863.davem@davemloft.net>
	 <20151021172502.63220dbb@griffin>
	 <20151021.085635.1582760365341524949.davem@davemloft.net>
	 <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
	 <5628F81D.1070009@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-xRwz7eOlubbWgvDGz/m2"
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290AbbJVPV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 11:21:56 -0400
In-Reply-To: <5628F81D.1070009@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xRwz7eOlubbWgvDGz/m2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-10-22 at 16:52 +0200, Nicolas Dichtel wrote:
> Le 21/10/2015 19:12, Hannes Frederic Sowa a =C3=A9crit :
> > Hello,
> >=20
> > On Wed, Oct 21, 2015, at 17:56, David Miller wrote:
> > > From: Jiri Benc <jbenc@redhat.com>
> > > Date: Wed, 21 Oct 2015 17:25:02 +0200
> > >=20
> > > > On Wed, 21 Oct 2015 08:32:14 -0700 (PDT), David Miller wrote:
> > > > > As you say the apps are broken, so file a bug and have them
> > > > > fixed.
> > > > >=20
> > > > > The assumption is clearly invalid, so apps cannot make such
> > > > > an
> > > > > assumption.
> > > >=20
> > > > Does it mean you would be okay with a patch that always
> > > > allocates and
> > > > assigns a new ifindex in the target netns when interface is
> > > > moved
> > > > between name spaces?
> > >=20
> > > I think you're misunderstanding me if you're still recommending
> > > kernel changes.
> > >=20
> > > I'm plainly saying to remove the assumption in the apps.
> > >=20
> > > If you don't show me exactly how some kernel change can lead to
> > > the apps implementing things properly, without the invalid
> > > assumptions, then I can only assume you didn't hear what I
> > > said.
> >=20
> > I think the reason why ifindexes exists as ints is that we want to
> > have
> > lightweight way to refer to interfaces without taking references or
> > timestamps or generation ids which completely remove the
> > possibility for
> > races. But the racy nature in ifindexes is something we actually
> > want,
> > otherwise a user space program acquiring an ifindex would need to
> > get a
> > reference on the device and either during socket close or program
> > termination release it, that would be very costly.
> >=20
> > This patch minimizes the race quite a lot, from something we could
> > actually see in everydays container creation to probably something
> > only
> > some users will expire with depleting the ifindex pool or playing
> > around
> > with CRIU.
> >=20
> > We could come up with more heavy machinery to close the race
> > further for
> > CRIU by keeping track of "poisoned" ifindexes, which would need a
> > hashmap which could become pretty big and we could recycle when
> > ifindex
> > wraps around, but this seems too heavy weight to me.
> >=20
> > I am in favor of a solution to minimize this race in the kernel
> > even
> > though we cannot ever close it completely.
> I probably miss something, but if the app listens netlink, I don't
> see how such
> app may have a race window.


Userspace uses the ifindex as identifier for the interface, for example
when changing a link or adding and IP address.

(1) Say, the application listens on netlink and learns about an
interface (and its ifindex).

(2) Immediately it does something with the ifindex (e.g. IF_UP the
interface).


Between (1) and (2) is a possibility of a race, that the application
cannot avoid. It can only hurry and hope for the best.



Thomas





--=-xRwz7eOlubbWgvDGz/m2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJWKP8QAAoJECnCNm5N/FcozVkP/3TTPUXjZBF6GX8hQj3oV8F2
L3DOrC/bIosrh2S4u42G80cicip/jvagbSUqmYGfpkJfLRvMiPV8A523tncAB74K
yOS+FcPCI77fZEK41TT6Pb4YZYoA5kaQPBUjVJS2cZHdX2feJwwSUPtO3WSw64vC
SCx+HuFQGsMUtxS+sFnAAfoOQGHBaYX0KMPX4g90cQxBqPCXCPngSwGco//fZVm2
E8b59x/30jHyI+8zn0OhocNot4MP04sLJTIZ46W6WMWJQdRarm7S9vm0stR8thJy
n/PvRy3lwFnhNPlBCAwRA6dbXuW96NJXHH53CDK3zLYSULWKCrFOPevpQF/LE0qJ
9Z+91zjJTuqPaUiiFGmp8yYTrOkL7hScOzuE3kZ7lrZF+iZqxzHogbTNVA80jJKf
IyJwG+7TCx2/QPLGSw2E8CRpiDk7Ue35Ut1A3BFgWHJw7KCii90miPdH/K4oY4Kj
/lSC+glgttGTsTs3OXzWEv7LQQP50A5mzH/LM1lS8v26vwzdZvZ/KnAGEiVl73a1
N5mPpBTJkUqWAqK7XxiFR9O9dPv8hL1seFAUJf9RED/HS/5E/tBVHpFu+j139YUm
1WRUtjfCmlYOHzkOg2ku2PL7vQPJo3+k7GDwezvlOdNxJRBZWyI3dXCLlatCPrD1
BKUyfJaepa5/4MQUFcnh
=DhTt
-----END PGP SIGNATURE-----

--=-xRwz7eOlubbWgvDGz/m2--
