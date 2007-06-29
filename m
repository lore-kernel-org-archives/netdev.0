From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 15:15:20 +0200
Message-ID: <1183122920.4089.63.camel@johannes.berg>
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
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rFRNXvO9o8xOw1RkeC41"
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <468504FE.9000502@trash.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rFRNXvO9o8xOw1RkeC41
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-06-29 at 15:11 +0200, Patrick McHardy wrote:

> > Hm. I'm starting to dislike the dynamic registration the more I think
> > about it. Now when a group is unregistered I'd have to unbind everybody
> > who's currently using it... At least when I want to enforce
> > root/non-root binds which is a further goal.
>=20
>=20
> How about using module references to prevent unloading while sockets
> are bound? We already do the same thing for netlink families.

Ah, no, you're both thinking something different. I'm thinking if we
allow dynamic registration the only sensible thing is to have dynamic
unregistration as well, and then we can have this sequence

 (1) register group X with non-root
 (2) non-root app A binds group X
 (3) kernel unregisters group X
 (4) something else in kernel reregisters group ID X but root-only
-> non-root app A is bound to root-only group X

johannes

--=-rFRNXvO9o8xOw1RkeC41
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGhQXo/ETPhpq3jKURAl1/AJ9kwjuhqvpYhzH53iWQEMYnH9OuSwCfcOS/
cjyV5NzalWXKHvWVgAGlzTI=
=rY82
-----END PGP SIGNATURE-----

--=-rFRNXvO9o8xOw1RkeC41--

