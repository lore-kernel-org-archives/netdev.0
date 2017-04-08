From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 13/22] staging: rtl8723bs: Fix indenting mistake in
 core/rtw_ap.c
Date: Sat,  8 Apr 2017 11:07:36 -0500
Message-ID: <20170408160745.14328-14-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, jes.sorensen@gmail.com, netdev@vger.kernel.org,
 hdegoede@redhat.com, hadess@hadess.net,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Smatch reports the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_ap.c
drivers/staging/rtl8723bs/core/rtw_ap.c:382 expire_timeout_chk() warn: inconsistent indenting

Fixing this requires changing the indentatikon of a long for loop.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_ap.c | 99 ++++++++++++++++-----------------
 1 file changed, 47 insertions(+), 52 deletions(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_ap.c b/drivers/staging/rtl8723bs/core/rtw_ap.c
index 9c71692a3a05..68b750275dff 100644
--- a/drivers/staging/rtl8723bs/core/rtw_ap.c
+++ b/drivers/staging/rtl8723bs/core/rtw_ap.c
@@ -379,70 +379,65 @@ void expire_timeout_chk(struct adapter *padapter)
 
 	spin_unlock_bh(&pstapriv->asoc_list_lock);
 
-if (chk_alive_num) {
+	if (chk_alive_num) {
+		u8 backup_oper_channel = 0;
+		struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+
+		/* switch to correct channel of current network  before issue keep-alive frames */
+		if (rtw_get_oper_ch(padapter) != pmlmeext->cur_channel) {
+			backup_oper_channel = rtw_get_oper_ch(padapter);
+			SelectChannel(padapter, pmlmeext->cur_channel);
+		}
 
-	u8 backup_oper_channel = 0;
-	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
-	/* switch to correct channel of current network  before issue keep-alive frames */
-	if (rtw_get_oper_ch(padapter) != pmlmeext->cur_channel) {
-		backup_oper_channel = rtw_get_oper_ch(padapter);
-		SelectChannel(padapter, pmlmeext->cur_channel);
-	}
+		/* issue null data to check sta alive*/
+		for (i = 0; i < chk_alive_num; i++) {
+			int ret = _FAIL;
 
-	/* issue null data to check sta alive*/
-	for (i = 0; i < chk_alive_num; i++) {
-		int ret = _FAIL;
+			psta = rtw_get_stainfo_by_offset(pstapriv, chk_alive_list[i]);
+			if (!(psta->state & _FW_LINKED))
+				continue;
 
-		psta = rtw_get_stainfo_by_offset(pstapriv, chk_alive_list[i]);
-		if (!(psta->state & _FW_LINKED))
-			continue;
+			if (psta->state & WIFI_SLEEP_STATE)
+				ret = issue_nulldata(padapter, psta->hwaddr, 0, 1, 50);
+			else
+				ret = issue_nulldata(padapter, psta->hwaddr, 0, 3, 50);
 
-		if (psta->state & WIFI_SLEEP_STATE)
-			ret = issue_nulldata(padapter, psta->hwaddr, 0, 1, 50);
-		else
-			ret = issue_nulldata(padapter, psta->hwaddr, 0, 3, 50);
+			psta->keep_alive_trycnt++;
+			if (ret == _SUCCESS) {
+				DBG_871X(
+					"asoc check, sta(" MAC_FMT ") is alive\n",
+					MAC_ARG(psta->hwaddr)
+					);
+				psta->expire_to = pstapriv->expire_to;
+				psta->keep_alive_trycnt = 0;
+				continue;
+			} else if (psta->keep_alive_trycnt <= 3) {
 
-		psta->keep_alive_trycnt++;
-		if (ret == _SUCCESS) {
+				DBG_871X(
+					"ack check for asoc expire, keep_alive_trycnt =%d\n",
+					psta->keep_alive_trycnt);
+				psta->expire_to = 1;
+				continue;
+			}
 
-			DBG_871X(
-				"asoc check, sta(" MAC_FMT ") is alive\n",
-				MAC_ARG(psta->hwaddr)
-			);
-			psta->expire_to = pstapriv->expire_to;
 			psta->keep_alive_trycnt = 0;
-			continue;
-		} else if (psta->keep_alive_trycnt <= 3) {
-
-
 			DBG_871X(
-				"ack check for asoc expire, keep_alive_trycnt =%d\n",
-				psta->keep_alive_trycnt
-			);
-			psta->expire_to = 1;
-			continue;
-		}
-
-		psta->keep_alive_trycnt = 0;
-		DBG_871X(
-			"asoc expire "MAC_FMT", state = 0x%x\n",
-			MAC_ARG(psta->hwaddr),
-			psta->state
-		);
-		spin_lock_bh(&pstapriv->asoc_list_lock);
-		if (list_empty(&psta->asoc_list) == false) {
-			list_del_init(&psta->asoc_list);
-			pstapriv->asoc_list_cnt--;
-			updated = ap_free_sta(padapter, psta, false, WLAN_REASON_DEAUTH_LEAVING);
+				"asoc expire "MAC_FMT", state = 0x%x\n",
+				MAC_ARG(psta->hwaddr),
+				psta->state);
+			spin_lock_bh(&pstapriv->asoc_list_lock);
+			if (list_empty(&psta->asoc_list) == false) {
+				list_del_init(&psta->asoc_list);
+				pstapriv->asoc_list_cnt--;
+				updated = ap_free_sta(padapter, psta, false, WLAN_REASON_DEAUTH_LEAVING);
+			}
+			spin_unlock_bh(&pstapriv->asoc_list_lock);
 		}
-		spin_unlock_bh(&pstapriv->asoc_list_lock);
 
+		if (backup_oper_channel > 0) /* back to the original operation channel */
+			SelectChannel(padapter, backup_oper_channel);
 	}
 
-	if (backup_oper_channel > 0) /* back to the original operation channel */
-		SelectChannel(padapter, backup_oper_channel);
-}
-
 	associated_clients_update(padapter, updated);
 }
 
-- 
2.12.0
