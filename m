From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-12-21
Date: Mon, 21 Dec 2009 14:16:27 -0500
Message-ID: <20091221191626.GE4979@tuxdriver.com>
References: <20091218211945.GC2828@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753786AbZLUTad@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091218211945.GC2828@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another big batch of fixes intended for 2.6.33.  They are mostly
driver fixes, along with a couple of small ones for mac80211.  I don't
think there is anything controverisal here.

Please let me know if there are problems!

Thanks,

John

P.S.  This re-adjusts after the rebasing confusion from this weekend.
The sliver lining is that it allowed me to drop a patch which in the
interim revealed itself to be broken in wireless-testing.

---

The following changes since commit 65182b9fb004220f250d4269c864cf0f1f372e85:
  John W. Linville (1):
        wireless: update old static regulatory domain rules

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Benjamin Herrenschmidt (1):
      ps3_gelic_wireless: Fix build failure due to missing WEXT_PRIV

Benoit Papillault (1):
      ath9k: Last fix for TX software padding.

Daniel Mack (1):
      Libertas: fix buffer overflow in lbs_get_essid()

Gertjan van Wingerde (4):
      rt2x00: Fix rt2800usb detection in rt2800lib.
      mac80211: Add define for TX headroom reserved by mac80211 itself.
      rt2x00: Disable powersaving for rt61pci and rt2800pci.
      rt2x00: Fix calculation of rt2800 iveiv entry offset.

Johannes Berg (4):
      iwlwifi: fix EEPROM/OTP reading endian annotations and a bug
      iwlwifi: fix more eeprom endian bugs
      mac80211: fix peer HT capabilities
      mac80211: fix WMM AP settings application

Julia Lawall (1):
      drivers/net/wireless: Correct code taking the size of a pointer

Reinette Chatre (4):
      iwlwifi: power up all devices for EEPROM read
      iwl3945: disable power save
      iwlwifi: initialize spinlock before use
      iwlwifi: fix 40MHz operation setting on cards that do not allow it

Roel Kluin (1):
      iwmc3200wifi: Fix test of unsigned in iwm_ntf_stop_resume_tx()

Sujith (3):
      ath9k: Fix bug in assigning sequence number
      ath9k: Fix TX queue draining
      ath9k: Stop ANI when doing a reset

Wey-Yi Guy (1):
      iwlwifi: fix syslog message for event log dump size

Zhu Yi (2):
      iwlwifi: allocated rx page accounting cleanup
      iwl3945: fix panic in iwl3945 driver

akpm@linux-foundation.org (1):
      drivers/net/wireless/iwlwifi/iwl-tx.c: fix gcc-3.4.5 warning

 drivers/net/Kconfig                         |    2 +
 drivers/net/wireless/ath/ath9k/mac.c        |    2 +-
 drivers/net/wireless/ath/ath9k/main.c       |    6 ++++
 drivers/net/wireless/ath/ath9k/xmit.c       |   40 +++++++++++---------------
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    5 ++-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h  |   14 ++++++---
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    7 +++--
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    6 ++--
 drivers/net/wireless/iwlwifi/iwl-csr.h      |    8 ++---
 drivers/net/wireless/iwlwifi/iwl-dev.h      |   13 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |   37 +++++++++++--------------
 drivers/net/wireless/iwlwifi/iwl-eeprom.h   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |    8 +----
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    8 +----
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    3 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   27 +++++++++---------
 drivers/net/wireless/iwmc3200wifi/iwm.h     |    2 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c  |    2 +-
 drivers/net/wireless/iwmc3200wifi/rx.c      |    2 +-
 drivers/net/wireless/libertas/wext.c        |    2 -
 drivers/net/wireless/rt2x00/rt2800.h        |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c     |   17 +++++++----
 drivers/net/wireless/rt2x00/rt61pci.c       |    5 +++
 include/linux/ieee80211.h                   |    2 +-
 include/net/mac80211.h                      |    6 ++++
 net/mac80211/ht.c                           |   25 +++++++++++++++--
 net/mac80211/main.c                         |    2 +
 net/mac80211/mlme.c                         |    8 +++++
 31 files changed, 160 insertions(+), 112 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0bbd5ae..18ff622 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2344,6 +2344,7 @@ config GELIC_NET
 
 config GELIC_WIRELESS
 	bool "PS3 Wireless support"
+	depends on WLAN
 	depends on GELIC_NET
 	select WIRELESS_EXT
 	help
@@ -2356,6 +2357,7 @@ config GELIC_WIRELESS
 config GELIC_WIRELESS_OLD_PSK_INTERFACE
        bool "PS3 Wireless private PSK interface (OBSOLETE)"
        depends on GELIC_WIRELESS
