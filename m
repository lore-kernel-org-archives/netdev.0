From: Cong Ding <dinggnu@gmail.com>
Subject: [PATCH] net: wireless/rtlwifi: fix uninitialized variable issue
Date: Sat, 19 Jan 2013 13:56:36 +0100
Message-ID: <1358600210-15942-1-git-send-email-dinggnu@gmail.com>
Cc: Cong Ding <dinggnu@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of variable packet_beacon might be uninitialized in the three files.

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index a0fbf28..cdb570f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -452,7 +452,7 @@ static void _rtl92de_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	u8 *praddr;
 	u16 type, cfc;
 	__le16 fc;
-	bool packet_matchbssid, packet_toself, packet_beacon;
+	bool packet_matchbssid, packet_toself, packet_beacon = false;
 
 	tmp_buf = skb->data + pstats->rx_drvinfo_size + pstats->rx_bufshift;
 	hdr = (struct ieee80211_hdr *)tmp_buf;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 206561d..f8431a3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -480,7 +480,7 @@ static void _rtl92se_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	u8 *praddr;
 	__le16 fc;
 	u16 type, cfc;
-	bool packet_matchbssid, packet_toself, packet_beacon;
+	bool packet_matchbssid, packet_toself, packet_beacon = false;
 
 	tmp_buf = skb->data + pstats->rx_drvinfo_size + pstats->rx_bufshift;
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index a313be8..ce8ad12 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -247,7 +247,7 @@ static void _rtl8723ae_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	u8 *psaddr;
 	__le16 fc;
 	u16 type;
-	bool packet_matchbssid, packet_toself, packet_beacon;
+	bool packet_matchbssid, packet_toself, packet_beacon = false;
 
 	tmp_buf = skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshift;
 
-- 
1.7.10.4
