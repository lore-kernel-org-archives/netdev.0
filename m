From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/6] staging: r8188eu: Remove _func_enter and _func_exit macros
Date: Sun,  9 Feb 2014 15:15:59 -0600
Message-ID: <1391980559-24288-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:57878 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbaBIVQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 16:16:15 -0500
Received: by mail-ob0-f181.google.com with SMTP id va2so6392103obc.40
        for <netdev@vger.kernel.org>; Sun, 09 Feb 2014 13:16:14 -0800 (PST)
In-Reply-To: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These debugging macros are seldom used for debugging once the driver
is working. If routine tracing is needed, it can be added on an
individual basis.

In a few cases, removal of the exit macro left a bare label. In these
cases, a go to that label was replaced by a return.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c          | 112 +--------------
 drivers/staging/rtl8188eu/core/rtw_ieee80211.c    |  13 --
 drivers/staging/rtl8188eu/core/rtw_io.c           |  28 ----
 drivers/staging/rtl8188eu/core/rtw_ioctl_set.c    |  25 ----
 drivers/staging/rtl8188eu/core/rtw_mlme.c         | 158 ++--------------------
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     |   2 -
 drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c     |  78 -----------
 drivers/staging/rtl8188eu/core/rtw_p2p.c          |  18 ---
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c      |  25 ----
 drivers/staging/rtl8188eu/core/rtw_recv.c         |  41 ------
 drivers/staging/rtl8188eu/core/rtw_security.c     |  75 +---------
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      |  28 +---
 drivers/staging/rtl8188eu/core/rtw_wlan_util.c    |   2 -
 drivers/staging/rtl8188eu/core/rtw_xmit.c         |  49 +------
 drivers/staging/rtl8188eu/hal/hal_intf.c          |   4 -
 drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c      |  12 --
 drivers/staging/rtl8188eu/hal/rtl8188e_dm.c       |   2 -
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c |   2 -
 drivers/staging/rtl8188eu/hal/usb_halinit.c       |  10 --
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c     |  23 +---
 drivers/staging/rtl8188eu/include/rtw_debug.h     |  14 --
 drivers/staging/rtl8188eu/include/rtw_ioctl.h     |   2 -
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c    |  58 --------
 drivers/staging/rtl8188eu/os_dep/mlme_linux.c     |   9 +-
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       |   4 -
 drivers/staging/rtl8188eu/os_dep/recv_linux.c     |   3 -
 drivers/staging/rtl8188eu/os_dep/usb_intf.c       |  14 --
 drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c  |   5 -
 drivers/staging/rtl8188eu/os_dep/xmit_linux.c     |   9 --
 29 files changed, 16 insertions(+), 809 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index cc322e5..bc78736 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -36,7 +36,6 @@ int	_rtw_init_cmd_priv (struct	cmd_priv *pcmdpriv)
 {
 	int res = _SUCCESS;
 
-_func_enter_;
 
 	sema_init(&(pcmdpriv->cmd_queue_sema), 0);
 	/* sema_init(&(pcmdpriv->cmd_done_sema), 0); */
@@ -71,7 +70,6 @@ _func_enter_;
 	pcmdpriv->cmd_done_cnt = 0;
 	pcmdpriv->rsp_cnt = 0;
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -81,7 +79,6 @@ int _rtw_init_evt_priv(struct evt_priv *pevtpriv)
 {
 	int res = _SUCCESS;
 
-_func_enter_;
 
 	/* allocate DMA-able/Non-Page memory for cmd_buf and rsp_buf */
 	atomic_set(&pevtpriv->event_seq, 0);
@@ -91,14 +88,12 @@ _func_enter_;
 	pevtpriv->c2h_wk_alive = false;
 	pevtpriv->c2h_queue = rtw_cbuf_alloc(C2H_QUEUE_MAX_LEN+1);
 
-_func_exit_;
 
 	return res;
 }
 
 void rtw_free_evt_priv(struct	evt_priv *pevtpriv)
 {
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_cmd_c_, _drv_info_, ("+rtw_free_evt_priv\n"));
 
@@ -113,12 +108,10 @@ _func_enter_;
 	}
 	RT_TRACE(_module_rtl871x_cmd_c_, _drv_info_, ("-rtw_free_evt_priv\n"));
 
-_func_exit_;
 }
 
 void _rtw_free_cmd_priv (struct	cmd_priv *pcmdpriv)
 {
-_func_enter_;
 
 	if (pcmdpriv) {
 		if (pcmdpriv->cmd_allocated_buf)
@@ -127,7 +120,6 @@ _func_enter_;
 		if (pcmdpriv->rsp_allocated_buf)
 			kfree(pcmdpriv->rsp_allocated_buf);
 	}
-_func_exit_;
 }
 
 /*
@@ -144,7 +136,6 @@ int	_rtw_enqueue_cmd(struct __queue *queue, struct cmd_obj *obj)
 {
 	unsigned long irqL;
 
-_func_enter_;
 
 	if (obj == NULL)
 		goto exit;
@@ -157,7 +148,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -167,7 +157,6 @@ struct	cmd_obj	*_rtw_dequeue_cmd(struct __queue *queue)
 	unsigned long irqL;
 	struct cmd_obj *obj;
 
-_func_enter_;
 
 	spin_lock_irqsave(&queue->lock, irqL);
 	if (rtw_is_list_empty(&(queue->queue))) {
@@ -179,7 +168,6 @@ _func_enter_;
 
 	spin_unlock_irqrestore(&queue->lock, irqL);
 
-_func_exit_;
 
 	return obj;
 }
@@ -187,27 +175,21 @@ _func_exit_;
 u32	rtw_init_cmd_priv(struct cmd_priv *pcmdpriv)
 {
 	u32	res;
-_func_enter_;
 	res = _rtw_init_cmd_priv (pcmdpriv);
-_func_exit_;
 	return res;
 }
 
 u32	rtw_init_evt_priv (struct	evt_priv *pevtpriv)
 {
 	int	res;
-_func_enter_;
 	res = _rtw_init_evt_priv(pevtpriv);
-_func_exit_;
 	return res;
 }
 
 void rtw_free_cmd_priv(struct	cmd_priv *pcmdpriv)
 {
-_func_enter_;
 	RT_TRACE(_module_rtl871x_cmd_c_, _drv_info_, ("rtw_free_cmd_priv\n"));
 	_rtw_free_cmd_priv(pcmdpriv);
-_func_exit_;
 }
 
 static int rtw_cmd_filter(struct cmd_priv *pcmdpriv, struct cmd_obj *cmd_obj)
@@ -238,7 +220,6 @@ u32 rtw_enqueue_cmd(struct cmd_priv *pcmdpriv, struct cmd_obj *cmd_obj)
 	int res = _FAIL;
 	struct adapter *padapter = pcmdpriv->padapter;
 
-_func_enter_;
 
 	if (cmd_obj == NULL)
 		goto exit;
@@ -258,7 +239,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -267,25 +247,20 @@ struct	cmd_obj	*rtw_dequeue_cmd(struct cmd_priv *pcmdpriv)
 {
 	struct cmd_obj *cmd_obj;
 
-_func_enter_;
 
 	cmd_obj = _rtw_dequeue_cmd(&pcmdpriv->cmd_queue);
 
-_func_exit_;
 	return cmd_obj;
 }
 
 void rtw_cmd_clr_isr(struct	cmd_priv *pcmdpriv)
 {
-_func_enter_;
 	pcmdpriv->cmd_done_cnt++;
 	/* up(&(pcmdpriv->cmd_done_sema)); */
-_func_exit_;
 }
 
 void rtw_free_cmd_obj(struct cmd_obj *pcmd)
 {
-_func_enter_;
 
 	if ((pcmd->cmdcode != _JoinBss_CMD_) && (pcmd->cmdcode != _CreateBss_CMD_)) {
 		/* free parmbuf in cmd_obj */
@@ -302,7 +277,6 @@ _func_enter_;
 	/* free cmd_obj */
 	kfree(pcmd);
 
-_func_exit_;
 }
 
 int rtw_cmd_thread(void *context)
@@ -315,7 +289,6 @@ int rtw_cmd_thread(void *context)
 	struct adapter *padapter = (struct adapter *)context;
 	struct cmd_priv *pcmdpriv = &(padapter->cmdpriv);
 
-_func_enter_;
 
 	thread_enter("RTW_CMD_THREAD");
 
@@ -410,7 +383,6 @@ post_process:
 
 	up(&pcmdpriv->terminate_cmdthread_sema);
 
-_func_exit_;
 
 	complete_and_exit(NULL, 0);
 }
@@ -423,7 +395,6 @@ u8 rtw_setstandby_cmd(struct adapter *padapter, uint action)
 
 	u8 ret = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -446,7 +417,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return ret;
 }
@@ -465,7 +435,6 @@ u8 rtw_sitesurvey_cmd(struct adapter  *padapter, struct ndis_802_11_ssid *ssid,
 	struct cmd_priv		*pcmdpriv = &padapter->cmdpriv;
 	struct mlme_priv	*pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 	if (check_fwstate(pmlmepriv, _FW_LINKED) == true) {
 		rtw_lps_ctrl_wk_cmd(padapter, LPS_CTRL_SCAN, 1);
 	}
@@ -537,7 +506,6 @@ _func_enter_;
 		_clr_fwstate_(pmlmepriv, _FW_UNDER_SURVEY);
 	}
 
-_func_exit_;
 
 	return res;
 }
@@ -549,7 +517,6 @@ u8 rtw_setdatarate_cmd(struct adapter *padapter, u8 *rateset)
 	struct cmd_priv *pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -570,7 +537,6 @@ _func_enter_;
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -582,7 +548,6 @@ u8 rtw_setbasicrate_cmd(struct adapter *padapter, u8 *rateset)
 	struct cmd_priv *pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -604,7 +569,6 @@ _func_enter_;
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -624,7 +588,6 @@ u8 rtw_setphy_cmd(struct adapter *padapter, u8 modem, u8 ch)
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -648,7 +611,6 @@ _func_enter_;
 
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -659,7 +621,6 @@ u8 rtw_setbbreg_cmd(struct adapter *padapter, u8 offset, u8 val)
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
 		res = _FAIL;
@@ -680,7 +641,6 @@ _func_enter_;
 
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -691,7 +651,6 @@ u8 rtw_getbbreg_cmd(struct adapter  *padapter, u8 offset, u8 *pval)
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
 		res = _FAIL;
@@ -715,7 +674,6 @@ _func_enter_;
 
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -725,7 +683,6 @@ u8 rtw_setrfreg_cmd(struct adapter  *padapter, u8 offset, u32 val)
 	struct writeRF_parm *pwriterfparm;
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
-_func_enter_;
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
 		res = _FAIL;
@@ -746,7 +703,6 @@ _func_enter_;
 
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -757,7 +713,6 @@ u8 rtw_getrfreg_cmd(struct adapter  *padapter, u8 offset, u8 *pval)
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -785,33 +740,28 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
 
 void rtw_getbbrfreg_cmdrsp_callback(struct adapter *padapter,  struct cmd_obj *pcmd)
 {
- _func_enter_;
 
 	kfree(pcmd->parmbuf);
 	kfree(pcmd);
 
 	if (padapter->registrypriv.mp_mode == 1)
 		padapter->mppriv.workparam.bcompleted = true;
-_func_exit_;
 }
 
 void rtw_readtssi_cmdrsp_callback(struct adapter *padapter,  struct cmd_obj *pcmd)
 {
- _func_enter_;
 
 	kfree(pcmd->parmbuf);
 	kfree(pcmd);
 
 	if (padapter->registrypriv.mp_mode == 1)
 		padapter->mppriv.workparam.bcompleted = true;
-_func_exit_;
 }
 
 u8 rtw_createbss_cmd(struct adapter  *padapter)
@@ -822,7 +772,6 @@ u8 rtw_createbss_cmd(struct adapter  *padapter)
 	struct wlan_bssid_ex *pdev_network = &padapter->registrypriv.dev_network;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	rtw_led_control(padapter, LED_CTL_START_TO_LINK);
 
@@ -847,7 +796,6 @@ _func_enter_;
 	res = rtw_enqueue_cmd(pcmdpriv, pcmd);
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -858,7 +806,6 @@ u8 rtw_createbss_cmd_ex(struct adapter  *padapter, unsigned char *pbss, unsigned
 	struct cmd_priv *pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	pcmd = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (pcmd == NULL) {
@@ -877,7 +824,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -898,7 +844,6 @@ u8 rtw_joinbss_cmd(struct adapter  *padapter, struct wlan_network *pnetwork)
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 
-_func_enter_;
 
 	rtw_led_control(padapter, LED_CTL_START_TO_LINK);
 
@@ -1020,7 +965,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1032,7 +976,6 @@ u8 rtw_disassoc_cmd(struct adapter *padapter, u32 deauth_timeout_ms, bool enqueu
 	struct cmd_priv *cmdpriv = &padapter->cmdpriv;
 	u8 res = _SUCCESS;
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_cmd_c_, _drv_notice_, ("+rtw_disassoc_cmd\n"));
 
@@ -1063,7 +1006,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1076,7 +1018,6 @@ u8 rtw_setopmode_cmd(struct adapter  *padapter, enum ndis_802_11_network_infra n
 	struct	cmd_priv   *pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -1098,7 +1039,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1115,7 +1055,6 @@ u8 rtw_setstakey_cmd(struct adapter *padapter, u8 *psta, u8 unicast_key)
 	struct sta_info *sta = (struct sta_info *)psta;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -1161,7 +1100,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1175,7 +1113,6 @@ u8 rtw_clearstakey_cmd(struct adapter *padapter, u8 *psta, u8 entry, u8 enqueue)
 	struct sta_info *sta = (struct sta_info *)psta;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	if (!enqueue) {
 		clear_cam_entry(padapter, entry);
@@ -1215,7 +1152,6 @@ _func_enter_;
 	}
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1226,7 +1162,6 @@ u8 rtw_setrttbl_cmd(struct adapter  *padapter, struct setratable_parm *prate_tab
 	struct setratable_parm *psetrttblparm;
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -1247,7 +1182,6 @@ _func_enter_;
 
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -1257,7 +1191,6 @@ u8 rtw_getrttbl_cmd(struct adapter  *padapter, struct getratable_rsp *pval)
 	struct getratable_parm *pgetrttblparm;
 	struct cmd_priv *pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -1285,7 +1218,6 @@ _func_enter_;
 
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -1298,7 +1230,6 @@ u8 rtw_setassocsta_cmd(struct adapter  *padapter, u8 *mac_addr)
 
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -1330,7 +1261,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
  }
@@ -1342,7 +1272,6 @@ u8 rtw_addbareq_cmd(struct adapter *padapter, u8 tid, u8 *addr)
 	struct addBaReq_parm *paddbareq_parm;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -1369,7 +1298,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1381,7 +1309,6 @@ u8 rtw_dynamic_chk_wk_cmd(struct adapter *padapter)
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -1406,7 +1333,6 @@ _func_enter_;
 	/* rtw_enqueue_cmd(pcmdpriv, ph2c); */
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -1418,7 +1344,6 @@ u8 rtw_set_ch_cmd(struct adapter *padapter, u8 ch, u8 bw, u8 ch_offset, u8 enque
 
 	u8 res = _SUCCESS;
 
-_func_enter_;
 
 	DBG_88E(FUNC_NDEV_FMT" ch:%u, bw:%u, ch_offset:%u\n",
 		FUNC_NDEV_ARG(padapter->pnetdev), ch, bw, ch_offset);
@@ -1460,7 +1385,6 @@ exit:
 
 	DBG_88E(FUNC_NDEV_FMT" res:%u\n", FUNC_NDEV_ARG(padapter->pnetdev), res);
 
-_func_exit_;
 
 	return res;
 }
@@ -1473,7 +1397,6 @@ u8 rtw_set_chplan_cmd(struct adapter *padapter, u8 chplan, u8 enqueue)
 
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_cmd_c_, _drv_notice_, ("+rtw_set_chplan_cmd\n"));
 
@@ -1516,7 +1439,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1529,7 +1451,6 @@ u8 rtw_led_blink_cmd(struct adapter *padapter, struct LED_871x *pLed)
 
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_cmd_c_, _drv_notice_, ("+rtw_led_blink_cmd\n"));
 
@@ -1553,7 +1474,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1566,7 +1486,6 @@ u8 rtw_set_csa_cmd(struct adapter *padapter, u8 new_ch_no)
 
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_cmd_c_, _drv_notice_, ("+rtw_set_csa_cmd\n"));
 
@@ -1590,7 +1509,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1685,7 +1603,6 @@ static void lps_ctrl_wk_hdl(struct adapter *padapter, u8 lps_ctrl_type)
 	struct mlme_priv *pmlmepriv = &(padapter->mlmepriv);
 	u8	mstatus;
 
-_func_enter_;
 
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE) == true) ||
 	    (check_fwstate(pmlmepriv, WIFI_ADHOC_STATE) == true))
@@ -1724,7 +1641,6 @@ _func_enter_;
 		break;
 	}
 
-_func_exit_;
 }
 
 u8 rtw_lps_ctrl_wk_cmd(struct adapter *padapter, u8 lps_ctrl_type, u8 enqueue)
@@ -1735,7 +1651,6 @@ u8 rtw_lps_ctrl_wk_cmd(struct adapter *padapter, u8 lps_ctrl_type, u8 enqueue)
 	/* struct pwrctrl_priv *pwrctrlpriv = &padapter->pwrctrlpriv; */
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	/* if (!pwrctrlpriv->bLeisurePs) */
 	/* 	return res; */
@@ -1767,7 +1682,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1785,7 +1699,6 @@ u8 rtw_rpt_timer_cfg_cmd(struct adapter *padapter, u16 min_time)
 
 	u8	res = _SUCCESS;
 
-_func_enter_;
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
 		res = _FAIL;
@@ -1806,7 +1719,6 @@ _func_enter_;
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1824,7 +1736,6 @@ u8 rtw_antenna_select_cmd(struct adapter *padapter, u8 antenna, u8 enqueue)
 	u8	support_ant_div;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 	rtw_hal_get_def_var(padapter, HAL_DEF_IS_SUPPORT_ANT_DIV, &support_ant_div);
 	if (!support_ant_div)
 		return res;
@@ -1854,7 +1765,6 @@ _func_enter_;
 	}
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1873,7 +1783,6 @@ u8 p2p_protocol_wk_cmd(struct adapter *padapter, int intCmdType)
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE))
 		return res;
@@ -1901,7 +1810,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1914,7 +1822,6 @@ u8 rtw_ps_cmd(struct adapter *padapter)
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 
 	u8	res = _SUCCESS;
