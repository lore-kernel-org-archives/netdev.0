From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the ceph tree
Date: Tue, 8 May 2012 13:09:48 +1000
Message-ID: <20120508130948.066bcfb7f7742d039c2db5d3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__8_May_2012_13_09_48_+1000_OTCCoMbxcU_QKdOx"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sage Weil <sage@newdream.net>, Sage Weil <sage@inktank.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__8_May_2012_13_09_48_+1000_OTCCoMbxcU_QKdOx
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ceph/osdmap.c between commit 8b3932690084 ("crush: warn on do_rule
failure") from the ceph tree and commit 95c961747284 ("net: cleanup
unsigned to unsigned int") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ceph/osdmap.c
index 2592f3c,56e561a..0000000
--- a/net/ceph/osdmap.c
+++ b/net/ceph/osdmap.c
@@@ -991,11 -998,12 +991,11 @@@ int ceph_calc_object_layout(struct ceph
  			    struct ceph_file_layout *fl,
  			    struct ceph_osdmap *osdmap)
  {
- 	unsigned num, num_mask;
+ 	unsigned int num, num_mask;
  	struct ceph_pg pgid;
 -	s32 preferred =3D (s32)le32_to_cpu(fl->fl_pg_preferred);
  	int poolid =3D le32_to_cpu(fl->fl_pg_pool);
  	struct ceph_pg_pool_info *pool;
- 	unsigned ps;
+ 	unsigned int ps;
 =20
  	BUG_ON(!osdmap);
 =20
@@@ -1027,7 -1045,8 +1027,7 @@@ static int *calc_pg_raw(struct ceph_osd
  	struct ceph_pg_mapping *pg;
  	struct ceph_pg_pool_info *pool;
  	int ruleno;
- 	unsigned poolid, ps, pps, t, r;
 -	unsigned int poolid, ps, pps, t;
 -	int preferred;
++	unsigned int poolid, ps, pps, t, r;
 =20
  	poolid =3D le32_to_cpu(pgid.pool);
  	ps =3D le16_to_cpu(pgid.ps);

--Signature=_Tue__8_May_2012_13_09_48_+1000_OTCCoMbxcU_QKdOx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPqI58AAoJEECxmPOUX5FEYDUP/Ru1IO148hWw6W2/8o+1JfD6
bV3J1sr0N7ZVAkQ+JV8Tk8fo2SV0Wnhop7vqFq6rmW4hh5mrvmEPOPCzIOh5Kpoi
797Xd7/gi6Y76Ir06RH2Bhzg6s1NMKUdrXhFSgGm3xlv0PUwctY/8Wv2UFYr3dTN
As6OfCApWzMv5g5Uu4tni2W4wHxLAgAWaeaa2m7tjoPYR4xRmSJo2kUtpO11+5Qt
/DZ2VEBy5oOvGtWem16Njaj3WPzU0evBQIlegZAvChzCfPHkgOP3aXVWvrDgzKaZ
Jk1pAs/EE6Zh7Eh+N/3HzKSWXdhG9BMyw9phZw4liO5qCUkzw+af969ffVWYD1rY
YaDER7BOxIkXxO214rOOkdujPEolbNG1SWEp92MzFmraGiVsdF11VkBA27AqGAyD
3RCzpu9Nu7RoR3cYqP7pQ1rbjmCVJkkZ09hWZFLa9xYBMj5JEoDdbehMDXFIbChz
IBKalcSbRG9j60OacdGNjCAc3g/HOj9AyDYy3PuaKVH/dWa/tzsR0D+te9dCCCla
kYF+bxaQTV5mVUqzCaSB7juCLfQvOTY8tGYorekSqv3TSCE76ZsnwDg3fcKnxXmy
dqLQC5mf4HvE99yz+5GBBQB+pQI6ZrR+w5JJ4mcpcFvTiUwIiS5mg1wgoWbw0pbM
cth225k2JA3Fkt9NAN9z
=HlS9
-----END PGP SIGNATURE-----

--Signature=_Tue__8_May_2012_13_09_48_+1000_OTCCoMbxcU_QKdOx--
