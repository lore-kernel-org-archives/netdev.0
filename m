From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 16:18:22 +0200
Message-ID: <1183558702.3812.33.camel@johannes.berg>
References: <1183492286.4021.21.camel@johannes.berg>
	 <468BAADC.4030203@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-P7qH+uvW6LbZFJfruoyM"
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49484 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758557AbXGDOR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 10:17:29 -0400
In-Reply-To: <468BAADC.4030203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-P7qH+uvW6LbZFJfruoyM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-04 at 16:12 +0200, Patrick McHardy wrote:
> Johannes Berg wrote:
> > Hey,
> >=20
> > Looking through the code that uses NL_NONROOT_SEND I just realised that
> > it's impossible to send multicast messages from userspace to multicast
> > groups with IDs higher than 31. That's not really good given that
> > everywhere else we handle multicast groups up to 2^32-1 :/
>=20
>=20
> Why do you want to send to a multicast group from userspace?

Why not, what's wrong with that?

Actually, I think I mentioned this earlier, I was thinking about doing
wireless configuration as a group where both the kernel and possibly a
userspace process listen on that multicast group and processes that want
to configure a device just send to that group. Then the kernel ignores
the message if a userspace process is handling the specific device
completely. For example changing the BSSID: if the kernel is doing MLME
then it changes the BSSID, but if a userspace process is doing it then
the kernel doesn't do anything since BSSID changing is a pure MLME
function, but for consistency it'd be nice if both could be done the
same way, hence a multicast group.

This was actually suggested by Herbert since it's easy to find out if
that multicast group has a listener and not so easy if a special generic
netlink socket in userspace is (still) open.

johannes

--=-P7qH+uvW6LbZFJfruoyM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGi6wu/ETPhpq3jKURAsF5AKCBZHC+Eq+F3KL5SGGjd1YskfzjCQCfTv2B
crWNwCJl/OCcmuqq2Pf6FQo=
=F9GM
-----END PGP SIGNATURE-----

--=-P7qH+uvW6LbZFJfruoyM--

