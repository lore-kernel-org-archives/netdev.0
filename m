From: Wang YanQing <udknight@gmail.com>
Subject: [PATCH v2] rtlwifi: Remove double check for cnt_after_linked
Date: Thu, 5 May 2016 23:08:22 +0800
Message-ID: <20160505150822.GA4151@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chaoming_li@realsil.com.cn, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry.Finger@lwfinger.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtl_lps_enter does two successive check for cnt_after_linked
to make sure some time has elapsed after linked. The second
check isn't necessary, because if cnt_after_linked is bigger
than 5, it is bigger than 2 of course!

This patch remove the second check code.

Signed-off-by: Wang YanQing <udknight@gmail.com>
---
 Changes
 v1-v2:
 1: rewrite subject and commit message.
 2: fix issues report by checkpatch.pl.

 drivers/net/wireless/realtek/rtlwifi/ps.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/ps.c b/drivers/net/wireless/realtek/rtlwifi/ps.c
index b69321d..93579ca 100644
--- a/drivers/net/wireless/realtek/rtlwifi/ps.c
+++ b/drivers/net/wireless/realtek/rtlwifi/ps.c
@@ -443,14 +443,10 @@ void rtl_lps_enter(struct ieee80211_hw *hw)
 
 	spin_lock_irqsave(&rtlpriv->locks.lps_lock, flag);
 
-	/* Idle for a while if we connect to AP a while ago. */
-	if (mac->cnt_after_linked >= 2) {
-		if (ppsc->dot11_psmode == EACTIVE) {
-			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 "Enter 802.11 power save mode...\n");
-
-			rtl_lps_set_psmode(hw, EAUTOPS);
-		}
+	if (ppsc->dot11_psmode == EACTIVE) {
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "Enter 802.11 power save mode...\n");
+		rtl_lps_set_psmode(hw, EAUTOPS);
 	}
 
 	spin_unlock_irqrestore(&rtlpriv->locks.lps_lock, flag);
-- 
1.8.5.6.2.g3d8a54e.dirty
