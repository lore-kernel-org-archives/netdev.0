From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-04-17
Date: Thu, 17 Apr 2014 10:57:57 -0400
Message-ID: <20140417145756.GB3435@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9jxsPFA5p3P2qPhR"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52986 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbaDQPAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 11:00:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.15 stream...

For the mac80211 bits, Johannes says:

"We have a fix from Chun-Yeow to not look at management frame bitrates
that are typically really low, two fixes from Felix for AP_VLAN
interfaces, a fix from Ido to disable SMPS settings when a monitor
interface is enabled, a radar detection fix from Micha=C5=82 and a fix from
myself for a very old remain-on-channel bug."

For the iwlwifi bits, Emmanuel says:

"I have new device IDs and a new firmware API. These are the trivial
ones. The less trivial ones are Johannes's fix that delays the
enablement of an interrupt coalescing hardware until after association
- this fixes a few connection problems seen in the field. Eyal has a
bunch of rate control fixes. I decided to add these for 3.15 because
they fix some disconnection and packet loss scenarios which were
reported by the field. I also have a fix for a memory leak that
happens only with a very new NIC."

Along with those...

Amitkumar Karwar fixes a couple of problems relating to driver/firmware
interactions in mwifiex.

Christian Engelmayer avoids a couple of potential memory leaks in
the new rsi driver.

Eliad Peller provides a wl18xx mailbox alignment fix for problems
when using new firmware.

Frederic Danis adds a couple of missing debugging strings to the
cw1200 driver.

Geert Uytterhoeven adds a variable initialization inside of the
rsi driver.

Luciano Coelho patches the wlcore code to ignore dummy packet events
in PLT mode in order to work around a firmware bug.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 0acf07d240a84069c4a6651e6030cf35d30c7159:

  seccomp: fix memory leak on filter attach (2014-04-16 15:25:53 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 4a0c3d9fd1af83ad0519997043467b817d3738fc:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-04-17 10:34:22 -0400)

----------------------------------------------------------------

Amitkumar Karwar (2):
      mwifiex: process event before command response
      mwifiex: fix hung task on command timeout

Christian Engelmayer (2):
      rsi: Fix a potential memory leak in rsi_set_channel()
      rsi: Fix a potential memory leak in rsi_send_auto_rate_request()

Chun-Yeow Yeoh (1):
      mac80211: update last_tx_rate only for data frame

Eliad Peller (1):
      wl18xx: align event mailbox with current fw

Emmanuel Grumbach (4):
      iwlwifi: mvm: BT Coex - send the new LUT upon antenna coupling change
      iwlwifi: 7000: bump API to 9
      iwlwifi: add MODULE_FIRMWARE for 7265
      iwlwifi: mvm: BT Coex - fix Look Up Table

Eyal Shapira (7):
      iwlwifi: mvm: rs: fix mimo delimiter in LQ cmd
      iwlwifi: mvm: rs: use correct max expected throughput figures
      iwlwifi: mvm: rs: fix and cleanup rs_get_rate_action
      iwlwifi: mvm: rs: reinit rs if no tx for a long time
      iwlwifi: mvm: rs: fallback to legacy Tx columns
      iwlwifi: mvm: avoid searching unnecessary columns
      iwlwifi: mvm: rs: clear per rate stats when aggregation changes

Felix Fietkau (2):
      mac80211: suppress BSS info change notifications for AP_VLAN
      mac80211: exclude AP_VLAN interfaces from tx power calculation

Frederic Danis (1):
      cw1200: Fix cw1200_debug_link_id

Geert Uytterhoeven (1):
      rsi: Add missing initialization of ii

Ido Yariv (1):
      mac80211: Disable SMPS for the monitor interface

Johannes Berg (2):
      mac80211: fix software remain-on-channel implementation
      iwlwifi: mvm: delay enabling smart FIFO until after beacon RX

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Luciano Coelho (1):
      wlcore: ignore dummy packet events in PLT mode

Michal Kazior (1):
      mac80211: fix radar_enabled propagation

Oren Givon (1):
      iwlwifi: add new 7265 HW IDs

 drivers/net/wireless/cw1200/debug.c         |   2 +
 drivers/net/wireless/iwlwifi/iwl-7000.c     |   5 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c     |  18 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c |   1 +
 drivers/net/wireless/iwlwifi/mvm/rs.c       | 261 ++++++++++++++++++------=
----
 drivers/net/wireless/iwlwifi/mvm/rs.h       |  14 +-
 drivers/net/wireless/iwlwifi/mvm/sf.c       |   3 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c     |   2 +
 drivers/net/wireless/mwifiex/main.c         |  12 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c    |   7 +-
 drivers/net/wireless/rsi/rsi_91x_core.c     |   2 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c     |  21 +--
 drivers/net/wireless/ti/wl18xx/event.h      |  20 +++
 drivers/net/wireless/ti/wlcore/event.c      |   5 +
 net/mac80211/chan.c                         |  11 +-
 net/mac80211/main.c                         |   4 +-
 net/mac80211/offchannel.c                   |   1 +
 net/mac80211/status.c                       |   1 +
 18 files changed, 258 insertions(+), 132 deletions(-)

diff --git a/drivers/net/wireless/cw1200/debug.c b/drivers/net/wireless/cw1=
200/debug.c
index e323b4d54338..34f97c31eecf 100644
--- a/drivers/net/wireless/cw1200/debug.c
+++ b/drivers/net/wireless/cw1200/debug.c
@@ -41,6 +41,8 @@ static const char * const cw1200_debug_link_id[] =3D {
 	"REQ",
 	"SOFT",
 	"HARD",
+	"RESET",
+	"RESET_REMAP",
 };
=20
 static const char *cw1200_debug_mode(int mode)
diff --git a/drivers/net/wireless/iwlwifi/iwl-7000.c b/drivers/net/wireless=
/iwlwifi/iwl-7000.c
index 003a546571d4..4c2d4ef28b22 100644
--- a/drivers/net/wireless/iwlwifi/iwl-7000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-7000.c
@@ -67,8 +67,8 @@
 #include "iwl-agn-hw.h"
=20
 /* Highest firmware API version supported */
-#define IWL7260_UCODE_API_MAX	8
-#define IWL3160_UCODE_API_MAX	8
+#define IWL7260_UCODE_API_MAX	9
+#define IWL3160_UCODE_API_MAX	9
=20
 /* Oldest version we won't warn about */
 #define IWL7260_UCODE_API_OK	8
