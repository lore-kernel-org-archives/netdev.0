From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] d80211: Switch d80211_mgmt.h to ieee80211.h style definitions
Date: Sat, 5 Aug 2006 01:45:33 -0700
Message-ID: <200608050145.40137.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1396562.H5pCDvWBkd";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:21688 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1422765AbWHEIpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 04:45:50 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1396562.H5pCDvWBkd
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: Switch d80211_mgmt.h to ieee80211.h style definitions

This patch switches a number of defines in d80211_mgmt.h to enums taken fro=
m=20
ieee80211.h and makes the corresponding changes in net/d80211.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 include/net/d80211_mgmt.h  |  153=20
+++++++++++++++++++++++++-------------------
 net/d80211/ieee80211.c     |    2 -
 net/d80211/ieee80211_sta.c |   50 +++++++-------
 3 files changed, 114 insertions(+), 91 deletions(-)

diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
index f623db3..44d81de 100644
=2D-- a/include/net/d80211_mgmt.h
+++ b/include/net/d80211_mgmt.h
@@ -119,77 +119,100 @@ #define WLAN_CAPABILITY_SHORT_SLOT_TIME=20
 #define WLAN_CAPABILITY_DSSS_OFDM BIT(13)
=20
 /* Status codes */
=2D#define WLAN_STATUS_SUCCESS 0
=2D#define WLAN_STATUS_UNSPECIFIED_FAILURE 1
=2D#define WLAN_STATUS_CAPS_UNSUPPORTED 10
=2D#define WLAN_STATUS_REASSOC_NO_ASSOC 11
=2D#define WLAN_STATUS_ASSOC_DENIED_UNSPEC 12
=2D#define WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG 13
=2D#define WLAN_STATUS_UNKNOWN_AUTH_TRANSACTION 14
=2D#define WLAN_STATUS_CHALLENGE_FAIL 15
=2D#define WLAN_STATUS_AUTH_TIMEOUT 16
=2D#define WLAN_STATUS_AP_UNABLE_TO_HANDLE_NEW_STA 17
=2D#define WLAN_STATUS_ASSOC_DENIED_RATES 18
=2D/* 802.11b */
=2D#define WLAN_STATUS_ASSOC_DENIED_NOSHORT 19
=2D#define WLAN_STATUS_ASSOC_DENIED_NOPBCC 20
=2D#define WLAN_STATUS_ASSOC_DENIED_NOAGILITY 21
=2D/* 802.11h */
=2D#define WLAN_STATUS_SPEC_MGMT_REQUIRED 22
=2D#define WLAN_STATUS_PWR_CAPABILITY_NOT_VALID 23
=2D#define WLAN_STATUS_SUPPORTED_CHANNEL_NOT_VALID 24
=2D/* 802.11g */
=2D#define WLAN_STATUS_ASSOC_DENOED_NO_SHORT_SLOT_TIME 25
=2D#define WLAN_STATUS_ASSOC_DENOED_NO_ER_PBCC 26
=2D#define WLAN_STATUS_ASSOC_DENOED_NO_DSSS_OFDM 27
+enum ieee80211_statuscode {
+	WLAN_STATUS_SUCCESS =3D 0,
+	WLAN_STATUS_UNSPECIFIED_FAILURE =3D 1,
+	WLAN_STATUS_CAPS_UNSUPPORTED =3D 10,
+	WLAN_STATUS_REASSOC_NO_ASSOC =3D 11,
+	WLAN_STATUS_ASSOC_DENIED_UNSPEC =3D 12,
+	WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG =3D 13,
+	WLAN_STATUS_UNKNOWN_AUTH_TRANSACTION =3D 14,
+	WLAN_STATUS_CHALLENGE_FAIL =3D 15,
+	WLAN_STATUS_AUTH_TIMEOUT =3D 16,
+	WLAN_STATUS_AP_UNABLE_TO_HANDLE_NEW_STA =3D 17,
+	WLAN_STATUS_ASSOC_DENIED_RATES =3D 18,
+	/* 802.11b */
+	WLAN_STATUS_ASSOC_DENIED_NOSHORTPREAMBLE =3D 19,
+	WLAN_STATUS_ASSOC_DENIED_NOPBCC =3D 20,
+	WLAN_STATUS_ASSOC_DENIED_NOAGILITY =3D 21,
+	/* 802.11h */
+	WLAN_STATUS_ASSOC_DENIED_NOSPECTRUM =3D 22,
+	WLAN_STATUS_ASSOC_REJECTED_BAD_POWER =3D 23,
+	WLAN_STATUS_ASSOC_REJECTED_BAD_SUPP_CHAN =3D 24,
+	/* 802.11g */
+	WLAN_STATUS_ASSOC_DENIED_NOSHORTTIME =3D 25,
+	WLAN_STATUS_ASSOC_DENIED_NODSSSOFDM =3D 26,
+	/* 802.11i */
+	WLAN_STATUS_INVALID_IE =3D 40,
+	WLAN_STATUS_INVALID_GROUP_CIPHER =3D 41,
+	WLAN_STATUS_INVALID_PAIRWISE_CIPHER =3D 42,
+	WLAN_STATUS_INVALID_AKMP =3D 43,
+	WLAN_STATUS_UNSUPP_RSN_VERSION =3D 44,
+	WLAN_STATUS_INVALID_RSN_IE_CAP =3D 45,
+	WLAN_STATUS_CIPHER_SUITE_REJECTED =3D 46,
+};
=20
=20
 /* Reason codes */
