From: martin f krafft <madduck@madduck.net>
Subject: non-root, non-real network manipulation for netconf testing
Date: Tue, 3 Jun 2008 10:05:29 +0200
Message-ID: <20080603080529.GA9010@lapse.madduck.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="X1bOJ3K7DJ5YkBrT"
Cc: netconf developers list <netconf-devel@lists.alioth.debian.org>
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seamus.madduck.net ([213.203.238.82]:49241 "EHLO
	seamus.madduck.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbYFCIFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 04:05:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dear networking wizards,

This is a bit of a self-reflexive mail, but I hope some of you might
have some input...

In writing netconf[0], we are having a bit of a problem with the
test suite, since many of netconf's operations require root rights
(e.g. interface manipulation with /bin/ip). In addition, a test
suite manipulating the network configuration of the running machine
is not really something I feel comfortable with.

0. http://netconf.alioth.debian.org

So I am trying to come up with alternative plans, of which there are
three:

1. do not fail tests that need root rights when run as non-root
2. set up a VDE network (which still requires root rights)
3. write a mock /bin/ip which pretends to be doing what it'd be doing

None of these three is satisfactory. (1) provides incomplete test
coverage unless run by root, which is not going to be done very
often, (2) can be combined with (1) but still puts the host machine
in danger of losing connectivity, and (3) just sounds terrible,
especially when other stuff, like dhclient or wpa_supplicant come
into play.

Of course, I am asking a bit much, but maybe you guys have some
input that could help us move along?

What I really want is some context handler that can emulate
a complete network and process stack for my test scripts, let
a normal user modify anything they want, but not touch anything on
the actual system. Sort of like database transactions. I think I may
be out of luck though, no?

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
"you don't sew with a fork, so I see no reason
 to eat with knitting needles."
                               -- miss piggy, on eating chinese food
=20
spamtraps: madduck.bogus@madduck.net

--X1bOJ3K7DJ5YkBrT
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIRPtJIgvIgzMMSnURAqPvAKCIBf+dfFa2X7h/CWYtRpqApd4XpwCfbo+n
jsbpZwQJPnUScy6wob/x4gM=
=oEx5
-----END PGP SIGNATURE-----

--X1bOJ3K7DJ5YkBrT--
