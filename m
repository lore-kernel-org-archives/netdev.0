From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/6 NEXT] staging: r8723au: Additional source patches
Date: Fri, 28 Mar 2014 21:37:42 -0500
Message-ID: <1396060663-3589-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:55368 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbaC2Cik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 22:38:40 -0400
Received: by mail-oa0-f43.google.com with SMTP id eb12so7004482oac.2
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 19:38:33 -0700 (PDT)
In-Reply-To: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes are fixes that were discovered late in the testing
cycle.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8723au/core/rtw_ap.c            |   4 +-
 drivers/staging/rtl8723au/core/rtw_cmd.c           |   8 +-
 drivers/staging/rtl8723au/core/rtw_efuse.c         |   2 -
 drivers/staging/rtl8723au/core/rtw_ieee80211.c     |  24 +-
 drivers/staging/rtl8723au/core/rtw_mlme.c          |  13 +-
 drivers/staging/rtl8723au/core/rtw_mlme_ext.c      |  38 +--
 drivers/staging/rtl8723au/core/rtw_p2p.c           | 280 ++++++++++++---------
 drivers/staging/rtl8723au/core/rtw_pwrctrl.c       |  39 +--
 drivers/staging/rtl8723au/core/rtw_security.c      |  11 +-
 drivers/staging/rtl8723au/core/rtw_sreset.c        |   2 +
 drivers/staging/rtl8723au/core/rtw_wlan_util.c     |   2 +-
 drivers/staging/rtl8723au/core/rtw_xmit.c          |   7 +-
 drivers/staging/rtl8723au/hal/hal_intf.c           |   2 +
 .../staging/rtl8723au/hal/rtl8723a_bt-coexist.c    |  10 +-
 drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c  |   2 +-
 drivers/staging/rtl8723au/hal/rtl8723au_xmit.c     |   2 +-
 drivers/staging/rtl8723au/include/Hal8723APhyCfg.h |   2 -
 drivers/staging/rtl8723au/include/drv_types.h      |   4 -
 drivers/staging/rtl8723au/include/odm.h            |  17 +-
 drivers/staging/rtl8723au/include/odm_HWConfig.h   |  16 +-
 drivers/staging/rtl8723au/include/osdep_service.h  | 133 ----------
 .../rtl8723au/include/rtl8723a_bt-coexist.h        |   4 +-
 drivers/staging/rtl8723au/include/rtl8723a_pg.h    |  23 +-
 drivers/staging/rtl8723au/include/rtw_mlme.h       |  52 ++--
 drivers/staging/rtl8723au/include/rtw_mlme_ext.h   |   2 -
 drivers/staging/rtl8723au/include/rtw_pwrctrl.h    |   2 +-
 drivers/staging/rtl8723au/include/rtw_recv.h       |  11 +-
 drivers/staging/rtl8723au/include/sta_info.h       |  15 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c  |  55 +++-
 drivers/staging/rtl8723au/os_dep/osdep_service.c   | 254 -------------------
 drivers/staging/rtl8723au/os_dep/usb_intf.c        |   7 +-
 31 files changed, 343 insertions(+), 700 deletions(-)

diff --git a/drivers/staging/rtl8723au/core/rtw_ap.c b/drivers/staging/rtl8723au/core/rtw_ap.c
index 3d936eb..a357e98 100644
--- a/drivers/staging/rtl8723au/core/rtw_ap.c
+++ b/drivers/staging/rtl8723au/core/rtw_ap.c
@@ -842,10 +842,10 @@ int rtw_check_beacon_data23a(struct rtw_adapter *padapter, u8 *pbuf,  int len)
 	/* beacon interval */
 	/* ie + 8;  8: TimeStamp, 2: Beacon Interval 2:Capability */
 	p = rtw_get_beacon_interval23a_from_ie(ie);
-	pbss_network->Configuration.BeaconPeriod = RTW_GET_LE16(p);
+	pbss_network->Configuration.BeaconPeriod = get_unaligned_le16(p);
 
 	/* capability */
-	cap = RTW_GET_LE16(ie);
+	cap = get_unaligned_le16(ie);
 
 	/* SSID */
 	p = rtw_get_ie23a(ie + _BEACON_IE_OFFSET_, _SSID_IE_, &ie_len,
diff --git a/drivers/staging/rtl8723au/core/rtw_cmd.c b/drivers/staging/rtl8723au/core/rtw_cmd.c
index dbc6401..5e3088a 100644
--- a/drivers/staging/rtl8723au/core/rtw_cmd.c
+++ b/drivers/staging/rtl8723au/core/rtw_cmd.c
@@ -447,7 +447,7 @@ _next:
 
 		pcmdpriv->cmd_issued_cnt++;
 
-		pcmd->cmdsz = _RND4(pcmd->cmdsz);/* _RND4 */
+		pcmd->cmdsz = ALIGN(pcmd->cmdsz, 4);
 
 		memcpy(pcmdbuf, pcmd->parmbuf, pcmd->cmdsz);
 
@@ -1141,7 +1141,9 @@ static void traffic_status_watchdog(struct rtw_adapter *padapter)
 	u8 bHigherBusyTraffic = false, bHigherBusyRxTraffic = false;
 	u8 bHigherBusyTxTraffic = false;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
-
+#ifndef CONFIG_8723AU_BT_COEXIST
+	int BusyThreshold = 100;
+#endif
 	/*  */
 	/*  Determine if our traffic is busy now */
 	/*  */
@@ -1638,12 +1640,12 @@ u8 rtw_drvextra_cmd_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf)
 	case P2P_PS_WK_CID:
 		p2p_ps_wk_hdl23a(padapter, pdrvextra_cmd->type_size);
 		break;
-#endif /*  CONFIG_8723AU_P2P */
 	case P2P_PROTO_WK_CID:
 		/*	Commented by Albert 2011/07/01 */
 		/*	I used the type_size as the type command */
 		p2p_protocol_wk_hdl23a(padapter, pdrvextra_cmd->type_size);
 		break;
+#endif /*  CONFIG_8723AU_P2P */
 #ifdef CONFIG_8723AU_AP_MODE
 	case CHECK_HIQ_WK_CID:
 		rtw_chk_hi_queue_hdl(padapter);
diff --git a/drivers/staging/rtl8723au/core/rtw_efuse.c b/drivers/staging/rtl8723au/core/rtw_efuse.c
index 94221ee..35b177f 100644
--- a/drivers/staging/rtl8723au/core/rtw_efuse.c
+++ b/drivers/staging/rtl8723au/core/rtw_efuse.c
@@ -108,7 +108,6 @@ ReadEFuseByte23a(struct rtw_adapter *Adapter, u16 _offset, u8 *pbuf)
 	u32	value32;
 	u8	readbyte;
 	u16	retry;
-	/* u32 start = rtw_get_current_time(); */
 
 	/* Write Address */
 	rtw_write8(Adapter, EFUSE_CTRL+1, (_offset & 0xff));
@@ -137,7 +136,6 @@ ReadEFuseByte23a(struct rtw_adapter *Adapter, u16 _offset, u8 *pbuf)
 	value32 = rtw_read32(Adapter, EFUSE_CTRL);
 
 	*pbuf = (u8)(value32 & 0xff);
-	/* DBG_8723A("ReadEFuseByte23a _offset:%08u, in %d ms\n", _offset , rtw_get_passing_time_ms23a(start)); */
 }
 
 /*  */
diff --git a/drivers/staging/rtl8723au/core/rtw_ieee80211.c b/drivers/staging/rtl8723au/core/rtw_ieee80211.c
index 8287f44..780631f 100644
--- a/drivers/staging/rtl8723au/core/rtw_ieee80211.c
+++ b/drivers/staging/rtl8723au/core/rtw_ieee80211.c
@@ -196,8 +196,8 @@ inline u8 *rtw_set_ie23a_mesh_ch_switch_parm(u8 *buf, u32 *buf_len, u8 ttl,
 
 	ie_data[0] = ttl;
 	ie_data[1] = flags;
-	RTW_PUT_LE16((u8*)&ie_data[2], reason);
-	RTW_PUT_LE16((u8*)&ie_data[4], precedence);
+	put_unaligned_le16(reason, (u8*)&ie_data[2]);
+	put_unaligned_le16(precedence, (u8*)&ie_data[4]);
 
 	return rtw_set_ie23a(buf, 0x118,  6, ie_data, buf_len);
 }
