From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 13:28:47 +0200
Message-ID: <1183116527.4089.40.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183023939.4769.76.camel@johannes.berg>
	 <1183115835.5156.37.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XMYuzPdr5h5GyWdc0CvU"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35447 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758023AbXF2L2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 07:28:38 -0400
In-Reply-To: <1183115835.5156.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-XMYuzPdr5h5GyWdc0CvU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-06-29 at 07:17 -0400, jamal wrote:

> > No, the controller is the only other generic netlink multicast user
> > according to what I've found. :)
>=20
> Scanning the code - true ;-> Iam a little suprised that the task
> accounting folks didnt use it to periodically dump stats.=20

:)
Because of this I'd really prefer if we could hold off on adding groups,
but I can handle both cases fine by just reserving a family and group ID
for the current users.

> Sorry i meant there are 2^16 families (-1 considering controller)
> There are 2^32 groups (-1 considering controller) for the same number of
> families. i.e i see those items as being global within genetlink.

Yeah, so we shouldn't really be worried about running out of either.

> It is just a boundary condition policy. When there are no more groups
> left (Note: it will take a lot of effort to hit that), then what do you
> do?
> Your current approach seems to say "return an error".

[suggestion snipped]

I think I'd prefer if we just returned an error. See, we aren't going to
run out of groups in the foreseeable future, and if we ever have users
that generate *a lot* of groups we can still add the sharing code etc.
For now it seems just bloat and a code path we won't ever touch so prone
to errors in it.

> > Why give them
> > numbers from a different namespace because they're used inside nested
> > attributes?
>=20
> Sorry - i should have read up to here ;-> Yes, it is because of the
> nesting. Again consider the suggestion of sending just one TLV.

Ok :) Though I'm not sure I understood the suggestion of sending just
one TLV, what should I send? Or are you referring to dynamic group
registration where the whole nesting is going away anyway since you get
one message per new group...

> Well, you can hide that from the user in the form of a library etc. They
> dont have to know; what they know is group named "link-events" is where
> they can join to listen to link events (and your abstraction generic
> code does all the dirty work).=20

Right. We'll see how it turns out in practice when we start using it :)

johannes

--=-XMYuzPdr5h5GyWdc0CvU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGhOzv/ETPhpq3jKURAhDaAJ97u99JUttLDfHDv2BA17bIHQzC3QCfcxdF
fCTp0+xklK5bEBUCob7OKnQ=
=5HBD
-----END PGP SIGNATURE-----

--=-XMYuzPdr5h5GyWdc0CvU--

