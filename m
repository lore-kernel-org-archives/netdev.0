From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-05-29
Date: Wed, 29 May 2013 11:28:53 -0400
Message-ID: <20130529152852.GA8770@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VS++wcV0S1rZb1Fb"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.10 stream...

Regarding the NFC bits, Samuel says:

"This is the first batch of NFC fixes for 3.10, and it contains:

- 3 fixes for the NFC MEI support:
        * We now depend on the correct Kconfig symbol.
        * We register an MEI event callback whenever we enable an NFC devic=
e,
          otherwise we fail to read anything after an enable/disable cycle.
        * We only disable an MEI device from its disable mey_phy_ops,
          preventing useless consecutive disable calls.

- An NFC Makefile cleanup, as I forgot to remove a commented out line when
  moving the LLCP code to the NFC top level directory."

As for the mac80211 bits, Johannes says:

"This time I have a fix from Stanislaw for a stupid mistake I made in the
auth/assoc timeout changes, a fix from Felix for 64-bit traffic counters
and one from Helmut for address mask handling in mac80211. I also have a
few fixes myself for four different crashes reported by a few people."

And Johannes says this about the iwlwifi bit:

"This fixes a brown paper-bag bug that we really should've caught in
review. More details in the changelog for the fix."

On top of that...

Arend van Spriel and Hante Meuleman cooperate to send a series of AP
and P2P mode fixes for brcmfmac.

Gabor Juhos corrects a register offset for AR9550, avoiding a bus
error.

Dan Carpenter provides a fixup to some dmesg output in the atmel
driver.

And, finally...

Felix Fietkau not only gives us a trio of small AR934x fixes, but
also refactors the ath9k aggregation session start/stop handling
(using the generic mac80211 support) in order to avoid a deadlock.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 8e6d91ae0917bf934ed86411148f79d904728d51:

  tuntap: forbid changing mq flag for persistent device (2013-05-29 00:21:3=
2 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 50cc1cab4cfc8ab32dc6ae470c271cdf65e82de3:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-05-29 10:59:35 -0400)

----------------------------------------------------------------

Arend van Spriel (3):
      brcmfmac: add additional parameter to brcmf_free_vif()
      brcmfmac: free net device when registration fails
      brcmfmac: use struct net_device::destructor to remove interfaces

Dan Carpenter (1):
      atmel: printing bogus information

Emmanuel Grumbach (1):
      iwlwifi: dvm: fix zero LQ CMD sending avoidance

Felix Fietkau (5):
      ath9k: prevent aggregation session deadlocks
      cfg80211: fix reporting 64-bit station info tx bytes
      ath9k_hw: fix spur mitigation issues on AR934x
      ath9k_hw: fix host interface reset on AR934x
      ath9k_hw: improve performance for AR934x v1.3+

Gabor Juhos (1):
      ath9k: use correct OTP register offsets for AR9550

Hante Meuleman (4):
      brcmfmac: Turn off ARP offloading when configured for AP.
      brcmfmac: Fix p2p setup when connected to ap on 5G.
      brcmfmac: Add multi channel support for P2P.
      brcmfmac: Disable powersave mode for P2P link.

Helmut Schaa (1):
      mac80211: Allow single vif mac address change with addr_mask

Johannes Berg (4):
      cfg80211: check wdev->netdev in connection work
      mac80211: fix queue handling crash
      mac80211: assign AP_VLAN hw queues correctly
      mac80211: close AP_VLAN interfaces before unregistering all

John W. Linville (4):
      Samuel Ortiz <sameo@linux.intel.com> says:
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Paul Bolle (1):
      NFC: Remove commented out LLCP related Makefile line

Samuel Ortiz (3):
      NFC: mei_phy depends on INTEL_MEI
      NFC: mei_phy: Register event callback when enabling the device
      NFC: mei: Do not disable MEI devices from their remove routine

Stanislaw Gruszka (1):
      mac80211: fix direct probe auth

 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   9 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   3 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |  14 +--
 drivers/net/wireless/ath/ath9k/hw.c                |  25 ++--
 drivers/net/wireless/ath/ath9k/mac.c               |   2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   3 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   5 +-
 drivers/net/wireless/ath/ath9k/reg.h               |  11 ++
 drivers/net/wireless/ath/ath9k/xmit.c              | 138 ++++++-----------=
----
 drivers/net/wireless/atmel.c                       |   2 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |  18 ---
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  16 ++-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |   3 +-
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   6 +
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  74 ++++++++---
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  89 ++++++++++---
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   3 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |   2 +-
 drivers/nfc/Kconfig                                |   2 +-
 drivers/nfc/mei_phy.c                              |   9 ++
 drivers/nfc/microread/mei.c                        |  20 +--
 drivers/nfc/pn544/mei.c                            |  20 +--
 net/mac80211/iface.c                               |  44 +++++--
 net/mac80211/mlme.c                                |  12 +-
 net/nfc/Makefile                                   |   1 -
 net/wireless/nl80211.c                             |   2 +-
 net/wireless/sme.c                                 |   3 +
 27 files changed, 301 insertions(+), 235 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h b/drivers/net/w=
ireless/ath/ath9k/ar9003_eeprom.h
index 54ba42f..874f657 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h
@@ -68,13 +68,16 @@
 #define AR9300_BASE_ADDR 0x3ff
 #define AR9300_BASE_ADDR_512 0x1ff
=20
-#define AR9300_OTP_BASE			(AR_SREV_9340(ah) ? 0x30000 : 0x14000)
-#define AR9300_OTP_STATUS		(AR_SREV_9340(ah) ? 0x30018 : 0x15f18)
+#define AR9300_OTP_BASE \
+		((AR_SREV_9340(ah) || AR_SREV_9550(ah)) ? 0x30000 : 0x14000)
+#define AR9300_OTP_STATUS \
+		((AR_SREV_9340(ah) || AR_SREV_9550(ah)) ? 0x30018 : 0x15f18)
 #define AR9300_OTP_STATUS_TYPE		0x7
 #define AR9300_OTP_STATUS_VALID		0x4
 #define AR9300_OTP_STATUS_ACCESS_BUSY	0x2
 #define AR9300_OTP_STATUS_SM_BUSY	0x1
