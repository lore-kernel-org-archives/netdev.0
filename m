From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/6] staging: r8188eu: Replace misspelled local container macro
Date: Sun,  9 Feb 2014 15:15:57 -0600
Message-ID: <1391980559-24288-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:65104 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaBIVQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 16:16:11 -0500
Received: by mail-ob0-f172.google.com with SMTP id vb8so6399287obc.17
        for <netdev@vger.kernel.org>; Sun, 09 Feb 2014 13:16:11 -0800 (PST)
In-Reply-To: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver has its own implementation of a "container_of" macro. It
is replaced with the standard container_of version. Most of these
are a straight one-to-one replacement; however, a few of the instances
referred to the member of a union. Those were replaced with the
struct that is part of that union.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c           | 16 ++++-----
 drivers/staging/rtl8188eu/core/rtw_cmd.c          |  2 +-
 drivers/staging/rtl8188eu/core/rtw_debug.c        |  2 +-
 drivers/staging/rtl8188eu/core/rtw_mlme.c         | 14 ++++----
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     |  4 +--
 drivers/staging/rtl8188eu/core/rtw_p2p.c          |  4 +--
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 44 ++++++++++++-----------
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      | 16 +++++----
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 20 +++++------
 drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c    |  2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h |  4 ---
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c    | 26 +++++++-------
 drivers/staging/rtl8188eu/os_dep/xmit_linux.c     |  2 +-
 13 files changed, 78 insertions(+), 78 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index fe5ec8e..f32011c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -289,7 +289,7 @@ void	expire_timeout_chk(struct adapter *padapter)
 
 	/* check auth_queue */
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
-		psta = LIST_CONTAINOR(plist, struct sta_info, auth_list);
+		psta = container_of(plist, struct sta_info, auth_list);
 		plist = get_next(plist);
 
 		if (psta->expire_to > 0) {
@@ -323,7 +323,7 @@ void	expire_timeout_chk(struct adapter *padapter)
 
 	/* check asoc_queue */
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
-		psta = LIST_CONTAINOR(plist, struct sta_info, asoc_list);
+		psta = container_of(plist, struct sta_info, asoc_list);
 		plist = get_next(plist);
 
 		if (chk_sta_is_alive(psta) || !psta->expire_to) {
@@ -1147,7 +1147,7 @@ int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 	plist = get_next(phead);
 
 	while (!rtw_end_of_queue_search(phead, plist)) {
-		paclnode = LIST_CONTAINOR(plist, struct rtw_wlan_acl_node, list);
+		paclnode = container_of(plist, struct rtw_wlan_acl_node, list);
 		plist = get_next(plist);
 
 		if (!memcmp(paclnode->addr, addr, ETH_ALEN)) {
@@ -1208,7 +1208,7 @@ int rtw_acl_remove_sta(struct adapter *padapter, u8 *addr)
 	plist = get_next(phead);
 
 	while (!rtw_end_of_queue_search(phead, plist)) {
-		paclnode = LIST_CONTAINOR(plist, struct rtw_wlan_acl_node, list);
+		paclnode = container_of(plist, struct rtw_wlan_acl_node, list);
 		plist = get_next(plist);
 
 		if (!memcmp(paclnode->addr, addr, ETH_ALEN)) {
@@ -1507,7 +1507,7 @@ void associated_clients_update(struct adapter *padapter, u8 updated)
 
 		/* check asoc_queue */
 		while ((rtw_end_of_queue_search(phead, plist)) == false) {
-			psta = LIST_CONTAINOR(plist, struct sta_info, asoc_list);
+			psta = container_of(plist, struct sta_info, asoc_list);
 
 			plist = get_next(plist);
 
@@ -1781,7 +1781,7 @@ int rtw_ap_inform_ch_switch(struct adapter *padapter, u8 new_ch, u8 ch_offset)
 
 	/* for each sta in asoc_queue */
 	while (!rtw_end_of_queue_search(phead, plist)) {
-		psta = LIST_CONTAINOR(plist, struct sta_info, asoc_list);
+		psta = container_of(plist, struct sta_info, asoc_list);
 		plist = get_next(plist);
 
 		issue_action_spct_ch_switch(padapter, psta->hwaddr, new_ch, ch_offset);
@@ -1815,7 +1815,7 @@ int rtw_sta_flush(struct adapter *padapter)
 
 	/* free sta asoc_queue */
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
-		psta = LIST_CONTAINOR(plist, struct sta_info, asoc_list);
+		psta = container_of(plist, struct sta_info, asoc_list);
 
 		plist = get_next(plist);
 
@@ -1944,7 +1944,7 @@ void stop_ap_mode(struct adapter *padapter)
 	phead = get_list_head(pacl_node_q);
 	plist = get_next(phead);
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
-		paclnode = LIST_CONTAINOR(plist, struct rtw_wlan_acl_node, list);
+		paclnode = container_of(plist, struct rtw_wlan_acl_node, list);
 		plist = get_next(plist);
 
 		if (paclnode->valid) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index 82fe8c4..d24252d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -173,7 +173,7 @@ _func_enter_;
 	if (rtw_is_list_empty(&(queue->queue))) {
 		obj = NULL;
 	} else {
-		obj = LIST_CONTAINOR(get_next(&(queue->queue)), struct cmd_obj, list);
+		obj = container_of(get_next(&(queue->queue)), struct cmd_obj, list);
 		rtw_list_delete(&obj->list);
 	}
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_debug.c b/drivers/staging/rtl8188eu/core/rtw_debug.c
index af32041..76e7b7b 100644
--- a/drivers/staging/rtl8188eu/core/rtw_debug.c
+++ b/drivers/staging/rtl8188eu/core/rtw_debug.c
@@ -854,7 +854,7 @@ int proc_get_all_sta_info(char *page, char **start,
 		plist = get_next(phead);
 
 		while ((rtw_end_of_queue_search(phead, plist)) == false) {
-			psta = LIST_CONTAINOR(plist, struct sta_info, hash_list);
+			psta = container_of(plist, struct sta_info, hash_list);
 
 			plist = get_next(plist);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 4f482e2..55090d7 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -167,7 +167,7 @@ _func_enter_;
 	if (_rtw_queue_empty(queue)) {
 		pnetwork = NULL;
 	} else {
-		pnetwork = LIST_CONTAINOR(get_next(&queue->queue), struct wlan_network, list);
+		pnetwork = container_of(get_next(&queue->queue), struct wlan_network, list);
 
 		rtw_list_delete(&(pnetwork->list));
 	}
@@ -195,7 +195,7 @@ _func_enter_;
 	}
 	plist = get_next(&(free_queue->queue));
 
-	pnetwork = LIST_CONTAINOR(plist , struct wlan_network, list);
+	pnetwork = container_of(plist , struct wlan_network, list);
 
 	rtw_list_delete(&pnetwork->list);
 
@@ -285,7 +285,7 @@ _func_enter_;
 	plist = get_next(phead);
 
 	while (plist != phead) {
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network , list);
+		pnetwork = container_of(plist, struct wlan_network , list);
 		if (!memcmp(addr, pnetwork->network.MacAddress, ETH_ALEN) == true)
 			break;
 		plist = get_next(plist);
@@ -314,7 +314,7 @@ _func_enter_;
 	plist = get_next(phead);
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 
 		plist = get_next(plist);
 
@@ -500,7 +500,7 @@ _func_enter_;
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pwlan = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pwlan = container_of(plist, struct wlan_network, list);
 
 		if (!pwlan->fixed) {
 			if (oldest == NULL || time_after(oldest->last_scanned, pwlan->last_scanned))
@@ -593,7 +593,7 @@ _func_enter_;
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork	= LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork	= container_of(plist, struct wlan_network, list);
 
 		if (is_same_network(&(pnetwork->network), target))
 			break;
@@ -1749,7 +1749,7 @@ _func_enter_;
 	adapter = (struct adapter *)pmlmepriv->nic_hdl;
 	pmlmepriv->pscanned = get_next(phead);
 	while (!rtw_end_of_queue_search(phead, pmlmepriv->pscanned)) {
-		pnetwork = LIST_CONTAINOR(pmlmepriv->pscanned, struct wlan_network, list);
+		pnetwork = container_of(pmlmepriv->pscanned, struct wlan_network, list);
 		if (pnetwork == NULL) {
 			RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("%s return _FAIL:(pnetwork==NULL)\n", __func__));
 			ret = _FAIL;
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index ce96586..8e92335 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -6236,7 +6236,7 @@ static void issue_action_BSSCoexistPacket(struct adapter *padapter)
 			if (rtw_end_of_queue_search(phead, plist))
 				break;
 
-			pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+			pnetwork = container_of(plist, struct wlan_network, list);
 
 			plist = get_next(plist);
 
@@ -8375,7 +8375,7 @@ u8 tx_beacon_hdl(struct adapter *padapter, unsigned char *pbuf)
 			xmitframe_plist = get_next(xmitframe_phead);
 
 			while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
-				pxmitframe = LIST_CONTAINOR(xmitframe_plist, struct xmit_frame, list);
+				pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
 				xmitframe_plist = get_next(xmitframe_plist);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index 4a9342d..e91a2ee 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -61,7 +61,7 @@ static u32 go_add_group_info_attr(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	/* look up sta asoc_queue */
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
-		psta = LIST_CONTAINOR(plist, struct sta_info, asoc_list);
+		psta = container_of(plist, struct sta_info, asoc_list);
 
 		plist = get_next(plist);
 
@@ -984,7 +984,7 @@ u32 process_p2p_devdisc_req(struct wifidirect_info *pwdinfo, u8 *pframe, uint le
 
 					/* look up sta asoc_queue */
 					while ((rtw_end_of_queue_search(phead, plist)) == false) {
-						psta = LIST_CONTAINOR(plist, struct sta_info, asoc_list);
+						psta = container_of(plist, struct sta_info, asoc_list);
 
 						plist = get_next(plist);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 7c5bfaf..edc40e5 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -140,23 +140,23 @@ _func_exit_;
 
 union recv_frame *_rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
 {
-	union recv_frame  *precvframe;
+	struct recv_frame_hdr *hdr;
 	struct list_head *plist, *phead;
 	struct adapter *padapter;
 	struct recv_priv *precvpriv;
 _func_enter_;
 
 	if (_rtw_queue_empty(pfree_recv_queue)) {
-		precvframe = NULL;
+		hdr = NULL;
 	} else {
 		phead = get_list_head(pfree_recv_queue);
 
 		plist = get_next(phead);
 
-		precvframe = LIST_CONTAINOR(plist, union recv_frame, u);
+		hdr = container_of(plist, struct recv_frame_hdr, list);
 
-		rtw_list_delete(&precvframe->u.hdr.list);
-		padapter = precvframe->u.hdr.adapter;
+		rtw_list_delete(&hdr->list);
+		padapter = hdr->adapter;
 		if (padapter != NULL) {
 			precvpriv = &padapter->recvpriv;
 			if (pfree_recv_queue == &precvpriv->free_recv_queue)
@@ -166,7 +166,7 @@ _func_enter_;
 
 _func_exit_;
 
-	return precvframe;
+	return (union recv_frame *)hdr;
 }
 
 union recv_frame *rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
@@ -266,7 +266,7 @@ using spinlock to protect
 
 void rtw_free_recvframe_queue(struct __queue *pframequeue,  struct __queue *pfree_recv_queue)
 {
-	union	recv_frame	*precvframe;
+	struct recv_frame_hdr *hdr;
 	struct list_head *plist, *phead;
 
 _func_enter_;
@@ -276,11 +276,11 @@ _func_enter_;
 	plist = get_next(phead);
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
-		precvframe = LIST_CONTAINOR(plist, union recv_frame, u);
+		hdr = container_of(plist, struct recv_frame_hdr, list);
 
 		plist = get_next(plist);
 
-		rtw_free_recvframe(precvframe, pfree_recv_queue);
+		rtw_free_recvframe((union recv_frame *)hdr, pfree_recv_queue);
 	}
 
 	spin_unlock(&pframequeue->lock);
@@ -340,7 +340,7 @@ struct recv_buf *rtw_dequeue_recvbuf (struct __queue *queue)
 
 		plist = get_next(phead);
 
-		precvbuf = LIST_CONTAINOR(plist, struct recv_buf, list);
+		precvbuf = container_of(plist, struct recv_buf, list);
 
 		rtw_list_delete(&precvbuf->list);
 	}
@@ -1102,7 +1102,7 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 			xmitframe_plist = get_next(xmitframe_phead);
 
 			if ((rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) == false) {
-				pxmitframe = LIST_CONTAINOR(xmitframe_plist, struct xmit_frame, list);
+				pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
 				xmitframe_plist = get_next(xmitframe_plist);
 
@@ -1518,8 +1518,8 @@ _func_enter_;
 
 	phead = get_list_head(defrag_q);
 	plist = get_next(phead);
-	prframe = LIST_CONTAINOR(plist, union recv_frame, u);
-	pfhdr = &prframe->u.hdr;
+	pfhdr = container_of(plist, struct recv_frame_hdr, list);
+	prframe = (union recv_frame *)pfhdr;
 	rtw_list_delete(&(prframe->u.list));
 
 	if (curfragnum != pfhdr->attrib.frag_num) {
@@ -1538,8 +1538,8 @@ _func_enter_;
 	plist = get_next(plist);
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
-		pnextrframe = LIST_CONTAINOR(plist, union recv_frame , u);
-		pnfhdr = &pnextrframe->u.hdr;
+		pnfhdr = container_of(plist, struct recv_frame_hdr , list);
+		pnextrframe = (union recv_frame *)pnfhdr;
 
 		/* check the fragment sequence  (2nd ~n fragment frame) */
 
@@ -1839,15 +1839,15 @@ int enqueue_reorder_recvframe(struct recv_reorder_ctrl *preorder_ctrl, union rec
 	struct rx_pkt_attrib *pattrib = &prframe->u.hdr.attrib;
 	struct __queue *ppending_recvframe_queue = &preorder_ctrl->pending_recvframe_queue;
 	struct list_head *phead, *plist;
-	union recv_frame *pnextrframe;
+	struct recv_frame_hdr *hdr;
 	struct rx_pkt_attrib *pnextattrib;
 
 	phead = get_list_head(ppending_recvframe_queue);
 	plist = get_next(phead);
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
-		pnextrframe = LIST_CONTAINOR(plist, union recv_frame, u);
-		pnextattrib = &pnextrframe->u.hdr.attrib;
+		hdr = container_of(plist, struct recv_frame_hdr, list);
+		pnextattrib = &hdr->attrib;
 
 		if (SN_LESS(pnextattrib->seq_num, pattrib->seq_num))
 			plist = get_next(plist);
@@ -1867,6 +1867,7 @@ static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reor
 {
 	struct list_head *phead, *plist;
 	union recv_frame *prframe;
+	struct recv_frame_hdr *prhdr;
 	struct rx_pkt_attrib *pattrib;
 	int bPktInBuf = false;
 	struct recv_priv *precvpriv = &padapter->recvpriv;
@@ -1880,15 +1881,16 @@ static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reor
 		if (rtw_is_list_empty(phead))
 			return true;
 
-		prframe = LIST_CONTAINOR(plist, union recv_frame, u);
-		pattrib = &prframe->u.hdr.attrib;
+		prhdr = container_of(plist, struct recv_frame_hdr, list);
+	        pattrib = &prhdr->attrib;
 		preorder_ctrl->indicate_seq = pattrib->seq_num;
 	}
 
 	/*  Prepare indication list and indication. */
 	/*  Check if there is any packet need indicate. */
 	while (!rtw_is_list_empty(phead)) {
-		prframe = LIST_CONTAINOR(plist, union recv_frame, u);
+		prhdr = container_of(plist, struct recv_frame_hdr, list);
+		prframe = (union recv_frame *)prhdr;
 		pattrib = &prframe->u.hdr.attrib;
 
 		if (!SN_LESS(preorder_ctrl->indicate_seq, pattrib->seq_num)) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index 0441bcc..6f870b8 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -163,7 +163,7 @@ _func_enter_;
 	plist = get_next(phead);
 
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
-		psta = LIST_CONTAINOR(plist, struct sta_info , list);
+		psta = container_of(plist, struct sta_info , list);
 		plist = get_next(plist);
 	}
 
@@ -194,7 +194,7 @@ _func_enter_;
 
 			while ((rtw_end_of_queue_search(phead, plist)) == false) {
 				int i;
-				psta = LIST_CONTAINOR(plist, struct sta_info , hash_list);
+				psta = container_of(plist, struct sta_info , hash_list);
 				plist = get_next(plist);
 
 				for (i = 0; i < 16; i++) {
@@ -236,7 +236,7 @@ _func_enter_;
 		spin_unlock_bh(&pfree_sta_queue->lock);
 		psta = NULL;
 	} else {
-		psta = LIST_CONTAINOR(get_next(&pfree_sta_queue->queue), struct sta_info, list);
+		psta = container_of(get_next(&pfree_sta_queue->queue), struct sta_info, list);
 		rtw_list_delete(&(psta->list));
 		spin_unlock_bh(&pfree_sta_queue->lock);
 		_rtw_init_stainfo(psta);
@@ -359,6 +359,7 @@ _func_enter_;
 	/* for A-MPDU Rx reordering buffer control, cancel reordering_ctrl_timer */
 	for (i = 0; i < 16; i++) {
 		struct list_head *phead, *plist;
+		struct recv_frame_hdr *prhdr;
 		union recv_frame *prframe;
 		struct __queue *ppending_recvframe_queue;
 		struct __queue *pfree_recv_queue = &padapter->recvpriv.free_recv_queue;
@@ -375,7 +376,8 @@ _func_enter_;
 		plist = get_next(phead);
 
 		while (!rtw_is_list_empty(phead)) {
-			prframe = LIST_CONTAINOR(plist, union recv_frame, u);
+			prhdr = container_of(plist, struct recv_frame_hdr, list);
+			prframe = (union recv_frame *)prhdr;
 
 			plist = get_next(plist);
 
@@ -455,7 +457,7 @@ _func_enter_;
 		plist = get_next(phead);
 
 		while ((!rtw_end_of_queue_search(phead, plist))) {
-			psta = LIST_CONTAINOR(plist, struct sta_info , hash_list);
+			psta = container_of(plist, struct sta_info , hash_list);
 
 			plist = get_next(plist);
 
@@ -498,7 +500,7 @@ _func_enter_;
 	plist = get_next(phead);
 
 	while ((!rtw_end_of_queue_search(phead, plist))) {
-		psta = LIST_CONTAINOR(plist, struct sta_info, hash_list);
+		psta = container_of(plist, struct sta_info, hash_list);
 
 		if ((!memcmp(psta->hwaddr, addr, ETH_ALEN)) == true) {
 			/*  if found the matched address */
@@ -564,7 +566,7 @@ u8 rtw_access_ctrl(struct adapter *padapter, u8 *mac_addr)
 	phead = get_list_head(pacl_node_q);
 	plist = get_next(phead);
 	while ((!rtw_end_of_queue_search(phead, plist))) {
-		paclnode = LIST_CONTAINOR(plist, struct rtw_wlan_acl_node, list);
+		paclnode = container_of(plist, struct rtw_wlan_acl_node, list);
 		plist = get_next(plist);
 
 		if (!memcmp(paclnode->addr, mac_addr, ETH_ALEN)) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index be35db6..d459127 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -1262,7 +1262,7 @@ _func_enter_;
 
 		plist = get_next(phead);
 
-		pxmitbuf = LIST_CONTAINOR(plist, struct xmit_buf, list);
+		pxmitbuf = container_of(plist, struct xmit_buf, list);
 
 		rtw_list_delete(&(pxmitbuf->list));
 	}
@@ -1330,7 +1330,7 @@ _func_enter_;
 
 		plist = get_next(phead);
 
-		pxmitbuf = LIST_CONTAINOR(plist, struct xmit_buf, list);
+		pxmitbuf = container_of(plist, struct xmit_buf, list);
 
 		rtw_list_delete(&(pxmitbuf->list));
 	}
@@ -1418,7 +1418,7 @@ _func_enter_;
 
 		plist = get_next(phead);
 
-		pxframe = LIST_CONTAINOR(plist, struct xmit_frame, list);
+		pxframe = container_of(plist, struct xmit_frame, list);
 
 		rtw_list_delete(&(pxframe->list));
 	}
@@ -1502,7 +1502,7 @@ _func_enter_;
 	plist = get_next(phead);
 
 	while (!rtw_end_of_queue_search(phead, plist)) {
-		pxmitframe = LIST_CONTAINOR(plist, struct xmit_frame, list);
+		pxmitframe = container_of(plist, struct xmit_frame, list);
 
 		plist = get_next(plist);
 
@@ -1534,7 +1534,7 @@ static struct xmit_frame *dequeue_one_xmitframe(struct xmit_priv *pxmitpriv, str
 	xmitframe_plist = get_next(xmitframe_phead);
 
 	if (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
-		pxmitframe = LIST_CONTAINOR(xmitframe_plist, struct xmit_frame, list);
+		pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
 		xmitframe_plist = get_next(xmitframe_plist);
 
@@ -1576,7 +1576,7 @@ _func_enter_;
 		sta_plist = get_next(sta_phead);
 
 		while (!rtw_end_of_queue_search(sta_phead, sta_plist)) {
-			ptxservq = LIST_CONTAINOR(sta_plist, struct tx_servq, tx_pending);
+			ptxservq = container_of(sta_plist, struct tx_servq, tx_pending);
 
 			pframe_queue = &ptxservq->sta_pending;
 
@@ -2074,7 +2074,7 @@ static void dequeue_xmitframes_to_sleeping_queue(struct adapter *padapter, struc
 	plist = get_next(phead);
 
 	while (!rtw_end_of_queue_search(phead, plist)) {
-		pxmitframe = LIST_CONTAINOR(plist, struct xmit_frame, list);
+		pxmitframe = container_of(plist, struct xmit_frame, list);
 
 		plist = get_next(plist);
 
@@ -2141,7 +2141,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 	xmitframe_plist = get_next(xmitframe_phead);
 
 	while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
-		pxmitframe = LIST_CONTAINOR(xmitframe_plist, struct xmit_frame, list);
+		pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
 		xmitframe_plist = get_next(xmitframe_plist);
 
@@ -2222,7 +2222,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 		xmitframe_plist = get_next(xmitframe_phead);
 
 		while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
-			pxmitframe = LIST_CONTAINOR(xmitframe_plist, struct xmit_frame, list);
+			pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
 			xmitframe_plist = get_next(xmitframe_plist);
 
@@ -2269,7 +2269,7 @@ void xmit_delivery_enabled_frames(struct adapter *padapter, struct sta_info *pst
 	xmitframe_plist = get_next(xmitframe_phead);
 
 	while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
-		pxmitframe = LIST_CONTAINOR(xmitframe_plist, struct xmit_frame, list);
+		pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
 		xmitframe_plist = get_next(xmitframe_plist);
 
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c b/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
index 6fb6a46..50bc215 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
@@ -540,7 +540,7 @@ s32 rtl8188eu_xmitframe_complete(struct adapter *adapt, struct xmit_priv *pxmitp
 	xmitframe_plist = get_next(xmitframe_phead);
 
 	while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
-		pxmitframe = LIST_CONTAINOR(xmitframe_plist, struct xmit_frame, list);
+		pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 		xmitframe_plist = get_next(xmitframe_plist);
 
 		pxmitframe->agg_num = 0; /*  not first frame of aggregation */
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index e726ff8..5939921 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -72,10 +72,6 @@ static inline struct list_head *get_list_head(struct __queue *queue)
 	return &(queue->queue);
 }
 
-
-#define LIST_CONTAINOR(ptr, type, member) \
-	((type *)((char *)(ptr)-(size_t)(&((type *)0)->member)))
-
 static inline int _enter_critical_mutex(struct mutex *pmutex,
 					unsigned long *pirqL)
 {
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index f3584dd..f9e52b3 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -1145,7 +1145,7 @@ static int rtw_wx_set_wap(struct net_device *dev,
 		if ((rtw_end_of_queue_search(phead, pmlmepriv->pscanned)) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(pmlmepriv->pscanned, struct wlan_network, list);
+		pnetwork = container_of(pmlmepriv->pscanned, struct wlan_network, list);
 
 		pmlmepriv->pscanned = get_next(pmlmepriv->pscanned);
 
@@ -1452,7 +1452,7 @@ static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 			break;
 		}
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 
 		/* report network only if the current channel set contains the channel to which this network belongs */
 		if (rtw_ch_set_search_ch(padapter->mlmeextpriv.channel_set, pnetwork->network.Configuration.DSConfig) >= 0)
@@ -1541,7 +1541,7 @@ static int rtw_wx_set_essid(struct net_device *dev,
 				break;
 			}
 
-			pnetwork = LIST_CONTAINOR(pmlmepriv->pscanned, struct wlan_network, list);
+			pnetwork = container_of(pmlmepriv->pscanned, struct wlan_network, list);
 
 			pmlmepriv->pscanned = get_next(pmlmepriv->pscanned);
 
@@ -2614,7 +2614,7 @@ static int rtw_get_ap_info(struct net_device *dev,
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 
 		if (hwaddr_aton_i(data, bssid)) {
 			DBG_88E("Invalid BSSID '%s'.\n", (u8 *)data);
@@ -3117,7 +3117,7 @@ static int rtw_p2p_get_wps_configmethod(struct net_device *dev,
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 		if (!memcmp(pnetwork->network.MacAddress, peerMAC, ETH_ALEN)) {
 			u8 *wpsie;
 			uint wpsie_len = 0;
@@ -3187,7 +3187,7 @@ static int rtw_p2p_get_go_device_address(struct net_device *dev,
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 		if (!memcmp(pnetwork->network.MacAddress, peerMAC, ETH_ALEN)) {
 			/*	Commented by Albert 2011/05/18 */
 			/*	Match the device address located in the P2P IE */
@@ -3271,7 +3271,7 @@ static int rtw_p2p_get_device_type(struct net_device *dev,
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 		if (!memcmp(pnetwork->network.MacAddress, peerMAC, ETH_ALEN)) {
 			u8 *wpsie;
 			uint wpsie_len = 0;
@@ -3350,7 +3350,7 @@ static int rtw_p2p_get_device_name(struct net_device *dev,
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 		if (!memcmp(pnetwork->network.MacAddress, peerMAC, ETH_ALEN)) {
 			u8 *wpsie;
 			uint wpsie_len = 0;
@@ -3421,7 +3421,7 @@ static int rtw_p2p_get_invitation_procedure(struct net_device *dev,
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 		if (!memcmp(pnetwork->network.MacAddress, peerMAC, ETH_ALEN)) {
 			/*	Commented by Albert 20121226 */
 			/*	Match the device address located in the P2P IE */
@@ -3503,7 +3503,7 @@ static int rtw_p2p_connect(struct net_device *dev,
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 		if (!memcmp(pnetwork->network.MacAddress, peerMAC, ETH_ALEN)) {
 			uintPeerChannel = pnetwork->network.Configuration.DSConfig;
 			break;
@@ -3598,7 +3598,7 @@ static int rtw_p2p_invite_req(struct net_device *dev,
 		if (rtw_end_of_queue_search(phead, plist) == true)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 
 		/*	Commented by Albert 2011/05/18 */
 		/*	Match the device address located in the P2P IE */
@@ -3751,7 +3751,7 @@ static int rtw_p2p_prov_disc(struct net_device *dev,
 		if (uintPeerChannel != 0)
 			break;
 
-		pnetwork = LIST_CONTAINOR(plist, struct wlan_network, list);
+		pnetwork = container_of(plist, struct wlan_network, list);
 
 		/*	Commented by Albert 2011/05/18 */
 		/*	Match the device address located in the P2P IE */
@@ -4440,7 +4440,7 @@ static int rtw_dbg_port(struct net_device *dev,
 					plist = get_next(phead);
 
 					while ((rtw_end_of_queue_search(phead, plist)) == false) {
-						psta = LIST_CONTAINOR(plist, struct sta_info, hash_list);
+						psta = container_of(plist, struct sta_info, hash_list);
 
 						plist = get_next(plist);
 
diff --git a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
index 9005971..dda73b3 100644
--- a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
@@ -204,7 +204,7 @@ static int rtw_mlcst2unicst(struct adapter *padapter, struct sk_buff *skb)
 
 	/* free sta asoc_queue */
 	while (!rtw_end_of_queue_search(phead, plist)) {
-		psta = LIST_CONTAINOR(plist, struct sta_info, asoc_list);
+		psta = container_of(plist, struct sta_info, asoc_list);
 
 		plist = get_next(plist);
 
-- 
1.8.4.5