=2D#define WLAN_REASON_UNSPECIFIED 1
=2D#define WLAN_REASON_PREV_AUTH_NOT_VALID 2
=2D#define WLAN_REASON_DEAUTH_LEAVING 3
=2D#define WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY 4
=2D#define WLAN_REASON_DISASSOC_AP_BUSY 5
=2D#define WLAN_REASON_CLASS2_FRAME_FROM_NONAUTH_STA 6
=2D#define WLAN_REASON_CLASS3_FRAME_FROM_NONASSOC_STA 7
=2D#define WLAN_REASON_DISASSOC_STA_HAS_LEFT 8
=2D#define WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH 9
=2D/* 802.11h */
=2D#define WLAN_REASON_PWR_CAPABILITY_NOT_VALID 10
=2D#define WLAN_REASON_SUPPORTED_CHANNEL_NOT_VALID 11
=2D
=2D#define WLAN_REASON_MIC_FAILURE 14
+enum ieee80211_reasoncode {
+	WLAN_REASON_UNSPECIFIED =3D 1,
+	WLAN_REASON_PREV_AUTH_NOT_VALID =3D 2,
+	WLAN_REASON_DEAUTH_LEAVING =3D 3,
+	WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY =3D 4,
+	WLAN_REASON_DISASSOC_AP_BUSY =3D 5,
+	WLAN_REASON_CLASS2_FRAME_FROM_NONAUTH_STA =3D 6,
+	WLAN_REASON_CLASS3_FRAME_FROM_NONASSOC_STA =3D 7,
+	WLAN_REASON_DISASSOC_STA_HAS_LEFT =3D 8,
+	WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH =3D 9,
+	/* 802.11h */
+	WLAN_REASON_DISASSOC_BAD_POWER =3D 10,
+	WLAN_REASON_DISASSOC_BAD_SUPP_CHAN =3D 11,
+	/* 802.11i */
+	WLAN_REASON_INVALID_IE =3D 13,
+	WLAN_REASON_MIC_FAILURE =3D 14,
+	WLAN_REASON_4WAY_HANDSHAKE_TIMEOUT =3D 15,
+	WLAN_REASON_GROUP_KEY_HANDSHAKE_TIMEOUT =3D 16,
+	WLAN_REASON_IE_DIFFERENT =3D 17,
+	WLAN_REASON_INVALID_GROUP_CIPHER =3D 18,
+	WLAN_REASON_INVALID_PAIRWISE_CIPHER =3D 19,
+	WLAN_REASON_INVALID_AKMP =3D 20,
+	WLAN_REASON_UNSUPP_RSN_VERSION =3D 21,
+	WLAN_REASON_INVALID_RSN_IE_CAP =3D 22,
+	WLAN_REASON_IEEE8021X_FAILED =3D 23,
+	WLAN_REASON_CIPHER_SUITE_REJECTED =3D 24,
+};
=20
=20
 /* Information Element IDs */
