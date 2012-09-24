From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the userns tree
Date: Mon, 24 Sep 2012 22:18:59 +1000
Message-ID: <20120924221859.b3f8fbc112ed7ff305b93512@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__24_Sep_2012_22_18_59_+1000_mG7M/WibNbRQUYBd"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__24_Sep_2012_22_18_59_+1000_mG7M/WibNbRQUYBd
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

After merging the userns tree, today's linux-next build (x86_64
allmodconfig) failed like this:

kernel/audit.c: In function 'audit_receive_msg':
kernel/audit.c:753:37: error: 'struct netlink_skb_parms' has no member name=
d 'pid'

I missed the conflict between commit 35ce9888ad2a ("audit: Properly set
the origin port id of audit messages") from the userns tree and commit
15e473046cb6 ("netlink: Rename pid to portid to avoid confusion") from
the net-next tree.  I have added the following merge fix patch and can
carry it as necessary.

=46rom 55a9ee70146f37c559333b1f35154618c708203f Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 24 Sep 2012 22:05:38 +1000
Subject: [PATCH] audit: fix up for pid to portid change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 kernel/audit.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index ea9b67a..4d0ceed 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -750,7 +750,7 @@ static int audit_receive_msg(struct sk_buff *skb, struc=
t nlmsghdr *nlh)
 					size--;
 				audit_log_n_untrustedstring(ab, data, size);
 			}
-			audit_set_pid(ab, NETLINK_CB(skb).pid);
+			audit_set_pid(ab, NETLINK_CB(skb).portid);
 			audit_log_end(ab);
 		}
 		break;
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__24_Sep_2012_22_18_59_+1000_mG7M/WibNbRQUYBd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQYE+zAAoJEECxmPOUX5FE5rcQAINEUOeO0+eykO5QGURPqWlV
1+ClzSUyrxinrXNJw3N95HdDhRDXGJvQF6yKj9P/BqJ2W6D87VNEZj/eLXVvLHUg
Dtkwo9Qvd/BzAx7wsr4CWgl4gzVWL+yBnubw2yUNU4AO3jRlWIiJUgDTd4/zWot5
TiT1Lmr3jdWM3H5KflISieEjh5mrlu/meYMpkE6BKRjwq3p6eAotOV+zHa59b3G7
zdCoWz0ydALDREClJFGJy7ypANdveoWlGYgpXz82h8J4fepIAUlpDjnex9XqaTPN
mV43j3N3QwW9PmSp6mZ6Cxr5E+s5m2fdL8sN+NB8XnFgEkTx3v4VhJ9W5mm5d+51
B34Gjt1r814PoOyWDC/plGBKwJkQxiO+G5TSLvrFXruK+xZWw/OXtzpS0iGM+Dr2
ybqkG5um2nLUsF9PYlen63RUSEHI7YultEu6GS0d3dCnEQq9mfLzXVPlQWHcPKZS
6iJAqCGZRFDyLhdcNN6h/Y6KVWwx2S8qVjMni0Q4Nl7Kez42hxPtCA0eLsCPORKg
9zLcp89xx9XUjQZ4L5SedJNlEe/7CPHw3r5u16ffc3IZXNGqIPDp2pqdgiZBDN91
UBXO9ucGgUdgohoaH6+pqdaFIo3Hz326WJncHYc5SAqbZnC89Durgv1bgGf/ZgeJ
gsino7V7oWKywIh42kPF
=xlif
-----END PGP SIGNATURE-----

--Signature=_Mon__24_Sep_2012_22_18_59_+1000_mG7M/WibNbRQUYBd--
