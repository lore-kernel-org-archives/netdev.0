From: Colin King <colin.king@canonical.com>
Subject: [PATCH][-next] rtlwifi: kfree entry until after entry->bssid has been accessed
Date: Fri, 30 Jun 2017 11:08:43 +0100
Message-ID: <20170630100843.9188-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The current code kfree's entry and then dereferences it by accessing
entry->bssid.  Avoid the dereference-after-free by moving the kfree
after the access to entry->bssid.

Detected by CoverityScan, CID#1448600 ("Read from pointer after free")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/realtek/rtlwifi/base.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/base.c b/drivers/net/wireless/realtek/rtlwifi/base.c
index e36ee592c660..208f56297a75 100644
--- a/drivers/net/wireless/realtek/rtlwifi/base.c
+++ b/drivers/net/wireless/realtek/rtlwifi/base.c
@@ -1735,12 +1735,12 @@ void rtl_scan_list_expire(struct ieee80211_hw *hw)
 			continue;
 
 		list_del(&entry->list);
-		kfree(entry);
 		rtlpriv->scan_list.num--;
 
 		RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
 			 "BSSID=%pM is expire in scan list (total=%d)\n",
 			 entry->bssid, rtlpriv->scan_list.num);
+		kfree(entry);
 	}
 
 	spin_unlock_irqrestore(&rtlpriv->locks.scan_list_lock, flags);
-- 
2.11.0
