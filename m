From: Pierre Ossman <pierre-list@ossman.eu>
Subject: [RFC][PATCH] Export DNSSL RA option to userspace
Date: Sun, 12 Dec 2010 14:43:00 +0100
Message-ID: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-23750-1292161386-0001-2"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:55611 "EHLO
	smtp.ossman.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131Ab0LLNss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 08:48:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-23750-1292161386-0001-2
Content-Type: multipart/mixed; boundary="MP_/Et=ViTe/XzLQ_U1hEDz0Om2"

--MP_/Et=ViTe/XzLQ_U1hEDz0Om2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

RFC 6106 specifies a new RA option for DNS resolver configuration that
therefore needs to end up in userspace.

This first patch just exports the new option, but I started thinking
that this seems overly complex that the kernel needs to be updated
every time there is something new of interest to userspace in the RA.
So I also have a second patch that exports everything that the kernel
doesn't want.

Patches only compile tested so far as I'm still hacking away at
userspace. Comments very much welcome though.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by FRA, a
  Swedish intelligence agency. Make sure your server uses
  encryption for SMTP traffic and consider using PGP for
  end-to-end encryption.

--MP_/Et=ViTe/XzLQ_U1hEDz0Om2
Content-Type: text/x-patch
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename=0001-ipv6-export-DNS-search-list-option-to-userspace.patch

=46rom a5b60e80eeed87763c811ecfb0d7aa5695d0a2bf Mon Sep 17 00:00:00 2001
From: Pierre Ossman <pierre@ossman.eu>
Date: Sun, 12 Dec 2010 00:06:48 +0100
Subject: [PATCH 1/2] ipv6: export DNS search list option to userspace

Like DNS resolver addresses, the suffixes to be used in DNS lookups need
to be configured by userspace. Make sure userspace has access to the
option containing that information.

Signed-off-by: Pierre Ossman <pierre@ossman.eu>
---
 include/net/ndisc.h |    3 ++-
 net/ipv6/ndisc.c    |    8 +++++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 895997b..9c8698a 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -33,7 +33,8 @@ enum {
 	ND_OPT_MTU =3D 5,			/* RFC2461 */
 	__ND_OPT_ARRAY_MAX,
 	ND_OPT_ROUTE_INFO =3D 24,		/* RFC4191 */
-	ND_OPT_RDNSS =3D 25,		/* RFC5006 */
+	ND_OPT_RDNSS =3D 25,		/* RFC5006 / RFC6106 */
+	ND_OPT_DNSSL =3D 31,		/* RFC6106 */
 	__ND_OPT_MAX
 };
=20
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 58841c4..c5b01e3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -233,7 +233,13 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_=
opt_hdr *cur,
=20
 static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
 {
-	return (opt->nd_opt_type =3D=3D ND_OPT_RDNSS);
+	switch (opt->nd_opt_type) {
+	case ND_OPT_RDNSS:
+	case ND_OPT_DNSSL:
+		return 1;
+	default:
+		return 0;
+	}
 }
=20
 static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
--=20
1.7.2.3


--MP_/Et=ViTe/XzLQ_U1hEDz0Om2--

--=_freyr.ossman.eu-23750-1292161386-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iF4EAREIAAYFAk0E0WgACgkQopDLsoqlmEIkMwEA0JUCEFab9TrP0oqF9QCJLzYm
emapbaflxVK7+VVQnzQA/0o2LQgPjiP5+carqVYX22gX0z/WMh644mN4TDAhe0lc
=O7YD
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-23750-1292161386-0001-2--
