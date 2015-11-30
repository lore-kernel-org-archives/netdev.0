From: Rahul Jain <rahul.jain@samsung.com>
Subject: [PATCH] mac80211_hwsim: missing NULL check
Date: Mon, 30 Nov 2015 12:46:52 +0530
Message-ID: <1448867812-11089-1-git-send-email-rahul.jain@samsung.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Amit Khatri <amit.khatri@samsung.com>,
	Rahul Jain <rahul.jain@samsung.com>
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amit Khatri <amit.khatri@samsung.com>

txrate variable might be NULL and passing inside function
without NULL check.

Signed-off-by: Amit Khatri <amit.khatri@samsung.com>
Signed-off-by: Rahul Jain <rahul.jain@samsung.com>
---
 drivers/net/wireless/mac80211_hwsim.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 194264c..72e4931 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -814,6 +814,9 @@ static void mac80211_hwsim_monitor_rx(struct ieee80211_hw *hw,
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(tx_skb);
 	struct ieee80211_rate *txrate = ieee80211_get_tx_rate(hw, info);
 
+	if (!txrate)
+		return;
+
 	if (!netif_running(hwsim_mon))
 		return;
 
-- 
1.9.1
