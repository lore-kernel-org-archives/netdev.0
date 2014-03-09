From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] bna: Replace large udelay() with mdelay()
Date: Sun, 09 Mar 2014 04:03:22 +0000
Message-ID: <1394337802.2861.71.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0CdENdSBsUtJha3WqZbA"
Cc: Vagrant Cascadian <vagrant@debian.org>,
	Rasesh Mody <rmody@brocade.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49486 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752356AbaCIED2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 23:03:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0CdENdSBsUtJha3WqZbA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

udelay() does not work on some architectures for values above
2000, in particular on ARM:

ERROR: "__bad_udelay" [drivers/net/ethernet/brocade/bna/bna.ko] undefined!

Reported-by: Vagrant Cascadian <vagrant@debian.org>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ether=
net/brocade/bna/bfa_ioc.c
index 1803c39..354ae97 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1704,7 +1704,7 @@ bfa_flash_sem_get(void __iomem *bar)
 	while (!bfa_raw_sem_get(bar)) {
 		if (--n <=3D 0)
 			return BFA_STATUS_BADFLASH;
-		udelay(10000);
+		mdelay(10);
 	}
 	return BFA_STATUS_OK;
 }


--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-0CdENdSBsUtJha3WqZbA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxvoCue/yOyVhhEJAQqZ3w/9EVJphhdlke0wA++msHs3ZJnwp/L54dr7
/ZlAZphyDl6oWVsYuL68dIt5YAGndsUNcfvnpOrM+QnqZxfheXov9wycFmauePLL
wv5k6mlwxDbj1Ve3PDV+6I/ECyG7tmaVsAJYrm7mosYpmAWpveTBA9GWhE0wJUom
ZXKn62LfXCE5V/vQe7HEGFxH7g7rlTZ/McTwPZ3OodcSp8/un5TKbVgAt462g6OQ
TfF+NwjOJjMs5lVB7BTe3+FwLB+v6IdUyPL0jhS+oYi4gmiM3c9VWxE0eButZBLl
ebPGvuFamGOOK7Cc7KhoVLaYlYVR5+oPH+L8RZd6bm9Zz1rTVEMqdGKjmLtWKE4o
E8RyeuJbDtwvbpaA/xtP58V560gUmNMHPl/ciFEcqbBLRnBhPlapDXYyxsJGq5Nw
0c58FhoUjMsROS76Q90zY2M6eEOF3Ol8MuhBkQtUQ35BkUKnmEQ2gZ8xxMb3VWVe
yKSqlM9NPcXjL44ay2wO55DdAtrJaU/HDarPST+0tlpZZPHhieSfJ9SZSLNM6k6U
u49y8jTuse/mBr65cLGI+r7zm/IwgI4nivKC8n3lGmrURkp7TCRAGZWlS7PDufNL
YcRb/ZQN54L2F0yV53gkD2eqBedSEjC6HKJc6ZtZS3lX9ZtA0NF6b3H+pLCc9T0L
LnA8tWTLDsc=
=48dO
-----END PGP SIGNATURE-----

--=-0CdENdSBsUtJha3WqZbA--