+       select WEXT_PRIV
        help
           This option retains the obsolete private interface to pass
           the PSK from user space programs to the driver.  The PSK
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index 71b84d9..efc420c 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -186,7 +186,7 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 		wait = wait_time;
 		while (ath9k_hw_numtxpending(ah, q)) {
 			if ((--wait) == 0) {
-				ath_print(common, ATH_DBG_QUEUE,
+				ath_print(common, ATH_DBG_FATAL,
 					  "Failed to stop TX DMA in 100 "
 					  "msec after killing last frame\n");
 				break;
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index c487434..9e68c1a 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1973,6 +1973,9 @@ int ath_reset(struct ath_softc *sc, bool retry_tx)
 	struct ieee80211_hw *hw = sc->hw;
 	int r;
 
+	/* Stop ANI */
+	del_timer_sync(&common->ani.timer);
+
 	ath9k_hw_set_interrupts(ah, 0);
 	ath_drain_all_txq(sc, retry_tx);
 	ath_stoprecv(sc);
@@ -2014,6 +2017,9 @@ int ath_reset(struct ath_softc *sc, bool retry_tx)
 		}
 	}
 
+	/* Start ANI */
+	ath_start_ani(common);
+
 	return r;
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 2a11cc5..1e813bb 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1108,11 +1108,11 @@ void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 	if (npend) {
 		int r;
 
-		ath_print(common, ATH_DBG_XMIT,
+		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to stop TxDMA. Reset HAL!\n");
 
 		spin_lock_bh(&sc->sc_resetlock);
-		r = ath9k_hw_reset(ah, sc->sc_ah->curchan, true);
+		r = ath9k_hw_reset(ah, sc->sc_ah->curchan, false);
 		if (r)
 			ath_print(common, ATH_DBG_FATAL,
 				  "Unable to reset hardware; reset status %d\n",
@@ -1414,17 +1414,9 @@ static void assign_aggr_tid_seqno(struct sk_buff *skb,
 	 * For HT capable stations, we save tidno for later use.
 	 * We also override seqno set by upper layer with the one
 	 * in tx aggregation state.
-	 *
-	 * If fragmentation is on, the sequence number is
-	 * not overridden, since it has been
-	 * incremented by the fragmentation routine.
-	 *
-	 * FIXME: check if the fragmentation threshold exceeds
-	 * IEEE80211 max.
 	 */
 	tid = ATH_AN_2_TID(an, bf->bf_tidno);
-	hdr->seq_ctrl = cpu_to_le16(tid->seq_next <<
-			IEEE80211_SEQ_SEQ_SHIFT);
+	hdr->seq_ctrl = cpu_to_le16(tid->seq_next << IEEE80211_SEQ_SEQ_SHIFT);
 	bf->bf_seqno = tid->seq_next;
 	INCR(tid->seq_next, IEEE80211_SEQ_MAX);
 }
@@ -1636,7 +1628,8 @@ static int ath_tx_setup_buffer(struct ieee80211_hw *hw, struct ath_buf *bf,
 		bf->bf_keyix = ATH9K_TXKEYIX_INVALID;
 	}
 
-	if (ieee80211_is_data_qos(fc) && (sc->sc_flags & SC_OP_TXAGGR))
+	if (ieee80211_is_data_qos(fc) && bf_isht(bf) &&
+	    (sc->sc_flags & SC_OP_TXAGGR))
 		assign_aggr_tid_seqno(skb, bf);
 
 	bf->bf_mpdu = skb;
@@ -1780,7 +1773,8 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct sk_buff *skb)
 	struct ath_wiphy *aphy = hw->priv;
 	struct ath_softc *sc = aphy->sc;
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
-	int hdrlen, padsize;
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	int padpos, padsize;
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct ath_tx_control txctl;
 
@@ -1792,7 +1786,6 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct sk_buff *skb)
 	 * BSSes.
 	 */
 	if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
-		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 		if (info->flags & IEEE80211_TX_CTL_FIRST_FRAGMENT)
 			sc->tx.seq_no += 0x10;
 		hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
@@ -1800,9 +1793,9 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct sk_buff *skb)
 	}
 
 	/* Add the padding after the header if this is not already done */
-	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
-	if (hdrlen & 3) {
-		padsize = hdrlen % 4;
+	padpos = ath9k_cmn_padpos(hdr->frame_control);
+	padsize = padpos & 3;
+	if (padsize && skb->len>padpos) {
 		if (skb_headroom(skb) < padsize) {
 			ath_print(common, ATH_DBG_XMIT,
 				  "TX CABQ padding failed\n");
@@ -1810,7 +1803,7 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct sk_buff *skb)
 			return;
 		}
 		skb_push(skb, padsize);
-		memmove(skb->data, skb->data + padsize, hdrlen);
+		memmove(skb->data, skb->data + padsize, padpos);
 	}
 
 	txctl.txq = sc->beacon.cabq;
@@ -1838,7 +1831,8 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 	struct ieee80211_hw *hw = sc->hw;
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(skb);
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
-	int hdrlen, padsize;
+	struct ieee80211_hdr * hdr = (struct ieee80211_hdr *)skb->data;
+	int padpos, padsize;
 
 	ath_print(common, ATH_DBG_XMIT, "TX complete: skb: %p\n", skb);
 
@@ -1853,14 +1847,14 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 		tx_info->flags |= IEEE80211_TX_STAT_ACK;
 	}
 
-	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
-	padsize = hdrlen & 3;
-	if (padsize && hdrlen >= 24) {
+	padpos = ath9k_cmn_padpos(hdr->frame_control);
+	padsize = padpos & 3;
+	if (padsize && skb->len>padpos+padsize) {
 		/*
 		 * Remove MAC header padding before giving the frame back to
 		 * mac80211.
 		 */
-		memmove(skb->data + padsize, skb->data, hdrlen);
+		memmove(skb->data + padsize, skb->data, padpos);
 		skb_pull(skb, padsize);
 	}
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 7da1dab..e413bd3 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -1835,8 +1835,7 @@ static int iwl3945_send_rxon_assoc(struct iwl_priv *priv)
 		rc = -EIO;
 	}
 
-	priv->alloc_rxb_page--;
-	free_pages(cmd.reply_page, priv->hw_params.rx_page_order);
+	iwl_free_pages(priv, cmd.reply_page);
 
 	return rc;
 }
