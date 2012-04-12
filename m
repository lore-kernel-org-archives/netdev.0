From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the wireless-next tree
Date: Thu, 12 Apr 2012 12:24:24 +1000
Message-ID: <20120412122424.fc3ee3b77a69ad7f84cc358f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__12_Apr_2012_12_24_24_+1000_xWkHsW9gOMWt2WGk"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Pedersen <c_tpeder@qca.qualcomm.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__12_Apr_2012_12_24_24_+1000_xWkHsW9gOMWt2WGk
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

After merging the wireless-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

net/wireless/nl80211.c: In function 'nl80211_ch_switch_notify':
net/wireless/nl80211.c:8060:2: error: implicit declaration of function 'NLA=
_PUT_U32' [-Werror=3Dimplicit-function-declaration]

Caused by commit 5314526b1743 ("cfg80211: add channel switch notify
event") interacting with commit 9360ffd18597 ("wireless: Stop using
NLA_PUT*()") from the net-next tree.

I added the following merge fix patch.

John, you may like to cherry-pick that commit from Dave's tree (or back
merge that part of Dave's tree or get Dave to merge you tree and start
further work on top of the merge).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 12 Apr 2012 12:21:01 +1000
Subject: [PATCH] cfg80211: NLA_PUT_U32 api change merge fix

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/wireless/nl80211.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index f727a1f..f7d2ebb 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -8057,9 +8057,12 @@ void nl80211_ch_switch_notify(struct cfg80211_regist=
ered_device *rdev,
 		return;
 	}
=20
-	NLA_PUT_U32(msg, NL80211_ATTR_IFINDEX, netdev->ifindex);
-	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY_FREQ, freq);
-	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY_CHANNEL_TYPE, type);
+	if (nla_put_u32(msg, NL80211_ATTR_IFINDEX, netdev->ifindex))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, NL80211_ATTR_WIPHY_FREQ, freq))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, NL80211_ATTR_WIPHY_CHANNEL_TYPE, type))
+		goto nla_put_failure;
=20
 	genlmsg_end(msg, hdr);
=20
--=20
1.7.10.rc3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__12_Apr_2012_12_24_24_+1000_xWkHsW9gOMWt2WGk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPhjzYAAoJEECxmPOUX5FExMgP/2V9LN3guzq7SNmAbTo6EBSn
UAkoi0xPug/vb2gCMdW/ThqVjN7Old9ICRg4AQMc/LwLpT4Bbh81ZjcLHVNQPGH8
8f30oaKicudVucnhMA6zMCfR9vG8p3ffWyjXK2xs0nyztGBRnLK8JjZfTf9kJdPZ
/sb9HrFugEjI62OXiY+FD0Z5Smd6rAcCpThyqlZOjvsfn1gkEip0df6wIti3m8Z2
dk42Nm/Xnw4eoUK199glV0F9I955LINfpWWQd9GBv67hCu97LSgrpWzETZh0ipsv
/BbR06nPgagVhqfa3N7oXDW9A/DLCE9kyHb94u1dRXzdGrnPxcu7LGljYHC1JERh
UIjwCELTuEL88YWMJPZD7GxVI1uRBH2iIsbhpgOegHiJx1OE8s0PMuIsPzPn68S3
XKZtAThq7ZHvttO8f+/Xq3mG47fXWIkH6ehnT/HGJ/2YodHMCK7QnxfoX/nj+5xz
4HWFePb52BLmE4S3RKxh5UttqBtPZWnKoJ7QL8bTSE6XM864OiB1a6cpxb1vppes
H8ymF2U1KBvREXn2MW/uoOkkHp2aYJircsa+6i0smknxPtTqM7ySbh9a8l55sYWo
eIug7fPLvc48m01XFZQWlbXvXAOY8SnVBIFNo0U/v5Z1K2lrOBGcmAb+sImG6d2x
IXdXn6tnhURgwSTiEzvt
=jqbf
-----END PGP SIGNATURE-----

--Signature=_Thu__12_Apr_2012_12_24_24_+1000_xWkHsW9gOMWt2WGk--
