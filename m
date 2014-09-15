From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 1/2] brcm80211: use container_of to resolve brcms_phy from brcms_phy_pub
Date: Mon, 15 Sep 2014 21:30:46 +0200
Message-ID: <1410809448-15982-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: brudley@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use container_of instead of casting first structure member.

Acked-by: Arend van Spriel <arend@broadcom.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---

Compiled but untested.

V2: 2 separate patches for brcm80211 (suggested by Arend van Spriel)

 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  | 122 ++++++++++-----------
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |   6 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   8 +-
 3 files changed, 68 insertions(+), 68 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
index 57ecc05..941b1e4 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
@@ -128,19 +128,19 @@ static const u8 ofdm_rate_lookup[] = {
 
 void wlc_phyreg_enter(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	wlapi_bmac_ucode_wake_override_phyreg_set(pi->sh->physhim);
 }
 
 void wlc_phyreg_exit(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	wlapi_bmac_ucode_wake_override_phyreg_clear(pi->sh->physhim);
 }
 
 void wlc_radioreg_enter(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	wlapi_bmac_mctrl(pi->sh->physhim, MCTL_LOCK_RADIO, MCTL_LOCK_RADIO);
 
 	udelay(10);
@@ -148,7 +148,7 @@ void wlc_radioreg_enter(struct brcms_phy_pub *pih)
 
 void wlc_radioreg_exit(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	(void)bcma_read16(pi->d11core, D11REGOFFS(phyversion));
 	pi->phy_wreg = 0;
@@ -586,7 +586,7 @@ err:
 
 void wlc_phy_detach(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (pih) {
 		if (--pi->refcnt)
@@ -613,7 +613,7 @@ bool
 wlc_phy_get_phyversion(struct brcms_phy_pub *pih, u16 *phytype, u16 *phyrev,
 		       u16 *radioid, u16 *radiover)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	*phytype = (u16) pi->pubpi.phy_type;
 	*phyrev = (u16) pi->pubpi.phy_rev;
 	*radioid = pi->pubpi.radioid;
@@ -624,19 +624,19 @@ wlc_phy_get_phyversion(struct brcms_phy_pub *pih, u16 *phytype, u16 *phyrev,
 
 bool wlc_phy_get_encore(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	return pi->pubpi.abgphy_encore;
 }
 
 u32 wlc_phy_get_coreflags(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	return pi->pubpi.coreflags;
 }
 
 void wlc_phy_anacore(struct brcms_phy_pub *pih, bool on)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (ISNPHY(pi)) {
 		if (on) {
@@ -673,7 +673,7 @@ void wlc_phy_anacore(struct brcms_phy_pub *pih, bool on)
 
 u32 wlc_phy_clk_bwbits(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	u32 phy_bw_clkbits = 0;
 
@@ -698,14 +698,14 @@ u32 wlc_phy_clk_bwbits(struct brcms_phy_pub *pih)
 
 void wlc_phy_por_inform(struct brcms_phy_pub *ppi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	pi->phy_init_por = true;
 }
 
 void wlc_phy_edcrs_lock(struct brcms_phy_pub *pih, bool lock)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	pi->edcrs_threshold_lock = lock;
 
@@ -717,14 +717,14 @@ void wlc_phy_edcrs_lock(struct brcms_phy_pub *pih, bool lock)
 
 void wlc_phy_initcal_enable(struct brcms_phy_pub *pih, bool initcal)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	pi->do_initcal = initcal;
 }
 
 void wlc_phy_hw_clk_state_upd(struct brcms_phy_pub *pih, bool newstate)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (!pi || !pi->sh)
 		return;
@@ -734,7 +734,7 @@ void wlc_phy_hw_clk_state_upd(struct brcms_phy_pub *pih, bool newstate)
 
 void wlc_phy_hw_state_upd(struct brcms_phy_pub *pih, bool newstate)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (!pi || !pi->sh)
 		return;
@@ -746,7 +746,7 @@ void wlc_phy_init(struct brcms_phy_pub *pih, u16 chanspec)
 {
 	u32 mc;
 	void (*phy_init)(struct brcms_phy *) = NULL;
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (pi->init_in_progress)
 		return;
@@ -798,7 +798,7 @@ void wlc_phy_init(struct brcms_phy_pub *pih, u16 chanspec)
 
 void wlc_phy_cal_init(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	void (*cal_init)(struct brcms_phy *) = NULL;
 
 	if (WARN((bcma_read32(pi->d11core, D11REGOFFS(maccontrol)) &
@@ -816,7 +816,7 @@ void wlc_phy_cal_init(struct brcms_phy_pub *pih)
 
 int wlc_phy_down(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	int callbacks = 0;
 
 	if (pi->phycal_timer
@@ -1070,7 +1070,7 @@ void wlc_phy_do_dummy_tx(struct brcms_phy *pi, bool ofdm, bool pa_on)
 
 void wlc_phy_hold_upd(struct brcms_phy_pub *pih, u32 id, bool set)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (set)
 		mboolset(pi->measure_hold, id);
@@ -1082,7 +1082,7 @@ void wlc_phy_hold_upd(struct brcms_phy_pub *pih, u32 id, bool set)
 
 void wlc_phy_mute_upd(struct brcms_phy_pub *pih, bool mute, u32 flags)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (mute)
 		mboolset(pi->measure_hold, PHY_HOLD_FOR_MUTE);
@@ -1096,7 +1096,7 @@ void wlc_phy_mute_upd(struct brcms_phy_pub *pih, bool mute, u32 flags)
 
 void wlc_phy_clear_tssi(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (ISNPHY(pi)) {
 		return;
@@ -1115,7 +1115,7 @@ static bool wlc_phy_cal_txpower_recalc_sw(struct brcms_phy *pi)
 
 void wlc_phy_switch_radio(struct brcms_phy_pub *pih, bool on)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	(void)bcma_read32(pi->d11core, D11REGOFFS(maccontrol));
 
 	if (ISNPHY(pi)) {
@@ -1149,35 +1149,35 @@ void wlc_phy_switch_radio(struct brcms_phy_pub *pih, bool on)
 
 u16 wlc_phy_bw_state_get(struct brcms_phy_pub *ppi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	return pi->bw;
 }
 
 void wlc_phy_bw_state_set(struct brcms_phy_pub *ppi, u16 bw)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	pi->bw = bw;
 }
 
 void wlc_phy_chanspec_radio_set(struct brcms_phy_pub *ppi, u16 newch)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	pi->radio_chanspec = newch;
 
 }
 
 u16 wlc_phy_chanspec_get(struct brcms_phy_pub *ppi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	return pi->radio_chanspec;
 }
 
 void wlc_phy_chanspec_set(struct brcms_phy_pub *ppi, u16 chanspec)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	u16 m_cur_channel;
 	void (*chanspec_set)(struct brcms_phy *, u16) = NULL;
 	m_cur_channel = CHSPEC_CHANNEL(chanspec);
@@ -1226,7 +1226,7 @@ int wlc_phy_chanspec_bandrange_get(struct brcms_phy *pi, u16 chanspec)
 void wlc_phy_chanspec_ch14_widefilter_set(struct brcms_phy_pub *ppi,
 					  bool wide_filter)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	pi->channel_14_wide_filter = wide_filter;
 
@@ -1246,7 +1246,7 @@ void
 wlc_phy_chanspec_band_validch(struct brcms_phy_pub *ppi, uint band,
 			      struct brcms_chanvec *channels)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	uint i;
 	uint channel;
 
@@ -1267,7 +1267,7 @@ wlc_phy_chanspec_band_validch(struct brcms_phy_pub *ppi, uint band,
 
 u16 wlc_phy_chanspec_band_firstch(struct brcms_phy_pub *ppi, uint band)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	uint i;
 	uint channel;
 	u16 chspec;
@@ -1311,7 +1311,7 @@ u16 wlc_phy_chanspec_band_firstch(struct brcms_phy_pub *ppi, uint band)
 
 int wlc_phy_txpower_get(struct brcms_phy_pub *ppi, uint *qdbm, bool *override)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	*qdbm = pi->tx_user_target[0];
 	if (override != NULL)
@@ -1323,7 +1323,7 @@ void wlc_phy_txpower_target_set(struct brcms_phy_pub *ppi,
 				struct txpwr_limits *txpwr)
 {
 	bool mac_enabled = false;
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	memcpy(&pi->tx_user_target[TXP_FIRST_CCK],
 	       &txpwr->cck[0], BRCMS_NUM_RATES_CCK);
@@ -1371,7 +1371,7 @@ void wlc_phy_txpower_target_set(struct brcms_phy_pub *ppi,
 
 int wlc_phy_txpower_set(struct brcms_phy_pub *ppi, uint qdbm, bool override)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	int i;
 
 	if (qdbm > 127)
@@ -1407,7 +1407,7 @@ void
 wlc_phy_txpower_sromlimit(struct brcms_phy_pub *ppi, uint channel, u8 *min_pwr,
 			  u8 *max_pwr, int txp_rate_idx)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	uint i;
 
 	*min_pwr = pi->min_txpower * BRCMS_TXPWR_DB_FACTOR;
@@ -1456,7 +1456,7 @@ void
 wlc_phy_txpower_sromlimit_max_get(struct brcms_phy_pub *ppi, uint chan,
 				  u8 *max_txpwr, u8 *min_txpwr)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	u8 tx_pwr_max = 0;
 	u8 tx_pwr_min = 255;
 	u8 max_num_rate;
@@ -1493,14 +1493,14 @@ wlc_phy_txpower_boardlimit_band(struct brcms_phy_pub *ppi, uint bandunit,
 
 u8 wlc_phy_txpower_get_target_min(struct brcms_phy_pub *ppi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	return pi->tx_power_min;
 }
 
 u8 wlc_phy_txpower_get_target_max(struct brcms_phy_pub *ppi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	return pi->tx_power_max;
 }
@@ -1812,21 +1812,21 @@ wlc_phy_txpower_reg_limit_calc(struct brcms_phy *pi, struct txpwr_limits *txpwr,
 
 void wlc_phy_txpwr_percent_set(struct brcms_phy_pub *ppi, u8 txpwr_percent)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	pi->txpwr_percent = txpwr_percent;
 }
 
 void wlc_phy_machwcap_set(struct brcms_phy_pub *ppi, u32 machwcap)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	pi->sh->machwcap = machwcap;
 }
 
 void wlc_phy_runbist_config(struct brcms_phy_pub *ppi, bool start_end)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	u16 rxc;
 	rxc = 0;
 
@@ -1857,7 +1857,7 @@ void
 wlc_phy_txpower_limit_set(struct brcms_phy_pub *ppi, struct txpwr_limits *txpwr,
 			  u16 chanspec)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	wlc_phy_txpower_reg_limit_calc(pi, txpwr, chanspec);
 
@@ -1881,14 +1881,14 @@ wlc_phy_txpower_limit_set(struct brcms_phy_pub *ppi, struct txpwr_limits *txpwr,
 
 void wlc_phy_ofdm_rateset_war(struct brcms_phy_pub *pih, bool war)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	pi->ofdm_rateset_war = war;
 }
 
 void wlc_phy_bf_preempt_enable(struct brcms_phy_pub *pih, bool bf_preempt)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	pi->bf_preempt_4306 = bf_preempt;
 }
@@ -1945,7 +1945,7 @@ void wlc_phy_txpower_update_shm(struct brcms_phy *pi)
 
 bool wlc_phy_txpower_hw_ctrl_get(struct brcms_phy_pub *ppi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	if (ISNPHY(pi))
 		return pi->nphy_txpwrctrl;
@@ -1955,7 +1955,7 @@ bool wlc_phy_txpower_hw_ctrl_get(struct brcms_phy_pub *ppi)
 
 void wlc_phy_txpower_hw_ctrl_set(struct brcms_phy_pub *ppi, bool hwpwrctrl)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	bool suspend;
 
 	if (!pi->hwpwrctrl_capable)
@@ -2038,7 +2038,7 @@ void
 wlc_phy_txpower_get_current(struct brcms_phy_pub *ppi, struct tx_power *power,
 			    uint channel)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	uint rate, num_rates;
 	u8 min_pwr, max_pwr;
 
@@ -2136,21 +2136,21 @@ wlc_phy_txpower_get_current(struct brcms_phy_pub *ppi, struct tx_power *power,
 
 void wlc_phy_antsel_type_set(struct brcms_phy_pub *ppi, u8 antsel_type)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	pi->antsel_type = antsel_type;
 }
 
 bool wlc_phy_test_ison(struct brcms_phy_pub *ppi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	return pi->phytest_on;
 }
 
 void wlc_phy_ant_rxdiv_set(struct brcms_phy_pub *ppi, u8 val)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	bool suspend;
 
 	pi->sh->rx_antdiv = val;
@@ -2283,7 +2283,7 @@ static s8 wlc_phy_noise_read_shmem(struct brcms_phy *pi)
 
 void wlc_phy_noise_sample_intr(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	u16 jssi_aux;
 	u8 channel = 0;
 	s8 noise_dbm = PHY_NOISE_FIXED_VAL_NPHY;
@@ -2339,7 +2339,7 @@ void wlc_phy_noise_sample_intr(struct brcms_phy_pub *pih)
 static void
 wlc_phy_noise_sample_request(struct brcms_phy_pub *pih, u8 reason, u8 ch)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	s8 noise_dbm = PHY_NOISE_FIXED_VAL_NPHY;
 	bool sampling_in_progress = (pi->phynoise_state != 0);
 	bool wait_for_intr = true;
@@ -2531,7 +2531,7 @@ int wlc_phy_rssi_compute(struct brcms_phy_pub *pih,
 {
 	int rssi = rxh->PhyRxStatus_1 & PRXS1_JSSI_MASK;
 	uint radioid = pih->radioid;
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if ((pi->sh->corerev >= 11)
 	    && !(rxh->RxStatus2 & RXS_PHYRXST_VALID)) {
@@ -2591,7 +2591,7 @@ void wlc_phy_set_deaf(struct brcms_phy_pub *ppi, bool user_flag)
 
 void wlc_phy_watchdog(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	bool delay_phy_cal = false;
 	pi->sh->now++;
 
@@ -2651,7 +2651,7 @@ void wlc_phy_watchdog(struct brcms_phy_pub *pih)
 
 void wlc_phy_BSSinit(struct brcms_phy_pub *pih, bool bonlyap, int rssi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	uint i;
 	uint k;
 
@@ -2711,7 +2711,7 @@ void wlc_phy_cal_perical(struct brcms_phy_pub *pih, u8 reason)
 	s16 nphy_currtemp = 0;
 	s16 delta_temp = 0;
 	bool do_periodic_cal = true;
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	if (!ISNPHY(pi))
 		return;
@@ -2804,7 +2804,7 @@ u8 wlc_phy_nbits(s32 value)
 
 void wlc_phy_stf_chain_init(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	pi->sh->hw_phytxchain = txchain;
 	pi->sh->hw_phyrxchain = rxchain;
@@ -2815,7 +2815,7 @@ void wlc_phy_stf_chain_init(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain)
 
 void wlc_phy_stf_chain_set(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	pi->sh->phytxchain = txchain;
 
@@ -2827,7 +2827,7 @@ void wlc_phy_stf_chain_set(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain)
 
 void wlc_phy_stf_chain_get(struct brcms_phy_pub *pih, u8 *txchain, u8 *rxchain)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	*txchain = pi->sh->phytxchain;
 	*rxchain = pi->sh->phyrxchain;
@@ -2837,7 +2837,7 @@ u8 wlc_phy_stf_chain_active_get(struct brcms_phy_pub *pih)
 {
 	s16 nphy_currtemp;
 	u8 active_bitmap;
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	active_bitmap = (pi->phy_txcore_heatedup) ? 0x31 : 0x33;
 
@@ -2867,7 +2867,7 @@ u8 wlc_phy_stf_chain_active_get(struct brcms_phy_pub *pih)
 
 s8 wlc_phy_stf_ssmode_get(struct brcms_phy_pub *pih, u16 chanspec)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	u8 siso_mcs_id, cdd_mcs_id;
 
 	siso_mcs_id =
@@ -2944,7 +2944,7 @@ s8 wlc_phy_upd_rssi_offset(struct brcms_phy *pi, s8 rssi, u16 chanspec)
 
 bool wlc_phy_txpower_ipa_ison(struct brcms_phy_pub *ppi)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	if (ISNPHY(pi))
 		return wlc_phy_n_txpower_ipa_ison(pi);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
index b2d6d6d..5f13662 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
@@ -2865,7 +2865,7 @@ static void wlc_lcnphy_idle_tssi_est(struct brcms_phy_pub *ppi)
 {
 	bool suspend, tx_gain_override_old;
 	struct lcnphy_txgains old_gains;
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	u16 idleTssi, idleTssi0_2C, idleTssi0_OB, idleTssi0_regvalue_OB,
 	    idleTssi0_regvalue_2C;
 	u16 SAVE_txpwrctrl = wlc_lcnphy_get_tx_pwr_ctrl(pi);
@@ -3084,7 +3084,7 @@ static void wlc_lcnphy_tx_pwr_ctrl_init(struct brcms_phy_pub *ppi)
 	s32 a1, b0, b1;
 	s32 tssi, pwr, maxtargetpwr, mintargetpwr;
 	bool suspend;
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 
 	suspend = (0 == (bcma_read32(pi->d11core, D11REGOFFS(maccontrol)) &
 			 MCTL_EN_MAC));
@@ -4348,7 +4348,7 @@ void wlc_lcnphy_tx_power_adjustment(struct brcms_phy_pub *ppi)
 {
 	s8 index;
 	u16 index2;
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	struct brcms_phy_lcnphy *pi_lcn = pi->u.pi_lcnphy;
 	u16 SAVE_txpwrctrl = wlc_lcnphy_get_tx_pwr_ctrl(pi);
 	if (wlc_lcnphy_tempsense_based_pwr_ctrl_enabled(pi) &&
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
index 93869e8..084f18f 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
@@ -14121,7 +14121,7 @@ static u8 ant_sw_ctrl_tbl_rev8_2057v7_core1[] = {
 
 bool wlc_phy_bist_check_phy(struct brcms_phy_pub *pih)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	u32 phybist0, phybist1, phybist2, phybist3, phybist4;
 
 	if (NREV_GE(pi->pubpi.phy_rev, 16))
@@ -19734,7 +19734,7 @@ void wlc_phy_rxcore_setstate_nphy(struct brcms_phy_pub *pih, u8 rxcore_bitmask)
 	u16 regval;
 	u16 tbl_buf[16];
 	uint i;
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 	u16 tbl_opcode;
 	bool suspend;
 
@@ -19812,7 +19812,7 @@ void wlc_phy_rxcore_setstate_nphy(struct brcms_phy_pub *pih, u8 rxcore_bitmask)
 u8 wlc_phy_rxcore_getstate_nphy(struct brcms_phy_pub *pih)
 {
 	u16 regval, rxen_bits;
-	struct brcms_phy *pi = (struct brcms_phy *) pih;
+	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
 
 	regval = read_phy_reg(pi, 0xa2);
 	rxen_bits = (regval >> 4) & 0xf;
@@ -21342,7 +21342,7 @@ void wlc_phy_chanspec_set_nphy(struct brcms_phy *pi, u16 chanspec)
 
 void wlc_phy_antsel_init(struct brcms_phy_pub *ppi, bool lut_init)
 {
-	struct brcms_phy *pi = (struct brcms_phy *) ppi;
+	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
 	u16 mask = 0xfc00;
 	u32 mc = 0;
 
-- 
1.9.1
