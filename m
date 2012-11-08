From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Fri, 9 Nov 2012 10:53:18 +1100
Message-ID: <20121109105318.e24e2fa2b899af6e4d444b30@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__9_Nov_2012_10_53_18_+1100_1.mq6L.2UhwDPvZR"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Merav Sicron <meravs@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__9_Nov_2012_10_53_18_+1100_1.mq6L.2UhwDPvZR
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c between commit
477864ddd365 ("bnx2x: Disable FCoE for 57840 since not yet supported by
FW") from Linus' tree and commit 55c11941e382 ("bnx2x: Support loading
cnic resources at run-time") from the net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index bd1fd3d,0546cf4..0000000
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@@ -11899,22 -12065,10 +12066,20 @@@ static int __devinit bnx2x_init_one(s=
tr
  	/* calc qm_cid_count */
  	bp->qm_cid_count =3D bnx2x_set_qm_cid_count(bp);
 =20
- #ifdef BCM_CNIC
- 	/* disable FCOE L2 queue for E1x */
+ 	/* disable FCOE L2 queue for E1x*/
  	if (CHIP_IS_E1x(bp))
  		bp->flags |=3D NO_FCOE_FLAG;
+=20
 +	/* disable FCOE for 57840 device, until FW supports it */
 +	switch (ent->driver_data) {
 +	case BCM57840_O:
 +	case BCM57840_4_10:
 +	case BCM57840_2_20:
 +	case BCM57840_MFO:
 +	case BCM57840_MF:
 +		bp->flags |=3D NO_FCOE_FLAG;
 +	}
- #endif
-=20
 +
  	/* Set bp->num_queues for MSI-X mode*/
  	bnx2x_set_num_queues(bp);
 =20

--Signature=_Fri__9_Nov_2012_10_53_18_+1100_1.mq6L.2UhwDPvZR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQnEXuAAoJEECxmPOUX5FEP00QAIrY1EAHh1MVpVIFwcijQ6Hj
NZ+U01SQfLOXikbm98uLcHgHeAOrUZu+I4potFHCqwIAJZRegeTf7siPptvv0q+0
Y2hW6F4qbvr6Pl8dbx71BIzl3zgh0jgfMx+9U2VgB18+6aOZeDcvut1w0bZBkl4z
TMC0ONivXxPYgQUY7Y7IJw2ds95jdoe97eCUxtlwQzwk/CZw35FjbJenCMPv3vt8
cRmD5JPBumztpPqRNYCbwLx3ZdRvLun0wO3Fvnx9XomK/kFa+LdYxKNsxEpk0rjK
4j5FqBKYMNN7v+N59QrzWfkNqE1akZnGEzlH6JCagGx9L6z0wAM/VTfUiwc2DDBY
a0m1cm8VdndaemQ8TcXQXHxcCa98KU38FCRQY5LJo0t5in/9rU0Fy5koBRqit0rA
J6x+z74f8m+EwfarbqmKdbCfS8w66JE7XkdiTT9k257QB7FcWtbGXMS1N+JcMdVu
sUFsbGx/JEbonsjDB9o/QGc/ElI0gGAjDCUyty2jg+N/l1xNlU3Qh/oRAWvk8pex
R5od2rAS4eOWjBbYQ1wKU2RefEQkrgUW8QwoFDKoiGeUM4uCi4XrkIsJSroo8AwS
EZfgALjxEPPdK6Dsr04naNH0wNxMp6SqEjF9gzSDm9RtHuRKWM+44KwTyQxp415D
pzC//v6QxU3EW7pTgPCs
=Fub3
-----END PGP SIGNATURE-----

--Signature=_Fri__9_Nov_2012_10_53_18_+1100_1.mq6L.2UhwDPvZR--
