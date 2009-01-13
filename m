From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-01-13
Date: Tue, 13 Jan 2009 11:35:24 -0500
Message-ID: <20090113163524.GD3623@tuxdriver.com>
References: <20090112201302.GB3786@tuxdriver.com> <20090112.212345.259792227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47912 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbZAMQpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 11:45:44 -0500
Content-Disposition: inline
In-Reply-To: <20090112.212345.259792227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(This is the 2nd try, w/ the erroneous file removal...well, removed. --=
 JWL)

Dave,

Here is the first post-merge-window pull request for wireless in the
2.6.29 cycle.  There are more patches than I would like -- as you noted
elsewhere, I failed to get things together before the merge window
closed.  Fortunately, there isn't anything in my pile of non-fixes that
I really wanted in 2.6.29 anyway.  So I think this batch will have
wireless caught-up for 2.6.29-rc2.

Most of these are small fixes and obvious enough.  I did lay a number o=
f
one-line warning fixes on top.  Everything else has been cooked in
wireless-testing, so there shouldn't be any surprise turds here -- let'=
s
hope! :-)

There are a few fixes here related to returning NETDEV_TX_OK instead of
something else.  This was the source of a subtle bug in rtl8187.  I've
included this kind of fix for other drivers in hopes of avoiding
similarly subtle bugs with them.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 3bc53427e4f323d4f33f70477fc32c1c2ae7=
fb5d:
  Timur Tabi (1):
        ucc_geth: use correct UCCE macros

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Andrew Price (1):
      rt2x00: Fix radio LED type check

Andrey Yurovsky (1):
      libertas_tf: return NETDEV_TX_OK in TX op

Bob Copeland (1):
      ath5k: fix return values from ath5k_tx

Christian Lamparter (5):
      p54: crypto offload fixes
      p54usb: fix random traffic stalls (LM87)
      minstrel: fix warning if lowest supported rate index is not 0
      p54: fix WARN_ON at line 2247 of net/mac80211/rx.c
      mac80211: initialize RC data for all mesh links upon allocation

Daniel Wu (1):
      iwlwifi: Fix typo in iwl-commands.h for CCK rate bit range.

David Kilroy (1):
      orinoco: take the driver lock in the rx tasklet

Erik Ekman (1):
      Wireless: Fix Kconfig fact error

Ivo van Doorn (4):
      rt2x00: Fix TX short preamble detection
      rt2x00: Fix segementation fault
      Fix rt2500usb HW crypto: TKIP
      rt2x00: Fix rt2500usb HW crypto: WEP 128 & AES

Johannes Berg (1):
      rtl8187: Fix module so that rmmod/insmod does not error

John W. Linville (5):
      mac80211: fix "=E2=80=98ret=E2=80=99 may be used uninitialized" w=
arning
      b43: fix "=E2=80=98gmode=E2=80=99 may be used uninitialized" warn=
ing
      b43legacy: fix "=E2=80=98up_dev=E2=80=99 may be used uninitialize=
d" warning
      iwl3945: fix "=E2=80=98power_idx=E2=80=99 may be used uninitializ=
ed" warning
      p54: fix "=E2=80=98ret=E2=80=99 may be used uninitialized" warnin=
g

Jouni Malinen (2):
      ath9k: Enforce module build if rfkill is a module
      ath9k: Revert fix to TX status reporting for retries and MCS inde=
x

Larry Finger (2):
      p54usb: Fix to prevent SKB memory allocation errors with 4K page =
size
      rtl8180: Fix to add STA mode

Michiel (1):
      p54usb: Add USB ID for Thomson Speedtouch 121g

Pavel Roskin (2):
      orinoco_cs: add ID for ARtem Onair Comcard 11
      mac80211: allow mode change if IBSS is not allowed

Samuel Ortiz (1):
      iwlwifi: Fix get_cmd_string() for REPLY_3945_RX

Senthil Balasubramanian (1):
      ath9k: Fix incorrect sequence numbering for unaggregated QoS Fram=
e.

Stefan Lippers-Hollmann (1):
      rt2x00: add USB ID for the Linksys WUSB200.

Steve Brown (1):
      ath5k: Correct usage of AR5K_CFG_ADHOC

Sujith (1):
      ath9k: Fix chainmask handling bug

 drivers/net/wireless/Kconfig                |    2 +-
 drivers/net/wireless/ath5k/base.c           |    8 ++--
 drivers/net/wireless/ath5k/pcu.c            |    4 +-
 drivers/net/wireless/ath5k/reg.h            |    2 +-
 drivers/net/wireless/ath9k/Kconfig          |    1 +
 drivers/net/wireless/ath9k/main.c           |    4 +-
 drivers/net/wireless/ath9k/xmit.c           |   48 ++++++++++---------=
