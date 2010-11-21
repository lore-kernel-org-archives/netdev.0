From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 56/62] iwlwifi: Use static const
Date: Sat, 20 Nov 2010 18:38:57 -0800
Message-ID: <2773a20a26f4e326f0849e8ae8fb4f347d6a6ecb.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1290305773.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  48644	     57	  12120	  60821	   ed95	drivers/net/wireless/b43/phy_n.o.new
  48661	     57	  12120	  60838	   eda6	drivers/net/wireless/b43/phy_n.o.old
  37906	     86	   7904	  45896	   b348	drivers/net/wireless/iwlwifi/iwl-agn-lib.o.new
  37937	     86	   7904	  45927	   b367	drivers/net/wireless/iwlwifi/iwl-agn-lib.o.old
  37781	    523	   6752	  45056	   b000	drivers/net/wireless/iwlwifi/iwl-3945.o.new
  37781	    523	   6752	  45056	   b000	drivers/net/wireless/iwlwifi/iwl-3945.o.old

Changed b43_nphy_write_clip_detection to take a const u16 *

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/b43/phy_n.c           |    9 +++++----
 drivers/net/wireless/iwlwifi/iwl-3945.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c |    6 +++---
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/b43/phy_n.c b/drivers/net/wireless/b43/phy_n.c
index 6facb8a..afbfdf0 100644
--- a/drivers/net/wireless/b43/phy_n.c
+++ b/drivers/net/wireless/b43/phy_n.c
@@ -655,7 +655,8 @@ static void b43_nphy_tx_iq_workaround(struct b43_wldev *dev)
 }
 
 /* http://bcm-v4.sipsolutions.net/802.11/PHY/N/clip-detection */
-static void b43_nphy_write_clip_detection(struct b43_wldev *dev, u16 *clip_st)
+static void b43_nphy_write_clip_detection(struct b43_wldev *dev,
+					  const u16 *clip_st)
 {
 	b43_phy_write(dev, B43_NPHY_C1_CLIP1THRES, clip_st[0]);
 	b43_phy_write(dev, B43_NPHY_C2_CLIP1THRES, clip_st[1]);
@@ -731,7 +732,7 @@ static void b43_nphy_stay_in_carrier_search(struct b43_wldev *dev, bool enable)
 	struct b43_phy_n *nphy = phy->n;
 
 	if (enable) {
-		u16 clip[] = { 0xFFFF, 0xFFFF };
+		static const u16 clip[] = { 0xFFFF, 0xFFFF };
 		if (nphy->deaf_count++ == 0) {
 			nphy->classifier_state = b43_nphy_classifier(dev, 0, 0);
 			b43_nphy_classifier(dev, 0x7, 0);
@@ -843,7 +844,7 @@ static void b43_nphy_adjust_lna_gain_table(struct b43_wldev *dev)
 	u16 data[4];
 	s16 gain[2];
 	u16 minmax[2];
-	u16 lna_gain[4] = { -2, 10, 19, 25 };
+	static const u16 lna_gain[4] = { -2, 10, 19, 25 };
 
 	if (nphy->hang_avoid)
 		b43_nphy_stay_in_carrier_search(dev, 1);
@@ -2299,7 +2300,7 @@ static void b43_nphy_int_pa_set_tx_dig_filters(struct b43_wldev *dev)
 {
 	int i, j;
 	/* B43_NPHY_TXF_20CO_S0A1, B43_NPHY_TXF_40CO_S0A1, unknown */
-	u16 offset[] = { 0x186, 0x195, 0x2C5 };
+	static const u16 offset[] = { 0x186, 0x195, 0x2C5 };
 
 	for (i = 0; i < 3; i++)
 		for (j = 0; j < 15; j++)
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index ebac04b..013c5a9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -116,7 +116,7 @@ void iwl3945_disable_events(struct iwl_priv *priv)
 	u32 base;		/* SRAM address of event log header */
 	u32 disable_ptr;	/* SRAM address of event-disable bitmap array */
 	u32 array_size;		/* # of u32 entries in array */
-	u32 evt_disable[IWL_EVT_DISABLE_SIZE] = {
+	static const u32 evt_disable[IWL_EVT_DISABLE_SIZE] = {
 		0x00000000,	/*   31 -    0  Event id numbers */
 		0x00000000,	/*   63 -   32 */
 		0x00000000,	/*   95 -   64 */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index ca3530c..75e808f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -2001,7 +2001,7 @@ static void iwlagn_set_kill_ack_msk(struct iwl_priv *priv,
 				     struct iwl_bt_uart_msg *uart_msg)
 {
 	u8 kill_ack_msk;
-	__le32 bt_kill_ack_msg[2] = {
+	static const __le32 bt_kill_ack_msg[2] = {
 			cpu_to_le32(0xFFFFFFF), cpu_to_le32(0xFFFFFC00) };
 
 	kill_ack_msk = (((BT_UART_MSG_FRAME3A2DP_MSK |
@@ -2287,7 +2287,7 @@ static const char *get_csr_string(int cmd)
 void iwl_dump_csr(struct iwl_priv *priv)
 {
 	int i;
-	u32 csr_tbl[] = {
+	static const u32 csr_tbl[] = {
 		CSR_HW_IF_CONFIG_REG,
 		CSR_INT_COALESCING,
 		CSR_INT,
@@ -2346,7 +2346,7 @@ int iwl_dump_fh(struct iwl_priv *priv, char **buf, bool display)
 	int pos = 0;
 	size_t bufsz = 0;
 #endif
-	u32 fh_tbl[] = {
+	static const u32 fh_tbl[] = {
 		FH_RSCSR_CHNL0_STTS_WPTR_REG,
 		FH_RSCSR_CHNL0_RBDCB_BASE_REG,
 		FH_RSCSR_CHNL0_WPTR,
-- 
1.7.3.2.245.g03276.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
