From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 22 Apr 2013 13:09:39 +1000
Message-ID: <20130422130939.9162d4f519402dcfc4cdbe0c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__22_Apr_2013_13_09_39_+1000_haU4jeNQ36pD63Ll"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__22_Apr_2013_13_09_39_+1000_haU4jeNQ36pD63Ll
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
include/net/scm.h between commit 83f1b4ba917d ("net: fix incorrect
credentials passing") from Linus' tree and commit 6b0ee8c036ec ("scm:
Stop passing struct cred") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).  I also applied the following merge fix patch (I am not
sure if this is correct, but it seems to be consistent):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 22 Apr 2013 13:06:10 +1000
Subject: [PATCH] net: af_unix fix for incorrect credentials passing

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/unix/af_unix.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5ca1631..9efe011 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1414,7 +1414,7 @@ static void maybe_add_creds(struct sk_buff *skb, cons=
t struct socket *sock,
 	    !other->sk_socket ||
 	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
 		UNIXCB(skb).pid  =3D get_pid(task_tgid(current));
-		current_euid_egid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
+		current_uid_gid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
 	}
 }
=20
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/net/scm.h
index b117081,5a4c6a9..0000000
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@@ -81,8 -75,10 +75,10 @@@ static __inline__ int scm_send(struct s
  			       struct scm_cookie *scm, bool forcecreds)
  {
  	memset(scm, 0, sizeof(*scm));
+ 	scm->creds.uid =3D INVALID_UID;
+ 	scm->creds.gid =3D INVALID_GID;
  	if (forcecreds)
- 		scm_set_cred(scm, task_tgid(current), current_cred());
 -		scm_set_cred(scm, task_tgid(current), current_euid(), current_egid());
++		scm_set_cred(scm, task_tgid(current), current_uid(), current_gid());
  	unix_get_peersec_dgram(sock, scm);
  	if (msg->msg_controllen <=3D 0)
  		return 0;

--Signature=_Mon__22_Apr_2013_13_09_39_+1000_haU4jeNQ36pD63Ll
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRdKnzAAoJEECxmPOUX5FEy+wP/2ZZsx/cbErMLaulHyCCBNMz
ScX+KUXgezIVPblY0ysyUvYC5JIag2+72FWGfn3Yx1PpS8UxaImLq6wNTGsXN/wC
TBxw7uFxcBlMrfSpkZImsCbvj92epfQztFAYNks3xax3UMOqIrdbTd/TI/0Fvvd4
Ee09qUvf49wPnmtg+gPgZX4mVP5tpjUL0SDPXHG2QReC8Fm+GsYArE47elALkZVP
0JzZ8WgWbFP52cl58BEp9vV2oKwcKI5qMTLfPIU3XrIuUkivi9UUadHDybimZ0Cf
9GHtQote5rT/DG295pC3I+q+vwPOrYtV4/3Y9ZY9VpI6zNfpZzVDIz87fkuFAKJ6
QoEpBLXbPBdmZ6ncw6uemoyBGOyPCjDQITxu1OW1/kWJym9jtrSrIt6/C14GCMIG
ltWflWFdOb970ovHkbTROwJn971sEvxE/Jx4MHg833mhjrZhr3vjXSGrPdlRq6Jb
XXZxjtBcpp0Uk7PdsTW2kG6HXpE7rf40LPhptAgoLP4NG47vq0YOJpWK/XLRbMXt
b2fI+6/n5dz9lUT+xN/HyEBIoJFkIv8DAijDSpSSLyfciVibKuCeQiZfzyYaOVRl
T+/pb/YeNV/iV8cf4jrdHzmFrxe+PiLaXbpq1EBcQMDlHQYRq1WeOL5N7Z3iRNLo
YDofsj0J+yPtXgvBnZWW
=yt+e
-----END PGP SIGNATURE-----

--Signature=_Mon__22_Apr_2013_13_09_39_+1000_haU4jeNQ36pD63Ll--