@@ -585,7 +585,7 @@ int rtw_parse_wpa_ie23a(u8* wpa_ie, int wpa_ie_len, int *group_cipher, int *pair
 	/* pairwise_cipher */
 	if (left >= 2) {
                 /* count = le16_to_cpu(*(u16*)pos); */
-		count = RTW_GET_LE16(pos);
+		count = get_unaligned_le16(pos);
 		pos += 2;
 		left -= 2;
 
@@ -661,7 +661,7 @@ int rtw_parse_wpa2_ie23a(u8* rsn_ie, int rsn_ie_len, int *group_cipher,
 	/* pairwise_cipher */
 	if (left >= 2) {
 	        /* count = le16_to_cpu(*(u16*)pos); */
-		count = RTW_GET_LE16(pos);
+		count = get_unaligned_le16(pos);
 		pos += 2;
 		left -= 2;
 
@@ -876,8 +876,8 @@ u8 *rtw_get_wps_attr23a(u8 *wps_ie, uint wps_ielen, u16 target_attr_id,
 
 	while (attr_ptr - wps_ie < wps_ielen) {
 		/*  4 = 2(Attribute ID) + 2(Length) */
-		u16 attr_id = RTW_GET_BE16(attr_ptr);
-		u16 attr_data_len = RTW_GET_BE16(attr_ptr + 2);
+		u16 attr_id = get_unaligned_be16(attr_ptr);
+		u16 attr_data_len = get_unaligned_be16(attr_ptr + 2);
 		u16 attr_len = attr_data_len + 4;
 
 		/* DBG_8723A("%s attr_ptr:%p, id:%u, length:%u\n", __func__, attr_ptr, attr_id, attr_data_len); */
@@ -1246,8 +1246,8 @@ void dump_wps_ie23a(u8 *ie, u32 ie_len) {
 
 	pos+= 6;
 	while (pos-ie < ie_len) {
-		id = RTW_GET_BE16(pos);
-		len = RTW_GET_BE16(pos + 2);
+		id = get_unaligned_be16(pos);
+		len = get_unaligned_be16(pos + 2);
 
 		DBG_8723A("%s ID:0x%04x, LEN:%u\n", __func__, id, len);
 
@@ -1271,7 +1271,7 @@ void dump_p2p_ie23a(u8 *ie, u32 ie_len) {
 	pos += 6;
 	while (pos-ie < ie_len) {
 		id = *pos;
-		len = RTW_GET_LE16(pos+1);
+		len = get_unaligned_le16(pos+1);
 
 		DBG_8723A("%s ID:%u, LEN:%u\n", __func__, id, len);
 
@@ -1362,7 +1362,7 @@ u8 *rtw_get_p2p_attr23a(u8 *p2p_ie, uint p2p_ielen, u8 target_attr_id,
 	while (attr_ptr - p2p_ie < p2p_ielen) {
 		/*  3 = 1(Attribute ID) + 2(Length) */
 		u8 attr_id = *attr_ptr;
-		u16 attr_data_len = RTW_GET_LE16(attr_ptr + 1);
+		u16 attr_data_len = get_unaligned_le16(attr_ptr + 1);
 		u16 attr_len = attr_data_len + 3;
 
 		/* DBG_8723A("%s attr_ptr:%p, id:%u, length:%u\n", __func__, attr_ptr, attr_id, attr_data_len); */
@@ -1429,7 +1429,7 @@ u32 rtw_set_p2p_attr_content23a(u8 *pbuf, u8 attr_id, u16 attr_len, u8 *pdata_at
 	*pbuf = attr_id;
 
 	/* u16*)(pbuf + 1) = cpu_to_le16(attr_len); */
-	RTW_PUT_LE16(pbuf + 1, attr_len);
+	put_unaligned_le16(attr_len, pbuf + 1);
 
 	if (pdata_attr)
 		memcpy(pbuf + 3, pdata_attr, attr_len);
@@ -1561,7 +1561,7 @@ int rtw_get_wfd_attr_content(u8 *wfd_ie, uint wfd_ielen, u8 target_attr_id,
 	/*	1 (WFD IE) + 1 (Length) + 3 (OUI) + 1 (OUI Type) */
 	cnt = 6;
 	while (cnt < wfd_ielen) {
-		u16 attrlen = RTW_GET_BE16(wfd_ie + cnt + 1);
+		u16 attrlen = get_unaligned_be16(wfd_ie + cnt + 1);
 
 		attr_id = wfd_ie[cnt];
 		if (attr_id == target_attr_id) {
diff --git a/drivers/staging/rtl8723au/core/rtw_mlme.c b/drivers/staging/rtl8723au/core/rtw_mlme.c
index 71749a3..6cee787 100644
--- a/drivers/staging/rtl8723au/core/rtw_mlme.c
+++ b/drivers/staging/rtl8723au/core/rtw_mlme.c
@@ -69,6 +69,7 @@ int _rtw_init_mlme_priv23a(struct rtw_adapter *padapter)
 	return res;
 }
 
+#ifdef CONFIG_8723AU_AP_MODE
 static void rtw_free_mlme_ie_data(u8 **ppie, u32 *plen)
 {
 	if(*ppie)
@@ -78,6 +79,7 @@ static void rtw_free_mlme_ie_data(u8 **ppie, u32 *plen)
 		*ppie=NULL;
 	}
 }
+#endif
 
 void rtw23a_free_mlme_priv_ie_data(struct mlme_priv *pmlmepriv)
 {
@@ -94,9 +96,7 @@ void rtw23a_free_mlme_priv_ie_data(struct mlme_priv *pmlmepriv)
 	rtw_free_mlme_ie_data(&pmlmepriv->p2p_probe_resp_ie, &pmlmepriv->p2p_probe_resp_ie_len);
 	rtw_free_mlme_ie_data(&pmlmepriv->p2p_go_probe_resp_ie, &pmlmepriv->p2p_go_probe_resp_ie_len);
 	rtw_free_mlme_ie_data(&pmlmepriv->p2p_assoc_req_ie, &pmlmepriv->p2p_assoc_req_ie_len);
-#endif
 
-#if defined(CONFIG_8723AU_P2P)
 	rtw_free_mlme_ie_data(&pmlmepriv->wfd_beacon_ie, &pmlmepriv->wfd_beacon_ie_len);
 	rtw_free_mlme_ie_data(&pmlmepriv->wfd_probe_req_ie, &pmlmepriv->wfd_probe_req_ie_len);
 	rtw_free_mlme_ie_data(&pmlmepriv->wfd_probe_resp_ie, &pmlmepriv->wfd_probe_resp_ie_len);
@@ -941,7 +941,7 @@ void rtw_indicate_disconnect23a(struct rtw_adapter *padapter)
 
 		/* set ips_deny_time to avoid enter IPS before LPS leave */
 		padapter->pwrctrlpriv.ips_deny_time =
-			rtw_get_current_time() + rtw_ms_to_systime23a(3000);
+			jiffies + msecs_to_jiffies(3000);
 
 		_clr_fwstate_(pmlmepriv, _FW_LINKED);
 
@@ -1675,7 +1675,7 @@ static int rtw_check_join_candidate(struct mlme_priv *pmlmepriv
 	}
 
 	/* check ssid, if needed */
-	if (pmlmepriv->assoc_ssid.ssid && pmlmepriv->assoc_ssid.ssid_len) {
+	if (pmlmepriv->assoc_ssid.ssid_len) {
 		if (competitor->network.Ssid.ssid_len !=
 		    pmlmepriv->assoc_ssid.ssid_len ||
 		    memcmp(competitor->network.Ssid.ssid,
@@ -1839,8 +1839,7 @@ int rtw_set_key23a(struct rtw_adapter *adapter,
 		res = _FAIL;  /* try again */
 		goto exit;
 	}
-	psetkeyparm = (struct setkey_parm *)
-		kzalloc(sizeof(struct setkey_parm), GFP_KERNEL);
+	psetkeyparm = kzalloc(sizeof(struct setkey_parm), GFP_KERNEL);
 	if (!psetkeyparm) {
 		kfree(pcmd);
 		res = _FAIL;
@@ -1902,6 +1901,8 @@ int rtw_set_key23a(struct rtw_adapter *adapter,
 			  "%x (must be 1 or 2 or 4 or 5)\n",
 			  psecuritypriv->dot11PrivacyAlgrthm));
 		res = _FAIL;
+		kfree(pcmd);
+		kfree(psetkeyparm);
 		goto exit;
 	}
 
diff --git a/drivers/staging/rtl8723au/core/rtw_mlme_ext.c b/drivers/staging/rtl8723au/core/rtw_mlme_ext.c
index 75ccdec..4c75363 100644
--- a/drivers/staging/rtl8723au/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8723au/core/rtw_mlme_ext.c
@@ -762,9 +762,9 @@ unsigned int OnProbeRsp23a(struct rtw_adapter *padapter,
 			   struct recv_frame *precv_frame)
 {
 	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+#ifdef CONFIG_8723AU_P2P
 	struct sk_buff *skb = precv_frame->pkt;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-#ifdef CONFIG_8723AU_P2P
 	struct wifidirect_info	*pwdinfo = &padapter->wdinfo;
 #endif
 
@@ -1309,10 +1309,10 @@ unsigned int OnAssocReq23a(struct rtw_adapter *padapter, struct recv_frame *prec
 		goto asoc_class2_error;
 	}
 
-	capab_info = RTW_GET_LE16(pframe + sizeof(struct ieee80211_hdr_3addr));
+	capab_info = get_unaligned_le16(pframe + sizeof(struct ieee80211_hdr_3addr));
 	/* capab_info = le16_to_cpu(*(unsigned short *)(pframe + sizeof(struct ieee80211_hdr_3addr))); */
 	/* listen_interval = le16_to_cpu(*(unsigned short *)(pframe + sizeof(struct ieee80211_hdr_3addr)+2)); */
-	listen_interval = RTW_GET_LE16(pframe + sizeof(struct ieee80211_hdr_3addr)+2);
+	listen_interval = get_unaligned_le16(pframe + sizeof(struct ieee80211_hdr_3addr)+2);
 
 	left = pkt_len - (sizeof(struct ieee80211_hdr_3addr) + ie_offset);
 	pos = pframe + (sizeof(struct ieee80211_hdr_3addr) + ie_offset);
@@ -1665,7 +1665,7 @@ unsigned int OnAssocReq23a(struct rtw_adapter *padapter, struct recv_frame *prec
 			rtw_get_wfd_attr_content(wfd_ie, wfd_ielen, WFD_ATTR_DEVICE_INFO, attr_content, &attr_contentlen);
 			if (attr_contentlen)
 			{
-				pwdinfo->wfd_info->peer_rtsp_ctrlport = RTW_GET_BE16(attr_content + 2);
+				pwdinfo->wfd_info->peer_rtsp_ctrlport = get_unaligned_be16(attr_content + 2);
 				DBG_8723A("[%s] Peer PORT NUM = %d\n", __func__, pwdinfo->wfd_info->peer_rtsp_ctrlport);
 			}
 		}
@@ -2091,7 +2091,7 @@ unsigned int OnAction23a_back23a(struct rtw_adapter *padapter, struct recv_frame
 			}
 			break;
 		case WLAN_ACTION_ADDBA_RESP: /* ADDBA response */
-			status = RTW_GET_LE16(&frame_body[3]);
+			status = get_unaligned_le16(&frame_body[3]);
 			tid = ((frame_body[5] >> 2) & 0x7);
 			if (status == 0) {	/* successful */
 				DBG_8723A("agg_enable for TID =%d\n", tid);
@@ -2110,7 +2110,7 @@ unsigned int OnAction23a_back23a(struct rtw_adapter *padapter, struct recv_frame
 					~(1 << ((frame_body[3] >> 4) & 0xf));
 
 				/* reason_code = frame_body[4] | (frame_body[5] << 8); */
-				reason_code = RTW_GET_LE16(&frame_body[4]);
+				reason_code = get_unaligned_le16(&frame_body[4]);
 			} else if ((frame_body[3] & BIT(3)) == BIT(3)) {
 				tid = (frame_body[3] >> 4) & 0x0F;
 
@@ -4531,14 +4531,14 @@ static s32 rtw_action_public_decache(struct recv_frame *recv_frame, s32 token)
 
 static unsigned int on_action_public23a_p2p(struct recv_frame *precv_frame)
 {
-	struct rtw_adapter *padapter = precv_frame->adapter;
 	struct sk_buff *skb = precv_frame->pkt;
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	u8 *pframe = skb->data;
-	uint len = skb->len;
 	u8 *frame_body;
 	u8 dialogToken = 0;
 #ifdef CONFIG_8723AU_P2P
+	struct rtw_adapter *padapter = precv_frame->adapter;
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	uint len = skb->len;
 	u8 *p2p_ie;
 	u32	p2p_ielen;
 	struct	wifidirect_info	*pwdinfo = &padapter->wdinfo;
@@ -5262,9 +5262,7 @@ void issue_beacon23a(struct rtw_adapter *padapter, int timeout_ms)
 	unsigned short *fctrl;
 	unsigned int rate_len;
 	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
-#ifdef CONFIG_8723AU_AP_MODE
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
-#endif
 	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info *pmlmeinfo = &pmlmeext->mlmext_info;
 	struct wlan_bssid_ex *cur_network = &pmlmeinfo->network;
@@ -5579,6 +5577,13 @@ void issue_probersp23a(struct rtw_adapter *padapter, unsigned char *da,
 #ifdef CONFIG_8723AU_AP_MODE
 	u8 *pwps_ie;
 	uint wps_ielen;
+	u8 *ssid_ie;
+	int ssid_ielen;
+	int ssid_ielen_diff;
+	u8 buf[MAX_IE_SZ];
+	u8 *ies;
+#endif
+#if defined(CONFIG_8723AU_AP_MODE) || defined(CONFIG_8723AU_P2P)
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 #endif
 	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
@@ -5588,11 +5593,6 @@ void issue_probersp23a(struct rtw_adapter *padapter, unsigned char *da,
 #ifdef CONFIG_8723AU_P2P
 	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
 #endif /* CONFIG_8723AU_P2P */
-	u8 *ssid_ie;
-	int ssid_ielen;
-	int ssid_ielen_diff;
-	u8 buf[MAX_IE_SZ];
-	u8 *ies;
 
 	/* DBG_8723A("%s\n", __func__); */
 
@@ -7559,6 +7559,7 @@ unsigned int send_beacon23a(struct rtw_adapter *padapter)
 	int	issue = 0;
 	int poll = 0;
 	unsigned long start = jiffies;
+	unsigned int passing_time;
 
 	rtw_hal_set_hwreg23a(padapter, HW_VAR_BCN_VALID, NULL);
 	do {
@@ -7578,11 +7579,12 @@ unsigned int send_beacon23a(struct rtw_adapter *padapter)
 	if (padapter->bSurpriseRemoved || padapter->bDriverStopped)
 		return _FAIL;
 
+	passing_time = jiffies_to_msecs(jiffies - start);
+
 	if (!bxmitok) {
-		DBG_8723A("%s fail! %u ms\n", __func__, rtw_get_passing_time_ms23a(start));
+		DBG_8723A("%s fail! %u ms\n", __func__, passing_time);
 		return _FAIL;
 	} else {
-		unsigned int passing_time = jiffies_to_msecs(jiffies - start);
 
 		if (passing_time > 100 || issue > 3)
 			DBG_8723A("%s success, issue:%d, poll:%d, %u ms\n",
diff --git a/drivers/staging/rtl8723au/core/rtw_p2p.c b/drivers/staging/rtl8723au/core/rtw_p2p.c
index becc3fe..27a6cc7 100644
--- a/drivers/staging/rtl8723au/core/rtw_p2p.c
+++ b/drivers/staging/rtl8723au/core/rtw_p2p.c
@@ -81,7 +81,7 @@ static u32 go_add_group_info_attr(struct wifidirect_info *pwdinfo, u8 *pbuf)
 			pcur++;
 
 			/* u16*)(pcur) = cpu_to_be16(psta->config_methods); */
-			RTW_PUT_BE16(pcur, psta->config_methods);
+			put_unaligned_be16(psta->config_methods, pcur);
 			pcur += 2;
 
 			memcpy(pcur, psta->primary_dev_type, 8);
@@ -96,11 +96,11 @@ static u32 go_add_group_info_attr(struct wifidirect_info *pwdinfo, u8 *pbuf)
 			if (psta->dev_name_len>0)
 			{
 				/* u16*)(pcur) = cpu_to_be16(WPS_ATTR_DEVICE_NAME); */
-				RTW_PUT_BE16(pcur, WPS_ATTR_DEVICE_NAME);
+				put_unaligned_be16(WPS_ATTR_DEVICE_NAME, pcur);
 				pcur += 2;
 
 				/* u16*)(pcur) = cpu_to_be16(psta->dev_name_len); */
-				RTW_PUT_BE16(pcur, psta->dev_name_len);
+				put_unaligned_be16(psta->dev_name_len, pcur);
 				pcur += 2;
 
 				memcpy(pcur, psta->dev_name, psta->dev_name_len);
@@ -320,23 +320,23 @@ static void issue_p2p_provision_resp(struct wifidirect_info *pwdinfo, u8* raddr,
 	wpsielen = 0;
 	/*	WPS OUI */
 	/* u32*) (wpsie) = cpu_to_be32(WPSOUI); */
-	RTW_PUT_BE32(wpsie, WPSOUI);
+	put_unaligned_be32(WPSOUI, wpsie);
 	wpsielen += 4;
 
 	/*	Config Method */
 	/*	Type: */
 	/* u16*) (wpsie + wpsielen) = cpu_to_be16(WPS_ATTR_CONF_METHOD); */
-	RTW_PUT_BE16(wpsie + wpsielen, WPS_ATTR_CONF_METHOD);
+	put_unaligned_be16(WPS_ATTR_CONF_METHOD, wpsie + wpsielen);
 	wpsielen += 2;
 
 	/*	Length: */
 	/* u16*) (wpsie + wpsielen) = cpu_to_be16(0x0002); */
-	RTW_PUT_BE16(wpsie + wpsielen, 0x0002);
+	put_unaligned_be16(0x0002, wpsie + wpsielen);
 	wpsielen += 2;
 
 	/*	Value: */
 	/* u16*) (wpsie + wpsielen) = cpu_to_be16(config_method); */
-	RTW_PUT_BE16(wpsie + wpsielen, config_method);
+	put_unaligned_be16(config_method, wpsie + wpsielen);
 	wpsielen += 2;
 
 	pframe = rtw_set_ie23a(pframe, _VENDOR_SPECIFIC_IE_, wpsielen, (unsigned char *) wpsie, &pattrib->pktlen);
@@ -513,7 +513,7 @@ u32 build_beacon_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
@@ -524,19 +524,24 @@ u32 build_beacon_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 		if (is_any_client_associated(pwdinfo->padapter))
 		{
 			/*	WFD primary sink + WiFi Direct mode + WSD (WFD Service Discovery) */
-			RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_WSD);
+			put_unaligned_be16(pwfd_info->wfd_device_type |
+					   WFD_DEVINFO_WSD, wfdie + wfdielen);
 		}
 		else
 		{
 			/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-			RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD);
+			put_unaligned_be16(pwfd_info->wfd_device_type |
+					   WFD_DEVINFO_SESSION_AVAIL |
+					   WFD_DEVINFO_WSD, wfdie + wfdielen);
 		}
 
 	}
 	else
 	{
 		/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-		RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD);
+		put_unaligned_be16(pwfd_info->wfd_device_type |
+				   WFD_DEVINFO_SESSION_AVAIL |
+				   WFD_DEVINFO_WSD, wfdie + wfdielen);
 	}
 
 	wfdielen += 2;
@@ -544,13 +549,13 @@ u32 build_beacon_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -559,7 +564,7 @@ u32 build_beacon_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -581,7 +586,7 @@ u32 build_beacon_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -628,7 +633,7 @@ u32 build_probe_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
@@ -637,17 +642,17 @@ u32 build_probe_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 	if (1 == pwdinfo->wfd_tdls_enable)
 	{
 		/*	WFD primary sink + available for WFD session + WiFi TDLS mode + WSC (WFD Service Discovery) */
-		RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type |
-						WFD_DEVINFO_SESSION_AVAIL |
-						WFD_DEVINFO_WSD |
-						WFD_DEVINFO_PC_TDLS);
+		put_unaligned_be16(pwfd_info->wfd_device_type |
+				   WFD_DEVINFO_SESSION_AVAIL |
+				   WFD_DEVINFO_WSD |
+				   WFD_DEVINFO_PC_TDLS, wfdie + wfdielen);
 	}
 	else
 	{
 		/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSC (WFD Service Discovery) */
-		RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type |
-						WFD_DEVINFO_SESSION_AVAIL |
-						WFD_DEVINFO_WSD);
+		put_unaligned_be16(pwfd_info->wfd_device_type |
+				   WFD_DEVINFO_SESSION_AVAIL |
+				   WFD_DEVINFO_WSD, wfdie + wfdielen);
 	}
 
 	wfdielen += 2;
@@ -655,13 +660,13 @@ u32 build_probe_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -670,7 +675,7 @@ u32 build_probe_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -692,7 +697,7 @@ u32 build_probe_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -740,7 +745,7 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
@@ -756,12 +761,12 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 				if (pwdinfo->wfd_tdls_enable)
 				{
 					/*	TDLS mode + WSD (WFD Service Discovery) */
-					RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_WSD | WFD_DEVINFO_PC_TDLS | WFD_DEVINFO_HDCP_SUPPORT);
+					put_unaligned_be16(pwfd_info->wfd_device_type | WFD_DEVINFO_WSD | WFD_DEVINFO_PC_TDLS | WFD_DEVINFO_HDCP_SUPPORT, wfdie + wfdielen);
 				}
 				else
 				{
 					/*	WiFi Direct mode + WSD (WFD Service Discovery) */
-					RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_WSD | WFD_DEVINFO_HDCP_SUPPORT);
+					put_unaligned_be16(pwfd_info->wfd_device_type | WFD_DEVINFO_WSD | WFD_DEVINFO_HDCP_SUPPORT, wfdie + wfdielen);
 				}
 			}
 			else
@@ -769,12 +774,12 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 				if (pwdinfo->wfd_tdls_enable)
 				{
 					/*	available for WFD session + TDLS mode + WSD (WFD Service Discovery) */
-					RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD | WFD_DEVINFO_PC_TDLS | WFD_DEVINFO_HDCP_SUPPORT);
+					put_unaligned_be16(pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD | WFD_DEVINFO_PC_TDLS | WFD_DEVINFO_HDCP_SUPPORT, wfdie + wfdielen);
 				}
 				else
 				{
 					/*	available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-					RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD | WFD_DEVINFO_HDCP_SUPPORT);
+					put_unaligned_be16(pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD | WFD_DEVINFO_HDCP_SUPPORT, wfdie + wfdielen);
 				}
 			}
 		}
@@ -783,13 +788,22 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 			if (pwdinfo->wfd_tdls_enable)
 			{
 				/*	available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-				RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD | WFD_DEVINFO_PC_TDLS | WFD_DEVINFO_HDCP_SUPPORT);
+				put_unaligned_be16(pwfd_info->wfd_device_type |
+						   WFD_DEVINFO_SESSION_AVAIL |
+						   WFD_DEVINFO_WSD |
+						   WFD_DEVINFO_PC_TDLS |
+						   WFD_DEVINFO_HDCP_SUPPORT,
+						   wfdie + wfdielen);
 			}
 			else
 			{
 
 				/*	available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-				RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD | WFD_DEVINFO_HDCP_SUPPORT);
+				put_unaligned_be16(pwfd_info->wfd_device_type |
+						   WFD_DEVINFO_SESSION_AVAIL |
+						   WFD_DEVINFO_WSD |
+						   WFD_DEVINFO_HDCP_SUPPORT,
+						   wfdie + wfdielen);
 			}
 		}
 	}
@@ -797,11 +811,18 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 	{
 		if (pwdinfo->wfd_tdls_enable)
 		{
-			RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_WSD |WFD_DEVINFO_PC_TDLS | WFD_DEVINFO_HDCP_SUPPORT);
+			put_unaligned_be16(pwfd_info->wfd_device_type |
+					   WFD_DEVINFO_WSD |
+					   WFD_DEVINFO_PC_TDLS |
+					   WFD_DEVINFO_HDCP_SUPPORT,
+					   wfdie + wfdielen);
 		}
 		else
 		{
-			RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_WSD | WFD_DEVINFO_HDCP_SUPPORT);
+			put_unaligned_be16(pwfd_info->wfd_device_type |
+					   WFD_DEVINFO_WSD |
+					   WFD_DEVINFO_HDCP_SUPPORT,
+					   wfdie + wfdielen);
 		}
 
 	}
@@ -811,13 +832,13 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -826,7 +847,7 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -848,7 +869,7 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -871,7 +892,7 @@ u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf, u8 tunnel
 
 		/*	Length: */
 		/*	Note: In the WFD specification, the size of length field is 2. */
-		RTW_PUT_BE16(wfdie + wfdielen, 0x0000);
+		put_unaligned_be16(0x0000, wfdie + wfdielen);
 		wfdielen += 2;
 
 		/*	Todo: to add the list of WFD device info descriptor in WFD group. */
@@ -919,25 +940,27 @@ u32 build_assoc_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD);
+	put_unaligned_be16(pwfd_info->wfd_device_type |
+			   WFD_DEVINFO_SESSION_AVAIL |
+			   WFD_DEVINFO_WSD, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -946,7 +969,7 @@ u32 build_assoc_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -968,7 +991,7 @@ u32 build_assoc_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1015,25 +1038,27 @@ u32 build_assoc_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD);
+	put_unaligned_be16(pwfd_info->wfd_device_type |
+			   WFD_DEVINFO_SESSION_AVAIL |
+			   WFD_DEVINFO_WSD, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -1042,7 +1067,7 @@ u32 build_assoc_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1064,7 +1089,7 @@ u32 build_assoc_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1111,25 +1136,27 @@ u32 build_nego_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + WiFi Direct mode + WSD (WFD Service Discovery) + WFD Session Available */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_WSD | WFD_DEVINFO_SESSION_AVAIL);
+	put_unaligned_be16(pwfd_info->wfd_device_type |
+			   WFD_DEVINFO_WSD | WFD_DEVINFO_SESSION_AVAIL,
+			   wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -1138,7 +1165,7 @@ u32 build_nego_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1160,7 +1187,7 @@ u32 build_nego_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1207,25 +1234,27 @@ u32 build_nego_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + WiFi Direct mode + WSD (WFD Service Discovery) + WFD Session Available */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_WSD | WFD_DEVINFO_SESSION_AVAIL);
+	put_unaligned_be16(pwfd_info->wfd_device_type |
+			   WFD_DEVINFO_WSD | WFD_DEVINFO_SESSION_AVAIL,
+			   wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -1234,7 +1263,7 @@ u32 build_nego_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1256,7 +1285,7 @@ u32 build_nego_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1303,25 +1332,26 @@ u32 build_nego_confirm_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + WiFi Direct mode + WSD (WFD Service Discovery) + WFD Session Available */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_WSD | WFD_DEVINFO_SESSION_AVAIL);
+	put_unaligned_be16(pwfd_info->wfd_device_type | WFD_DEVINFO_WSD |
+			   WFD_DEVINFO_SESSION_AVAIL, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -1330,7 +1360,7 @@ u32 build_nego_confirm_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1352,7 +1382,7 @@ u32 build_nego_confirm_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1399,25 +1429,27 @@ u32 build_invitation_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD);
+	put_unaligned_be16(pwfd_info->wfd_device_type |
+			   WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD,
+			   wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -1426,7 +1458,7 @@ u32 build_invitation_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1448,7 +1480,7 @@ u32 build_invitation_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1471,7 +1503,7 @@ u32 build_invitation_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 		/*	Length: */
 		/*	Note: In the WFD specification, the size of length field is 2. */
-		RTW_PUT_BE16(wfdie + wfdielen, 0x0000);
+		put_unaligned_be16(0x0000, wfdie + wfdielen);
 		wfdielen += 2;
 
 		/*	Todo: to add the list of WFD device info descriptor in WFD group. */
@@ -1510,25 +1542,27 @@ u32 build_invitation_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD);
+	put_unaligned_be16(pwfd_info->wfd_device_type |
+			   WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD,
+			   wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -1537,7 +1571,7 @@ u32 build_invitation_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1559,7 +1593,7 @@ u32 build_invitation_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1582,7 +1616,7 @@ u32 build_invitation_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 		/*	Length: */
 		/*	Note: In the WFD specification, the size of length field is 2. */
-		RTW_PUT_BE16(wfdie + wfdielen, 0x0000);
+		put_unaligned_be16(0x0000, wfdie + wfdielen);
 		wfdielen += 2;
 
 		/*	Todo: to add the list of WFD device info descriptor in WFD group. */
@@ -1621,25 +1655,27 @@ u32 build_provdisc_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD);
+	put_unaligned_be16(pwfd_info->wfd_device_type |
+			   WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD,
+			   wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -1648,7 +1684,7 @@ u32 build_provdisc_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1670,7 +1706,7 @@ u32 build_provdisc_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1717,25 +1753,27 @@ u32 build_provdisc_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value1: */
 	/*	WFD device information */
 	/*	WFD primary sink + available for WFD session + WiFi Direct mode + WSD (WFD Service Discovery) */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->wfd_device_type | WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD);
+	put_unaligned_be16(pwfd_info->wfd_device_type |
+			   WFD_DEVINFO_SESSION_AVAIL | WFD_DEVINFO_WSD,
+			   wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value2: */
 	/*	Session Management Control Port */
 	/*	Default TCP port for RTSP messages is 554 */
-	RTW_PUT_BE16(wfdie + wfdielen, pwfd_info->rtsp_ctrlport);
+	put_unaligned_be16(pwfd_info->rtsp_ctrlport, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value3: */
 	/*	WFD Device Maximum Throughput */
 	/*	300Mbps is the maximum throughput */
-	RTW_PUT_BE16(wfdie + wfdielen, 300);
+	put_unaligned_be16(300, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Associated BSSID ATTR */
@@ -1744,7 +1782,7 @@ u32 build_provdisc_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0006);
+	put_unaligned_be16(0x0006, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1766,7 +1804,7 @@ u32 build_provdisc_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/*	Note: In the WFD specification, the size of length field is 2. */
-	RTW_PUT_BE16(wfdie + wfdielen, 0x0007);
+	put_unaligned_be16(0x0007, wfdie + wfdielen);
 	wfdielen += 2;
 
 	/*	Value: */
@@ -1814,7 +1852,7 @@ u32 build_probe_resp_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/* u16*) (p2pie + p2pielen) = cpu_to_le16(0x0002); */
-	RTW_PUT_LE16(p2pie + p2pielen, 0x0002);
+	put_unaligned_le16(0x0002, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Value: */
@@ -1846,18 +1884,18 @@ u32 build_probe_resp_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/*	Length: */
 	/* u16*) (p2pie + p2pielen) = cpu_to_le16(0x0004); */
-	RTW_PUT_LE16(p2pie + p2pielen, 0x0004);
+	put_unaligned_le16(0x0004, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Value: */
 	/*	Availability Period */
 	/* u16*) (p2pie + p2pielen) = cpu_to_le16(0xFFFF); */
-	RTW_PUT_LE16(p2pie + p2pielen, 0xFFFF);
+	put_unaligned_le16(0xFFFF, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Availability Interval */
 	/* u16*) (p2pie + p2pielen) = cpu_to_le16(0xFFFF); */
-	RTW_PUT_LE16(p2pie + p2pielen, 0xFFFF);
+	put_unaligned_le16(0xFFFF, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*  Notice of Absence ATTR */
@@ -1877,7 +1915,7 @@ u32 build_probe_resp_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf)
 	/*	21 -> P2P Device Address (6bytes) + Config Methods (2bytes) + Primary Device Type (8bytes) */
 	/*	+ NumofSecondDevType (1byte) + WPS Device Name ID field (2bytes) + WPS Device Name Len field (2bytes) */
 	/* u16*) (p2pie + p2pielen) = cpu_to_le16(21 + pwdinfo->device_name_len); */
-	RTW_PUT_LE16(p2pie + p2pielen, 21 + pwdinfo->device_name_len);
+	put_unaligned_le16(21 + pwdinfo->device_name_len, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Value: */
@@ -1888,23 +1926,23 @@ u32 build_probe_resp_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf)
 	/*	Config Method */
 	/*	This field should be big endian. Noted by P2P specification. */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(pwdinfo->supported_wps_cm); */
-	RTW_PUT_BE16(p2pie + p2pielen, pwdinfo->supported_wps_cm);
+	put_unaligned_be16(pwdinfo->supported_wps_cm, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Primary Device Type */
 	/*	Category ID */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(WPS_PDT_CID_MULIT_MEDIA); */
-	RTW_PUT_BE16(p2pie + p2pielen, WPS_PDT_CID_MULIT_MEDIA);
+	put_unaligned_be16(WPS_PDT_CID_MULIT_MEDIA, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	OUI */
 	/* u32*) (p2pie + p2pielen) = cpu_to_be32(WPSOUI); */
-	RTW_PUT_BE32(p2pie + p2pielen, WPSOUI);
+	put_unaligned_be32(WPSOUI, p2pie + p2pielen);
 	p2pielen += 4;
 
 	/*	Sub Category ID */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(WPS_PDT_SCID_MEDIA_SERVER); */
-	RTW_PUT_BE16(p2pie + p2pielen, WPS_PDT_SCID_MEDIA_SERVER);
+	put_unaligned_be16(WPS_PDT_SCID_MEDIA_SERVER, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Number of Secondary Device Types */
@@ -1913,12 +1951,12 @@ u32 build_probe_resp_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf)
 	/*	Device Name */
 	/*	Type: */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(WPS_ATTR_DEVICE_NAME); */
-	RTW_PUT_BE16(p2pie + p2pielen, WPS_ATTR_DEVICE_NAME);
+	put_unaligned_be16(WPS_ATTR_DEVICE_NAME, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Length: */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(pwdinfo->device_name_len); */
-	RTW_PUT_BE16(p2pie + p2pielen, pwdinfo->device_name_len);
+	put_unaligned_be16(pwdinfo->device_name_len, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Value: */
@@ -1963,7 +2001,7 @@ u32 build_prov_disc_request_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf,
 
 	/*	Length: */
 	/* u16*) (p2pie + p2pielen) = cpu_to_le16(0x0002); */
-	RTW_PUT_LE16(p2pie + p2pielen, 0x0002);
+	put_unaligned_le16(0x0002, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Value: */
@@ -1984,7 +2022,7 @@ u32 build_prov_disc_request_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf,
 	/*	21 -> P2P Device Address (6bytes) + Config Methods (2bytes) + Primary Device Type (8bytes) */
 	/*	+ NumofSecondDevType (1byte) + WPS Device Name ID field (2bytes) + WPS Device Name Len field (2bytes) */
 	/* u16*) (p2pie + p2pielen) = cpu_to_le16(21 + pwdinfo->device_name_len); */
-	RTW_PUT_LE16(p2pie + p2pielen, 21 + pwdinfo->device_name_len);
+	put_unaligned_le16(21 + pwdinfo->device_name_len, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Value: */
@@ -1997,12 +2035,12 @@ u32 build_prov_disc_request_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf,
 	if (pwdinfo->ui_got_wps_info == P2P_GOT_WPSINFO_PBC)
 	{
 		/* u16*) (p2pie + p2pielen) = cpu_to_be16(WPS_CONFIG_METHOD_PBC); */
-		RTW_PUT_BE16(p2pie + p2pielen, WPS_CONFIG_METHOD_PBC);
+		put_unaligned_be16(WPS_CONFIG_METHOD_PBC, p2pie + p2pielen);
 	}
 	else
 	{
 		/* u16*) (p2pie + p2pielen) = cpu_to_be16(WPS_CONFIG_METHOD_DISPLAY); */
-		RTW_PUT_BE16(p2pie + p2pielen, WPS_CONFIG_METHOD_DISPLAY);
+		put_unaligned_be16(WPS_CONFIG_METHOD_DISPLAY, p2pie + p2pielen);
 	}
 
 	p2pielen += 2;
@@ -2010,17 +2048,17 @@ u32 build_prov_disc_request_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf,
 	/*	Primary Device Type */
 	/*	Category ID */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(WPS_PDT_CID_MULIT_MEDIA); */
-	RTW_PUT_BE16(p2pie + p2pielen, WPS_PDT_CID_MULIT_MEDIA);
+	put_unaligned_be16(WPS_PDT_CID_MULIT_MEDIA, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	OUI */
 	/* u32*) (p2pie + p2pielen) = cpu_to_be32(WPSOUI); */
-	RTW_PUT_BE32(p2pie + p2pielen, WPSOUI);
+	put_unaligned_be32(WPSOUI, p2pie + p2pielen);
 	p2pielen += 4;
 
 	/*	Sub Category ID */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(WPS_PDT_SCID_MEDIA_SERVER); */
-	RTW_PUT_BE16(p2pie + p2pielen, WPS_PDT_SCID_MEDIA_SERVER);
+	put_unaligned_be16(WPS_PDT_SCID_MEDIA_SERVER, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Number of Secondary Device Types */
@@ -2029,12 +2067,12 @@ u32 build_prov_disc_request_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf,
 	/*	Device Name */
 	/*	Type: */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(WPS_ATTR_DEVICE_NAME); */
-	RTW_PUT_BE16(p2pie + p2pielen, WPS_ATTR_DEVICE_NAME);
+	put_unaligned_be16(WPS_ATTR_DEVICE_NAME, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Length: */
 	/* u16*) (p2pie + p2pielen) = cpu_to_be16(pwdinfo->device_name_len); */
-	RTW_PUT_BE16(p2pie + p2pielen, pwdinfo->device_name_len);
+	put_unaligned_be16(pwdinfo->device_name_len, p2pie + p2pielen);
 	p2pielen += 2;
 
 	/*	Value: */
@@ -2052,7 +2090,7 @@ u32 build_prov_disc_request_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf,
 
 		/*	Length: */
 		/* u16*) (p2pie + p2pielen) = cpu_to_le16(ETH_ALEN + ussidlen); */
-		RTW_PUT_LE16(p2pie + p2pielen, ETH_ALEN + ussidlen);
+		put_unaligned_le16(ETH_ALEN + ussidlen, p2pie + p2pielen);
 		p2pielen += 2;
 
 		/*	Value: */
@@ -2685,7 +2723,7 @@ u8 process_p2p_group_negotation_req23a(struct wifidirect_info *pwdinfo, u8 *pfra
 		rtw_get_wfd_attr_content(wfd_ie, wfd_ielen, WFD_ATTR_DEVICE_INFO, attr_content, &attr_contentlen);
 		if (attr_contentlen)
 		{
-			pwdinfo->wfd_info->peer_rtsp_ctrlport = RTW_GET_BE16(attr_content + 2);
+			pwdinfo->wfd_info->peer_rtsp_ctrlport = get_unaligned_be16(attr_content + 2);
 			DBG_8723A("[%s] Peer PORT NUM = %d\n", __func__, pwdinfo->wfd_info->peer_rtsp_ctrlport);
 		}
 	}
@@ -2926,7 +2964,7 @@ u8 process_p2p_group_negotation_resp23a(struct wifidirect_info *pwdinfo, u8 *pfr
 		rtw_get_wfd_attr_content(wfd_ie, wfd_ielen, WFD_ATTR_DEVICE_INFO, attr_content, &attr_contentlen);
 		if (attr_contentlen)
 		{
-			pwdinfo->wfd_info->peer_rtsp_ctrlport = RTW_GET_BE16(attr_content + 2);
+			pwdinfo->wfd_info->peer_rtsp_ctrlport = get_unaligned_be16(attr_content + 2);
 			DBG_8723A("[%s] Peer PORT NUM = %d\n", __func__, pwdinfo->wfd_info->peer_rtsp_ctrlport);
 		}
 	}
@@ -3859,7 +3897,7 @@ void init_wifidirect_info23a(struct rtw_adapter *padapter, enum P2P_ROLE role)
 
 	rtw_p2p_findphase_ex_set(pwdinfo, P2P_FINDPHASE_EX_NONE);
 
-	pwdinfo->listen_dwell = (u8) ((rtw_get_current_time() % 3) + 1);
+	pwdinfo->listen_dwell = (u8) ((jiffies % 3) + 1);
 	/* DBG_8723A("[%s] listen_dwell time is %d00ms\n", __func__, pwdinfo->listen_dwell); */
 
 	memset(&pwdinfo->tx_prov_disc_info, 0x00, sizeof(struct tx_provdisc_req_info));
diff --git a/drivers/staging/rtl8723au/core/rtw_pwrctrl.c b/drivers/staging/rtl8723au/core/rtw_pwrctrl.c
index 354873c..8ddd67f 100644
--- a/drivers/staging/rtl8723au/core/rtw_pwrctrl.c
+++ b/drivers/staging/rtl8723au/core/rtw_pwrctrl.c
@@ -108,13 +108,11 @@ static bool rtw_pwr_unassociated_idle(struct rtw_adapter *adapter)
 	struct rtw_adapter *buddy = adapter->pbuddy_adapter;
 	struct mlme_priv *pmlmepriv = &adapter->mlmepriv;
 	struct xmit_priv *pxmit_priv = &adapter->xmitpriv;
-#ifdef CONFIG_8723AU_P2P
 	struct wifidirect_info *pwdinfo = &adapter->wdinfo;
-#endif
 
 	bool ret = false;
 
-	if (adapter->pwrctrlpriv.ips_deny_time >= rtw_get_current_time())
+	if (time_after_eq(adapter->pwrctrlpriv.ips_deny_time, jiffies))
 		goto exit;
 
 	if (check_fwstate(pmlmepriv, WIFI_ASOC_STATE|WIFI_SITE_MONITOR)
@@ -129,9 +127,7 @@ static bool rtw_pwr_unassociated_idle(struct rtw_adapter *adapter)
 	/* consider buddy, if exist */
 	if (buddy) {
 		struct mlme_priv *b_pmlmepriv = &buddy->mlmepriv;
-#ifdef CONFIG_8723AU_P2P
 		struct wifidirect_info *b_pwdinfo = &buddy->wdinfo;
-#endif
 
 		if (check_fwstate(b_pmlmepriv, WIFI_ASOC_STATE|WIFI_SITE_MONITOR)
 			|| check_fwstate(b_pmlmepriv, WIFI_UNDER_LINKING|WIFI_UNDER_WPS)
@@ -386,11 +382,13 @@ void rtw_set_ps_mode23a(struct rtw_adapter *padapter, u8 ps_mode, u8 smart_ps, u
  */
 s32 LPS_RF_ON_check23a(struct rtw_adapter *padapter, u32 delay_ms)
 {
-	u32 start_time;
+	unsigned long start_time, end_time;
 	u8 bAwake = false;
 	s32 err = 0;
 
-	start_time = rtw_get_current_time();
+	start_time = jiffies;
+	end_time = start_time + msecs_to_jiffies(delay_ms);
+
 	while (1)
 	{
 		rtw23a_hal_get_hwreg(padapter, HW_VAR_FWLPS_RF_ON, &bAwake);
@@ -404,8 +402,7 @@ s32 LPS_RF_ON_check23a(struct rtw_adapter *padapter, u32 delay_ms)
 			break;
 		}
 
-		if (rtw_get_passing_time_ms23a(start_time) > delay_ms)
-		{
+		if (time_after(jiffies, end_time)) {
 			err = -1;
 			DBG_8723A("%s: Wait for FW LPS leave more than %u ms!!!\n", __func__, delay_ms);
 			break;
@@ -539,7 +536,7 @@ u8 rtw_interface_ps_func23a(struct rtw_adapter *padapter, enum hal_intf_ps_func
 inline void rtw_set_ips_deny23a(struct rtw_adapter *padapter, u32 ms)
 {
 	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
-	pwrpriv->ips_deny_time = rtw_get_current_time() + rtw_ms_to_systime23a(ms);
+	pwrpriv->ips_deny_time = jiffies + msecs_to_jiffies(ms);
 }
 
 /*
@@ -554,14 +551,18 @@ int _rtw_pwr_wakeup23a(struct rtw_adapter *padapter, u32 ips_deffer_ms, const ch
 	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	int ret = _SUCCESS;
-	u32 start = rtw_get_current_time();
+	unsigned long start = jiffies;
+	unsigned long new_deny_time;
+
+	new_deny_time = jiffies + msecs_to_jiffies(ips_deffer_ms);
 
-	if (pwrpriv->ips_deny_time < rtw_get_current_time() + rtw_ms_to_systime23a(ips_deffer_ms))
-		pwrpriv->ips_deny_time = rtw_get_current_time() + rtw_ms_to_systime23a(ips_deffer_ms);
+	if (time_before(pwrpriv->ips_deny_time, new_deny_time))
+		pwrpriv->ips_deny_time = new_deny_time;
 
 	if (pwrpriv->ps_processing) {
 		DBG_8723A("%s wait ps_processing...\n", __func__);
-		while (pwrpriv->ps_processing && rtw_get_passing_time_ms23a(start) <= 3000)
+		while (pwrpriv->ps_processing &&
+		       jiffies_to_msecs(jiffies - start) <= 3000)
 			msleep(10);
 		if (pwrpriv->ps_processing)
 			DBG_8723A("%s wait ps_processing timeout\n", __func__);
@@ -571,7 +572,8 @@ int _rtw_pwr_wakeup23a(struct rtw_adapter *padapter, u32 ips_deffer_ms, const ch
 
 	if (rtw_hal_sreset_inprogress(padapter)) {
 		DBG_8723A("%s wait sreset_inprogress...\n", __func__);
-		while (rtw_hal_sreset_inprogress(padapter) && rtw_get_passing_time_ms23a(start) <= 4000)
+		while (rtw_hal_sreset_inprogress(padapter) &&
+		       jiffies_to_msecs(jiffies - start) <= 4000)
 			msleep(10);
 		if (rtw_hal_sreset_inprogress(padapter))
 			DBG_8723A("%s wait sreset_inprogress timeout\n", __func__);
@@ -582,7 +584,7 @@ int _rtw_pwr_wakeup23a(struct rtw_adapter *padapter, u32 ips_deffer_ms, const ch
 	if (pwrpriv->bInternalAutoSuspend == false && pwrpriv->bInSuspend) {
 		DBG_8723A("%s wait bInSuspend...\n", __func__);
 		while (pwrpriv->bInSuspend &&
-		       (rtw_get_passing_time_ms23a(start) <= 3000)) {
+		       (jiffies_to_msecs(jiffies - start) <= 3000)) {
 			msleep(10);
 		}
 		if (pwrpriv->bInSuspend)
@@ -630,8 +632,9 @@ int _rtw_pwr_wakeup23a(struct rtw_adapter *padapter, u32 ips_deffer_ms, const ch
 	}
 
 exit:
-	if (pwrpriv->ips_deny_time < rtw_get_current_time() + rtw_ms_to_systime23a(ips_deffer_ms))
-		pwrpriv->ips_deny_time = rtw_get_current_time() + rtw_ms_to_systime23a(ips_deffer_ms);
+	new_deny_time = jiffies + msecs_to_jiffies(ips_deffer_ms);
+	if (time_before(pwrpriv->ips_deny_time, new_deny_time))
+		pwrpriv->ips_deny_time = new_deny_time;
 	return ret;
 }
 
diff --git a/drivers/staging/rtl8723au/core/rtw_security.c b/drivers/staging/rtl8723au/core/rtw_security.c
index 0d45714..fd43e71 100644
--- a/drivers/staging/rtl8723au/core/rtw_security.c
+++ b/drivers/staging/rtl8723au/core/rtw_security.c
@@ -202,7 +202,7 @@ void rtw_wep_encrypt23a(struct rtw_adapter *padapter,
 			arcfour_encrypt(&mycontext, payload + length, crc, 4);
 
 			pframe += pxmitpriv->frag_len;
-			pframe = (u8 *)RND4((unsigned long)(pframe));
+			pframe = PTR_ALIGN(pframe, 4);
 		}
 	}
 
@@ -225,7 +225,7 @@ void rtw_wep_decrypt23a(struct rtw_adapter *padapter,
 	pframe = skb->data;
 
 	/* start to decrypt recvframe */
-	if ((prxattrib->encrypt =! _WEP40_) && (prxattrib->encrypt != _WEP104_))
+	if ((prxattrib->encrypt != _WEP40_) && (prxattrib->encrypt != _WEP104_))
 		return;
 
 	iv = pframe + prxattrib->hdrlen;
@@ -699,8 +699,7 @@ u32 rtw_tkip_encrypt23a(struct rtw_adapter *padapter,
 					arcfour_encrypt(&mycontext, payload+length, crc, 4);
 
 				pframe+= pxmitpriv->frag_len;
-				pframe = (u8 *)RND4((unsigned long)(pframe));
-
+				pframe = PTR_ALIGN(pframe, 4);
 				}
 			}
 
@@ -1371,7 +1370,7 @@ u32 rtw_aes_encrypt23a(struct rtw_adapter *padapter, struct xmit_frame *pxmitfra
 
 			aes_cipher(prwskey, pattrib->hdrlen, pframe, length);
 			pframe += pxmitpriv->frag_len;
-			pframe = (u8*)RND4((unsigned long)pframe);
+			pframe = PTR_ALIGN(pframe, 4);
 		}
 	}
 out:
@@ -1599,7 +1598,7 @@ u32 rtw_aes_decrypt23a(struct rtw_adapter *padapter, struct recv_frame *precvfra
 
 	pframe = skb->data;
 	/* 4 start to encrypt each fragment */
-	if (!prxattrib->encrypt != _AES_)
+	if (prxattrib->encrypt != _AES_)
 		return _FAIL;
 
 	stainfo = rtw_get_stainfo23a(&padapter->stapriv, &prxattrib->ta[0]);
diff --git a/drivers/staging/rtl8723au/core/rtw_sreset.c b/drivers/staging/rtl8723au/core/rtw_sreset.c
index 8d1a6fe..4f74592 100644
--- a/drivers/staging/rtl8723au/core/rtw_sreset.c
+++ b/drivers/staging/rtl8723au/core/rtw_sreset.c
@@ -165,9 +165,11 @@ static void sreset_restore_network_status(struct rtw_adapter *padapter)
 	if (check_fwstate(mlmepriv, WIFI_STATION_STATE)) {
 		DBG_8723A(FUNC_ADPT_FMT" fwstate:0x%08x - WIFI_STATION_STATE\n", FUNC_ADPT_ARG(padapter), get_fwstate(mlmepriv));
 		sreset_restore_network_station(padapter);
+#ifdef CONFIG_8723AU_AP_MODE
 	} else if (check_fwstate(mlmepriv, WIFI_AP_STATE)) {
 		DBG_8723A(FUNC_ADPT_FMT" fwstate:0x%08x - WIFI_AP_STATE\n", FUNC_ADPT_ARG(padapter), get_fwstate(mlmepriv));
 		rtw_ap_restore_network(padapter);
+#endif
 	} else if (check_fwstate(mlmepriv, WIFI_ADHOC_STATE)) {
 		DBG_8723A(FUNC_ADPT_FMT" fwstate:0x%08x - WIFI_ADHOC_STATE\n", FUNC_ADPT_ARG(padapter), get_fwstate(mlmepriv));
 	} else {
diff --git a/drivers/staging/rtl8723au/core/rtw_wlan_util.c b/drivers/staging/rtl8723au/core/rtw_wlan_util.c
index 76d2f24..0dfcfbc 100644
--- a/drivers/staging/rtl8723au/core/rtw_wlan_util.c
+++ b/drivers/staging/rtl8723au/core/rtw_wlan_util.c
@@ -581,7 +581,7 @@ int WFD_info_handler(struct rtw_adapter *padapter, struct ndis_802_11_var_ies *
 		DBG_8723A("[%s] Found WFD IE\n", __func__);
 		rtw_get_wfd_attr_content(wfd_ie, wfd_ielen, WFD_ATTR_DEVICE_INFO, attr_content, &attr_contentlen);
 		if (attr_contentlen) {
-			pwdinfo->wfd_info->peer_rtsp_ctrlport = RTW_GET_BE16(attr_content + 2);
+			pwdinfo->wfd_info->peer_rtsp_ctrlport = get_unaligned_be16(attr_content + 2);
 			DBG_8723A("[%s] Peer PORT NUM = %d\n", __func__, pwdinfo->wfd_info->peer_rtsp_ctrlport);
 			return true;
 		}
diff --git a/drivers/staging/rtl8723au/core/rtw_xmit.c b/drivers/staging/rtl8723au/core/rtw_xmit.c
index a1abba0..0f10cfa 100644
--- a/drivers/staging/rtl8723au/core/rtw_xmit.c
+++ b/drivers/staging/rtl8723au/core/rtw_xmit.c
@@ -785,7 +785,7 @@ static s32 xmitframe_addmic(struct rtw_adapter *padapter,
 
 			for (curfragnum = 0; curfragnum < pattrib->nr_frags;
 			     curfragnum++) {
-				payload = (u8 *)RND4((unsigned long)payload);
+				payload = PTR_ALIGN(payload, 4);
 				RT_TRACE(_module_rtl871x_xmit_c_, _drv_err_,
 					 ("=== curfragnum =%d, pframe = 0x%.2x, "
 					  "0x%.2x, 0x%.2x, 0x%.2x, 0x%.2x, 0x"
@@ -1124,7 +1124,6 @@ s32 rtw_xmitframe_coalesce23a(struct rtw_adapter *padapter, struct sk_buff *pkt,
 	struct xmit_priv	*pxmitpriv = &padapter->xmitpriv;
 	struct pkt_attrib	*pattrib = &pxmitframe->attrib;
 	s32 frg_inx, frg_len, mpdu_len, llc_sz, mem_sz;
-	unsigned long addr;
 	u8 *pframe, *mem_start;
 	u8 hw_hdr_offset;
 	u8 *pbuf_start;
@@ -1261,9 +1260,7 @@ s32 rtw_xmitframe_coalesce23a(struct rtw_adapter *padapter, struct sk_buff *pkt,
 			RT_TRACE(_module_rtl871x_xmit_c_, _drv_err_, ("%s: There're still something in packet!\n", __func__));
 		}
 
-		addr = (unsigned long)pframe;
-
-		mem_start = (unsigned char *)RND4(addr) + hw_hdr_offset;
+		mem_start = PTR_ALIGN(pframe, 4) + hw_hdr_offset;
 		memcpy(mem_start, pbuf_start + hw_hdr_offset, pattrib->hdrlen);
 
 	}
diff --git a/drivers/staging/rtl8723au/hal/hal_intf.c b/drivers/staging/rtl8723au/hal/hal_intf.c
index c1a5b73..de3608b 100644
--- a/drivers/staging/rtl8723au/hal/hal_intf.c
+++ b/drivers/staging/rtl8723au/hal/hal_intf.c
@@ -259,7 +259,9 @@ void rtw_hal_update_ra_mask23a(struct sta_info *psta, u8 rssi_level)
 	pmlmepriv = &padapter->mlmepriv;
 
 	if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
+#ifdef CONFIG_8723AU_AP_MODE
 		add_RATid23a(padapter, psta, rssi_level);
+#endif
 	} else {
 		if (padapter->HalFunc.UpdateRAMaskHandler)
 			padapter->HalFunc.UpdateRAMaskHandler(padapter, psta->mac_id, rssi_level);
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_bt-coexist.c b/drivers/staging/rtl8723au/hal/rtl8723a_bt-coexist.c
index 2d4135f..9d738d7 100644
--- a/drivers/staging/rtl8723au/hal/rtl8723a_bt-coexist.c
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_bt-coexist.c
@@ -4620,11 +4620,11 @@ bthci_StateConnected(struct rtw_adapter *padapter,
 /*PMGNT_INFO pMgntInfo = &padapter->MgntInfo; */
 	struct bt_30info *pBTInfo = GET_BT_INFO(padapter);
 	struct bt_mgnt *pBtMgnt = &pBTInfo->BtMgnt;
+	u8 i;
+	u16 logicHandle = 0;
 
 	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT state], [Connected], "));
 	switch (StateCmd) {
-	u8 i;
-	u16 logicHandle = 0;
 	case STATE_CMD_DISCONNECT_PHY_LINK:
 		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_DISCONNECT_PHY_LINK\n"));
 
@@ -7076,17 +7076,17 @@ static void btdm_2AntBtInquiryPage(struct rtw_adapter *padapter)
 static u8 btdm_HoldForBtInqPage(struct rtw_adapter *padapter)
 {
 	struct hal_data_8723a *pHalData = GET_HAL_DATA(padapter);
-	u32 curTime = rtw_get_current_time();
+	u32 curTime = jiffies;
 
 	if (pHalData->bt_coexist.halCoex8723.bC2hBtInquiryPage) {
 		/*  bt inquiry or page is started. */
 		if (pHalData->bt_coexist.halCoex8723.btInqPageStartTime == 0) {
 			pHalData->bt_coexist.halCoex8723.btInqPageStartTime = curTime;
-			RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT Inquiry/page is started at time : 0x%"i64fmt"x \n",
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT Inquiry/page is started at time : 0x%lx \n",
 			pHalData->bt_coexist.halCoex8723.btInqPageStartTime));
 		}
 	}
-	RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT Inquiry/page started time : 0x%"i64fmt"x, curTime : 0x%x \n",
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT Inquiry/page started time : 0x%lx, curTime : 0x%x \n",
 		pHalData->bt_coexist.halCoex8723.btInqPageStartTime, curTime));
 
 	if (pHalData->bt_coexist.halCoex8723.btInqPageStartTime) {
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c b/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c
index fd00ddb..0982b0a 100644
--- a/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c
@@ -388,7 +388,7 @@ s32 rtl8723a_FirmwareDownload(struct rtw_adapter *padapter)
 		rtStatus = _WriteFW(padapter, buf, fw_size);
 
 		if (rtStatus == _SUCCESS ||
-		    (rtw_get_passing_time_ms23a(fwdl_start_time) > 500 &&
+		    (jiffies_to_msecs(jiffies - fwdl_start_time) > 500 &&
 		     writeFW_retry++ >= 3))
 			break;
 
diff --git a/drivers/staging/rtl8723au/hal/rtl8723au_xmit.c b/drivers/staging/rtl8723au/hal/rtl8723au_xmit.c
index 3165ff5..2af2e3e 100644
--- a/drivers/staging/rtl8723au/hal/rtl8723au_xmit.c
+++ b/drivers/staging/rtl8723au/hal/rtl8723au_xmit.c
@@ -366,7 +366,7 @@ static s32 rtw_dump_xframe(struct rtw_adapter *padapter, struct xmit_frame *pxmi
 
 		mem_addr += w_sz;
 
-		mem_addr = (u8 *)RND4(((unsigned long)(mem_addr)));
+		mem_addr = PTR_ALIGN(mem_addr, 4);
 	}
 
 	rtw_free_xmitframe23a(pxmitpriv, pxmitframe);
diff --git a/drivers/staging/rtl8723au/include/Hal8723APhyCfg.h b/drivers/staging/rtl8723au/include/Hal8723APhyCfg.h
index 4aa8cdb..1478d31 100644
--- a/drivers/staging/rtl8723au/include/Hal8723APhyCfg.h
+++ b/drivers/staging/rtl8723au/include/Hal8723APhyCfg.h
@@ -65,8 +65,6 @@ enum RF_RADIO_PATH {
 	RF_PATH_MAX			/* Max RF number 90 support */
 };
 
-#define	RF_PATH_MAX			3
-
 #define CHANNEL_MAX_NUMBER		14	/*  14 is the max channel number */
 #define CHANNEL_GROUP_MAX		3	/*  ch1~3, ch4~9, ch10~14 total three groups */
 
diff --git a/drivers/staging/rtl8723au/include/drv_types.h b/drivers/staging/rtl8723au/include/drv_types.h
index 5847988..53eecea 100644
--- a/drivers/staging/rtl8723au/include/drv_types.h
+++ b/drivers/staging/rtl8723au/include/drv_types.h
@@ -258,13 +258,9 @@ struct rtw_adapter {
 	struct	hostapd_priv	*phostapdpriv;
 #endif
 
-#ifdef CONFIG_8723AU_P2P
 	struct cfg80211_wifidirect_info	cfg80211_wdinfo;
-#endif /* CONFIG_8723AU_P2P */
 	u32	setband;
-#ifdef CONFIG_8723AU_P2P
 	struct wifidirect_info	wdinfo;
-#endif /* CONFIG_8723AU_P2P */
 
 #ifdef CONFIG_8723AU_P2P
 	struct wifi_display_info wfd_info;
diff --git a/drivers/staging/rtl8723au/include/odm.h b/drivers/staging/rtl8723au/include/odm.h
index ac42732..dfedfbb 100644
--- a/drivers/staging/rtl8723au/include/odm.h
+++ b/drivers/staging/rtl8723au/include/odm.h
@@ -265,35 +265,30 @@ struct odm_rate_adapt {
 #define		DM_Type_ByFW			0
 #define		DM_Type_ByDriver		1
 
-/*  */
-/*  Declare for common info */
-/*  */
 /*  Declare for common info */
-/*  */
-#define MAX_PATH_NUM_92CS		2
 
 struct odm_phy_info {
 	u8		RxPWDBAll;
 	u8		SignalQuality;	 /*  in 0-100 index. */
-	u8		RxMIMOSignalQuality[MAX_PATH_NUM_92CS]; /* EVM */
-	u8		RxMIMOSignalStrength[MAX_PATH_NUM_92CS];/*  in 0~100 index */
+	u8		RxMIMOSignalQuality[RF_PATH_MAX]; /* EVM */
+	u8		RxMIMOSignalStrength[RF_PATH_MAX];/*  in 0~100 index */
 	s8		RxPower; /*  in dBm Translate from PWdB */
 	s8		RecvSignalPower;/*  Real power in dBm for this packet, no beautification and aggregation. Keep this raw info to be used for the other procedures. */
 	u8		BTRxRSSIPercentage;
 	u8		SignalStrength; /*  in 0-100 index. */
-	u8		RxPwr[MAX_PATH_NUM_92CS];/* per-path's pwdb */
-	u8		RxSNR[MAX_PATH_NUM_92CS];/* per-path's SNR */
+	u8		RxPwr[RF_PATH_MAX];/* per-path's pwdb */
+	u8		RxSNR[RF_PATH_MAX];/* per-path's SNR */
 };
 
 
 struct odm_phy_dbg_info {
 	/* ODM Write,debug info */
-	s8		RxSNRdB[MAX_PATH_NUM_92CS];
+	s8		RxSNRdB[RF_PATH_MAX];
 	u64		NumQryPhyStatus;
 	u64		NumQryPhyStatusCCK;
 	u64		NumQryPhyStatusOFDM;
 	/* Others */
-	s32		RxEVM[MAX_PATH_NUM_92CS];
+	s32		RxEVM[RF_PATH_MAX];
 
 };
 
diff --git a/drivers/staging/rtl8723au/include/odm_HWConfig.h b/drivers/staging/rtl8723au/include/odm_HWConfig.h
index 057fdb0..147855c 100644
--- a/drivers/staging/rtl8723au/include/odm_HWConfig.h
+++ b/drivers/staging/rtl8723au/include/odm_HWConfig.h
@@ -74,21 +74,21 @@ struct phy_rx_agc_info {
 };
 
 struct phy_status_rpt {
-	struct phy_rx_agc_info path_agc[2];
-	u8	ch_corr[2];
+	struct phy_rx_agc_info path_agc[RF_PATH_MAX];
+	u8	ch_corr[RF_PATH_MAX];
 	u8	cck_sig_qual_ofdm_pwdb_all;
 	u8	cck_agc_rpt_ofdm_cfosho_a;
 	u8	cck_rpt_b_ofdm_cfosho_b;
 	u8	rsvd_1;/* ch_corr_msb; */
 	u8	noise_power_db_msb;
-	u8	path_cfotail[2];
-	u8	pcts_mask[2];
-	s8	stream_rxevm[2];
-	u8	path_rxsnr[2];
+	u8	path_cfotail[RF_PATH_MAX];
+	u8	pcts_mask[RF_PATH_MAX];
+	s8	stream_rxevm[RF_PATH_MAX];
+	u8	path_rxsnr[RF_PATH_MAX];
 	u8	noise_power_db_lsb;
 	u8	rsvd_2[3];
-	u8	stream_csi[2];
-	u8	stream_target_csi[2];
+	u8	stream_csi[RF_PATH_MAX];
+	u8	stream_target_csi[RF_PATH_MAX];
 	s8	sig_evm;
 	u8	rsvd_3;
 
diff --git a/drivers/staging/rtl8723au/include/osdep_service.h b/drivers/staging/rtl8723au/include/osdep_service.h
index cb7b5cd..039bc72 100644
--- a/drivers/staging/rtl8723au/include/osdep_service.h
+++ b/drivers/staging/rtl8723au/include/osdep_service.h
@@ -149,70 +149,6 @@ extern unsigned char	MCS_rate_1R23A[16];
 void	_rtw_init_queue23a(struct rtw_queue *pqueue);
 u32	_rtw_queue_empty23a(struct rtw_queue *pqueue);
 
-u32	rtw_get_current_time(void);
-u32	rtw_systime_to_ms23a(u32 systime);
-u32	rtw_ms_to_systime23a(u32 ms);
-s32	rtw_get_passing_time_ms23a(u32 start);
-s32	rtw_get_time_interval_ms23a(u32 start, u32 end);
-
-#define _RND(sz, r) ((((sz)+((r)-1))/(r))*(r))
-#define RND4(x)	(((x >> 2) + (((x & 3) == 0) ?  0: 1)) << 2)
-
-static inline u32 _RND4(u32 sz)
-{
-
-	u32	val;
-
-	val = ((sz >> 2) + ((sz & 3) ? 1: 0)) << 2;
-
-	return val;
-
-}
-
-static inline u32 _RND8(u32 sz)
-{
-
-	u32	val;
-
-	val = ((sz >> 3) + ((sz & 7) ? 1: 0)) << 3;
-
-	return val;
-
-}
-
-static inline u32 _RND128(u32 sz)
-{
-
-	u32	val;
-
-	val = ((sz >> 7) + ((sz & 127) ? 1: 0)) << 7;
-
-	return val;
-
-}
-
-static inline u32 _RND256(u32 sz)
-{
-
-	u32	val;
-
-	val = ((sz >> 8) + ((sz & 255) ? 1: 0)) << 8;
-
-	return val;
-
-}
-
-static inline u32 _RND512(u32 sz)
-{
-
-	u32	val;
-
-	val = ((sz >> 9) + ((sz & 511) ? 1: 0)) << 9;
-
-	return val;
-
-}
-
 static inline u32 bitshift(u32 bitmask)
 {
 	u32 i;
@@ -223,20 +159,11 @@ static inline u32 bitshift(u32 bitmask)
 	return i;
 }
 
-#define STRUCT_PACKED __attribute__ ((packed))
-
-/*  limitation of path length */
-#define PATH_LENGTH_MAX PATH_MAX
-
 void rtw_suspend_lock_init(void);
 void rtw_suspend_lock_uninit(void);
 void rtw_lock_suspend(void);
 void rtw_unlock_suspend(void);
 
-/* File operation APIs, just for linux now */
-int rtw_is_file_readable(char *path);
-int rtw_retrive_from_file(char *path, u8* buf, u32 sz);
-int rtw_store_to_file(char *path, u8* buf, u32 sz);
 
 #define NDEV_FMT "%s"
 #define NDEV_ARG(ndev) ndev->name
@@ -255,69 +182,9 @@ u64 rtw_division6423a(u64 x, u64 y);
 
 /* Macros for handling unaligned memory accesses */
 
-#define RTW_GET_BE16(a) ((u16) (((a)[0] << 8) | (a)[1]))
-#define RTW_PUT_BE16(a, val)			\
-	do {					\
-		(a)[0] = ((u16) (val)) >> 8;	\
-		(a)[1] = ((u16) (val)) & 0xff;	\
-	} while (0)
-
-#define RTW_GET_LE16(a) ((u16) (((a)[1] << 8) | (a)[0]))
-#define RTW_PUT_LE16(a, val)			\
-	do {					\
-		(a)[1] = ((u16) (val)) >> 8;	\
-		(a)[0] = ((u16) (val)) & 0xff;	\
-	} while (0)
-
 #define RTW_GET_BE24(a) ((((u32) (a)[0]) << 16) | (((u32) (a)[1]) << 8) | \
 			 ((u32) (a)[2]))
-#define RTW_PUT_BE24(a, val)					\
-	do {							\
-		(a)[0] = (u8) ((((u32) (val)) >> 16) & 0xff);	\
-		(a)[1] = (u8) ((((u32) (val)) >> 8) & 0xff);	\
-		(a)[2] = (u8) (((u32) (val)) & 0xff);		\
-	} while (0)
-
-#define RTW_GET_BE32(a) ((((u32) (a)[0]) << 24) | (((u32) (a)[1]) << 16) | \
-			 (((u32) (a)[2]) << 8) | ((u32) (a)[3]))
-#define RTW_PUT_BE32(a, val)					\
-	do {							\
-		(a)[0] = (u8) ((((u32) (val)) >> 24) & 0xff);	\
-		(a)[1] = (u8) ((((u32) (val)) >> 16) & 0xff);	\
-		(a)[2] = (u8) ((((u32) (val)) >> 8) & 0xff);	\
-		(a)[3] = (u8) (((u32) (val)) & 0xff);		\
-	} while (0)
-
-#define RTW_GET_LE32(a) ((((u32) (a)[3]) << 24) | (((u32) (a)[2]) << 16) | \
-			 (((u32) (a)[1]) << 8) | ((u32) (a)[0]))
-#define RTW_PUT_LE32(a, val)					\
-	do {							\
-		(a)[3] = (u8) ((((u32) (val)) >> 24) & 0xff);	\
-		(a)[2] = (u8) ((((u32) (val)) >> 16) & 0xff);	\
-		(a)[1] = (u8) ((((u32) (val)) >> 8) & 0xff);	\
-		(a)[0] = (u8) (((u32) (val)) & 0xff);		\
-	} while (0)
-
-#define RTW_GET_BE64(a) ((((u64) (a)[0]) << 56) | (((u64) (a)[1]) << 48) | \
-			 (((u64) (a)[2]) << 40) | (((u64) (a)[3]) << 32) | \
-			 (((u64) (a)[4]) << 24) | (((u64) (a)[5]) << 16) | \
-			 (((u64) (a)[6]) << 8) | ((u64) (a)[7]))
-#define RTW_PUT_BE64(a, val)				\
-	do {						\
-		(a)[0] = (u8) (((u64) (val)) >> 56);	\
-		(a)[1] = (u8) (((u64) (val)) >> 48);	\
-		(a)[2] = (u8) (((u64) (val)) >> 40);	\
-		(a)[3] = (u8) (((u64) (val)) >> 32);	\
-		(a)[4] = (u8) (((u64) (val)) >> 24);	\
-		(a)[5] = (u8) (((u64) (val)) >> 16);	\
-		(a)[6] = (u8) (((u64) (val)) >> 8);	\
-		(a)[7] = (u8) (((u64) (val)) & 0xff);	\
-	} while (0)
 
-#define RTW_GET_LE64(a) ((((u64) (a)[7]) << 56) | (((u64) (a)[6]) << 48) | \
-			 (((u64) (a)[5]) << 40) | (((u64) (a)[4]) << 32) | \
-			 (((u64) (a)[3]) << 24) | (((u64) (a)[2]) << 16) | \
-			 (((u64) (a)[1]) << 8) | ((u64) (a)[0]))
 
 struct rtw_cbuf {
 	u32 write;
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_bt-coexist.h b/drivers/staging/rtl8723au/include/rtl8723a_bt-coexist.h
index 5777eda..6d1edc6 100644
--- a/drivers/staging/rtl8723au/include/rtl8723a_bt-coexist.h
+++ b/drivers/staging/rtl8723au/include/rtl8723a_bt-coexist.h
@@ -1074,7 +1074,7 @@ struct packet_irp_acl_data {
 struct packet_irp_hcievent_data {
 	u8		EventCode;
 	u8		Length;
-	u8		Data[5];
+	u8		Data[20];
 };
 
 struct common_triple {
@@ -1332,7 +1332,7 @@ struct bt_coexist_8723a {
 	u8					c2hBtInfoOriginal;
 	u8					prec2hBtInfo; /*  for 1Ant */
 	u8					bC2hBtInquiryPage;
-	u64					btInqPageStartTime; /*  for 2Ant */
+	unsigned long				btInqPageStartTime; /*  for 2Ant */
 	u8					c2hBtProfile; /*  for 1Ant */
 	u8					btRetryCnt;
 	u8					btInfoExt;
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_pg.h b/drivers/staging/rtl8723au/include/rtl8723a_pg.h
index 12f7a13..5c2ec44 100644
--- a/drivers/staging/rtl8723au/include/rtl8723a_pg.h
+++ b/drivers/staging/rtl8723au/include/rtl8723a_pg.h
@@ -15,9 +15,7 @@
 #ifndef __RTL8723A_PG_H__
 #define __RTL8723A_PG_H__
 
-/*  */
 /*			EEPROM/Efuse PG Offset for 8723E/8723U/8723S */
-/*  */
 #define EEPROM_CCK_TX_PWR_INX_8723A			0x10
 #define EEPROM_HT40_1S_TX_PWR_INX_8723A		0x16
 #define EEPROM_HT20_TX_PWR_INX_DIFF_8723A	0x1C
@@ -53,31 +51,24 @@
 /*  RTL8723AS */
 #define EEPROM_MAC_ADDR_8723AS				0xAA
 
-/*  */
 /*			EEPROM/Efuse Value Type */
-/*  */
 #define EETYPE_TX_PWR						0x0
 
-/*  */
 /*			EEPROM/Efuse Default Value */
-/*  */
 #define EEPROM_Default_CrystalCap_8723A		0x20
 
 
-/*  */
 /*        EEPROM/EFUSE data structure definition. */
-/*  */
-#define	MAX_RF_PATH_NUM	2
 #define	MAX_CHNL_GROUP		3+9
 
 struct txpowerinfo {
-	u8 CCKIndex[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
-	u8 HT40_1SIndex[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
-	u8 HT40_2SIndexDiff[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
-	u8 HT20IndexDiff[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
-	u8 OFDMIndexDiff[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
-	u8 HT40MaxOffset[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
-	u8 HT20MaxOffset[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
+	u8 CCKIndex[RF_PATH_MAX][MAX_CHNL_GROUP];
+	u8 HT40_1SIndex[RF_PATH_MAX][MAX_CHNL_GROUP];
+	u8 HT40_2SIndexDiff[RF_PATH_MAX][MAX_CHNL_GROUP];
+	u8 HT20IndexDiff[RF_PATH_MAX][MAX_CHNL_GROUP];
+	u8 OFDMIndexDiff[RF_PATH_MAX][MAX_CHNL_GROUP];
+	u8 HT40MaxOffset[RF_PATH_MAX][MAX_CHNL_GROUP];
+	u8 HT20MaxOffset[RF_PATH_MAX][MAX_CHNL_GROUP];
 	u8 TSSI_A[3];
 	u8 TSSI_B[3];
 	u8 TSSI_A_5G[3];		/* 5GL/5GM/5GH */
diff --git a/drivers/staging/rtl8723au/include/rtw_mlme.h b/drivers/staging/rtl8723au/include/rtw_mlme.h
index adbea44..31f96f3 100644
--- a/drivers/staging/rtl8723au/include/rtw_mlme.h
+++ b/drivers/staging/rtl8723au/include/rtw_mlme.h
@@ -379,6 +379,28 @@ struct mlme_priv {
 
 	u8 *wps_probe_req_ie;
 	u32 wps_probe_req_ie_len;
+	u8 *assoc_req;
+	u32 assoc_req_len;
+	u32 assoc_rsp_len;
+	u8 *assoc_rsp;
+	u32 wps_assoc_resp_ie_len;
+	u8 *wps_assoc_resp_ie;
+	u8 *wps_probe_resp_ie;
+	u32 wps_probe_resp_ie_len;
+	u8 *wps_beacon_ie;
+	u32 wps_beacon_ie_len;
+	u32 p2p_go_probe_resp_ie_len; /* for GO */
+	u32 p2p_assoc_req_ie_len;
+	u8 *p2p_beacon_ie;
+	u8 *p2p_probe_req_ie;
+	u8 *p2p_probe_resp_ie;
+	u8 *p2p_go_probe_resp_ie; /* for GO */
+	u8 *p2p_assoc_req_ie;
+	u32 p2p_beacon_ie_len;
+	u32 p2p_probe_req_ie_len;
+	u32 p2p_probe_resp_ie_len;
+	u8 *wfd_assoc_req_ie;
+	u32 wfd_assoc_req_ie_len;
 
 #ifdef CONFIG_8723AU_AP_MODE
 	/* Number of associated Non-ERP stations (i.e., stations using 802.11b
@@ -407,50 +429,20 @@ struct mlme_priv {
 
 	u16 ht_op_mode;
 
-	u8 *assoc_req;
-	u32 assoc_req_len;
-	u8 *assoc_rsp;
-	u32 assoc_rsp_len;
-
-	u8 *wps_beacon_ie;
-	/* u8 *wps_probe_req_ie; */
-	u8 *wps_probe_resp_ie;
-	u8 *wps_assoc_resp_ie;
-
-	u32 wps_beacon_ie_len;
-	/* u32 wps_probe_req_ie_len; */
-	u32 wps_probe_resp_ie_len;
-	u32 wps_assoc_resp_ie_len;
-
-	u8 *p2p_beacon_ie;
-	u8 *p2p_probe_req_ie;
-	u8 *p2p_probe_resp_ie;
-	u8 *p2p_go_probe_resp_ie; /* for GO */
-	u8 *p2p_assoc_req_ie;
-
-	u32 p2p_beacon_ie_len;
-	u32 p2p_probe_req_ie_len;
-	u32 p2p_probe_resp_ie_len;
-	u32 p2p_go_probe_resp_ie_len; /* for GO */
-	u32 p2p_assoc_req_ie_len;
 	spinlock_t	bcn_update_lock;
 	u8		update_bcn;
 
 #endif /* ifdef CONFIG_8723AU_AP_MODE */
 
-#if defined(CONFIG_8723AU_P2P)
 	u8 *wfd_beacon_ie;
 	u8 *wfd_probe_req_ie;
 	u8 *wfd_probe_resp_ie;
 	u8 *wfd_go_probe_resp_ie; /* for GO */
-	u8 *wfd_assoc_req_ie;
 
 	u32 wfd_beacon_ie_len;
 	u32 wfd_probe_req_ie_len;
 	u32 wfd_probe_resp_ie_len;
 	u32 wfd_go_probe_resp_ie_len; /* for GO */
-	u32 wfd_assoc_req_ie_len;
-#endif
 };
 
 #ifdef CONFIG_8723AU_AP_MODE
diff --git a/drivers/staging/rtl8723au/include/rtw_mlme_ext.h b/drivers/staging/rtl8723au/include/rtw_mlme_ext.h
index d1c2d71..0aaf0d5 100644
--- a/drivers/staging/rtl8723au/include/rtw_mlme_ext.h
+++ b/drivers/staging/rtl8723au/include/rtw_mlme_ext.h
@@ -451,9 +451,7 @@ struct mlme_ext_priv {
 
 	u64 TSFValue;
 
-#ifdef CONFIG_8723AU_AP_MODE
 	unsigned char bstart_bss;
-#endif
 	u8 update_channel_plan_by_ap_done;
 	/* recv_decache check for Action_public frame */
 	u8 action_public_dialog_token;
diff --git a/drivers/staging/rtl8723au/include/rtw_pwrctrl.h b/drivers/staging/rtl8723au/include/rtw_pwrctrl.h
index b42e141..e0da87d 100644
--- a/drivers/staging/rtl8723au/include/rtw_pwrctrl.h
+++ b/drivers/staging/rtl8723au/include/rtw_pwrctrl.h
@@ -180,7 +180,7 @@ struct pwrctrl_priv {
 	u8	ips_mode;
 	u8	ips_mode_req; /*  used to accept the mode setting request */
 	uint bips_processing;
-	u32 ips_deny_time; /* will deny IPS when system time is smaller */
+	unsigned long ips_deny_time; /* deny IPS when system time is smaller */
 	u8 ps_processing; /* used to mark whether in rtw_ps_processor23a */
 
 	u8	bLeisurePs;
diff --git a/drivers/staging/rtl8723au/include/rtw_recv.h b/drivers/staging/rtl8723au/include/rtw_recv.h
index e2462e0..d1866a6 100644
--- a/drivers/staging/rtl8723au/include/rtw_recv.h
+++ b/drivers/staging/rtl8723au/include/rtw_recv.h
@@ -17,6 +17,7 @@
 
 #include <osdep_service.h>
 #include <drv_types.h>
+#include <Hal8723APhyCfg.h>
 
 #define NR_RECVFRAME		256
 
@@ -75,13 +76,11 @@ struct signal_stat {
 	u32	total_val;		/* sum of valid elements */
 };
 
-#define MAX_PATH_NUM_92CS		2
-
 struct phy_info {
 	u8		RxPWDBAll;
 	u8		SignalQuality;	 /*  in 0-100 index. */
-	u8		RxMIMOSignalQuality[MAX_PATH_NUM_92CS]; /* EVM */
-	u8		RxMIMOSignalStrength[MAX_PATH_NUM_92CS];/* 0~100 */
+	u8		RxMIMOSignalQuality[RF_PATH_MAX]; /* EVM */
+	u8		RxMIMOSignalStrength[RF_PATH_MAX];/* 0~100 */
 	s8		RxPower; /*  in dBm Translate from PWdB */
 	/* Real power in dBm for this packet, no beautification and aggregation.
 	 * Keep this raw info to be used for the other procedures.
@@ -89,8 +88,8 @@ struct phy_info {
 	s8		RecvSignalPower;
 	u8		BTRxRSSIPercentage;
 	u8		SignalStrength; /*  in 0-100 index. */
-	u8		RxPwr[MAX_PATH_NUM_92CS];/* per-path's pwdb */
-	u8		RxSNR[MAX_PATH_NUM_92CS];/* per-path's SNR */
+	u8		RxPwr[RF_PATH_MAX];/* per-path's pwdb */
+	u8		RxSNR[RF_PATH_MAX];/* per-path's SNR */
 };
 
 
diff --git a/drivers/staging/rtl8723au/include/sta_info.h b/drivers/staging/rtl8723au/include/sta_info.h
index 8af98ee..ffbc9e3 100644
--- a/drivers/staging/rtl8723au/include/sta_info.h
+++ b/drivers/staging/rtl8723au/include/sta_info.h
@@ -140,8 +140,6 @@ struct sta_info {
 	/* curr_network(mlme_priv/security_priv/qos/ht) : AP CAP/INFO */
 	/* sta_info: (AP & STA) CAP/INFO */
 
-#ifdef CONFIG_8723AU_AP_MODE
-
 	struct list_head asoc_list;
 	struct list_head auth_list;
 
@@ -183,11 +181,12 @@ struct sta_info {
 	u8 has_legacy_ac;
 	unsigned int sleepq_ac_len;
 
-#ifdef CONFIG_8723AU_P2P
 	/* p2p priv data */
 	u8 is_p2p_device;
 	u8 p2p_status_code;
 
+	u8 keep_alive_trycnt;
+
 	/* p2p client info */
 	u8 dev_addr[ETH_ALEN];
 	u8 dev_cap;
@@ -197,12 +196,6 @@ struct sta_info {
 	u8 secdev_types_list[32];/*  32/8 == 4; */
 	u16 dev_name_len;
 	u8 dev_name[32];
-#endif /* CONFIG_8723AU_P2P */
-
-	u8 keep_alive_trycnt;
-
-#endif	/*  CONFIG_8723AU_AP_MODE */
-
 	u8 *passoc_req;
 	u32 assoc_req_len;
 
@@ -329,9 +322,6 @@ struct	sta_priv {
 	struct rtw_queue wakeup_q;
 
 	struct rtw_adapter *padapter;
-
-
-#ifdef CONFIG_8723AU_AP_MODE
 	struct list_head asoc_list;
 	struct list_head auth_list;
 	spinlock_t asoc_list_lock;
@@ -357,7 +347,6 @@ struct	sta_priv {
 	u16 max_num_sta;
 
 	struct wlan_acl_pool acl_list;
-#endif
 };
 
 static inline u32 wifi_mac_hash(u8 *mac)
diff --git a/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c b/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
index 1c99616..50840b9 100644
--- a/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
+++ b/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
@@ -1495,9 +1495,11 @@ static int rtw_cfg80211_set_probe_req_wpsp2pie(struct rtw_adapter *padapter,
 	int ret = 0;
 	uint wps_ielen = 0;
 	u8 *wps_ie;
+#ifdef CONFIG_8723AU_P2P
 	u32 p2p_ielen = 0;
 	u8 *p2p_ie;
 	u32 wfd_ielen = 0;
+#endif
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
 #ifdef CONFIG_DEBUG_CFG80211
@@ -1595,12 +1597,12 @@ static int cfg80211_rtw_scan(struct wiphy *wiphy,
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct cfg80211_ssid ssid[RTW_SSID_SCAN_AMOUNT];
 	struct rtw_ieee80211_channel ch[RTW_CHANNEL_SCAN_AMOUNT];
-#ifdef CONFIG_8723AU_P2P
-	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
-#endif /* CONFIG_8723AU_P2P */
 	struct rtw_wdev_priv *pwdev_priv = wdev_to_priv(padapter->rtw_wdev);
 	struct cfg80211_ssid *ssids = request->ssids;
+#ifdef CONFIG_8723AU_P2P
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
 	int social_channel = 0;
+#endif /* CONFIG_8723AU_P2P */
 	bool need_indicate_scan_done = false;
 
 #ifdef CONFIG_DEBUG_CFG80211
@@ -1625,8 +1627,7 @@ static int cfg80211_rtw_scan(struct wiphy *wiphy,
 		goto check_need_indicate_scan_done;
 	}
 #ifdef CONFIG_8723AU_P2P
-	if (ssids->ssid != NULL &&
-	    !memcmp(ssids->ssid, "DIRECT-", 7) &&
+	if (!memcmp(ssids->ssid, "DIRECT-", 7) &&
 	    rtw_get_p2p_ie23a((u8 *) request->ie, request->ie_len, NULL, NULL)) {
 		if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
 			rtw_p2p_enable23a(padapter, P2P_ROLE_DEVICE);
@@ -2738,7 +2739,9 @@ static int rtw_cfg80211_monitor_if_xmit_entry(struct sk_buff *skb,
 		struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
 		u32 len = skb->len;
 		u8 category, action;
+#ifdef CONFIG_8723AU_P2P
 		int type = -1;
+#endif
 
 		if (rtw_action_frame_parse23a(skb->data, len, &category,
 					   &action) == false) {
@@ -2760,7 +2763,9 @@ static int rtw_cfg80211_monitor_if_xmit_entry(struct sk_buff *skb,
 		else
 			DBG_8723A("RTW_Tx:category(%u), action(%u)\n", category,
 				  action);
+#ifdef CONFIG_8723AU_P2P
 dump:
+#endif
 		/* starting alloc mgmt frame to dump it */
 		pmgntframe = alloc_mgtxmitframe23a(pxmitpriv);
 		if (pmgntframe == NULL)
@@ -2971,8 +2976,10 @@ static int rtw_add_beacon(struct rtw_adapter *adapter, const u8 *head,
 	int ret = 0;
 	u8 *pbuf = NULL;
 	uint len, wps_ielen = 0;
+#ifdef CONFIG_8723AU_P2P
 	uint p2p_ielen = 0;
 	u8 got_p2p_ie = false;
+#endif
 	struct mlme_priv *pmlmepriv = &adapter->mlmepriv;
 	/* struct sta_priv *pstapriv = &padapter->stapriv; */
 
@@ -3245,7 +3252,9 @@ static int cfg80211_rtw_change_bss(struct wiphy *wiphy, struct net_device *ndev,
 void rtw_cfg80211_rx_action_p2p(struct rtw_adapter *padapter, u8 *pmgmt_frame,
 				uint frame_len)
 {
+#ifdef CONFIG_8723AU_P2P
 	int type;
+#endif
 	s32 freq;
 	int channel;
 	u8 category, action;
@@ -3261,7 +3270,9 @@ void rtw_cfg80211_rx_action_p2p(struct rtw_adapter *padapter, u8 *pmgmt_frame,
 	rtw_action_frame_parse23a(pmgmt_frame, frame_len, &category, &action);
 	DBG_8723A("RTW_Rx:category(%u), action(%u)\n", category, action);
 
+#ifdef CONFIG_8723AU_P2P
 indicate:
+#endif
 	if (channel <= RTW_CH_MAX_2G_CHANNEL)
 		freq = ieee80211_channel_to_frequency(channel,
 						      IEEE80211_BAND_2GHZ);
@@ -3276,7 +3287,9 @@ indicate:
 void rtw_cfg80211_rx_p2p_action_public(struct rtw_adapter *padapter,
 				       u8 *pmgmt_frame, uint frame_len)
 {
+#ifdef CONFIG_8723AU_P2P
 	int type;
+#endif
 	s32 freq;
 	int channel;
 	u8 category, action;
@@ -3298,7 +3311,9 @@ void rtw_cfg80211_rx_p2p_action_public(struct rtw_adapter *padapter,
 	rtw_action_frame_parse23a(pmgmt_frame, frame_len, &category, &action);
 	DBG_8723A("RTW_Rx:category(%u), action(%u)\n", category, action);
 
+#ifdef CONFIG_8723AU_P2P
 indicate:
+#endif
 	if (channel <= RTW_CH_MAX_2G_CHANNEL)
 		freq = ieee80211_channel_to_frequency(channel,
 						      IEEE80211_BAND_2GHZ);
@@ -3485,7 +3500,7 @@ void rtw_cfg80211_issue_p2p_provision_request23a(struct rtw_adapter *padapter,
 	p2p_ie[p2pielen++] = P2P_ATTR_CAPABILITY;
 
 	/*      Length: */
-	RTW_PUT_LE16(p2p_ie + p2pielen, 0x0002);
+	put_unaligned_le16(0x0002, p2p_ie + p2pielen);
 	p2pielen += 2;
 
 	/*      Value: */
@@ -3499,7 +3514,7 @@ void rtw_cfg80211_issue_p2p_provision_request23a(struct rtw_adapter *padapter,
 	p2p_ie[p2pielen++] = P2P_ATTR_DEVICE_INFO;
 
 	/*      Length: */
-	RTW_PUT_LE16(p2p_ie + p2pielen, devinfo_contentlen);
+	put_unaligned_le16(devinfo_contentlen, p2p_ie + p2pielen);
 	p2pielen += 2;
 
 	/*      Value: */
@@ -3580,7 +3595,9 @@ static s32 cfg80211_rtw_remain_on_channel(struct wiphy *wiphy,
 
 		del_timer_sync(&padapter->cfg80211_wdinfo.remain_on_ch_timer);
 
+#ifdef CONFIG_8723AU_P2P
 		p2p_protocol_wk_hdl23a(padapter, P2P_RO_CH_WK);
+#endif
 	}
 
 	pcfg80211_wdinfo->is_ro_ch = true;
@@ -3663,7 +3680,9 @@ static s32 cfg80211_rtw_cancel_remain_on_channel(struct wiphy *wiphy,
 	if (pcfg80211_wdinfo->is_ro_ch == true) {
 		DBG_8723A("%s, cancel ro ch timer\n", __func__);
 		del_timer_sync(&padapter->cfg80211_wdinfo.remain_on_ch_timer);
+#ifdef CONFIG_8723AU_P2P
 		p2p_protocol_wk_hdl23a(padapter, P2P_RO_CH_WK);
+#endif
 	}
 
 	rtw_p2p_set_state(pwdinfo, rtw_p2p_pre_state(pwdinfo));
@@ -3834,7 +3853,9 @@ static int cfg80211_rtw_mgmt_tx(struct wiphy *wiphy, struct wireless_dev *wdev,
 		DBG_8723A("RTW_Tx:category(%u), action(%u)\n",
 			  category, action);
 
+#ifdef CONFIG_8723AU_P2P
 dump:
+#endif
 	do {
 		dump_cnt++;
 		tx_ret = _cfg80211_rtw_mgmt_tx(padapter, tx_ch, buf, len);
@@ -3890,10 +3911,14 @@ static int rtw_cfg80211_set_beacon_wpsp2pie(struct net_device *ndev, char *buf,
 	int ret = 0;
 	uint wps_ielen = 0;
 	u8 *wps_ie;
+#ifdef CONFIG_8723AU_P2P
 	u32 p2p_ielen = 0;
-	u8 wps_oui[8] = { 0x0, 0x50, 0xf2, 0x04 };
-	u8 *p2p_ie;
 	u32 wfd_ielen = 0;
+	u8 *p2p_ie;
+#endif
+#ifdef CONFIG_8723AU_AP_MODE
+	u8 wps_oui[8] = { 0x0, 0x50, 0xf2, 0x04 };
+#endif
 	struct rtw_adapter *padapter = netdev_priv(ndev);
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
@@ -3923,8 +3948,10 @@ static int rtw_cfg80211_set_beacon_wpsp2pie(struct net_device *ndev, char *buf,
 			memcpy(pmlmepriv->wps_beacon_ie, wps_ie, wps_ielen);
 			pmlmepriv->wps_beacon_ie_len = wps_ielen;
 
+#ifdef CONFIG_8723AU_AP_MODE
 			update_beacon23a(padapter, _VENDOR_SPECIFIC_IE_, wps_oui,
 				      true);
+#endif
 		}
 #ifdef CONFIG_8723AU_P2P
 		p2p_ie = rtw_get_p2p_ie23a(buf, len, NULL, &p2p_ielen);
@@ -3992,12 +4019,14 @@ static int rtw_cfg80211_set_probe_resp_wpsp2pie(struct net_device *net,
 {
 	struct rtw_adapter *padapter = netdev_priv(net);
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
-	int ret = 0;
-	uint wps_ielen = 0;
-	u8 *wps_ie;
+#ifdef CONFIG_8723AU_P2P
 	u32 p2p_ielen = 0;
 	u8 *p2p_ie;
 	u32 wfd_ielen = 0;
+#endif
+	int ret = 0;
+	uint wps_ielen = 0;
+	u8 *wps_ie;
 
 	if (len > 0) {
 		wps_ie = rtw_get_wps_ie23a(buf, len, NULL, &wps_ielen);
@@ -4176,7 +4205,9 @@ int rtw_cfg80211_set_mgnt_wpsp2pie(struct net_device *net, char *buf, int len,
 {
 	int ret = 0;
 	uint wps_ielen = 0;
+#ifdef CONFIG_8723AU_P2P
 	u32 p2p_ielen = 0;
+#endif
 
 #ifdef CONFIG_DEBUG_CFG80211
 	DBG_8723A("%s, ielen =%d\n", __func__, len);
diff --git a/drivers/staging/rtl8723au/os_dep/osdep_service.c b/drivers/staging/rtl8723au/os_dep/osdep_service.c
index aeb48db..97fc27d 100644
--- a/drivers/staging/rtl8723au/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8723au/os_dep/osdep_service.c
@@ -71,260 +71,6 @@ u32 _rtw_queue_empty23a(struct rtw_queue *pqueue)
 		return false;
 }
 
-u32	rtw_get_current_time(void)
-{
-	return jiffies;
-}
-
-inline u32 rtw_systime_to_ms23a(u32 systime)
-{
-	return systime * 1000 / HZ;
-}
-
-inline u32 rtw_ms_to_systime23a(u32 ms)
-{
-	return ms * HZ / 1000;
-}
-
-/*  the input parameter start use the same unit as returned
- * by rtw_get_current_time
- */
-inline s32 rtw_get_passing_time_ms23a(u32 start)
-{
-	return rtw_systime_to_ms23a(jiffies-start);
-}
-
-inline s32 rtw_get_time_interval_ms23a(u32 start, u32 end)
-{
-	return rtw_systime_to_ms23a(end-start);
-}
-
-#define RTW_SUSPEND_LOCK_NAME "rtw_wifi"
-
-inline void rtw_suspend_lock_init(void)
-{
-}
-
-inline void rtw_suspend_lock_uninit(void)
-{
-}
-
-inline void rtw_lock_suspend(void)
-{
-}
-
-inline void rtw_unlock_suspend(void)
-{
-}
-
-/* Open a file with the specific @param path, @param flag, @param mode
- * @param fpp the pointer of struct file pointer to get struct
- * file pointer while file opening is success
- * @param path the path of the file to open
- * @param flag file operation flags, please refer to linux document
- * @param mode please refer to linux document
- * @return Linux specific error code
- */
-static int openFile(struct file **fpp, char *path, int flag, int mode)
-{
-	struct file *fp;
-
-	fp = filp_open(path, flag, mode);
-	if (IS_ERR(fp)) {
-		*fpp = NULL;
-		return PTR_ERR(fp);
-	} else {
-		*fpp = fp;
-		return 0;
-	}
-}
-
-/* Close the file with the specific @param fp
- * @param fp the pointer of struct file to close
- * @return always 0
- */
-static int closeFile(struct file *fp)
-{
-	filp_close(fp, NULL);
-	return 0;
-}
-
-static int readFile(struct file *fp, char *buf, int len)
-{
-	int rlen = 0, sum = 0;
-
-	if (!fp->f_op || !fp->f_op->read)
-		return -EPERM;
-
-	while (sum < len) {
-		rlen = fp->f_op->read(fp, buf+sum, len-sum, &fp->f_pos);
-		if (rlen > 0)
-			sum += rlen;
-		else if (0 != rlen)
-			return rlen;
-		else
-			break;
-	}
-	return  sum;
-}
-
-static int writeFile(struct file *fp, char *buf, int len)
-{
-	int wlen = 0, sum = 0;
-
-	if (!fp->f_op || !fp->f_op->write)
-		return -EPERM;
-
-	while (sum < len) {
-		wlen = fp->f_op->write(fp, buf+sum, len-sum, &fp->f_pos);
-		if (wlen > 0)
-			sum += wlen;
-		else if (0 != wlen)
-			return wlen;
-		else
-			break;
-	}
-	return sum;
-}
-
-/* Test if the specifi @param path is a file and readable
- * @param path the path of the file to test
- * @return Linux specific error code
- */
-static int isFileReadable(char *path)
-{
-	struct file *fp;
-	int ret = 0;
-	mm_segment_t oldfs;
-	char buf;
-
-	fp = filp_open(path, O_RDONLY, 0);
-	if (IS_ERR(fp)) {
-		ret = PTR_ERR(fp);
-	} else {
-		oldfs = get_fs();
-		set_fs(get_ds());
-
-		if (1 != readFile(fp, &buf, 1))
-			ret = PTR_ERR(fp);
-
-		set_fs(oldfs);
-		filp_close(fp, NULL);
-	}
-	return ret;
-}
-
-/* Open the file with @param path and retrive the file content into
- * memory starting from @param buf for @param sz at most
- * @param path the path of the file to open and read
- * @param buf the starting address of the buffer to store file content
- * @param sz how many bytes to read at most
- * @return the byte we've read, or Linux specific error code
- */
-static int retriveFromFile(char *path, u8 *buf, u32 sz)
-{
-	int ret = -1;
-	mm_segment_t oldfs;
-	struct file *fp;
-
-	if (path && buf) {
-		ret = openFile(&fp, path, O_RDONLY, 0);
-		if (!ret) {
-			DBG_8723A("%s openFile path:%s fp =%p\n",
-				  __func__, path, fp);
-
-			oldfs = get_fs(); set_fs(get_ds());
-			ret = readFile(fp, buf, sz);
-			set_fs(oldfs);
-			closeFile(fp);
-
-			DBG_8723A("%s readFile, ret:%d\n", __func__, ret);
-		} else {
-			DBG_8723A("%s openFile path:%s Fail, ret:%d\n",
-				  __func__, path, ret);
-		}
-	} else {
-		DBG_8723A("%s NULL pointer\n", __func__);
-		ret =  -EINVAL;
-	}
-	return ret;
-}
-
-/* Open the file with @param path and wirte @param sz byte of data starting
- * from @param buf into the file
- * @param path the path of the file to open and write
- * @param buf the starting address of the data to write into file
- * @param sz how many bytes to write at most
- * @return the byte we've written, or Linux specific error code
- */
-static int storeToFile(char *path, u8 *buf, u32 sz)
-{
-	struct file *fp;
-	int ret = 0;
-	mm_segment_t oldfs;
-
-	if (path && buf) {
-		ret = openFile(&fp, path, O_CREAT|O_WRONLY, 0666);
-		if (!ret) {
-			DBG_8723A("%s openFile path:%s fp =%p\n", __func__,
-				  path, fp);
-
-			oldfs = get_fs(); set_fs(get_ds());
-			ret = writeFile(fp, buf, sz);
-			set_fs(oldfs);
-			closeFile(fp);
-
-			DBG_8723A("%s writeFile, ret:%d\n", __func__, ret);
-		} else {
-			DBG_8723A("%s openFile path:%s Fail, ret:%d\n",
-				  __func__, path, ret);
-		}
-	} else {
-		DBG_8723A("%s NULL pointer\n", __func__);
-		ret =  -EINVAL;
-	}
-	return ret;
-}
-
-/*
-* Test if the specifi @param path is a file and readable
-* @param path the path of the file to test
-* @return true or false
-*/
-int rtw_is_file_readable(char *path)
-{
-	if (isFileReadable(path) == 0)
-		return true;
-	else
-		return false;
-}
-
-/* Open the file with @param path and retrive the file content into memoryi
- * starting from @param buf for @param sz at most
- * @param path the path of the file to open and read
- * @param buf the starting address of the buffer to store file content
- * @param sz how many bytes to read at most
- * @return the byte we've read
- */
-int rtw_retrive_from_file(char *path, u8 *buf, u32 sz)
-{
-	int ret = retriveFromFile(path, buf, sz);
-	return ret >= 0 ? ret : 0;
-}
-
-/* Open the file with @param path and wirte @param sz byte of
- * data starting from @param buf into the file
- * @param path the path of the file to open and write
- * @param buf the starting address of the data to write into file
- * @param sz how many bytes to write at most
- * @return the byte we've written
- */
-int rtw_store_to_file(char *path, u8 *buf, u32 sz)
-{
-	int ret = storeToFile(path, buf, sz);
-	return ret >= 0 ? ret : 0;
-}
-
 u64 rtw_modular6423a(u64 x, u64 y)
 {
 	return do_div(x, y);
diff --git a/drivers/staging/rtl8723au/os_dep/usb_intf.c b/drivers/staging/rtl8723au/os_dep/usb_intf.c
index 040bf29..612806e 100644
--- a/drivers/staging/rtl8723au/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8723au/os_dep/usb_intf.c
@@ -664,8 +664,10 @@ static struct rtw_adapter *rtw_usb_if1_init(struct dvobj_priv *dvobj,
 
 	/*  set mac addr */
 	rtw_macaddr_cfg23a(padapter->eeprompriv.mac_addr);
+#ifdef CONFIG_8723AU_P2P
 	rtw_init_wifidirect_addrs23a(padapter, padapter->eeprompriv.mac_addr,
 				  padapter->eeprompriv.mac_addr);
+#endif
 
 	DBG_8723A("bDriverStopped:%d, bSurpriseRemoved:%d, bup:%d, hw_init_completed:%d\n",
 		  padapter->bDriverStopped, padapter->bSurpriseRemoved,
@@ -811,12 +813,9 @@ static void rtw_disconnect(struct usb_interface *pusb_intf)
 	return;
 }
 
-extern int console_suspend_enabled;
-
 static int __init rtw_drv_entry(void)
 {
 	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+rtw_drv_entry\n"));
-	rtw_suspend_lock_init();
 	return usb_register(usb_drv);
 }
 
@@ -825,8 +824,6 @@ static void __exit rtw_drv_halt(void)
 	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+rtw_drv_halt\n"));
 	DBG_8723A("+rtw_drv_halt\n");
 
-	rtw_suspend_lock_uninit();
-
 	usb_deregister(usb_drv);
 
 	DBG_8723A("-rtw_drv_halt\n");
-- 
1.8.4.5
