From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 09/11] staging: r8188eu: Replace wrappers ODM_sleep_ms() and rtw_msleep_os() with a simple msleep
Date: Thu, 19 Dec 2013 22:38:41 -0600
Message-ID: <1387514323-4486-10-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:55297 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740Ab3LTEl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:41:27 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so2032564pdj.37
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:41:27 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c           |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_mlme.c          |  2 +-
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c      | 16 ++++++++--------
 drivers/staging/rtl8188eu/core/rtw_mp.c            |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c      |  6 +++---
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c       |  2 +-
 drivers/staging/rtl8188eu/core/rtw_xmit.c          |  4 ++--
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     |  2 +-
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c |  6 +++---
 drivers/staging/rtl8188eu/hal/odm_interface.c      |  5 -----
 drivers/staging/rtl8188eu/hal/rtl8188e_mp.c        |  6 +++---
 drivers/staging/rtl8188eu/include/odm_interface.h  |  2 --
 drivers/staging/rtl8188eu/include/osdep_service.h  |  1 -
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c     | 10 +++++-----
 drivers/staging/rtl8188eu/os_dep/osdep_service.c   |  5 -----
 15 files changed, 31 insertions(+), 44 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index 73cb2be..281608b 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -104,7 +104,7 @@ _func_enter_;
 
 	_cancel_workitem_sync(&pevtpriv->c2h_wk);
 	while (pevtpriv->c2h_wk_alive)