=2D#define WLAN_EID_SSID 0
=2D#define WLAN_EID_SUPP_RATES 1
=2D#define WLAN_EID_FH_PARAMS 2
=2D#define WLAN_EID_DS_PARAMS 3
=2D#define WLAN_EID_CF_PARAMS 4
=2D#define WLAN_EID_TIM 5
=2D#define WLAN_EID_IBSS_PARAMS 6
=2D#define WLAN_EID_COUNTRY 7
=2D#define WLAN_EID_CHALLENGE 16
=2D/* EIDs defined as part fo 11h - starts */
=2D#define WLAN_EID_PWR_CONSTRAINT	32
=2D#define WLAN_EID_PWR_CAPABILITY	33
=2D#define WLAN_EID_TPC_REQUEST	34
=2D#define WLAN_EID_TPC_REPORT	35
=2D#define WLAN_EID_SUPPORTED_CHANNELS	36
=2D#define WLAN_EID_CHANNEL_SWITCH	37
=2D#define WLAN_EID_MEASURE_REQUEST	38
=2D#define WLAN_EID_MEASURE_REPORT	39
=2D#define WLAN_EID_QUITE	40
=2D#define WLAN_EID_IBSS_DFS	41
=2D/* EIDs defined as part fo 11h - ends */
=2D#define WLAN_EID_ERP_INFO 42
=2D#define WLAN_EID_RSN 48
=2D#define WLAN_EID_EXT_SUPP_RATES 50
=2D#define WLAN_EID_WPA 221
=2D#define WLAN_EID_GENERIC 221
=2D#define WLAN_EID_VENDOR_SPECIFIC 221
=2D
+enum ieee80211_mfie {
+	MFIE_TYPE_SSID =3D 0,
+	MFIE_TYPE_RATES =3D 1,
+	MFIE_TYPE_FH_SET =3D 2,
+	MFIE_TYPE_DS_SET =3D 3,
+	MFIE_TYPE_CF_SET =3D 4,
+	MFIE_TYPE_TIM =3D 5,
+	MFIE_TYPE_IBSS_SET =3D 6,
+	MFIE_TYPE_COUNTRY =3D 7,
+	MFIE_TYPE_HOP_PARAMS =3D 8,
+	MFIE_TYPE_HOP_TABLE =3D 9,
+	MFIE_TYPE_REQUEST =3D 10,
+	MFIE_TYPE_CHALLENGE =3D 16,
+	MFIE_TYPE_POWER_CONSTRAINT =3D 32,
+	MFIE_TYPE_POWER_CAPABILITY =3D 33,
+	MFIE_TYPE_TPC_REQUEST =3D 34,
+	MFIE_TYPE_TPC_REPORT =3D 35,
+	MFIE_TYPE_SUPP_CHANNELS =3D 36,
+	MFIE_TYPE_CSA =3D 37,
+	MFIE_TYPE_MEASURE_REQUEST =3D 38,
+	MFIE_TYPE_MEASURE_REPORT =3D 39,
+	MFIE_TYPE_QUIET =3D 40,
+	MFIE_TYPE_IBSS_DFS =3D 41,
+	MFIE_TYPE_ERP_INFO =3D 42,
+	MFIE_TYPE_RSN =3D 48,
+	MFIE_TYPE_RATES_EX =3D 50,
+	MFIE_TYPE_GENERIC =3D 221,
+	MFIE_TYPE_QOS_PARAMETER =3D 222,
+};
=20
=20
 #define ATHEROS_INFO_USEXR BIT(3)
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index bf0e86b..83738da 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1714,7 +1714,7 @@ static void ieee80211_beacon_add_tim(str
 		bss->dtim_count--;
=20
 	tim =3D pos =3D (u8 *) skb_put(skb, 6);
=2D	*pos++ =3D WLAN_EID_TIM;
+	*pos++ =3D MFIE_TYPE_TIM;
 	*pos++ =3D 4;
 	*pos++ =3D bss->dtim_count;
 	*pos++ =3D bss->dtim_period;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 8caf352..4bbd59b 100644
=2D-- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -133,39 +133,39 @@ #endif
 		}