@@ -2836,6 +2835,7 @@ static struct iwl_cfg iwl3945_bg_cfg = {
 	.use_isr_legacy = true,
 	.ht_greenfield_support = false,
 	.led_compensation = 64,
+	.broken_powersave = true,
 };
 
 static struct iwl_cfg iwl3945_abg_cfg = {
@@ -2852,6 +2852,7 @@ static struct iwl_cfg iwl3945_abg_cfg = {
 	.use_isr_legacy = true,
 	.ht_greenfield_support = false,
 	.led_compensation = 64,
+	.broken_powersave = true,
 };
 
 struct pci_device_id iwl3945_hw_card_ids[] = {
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 386513b..484c5fd 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -1204,7 +1204,7 @@ static int iwl4965_fill_txpower_tbl(struct iwl_priv *priv, u8 band, u16 channel,
 	iwl4965_interpolate_chan(priv, channel, &ch_eeprom_info);
 
 	/* calculate tx gain adjustment based on power supply voltage */
-	voltage = priv->calib_info->voltage;
+	voltage = le16_to_cpu(priv->calib_info->voltage);
 	init_voltage = (s32)le32_to_cpu(priv->card_alive_init.voltage);
 	voltage_compensation =
 	    iwl4965_get_voltage_compensation(voltage, init_voltage);
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000-hw.h b/drivers/net/wireless/iwlwifi/iwl-5000-hw.h
index 4ef6804..bc056e9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-5000-hw.h
@@ -92,11 +92,15 @@
 
 static inline s32 iwl_temp_calib_to_offset(struct iwl_priv *priv)
 {
-	u16 *temp_calib = (u16 *)iwl_eeprom_query_addr(priv,
-						       EEPROM_5000_TEMPERATURE);
-	/* offset =  temperature -  voltage / coef */
-	s32 offset = (s32)(temp_calib[0] - temp_calib[1] / IWL_5150_VOLTAGE_TO_TEMPERATURE_COEFF);
-	return offset;
+	u16 temperature, voltage;
+	__le16 *temp_calib =
+		(__le16 *)iwl_eeprom_query_addr(priv, EEPROM_5000_TEMPERATURE);
+
+	temperature = le16_to_cpu(temp_calib[0]);
+	voltage = le16_to_cpu(temp_calib[1]);
+
+	/* offset = temp - volt / coeff */
+	return (s32)(temperature - voltage / IWL_5150_VOLTAGE_TO_TEMPERATURE_COEFF);
 }
 
 /* Fixed (non-configurable) rx data from phy */
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index e2f8615..33a5866 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -333,14 +333,15 @@ static void iwl5000_set_ct_threshold(struct iwl_priv *priv)
 static int iwl5000_set_Xtal_calib(struct iwl_priv *priv)
 {
 	struct iwl_calib_xtal_freq_cmd cmd;
-	u16 *xtal_calib = (u16 *)iwl_eeprom_query_addr(priv, EEPROM_5000_XTAL);
+	__le16 *xtal_calib =
+		(__le16 *)iwl_eeprom_query_addr(priv, EEPROM_5000_XTAL);
 
 	cmd.hdr.op_code = IWL_PHY_CALIBRATE_CRYSTAL_FRQ_CMD;
 	cmd.hdr.first_group = 0;
 	cmd.hdr.groups_num = 1;
 	cmd.hdr.data_valid = 1;
-	cmd.cap_pin1 = (u8)xtal_calib[0];
-	cmd.cap_pin2 = (u8)xtal_calib[1];
+	cmd.cap_pin1 = le16_to_cpu(xtal_calib[0]);
+	cmd.cap_pin2 = le16_to_cpu(xtal_calib[1]);
 	return iwl_calib_set(&priv->calib_results[IWL_CALIB_XTAL],
 			     (u8 *)&cmd, sizeof(cmd));
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index b8377ef..1c9866d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1842,7 +1842,7 @@ void iwl_dump_nic_event_log(struct iwl_priv *priv, bool full_log)
 	}
 
 #ifdef CONFIG_IWLWIFI_DEBUG
-	if (!(iwl_get_debug_level(priv) & IWL_DL_FW_ERRORS))
+	if (!(iwl_get_debug_level(priv) & IWL_DL_FW_ERRORS) && !full_log)
 		size = (size > DEFAULT_DUMP_EVENT_LOG_ENTRIES)
 			? DEFAULT_DUMP_EVENT_LOG_ENTRIES : size;
 #else
@@ -3173,7 +3173,6 @@ static int iwl_init_drv(struct iwl_priv *priv)
 
 	priv->ibss_beacon = NULL;
 
-	spin_lock_init(&priv->lock);
 	spin_lock_init(&priv->sta_lock);
 	spin_lock_init(&priv->hcmd_lock);
 
@@ -3361,10 +3360,11 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		(unsigned long long) pci_resource_len(pdev, 0));
 	IWL_DEBUG_INFO(priv, "pci_resource_base = %p\n", priv->hw_base);
 
-	/* this spin lock will be used in apm_ops.init and EEPROM access
+	/* these spin locks will be used in apm_ops.init and EEPROM access
 	 * we should init now
 	 */
 	spin_lock_init(&priv->reg_lock);
+	spin_lock_init(&priv->lock);
 	iwl_hw_detect(priv);
 	IWL_INFO(priv, "Detected Intel Wireless WiFi Link %s REV=0x%X\n",
 		priv->cfg->name, priv->hw_rev);
diff --git a/drivers/net/wireless/iwlwifi/iwl-csr.h b/drivers/net/wireless/iwlwifi/iwl-csr.h
index a7bfae0..1ec8cb4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-csr.h
+++ b/drivers/net/wireless/iwlwifi/iwl-csr.h
@@ -77,8 +77,7 @@
  * The MAC (uCode processor, etc.) does not need to be powered up for accessing
  * the CSR registers.
  *
- * NOTE:  Newer devices using one-time-programmable (OTP) memory
- *        require device to be awake in order to read this memory
+ * NOTE:  Device does need to be awake in order to read this memory
  *        via CSR_EEPROM and CSR_OTP registers
  */
 #define CSR_BASE    (0x000)
@@ -111,9 +110,8 @@
 /*
  * EEPROM and OTP (one-time-programmable) memory reads
  *
- * NOTE:  For (newer) devices using OTP, device must be awake, initialized via
- *        apm_ops.init() in order to read.  Older devices (3945/4965/5000)
- *        use EEPROM and do not require this.
+ * NOTE:  Device must be awake, initialized via apm_ops.init(),
+ *        in order to read.
  */
 #define CSR_EEPROM_REG          (CSR_BASE+0x02c)
 #define CSR_EEPROM_GP           (CSR_BASE+0x030)
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index 2673e9a..165d1f6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -1168,7 +1168,7 @@ struct iwl_priv {
 	u32 last_beacon_time;
 	u64 last_tsf;
 
-	/* eeprom */
+	/* eeprom -- this is in the card's little endian byte order */
 	u8 *eeprom;
 	int    nvm_device_type;
 	struct iwl_eeprom_calib_info *calib_info;
@@ -1353,4 +1353,15 @@ static inline int is_channel_ibss(const struct iwl_channel_info *ch)
 	return ((ch->flags & EEPROM_CHANNEL_IBSS)) ? 1 : 0;
 }
 
+static inline void __iwl_free_pages(struct iwl_priv *priv, struct page *page)
+{
+	__free_pages(page, priv->hw_params.rx_page_order);
+	priv->alloc_rxb_page--;
+}
+
+static inline void iwl_free_pages(struct iwl_priv *priv, unsigned long page)
+{
+	free_pages(page, priv->hw_params.rx_page_order);
+	priv->alloc_rxb_page--;
+}
 #endif				/* __iwl_dev_h__ */
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.c b/drivers/net/wireless/iwlwifi/iwl-eeprom.c
index 3946e5c..4a30969 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.c
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.c
@@ -370,7 +370,7 @@ static int iwl_init_otp_access(struct iwl_priv *priv)
 	return ret;
 }
 
-static int iwl_read_otp_word(struct iwl_priv *priv, u16 addr, u16 *eeprom_data)
+static int iwl_read_otp_word(struct iwl_priv *priv, u16 addr, __le16 *eeprom_data)
 {
 	int ret = 0;
 	u32 r;
@@ -404,7 +404,7 @@ static int iwl_read_otp_word(struct iwl_priv *priv, u16 addr, u16 *eeprom_data)
 				CSR_OTP_GP_REG_ECC_CORR_STATUS_MSK);
 		IWL_ERR(priv, "Correctable OTP ECC error, continue read\n");
 	}
