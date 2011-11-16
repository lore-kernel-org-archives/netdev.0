From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next v2] 6LoWPAN: double free in lowpan_fragment_xmit()
Date: Wed, 16 Nov 2011 11:36:43 +0300
Message-ID: <20111116083643.GA25612@mwanda>
References: <20111116083254.GB4349@mwanda>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:34090 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab1KPIfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 03:35:52 -0500
Content-Disposition: inline
In-Reply-To: <20111116083254.GB4349@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

dev_queue_xmit() consumes its own skb, so the call to dev_kfree_skb()
in lowpan_fragment_xmit() is a double free.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: fixed commit message.

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 602f318..e4ecc1e 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -980,9 +980,6 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
=20
 	ret =3D dev_queue_xmit(frag);
=20
-	if (ret < 0)
-		dev_kfree_skb(frag);
-
 	return ret;
 }
=20


--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOw3YbAAoJEOnZkXI/YHqR9h8P/1SXx1YrEaJPWnwsscee1q+q
l0lArnYFrxXH8FCelU9+5cqxBYVdatnCSHF/YYtLsSdZu8vEPwJAKLbYbthmZlSl
duZeR8HFcBPxf2gkuRMJEE4Ywk6VmCugraS/WmWFJzuZ/pwWUvh8s0L3LWZFNEgo
YXLRDhRP1k2IDG4iNRhuKvXwPtarYCyNY7mOlwfJ+TPWPUjC/dlggnp1BgHjCvgY
xqSeia/TVGHv5iRHovt4m3Og9/vXCt9e17Pvdv1m7KwwBxUd1HdEfhljAem0lfCV
wuwV1XZl0tyV2/awfjayI/G96/ojGLzddo5VTO610iTDiQQWu6BLgQ+t/8ICat89
qDWFk0az5ZTkE7bhE900o5o6RSUsJT/shgFu9UiJDaeFf9qST/J90j6EZZEobm6X
KvZkFskdvT1HZYaiHVufIAY7aIc9lSaVI8Y9ZtXb4BUjMXSTgUeq97C5a4fQKeJw
7KrmCaYqj+DyHqmADhSs/b7CH5VOPLKiV52YqpMl4qrgbEFXthtifGtfuJ6FL6LM
lzxFQOqATHTXQQnxuV/MeQdqkxt/Vl/KeD/uApz8OZ8Rb+/TiZjCZKqQhVieRqLK
zEybWg+u3/c2XboaQxmTlXjofqNORgTiAYKTdyLCUZTnRI6hQ4B9YlvMVbZKke6n
jG4QbzFU++qCldh7SlGe
=bbxK
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
