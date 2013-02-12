From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-02-12
Date: Tue, 12 Feb 2013 11:03:16 -0500
Message-ID: <20130212160316.GA2086@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M9NhX3UHpAaciwkO"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47184 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933293Ab3BLQPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 11:15:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Here is another handful of late-breaking fixes intended for the 3.8
stream...  Hopefully the will still make it! :-)

There are three mac80211 fixes pulled from Johannes:

"Here are three fixes still for the 3.8 stream, the fix from Cong Ding
for the bad sizeof (Stephen Hemminger had pointed it out before but I'd
promptly forgotten), a mac80211 managed-mode channel context usage fix
where a downgrade would never stop until reaching non-HT and a bug in
the channel determination that could cause invalid channels like HT40+
on channel 11 to be used."

Also included is a mwl8k fix that avoids an oops when using mwl8k
devices that only support the 5 GHz band.

Please let me know if there are problems!

John

---

The following changes since commit 547b4e718115eea74087e28d7fa70aec619200db:

  bridge: set priority of STP packets (2013-02-11 14:16:52 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 318d86dbe55cbc63a61a83b9ff6cdbc044905f5e:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-02-12 10:41:46 -0500)

----------------------------------------------------------------

Cong Ding (1):
      mac80211: fix error in sizeof() usage

Johannes Berg (2):
      mac80211: fix managed mode channel context use
      mac80211: fix channel selection bug

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jonas Gorski (1):
      mwl8k: fix band for supported channels

 drivers/net/wireless/mwl8k.c | 36 ++++++++++++++++++------------------
 net/mac80211/cfg.c           |  3 ++-
 net/mac80211/mlme.c          | 11 +++++++----
 3 files changed, 27 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 83564d3..a00a03e 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -318,20 +318,20 @@ struct mwl8k_sta {
 #define MWL8K_STA(_sta) ((struct mwl8k_sta *)&((_sta)->drv_priv))
=20
 static const struct ieee80211_channel mwl8k_channels_24[] =3D {
-	{ .center_freq =3D 2412, .hw_value =3D 1, },
-	{ .center_freq =3D 2417, .hw_value =3D 2, },
-	{ .center_freq =3D 2422, .hw_value =3D 3, },
-	{ .center_freq =3D 2427, .hw_value =3D 4, },
-	{ .center_freq =3D 2432, .hw_value =3D 5, },
-	{ .center_freq =3D 2437, .hw_value =3D 6, },
-	{ .center_freq =3D 2442, .hw_value =3D 7, },
-	{ .center_freq =3D 2447, .hw_value =3D 8, },
-	{ .center_freq =3D 2452, .hw_value =3D 9, },
-	{ .center_freq =3D 2457, .hw_value =3D 10, },
-	{ .center_freq =3D 2462, .hw_value =3D 11, },
-	{ .center_freq =3D 2467, .hw_value =3D 12, },
-	{ .center_freq =3D 2472, .hw_value =3D 13, },
-	{ .center_freq =3D 2484, .hw_value =3D 14, },
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2412, .hw_value =3D 1, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2417, .hw_value =3D 2, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2422, .hw_value =3D 3, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2427, .hw_value =3D 4, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2432, .hw_value =3D 5, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2437, .hw_value =3D 6, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2442, .hw_value =3D 7, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2447, .hw_value =3D 8, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2452, .hw_value =3D 9, =
},
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2457, .hw_value =3D 10,=
 },
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2462, .hw_value =3D 11,=
 },
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2467, .hw_value =3D 12,=
 },
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2472, .hw_value =3D 13,=
 },
+	{ .band =3D IEEE80211_BAND_2GHZ, .center_freq =3D 2484, .hw_value =3D 14,=
 },
 };