-_func_enter_;
 
 	ppscmd = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ppscmd == NULL) {
@@ -1937,7 +1844,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -2174,7 +2080,6 @@ void rtw_survey_cmd_callback(struct adapter *padapter,  struct cmd_obj *pcmd)
 {
 	struct	mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 
 	if (pcmd->res == H2C_DROPPED) {
 		/* TODO: cancel timer and do timeout handler directly... */
@@ -2188,13 +2093,11 @@ _func_enter_;
 	/*  free cmd */
 	rtw_free_cmd_obj(pcmd);
 
-_func_exit_;
 }
 void rtw_disassoc_cmd_callback(struct adapter *padapter, struct cmd_obj *pcmd)
 {
 	struct	mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 
 	if (pcmd->res != H2C_SUCCESS) {
 		spin_lock_bh(&pmlmepriv->lock);
@@ -2202,24 +2105,18 @@ _func_enter_;
 		spin_unlock_bh(&pmlmepriv->lock);
 
 		RT_TRACE(_module_rtl871x_cmd_c_, _drv_err_, ("\n ***Error: disconnect_cmd_callback Fail ***\n."));
-
-		goto exit;
+		return;
 	} else /* clear bridge database */
 		nat25_db_cleanup(padapter);
 
 	/*  free cmd */
 	rtw_free_cmd_obj(pcmd);
-
-exit:
-
-_func_exit_;
 }
 
 void rtw_joinbss_cmd_callback(struct adapter *padapter,  struct cmd_obj *pcmd)
 {
 	struct	mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 
 	if (pcmd->res == H2C_DROPPED) {
 		/* TODO: cancel timer and do timeout handler directly... */
@@ -2232,7 +2129,6 @@ _func_enter_;
 
 	rtw_free_cmd_obj(pcmd);
 
-_func_exit_;
 }
 
 void rtw_createbss_cmd_callback(struct adapter *padapter, struct cmd_obj *pcmd)
@@ -2244,7 +2140,6 @@ void rtw_createbss_cmd_callback(struct adapter *padapter, struct cmd_obj *pcmd)
 	struct wlan_bssid_ex *pnetwork = (struct wlan_bssid_ex *)pcmd->parmbuf;
 	struct wlan_network *tgt_network = &(pmlmepriv->cur_network);
 
-_func_enter_;
 
 	if ((pcmd->res != H2C_SUCCESS)) {
 		RT_TRACE(_module_rtl871x_cmd_c_, _drv_err_, ("\n ********Error: rtw_createbss_cmd_callback  Fail ************\n\n."));
@@ -2298,7 +2193,6 @@ createbss_cmd_fail:
 
 	rtw_free_cmd_obj(pcmd);
 
-_func_exit_;
 }
 
 void rtw_setstaKey_cmdrsp_callback(struct adapter *padapter,  struct cmd_obj *pcmd)
@@ -2307,7 +2201,6 @@ void rtw_setstaKey_cmdrsp_callback(struct adapter *padapter,  struct cmd_obj *pc
 	struct set_stakey_rsp *psetstakey_rsp = (struct set_stakey_rsp *)(pcmd->rsp);
 	struct sta_info *psta = rtw_get_stainfo(pstapriv, psetstakey_rsp->addr);
 
-_func_enter_;
 
 	if (psta == NULL) {
 		RT_TRACE(_module_rtl871x_cmd_c_, _drv_err_, ("\nERROR: rtw_setstaKey_cmdrsp_callback => can't get sta_info\n\n"));
@@ -2315,7 +2208,6 @@ _func_enter_;
 	}
 exit:
 	rtw_free_cmd_obj(pcmd);
-_func_exit_;
 }
 
 void rtw_setassocsta_cmdrsp_callback(struct adapter *padapter,  struct cmd_obj *pcmd)
@@ -2326,7 +2218,6 @@ void rtw_setassocsta_cmdrsp_callback(struct adapter *padapter,  struct cmd_obj *
 	struct set_assocsta_rsp *passocsta_rsp = (struct set_assocsta_rsp *)(pcmd->rsp);
 	struct sta_info *psta = rtw_get_stainfo(pstapriv, passocsta_parm->addr);
 
-_func_enter_;
 
 	if (psta == NULL) {
 		RT_TRACE(_module_rtl871x_cmd_c_, _drv_err_, ("\nERROR: setassocsta_cmdrsp_callbac => can't get sta_info\n\n"));
@@ -2347,5 +2238,4 @@ _func_enter_;
 exit:
 	rtw_free_cmd_obj(pcmd);
 
-_func_exit_;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_ieee80211.c b/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
index 002195a..d779c80 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
@@ -147,7 +147,6 @@ u8 *rtw_set_ie
 	uint *frlen /* frame length */
 )
 {
-_func_enter_;
 	*pbuf = (u8)index;
 
 	*(pbuf + 1) = (u8)len;
@@ -157,7 +156,6 @@ _func_enter_;
 
 	*frlen = *frlen + (len + 2);
 
-_func_exit_;
 	return pbuf + len + 2;
 }
 
@@ -221,9 +219,7 @@ u8 *rtw_get_ie(u8 *pbuf, int index, int *len, int limit)
 {
 	int tmp, i;
 	u8 *p;
-_func_enter_;
 	if (limit < 1) {
-		_func_exit_;
 		return NULL;
 	}
 
@@ -242,7 +238,6 @@ _func_enter_;
 		if (i >= limit)
 			break;
 	}
-_func_exit_;
 	return NULL;
 }
 
@@ -339,7 +334,6 @@ exit:
 
 void rtw_set_supported_rate(u8 *SupportedRates, uint mode)
 {
-_func_enter_;
 
 	_rtw_memset(SupportedRates, 0, NDIS_802_11_LENGTH_RATES_EX);
 
@@ -361,13 +355,11 @@ _func_enter_;
 		memcpy(SupportedRates + IEEE80211_CCK_RATE_LEN, WIFI_OFDMRATES, IEEE80211_NUM_OFDM_RATESLEN);
 		break;
 	}
-_func_exit_;
 }
 
 uint	rtw_get_rateset_len(u8	*rateset)
 {
 	uint i = 0;
-_func_enter_;
 	while (1) {
 		if ((rateset[i]) == 0)
 			break;
@@ -375,7 +367,6 @@ _func_enter_;
 			break;
 		i++;
 	}
-_func_exit_;
 	return i;
 }
 
@@ -386,7 +377,6 @@ int rtw_generate_ie(struct registry_priv *pregistrypriv)
 	struct wlan_bssid_ex *pdev_network = &pregistrypriv->dev_network;
 	u8 *ie = pdev_network->IEs;
 
-_func_enter_;
 
 	/* timestamp will be inserted by hardware */
 	sz += 8;
@@ -444,7 +434,6 @@ _func_enter_;
 
 	if (rateLen > 8)
 		ie = rtw_set_ie(ie, _EXT_SUPPORTEDRATES_IE_, (rateLen - 8), (pdev_network->SupportedRates + 8), &sz);
-_func_exit_;
 
 	return sz;
 }
@@ -672,7 +661,6 @@ int rtw_get_sec_ie(u8 *in_ie, uint in_len, u8 *rsn_ie, u16 *rsn_len, u8 *wpa_ie,
 	u8 wpa_oui[4] = {0x0, 0x50, 0xf2, 0x01};
 	uint	cnt;
 
-_func_enter_;
 
 	/* Search required WPA or WPA2 IE and copy to sec_ie[] */
 
@@ -726,7 +714,6 @@ _func_enter_;
 		}
 	}
 
-_func_exit_;
 
 	return *rsn_len + *wpa_len;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_io.c b/drivers/staging/rtl8188eu/core/rtw_io.c
index ff0398f..7530532 100644
--- a/drivers/staging/rtl8188eu/core/rtw_io.c
+++ b/drivers/staging/rtl8188eu/core/rtw_io.c
@@ -59,10 +59,8 @@ u8 _rtw_read8(struct adapter *adapter, u32 addr)
 	struct	intf_hdl *pintfhdl = &(pio_priv->intf);
 	u8 (*_read8)(struct intf_hdl *pintfhdl, u32 addr);
 
-	_func_enter_;
 	_read8 = pintfhdl->io_ops._read8;
 	r_val = _read8(pintfhdl, addr);
-	_func_exit_;
 	return r_val;
 }
 
@@ -72,11 +70,9 @@ u16 _rtw_read16(struct adapter *adapter, u32 addr)
 	struct io_priv *pio_priv = &adapter->iopriv;
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 	u16 (*_read16)(struct intf_hdl *pintfhdl, u32 addr);
-_func_enter_;
 	_read16 = pintfhdl->io_ops._read16;
 
 	r_val = _read16(pintfhdl, addr);
-_func_exit_;
 	return r_val;
 }
 
@@ -86,11 +82,9 @@ u32 _rtw_read32(struct adapter *adapter, u32 addr)
 	struct io_priv *pio_priv = &adapter->iopriv;
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 	u32	(*_read32)(struct intf_hdl *pintfhdl, u32 addr);
-_func_enter_;
 	_read32 = pintfhdl->io_ops._read32;
 
 	r_val = _read32(pintfhdl, addr);
-_func_exit_;
 	return r_val;
 }
 
@@ -100,11 +94,9 @@ int _rtw_write8(struct adapter *adapter, u32 addr, u8 val)
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 	int (*_write8)(struct intf_hdl *pintfhdl, u32 addr, u8 val);
 	int ret;
-	_func_enter_;
 	_write8 = pintfhdl->io_ops._write8;
 
 	ret = _write8(pintfhdl, addr, val);
-	_func_exit_;
 
 	return RTW_STATUS_CODE(ret);
 }
@@ -115,11 +107,9 @@ int _rtw_write16(struct adapter *adapter, u32 addr, u16 val)
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 	int (*_write16)(struct intf_hdl *pintfhdl, u32 addr, u16 val);
 	int ret;
-	_func_enter_;
 	_write16 = pintfhdl->io_ops._write16;
 
 	ret = _write16(pintfhdl, addr, val);
-	_func_exit_;
 
 	return RTW_STATUS_CODE(ret);
 }
@@ -129,11 +119,9 @@ int _rtw_write32(struct adapter *adapter, u32 addr, u32 val)
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 	int (*_write32)(struct intf_hdl *pintfhdl, u32 addr, u32 val);
 	int ret;
-	_func_enter_;
 	_write32 = pintfhdl->io_ops._write32;
 
 	ret = _write32(pintfhdl, addr, val);
-	_func_exit_;
 
 	return RTW_STATUS_CODE(ret);
 }
@@ -144,11 +132,9 @@ int _rtw_writeN(struct adapter *adapter, u32 addr , u32 length , u8 *pdata)
 	struct	intf_hdl *pintfhdl = (struct intf_hdl *)(&(pio_priv->intf));
 	int (*_writeN)(struct intf_hdl *pintfhdl, u32 addr, u32 length, u8 *pdata);
 	int ret;
-	_func_enter_;
 	_writeN = pintfhdl->io_ops._writeN;
 
 	ret = _writeN(pintfhdl, addr, length, pdata);
-	_func_exit_;
 
 	return RTW_STATUS_CODE(ret);
 }
@@ -158,11 +144,9 @@ int _rtw_write8_async(struct adapter *adapter, u32 addr, u8 val)
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 	int (*_write8_async)(struct intf_hdl *pintfhdl, u32 addr, u8 val);
 	int ret;
-	_func_enter_;
 	_write8_async = pintfhdl->io_ops._write8_async;
 
 	ret = _write8_async(pintfhdl, addr, val);
-	_func_exit_;
 
 	return RTW_STATUS_CODE(ret);
 }
@@ -174,10 +158,8 @@ int _rtw_write16_async(struct adapter *adapter, u32 addr, u16 val)
 	int (*_write16_async)(struct intf_hdl *pintfhdl, u32 addr, u16 val);
 	int ret;
 
-_func_enter_;
 	_write16_async = pintfhdl->io_ops._write16_async;
 	ret = _write16_async(pintfhdl, addr, val);
-_func_exit_;
 
 	return RTW_STATUS_CODE(ret);
 }
@@ -189,10 +171,8 @@ int _rtw_write32_async(struct adapter *adapter, u32 addr, u32 val)
 	int (*_write32_async)(struct intf_hdl *pintfhdl, u32 addr, u32 val);
 	int ret;
 
-_func_enter_;
 	_write32_async = pintfhdl->io_ops._write32_async;
 	ret = _write32_async(pintfhdl, addr, val);
-_func_exit_;
 
 	return RTW_STATUS_CODE(ret);
 }
@@ -203,7 +183,6 @@ void _rtw_read_mem(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 	struct io_priv *pio_priv = &adapter->iopriv;
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 
-	_func_enter_;
 	if (adapter->bDriverStopped || adapter->bSurpriseRemoved) {
 		RT_TRACE(_module_rtl871x_io_c_, _drv_info_,
 			 ("rtw_read_mem:bDriverStopped(%d) OR bSurpriseRemoved(%d)",
@@ -212,7 +191,6 @@ void _rtw_read_mem(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 	}
 	_read_mem = pintfhdl->io_ops._read_mem;
 	_read_mem(pintfhdl, addr, cnt, pmem);
-	_func_exit_;
 }
 
 void _rtw_write_mem(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
@@ -221,13 +199,11 @@ void _rtw_write_mem(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 	struct io_priv *pio_priv = &adapter->iopriv;
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 
-	_func_enter_;
 
 	_write_mem = pintfhdl->io_ops._write_mem;
 
 	_write_mem(pintfhdl, addr, cnt, pmem);
 
-	_func_exit_;
 }
 
 void _rtw_read_port(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
@@ -236,7 +212,6 @@ void _rtw_read_port(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 	struct io_priv *pio_priv = &adapter->iopriv;
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 
-	_func_enter_;
 
 	if (adapter->bDriverStopped || adapter->bSurpriseRemoved) {
 		RT_TRACE(_module_rtl871x_io_c_, _drv_info_,
@@ -249,7 +224,6 @@ void _rtw_read_port(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 
 	_read_port(pintfhdl, addr, cnt, pmem);
 
-	_func_exit_;
 }
 
 void _rtw_read_port_cancel(struct adapter *adapter)
@@ -271,13 +245,11 @@ u32 _rtw_write_port(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem)
 	struct	intf_hdl		*pintfhdl = &(pio_priv->intf);
 	u32 ret = _SUCCESS;
 
-	_func_enter_;
 
 	_write_port = pintfhdl->io_ops._write_port;
 
 	ret = _write_port(pintfhdl, addr, cnt, pmem);
 
-	 _func_exit_;
 
 	return ret;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
index 0f0f515..807b7d4 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
@@ -42,7 +42,6 @@ u8 rtw_validate_ssid(struct ndis_802_11_ssid *ssid)
 	u8	 i;
 	u8	ret = true;
 
-_func_enter_;
 
 	if (ssid->SsidLength > 32) {
 		RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_err_, ("ssid length >32\n"));
@@ -61,8 +60,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
-
 	return ret;
 }
 
@@ -74,7 +71,6 @@ u8 rtw_do_join(struct adapter *padapter)
 	struct __queue *queue	= &(pmlmepriv->scanned_queue);
 	u8 ret = _SUCCESS;
 
-_func_enter_;
 
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 	phead = get_list_head(queue);
@@ -170,7 +166,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return ret;
 }
@@ -181,7 +176,6 @@ u8 rtw_set_802_11_bssid(struct adapter *padapter, u8 *bssid)
 	u32 cur_time = 0;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 
 	DBG_88E_LEVEL(_drv_info_, "set bssid:%pM\n", bssid);
 
@@ -257,7 +251,6 @@ exit:
 	RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_err_,
 		 ("rtw_set_802_11_bssid: status=%d\n", status));
 
-_func_exit_;
 
 	return status;
 }
@@ -270,7 +263,6 @@ u8 rtw_set_802_11_ssid(struct adapter *padapter, struct ndis_802_11_ssid *ssid)
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct wlan_network *pnetwork = &pmlmepriv->cur_network;
 
-_func_enter_;
 
 	DBG_88E_LEVEL(_drv_info_, "set ssid [%s] fw_state=0x%08x\n",
 		      ssid->Ssid, get_fwstate(pmlmepriv));
@@ -369,7 +361,6 @@ release_mlme_lock:
 exit:
 	RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_err_,
 		 ("-rtw_set_802_11_ssid: status =%d\n", status));
-_func_exit_;
 	return status;
 }
 
@@ -380,7 +371,6 @@ u8 rtw_set_802_11_infrastructure_mode(struct adapter *padapter,
 	struct	wlan_network	*cur_network = &pmlmepriv->cur_network;
 	enum ndis_802_11_network_infra *pold_state = &(cur_network->network.InfrastructureMode);
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_notice_,
 		 ("+rtw_set_802_11_infrastructure_mode: old =%d new =%d fw_state = 0x%08x\n",
@@ -438,7 +428,6 @@ _func_enter_;
 		spin_unlock_bh(&pmlmepriv->lock);
 	}
 
-_func_exit_;
 
 	return true;
 }
@@ -448,7 +437,6 @@ u8 rtw_set_802_11_disassociate(struct adapter *padapter)
 {
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 
 	spin_lock_bh(&pmlmepriv->lock);
 
@@ -464,7 +452,6 @@ _func_enter_;
 
 	spin_unlock_bh(&pmlmepriv->lock);
 
-_func_exit_;
 
 	return true;
 }
@@ -474,7 +461,6 @@ u8 rtw_set_802_11_bssid_list_scan(struct adapter *padapter, struct ndis_802_11_s
 	struct	mlme_priv		*pmlmepriv = &padapter->mlmepriv;
 	u8	res = true;
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_err_, ("+rtw_set_802_11_bssid_list_scan(), fw_state =%x\n", get_fwstate(pmlmepriv)));
 
@@ -514,7 +500,6 @@ _func_enter_;
 	}
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -525,7 +510,6 @@ u8 rtw_set_802_11_authentication_mode(struct adapter *padapter, enum ndis_802_11
 	int res;
 	u8 ret;
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_info_, ("set_802_11_auth.mode(): mode =%x\n", authmode));
 
@@ -545,7 +529,6 @@ _func_enter_;
 	else
 		ret = false;
 
-_func_exit_;
 
 	return ret;
 }
@@ -556,7 +539,6 @@ u8 rtw_set_802_11_add_wep(struct adapter *padapter, struct ndis_802_11_wep *wep)
 	struct security_priv *psecuritypriv = &(padapter->securitypriv);
 	u8		ret = _SUCCESS;
 
-_func_enter_;
 
 	keyid = wep->KeyIndex & 0x3fffffff;
 
@@ -611,7 +593,6 @@ _func_enter_;
 	if (res == _FAIL)
 		ret = false;
 exit:
-_func_exit_;
 	return ret;
 }
 
@@ -619,7 +600,6 @@ u8 rtw_set_802_11_remove_wep(struct adapter *padapter, u32 keyindex)
 {
 	u8 ret = _SUCCESS;
 
-_func_enter_;
 	if (keyindex >= 0x80000000 || padapter == NULL) {
 		ret = false;
 		goto exit;
@@ -638,7 +618,6 @@ _func_enter_;
 	}
 exit:
 
-_func_exit_;
 	return ret;
 }
 
@@ -651,7 +630,6 @@ u8 rtw_set_802_11_add_key(struct adapter *padapter, struct ndis_802_11_key *key)
 	u8	bgrouptkey = false;/* can be removed later */
 	u8	ret = _SUCCESS;
 
-_func_enter_;
 
 	if (((key->KeyIndex & 0x80000000) == 0) && ((key->KeyIndex & 0x40000000) > 0)) {
 		/*  It is invalid to clear bit 31 and set bit 30. If the miniport driver encounters this combination, */
@@ -992,7 +970,6 @@ _func_enter_;
 	}
 exit:
 
-_func_exit_;
 	return ret;
 }
 
@@ -1004,7 +981,6 @@ u8 rtw_set_802_11_remove_key(struct adapter *padapter, struct ndis_802_11_remove
 	u8	keyIndex = (u8)key->KeyIndex & 0x03;
 	u8	ret = _SUCCESS;
 
-_func_enter_;
 
 	if ((key->KeyIndex & 0xbffffffc) > 0) {
 		ret = _FAIL;
@@ -1032,7 +1008,6 @@ _func_enter_;
 	}
 exit:
 
-_func_exit_;
 	return ret;
 }
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 700a34d..260da41 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -44,8 +44,6 @@ int	_rtw_init_mlme_priv (struct adapter *padapter)
 	struct mlme_priv		*pmlmepriv = &padapter->mlmepriv;
 	int	res = _SUCCESS;
 
-_func_enter_;
-
 	/*  We don't need to memset padapter->XXX to zero, because adapter is allocated by vzalloc(). */
 
 	pmlmepriv->nic_hdl = (u8 *)padapter;
@@ -88,9 +86,6 @@ _func_enter_;
 	rtw_init_mlme_timer(padapter);
 
 exit:
-
-_func_exit_;
-
 	return res;
 }
 
@@ -125,21 +120,16 @@ void rtw_free_mlme_priv_ie_data(struct mlme_priv *pmlmepriv)
 
 void _rtw_free_mlme_priv (struct mlme_priv *pmlmepriv)
 {
-_func_enter_;
-
 	rtw_free_mlme_priv_ie_data(pmlmepriv);
 
 	if (pmlmepriv) {
 		if (pmlmepriv->free_bss_buf)
 			vfree(pmlmepriv->free_bss_buf);
 	}
-_func_exit_;
 }
 
 int	_rtw_enqueue_network(struct __queue *queue, struct wlan_network *pnetwork)
 {
-_func_enter_;
-
 	if (pnetwork == NULL)
 		goto exit;
 
@@ -150,9 +140,6 @@ _func_enter_;
 	spin_unlock_bh(&queue->lock);
 
 exit:
-
-_func_exit_;
-
 	return _SUCCESS;
 }
 
@@ -160,8 +147,6 @@ struct	wlan_network *_rtw_dequeue_network(struct __queue *queue)
 {
 	struct wlan_network *pnetwork;
 
-_func_enter_;
-
 	spin_lock_bh(&queue->lock);
 
 	if (_rtw_queue_empty(queue)) {
@@ -174,8 +159,6 @@ _func_enter_;
 
 	spin_unlock_bh(&queue->lock);
 
-_func_exit_;
-
 	return pnetwork;
 }
 
@@ -185,8 +168,6 @@ struct	wlan_network *_rtw_alloc_network(struct	mlme_priv *pmlmepriv)/* _queue *f
 	struct __queue *free_queue = &pmlmepriv->free_bss_pool;
 	struct list_head *plist = NULL;
 
-_func_enter_;
-
 	spin_lock_bh(&free_queue->lock);
 
 	if (_rtw_queue_empty(free_queue) == true) {
@@ -211,8 +192,6 @@ _func_enter_;
 exit:
 	spin_unlock_bh(&free_queue->lock);
 
-_func_exit_;
-
 	return pnetwork;
 }
 
@@ -222,13 +201,11 @@ void _rtw_free_network(struct	mlme_priv *pmlmepriv , struct wlan_network *pnetwo
 	u32 lifetime = SCANQUEUE_LIFETIME;
 	struct __queue *free_queue = &(pmlmepriv->free_bss_pool);
 
-_func_enter_;
-
 	if (pnetwork == NULL)
-		goto exit;
+		return;
 
 	if (pnetwork->fixed)
-		goto exit;
+		return;
 	curr_time = jiffies;
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) ||
 	    (check_fwstate(pmlmepriv, WIFI_ADHOC_STATE)))
@@ -236,33 +213,26 @@ _func_enter_;
 	if (!isfreeall) {
 		delta_time = (curr_time - pnetwork->last_scanned)/HZ;
 		if (delta_time < lifetime)/*  unit:sec */
-			goto exit;
+			return;
 	}
 	spin_lock_bh(&free_queue->lock);
 	rtw_list_delete(&(pnetwork->list));
 	rtw_list_insert_tail(&(pnetwork->list), &(free_queue->queue));
 	pmlmepriv->num_of_scanned--;
 	spin_unlock_bh(&free_queue->lock);
-
-exit:
-_func_exit_;
 }
 
 void _rtw_free_network_nolock(struct	mlme_priv *pmlmepriv, struct wlan_network *pnetwork)
 {
 	struct __queue *free_queue = &(pmlmepriv->free_bss_pool);
 
-_func_enter_;
 	if (pnetwork == NULL)
-		goto exit;
+		return;
 	if (pnetwork->fixed)
-		goto exit;
+		return;
 	rtw_list_delete(&(pnetwork->list));
 	rtw_list_insert_tail(&(pnetwork->list), get_list_head(free_queue));
 	pmlmepriv->num_of_scanned--;
-exit:
-
-_func_exit_;
 }
 
 /*
@@ -276,7 +246,6 @@ struct wlan_network *_rtw_find_network(struct __queue *scanned_queue, u8 *addr)
 	struct	wlan_network *pnetwork = NULL;
 	u8 zero_addr[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
 
-_func_enter_;
 	if (!memcmp(zero_addr, addr, ETH_ALEN)) {
 		pnetwork = NULL;
 		goto exit;
@@ -293,7 +262,6 @@ _func_enter_;
 	if (plist == phead)
 		pnetwork = NULL;
 exit:
-_func_exit_;
 	return pnetwork;
 }
 
@@ -305,9 +273,6 @@ void _rtw_free_network_queue(struct adapter *padapter, u8 isfreeall)
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct __queue *scanned_queue = &pmlmepriv->scanned_queue;
 
-_func_enter_;
-
-
 	spin_lock_bh(&scanned_queue->lock);
 
 	phead = get_list_head(scanned_queue);
@@ -321,13 +286,11 @@ _func_enter_;
 		_rtw_free_network(pmlmepriv, pnetwork, isfreeall);
 	}
 	spin_unlock_bh(&scanned_queue->lock);
-_func_exit_;
 }
 
 int rtw_if_up(struct adapter *padapter)
 {
 	int res;
-_func_enter_;
 
 	if (padapter->bDriverStopped || padapter->bSurpriseRemoved ||
 	    (check_fwstate(&padapter->mlmepriv, _FW_LINKED) == false)) {
@@ -338,8 +301,6 @@ _func_enter_;
 	} else {
 		res =  true;
 	}
-
-_func_exit_;
 	return res;
 }
 
@@ -347,14 +308,12 @@ void rtw_generate_random_ibss(u8 *pibss)
 {
 	u32	curtime = jiffies;
 
-_func_enter_;
 	pibss[0] = 0x02;  /* in ad-hoc mode bit1 must set to 1 */
 	pibss[1] = 0x11;
 	pibss[2] = 0x87;
 	pibss[3] = (u8)(curtime & 0xff);/* p[0]; */
 	pibss[4] = (u8)((curtime>>8) & 0xff);/* p[1]; */
 	pibss[5] = (u8)((curtime>>16) & 0xff);/* p[2]; */
