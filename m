From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Thu, 24 Jul 2014 12:47:00 +1000
Message-ID: <20140724124700.602081e7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Qleug8pSeulOUMoaXBG9p.p"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>,
	Johannes Berg <johannes.berg@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Qleug8pSeulOUMoaXBG9p.p
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/mac80211/cfg.c between commit fa8f136fe9a8 ("mac80211: fix crash on
getting sta info with uninitialized rate control") from the wireless
tree and commit b7ffbd7ef675 ("cfg80211: make ethtool the driver's
responsibility") from the net-next tree.

I fixed it up (the latter moved the code modified by the former, so I
removed the code and added the following patch) and can carry the fix
as necessary (no action is required).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 24 Jul 2014 12:32:49 +1000
Subject: [PATCH] mac80211: fix for code movement

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/mac80211/sta_info.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index f41177f58b30..c6ee2139fbc5 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1724,12 +1724,15 @@ void sta_set_sinfo(struct sta_info *sta, struct sta=
tion_info *sinfo)
 {
 	struct ieee80211_sub_if_data *sdata =3D sta->sdata;
 	struct ieee80211_local *local =3D sdata->local;
-	struct rate_control_ref *ref =3D local->rate_ctrl;
+	struct rate_control_ref *ref =3D NULL;
 	struct timespec uptime;
 	u64 packets =3D 0;
 	u32 thr =3D 0;
 	int i, ac;
=20
+	if (test_sta_flag(sta, WLAN_STA_RATE_CONTROL))
+		ref =3D local->rate_ctrl;
+
 	sinfo->generation =3D sdata->local->sta_generation;
=20
 	sinfo->filled =3D STATION_INFO_INACTIVE_TIME |
--=20
2.0.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/Qleug8pSeulOUMoaXBG9p.p
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT0HOqAAoJEMDTa8Ir7ZwVKawP/1Z1lSxXUEXS3R2tWygxbpQP
4nuxdnZ976GOaDS1I306jPbYAFQ2NbA4/UwBxRBUKq5aH6r4Uyo8Xy4fUSwsvVY+
dmgJ772N+7avIkPkWejXn1mk5A0MEvI2HPr5poqTjj48W050/OwJiAQtpQfYVExs
zykm8uHlV0KwEWPzuytdpWrCEFlkqA+SxXu3AIPfvU1C1Wd6iFU5I79vWC4SUsR5
WhHRkZPLSMi1f13sUkOezVvIlBpf8TWvRPK8C981I8bEvEtdovPZWvdu5oDnnHyp
1YuJFwWe1o4hbKcyKoukCyf0nFcHqrN3qMA0hznGRMCZ4D3N0fgB2oK33L7eYZ8x
amPRz5zCjBdwHfS8CmmVHqqrnu325sKE7xH2yCVBumu82n3UYvKCbhxLNTsKkNLl
giXUMCl1EaI8fNU29B0gewktYGIt3P5WKAxJ8uZsnvXcCkcmY0+syD9DlJwVAFdI
XYvrtrKPtgTblJo9k0o3xmfDNExZuWtcZ/nuLJZNDBrCjbQrireDuFyJTee4wKwn
QYyfrfycE5JVgb1xbrj1rNX2UGpIPAlq4Suj4xDnr8nYLXR+Sf8g22Njk8LXITem
6GHRDbanhk8KBBHvT764HE31JvPOI3cTiIGk4R8hnZXNREpoDM3Rssk/nCzqL8dO
epG0yx9CwJziVkBmdt23
=a2Cg
-----END PGP SIGNATURE-----

--Sig_/Qleug8pSeulOUMoaXBG9p.p--