-	*eeprom_data = le16_to_cpu((__force __le16)(r >> 16));
+	*eeprom_data = cpu_to_le16(r >> 16);
 	return 0;
 }
 
@@ -413,7 +413,8 @@ static int iwl_read_otp_word(struct iwl_priv *priv, u16 addr, u16 *eeprom_data)
  */
 static bool iwl_is_otp_empty(struct iwl_priv *priv)
 {
-	u16 next_link_addr = 0, link_value;
+	u16 next_link_addr = 0;
+	__le16 link_value;
 	bool is_empty = false;
 
 	/* locate the beginning of OTP link list */
@@ -443,7 +444,8 @@ static bool iwl_is_otp_empty(struct iwl_priv *priv)
 static int iwl_find_otp_image(struct iwl_priv *priv,
 					u16 *validblockaddr)
 {
-	u16 next_link_addr = 0, link_value = 0, valid_addr;
+	u16 next_link_addr = 0, valid_addr;
+	__le16 link_value = 0;
 	int usedblocks = 0;
 
 	/* set addressing mode to absolute to traverse the link list */
@@ -463,7 +465,7 @@ static int iwl_find_otp_image(struct iwl_priv *priv,
 		 * check for more block on the link list
 		 */
 		valid_addr = next_link_addr;
-		next_link_addr = link_value * sizeof(u16);
+		next_link_addr = le16_to_cpu(link_value) * sizeof(u16);
 		IWL_DEBUG_INFO(priv, "OTP blocks %d addr 0x%x\n",
 			       usedblocks, next_link_addr);
 		if (iwl_read_otp_word(priv, next_link_addr, &link_value))
@@ -497,7 +499,7 @@ static int iwl_find_otp_image(struct iwl_priv *priv,
  */
 int iwl_eeprom_init(struct iwl_priv *priv)
 {
-	u16 *e;
+	__le16 *e;
 	u32 gp = iwl_read32(priv, CSR_EEPROM_GP);
 	int sz;
 	int ret;
@@ -516,12 +518,9 @@ int iwl_eeprom_init(struct iwl_priv *priv)
 		ret = -ENOMEM;
 		goto alloc_err;
 	}
-	e = (u16 *)priv->eeprom;
+	e = (__le16 *)priv->eeprom;
 
-	if (priv->nvm_device_type == NVM_DEVICE_TYPE_OTP) {
-		/* OTP reads require powered-up chip */
-		priv->cfg->ops->lib->apm_ops.init(priv);
-	}
+	priv->cfg->ops->lib->apm_ops.init(priv);
 
 	ret = priv->cfg->ops->lib->eeprom_ops.verify_signature(priv);
 	if (ret < 0) {
@@ -562,7 +561,7 @@ int iwl_eeprom_init(struct iwl_priv *priv)
 		}
 		for (addr = validblockaddr; addr < validblockaddr + sz;
 		     addr += sizeof(u16)) {
-			u16 eeprom_data;
+			__le16 eeprom_data;
 
 			ret = iwl_read_otp_word(priv, addr, &eeprom_data);
 			if (ret)
@@ -570,13 +569,6 @@ int iwl_eeprom_init(struct iwl_priv *priv)
 			e[cache_addr / 2] = eeprom_data;
 			cache_addr += sizeof(u16);
 		}
-
-		/*
-		 * Now that OTP reads are complete, reset chip to save
-		 *   power until we load uCode during "up".
-		 */
-		priv->cfg->ops->lib->apm_ops.stop(priv);
-
 	} else {
 		/* eeprom is an array of 16bit values */
 		for (addr = 0; addr < sz; addr += sizeof(u16)) {
@@ -594,7 +586,7 @@ int iwl_eeprom_init(struct iwl_priv *priv)
 				goto done;
 			}
 			r = _iwl_read_direct32(priv, CSR_EEPROM_REG);
-			e[addr / 2] = le16_to_cpu((__force __le16)(r >> 16));
+			e[addr / 2] = cpu_to_le16(r >> 16);
 		}
 	}
 	ret = 0;
@@ -603,6 +595,8 @@ done:
 err:
 	if (ret)
 		iwl_eeprom_free(priv);
+	/* Reset chip to save power until we load uCode during "up". */
+	priv->cfg->ops->lib->apm_ops.stop(priv);
 alloc_err:
 	return ret;
 }
@@ -755,7 +749,8 @@ static int iwl_mod_ht40_chan_info(struct iwl_priv *priv,
 	ch_info->ht40_eeprom = *eeprom_ch;
 	ch_info->ht40_max_power_avg = eeprom_ch->max_power_avg;
 	ch_info->ht40_flags = eeprom_ch->flags;
-	ch_info->ht40_extension_channel &= ~clear_ht40_extension_channel;
+	if (eeprom_ch->flags & EEPROM_CHANNEL_VALID)
+		ch_info->ht40_extension_channel &= ~clear_ht40_extension_channel;
 
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.h b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
index 5cd2b66..0cd9c02 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.h
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
@@ -137,7 +137,7 @@ struct iwl_eeprom_channel {
  *
  */
 struct iwl_eeprom_enhanced_txpwr {
-	u16 common;
+	__le16 common;
 	s8 chain_a_max;
 	s8 chain_b_max;
 	s8 chain_c_max;
@@ -360,7 +360,7 @@ struct iwl_eeprom_calib_subband_info {
 struct iwl_eeprom_calib_info {
 	u8 saturation_power24;	/* half-dBm (e.g. "34" = 17 dBm) */
 	u8 saturation_power52;	/* half-dBm */
-	s16 voltage;		/* signed */
+	__le16 voltage;		/* signed */
 	struct iwl_eeprom_calib_subband_info
 		band_info[EEPROM_TX_POWER_BANDS];
 } __attribute__ ((packed));
diff --git a/drivers/net/wireless/iwlwifi/iwl-hcmd.c b/drivers/net/wireless/iwlwifi/iwl-hcmd.c
index a231659..30e9ea6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-hcmd.c
+++ b/drivers/net/wireless/iwlwifi/iwl-hcmd.c
@@ -234,7 +234,7 @@ cancel:
 	}
 fail:
 	if (cmd->reply_page) {
-		free_pages(cmd->reply_page, priv->hw_params.rx_page_order);
+		iwl_free_pages(priv, cmd->reply_page);
 		cmd->reply_page = 0;
 	}
 out:
diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
index 6090bc1..f5c87e7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
@@ -345,10 +345,8 @@ void iwl_rx_queue_free(struct iwl_priv *priv, struct iwl_rx_queue *rxq)
 			pci_unmap_page(priv->pci_dev, rxq->pool[i].page_dma,
 				PAGE_SIZE << priv->hw_params.rx_page_order,
 				PCI_DMA_FROMDEVICE);
-			__free_pages(rxq->pool[i].page,
-				     priv->hw_params.rx_page_order);
+			__iwl_free_pages(priv, rxq->pool[i].page);
 			rxq->pool[i].page = NULL;
-			priv->alloc_rxb_page--;
 		}
 	}
 
@@ -416,9 +414,7 @@ void iwl_rx_queue_reset(struct iwl_priv *priv, struct iwl_rx_queue *rxq)
 			pci_unmap_page(priv->pci_dev, rxq->pool[i].page_dma,
 				PAGE_SIZE << priv->hw_params.rx_page_order,
 				PCI_DMA_FROMDEVICE);
-			priv->alloc_rxb_page--;
-			__free_pages(rxq->pool[i].page,
-				     priv->hw_params.rx_page_order);
+			__iwl_free_pages(priv, rxq->pool[i].page);
 			rxq->pool[i].page = NULL;
 		}
 		list_add_tail(&rxq->pool[i].list, &rxq->rx_used);
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index a2b2b83..fa1c89b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -144,8 +144,7 @@ static int iwl_send_scan_abort(struct iwl_priv *priv)
 		clear_bit(STATUS_SCAN_HW, &priv->status);
 	}
 
