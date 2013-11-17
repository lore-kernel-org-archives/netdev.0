From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8188eu: Fix AP mode
Date: Sun, 17 Nov 2013 13:28:29 -0600
Message-ID: <1384716509-12823-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Stable <stable@vger.kernel.org>, Larry Finger <Larry.Finger@lwfinger.net>
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

Two code lines were accidentally deleted in the code.  Restore them.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index 2c73823..2a13a41 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -1115,6 +1115,9 @@ int rtw_check_beacon_data(struct adapter *padapter, u8 *pbuf,  int len)
 			return _FAIL;
 	}
 
+	/* fix bug of flush_cam_entry at STOP AP mode */
+	psta->state |= WIFI_AP_STATE;
+	rtw_indicate_connect(padapter);
 	pmlmepriv->cur_network.join_res = true;/* for check if already set beacon */
 	return ret;
 }
-- 
1.8.4