--------
 drivers/net/wireless/b43/main.c             |    2 +-
 drivers/net/wireless/b43legacy/main.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h |    2 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    1 +
 drivers/net/wireless/libertas_tf/main.c     |    2 +-
 drivers/net/wireless/orinoco/orinoco.c      |   28 ++++++++++++++--
 drivers/net/wireless/orinoco/orinoco_cs.c   |    1 +
 drivers/net/wireless/p54/p54common.c        |   34 +++++++++++++++++--
 drivers/net/wireless/p54/p54usb.c           |    2 +
 drivers/net/wireless/rt2x00/rt2500usb.c     |   23 ++++--------
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    8 ++---
 drivers/net/wireless/rt2x00/rt2x00leds.c    |    2 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h     |   11 ------
 drivers/net/wireless/rt2x00/rt2x00queue.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c     |    6 ++--
 drivers/net/wireless/rt2x00/rt73usb.c       |    1 +
 drivers/net/wireless/rtl818x/rtl8180_dev.c  |    1 +
 drivers/net/wireless/rtl818x/rtl8187_dev.c  |    5 ++-
 net/mac80211/ht.c                           |    2 +-
 net/mac80211/iface.c                        |    3 +-
 net/mac80211/mesh_plink.c                   |    1 +
 net/mac80211/rc80211_minstrel.c             |   10 +++--
 30 files changed, 124 insertions(+), 96 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfi=
g
index ea543fc..e4f9f74 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -111,7 +111,7 @@ config WLAN_80211
 	  lets you choose drivers.
=20
 config PCMCIA_RAYCS
-	tristate "Aviator/Raytheon 2.4MHz wireless support"
+	tristate "Aviator/Raytheon 2.4GHz wireless support"
 	depends on PCMCIA && WLAN_80211
 	select WIRELESS_EXT
 	---help---
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/a=
th5k/base.c
index 4af2607..8ef8735 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -2644,7 +2644,7 @@ ath5k_tx(struct ieee80211_hw *hw, struct sk_buff =
*skb)
 		if (skb_headroom(skb) < padsize) {
 			ATH5K_ERR(sc, "tx hdrlen not %%4: %d not enough"
 				  " headroom to pad %d\n", hdrlen, padsize);
-			return -1;
+			return NETDEV_TX_BUSY;
 		}
 		skb_push(skb, padsize);
 		memmove(skb->data, skb->data+padsize, hdrlen);
@@ -2655,7 +2655,7 @@ ath5k_tx(struct ieee80211_hw *hw, struct sk_buff =
*skb)
 		ATH5K_ERR(sc, "no further txbuf available, dropping packet\n");
 		spin_unlock_irqrestore(&sc->txbuflock, flags);
 		ieee80211_stop_queue(hw, skb_get_queue_mapping(skb));
-		return -1;
+		return NETDEV_TX_BUSY;
 	}
 	bf =3D list_first_entry(&sc->txbuf, struct ath5k_buf, list);
 	list_del(&bf->list);
@@ -2673,10 +2673,10 @@ ath5k_tx(struct ieee80211_hw *hw, struct sk_buf=
f *skb)
 		sc->txbuf_len++;
 		spin_unlock_irqrestore(&sc->txbuflock, flags);
 		dev_kfree_skb_any(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
=20
-	return 0;
+	return NETDEV_TX_OK;
 }
=20
 static int
diff --git a/drivers/net/wireless/ath5k/pcu.c b/drivers/net/wireless/at=
h5k/pcu.c
index 0cac05c..75eb9f4 100644
--- a/drivers/net/wireless/ath5k/pcu.c
+++ b/drivers/net/wireless/ath5k/pcu.c
@@ -65,7 +65,7 @@ int ath5k_hw_set_opmode(struct ath5k_hw *ah)
 		if (ah->ah_version =3D=3D AR5K_AR5210)
 			pcu_reg |=3D AR5K_STA_ID1_NO_PSPOLL;
 		else
-			AR5K_REG_DISABLE_BITS(ah, AR5K_CFG, AR5K_CFG_ADHOC);
+			AR5K_REG_ENABLE_BITS(ah, AR5K_CFG, AR5K_CFG_IBSS);
 		break;
=20
 	case NL80211_IFTYPE_AP:
@@ -75,7 +75,7 @@ int ath5k_hw_set_opmode(struct ath5k_hw *ah)
 		if (ah->ah_version =3D=3D AR5K_AR5210)
 			pcu_reg |=3D AR5K_STA_ID1_NO_PSPOLL;
 		else
-			AR5K_REG_ENABLE_BITS(ah, AR5K_CFG, AR5K_CFG_ADHOC);
+			AR5K_REG_DISABLE_BITS(ah, AR5K_CFG, AR5K_CFG_IBSS);
 		break;
=20
 	case NL80211_IFTYPE_STATION:
diff --git a/drivers/net/wireless/ath5k/reg.h b/drivers/net/wireless/at=
h5k/reg.h
index 91aaeaf..9189ab1 100644
--- a/drivers/net/wireless/ath5k/reg.h
+++ b/drivers/net/wireless/ath5k/reg.h
@@ -73,7 +73,7 @@
 #define	AR5K_CFG_SWRD		0x00000004	/* Byte-swap RX descriptor */
 #define	AR5K_CFG_SWRB		0x00000008	/* Byte-swap RX buffer */
 #define	AR5K_CFG_SWRG		0x00000010	/* Byte-swap Register access */
-#define AR5K_CFG_ADHOC		0x00000020 	/* AP/Adhoc indication [5211+] */
+#define AR5K_CFG_IBSS		0x00000020 	/* 0-BSS, 1-IBSS [5211+] */
 #define AR5K_CFG_PHY_OK		0x00000100	/* [5211+] */
 #define AR5K_CFG_EEBS		0x00000200	/* EEPROM is busy */
 #define	AR5K_CFG_CLKGD		0x00000400	/* Clock gated (Disable dynamic clo=