-	priv->alloc_rxb_page--;
-	free_pages(cmd.reply_page, priv->hw_params.rx_page_order);
+	iwl_free_pages(priv, cmd.reply_page);
 
 	return ret;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wireless/iwlwifi/iwl-sta.c
index cd6a690..cde09a8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -164,9 +164,7 @@ int iwl_send_add_sta(struct iwl_priv *priv,
 			break;
 		}
 	}
-
-	priv->alloc_rxb_page--;
-	free_pages(cmd.reply_page, priv->hw_params.rx_page_order);
+	iwl_free_pages(priv, cmd.reply_page);
 
 	return ret;
 }
@@ -391,9 +389,7 @@ static int iwl_send_remove_station(struct iwl_priv *priv, const u8 *addr,
 			break;
 		}
 	}
-
-	priv->alloc_rxb_page--;
-	free_pages(cmd.reply_page, priv->hw_params.rx_page_order);
+	iwl_free_pages(priv, cmd.reply_page);
 
 	return ret;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 00da5e1..87ce2bd 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -407,13 +407,14 @@ void iwl_hw_txq_ctx_free(struct iwl_priv *priv)
 	int txq_id;
 
 	/* Tx queues */
-	if (priv->txq)
+	if (priv->txq) {
 		for (txq_id = 0; txq_id < priv->hw_params.max_txq_num;
 		     txq_id++)
 			if (txq_id == IWL_CMD_QUEUE_NUM)
 				iwl_cmd_queue_free(priv);
 			else
 				iwl_tx_queue_free(priv, txq_id);
+	}
 	iwl_free_dma_ptr(priv, &priv->kw);
 
 	iwl_free_dma_ptr(priv, &priv->scd_bc_tbls);
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 2a28a1f..e5d8fa3 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -548,6 +548,9 @@ static int iwl3945_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	txq = &priv->txq[txq_id];
 	q = &txq->q;
 
