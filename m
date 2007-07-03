From: Johannes Berg <johannes@sipsolutions.net>
Subject: multicasting netlink messages to groups > 31 from userspace
Date: Tue, 03 Jul 2007 21:51:25 +0200
Message-ID: <1183492286.4021.21.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cZ+u+DYeoOmYqJNwuE+Z"
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
	Thomas Graf <tgraf@suug.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60765 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758327AbXGDLjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 07:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cZ+u+DYeoOmYqJNwuE+Z
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hey,

Looking through the code that uses NL_NONROOT_SEND I just realised that
it's impossible to send multicast messages from userspace to multicast
groups with IDs higher than 31. That's not really good given that
everywhere else we handle multicast groups up to 2^32-1 :/

Unfortunately, I haven't found any good way to fix this; in fact the
only way to fix it backward-compatibly I could come up with so far is to
extend struct sockaddr_nl by "__u32 nl_group;" and use that in
netlink_sendmsg instead of nl_groups when msg_namelen is large enough
and I'm not even sure that checking msg_namelen is enough, apps could
give you a length much longer than the actual structure... Maybe
additionally require that nl_groups is set to ~0 or something. The same
should be done for netlink_connect() then.

It would of course be possible to add a new sockopt
NETLINK_{SET,GET}_DST_GROUP, but that prevents you from sending messages
to multiple high groups with sendmsg(), and I think having a working
sendmsg() is desirable as well.

Does anybody have any better ideas?

johannes

--=-cZ+u+DYeoOmYqJNwuE+Z
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGiqi8/ETPhpq3jKURAtCeAJ4rAKR1+argXq9yN7jK2Is+4ajOdgCfdpsx
EfQV54hujHia+dYW5SuZuGU=
=J9nM
-----END PGP SIGNATURE-----

--=-cZ+u+DYeoOmYqJNwuE+Z--