-_func_exit_;
 	return;
 }
 
@@ -367,11 +326,9 @@ u8 *rtw_get_capability_from_ie(u8 *ie)
 u16 rtw_get_capability(struct wlan_bssid_ex *bss)
 {
 	__le16	val;
-_func_enter_;
 
 	memcpy((u8 *)&val, rtw_get_capability_from_ie(bss->IEs), 2);
 
-_func_exit_;
 	return le16_to_cpu(val);
 }
 
@@ -388,43 +345,31 @@ u8 *rtw_get_beacon_interval_from_ie(u8 *ie)
 int	rtw_init_mlme_priv (struct adapter *padapter)/* struct	mlme_priv *pmlmepriv) */
 {
 	int	res;
-_func_enter_;
 	res = _rtw_init_mlme_priv(padapter);/*  (pmlmepriv); */
-_func_exit_;
 	return res;
 }
 
 void rtw_free_mlme_priv (struct mlme_priv *pmlmepriv)
 {
-_func_enter_;
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("rtw_free_mlme_priv\n"));
 	_rtw_free_mlme_priv (pmlmepriv);
-_func_exit_;
 }
 
 static struct wlan_network *rtw_alloc_network(struct mlme_priv *pmlmepriv)
 {
-	struct	wlan_network	*pnetwork;
-_func_enter_;
-	pnetwork = _rtw_alloc_network(pmlmepriv);
-_func_exit_;
-	return pnetwork;
+	return _rtw_alloc_network(pmlmepriv);
 }
 
 static void rtw_free_network_nolock(struct mlme_priv *pmlmepriv,
 				    struct wlan_network *pnetwork)
 {
-_func_enter_;
 	_rtw_free_network_nolock(pmlmepriv, pnetwork);
-_func_exit_;
 }
 
 
 void rtw_free_network_queue(struct adapter *dev, u8 isfreeall)
 {
-_func_enter_;
 	_rtw_free_network_queue(dev, isfreeall);
-_func_exit_;
 }
 
 /*
@@ -466,7 +411,6 @@ int is_same_network(struct wlan_bssid_ex *src, struct wlan_bssid_ex *dst)
 	 u16 s_cap, d_cap;
 	__le16 le_scap, le_dcap;
 
-_func_enter_;
 	memcpy((u8 *)&le_scap, rtw_get_capability_from_ie(src->IEs), 2);
 	memcpy((u8 *)&le_dcap, rtw_get_capability_from_ie(dst->IEs), 2);
 
@@ -474,8 +418,6 @@ _func_enter_;
 	s_cap = le16_to_cpu(le_scap);
 	d_cap = le16_to_cpu(le_dcap);
 
-_func_exit_;
-
 	return ((src->Ssid.SsidLength == dst->Ssid.SsidLength) &&
 		((!memcmp(src->MacAddress, dst->MacAddress, ETH_ALEN)) == true) &&
 		((!memcmp(src->Ssid.Ssid, dst->Ssid.Ssid, src->Ssid.SsidLength)) == true) &&
@@ -491,7 +433,6 @@ struct	wlan_network	*rtw_get_oldest_wlan_network(struct __queue *scanned_queue)
 	struct	wlan_network	*pwlan = NULL;
 	struct	wlan_network	*oldest = NULL;
 
-_func_enter_;
 	phead = get_list_head(scanned_queue);
 
 	plist = phead->next;
@@ -509,7 +450,6 @@ _func_enter_;
 
 		plist = plist->next;
 	}
-_func_exit_;
 	return oldest;
 }
 
@@ -522,7 +462,6 @@ void update_network(struct wlan_bssid_ex *dst, struct wlan_bssid_ex *src,
 	u8 sq_final;
 	long rssi_final;
 
-_func_enter_;
 	rtw_hal_antdiv_rssi_compared(padapter, dst, src); /* this will update src.Rssi, need consider again */
 
 	/* The rule below is 1/5 for sample value, 4/5 for history value */
@@ -553,22 +492,18 @@ _func_enter_;
 	dst->PhyInfo.SignalQuality = sq_final;
 	dst->Rssi = rssi_final;
 
-_func_exit_;
 }
 
 static void update_current_network(struct adapter *adapter, struct wlan_bssid_ex *pnetwork)
 {
 	struct	mlme_priv	*pmlmepriv = &(adapter->mlmepriv);
 
-_func_enter_;
-
 	if ((check_fwstate(pmlmepriv, _FW_LINKED) == true) &&
 	    (is_same_network(&(pmlmepriv->cur_network.network), pnetwork))) {
 		update_network(&(pmlmepriv->cur_network.network), pnetwork, adapter, true);
 		rtw_update_protection(adapter, (pmlmepriv->cur_network.network.IEs) + sizeof(struct ndis_802_11_fixed_ie),
 				      pmlmepriv->cur_network.network.IELength);
 	}
-_func_exit_;
 }
 
 /*
@@ -583,8 +518,6 @@ void rtw_update_scanned_network(struct adapter *adapter, struct wlan_bssid_ex *t
 	struct wlan_network	*pnetwork = NULL;
 	struct wlan_network	*oldest = NULL;
 
-_func_enter_;
-
 	spin_lock_bh(&queue->lock);
 	phead = get_list_head(queue);
 	plist = phead->next;
@@ -663,19 +596,16 @@ _func_enter_;
 exit:
 	spin_unlock_bh(&queue->lock);
 
-_func_exit_;
 }
 
 static void rtw_add_network(struct adapter *adapter,
 			    struct wlan_bssid_ex *pnetwork)
 {
-_func_enter_;
 #if defined(CONFIG_88EU_P2P)
 	rtw_wlan_bssid_ex_remove_p2p_attr(pnetwork, P2P_ATTR_GROUP_INFO);
 #endif
 	update_current_network(adapter, pnetwork);
 	rtw_update_scanned_network(adapter, pnetwork);
-_func_exit_;
 }
 
 /* select the desired network based on the capability of the (i)bss. */
@@ -728,9 +658,7 @@ static int rtw_is_desired_network(struct adapter *adapter, struct wlan_network *
 /* TODO: Perry: For Power Management */
 void rtw_atimdone_event_callback(struct adapter	*adapter , u8 *pbuf)
 {
-_func_enter_;
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("receive atimdone_evet\n"));
-_func_exit_;
 	return;
 }
 
@@ -741,8 +669,6 @@ void rtw_survey_event_callback(struct adapter	*adapter, u8 *pbuf)
 	struct wlan_bssid_ex *pnetwork;
 	struct	mlme_priv	*pmlmepriv = &(adapter->mlmepriv);
 
-_func_enter_;
-
 	pnetwork = (struct wlan_bssid_ex *)pbuf;
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("rtw_survey_event_callback, ssid=%s\n",  pnetwork->Ssid.Ssid));
@@ -781,20 +707,14 @@ _func_enter_;
 exit:
 
 	spin_unlock_bh(&pmlmepriv->lock);
-
-_func_exit_;
-
 	return;
 }
 
-
-
 void rtw_surveydone_event_callback(struct adapter	*adapter, u8 *pbuf)
 {
 	struct	mlme_priv *pmlmepriv = &(adapter->mlmepriv);
 	struct mlme_ext_priv *pmlmeext;
 
-_func_enter_;
 	spin_lock_bh(&pmlmepriv->lock);
 
 	if (pmlmepriv->wps_probe_req_ie) {
@@ -884,7 +804,6 @@ _func_enter_;
 	pmlmeext = &adapter->mlmeextpriv;
 	if (pmlmeext->sitesurvey_res.bss_cnt == 0)
 		rtw_hal_sreset_reset(adapter);
-_func_exit_;
 }
 
 void rtw_dummy_event_callback(struct adapter *adapter , u8 *pbuf)
@@ -901,8 +820,6 @@ static void free_scanqueue(struct	mlme_priv *pmlmepriv)
 	struct __queue *scan_queue = &pmlmepriv->scanned_queue;
 	struct list_head *plist, *phead, *ptemp;
 
-_func_enter_;
-
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_notice_, ("+free_scanqueue\n"));
 	spin_lock_bh(&scan_queue->lock);
 	spin_lock_bh(&free_queue->lock);
@@ -920,8 +837,6 @@ _func_enter_;
 
 	spin_unlock_bh(&free_queue->lock);
 	spin_unlock_bh(&scan_queue->lock);
-
-_func_exit_;
 }
 
 /*
@@ -934,8 +849,6 @@ void rtw_free_assoc_resources(struct adapter *adapter, int lock_scanned_queue)
 	struct	sta_priv *pstapriv = &adapter->stapriv;
 	struct wlan_network *tgt_network = &pmlmepriv->cur_network;
 
-_func_enter_;
-
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_notice_, ("+rtw_free_assoc_resources\n"));
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_,
 		 ("tgt_network->network.MacAddress=%pM ssid=%s\n",
@@ -979,7 +892,6 @@ _func_enter_;
 	if (lock_scanned_queue)
 		spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 	pmlmepriv->key_mask = 0;
-_func_exit_;
 }
 
 /*
@@ -989,8 +901,6 @@ void rtw_indicate_connect(struct adapter *padapter)
 {
 	struct mlme_priv	*pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
-
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("+rtw_indicate_connect\n"));
 
 	pmlmepriv->to_join = false;
@@ -1008,7 +918,6 @@ _func_enter_;
 	rtw_set_scan_deny(padapter, 3000);
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("-rtw_indicate_connect: fw_state=0x%08x\n", get_fwstate(pmlmepriv)));
-_func_exit_;
 }
 
 /*
@@ -1018,7 +927,6 @@ void rtw_indicate_disconnect(struct adapter *padapter)
 {
 	struct	mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("+rtw_indicate_disconnect\n"));
 
 	_clr_fwstate_(pmlmepriv, _FW_UNDER_LINKING | WIFI_UNDER_WPS);
@@ -1038,8 +946,6 @@ _func_enter_;
 	p2p_ps_wk_cmd(padapter, P2P_PS_DISABLE, 1);
 
 	rtw_lps_ctrl_wk_cmd(padapter, LPS_CTRL_DISCONNECT, 1);
-
-_func_exit_;
 }
 
 inline void rtw_indicate_scan_done(struct adapter *padapter, bool aborted)
@@ -1206,8 +1112,6 @@ void rtw_joinbss_event_prehandle(struct adapter *adapter, u8 *pbuf)
 	struct wlan_network	*pcur_wlan = NULL, *ptarget_wlan = NULL;
 	unsigned int		the_same_macaddr = false;
 
-_func_enter_;
-
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("joinbss event call back received with res=%d\n", pnetwork->join_res));
 
 	rtw_get_encrypt_decrypt_from_registrypriv(adapter);
@@ -1223,7 +1127,7 @@ _func_enter_;
 	pnetwork->network.Length = get_wlan_bssid_ex_sz(&pnetwork->network);
 	if (pnetwork->network.Length > sizeof(struct wlan_bssid_ex)) {
 		RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("\n\n ***joinbss_evt_callback return a wrong bss ***\n\n"));
-		goto ignore_nolock;
+		return;
 	}
 
 	spin_lock_bh(&pmlmepriv->lock);
@@ -1319,21 +1223,15 @@ _func_enter_;
 
 ignore_joinbss_callback:
 	spin_unlock_bh(&pmlmepriv->lock);
-ignore_nolock:
-_func_exit_;
 }
 
 void rtw_joinbss_event_callback(struct adapter *adapter, u8 *pbuf)
 {
 	struct wlan_network	*pnetwork	= (struct wlan_network *)pbuf;
 
-_func_enter_;
-
 	mlmeext_joinbss_event_callback(adapter, pnetwork->join_res);
 
 	rtw_os_xmit_schedule(adapter);
-
-_func_exit_;
 }
 
 static u8 search_max_mac_id(struct adapter *padapter)
@@ -1388,8 +1286,6 @@ void rtw_stassoc_event_callback(struct adapter *adapter, u8 *pbuf)
 	struct wlan_network	*cur_network = &(pmlmepriv->cur_network);
 	struct wlan_network	*ptarget_wlan = NULL;
 
-_func_enter_;
-
 	if (rtw_access_ctrl(adapter, pstassoc->macaddr) == false)
 		return;
 
@@ -1400,7 +1296,7 @@ _func_enter_;
 			ap_sta_info_defer_update(adapter, psta);
 			rtw_stassoc_hw_rpt(adapter, psta);
 		}
-		goto exit;
+		return;
 	}
 #endif
 	/* for AD-HOC mode */
@@ -1408,12 +1304,12 @@ _func_enter_;
 	if (psta != NULL) {
 		/* the sta have been in sta_info_queue => do nothing */
 		RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("Error: rtw_stassoc_event_callback: sta has been in sta_hash_queue\n"));
-		goto exit; /* between drv has received this event before and  fw have not yet to set key to CAM_ENTRY) */
+		return; /* between drv has received this event before and  fw have not yet to set key to CAM_ENTRY) */
 	}
 	psta = rtw_alloc_stainfo(&adapter->stapriv, pstassoc->macaddr);
 	if (psta == NULL) {
 		RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("Can't alloc sta_info when rtw_stassoc_event_callback\n"));
-		goto exit;
+		return;
 	}
 	/* to do: init sta_info variable */
 	psta->qos_option = 0;
@@ -1440,8 +1336,6 @@ _func_enter_;
 	}
 	spin_unlock_bh(&pmlmepriv->lock);
 	mlmeext_sta_add_event_callback(adapter, psta);
-exit:
-_func_exit_;
 }
 
 void rtw_stadel_event_callback(struct adapter *adapter, u8 *pbuf)
@@ -1456,8 +1350,6 @@ void rtw_stadel_event_callback(struct adapter *adapter, u8 *pbuf)
 	struct	sta_priv *pstapriv = &adapter->stapriv;
 	struct wlan_network *tgt_network = &(pmlmepriv->cur_network);
 
-_func_enter_;
-
 	psta = rtw_get_stainfo(&adapter->stapriv, pstadel->macaddr);
 	if (psta)
 		mac_id = psta->mac_id;
@@ -1541,14 +1433,11 @@ _func_enter_;
 		}
 	}
 	spin_unlock_bh(&pmlmepriv->lock);
-_func_exit_;
 }
 
 void rtw_cpwm_event_callback(struct adapter *padapter, u8 *pbuf)
 {
-_func_enter_;
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("+rtw_cpwm_event_callback !!!\n"));
-_func_exit_;
 }
 
 /*
@@ -1560,8 +1449,6 @@ void _rtw_join_timeout_handler (struct adapter *adapter)
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
 	int do_join_r;
 
-_func_enter_;
-
 	DBG_88E("%s, fw_state=%x\n", __func__, get_fwstate(pmlmepriv));
 
 	if (adapter->bDriverStopped || adapter->bSurpriseRemoved)
@@ -1592,7 +1479,6 @@ _func_enter_;
 		free_scanqueue(pmlmepriv);/*  */
 	}
 	spin_unlock_bh(&pmlmepriv->lock);
-_func_exit_;
 }
 
 /*
@@ -1742,8 +1628,6 @@ int rtw_select_and_join_from_scanned_queue(struct mlme_priv *pmlmepriv)
 	struct	wlan_network	*candidate = NULL;
 	u8	supp_ant_div = false;
 
-_func_enter_;
-
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 	phead = get_list_head(queue);
 	adapter = (struct adapter *)pmlmepriv->nic_hdl;
@@ -1792,9 +1676,6 @@ _func_enter_;
 
 exit:
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
-
-_func_exit_;
-
 	return ret;
 }
 
@@ -1805,8 +1686,6 @@ int rtw_set_auth(struct adapter *adapter, struct security_priv *psecuritypriv)
 	struct	cmd_priv *pcmdpriv = &(adapter->cmdpriv);
 	int		res = _SUCCESS;
 
-_func_enter_;
-
 	pcmd = (struct	cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (pcmd == NULL) {
 		res = _FAIL;  /* try again */
@@ -1832,7 +1711,6 @@ _func_enter_;
 		 psecuritypriv->dot11AuthAlgrthm));
 	res = rtw_enqueue_cmd(pcmdpriv, pcmd);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -1845,7 +1723,6 @@ int rtw_set_key(struct adapter *adapter, struct security_priv *psecuritypriv, in
 	struct mlme_priv		*pmlmepriv = &(adapter->mlmepriv);
 	int	res = _SUCCESS;
 
-_func_enter_;
 	pcmd = (struct	cmd_obj *)rtw_zmalloc(sizeof(struct	cmd_obj));
 	if (pcmd == NULL) {
 		res = _FAIL;  /* try again */
@@ -1914,7 +1791,6 @@ _func_enter_;
 	_rtw_init_listhead(&pcmd->list);
 	res = rtw_enqueue_cmd(pcmdpriv, pcmd);
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -2018,8 +1894,6 @@ int rtw_restruct_sec_ie(struct adapter *adapter, u8 *in_ie, u8 *out_ie, uint in_
 	uint	ndisauthmode = psecuritypriv->ndisauthtype;
 	uint ndissecuritytype = psecuritypriv->ndisencryptstatus;
 
-_func_enter_;
-
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_notice_,
 		 ("+rtw_restruct_sec_ie: ndisauthmode=%d ndissecuritytype=%d\n",
 		  ndisauthmode, ndissecuritytype));
@@ -2052,9 +1926,6 @@ _func_enter_;
 		if (authmode == _WPA2_IE_ID_)
 			ielength = rtw_append_pmkid(adapter, iEntry, out_ie, ielength);
 	}
-
-_func_exit_;
-
 	return ielength;
 }
 
@@ -2065,8 +1936,6 @@ void rtw_init_registrypriv_dev_network(struct adapter *adapter)
 	struct wlan_bssid_ex    *pdev_network = &pregistrypriv->dev_network;
 	u8 *myhwaddr = myid(peepriv);
 
-_func_enter_;
-
 	memcpy(pdev_network->MacAddress, myhwaddr, ETH_ALEN);
 
 	memcpy(&pdev_network->Ssid, &pregistrypriv->ssid, sizeof(struct ndis_802_11_ssid));
@@ -2077,8 +1946,6 @@ _func_enter_;
 	pdev_network->Configuration.FHConfig.HopPattern = 0;
 	pdev_network->Configuration.FHConfig.HopSet = 0;
 	pdev_network->Configuration.FHConfig.DwellTime = 0;
-
-_func_exit_;
 }
 
 void rtw_update_registrypriv_dev_network(struct adapter *adapter)
@@ -2089,8 +1956,6 @@ void rtw_update_registrypriv_dev_network(struct adapter *adapter)
 	struct	security_priv *psecuritypriv = &adapter->securitypriv;
 	struct	wlan_network	*cur_network = &adapter->mlmepriv.cur_network;
 
-_func_enter_;
-
 	pdev_network->Privacy = (psecuritypriv->dot11PrivacyAlgrthm > 0 ? 1 : 0); /*  adhoc no 802.1x */
 
 	pdev_network->Rssi = 0;
@@ -2140,13 +2005,10 @@ _func_enter_;
 
 	/* notes: translate IELength & Length after assign the Length to cmdsz in createbss_cmd(); */
 	/* pdev_network->IELength = cpu_to_le32(sz); */
-_func_exit_;
 }
 
 void rtw_get_encrypt_decrypt_from_registrypriv(struct adapter *adapter)
 {
-_func_enter_;
-_func_exit_;
 }
 
 /* the function is at passive_level */
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 2c5d704..b84610f 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -8265,7 +8265,6 @@ u8 set_tx_beacon_cmd(struct adapter *padapter)
 	u8 res = _SUCCESS;
 	int len_diff = 0;
 
-_func_enter_;
 
 	ph2c = (struct cmd_obj *)rtw_zmalloc(sizeof(struct cmd_obj));
 	if (ph2c == NULL) {
@@ -8294,7 +8293,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c b/drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c
index edcd8a5..e783968 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c
@@ -33,7 +33,6 @@ int rtl8188eu_oid_rt_wireless_mode_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->information_buf_len < sizeof(u8))
 		return NDIS_STATUS_INVALID_LENGTH;
@@ -48,7 +47,6 @@ _func_enter_;
 		status = NDIS_STATUS_NOT_ACCEPTED;
 	}
 
-_func_exit_;
 
 	return status;
 }
@@ -61,7 +59,6 @@ int rtl8188eu_oid_rt_pro_write_bb_reg_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_write_bb_reg_hdl\n"));
 
@@ -87,7 +84,6 @@ _func_enter_;
 	write_bbreg(Adapter, offset, 0xFFFFFFFF, value);
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -100,7 +96,6 @@ int rtl8188eu_oid_rt_pro_read_bb_reg_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_read_bb_reg_hdl\n"));
 
@@ -126,7 +121,6 @@ _func_enter_;
 	RT_TRACE(_module_mp_, _drv_notice_,
 		 ("-rtl8188eu_oid_rt_pro_read_bb_reg_hdl: offset=0x%03X value:0x%08X\n",
 		  offset, value));
-_func_exit_;
 
 	return status;
 }
@@ -140,7 +134,6 @@ int rtl8188eu_oid_rt_pro_write_rf_reg_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_write_rf_reg_hdl\n"));
 
