From: Cong Ding <dinggnu@gmail.com>
Subject: [PATCH] net: wireless/rtlwifi: fix uninitialized variable issue
Date: Mon,  4 Feb 2013 22:43:22 +0100
Message-ID: <1360014206-6138-1-git-send-email-dinggnu@gmail.com>
Cc: Cong Ding <dinggnu@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of variable packet_beacon might be uninitialized in the two files,
which is same as this patch:
https://patchwork.kernel.org/patch/2006711/

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index c31795e..da0e902 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -488,7 +488,7 @@ static void _rtl92ce_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	u8 *praddr;
 	__le16 fc;
 	u16 type, c_fc;
-	bool packet_matchbssid, packet_toself, packet_beacon;
+	bool packet_matchbssid, packet_toself, packet_beacon = false;
 
 	tmp_buf = skb->data + pstats->rx_drvinfo_size + pstats->rx_bufshift;
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 32ff959..85b6bdb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -1084,7 +1084,7 @@ void rtl92c_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	u8 *praddr;
 	__le16 fc;
 	u16 type, cpu_fc;
-	bool packet_matchbssid, packet_toself, packet_beacon;
+	bool packet_matchbssid, packet_toself, packet_beacon = false;
 
 	tmp_buf = skb->data + pstats->rx_drvinfo_size + pstats->rx_bufshift;
 	hdr = (struct ieee80211_hdr *)tmp_buf;
-- 
1.7.9.5
