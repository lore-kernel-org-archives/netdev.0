From: Christian Langrock <christian.langrock@secunet.com>
Subject: [PATCH] ip/link_vti*.c: Fix output for ikey/okey
Date: Mon, 7 Aug 2017 11:59:28 +0200
Message-ID: <bf2d09ad-28b8-c64c-dd60-4fb288259e3e@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature";
        boundary="AjB10uVaPt2D2dmv9vH5rC1x8p2USiApq"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38982 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752584AbdHGJ7j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Aug 2017 05:59:39 -0400
Received: from localhost (localhost [127.0.0.1])
        by a.mx.secunet.com (Postfix) with ESMTP id 24FC420189
        for <netdev@vger.kernel.org>; Mon,  7 Aug 2017 11:59:38 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
        by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id DN5QxhaBwdPn for <netdev@vger.kernel.org>;
        Mon,  7 Aug 2017 11:59:37 +0200 (CEST)
Received: from mail-essen-01.secunet.de (mail-essen-01.secunet.de [10.53.40.204])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by a.mx.secunet.com (Postfix) with ESMTPS id A0FA120073
        for <netdev@vger.kernel.org>; Mon,  7 Aug 2017 11:59:37 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--AjB10uVaPt2D2dmv9vH5rC1x8p2USiApq
Content-Type: multipart/mixed; boundary="mbH1scDEmCuJM2j5hIFpbbVxJv5FiPAUk";
 protected-headers="v1"
From: Christian Langrock <christian.langrock@secunet.com>
To: netdev@vger.kernel.org
Message-ID: <bf2d09ad-28b8-c64c-dd60-4fb288259e3e@secunet.com>
Subject: [PATCH] ip/link_vti*.c: Fix output for ikey/okey

--mbH1scDEmCuJM2j5hIFpbbVxJv5FiPAUk
Content-Type: multipart/mixed;
 boundary="------------C9CC55EA3A84CAA59BFC2A68"
Content-Language: de-DE

This is a multi-part message in MIME format.
--------------C9CC55EA3A84CAA59BFC2A68
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

ikey and okey are normal u32 values. There's no reason to print them as
IPv4/IPv6 addresses.

Signed-off-by: Christian Langrock <christian.langrock@secunet.com>
---
 ip/link_vti.c  | 10 ++++------
 ip/link_vti6.c | 10 ++++------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/ip/link_vti.c b/ip/link_vti.c
index d5242ac..a694ec4 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -244,14 +244,12 @@ static void vti_print_opt(struct link_util *lu,
FILE *f, struct rtattr *tb[])
                        fprintf(f, "dev %u ", link);
        }
=20
-       if (tb[IFLA_VTI_IKEY]) {
-               inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_IKEY]), s2,
sizeof(s2));
-               fprintf(f, "ikey %s ", s2);
+       if (tb[IFLA_VTI_IKEY] && rta_getattr_u32(tb[IFLA_VTI_IKEY])) {
+               fprintf(f, "ikey %u ",
ntohl(rta_getattr_u32(tb[IFLA_VTI_IKEY])));
        }
=20
-       if (tb[IFLA_VTI_OKEY]) {
-               inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2,
sizeof(s2));
-               fprintf(f, "okey %s ", s2);
+       if (tb[IFLA_VTI_OKEY] && rta_getattr_u32(tb[IFLA_VTI_OKEY])) {
+               fprintf(f, "okey %u ",
ntohl(rta_getattr_u32(tb[IFLA_VTI_OKEY])));
        }
=20
        if (tb[IFLA_VTI_FWMARK] && rta_getattr_u32(tb[IFLA_VTI_FWMARK])) =
{
diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index 220b7df..6ae87dd 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -247,14 +247,12 @@ static void vti6_print_opt(struct link_util *lu,
FILE *f, struct rtattr *tb[])
                        fprintf(f, "dev %u ", link);
        }
=20
-       if (tb[IFLA_VTI_IKEY]) {
-               inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_IKEY]), s2,
sizeof(s2));
-               fprintf(f, "ikey %s ", s2);
+       if (tb[IFLA_VTI_IKEY] && rta_getattr_u32(tb[IFLA_VTI_IKEY])) {
+               fprintf(f, "ikey %u ",
ntohl(rta_getattr_u32(tb[IFLA_VTI_IKEY])));
        }
=20
-       if (tb[IFLA_VTI_OKEY]) {
-               inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2,
sizeof(s2));
-               fprintf(f, "okey %s ", s2);
+       if (tb[IFLA_VTI_OKEY] && rta_getattr_u32(tb[IFLA_VTI_OKEY])) {
+               fprintf(f, "okey %u ",
ntohl(rta_getattr_u32(tb[IFLA_VTI_OKEY])));
        }
