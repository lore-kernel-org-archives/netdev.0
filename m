From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8188eu: Fix Smatch warnings
Date: Wed, 12 Feb 2014 11:27:45 -0600
Message-ID: <1392226065-21778-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Dan Carpenter <dan.carpenter@oracle.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Smatch reports the following:

core/rtw_ieee80211.c:489 rtw_get_wpa_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:491 rtw_get_wpa_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:493 rtw_get_wpa_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:495 rtw_get_wpa_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:497 rtw_get_wpa_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:505 rtw_get_wpa2_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:507 rtw_get_wpa2_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:509 rtw_get_wpa2_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:511 rtw_get_wpa2_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:513 rtw_get_wpa2_cipher_suite() warn: add some parenthesis here?
core/rtw_ieee80211.c:534 rtw_parse_wpa_ie() warn: add some parenthesis here?
core/rtw_ieee80211.c:579 rtw_parse_wpa_ie() warn: add some parenthesis here?
core/rtw_ieee80211.c:649 rtw_parse_wpa2_ie() warn: add some parenthesis here?
core/rtw_ieee80211.c:803 rtw_get_wps_attr() warn: add some parenthesis here?
core/rtw_ieee80211.c:1213 rtw_get_p2p_ie() warn: add some parenthesis here?
core/rtw_ieee80211.c:1248 rtw_get_p2p_attr() warn: add some parenthesis here?
core/rtw_mlme.c:258 _rtw_find_network() warn: add some parenthesis here?
core/rtw_mlme.c:1581 rtw_check_join_candidate() warn: this array is probably non-NULL. 'pmlmepriv->assoc_ssid.Ssid'
core/rtw_mlme.c:1843 SecIsInPMKIDList() warn: add some parenthesis here?
core/rtw_mlme_ext.c:4189 on_action_public_vendor() warn: add some parenthesis here?
core/rtw_recv.c:1157 validate_recv_mgnt_frame() warn: add some parenthesis here?
core/rtw_xmit.c:671 xmitframe_addmic() warn: add some parenthesis here?
hal/rtl8188e_mp.c:206 Hal_MPT_CCKTxPowerAdjustbyIndex() error: buffer overflow 'CCKSwingTable_Ch1_Ch13' 33 <= 255
hal/rtl8188e_mp.c:215 Hal_MPT_CCKTxPowerAdjustbyIndex() error: buffer overflow 'CCKSwingTable_Ch14' 33 <= 255

Not listed here is one remaining buffer overflow message that I believe to be an error in Smatch.

These warnings were reported by the 0-DAY kernel build testing backend.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ieee80211.c | 32 +++++++++++++-------------
 drivers/staging/rtl8188eu/core/rtw_mlme.c      |  6 ++---
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c  |  2 +-
 drivers/staging/rtl8188eu/core/rtw_recv.c      |  3 ++-
 drivers/staging/rtl8188eu/core/rtw_xmit.c      |  2 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_mp.c    |  2 ++
 6 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ieee80211.c b/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