@@ -171,7 +164,6 @@ _func_enter_;
 	write_rfreg(Adapter, path, offset, value);
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -185,7 +177,6 @@ int rtl8188eu_oid_rt_pro_read_rf_reg_hdl(struct oid_par_priv *poid_par_priv)
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 	int status = NDIS_STATUS_SUCCESS;
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_read_rf_reg_hdl\n"));
 
@@ -217,7 +208,6 @@ _func_enter_;
 		 ("-rtl8188eu_oid_rt_pro_read_rf_reg_hdl: path=%d offset=0x%02X value=0x%05X\n",
 		  path, offset, value));
 
-_func_exit_;
 
 	return status;
 }
@@ -232,7 +222,6 @@ int rtl8188eu_oid_rt_pro_set_data_rate_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_,
 		 ("+rtl8188eu_oid_rt_pro_set_data_rate_hdl\n"));
@@ -255,7 +244,6 @@ _func_enter_;
 	SetDataRate(Adapter);
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -266,7 +254,6 @@ int rtl8188eu_oid_rt_pro_start_test_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_start_test_hdl\n"));
 
@@ -293,7 +280,6 @@ exit:
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("-rtl8188eu_oid_rt_pro_start_test_hdl: mp_mode=%d\n", Adapter->mppriv.mode));
 
-_func_exit_;
 
 	return status;
 }
@@ -303,7 +289,6 @@ int rtl8188eu_oid_rt_pro_stop_test_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+Set OID_RT_PRO_STOP_TEST\n"));
 
@@ -316,7 +301,6 @@ _func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("-Set OID_RT_PRO_STOP_TEST\n"));
 
-_func_exit_;
 
 	return status;
 }
@@ -327,7 +311,6 @@ int rtl8188eu_oid_rt_pro_set_channel_direct_call_hdl(struct oid_par_priv *poid_p
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_set_channel_direct_call_hdl\n"));
 
@@ -352,7 +335,6 @@ _func_enter_;
 	SetChannel(Adapter);
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -364,7 +346,6 @@ int rtl8188eu_oid_rt_set_bandwidth_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *padapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_info_,
 		 ("+rtl8188eu_oid_rt_set_bandwidth_hdl\n"));
@@ -391,7 +372,6 @@ _func_enter_;
 		 ("-rtl8188eu_oid_rt_set_bandwidth_hdl: bandwidth=%d channel_offset=%d\n",
 		  bandwidth, channel_offset));
 
-_func_exit_;
 
 	return status;
 }
@@ -402,7 +382,6 @@ int rtl8188eu_oid_rt_pro_set_antenna_bb_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_set_antenna_bb_hdl\n"));
 
@@ -426,7 +405,6 @@ _func_enter_;
 		*(u32 *)poid_par_priv->information_buf = antenna;
 	}
 
-_func_exit_;
 
 	return status;
 }
@@ -437,7 +415,6 @@ int rtl8188eu_oid_rt_pro_set_tx_power_control_hdl(struct oid_par_priv *poid_par_
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_info_, ("+rtl8188eu_oid_rt_pro_set_tx_power_control_hdl\n"));
 
@@ -461,7 +438,6 @@ _func_enter_;
 	SetTxPower(Adapter);
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -474,7 +450,6 @@ int rtl8188eu_oid_rt_pro_query_tx_packet_sent_hdl(struct oid_par_priv *poid_par_
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID) {
 		status = NDIS_STATUS_NOT_ACCEPTED;
@@ -488,7 +463,6 @@ _func_enter_;
 		status = NDIS_STATUS_INVALID_LENGTH;
 	}
 
-_func_exit_;
 
 	return status;
 }
@@ -498,7 +472,6 @@ int rtl8188eu_oid_rt_pro_query_rx_packet_received_hdl(struct oid_par_priv *poid_
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID) {
 		status = NDIS_STATUS_NOT_ACCEPTED;
@@ -513,7 +486,6 @@ _func_enter_;
 		status = NDIS_STATUS_INVALID_LENGTH;
 	}
 
-_func_exit_;
 
 	return status;
 }
@@ -523,7 +495,6 @@ int rtl8188eu_oid_rt_pro_query_rx_packet_crc32_error_hdl(struct oid_par_priv *po
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID) {
 		status = NDIS_STATUS_NOT_ACCEPTED;
@@ -538,7 +509,6 @@ _func_enter_;
 		status = NDIS_STATUS_INVALID_LENGTH;
 	}
 
-_func_exit_;
 
 	return status;
 }
@@ -549,7 +519,6 @@ int rtl8188eu_oid_rt_pro_reset_tx_packet_sent_hdl(struct oid_par_priv *poid_par_
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != SET_OID) {
 		status = NDIS_STATUS_NOT_ACCEPTED;
@@ -559,7 +528,6 @@ _func_enter_;
 	RT_TRACE(_module_mp_, _drv_alert_, ("===> rtl8188eu_oid_rt_pro_reset_tx_packet_sent_hdl.\n"));
 	Adapter->mppriv.tx_pktcount = 0;
 
-_func_exit_;
 
 	return status;
 }
@@ -569,7 +537,6 @@ int rtl8188eu_oid_rt_pro_reset_rx_packet_received_hdl(struct oid_par_priv *poid_
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != SET_OID) {
 		status = NDIS_STATUS_NOT_ACCEPTED;
@@ -583,7 +550,6 @@ _func_enter_;
 		status = NDIS_STATUS_INVALID_LENGTH;
 	}
 
-_func_exit_;
 
 	return status;
 }
@@ -593,7 +559,6 @@ int rtl8188eu_oid_rt_reset_phy_rx_packet_count_hdl(struct oid_par_priv *poid_par
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != SET_OID) {
 		status = NDIS_STATUS_NOT_ACCEPTED;
@@ -604,7 +569,6 @@ _func_enter_;
 	ResetPhyRxPktCount(Adapter);
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -614,7 +578,6 @@ int rtl8188eu_oid_rt_get_phy_rx_packet_received_hdl(struct oid_par_priv *poid_pa
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_info_, ("+rtl8188eu_oid_rt_get_phy_rx_packet_received_hdl\n"));
 
@@ -632,7 +595,6 @@ _func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("-rtl8188eu_oid_rt_get_phy_rx_packet_received_hdl: recv_ok=%d\n", *(u32 *)poid_par_priv->information_buf));
 
-_func_exit_;
 
 	return status;
 }
@@ -642,7 +604,6 @@ int rtl8188eu_oid_rt_get_phy_rx_packet_crc32_error_hdl(struct oid_par_priv *poid
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_info_, ("+rtl8188eu_oid_rt_get_phy_rx_packet_crc32_error_hdl\n"));
 
@@ -663,7 +624,6 @@ _func_enter_;
 		 ("-rtl8188eu_oid_rt_get_phy_rx_packet_crc32_error_hdl: recv_err =%d\n",
 		 *(u32 *)poid_par_priv->information_buf));
 
-_func_exit_;
 
 	return status;
 }
@@ -674,7 +634,6 @@ int rtl8188eu_oid_rt_pro_set_continuous_tx_hdl(struct oid_par_priv *poid_par_pri
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_set_continuous_tx_hdl\n"));
 
@@ -698,7 +657,6 @@ _func_enter_;
 	}
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -709,7 +667,6 @@ int rtl8188eu_oid_rt_pro_set_single_carrier_tx_hdl(struct oid_par_priv *poid_par
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_alert_, ("+rtl8188eu_oid_rt_pro_set_single_carrier_tx_hdl\n"));
 
@@ -733,7 +690,6 @@ _func_enter_;
 	}
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -744,7 +700,6 @@ int rtl8188eu_oid_rt_pro_set_carrier_suppression_tx_hdl(struct oid_par_priv *poi
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_set_carrier_suppression_tx_hdl\n"));
 
@@ -768,7 +723,6 @@ _func_enter_;
 	}
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -779,7 +733,6 @@ int rtl8188eu_oid_rt_pro_set_single_tone_tx_hdl(struct oid_par_priv *poid_par_pr
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_alert_, ("+rtl8188eu_oid_rt_pro_set_single_tone_tx_hdl\n"));
 
@@ -792,7 +745,6 @@ _func_enter_;
 	SetSingleToneTx(Adapter, (u8)bStartTest);
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -806,7 +758,6 @@ int rtl8188eu_oid_rt_pro_trigger_gpio_hdl(struct oid_par_priv *poid_par_priv)
 {
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 	int status = NDIS_STATUS_SUCCESS;
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != SET_OID)
 		return NDIS_STATUS_NOT_ACCEPTED;
@@ -815,7 +766,6 @@ _func_enter_;
 	rtw_hal_set_hwreg(Adapter, HW_VAR_TRIGGER_GPIO_0, NULL);
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -833,7 +783,6 @@ int rtl8188eu_oid_rt_pro_read_register_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_info_,
 		 ("+rtl8188eu_oid_rt_pro_read_register_hdl\n"));
@@ -870,7 +819,6 @@ _func_enter_;
 
 	*poid_par_priv->bytes_rw = width;
 
-_func_exit_;
 
 	return status;
 }
@@ -882,7 +830,6 @@ int rtl8188eu_oid_rt_pro_write_register_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *padapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_info_,
 		 ("+rtl8188eu_oid_rt_pro_write_register_hdl\n"));
@@ -929,7 +876,6 @@ _func_enter_;
 		 ("-rtl8188eu_oid_rt_pro_write_register_hdl: offset=0x%08X width=%d value=0x%X\n",
 		  offset, width, value));
 
-_func_exit_;
 
 	return status;
 }
@@ -1002,7 +948,6 @@ int rtl8188eu_oid_rt_pro_set_data_rate_ex_hdl(struct oid_par_priv *poid_par_priv
 
 	int status = NDIS_STATUS_SUCCESS;
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+OID_RT_PRO_SET_DATA_RATE_EX\n"));
 
@@ -1016,7 +961,6 @@ _func_enter_;
 
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -1027,7 +971,6 @@ int rtl8188eu_oid_rt_get_thermal_meter_hdl(struct oid_par_priv *poid_par_priv)
 	u8 thermal = 0;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_get_thermal_meter_hdl\n"));
 
@@ -1044,7 +987,6 @@ _func_enter_;
 	*(u32 *)poid_par_priv->information_buf = (u32)thermal;
 	*poid_par_priv->bytes_rw = sizeof(u32);
 
-_func_exit_;
 
 	return status;
 }
@@ -1060,7 +1002,6 @@ int rtl8188eu_oid_rt_pro_set_power_tracking_hdl(struct oid_par_priv *poid_par_pr
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
 
-_func_enter_;
 
 	if (poid_par_priv->information_buf_len < sizeof(u8))
 		return NDIS_STATUS_INVALID_LENGTH;
@@ -1079,7 +1020,6 @@ _func_enter_;
 	}
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -1143,7 +1083,6 @@ int rtl8188eu_oid_rt_pro_read_efuse_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return NDIS_STATUS_NOT_ACCEPTED;
@@ -1176,7 +1115,6 @@ _func_enter_;
 	}
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -1190,7 +1128,6 @@ int rtl8188eu_oid_rt_pro_write_efuse_hdl(struct oid_par_priv *poid_par_priv)
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != SET_OID)
 		return NDIS_STATUS_NOT_ACCEPTED;
@@ -1216,7 +1153,6 @@ _func_enter_;
 		status = NDIS_STATUS_FAILURE;
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
@@ -1227,7 +1163,6 @@ int rtl8188eu_oid_rt_pro_rw_efuse_pgpkt_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	*poid_par_priv->bytes_rw = 0;
 
@@ -1267,7 +1202,6 @@ _func_enter_;
 	RT_TRACE(_module_mp_, _drv_info_,
 		 ("-rtl8188eu_oid_rt_pro_rw_efuse_pgpkt_hdl: status=0x%08X\n", status));
 
-_func_exit_;
 
 	return status;
 }
@@ -1279,7 +1213,6 @@ int rtl8188eu_oid_rt_get_efuse_current_size_hdl(struct oid_par_priv *poid_par_pr
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return NDIS_STATUS_NOT_ACCEPTED;
@@ -1296,7 +1229,6 @@ _func_enter_;
 	} else {
 		status = NDIS_STATUS_FAILURE;
 	}
-_func_exit_;
 
 	return status;
 }
@@ -1306,7 +1238,6 @@ int rtl8188eu_oid_rt_get_efuse_max_size_hdl(struct oid_par_priv *poid_par_priv)
 	int status = NDIS_STATUS_SUCCESS;
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return NDIS_STATUS_NOT_ACCEPTED;
@@ -1321,7 +1252,6 @@ _func_enter_;
 		 ("-rtl8188eu_oid_rt_get_efuse_max_size_hdl: size=%d status=0x%08X\n",
 		  *(int *)poid_par_priv->information_buf, status));
 
-_func_exit_;
 
 	return status;
 }
@@ -1330,7 +1260,6 @@ int rtl8188eu_oid_rt_pro_efuse_hdl(struct oid_par_priv *poid_par_priv)
 {
 	int status;
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_info_, ("+rtl8188eu_oid_rt_pro_efuse_hdl\n"));
 
@@ -1341,7 +1270,6 @@ _func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_info_, ("-rtl8188eu_oid_rt_pro_efuse_hdl: status=0x%08X\n", status));
 
-_func_exit_;
 
 	return status;
 }
@@ -1353,7 +1281,6 @@ int rtl8188eu_oid_rt_pro_efuse_map_hdl(struct oid_par_priv *poid_par_priv)
 	struct adapter *Adapter = (struct adapter *)(poid_par_priv->adapter_context);
 	u16	maplen = 0;
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_pro_efuse_map_hdl\n"));
 
@@ -1398,7 +1325,6 @@ _func_enter_;
 	RT_TRACE(_module_mp_, _drv_info_,
 		 ("-rtl8188eu_oid_rt_pro_efuse_map_hdl: status=0x%08X\n", status));
 
-_func_exit_;
 
 	return status;
 }
@@ -1414,7 +1340,6 @@ int rtl8188eu_oid_rt_set_rx_packet_type_hdl(struct oid_par_priv *poid_par_priv)
 	u8		rx_pkt_type;
 	int status = NDIS_STATUS_SUCCESS;
 
-_func_enter_;
 
 	RT_TRACE(_module_mp_, _drv_notice_, ("+rtl8188eu_oid_rt_set_rx_packet_type_hdl\n"));
 
@@ -1427,7 +1352,6 @@ _func_enter_;
 	rx_pkt_type = *((u8 *)poid_par_priv->information_buf);/* 4 */
 
 	RT_TRACE(_module_mp_, _drv_info_, ("rx_pkt_type: %x\n", rx_pkt_type));
-_func_exit_;
 
 	return status;
 }
@@ -1482,7 +1406,6 @@ int rtl8188eu_oid_rt_set_power_down_hdl(struct oid_par_priv *poid_par_priv)
 {
 	int status = NDIS_STATUS_SUCCESS;
 
-_func_enter_;
 
 	if (poid_par_priv->type_of_oid != SET_OID) {
 		status = NDIS_STATUS_NOT_ACCEPTED;
@@ -1497,7 +1420,6 @@ _func_enter_;
 	/* CALL  the power_down function */
 	_irqlevel_changed_(&oldirql, RAISE);
 
-_func_exit_;
 
 	return status;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index 4670eb3..9425c49 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -1498,7 +1498,6 @@ static void find_phase_handler(struct adapter *padapter)
 	struct ndis_802_11_ssid	ssid;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 
 	_rtw_memset((unsigned char *)&ssid, 0, sizeof(struct ndis_802_11_ssid));
 	memcpy(ssid.Ssid, pwdinfo->p2p_wildcard_ssid, P2P_WILDCARD_SSID_LEN);
@@ -1509,7 +1508,6 @@ _func_enter_;
         spin_lock_bh(&pmlmepriv->lock);
         rtw_sitesurvey_cmd(padapter, &ssid, 1, NULL, 0);
         spin_unlock_bh(&pmlmepriv->lock);
-_func_exit_;
 }
 
 void p2p_concurrent_handler(struct adapter *padapter);
@@ -1518,7 +1516,6 @@ static void restore_p2p_state_handler(struct adapter *padapter)
 {
 	struct wifidirect_info  *pwdinfo = &padapter->wdinfo;
 
-_func_enter_;
 	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_GONEGO_ING) || rtw_p2p_chk_state(pwdinfo, P2P_STATE_GONEGO_FAIL))
 		rtw_p2p_set_role(pwdinfo, P2P_ROLE_DEVICE);
 	rtw_p2p_set_state(pwdinfo, rtw_p2p_pre_state(pwdinfo));
@@ -1528,54 +1525,46 @@ _func_enter_;
 		/*	because this P2P client should stay at the operating channel of P2P GO. */
 		set_channel_bwmode(padapter, pwdinfo->listen_channel, HAL_PRIME_CHNL_OFFSET_DONT_CARE, HT_CHANNEL_WIDTH_20);
 	}
-_func_exit_;
 }
 
 static void pre_tx_invitereq_handler(struct adapter *padapter)
 {
 	struct wifidirect_info  *pwdinfo = &padapter->wdinfo;
 	u8	val8 = 1;
-_func_enter_;
 
 	set_channel_bwmode(padapter, pwdinfo->invitereq_info.peer_ch, HAL_PRIME_CHNL_OFFSET_DONT_CARE, HT_CHANNEL_WIDTH_20);
 	padapter->HalFunc.SetHwRegHandler(padapter, HW_VAR_MLME_SITESURVEY, (u8 *)(&val8));
 	issue_probereq_p2p(padapter, NULL);
 	_set_timer(&pwdinfo->pre_tx_scan_timer, P2P_TX_PRESCAN_TIMEOUT);
 
-_func_exit_;
 }
 
 static void pre_tx_provdisc_handler(struct adapter *padapter)
 {
 	struct wifidirect_info  *pwdinfo = &padapter->wdinfo;
 	u8	val8 = 1;
-_func_enter_;
 
 	set_channel_bwmode(padapter, pwdinfo->tx_prov_disc_info.peer_channel_num[0], HAL_PRIME_CHNL_OFFSET_DONT_CARE, HT_CHANNEL_WIDTH_20);
 	rtw_hal_set_hwreg(padapter, HW_VAR_MLME_SITESURVEY, (u8 *)(&val8));
 	issue_probereq_p2p(padapter, NULL);
 	_set_timer(&pwdinfo->pre_tx_scan_timer, P2P_TX_PRESCAN_TIMEOUT);
 
-_func_exit_;
 }
 
 static void pre_tx_negoreq_handler(struct adapter *padapter)
 {
 	struct wifidirect_info  *pwdinfo = &padapter->wdinfo;
 	u8	val8 = 1;
-_func_enter_;
 
 	set_channel_bwmode(padapter, pwdinfo->nego_req_info.peer_channel_num[0], HAL_PRIME_CHNL_OFFSET_DONT_CARE, HT_CHANNEL_WIDTH_20);
 	rtw_hal_set_hwreg(padapter, HW_VAR_MLME_SITESURVEY, (u8 *)(&val8));
 	issue_probereq_p2p(padapter, NULL);
 	_set_timer(&pwdinfo->pre_tx_scan_timer, P2P_TX_PRESCAN_TIMEOUT);
 
-_func_exit_;
 }
 
 void p2p_protocol_wk_hdl(struct adapter *padapter, int intCmdType)
 {
-_func_enter_;
 	switch (intCmdType) {
 	case P2P_FIND_PHASE_WK:
 		find_phase_handler(padapter);
@@ -1594,7 +1583,6 @@ _func_enter_;
 		break;
 	}
 
-_func_exit_;
 }
 
 void process_p2p_ps_ie(struct adapter *padapter, u8 *IEs, u32 IELength)
@@ -1610,7 +1598,6 @@ void process_p2p_ps_ie(struct adapter *padapter, u8 *IEs, u32 IELength)
 	u8	find_p2p = false, find_p2p_ps = false;
 	u8	noa_offset, noa_num, noa_index;
 
-_func_enter_;
 
 	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE))
 		return;
@@ -1683,7 +1670,6 @@ _func_enter_;
 			p2p_ps_wk_cmd(padapter, P2P_PS_DISABLE, 1);
 	}
 
-_func_exit_;
 }
 
 void p2p_ps_wk_hdl(struct adapter *padapter, u8 p2p_ps_state)
@@ -1691,7 +1677,6 @@ void p2p_ps_wk_hdl(struct adapter *padapter, u8 p2p_ps_state)
 	struct pwrctrl_priv		*pwrpriv = &padapter->pwrctrlpriv;
 	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
 
-_func_enter_;
 
 	/*  Pre action for p2p state */
 	switch (p2p_ps_state) {
@@ -1738,7 +1723,6 @@ _func_enter_;
 		break;
 	}
 
-_func_exit_;
 }
 
 u8 p2p_ps_wk_cmd(struct adapter *padapter, u8 p2p_ps_state, u8 enqueue)
@@ -1749,7 +1733,6 @@ u8 p2p_ps_wk_cmd(struct adapter *padapter, u8 p2p_ps_state, u8 enqueue)
 	struct cmd_priv	*pcmdpriv = &padapter->cmdpriv;
 	u8	res = _SUCCESS;
 
-_func_enter_;
 
 	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE))
 		return res;
@@ -1781,7 +1764,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
index b5db22c..491d6af 100644
--- a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
+++ b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
@@ -226,11 +226,8 @@ void rtw_set_rpwm(struct adapter *padapter, u8 pslv)
 	u8	rpwm;
 	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
 
-_func_enter_;
-
 	pslv = PS_STATE(pslv);
 
-
 	if (pwrpriv->btcoex_rfon) {
 		if (pslv < PS_STATE_S4)
 			pslv = PS_STATE_S3;
@@ -274,8 +271,6 @@ _func_enter_;
 
 	pwrpriv->tog += 0x80;
 	pwrpriv->cpwm = pslv;
-
-_func_exit_;
 }
 
 static u8 PS_RDY_CHECK(struct adapter *padapter)
@@ -313,8 +308,6 @@ void rtw_set_ps_mode(struct adapter *padapter, u8 ps_mode, u8 smart_ps, u8 bcn_a
 	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
 #endif /* CONFIG_88EU_P2P */
 
-_func_enter_;
-
 	RT_TRACE(_module_rtl871x_pwrctrl_c_, _drv_notice_,
 		 ("%s: PowerMode=%d Smart_PS=%d\n",
 		  __func__, ps_mode, smart_ps));
@@ -362,8 +355,6 @@ _func_enter_;
 			rtw_set_rpwm(padapter, PS_STATE_S2);
 		}
 	}