=20
        if (tb[IFLA_VTI_FWMARK] && rta_getattr_u32(tb[IFLA_VTI_FWMARK])) =
{
--=20
2.7.4


--------------C9CC55EA3A84CAA59BFC2A68
Content-Type: application/pgp-keys;
 name="0x82EB6B5E.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x82EB6B5E.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

mQENBFee7jkBCACkeMIuzZu/KBA1q3kKGr7d9iiZGF5IpJnIE9dMiK3uaz7uM26V
STJVp6jdGuSGGGmb81OSLEcIEIsYKXvjblAKUX1A74t3WMRcky3MwJbmN6AkN8Ql
P45mDddtPRf1ElB2S32i9OrEkvw8xcvHYPwbaHenXic4/8fHWEh+vtd/5/5TDTIU
/ag9tQfPea13ixXN0PuccMubFeUMpwFCg324+Z19iGvfDWWZmQQGlBjc3Q6z0hXO
b/deWL/+lPS4t+tTgpmmZO4XkIs+18KqxCVukCbnqV0y+04sj3G1GQ/DlGvZHxwy
wBceAL7BvmdeXQKAS0KRL5zrghIBCgnUyutDABEBAAG0M0NocmlzdGlhbiBMYW5n
cm9jayA8Y2hyaXN0aWFuLmxhbmdyb2NrQHNlY3VuZXQuY29tPokBNwQTAQgAIQUC
V57uOQIbAwULCQgHAgYVCAkKCwIEFgIDAQIeAQIXgAAKCRCjeMdfgutrXu3kCACI
Bx6UHReBtBciNUPkP3fRaGeSOADIrql72VKD9faLAHTt6w8kvyzb8Ctpa77jswJt
21c349mF3maPlpNtpswqH27bTlXYhNcXxcmHPCbNtN3yGUy0UuIJfBMZc8PLqiqY
oY5GKD3uimeVbDYjgNhebO2f1cUvwY2wTwX6b0tgKVK0xYYTDpXI1/2MVGsjXqak
7PQoqVq0sDu0gIAAi1QO0Fbb6jIaHj6CEM2hpBTBk8qbkPs/MqYGdLl4oXvkWTLd
uQjm6dMtjxvIt6WJWZQbLjTeQIfc21luNQKDmfT623pVTPPMMAciWfpdw63FblfG
cfBnAKCJ8JBj0z9T6/PmuQENBFee7jkBCADS7amJPbY2dWpeGtE+I9yLL53lSriP
4L6rI9UoEwNM1OkjnB7wFnH8dm8N68K2OJogkHwoX2OnzGhxJ28NHRuAh++3hIYY
+gU4HMLaX3onDK1oqAdYczhJ7f6UCPbYaghkzJ6Vg/FEWpA8u5vG/BX4y+F3/Y98
l6mzAX5wLmTapRwdfuRCXRA6jlIHIOwP3NPKK4Pz2E7witsimV1ucN4uXFiZ36CU
PAiXXlER9iPZnQUSyCobqJOJKm4C7wUNQ1negCXDBd3KjSyzTIafw/oYG4RrWGul
iI2ig/qTUC8cZdAJTMBjUJR6ugJazMB1Rg17p2GRD0AzUOV2qdqYFqQFABEBAAGJ
AR8EGAEIAAkFAlee7jkCGwwACgkQo3jHX4Lra17vtQgAg2g0JEXVTGT36BDJgVjI
UY1evnm1fWwTPpcokP/8/aO2ubmlxtWQ2hV5OPfL5nDday2S4Nq5j3kqQq+rvUrO
RVmvT4WxYZM1fr2nibuzaUbsJtxphNpjahrsEcLLTzBW4CbHTaL4YTT+ZD/GDeHo
xAh9JfMkdMBXHyWTuw+QSP0pp7WvNsDosukKFyQ0rve9PH2dry6A0oLP7UxtAzEE
RV2Se0BueZPQuVnU6Cvj3ZStK28JDhMjxIPkZPE5kCV8QNF8OsiwymA3aoPKe5Bw
0lOcjuuJkxRa5bazyuubX9pIIgTeGsecgpSgpfA9jsEHKFqoLuxUA+77VQ5hSydV
aQ=3D=3D
=3DO6Ea
-----END PGP PUBLIC KEY BLOCK-----

--------------C9CC55EA3A84CAA59BFC2A68--

--mbH1scDEmCuJM2j5hIFpbbVxJv5FiPAUk--

--AjB10uVaPt2D2dmv9vH5rC1x8p2USiApq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJZiDoBAAoJEKN4x1+C62te44oIAJUt5Sqh4w7uAYnI+HU6r5/o
pkuzGZywHW80QpVUDZYlVbUKheBFup2t+KIiK1q5bWUWdq6UAqSBSBJdHSmDPV2c
7pv29LsTrxoK8vkKbtw+Lni5SD84UwBRPyU1EvkImTXzhkdtnHBy6u/bKV11RBC7
1RHWRGkje67NyWsJQFriaw0yGIHkP/X33uu5DoJfq9j57AXIdVQiXLrFxsnPCSao
lezi7kaQuWBTpln70WWBxGyOCc6h8Y/a7eCwDYdWzC3M28t7AgQz7JfxGFiuHQDH
qQJOc6M+5hWwssZnXMP63MH9hHMsaeERSnD3twFWds3utBVNIdrR33O6PZn3yjQ=
=ql68
-----END PGP SIGNATURE-----

--AjB10uVaPt2D2dmv9vH5rC1x8p2USiApq--
