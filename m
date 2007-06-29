From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 15:34:45 +0200
Message-ID: <1183124085.4089.66.camel@johannes.berg>
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
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pZsgB+NFo/O8jxKOhIhb"
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <468507C9.2000800@trash.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-pZsgB+NFo/O8jxKOhIhb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-06-29 at 15:23 +0200, Patrick McHardy wrote:

> I'm not sure that "the only sensible thing to do" is right, we
> do allow dynamic registration of netlink families and do the
> module reference thing anyway (admittedly, I never liked that
> and the autoloading part very much). I guess it depends on how
> this will be used in the end, if you really do have a group per
> device or something like that you probably need to be able to
> unregister at any time. But as I said previously I believe its
> more in the spirit of netlink to group things logically by
> message type, in which case some core part would own the
> family and not a single device.
>=20
> If you do want the dynamic unregistation *and* the non-root mc
> listening then I guess you don't have a choice but to unbind
> sockets at unregistration. That shouln't be a real problem,
> without having though much about it, I believe just clearing
> the mc group from the bitmap and calling netlink_update_subscriptions
> should be fine.

Yeah, true, but the patch gets larger with every little thing here :)

How about for now I only allow dynamic registration (no unregistration)
and just send out when new groups are registered, and also give
userspace a list of registered mc groups when they ask for a family
description? That should make this patch not too big and still leaves
room for dynamic unregistration later.

johannes

--=-pZsgB+NFo/O8jxKOhIhb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGhQp1/ETPhpq3jKURAg00AKCR5w9Jbjjx0YsaduwjJSBKF1ZQ5QCcCR4x
nm0GlHfUWuyZo/lq0n90Xf0=
=69B4
-----END PGP SIGNATURE-----

--=-pZsgB+NFo/O8jxKOhIhb--

