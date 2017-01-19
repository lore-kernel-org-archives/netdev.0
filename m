From: Alexander Heinlein <alexander.heinlein@secunet.com>
Subject: Re: [PATCH] ip/xfrm: Fix deleteall when having many policies
 installed
Date: Thu, 19 Jan 2017 08:57:56 +0100
Message-ID: <51b5293a-bce8-b663-f9de-97dc7c8113b3@secunet.com>
References: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
 <20170118090302.6efd6cce@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature";
        boundary="Bic70jE9rLDC2l2Djgrxs2d17DAPNQXpj"
Cc: <netdev@vger.kernel.org>, <shemminger@osdl.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46864 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751222AbdASIFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 03:05:25 -0500
In-Reply-To: <20170118090302.6efd6cce@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Bic70jE9rLDC2l2Djgrxs2d17DAPNQXpj
Content-Type: multipart/mixed; boundary="m9ox5M0M7ttJSI4br7d2TKphwDtN1HR8E";
 protected-headers="v1"
From: Alexander Heinlein <alexander.heinlein@secunet.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Message-ID: <51b5293a-bce8-b663-f9de-97dc7c8113b3@secunet.com>
Subject: Re: [PATCH] ip/xfrm: Fix deleteall when having many policies
 installed
References: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
 <20170118090302.6efd6cce@xeon-e3>
In-Reply-To: <20170118090302.6efd6cce@xeon-e3>

--m9ox5M0M7ttJSI4br7d2TKphwDtN1HR8E
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

=46rom 192cf19b3a97871a508ad57ba5893d1719877f13 Mon Sep 17 00:00:00 2001
From: Alexander Heinlein <alexander.heinlein@secunet.com>
Date: Mon, 16 Jan 2017 14:48:25 +0100
Subject: [PATCH] ip/xfrm: Fix deleteall when having many policies install=
ed

Fix "Policy buffer overflow" when trying to use deleteall with many
policies installed.

Signed-off-by: Alexander Heinlein <alexander.heinlein@secunet.com>
---
 ip/xfrm_policy.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index cc9c0f1..451b982 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -732,10 +732,8 @@ static int xfrm_policy_keep(const struct sockaddr_nl=
 *who,
 	if (!xfrm_policy_filter_match(xpinfo, ptype))
 		return 0;
=20
-	if (xb->offset > xb->size) {
-		fprintf(stderr, "Policy buffer overflow\n");
-		return -1;
-	}
+	if (xb->offset + NLMSG_LENGTH(sizeof(*xpid)) > xb->size)
+		return 0;
=20
 	new_n =3D (struct nlmsghdr *)(xb->buf + xb->offset);
 	new_n->nlmsg_len =3D NLMSG_LENGTH(sizeof(*xpid));
--=20
2.1.4


--m9ox5M0M7ttJSI4br7d2TKphwDtN1HR8E--

--Bic70jE9rLDC2l2Djgrxs2d17DAPNQXpj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd9SQ6eG5LDb5ryJLIdvqUoU0W6kFAliAcYUACgkQIdvqUoU0
W6nXtBAApzMaJvQGEG0G7qw+ok2lmw6Es5DGQGjgQ6BPKl5avZy6czS4PyKASM56
EvR6xXsinVrw7/iOI/HvTCfYAnfVNd+tGbakO4FCI/teXujBM1mPUvJcigIpY3WN
8b4SNRLDnumuZQKWCVonxUAs5rR/xuYg/99Y9rKP/vmPIKWooGYIVvbYrhRoByWJ
FlAuEH8gG9+RyiMvzhYinQ7Q+pVBRW0pWqvV4G9F9UUygfiVBm/UsejiEaZvLrR/
wHx+zxNRAaH3Bcoy/27aq1Ohpt27vdS73lqDPYsAiWxpA09rEy1NDUWTkI7ZhSbX
r1lVGyl8SL20Bj508xuNU1ztjuFTDmvVUQmpnx+X+t4v/7APOtgIoQLL2Bqelwes
Mz+FM0Yfwu0qb0jLBO2H4PElLw4ohIMQtic+ogsBzcaCO8xaWXemmvjVZmjoVNd8
QnTCOHYDh965gBMYmFwAtVs9z7jK1kDSuvgVAE6eYXkt5wui4qXyqNi8mTXVEFIt
yM51wPt5GANokSk/T9HtgTd5+sVErlDK59lJprWueuONdeAAHbAxjuqf1e0Qz/or
z94jDK79gUVsC3F4uWDmJWMM1CVe8LE3XdA7GUBIcSNBwxdb4JipJF8tMEkl+E2p
9q+SaL6JW0uYbHEHZQRixeKZSUWsysspfBiWcKc5r3ORWwqTHcM=
=rcqp
-----END PGP SIGNATURE-----

--Bic70jE9rLDC2l2Djgrxs2d17DAPNQXpj--