-
-_func_exit_;
 }
 
 /*
@@ -410,8 +401,6 @@ void LPS_Enter(struct adapter *padapter)
 {
 	struct pwrctrl_priv	*pwrpriv = &padapter->pwrctrlpriv;
 
-_func_enter_;
-
 	if (PS_RDY_CHECK(padapter) == false)
 		return;
 
@@ -428,8 +417,6 @@ _func_enter_;
 			pwrpriv->LpsIdleCount++;
 		}
 	}
-
-_func_exit_;
 }
 
 #define LPS_LEAVE_TIMEOUT_MS 100
@@ -440,8 +427,6 @@ void LPS_Leave(struct adapter *padapter)
 {
 	struct pwrctrl_priv	*pwrpriv = &padapter->pwrctrlpriv;
 
-_func_enter_;
-
 	if (pwrpriv->bLeisurePs) {
 		if (pwrpriv->pwr_mode != PS_MODE_ACTIVE) {
 			rtw_set_ps_mode(padapter, PS_MODE_ACTIVE, 0, 0);
@@ -452,8 +437,6 @@ _func_enter_;
 	}
 
 	pwrpriv->bpower_saving = false;
-
-_func_exit_;
 }
 
 /*  */
@@ -465,23 +448,17 @@ void LeaveAllPowerSaveMode(struct adapter *Adapter)
 	struct mlme_priv	*pmlmepriv = &(Adapter->mlmepriv);
 	u8	enqueue = 0;
 
-_func_enter_;
-
 	if (check_fwstate(pmlmepriv, _FW_LINKED)) { /* connect */
 		p2p_ps_wk_cmd(Adapter, P2P_PS_DISABLE, enqueue);
 
 		rtw_lps_ctrl_wk_cmd(Adapter, LPS_CTRL_LEAVE, enqueue);
 	}
-
-_func_exit_;
 }
 
 void rtw_init_pwrctrl_priv(struct adapter *padapter)
 {
 	struct pwrctrl_priv *pwrctrlpriv = &padapter->pwrctrlpriv;
 
-_func_enter_;
-
 	_init_pwrlock(&pwrctrlpriv->lock);
 	pwrctrlpriv->rf_pwrstate = rf_on;
 	pwrctrlpriv->ips_enter_cnts = 0;
@@ -518,8 +495,6 @@ _func_enter_;
 	pwrctrlpriv->btcoex_rfon = false;
 
 	_init_timer(&(pwrctrlpriv->pwr_state_check_timer), padapter->pnetdev, pwr_state_check_handler, (u8 *)padapter);
-
-_func_exit_;
 }
 
 u8 rtw_interface_ps_func(struct adapter *padapter, enum hal_intf_ps_func efunc_id, u8 *val)
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index f21630d..94d320b 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -46,7 +46,6 @@ void rtw_signal_stat_timer_hdl(RTW_TIMER_HDL_ARGS);
 
 void _rtw_init_sta_recv_priv(struct sta_recv_priv *psta_recvpriv)
 {
-_func_enter_;
 
 	_rtw_memset((u8 *)psta_recvpriv, 0, sizeof (struct sta_recv_priv));
 
@@ -54,7 +53,6 @@ _func_enter_;
 
 	_rtw_init_queue(&psta_recvpriv->defrag_q);
 
-_func_exit_;
 }
 
 int _rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter)
@@ -65,7 +63,6 @@ int _rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter)
 
 	int	res = _SUCCESS;
 
-_func_enter_;
 	spin_lock_init(&precvpriv->lock);
 
 	_rtw_init_queue(&precvpriv->free_recv_queue);
@@ -114,7 +111,6 @@ _func_enter_;
 	rtw_set_signal_stat_timer(precvpriv);
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -123,7 +119,6 @@ void _rtw_free_recv_priv (struct recv_priv *precvpriv)
 {
 	struct adapter	*padapter = precvpriv->adapter;
 
-_func_enter_;
 
 	rtw_free_uc_swdec_pending_queue(padapter);
 
@@ -135,7 +130,6 @@ _func_enter_;
 
 	rtw_hal_free_recv_priv(padapter);
 
-_func_exit_;
 }
 
 union recv_frame *_rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
@@ -144,7 +138,6 @@ union recv_frame *_rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
 	struct list_head *plist, *phead;
 	struct adapter *padapter;
 	struct recv_priv *precvpriv;
-_func_enter_;
 
 	if (_rtw_queue_empty(pfree_recv_queue)) {
 		hdr = NULL;
@@ -164,7 +157,6 @@ _func_enter_;
 		}
 	}
 
-_func_exit_;
 
 	return (union recv_frame *)hdr;
 }
@@ -195,7 +187,6 @@ int rtw_free_recvframe(union recv_frame *precvframe, struct __queue *pfree_recv_
 	struct adapter *padapter;
 	struct recv_priv *precvpriv;
 
-_func_enter_;
 	if (!precvframe)
 		return _FAIL;
 	padapter = precvframe->u.hdr.adapter;
@@ -220,7 +211,6 @@ _func_enter_;
 
       spin_unlock_bh(&pfree_recv_queue->lock);
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -230,7 +220,6 @@ int _rtw_enqueue_recvframe(union recv_frame *precvframe, struct __queue *queue)
 	struct adapter *padapter = precvframe->u.hdr.adapter;
 	struct recv_priv *precvpriv = &padapter->recvpriv;
 
-_func_enter_;
 
 	rtw_list_delete(&(precvframe->u.hdr.list));
 	rtw_list_insert_tail(&(precvframe->u.hdr.list), get_list_head(queue));
@@ -240,7 +229,6 @@ _func_enter_;
 			precvpriv->free_recvframe_cnt++;
 	}
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -269,7 +257,6 @@ void rtw_free_recvframe_queue(struct __queue *pframequeue,  struct __queue *pfre
 	struct recv_frame_hdr *hdr;
 	struct list_head *plist, *phead;
 
-_func_enter_;
 	spin_lock(&pframequeue->lock);
 
 	phead = get_list_head(pframequeue);
@@ -285,7 +272,6 @@ _func_enter_;
 
 	spin_unlock(&pframequeue->lock);
 
-_func_exit_;
 }
 
 u32 rtw_free_uc_swdec_pending_queue(struct adapter *adapter)
@@ -364,7 +350,6 @@ static int recvframe_chkmic(struct adapter *adapter,  union recv_frame *precvfra
 
 	struct mlme_ext_priv	*pmlmeext = &adapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
-_func_enter_;
 
 	stainfo = rtw_get_stainfo(&adapter->stapriv, &prxattrib->ta[0]);
 
@@ -472,7 +457,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -484,7 +468,6 @@ static union recv_frame *decryptor(struct adapter *padapter, union recv_frame *p
 	struct security_priv *psecuritypriv = &padapter->securitypriv;
 	union recv_frame *return_packet = precv_frame;
 	u32	 res = _SUCCESS;
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("prxstat->decrypted=%x prxattrib->encrypt=0x%03x\n", prxattrib->bdecrypted, prxattrib->encrypt));
 
@@ -535,7 +518,6 @@ _func_enter_;
 		return_packet = NULL;
 	}
 
-_func_exit_;
 
 	return return_packet;
 }
@@ -554,7 +536,6 @@ static union recv_frame *portctrl(struct adapter *adapter, union recv_frame *pre
 	struct rx_pkt_attrib *pattrib;
 	__be16 be_tmp;
 
-_func_enter_;
 
 	pstapriv = &adapter->stapriv;
 	psta = rtw_get_stainfo(pstapriv, psta_addr);
@@ -614,7 +595,6 @@ _func_enter_;
 		prtnframe = precv_frame;
 	}
 
-_func_exit_;
 
 		return prtnframe;
 }
@@ -626,7 +606,6 @@ static int recv_decache(union recv_frame *precv_frame, u8 bretry, struct stainfo
 	u16 seq_ctrl = ((precv_frame->u.hdr.attrib.seq_num&0xffff) << 4) |
 		(precv_frame->u.hdr.attrib.frag_num & 0xf);
 
-_func_enter_;
 
 	if (tid > 15) {
 		RT_TRACE(_module_rtl871x_recv_c_, _drv_notice_, ("recv_decache, (tid>15)! seq_ctrl=0x%x, tid=0x%x\n", seq_ctrl, tid));
@@ -644,7 +623,6 @@ _func_enter_;
 
 	prxcache->tid_rxseq[tid] = seq_ctrl;
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -778,7 +756,6 @@ int sta2sta_data_frame(struct adapter *adapter, union recv_frame *precv_frame, s
 	u8 *sta_addr = NULL;
 	int bmcast = IS_MCAST(pattrib->dst);
 
-_func_enter_;
 
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_STATE) == true) ||
 	    (check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE) == true)) {
@@ -854,7 +831,6 @@ _func_enter_;
 	}
 
 exit:
-_func_exit_;
 	return ret;
 }
 
@@ -872,7 +848,6 @@ static int ap2sta_data_frame (
 	u8 *myhwaddr = myid(&adapter->eeprompriv);
 	int bmcast = IS_MCAST(pattrib->dst);
 
-_func_enter_;
 
 	if ((check_fwstate(pmlmepriv, WIFI_STATION_STATE) == true) &&
 	    (check_fwstate(pmlmepriv, _FW_LINKED) == true ||
@@ -965,7 +940,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return ret;
 }
@@ -981,7 +955,6 @@ static int sta2ap_data_frame(struct adapter *adapter,
 	unsigned char *mybssid  = get_bssid(pmlmepriv);
 	int ret = _SUCCESS;
 
-_func_enter_;
 
 	if (check_fwstate(pmlmepriv, WIFI_AP_STATE) == true) {
 		/* For AP mode, RA = BSSID, TX = STA(SRC_ADDR), A3 = DST_ADDR */
@@ -1027,7 +1000,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return ret;
 }
@@ -1208,7 +1180,6 @@ static int validate_recv_data_frame(struct adapter *adapter,
 	struct security_priv	*psecuritypriv = &adapter->securitypriv;
 	int ret = _SUCCESS;
 
-_func_enter_;
 
 	bretry = GetRetry(ptr);
 	pda = get_da(ptr);
@@ -1313,7 +1284,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return ret;
 }
@@ -1333,7 +1303,6 @@ static int validate_recv_frame(struct adapter *adapter, union recv_frame *precv_
 	u8  ver = (unsigned char) (*ptr)&0x3;
 	struct mlme_ext_priv *pmlmeext = &adapter->mlmeextpriv;
 
-_func_enter_;
 
 	if (pmlmeext->sitesurvey_res.state == SCAN_PROCESS) {
 		int ch_set_idx = rtw_ch_set_search_ch(pmlmeext->channel_set, rtw_get_oper_ch(adapter));
@@ -1423,7 +1392,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return retval;
 }
@@ -1446,7 +1414,6 @@ static int wlanhdr_to_ethhdr (union recv_frame *precvframe)
 	u8	*ptr = get_recvframe_data(precvframe); /*  point to frame_ctrl field */
 	struct rx_pkt_attrib *pattrib = &precvframe->u.hdr.attrib;
 
-_func_enter_;
 
 	if (pattrib->encrypt)
 		recvframe_pull_tail(precvframe, pattrib->icv_len);
@@ -1497,7 +1464,6 @@ _func_enter_;
 		memcpy(ptr+12, &be_tmp, 2);
 	}
 
-_func_exit_;
 	return ret;
 }
 
@@ -1511,7 +1477,6 @@ static union recv_frame *recvframe_defrag(struct adapter *adapter, struct __queu
 	union recv_frame *prframe, *pnextrframe;
 	struct __queue *pfree_recv_queue;
 
-_func_enter_;
 
 	curfragnum = 0;
 	pfree_recv_queue = &adapter->recvpriv.free_recv_queue;
@@ -1577,7 +1542,6 @@ _func_enter_;
 
 	RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("Performance defrag!!!!!\n"));
 
-_func_exit_;
 
 	return prframe;
 }
@@ -1595,7 +1559,6 @@ union recv_frame *recvframe_chk_defrag(struct adapter *padapter, union recv_fram
 	union recv_frame *prtnframe = NULL;
 	struct __queue *pfree_recv_queue, *pdefrag_q;
 
-_func_enter_;
 
 	pstapriv = &padapter->stapriv;
 
@@ -1680,7 +1643,6 @@ _func_enter_;
 		}
 	}
 
-_func_exit_;
 
 	return prtnframe;
 }
@@ -2202,7 +2164,6 @@ s32 rtw_recv_entry(union recv_frame *precvframe)
 	struct recv_priv *precvpriv;
 	s32 ret = _SUCCESS;
 
-_func_enter_;
 
 	padapter = precvframe->u.hdr.adapter;
 
@@ -2216,7 +2177,6 @@ _func_enter_;
 
 	precvpriv->rx_pkts++;
 
-_func_exit_;
 
 	return ret;
 
@@ -2225,7 +2185,6 @@ _recv_entry_drop:
 	if (padapter->registrypriv.mp_mode == 1)
 		padapter->mppriv.rx_pktloss = precvpriv->rx_drop;
 
-_func_exit_;
 
 	return ret;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_security.c b/drivers/staging/rtl8188eu/core/rtw_security.c
index e088457..c3ce569 100644
--- a/drivers/staging/rtl8188eu/core/rtw_security.c
+++ b/drivers/staging/rtl8188eu/core/rtw_security.c
@@ -41,7 +41,6 @@ static void arcfour_init(struct arc4context *parc4ctx, u8 *key, u32	key_len)
 	u32	stateindex;
 	u8 *state;
 	u32	counter;
-_func_enter_;
 	state = parc4ctx->state;
 	parc4ctx->x = 0;
 	parc4ctx->y = 0;
@@ -58,7 +57,6 @@ _func_enter_;
 		if (++keyindex >= key_len)
 			keyindex = 0;
 	}
-_func_exit_;
 }
 
 static u32 arcfour_byte(struct arc4context *parc4ctx)
@@ -67,7 +65,6 @@ static u32 arcfour_byte(struct arc4context *parc4ctx)
 	u32 y;
 	u32 sx, sy;
 	u8 *state;
-_func_enter_;
 	state = parc4ctx->state;
 	x = (parc4ctx->x + 1) & 0xff;
 	sx = state[x];
@@ -77,17 +74,14 @@ _func_enter_;
 	parc4ctx->y = y;
 	state[y] = (u8)sx;
 	state[x] = (u8)sy;
-_func_exit_;
 	return state[(sx + sy) & 0xff];
 }
 
 static void arcfour_encrypt(struct arc4context *parc4ctx, u8 *dest, u8 *src, u32 len)
 {
 	u32	i;
-_func_enter_;
 	for (i = 0; i < len; i++)
 		dest[i] = src[i] ^ (unsigned char)arcfour_byte(parc4ctx);
-_func_exit_;
 }
 
 static int bcrc32initialized;
@@ -102,9 +96,8 @@ static u8 crc32_reverseBit(u8 data)
 
 static void crc32_init(void)
 {
-_func_enter_;
 	if (bcrc32initialized == 1) {
-		goto exit;
+		return;
 	} else {
 		int i, j;
 		u32 c;
@@ -126,15 +119,12 @@ _func_enter_;
 		}
 		bcrc32initialized = 1;
 	}
-exit:
-_func_exit_;
 }
 
 static __le32 getcrc32(u8 *buf, int len)
 {
 	u8 *p;
 	u32  crc;
-_func_enter_;
 	if (bcrc32initialized == 0)
 		crc32_init();
 
@@ -142,7 +132,6 @@ _func_enter_;
 
 	for (p = buf; len > 0; ++p, --len)
 		crc = crc32_table[(crc ^ *p) & 0xff] ^ (crc >> 8);
-_func_exit_;
 	return cpu_to_le32(~crc);    /* transmit complement, per CRC-32 spec */
 }
 
@@ -165,7 +154,6 @@ void rtw_wep_encrypt(struct adapter *padapter, u8 *pxmitframe)
 	struct	security_priv	*psecuritypriv = &padapter->securitypriv;
 	struct	xmit_priv		*pxmitpriv = &padapter->xmitpriv;
 
-_func_enter_;
 
 	if (((struct xmit_frame *)pxmitframe)->buf_addr == NULL)
 		return;
@@ -206,7 +194,6 @@ _func_enter_;
 		}
 	}
 
-_func_exit_;
 }
 
 void rtw_wep_decrypt(struct adapter  *padapter, u8 *precvframe)
@@ -221,7 +208,6 @@ void rtw_wep_decrypt(struct adapter  *padapter, u8 *precvframe)
 	struct	rx_pkt_attrib	 *prxattrib = &(((union recv_frame *)precvframe)->u.hdr.attrib);
 	struct	security_priv	*psecuritypriv = &padapter->securitypriv;
 
-_func_enter_;
 
 	pframe = (unsigned char *)((union recv_frame *)precvframe)->u.hdr.rx_data;
 
@@ -252,7 +238,6 @@ _func_enter_;
 				 &crc, &payload[length-4]));
 		}
 	}
-_func_exit_;
 	return;
 }
 
@@ -263,10 +248,8 @@ static u32 secmicgetuint32(u8 *p)
 {
 	s32 i;
 	u32 res = 0;
-_func_enter_;
 	for (i = 0; i < 4; i++)
 		res |= ((u32)(*p++)) << (8*i);
-_func_exit_;
 	return res;
 }
 
@@ -274,39 +257,32 @@ static void secmicputuint32(u8 *p, u32 val)
 /*  Convert from Us3232 to Byte[] in a portable way */
 {
 	long i;
-_func_enter_;
 	for (i = 0; i < 4; i++) {
 		*p++ = (u8) (val & 0xff);
 		val >>= 8;
 	}
-_func_exit_;
 }
 
 static void secmicclear(struct mic_data *pmicdata)
 {
 /*  Reset the state to the empty message. */
-_func_enter_;
 	pmicdata->L = pmicdata->K0;
 	pmicdata->R = pmicdata->K1;
 	pmicdata->nBytesInM = 0;
 	pmicdata->M = 0;
-_func_exit_;
 }
 
 void rtw_secmicsetkey(struct mic_data *pmicdata, u8 *key)
 {
 	/*  Set the key */
-_func_enter_;
 	pmicdata->K0 = secmicgetuint32(key);
 	pmicdata->K1 = secmicgetuint32(key + 4);
 	/*  and reset the message */
 	secmicclear(pmicdata);
-_func_exit_;
 }
 
 void rtw_secmicappendbyte(struct mic_data *pmicdata, u8 b)
 {
-_func_enter_;
 	/*  Append the byte to our word-sized buffer */
 	pmicdata->M |= ((unsigned long)b) << (8*pmicdata->nBytesInM);
 	pmicdata->nBytesInM++;
@@ -325,23 +301,19 @@ _func_enter_;
 		pmicdata->M = 0;
 		pmicdata->nBytesInM = 0;
 	}
-_func_exit_;
 }
 
 void rtw_secmicappend(struct mic_data *pmicdata, u8 *src, u32 nbytes)
 {
-_func_enter_;
 	/*  This is simple */
 	while (nbytes > 0) {
 		rtw_secmicappendbyte(pmicdata, *src++);
 		nbytes--;
 	}
-_func_exit_;
 }
 
 void rtw_secgetmic(struct mic_data *pmicdata, u8 *dst)
 {
-_func_enter_;
 	/*  Append the minimum padding */
 	rtw_secmicappendbyte(pmicdata, 0x5a);
 	rtw_secmicappendbyte(pmicdata, 0);
@@ -356,14 +328,12 @@ _func_enter_;
 	secmicputuint32(dst+4, pmicdata->R);
 	/*  Reset to the empty message. */
 	secmicclear(pmicdata);
-_func_exit_;
 }
 
 void rtw_seccalctkipmic(u8 *key, u8 *header, u8 *data, u32 data_len, u8 *mic_code, u8 pri)
 {
 	struct mic_data	micdata;
 	u8 priority[4] = {0x0, 0x0, 0x0, 0x0};
-_func_enter_;
 	rtw_secmicsetkey(&micdata, key);
 	priority[0] = pri;
 
@@ -386,7 +356,6 @@ _func_enter_;
 	rtw_secmicappend(&micdata, data, data_len);
 
 	rtw_secgetmic(&micdata, mic_code);
-_func_exit_;
 }
 
 
@@ -505,7 +474,6 @@ static const unsigned short Sbox1[2][256] = {  /* Sbox for hash (can be in ROM)
 static void phase1(u16 *p1k, const u8 *tk, const u8 *ta, u32 iv32)
 {
 	int  i;
-_func_enter_;
 	/* Initialize the 80 bits of P1K[] from IV32 and TA[0..5]     */
 	p1k[0]      = Lo16(iv32);
 	p1k[1]      = Hi16(iv32);
@@ -523,7 +491,6 @@ _func_enter_;
 		p1k[4] += _S_(p1k[3] ^ TK16((i&1)+0));
 		p1k[4] +=  (unsigned short)i;   /* avoid "slide attacks" */
 	}
-_func_exit_;
 }
 
 /*
@@ -553,7 +520,6 @@ static void phase2(u8 *rc4key, const u8 *tk, const u16 *p1k, u16 iv16)
 {
 	int  i;
 	u16 PPK[6];			/* temporary key for mixing    */
-_func_enter_;
 	/* Note: all adds in the PPK[] equations below are mod 2**16	 */
 	for (i = 0; i < 5; i++)
 		PPK[i] = p1k[i];	/* first, copy P1K to PPK      */
@@ -590,7 +556,6 @@ _func_enter_;
 		rc4key[4+2*i] = Lo8(PPK[i]);
 		rc4key[5+2*i] = Hi8(PPK[i]);
 	}
-_func_exit_;
 }
 
 /* The hlen isn't include the IV */
@@ -612,7 +577,6 @@ u32	rtw_tkip_encrypt(struct adapter *padapter, u8 *pxmitframe)
 	struct	security_priv	*psecuritypriv = &padapter->securitypriv;
 	struct	xmit_priv		*pxmitpriv = &padapter->xmitpriv;
 	u32	res = _SUCCESS;
-_func_enter_;
 
 	if (((struct xmit_frame *)pxmitframe)->buf_addr == NULL)
 		return _FAIL;
