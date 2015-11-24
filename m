From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH iproute2] ip-address: properly display zero IPv4 peer
 address
Date: Tue, 24 Nov 2015 13:14:40 +0100
Message-ID: <1448367280.3677.16.camel@redhat.com>
References: <1445502868-29474-1-git-send-email-thaller@redhat.com>
	 <20151123160450.73eec3ef@xeon-e3> <20151124114417.GA23115@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-W4AOh41v+nWrYcnc+4rQ"
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36902 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753071AbbKXMOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 07:14:51 -0500
In-Reply-To: <20151124114417.GA23115@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-W4AOh41v+nWrYcnc+4rQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-11-24 at 12:44 +0100, Phil Sutter wrote:
> On Mon, Nov 23, 2015 at 04:04:50PM -0800, Stephen Hemminger wrote:
> > On Thu, 22 Oct 2015 10:34:28 +0200
> > Thomas Haller <thaller@redhat.com> wrote:
> >=20
> > > Kernel allows for zero IPv4 peer addresses (IFA_ADDRESS):
> > >=20
> > > =C2=A0=C2=A0=C2=A0ip address add 192.168.5.1 peer 0.0.0.0/24 dev dumm=
y
> > >=20
> > > which is distinct from a usual address like:
> > >=20
> > > =C2=A0=C2=A0=C2=A0ip address add 192.168.5.1/24 dev dummy
> > > =C2=A0=C2=A0=C2=A0ip address add 192.168.5.1 peer 192.168.5.1/24 dev =
dummy
> > >=20
> > > For IPv4, a missing IFA_ADDRESS attribute means that the peer
> > > is 0.0.0.0. See inet_fill_ifaddr(), which does:
> > >=20
> > > =C2=A0 if ((ifa->ifa_address &&
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0nla_put_in_addr(skb, IFA_AD=
DRESS, ifa->ifa_address)) ||
> > >=20
> > > Signed-off-by: Thomas Haller <thaller@redhat.com>
> >=20
> > I would prefer that this apply to both IPv4 and IPv6.
>=20
> The case that patch handles does not happen in IPv6.
>=20
> > If the kernel sends back an address, then display it.
>=20
> It's rather "if the kernel *does not* send back an address ...".
>=20
> When reviewing this patch, I tried to find an easier (and less ugly)
> solution, but failed.=C2=A0=C2=A0Here's the result from testing all varia=
nts:


Thank you Phil for evaluating this.

I also tried to change the patch to come up with a cleaner/unified way,
but the result wasn't subjectively better.


Thomas






For reference, the relevant lines of code from kernel:



ipv4: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/=
net/ipv4/devinet.c?id=3D6a13feb9c82803e2b815eca72fa7a9f5561d7861#n1542

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if ((ifa->ifa_address &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0nla_put_in_addr(skb, IFA_ADDRESS, ifa->ifa_address)) ||
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(if=
a->ifa_local &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0nla_put_in_addr(skb, IFA_LOCAL, ifa->ifa_local)) ||



ipv6: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/=
net/ipv6/addrconf.c?id=3D6a13feb9c82803e2b815eca72fa7a9f5561d7861#n4310

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!ipv6_addr_any(&ifa->pe=
er_addr)) {
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0if (nla_put_in6_addr(skb, IFA_LOCAL, &ifa->addr) < 0 |=
|
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0nla_put_in6_addr(skb, IFA_ADDR=
ESS, &ifa->peer_addr) < 0)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0goto e=
rror;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0} else
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0if (nla_put_in6_addr(skb, IFA_ADDRESS, &ifa->addr) < 0=
)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0goto e=
rror;

--=-W4AOh41v+nWrYcnc+4rQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJWVFSwAAoJECnCNm5N/Fcohg4P/1gV0FVNtF7T3egWYjwrC6Ng
mqj2Da29PAbXtPT0XEF/yHisqXX6/1uz8oCUj3EwoL0G872Hl8ZAe18n2K/20MVH
knCWmBBbpI5NzghjOmSyfBQkE9RfJXE01GGSsaYurwlVJWvObUTOrq+S10nzrhdJ
xj0oPHUGSjYuktamlYMeEaQztlkCqA2Mg4wJqo0mRNIuzEFzU/ib49efubLrztH6
wx4pXbaXw28CzlFTKFEMnd2FLS9cnQYpgOrpXmK89QbGqIycmF0usV50YAUqlmz0
/xyWDzPaFMzmSarPKmyYH2ZmB9hiUHjMPjbHFxLaUQN5jCKwlKoUHFlxh78VaC5y
bKwmWOeiOXr4SkU+MgF4faJkpaxX+tRQhB1+XHr80YceuUWtLzfalfZsPhQa81Y+
g8DEFnszqtQN0aLyQ7TRhVywjE3yr0nbxMRFsaZJpQvOhCHDgWnvBumD21mTTqSo
0TfGuIJqQtAB7eOJOf66x6dM/8CNPJkbGxA1Pp4k3aE20EATN/tPQ4YhHZWi5MY2
ZSo8t15C8pC7HhYIautv9FIze+WOovEwiJXR55RhTBfCImyleHy27CnYvx4T/aXI
rpQ9FpOocyadoXtCnU7L7jK5Xn9dBWvv32n1tlRkdTgyX4bjl/7UktyZb7IZwImM
u86ogk+QpTVpnZUAHOFt
=vFCe
-----END PGP SIGNATURE-----

--=-W4AOh41v+nWrYcnc+4rQ--
