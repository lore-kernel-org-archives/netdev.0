From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Tue, 23 Apr 2013 17:46:18 +1000
Message-ID: <20130423174618.59095bd1cf999c61332d4805@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__23_Apr_2013_17_46_18_+1000_05e+C9Y1BSG8sqy7"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:59511 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab3DWHqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 03:46:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__23_Apr_2013_17_46_18_+1000_05e+C9Y1BSG8sqy7
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/netlink/af_netlink.c: In function 'netlink_frame_flush_dcache':
net/netlink/af_netlink.c:384:40: error: 'NL_MMAP_MSG_HDRLEN' undeclared (fi=
rst use in this function)

Caused by commit 9652e931e73b ("netlink: add mmap'ed netlink helper
functions").  This needed to be build tested on an architecture that has
ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE set to 1 (like Sparc :-)).

I added the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 23 Apr 2013 17:40:35 +1000
Subject: [PATCH] netlink: fix typo in net/netlink/af_netlink.c

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2a3e9ba..da5601d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -381,7 +381,7 @@ static void netlink_frame_flush_dcache(const struct nl_=
mmap_hdr *hdr)
=20
 	/* First page is flushed through netlink_{get,set}_status */
 	p_start =3D pgvec_to_page(hdr + PAGE_SIZE);
-	p_end   =3D pgvec_to_page((void *)hdr + NL_MMAP_MSG_HDRLEN + hdr->nm_len =
- 1);
+	p_end   =3D pgvec_to_page((void *)hdr + NL_MMAP_HDRLEN + hdr->nm_len - 1);
 	while (p_start <=3D p_end) {
 		flush_dcache_page(p_start);
 		p_start++;
--=20
1.8.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__23_Apr_2013_17_46_18_+1000_05e+C9Y1BSG8sqy7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRdjxKAAoJEECxmPOUX5FElJYP/2R8Ywv6kZrjU46NYhpA35ES
j67owH0er21qTh0EHaokq1Zn90NT0AsMetUzH0xNi1kR1inZNA2QM5/5ZYGbdYG/
hWu5ZQAkO+7R6za9jRk08h/Wgt21nnryvcylRxikTeGVBLT5q06MzLwHt+j0T1aW
ZxdstV1e7YD0o71MLZAuo/hKdiMjGSwG4dPwytmvd5oJCaycJWpT9SzoXPDBGaW2
N8zcrsOgNx4sO9zmy8kgoZxexhhAzuFRM5VhCCUMOOdm6oFPLAWikptMX6TmotRJ
07eC4CC81udtwYtOag665swCEp7icVGe/yDCQZxOXr3Eq/TeSPMiyv+CwGwhvqYq
b9LSTYfXwnpaYonQ45JdPkVs/ZB+IpkAq6dt+4N9/chxggT+9x6Di4XWzjC7XOhU
w/gD/OdktHYdyMPPoA93lPlz1e9HLBpNbGFZV/AXu3JeGUjDXzBnyr1cWMQJ/Js4
MDsOf4V7LdTNcw9yzkuNSp1Os474bOEeBbra5PTCjmBNHwdGAAc8uR/655HAwuGT
RwrIXPO2pqjB7HyOSW375q0yaxfgy/AVfk94PTre5OaXnm7XdTPlyAkSGqVLbmb2
F/oSSJePYGl8JoiGOWpOAu+cUkgwMtNrYm4eTp+lgRm47AeV3UHe3L8+VVaQdcMW
CCOQNi+rox3NgwoCARYj
=HVca
-----END PGP SIGNATURE-----

--Signature=_Tue__23_Apr_2013_17_46_18_+1000_05e+C9Y1BSG8sqy7--