ck) */
diff --git a/drivers/net/wireless/ath9k/Kconfig b/drivers/net/wireless/=
ath9k/Kconfig
index c43bd32..90a8dd8 100644
--- a/drivers/net/wireless/ath9k/Kconfig
+++ b/drivers/net/wireless/ath9k/Kconfig
@@ -1,6 +1,7 @@
 config ATH9K
 	tristate "Atheros 802.11n wireless cards support"
 	depends on PCI && MAC80211 && WLAN_80211
+	depends on RFKILL || RFKILL=3Dn
 	select MAC80211_LEDS
 	select LEDS_CLASS
 	select NEW_LEDS
diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/a=
th9k/main.c
index 191eec5..727f067 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -2164,13 +2164,13 @@ static int ath9k_config(struct ieee80211_hw *hw=
, u32 changed)
 						    conf->ht.channel_type);
 		}
=20
+		ath_update_chainmask(sc, conf->ht.enabled);
+
 		if (ath_set_channel(sc, &sc->sc_ah->ah_channels[pos]) < 0) {
 			DPRINTF(sc, ATH_DBG_FATAL, "Unable to set channel\n");
 			mutex_unlock(&sc->mutex);
 			return -EINVAL;
 		}
-
-		ath_update_chainmask(sc, conf->ht.enabled);
 	}
=20
 	if (changed & IEEE80211_CONF_CHANGE_POWER)
diff --git a/drivers/net/wireless/ath9k/xmit.c b/drivers/net/wireless/a=
th9k/xmit.c
index 3bfc3b9..c92f0c6 100644
--- a/drivers/net/wireless/ath9k/xmit.c
+++ b/drivers/net/wireless/ath9k/xmit.c
@@ -126,15 +126,7 @@ static void ath_tx_complete(struct ath_softc *sc, =
struct sk_buff *skb,
 		tx_info->flags |=3D IEEE80211_TX_STAT_ACK;
 	}
=20
-	tx_info->status.rates[0].count =3D tx_status->retries;
-	if (tx_info->status.rates[0].flags & IEEE80211_TX_RC_MCS) {
-		/* Change idx from internal table index to MCS index */
-		int idx =3D tx_info->status.rates[0].idx;
-		struct ath_rate_table *rate_table =3D sc->cur_rate_table;
-		if (idx >=3D 0 && idx < rate_table->rate_cnt)
-			tx_info->status.rates[0].idx =3D
-				rate_table->info[idx].ratecode & 0x7f;
-	}
+	tx_info->status.rates[0].count =3D tx_status->retries + 1;
=20
 	hdrlen =3D ieee80211_get_hdrlen_from_skb(skb);
 	padsize =3D hdrlen & 3;
@@ -264,25 +256,22 @@ static void assign_aggr_tid_seqno(struct sk_buff =
*skb,
 	}
=20
 	/* Get seqno */
-
-	if (ieee80211_is_data(fc) && !is_pae(skb)) {
-		/* For HT capable stations, we save tidno for later use.
-		 * We also override seqno set by upper layer with the one
-		 * in tx aggregation state.
-		 *
-		 * If fragmentation is on, the sequence number is
-		 * not overridden, since it has been
-		 * incremented by the fragmentation routine.
-		 *
-		 * FIXME: check if the fragmentation threshold exceeds
-		 * IEEE80211 max.
-		 */
-		tid =3D ATH_AN_2_TID(an, bf->bf_tidno);
-		hdr->seq_ctrl =3D cpu_to_le16(tid->seq_next <<
-					    IEEE80211_SEQ_SEQ_SHIFT);
-		bf->bf_seqno =3D tid->seq_next;
-		INCR(tid->seq_next, IEEE80211_SEQ_MAX);
-	}
+	/* For HT capable stations, we save tidno for later use.
+	 * We also override seqno set by upper layer with the one
+	 * in tx aggregation state.
+	 *
+	 * If fragmentation is on, the sequence number is
+	 * not overridden, since it has been
+	 * incremented by the fragmentation routine.
+	 *
+	 * FIXME: check if the fragmentation threshold exceeds
+	 * IEEE80211 max.
+	 */
+	tid =3D ATH_AN_2_TID(an, bf->bf_tidno);
+	hdr->seq_ctrl =3D cpu_to_le16(tid->seq_next <<
+			IEEE80211_SEQ_SEQ_SHIFT);
+	bf->bf_seqno =3D tid->seq_next;
+	INCR(tid->seq_next, IEEE80211_SEQ_MAX);
 }
