From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] rtlwifi: remove useless code
Date: Tue, 18 Jul 2017 15:41:06 -0500
Message-ID: <20170718204106.GA9905@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove useless local variables last_read_point and last_txw_point and
the code related.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
index 55f238a..c58393e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
@@ -478,7 +478,6 @@ u16 rtl92ee_rx_desc_buff_remained_cnt(struct ieee80211_hw *hw, u8 queue_index)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u16 read_point = 0, write_point = 0, remind_cnt = 0;
 	u32 tmp_4byte = 0;
-	static u16 last_read_point;
 	static bool start_rx;
 
 	tmp_4byte = rtl_read_dword(rtlpriv, REG_RXQ_TXBD_IDX);
@@ -506,7 +505,6 @@ u16 rtl92ee_rx_desc_buff_remained_cnt(struct ieee80211_hw *hw, u8 queue_index)
 
 	rtlpci->rx_ring[queue_index].next_rx_rp = write_point;
 
-	last_read_point = read_point;
 	return remind_cnt;
 }
 
@@ -917,7 +915,6 @@ void rtl92ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u16 cur_tx_rp = 0;
 	u16 cur_tx_wp = 0;
-	static u16 last_txw_point;
 	static bool over_run;
 	u32 tmp = 0;
 	u8 q_idx = *val;
@@ -951,9 +948,6 @@ void rtl92ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 				rtl_write_word(rtlpriv,
 					       get_desc_addr_fr_q_idx(q_idx),
 					       ring->cur_tx_wp);
-
-				if (q_idx == 1)
-					last_txw_point = cur_tx_wp;
 			}
 
 			if (ring->avl_desc < (max_tx_desc - 15)) {
-- 
2.5.0
