From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 01/12 NEXT] rtlwifi: rtl8192c: Prevent reconnect attempts if not connected
Date: Mon, 18 Nov 2013 11:11:25 -0600
Message-ID: <1384794696-20314-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver has a watchdog timer that attempts to reconnect when beacon frames
are not seen for 6 seconds. This patch disables that reconnect whenever the
device has never been connected.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/base.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: wireless-testing/drivers/net/wireless/rtlwifi/base.c
===================================================================
--- wireless-testing.orig/drivers/net/wireless/rtlwifi/base.c
+++ wireless-testing/drivers/net/wireless/rtlwifi/base.c
@@ -1437,7 +1437,8 @@ void rtl_watchdog_wq_callback(void *data
 			/* if we can't recv beacon for 6s, we should
 			 * reconnect this AP
 			 */
-			if (rtlpriv->link_info.roam_times >= 3) {
+			if ((rtlpriv->link_info.roam_times >= 3) &&
+			    !is_zero_ether_addr(rtlpriv->mac80211.bssid)) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 					 "AP off, try to reconnect now\n");
 				rtlpriv->link_info.roam_times = 0;