=20
 static int setup_tx_flags(struct ath_softc *sc, struct sk_buff *skb,
@@ -1718,11 +1707,10 @@ static int ath_tx_setup_buffer(struct ath_softc=
 *sc, struct ath_buf *bf,
=20
 	/* Assign seqno, tidno */
=20
-	if (bf_isht(bf) && (sc->sc_flags & SC_OP_TXAGGR))
+	if (ieee80211_is_data_qos(fc) && (sc->sc_flags & SC_OP_TXAGGR))
 		assign_aggr_tid_seqno(skb, bf);
=20
 	/* DMA setup */
-
 	bf->bf_mpdu =3D skb;
=20
 	bf->bf_dmacontext =3D pci_map_single(sc->pdev, skb->data,
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43=
/main.c
index 7b31a32..c788bad 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -3261,7 +3261,7 @@ static int b43_switch_band(struct b43_wl *wl, str=
uct ieee80211_channel *chan)
 	struct b43_wldev *down_dev;
 	struct b43_wldev *d;
 	int err;
-	bool gmode;
+	bool uninitialized_var(gmode);
 	int prev_status;
=20
 	/* Find a device and PHY which supports the band. */
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wirele=
ss/b43legacy/main.c
index c1324e3..fb996c2 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2465,7 +2465,7 @@ static void b43legacy_put_phy_into_reset(struct b=
43legacy_wldev *dev)
 static int b43legacy_switch_phymode(struct b43legacy_wl *wl,
 				      unsigned int new_mode)
 {
-	struct b43legacy_wldev *up_dev;
+	struct b43legacy_wldev *uninitialized_var(up_dev);
 	struct b43legacy_wldev *down_dev;
 	int err;
 	bool gmode =3D 0;
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wire=
less/iwlwifi/iwl-3945.c
index 8fdb342..45cfa1c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2219,7 +2219,7 @@ int iwl3945_txpower_set_from_eeprom(struct iwl394=
5_priv *priv)
 		/* set tx power value for all OFDM rates */
 		for (rate_index =3D 0; rate_index < IWL_OFDM_RATES;
 		     rate_index++) {
-			s32 power_idx;
+			s32 uninitialized_var(power_idx);
 			int rc;
=20
 			/* use channel group's clip-power table,
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/=
wireless/iwlwifi/iwl-commands.h
index 52966ff..ba99720 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -255,7 +255,7 @@ struct iwl_cmd_header {
  *        0x3)  54 Mbps
  *
  * Legacy CCK rate format for bits 7:0 (bit 8 must be "0", bit 9 "1"):
- *  3-0:   10)  1 Mbps
+ *  6-0:   10)  1 Mbps
  *         20)  2 Mbps
  *         55)  5.5 Mbps
  *        110)  11 Mbps
diff --git a/drivers/net/wireless/iwlwifi/iwl-hcmd.c b/drivers/net/wire=
less/iwlwifi/iwl-hcmd.c
index 01a2169..8c71ad4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-hcmd.c
+++ b/drivers/net/wireless/iwlwifi/iwl-hcmd.c
@@ -51,6 +51,7 @@ const char *get_cmd_string(u8 cmd)
 		IWL_CMD(REPLY_REMOVE_STA);
 		IWL_CMD(REPLY_REMOVE_ALL_STA);
 		IWL_CMD(REPLY_WEPKEY);
+		IWL_CMD(REPLY_3945_RX);
 		IWL_CMD(REPLY_TX);
 		IWL_CMD(REPLY_RATE_SCALE);
 		IWL_CMD(REPLY_LEDS_CMD);
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wire=
less/libertas_tf/main.c
index d1fc305..e7289e2 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -206,7 +206,7 @@ static int lbtf_op_tx(struct ieee80211_hw *hw, stru=
ct sk_buff *skb)
 	 * there are no buffered multicast frames to send
 	 */
 	ieee80211_stop_queues(priv->hw);
-	return 0;
+	return NETDEV_TX_OK;
 }
=20
 static void lbtf_tx_work(struct work_struct *work)
diff --git a/drivers/net/wireless/orinoco/orinoco.c b/drivers/net/wirel=
ess/orinoco/orinoco.c
index bc84e27..c3bb85e 100644
--- a/drivers/net/wireless/orinoco/orinoco.c
+++ b/drivers/net/wireless/orinoco/orinoco.c
@@ -1610,6 +1610,16 @@ static void orinoco_rx_isr_tasklet(unsigned long=
 data)
 	struct orinoco_rx_data *rx_data, *temp;
 	struct hermes_rx_descriptor *desc;
 	struct sk_buff *skb;
+	unsigned long flags;
+
+	/* orinoco_rx requires the driver lock, and we also need to
+	 * protect priv->rx_list, so just hold the lock over the
+	 * lot.
+	 *
+	 * If orinoco_lock fails, we've unplugged the card. In this
+	 * case just abort. */
+	if (orinoco_lock(priv, &flags) !=3D 0)
+		return;
=20
 	/* extract desc and skb from queue */
 	list_for_each_entry_safe(rx_data, temp, &priv->rx_list, list) {
@@ -1622,6 +1632,8 @@ static void orinoco_rx_isr_tasklet(unsigned long =
data)
=20
 		kfree(desc);
 	}
+
+	orinoco_unlock(priv, &flags);
 }
=20
 /********************************************************************/
@@ -3645,12 +3657,22 @@ struct net_device
 void free_orinocodev(struct net_device *dev)
 {
 	struct orinoco_private *priv =3D netdev_priv(dev);
+	struct orinoco_rx_data *rx_data, *temp;
=20
-	/* No need to empty priv->rx_list: if the tasklet is scheduled
-	 * when we call tasklet_kill it will run one final time,
-	 * emptying the list */
+	/* If the tasklet is scheduled when we call tasklet_kill it
+	 * will run one final time. However the tasklet will only
+	 * drain priv->rx_list if the hw is still available. */
 	tasklet_kill(&priv->rx_tasklet);
=20
+	/* Explicitly drain priv->rx_list */
+	list_for_each_entry_safe(rx_data, temp, &priv->rx_list, list) {
+		list_del(&rx_data->list);
+
+		dev_kfree_skb(rx_data->skb);
+		kfree(rx_data->desc);
+		kfree(rx_data);
+	}
+
 	unregister_pm_notifier(&priv->pm_notifier);
 	orinoco_uncache_fw(priv);
=20
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wi=
reless/orinoco/orinoco_cs.c
index f127602..0b32215 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -435,6 +435,7 @@ static struct pcmcia_device_id orinoco_cs_ids[] =3D=
 {
 	PCMCIA_DEVICE_MANF_CARD(0x0250, 0x0002), /* Samsung SWL2000-N 11Mb/s =
WLAN Card */
 	PCMCIA_DEVICE_MANF_CARD(0x0261, 0x0002), /* AirWay 802.11 Adapter (PC=
MCIA) */
 	PCMCIA_DEVICE_MANF_CARD(0x0268, 0x0001), /* ARtem Onair */
+	PCMCIA_DEVICE_MANF_CARD(0x0268, 0x0003), /* ARtem Onair Comcard 11 */
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0305), /* Buffalo WLI-PCM-S11 */
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1612), /* Linksys WPC11 Version 2.5=
 */
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1613), /* Linksys WPC11 Version 3 *=
/
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireles=
s/p54/p54common.c
index 82354b9..c6a370f 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -138,6 +138,7 @@ int p54_parse_firmware(struct ieee80211_hw *dev, co=
nst struct firmware *fw)
 	u8 *fw_version =3D NULL;
 	size_t len;
 	int i;
+	int maxlen;
=20
 	if (priv->rx_start)
 		return 0;
@@ -195,6 +196,16 @@ int p54_parse_firmware(struct ieee80211_hw *dev, c=
onst struct firmware *fw)
 			else
 				priv->rx_mtu =3D (size_t)
 					0x620 - priv->tx_hdr_len;
+			maxlen =3D priv->tx_hdr_len + /* USB devices */
+				 sizeof(struct p54_rx_data) +
+				 4 + /* rx alignment */
+				 IEEE80211_MAX_FRAG_THRESHOLD;
+			if (priv->rx_mtu > maxlen && PAGE_SIZE =3D=3D 4096) {
+				printk(KERN_INFO "p54: rx_mtu reduced from %d "
+					         "to %d\n", priv->rx_mtu,
+						 maxlen);
+				priv->rx_mtu =3D maxlen;
+			}
 			break;
 			}
 		case BR_CODE_EXPOSED_IF:
@@ -575,6 +586,7 @@ static int p54_rx_data(struct ieee80211_hw *dev, st=
ruct sk_buff *skb)
 	u16 freq =3D le16_to_cpu(hdr->freq);
 	size_t header_len =3D sizeof(*hdr);
 	u32 tsf32;
+	u8 rate =3D hdr->rate & 0xf;
=20
 	/*
 	 * If the device is in a unspecified state we have to
@@ -603,8 +615,11 @@ static int p54_rx_data(struct ieee80211_hw *dev, s=
truct sk_buff *skb)
 	rx_status.qual =3D (100 * hdr->rssi) / 127;
 	if (hdr->rate & 0x10)
 		rx_status.flag |=3D RX_FLAG_SHORTPRE;
-	rx_status.rate_idx =3D (dev->conf.channel->band =3D=3D IEEE80211_BAND=
_2GHZ ?
-			hdr->rate : (hdr->rate - 4)) & 0xf;
+	if (dev->conf.channel->band =3D=3D IEEE80211_BAND_5GHZ)
+		rx_status.rate_idx =3D (rate < 4) ? 0 : rate - 4;
+	else
+		rx_status.rate_idx =3D rate;
+
 	rx_status.freq =3D freq;
 	rx_status.band =3D  dev->conf.channel->band;
 	rx_status.antenna =3D hdr->antenna;
@@ -798,6 +813,16 @@ static void p54_rx_frame_sent(struct ieee80211_hw =
*dev, struct sk_buff *skb)
 			info->flags |=3D IEEE80211_TX_STAT_TX_FILTERED;
 		info->status.ack_signal =3D p54_rssi_to_dbm(dev,
 				(int)payload->ack_rssi);
+
+		if (entry_data->key_type =3D=3D P54_CRYPTO_TKIPMICHAEL) {
+			u8 *iv =3D (u8 *)(entry_data->align + pad +
+				        entry_data->crypt_offset);
+
+			/* Restore the original TKIP IV. */
+			iv[2] =3D iv[0];
+			iv[0] =3D iv[1];
+			iv[1] =3D (iv[0] | 0x20) & 0x7f;	/* WEPSeed - 8.3.2.2 */
+		}
 		skb_pull(entry, sizeof(*hdr) + pad + sizeof(*entry_data));
 		ieee80211_tx_status_irqsafe(dev, entry);
 		goto out;