+	if ((iwl_queue_space(q) < q->high_mark))
+		goto drop;
+
 	spin_lock_irqsave(&priv->lock, flags);
 
 	idx = get_cmd_index(q, q->write_ptr, 0);
@@ -812,7 +815,7 @@ static int iwl3945_get_measurement(struct iwl_priv *priv,
 		break;
 	}
 
-	free_pages(cmd.reply_page, priv->hw_params.rx_page_order);
+	iwl_free_pages(priv, cmd.reply_page);
 
 	return rc;
 }
@@ -1198,9 +1201,7 @@ void iwl3945_rx_queue_reset(struct iwl_priv *priv, struct iwl_rx_queue *rxq)
 			pci_unmap_page(priv->pci_dev, rxq->pool[i].page_dma,
 				PAGE_SIZE << priv->hw_params.rx_page_order,
 				PCI_DMA_FROMDEVICE);
-			priv->alloc_rxb_page--;
-			__free_pages(rxq->pool[i].page,
-				     priv->hw_params.rx_page_order);
+			__iwl_free_pages(priv, rxq->pool[i].page);
 			rxq->pool[i].page = NULL;
 		}
 		list_add_tail(&rxq->pool[i].list, &rxq->rx_used);
@@ -1247,10 +1248,8 @@ static void iwl3945_rx_queue_free(struct iwl_priv *priv, struct iwl_rx_queue *rx
 			pci_unmap_page(priv->pci_dev, rxq->pool[i].page_dma,
 				PAGE_SIZE << priv->hw_params.rx_page_order,
 				PCI_DMA_FROMDEVICE);
-			__free_pages(rxq->pool[i].page,
-				     priv->hw_params.rx_page_order);
+			__iwl_free_pages(priv, rxq->pool[i].page);
 			rxq->pool[i].page = NULL;
-			priv->alloc_rxb_page--;
 		}
 	}
 
@@ -1688,7 +1687,7 @@ void iwl3945_dump_nic_event_log(struct iwl_priv *priv, bool full_log)
 	}
 
 #ifdef CONFIG_IWLWIFI_DEBUG
-	if (!(iwl_get_debug_level(priv) & IWL_DL_FW_ERRORS))
+	if (!(iwl_get_debug_level(priv) & IWL_DL_FW_ERRORS) && !full_log)
 		size = (size > DEFAULT_IWL3945_DUMP_EVENT_LOG_ENTRIES)
 			? DEFAULT_IWL3945_DUMP_EVENT_LOG_ENTRIES : size;
 #else
@@ -3867,7 +3866,6 @@ static int iwl3945_init_drv(struct iwl_priv *priv)
 	priv->retry_rate = 1;
 	priv->ibss_beacon = NULL;
 
-	spin_lock_init(&priv->lock);
 	spin_lock_init(&priv->sta_lock);
 	spin_lock_init(&priv->hcmd_lock);
 
@@ -3936,9 +3934,11 @@ static int iwl3945_setup_mac(struct iwl_priv *priv)
 	/* Tell mac80211 our characteristics */
 	hw->flags = IEEE80211_HW_SIGNAL_DBM |
 		    IEEE80211_HW_NOISE_DBM |
-		    IEEE80211_HW_SPECTRUM_MGMT |
-		    IEEE80211_HW_SUPPORTS_PS |
-		    IEEE80211_HW_SUPPORTS_DYNAMIC_PS;
+		    IEEE80211_HW_SPECTRUM_MGMT;
+
+	if (!priv->cfg->broken_powersave)
+		hw->flags |= IEEE80211_HW_SUPPORTS_PS |
+			     IEEE80211_HW_SUPPORTS_DYNAMIC_PS;
 
 	hw->wiphy->interface_modes =
 		BIT(NL80211_IFTYPE_STATION) |
@@ -4057,10 +4057,11 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	 * PCI Tx retries from interfering with C3 CPU state */
 	pci_write_config_byte(pdev, 0x41, 0x00);
 
-	/* this spin lock will be used in apm_ops.init and EEPROM access
+	/* these spin locks will be used in apm_ops.init and EEPROM access
 	 * we should init now
 	 */
 	spin_lock_init(&priv->reg_lock);
