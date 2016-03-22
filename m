From: Wei-Ning Huang <wnhuang@chromium.org>
Subject: [PATCH v2] mwifiex: advertise low priority scan feature
Date: Tue, 22 Mar 2016 12:09:56 +0800
Message-ID: <1458619796-7694-1-git-send-email-wnhuang@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akarwar@marvell.com,
	djkurtz@chromium.org, Wei-Ning Huang <wnhuang@chromium.org>,
	nishants@marvell.com, kvalo@codeaurora.org, netdev@vger.kernel.org
To: Linux Wireless <linux-wireless@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitkumar Karwar <akarwar@marvell.com>

Low priority scan handling code which delays or aborts scan
operation based on Tx traffic is removed recently. The reason
is firmware already takes care of it in our new feature scan
channel gap. Hence we should advertise low priority scan
support to cfg80211.

This patch fixes a problem in which OBSS scan request from
wpa_supplicant was being rejected by cfg80211.

Signed-off-by: Amitkumar Karwar <akarwar@marvell.com>
Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
---
 drivers/net/wireless/marvell/mwifiex/cfg80211.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
index bb7235e..7dafc5b 100644
--- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
@@ -4086,6 +4086,7 @@ int mwifiex_register_cfg80211(struct mwifiex_adapter *adapter)
 
 	wiphy->features |= NL80211_FEATURE_HT_IBSS |
 			   NL80211_FEATURE_INACTIVITY_TIMER |
+			   NL80211_FEATURE_LOW_PRIORITY_SCAN |
 			   NL80211_FEATURE_NEED_OBSS_SCAN;
 
 	if (ISSUPP_TDLS_ENABLED(adapter->fw_cap_info))
-- 
2.8.0.rc3.226.g39d4020
