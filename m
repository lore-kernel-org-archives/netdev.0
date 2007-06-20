From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Wed, 20 Jun 2007 13:25:44 +0200
Message-ID: <1182338744.3714.59.camel@johannes.berg>
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
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Z5+FOg78GgTZAFkbpyC0"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	lenb@kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:52923 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbXFTLYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 07:24:42 -0400
In-Reply-To: <1182270006.4968.62.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Z5+FOg78GgTZAFkbpyC0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[took off acpi list]

On Tue, 2007-06-19 at 12:20 -0400, jamal wrote:

> There is one default mcast group per entity. Most users only need that
> one.

Ok. That's definitely a bug in nl80211 as we have it in development
right now. Btw, what happens if the group id gets larger than 31?

> If you need more, we go one of two ways:
> a) Register for multiple IDs with the code as is.=20
> b) we could add a "reserve multicast group" interface in the kernel.
>=20
> Thoughts?

I'd really like to be able to reserve multicast groups with special
semantics too, especially I might want to permit/deny non-CAP_NET_ADMIN
users from binding specific multicast groups. That isn't actually
possible with netlink nor genetlink right now afaict.

If we register multiple IDs then we'll end up filling up the generic
netlink family space really soon. I was under the impression that
generic netlink was basically open-ended because the family is a large
enough number, but with this arbitrary limit on multicast groups that's
really not true and we might run out of multicast groups fairly soon
since most users of generic netlink will want at least one...

johannes

--=-Z5+FOg78GgTZAFkbpyC0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGeQ64/ETPhpq3jKURAtnsAJ9z4fB/a4SH8FixepNHYRoPa+vOmgCfYM6v
9/zNSSOcgfGnUmpOtP5OA2M=
=GDpj
-----END PGP SIGNATURE-----

--=-Z5+FOg78GgTZAFkbpyC0--