+	spin_lock_init(&priv->lock);
 
 	/***********************
 	 * 4. Read EEPROM
diff --git a/drivers/net/wireless/iwmc3200wifi/iwm.h b/drivers/net/wireless/iwmc3200wifi/iwm.h
index 5a26bb0..79ffa3b 100644
--- a/drivers/net/wireless/iwmc3200wifi/iwm.h
+++ b/drivers/net/wireless/iwmc3200wifi/iwm.h
@@ -349,7 +349,7 @@ int iwm_up(struct iwm_priv *iwm);
 int iwm_down(struct iwm_priv *iwm);
 
 /* TX API */
-u16 iwm_tid_to_queue(u16 tid);
+int iwm_tid_to_queue(u16 tid);
 void iwm_tx_credit_inc(struct iwm_priv *iwm, int id, int total_freed_pages);
 void iwm_tx_worker(struct work_struct *work);
 int iwm_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
diff --git a/drivers/net/wireless/iwmc3200wifi/netdev.c b/drivers/net/wireless/iwmc3200wifi/netdev.c
index e4f0f87..c4c0d23 100644
--- a/drivers/net/wireless/iwmc3200wifi/netdev.c
+++ b/drivers/net/wireless/iwmc3200wifi/netdev.c
@@ -76,7 +76,7 @@ static int iwm_stop(struct net_device *ndev)
  */
 static const u16 iwm_1d_to_queue[8] = { 1, 0, 0, 1, 2, 2, 3, 3 };
 
