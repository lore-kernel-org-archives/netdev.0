From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch] rename members in dummy _xt_align struct
Date: Mon, 29 Jan 2007 17:25:47 -0500
Message-ID: <200701291725.47920.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_rRnvFEv/pxXYrZz"
Cc: linux-kernel@vger.kernel.org
To: netfilter@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43951 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932662AbXA2WZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 17:25:06 -0500
Received: from home.wh0rd.org (pool-151-203-5-76.bos.east.verizon.net [151.203.5.76])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 8E3EC65025
	for <netdev@vger.kernel.org>; Mon, 29 Jan 2007 22:25:03 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_rRnvFEv/pxXYrZz
Content-Type: multipart/signed;
  boundary="nextPart1550477.nZ2r2BMeEE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1550477.nZ2r2BMeEE
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

i'd like to rename the members in the _xt_align struct in=20
netfilter/x_tables.h ... by not using 'u8', 'u16', etc..., it's possible to=
=20
filter headers meant for userspace through the preprocessor and pull out=20
people who accidentally utilize these internal types ... however, by using=
=20
struct members who have the same name as 'u8', 'u16', etc..., this throws u=
p=20
a false positive

of all the exported headers, this is the only one to do this sort of thing,=
 so=20
i hope you guys wont mind making the change :)
=2Dmike

--nextPart1550477.nZ2r2BMeEE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.1 (GNU/Linux)

iQIVAwUARb50a0FjO5/oN/WBAQK19Q//XjMxUPdaaiCUs3s84n7SjfT1YUezks3n
+9J+FXhNastfKmYc8OehSLb5GG7phYLCftQjYOtZFhWSn45R0OjzhGyOYc5mKHqS
LAnzWWoV0sAUiO/4HZYNLZy/tFt+hLKUKgMy5B9rHaJXH1sD9jrIZqBgbitoalvL
+sm9NzJn3ROD8jTSgqZLNzU0PfiYMP+Os0515BAQQgvuA8W/NK+ZZJhKZIACDrQH
FsS9xznMG+u5/UXcmeA6D36oXUJQBZZ6IdQ0h76p8CEMG9tn0OJ8EuYpkHO+8331
AQ5jaORHMin0/0oenhfD0gxsz3aHS11FMnZ1aH0HKDKCEtok+qobOwmq9v52Xz+3
mT+PlCbapW6Vs2Mn++4xNpYFw5WHV8OwZCboBzCgBj0k9uDcBpleuJOV9JgNNVU8
ZhstvNgVL7+sQGmd9TfBiwTlNnbFQLHaSvhIerR81PDuUzP0X/C20jclLjTAEyIj
3bNoCMjqXO4gnfxZ/jnKCwYn/DxON6B2LiiQypRzya3wuEq7wzlvPiG3eg2w59H0
Le4FiaAWy1UQCT359a3vVL1BK+9Ax8kS/8NJfYlaKa8D0guydu4DhVFRlQrwX732
DTn9BqyiaCthMT//OxC0zE3WjUL3s03Y22iiV8GQpfRHqu7bqbR3lIV32XpDP1Hh
8ciiHQQgUfI=
=wSt+
-----END PGP SIGNATURE-----

--nextPart1550477.nZ2r2BMeEE--

--Boundary-00=_rRnvFEv/pxXYrZz
Content-Type: text/x-diff;
  charset="us-ascii";
  name="linux-netfilter-dont-use-type-names.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="linux-netfilter-dont-use-type-names.patch"

Use diff variable names than the standard type so we can run automated script
checks on the code to easily pull out export violations.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>

--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -82,10 +84,10 @@ struct xt_get_revision
  */
 struct _xt_align
 {
-	u_int8_t u8;
-	u_int16_t u16;
-	u_int32_t u32;
-	u_int64_t u64;
+	u_int8_t align_u8;
+	u_int16_t align_u16;
+	u_int32_t align_u32;
+	u_int64_t align_u64;
 };
 
 #define XT_ALIGN(s) (((s) + (__alignof__(struct _xt_align)-1)) 	\

--Boundary-00=_rRnvFEv/pxXYrZz--
