From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-06-19
Date: Wed, 19 Jun 2013 15:41:41 -0400
Message-ID: <20130619194141.GH12079@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

One more late-breaking fix in the nl80211 code, the fix for the
nl80211_fam.attrbuf race Linus ran into and analysed.  Hopefully it
looks familiar... :-)

Let me know if there are problems!

John

---

The following changes since commit eb064c3b49931dc73bba59887019c7f5cb97d322:

  vxlan: fix check for migration of static entry (2013-06-19 00:50:58 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 4067c666f2dccf56f5db5c182713e68c40d46013:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-06-19 15:24:36 -0400)

----------------------------------------------------------------

Johannes Berg (1):
      nl80211: fix attrbuf access race by allocating a separate one

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

 net/wireless/nl80211.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index d5aed3b..b14b7e3 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1564,12 +1564,17 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, =
struct netlink_callback *cb)
 	struct cfg80211_registered_device *dev;
 	s64 filter_wiphy =3D -1;
 	bool split =3D false;
-	struct nlattr **tb =3D nl80211_fam.attrbuf;
+	struct nlattr **tb;
 	int res;
=20
+	/* will be zeroed in nlmsg_parse() */
+	tb =3D kmalloc(sizeof(*tb) * (NL80211_ATTR_MAX + 1), GFP_KERNEL);
+	if (!tb)
+		return -ENOMEM;
+
 	mutex_lock(&cfg80211_mutex);
 	res =3D nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
-			  tb, nl80211_fam.maxattr, nl80211_policy);
+			  tb, NL80211_ATTR_MAX, nl80211_policy);
 	if (res =3D=3D 0) {
 		split =3D tb[NL80211_ATTR_SPLIT_WIPHY_DUMP];
 		if (tb[NL80211_ATTR_WIPHY])
@@ -1583,6 +1588,7 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, st=
ruct netlink_callback *cb)
 			netdev =3D dev_get_by_index(sock_net(skb->sk), ifidx);
 			if (!netdev) {
 				mutex_unlock(&cfg80211_mutex);
+				kfree(tb);
 				return -ENODEV;
 			}
 			if (netdev->ieee80211_ptr) {
@@ -1593,6 +1599,7 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, st=
ruct netlink_callback *cb)
 			dev_put(netdev);
 		}
 	}
+	kfree(tb);
=20
 	list_for_each_entry(dev, &cfg80211_rdev_list, list) {
 		if (!net_eq(wiphy_net(&dev->wiphy), sock_net(skb->sk)))
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRwgl1AAoJEJctW/TcYTgGg8gP/AxX2R/LwGHAWcqKzBuKXvlk
Eir0rGZWXt+Pnv72wLmmx0CsLNBDZ+uAttkooWPcdFnk8a7MENqJY2Jsj+GFlVZ9
Ug/3FkRiQz6dr7X2IRi8PKbl4+SR8NyG53Yvp1JPmKnonpq5ibHeZn3WbxBgBWbj
4aBQ/hXYjri5tyayCx4F/Y8BOzUQFJM+jx13xaUwaROL4uNgufUwvV256SJQNTet
yA+mPA5QJZE95QO4vt0Z42dg66H602sd6rR/S4evFBhfisRTRT35VL2v99vRK1zE
H4SnfGnW/KKXYNRML2qaBTMIuhsCaNNg57PUPoKdSiUEEIgHawqUjcx2ULFab4+7
YCYypLTQ2+HlQHgegYParZfD/Kn8SNOBcxabgeGhbw2uzAfhYoP1V8XNQTy0yZYC
VayzWPJSiF+QD179fIngfrIpjTWiSKZakOJOpul0LqlNz35RqhEpZCjJtE71TdME
UmXSklFBfnj/qSP2L1ejRV++8PB4IZ30npD+XUHfV0kKs4kvbl0P0Ss5ZlHWfAhN
vyP/A+JkiA1JEo4/Pe7u4ndmR4VfrfBM2/OcISVPq1YTzespySJlMo3KRbhp/PZO
g0hBkuUTh/DaIhXP4poOfxCJA1l9CG23PODONNAdON815KZRfRfn8XCkHN0LTeF5
lWgG7j1dS+To9x/u4K7H
=39VE
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
