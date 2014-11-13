From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 13 Nov 2014 11:35:55 +1100
Message-ID: <20141113113555.15117365@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/6fVwv1pMQtxv3BlPgR=FAad"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/6fVwv1pMQtxv3BlPgR=FAad
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/chelsio/cxgb4vf/sge.c between commit 65f6ecc93e7c
("cxgb4vf: Move fl_starv_thres into adapter->sge data structure") from
the net tree and commit aa9cd31c3f3e ("cxgb4/cxgb4vf: Replace
__skb_alloc_page with __dev_alloc_page") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index fdd078d7d82c,cd538afa40dd..000000000000
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@@ -608,8 -614,7 +610,7 @@@ static unsigned int refill_fl(struct ad
  		goto alloc_small_pages;
 =20
  	while (n) {
- 		page =3D alloc_pages(gfp | __GFP_COMP | __GFP_NOWARN,
- 				   s->fl_pg_order);
 -		page =3D __dev_alloc_pages(gfp, FL_PG_ORDER);
++		page =3D __dev_alloc_pages(gfp, s->fl_pg_order);
  		if (unlikely(!page)) {
  			/*
  			 * We've failed inour attempt to allocate a "large

--Sig_/6fVwv1pMQtxv3BlPgR=FAad
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUY/z2AAoJEMDTa8Ir7ZwVopcP/RoOjZWEtE0FN0k7u08FM4Vr
B5RSIAXNctLg1RomUFjOY/UANA8VdjiiEe+0BtF6cDyAEAVUWQmBNg1DvfOmmSi7
rUXPAdnjHFh2uC+djYoyHlOydhlGjlxzPaEQKKw6Ry6Y/brLV21XuXIYlinfbBZW
3IGJxW4ohKceAel3flabj+NIYASZJ/9PPhuyTASWxVupJ+Fm1v5UhQq7HxPKsGDb
47WA2+Zw/TCPdatyyDKBi6KyOfoIHc2ByLdOXybC5msuo5ONxFocNERthaEdWtMB
cW/n35/FXHi9+4FqI8I4Y4RI7x1e9b+nQrY6C2WIViqeOXFQAucdFXkpsvIRRZMe
JP8Q/FV1nZs9WAgwJ6N2MFl9UQOewbAyZDoh5+KTfd+LRF2haS9bKTQTZSCJVy6P
/Vat8+7WRMjw15pAXm5R4gRG+3hZ68dPK4D1TYjbmsnvjGl3tRs2HA5SvnwVoZVx
AsfpNhxUKxIfgw1TeY3JpJ1kTx+9134IfENBD1Vh0cv9q9BqkOU0OX9ABx3zuzum
ATjxyB8VrwzGs9HvZsl0Je6ixPQ+Q8EPx4VIufZYWvqcAoBqH70I1uv3e0Wfl77T
aiAB4mjgJIuYdT0bMVuRXxRydB9ogtFwVGHSot491mZ4ikDw1XiIFi/bsVc8jO68
f/6LIQvgK4Jy/bzHMnwc
=j0ei
-----END PGP SIGNATURE-----

--Sig_/6fVwv1pMQtxv3BlPgR=FAad--
