From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the bluetooth tree with the
 net/net-next trees
Date: Tue, 7 Jan 2014 12:54:18 +1100
Message-ID: <20140107125418.986ae20298ddc55e5e657447@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__7_Jan_2014_12_54_18_+1100_pXUNO9WrbAEk9dYH"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Jukka Rissanen <jukka.rissanen@linux.intel.com>
To: Gustavo Padovan <gustavo@padovan.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47545 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756026AbaAGByY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 20:54:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__7_Jan_2014_12_54_18_+1100_pXUNO9WrbAEk9dYH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Gustavo,

Today's linux-next merge of the bluetooth tree got a conflict in
net/ieee802154/6lowpan.c between commit 965801e1eb62 ("net: 6lowpan: fix
lowpan_header_create non-compression memcpy call") from the  tree and
commit 8df8c56a5abc ("6lowpan: Moving generic compression code into
6lowpan_iphc.c") from the bluetooth tree.

I fixed it up (I applied the following patch to move the fix into
6lowpan_iphc.c) and can carry the fix as necessary (no action is
required).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 7 Jan 2014 12:52:43 +1100
Subject: [PATCH] net: 6lowpan: fixup for code movement

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/ieee802154/6lowpan_iphc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
index 11840f9e46da..e14fe8b2c054 100644
--- a/net/ieee802154/6lowpan_iphc.c
+++ b/net/ieee802154/6lowpan_iphc.c
@@ -677,7 +677,7 @@ int lowpan_header_compress(struct sk_buff *skb, struct =
net_device *dev,
 			hc06_ptr +=3D 3;
 		} else {
 			/* compress nothing */
-			memcpy(hc06_ptr, &hdr, 4);
+			memcpy(hc06_ptr, hdr, 4);
 			/* replace the top byte with new ECN | DSCP format */
 			*hc06_ptr =3D tmp;
 			hc06_ptr +=3D 4;
--=20
1.8.5.2

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__7_Jan_2014_12_54_18_+1100_pXUNO9WrbAEk9dYH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSy15NAAoJEMDTa8Ir7ZwVD8oP/jLeNt9+GSp7/2inuRNsPNNi
m0Nvz2Yw4fbPyPKel5z/Tx2mkwYTxkyUbYz/RWqJ2nKxv+2DYkyz9QsDokI0aCw0
XUmSTSML0EDNGmAyIVHIkKRonFGPNkOSgbjJdkyaNTT74TJ5segwnCTS4fkTJskz
DxcA0GaZoM3Wvp/hCNKBcIBxKG880a59Q/8ajOZr7q25pNMuJCSDr8eZZMY6Nx+u
0PgLb5HM1yOy3y2SpC1HlRFi/PcFqTsyV7I7f6MMAYRbhPaqnjaLTr4rZoS61p/H
JtjI3VUvg/aJ3atlGM0FkvcYPFzzZI+oOFanyUx4uRPhDJmV+m2Syk/faR8bHlb9
WqdAs6/o002/7dUi/Sm+R8Gwvq5dYEh97zz1utFogOWLXYG7RGZo1qDRlD9tvpNB
cl7pesVAENPflxUQK+uEEKdKdYFqL2E55wM3MbjJoXCw/3zd/pLcR45rN7fnEhO7
9ZuYVm9abbrAE9z9bPe2Aga53mGxKPSb+VOkuMY/JB2ruzAJ787Njyhpqr54U5wV
z5TSzlPx6ciXKCO1juKQwC0+48qPkugi1Jc/CsB0jyIK1oi0iwDmxHSZUV7i/ehz
H9cozZ5UN85h8jK92RYBi9EmQprcJv/+DUM5YtuHhJYnDx3WmezXVNT+TMdBYP5E
+unY4gvPKB735WBeVT9w
=cE6f
-----END PGP SIGNATURE-----

--Signature=_Tue__7_Jan_2014_12_54_18_+1100_pXUNO9WrbAEk9dYH--