@@ -672,7 +636,6 @@ _func_enter_;
 			res = _FAIL;
 		}
 	}
-_func_exit_;
 	return res;
 }
 
@@ -694,7 +657,6 @@ u32 rtw_tkip_decrypt(struct adapter *padapter, u8 *precvframe)
 	struct	security_priv	*psecuritypriv = &padapter->securitypriv;
 	u32		res = _SUCCESS;
 
-_func_enter_;
 
 	pframe = (unsigned char *)((union recv_frame *)precvframe)->u.hdr.rx_data;
 
@@ -747,7 +709,6 @@ _func_enter_;
 			res = _FAIL;
 		}
 	}
-_func_exit_;
 exit:
 	return res;
 }
@@ -821,19 +782,15 @@ static void aes128k128d(u8 *key, u8 *data, u8 *ciphertext);
 static void xor_128(u8 *a, u8 *b, u8 *out)
 {
 	int i;
-_func_enter_;
 	for (i = 0; i < 16; i++)
 		out[i] = a[i] ^ b[i];
-_func_exit_;
 }
 
 static void xor_32(u8 *a, u8 *b, u8 *out)
 {
 	int i;
-_func_enter_;
 	for (i = 0; i < 4; i++)
 		out[i] = a[i] ^ b[i];
-_func_exit_;
 }
 
 static u8 sbox(u8 a)
@@ -849,7 +806,6 @@ static void next_key(u8 *key, int round)
 		0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80,
 		0x1b, 0x36, 0x36, 0x36
 	};
-_func_enter_;
 	sbox_key[0] = sbox(key[13]);
 	sbox_key[1] = sbox(key[14]);
 	sbox_key[2] = sbox(key[15]);
@@ -863,21 +819,17 @@ _func_enter_;
 	xor_32(&key[4], &key[0], &key[4]);
 	xor_32(&key[8], &key[4], &key[8]);
 	xor_32(&key[12], &key[8], &key[12]);
-_func_exit_;
 }
 
 static void byte_sub(u8 *in, u8 *out)
 {
 	int i;
-_func_enter_;
 	for (i = 0; i < 16; i++)
 		out[i] = sbox(in[i]);
-_func_exit_;
 }
 
 static void shift_row(u8 *in, u8 *out)
 {
-_func_enter_;
 	out[0] =  in[0];
 	out[1] =  in[5];
 	out[2] =  in[10];
@@ -894,7 +846,6 @@ _func_enter_;
 	out[13] = in[1];
 	out[14] = in[6];
 	out[15] = in[11];
-_func_exit_;
 }
 
 static void mix_column(u8 *in, u8 *out)
@@ -908,7 +859,6 @@ static void mix_column(u8 *in, u8 *out)
 	u8 rotr[4];
 	u8 temp[4];
 	u8 tempb[4];
-_func_enter_;
 	for (i = 0 ; i < 4; i++) {
 		if ((in[i] & 0x80) == 0x80)
 			add1b[i] = 0x1b;
@@ -952,7 +902,6 @@ _func_enter_;
 	xor_32(add1bf7, rotr, temp);
 	xor_32(swap_halfs, rotl, tempb);
 	xor_32(temp, tempb, out);
-_func_exit_;
 }
 
 static void aes128k128d(u8 *key, u8 *data, u8 *ciphertext)
@@ -962,7 +911,6 @@ static void aes128k128d(u8 *key, u8 *data, u8 *ciphertext)
 	u8 intermediatea[16];
 	u8 intermediateb[16];
 	u8 round_key[16];
-_func_enter_;
 	for (i = 0; i < 16; i++)
 		round_key[i] = key[i];
 	for (round = 0; round < 11; round++) {
@@ -984,7 +932,6 @@ _func_enter_;
 			next_key(round_key, round);
 		}
 	}
-_func_exit_;
 }
 
 /************************************************/
@@ -995,7 +942,6 @@ static void construct_mic_iv(u8 *mic_iv, int qc_exists, int a4_exists, u8 *mpdu,
 			     uint payload_length, u8 *pn_vector)
 {
 	int i;
-_func_enter_;
 	mic_iv[0] = 0x59;
 	if (qc_exists && a4_exists)
 		mic_iv[1] = mpdu[30] & 0x0f;    /* QoS_TC	   */
@@ -1009,7 +955,6 @@ _func_enter_;
 		mic_iv[i] = pn_vector[13 - i];	/* mic_iv[8:13] = PN[5:0] */
 	mic_iv[14] = (unsigned char) (payload_length / 256);
 	mic_iv[15] = (unsigned char) (payload_length % 256);
-_func_exit_;
 }
 
 /************************************************/
@@ -1019,7 +964,6 @@ _func_exit_;
 /************************************************/
 static void construct_mic_header1(u8 *mic_header1, int header_length, u8 *mpdu)
 {
-_func_enter_;
 	mic_header1[0] = (u8)((header_length - 2) / 256);
 	mic_header1[1] = (u8)((header_length - 2) % 256);
 	mic_header1[2] = mpdu[0] & 0xcf;    /* Mute CF poll & CF ack bits */
@@ -1036,7 +980,6 @@ _func_enter_;
 	mic_header1[13] = mpdu[13];
 	mic_header1[14] = mpdu[14];
 	mic_header1[15] = mpdu[15];
-_func_exit_;
 }
 
 /************************************************/
@@ -1047,7 +990,6 @@ _func_exit_;
 static void construct_mic_header2(u8 *mic_header2, u8 *mpdu, int a4_exists, int qc_exists)
 {
 	int i;
-_func_enter_;
 	for (i = 0; i < 16; i++)
 		mic_header2[i] = 0x00;
 
@@ -1079,7 +1021,6 @@ _func_enter_;
 		mic_header2[15] = mpdu[31] & 0x00;
 	}
 
-_func_exit_;
 }
 
 /************************************************/
@@ -1090,7 +1031,6 @@ _func_exit_;
 static void construct_ctr_preload(u8 *ctr_preload, int a4_exists, int qc_exists, u8 *mpdu, u8 *pn_vector, int c)
 {
 	int i;
-_func_enter_;
 	for (i = 0; i < 16; i++)
 		ctr_preload[i] = 0x00;
 	i = 0;
@@ -1107,7 +1047,6 @@ _func_enter_;
 		ctr_preload[i] =    pn_vector[13 - i];	  /* ctr_preload[8:13] = PN[5:0] */
 	ctr_preload[14] =  (unsigned char) (c / 256); /* Ctr */
 	ctr_preload[15] =  (unsigned char) (c % 256);
-_func_exit_;
 }
 
 /************************************/
@@ -1117,10 +1056,8 @@ _func_exit_;
 static void bitwise_xor(u8 *ina, u8 *inb, u8 *out)
 {
 	int i;
-_func_enter_;
 	for (i = 0; i < 16; i++)
 		out[i] = ina[i] ^ inb[i];
-_func_exit_;
 }
 
 static int aes_cipher(u8 *key, uint hdrlen, u8 *pframe, uint plen)
@@ -1142,7 +1079,6 @@ static int aes_cipher(u8 *key, uint hdrlen, u8 *pframe, uint plen)
 	uint	frtype  = GetFrameType(pframe);
 	uint	frsubtype  = GetFrameSubType(pframe);
 
-_func_enter_;
 	frsubtype = frsubtype>>4;
 
 	_rtw_memset((void *)mic_iv, 0, 16);
@@ -1253,7 +1189,6 @@ _func_enter_;
 	bitwise_xor(aes_out, padded_buffer, chain_buffer);
 	for (j = 0; j < 8; j++)
 		pframe[payload_index++] = chain_buffer[j];
-_func_exit_;
 	return _SUCCESS;
 }
 
@@ -1274,7 +1209,6 @@ u32	rtw_aes_encrypt(struct adapter *padapter, u8 *pxmitframe)
 
 /*	uint	offset = 0; */
 	u32 res = _SUCCESS;
-_func_enter_;
 
 	if (((struct xmit_frame *)pxmitframe)->buf_addr == NULL)
 		return _FAIL;
@@ -1318,7 +1252,6 @@ _func_enter_;
 	}
 
 
-_func_exit_;
 		return res;
 }
 
@@ -1344,7 +1277,6 @@ static int aes_decipher(u8 *key, uint	hdrlen,
 /*	uint	offset = 0; */
 	uint	frtype  = GetFrameType(pframe);
 	uint	frsubtype  = GetFrameSubType(pframe);
-_func_enter_;
 	frsubtype = frsubtype>>4;
 
 	_rtw_memset((void *)mic_iv, 0, 16);
@@ -1514,7 +1446,6 @@ _func_enter_;
 			res = _FAIL;
 		}
 	}
-_func_exit_;
 	return res;
 }
 
@@ -1527,7 +1458,6 @@ u32	rtw_aes_decrypt(struct adapter *padapter, u8 *precvframe)
 	struct	rx_pkt_attrib	 *prxattrib = &((union recv_frame *)precvframe)->u.hdr.attrib;
 	struct	security_priv	*psecuritypriv = &padapter->securitypriv;
 	u32	res = _SUCCESS;
-_func_enter_;
 	pframe = (unsigned char *)((union recv_frame *)precvframe)->u.hdr.rx_data;
 	/* 4 start to encrypt each fragment */
 	if ((prxattrib->encrypt == _AES_)) {
@@ -1559,7 +1489,6 @@ _func_enter_;
 			res = _FAIL;
 		}
 	}
-_func_exit_;
 exit:
 	return res;
 }
@@ -1767,7 +1696,6 @@ void rtw_use_tkipkey_handler(void *FunctionContext)
 {
 	struct adapter *padapter = (struct adapter *)FunctionContext;
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_security_c_, _drv_err_, ("^^^rtw_use_tkipkey_handler ^^^\n"));
 
@@ -1775,5 +1703,4 @@ _func_enter_;
 
 	RT_TRACE(_module_rtl871x_security_c_, _drv_err_, ("^^^rtw_use_tkipkey_handler padapter->securitypriv.busetkipkey=%d^^^\n", padapter->securitypriv.busetkipkey));
 
-_func_exit_;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index 5c9326d..a59f062 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -29,7 +29,6 @@
 
 static void _rtw_init_stainfo(struct sta_info *psta)
 {
-_func_enter_;
 	_rtw_memset((u8 *)psta, 0, sizeof (struct sta_info));
 
 	 spin_lock_init(&psta->lock);
@@ -70,7 +69,6 @@ _func_enter_;
 
 #endif	/*  CONFIG_88EU_AP_MODE */
 
-_func_exit_;
 }
 
 u32	_rtw_init_sta_priv(struct	sta_priv *pstapriv)
@@ -78,7 +76,6 @@ u32	_rtw_init_sta_priv(struct	sta_priv *pstapriv)
 	struct sta_info *psta;
 	s32 i;
 
-_func_enter_;
 
 	pstapriv->pallocated_stainfo_buf = vzalloc(sizeof(struct sta_info) * NUM_STA + 4);
 
@@ -126,7 +123,6 @@ _func_enter_;
 	pstapriv->max_num_sta = NUM_STA;
 #endif
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -155,7 +151,6 @@ static void rtw_mfree_all_stainfo(struct sta_priv *pstapriv)
 	struct list_head *plist, *phead;
 	struct sta_info *psta = NULL;
 
-_func_enter_;
 
 	spin_lock_bh(&pstapriv->sta_hash_lock);
 
@@ -169,7 +164,6 @@ _func_enter_;
 
 	spin_unlock_bh(&pstapriv->sta_hash_lock);
 
-_func_exit_;
 }
 
 static void rtw_mfree_sta_priv_lock(struct sta_priv *pstapriv)
@@ -184,7 +178,6 @@ u32	_rtw_free_sta_priv(struct	sta_priv *pstapriv)
 	struct recv_reorder_ctrl *preorder_ctrl;
 	int	index;
 
-_func_enter_;
 	if (pstapriv) {
 		/*	delete all reordering_ctrl_timer		*/
 		spin_lock_bh(&pstapriv->sta_hash_lock);
@@ -212,7 +205,6 @@ _func_enter_;
 			vfree(pstapriv->pallocated_stainfo_buf);
 	}
 
-_func_exit_;
 	return _SUCCESS;
 }
 
@@ -226,7 +218,6 @@ struct	sta_info *rtw_alloc_stainfo(struct sta_priv *pstapriv, u8 *hwaddr)
 	int i = 0;
 	u16  wRxSeqInitialValue = 0xffff;
 
-_func_enter_;
 
 	pfree_sta_queue = &pstapriv->free_sta_queue;
 
@@ -298,9 +289,6 @@ _func_enter_;
 	}
 
 exit:
-
-_func_exit_;
-
 	return psta;
 }
 
@@ -314,7 +302,6 @@ u32	rtw_free_stainfo(struct adapter *padapter , struct sta_info *psta)
 	struct	xmit_priv	*pxmitpriv = &padapter->xmitpriv;
 	struct	sta_priv *pstapriv = &padapter->stapriv;
 
-_func_enter_;
 
 	if (psta == NULL)
 		goto exit;
@@ -431,7 +418,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -445,10 +431,9 @@ void rtw_free_all_stainfo(struct adapter *padapter)
 	struct	sta_priv *pstapriv = &padapter->stapriv;
 	struct sta_info *pbcmc_stainfo = rtw_get_bcmc_stainfo(padapter);
 
-_func_enter_;
 
 	if (pstapriv->asoc_sta_count == 1)
-		goto exit;
+		return;
 
 	spin_lock_bh(&pstapriv->sta_hash_lock);
 
@@ -465,12 +450,7 @@ _func_enter_;
 				rtw_free_stainfo(padapter , psta);
 		}
 	}
-
 	spin_unlock_bh(&pstapriv->sta_hash_lock);
-
-exit:
-
-_func_exit_;
 }
 
 /* any station allocated can be searched by hash list */
@@ -482,7 +462,6 @@ struct sta_info *rtw_get_stainfo(struct sta_priv *pstapriv, u8 *hwaddr)
 	u8 *addr;
 	u8 bc_addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
-_func_enter_;
 
 	if (hwaddr == NULL)
 		return NULL;
@@ -511,7 +490,6 @@ _func_enter_;
 	}
 
 	spin_unlock_bh(&pstapriv->sta_hash_lock);
-_func_exit_;
 	return psta;
 }
 
@@ -522,7 +500,6 @@ u32 rtw_init_bcmc_stainfo(struct adapter *padapter)
 	unsigned char bcast_addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 	struct	sta_priv *pstapriv = &padapter->stapriv;
 
-_func_enter_;
 
 	psta = rtw_alloc_stainfo(pstapriv, bcast_addr);
 
@@ -536,7 +513,6 @@ _func_enter_;
 	psta->mac_id = 1;
 
 exit:
-_func_exit_;
 	return res;
 }
 
@@ -545,9 +521,7 @@ struct sta_info *rtw_get_bcmc_stainfo(struct adapter *padapter)
 	struct sta_info		*psta;
 	struct sta_priv		*pstapriv = &padapter->stapriv;
 	u8 bc_addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
-_func_enter_;
 	 psta = rtw_get_stainfo(pstapriv, bc_addr);
-_func_exit_;
 	return psta;
 }
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
index 2c8d58d..f64b979 100644
--- a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
+++ b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
@@ -1090,12 +1090,10 @@ int rtw_check_bcn_info(struct adapter  *Adapter, u8 *pframe, u32 packet_len)
 	}
 
 	kfree(bssid);
-	_func_exit_;
 	return _SUCCESS;
 
 _mismatch:
 	kfree(bssid);
-	_func_exit_;
 	return _FAIL;
 }
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 37030e1..44e54a3 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -33,16 +33,13 @@ static u8 RFC1042_OUI[P80211_OUI_LEN] = { 0x00, 0x00, 0x00 };
 
 static void _init_txservq(struct tx_servq *ptxservq)
 {
-_func_enter_;
 	_rtw_init_listhead(&ptxservq->tx_pending);
 	_rtw_init_queue(&ptxservq->sta_pending);
 	ptxservq->qcnt = 0;
-_func_exit_;
 }
 
 void	_rtw_init_sta_xmit_priv(struct sta_xmit_priv *psta_xmitpriv)
 {
-_func_enter_;
 	_rtw_memset((unsigned char *)psta_xmitpriv, 0, sizeof (struct sta_xmit_priv));
 	spin_lock_init(&psta_xmitpriv->lock);
 	_init_txservq(&psta_xmitpriv->be_q);
@@ -52,7 +49,6 @@ _func_enter_;
 	_rtw_init_listhead(&psta_xmitpriv->legacy_dz);
 	_rtw_init_listhead(&psta_xmitpriv->apsd);
 
-_func_exit_;
 }
 
 s32	_rtw_init_xmit_priv(struct xmit_priv *pxmitpriv, struct adapter *padapter)
@@ -64,7 +60,6 @@ s32	_rtw_init_xmit_priv(struct xmit_priv *pxmitpriv, struct adapter *padapter)
 	u32 max_xmit_extbuf_size = MAX_XMIT_EXTBUF_SZ;
 	u32 num_xmit_extbuf = NR_XMIT_EXTBUFF;
 
-_func_enter_;
 
 	/*  We don't need to memset padapter->XXX to zero, because adapter is allocated by vzalloc(). */
 
@@ -227,7 +222,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -241,12 +235,11 @@ void _rtw_free_xmit_priv (struct xmit_priv *pxmitpriv)
 	u32 max_xmit_extbuf_size = MAX_XMIT_EXTBUF_SZ;
 	u32 num_xmit_extbuf = NR_XMIT_EXTBUFF;
 
- _func_enter_;
 
 	rtw_hal_free_xmit_priv(padapter);
 
 	if (pxmitpriv->pxmit_frame_buf == NULL)
-		goto out;
+		return;
 
 	for (i = 0; i < NR_XMITFRAME; i++) {
 		rtw_os_xmit_complete(padapter, pxmitframe);
@@ -279,10 +272,6 @@ void _rtw_free_xmit_priv (struct xmit_priv *pxmitpriv)
 	rtw_free_hwxmits(padapter);
 
 	mutex_destroy(&pxmitpriv->ack_tx_mutex);
-
-out:
-
-_func_exit_;
 }
 
 static void update_attrib_vcs_info(struct adapter *padapter, struct xmit_frame *pxmitframe)
@@ -456,7 +445,6 @@ static s32 update_attrib(struct adapter *padapter, struct sk_buff *pkt, struct p
 	struct qos_priv		*pqospriv = &pmlmepriv->qospriv;
 	int res = _SUCCESS;
 
- _func_enter_;
 
 	_rtw_open_pktfile(pkt, &pktfile);
 	_rtw_pktfile_read(&pktfile, (u8 *)&etherhdr, ETH_HLEN);
@@ -640,7 +628,6 @@ static s32 update_attrib(struct adapter *padapter, struct sk_buff *pkt, struct p
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -663,7 +650,6 @@ static s32 xmitframe_addmic(struct adapter *padapter, struct xmit_frame *pxmitfr
 	else
 		stainfo = rtw_get_stainfo(&padapter->stapriv , &pattrib->ra[0]);
 
-_func_enter_;
 
 	hw_hdr_offset = TXDESC_SIZE + (pxmitframe->pkt_offset * PACKET_OFFSET_SZ);
 
@@ -761,7 +747,6 @@ _func_enter_;
 			}
 	}
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -770,7 +755,6 @@ static s32 xmitframe_swencrypt(struct adapter *padapter, struct xmit_frame *pxmi
 {
 	struct	pkt_attrib	 *pattrib = &pxmitframe->attrib;
 
-_func_enter_;
 
 	if (pattrib->bswenc) {
 		RT_TRACE(_module_rtl871x_xmit_c_, _drv_alert_, ("### xmitframe_swencrypt\n"));
@@ -792,7 +776,6 @@ _func_enter_;
 		RT_TRACE(_module_rtl871x_xmit_c_, _drv_notice_, ("### xmitframe_hwencrypt\n"));
 	}
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -813,7 +796,6 @@ s32 rtw_make_wlanhdr (struct adapter *padapter , u8 *hdr, struct pkt_attrib *pat
 
 	int bmcst = IS_MCAST(pattrib->ra);
 
-_func_enter_;
 
 	if (pattrib->psta) {
 		psta = pattrib->psta;
@@ -919,7 +901,6 @@ _func_enter_;
 	}
 exit:
 
-_func_exit_;
 	return res;
 }
 
@@ -1008,7 +989,6 @@ s32 rtw_xmitframe_coalesce(struct adapter *padapter, struct sk_buff *pkt, struct
 	s32 bmcst = IS_MCAST(pattrib->ra);
 	s32 res = _SUCCESS;
 
-_func_enter_;
 
 	psta = rtw_get_stainfo(&padapter->stapriv, pattrib->ra);
 
@@ -1146,7 +1126,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1163,7 +1142,6 @@ s32 rtw_put_snap(u8 *data, u16 h_proto)
 	struct ieee80211_snap_hdr *snap;
 	u8 *oui;
 
-_func_enter_;
 
 	snap = (struct ieee80211_snap_hdr *)data;
 	snap->dsap = 0xaa;
@@ -1181,7 +1159,6 @@ _func_enter_;
 
 	*(__be16 *)(data + SNAP_SIZE) = htons(h_proto);
 
-_func_exit_;
 
 	return SNAP_SIZE + sizeof(u16);
 }
@@ -1194,7 +1171,6 @@ void rtw_update_protection(struct adapter *padapter, u8 *ie, uint ie_len)
 	struct	xmit_priv *pxmitpriv = &padapter->xmitpriv;
 	struct	registry_priv *pregistrypriv = &padapter->registrypriv;
 
-_func_enter_;
 
 	switch (pxmitpriv->vcs_setting) {
 	case DISABLE_VCS:
@@ -1221,7 +1197,6 @@ _func_enter_;
 		break;
 	}
 
-_func_exit_;
 }
 
 void rtw_count_tx_stats(struct adapter *padapter, struct xmit_frame *pxmitframe, int sz)
@@ -1251,7 +1226,6 @@ struct xmit_buf *rtw_alloc_xmitbuf_ext(struct xmit_priv *pxmitpriv)
 	struct list_head *plist, *phead;
 	struct __queue *pfree_queue = &pxmitpriv->free_xmit_extbuf_queue;
 
-_func_enter_;
 
 	spin_lock_irqsave(&pfree_queue->lock, irql);
 
@@ -1281,7 +1255,6 @@ _func_enter_;
 
 	spin_unlock_irqrestore(&pfree_queue->lock, irql);
 
-_func_exit_;
 
 	return pxmitbuf;
 }
@@ -1291,7 +1264,6 @@ s32 rtw_free_xmitbuf_ext(struct xmit_priv *pxmitpriv, struct xmit_buf *pxmitbuf)
 	unsigned long irql;
 	struct __queue *pfree_queue = &pxmitpriv->free_xmit_extbuf_queue;
 
-_func_enter_;
 
 	if (pxmitbuf == NULL)
 		return _FAIL;
@@ -1305,7 +1277,6 @@ _func_enter_;
 
 	spin_unlock_irqrestore(&pfree_queue->lock, irql);
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -1317,7 +1288,6 @@ struct xmit_buf *rtw_alloc_xmitbuf(struct xmit_priv *pxmitpriv)
 	struct list_head *plist, *phead;
 	struct __queue *pfree_xmitbuf_queue = &pxmitpriv->free_xmitbuf_queue;
 
-_func_enter_;
 
 	/* DBG_88E("+rtw_alloc_xmitbuf\n"); */
 
@@ -1345,7 +1315,6 @@ _func_enter_;
 	}
 	spin_unlock_irqrestore(&pfree_xmitbuf_queue->lock, irql);
 
