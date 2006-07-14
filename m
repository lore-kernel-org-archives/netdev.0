From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH dscape] d80211: Add sparse bitwise annotations
Date: Fri, 14 Jul 2006 00:20:39 -0700
Message-ID: <200607140020.53446.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1497477.0FU5bz4kKD";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:17794 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1161073AbWGNHVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 03:21:09 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1497477.0FU5bz4kKD
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

This patch adds sparse bitwise annotations to d80211.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 include/net/d80211.h       |    6 +++---
 include/net/d80211_mgmt.h  |   42 +++++++++++++++++++++-------------------=
=2D-
 net/d80211/ieee80211_sta.c |    7 +------
 3 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 6ae4325..e6dcb0e 100644
=2D-- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -959,12 +959,12 @@ #define IEEE80211_MAX_FRAG_THRESHOLD 234
 #define IEEE80211_MAX_RTS_THRESHOLD 2347
=20
 struct ieee80211_hdr {
=2D	u16 frame_control;
=2D	u16 duration_id;
+	__le16 frame_control;
+	__le16 duration_id;
 	u8 addr1[6];
 	u8 addr2[6];
 	u8 addr3[6];
=2D	u16 seq_ctrl;
+	__le16 seq_ctrl;
 	u8 addr4[6];
 } __attribute__ ((packed));
=20
diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
index 8066af7..f623db3 100644
=2D-- a/include/net/d80211_mgmt.h
+++ b/include/net/d80211_mgmt.h
@@ -15,50 +15,50 @@ #define D802_11_MGMT_H
 #include <linux/types.h>
=20
 struct ieee80211_mgmt {
=2D	u16 frame_control;
=2D	u16 duration;
+	__le16 frame_control;
+	__le16 duration;
 	u8 da[6];
 	u8 sa[6];
 	u8 bssid[6];
=2D	u16 seq_ctrl;
+	__le16 seq_ctrl;
 	union {
 		struct {
=2D			u16 auth_alg;
=2D			u16 auth_transaction;
=2D			u16 status_code;
+			__le16 auth_alg;
+			__le16 auth_transaction;
+			__le16 status_code;
 			/* possibly followed by Challenge text */
 			u8 variable[0];
 		} __attribute__ ((packed)) auth;
 		struct {
=2D			u16 reason_code;
+			__le16 reason_code;
 		} __attribute__ ((packed)) deauth;
 		struct {
=2D			u16 capab_info;
=2D			u16 listen_interval;
+			__le16 capab_info;
+			__le16 listen_interval;
 			/* followed by SSID and Supported rates */
 			u8 variable[0];
 		} __attribute__ ((packed)) assoc_req;
 		struct {
=2D			u16 capab_info;
=2D			u16 status_code;
=2D			u16 aid;
+			__le16 capab_info;
+			__le16 status_code;
+			__le16 aid;
 			/* followed by Supported rates */
 			u8 variable[0];
 		} __attribute__ ((packed)) assoc_resp, reassoc_resp;
 		struct {
=2D			u16 capab_info;
=2D			u16 listen_interval;
+			__le16 capab_info;
+			__le16 listen_interval;
 			u8 current_ap[6];
 			/* followed by SSID and Supported rates */
 			u8 variable[0];
 		} __attribute__ ((packed)) reassoc_req;
 		struct {
=2D			u16 reason_code;
+			__le16 reason_code;
 		} __attribute__ ((packed)) disassoc;
 		struct {
=2D			u8 timestamp[8];
=2D			u16 beacon_int;
=2D			u16 capab_info;
+			__le64 timestamp;
+			__le16 beacon_int;
+			__le16 capab_info;
 			/* followed by some of SSID, Supported rates,
 			 * FH Params, DS Params, CF Params, IBSS Params, TIM */
 			u8 variable[0];
@@ -68,9 +68,9 @@ struct ieee80211_mgmt {
 			u8 variable[0];
 		} __attribute__ ((packed)) probe_req;
 		struct {
=2D			u8 timestamp[8];
=2D			u16 beacon_int;
=2D			u16 capab_info;
+			__le64 timestamp;
+			__le16 beacon_int;
+			__le16 capab_info;
 			/* followed by some of SSID, Supported rates,
 			 * FH Params, DS Params, CF Params, IBSS Params */
 			u8 variable[0];
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 82fbe3d..b0cfff1 100644
=2D-- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1344,7 +1344,6 @@ static void ieee80211_rx_bss_info(struct
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata =3D IEEE80211_DEV_TO_SUB_IF(dev);
 	u64 timestamp;
=2D	u8 *pos;
=20
 	if (!beacon && memcmp(mgmt->da, dev->dev_addr, ETH_ALEN))
 		return; /* ignore ProbeResp to foreign address */
@@ -1359,11 +1358,7 @@ #endif
 	if (baselen > len)
 		return;
=20
=2D	pos =3D mgmt->u.beacon.timestamp;
=2D	timestamp =3D ((u64) pos[7] << 56) | ((u64) pos[6] << 48) |
=2D		((u64) pos[5] << 40) | ((u64) pos[4] << 32) |
=2D		((u64) pos[3] << 24) | ((u64) pos[2] << 16) |
=2D		((u64) pos[1] << 8) | ((u64) pos[0]);
+	timestamp =3D le64_to_cpu(mgmt->u.beacon.timestamp);
=20
 	if (sdata->type =3D=3D IEEE80211_IF_TYPE_IBSS && beacon &&
 	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) =3D=3D 0) {

--nextPart1497477.0FU5bz4kKD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEt0XVT3Oqt9AH4aERAuyvAJ9CsUwzj4F2tEHoNO5V9vha0R/NkgCeNqU+
9gbkfQV8MdkwWwAJvAjh/BA=
=Y9O6
-----END PGP SIGNATURE-----

--nextPart1497477.0FU5bz4kKD--
