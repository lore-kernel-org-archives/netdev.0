From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool] test-cmdline: Disable test cases for --rxfh hash
 key parsing
Date: Sun, 21 Sep 2014 23:52:24 +0100
Message-ID: <1411339944.20019.30.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mDWuqAZ+hBDU9wGYLHmb"
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33329 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbaIUWwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 18:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mDWuqAZ+hBDU9wGYLHmb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

test-cmdline does not mock the result of send_ioctl() but just treats
a call to send_ioctl() as indicating successful parsing.  Any parse
failure after this point cannot be tested for.  Currently, the hash
key string passed to --rxfh isn't parsed until after the device's key
size is known, so we can't test it tis way.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 test-cmdline.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/test-cmdline.c b/test-cmdline.c
index be41a30..2fd7cbb 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -184,8 +184,14 @@ static struct test_case {
 	{ 0, "--set-rxfh-indir devname weight 1 2 3 4" },
 	{ 0, "--rxfh devname hkey 48:15:6e:bb:d8:bd:6f:b1:a4:c6:7a:c4:76:1c:29:98=
:da:e1:ae:6c:2e:12:2f:c0:b9:be:61:3d:00:54:35:9e:09:05:c7:d7:93:72:4a:ee" }=
,
 	{ 0, "-X devname hkey 48:15:6e:bb:d8:bd:6f:b1:a4:c6:7a:c4:76:1c:29:98:da:=
e1:ae:6c:2e:12:2f:c0:b9:be:61:3d:00:54:35:9e:09:05:c7:d7:93:72:4a:ee" },
+#if 0
+	/* XXX These won't fail as expected because we don't parse the
+	 * hash key until after the first send_ioctl().  That needs to
+	 * be changed before we enable them.
+	 */
 	{ 1, "--rxfh devname hkey foo" },
 	{ 1, "-X devname hkey foo" },
+#endif
 	{ 0, "--rxfh devname hkey 48:15:6e:bb:d8:bd:6f:b1:a4:c6:7a:c4:76:1c:29:98=
:da:e1:ae:6c:2e:12:2f:c0:b9:be:61:3d:00:54:35:9e:09:05:c7:d7:93:72:4a:ee we=
ight 1 2 3 4" },
 	{ 0, "-X devname weight 1 2 3 4 hkey 48:15:6e:bb:d8:bd:6f:b1:a4:c6:7a:c4:=
76:1c:29:98:da:e1:ae:6c:2e:12:2f:c0:b9:be:61:3d:00:54:35:9e:09:05:c7:d7:93:=
72:4a:ee" },
 	{ 0, "--rxfh devname hkey 48:15:6e:bb:d8:bd:6f:b1:a4:c6:7a:c4:76:1c:29:98=
:da:e1:ae:6c:2e:12:2f:c0:b9:be:61:3d:00:54:35:9e:09:05:c7:d7:93:72:4a:ee eq=
ual 2" },

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camu=
s

--=-mDWuqAZ+hBDU9wGYLHmb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVB9Wsue/yOyVhhEJAQq5+A/+LVk0rzkhfYZf+tD75yTV+hSLnG0jNtHg
L7lQstVROUuJGnIh0kgg6zB0jRZRp2AFV2BBTbJvQq+c2Y/dIhJT/Yy4gc482NBu
G0vGVHwP1KIkQ/e7HQaxjaS1hbyGwfOQBnbb7NJcRn82d2QmxriqoqeVurw0+5oY
bRN0y2o92+59JNTv5KdlS7C85u59eV+qTDy6dmxo3Uuwutz6P4QsaAmRkQLNjsr0
qFTf7c1UwiDTtHR3/jpfobW2IqRlyh7mQvtrqQB02BZfvm3bbtt7vY1eWsJx5KP2
wxKE5K5a+xUHQE6XAK9TFr/q5WPYIWHSWKOw2ycrg8eux/G1WVaPkDHaze3bSjfL
uX6/LMbwc+NpliKXvL4VAPcuClDK68zlsGtZmzwXw5FnvIx55YowC3fvGZhKIiw7
k824jXv9OX0qXMYPwfsERVaEoD04DSBRJ5jcHIFLW2WUFHbGQx1SDLMsrjypymuY
su7vBSxnhKqOpM/rRJqrRWlL52AIHZZckDqLT5UroeWlsmznIp7ZtnSsHXoxLt4B
97DRJNcmA2nR2gULrUrq+wqlDH7bLctyy1Rd7kmCwkofd2/35tpMH7K9f8dGoIoi
HojR77Kw7a8q8uytDY+mr0eKxN325O9zOWPQH1ObaIG70O3HqgqgMBKiHLLICc3S
C+hfrJvC0TU=
=VET9
-----END PGP SIGNATURE-----

--=-mDWuqAZ+hBDU9wGYLHmb--