-_func_exit_;
 
 	return pxmitbuf;
 }
@@ -1355,7 +1324,6 @@ s32 rtw_free_xmitbuf(struct xmit_priv *pxmitpriv, struct xmit_buf *pxmitbuf)
 	unsigned long irql;
 	struct __queue *pfree_xmitbuf_queue = &pxmitpriv->free_xmitbuf_queue;
 
-_func_enter_;
 	if (pxmitbuf == NULL)
 		return _FAIL;
 
@@ -1377,7 +1345,6 @@ _func_enter_;
 		spin_unlock_irqrestore(&pfree_xmitbuf_queue->lock, irql);
 	}
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -1406,7 +1373,6 @@ struct xmit_frame *rtw_alloc_xmitframe(struct xmit_priv *pxmitpriv)/* _queue *pf
 	struct list_head *plist, *phead;
 	struct __queue *pfree_xmit_queue = &pxmitpriv->free_xmit_queue;
 
-_func_enter_;
 
 	spin_lock_bh(&pfree_xmit_queue->lock);
 
@@ -1445,7 +1411,6 @@ _func_enter_;
 
 	spin_unlock_bh(&pfree_xmit_queue->lock);
 
-_func_exit_;
 
 	return pxframe;
 }
@@ -1456,7 +1421,6 @@ s32 rtw_free_xmitframe(struct xmit_priv *pxmitpriv, struct xmit_frame *pxmitfram
 	struct adapter *padapter = pxmitpriv->adapter;
 	struct sk_buff *pndis_pkt = NULL;
 
-_func_enter_;
 
 	if (pxmitframe == NULL) {
 		RT_TRACE(_module_rtl871x_xmit_c_, _drv_err_, ("====== rtw_free_xmitframe():pxmitframe == NULL!!!!!!!!!!\n"));
@@ -1484,7 +1448,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return _SUCCESS;
 }
@@ -1494,7 +1457,6 @@ void rtw_free_xmitframe_queue(struct xmit_priv *pxmitpriv, struct __queue *pfram
 	struct list_head *plist, *phead;
 	struct	xmit_frame	*pxmitframe;
 
-_func_enter_;
 
 	spin_lock_bh(&(pframequeue->lock));
 
@@ -1510,7 +1472,6 @@ _func_enter_;
 	}
 	spin_unlock_bh(&(pframequeue->lock));
 
-_func_exit_;
 }
 
 s32 rtw_xmitframe_enqueue(struct adapter *padapter, struct xmit_frame *pxmitframe)
@@ -1556,7 +1517,6 @@ struct xmit_frame *rtw_dequeue_xframe(struct xmit_priv *pxmitpriv, struct hw_xmi
 	struct registry_priv	*pregpriv = &padapter->registrypriv;
 	int i, inx[4];
 
-_func_enter_;
 
 	inx[0] = 0; inx[1] = 1; inx[2] = 2; inx[3] = 3;
 
@@ -1596,7 +1556,6 @@ _func_enter_;
 	}
 exit:
 	spin_unlock_bh(&pxmitpriv->lock);
-_func_exit_;
 	return pxmitframe;
 }
 
@@ -1604,7 +1563,6 @@ struct tx_servq *rtw_get_sta_pending(struct adapter *padapter, struct sta_info *
 {
 	struct tx_servq *ptxservq;
 
-_func_enter_;
 	switch (up) {
 	case 1:
 	case 2:
@@ -1633,7 +1591,6 @@ _func_enter_;
 	break;
 	}
 
-_func_exit_;
 
 	return ptxservq;
 }
@@ -1652,7 +1609,6 @@ s32 rtw_xmit_classifier(struct adapter *padapter, struct xmit_frame *pxmitframe)
 	struct hw_xmit	*phwxmits =  padapter->xmitpriv.hwxmits;
 	int res = _SUCCESS;
 
-_func_enter_;
 
 	if (pattrib->psta) {
 		psta = pattrib->psta;
@@ -1677,7 +1633,6 @@ _func_enter_;
 	phwxmits[ac_index].accnt++;
 exit:
 
-_func_exit_;
 
 	return res;
 }
@@ -1720,10 +1675,8 @@ void rtw_free_hwxmits(struct adapter *padapter)
 void rtw_init_hwxmits(struct hw_xmit *phwxmit, int entry)
 {
 	int i;
-_func_enter_;
 	for (i = 0; i < entry; i++, phwxmit++)
 		phwxmit->accnt = 0;
-_func_exit_;
 }
 
 static int rtw_br_client_tx(struct adapter *padapter, struct sk_buff **pskb)
diff --git a/drivers/staging/rtl8188eu/hal/hal_intf.c b/drivers/staging/rtl8188eu/hal/hal_intf.c
index 5981404..d75ca7a 100644
--- a/drivers/staging/rtl8188eu/hal/hal_intf.c
+++ b/drivers/staging/rtl8188eu/hal/hal_intf.c
@@ -116,8 +116,6 @@ uint rtw_hal_deinit(struct adapter *adapt)
 {
 	uint	status = _SUCCESS;
 
-_func_enter_;
-
 	status = adapt->HalFunc.hal_deinit(adapt);
 
 	if (status == _SUCCESS)
@@ -125,8 +123,6 @@ _func_enter_;
 	else
 		DBG_88E("\n rtw_hal_deinit: hal_init fail\n");
 
-_func_exit_;
-
 	return status;
 }
 
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
index ca0a708..021e587 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
@@ -72,7 +72,6 @@ static s32 FillH2CCmd_88E(struct adapter *adapt, u8 ElementID, u32 CmdLen, u8 *p
 	u32 h2c_cmd_ex = 0;
 	s32 ret = _FAIL;
 
-_func_enter_;
 
 	if (!adapt->bFWReady) {
 		DBG_88E("FillH2CCmd_88E(): return H2C cmd because fw is not ready\n");
@@ -125,7 +124,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 
 	return ret;
 }
@@ -134,7 +132,6 @@ u8 rtl8188e_set_rssi_cmd(struct adapter *adapt, u8 *param)
 {
 	u8 res = _SUCCESS;
 	struct hal_data_8188e *haldata = GET_HAL_DATA(adapt);
-_func_enter_;
 
 	if (haldata->fw_ractrl) {
 		;
@@ -143,7 +140,6 @@ _func_enter_;
 		res = _FAIL;
 	}
 
-_func_exit_;
 
 	return res;
 }
@@ -154,7 +150,6 @@ u8 rtl8188e_set_raid_cmd(struct adapter *adapt, u32 mask)
 	u8 res = _SUCCESS;
 	struct hal_data_8188e *haldata = GET_HAL_DATA(adapt);
 
-_func_enter_;
 	if (haldata->fw_ractrl) {
 		__le32 lmask;
 
@@ -168,7 +163,6 @@ _func_enter_;
 		res = _FAIL;
 	}
 
-_func_exit_;
 
 	return res;
 }
@@ -215,7 +209,6 @@ void rtl8188e_set_FwPwrMode_cmd(struct adapter *adapt, u8 Mode)
 	struct setpwrmode_parm H2CSetPwrMode;
 	struct pwrctrl_priv *pwrpriv = &adapt->pwrctrlpriv;
 	u8 RLBM = 0; /*  0:Min, 1:Max, 2:User define */
-_func_enter_;
 
 	DBG_88E("%s: Mode=%d SmartPS=%d UAPSD=%d\n", __func__,
 		Mode, pwrpriv->smart_ps, adapt->registrypriv.uapsd_enable);
@@ -256,7 +249,6 @@ _func_enter_;
 
 	FillH2CCmd_88E(adapt, H2C_PS_PWR_MODE, sizeof(H2CSetPwrMode), (u8 *)&H2CSetPwrMode);
 
-_func_exit_;
 }
 
 void rtl8188e_set_FwMediaStatus_cmd(struct adapter *adapt, __le16 mstatus_rpt)
@@ -617,7 +609,6 @@ void rtl8188e_set_FwJoinBssReport_cmd(struct adapter *adapt, u8 mstatus)
 	u8 DLBcnCount = 0;
 	u32 poll = 0;
 
-_func_enter_;
 
 	DBG_88E("%s mstatus(%x)\n", __func__, mstatus);
 
@@ -701,7 +692,6 @@ _func_enter_;
 		haldata->RegCR_1 &= (~BIT0);
 		rtw_write8(adapt,  REG_CR+1, haldata->RegCR_1);
 	}
-_func_exit_;
 }
 
 void rtl8188e_set_p2p_ps_offload_cmd(struct adapter *adapt, u8 p2p_ps_state)
@@ -712,7 +702,6 @@ void rtl8188e_set_p2p_ps_offload_cmd(struct adapter *adapt, u8 p2p_ps_state)
 	struct P2P_PS_Offload_t	*p2p_ps_offload = &haldata->p2p_ps_offload;
 	u8 i;
 
-_func_enter_;
 
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
@@ -775,5 +764,4 @@ _func_enter_;
 	FillH2CCmd_88E(adapt, H2C_PS_P2P_OFFLOAD, 1, (u8 *)p2p_ps_offload);
 #endif
 
-_func_exit_;
 }
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c b/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
index 4c934e2..cf88bf2 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
@@ -160,7 +160,6 @@ void rtl8188e_HalDmWatchDog(struct adapter *Adapter)
 	u8 hw_init_completed = false;
 	struct hal_data_8188e *hal_data = GET_HAL_DATA(Adapter);
 
-	_func_enter_;
 	hw_init_completed = Adapter->hw_init_completed;
 
 	if (!hw_init_completed)
@@ -178,7 +177,6 @@ void rtl8188e_HalDmWatchDog(struct adapter *Adapter)
 		/*  Calculate Tx/Rx statistics. */
 		dm_CheckStatistics(Adapter);
 
-	_func_exit_;
 	}
 
 	/* ODM */
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
index 5248995..13c0619 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
@@ -708,10 +708,8 @@ void rtl8188e_InitializeFirmwareVars(struct adapter *padapter)
 
 static void rtl8188e_free_hal_data(struct adapter *padapter)
 {
-_func_enter_;
 	kfree(padapter->HalData);
 	padapter->HalData = NULL;
-_func_exit_;
 }
 
 /*  */
diff --git a/drivers/staging/rtl8188eu/hal/usb_halinit.c b/drivers/staging/rtl8188eu/hal/usb_halinit.c
index b24ad49..c92067f 100644
--- a/drivers/staging/rtl8188eu/hal/usb_halinit.c
+++ b/drivers/staging/rtl8188eu/hal/usb_halinit.c
@@ -709,7 +709,6 @@ static u32 rtl8188eu_hal_init(struct adapter *Adapter)
 
 	#define HAL_INIT_PROFILE_TAG(stage) do {} while (0)
 
-_func_enter_;
 
 	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_BEGIN);
 
@@ -967,7 +966,6 @@ HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_END);
 
 	DBG_88E("%s in %dms\n", __func__, rtw_get_passing_time_ms(init_start_time));
 
-_func_exit_;
 
 	return status;
 }
@@ -1084,7 +1082,6 @@ static unsigned int rtl8188eu_inirp_init(struct adapter *Adapter)
 	struct recv_priv *precvpriv = &(Adapter->recvpriv);
 	u32 (*_read_port)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *pmem);
 
-_func_enter_;
 
 	_read_port = pintfhdl->io_ops._read_port;
 
@@ -1112,7 +1109,6 @@ exit:
 
 	RT_TRACE(_module_hci_hal_init_c_, _drv_info_, ("<=== usb_inirp_init\n"));
 
-_func_exit_;
 
 	return status;
 }
@@ -1402,7 +1398,6 @@ static void SetHwReg8188EU(struct adapter *Adapter, u8 variable, u8 *val)
 	struct hal_data_8188e	*haldata = GET_HAL_DATA(Adapter);
 	struct dm_priv	*pdmpriv = &haldata->dmpriv;
 	struct odm_dm_struct *podmpriv = &haldata->odmpriv;
-_func_enter_;
 
 	switch (variable) {
 	case HW_VAR_MEDIA_STATUS:
@@ -1921,14 +1916,12 @@ _func_enter_;
 	default:
 		break;
 	}
-_func_exit_;
 }
 
 static void GetHwReg8188EU(struct adapter *Adapter, u8 variable, u8 *val)
 {
 	struct hal_data_8188e	*haldata = GET_HAL_DATA(Adapter);
 	struct odm_dm_struct *podmpriv = &haldata->odmpriv;
-_func_enter_;
 
 	switch (variable) {
 	case HW_VAR_BASIC_RATE:
@@ -1980,7 +1973,6 @@ _func_enter_;
 		break;
 	}
 
-_func_exit_;
 }
 
 /*  */
@@ -2302,7 +2294,6 @@ void rtl8188eu_set_hal_ops(struct adapter *adapt)
 {
 	struct hal_ops	*halfunc = &adapt->HalFunc;
 
-_func_enter_;
 
 	adapt->HalData = rtw_zmalloc(sizeof(struct hal_data_8188e));
 	if (adapt->HalData == NULL)
@@ -2342,5 +2333,4 @@ _func_enter_;
 	halfunc->interface_ps_func = &rtl8188eu_ps_func;
 
 	rtl8188e_set_hal_ops(halfunc);
-_func_exit_;
 }
diff --git a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
index 31ae21a..74ee2e6 100644
--- a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
@@ -125,7 +125,6 @@ static u8 usb_read8(struct intf_hdl *pintfhdl, u32 addr)
 	u16 len;
 	u8 data = 0;
 
-	_func_enter_;
 
 	request = 0x05;
 	requesttype = 0x01;/* read_in */
@@ -136,7 +135,6 @@ static u8 usb_read8(struct intf_hdl *pintfhdl, u32 addr)
 
 	usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, requesttype);
 
-	_func_exit_;
 
 	return data;
 
@@ -151,14 +149,12 @@ static u16 usb_read16(struct intf_hdl *pintfhdl, u32 addr)
 	u16 len;
 	__le32 data;
 
-_func_enter_;
 	request = 0x05;
 	requesttype = 0x01;/* read_in */
 	index = 0;/* n/a */
 	wvalue = (u16)(addr&0x0000ffff);
 	len = 2;
 	usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, requesttype);
-_func_exit_;
 
 	return (u16)(le32_to_cpu(data)&0xffff);
 }
@@ -172,7 +168,6 @@ static u32 usb_read32(struct intf_hdl *pintfhdl, u32 addr)
 	u16 len;
 	__le32 data;
 
-_func_enter_;
 
 	request = 0x05;
 	requesttype = 0x01;/* read_in */
@@ -183,7 +178,6 @@ _func_enter_;
 
 	usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, requesttype);
 
-_func_exit_;
 
 	return le32_to_cpu(data);
 }
@@ -198,7 +192,6 @@ static int usb_write8(struct intf_hdl *pintfhdl, u32 addr, u8 val)
 	u8 data;
 	int ret;
 
-	_func_enter_;
 	request = 0x05;
 	requesttype = 0x00;/* write_out */
 	index = 0;/* n/a */
@@ -206,7 +199,6 @@ static int usb_write8(struct intf_hdl *pintfhdl, u32 addr, u8 val)
 	len = 1;
 	data = val;
 	ret = usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, requesttype);
-	_func_exit_;
 	return ret;
 }
 
@@ -220,7 +212,6 @@ static int usb_write16(struct intf_hdl *pintfhdl, u32 addr, u16 val)
 	__le32 data;
 	int ret;
 
-	_func_enter_;
 
 	request = 0x05;
 	requesttype = 0x00;/* write_out */
@@ -233,7 +224,6 @@ static int usb_write16(struct intf_hdl *pintfhdl, u32 addr, u16 val)
 
 	ret = usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, requesttype);
 
-	_func_exit_;
 
 	return ret;
 }
@@ -248,7 +238,6 @@ static int usb_write32(struct intf_hdl *pintfhdl, u32 addr, u32 val)
 	__le32 data;
 	int ret;
 
-	_func_enter_;
 
 	request = 0x05;
 	requesttype = 0x00;/* write_out */
@@ -260,7 +249,6 @@ static int usb_write32(struct intf_hdl *pintfhdl, u32 addr, u32 val)
 
 	ret = usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, requesttype);
 
-	_func_exit_;
 
 	return ret;
 }
@@ -275,7 +263,6 @@ static int usb_writeN(struct intf_hdl *pintfhdl, u32 addr, u32 length, u8 *pdata
 	u8 buf[VENDOR_CMD_MAX_DATA_LEN] = {0};
 	int ret;
 
-	_func_enter_;
 
 	request = 0x05;
 	requesttype = 0x00;/* write_out */
@@ -287,7 +274,6 @@ static int usb_writeN(struct intf_hdl *pintfhdl, u32 addr, u32 length, u8 *pdata
 
 	ret = usbctrl_vendorreq(pintfhdl, request, wvalue, index, buf, len, requesttype);
 
-	_func_exit_;
 
 	return ret;
 }
@@ -519,7 +505,7 @@ static void usb_read_port_complete(struct urb *purb, struct pt_regs *regs)
 		DBG_88E("%s() RX Warning! bDriverStopped(%d) OR bSurpriseRemoved(%d) bReadPortCancel(%d)\n",
 			__func__, adapt->bDriverStopped,
 			adapt->bSurpriseRemoved, adapt->bReadPortCancel);
-		goto exit;
+		return;
 	}
 
 	if (purb->status == 0) { /* SUCCESS */
@@ -579,9 +565,6 @@ static void usb_read_port_complete(struct urb *purb, struct pt_regs *regs)
 			break;
 		}
 	}
-
-exit:
-_func_exit_;
 }
 
 static u32 usb_read_port(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *rmem)
@@ -598,7 +581,6 @@ static u32 usb_read_port(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *rmem)
 	size_t alignment = 0;
 	u32 ret = _SUCCESS;
 
-_func_enter_;
 
 	if (adapter->bDriverStopped || adapter->bSurpriseRemoved ||
 	    adapter->pwrctrlpriv.pnp_bstop_trx) {
@@ -672,7 +654,6 @@ _func_enter_;
 		ret = _FAIL;
 	}
 
-_func_exit_;
 	return ret;
 }
 
@@ -702,7 +683,6 @@ void rtl8188eu_xmit_tasklet(void *priv)
 
 void rtl8188eu_set_intf_ops(struct _io_ops	*pops)
 {
-	_func_enter_;
 	_rtw_memset((u8 *)pops, 0, sizeof(struct _io_ops));
 	pops->_read8 = &usb_read8;
 	pops->_read16 = &usb_read16;
@@ -717,7 +697,6 @@ void rtl8188eu_set_intf_ops(struct _io_ops	*pops)
 	pops->_write_port = &usb_write_port;
 	pops->_read_port_cancel = &usb_read_port_cancel;
 	pops->_write_port_cancel = &usb_write_port_cancel;
-	_func_exit_;
 }
 
 void rtl8188eu_set_hw_type(struct adapter *adapt)
diff --git a/drivers/staging/rtl8188eu/include/rtw_debug.h b/drivers/staging/rtl8188eu/include/rtw_debug.h
index c6b193a..1cdc07d 100644
--- a/drivers/staging/rtl8188eu/include/rtw_debug.h
+++ b/drivers/staging/rtl8188eu/include/rtw_debug.h
@@ -99,20 +99,6 @@ extern u32 GlobalDebugLevel;
 		}							\
 	} while (0)
 
