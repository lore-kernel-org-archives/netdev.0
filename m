From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch] do not rely on OPEN_MAX
Date: Mon, 15 Oct 2007 01:50:58 -0400
Message-ID: <200710150150.58591.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_C/vEHWPo3P/LMup"
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:37707 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752561AbXJOFww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 01:52:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_C/vEHWPo3P/LMup
Content-Type: multipart/signed;
  boundary="nextPart2834394.OBMPZvoHe8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2834394.OBMPZvoHe8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

the OPEN_MAX define was removed from the kernel's limits.h during the 2.6.2=
3=20
development cycle, so switching to using the dynamic sysconf() func should =
be=20
done
=2Dmike

--nextPart2834394.OBMPZvoHe8
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iQIVAwUARxL/wkFjO5/oN/WBAQLflg/+IB8AoUTFok5Mz25t5UWKB+SyUo6QoBHf
sphuoHO/J6rLZUvkjMJTj2VheHCnWm9mIBDsVKbFo2tnOKH84IPynu19RXjfqhYF
XjBwxGPRfkPk2NdNryjQfQNu1Ti/oT2E9jtMoMfjLUKcDYRIyDJM8oiLR6GwYQl3
v1qkzLR/dppNE9+ocoVzaS2KnWXrUI9QWc46SXoXoz3RXLPqyfJ7sYQcWqMn07w2
ZeLfhjTWN6Yf38fdQlg+bWmgx4Gw5v7Yp/aVlQ9CGoxm+Ox3InqV3ZkVEAHpvK0i
Nwrhyu04kSHo1Z8qyZdt934RTyEtKVaA3QCV/ZVHpWednFLKYhXaP5CvgYeDl36C
MPvT/vC2nmCAR4Kg72cVwmQ7lkxoUyqs6In35Agzx0H/qiSYRvzM6OhICDSOQie3
g4atkT2kDtg7s/+KUx4phRoUy4ERRcByBVVoyCjJDQ3COKUoOErhVOrMiXYPgYk3
zgsuRKa5rl9fufdOH9X7DBBsSX2P8vFvUagyocHGlh5nmMFrGAqgifRYjAfDjCNv
Fz1a4RE1F/J7ZWl9ZWTpQ2CRA1/NASCuE5MZvNQ5EBuXnOaY7TCes7LyV1PDfVf+
9MNP+Qpp4duZ29SafCVTLU27M92blVD5gDP1mi64A6In1K+yc1o0lcdWFeaKm7WP
Fc2i7yQZb5M=
=nQ04
-----END PGP SIGNATURE-----

--nextPart2834394.OBMPZvoHe8--

--Boundary-00=_C/vEHWPo3P/LMup
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iputils-20070202-no-open-max.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="iputils-20070202-no-open-max.patch"

the OPEN_MAX define has been removed in newer kernel headers so use the
proper method of getting the value dynamically

http://bugs.gentoo.org/195861

--- a/rdisc.c
+++ b/rdisc.c
@@ -247,7 +247,7 @@ void do_fork(void)
 	if ((pid=fork()) != 0)
 		exit(0);
 
-	for (t = 0; t < OPEN_MAX; t++)
+	for (t = 0; t < sysconf(_SC_OPEN_MAX); t++)
 		if (t != s)
 			close(t);
 

--Boundary-00=_C/vEHWPo3P/LMup--