=20
 		switch (id) {
=2D		case WLAN_EID_SSID:
+		case MFIE_TYPE_SSID:
 			elems->ssid =3D pos;
 			elems->ssid_len =3D elen;
 			break;
=2D		case WLAN_EID_SUPP_RATES:
+		case MFIE_TYPE_RATES:
 			elems->supp_rates =3D pos;
 			elems->supp_rates_len =3D elen;
 			break;
=2D		case WLAN_EID_FH_PARAMS:
+		case MFIE_TYPE_FH_SET:
 			elems->fh_params =3D pos;
 			elems->fh_params_len =3D elen;
 			break;
=2D		case WLAN_EID_DS_PARAMS:
+		case MFIE_TYPE_DS_SET:
 			elems->ds_params =3D pos;
 			elems->ds_params_len =3D elen;
 			break;
=2D		case WLAN_EID_CF_PARAMS:
+		case MFIE_TYPE_CF_SET:
 			elems->cf_params =3D pos;
 			elems->cf_params_len =3D elen;
 			break;
=2D		case WLAN_EID_TIM:
+		case MFIE_TYPE_TIM:
 			elems->tim =3D pos;
 			elems->tim_len =3D elen;
 			break;
=2D		case WLAN_EID_IBSS_PARAMS:
+		case MFIE_TYPE_IBSS_SET:
 			elems->ibss_params =3D pos;
 			elems->ibss_params_len =3D elen;
 			break;
=2D		case WLAN_EID_CHALLENGE:
+		case MFIE_TYPE_CHALLENGE:
 			elems->challenge =3D pos;
 			elems->challenge_len =3D elen;
 			break;
=2D		case WLAN_EID_WPA:
+		case MFIE_TYPE_GENERIC:
 			if (elen >=3D 4 && pos[0] =3D=3D 0x00 && pos[1] =3D=3D 0x50 &&
 			    pos[2] =3D=3D 0xf2) {
 				/* Microsoft OUI (00:50:F2) */
@@ -184,15 +184,15 @@ #endif
 				}
 			}
 			break;
=2D		case WLAN_EID_RSN:
+		case MFIE_TYPE_RSN:
 			elems->rsn =3D pos;
 			elems->rsn_len =3D elen;
 			break;
=2D		case WLAN_EID_ERP_INFO:
+		case MFIE_TYPE_ERP_INFO:
 			elems->erp_info =3D pos;
 			elems->erp_info_len =3D elen;
 			break;
=2D		case WLAN_EID_EXT_SUPP_RATES:
+		case MFIE_TYPE_RATES_EX:
 			elems->ext_supp_rates =3D pos;
 			elems->ext_supp_rates_len =3D elen;
 			break;
