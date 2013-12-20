From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/2] staging: r8188eu: Fix unused variable warnings
Date: Fri, 20 Dec 2013 14:58:45 -0600
Message-ID: <1387573126-28907-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1387573126-28907-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:50749 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab3LTU7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 15:59:07 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so3110762pab.21
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 12:59:06 -0800 (PST)
In-Reply-To: <1387573126-28907-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A previous set of patches were test compiled with one of the configuration
variables not set. As a result, a number of unused variables were left in the
code.

In several instances, declaration of the unused variable was the only statement
inside ifdef .. endif pairs. In those cases, the entire block was removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c        | 12 ------------
 drivers/staging/rtl8188eu/core/rtw_debug.c     |  1 -
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c  |  8 --------
 drivers/staging/rtl8188eu/core/rtw_recv.c      |  1 -
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c   |  4 ----
 drivers/staging/rtl8188eu/core/rtw_xmit.c      |  8 --------
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c |  1 -
 7 files changed, 35 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index e022aaa..8ebe6bc 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -43,7 +43,6 @@ void init_mlme_ap_info(struct adapter *padapter)
 
 void free_mlme_ap_info(struct adapter *padapter)
 {
-	unsigned long irqL;
 	struct sta_info *psta = NULL;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 	struct mlme_priv *pmlmepriv = &(padapter->mlmepriv);
@@ -275,7 +274,6 @@ static u8 chk_sta_is_alive(struct sta_info *psta)
 
 void	expire_timeout_chk(struct adapter *padapter)
 {
-	unsigned long irqL;
 	struct list_head *phead, *plist;
 	u8 updated = 0;
 	struct sta_info *psta = NULL;
@@ -533,7 +531,6 @@ void add_RATid(struct adapter *padapter, struct sta_info *psta, u8 rssi_level)
 
 static void update_bmc_sta(struct adapter *padapter)
 {
-	unsigned long	irqL;
 	u32 init_rate = 0;
 	unsigned char	network_type, raid;
 	int i, supportRateNum = 0;
@@ -620,7 +617,6 @@ static void update_bmc_sta(struct adapter *padapter)
 
 void update_sta_info_apmode(struct adapter *padapter, struct sta_info *psta)
 {
-	unsigned long	irqL;
 	struct mlme_priv *pmlmepriv = &(padapter->mlmepriv);
 	struct security_priv *psecuritypriv = &padapter->securitypriv;
 	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
@@ -1132,7 +1128,6 @@ void rtw_set_macaddr_acl(struct adapter *padapter, int mode)
 
 int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 {
-	unsigned long irqL;
 	struct list_head *plist, *phead;
 	u8 added = false;
 	int i, ret = 0;
@@ -1198,7 +1193,6 @@ int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 
 int rtw_acl_remove_sta(struct adapter *padapter, u8 *addr)
 {
-	unsigned long irqL;
 	struct list_head *plist, *phead;
 	int ret = 0;
 	struct rtw_wlan_acl_node *paclnode;
@@ -1371,7 +1365,6 @@ static void update_bcn_vendor_spec_ie(struct adapter *padapter, u8 *oui)
 
 void update_beacon(struct adapter *padapter, u8 ie_id, u8 *oui, u8 tx)
 {
-	unsigned long irqL;
 	struct mlme_priv *pmlmepriv;
 	struct mlme_ext_priv	*pmlmeext;
 
@@ -1503,7 +1496,6 @@ void associated_clients_update(struct adapter *padapter, u8 updated)
 {
 	/* update associcated stations cap. */
 	if (updated) {
-		unsigned long irqL;
 		struct list_head *phead, *plist;
 		struct sta_info *psta = NULL;
 		struct sta_priv *pstapriv = &padapter->stapriv;
@@ -1729,7 +1721,6 @@ u8 bss_cap_update_on_sta_leave(struct adapter *padapter, struct sta_info *psta)
 u8 ap_free_sta(struct adapter *padapter, struct sta_info *psta,
 	       bool active, u16 reason)
 {
-	unsigned long irqL;
 	u8 beacon_updated = false;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 
@@ -1770,7 +1761,6 @@ u8 ap_free_sta(struct adapter *padapter, struct sta_info *psta,
 
 int rtw_ap_inform_ch_switch(struct adapter *padapter, u8 new_ch, u8 ch_offset)
 {
-	unsigned long irqL;
 	struct list_head *phead, *plist;
 	int ret = 0;
 	struct sta_info *psta = NULL;
@@ -1806,7 +1796,6 @@ int rtw_ap_inform_ch_switch(struct adapter *padapter, u8 new_ch, u8 ch_offset)
 
 int rtw_sta_flush(struct adapter *padapter)
 {
-	unsigned long irqL;
 	struct list_head *phead, *plist;
 	int ret = 0;
 	struct sta_info *psta = NULL;
@@ -1933,7 +1922,6 @@ void start_ap_mode(struct adapter *padapter)
 
 void stop_ap_mode(struct adapter *padapter)
 {
-	unsigned long irqL;
 	struct list_head *phead, *plist;
 	struct rtw_wlan_acl_node *paclnode;
 	struct sta_info *psta = NULL;
diff --git a/drivers/staging/rtl8188eu/core/rtw_debug.c b/drivers/staging/rtl8188eu/core/rtw_debug.c
index 8a1988e..af32041 100644
--- a/drivers/staging/rtl8188eu/core/rtw_debug.c
+++ b/drivers/staging/rtl8188eu/core/rtw_debug.c
@@ -835,7 +835,6 @@ int proc_get_all_sta_info(char *page, char **start,
 			  off_t offset, int count,
 			  int *eof, void *data)
 {
-	unsigned long irqL;
 	struct sta_info *psta;
 	struct net_device *dev = data;
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index c189056..9938e22 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -756,7 +756,6 @@ _END_ONBEACON_:
 unsigned int OnAuth(struct adapter *padapter, union recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_AP_MODE
-	unsigned long irqL;
 	unsigned int	auth_mode, ie_len;
 	u16 seq;
 	unsigned char	*sa, *p;
@@ -1005,7 +1004,6 @@ authclnt_fail:
 unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_AP_MODE
-	unsigned long irqL;
 	u16 capab_info;
 	struct rtw_ieee802_11_elems elems;
 	struct sta_info	*pstat;
@@ -1590,7 +1588,6 @@ unsigned int OnDeAuth(struct adapter *padapter, union recv_frame *precv_frame)
 
 #ifdef CONFIG_88EU_AP_MODE
 	if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
-		unsigned long irqL;
 		struct sta_info *psta;
 		struct sta_priv *pstapriv = &padapter->stapriv;
 
@@ -1654,7 +1651,6 @@ unsigned int OnDisassoc(struct adapter *padapter, union recv_frame *precv_frame)
 
 #ifdef CONFIG_88EU_AP_MODE
 	if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
-		unsigned long irqL;
 		struct sta_info *psta;
 		struct sta_priv *pstapriv = &padapter->stapriv;
 
@@ -4483,9 +4479,6 @@ void issue_beacon(struct adapter *padapter, int timeout_ms)
 	__le16 *fctrl;
 	unsigned int	rate_len;
 	struct xmit_priv	*pxmitpriv = &(padapter->xmitpriv);
-#if defined(CONFIG_88EU_AP_MODE)
-	unsigned long irqL;
-#endif /* if defined (CONFIG_88EU_AP_MODE) */
 	struct mlme_priv *pmlmepriv = &(padapter->mlmepriv);
 	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
@@ -8360,7 +8353,6 @@ u8 tx_beacon_hdl(struct adapter *padapter, unsigned char *pbuf)
 	}
 #ifdef CONFIG_88EU_AP_MODE
 	else { /* tx bc/mc frames after update TIM */
-		unsigned long irqL;
 		struct sta_info *psta_bmc;
 		struct list_head *xmitframe_plist, *xmitframe_phead;
 		struct xmit_frame *pxmitframe = NULL;
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 9c9d1dd..7c5403a 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -1092,7 +1092,6 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 		}
 
 		if ((psta->state&WIFI_SLEEP_STATE) && (pstapriv->sta_dz_bitmap&BIT(psta->aid))) {
-			unsigned long irqL;
 			struct list_head *xmitframe_plist, *xmitframe_phead;
 			struct xmit_frame *pxmitframe = NULL;
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index ff03424..ed8075d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -173,9 +173,6 @@ _func_exit_;
 
 static void rtw_mfree_sta_priv_lock(struct sta_priv *pstapriv)
 {
-#ifdef CONFIG_88EU_AP_MODE
-	struct wlan_acl_pool *pacl_list = &pstapriv->acl_list;
-#endif
 	 rtw_mfree_all_stainfo(pstapriv); /* be done before free sta_hash_lock */
 }
 
@@ -555,7 +552,6 @@ u8 rtw_access_ctrl(struct adapter *padapter, u8 *mac_addr)
 {
 	u8 res = true;
 #ifdef CONFIG_88EU_AP_MODE
-	unsigned long irql;
 	struct list_head *plist, *phead;
 	struct rtw_wlan_acl_node *paclnode;
 	u8 match = false;
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index a457385..0ebcc7a 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -1651,7 +1651,6 @@ _func_exit_;
  */
 s32 rtw_xmit_classifier(struct adapter *padapter, struct xmit_frame *pxmitframe)
 {
-	/* unsigned long irql0; */
 	u8	ac_index;
 	struct sta_info	*psta;
 	struct tx_servq	*ptxservq;
@@ -1912,9 +1911,6 @@ static void do_queue_select(struct adapter	*padapter, struct pkt_attrib *pattrib
  */
 s32 rtw_xmit(struct adapter *padapter, struct sk_buff **ppkt)
 {
-#ifdef CONFIG_88EU_AP_MODE
-	unsigned long irql0;
-#endif
 	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
 	struct xmit_frame *pxmitframe = NULL;
 	struct mlme_priv	*pmlmepriv = &padapter->mlmepriv;
@@ -1972,7 +1968,6 @@ s32 rtw_xmit(struct adapter *padapter, struct sk_buff **ppkt)
 
 int xmitframe_enqueue_for_sleeping_sta(struct adapter *padapter, struct xmit_frame *pxmitframe)
 {
-	unsigned long irql;
 	int ret = false;
 	struct sta_info *psta = NULL;
 	struct sta_priv *pstapriv = &padapter->stapriv;
@@ -2103,7 +2098,6 @@ static void dequeue_xmitframes_to_sleeping_queue(struct adapter *padapter, struc
 
 void stop_sta_xmit(struct adapter *padapter, struct sta_info *psta)
 {
-	unsigned long irql0;
 	struct sta_info *psta_bmc;
 	struct sta_xmit_priv *pstaxmitpriv;
 	struct sta_priv *pstapriv = &padapter->stapriv;
@@ -2142,7 +2136,6 @@ void stop_sta_xmit(struct adapter *padapter, struct sta_info *psta)
 
 void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 {
-	unsigned long irql;
 	u8 update_mask = 0, wmmps_ac = 0;
 	struct sta_info *psta_bmc;
 	struct list_head *xmitframe_plist, *xmitframe_phead;
@@ -2272,7 +2265,6 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 
 void xmit_delivery_enabled_frames(struct adapter *padapter, struct sta_info *psta)
 {
-	unsigned long irql;
 	u8 wmmps_ac = 0;
 	struct list_head *xmitframe_plist, *xmitframe_phead;
 	struct xmit_frame *pxmitframe = NULL;
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index 13f52581..c8e808e 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -5237,7 +5237,6 @@ static int rtw_add_sta(struct net_device *dev, struct ieee_param *param)
 
 static int rtw_del_sta(struct net_device *dev, struct ieee_param *param)
 {
-	unsigned long irqL;
 	int ret = 0;
 	struct sta_info *psta = NULL;
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
-- 
1.8.4