-		rtw_msleep_os(10);
+		msleep(10);
 
 	while (!rtw_cbuf_empty(pevtpriv->c2h_queue)) {
 		void *c2h = rtw_cbuf_pop(pevtpriv->c2h_queue);
@@ -1966,7 +1966,7 @@ static void rtw_chk_hi_queue_hdl(struct adapter *padapter)
 		rtw_hal_get_hwreg(padapter, HW_VAR_CHK_HI_QUEUE_EMPTY, &val);
 
 		while (!val) {
-			rtw_msleep_os(100);
+			msleep(100);
 
 			cnt++;
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 6078d03..c738230 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -1060,7 +1060,7 @@ void rtw_scan_abort(struct adapter *adapter)
 		if (adapter->bDriverStopped || adapter->bSurpriseRemoved)
 			break;
 		DBG_88E(FUNC_NDEV_FMT"fw_state=_FW_UNDER_SURVEY!\n", FUNC_NDEV_ARG(adapter->pnetdev));
-		rtw_msleep_os(20);
+		msleep(20);
 	}
 	if (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY)) {
 		if (!adapter->bDriverStopped && !adapter->bSurpriseRemoved)
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index bada209..c189056 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -3833,7 +3833,7 @@ int issue_probereq_p2p_ex(struct adapter *adapter, u8 *da, int try_cnt, int wait
 			break;
 
 		if (i < try_cnt && wait_ms > 0 && ret == _FAIL)
-			rtw_msleep_os(wait_ms);
+			msleep(wait_ms);
 	} while ((i < try_cnt) && ((ret == _FAIL) || (wait_ms == 0)));
 
 	if (ret != _FAIL) {
@@ -4979,7 +4979,7 @@ int issue_probereq_ex(struct adapter *padapter, struct ndis_802_11_ssid *pssid,
 			break;
 
 		if (i < try_cnt && wait_ms > 0 && ret == _FAIL)
-			rtw_msleep_os(wait_ms);
+			msleep(wait_ms);
 
 	} while ((i < try_cnt) && ((ret == _FAIL) || (wait_ms == 0)));
 
@@ -5706,7 +5706,7 @@ int issue_nulldata(struct adapter *padapter, unsigned char *da, unsigned int pow
 			break;
 
 		if (i < try_cnt && wait_ms > 0 && ret == _FAIL)
-			rtw_msleep_os(wait_ms);
+			msleep(wait_ms);
 	} while ((i < try_cnt) && ((ret == _FAIL) || (wait_ms == 0)));
 
 	if (ret != _FAIL) {
@@ -5829,7 +5829,7 @@ int issue_qos_nulldata(struct adapter *padapter, unsigned char *da, u16 tid, int
 			break;
 
 		if (i < try_cnt && wait_ms > 0 && ret == _FAIL)
-			rtw_msleep_os(wait_ms);
+			msleep(wait_ms);
 	} while ((i < try_cnt) && ((ret == _FAIL) || (wait_ms == 0)));
 
 	if (ret != _FAIL) {
@@ -5941,7 +5941,7 @@ int issue_deauth_ex(struct adapter *padapter, u8 *da, unsigned short reason, int
 			break;
 
 		if (i < try_cnt && wait_ms > 0 && ret == _FAIL)
-			rtw_msleep_os(wait_ms);
+			msleep(wait_ms);
 	} while ((i < try_cnt) && ((ret == _FAIL) || (wait_ms == 0)));
 
 	if (ret != _FAIL) {
@@ -6430,7 +6430,7 @@ void site_survey(struct adapter *padapter)
 					if (pmlmeext->sitesurvey_res.ssid[i].SsidLength) {
 						/* todo: to issue two probe req??? */
 						issue_probereq(padapter, &(pmlmeext->sitesurvey_res.ssid[i]), NULL);
-						/* rtw_msleep_os(SURVEY_TO>>1); */
+						/* msleep(SURVEY_TO>>1); */
 						issue_probereq(padapter, &(pmlmeext->sitesurvey_res.ssid[i]), NULL);
 					}
 				}
@@ -6438,7 +6438,7 @@ void site_survey(struct adapter *padapter)
 				if (pmlmeext->sitesurvey_res.scan_mode == SCAN_ACTIVE) {
 					/* todo: to issue two probe req??? */
 					issue_probereq(padapter, NULL, NULL);
-					/* rtw_msleep_os(SURVEY_TO>>1); */
+					/* msleep(SURVEY_TO>>1); */
 					issue_probereq(padapter, NULL, NULL);
 				}
 			}
@@ -8372,7 +8372,7 @@ u8 tx_beacon_hdl(struct adapter *padapter, unsigned char *pbuf)
 			return H2C_SUCCESS;
 
 		if ((pstapriv->tim_bitmap&BIT(0)) && (psta_bmc->sleepq_len > 0)) {
-			rtw_msleep_os(10);/*  10ms, ATIM(HIQ) Windows */
+			msleep(10);/*  10ms, ATIM(HIQ) Windows */
 			spin_lock_bh(&psta_bmc->sleep_q.lock);
 
 			xmitframe_phead = get_list_head(&psta_bmc->sleep_q);
diff --git a/drivers/staging/rtl8188eu/core/rtw_mp.c b/drivers/staging/rtl8188eu/core/rtw_mp.c
index f347354..76c1198 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp.c
@@ -609,7 +609,7 @@ static int mp_xmit_packet_thread(void *context)
 			    padapter->bDriverStopped) {
 				goto exit;
 			} else {
-				rtw_msleep_os(1);
+				msleep(1);
 				continue;
 			}
 		}
@@ -915,7 +915,7 @@ u32 mp_query_psd(struct adapter *pAdapter, u8 *data)
 		i++;
 	}
 
-	rtw_msleep_os(100);
+	msleep(100);
 	return strlen(data)+1;
 }
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c b/drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c
index f06312c..edcd8a5 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c
@@ -690,7 +690,7 @@ _func_enter_;
 		if (pmp_priv->tx.stop == 0) {
 			pmp_priv->tx.stop = 1;
 			DBG_88E("%s: pkt tx is running...\n", __func__);
-			rtw_msleep_os(5);
+			msleep(5);
 		}
 		pmp_priv->tx.stop = 0;
 		pmp_priv->tx.count = 1;
@@ -725,7 +725,7 @@ _func_enter_;
 		if (pmp_priv->tx.stop == 0) {
 			pmp_priv->tx.stop = 1;
 			DBG_88E("%s: pkt tx is running...\n", __func__);
-			rtw_msleep_os(5);
+			msleep(5);
 		}
 		pmp_priv->tx.stop = 0;
 		pmp_priv->tx.count = 1;
@@ -760,7 +760,7 @@ _func_enter_;
 		if (pmp_priv->tx.stop == 0) {
 			pmp_priv->tx.stop = 1;
 			DBG_88E("%s: pkt tx is running...\n", __func__);
-			rtw_msleep_os(5);
+			msleep(5);
 		}
 		pmp_priv->tx.stop = 0;
 		pmp_priv->tx.count = 1;
