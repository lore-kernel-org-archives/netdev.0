From: maximilian attems <janitor@sternwelten.at>
Subject: [PATCH 1/5] tun check error on memcpy_fromiovec
Date: Fri, 19 Dec 2003 11:34:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031219103457.GD1213@mail.sternwelten.at>
References: <20031208202302.C30587@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="m1UC1K4AOz1Ywdkx"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031208202302.C30587@build.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--m1UC1K4AOz1Ywdkx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

hey chris,

after applying your 4 patches on top of linux-2.6.0=20
+ experimental net,=20
found 2 last unchecked memcpy_fromiovec in tun.c
patch bellow fixes the second call,=20
the first is beyond me, please complete this patch :)
compile tested

thx max



--- linux-2.6.0-net/drivers/net/tun.c	2003-12-19 11:27:38.000000000 +0100
+++ linux/drivers/net/tun.c	2003-12-19 11:19:33.000000000 +0100
@@ -193,7 +193,10 @@
 	}
=20
 	skb_reserve(skb, 2);
-	memcpy_fromiovec(skb_put(skb, len), iv, len);
+	if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
+		kfree_skb(skb);
+		return -EFAULT;
+	}
=20
 	skb->dev =3D tun->dev;
 	switch (tun->flags & TUN_TYPE_MASK) {

--m1UC1K4AOz1Ywdkx
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/4tRR6//kSTNjoX0RAh2AAJ0TzczOCySrZGsg4TRzYzZBBYzx8ACfbQz/
pnT5LJVmA0V4043IJlxuOvE=
=cqMQ
-----END PGP SIGNATURE-----

--m1UC1K4AOz1Ywdkx--