@@ -1383,7 +1408,6 @@ static int p54_tx(struct ieee80211_hw *dev, struc=
t sk_buff *skb)
 	hdr->tries =3D ridx;
 	txhdr->rts_rate_idx =3D 0;
 	if (info->control.hw_key) {
-		crypt_offset +=3D info->control.hw_key->iv_len;
 		txhdr->key_type =3D p54_convert_algo(info->control.hw_key->alg);
 		txhdr->key_len =3D min((u8)16, info->control.hw_key->keylen);
 		memcpy(txhdr->key, info->control.hw_key->key, txhdr->key_len);
@@ -1397,6 +1421,8 @@ static int p54_tx(struct ieee80211_hw *dev, struc=
t sk_buff *skb)
 		}
 		/* reserve some space for ICV */
 		len +=3D info->control.hw_key->icv_len;
+		memset(skb_put(skb, info->control.hw_key->icv_len), 0,
+		       info->control.hw_key->icv_len);
 	} else {
 		txhdr->key_type =3D 0;
 		txhdr->key_len =3D 0;
@@ -1824,7 +1850,7 @@ static void p54_remove_interface(struct ieee80211=
_hw *dev,
=20
 static int p54_config(struct ieee80211_hw *dev, u32 changed)
 {
-	int ret;
+	int ret =3D 0;
 	struct p54_common *priv =3D dev->priv;
 	struct ieee80211_conf *conf =3D &dev->conf;
=20
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p=
54/p54usb.c
index c44a200..6a6a72f 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -56,6 +56,7 @@ static struct usb_device_id p54u_table[] __devinitdat=
a =3D {
 	{USB_DEVICE(0x050d, 0x7050)},	/* Belkin F5D7050 ver 1000 */
 	{USB_DEVICE(0x0572, 0x2000)},	/* Cohiba Proto board */
 	{USB_DEVICE(0x0572, 0x2002)},	/* Cohiba Proto board */
+	{USB_DEVICE(0x06b9, 0x0121)},	/* Thomson SpeedTouch 121g */
 	{USB_DEVICE(0x0707, 0xee13)},   /* SMC 2862W-G version 2 */
 	{USB_DEVICE(0x083a, 0x4521)},   /* Siemens Gigaset USB Adapter 54 ver=
sion 2 */
 	{USB_DEVICE(0x0846, 0x4240)},	/* Netgear WG111 (v2) */
@@ -284,6 +285,7 @@ static void p54u_tx_lm87(struct ieee80211_hw *dev, =
struct sk_buff *skb)
 	usb_fill_bulk_urb(data_urb, priv->udev,
 			  usb_sndbulkpipe(priv->udev, P54U_PIPE_DATA),
 			  skb->data, skb->len, p54u_tx_cb, skb);
+	data_urb->transfer_flags |=3D URB_ZERO_PACKET;
=20
 	usb_anchor_urb(data_urb, &priv->submitted);
 	if (usb_submit_urb(data_urb, GFP_ATOMIC)) {
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wire=
less/rt2x00/rt2500usb.c
index 30028e2..af6b584 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -38,7 +38,7 @@
 /*
  * Allow hardware encryption to be disabled.
  */
-static int modparam_nohwcrypt =3D 1;
+static int modparam_nohwcrypt =3D 0;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
=20
@@ -376,11 +376,11 @@ static int rt2500usb_config_key(struct rt2x00_dev=
 *rt2x00dev,
=20
 		/*
 		 * The driver does not support the IV/EIV generation
-		 * in hardware. However it doesn't support the IV/EIV
-		 * inside the ieee80211 frame either, but requires it
-		 * to be provided seperately for the descriptor.
-		 * rt2x00lib will cut the IV/EIV data out of all frames
-		 * given to us by mac80211, but we must tell mac80211
+		 * in hardware. However it demands the data to be provided
+		 * both seperately as well as inside the frame.
+		 * We already provided the CONFIG_CRYPTO_COPY_IV to rt2x00lib
+		 * to ensure rt2x00lib will not strip the data from the
+		 * frame after the copy, now we must tell mac80211
 		 * to generate the IV/EIV data.
 		 */
 		key->flags |=3D IEEE80211_KEY_FLAG_GENERATE_IV;
@@ -1181,7 +1181,7 @@ static void rt2500usb_write_tx_desc(struct rt2x00=
_dev *rt2x00dev,
 			   test_bit(ENTRY_TXD_FIRST_FRAGMENT, &txdesc->flags));
 	rt2x00_set_field32(&word, TXD_W0_IFS, txdesc->ifs);
 	rt2x00_set_field32(&word, TXD_W0_DATABYTE_COUNT, skb->len);
-	rt2x00_set_field32(&word, TXD_W0_CIPHER, txdesc->cipher);
+	rt2x00_set_field32(&word, TXD_W0_CIPHER, !!txdesc->cipher);
 	rt2x00_set_field32(&word, TXD_W0_KEY_ID, txdesc->key_idx);
 	rt2x00_desc_write(txd, 0, word);
 }
@@ -1334,14 +1334,7 @@ static void rt2500usb_fill_rxdone(struct queue_e=
ntry *entry,
=20
 		/* ICV is located at the end of frame */
=20
-		/*
-		 * Hardware has stripped IV/EIV data from 802.11 frame during
-		 * decryption. It has provided the data seperately but rt2x00lib
-		 * should decide if it should be reinserted.
-		 */
-		rxdesc->flags |=3D RX_FLAG_IV_STRIPPED;
-		if (rxdesc->cipher !=3D CIPHER_TKIP)
-			rxdesc->flags |=3D RX_FLAG_MMIC_STRIPPED;
+		rxdesc->flags |=3D RX_FLAG_MMIC_STRIPPED;
 		if (rxdesc->cipher_status =3D=3D RX_CRYPTO_SUCCESS)
 			rxdesc->flags |=3D RX_FLAG_DECRYPTED;
 		else if (rxdesc->cipher_status =3D=3D RX_CRYPTO_FAIL_MIC)
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wire=
less/rt2x00/rt2x00dev.c
index 6d92542..87c0f2c 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -807,13 +807,11 @@ static void rt2x00lib_rate(struct ieee80211_rate =
*entry,
 {
 	entry->flags =3D 0;
 	entry->bitrate =3D rate->bitrate;
-	entry->hw_value =3D rt2x00_create_rate_hw_value(index, 0);
-	entry->hw_value_short =3D entry->hw_value;
+	entry->hw_value =3Dindex;
+	entry->hw_value_short =3D index;
=20
-	if (rate->flags & DEV_RATE_SHORT_PREAMBLE) {
+	if (rate->flags & DEV_RATE_SHORT_PREAMBLE)
 		entry->flags |=3D IEEE80211_RATE_SHORT_PREAMBLE;
-		entry->hw_value_short |=3D rt2x00_create_rate_hw_value(index, 1);
-	}
 }
=20
 static int rt2x00lib_probe_hw_modes(struct rt2x00_dev *rt2x00dev,
diff --git a/drivers/net/wireless/rt2x00/rt2x00leds.c b/drivers/net/wir=
eless/rt2x00/rt2x00leds.c
index 68f4e0f..a0cd35b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00leds.c
+++ b/drivers/net/wireless/rt2x00/rt2x00leds.c
@@ -97,7 +97,7 @@ void rt2x00leds_led_assoc(struct rt2x00_dev *rt2x00de=
v, bool enabled)
=20
 void rt2x00leds_led_radio(struct rt2x00_dev *rt2x00dev, bool enabled)
 {
-	if (rt2x00dev->led_radio.type =3D=3D LED_TYPE_ASSOC)
+	if (rt2x00dev->led_radio.type =3D=3D LED_TYPE_RADIO)
 		rt2x00led_led_simple(&rt2x00dev->led_radio, enabled);
 }
=20
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wire=
less/rt2x00/rt2x00lib.h
index 0302432..86cd26f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -52,22 +52,11 @@ struct rt2x00_rate {
=20
 extern const struct rt2x00_rate rt2x00_supported_rates[12];
=20
-static inline u16 rt2x00_create_rate_hw_value(const u16 index,
-					      const u16 short_preamble)
-{
-	return (short_preamble << 8) | (index & 0xff);
-}
-
 static inline const struct rt2x00_rate *rt2x00_get_rate(const u16 hw_v=
alue)
 {
 	return &rt2x00_supported_rates[hw_value & 0xff];
 }
=20
-static inline int rt2x00_get_rate_preamble(const u16 hw_value)
-{
-	return (hw_value & 0xff00);
-}
-
 /*
  * Radio control handlers.
  */
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wi=
reless/rt2x00/rt2x00queue.c
index eaec6bd..746a8f3 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -313,7 +313,7 @@ static void rt2x00queue_create_tx_descriptor(struct=
 queue_entry *entry,
 		 * When preamble is enabled we should set the
 		 * preamble bit for the signal.
 		 */
-		if (rt2x00_get_rate_preamble(rate->hw_value))
+		if (rate->flags & IEEE80211_TX_RC_USE_SHORT_PREAMBLE)
 			txdesc->signal |=3D 0x08;
 	}
 }
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wire=
less/rt2x00/rt2x00usb.c
index 83df312..0b29d76 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -434,11 +434,11 @@ static int rt2x00usb_find_endpoints(struct rt2x00=
_dev *rt2x00dev)
=20
 		if (usb_endpoint_is_bulk_in(ep_desc)) {
 			rt2x00usb_assign_endpoint(rt2x00dev->rx, ep_desc);
-		} else if (usb_endpoint_is_bulk_out(ep_desc)) {
+		} else if (usb_endpoint_is_bulk_out(ep_desc) &&
+			   (queue !=3D queue_end(rt2x00dev))) {
 			rt2x00usb_assign_endpoint(queue, ep_desc);
+			queue =3D queue_next(queue);
=20
-			if (queue !=3D queue_end(rt2x00dev))
-				queue =3D queue_next(queue);
 			tx_ep_desc =3D ep_desc;
 		}
 	}
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wirele=
ss/rt2x00/rt73usb.c
index d638a8a..96a8d69 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2321,6 +2321,7 @@ static struct usb_device_id rt73usb_device_table[=
] =3D {
 	/* Linksys */
 	{ USB_DEVICE(0x13b1, 0x0020), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x13b1, 0x0023), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x13b1, 0x0028), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* MSI */
 	{ USB_DEVICE(0x0db0, 0x6877), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0db0, 0x6874), USB_DEVICE_DATA(&rt73usb_ops) },
diff --git a/drivers/net/wireless/rtl818x/rtl8180_dev.c b/drivers/net/w=
ireless/rtl818x/rtl8180_dev.c
index 5f887fb..387c133 100644
--- a/drivers/net/wireless/rtl818x/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180_dev.c
@@ -897,6 +897,7 @@ static int __devinit rtl8180_probe(struct pci_dev *=
pdev,
 	dev->flags =3D IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
 		     IEEE80211_HW_RX_INCLUDES_FCS |
 		     IEEE80211_HW_SIGNAL_UNSPEC;
+	dev->wiphy->interface_modes =3D BIT(NL80211_IFTYPE_STATION);
 	dev->queues =3D 1;
 	dev->max_signal =3D 65;
=20
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/w=
ireless/rtl818x/rtl8187_dev.c
index 00ce3ef..6ad6bac 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -213,7 +213,7 @@ static int rtl8187_tx(struct ieee80211_hw *dev, str=
uct sk_buff *skb)
 	urb =3D usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
 		kfree_skb(skb);
-		return -ENOMEM;
+		return NETDEV_TX_OK;
 	}
=20
 	flags =3D skb->len;
@@ -281,7 +281,7 @@ static int rtl8187_tx(struct ieee80211_hw *dev, str=
uct sk_buff *skb)
 	}
 	usb_free_urb(urb);
=20
-	return rc;
+	return NETDEV_TX_OK;
 }
=20
 static void rtl8187_rx_cb(struct urb *urb)
@@ -1471,6 +1471,7 @@ static void __devexit rtl8187_disconnect(struct u=
sb_interface *intf)
 	ieee80211_unregister_hw(dev);
=20
 	priv =3D dev->priv;
+	usb_reset_device(priv->udev);
 	usb_put_dev(interface_to_usbdev(intf));
 	ieee80211_free_hw(dev);
 }
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 5f510a1..c5c0c52 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -469,7 +469,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_=
hw *hw, u8 *ra, u16 tid)
 	struct ieee80211_sub_if_data *sdata;
 	u16 start_seq_num;
 	u8 *state;
-	int ret;
+	int ret =3D 0;
=20
 	if ((tid >=3D STA_TID_NUM) || !(hw->flags & IEEE80211_HW_AMPDU_AGGREG=
ATION))
 		return -EINVAL;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 5abbc3f..b907482 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -699,7 +699,8 @@ int ieee80211_if_change_type(struct ieee80211_sub_i=
f_data *sdata,
 		return 0;
=20
 	/* Setting ad-hoc mode on non-IBSS channel is not supported. */
-	if (sdata->local->oper_channel->flags & IEEE80211_CHAN_NO_IBSS)
+	if (sdata->local->oper_channel->flags & IEEE80211_CHAN_NO_IBSS &&
+	    type =3D=3D NL80211_IFTYPE_ADHOC)
 		return -EOPNOTSUPP;
=20
 	/*
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 929ba54..1159bdb 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -107,6 +107,7 @@ static struct sta_info *mesh_plink_alloc(struct iee=
e80211_sub_if_data *sdata,
=20
 	sta->flags =3D WLAN_STA_AUTHORIZED;
 	sta->sta.supp_rates[local->hw.conf.channel->band] =3D rates;
+	rate_control_rate_init(sta);
=20
 	return sta;
 }
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_min=
strel.c
index 2b3b490..3824990 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -395,13 +395,15 @@ minstrel_rate_init(void *priv, struct ieee80211_s=
upported_band *sband,
 {
 	struct minstrel_sta_info *mi =3D priv_sta;
 	struct minstrel_priv *mp =3D priv;
-	struct minstrel_rate *mr_ctl;
+	struct ieee80211_local *local =3D hw_to_local(mp->hw);
+	struct ieee80211_rate *ctl_rate;
 	unsigned int i, n =3D 0;
 	unsigned int t_slot =3D 9; /* FIXME: get real slot time */
=20
 	mi->lowest_rix =3D rate_lowest_index(sband, sta);
-	mr_ctl =3D &mi->r[rix_to_ndx(mi, mi->lowest_rix)];
-	mi->sp_ack_dur =3D mr_ctl->ack_time;
+	ctl_rate =3D &sband->bitrates[mi->lowest_rix];
+	mi->sp_ack_dur =3D ieee80211_frame_duration(local, 10, ctl_rate->bitr=
ate,
+				!!(ctl_rate->flags & IEEE80211_RATE_ERP_G), 1);
=20
 	for (i =3D 0; i < sband->n_bitrates; i++) {
 		struct minstrel_rate *mr =3D &mi->r[n];
@@ -416,7 +418,7 @@ minstrel_rate_init(void *priv, struct ieee80211_sup=
ported_band *sband,
=20
 		mr->rix =3D i;
 		mr->bitrate =3D sband->bitrates[i].bitrate / 5;
-		calc_rate_durations(mi, hw_to_local(mp->hw), mr,
+		calc_rate_durations(mi, local, mr,
 				&sband->bitrates[i]);
=20
 		/* calculate maximum number of retransmissions before
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