@@ -244,3 +244,4 @@ const struct iwl_cfg iwl7265_n_cfg =3D {
=20
 MODULE_FIRMWARE(IWL7260_MODULE_FIRMWARE(IWL7260_UCODE_API_OK));
 MODULE_FIRMWARE(IWL3160_MODULE_FIRMWARE(IWL3160_UCODE_API_OK));
+MODULE_FIRMWARE(IWL7265_MODULE_FIRMWARE(IWL7260_UCODE_API_OK));
diff --git a/drivers/net/wireless/iwlwifi/mvm/coex.c b/drivers/net/wireless=
/iwlwifi/mvm/coex.c
index 685f7e8e6943..fa858d548d13 100644
--- a/drivers/net/wireless/iwlwifi/mvm/coex.c
+++ b/drivers/net/wireless/iwlwifi/mvm/coex.c
@@ -190,7 +190,7 @@ static const __le32 iwl_combined_lookup[BT_COEX_MAX_LUT=
][BT_COEX_LUT_SIZE] =3D {
 		cpu_to_le32(0xcc00aaaa),
 		cpu_to_le32(0x0000aaaa),
 		cpu_to_le32(0xc0004000),
-		cpu_to_le32(0x00000000),
+		cpu_to_le32(0x00004000),
 		cpu_to_le32(0xf0005000),
 		cpu_to_le32(0xf0005000),
 	},
@@ -213,16 +213,16 @@ static const __le32 iwl_combined_lookup[BT_COEX_MAX_L=
UT][BT_COEX_LUT_SIZE] =3D {
 		/* Tx Tx disabled */
 		cpu_to_le32(0xaaaaaaaa),
 		cpu_to_le32(0xaaaaaaaa),
-		cpu_to_le32(0xaaaaaaaa),
+		cpu_to_le32(0xeeaaaaaa),
 		cpu_to_le32(0xaaaaaaaa),
 		cpu_to_le32(0xcc00ff28),
 		cpu_to_le32(0x0000aaaa),
 		cpu_to_le32(0xcc00aaaa),
 		cpu_to_le32(0x0000aaaa),
-		cpu_to_le32(0xC0004000),
-		cpu_to_le32(0xC0004000),
-		cpu_to_le32(0xF0005000),
-		cpu_to_le32(0xF0005000),
+		cpu_to_le32(0xc0004000),
+		cpu_to_le32(0xc0004000),
+		cpu_to_le32(0xf0005000),
+		cpu_to_le32(0xf0005000),
 	},
 };
