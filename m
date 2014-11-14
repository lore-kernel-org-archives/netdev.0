From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] wireless: remove unnecessary sizeof(u8)
Date: Fri, 14 Nov 2014 21:55:53 +0100
Message-ID: <1415998553-12636-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sizeof(u8) is always 1.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/b43/ppr.c            |  2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c |  2 +-
 drivers/net/wireless/rtlwifi/efuse.c      | 16 ++++++++--------
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/b43/ppr.c b/drivers/net/wireless/b43/ppr.c
index 9a77027..6bc1c6f 100644
--- a/drivers/net/wireless/b43/ppr.c
+++ b/drivers/net/wireless/b43/ppr.c
@@ -28,7 +28,7 @@ void b43_ppr_clear(struct b43_wldev *dev, struct b43_ppr *ppr)
 	memset(ppr, 0, sizeof(*ppr));
 
 	/* Compile-time PPR check */
-	BUILD_BUG_ON(sizeof(struct b43_ppr) != B43_PPR_RATES_NUM * sizeof(u8));
+	BUILD_BUG_ON(sizeof(struct b43_ppr) != B43_PPR_RATES_NUM);
 }
 
 void b43_ppr_add(struct b43_wldev *dev, struct b43_ppr *ppr, int diff)
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wireless/iwlwifi/pcie/trans.c
index 836725e..f016824 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -1157,7 +1157,7 @@ static void iwl_trans_pcie_configure(struct iwl_trans *trans,
 		trans_pcie->n_no_reclaim_cmds = trans_cfg->n_no_reclaim_cmds;
 	if (trans_pcie->n_no_reclaim_cmds)
 		memcpy(trans_pcie->no_reclaim_cmds, trans_cfg->no_reclaim_cmds,
-		       trans_pcie->n_no_reclaim_cmds * sizeof(u8));
+		       trans_pcie->n_no_reclaim_cmds);
 
 	trans_pcie->rx_buf_size_8k = trans_cfg->rx_buf_size_8k;
 	if (trans_pcie->rx_buf_size_8k)
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index 0b4082c..a3135c5 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -251,8 +251,8 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 	}
 
 	/* allocate memory for efuse_tbl and efuse_word */
-	efuse_tbl = kzalloc(rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE] *
-			    sizeof(u8), GFP_ATOMIC);
+	efuse_tbl = kzalloc(rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE],
+			    GFP_ATOMIC);
 	if (!efuse_tbl)
 		return;
 	efuse_word = kzalloc(EFUSE_MAX_WORD_UNIT * sizeof(u16 *), GFP_ATOMIC);
@@ -733,8 +733,8 @@ static int efuse_pg_packet_read(struct ieee80211_hw *hw, u8 offset, u8 *data)
 	if (offset > 15)
 		return false;
 
-	memset(data, 0xff, PGPKT_DATA_SIZE * sizeof(u8));
-	memset(tmpdata, 0xff, PGPKT_DATA_SIZE * sizeof(u8));
+	memset(data, 0xff, PGPKT_DATA_SIZE);
+	memset(tmpdata, 0xff, PGPKT_DATA_SIZE);
 
 	while (continual && (efuse_addr < EFUSE_MAX_SIZE)) {
 		if (readstate & PG_STATE_HEADER) {
@@ -772,7 +772,7 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct pgpkt_struct tmp_pkt;
 	int dataempty = true;
-	u8 originaldata[8 * sizeof(u8)];
+	u8 originaldata[8];
 	u8 badworden = 0x0F;
 	u8 match_word_en, tmp_word_en;
 	u8 tmpindex;
@@ -881,7 +881,7 @@ static void efuse_write_data_case2(struct ieee80211_hw *hw, u16 *efuse_addr,
 	struct pgpkt_struct tmp_pkt;
 	u8 pg_header;
 	u8 tmp_header;
-	u8 originaldata[8 * sizeof(u8)];
+	u8 originaldata[8];
 	u8 tmp_word_cnts;
 	u8 badworden = 0x0F;
 
@@ -904,7 +904,7 @@ static void efuse_write_data_case2(struct ieee80211_hw *hw, u16 *efuse_addr,
 
 		tmp_word_cnts = efuse_calculate_word_cnts(tmp_pkt.word_en);
 
-		memset(originaldata, 0xff,  8 * sizeof(u8));
+		memset(originaldata, 0xff,  8);
 
 		if (efuse_pg_packet_read(hw, tmp_pkt.offset, originaldata)) {
 			badworden = enable_efuse_data_write(hw,
@@ -962,7 +962,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	target_pkt.offset = offset;
 	target_pkt.word_en = word_en;
 
-	memset(target_pkt.data, 0xFF,  8 * sizeof(u8));
+	memset(target_pkt.data, 0xFF,  8);
 
 	efuse_word_enable_data_read(word_en, data, target_pkt.data);
 	target_word_cnts = efuse_calculate_word_cnts(target_pkt.word_en);
-- 
1.9.3
