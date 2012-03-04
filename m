From: Kenyon Ralph <kenyon@kenyonralph.com>
Subject: [PATCH] iproute2: update ip address manual page
Date: Sun, 4 Mar 2012 12:17:11 -0800
Message-ID: <20120304201711.GA4106@kenyonralph.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from darwin.kenyonralph.com ([173.255.215.209]:55250 "EHLO
	darwin.kenyonralph.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab2CDUZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 15:25:33 -0500
Received: from darwin.kenyonralph.com (localhost [IPv6:::1])
	by darwin.kenyonralph.com (Postfix) with ESMTP id 848D7E142
	for <netdev@vger.kernel.org>; Sun,  4 Mar 2012 12:17:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* update synopsis to match "ip address help" output
* specify IPv4, since "IP" is ambiguous
* remove deprecated site scope
* document lifetimes, home, and nodad
* update wording to make sense since page was split from the ip(8) page

Signed-off-by: Kenyon Ralph <kenyon@kenyonralph.com>
---
 man/man8/ip-address.8 |   59 +++++++++++++++++++++++++++++++++++++++++----=
---
 1 files changed, 50 insertions(+), 9 deletions(-)

diff --git a/man/man8/ip-address.8 b/man/man8/ip-address.8
index 971fe16..880ae12 100644
--- a/man/man8/ip-address.8
+++ b/man/man8/ip-address.8
@@ -1,4 +1,4 @@
-.TH "IP\-ADDRESS" 8 "20 Dec 2011" "iproute2" "Linux"
+.TH "IP\-ADDRESS" 8 "04 March 2012" "iproute2" "Linux"
 .SH "NAME"
 ip-address \- protocol address management
 .SH "SYNOPSIS"
@@ -14,7 +14,12 @@ ip-address \- protocol address management
 .sp
=20
 .ti -8
-.BR "ip address" " { " add " | " del " } "
+.BR "ip address" " { " add " | " change " | " replace " } "
+.IB IFADDR " dev " STRING
+.RI "[ " LIFETIME " ] [ " CONFFLAG-LIST " ]"
+
+.ti -8
+.BR "ip address del"
 .IB IFADDR " dev " STRING
=20
 .ti -8
@@ -51,12 +56,30 @@ ip-address \- protocol address management
 .ti -8
 .IR FLAG " :=3D "
 .RB "[ " permanent " | " dynamic " | " secondary " | " primary " | "\
-tentative " | " deprecated " | " dadfailed " | " temporary " ]"
+tentative " | " deprecated " | " dadfailed " | " temporary " | " CONFFLAG-=
LIST " ]"
+
+.ti -8
+.IR CONFFLAG-LIST " :=3D [ "  CONFFLAG-LIST " ] " CONFFLAG
+
+.ti -8
+.IR CONFFLAG " :=3D "
+.RB "[ " home " | " nodad " ]"
+
+.ti -8
+.IR LIFETIME " :=3D [ "
+.BI valid_lft " LFT"
+.RB "| " preferred_lft
+.IR  LFT " ]"
+
+.ti -8
+.IR LFT " :=3D [ "
+.BR forever " |"
+.IR SECONDS " ]"
=20
 .SH "DESCRIPTION"
 The
 .B address
-is a protocol (IP or IPv6) address attached
+is a protocol (IPv4 or IPv6) address attached
 to a network device.  Each device must have at least one address
 to use the corresponding protocol.  It is possible to have several
 different addresses attached to one device.  These addresses are not
@@ -123,10 +146,6 @@ Predefined scope values are:
 .B global
 - the address is globally valid.
 .sp
-.B site
-- (IPv6 only) the address is site local, i.e. it is
-valid inside this site.
-.sp
 .B link
 - the address is link local, i.e. it is valid only on this device.
 .sp
@@ -134,6 +153,28 @@ valid inside this site.
 - the address is valid only inside this host.
 .in -8
=20
+.TP
+.BI valid_lft " LFT"
+(IPv6 only) the valid lifetime of this address; see section 5.5.4 of
+RFC 4862. Defaults to
+.BR "forever" .
+
+.TP
+.BI preferred_lft " LFT"
+(IPv6 only) the preferred lifetime of this address; see section 5.5.4
+of RFC 4862. Defaults to
+.BR "forever" .
+
+.TP
+.B home
+(IPv6 only) designates this address the "home address" as defined in
+RFC 6275.
+
+.TP
+.B nodad
+(IPv6 only) do not perform Duplicate Address Detection (RFC 4862) when
+adding this address.
+
 .SS ip address delete - delete protocol address
 .B Arguments:
 coincide with the arguments of
@@ -202,7 +243,7 @@ The difference is that it does not run when no argument=
s are given.
 .B Warning:
 This command (and other
 .B flush
-commands described below) is pretty dangerous.  If you make a mistake,
+commands) is pretty dangerous.  If you make a mistake,
 it will not forgive it, but will cruelly purge all the addresses.
=20
 .PP
--=20
1.7.9


--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBCgAGBQJPU83HAAoJEJj/PvnJuRLVzioQAMSHfguiMX5IrHa+NuGTumT5
XQubICD57qumFhqjmzgx7fHf2BvsyYDnW5ZAws7OMNO5Zc5KI7Z+XZlBjTFzdWge
B4RHgNGXYuuyV61aIiQZ+tp9QGkvp1fHRzHgm2g23kMYociGrvLCMX1IZAnCD9A1
KZbptyFTnmuq32rYQ6JRAGfY2AcFlMZ/zf05l0fDZk0QjmoUAVu2aOsZlRLAIWBf
6NG+kki4TPr4KfIa9VI/0Y8/TyD0EM9V5jYd3WHl+RJOm+Nbq7uW6VKpZl49vYYA
Oe4nfZIpctXIcVV+HFca5PRGpkTa6DyAsEETiH77nE2DEzhxDiC6sRUC/YOaj8N+
yGzHC3rNuBggZNW3REGvZnVDHCTePa6nnFWWOnAp8Qh2UjXjxqHyx1CfXXdDpAIg
vOQqldoVySBG8eKXaz9xC8huIafANH0Zje5KLfYRXKeytSOyCkPhO7iv9c6aq6sf
h097NgnSLOK8K+I9HCDDWVTNKJRz6hCZXbV4DRA6RlgcYArZUuDQW4PglLEPBxe8
kiB5QfebBuacXilK2jHSmZmTQL1Mg//j1ZBnZO4q5eAQwGF8RYr/9g5VbY+KjV2H
dT507CZtKiy6AhpxfIKUGLPlP+fkSWJFVRZhzvqI3rf6rkiF1Hc5eYNKsyqjX3Yy
M2m2kAh0JS574ecvHKk0
=1JAl
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--
