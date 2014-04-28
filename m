From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 28 Apr 2014 12:57:59 +1000
Message-ID: <20140428125759.47924ab500af7624f401d424@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__28_Apr_2014_12_57_59_+1000_2bWsHzvFS5IrcEcj"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Richard Guy Briggs <rgb@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__28_Apr_2014_12_57_59_+1000_2bWsHzvFS5IrcEcj
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/netlink/af_netlink.c between commit 5187cd055b6e ("netlink: Rename
netlink_capable netlink_allowed") from the net tree and commit
4f520900522f ("netlink: have netlink per-protocol bind function return an
error code") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/netlink/af_netlink.c
index 81dca96d2be6,92f4b6915e89..000000000000
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@@ -1492,8 -1445,8 +1510,8 @@@ static int netlink_bind(struct socket *
  		return -EINVAL;
 =20
  	/* Only superuser is allowed to listen multicasts */
- 	if (nladdr->nl_groups) {
+ 	if (groups) {
 -		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
 +		if (!netlink_allowed(sock, NL_CFG_F_NONROOT_RECV))
  			return -EPERM;
  		err =3D netlink_realloc_groups(sk);
  		if (err)

--Signature=_Mon__28_Apr_2014_12_57_59_+1000_2bWsHzvFS5IrcEcj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTXcO8AAoJEMDTa8Ir7ZwVUMEQAIL8aJKBOL6UgouDX1WrMc7F
XHMeodZdBqSdU30ujeT0zmHYrBt12b2bcX8/ydF4XApPTzwVbe6flqCurDM1iCDH
Y/wqJArEgtc9l0r/mbsyYisOULTlg2oe3fpjQRbp0Zshe8ACpJZ6JVyPi6JDxhm3
xBYZjKA3AsrSPYx8M3H0Q4P+PzCtGcSDwb0fkV0P85SahsSEV5sHTNTEMRtJ8f2a
UvTD4skGvFD77oOBupEu52/c0Ql1fpxBs6CPWeY8T/AXISO2qFvoMX7bGupNkA1U
7K+v0bL2+F59MqH+3sQA8A2kVbG2+eRDxbFU4urB4DzKWFx1xp+Czaf49P/gFsVB
HORU2l7VY+skR/pwbHYm3EExOvrKvpXBMi5FgZ+p7jEX8PfazBsHlBSSnOxQZ6ge
Yw4GKdo3FPCNbXtRgEQjx/O5+jCl5oO0max6PTM0y41GKad0t2iALjKpkJHTBrNJ
cVsAJ9AqwUVLbqDTRTQ/YTv57mVmNEHLLLvcXcQKawK4x8zrHVy1rluUQeV0TjeD
G3PspWX4Rsg1s7zjsJaJykvkDU+5NhanFM/zNw/CltLSofHjjtG+ESlz8ZZqfzW1
KNil7CzwGk6MCfr1orpu80OKUH6g3SF1Ex2IOVLLeJf/ZwQw6h3VI59FuGD8ad3V
XEioZfvRwRgO4gZiBm4v
=Nth7
-----END PGP SIGNATURE-----

--Signature=_Mon__28_Apr_2014_12_57_59_+1000_2bWsHzvFS5IrcEcj--