-#define _func_enter_							\
-	do {								\
-		if (GlobalDebugLevel >= _drv_debug_)			\
-			pr_info("%s : %s enters at %d\n",		\
-				 DRIVER_PREFIX, __func__, __LINE__);	\
-	} while (0)
-
-#define _func_exit_							\
-	do {								\
-		if (GlobalDebugLevel >= _drv_debug_)			\
-			pr_info("%s : %s exits at %d\n",		\
-				 DRIVER_PREFIX, __func__, __LINE__);	\
-	} while (0)
-
 #define RT_PRINT_DATA(_comp, _level, _titlestring, _hexdata, _hexdatalen)\
 	do {								\
 		if (_level <= GlobalDebugLevel) {			\
diff --git a/drivers/staging/rtl8188eu/include/rtw_ioctl.h b/drivers/staging/rtl8188eu/include/rtw_ioctl.h
index 8772d1d..f3aa924 100644
--- a/drivers/staging/rtl8188eu/include/rtw_ioctl.h
+++ b/drivers/staging/rtl8188eu/include/rtw_ioctl.h
@@ -102,8 +102,6 @@ struct oid_obj_priv {
 
 #if defined(_RTW_MP_IOCTL_C_)
 static int oid_null_function(struct oid_par_priv *poid_par_priv) {
-	_func_enter_;
-	_func_exit_;
 	return NDIS_STATUS_SUCCESS;
 }
 #endif
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index 08be34e..7de8139 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -473,8 +473,6 @@ static int wpa_set_encryption(struct net_device *dev, struct ieee_param *param,
 	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
 #endif /* CONFIG_88EU_P2P */
 
-_func_enter_;
-
 	param->u.crypt.err = 0;
 	param->u.crypt.alg[IEEE_CRYPT_ALG_NAME_LEN - 1] = '\0';
 
@@ -615,9 +613,6 @@ _func_enter_;
 exit:
 
 	kfree(pwep);
-
-_func_exit_;
-
 	return ret;
 }
 
@@ -771,8 +766,6 @@ static int rtw_wx_get_name(struct net_device *dev,
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("cmd_code =%x\n", info->cmd));
 
-	_func_enter_;
-
 	if (check_fwstate(pmlmepriv, _FW_LINKED|WIFI_ADHOC_MASTER_STATE) == true) {
 		/* parsing HT_CAP_IE */
 		p = rtw_get_ie(&pcur_bss->IEs[12], _HT_CAPABILITY_IE_, &ht_ielen, pcur_bss->IELength-12);
@@ -807,9 +800,6 @@ static int rtw_wx_get_name(struct net_device *dev,
 	} else {
 		snprintf(wrqu->name, IFNAMSIZ, "unassociated");
 	}
-
-	_func_exit_;
-
 	return 0;
 }
 
@@ -817,12 +807,7 @@ static int rtw_wx_set_freq(struct net_device *dev,
 			     struct iw_request_info *info,
 			     union iwreq_data *wrqu, char *extra)
 {
-	_func_enter_;
-
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_notice_, ("+rtw_wx_set_freq\n"));
-
-	_func_exit_;
-
 	return 0;
 }
 
@@ -855,8 +840,6 @@ static int rtw_wx_set_mode(struct net_device *dev, struct iw_request_info *a,
 	enum ndis_802_11_network_infra networkType;
 	int ret = 0;
 
-	_func_enter_;
-
 	if (_FAIL == rtw_pwr_wakeup(padapter)) {
 		ret = -EPERM;
 		goto exit;
@@ -895,7 +878,6 @@ static int rtw_wx_set_mode(struct net_device *dev, struct iw_request_info *a,
 	}
 	rtw_setopmode_cmd(padapter, networkType);
 exit:
-	_func_exit_;
 	return ret;
 }
 
@@ -907,8 +889,6 @@ static int rtw_wx_get_mode(struct net_device *dev, struct iw_request_info *a,
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, (" rtw_wx_get_mode\n"));
 
-	_func_enter_;
-
 	if (check_fwstate(pmlmepriv, WIFI_STATION_STATE))
 		wrqu->mode = IW_MODE_INFRA;
 	else if  ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) ||
@@ -919,8 +899,6 @@ static int rtw_wx_get_mode(struct net_device *dev, struct iw_request_info *a,
 	else
 		wrqu->mode = IW_MODE_AUTO;
 
-	_func_exit_;
-
 	return 0;
 }
 
@@ -1012,8 +990,6 @@ static int rtw_wx_get_range(struct net_device *dev,
 	u16 val;
 	int i;
 
-	_func_enter_;
-
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("rtw_wx_get_range. cmd_code =%x\n", info->cmd));
 
 	wrqu->data.length = sizeof(*range);
@@ -1094,8 +1070,6 @@ static int rtw_wx_get_range(struct net_device *dev,
 	range->scan_capa = IW_SCAN_CAPA_ESSID | IW_SCAN_CAPA_TYPE |
 			   IW_SCAN_CAPA_BSSID | IW_SCAN_CAPA_CHANNEL |
 			   IW_SCAN_CAPA_MODE | IW_SCAN_CAPA_RATE;
-	_func_exit_;
-
 	return 0;
 }
 
@@ -1119,8 +1093,6 @@ static int rtw_wx_set_wap(struct net_device *dev,
 	struct	wlan_network	*pnetwork = NULL;
 	enum ndis_802_11_auth_mode	authmode;
 
-	_func_enter_;
-
 	if (_FAIL == rtw_pwr_wakeup(padapter)) {
 		ret = -1;
 		goto exit;
@@ -1174,8 +1146,6 @@ static int rtw_wx_set_wap(struct net_device *dev,
 
 exit:
 
-	_func_exit_;
-
 	return ret;
 }
 
@@ -1193,17 +1163,12 @@ static int rtw_wx_get_wap(struct net_device *dev,
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("rtw_wx_get_wap\n"));
 
-	_func_enter_;
-
 	if (((check_fwstate(pmlmepriv, _FW_LINKED)) == true) ||
 	    ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) == true) ||
 	    ((check_fwstate(pmlmepriv, WIFI_AP_STATE)) == true))
 		memcpy(wrqu->ap_addr.sa_data, pcur_bss->MacAddress, ETH_ALEN);
 	else
 		_rtw_memset(wrqu->ap_addr.sa_data, 0, ETH_ALEN);
-
-	_func_exit_;
-
 	return 0;
 }
 
@@ -1253,7 +1218,6 @@ static int rtw_wx_set_scan(struct net_device *dev, struct iw_request_info *a,
 #endif /* CONFIG_88EU_P2P */
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("rtw_wx_set_scan\n"));
 
-_func_enter_;
 	if (padapter->registrypriv.mp_mode == 1) {
 		if (check_fwstate(pmlmepriv, WIFI_MP_STATE)) {
 			ret = -1;
@@ -1384,7 +1348,6 @@ _func_enter_;
 
 exit:
 
-_func_exit_;
 	return ret;
 }
 
@@ -1408,8 +1371,6 @@ static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("rtw_wx_get_scan\n"));
 	RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_info_, (" Start of Query SIOCGIWSCAN .\n"));
 
-	_func_enter_;
-
 	if (padapter->pwrctrlpriv.brfoffbyhw && padapter->bDriverStopped) {
 		ret = -EINVAL;
 		goto exit;
@@ -1467,7 +1428,6 @@ static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 	wrqu->data.flags = 0;
 
 exit:
-	_func_exit_;
 	return ret;
 }
 
@@ -1491,7 +1451,6 @@ static int rtw_wx_set_essid(struct net_device *dev,
 
 	uint ret = 0, len;
 
-	_func_enter_;
 
 	RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_info_,
 		 ("+rtw_wx_set_essid: fw_state = 0x%08x\n", get_fwstate(pmlmepriv)));
@@ -1584,7 +1543,6 @@ exit:
 
 	DBG_88E("<=%s, ret %d\n", __func__, ret);
 
-	_func_exit_;
 
 	return ret;
 }
@@ -1600,7 +1558,6 @@ static int rtw_wx_get_essid(struct net_device *dev,
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("rtw_wx_get_essid\n"));
 
-	_func_enter_;
 
 	if ((check_fwstate(pmlmepriv, _FW_LINKED)) ||
 	    (check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE))) {
@@ -1618,7 +1575,6 @@ static int rtw_wx_get_essid(struct net_device *dev,
 
 exit:
 
-	_func_exit_;
 
 	return ret;
 }
@@ -1635,7 +1591,6 @@ static int rtw_wx_set_rate(struct net_device *dev,
 	u32	ratevalue = 0;
 	 u8 mpdatarate[NumRates] = {11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 0xff};
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, (" rtw_wx_set_rate\n"));
 	RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_info_, ("target_rate = %d, fixed = %d\n", target_rate, fixed));
@@ -1707,7 +1662,6 @@ set_rate:
 		ret = -1;
 	}
 
-_func_exit_;
 
 	return ret;
 }
@@ -1735,7 +1689,6 @@ static int rtw_wx_set_rts(struct net_device *dev,
 {
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 
-	_func_enter_;
 
 	if (wrqu->rts.disabled) {
 		padapter->registrypriv.rts_thresh = 2347;
@@ -1749,7 +1702,6 @@ static int rtw_wx_set_rts(struct net_device *dev,
 
 	DBG_88E("%s, rts_thresh =%d\n", __func__, padapter->registrypriv.rts_thresh);
 
-	_func_exit_;
 
 	return 0;
 }
@@ -1760,7 +1712,6 @@ static int rtw_wx_get_rts(struct net_device *dev,
 {
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 
-	_func_enter_;
 
 	DBG_88E("%s, rts_thresh =%d\n", __func__, padapter->registrypriv.rts_thresh);
 
@@ -1768,7 +1719,6 @@ static int rtw_wx_get_rts(struct net_device *dev,
 	wrqu->rts.fixed = 0;	/* no auto select */
 	/* wrqu->rts.disabled = (wrqu->rts.value == DEFAULT_RTS_THRESHOLD); */
 
-	_func_exit_;
 
 	return 0;
 }
@@ -1779,7 +1729,6 @@ static int rtw_wx_set_frag(struct net_device *dev,
 {
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 
-	_func_enter_;
 
 	if (wrqu->frag.disabled) {
 		padapter->xmitpriv.frag_len = MAX_FRAG_THRESHOLD;
@@ -1793,7 +1742,6 @@ static int rtw_wx_set_frag(struct net_device *dev,
 
 	DBG_88E("%s, frag_len =%d\n", __func__, padapter->xmitpriv.frag_len);
 
-	_func_exit_;
 
 	return 0;
 }
@@ -1804,14 +1752,12 @@ static int rtw_wx_get_frag(struct net_device *dev,
 {
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 
-	_func_enter_;
 
 	DBG_88E("%s, frag_len =%d\n", __func__, padapter->xmitpriv.frag_len);
 
 	wrqu->frag.value = padapter->xmitpriv.frag_len;
 	wrqu->frag.fixed = 0;	/* no auto select */
 
-	_func_exit_;
 
 	return 0;
 }
@@ -1845,7 +1791,6 @@ static int rtw_wx_set_enc(struct net_device *dev,
 
 	key = erq->flags & IW_ENCODE_INDEX;
 
-	_func_enter_;
 
 	if (erq->flags & IW_ENCODE_DISABLED) {
 		DBG_88E("EncryptionDisabled\n");
@@ -1940,7 +1885,6 @@ static int rtw_wx_set_enc(struct net_device *dev,
 
 exit:
 
-	_func_exit_;
 
 	return ret;
 }
@@ -1954,7 +1898,6 @@ static int rtw_wx_get_enc(struct net_device *dev,
 	struct iw_point *erq = &(wrqu->encoding);
 	struct	mlme_priv	*pmlmepriv = &(padapter->mlmepriv);
 
-	_func_enter_;
 
 	if (check_fwstate(pmlmepriv, _FW_LINKED) != true) {
 		if (!check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) {
@@ -2008,7 +1951,6 @@ static int rtw_wx_get_enc(struct net_device *dev,
 		erq->flags |= IW_ENCODE_DISABLED;
 		break;
 	}
-	_func_exit_;
 
 	return ret;
 }
diff --git a/drivers/staging/rtl8188eu/os_dep/mlme_linux.c b/drivers/staging/rtl8188eu/os_dep/mlme_linux.c
index 57d1ff7..0624378 100644
--- a/drivers/staging/rtl8188eu/os_dep/mlme_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/mlme_linux.c
@@ -61,12 +61,10 @@ void rtw_init_mlme_timer(struct adapter *padapter)
 
 void rtw_os_indicate_connect(struct adapter *adapter)
 {
-_func_enter_;
 	rtw_indicate_wx_assoc_event(adapter);
 	netif_carrier_on(adapter->pnetdev);
 	if (adapter->pid[2] != 0)
 		rtw_signal_process(adapter->pid[2], SIGALRM);
-_func_exit_;
 }
 
 void rtw_os_indicate_scan_done(struct adapter *padapter, bool aborted)
@@ -119,11 +117,9 @@ void rtw_reset_securitypriv(struct adapter *adapter)
 
 void rtw_os_indicate_disconnect(struct adapter *adapter)
 {
-_func_enter_;
 	netif_carrier_off(adapter->pnetdev); /*  Do it first for tx broadcast pkt after disconnection issue! */
 	rtw_indicate_wx_disassoc_event(adapter);
 	 rtw_reset_securitypriv(adapter);
-_func_exit_;
 }
 
 void rtw_report_sec_ie(struct adapter *adapter, u8 authmode, u8 *sec_ie)
@@ -132,7 +128,6 @@ void rtw_report_sec_ie(struct adapter *adapter, u8 authmode, u8 *sec_ie)
 	u8	*buff, *p, i;
 	union iwreq_data wrqu;
 
-_func_enter_;
 	RT_TRACE(_module_mlme_osdep_c_, _drv_info_,
 		 ("+rtw_report_sec_ie, authmode=%d\n", authmode));
 	buff = NULL;
@@ -141,7 +136,7 @@ _func_enter_;
 			 ("rtw_report_sec_ie, authmode=%d\n", authmode));
 		buff = rtw_malloc(IW_CUSTOM_MAX);
 		if (!buff)
-			goto exit;
+			return;
 		_rtw_memset(buff, 0, IW_CUSTOM_MAX);
 		p = buff;
 		p += sprintf(p, "ASSOCINFO(ReqIEs =");
@@ -157,8 +152,6 @@ _func_enter_;
 		wireless_send_event(adapter->pnetdev, IWEVCUSTOM, &wrqu, buff);
 		kfree(buff);
 	}
-exit:
-_func_exit_;
 }
 
 static void _survey_timer_hdl(void *FunctionContext)
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index 68f98fa..cf4107a 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -520,7 +520,6 @@ static uint loadparam(struct adapter *padapter,  struct  net_device *pnetdev)
 	uint status = _SUCCESS;
 	struct registry_priv  *registry_par = &padapter->registrypriv;
 
-_func_enter_;
 
 	GlobalDebugLevel = rtw_debug;
 	registry_par->chip_version = (u8)rtw_chip_version;
@@ -588,7 +587,6 @@ _func_enter_;
 	snprintf(registry_par->ifname, 16, "%s", ifname);
 	snprintf(registry_par->if2name, 16, "%s", if2name);
 	registry_par->notch_filter = (u8)rtw_notch_filter;
-_func_exit_;
 	return status;
 }
 
@@ -855,7 +853,6 @@ u8 rtw_init_drv_sw(struct adapter *padapter)
 {
 	u8	ret8 = _SUCCESS;
 
-_func_enter_;
 
 	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+rtw_init_drv_sw\n"));
 
@@ -930,7 +927,6 @@ _func_enter_;
 exit:
 	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("-rtw_init_drv_sw\n"));
 
-	_func_exit_;
 
 	return ret8;
 }
diff --git a/drivers/staging/rtl8188eu/os_dep/recv_linux.c b/drivers/staging/rtl8188eu/os_dep/recv_linux.c
index 989b7f1..fd8ca60 100644
--- a/drivers/staging/rtl8188eu/os_dep/recv_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/recv_linux.c
@@ -130,7 +130,6 @@ int rtw_recv_indicatepkt(struct adapter *padapter,
 	struct sk_buff *skb;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-_func_enter_;
 
 	precvpriv = &(padapter->recvpriv);
 	pfree_recv_queue = &(precvpriv->free_recv_queue);
@@ -216,7 +215,6 @@ _recv_indicatepkt_end:
 	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
 		 ("\n rtw_recv_indicatepkt :after netif_rx!!!!\n"));
 
-_func_exit_;
 
 	return _SUCCESS;
 
@@ -225,7 +223,6 @@ _recv_indicatepkt_drop:
 	 /* enqueue back to free_recv_queue */
 	rtw_free_recvframe(precv_frame, pfree_recv_queue);
 
-_func_exit_;
 	 return _FAIL;
 }
 
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 8ad3948..eba5370 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -162,7 +162,6 @@ static struct dvobj_priv *usb_dvobj_init(struct usb_interface *usb_intf)
 	struct usb_endpoint_descriptor	*pendp_desc;
 	struct usb_device	*pusbd;
 
-_func_enter_;
 
 	pdvobjpriv = (struct dvobj_priv *)rtw_zmalloc(sizeof(*pdvobjpriv));
 	if (pdvobjpriv == NULL)
@@ -255,7 +254,6 @@ free_dvobj:
 		pdvobjpriv = NULL;
 	}
 exit:
-_func_exit_;
 	return pdvobjpriv;
 }
 
@@ -263,7 +261,6 @@ static void usb_dvobj_deinit(struct usb_interface *usb_intf)
 {
 	struct dvobj_priv *dvobj = usb_get_intfdata(usb_intf);
 
-_func_enter_;
 
 	usb_set_intfdata(usb_intf, NULL);
 	if (dvobj) {
@@ -288,7 +285,6 @@ _func_enter_;
 
 	usb_put_dev(interface_to_usbdev(usb_intf));
 
-_func_exit_;
 }
 
 static void chip_by_usb_id(struct adapter *padapter,
@@ -390,7 +386,6 @@ int rtw_hw_suspend(struct adapter *padapter)
 	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
 	struct net_device *pnetdev = padapter->pnetdev;
 
-	_func_enter_;
 
 	if ((!padapter->bup) || (padapter->bDriverStopped) ||
 	    (padapter->bSurpriseRemoved)) {
@@ -443,7 +438,6 @@ int rtw_hw_suspend(struct adapter *padapter)
 	} else {
 		goto error_exit;
 	}
-	_func_exit_;
 	return 0;
 
 error_exit:
@@ -456,7 +450,6 @@ int rtw_hw_resume(struct adapter *padapter)
 	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
 	struct net_device *pnetdev = padapter->pnetdev;
 
-	_func_enter_;
 
 	if (padapter) { /* system resume */
 		DBG_88E("==> rtw_hw_resume\n");
@@ -488,7 +481,6 @@ int rtw_hw_resume(struct adapter *padapter)
 		goto error_exit;
 	}
 
-	_func_exit_;
 
 	return 0;
 error_exit:
@@ -507,7 +499,6 @@ static int rtw_suspend(struct usb_interface *pusb_intf, pm_message_t message)
 	int ret = 0;
 	u32 start_time = jiffies;
 
-	_func_enter_;
 
 	DBG_88E("==> %s (%s:%d)\n", __func__, current->comm, current->pid);
 
@@ -564,7 +555,6 @@ exit:
 	DBG_88E("<===  %s return %d.............. in %dms\n", __func__
 		, ret, rtw_get_passing_time_ms(start_time));
 
-	_func_exit_;
 	return ret;
 }
 
@@ -588,7 +578,6 @@ int rtw_resume_process(struct adapter *padapter)
 	struct pwrctrl_priv *pwrpriv = NULL;
 	int ret = -1;
 	u32 start_time = jiffies;
-	_func_enter_;
 
 	DBG_88E("==> %s (%s:%d)\n", __func__, current->comm, current->pid);
 
@@ -627,7 +616,6 @@ exit:
 	DBG_88E("<===  %s return %d.............. in %dms\n", __func__,
 		ret, rtw_get_passing_time_ms(start_time));
 
-	_func_exit_;
 
 	return ret;
 }
@@ -836,7 +824,6 @@ static void rtw_dev_remove(struct usb_interface *pusb_intf)
 	struct dvobj_priv *dvobj = usb_get_intfdata(pusb_intf);
 	struct adapter *padapter = dvobj->if1;
 
-_func_enter_;
 
 	DBG_88E("+rtw_dev_remove\n");
 	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+dev_remove()\n"));
@@ -855,7 +842,6 @@ _func_enter_;
 
 	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("-dev_remove()\n"));
 	DBG_88E("-r871xu_dev_remove, done\n");
-_func_exit_;
 
 	return;
 }
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c b/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
index 7e3f2fa..fb0bba8 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
@@ -80,7 +80,6 @@ static void usb_write_port_complete(struct urb *purb, struct pt_regs *regs)
 	struct xmit_priv	*pxmitpriv = &padapter->xmitpriv;
 	struct hal_data_8188e	*haldata;
 
-_func_enter_;
 
 	switch (pxmitbuf->flags) {
 	case VO_QUEUE_INX:
@@ -156,8 +155,6 @@ check_completion:
 	rtw_free_xmitbuf(pxmitpriv, pxmitbuf);
 
 	tasklet_hi_schedule(&pxmitpriv->xmit_tasklet);
-
-_func_exit_;
 }
 
 u32 usb_write_port(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *wmem)
@@ -174,7 +171,6 @@ u32 usb_write_port(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *wmem)
 	struct xmit_frame *pxmitframe = (struct xmit_frame *)pxmitbuf->priv_data;
 	struct usb_device *pusbd = pdvobj->pusbdev;
 
-_func_enter_;
 
 	RT_TRACE(_module_hci_ops_os_c_, _drv_err_, ("+usb_write_port\n"));
 
@@ -255,7 +251,6 @@ _func_enter_;
 exit:
 	if (ret != _SUCCESS)
 		rtw_free_xmitbuf(pxmitpriv, pxmitbuf);
-_func_exit_;
 	return ret;
 }
 
diff --git a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
index a84a8b9..07ba90d 100644
--- a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
@@ -39,7 +39,6 @@ uint rtw_remainder_len(struct pkt_file *pfile)
 
 void _rtw_open_pktfile(struct sk_buff *pktptr, struct pkt_file *pfile)
 {
-_func_enter_;
 
 	pfile->pkt = pktptr;
 	pfile->cur_addr = pktptr->data;
@@ -49,14 +48,12 @@ _func_enter_;
 
 	pfile->cur_buffer = pfile->buf_start;
 
-_func_exit_;
 }
 
 uint _rtw_pktfile_read (struct pkt_file *pfile, u8 *rmem, uint rlen)
 {
 	uint	len = 0;
 
-_func_enter_;
 
 	len =  rtw_remainder_len(pfile);
 	len = (rlen > len) ? len : rlen;
@@ -67,21 +64,17 @@ _func_enter_;
 	pfile->cur_addr += len;
 	pfile->pkt_len -= len;
 
-_func_exit_;
 
 	return len;
 }
 
 int rtw_endofpktfile(struct pkt_file *pfile)
 {
-_func_enter_;
 
 	if (pfile->pkt_len == 0) {
-	_func_exit_;
 		return true;
 	}
 
-_func_exit_;
 
 	return false;
 }
@@ -246,7 +239,6 @@ int rtw_xmit_entry(struct sk_buff *pkt, struct  net_device *pnetdev)
 	struct mlme_priv	*pmlmepriv = &padapter->mlmepriv;
 	s32 res = 0;
 
-_func_enter_;
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("+xmit_enry\n"));
 
@@ -282,7 +274,6 @@ drop_packet:
 
 exit:
 
-_func_exit_;
 
 	return 0;
 }
-- 
1.8.4.5