=20
@@ -1262,6 +1262,7 @@ int iwl_mvm_rx_ant_coupling_notif(struct iwl_mvm *mvm,
 	struct iwl_rx_packet *pkt =3D rxb_addr(rxb);
 	u32 ant_isolation =3D le32_to_cpup((void *)pkt->data);
 	u8 __maybe_unused lower_bound, upper_bound;
+	int ret;
 	u8 lut;
=20
 	struct iwl_bt_coex_cmd *bt_cmd;
@@ -1318,5 +1319,8 @@ int iwl_mvm_rx_ant_coupling_notif(struct iwl_mvm *mvm,
 	memcpy(bt_cmd->bt4_corun_lut40, antenna_coupling_ranges[lut].lut20,
 	       sizeof(bt_cmd->bt4_corun_lut40));
=20
-	return 0;
+	ret =3D iwl_mvm_send_cmd(mvm, &cmd);
+
+	kfree(bt_cmd);
+	return ret;
 }
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index 4dd9ff43b8b6..f0cebf12c7b8 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -1332,6 +1332,7 @@ static void iwl_mvm_bss_info_changed_station(struct i=
wl_mvm *mvm,
 		 */
 		iwl_mvm_remove_time_event(mvm, mvmvif,
 					  &mvmvif->time_event_data);
+		iwl_mvm_sf_update(mvm, vif, false);
 		WARN_ON(iwl_mvm_enable_beacon_filter(mvm, vif, CMD_SYNC));
 	} else if (changes & (BSS_CHANGED_PS | BSS_CHANGED_P2P_PS |
 			      BSS_CHANGED_QOS)) {
diff --git a/drivers/net/wireless/iwlwifi/mvm/rs.c b/drivers/net/wireless/i=
wlwifi/mvm/rs.c
index 568abd61b14f..9f52c5b3f0ec 100644
--- a/drivers/net/wireless/iwlwifi/mvm/rs.c
+++ b/drivers/net/wireless/iwlwifi/mvm/rs.c
@@ -59,7 +59,7 @@
 /* max allowed rate miss before sync LQ cmd */
 #define IWL_MISSED_RATE_MAX		15
 #define RS_STAY_IN_COLUMN_TIMEOUT       (5*HZ)
-
+#define RS_IDLE_TIMEOUT                 (5*HZ)
=20
 static u8 rs_ht_to_legacy[] =3D {
 	[IWL_RATE_MCS_0_INDEX] =3D IWL_RATE_6M_INDEX,
@@ -142,7 +142,7 @@ enum rs_column_mode {
 	RS_MIMO2,
 };
=20
-#define MAX_NEXT_COLUMNS 5
+#define MAX_NEXT_COLUMNS 7
 #define MAX_COLUMN_CHECKS 3
=20
 typedef bool (*allow_column_func_t) (struct iwl_mvm *mvm,
@@ -212,8 +212,10 @@ static const struct rs_tx_column rs_tx_columns[] =3D {
 			RS_COLUMN_LEGACY_ANT_B,
 			RS_COLUMN_SISO_ANT_A,
 			RS_COLUMN_SISO_ANT_B,
-			RS_COLUMN_MIMO2,
-			RS_COLUMN_MIMO2_SGI,
+			RS_COLUMN_INVALID,
+			RS_COLUMN_INVALID,
+			RS_COLUMN_INVALID,
+			RS_COLUMN_INVALID,
 		},
 	},
 	[RS_COLUMN_LEGACY_ANT_B] =3D {
@@ -223,8 +225,10 @@ static const struct rs_tx_column rs_tx_columns[] =3D {
 			RS_COLUMN_LEGACY_ANT_A,
 			RS_COLUMN_SISO_ANT_A,
 			RS_COLUMN_SISO_ANT_B,
-			RS_COLUMN_MIMO2,
-			RS_COLUMN_MIMO2_SGI,
+			RS_COLUMN_INVALID,
+			RS_COLUMN_INVALID,
+			RS_COLUMN_INVALID,
+			RS_COLUMN_INVALID,
 		},
 	},
 	[RS_COLUMN_SISO_ANT_A] =3D {
@@ -235,7 +239,9 @@ static const struct rs_tx_column rs_tx_columns[] =3D {
 			RS_COLUMN_MIMO2,
 			RS_COLUMN_SISO_ANT_A_SGI,
 			RS_COLUMN_SISO_ANT_B_SGI,
-			RS_COLUMN_MIMO2_SGI,
+			RS_COLUMN_LEGACY_ANT_A,
+			RS_COLUMN_LEGACY_ANT_B,
+			RS_COLUMN_INVALID,
 		},
 		.checks =3D {
 			rs_siso_allow,
@@ -249,7 +255,9 @@ static const struct rs_tx_column rs_tx_columns[] =3D {
 			RS_COLUMN_MIMO2,
 			RS_COLUMN_SISO_ANT_B_SGI,
 			RS_COLUMN_SISO_ANT_A_SGI,
-			RS_COLUMN_MIMO2_SGI,
+			RS_COLUMN_LEGACY_ANT_A,
+			RS_COLUMN_LEGACY_ANT_B,
+			RS_COLUMN_INVALID,
 		},
 		.checks =3D {
 			rs_siso_allow,
@@ -265,6 +273,8 @@ static const struct rs_tx_column rs_tx_columns[] =3D {
 			RS_COLUMN_SISO_ANT_A,
 			RS_COLUMN_SISO_ANT_B,
 			RS_COLUMN_MIMO2,
+			RS_COLUMN_LEGACY_ANT_A,
+			RS_COLUMN_LEGACY_ANT_B,
 		},
 		.checks =3D {
 			rs_siso_allow,
@@ -281,6 +291,8 @@ static const struct rs_tx_column rs_tx_columns[] =3D {
 			RS_COLUMN_SISO_ANT_B,
 			RS_COLUMN_SISO_ANT_A,
 			RS_COLUMN_MIMO2,
+			RS_COLUMN_LEGACY_ANT_A,
+			RS_COLUMN_LEGACY_ANT_B,
 		},
 		.checks =3D {
 			rs_siso_allow,
@@ -296,6 +308,8 @@ static const struct rs_tx_column rs_tx_columns[] =3D {
 			RS_COLUMN_SISO_ANT_A_SGI,
 			RS_COLUMN_SISO_ANT_B_SGI,
 			RS_COLUMN_MIMO2_SGI,
+			RS_COLUMN_LEGACY_ANT_A,
+			RS_COLUMN_LEGACY_ANT_B,
 		},
 		.checks =3D {
 			rs_mimo_allow,
@@ -311,6 +325,8 @@ static const struct rs_tx_column rs_tx_columns[] =3D {
 			RS_COLUMN_SISO_ANT_A,
 			RS_COLUMN_SISO_ANT_B,
 			RS_COLUMN_MIMO2,
+			RS_COLUMN_LEGACY_ANT_A,
+			RS_COLUMN_LEGACY_ANT_B,
 		},
 		.checks =3D {
 			rs_mimo_allow,
@@ -503,10 +519,12 @@ static void rs_rate_scale_clear_window(struct iwl_rat=
e_scale_data *window)
 	window->average_tpt =3D IWL_INVALID_VALUE;
 }
=20
-static void rs_rate_scale_clear_tbl_windows(struct iwl_scale_tbl_info *tbl)
+static void rs_rate_scale_clear_tbl_windows(struct iwl_mvm *mvm,
+					    struct iwl_scale_tbl_info *tbl)
 {
 	int i;
=20
+	IWL_DEBUG_RATE(mvm, "Clearing up window stats\n");
 	for (i =3D 0; i < IWL_RATE_COUNT; i++)
 		rs_rate_scale_clear_window(&tbl->win[i]);
 }
@@ -992,6 +1010,13 @@ static void rs_tx_status(void *mvm_r, struct ieee8021=
1_supported_band *sband,
 		return;
 	}
=20
+#ifdef CPTCFG_MAC80211_DEBUGFS
+	/* Disable last tx check if we are debugging with fixed rate */
+	if (lq_sta->dbg_fixed_rate) {
+		IWL_DEBUG_RATE(mvm, "Fixed rate. avoid rate scaling\n");
+		return;
+	}
+#endif
 	if (!ieee80211_is_data(hdr->frame_control) ||
 	    info->flags & IEEE80211_TX_CTL_NO_ACK)
 		return;
@@ -1034,6 +1059,18 @@ static void rs_tx_status(void *mvm_r, struct ieee802=
11_supported_band *sband,
 			mac_index++;
 	}
=20
+	if (time_after(jiffies,
+		       (unsigned long)(lq_sta->last_tx + RS_IDLE_TIMEOUT))) {
+		int tid;
+		IWL_DEBUG_RATE(mvm, "Tx idle for too long. reinit rs\n");
+		for (tid =3D 0; tid < IWL_MAX_TID_COUNT; tid++)
+			ieee80211_stop_tx_ba_session(sta, tid);
+
+		iwl_mvm_rs_rate_init(mvm, sta, sband->band, false);
+		return;
+	}
+	lq_sta->last_tx =3D jiffies;
+
 	/* Here we actually compare this rate to the latest LQ command */
 	if ((mac_index < 0) ||
 	    (rate.sgi !=3D !!(mac_flags & IEEE80211_TX_RC_SHORT_GI)) ||
@@ -1186,9 +1223,26 @@ static void rs_set_stay_in_table(struct iwl_mvm *mvm=
, u8 is_legacy,
 	lq_sta->visited_columns =3D 0;
 }
=20
+static int rs_get_max_allowed_rate(struct iwl_lq_sta *lq_sta,
+				   const struct rs_tx_column *column)
+{
+	switch (column->mode) {
+	case RS_LEGACY:
+		return lq_sta->max_legacy_rate_idx;
+	case RS_SISO:
+		return lq_sta->max_siso_rate_idx;
+	case RS_MIMO2:
+		return lq_sta->max_mimo2_rate_idx;
+	default:
+		WARN_ON_ONCE(1);
+	}
+
+	return lq_sta->max_legacy_rate_idx;
+}
+
 static const u16 *rs_get_expected_tpt_table(struct iwl_lq_sta *lq_sta,
-				      const struct rs_tx_column *column,
-				      u32 bw)
+					    const struct rs_tx_column *column,
+					    u32 bw)
 {
 	/* Used to choose among HT tables */
 	const u16 (*ht_tbl_pointer)[IWL_RATE_COUNT];
@@ -1438,7 +1492,7 @@ static void rs_stay_in_table(struct iwl_lq_sta *lq_st=
a, bool force_search)
=20
 				IWL_DEBUG_RATE(mvm,
 					       "LQ: stay in table clear win\n");
-				rs_rate_scale_clear_tbl_windows(tbl);
+				rs_rate_scale_clear_tbl_windows(mvm, tbl);
 			}
 		}
=20
@@ -1446,8 +1500,7 @@ static void rs_stay_in_table(struct iwl_lq_sta *lq_st=
a, bool force_search)
 		 * bitmaps and stats in active table (this will become the new
 		 * "search" table). */
 		if (lq_sta->rs_state =3D=3D RS_STATE_SEARCH_CYCLE_STARTED) {
-			IWL_DEBUG_RATE(mvm, "Clearing up window stats\n");
-			rs_rate_scale_clear_tbl_windows(tbl);
+			rs_rate_scale_clear_tbl_windows(mvm, tbl);
 		}
 	}
 }
@@ -1485,14 +1538,14 @@ static enum rs_column rs_get_next_column(struct iwl=
_mvm *mvm,
 					 struct ieee80211_sta *sta,
 					 struct iwl_scale_tbl_info *tbl)
 {
-	int i, j, n;
+	int i, j, max_rate;
 	enum rs_column next_col_id;
 	const struct rs_tx_column *curr_col =3D &rs_tx_columns[tbl->column];
 	const struct rs_tx_column *next_col;
 	allow_column_func_t allow_func;
 	u8 valid_ants =3D mvm->fw->valid_tx_ant;
 	const u16 *expected_tpt_tbl;
-	s32 tpt, max_expected_tpt;
+	u16 tpt, max_expected_tpt;
=20
 	for (i =3D 0; i < MAX_NEXT_COLUMNS; i++) {
 		next_col_id =3D curr_col->next_columns[i];
@@ -1535,11 +1588,11 @@ static enum rs_column rs_get_next_column(struct iwl=
_mvm *mvm,
 		if (WARN_ON_ONCE(!expected_tpt_tbl))
 			continue;
=20
-		max_expected_tpt =3D 0;
-		for (n =3D 0; n < IWL_RATE_COUNT; n++)
-			if (expected_tpt_tbl[n] > max_expected_tpt)
-				max_expected_tpt =3D expected_tpt_tbl[n];
+		max_rate =3D rs_get_max_allowed_rate(lq_sta, next_col);
+		if (WARN_ON_ONCE(max_rate =3D=3D IWL_RATE_INVALID))
+			continue;
=20
+		max_expected_tpt =3D expected_tpt_tbl[max_rate];
 		if (tpt >=3D max_expected_tpt) {
 			IWL_DEBUG_RATE(mvm,
 				       "Skip column %d: can't beat current TPT. Max expected %d curren=
t %d\n",
@@ -1547,14 +1600,15 @@ static enum rs_column rs_get_next_column(struct iwl=
_mvm *mvm,
 			continue;
 		}
=20
+		IWL_DEBUG_RATE(mvm,
+			       "Found potential column %d. Max expected %d current %d\n",
+			       next_col_id, max_expected_tpt, tpt);
 		break;
 	}
=20
 	if (i =3D=3D MAX_NEXT_COLUMNS)
 		return RS_COLUMN_INVALID;
=20
-	IWL_DEBUG_RATE(mvm, "Found potential column %d\n", next_col_id);
-
 	return next_col_id;
 }
=20
@@ -1640,85 +1694,76 @@ static enum rs_action rs_get_rate_action(struct iwl=
_mvm *mvm,
 {
 	enum rs_action action =3D RS_ACTION_STAY;
=20
-	/* Too many failures, decrease rate */
 	if ((sr <=3D RS_SR_FORCE_DECREASE) || (current_tpt =3D=3D 0)) {
 		IWL_DEBUG_RATE(mvm,
-			       "decrease rate because of low SR\n");
-		action =3D RS_ACTION_DOWNSCALE;
-	/* No throughput measured yet for adjacent rates; try increase. */
-	} else if ((low_tpt =3D=3D IWL_INVALID_VALUE) &&
-		   (high_tpt =3D=3D IWL_INVALID_VALUE)) {
-		if (high !=3D IWL_RATE_INVALID && sr >=3D IWL_RATE_INCREASE_TH) {
-			IWL_DEBUG_RATE(mvm,
-				       "Good SR and no high rate measurement. "
-				       "Increase rate\n");
-			action =3D RS_ACTION_UPSCALE;
-		} else if (low !=3D IWL_RATE_INVALID) {
-			IWL_DEBUG_RATE(mvm,
-				       "Remain in current rate\n");
-			action =3D RS_ACTION_STAY;
-		}
+			       "Decrease rate because of low SR\n");
+		return RS_ACTION_DOWNSCALE;
 	}
=20
-	/* Both adjacent throughputs are measured, but neither one has better
-	 * throughput; we're using the best rate, don't change it!
-	 */
-	else if ((low_tpt !=3D IWL_INVALID_VALUE) &&
-		 (high_tpt !=3D IWL_INVALID_VALUE) &&
-		 (low_tpt < current_tpt) &&
-		 (high_tpt < current_tpt)) {
+	if ((low_tpt =3D=3D IWL_INVALID_VALUE) &&
+	    (high_tpt =3D=3D IWL_INVALID_VALUE) &&
+	    (high !=3D IWL_RATE_INVALID)) {
 		IWL_DEBUG_RATE(mvm,
-			       "Both high and low are worse. "
-			       "Maintain rate\n");
-		action =3D RS_ACTION_STAY;
+			       "No data about high/low rates. Increase rate\n");
+		return RS_ACTION_UPSCALE;
 	}
=20
-	/* At least one adjacent rate's throughput is measured,
-	 * and may have better performance.
-	 */
-	else {
-		/* Higher adjacent rate's throughput is measured */
-		if (high_tpt !=3D IWL_INVALID_VALUE) {
-			/* Higher rate has better throughput */
-			if (high_tpt > current_tpt &&
-			    sr >=3D IWL_RATE_INCREASE_TH) {
-				IWL_DEBUG_RATE(mvm,
-					       "Higher rate is better and good "
-					       "SR. Increate rate\n");
-				action =3D RS_ACTION_UPSCALE;
-			} else {
-				IWL_DEBUG_RATE(mvm,
-					       "Higher rate isn't better OR "
-					       "no good SR. Maintain rate\n");
-				action =3D RS_ACTION_STAY;
-			}
+	if ((high_tpt =3D=3D IWL_INVALID_VALUE) &&
+	    (high !=3D IWL_RATE_INVALID) &&
+	    (low_tpt !=3D IWL_INVALID_VALUE) &&
+	    (low_tpt < current_tpt)) {
+		IWL_DEBUG_RATE(mvm,
+			       "No data about high rate and low rate is worse. Increase rate\n"=
);
+		return RS_ACTION_UPSCALE;
+	}
=20
-		/* Lower adjacent rate's throughput is measured */
-		} else if (low_tpt !=3D IWL_INVALID_VALUE) {
-			/* Lower rate has better throughput */
-			if (low_tpt > current_tpt) {
-				IWL_DEBUG_RATE(mvm,
-					       "Lower rate is better. "
-					       "Decrease rate\n");
-				action =3D RS_ACTION_DOWNSCALE;
-			} else if (sr >=3D IWL_RATE_INCREASE_TH) {
-				IWL_DEBUG_RATE(mvm,
-					       "Lower rate isn't better and "
-					       "good SR. Increase rate\n");
-				action =3D RS_ACTION_UPSCALE;
-			}
-		}
+	if ((high_tpt !=3D IWL_INVALID_VALUE) &&
+	    (high_tpt > current_tpt)) {
+		IWL_DEBUG_RATE(mvm,
+			       "Higher rate is better. Increate rate\n");
+		return RS_ACTION_UPSCALE;
 	}
=20
-	/* Sanity check; asked for decrease, but success rate or throughput
-	 * has been good at old rate.  Don't change it.
-	 */
-	if ((action =3D=3D RS_ACTION_DOWNSCALE) && (low !=3D IWL_RATE_INVALID) &&
-	    ((sr > IWL_RATE_HIGH_TH) ||
-	     (current_tpt > (100 * tbl->expected_tpt[low])))) {
+	if ((low_tpt !=3D IWL_INVALID_VALUE) &&
+	    (high_tpt !=3D IWL_INVALID_VALUE) &&
+	    (low_tpt < current_tpt) &&
+	    (high_tpt < current_tpt)) {
+		IWL_DEBUG_RATE(mvm,
+			       "Both high and low are worse. Maintain rate\n");
+		return RS_ACTION_STAY;
+	}
+
+	if ((low_tpt !=3D IWL_INVALID_VALUE) &&
+	    (low_tpt > current_tpt)) {
+		IWL_DEBUG_RATE(mvm,
+			       "Lower rate is better\n");
+		action =3D RS_ACTION_DOWNSCALE;
+		goto out;
+	}
+
+	if ((low_tpt =3D=3D IWL_INVALID_VALUE) &&
+	    (low !=3D IWL_RATE_INVALID)) {
 		IWL_DEBUG_RATE(mvm,
-			       "Sanity check failed. Maintain rate\n");
-		action =3D RS_ACTION_STAY;
+			       "No data about lower rate\n");
+		action =3D RS_ACTION_DOWNSCALE;
+		goto out;
+	}
+
+	IWL_DEBUG_RATE(mvm, "Maintain rate\n");
+
+out:
+	if ((action =3D=3D RS_ACTION_DOWNSCALE) && (low !=3D IWL_RATE_INVALID)) {
+		if (sr >=3D RS_SR_NO_DECREASE) {
+			IWL_DEBUG_RATE(mvm,
+				       "SR is above NO DECREASE. Avoid downscale\n");
+			action =3D RS_ACTION_STAY;
+		} else if (current_tpt > (100 * tbl->expected_tpt[low])) {
+			IWL_DEBUG_RATE(mvm,
+				       "Current TPT is higher than max expected in low rate. Avoid dow=
nscale\n");
+			action =3D RS_ACTION_STAY;
+		} else {
+			IWL_DEBUG_RATE(mvm, "Decrease rate\n");
+		}
 	}
=20
 	return action;
@@ -1792,6 +1837,7 @@ static void rs_rate_scale_perform(struct iwl_mvm *mvm,
 			       "Aggregation changed: prev %d current %d. Update expected TPT ta=
ble\n",
 			       prev_agg, lq_sta->is_agg);
 		rs_set_expected_tpt_table(lq_sta, tbl);
+		rs_rate_scale_clear_tbl_windows(mvm, tbl);
 	}
=20
 	/* current tx rate */
@@ -2021,7 +2067,7 @@ lq_update:
 		if (lq_sta->search_better_tbl) {
 			/* Access the "search" table, clear its history. */
 			tbl =3D &(lq_sta->lq_info[(1 - lq_sta->active_tbl)]);
-			rs_rate_scale_clear_tbl_windows(tbl);
+			rs_rate_scale_clear_tbl_windows(mvm, tbl);
=20
 			/* Use new "search" start rate */
 			index =3D tbl->rate.index;
@@ -2042,8 +2088,18 @@ lq_update:
 		 * stay with best antenna legacy modulation for a while
 		 * before next round of mode comparisons. */
 		tbl1 =3D &(lq_sta->lq_info[lq_sta->active_tbl]);
-		if (is_legacy(&tbl1->rate) && !sta->ht_cap.ht_supported) {
+		if (is_legacy(&tbl1->rate)) {
 			IWL_DEBUG_RATE(mvm, "LQ: STAY in legacy table\n");
+
+			if (tid !=3D IWL_MAX_TID_COUNT) {
+				tid_data =3D &sta_priv->tid_data[tid];
+				if (tid_data->state !=3D IWL_AGG_OFF) {
+					IWL_DEBUG_RATE(mvm,
+						       "Stop aggregation on tid %d\n",
+						       tid);
+					ieee80211_stop_tx_ba_session(sta, tid);
+				}
+			}
 			rs_set_stay_in_table(mvm, 1, lq_sta);
 		} else {
 		/* If we're in an HT mode, and all 3 mode switch actions
@@ -2342,9 +2398,10 @@ void iwl_mvm_rs_rate_init(struct iwl_mvm *mvm, struc=
t ieee80211_sta *sta,
 	lq_sta->lq.sta_id =3D sta_priv->sta_id;
=20
 	for (j =3D 0; j < LQ_SIZE; j++)
-		rs_rate_scale_clear_tbl_windows(&lq_sta->lq_info[j]);
+		rs_rate_scale_clear_tbl_windows(mvm, &lq_sta->lq_info[j]);
=20
 	lq_sta->flush_timer =3D 0;
+	lq_sta->last_tx =3D jiffies;
=20
 	IWL_DEBUG_RATE(mvm,
 		       "LQ: *** rate scale station global init for station %d ***\n",
@@ -2388,11 +2445,22 @@ void iwl_mvm_rs_rate_init(struct iwl_mvm *mvm, stru=
ct ieee80211_sta *sta,
 		lq_sta->is_vht =3D true;
 	}
=20
-	IWL_DEBUG_RATE(mvm,
-		       "SISO-RATE=3D%X MIMO2-RATE=3D%X VHT=3D%d\n",
+	lq_sta->max_legacy_rate_idx =3D find_last_bit(&lq_sta->active_legacy_rate,
+						    BITS_PER_LONG);
+	lq_sta->max_siso_rate_idx =3D find_last_bit(&lq_sta->active_siso_rate,
+						  BITS_PER_LONG);
+	lq_sta->max_mimo2_rate_idx =3D find_last_bit(&lq_sta->active_mimo2_rate,
+						   BITS_PER_LONG);
+
+	IWL_DEBUG_RATE(mvm, "RATE MASK: LEGACY=3D%lX SISO=3D%lX MIMO2=3D%lX VHT=
=3D%d\n",
+		       lq_sta->active_legacy_rate,
 		       lq_sta->active_siso_rate,
 		       lq_sta->active_mimo2_rate,
 		       lq_sta->is_vht);
+	IWL_DEBUG_RATE(mvm, "MAX RATE: LEGACY=3D%d SISO=3D%d MIMO2=3D%d\n",
+		       lq_sta->max_legacy_rate_idx,
+		       lq_sta->max_siso_rate_idx,
+		       lq_sta->max_mimo2_rate_idx);
=20
 	/* These values will be overridden later */
 	lq_sta->lq.single_stream_ant_msk =3D
@@ -2547,6 +2615,7 @@ static void rs_build_rates_table(struct iwl_mvm *mvm,
 	if (is_siso(&rate)) {
 		num_rates =3D RS_SECONDARY_SISO_NUM_RATES;
 		num_retries =3D RS_SECONDARY_SISO_RETRIES;
+		lq_cmd->mimo_delim =3D index;
 	} else if (is_legacy(&rate)) {
 		num_rates =3D RS_SECONDARY_LEGACY_NUM_RATES;
 		num_retries =3D RS_LEGACY_RETRIES_PER_RATE;
@@ -2749,7 +2818,7 @@ static ssize_t rs_sta_dbgfs_scale_table_read(struct f=
ile *file,
 		return -ENOMEM;
=20
 	desc +=3D sprintf(buff+desc, "sta_id %d\n", lq_sta->lq.sta_id);
-	desc +=3D sprintf(buff+desc, "failed=3D%d success=3D%d rate=3D0%X\n",
+	desc +=3D sprintf(buff+desc, "failed=3D%d success=3D%d rate=3D0%lX\n",
 			lq_sta->total_failed, lq_sta->total_success,
 			lq_sta->active_legacy_rate);
 	desc +=3D sprintf(buff+desc, "fixed rate 0x%X\n",
diff --git a/drivers/net/wireless/iwlwifi/mvm/rs.h b/drivers/net/wireless/i=
wlwifi/mvm/rs.h
index 3332b396011e..0acfac96a56c 100644
--- a/drivers/net/wireless/iwlwifi/mvm/rs.h
+++ b/drivers/net/wireless/iwlwifi/mvm/rs.h
@@ -156,6 +156,7 @@ enum {
 #define IWL_RATE_HIGH_TH		10880	/*  85% */
 #define IWL_RATE_INCREASE_TH		6400	/*  50% */
 #define RS_SR_FORCE_DECREASE		1920	/*  15% */
+#define RS_SR_NO_DECREASE		10880	/*  85% */
=20
 #define LINK_QUAL_AGG_TIME_LIMIT_DEF	(4000) /* 4 milliseconds */
 #define LINK_QUAL_AGG_TIME_LIMIT_MAX	(8000)
@@ -310,13 +311,20 @@ struct iwl_lq_sta {
 	u32 visited_columns;    /* Bitmask marking which Tx columns were
 				 * explored during a search cycle
 				 */
+	u64 last_tx;
 	bool is_vht;
 	enum ieee80211_band band;
=20
 	/* The following are bitmaps of rates; IWL_RATE_6M_MASK, etc. */
-	u16 active_legacy_rate;
-	u16 active_siso_rate;
-	u16 active_mimo2_rate;
+	unsigned long active_legacy_rate;
+	unsigned long active_siso_rate;
+	unsigned long active_mimo2_rate;
+
+	/* Highest rate per Tx mode */
+	u8 max_legacy_rate_idx;
+	u8 max_siso_rate_idx;
+	u8 max_mimo2_rate_idx;
+
 	s8 max_rate_idx;     /* Max rate set by user */
 	u8 missed_rate_counter;
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/sf.c b/drivers/net/wireless/i=
wlwifi/mvm/sf.c
index 8401627c0030..88809b2d1654 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sf.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sf.c
@@ -274,7 +274,8 @@ int iwl_mvm_sf_update(struct iwl_mvm *mvm, struct ieee8=
0211_vif *changed_vif,
 				return -EINVAL;
 			if (changed_vif->type !=3D NL80211_IFTYPE_STATION) {
 				new_state =3D SF_UNINIT;
-			} else if (changed_vif->bss_conf.assoc) {
+			} else if (changed_vif->bss_conf.assoc &&
+				   changed_vif->bss_conf.dtim_period) {
 				mvmvif =3D iwl_mvm_vif_from_mac80211(changed_vif);
 				sta_id =3D mvmvif->ap_sta_id;
 				new_state =3D SF_FULL_ON;
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index edb015c99049..3d1d57f9f5bc 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -373,12 +373,14 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 	{IWL_PCI_DEVICE(0x095A, 0x500A, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5200, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5002, iwl7265_n_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5102, iwl7265_n_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5202, iwl7265_n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9010, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9012, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9110, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9112, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9210, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9200, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9510, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9310, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9410, iwl7265_2ac_cfg)},
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwi=
fiex/main.c
index 77db0886c6e2..9c771b3e9918 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -292,6 +292,12 @@ process_start:
 			while ((skb =3D skb_dequeue(&adapter->usb_rx_data_q)))
 				mwifiex_handle_rx_packet(adapter, skb);
=20
+		/* Check for event */
+		if (adapter->event_received) {
+			adapter->event_received =3D false;
+			mwifiex_process_event(adapter);
+		}
+
 		/* Check for Cmd Resp */
 		if (adapter->cmd_resp_received) {
 			adapter->cmd_resp_received =3D false;
@@ -304,12 +310,6 @@ process_start:
 			}
 		}
=20
-		/* Check for event */
-		if (adapter->event_received) {
-			adapter->event_received =3D false;
-			mwifiex_process_event(adapter);
-		}
-
 		/* Check if we need to confirm Sleep Request
 		   received previously */
 		if (adapter->ps_state =3D=3D PS_STATE_PRE_SLEEP) {
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index 894270611f2c..536c14aa71f3 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -60,9 +60,10 @@ int mwifiex_wait_queue_complete(struct mwifiex_adapter *=
adapter,
 	int status;
=20
 	/* Wait for completion */
-	status =3D wait_event_interruptible(adapter->cmd_wait_q.wait,
-					  *(cmd_queued->condition));
-	if (status) {
+	status =3D wait_event_interruptible_timeout(adapter->cmd_wait_q.wait,
+						  *(cmd_queued->condition),
+						  (12 * HZ));
+	if (status <=3D 0) {
 		dev_err(adapter->dev, "cmd_wait_q terminated: %d\n", status);
 		mwifiex_cancel_all_pending_cmd(adapter);
 		return status;
diff --git a/drivers/net/wireless/rsi/rsi_91x_core.c b/drivers/net/wireless=
/rsi/rsi_91x_core.c
index 1a8d32138593..cf61d6e3eaa7 100644
--- a/drivers/net/wireless/rsi/rsi_91x_core.c
+++ b/drivers/net/wireless/rsi/rsi_91x_core.c
@@ -88,7 +88,7 @@ static u8 rsi_core_determine_hal_queue(struct rsi_common =
*common)
 	bool recontend_queue =3D false;
 	u32 q_len =3D 0;
 	u8 q_num =3D INVALID_QUEUE;
-	u8 ii, min =3D 0;
+	u8 ii =3D 0, min =3D 0;
=20
 	if (skb_queue_len(&common->tx_queue[MGMT_SOFT_Q])) {
 		if (!common->mgmt_q_block)
diff --git a/drivers/net/wireless/rsi/rsi_91x_mgmt.c b/drivers/net/wireless=
/rsi/rsi_91x_mgmt.c
index 73694295648f..1b28cda6ca88 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mgmt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
@@ -841,16 +841,6 @@ int rsi_set_channel(struct rsi_common *common, u16 cha=
nnel)
 	rsi_dbg(MGMT_TX_ZONE,
 		"%s: Sending scan req frame\n", __func__);
=20
-	skb =3D dev_alloc_skb(FRAME_DESC_SZ);
-	if (!skb) {
-		rsi_dbg(ERR_ZONE, "%s: Failed in allocation of skb\n",
-			__func__);
-		return -ENOMEM;
-	}
-
-	memset(skb->data, 0, FRAME_DESC_SZ);
-	mgmt_frame =3D (struct rsi_mac_frame *)skb->data;
-
 	if (common->band =3D=3D IEEE80211_BAND_5GHZ) {
 		if ((channel >=3D 36) && (channel <=3D 64))
 			channel =3D ((channel - 32) / 4);
@@ -868,6 +858,16 @@ int rsi_set_channel(struct rsi_common *common, u16 cha=
nnel)
 		}
 	}
=20
+	skb =3D dev_alloc_skb(FRAME_DESC_SZ);
+	if (!skb) {
+		rsi_dbg(ERR_ZONE, "%s: Failed in allocation of skb\n",
+			__func__);
+		return -ENOMEM;
+	}
+
+	memset(skb->data, 0, FRAME_DESC_SZ);
+	mgmt_frame =3D (struct rsi_mac_frame *)skb->data;
+
 	mgmt_frame->desc_word[0] =3D cpu_to_le16(RSI_WIFI_MGMT_Q << 12);
 	mgmt_frame->desc_word[1] =3D cpu_to_le16(SCAN_REQUEST);
 	mgmt_frame->desc_word[4] =3D cpu_to_le16(channel);
@@ -966,6 +966,7 @@ static int rsi_send_auto_rate_request(struct rsi_common=
 *common)
 	if (!selected_rates) {
 		rsi_dbg(ERR_ZONE, "%s: Failed in allocation of mem\n",
 			__func__);
+		dev_kfree_skb(skb);
 		return -ENOMEM;
 	}
=20
diff --git a/drivers/net/wireless/ti/wl18xx/event.h b/drivers/net/wireless/=
ti/wl18xx/event.h
index 398f3d2c0a6c..a76e98eb8372 100644
--- a/drivers/net/wireless/ti/wl18xx/event.h
+++ b/drivers/net/wireless/ti/wl18xx/event.h
@@ -68,6 +68,26 @@ struct wl18xx_event_mailbox {
=20
 	/* bitmap of inactive stations (by HLID) */
 	__le32 inactive_sta_bitmap;
+
+	/* rx BA win size indicated by RX_BA_WIN_SIZE_CHANGE_EVENT_ID */
+	u8 rx_ba_role_id;
+	u8 rx_ba_link_id;
+	u8 rx_ba_win_size;
+	u8 padding;
+
+	/* smart config */
+	u8 sc_ssid_len;
+	u8 sc_pwd_len;
+	u8 sc_token_len;
+	u8 padding1;
+	u8 sc_ssid[32];
+	u8 sc_pwd[32];
+	u8 sc_token[32];
+
+	/* smart config sync channel */
+	u8 sc_sync_channel;
+	u8 sc_sync_band;
+	u8 padding2[2];
 } __packed;
=20
 int wl18xx_wait_for_event(struct wl1271 *wl, enum wlcore_wait_event event,
diff --git a/drivers/net/wireless/ti/wlcore/event.c b/drivers/net/wireless/=
ti/wlcore/event.c
index 1f9a36031b06..16d10281798d 100644
--- a/drivers/net/wireless/ti/wlcore/event.c
+++ b/drivers/net/wireless/ti/wlcore/event.c
@@ -158,6 +158,11 @@ EXPORT_SYMBOL_GPL(wlcore_event_channel_switch);
=20
 void wlcore_event_dummy_packet(struct wl1271 *wl)
 {
+	if (wl->plt) {
+		wl1271_info("Got DUMMY_PACKET event in PLT mode.  FW bug, ignoring.");
+		return;
+	}
+
 	wl1271_debug(DEBUG_EVENT, "DUMMY_PACKET_ID_EVENT_ID");
 	wl1271_tx_dummy_packet(wl);
 }
diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index bd1fd8ea5105..75b5dd2c9267 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -249,7 +249,7 @@ ieee80211_new_chanctx(struct ieee80211_local *local,
=20
 	if (!local->use_chanctx) {
 		local->_oper_chandef =3D *chandef;
-		ieee80211_hw_config(local, 0);
+		ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_CHANNEL);
 	} else {
 		err =3D drv_add_chanctx(local, ctx);
 		if (err) {
@@ -286,7 +286,7 @@ static void ieee80211_free_chanctx(struct ieee80211_loc=
al *local,
 			check_single_channel =3D true;
 		local->hw.conf.radar_enabled =3D false;
=20
-		ieee80211_hw_config(local, 0);
+		ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_CHANNEL);
 	} else {
 		drv_remove_chanctx(local, ctx);
 	}
@@ -492,6 +492,13 @@ void ieee80211_recalc_smps_chanctx(struct ieee80211_lo=
cal *local,
 		rx_chains_static =3D max(rx_chains_static, needed_static);
 		rx_chains_dynamic =3D max(rx_chains_dynamic, needed_dynamic);
 	}
+
+	/* Disable SMPS for the monitor interface */
+	sdata =3D rcu_dereference(local->monitor_sdata);
+	if (sdata &&
+	    rcu_access_pointer(sdata->vif.chanctx_conf) =3D=3D &chanctx->conf)
+		rx_chains_dynamic =3D rx_chains_static =3D local->rx_chains;
+
 	rcu_read_unlock();
=20
 	if (!local->use_chanctx) {
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index b055f6a55c68..4c1bf61bc778 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -148,6 +148,8 @@ static u32 ieee80211_hw_conf_chan(struct ieee80211_loca=
l *local)
 	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		if (!rcu_access_pointer(sdata->vif.chanctx_conf))
 			continue;
+		if (sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
+			continue;
 		power =3D min(power, sdata->vif.bss_conf.txpower);
 	}
 	rcu_read_unlock();
@@ -199,7 +201,7 @@ void ieee80211_bss_info_change_notify(struct ieee80211_=
sub_if_data *sdata,
 {
 	struct ieee80211_local *local =3D sdata->local;
=20
-	if (!changed)
+	if (!changed || sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
 		return;
=20
 	drv_bss_info_changed(local, sdata, &sdata->vif.bss_conf, changed);
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index 0c2a29484c07..6fb38558a5e6 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -355,6 +355,7 @@ void ieee80211_sw_roc_work(struct work_struct *work)
 		struct ieee80211_roc_work *dep;
=20
 		/* start this ROC */
+		ieee80211_offchannel_stop_vifs(local);
=20
 		/* switch channel etc */
 		ieee80211_recalc_idle(local);
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index e6e574a307c8..00ba90b02ab2 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -618,6 +618,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struc=
t sk_buff *skb)
 					sta, true, acked);
=20
 		if ((local->hw.flags & IEEE80211_HW_HAS_RATE_CONTROL) &&
+		    (ieee80211_is_data(hdr->frame_control)) &&
 		    (rates_idx !=3D -1))
 			sta->last_tx_rate =3D info->status.rates[rates_idx];
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTT+v0AAoJEJctW/TcYTgGYpMP+gIrM/KgPwNcMgM3VO77hc/S
hcP6wGZQnuRuVPdazWarrlrAKQVBHGgT1RcSzSnihn3RD3diGw148ashuTqU5E0/
H6OqTNdrd/ofRwpiZC2gAR76OCle12eKdzH6w0L1boF9h1I6pZxFyd57K1sKqtbO
3UnSGkquu47fI6NIbk9cvl4xL4iJI1JKIOaqSmimDaHRjefIBC2roiPbId6MbRId
1I2HnZ8O6k2RimWyW57EkGN1akPnFoe4c21vOdvhK7iaCHJ69SN22NyM+1x+QPt0
6eS3rj3YTyWSvUyVzw6Po7q2zvdhF5yRarWmBw91ClhgSLb2HCg1lgkPGqEzdQlC
X/aiVHC/WJHrF1fnB8WyWgIoocHZKp2fR6U3+KpJ3A3DHTvH6FDMu/3/74wXDWVh
dV3ri0Ep8QKBmu+qnqA3rqJXHx3VPqtDPc0449kjMcgo9pAMrwulcKUEQk5EaUkC
iPj40OXsV9t/Eu4w/pzTC04Xaudacdy659/Xq7yKuQEgabOekDc99mel+Ld+H1ON
yYy3BplW1HbjS+RZkMy6k8UbQERyuQJEUzoOEmArCtg90qOr+CPzRh8jwe9PfidQ
Z8RFpnPi0T47JG1XHOT0K929UAkk7tVSuSxML4jFiLNvK8gBnHUoaVnI1khFc/mE
rqxC1OOlWx5nbE5BOXiS
=XaBt
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--