-#define AR9300_OTP_READ_DATA		(AR_SREV_9340(ah) ? 0x3001c : 0x15f1c)
+#define AR9300_OTP_READ_DATA \
+		((AR_SREV_9340(ah) || AR_SREV_9550(ah)) ? 0x3001c : 0x15f1c)
=20
 enum targetPowerHTRates {
 	HT_TARGET_RATE_0_8_16,
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.c
index 2bf6548..e1714d7 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -334,7 +334,8 @@ static void ar9003_hw_spur_ofdm(struct ath_hw *ah,
 	REG_RMW_FIELD(ah, AR_PHY_SPUR_REG,
 		      AR_PHY_SPUR_REG_EN_VIT_SPUR_RSSI, 1);
=20
-	if (REG_READ_FIELD(ah, AR_PHY_MODE,
+	if (!AR_SREV_9340(ah) &&
+	    REG_READ_FIELD(ah, AR_PHY_MODE,
 			   AR_PHY_MODE_DYNAMIC) =3D=3D 0x1)
 		REG_RMW_FIELD(ah, AR_PHY_SPUR_REG,
 			      AR_PHY_SPUR_REG_ENABLE_NF_RSSI_SPUR_MIT, 1);
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/=
ath/ath9k/ath9k.h
index 366002f..42b03dc 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -251,10 +251,9 @@ struct ath_atx_tid {
 	int tidno;
 	int baw_head;   /* first un-acked tx buffer */
 	int baw_tail;   /* next unused tx buffer slot */
-	int sched;
-	int paused;
-	u8 state;
-	bool stop_cb;
+	bool sched;
+	bool paused;
+	bool active;
 };
=20
 struct ath_node {
@@ -275,10 +274,6 @@ struct ath_node {
 #endif
 };
=20
-#define AGGR_CLEANUP         BIT(1)
-#define AGGR_ADDBA_COMPLETE  BIT(2)
-#define AGGR_ADDBA_PROGRESS  BIT(3)
-
 struct ath_tx_control {
 	struct ath_txq *txq;
 	struct ath_node *an;
@@ -352,8 +347,7 @@ void ath_tx_tasklet(struct ath_softc *sc);
 void ath_tx_edma_tasklet(struct ath_softc *sc);
 int ath_tx_aggr_start(struct ath_softc *sc, struct ieee80211_sta *sta,
 		      u16 tid, u16 *ssn);
-bool ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16=
 tid,
-		      bool flush);
+void ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16=
 tid);
 void ath_tx_aggr_resume(struct ath_softc *sc, struct ieee80211_sta *sta, u=
16 tid);
=20
 void ath_tx_aggr_wakeup(struct ath_softc *sc, struct ath_node *an);
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 7f25da8..15dfefc 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1172,6 +1172,7 @@ u32 ath9k_regd_get_ctl(struct ath_regulatory *reg, st=
ruct ath9k_channel *chan)
 static inline void ath9k_hw_set_dma(struct ath_hw *ah)
 {
 	struct ath_common *common =3D ath9k_hw_common(ah);
+	int txbuf_size;
=20
 	ENABLE_REGWRITE_BUFFER(ah);
=20
@@ -1225,13 +1226,17 @@ static inline void ath9k_hw_set_dma(struct ath_hw *=
ah)
 		 * So set the usable tx buf size also to half to
 		 * avoid data/delimiter underruns
 		 */
-		REG_WRITE(ah, AR_PCU_TXBUF_CTRL,
-			  AR_9285_PCU_TXBUF_CTRL_USABLE_SIZE);
-	} else if (!AR_SREV_9271(ah)) {
-		REG_WRITE(ah, AR_PCU_TXBUF_CTRL,
-			  AR_PCU_TXBUF_CTRL_USABLE_SIZE);
+		txbuf_size =3D AR_9285_PCU_TXBUF_CTRL_USABLE_SIZE;
+	} else if (AR_SREV_9340_13_OR_LATER(ah)) {
+		/* Uses fewer entries for AR934x v1.3+ to prevent rx overruns */
+		txbuf_size =3D AR_9340_PCU_TXBUF_CTRL_USABLE_SIZE;
+	} else {
+		txbuf_size =3D AR_PCU_TXBUF_CTRL_USABLE_SIZE;
 	}
=20
+	if (!AR_SREV_9271(ah))
+		REG_WRITE(ah, AR_PCU_TXBUF_CTRL, txbuf_size);
+
 	REGWRITE_BUFFER_FLUSH(ah);
=20
 	if (AR_SREV_9300_20_OR_LATER(ah))
@@ -1306,9 +1311,13 @@ static bool ath9k_hw_set_reset(struct ath_hw *ah, in=
t type)
 			AR_RTC_RC_COLD_RESET | AR_RTC_RC_WARM_RESET;
 	} else {
 		tmpReg =3D REG_READ(ah, AR_INTR_SYNC_CAUSE);
-		if (tmpReg &
-		    (AR_INTR_SYNC_LOCAL_TIMEOUT |
-		     AR_INTR_SYNC_RADM_CPL_TIMEOUT)) {
+		if (AR_SREV_9340(ah))
+			tmpReg &=3D AR9340_INTR_SYNC_LOCAL_TIMEOUT;
+		else
+			tmpReg &=3D AR_INTR_SYNC_LOCAL_TIMEOUT |
+				  AR_INTR_SYNC_RADM_CPL_TIMEOUT;
+
+		if (tmpReg) {
 			u32 val;
 			REG_WRITE(ah, AR_INTR_SYNC_ENABLE, 0);
=20
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/at=
h/ath9k/mac.c
index 498fee0..566109a 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -410,7 +410,7 @@ bool ath9k_hw_resettxqueue(struct ath_hw *ah, u32 q)
=20
 	REG_WRITE(ah, AR_QMISC(q), AR_Q_MISC_DCU_EARLY_TERM_REQ);
=20
-	if (AR_SREV_9340(ah))
+	if (AR_SREV_9340(ah) && !AR_SREV_9340_13_OR_LATER(ah))
 		REG_WRITE(ah, AR_DMISC(q),
 			  AR_D_MISC_CW_BKOFF_EN | AR_D_MISC_FRAG_WAIT_EN | 0x1);
 	else
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 2382d12..5092eca 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1709,7 +1709,8 @@ static int ath9k_ampdu_action(struct ieee80211_hw *hw,
 		flush =3D true;
 	case IEEE80211_AMPDU_TX_STOP_CONT:
 		ath9k_ps_wakeup(sc);
-		if (ath_tx_aggr_stop(sc, sta, tid, flush))
+		ath_tx_aggr_stop(sc, sta, tid);
+		if (!flush)
 			ieee80211_stop_tx_ba_cb_irqsafe(vif, sta->addr, tid);
 		ath9k_ps_restore(sc);
 		break;
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath=
/ath9k/rc.c
index aa4d368..7eb1f4b 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1227,10 +1227,7 @@ static bool ath_tx_aggr_check(struct ath_softc *sc, =
struct ieee80211_sta *sta,
 		return false;
=20
 	txtid =3D ATH_AN_2_TID(an, tidno);
-
-	if (!(txtid->state & (AGGR_ADDBA_COMPLETE | AGGR_ADDBA_PROGRESS)))
-			return true;
-	return false;
+	return !txtid->active;
 }
=20
=20
diff --git a/drivers/net/wireless/ath/ath9k/reg.h b/drivers/net/wireless/at=
h/ath9k/reg.h
index 5c4ab50..f7c90cc 100644
--- a/drivers/net/wireless/ath/ath9k/reg.h
+++ b/drivers/net/wireless/ath/ath9k/reg.h
@@ -798,6 +798,10 @@
 #define AR_SREV_REVISION_9485_10	0
 #define AR_SREV_REVISION_9485_11        1
 #define AR_SREV_VERSION_9340		0x300
+#define AR_SREV_REVISION_9340_10	0
+#define AR_SREV_REVISION_9340_11	1
+#define AR_SREV_REVISION_9340_12	2
+#define AR_SREV_REVISION_9340_13	3
 #define AR_SREV_VERSION_9580		0x1C0
 #define AR_SREV_REVISION_9580_10	4 /* AR9580 1.0 */
 #define AR_SREV_VERSION_9462		0x280
@@ -897,6 +901,10 @@
 #define AR_SREV_9340(_ah) \
 	(((_ah)->hw_version.macVersion =3D=3D AR_SREV_VERSION_9340))
=20
+#define AR_SREV_9340_13_OR_LATER(_ah) \
+	(AR_SREV_9340((_ah)) && \
+	 ((_ah)->hw_version.macRev >=3D AR_SREV_REVISION_9340_13))
+
 #define AR_SREV_9285E_20(_ah) \
     (AR_SREV_9285_12_OR_LATER(_ah) && \
      ((REG_READ(_ah, AR_AN_SYNTH9) & 0x7) =3D=3D 0x1))
@@ -1007,6 +1015,8 @@ enum {
 				AR_INTR_SYNC_LOCAL_TIMEOUT |
 				AR_INTR_SYNC_MAC_SLEEP_ACCESS),
=20
+	AR9340_INTR_SYNC_LOCAL_TIMEOUT =3D 0x00000010,
+
 	AR_INTR_SYNC_SPURIOUS =3D 0xFFFFFFFF,
=20
 };
@@ -1881,6 +1891,7 @@ enum {
 #define AR_PCU_TXBUF_CTRL_SIZE_MASK     0x7FF
 #define AR_PCU_TXBUF_CTRL_USABLE_SIZE   0x700
 #define AR_9285_PCU_TXBUF_CTRL_USABLE_SIZE   0x380
+#define AR_9340_PCU_TXBUF_CTRL_USABLE_SIZE   0x500
=20
 #define AR_PCU_MISC_MODE2               0x8344
 #define AR_PCU_MISC_MODE2_MGMT_CRYPTO_ENABLE           0x00000002
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 14bb335..1c9b1ba 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -125,24 +125,6 @@ static void ath_tx_queue_tid(struct ath_txq *txq, stru=
ct ath_atx_tid *tid)
 	list_add_tail(&ac->list, &txq->axq_acq);
 }
=20
-static void ath_tx_resume_tid(struct ath_softc *sc, struct ath_atx_tid *ti=
d)
-{
-	struct ath_txq *txq =3D tid->ac->txq;
-
-	WARN_ON(!tid->paused);
-
-	ath_txq_lock(sc, txq);
-	tid->paused =3D false;
-
-	if (skb_queue_empty(&tid->buf_q))
-		goto unlock;
-
-	ath_tx_queue_tid(txq, tid);
-	ath_txq_schedule(sc, txq);
-unlock:
-	ath_txq_unlock_complete(sc, txq);
-}
-
 static struct ath_frame_info *get_frame_info(struct sk_buff *skb)
 {
 	struct ieee80211_tx_info *tx_info =3D IEEE80211_SKB_CB(skb);
@@ -164,20 +146,7 @@ static void ath_set_rates(struct ieee80211_vif *vif, s=
truct ieee80211_sta *sta,
 			       ARRAY_SIZE(bf->rates));
 }
=20
-static void ath_tx_clear_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
-{
-	tid->state &=3D ~AGGR_ADDBA_COMPLETE;
-	tid->state &=3D ~AGGR_CLEANUP;
-	if (!tid->stop_cb)
-		return;
-
-	ieee80211_start_tx_ba_cb_irqsafe(tid->an->vif, tid->an->sta->addr,
-					 tid->tidno);
-	tid->stop_cb =3D false;
-}
-
-static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid,
-			     bool flush_packets)
+static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 {
 	struct ath_txq *txq =3D tid->ac->txq;
 	struct sk_buff *skb;
@@ -194,15 +163,16 @@ static void ath_tx_flush_tid(struct ath_softc *sc, st=
ruct ath_atx_tid *tid,
 	while ((skb =3D __skb_dequeue(&tid->buf_q))) {
 		fi =3D get_frame_info(skb);
 		bf =3D fi->bf;
-		if (!bf && !flush_packets)
-			bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
=20
 		if (!bf) {
-			ieee80211_free_txskb(sc->hw, skb);
-			continue;
+			bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
+			if (!bf) {
+				ieee80211_free_txskb(sc->hw, skb);
+				continue;
+			}
 		}
=20
-		if (fi->retries || flush_packets) {
+		if (fi->retries) {
 			list_add_tail(&bf->list, &bf_head);
 			ath_tx_update_baw(sc, tid, bf->bf_state.seqno);
 			ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0);
@@ -213,10 +183,7 @@ static void ath_tx_flush_tid(struct ath_softc *sc, str=
uct ath_atx_tid *tid,
 		}
 	}
=20
-	if (tid->baw_head =3D=3D tid->baw_tail)
-		ath_tx_clear_tid(sc, tid);
-
-	if (sendbar && !flush_packets) {
+	if (sendbar) {
 		ath_txq_unlock(sc, txq);
 		ath_send_bar(tid, tid->seq_start);
 		ath_txq_lock(sc, txq);
@@ -499,19 +466,19 @@ static void ath_tx_complete_aggr(struct ath_softc *sc=
, struct ath_txq *txq,
 		tx_info =3D IEEE80211_SKB_CB(skb);
 		fi =3D get_frame_info(skb);
=20
-		if (ATH_BA_ISSET(ba, ATH_BA_INDEX(seq_st, seqno))) {
+		if (!BAW_WITHIN(tid->seq_start, tid->baw_size, seqno)) {
+			/*
+			 * Outside of the current BlockAck window,
+			 * maybe part of a previous session
+			 */
+			txfail =3D 1;
+		} else if (ATH_BA_ISSET(ba, ATH_BA_INDEX(seq_st, seqno))) {
 			/* transmit completion, subframe is
 			 * acked by block ack */
 			acked_cnt++;
 		} else if (!isaggr && txok) {
 			/* transmit completion */
 			acked_cnt++;
-		} else if (tid->state & AGGR_CLEANUP) {
-			/*
-			 * cleanup in progress, just fail
-			 * the un-acked sub-frames
-			 */
-			txfail =3D 1;
 		} else if (flush) {
 			txpending =3D 1;
 		} else if (fi->retries < ATH_MAX_SW_RETRIES) {
@@ -535,7 +502,7 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, =
struct ath_txq *txq,
 		if (bf_next !=3D NULL || !bf_last->bf_stale)
 			list_move_tail(&bf->list, &bf_head);
=20
-		if (!txpending || (tid->state & AGGR_CLEANUP)) {
+		if (!txpending) {
 			/*
 			 * complete the acked-ones/xretried ones; update
 			 * block-ack window
@@ -609,9 +576,6 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, =
struct ath_txq *txq,
 		ath_txq_lock(sc, txq);
 	}
=20
-	if (tid->state & AGGR_CLEANUP)
-		ath_tx_flush_tid(sc, tid, false);
-
 	rcu_read_unlock();
=20
 	if (needreset)
@@ -1244,9 +1208,6 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct ie=
ee80211_sta *sta,
 	an =3D (struct ath_node *)sta->drv_priv;
 	txtid =3D ATH_AN_2_TID(an, tid);
=20
-	if (txtid->state & (AGGR_CLEANUP | AGGR_ADDBA_COMPLETE))
-		return -EAGAIN;
-
 	/* update ampdu factor/density, they may have changed. This may happen
 	 * in HT IBSS when a beacon with HT-info is received after the station
 	 * has already been added.
@@ -1258,7 +1219,7 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct ie=
ee80211_sta *sta,
 		an->mpdudensity =3D density;
 	}
=20
-	txtid->state |=3D AGGR_ADDBA_PROGRESS;
+	txtid->active =3D true;
 	txtid->paused =3D true;
 	*ssn =3D txtid->seq_start =3D txtid->seq_next;
 	txtid->bar_index =3D -1;
@@ -1269,45 +1230,17 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct =
ieee80211_sta *sta,
 	return 0;
 }
=20
-bool ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16=
 tid,
-		      bool flush)
+void ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16=
 tid)
 {
 	struct ath_node *an =3D (struct ath_node *)sta->drv_priv;
 	struct ath_atx_tid *txtid =3D ATH_AN_2_TID(an, tid);
 	struct ath_txq *txq =3D txtid->ac->txq;
-	bool ret =3D !flush;
-
-	if (flush)
-		txtid->stop_cb =3D false;
-
-	if (txtid->state & AGGR_CLEANUP)
-		return false;
-
-	if (!(txtid->state & AGGR_ADDBA_COMPLETE)) {
-		txtid->state &=3D ~AGGR_ADDBA_PROGRESS;
-		return ret;
-	}
=20
 	ath_txq_lock(sc, txq);
+	txtid->active =3D false;
 	txtid->paused =3D true;
-
-	/*
-	 * If frames are still being transmitted for this TID, they will be
-	 * cleaned up during tx completion. To prevent race conditions, this
-	 * TID can only be reused after all in-progress subframes have been
-	 * completed.
-	 */
-	if (txtid->baw_head !=3D txtid->baw_tail) {
-		txtid->state |=3D AGGR_CLEANUP;
-		ret =3D false;
-		txtid->stop_cb =3D !flush;
-	} else {
-		txtid->state &=3D ~AGGR_ADDBA_COMPLETE;
-	}
-
-	ath_tx_flush_tid(sc, txtid, flush);
+	ath_tx_flush_tid(sc, txtid);
 	ath_txq_unlock_complete(sc, txq);
-	return ret;
 }
=20
 void ath_tx_aggr_sleep(struct ieee80211_sta *sta, struct ath_softc *sc,
@@ -1371,18 +1304,28 @@ void ath_tx_aggr_wakeup(struct ath_softc *sc, struc=
t ath_node *an)
 	}
 }
=20
-void ath_tx_aggr_resume(struct ath_softc *sc, struct ieee80211_sta *sta, u=
16 tid)
+void ath_tx_aggr_resume(struct ath_softc *sc, struct ieee80211_sta *sta,
+			u16 tidno)
 {
-	struct ath_atx_tid *txtid;
+	struct ath_atx_tid *tid;
 	struct ath_node *an;
+	struct ath_txq *txq;
=20
 	an =3D (struct ath_node *)sta->drv_priv;
+	tid =3D ATH_AN_2_TID(an, tidno);
+	txq =3D tid->ac->txq;
=20
-	txtid =3D ATH_AN_2_TID(an, tid);
-	txtid->baw_size =3D IEEE80211_MIN_AMPDU_BUF << sta->ht_cap.ampdu_factor;
-	txtid->state |=3D AGGR_ADDBA_COMPLETE;
-	txtid->state &=3D ~AGGR_ADDBA_PROGRESS;
-	ath_tx_resume_tid(sc, txtid);
+	ath_txq_lock(sc, txq);
+
+	tid->baw_size =3D IEEE80211_MIN_AMPDU_BUF << sta->ht_cap.ampdu_factor;
+	tid->paused =3D false;
+
+	if (!skb_queue_empty(&tid->buf_q)) {
+		ath_tx_queue_tid(txq, tid);
+		ath_txq_schedule(sc, txq);
+	}
+
+	ath_txq_unlock_complete(sc, txq);
 }
=20
 /********************/
@@ -2431,13 +2374,10 @@ void ath_tx_node_init(struct ath_softc *sc, struct =
ath_node *an)
 		tid->baw_head  =3D tid->baw_tail =3D 0;
 		tid->sched     =3D false;
 		tid->paused    =3D false;
-		tid->state &=3D ~AGGR_CLEANUP;
+		tid->active	   =3D false;
 		__skb_queue_head_init(&tid->buf_q);
 		acno =3D TID_TO_WME_AC(tidno);
 		tid->ac =3D &an->ac[acno];
-		tid->state &=3D ~AGGR_ADDBA_COMPLETE;
-		tid->state &=3D ~AGGR_ADDBA_PROGRESS;
-		tid->stop_cb =3D false;
 	}
=20
 	for (acno =3D 0, ac =3D &an->ac[acno];
@@ -2474,7 +2414,7 @@ void ath_tx_node_cleanup(struct ath_softc *sc, struct=
 ath_node *an)
 		}
=20
 		ath_tid_drain(sc, txq, tid);
-		ath_tx_clear_tid(sc, tid);
+		tid->active =3D false;
=20
 		ath_txq_unlock(sc, txq);
 	}
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 830bb1d..b827d51 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1624,7 +1624,7 @@ struct net_device *init_atmel_card(unsigned short irq=
, unsigned long port,
=20
 	netif_carrier_off(dev);
=20
-	if (!proc_create_data("driver/atmel", 0, NULL, &atmel_proc_fops, priv));
+	if (!proc_create_data("driver/atmel", 0, NULL, &atmel_proc_fops, priv))
 		printk(KERN_WARNING "atmel: unable to create /proc entry.\n");
=20
 	printk(KERN_INFO "%s: Atmel at76c50x. Version %d.%d. MAC %pM\n",
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c b/drivers=
/net/wireless/brcm80211/brcmfmac/dhd_common.c
index be0787c..9431af2 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
@@ -27,7 +27,6 @@
 #include "tracepoint.h"
=20
 #define PKTFILTER_BUF_SIZE		128
-#define BRCMF_ARPOL_MODE		0xb	/* agent|snoop|peer_autoreply */
 #define BRCMF_DEFAULT_BCN_TIMEOUT	3
 #define BRCMF_DEFAULT_SCAN_CHANNEL_TIME	40
 #define BRCMF_DEFAULT_SCAN_UNASSOC_TIME	40
@@ -338,23 +337,6 @@ int brcmf_c_preinit_dcmds(struct brcmf_if *ifp)
 		goto done;
 	}
=20
-	/* Try to set and enable ARP offload feature, this may fail */
-	err =3D brcmf_fil_iovar_int_set(ifp, "arp_ol", BRCMF_ARPOL_MODE);
-	if (err) {
-		brcmf_dbg(TRACE, "failed to set ARP offload mode to 0x%x, err =3D %d\n",
-			  BRCMF_ARPOL_MODE, err);
-		err =3D 0;
-	} else {
-		err =3D brcmf_fil_iovar_int_set(ifp, "arpoe", 1);
-		if (err) {
-			brcmf_dbg(TRACE, "failed to enable ARP offload err =3D %d\n",
-				  err);
-			err =3D 0;
-		} else
-			brcmf_dbg(TRACE, "successfully enabled ARP offload to 0x%x\n",
-				  BRCMF_ARPOL_MODE);
-	}
-
 	/* Setup packet filter */
 	brcmf_c_pktfilter_offload_set(ifp, BRCMF_DEFAULT_PACKET_FILTER);
 	brcmf_c_pktfilter_offload_enable(ifp, BRCMF_DEFAULT_PACKET_FILTER,
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/=
net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 59c2546..b98f223 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -653,10 +653,13 @@ int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_=
locked)
=20
 	brcmf_dbg(INFO, "%s: Broadcom Dongle Host Driver\n", ndev->name);
=20
+	ndev->destructor =3D free_netdev;
 	return 0;
=20
 fail:
+	drvr->iflist[ifp->bssidx] =3D NULL;
 	ndev->netdev_ops =3D NULL;
+	free_netdev(ndev);
 	return -EBADE;
 }
=20
@@ -720,6 +723,9 @@ static int brcmf_net_p2p_attach(struct brcmf_if *ifp)
 	return 0;
=20
 fail:
+	ifp->drvr->iflist[ifp->bssidx] =3D NULL;
+	ndev->netdev_ops =3D NULL;
+	free_netdev(ndev);
 	return -EBADE;
 }
=20
@@ -788,6 +794,7 @@ void brcmf_del_if(struct brcmf_pub *drvr, s32 bssidx)
 	struct brcmf_if *ifp;
=20
 	ifp =3D drvr->iflist[bssidx];
+	drvr->iflist[bssidx] =3D NULL;
 	if (!ifp) {
 		brcmf_err("Null interface, idx=3D%d\n", bssidx);
 		return;
@@ -808,15 +815,13 @@ void brcmf_del_if(struct brcmf_pub *drvr, s32 bssidx)
 			cancel_work_sync(&ifp->setmacaddr_work);
 			cancel_work_sync(&ifp->multicast_work);
 		}
-
+		/* unregister will take care of freeing it */
 		unregister_netdev(ifp->ndev);
 		if (bssidx =3D=3D 0)
 			brcmf_cfg80211_detach(drvr->config);
-		free_netdev(ifp->ndev);
 	} else {
 		kfree(ifp);
 	}
-	drvr->iflist[bssidx] =3D NULL;
 }
=20
 int brcmf_attach(uint bus_hdrlen, struct device *dev)
@@ -925,8 +930,6 @@ fail:
 			brcmf_fws_del_interface(ifp);
 			brcmf_fws_deinit(drvr);
 		}
-		free_netdev(ifp->ndev);
-		drvr->iflist[0] =3D NULL;
 		if (p2p_ifp) {
 			free_netdev(p2p_ifp->ndev);
 			drvr->iflist[1] =3D NULL;
@@ -934,7 +937,8 @@ fail:
 		return ret;
 	}
 	if ((brcmf_p2p_enable) && (p2p_ifp))
-		brcmf_net_p2p_attach(p2p_ifp);
+		if (brcmf_net_p2p_attach(p2p_ifp) < 0)
+			brcmf_p2p_enable =3D 0;
=20
 	return 0;
 }
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c b/drivers/net/w=
ireless/brcm80211/brcmfmac/fweh.c
index 5a64280..83ee53a 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
@@ -202,7 +202,8 @@ static void brcmf_fweh_handle_if_event(struct brcmf_pub=
 *drvr,
 			return;
 		brcmf_fws_add_interface(ifp);
 		if (!drvr->fweh.evt_handler[BRCMF_E_IF])
-			err =3D brcmf_net_attach(ifp, false);
+			if (brcmf_net_attach(ifp, false) < 0)
+				return;
 	}
=20
 	if (ifevent->action =3D=3D BRCMF_E_IF_CHANGE)
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwil_types.h b/drivers=
/net/wireless/brcm80211/brcmfmac/fwil_types.h
index 0f2c83b..665ef69 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fwil_types.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fwil_types.h
@@ -23,6 +23,12 @@
=20
 #define BRCMF_FIL_ACTION_FRAME_SIZE	1800
=20
+/* ARP Offload feature flags for arp_ol iovar */
+#define BRCMF_ARP_OL_AGENT		0x00000001
+#define BRCMF_ARP_OL_SNOOP		0x00000002
+#define BRCMF_ARP_OL_HOST_AUTO_REPLY	0x00000004
+#define BRCMF_ARP_OL_PEER_AUTO_REPLY	0x00000008
+
=20
 enum brcmf_fil_p2p_if_types {
 	BRCMF_FIL_P2P_IF_CLIENT,
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/p2p.c
index e7a1a47..79555f0 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -47,6 +47,7 @@
 #define IS_P2P_SOCIAL_CHANNEL(channel) ((channel =3D=3D SOCIAL_CHAN_1) || \
 					 (channel =3D=3D SOCIAL_CHAN_2) || \
 					 (channel =3D=3D SOCIAL_CHAN_3))
+#define BRCMF_P2P_TEMP_CHAN	SOCIAL_CHAN_3
 #define SOCIAL_CHAN_CNT		3
 #define AF_PEER_SEARCH_CNT	2
=20
@@ -1954,21 +1955,21 @@ s32 brcmf_p2p_attach(struct brcmf_cfg80211_info *cf=
g)
 		err =3D brcmf_fil_iovar_int_set(pri_ifp, "p2p_disc", 1);
 		if (err < 0) {
 			brcmf_err("set p2p_disc error\n");
-			brcmf_free_vif(p2p_vif);
+			brcmf_free_vif(cfg, p2p_vif);
 			goto exit;
 		}
 		/* obtain bsscfg index for P2P discovery */
 		err =3D brcmf_fil_iovar_int_get(pri_ifp, "p2p_dev", &bssidx);
 		if (err < 0) {
 			brcmf_err("retrieving discover bsscfg index failed\n");
-			brcmf_free_vif(p2p_vif);
+			brcmf_free_vif(cfg, p2p_vif);
 			goto exit;
 		}
 		/* Verify that firmware uses same bssidx as driver !! */
 		if (p2p_ifp->bssidx !=3D bssidx) {
 			brcmf_err("Incorrect bssidx=3D%d, compared to p2p_ifp->bssidx=3D%d\n",
 				  bssidx, p2p_ifp->bssidx);
-			brcmf_free_vif(p2p_vif);
+			brcmf_free_vif(cfg, p2p_vif);
 			goto exit;
 		}
=20
@@ -1996,7 +1997,7 @@ void brcmf_p2p_detach(struct brcmf_p2p_info *p2p)
 		brcmf_p2p_cancel_remain_on_channel(vif->ifp);
 		brcmf_p2p_deinit_discovery(p2p);
 		/* remove discovery interface */
-		brcmf_free_vif(vif);
+		brcmf_free_vif(p2p->cfg, vif);
 		p2p->bss_idx[P2PAPI_BSSCFG_DEVICE].vif =3D NULL;
 	}
 	/* just set it all to zero */
@@ -2013,17 +2014,30 @@ static void brcmf_p2p_get_current_chanspec(struct b=
rcmf_p2p_info *p2p,
 					   u16 *chanspec)
 {
 	struct brcmf_if *ifp;
-	struct brcmf_fil_chan_info_le ci;
+	u8 mac_addr[ETH_ALEN];
 	struct brcmu_chan ch;
-	s32 err;
+	struct brcmf_bss_info_le *bi;
+	u8 *buf;
=20
 	ifp =3D p2p->bss_idx[P2PAPI_BSSCFG_PRIMARY].vif->ifp;
=20
-	ch.chnum =3D 11;
-
-	err =3D brcmf_fil_cmd_data_get(ifp, BRCMF_C_GET_CHANNEL, &ci, sizeof(ci));
-	if (!err)
-		ch.chnum =3D le32_to_cpu(ci.hw_channel);
+	if (brcmf_fil_cmd_data_get(ifp, BRCMF_C_GET_BSSID, mac_addr,
+				   ETH_ALEN) =3D=3D 0) {
+		buf =3D kzalloc(WL_BSS_INFO_MAX, GFP_KERNEL);
+		if (buf !=3D NULL) {
+			*(__le32 *)buf =3D cpu_to_le32(WL_BSS_INFO_MAX);
+			if (brcmf_fil_cmd_data_get(ifp, BRCMF_C_GET_BSS_INFO,
+						   buf, WL_BSS_INFO_MAX) =3D=3D 0) {
+				bi =3D (struct brcmf_bss_info_le *)(buf + 4);
+				*chanspec =3D le16_to_cpu(bi->chanspec);
+				kfree(buf);
+				return;
+			}
+			kfree(buf);
+		}
+	}
+	/* Use default channel for P2P */
+	ch.chnum =3D BRCMF_P2P_TEMP_CHAN;
 	ch.bw =3D BRCMU_CHAN_BW_20;
 	p2p->cfg->d11inf.encchspec(&ch);
 	*chanspec =3D ch.chspec;
@@ -2208,7 +2222,7 @@ static struct wireless_dev *brcmf_p2p_create_p2pdev(s=
truct brcmf_p2p_info *p2p,
 	return &p2p_vif->wdev;
=20
 fail:
-	brcmf_free_vif(p2p_vif);
+	brcmf_free_vif(p2p->cfg, p2p_vif);
 	return ERR_PTR(err);
 }
=20
@@ -2217,13 +2231,31 @@ fail:
  *
  * @vif: virtual interface object to delete.
  */
-static void brcmf_p2p_delete_p2pdev(struct brcmf_cfg80211_vif *vif)
+static void brcmf_p2p_delete_p2pdev(struct brcmf_cfg80211_info *cfg,
+				    struct brcmf_cfg80211_vif *vif)
 {
-	struct brcmf_p2p_info *p2p =3D &vif->ifp->drvr->config->p2p;
-
 	cfg80211_unregister_wdev(&vif->wdev);
-	p2p->bss_idx[P2PAPI_BSSCFG_DEVICE].vif =3D NULL;
-	brcmf_free_vif(vif);
+	cfg->p2p.bss_idx[P2PAPI_BSSCFG_DEVICE].vif =3D NULL;
+	brcmf_free_vif(cfg, vif);
+}
+
+/**
+ * brcmf_p2p_free_p2p_if() - free up net device related data.
+ *
+ * @ndev: net device that needs to be freed.
+ */
+static void brcmf_p2p_free_p2p_if(struct net_device *ndev)
+{
+	struct brcmf_cfg80211_info *cfg;
+	struct brcmf_cfg80211_vif *vif;
+	struct brcmf_if *ifp;
+
+	ifp =3D netdev_priv(ndev);
+	cfg =3D ifp->drvr->config;
+	vif =3D ifp->vif;
+
+	brcmf_free_vif(cfg, vif);
+	free_netdev(ifp->ndev);
 }
=20
 /**
@@ -2303,6 +2335,9 @@ struct wireless_dev *brcmf_p2p_add_vif(struct wiphy *=
wiphy, const char *name,
 		brcmf_err("Registering netdevice failed\n");
 		goto fail;
 	}
+	/* override destructor */
+	ifp->ndev->destructor =3D brcmf_p2p_free_p2p_if;
+
 	cfg->p2p.bss_idx[P2PAPI_BSSCFG_CONNECTION].vif =3D vif;
 	/* Disable firmware roaming for P2P interface  */
 	brcmf_fil_iovar_int_set(ifp, "roam_off", 1);
@@ -2314,7 +2349,7 @@ struct wireless_dev *brcmf_p2p_add_vif(struct wiphy *=
wiphy, const char *name,
 	return &ifp->vif->wdev;
=20
 fail:
-	brcmf_free_vif(vif);
+	brcmf_free_vif(cfg, vif);
 	return ERR_PTR(err);
 }
=20
@@ -2350,7 +2385,7 @@ int brcmf_p2p_del_vif(struct wiphy *wiphy, struct wir=
eless_dev *wdev)
 		break;
=20
 	case NL80211_IFTYPE_P2P_DEVICE:
-		brcmf_p2p_delete_p2pdev(vif);
+		brcmf_p2p_delete_p2pdev(cfg, vif);
 		return 0;
 	default:
 		return -ENOTSUPP;
@@ -2378,7 +2413,6 @@ int brcmf_p2p_del_vif(struct wiphy *wiphy, struct wir=
eless_dev *wdev)
 			err =3D 0;
 	}
 	brcmf_cfg80211_arm_vif_event(cfg, NULL);
-	brcmf_free_vif(vif);
 	p2p->bss_idx[P2PAPI_BSSCFG_CONNECTION].vif =3D NULL;
=20
 	return err;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 761f501..301e572 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -459,6 +459,38 @@ send_key_to_dongle(struct net_device *ndev, struct brc=
mf_wsec_key *key)
 	return err;
 }
=20
+static s32
+brcmf_configure_arp_offload(struct brcmf_if *ifp, bool enable)
+{
+	s32 err;
+	u32 mode;
+
+	if (enable)
+		mode =3D BRCMF_ARP_OL_AGENT | BRCMF_ARP_OL_PEER_AUTO_REPLY;
+	else
+		mode =3D 0;
+
+	/* Try to set and enable ARP offload feature, this may fail, then it  */
+	/* is simply not supported and err 0 will be returned                 */
+	err =3D brcmf_fil_iovar_int_set(ifp, "arp_ol", mode);
+	if (err) {
+		brcmf_dbg(TRACE, "failed to set ARP offload mode to 0x%x, err =3D %d\n",
+			  mode, err);
+		err =3D 0;
+	} else {
+		err =3D brcmf_fil_iovar_int_set(ifp, "arpoe", enable);
+		if (err) {
+			brcmf_dbg(TRACE, "failed to configure (%d) ARP offload err =3D %d\n",
+				  enable, err);
+			err =3D 0;
+		} else
+			brcmf_dbg(TRACE, "successfully configured (%d) ARP offload to 0x%x\n",
+				  enable, mode);
+	}
+
+	return err;
+}
+
 static struct wireless_dev *brcmf_cfg80211_add_iface(struct wiphy *wiphy,
 						     const char *name,
 						     enum nl80211_iftype type,
@@ -2216,6 +2248,11 @@ brcmf_cfg80211_set_power_mgmt(struct wiphy *wiphy, s=
truct net_device *ndev,
 	}
=20
 	pm =3D enabled ? PM_FAST : PM_OFF;
+	/* Do not enable the power save after assoc if it is a p2p interface */
+	if (ifp->vif->wdev.iftype =3D=3D NL80211_IFTYPE_P2P_CLIENT) {
+		brcmf_dbg(INFO, "Do not enable power save for P2P clients\n");
+		pm =3D PM_OFF;
+	}
 	brcmf_dbg(INFO, "power save %s\n", (pm ? "enabled" : "disabled"));
=20
 	err =3D brcmf_fil_cmd_int_set(ifp, BRCMF_C_SET_PM, pm);
@@ -3640,10 +3677,28 @@ brcmf_config_ap_mgmt_ie(struct brcmf_cfg80211_vif *=
vif,
 }
=20
 static s32
+brcmf_cfg80211_set_channel(struct brcmf_cfg80211_info *cfg,
+			   struct brcmf_if *ifp,
+			   struct ieee80211_channel *channel)
+{
+	u16 chanspec;
+	s32 err;
+
+	brcmf_dbg(TRACE, "band=3D%d, center_freq=3D%d\n", channel->band,
+		  channel->center_freq);
+
+	chanspec =3D channel_to_chanspec(&cfg->d11inf, channel);
+	err =3D brcmf_fil_iovar_int_set(ifp, "chanspec", chanspec);
+
+	return err;
+}
+
+static s32
 brcmf_cfg80211_start_ap(struct wiphy *wiphy, struct net_device *ndev,
 			struct cfg80211_ap_settings *settings)
 {
 	s32 ie_offset;
+	struct brcmf_cfg80211_info *cfg =3D wiphy_to_cfg(wiphy);
 	struct brcmf_if *ifp =3D netdev_priv(ndev);
 	struct brcmf_tlv *ssid_ie;
 	struct brcmf_ssid_le ssid_le;
@@ -3683,6 +3738,7 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, struct n=
et_device *ndev,
 	}
=20
 	brcmf_set_mpc(ifp, 0);
+	brcmf_configure_arp_offload(ifp, false);
=20
 	/* find the RSN_IE */
 	rsn_ie =3D brcmf_parse_tlvs((u8 *)settings->beacon.tail,
@@ -3713,6 +3769,12 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, struct =
net_device *ndev,
=20
 	brcmf_config_ap_mgmt_ie(ifp->vif, &settings->beacon);
=20
+	err =3D brcmf_cfg80211_set_channel(cfg, ifp, settings->chandef.chan);
+	if (err < 0) {
+		brcmf_err("Set Channel failed, %d\n", err);
+		goto exit;
+	}
+
 	if (settings->beacon_interval) {
 		err =3D brcmf_fil_cmd_int_set(ifp, BRCMF_C_SET_BCNPRD,
 					    settings->beacon_interval);
@@ -3789,8 +3851,10 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, struct =
net_device *ndev,
 	set_bit(BRCMF_VIF_STATUS_AP_CREATED, &ifp->vif->sme_state);
=20
 exit:
-	if (err)
+	if (err) {
 		brcmf_set_mpc(ifp, 1);
+		brcmf_configure_arp_offload(ifp, true);
+	}
 	return err;
 }
=20
@@ -3831,6 +3895,7 @@ static int brcmf_cfg80211_stop_ap(struct wiphy *wiphy=
, struct net_device *ndev)
 			brcmf_err("bss_enable config failed %d\n", err);
 	}
 	brcmf_set_mpc(ifp, 1);
+	brcmf_configure_arp_offload(ifp, true);
 	set_bit(BRCMF_VIF_STATUS_AP_CREATING, &ifp->vif->sme_state);
 	clear_bit(BRCMF_VIF_STATUS_AP_CREATED, &ifp->vif->sme_state);
=20
@@ -4148,7 +4213,7 @@ static const struct ieee80211_iface_limit brcmf_iface=
_limits[] =3D {
 static const struct ieee80211_iface_combination brcmf_iface_combos[] =3D {
 	{
 		 .max_interfaces =3D BRCMF_IFACE_MAX_CNT,
-		 .num_different_channels =3D 1, /* no multi-channel for now */
+		 .num_different_channels =3D 2,
 		 .n_limits =3D ARRAY_SIZE(brcmf_iface_limits),
 		 .limits =3D brcmf_iface_limits
 	}
@@ -4256,20 +4321,16 @@ struct brcmf_cfg80211_vif *brcmf_alloc_vif(struct b=
rcmf_cfg80211_info *cfg,
 	return vif;
 }
=20
-void brcmf_free_vif(struct brcmf_cfg80211_vif *vif)
+void brcmf_free_vif(struct brcmf_cfg80211_info *cfg,
+		    struct brcmf_cfg80211_vif *vif)
 {
-	struct brcmf_cfg80211_info *cfg;
-	struct wiphy *wiphy;
-
-	wiphy =3D vif->wdev.wiphy;
-	cfg =3D wiphy_priv(wiphy);
 	list_del(&vif->list);
 	cfg->vif_cnt--;
=20
 	kfree(vif);
 	if (!cfg->vif_cnt) {
-		wiphy_unregister(wiphy);
-		wiphy_free(wiphy);
+		wiphy_unregister(cfg->wiphy);
+		wiphy_free(cfg->wiphy);
 	}
 }
=20
@@ -4646,7 +4707,6 @@ static s32 brcmf_notify_vif_event(struct brcmf_if *if=
p,
 		return 0;
=20
 	case BRCMF_E_IF_DEL:
-		ifp->vif =3D NULL;
 		mutex_unlock(&event->vif_event_lock);
 		/* event may not be upon user request */
 		if (brcmf_cfg80211_vif_event_armed(cfg))
@@ -4852,8 +4912,7 @@ cfg80211_p2p_attach_out:
 	wl_deinit_priv(cfg);
=20
 cfg80211_attach_out:
-	brcmf_free_vif(vif);
-	wiphy_free(wiphy);
+	brcmf_free_vif(cfg, vif);
 	return NULL;
 }
=20
@@ -4865,7 +4924,7 @@ void brcmf_cfg80211_detach(struct brcmf_cfg80211_info=
 *cfg)
 	wl_deinit_priv(cfg);
 	brcmf_btcoex_detach(cfg);
 	list_for_each_entry_safe(vif, tmp, &cfg->vif_list, list) {
-		brcmf_free_vif(vif);
+		brcmf_free_vif(cfg, vif);
 	}
 }
=20
@@ -5229,6 +5288,8 @@ static s32 brcmf_config_dongle(struct brcmf_cfg80211_=
info *cfg)
 	if (err)
 		goto default_conf_out;
=20
+	brcmf_configure_arp_offload(ifp, true);
+
 	cfg->dongle_up =3D true;
 default_conf_out:
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
index a71cff8..d9bdaf9 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
@@ -487,7 +487,8 @@ enum nl80211_iftype brcmf_cfg80211_get_iftype(struct br=
cmf_if *ifp);
 struct brcmf_cfg80211_vif *brcmf_alloc_vif(struct brcmf_cfg80211_info *cfg,
 					   enum nl80211_iftype type,
 					   bool pm_block);
-void brcmf_free_vif(struct brcmf_cfg80211_vif *vif);
+void brcmf_free_vif(struct brcmf_cfg80211_info *cfg,
+	            struct brcmf_cfg80211_vif *vif);
=20
 s32 brcmf_vif_set_mgmt_ie(struct brcmf_cfg80211_vif *vif, s32 pktflag,
 			  const u8 *vndr_ie_buf, u32 vndr_ie_len);
diff --git a/drivers/net/wireless/iwlwifi/dvm/sta.c b/drivers/net/wireless/=
iwlwifi/dvm/sta.c
index db183b4..c3c13ce 100644
--- a/drivers/net/wireless/iwlwifi/dvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/dvm/sta.c
@@ -735,7 +735,7 @@ void iwl_restore_stations(struct iwl_priv *priv, struct=
 iwl_rxon_context *ctx)
 					memcpy(&lq, priv->stations[i].lq,
 					       sizeof(struct iwl_link_quality_cmd));
=20
-				if (!memcmp(&lq, &zero_lq, sizeof(lq)))
+				if (memcmp(&lq, &zero_lq, sizeof(lq)))
 					send_lq =3D true;
 			}
 			spin_unlock_bh(&priv->sta_lock);
diff --git a/drivers/nfc/Kconfig b/drivers/nfc/Kconfig
index 4775d4e..74a852e 100644
--- a/drivers/nfc/Kconfig
+++ b/drivers/nfc/Kconfig
@@ -28,7 +28,7 @@ config NFC_WILINK
=20
 config NFC_MEI_PHY
 	tristate "MEI bus NFC device support"
-	depends on INTEL_MEI_BUS_NFC && NFC_HCI
+	depends on INTEL_MEI && NFC_HCI
 	help
 	  This adds support to use an mei bus nfc device. Select this if you
 	  will use an HCI NFC driver for an NFC chip connected behind an
diff --git a/drivers/nfc/mei_phy.c b/drivers/nfc/mei_phy.c
index b8f8abc..1201bdb 100644
--- a/drivers/nfc/mei_phy.c
+++ b/drivers/nfc/mei_phy.c
@@ -64,6 +64,15 @@ int nfc_mei_phy_enable(void *phy_id)
                 return r;
 	}
=20
+	r =3D mei_cl_register_event_cb(phy->device, nfc_mei_event_cb, phy);
+	if (r) {
+		pr_err("MEY_PHY: Event cb registration failed\n");
+		mei_cl_disable_device(phy->device);
+		phy->powered =3D 0;
+
+		return r;
+	}
+
 	phy->powered =3D 1;
=20
 	return 0;
diff --git a/drivers/nfc/microread/mei.c b/drivers/nfc/microread/mei.c
index 1ad044d..cdf1bc5 100644
--- a/drivers/nfc/microread/mei.c
+++ b/drivers/nfc/microread/mei.c
@@ -43,24 +43,16 @@ static int microread_mei_probe(struct mei_cl_device *de=
vice,
 		return -ENOMEM;
 	}
=20
-	r =3D mei_cl_register_event_cb(device, nfc_mei_event_cb, phy);
-	if (r) {
-		pr_err(MICROREAD_DRIVER_NAME ": event cb registration failed\n");
-		goto err_out;
-	}
-
 	r =3D microread_probe(phy, &mei_phy_ops, LLC_NOP_NAME,
 			    MEI_NFC_HEADER_SIZE, 0, MEI_NFC_MAX_HCI_PAYLOAD,
 			    &phy->hdev);
-	if (r < 0)
-		goto err_out;
-
-	return 0;
+	if (r < 0) {
+		nfc_mei_phy_free(phy);
=20
-err_out:
-	nfc_mei_phy_free(phy);
+		return r;
+	}
=20
-	return r;
+	return 0;
 }
=20
 static int microread_mei_remove(struct mei_cl_device *device)
@@ -71,8 +63,6 @@ static int microread_mei_remove(struct mei_cl_device *dev=
ice)
=20
 	microread_remove(phy->hdev);
=20
-	nfc_mei_phy_disable(phy);
-
 	nfc_mei_phy_free(phy);
=20
 	return 0;
diff --git a/drivers/nfc/pn544/mei.c b/drivers/nfc/pn544/mei.c
index 1eb4884..b5d3d18 100644
--- a/drivers/nfc/pn544/mei.c
+++ b/drivers/nfc/pn544/mei.c
@@ -43,24 +43,16 @@ static int pn544_mei_probe(struct mei_cl_device *device,
 		return -ENOMEM;
 	}
=20
-	r =3D mei_cl_register_event_cb(device, nfc_mei_event_cb, phy);
-	if (r) {
-		pr_err(PN544_DRIVER_NAME ": event cb registration failed\n");
-		goto err_out;
-	}
-
 	r =3D pn544_hci_probe(phy, &mei_phy_ops, LLC_NOP_NAME,
 			    MEI_NFC_HEADER_SIZE, 0, MEI_NFC_MAX_HCI_PAYLOAD,
 			    &phy->hdev);
-	if (r < 0)
-		goto err_out;
-
-	return 0;
+	if (r < 0) {
+		nfc_mei_phy_free(phy);
=20
-err_out:
-	nfc_mei_phy_free(phy);
+		return r;
+	}
=20
-	return r;
+	return 0;
 }
=20
 static int pn544_mei_remove(struct mei_cl_device *device)
@@ -71,8 +63,6 @@ static int pn544_mei_remove(struct mei_cl_device *device)
=20
 	pn544_hci_remove(phy->hdev);
=20
-	nfc_mei_phy_disable(phy);
-
 	nfc_mei_phy_free(phy);
=20
 	return 0;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 60f1ce5..98d20c0 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -159,9 +159,10 @@ static int ieee80211_change_mtu(struct net_device *dev=
, int new_mtu)
 	return 0;
 }
=20
-static int ieee80211_verify_mac(struct ieee80211_local *local, u8 *addr)
+static int ieee80211_verify_mac(struct ieee80211_sub_if_data *sdata, u8 *a=
ddr)
 {
-	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_local *local =3D sdata->local;
+	struct ieee80211_sub_if_data *iter;
 	u64 new, mask, tmp;
 	u8 *m;
 	int ret =3D 0;
@@ -181,11 +182,14 @@ static int ieee80211_verify_mac(struct ieee80211_loca=
l *local, u8 *addr)
=20
=20
 	mutex_lock(&local->iflist_mtx);
-	list_for_each_entry(sdata, &local->interfaces, list) {
-		if (sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR)
+	list_for_each_entry(iter, &local->interfaces, list) {
+		if (iter =3D=3D sdata)
+			continue;
+
+		if (iter->vif.type =3D=3D NL80211_IFTYPE_MONITOR)
 			continue;
=20
-		m =3D sdata->vif.addr;
+		m =3D iter->vif.addr;
 		tmp =3D	((u64)m[0] << 5*8) | ((u64)m[1] << 4*8) |
 			((u64)m[2] << 3*8) | ((u64)m[3] << 2*8) |
 			((u64)m[4] << 1*8) | ((u64)m[5] << 0*8);
@@ -209,7 +213,7 @@ static int ieee80211_change_mac(struct net_device *dev,=
 void *addr)
 	if (ieee80211_sdata_running(sdata))
 		return -EBUSY;
=20
-	ret =3D ieee80211_verify_mac(sdata->local, sa->sa_data);
+	ret =3D ieee80211_verify_mac(sdata, sa->sa_data);
 	if (ret)
 		return ret;
=20
@@ -474,6 +478,9 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool c=
oming_up)
 			master->control_port_protocol;
 		sdata->control_port_no_encrypt =3D
 			master->control_port_no_encrypt;
+		sdata->vif.cab_queue =3D master->vif.cab_queue;
+		memcpy(sdata->vif.hw_queue, master->vif.hw_queue,
+		       sizeof(sdata->vif.hw_queue));
 		break;
 		}
 	case NL80211_IFTYPE_AP:
@@ -653,7 +660,11 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool =
coming_up)
=20
 	ieee80211_recalc_ps(local, -1);
=20
-	if (dev) {
+	if (sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR ||
+	    sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN) {
+		/* XXX: for AP_VLAN, actually track AP queues */
+		netif_tx_start_all_queues(dev);
+	} else if (dev) {
 		unsigned long flags;
 		int n_acs =3D IEEE80211_NUM_ACS;
 		int ac;
@@ -1479,7 +1490,17 @@ static void ieee80211_assign_perm_addr(struct ieee80=
211_local *local,
 			break;
 		}
=20
+		/*
+		 * Pick address of existing interface in case user changed
+		 * MAC address manually, default to perm_addr.
+		 */
 		m =3D local->hw.wiphy->perm_addr;
+		list_for_each_entry(sdata, &local->interfaces, list) {
+			if (sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR)
+				continue;
+			m =3D sdata->vif.addr;
+			break;
+		}
 		start =3D ((u64)m[0] << 5*8) | ((u64)m[1] << 4*8) |
 			((u64)m[2] << 3*8) | ((u64)m[3] << 2*8) |
 			((u64)m[4] << 1*8) | ((u64)m[5] << 0*8);
@@ -1696,6 +1717,15 @@ void ieee80211_remove_interfaces(struct ieee80211_lo=
cal *local)
=20
 	ASSERT_RTNL();
=20
+	/*
+	 * Close all AP_VLAN interfaces first, as otherwise they
+	 * might be closed while the AP interface they belong to
+	 * is closed, causing unregister_netdevice_many() to crash.
+	 */
+	list_for_each_entry(sdata, &local->interfaces, list)
+		if (sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
+			dev_close(sdata->dev);
+
 	mutex_lock(&local->iflist_mtx);
 	list_for_each_entry_safe(sdata, tmp, &local->interfaces, list) {
 		list_del(&sdata->list);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index a46e490..a8c2130 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3321,10 +3321,6 @@ static int ieee80211_probe_auth(struct ieee80211_sub=
_if_data *sdata)
 	if (WARN_ON_ONCE(!auth_data))
 		return -EINVAL;
=20
-	if (local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS)
-		tx_flags =3D IEEE80211_TX_CTL_REQ_TX_STATUS |
-			   IEEE80211_TX_INTFL_MLME_CONN_TX;
-
 	auth_data->tries++;
=20
 	if (auth_data->tries > IEEE80211_AUTH_MAX_TRIES) {
@@ -3358,6 +3354,10 @@ static int ieee80211_probe_auth(struct ieee80211_sub=
_if_data *sdata)
 			auth_data->expected_transaction =3D trans;
 		}
=20
+		if (local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS)
+			tx_flags =3D IEEE80211_TX_CTL_REQ_TX_STATUS |
+				   IEEE80211_TX_INTFL_MLME_CONN_TX;
+
 		ieee80211_send_auth(sdata, trans, auth_data->algorithm, status,
 				    auth_data->data, auth_data->data_len,
 				    auth_data->bss->bssid,
@@ -3381,12 +3381,12 @@ static int ieee80211_probe_auth(struct ieee80211_su=
b_if_data *sdata)
 		 * will not answer to direct packet in unassociated state.
 		 */
 		ieee80211_send_probe_req(sdata, NULL, ssidie + 2, ssidie[1],
-					 NULL, 0, (u32) -1, true, tx_flags,
+					 NULL, 0, (u32) -1, true, 0,
 					 auth_data->bss->channel, false);
 		rcu_read_unlock();
 	}
=20
-	if (!(local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS)) {
+	if (tx_flags =3D=3D 0) {
 		auth_data->timeout =3D jiffies + IEEE80211_AUTH_TIMEOUT;
 		ifmgd->auth_data->timeout_started =3D true;
 		run_again(ifmgd, auth_data->timeout);
diff --git a/net/nfc/Makefile b/net/nfc/Makefile
index fb799de..a76f453 100644
--- a/net/nfc/Makefile
+++ b/net/nfc/Makefile
@@ -5,7 +5,6 @@
 obj-$(CONFIG_NFC) +=3D nfc.o
 obj-$(CONFIG_NFC_NCI) +=3D nci/
 obj-$(CONFIG_NFC_HCI) +=3D hci/
-#obj-$(CONFIG_NFC_LLCP) +=3D llcp/
=20
 nfc-objs :=3D core.o netlink.o af_nfc.o rawsock.o llcp_core.o llcp_command=
s.o \
 		llcp_sock.o
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index dfdb5e6..d5aed3b 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -3411,7 +3411,7 @@ static int nl80211_send_station(struct sk_buff *msg, =
u32 portid, u32 seq,
 			(u32)sinfo->rx_bytes))
 		goto nla_put_failure;
 	if ((sinfo->filled & (STATION_INFO_TX_BYTES |
-			      NL80211_STA_INFO_TX_BYTES64)) &&
+			      STATION_INFO_TX_BYTES64)) &&
 	    nla_put_u32(msg, NL80211_STA_INFO_TX_BYTES,
 			(u32)sinfo->tx_bytes))
 		goto nla_put_failure;
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 8b5eddf..3ed35c3 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -231,6 +231,9 @@ void cfg80211_conn_work(struct work_struct *work)
 	mutex_lock(&rdev->sched_scan_mtx);
=20
 	list_for_each_entry(wdev, &rdev->wdev_list, list) {
+		if (!wdev->netdev)
+			continue;
+
 		wdev_lock(wdev);
 		if (!netif_running(wdev->netdev)) {
 			wdev_unlock(wdev);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRph60AAoJEJctW/TcYTgGD+wP/1X3AR4YysxSBsK4Ps6t/9bM
7i2l3CEp/CH20J2Gl2Q5RBNJkofEPHvF3XG3aYlovVLDVDEfxZFYrhUq0clQT0ZB
qf/bHd3UMeoEGUDPKJPfztLehiEKeR/vZ93IatfjHqngsxKtArTz8eZUxxNM8pKI
SOkA7V47d/q2kZ6x9sbSr/K/D9WbGaFHL8O0koAAX5VN5JdgVAci/BFLEMMdfEnU
S4AwkUlOnEao80Q/YLjKqlOPD1EVZx095wHZTqKAN0O5wwLPwvOFMf7JQ5KB7Lxv
rMJVIgCbDwL+QviaULkaJviTYa9+nEqtlANp9DS//HIQNo5BugxN+kaeb3opIW4E
20bpoHEt2vyAv/wOxFHIOkREDnKWsNxL4yicIUVH+MdZTQzLtO6XjevIj0dLyMDd
S+Ox8vdj4UnEemjO9b+yrm7KcKpAzGjDQ9wOR3IgwsjAQroGGWXpaPXQxEPBcDNR
Yzqj5NPgxjkitfQ3uiKuItnkgXoOmN5DDsRFGTyYpMLUCl1mgr2BhjwSP0yJbL2B
JlLmcIc9rUMseURQ5BR91WPFK561roCmzdE8/Uy6AVCubtb9SACz29Hi2SmelIcK
gyJS8E3RzfoOYkXq7kJ0zSqiYAvee5RwBMn0v97Ci71FLZVxprwByOR9lHVTdUu3
zpxNKxnT0V8u+hamIJOm
=+DTp
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--
