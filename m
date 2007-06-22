From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 22 Jun 2007 12:09:06 +0200
Message-ID: <1182506947.21939.89.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182252616.21013.12.camel@johannes.berg>
	 <1182270006.4968.62.camel@localhost>
	 <1182338744.3714.59.camel@johannes.berg>
	 <1182440840.5017.40.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-w+t2VtctO3a1HnoYpNm2"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	lenb@kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60448 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbXFVKIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 06:08:02 -0400
In-Reply-To: <1182440840.5017.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-w+t2VtctO3a1HnoYpNm2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-06-21 at 11:47 -0400, jamal wrote:
> On Wed, 2007-20-06 at 13:25 +0200, Johannes Berg wrote:
>=20
> > Ok. That's definitely a bug in nl80211 as we have it in development
> > right now.=20
>=20
> Sorry, have never looked at that code.

No worries, I was just stating that.

> You can use setsockopt to set the multicast groups. What you cant do
> with that is subscribe to many groups in one shot.
> The call in iproute2 hasnt reflected this reality yet.

Ah, ok, I see now. I was under the impression that groups was always
just a u32.

> > I'd really like to be able to reserve multicast groups with special
> > semantics too, especially I might want to permit/deny non-CAP_NET_ADMIN
> > users from binding specific multicast groups. That isn't actually
> > possible with netlink nor genetlink right now afaict.
>=20
> This would be hard - but doable via SELinux interface. I think you
> should be able to extend your tool to make calls to that interface.

Why do you think that would be hard? It'd basically just mean replacing
the netlink_capable(sock, NL_NONROOT_RECV) calls with a call that
actually tests depending on the group(s) it wants.

> > If we register multiple IDs then we'll end up filling up the generic
> > netlink family space really soon.=20
>=20
> Theres a huge number of these groups; and not just that, but considering
> that some genetlink users may not be interested in such multicast
> groups, it is quiet usable to have many groups as long as we avoid
> conflict.

Yeah, never mind, I thought that the number of groups was limited to 32.

> The multicast issue wasnt well-attacked. We have a group magically
> assigned to a user based on their allocated id. It should be feasible
> to add an API to the kernel for registering for many groups and allow
> user space to discover these groups before registering. Maybe thats
> the path to proceed to.

Yeah, sounds reasonable, you could ask the controller for which groups
are attached to a family and then get the IDs for those groups by name.

johannes

--=-w+t2VtctO3a1HnoYpNm2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGe5/C/ETPhpq3jKURAkAhAJwNA/dMdP/VJkE+dGiaOKc7y27oXwCfTFfR
yVUzL05k9NN9q54ndFRDFkM=
=qdSC
-----END PGP SIGNATURE-----

--=-w+t2VtctO3a1HnoYpNm2--

