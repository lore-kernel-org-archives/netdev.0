From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool 1/2] Fix missing function declarations when building
 tests
Date: Fri, 09 Oct 2015 04:03:27 +0100
Message-ID: <1444359807.2956.294.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zjzHL8zliUkFs4c8m8ra"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36472 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750760AbbJIDDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 23:03:42 -0400
Received: from deadeye.wl.decadent.org.uk ([192.168.4.247] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.84)
	(envelope-from <ben@decadent.org.uk>)
	id 1ZkNy7-0003I0-13
	for netdev@vger.kernel.org; Fri, 09 Oct 2015 04:03:39 +0100
Received: from ben by deadeye with local (Exim 4.86)
	(envelope-from <ben@decadent.org.uk>)
	id 1ZkNy1-0001Y4-OX
	for netdev@vger.kernel.org; Fri, 09 Oct 2015 04:03:33 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zjzHL8zliUkFs4c8m8ra
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Fix these compiler warnings by declaring test_exit() and test_main()
regardless of whether TEST_NO_WRAPPERS is defined:

test-cmdline.c: In function =E2=80=98send_ioctl=E2=80=99:
test-cmdline.c:268:2: warning: implicit declaration of function =E2=80=98te=
st_exit=E2=80=99 [-Wimplicit-function-declaration]
  test_exit(0);
  ^
test-common.c: In function =E2=80=98test_cmdline=E2=80=99:
test-common.c:361:21: warning: implicit declaration of function =E2=80=98te=
st_main=E2=80=99 [-Wimplicit-function-declaration]
  rc =3D rc ? rc - 1 : test_main(argc, argv);
                     ^

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
These warnings are longstanding so I'm not sure why I didn't notice
them before!  I've applied this post-4.2.

Ben.

 internal.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/internal.h b/internal.h
index 444810d..156770c 100644
--- a/internal.h
+++ b/internal.h
@@ -132,10 +132,11 @@ struct cmd_expect {
 int test_ioctl(const struct cmd_expect *expect, void *cmd);
 #define TEST_IOCTL_MISMATCH (-2)
=20
-#ifndef TEST_NO_WRAPPERS
 int test_main(int argc, char **argp);
-#define main(...) test_main(__VA_ARGS__)
 void test_exit(int rc) __attribute__((noreturn));
+
+#ifndef TEST_NO_WRAPPERS
+#define main(...) test_main(__VA_ARGS__)
 #undef exit
 #define exit(rc) test_exit(rc)
 void *test_malloc(size_t size);

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.
--=-zjzHL8zliUkFs4c8m8ra
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVhcuf+e/yOyVhhEJAQqotQ/+KDYX0jCighBffoGlqgqWp4c3OqUxoedP
90hfiHIXE9OCHoG+tC1UsJjC5fIYbOtwUyqGiKSvhMsJ++ckorKluoy4RHViVIYj
uDOTTa9z/Of01BjSOPB7prUeRm6NLTH6NDhnsSUWpBgYLegt0ui0jveN5u/lp+Mr
x3/FNsLz0+ZsAZ4MXyKMMG6+/9ntWFZMm4WExDh0civEuOGFWSfi9QQNWG6yIwQf
+6XwYaBqTffDslNDDm5Uv2HOZJ5HStnscFJFom120ySppkZs5yk7qVK57tM2wiyB
+j5KWc57ggPMempqNKs3rWcQftrJJX5Rn+hHdelOtLKN2rF1wybY3X+OBfrY7ISh
d6Y4/lLjRYY2zwlvs19H5FAd1ZgHir04+Mcl4U+CjrugG0Tvkl0iycL79fPZIYw/
oFl4lr/nNlMRRhGzxfaGDI/aI9yDRfzaJKjPIjQYof5KSxW/Z0qQwBydsw/d4QmG
ylpaxFbWgRV86UGk4v6UCe1Xu1aTuBZxpuR8SaE4xJ8ia2t4RsmwyQVu/fuux11J
Uj4OCI6X12Fn8xgmBOOoOXfYEMVnRwjy4IGp1x7F0QmgJrO8QlK243KI+K2WPej0
kMQtc5PfuUIwgtoF08fX+FBWO2lbAWDxEsnGlRRiC8upXU1KMR9Bot3FL6UY1DQA
nE3BcEWPCvI=
=WFIV
-----END PGP SIGNATURE-----

--=-zjzHL8zliUkFs4c8m8ra--