=20
 static const struct ieee80211_rate mwl8k_rates_24[] =3D {
@@ -352,10 +352,10 @@ static const struct ieee80211_rate mwl8k_rates_24[] =
=3D {
 };
=20
 static const struct ieee80211_channel mwl8k_channels_50[] =3D {
-	{ .center_freq =3D 5180, .hw_value =3D 36, },
-	{ .center_freq =3D 5200, .hw_value =3D 40, },
-	{ .center_freq =3D 5220, .hw_value =3D 44, },
-	{ .center_freq =3D 5240, .hw_value =3D 48, },
+	{ .band =3D IEEE80211_BAND_5GHZ, .center_freq =3D 5180, .hw_value =3D 36,=
 },
+	{ .band =3D IEEE80211_BAND_5GHZ, .center_freq =3D 5200, .hw_value =3D 40,=
 },
+	{ .band =3D IEEE80211_BAND_5GHZ, .center_freq =3D 5220, .hw_value =3D 44,=
 },
+	{ .band =3D IEEE80211_BAND_5GHZ, .center_freq =3D 5240, .hw_value =3D 48,=
 },
 };
=20
 static const struct ieee80211_rate mwl8k_rates_50[] =3D {
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 516fbc9..0479c64 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2004,7 +2004,8 @@ static int ieee80211_set_mcast_rate(struct wiphy *wip=
hy, struct net_device *dev,
 {
 	struct ieee80211_sub_if_data *sdata =3D IEEE80211_DEV_TO_SUB_IF(dev);
=20
-	memcpy(sdata->vif.bss_conf.mcast_rate, rate, sizeof(rate));
+	memcpy(sdata->vif.bss_conf.mcast_rate, rate,
+	       sizeof(int) * IEEE80211_NUM_BANDS);
=20
 	return 0;
 }
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index a355292..5107248 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3400,6 +3400,7 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_=
data *sdata,
=20
 	ret =3D 0;
=20
+out:
 	while (!cfg80211_chandef_usable(sdata->local->hw.wiphy, chandef,
 					IEEE80211_CHAN_DISABLED)) {
 		if (WARN_ON(chandef->width =3D=3D NL80211_CHAN_WIDTH_20_NOHT)) {
@@ -3408,14 +3409,13 @@ ieee80211_determine_chantype(struct ieee80211_sub_i=
f_data *sdata,
 			goto out;
 		}
=20
-		ret =3D chandef_downgrade(chandef);
+		ret |=3D chandef_downgrade(chandef);
 	}
=20
 	if (chandef->width !=3D vht_chandef.width)
 		sdata_info(sdata,
-			   "local regulatory prevented using AP HT/VHT configuration, downgrade=
d\n");
+			   "capabilities/regulatory prevented using AP HT/VHT configuration, do=
wngraded\n");
=20
-out:
 	WARN_ON_ONCE(!cfg80211_chandef_valid(chandef));
 	return ret;
 }
@@ -3529,8 +3529,11 @@ static int ieee80211_prep_channel(struct ieee80211_s=
ub_if_data *sdata,
 	 */
 	ret =3D ieee80211_vif_use_channel(sdata, &chandef,
 					IEEE80211_CHANCTX_SHARED);
-	while (ret && chandef.width !=3D NL80211_CHAN_WIDTH_20_NOHT)
+	while (ret && chandef.width !=3D NL80211_CHAN_WIDTH_20_NOHT) {
 		ifmgd->flags |=3D chandef_downgrade(&chandef);
+		ret =3D ieee80211_vif_use_channel(sdata, &chandef,
+						IEEE80211_CHANCTX_SHARED);
+	}
 	return ret;
 }
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRGmfEAAoJEJctW/TcYTgGBSsP/RKwrk8PPkTdXayqbiQ+RI4a
w58chzt+4PB2jrQtKFm8i0zCdJM1DUG6b0cFLVm4k3j1zlacpw/QMrZUnOh2S8P1
7l04yj5BcS3M3I4fvwPemluhHq7EBzhUc4LKVGEHp2gR2awOlOYZogKi1KAQp2MC
JlHBqZNCYlnbLEvjBhLXCyJ9FlAs0IwS1W2KUrxMzMmigh8THJCFWXGhT4UIH17t
96cDxYmhIHzFPvvOG8kbabsfDwF5nVt6vK925AR2B2u25eoYGdmp0zuhcQMITbPI
tdSWTEefifwWHRS+fWkCXciNw5qztp1+AIUkrcVEjz+cjqDQPAfHZX0RRL0uXyqF
ZZU5lzNGIQlfST30TKqLtISMuYqbYgxynjCPVzs4Kv3Sm+m/TMK5dtfJ8S29Smp8
ki7nyy72NNPbEpyTWn0r79ybF5Sf/zftSJ+HXntP1klaw2PFVFXa9KHNUAhjUYTu
+f2b+THO74O+HGCkWgpIVNWSKivE1nptGaeYrxfrn+6Yh6RFdjRp4k+AuI7Qlw45
yHMzRCq0N/Ed8qnozGENXA1x0paxcK9fIvK4FDcYLkyQ3vCvqeuODUWVF5EmrHD/
bD5tNwBu8nzYOznap1PiKtff4yeaewHBYND8b28hMHwUzzwXYoJPsjgTzMAF72Gl
Fe0yc1FlSc0Px4JvcPjt
=tw6J
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