@@ -524,7 +524,7 @@ static void ieee80211_send_assoc(struct=20
=20
 	/* SSID */
 	ies =3D pos =3D skb_put(skb, 2 + ifsta->ssid_len);
=2D	*pos++ =3D WLAN_EID_SSID;
+	*pos++ =3D MFIE_TYPE_SSID;
 	*pos++ =3D ifsta->ssid_len;
 	memcpy(pos, ifsta->ssid, ifsta->ssid_len);
=20
@@ -532,7 +532,7 @@ static void ieee80211_send_assoc(struct=20
 	if (len > 8)
 		len =3D 8;
 	pos =3D skb_put(skb, len + 2);
=2D	*pos++ =3D WLAN_EID_SUPP_RATES;
+	*pos++ =3D MFIE_TYPE_RATES;
 	*pos++ =3D len;
 	for (i =3D 0; i < len; i++) {
 		int rate =3D local->curr_rates[i].rate;
@@ -543,7 +543,7 @@ static void ieee80211_send_assoc(struct=20
=20
 	if (local->num_curr_rates > len) {
 		pos =3D skb_put(skb, local->num_curr_rates - len + 2);
=2D		*pos++ =3D WLAN_EID_EXT_SUPP_RATES;
+		*pos++ =3D MFIE_TYPE_RATES_EX;
 		*pos++ =3D local->num_curr_rates - len;
 		for (i =3D len; i < local->num_curr_rates; i++) {
 			int rate =3D local->curr_rates[i].rate;
@@ -560,7 +560,7 @@ static void ieee80211_send_assoc(struct=20
=20
 	if (wmm && ifsta->wmm_enabled) {
 		pos =3D skb_put(skb, 9);
=2D		*pos++ =3D WLAN_EID_VENDOR_SPECIFIC;
+		*pos++ =3D MFIE_TYPE_GENERIC;
 		*pos++ =3D 7; /* len */
 		*pos++ =3D 0x00; /* Microsoft OUI 00:50:F2 */
 		*pos++ =3D 0x50;
@@ -775,12 +775,12 @@ static void ieee80211_send_probe_req(str
 		memset(mgmt->bssid, 0xff, ETH_ALEN);
 	}
 	pos =3D skb_put(skb, 2 + ssid_len);
=2D	*pos++ =3D WLAN_EID_SSID;
+	*pos++ =3D MFIE_TYPE_SSID;
 	*pos++ =3D ssid_len;
 	memcpy(pos, ssid, ssid_len);
=20
 	supp_rates =3D skb_put(skb, 2);
=2D	supp_rates[0] =3D WLAN_EID_SUPP_RATES;
+	supp_rates[0] =3D MFIE_TYPE_RATES;
 	supp_rates[1] =3D 0;
 	for (i =3D 0; i < local->num_curr_rates; i++) {
 		struct ieee80211_rate *rate =3D &local->curr_rates[i];
@@ -791,7 +791,7 @@ static void ieee80211_send_probe_req(str
 			esupp_rates[1]++;
 		} else if (supp_rates[1] =3D=3D 8) {
 			esupp_rates =3D skb_put(skb, 3);
=2D			esupp_rates[0] =3D WLAN_EID_EXT_SUPP_RATES;
+			esupp_rates[0] =3D MFIE_TYPE_RATES_EX;
 			esupp_rates[1] =3D 1;
 			pos =3D &esupp_rates[2];
 		} else {
@@ -1673,7 +1673,7 @@ #endif /* IEEE80211_IBSS_DEBUG */
=20
 	end =3D ((u8 *) mgmt) + len;
 	pos =3D mgmt->u.probe_req.variable;
=2D	if (pos[0] !=3D WLAN_EID_SSID ||
+	if (pos[0] !=3D MFIE_TYPE_SSID ||
 	    pos + 2 + pos[1] > end) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: Invalid SSID IE in ProbeReq "
@@ -2028,7 +2028,7 @@ static int ieee80211_sta_join_ibss(struc
 		mgmt->u.beacon.capab_info =3D cpu_to_le16(bss->capability);
=20
 		pos =3D skb_put(skb, 2 + ifsta->ssid_len);
=2D		*pos++ =3D WLAN_EID_SSID;
+		*pos++ =3D MFIE_TYPE_SSID;
 		*pos++ =3D ifsta->ssid_len;
 		memcpy(pos, ifsta->ssid, ifsta->ssid_len);
=20
@@ -2036,17 +2036,17 @@ static int ieee80211_sta_join_ibss(struc
 		if (rates > 8)
 			rates =3D 8;
 		pos =3D skb_put(skb, 2 + rates);
=2D		*pos++ =3D WLAN_EID_SUPP_RATES;
+		*pos++ =3D MFIE_TYPE_RATES;
 		*pos++ =3D rates;
 		memcpy(pos, bss->supp_rates, rates);
=20
 		pos =3D skb_put(skb, 2 + 1);
=2D		*pos++ =3D WLAN_EID_DS_PARAMS;
+		*pos++ =3D MFIE_TYPE_DS_SET;
 		*pos++ =3D 1;
 		*pos++ =3D bss->channel;
=20
 		pos =3D skb_put(skb, 2 + 2);
=2D		*pos++ =3D WLAN_EID_IBSS_PARAMS;
+		*pos++ =3D MFIE_TYPE_IBSS_SET;
 		*pos++ =3D 2;
 		/* FIX: set ATIM window based on scan results */
 		*pos++ =3D 0;
@@ -2055,7 +2055,7 @@ static int ieee80211_sta_join_ibss(struc
 		if (bss->supp_rates_len > 8) {
 			rates =3D bss->supp_rates_len - 8;
 			pos =3D skb_put(skb, 2 + rates);
=2D			*pos++ =3D WLAN_EID_EXT_SUPP_RATES;
+			*pos++ =3D MFIE_TYPE_RATES_EX;
 			*pos++ =3D rates;
 			memcpy(pos, &bss->supp_rates[8], rates);
 		}

--nextPart1396562.H5pCDvWBkd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE1Fq0T3Oqt9AH4aERAl48AJ9H2rdh9L1kHYN8tcPizUuip1yEDgCfQDIs
OhL1lOf1qxyFPS/L+XUojSw=
=wV14
-----END PGP SIGNATURE-----

--nextPart1396562.H5pCDvWBkd--