index d779c80..4076c66 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
@@ -486,15 +486,15 @@ unsigned char *rtw_get_wpa2_ie(unsigned char *pie, int *rsn_ie_len, int limit)
 
 int rtw_get_wpa_cipher_suite(u8 *s)
 {
-	if (!memcmp(s, WPA_CIPHER_SUITE_NONE, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_NONE, WPA_SELECTOR_LEN))
 		return WPA_CIPHER_NONE;
-	if (!memcmp(s, WPA_CIPHER_SUITE_WEP40, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_WEP40, WPA_SELECTOR_LEN))
 		return WPA_CIPHER_WEP40;
-	if (!memcmp(s, WPA_CIPHER_SUITE_TKIP, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_TKIP, WPA_SELECTOR_LEN))
 		return WPA_CIPHER_TKIP;
-	if (!memcmp(s, WPA_CIPHER_SUITE_CCMP, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_CCMP, WPA_SELECTOR_LEN))
 		return WPA_CIPHER_CCMP;
-	if (!memcmp(s, WPA_CIPHER_SUITE_WEP104, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_WEP104, WPA_SELECTOR_LEN))
 		return WPA_CIPHER_WEP104;
 
 	return 0;
@@ -502,15 +502,15 @@ int rtw_get_wpa_cipher_suite(u8 *s)
 
 int rtw_get_wpa2_cipher_suite(u8 *s)
 {
-	if (!memcmp(s, RSN_CIPHER_SUITE_NONE, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_NONE, RSN_SELECTOR_LEN))
 		return WPA_CIPHER_NONE;
-	if (!memcmp(s, RSN_CIPHER_SUITE_WEP40, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_WEP40, RSN_SELECTOR_LEN))
 		return WPA_CIPHER_WEP40;
-	if (!memcmp(s, RSN_CIPHER_SUITE_TKIP, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_TKIP, RSN_SELECTOR_LEN))
 		return WPA_CIPHER_TKIP;
-	if (!memcmp(s, RSN_CIPHER_SUITE_CCMP, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_CCMP, RSN_SELECTOR_LEN))
 		return WPA_CIPHER_CCMP;
-	if (!memcmp(s, RSN_CIPHER_SUITE_WEP104, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_WEP104, RSN_SELECTOR_LEN))
 		return WPA_CIPHER_WEP104;
 
 	return 0;
@@ -531,7 +531,7 @@ int rtw_parse_wpa_ie(u8 *wpa_ie, int wpa_ie_len, int *group_cipher, int *pairwis
 
 
 	if ((*wpa_ie != _WPA_IE_ID_) || (*(wpa_ie+1) != (u8)(wpa_ie_len - 2)) ||
-	    (!memcmp(wpa_ie+2, RTW_WPA_OUI_TYPE, WPA_SELECTOR_LEN) != true))
+	    (memcmp(wpa_ie+2, RTW_WPA_OUI_TYPE, WPA_SELECTOR_LEN)))
 		return _FAIL;
 
 	pos = wpa_ie;
@@ -576,7 +576,7 @@ int rtw_parse_wpa_ie(u8 *wpa_ie, int wpa_ie_len, int *group_cipher, int *pairwis
 	if (is_8021x) {
 		if (left >= 6) {
 			pos += 2;
-			if (!memcmp(pos, SUITE_1X, 4) == 1) {
+			if (!memcmp(pos, SUITE_1X, 4)) {
 				RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("%s : there has 802.1x auth\n", __func__));
 				*is_8021x = 1;
 			}
@@ -646,7 +646,7 @@ int rtw_parse_wpa2_ie(u8 *rsn_ie, int rsn_ie_len, int *group_cipher, int *pairwi
 	if (is_8021x) {
 		if (left >= 6) {
 			pos += 2;
-			if (!memcmp(pos, SUITE_1X, 4) == 1) {
+			if (!memcmp(pos, SUITE_1X, 4)) {
 				RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("%s (): there has 802.1x auth\n", __func__));
 				*is_8021x = 1;
 			}
@@ -800,7 +800,7 @@ u8 *rtw_get_wps_attr(u8 *wps_ie, uint wps_ielen, u16 target_attr_id , u8 *buf_at
 		*len_attr = 0;
 
 	if ((wps_ie[0] != _VENDOR_SPECIFIC_IE_) ||
-	    (!memcmp(wps_ie + 2, wps_oui , 4) != true))
+	    (memcmp(wps_ie + 2, wps_oui , 4)))
 		return attr_ptr;
 
 	/*  6 = 1(Element ID) + 1(Length) + 4(WPS OUI) */
@@ -1210,7 +1210,7 @@ u8 *rtw_get_p2p_ie(u8 *in_ie, int in_len, u8 *p2p_ie, uint *p2p_ielen)
 			dump_stack();
 			return NULL;
 		}
-		if ((eid == _VENDOR_SPECIFIC_IE_) && (!memcmp(&in_ie[cnt+2], p2p_oui, 4) == true)) {
+		if ((eid == _VENDOR_SPECIFIC_IE_) && (!memcmp(&in_ie[cnt+2], p2p_oui, 4))) {
 			p2p_ie_ptr = in_ie + cnt;
 
 			if (p2p_ie != NULL)
@@ -1245,7 +1245,7 @@ u8 *rtw_get_p2p_attr(u8 *p2p_ie, uint p2p_ielen, u8 target_attr_id , u8 *buf_att
 		*len_attr = 0;
 
 	if (!p2p_ie || (p2p_ie[0] != _VENDOR_SPECIFIC_IE_) ||
-	    (!memcmp(p2p_ie + 2, p2p_oui , 4) != true))
+	    (memcmp(p2p_ie + 2, p2p_oui , 4)))
 		return attr_ptr;
 
 	/*  6 = 1(Element ID) + 1(Length) + 3 (OUI) + 1(OUI Type) */
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 260da41..a934bd9 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -255,7 +255,7 @@ struct wlan_network *_rtw_find_network(struct __queue *scanned_queue, u8 *addr)
 
 	while (plist != phead) {
 		pnetwork = container_of(plist, struct wlan_network , list);
-		if (!memcmp(addr, pnetwork->network.MacAddress, ETH_ALEN) == true)
+		if (!memcmp(addr, pnetwork->network.MacAddress, ETH_ALEN))
 			break;
 		plist = plist->next;
 	}
@@ -1578,7 +1578,7 @@ static int rtw_check_join_candidate(struct mlme_priv *pmlmepriv
 	}
 
 	/* check ssid, if needed */
-	if (pmlmepriv->assoc_ssid.Ssid && pmlmepriv->assoc_ssid.SsidLength) {
+	if (pmlmepriv->assoc_ssid.SsidLength) {
 		if (competitor->network.Ssid.SsidLength != pmlmepriv->assoc_ssid.SsidLength ||
 		    !memcmp(competitor->network.Ssid.Ssid, pmlmepriv->assoc_ssid.Ssid, pmlmepriv->assoc_ssid.SsidLength) == false)
 			goto exit;
@@ -1840,7 +1840,7 @@ static int SecIsInPMKIDList(struct adapter *Adapter, u8 *bssid)
 
 	do {
 		if ((psecuritypriv->PMKIDList[i].bUsed) &&
-		    (!memcmp(psecuritypriv->PMKIDList[i].Bssid, bssid, ETH_ALEN) == true)) {
+		    (!memcmp(psecuritypriv->PMKIDList[i].Bssid, bssid, ETH_ALEN))) {
 			break;
 		} else {
 			i++;
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index b84610f..301cda5 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -4186,7 +4186,7 @@ static unsigned int on_action_public_vendor(union recv_frame *precv_frame)
 	u8 *pframe = precv_frame->u.hdr.rx_data;
 	u8 *frame_body = pframe + sizeof(struct rtw_ieee80211_hdr_3addr);
 
-	if (!memcmp(frame_body + 2, P2P_OUI, 4) == true)
+	if (!memcmp(frame_body + 2, P2P_OUI, 4))
 		ret = on_action_public_p2p(precv_frame);
 
 	return ret;
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 94d320b..35397bd 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -1154,7 +1154,8 @@ static int validate_recv_mgnt_frame(struct adapter *padapter,
 		} else if (GetFrameSubType(precv_frame->u.hdr.rx_data) == WIFI_PROBEREQ) {
 			psta->sta_stats.rx_probereq_pkts++;
 		} else if (GetFrameSubType(precv_frame->u.hdr.rx_data) == WIFI_PROBERSP) {
-			if (!memcmp(padapter->eeprompriv.mac_addr, GetAddr1Ptr(precv_frame->u.hdr.rx_data), ETH_ALEN) == true)
+			if (!memcmp(padapter->eeprompriv.mac_addr,
+				    GetAddr1Ptr(precv_frame->u.hdr.rx_data), ETH_ALEN))
 				psta->sta_stats.rx_probersp_pkts++;
 			else if (is_broadcast_mac_addr(GetAddr1Ptr(precv_frame->u.hdr.rx_data)) ||
 				 is_multicast_mac_addr(GetAddr1Ptr(precv_frame->u.hdr.rx_data)))
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 44e54a3..4475ed4 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -668,7 +668,7 @@ static s32 xmitframe_addmic(struct adapter *padapter, struct xmit_frame *pxmitfr
 				/* start to calculate the mic code */
 				rtw_secmicsetkey(&micdata, psecuritypriv->dot118021XGrptxmickey[psecuritypriv->dot118021XGrpKeyid].skey);
 			} else {
-				if (!memcmp(&stainfo->dot11tkiptxmickey.skey[0], null_key, 16) == true) {
+				if (!memcmp(&stainfo->dot11tkiptxmickey.skey[0], null_key, 16)) {
 					/* DbgPrint("\nxmitframe_addmic:stainfo->dot11tkiptxmickey == 0\n"); */
 					/* msleep(10); */
 					return _FAIL;
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
index cd2027b..cc71784 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
@@ -201,6 +201,8 @@ void Hal_MPT_CCKTxPowerAdjustbyIndex(struct adapter *pAdapter, bool beven)
 		else
 			CCK_index = CCK_index_old + 1;
 
+		if (CCK_index > 32)
+			CCK_index = 32;
 		/* Adjust CCK according to gain index */
 		if (!pDM_Odm->RFCalibrateInfo.bCCKinCH14) {
 			rtw_write8(pAdapter, 0xa22, CCKSwingTable_Ch1_Ch13[CCK_index][0]);
-- 
1.8.4.5