diff --git a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
index 86b522f..d5ad1dc 100644
--- a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
+++ b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
@@ -569,7 +569,7 @@ int _rtw_pwr_wakeup(struct adapter *padapter, u32 ips_deffer_ms, const char *cal
 	if (pwrpriv->ps_processing) {
 		DBG_88E("%s wait ps_processing...\n", __func__);
 		while (pwrpriv->ps_processing && rtw_get_passing_time_ms(start) <= 3000)
-			rtw_msleep_os(10);
+			msleep(10);
 		if (pwrpriv->ps_processing)
 			DBG_88E("%s wait ps_processing timeout\n", __func__);
 		else
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 4845d96..a457385 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -153,7 +153,7 @@ _func_enter_;
 		/* Tx buf allocation may fail sometimes, so sleep and retry. */
 		res = rtw_os_xmit_resource_alloc(padapter, pxmitbuf, (MAX_XMITBUF_SZ + XMITBUF_ALIGN_SZ));
 		if (res == _FAIL) {
-			rtw_msleep_os(10);
+			msleep(10);
 			res = rtw_os_xmit_resource_alloc(padapter, pxmitbuf, (MAX_XMITBUF_SZ + XMITBUF_ALIGN_SZ));
 			if (res == _FAIL) {
 				goto exit;
@@ -691,7 +691,7 @@ _func_enter_;
 			} else {
 				if (_rtw_memcmp(&stainfo->dot11tkiptxmickey.skey[0], null_key, 16) == true) {
 					/* DbgPrint("\nxmitframe_addmic:stainfo->dot11tkiptxmickey == 0\n"); */
-					/* rtw_msleep_os(10); */
+					/* msleep(10); */
 					return _FAIL;
 				}
 				/* start to calculate the mic code */
diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 8a7947d..650aefc 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -1258,7 +1258,7 @@ static void phy_LCCalibrate_8188E(struct adapter *adapt, bool is2t)
 	/* 4. Set LC calibration begin	bit15 */
 	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_CHNLBW, bMask12Bits, LC_Cal|0x08000);
 
-	ODM_sleep_ms(100);
+	msleep(100);
 
 	/* Restore original situation */
 	if ((tmpreg&0x70) != 0) {
diff --git a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
index 18c0533..48cea29 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
@@ -25,7 +25,7 @@ void odm_ConfigRFReg_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 			   u32 RegAddr)
 {
     if (Addr == 0xffe) {
-		ODM_sleep_ms(50);
+		msleep(50);
 	} else if (Addr == 0xfd) {
 		ODM_delay_ms(5);
 	} else if (Addr == 0xfc) {
@@ -83,7 +83,7 @@ void odm_ConfigBB_PHY_REG_PG_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 				   u32 Bitmask, u32 Data)
 {
 	if (Addr == 0xfe) {
-		ODM_sleep_ms(50);
+		msleep(50);
 	} else if (Addr == 0xfd) {
 		ODM_delay_ms(5);
 	} else if (Addr == 0xfc) {
@@ -105,7 +105,7 @@ void odm_ConfigBB_PHY_REG_PG_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 void odm_ConfigBB_PHY_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Bitmask, u32 Data)
 {
 	if (Addr == 0xfe) {
-		ODM_sleep_ms(50);
+		msleep(50);
 	} else if (Addr == 0xfd) {
 		ODM_delay_ms(5);
 	} else if (Addr == 0xfc) {
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 59ad5bf..fa30811 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -162,11 +162,6 @@ void ODM_delay_us(u32 us)
 	rtw_udelay_os(us);
 }
 
-void ODM_sleep_ms(u32 ms)
-{
-	rtw_msleep_os(ms);
-}
-
 void ODM_sleep_us(u32 us)
 {
 	rtw_usleep_os(us);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
index e97ba02..ec4fb023 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
@@ -581,7 +581,7 @@ u8 Hal_ReadRFThermalMeter(struct adapter *pAdapter)
 void Hal_GetThermalMeter(struct adapter *pAdapter, u8 *value)
 {
 	Hal_TriggerRFThermalMeter(pAdapter);
-	rtw_msleep_os(1000);
+	msleep(1000);
 	*value = Hal_ReadRFThermalMeter(pAdapter);
 }
 
@@ -614,7 +614,7 @@ void Hal_SetSingleCarrierTx(struct adapter *pAdapter, u8 bStart)
 		write_bbreg(pAdapter, rOFDM1_LSTF, bOFDMContinueTx, bDisable);
 		write_bbreg(pAdapter, rOFDM1_LSTF, bOFDMSingleCarrier, bDisable);
 		write_bbreg(pAdapter, rOFDM1_LSTF, bOFDMSingleTone, bDisable);
-		rtw_msleep_os(10);
+		msleep(10);
 
 		/* BB Reset */
 		write_bbreg(pAdapter, rPMAC_Reset, bBBResetB, 0x0);
@@ -832,7 +832,7 @@ void Hal_SetOFDMContinuousTx(struct adapter *pAdapter, u8 bStart)
 		write_bbreg(pAdapter, rOFDM1_LSTF, bOFDMSingleCarrier, bDisable);
 		write_bbreg(pAdapter, rOFDM1_LSTF, bOFDMSingleTone, bDisable);
 		/* Delay 10 ms */
-		rtw_msleep_os(10);
+		msleep(10);
 		/* BB Reset */
 		write_bbreg(pAdapter, rPMAC_Reset, bBBResetB, 0x0);
 		write_bbreg(pAdapter, rPMAC_Reset, bBBResetB, 0x1);
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index e5c8704..0585463 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -141,8 +141,6 @@ void ODM_delay_ms(u32 ms);
 
 void ODM_delay_us(u32 us);
 
-void ODM_sleep_ms(u32 ms);
-
 void ODM_sleep_us(u32 us);
 
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer,
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 7a0fbe6..a4ba79a 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -275,7 +275,6 @@ s32  rtw_get_time_interval_ms(u32 start, u32 end);
 
 void rtw_sleep_schedulable(int ms);
 
-void rtw_msleep_os(int ms);
 void rtw_usleep_os(int us);
 
 u32  rtw_atoi(u8 *s);
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index ef3ae06..13f52581 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -1431,7 +1431,7 @@ static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 	wait_status = _FW_UNDER_SURVEY | _FW_UNDER_LINKING;
 
 	while (check_fwstate(pmlmepriv, wait_status)) {
-		rtw_msleep_os(30);
+		msleep(30);
 		cnt++;
 		if (cnt > wait_for_surveydone)
 			break;
@@ -2588,7 +2588,7 @@ static int rtw_get_ap_info(struct net_device *dev,
 	}
 
 	while ((check_fwstate(pmlmepriv, (_FW_UNDER_SURVEY|_FW_UNDER_LINKING)))) {
-		rtw_msleep_os(30);
+		msleep(30);
 		cnt++;
 		if (cnt > 100)
 			break;
@@ -7039,7 +7039,7 @@ static int rtw_mp_ctx(struct net_device *dev,
 		struct mp_priv *pmp_priv = &padapter->mppriv;
 		if (pmp_priv->tx.stop == 0) {
 			pmp_priv->tx.stop = 1;
-			rtw_msleep_os(5);
+			msleep(5);
 		}
 		pmp_priv->tx.stop = 0;
 		pmp_priv->tx.count = 1;
@@ -7254,7 +7254,7 @@ static int rtw_mp_reset_stats(struct net_device *dev,
 
 	/* reset phy counter */
 	write_bbreg(padapter, 0xf14, BIT16, 0x1);
-	rtw_msleep_os(10);
+	msleep(10);
 	write_bbreg(padapter, 0xf14, BIT16, 0x0);
 
 	return 0;
@@ -7531,7 +7531,7 @@ static int rtw_mp_get(struct net_device *dev,
 		break;
 	}
 
-	rtw_msleep_os(10); /* delay 5ms for sending pkt before exit adb shell operation */
+	msleep(10); /* delay 5ms for sending pkt before exit adb shell operation */
 	return 0;
 }
 
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 59c098f..bf1cd69 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -245,11 +245,6 @@ void rtw_sleep_schedulable(int ms)
 		return;
 }
 
-void rtw_msleep_os(int ms)
-{
-	msleep((unsigned int)ms);
-}
-
 void rtw_usleep_os(int us)
 {
 	if (1 < (us/1000))
-- 
1.8.4