-u16 iwm_tid_to_queue(u16 tid)
+int iwm_tid_to_queue(u16 tid)
 {
 	if (tid > IWM_UMAC_TID_NR - 2)
 		return -EINVAL;
diff --git a/drivers/net/wireless/iwmc3200wifi/rx.c b/drivers/net/wireless/iwmc3200wifi/rx.c
index 72c27a3..3db3d8b 100644
--- a/drivers/net/wireless/iwmc3200wifi/rx.c
+++ b/drivers/net/wireless/iwmc3200wifi/rx.c
@@ -1126,7 +1126,7 @@ static int iwm_ntf_stop_resume_tx(struct iwm_priv *iwm, u8 *buf,
 
 		if (!stop) {
 			struct iwm_tx_queue *txq;
-			u16 queue = iwm_tid_to_queue(bit);
+			int queue = iwm_tid_to_queue(bit);
 
 			if (queue < 0)
 				continue;
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index a8eb9e1..4b1aab5 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -2025,10 +2025,8 @@ static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
 	if (priv->connect_status == LBS_CONNECTED) {
 		memcpy(extra, priv->curbssparams.ssid,
 		       priv->curbssparams.ssid_len);
-		extra[priv->curbssparams.ssid_len] = '\0';
 	} else {
 		memset(extra, 0, 32);
-		extra[priv->curbssparams.ssid_len] = '\0';
 	}
 	/*
 	 * If none, we may want to get the one that was set
diff --git a/drivers/net/wireless/rt2x00/rt2800.h b/drivers/net/wireless/rt2x00/rt2800.h
index c5fe867..1a7eae3 100644
--- a/drivers/net/wireless/rt2x00/rt2800.h
+++ b/drivers/net/wireless/rt2x00/rt2800.h
@@ -1323,7 +1323,7 @@
 #define PAIRWISE_KEY_ENTRY(__idx) \
 	( PAIRWISE_KEY_TABLE_BASE + ((__idx) * sizeof(struct hw_key_entry)) )
 #define MAC_IVEIV_ENTRY(__idx) \
-	( MAC_IVEIV_TABLE_BASE + ((__idx) & sizeof(struct mac_iveiv_entry)) )
+	( MAC_IVEIV_TABLE_BASE + ((__idx) * sizeof(struct mac_iveiv_entry)) )
 #define MAC_WCID_ATTR_ENTRY(__idx) \
 	( MAC_WCID_ATTRIBUTE_BASE + ((__idx) * sizeof(u32)) )
 #define SHARED_KEY_ENTRY(__idx) \
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index eb1e1d0..27bf887 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -37,7 +37,7 @@
 #include <linux/module.h>
 
 #include "rt2x00.h"
-#ifdef CONFIG_RT2800USB
+#if defined(CONFIG_RT2800USB) || defined(CONFIG_RT2800USB_MODULE)
 #include "rt2x00usb.h"
 #endif
 #include "rt2800lib.h"
@@ -1121,7 +1121,7 @@ int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 
 	if (rt2x00_intf_is_usb(rt2x00dev)) {
 		rt2800_register_write(rt2x00dev, USB_DMA_CFG, 0x00000000);
-#ifdef CONFIG_RT2800USB
+#if defined(CONFIG_RT2800USB) || defined(CONFIG_RT2800USB_MODULE)
 		rt2x00usb_vendor_request_sw(rt2x00dev, USB_DEVICE_MODE, 0,
 					    USB_MODE_RESET, REGISTER_TIMEOUT);
 #endif
@@ -2022,6 +2022,12 @@ int rt2800_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	u16 eeprom;
 
 	/*
+	 * Disable powersaving as default on PCI devices.
+	 */
+	if (rt2x00_intf_is_pci(rt2x00dev))
+		rt2x00dev->hw->wiphy->flags &= ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
+
+	/*
 	 * Initialize all hw fields.
 	 */
 	rt2x00dev->hw->flags =
@@ -2074,8 +2080,7 @@ int rt2800_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	    IEEE80211_HT_CAP_SGI_20 |
 	    IEEE80211_HT_CAP_SGI_40 |
 	    IEEE80211_HT_CAP_TX_STBC |
-	    IEEE80211_HT_CAP_RX_STBC |
-	    IEEE80211_HT_CAP_PSMP_SUPPORT;
+	    IEEE80211_HT_CAP_RX_STBC;
 	spec->ht.ampdu_factor = 3;
 	spec->ht.ampdu_density = 4;
 	spec->ht.mcs.tx_params =
@@ -2140,8 +2145,8 @@ static void rt2800_get_tkip_seq(struct ieee80211_hw *hw, u8 hw_key_idx,
 	rt2800_register_multiread(rt2x00dev, offset,
 				      &iveiv_entry, sizeof(iveiv_entry));
 
-	memcpy(&iveiv_entry.iv[0], iv16, sizeof(iv16));
-	memcpy(&iveiv_entry.iv[4], iv32, sizeof(iv32));
+	memcpy(iv16, &iveiv_entry.iv[0], sizeof(*iv16));
+	memcpy(iv32, &iveiv_entry.iv[4], sizeof(*iv32));
 }
 
 static int rt2800_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 687e17d..0ca5893 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2539,6 +2539,11 @@ static int rt61pci_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	unsigned int i;
 
 	/*
+	 * Disable powersaving as default.
+	 */
+	rt2x00dev->hw->wiphy->flags &= ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
+
+	/*
 	 * Initialize all hw fields.
 	 */
 	rt2x00dev->hw->flags =
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index d9724a2..163c840 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -832,7 +832,7 @@ struct ieee80211_ht_cap {
 #define IEEE80211_HT_CAP_DELAY_BA		0x0400
 #define IEEE80211_HT_CAP_MAX_AMSDU		0x0800
 #define IEEE80211_HT_CAP_DSSSCCK40		0x1000
-#define IEEE80211_HT_CAP_PSMP_SUPPORT		0x2000
+#define IEEE80211_HT_CAP_RESERVED		0x2000
 #define IEEE80211_HT_CAP_40MHZ_INTOLERANT	0x4000
 #define IEEE80211_HT_CAP_LSIG_TXOP_PROT		0x8000
 
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 2aff490..538d6b7 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1737,6 +1737,12 @@ static inline void ieee80211_rx_ni(struct ieee80211_hw *hw,
 	local_bh_enable();
 }
 
+/*
+ * The TX headroom reserved by mac80211 for its own tx_status functions.
+ * This is enough for the radiotap header.
+ */
+#define IEEE80211_TX_STATUS_HEADROOM	13
+
 /**
  * ieee80211_tx_status - transmit status callback
  *
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 3787455..d7dcee6 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -34,9 +34,28 @@ void ieee80211_ht_cap_ie_to_sta_ht_cap(struct ieee80211_supported_band *sband,
 
 	ht_cap->ht_supported = true;
 
-	ht_cap->cap = le16_to_cpu(ht_cap_ie->cap_info) & sband->ht_cap.cap;
-	ht_cap->cap &= ~IEEE80211_HT_CAP_SM_PS;
-	ht_cap->cap |= sband->ht_cap.cap & IEEE80211_HT_CAP_SM_PS;
+	/*
+	 * The bits listed in this expression should be
+	 * the same for the peer and us, if the station
+	 * advertises more then we can't use those thus
+	 * we mask them out.
+	 */
+	ht_cap->cap = le16_to_cpu(ht_cap_ie->cap_info) &
+		(sband->ht_cap.cap |
+		 ~(IEEE80211_HT_CAP_LDPC_CODING |
+		   IEEE80211_HT_CAP_SUP_WIDTH_20_40 |
+		   IEEE80211_HT_CAP_GRN_FLD |
+		   IEEE80211_HT_CAP_SGI_20 |
+		   IEEE80211_HT_CAP_SGI_40 |
+		   IEEE80211_HT_CAP_DSSSCCK40));
+	/*
+	 * The STBC bits are asymmetric -- if we don't have
+	 * TX then mask out the peer's RX and vice versa.
+	 */
+	if (!(sband->ht_cap.cap & IEEE80211_HT_CAP_TX_STBC))
+		ht_cap->cap &= ~IEEE80211_HT_CAP_RX_STBC;
+	if (!(sband->ht_cap.cap & IEEE80211_HT_CAP_RX_STBC))
+		ht_cap->cap &= ~IEEE80211_HT_CAP_TX_STBC;
 
 	ampdu_info = ht_cap_ie->ampdu_params_info;
 	ht_cap->ampdu_factor =
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 8116d1a..0d2d948 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -515,6 +515,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	 * and we need some headroom for passing the frame to monitor
 	 * interfaces, but never both at the same time.
 	 */
+	BUILD_BUG_ON(IEEE80211_TX_STATUS_HEADROOM !=
+			sizeof(struct ieee80211_tx_status_rtap_hdr));
 	local->tx_headroom = max_t(unsigned int , local->hw.extra_tx_headroom,
 				   sizeof(struct ieee80211_tx_status_rtap_hdr));
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index d8d50fb..c79e59f 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -915,6 +915,14 @@ static void ieee80211_set_associated(struct ieee80211_sub_if_data *sdata,
 	sdata->u.mgd.flags &= ~(IEEE80211_STA_CONNECTION_POLL |
 				IEEE80211_STA_BEACON_POLL);
 
+	/*
+	 * Always handle WMM once after association regardless
+	 * of the first value the AP uses. Setting -1 here has
+	 * that effect because the AP values is an unsigned
+	 * 4-bit value.
+	 */
+	sdata->u.mgd.wmm_last_param_set = -1;
+
 	ieee80211_led_assoc(local, 1);
 
 	sdata->vif.bss_conf.assoc = 1;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
