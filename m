From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 20/22] staging rtl8723bs: Fix indenting errors and an off-by-one mistake in core/rtw_mlme_ext.c
Date: Sat,  8 Apr 2017 11:07:43 -0500
Message-ID: <20170408160745.14328-21-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34885 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752719AbdDHQIU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:20 -0400
Received: by mail-oi0-f68.google.com with SMTP id g204so6269201oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:19 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_mlme_ext.c
drivers/staging/rtl8723bs/core/rtw_mlme_ext.c:525 _mgt_dispatcher() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_mlme_ext.c:1595 OnAssocReq() error: buffer overflow 'pstapriv->sta_aid' 32 <= 32
drivers/staging/rtl8723bs/core/rtw_mlme_ext.c:2391 dump_mgntframe_and_wait() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_mlme_ext.c:2420 dump_mgntframe_and_wait_ack() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_mlme_ext.c:4969 process_80211d() error: testing array offset 'i' after use.
drivers/staging/rtl8723bs/core/rtw_mlme_ext.c:5738 linked_status_chk() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_mlme_ext.c:6459 sitesurvey_cmd_hdl() warn: inconsistent indenting

The indenting problems were fixed with white-space changes. The error at
line 1595 was the result of an off-by-one error in a for loop. The error
at line 4969 was not fixed as that code lies inside a block of code that
only is needed for 5G channels. This chip only works at 2.4 GHz.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_mlme_ext.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_mlme_ext.c b/drivers/staging/rtl8723bs/core/rtw_mlme_ext.c
index e0a3cd64777f..18e78d5198c3 100644
--- a/drivers/staging/rtl8723bs/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8723bs/core/rtw_mlme_ext.c
@@ -522,15 +522,14 @@ static void _mgt_dispatcher(struct adapter *padapter, struct mlme_handler *ptabl
 	u8 bc_addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 	u8 *pframe = precv_frame->u.hdr.rx_data;
 
-	  if (ptable->func) {
-		 /* receive the frames that ra(a1) is my address or ra(a1) is bc address. */
-			if (memcmp(GetAddr1Ptr(pframe), myid(&padapter->eeprompriv), ETH_ALEN) &&
-				memcmp(GetAddr1Ptr(pframe), bc_addr, ETH_ALEN))
-				return;
-
-			ptable->func(padapter, precv_frame);
-		}
+	if (ptable->func) {
+		/* receive the frames that ra(a1) is my address or ra(a1) is bc address. */
+		if (memcmp(GetAddr1Ptr(pframe), myid(&padapter->eeprompriv), ETH_ALEN) &&
+		    memcmp(GetAddr1Ptr(pframe), bc_addr, ETH_ALEN))
+			return;
 
+		ptable->func(padapter, precv_frame);
+	}
 }
 
 void mgt_dispatcher(struct adapter *padapter, union recv_frame *precv_frame)
@@ -1575,7 +1574,7 @@ unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
 	if (pstat->aid > 0) {
 		DBG_871X("  old AID %d\n", pstat->aid);
 	} else {
-		for (pstat->aid = 1; pstat->aid <= NUM_STA; pstat->aid++)
+		for (pstat->aid = 1; pstat->aid < NUM_STA; pstat->aid++)
 			if (pstapriv->sta_aid[pstat->aid - 1] == NULL)
 				break;
 
@@ -2388,7 +2387,7 @@ s32 dump_mgntframe_and_wait(struct adapter *padapter, struct xmit_frame *pmgntfr
 	pxmitbuf->sctx = NULL;
 	spin_unlock_irqrestore(&pxmitpriv->lock_sctx, irqL);
 
-	 return ret;
+	return ret;
 }
 
 s32 dump_mgntframe_and_wait_ack(struct adapter *padapter, struct xmit_frame *pmgntframe)
@@ -2417,7 +2416,7 @@ s32 dump_mgntframe_and_wait_ack(struct adapter *padapter, struct xmit_frame *pmg
 		mutex_unlock(&pxmitpriv->ack_tx_mutex);
 	}
 
-	 return ret;
+	return ret;
 }
 
 static int update_hidden_ssid(u8 *ies, u32 ies_len, u8 hidden_ssid_mode)
@@ -5735,7 +5734,7 @@ void linked_status_chk(struct adapter *padapter)
 		#else
 		rx_chk_limit = 8;
 		#endif
-			link_count_limit = 7; /*  16 sec */
+		link_count_limit = 7; /*  16 sec */
 
 		/*  Marked by Kurt 20130715 */
 		/*  For WiDi 3.5 and latered on, they don't ask WiDi sink to do roaming, so we could not check rx limit that strictly. */
@@ -6456,7 +6455,7 @@ u8 sitesurvey_cmd_hdl(struct adapter *padapter, u8 *pbuf)
 		Switch_DM_Func(padapter, DYNAMIC_FUNC_DISABLE, false);
 
 		/* config the initial gain under scaning, need to write the BB registers */
-			initialgain = 0x1e;
+		initialgain = 0x1e;
 
 		rtw_hal_set_hwreg(padapter, HW_VAR_INITIAL_GAIN, (u8 *)(&initialgain));
 
-- 
2.12.0
