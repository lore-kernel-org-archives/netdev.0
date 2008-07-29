From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-07-29
Date: Tue, 29 Jul 2008 17:34:47 -0400
Message-ID: <20080729213447.GB7443@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3151 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbYG3AYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 20:24:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

A rather large set of patches to fix some of the problems that have been
festering in Linus's tree for the last week or so...I apologize for my
absence while I dallied in sunny Ottawa...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 281c7413ed914623d3245299a4761b6b27ab9fdb:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andrew Morton (1):
      drivers/net/wireless/iwlwifi/iwl-led.c: printk fix

Bob Copeland (2):
      ath5k: use positive logic for HP laptop LEDs
      ath5k: fix recursive locking in ath5k_beacon_update

Brian Cavagnolo (1):
      libertas: check bounds and only use decimal for sysfs persistent features.

Denis V. Lunev (2):
      iwlwifi: compilation error when CONFIG_IWLWIFI_DEBUG is not set
      iwlwifi: small compile warnings without CONFIG_IWLWIFI_DEBUG

Harvey Harrison (1):
      mac80211: fix sparse integer as NULL pointer warning

Henrique de Moraes Holschuh (5):
      rfkill: document rfkill_force_state as required (v2)
      rfkill: fix led-trigger unregister order in error unwind
      rfkill: document the rfkill struct locking (v2)
      rfkill: mutex fixes
      rfkill: yet more minor kernel-doc fixes

Ivo van Doorn (6):
      rt2x00: Remove duplicate declaration
      rt2x00: Fix EIFS timing value
      rt2x00: Fix QOS sequence counting
      rt2x00: Fix memleak when RTS/CTS fails
      rt2x00: Force full register config after start()
      rt2x00: Clear queue entry flags during initialization

Iwo Mergler (3):
      rt2x00: Support for large vendor requests
      rt2x00: Large vendor requests for rt73usb firmware upload and beacons
      rt2x00: Fix the beacon length bug

Jeremy Fitzhardinge (1):
      mac80211: return correct error return from ieee80211_wep_init

Jiri Slaby (6):
      Ath5k: fix memory corruption
      Ath5k: kill tasklets on shutdown
      Ath5k: flush work
      Ath5k: fix dma operation
      Ath5k: suspend/resume fixes
      mac80211: tx, use dev_kfree_skb_any for beacon_get

Johannes Berg (4):
      mac80211: remove IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE flag
      mac80211: partially fix skb->cb use
      nl80211: fix dump callbacks
      mac80211: fix cfg80211 hooks for master interface

Julia Lawall (2):
      drivers/net/wireless/ipw2100.c: Release mutex in error handling code
      b43legacy: Release mutex in error handling code

Larry Finger (2):
      rtl8187: Fix for TX sequence number problem
      rtl8187: Improve wireless statistics for RTL8187B

Luis Carlos Cobo (1):
      mac80211: fix mesh beaconing

Pavel Roskin (1):
      ath5k: don't enable MSI, we cannot handle it yet

Rami Rosen (2):
      iwl-3945: add #ifdef CONFIG_IWL3945_LEDS to avoid compile warning.
      mac80211: append CONFIG_ to MAC80211_VERBOSE_PS_DEBUG in net/mac80211/tx.c.

Vegard Nossum (1):
      PS3: gelic: use unsigned long for irqflags

 Documentation/rfkill.txt                    |   20 ++-
 drivers/net/ps3_gelic_wireless.c            |   12 +-
 drivers/net/wireless/ath5k/base.c           |   99 ++++++----
 drivers/net/wireless/ath5k/base.h           |    2 +-
 drivers/net/wireless/ath5k/hw.c             |    4 +
 drivers/net/wireless/b43/main.c             |    3 +-
 drivers/net/wireless/b43/xmit.c             |    2 +-
 drivers/net/wireless/b43legacy/main.c       |    5 +-
 drivers/net/wireless/b43legacy/xmit.c       |    2 +-
 drivers/net/wireless/ipw2100.c              |    3 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-core.c     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h    |    8 +-
 drivers/net/wireless/iwlwifi/iwl-led.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    5 +-
 drivers/net/wireless/libertas/persistcfg.c  |   30 ++--
 drivers/net/wireless/mac80211_hwsim.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c     |   13 ++-
 drivers/net/wireless/rt2x00/rt2x00.h        |    6 +-
 drivers/net/wireless/rt2x00/rt2x00config.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    7 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    7 -
 drivers/net/wireless/rt2x00/rt2x00mac.c     |   29 ++--
 drivers/net/wireless/rt2x00/rt2x00queue.c   |   36 ++++-
 drivers/net/wireless/rt2x00/rt2x00queue.h   |    2 +
 drivers/net/wireless/rt2x00/rt2x00usb.c     |   32 +++
 drivers/net/wireless/rt2x00/rt2x00usb.h     |   22 ++-
 drivers/net/wireless/rt2x00/rt61pci.c       |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |   56 +++----
 drivers/net/wireless/rtl8187.h              |   11 +-
 drivers/net/wireless/rtl8187_dev.c          |   93 ++++++---
 drivers/net/wireless/zd1211rw/zd_mac.c      |    1 -
 include/linux/rfkill.h                      |    8 +-
 include/linux/skbuff.h                      |    5 +-
 include/net/mac80211.h                      |    7 -
 net/core/skbuff.c                           |    3 +
 net/mac80211/cfg.c                          |  103 +++++++++--
 net/mac80211/main.c                         |   12 +-
 net/mac80211/mlme.c                         |    9 +-
 net/mac80211/tx.c                           |   55 +++---
 net/mac80211/wep.c                          |    4 +-
 net/mac80211/wme.c                          |    3 +
 net/rfkill/rfkill.c                         |   62 ++++---
 net/wireless/nl80211.c                      |  277 +++++++++++++++------------
 46 files changed, 674 insertions(+), 405 deletions(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index 0843ed0..28b6ec8 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -390,9 +390,10 @@ rfkill lines are inactive, it must return RFKILL_STATE_SOFT_BLOCKED if its soft
 rfkill input line is active.  Only if none of the rfkill input lines are
 active, will it return RFKILL_STATE_UNBLOCKED.
 
-If it doesn't implement the get_state() hook, it must make sure that its calls
-to rfkill_force_state() are enough to keep the status always up-to-date, and it
-must do a rfkill_force_state() on resume from sleep.
+Since the device has a hardware rfkill line, it IS subject to state changes
+external to rfkill.  Therefore, the driver must make sure that it calls
+rfkill_force_state() to keep the status always up-to-date, and it must do a
+rfkill_force_state() on resume from sleep.
 
 Every time the driver gets a notification from the card that one of its rfkill
 lines changed state (polling might be needed on badly designed cards that don't
@@ -422,13 +423,24 @@ of the hardware is unknown), or read-write (where the hardware can be queried
 about its current state).
 
 The rfkill class will call the get_state hook of a device every time it needs
-to know the *real* current state of the hardware.  This can happen often.
+to know the *real* current state of the hardware.  This can happen often, but
+it does not do any polling, so it is not enough on hardware that is subject
+to state changes outside of the rfkill subsystem.
+
+Therefore, calling rfkill_force_state() when a state change happens is
+mandatory when the device has a hardware rfkill line, or when something else
+like the firmware could cause its state to be changed without going through the
+rfkill class.
 
 Some hardware provides events when its status changes.  In these cases, it is
 best for the driver to not provide a get_state hook, and instead register the
 rfkill class *already* with the correct status, and keep it updated using
 rfkill_force_state() when it gets an event from the hardware.
 
+rfkill_force_state() must be used on the device resume handlers to update the
+rfkill status, should there be any chance of the device status changing during
+the sleep.
+
 There is no provision for a statically-allocated rfkill struct.  You must
 use rfkill_allocate() to allocate one.
 
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index 6b2dee0..a834b52 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -1024,7 +1024,7 @@ static int gelic_wl_set_encode(struct net_device *netdev,
 	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
 	struct iw_point *enc = &data->encoding;
 	__u16 flags;
-	unsigned int irqflag;
+	unsigned long irqflag;
 	int key_index, index_specified;
 	int ret = 0;
 
@@ -1097,7 +1097,7 @@ static int gelic_wl_get_encode(struct net_device *netdev,
 {
 	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
 	struct iw_point *enc = &data->encoding;
-	unsigned int irqflag;
+	unsigned long irqflag;
 	unsigned int key_index, index_specified;
 	int ret = 0;
 
@@ -1215,7 +1215,7 @@ static int gelic_wl_set_encodeext(struct net_device *netdev,
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	__u16 alg;
 	__u16 flags;
-	unsigned int irqflag;
+	unsigned long irqflag;
 	int key_index;
 	int ret = 0;
 
@@ -1303,7 +1303,7 @@ static int gelic_wl_get_encodeext(struct net_device *netdev,
 	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
 	struct iw_point *enc = &data->encoding;
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
-	unsigned int irqflag;
+	unsigned long irqflag;
 	int key_index;
 	int ret = 0;
 	int max_key_len;
@@ -1426,7 +1426,7 @@ static int gelic_wl_priv_set_psk(struct net_device *net_dev,
 {
 	struct gelic_wl_info *wl = port_wl(netdev_priv(net_dev));
 	unsigned int len;
-	unsigned int irqflag;
+	unsigned long irqflag;
 	int ret = 0;
 
 	pr_debug("%s:<- len=%d\n", __func__, data->data.length);
@@ -1467,7 +1467,7 @@ static int gelic_wl_priv_get_psk(struct net_device *net_dev,
 {
 	struct gelic_wl_info *wl = port_wl(netdev_priv(net_dev));
 	char *p;
-	unsigned int irqflag;
+	unsigned long irqflag;
 	unsigned int i;
 
 	pr_debug("%s:<-\n", __func__);
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index d9769c5..ff3fad7 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -43,7 +43,9 @@
 #include <linux/version.h>
 #include <linux/module.h>
 #include <linux/delay.h>
+#include <linux/hardirq.h>
 #include <linux/if.h>
+#include <linux/io.h>
 #include <linux/netdevice.h>
 #include <linux/cache.h>
 #include <linux/pci.h>
@@ -471,9 +473,6 @@ ath5k_pci_probe(struct pci_dev *pdev,
 	/* Set private data */
 	pci_set_drvdata(pdev, hw);
 
-	/* Enable msi for devices that support it */
-	pci_enable_msi(pdev);
-
 	/* Setup interrupt handler */
 	ret = request_irq(pdev->irq, ath5k_intr, IRQF_SHARED, "ath", sc);
 	if (ret) {
@@ -551,7 +550,6 @@ err_ah:
 err_irq:
 	free_irq(pdev->irq, sc);
 err_free:
-	pci_disable_msi(pdev);
 	ieee80211_free_hw(hw);
 err_map:
 	pci_iounmap(pdev, mem);
@@ -573,7 +571,6 @@ ath5k_pci_remove(struct pci_dev *pdev)
 	ath5k_detach(pdev, hw);
 	ath5k_hw_detach(sc->ah);
 	free_irq(pdev->irq, sc);
-	pci_disable_msi(pdev);
 	pci_iounmap(pdev, sc->iobase);
 	pci_release_region(pdev, 0);
 	pci_disable_device(pdev);
@@ -590,6 +587,9 @@ ath5k_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	ath5k_led_off(sc);
 
 	ath5k_stop_hw(sc);
+
+	free_irq(pdev->irq, sc);
+	pci_disable_msi(pdev);
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
@@ -605,15 +605,12 @@ ath5k_pci_resume(struct pci_dev *pdev)
 	struct ath5k_hw *ah = sc->ah;
 	int i, err;
 
-	err = pci_set_power_state(pdev, PCI_D0);
-	if (err)
-		return err;
+	pci_restore_state(pdev);
 
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
 
-	pci_restore_state(pdev);
 	/*
 	 * Suspend/Resume resets the PCI configuration space, so we have to
 	 * re-disable the RETRY_TIMEOUT register (0x41) to keep
@@ -621,7 +618,17 @@ ath5k_pci_resume(struct pci_dev *pdev)
 	 */
 	pci_write_config_byte(pdev, 0x41, 0);
 
-	ath5k_init(sc);
+	pci_enable_msi(pdev);
+
+	err = request_irq(pdev->irq, ath5k_intr, IRQF_SHARED, "ath", sc);
+	if (err) {
+		ATH5K_ERR(sc, "request_irq failed\n");
+		goto err_msi;
+	}
+
+	err = ath5k_init(sc);
+	if (err)
+		goto err_irq;
 	ath5k_led_enable(sc);
 
 	/*
@@ -635,6 +642,12 @@ ath5k_pci_resume(struct pci_dev *pdev)
 		ath5k_hw_reset_key(ah, i);
 
 	return 0;
+err_irq:
+	free_irq(pdev->irq, sc);
+err_msi:
+	pci_disable_msi(pdev);
+	pci_disable_device(pdev);
+	return err;
 }
 #endif /* CONFIG_PM */
 
@@ -1224,7 +1237,7 @@ ath5k_txbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 
 	pktlen = skb->len;
 
-	if (!(info->flags & IEEE80211_TX_CTL_DO_NOT_ENCRYPT)) {
+	if (info->control.hw_key) {
 		keyidx = info->control.hw_key->hw_key_idx;
 		pktlen += info->control.icv_len;
 	}
@@ -1249,6 +1262,7 @@ ath5k_txbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 
 	txq->link = &ds->ds_link;
 	ath5k_hw_tx_start(ah, txq->qnum);
+	mmiowb();
 	spin_unlock_bh(&txq->lock);
 
 	return 0;
@@ -1583,7 +1597,6 @@ ath5k_rx_stop(struct ath5k_softc *sc)
 	ath5k_hw_stop_pcu_recv(ah);	/* disable PCU */
 	ath5k_hw_set_rx_filter(ah, 0);	/* clear recv filter */
 	ath5k_hw_stop_rx_dma(ah);	/* disable DMA engine */
-	mdelay(3);			/* 3ms is long enough for 1 frame */
 
 	ath5k_debug_printrxbuffs(sc, ah);
 
@@ -1682,31 +1695,44 @@ ath5k_tasklet_rx(unsigned long data)
 	struct ath5k_rx_status rs = {};
 	struct sk_buff *skb;
 	struct ath5k_softc *sc = (void *)data;
-	struct ath5k_buf *bf;
+	struct ath5k_buf *bf, *bf_last;
 	struct ath5k_desc *ds;
 	int ret;
 	int hdrlen;
 	int pad;
 
 	spin_lock(&sc->rxbuflock);
+	if (list_empty(&sc->rxbuf)) {
+		ATH5K_WARN(sc, "empty rx buf pool\n");
+		goto unlock;
+	}
+	bf_last = list_entry(sc->rxbuf.prev, struct ath5k_buf, list);
 	do {
 		rxs.flag = 0;
 
-		if (unlikely(list_empty(&sc->rxbuf))) {
-			ATH5K_WARN(sc, "empty rx buf pool\n");
-			break;
-		}
 		bf = list_first_entry(&sc->rxbuf, struct ath5k_buf, list);
 		BUG_ON(bf->skb == NULL);
 		skb = bf->skb;
 		ds = bf->desc;
 
-		/* TODO only one segment */
-		pci_dma_sync_single_for_cpu(sc->pdev, sc->desc_daddr,
-				sc->desc_len, PCI_DMA_FROMDEVICE);
-
-		if (unlikely(ds->ds_link == bf->daddr)) /* this is the end */
-			break;
+		/*
+		 * last buffer must not be freed to ensure proper hardware
+		 * function. When the hardware finishes also a packet next to
+		 * it, we are sure, it doesn't use it anymore and we can go on.
+		 */
+		if (bf_last == bf)
+			bf->flags |= 1;
+		if (bf->flags) {
+			struct ath5k_buf *bf_next = list_entry(bf->list.next,
+					struct ath5k_buf, list);
+			ret = sc->ah->ah_proc_rx_desc(sc->ah, bf_next->desc,
+					&rs);
+			if (ret)
+				break;
+			bf->flags &= ~1;
+			/* skip the overwritten one (even status is martian) */
+			goto next;
+		}
 
 		ret = sc->ah->ah_proc_rx_desc(sc->ah, ds, &rs);
 		if (unlikely(ret == -EINPROGRESS))
@@ -1752,8 +1778,6 @@ ath5k_tasklet_rx(unsigned long data)
 				goto next;
 		}
 accept:
-		pci_dma_sync_single_for_cpu(sc->pdev, bf->skbaddr,
-				rs.rs_datalen, PCI_DMA_FROMDEVICE);
 		pci_unmap_single(sc->pdev, bf->skbaddr, sc->rxbufsize,
 				PCI_DMA_FROMDEVICE);
 		bf->skb = NULL;
@@ -1816,6 +1840,7 @@ accept:
 next:
 		list_move_tail(&bf->list, &sc->rxbuf);
 	} while (ath5k_rxbuf_setup(sc, bf) == 0);
+unlock:
 	spin_unlock(&sc->rxbuflock);
 }
 
@@ -1840,9 +1865,6 @@ ath5k_tx_processq(struct ath5k_softc *sc, struct ath5k_txq *txq)
 	list_for_each_entry_safe(bf, bf0, &txq->q, list) {
 		ds = bf->desc;
 
-		/* TODO only one segment */
-		pci_dma_sync_single_for_cpu(sc->pdev, sc->desc_daddr,
-				sc->desc_len, PCI_DMA_FROMDEVICE);
 		ret = sc->ah->ah_proc_tx_desc(sc->ah, ds, &ts);
 		if (unlikely(ret == -EINPROGRESS))
 			break;
@@ -2015,8 +2037,6 @@ ath5k_beacon_send(struct ath5k_softc *sc)
 		ATH5K_WARN(sc, "beacon queue %u didn't stop?\n", sc->bhalq);
 		/* NB: hw still stops DMA, so proceed */
 	}
-	pci_dma_sync_single_for_cpu(sc->pdev, bf->skbaddr, bf->skb->len,
-			PCI_DMA_TODEVICE);
 
 	ath5k_hw_put_tx_buf(ah, sc->bhalq, bf->daddr);
 	ath5k_hw_tx_start(ah, sc->bhalq);
@@ -2240,6 +2260,7 @@ ath5k_init(struct ath5k_softc *sc)
 
 	ret = 0;
 done:
+	mmiowb();
 	mutex_unlock(&sc->lock);
 	return ret;
 }
@@ -2272,6 +2293,7 @@ ath5k_stop_locked(struct ath5k_softc *sc)
 	if (!test_bit(ATH_STAT_INVALID, sc->status)) {
 		ath5k_led_off(sc);
 		ath5k_hw_set_intr(ah, 0);
+		synchronize_irq(sc->pdev->irq);
 	}
 	ath5k_txq_cleanup(sc);
 	if (!test_bit(ATH_STAT_INVALID, sc->status)) {
@@ -2321,9 +2343,13 @@ ath5k_stop_hw(struct ath5k_softc *sc)
 		}
 	}
 	ath5k_txbuf_free(sc, sc->bbuf);
+	mmiowb();
 	mutex_unlock(&sc->lock);
 
 	del_timer_sync(&sc->calib_tim);
+	tasklet_kill(&sc->rxtq);
+	tasklet_kill(&sc->txtq);
+	tasklet_kill(&sc->restq);
 
 	return ret;
 }
@@ -2550,8 +2576,6 @@ ath5k_init_leds(struct ath5k_softc *sc)
 	struct pci_dev *pdev = sc->pdev;
 	char name[ATH5K_LED_MAX_NAME_LEN + 1];
 
-	sc->led_on = 0;  /* active low */
-
 	/*
 	 * Auto-enable soft led processing for IBM cards and for
 	 * 5211 minipci cards.
@@ -2560,11 +2584,13 @@ ath5k_init_leds(struct ath5k_softc *sc)
 	    pdev->device == PCI_DEVICE_ID_ATHEROS_AR5211) {
 		__set_bit(ATH_STAT_LEDSOFT, sc->status);
 		sc->led_pin = 0;
+		sc->led_on = 0;  /* active low */
 	}
 	/* Enable softled on PIN1 on HP Compaq nc6xx, nc4000 & nx5000 laptops */
 	if (pdev->subsystem_vendor == PCI_VENDOR_ID_COMPAQ) {
 		__set_bit(ATH_STAT_LEDSOFT, sc->status);
 		sc->led_pin = 1;
+		sc->led_on = 1;  /* active high */
 	}
 	if (!test_bit(ATH_STAT_LEDSOFT, sc->status))
 		goto out;
@@ -2783,6 +2809,7 @@ ath5k_config_interface(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 		/* XXX: assoc id is set to 0 for now, mac80211 doesn't have
 		 * a clean way of letting us retrieve this yet. */
 		ath5k_hw_set_associd(ah, ah->ah_bssid, 0);
+		mmiowb();
 	}
 
 	if (conf->changed & IEEE80211_IFCC_BEACON &&
@@ -2971,6 +2998,7 @@ ath5k_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	}
 
 unlock:
+	mmiowb();
 	mutex_unlock(&sc->lock);
 	return ret;
 }
@@ -3032,8 +3060,6 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb)
 
 	ath5k_debug_dump_skb(sc, skb, "BC  ", 1);
 
-	mutex_lock(&sc->lock);
-
 	if (sc->opmode != IEEE80211_IF_TYPE_IBSS) {
 		ret = -EIO;
 		goto end;
@@ -3044,11 +3070,12 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb)
 	ret = ath5k_beacon_setup(sc, sc->bbuf);
 	if (ret)
 		sc->bbuf->skb = NULL;
-	else
+	else {
 		ath5k_beacon_config(sc);
+		mmiowb();
+	}
 
 end:
-	mutex_unlock(&sc->lock);
 	return ret;
 }
 
diff --git a/drivers/net/wireless/ath5k/base.h b/drivers/net/wireless/ath5k/base.h
index 47f414b..d7e03e6 100644
--- a/drivers/net/wireless/ath5k/base.h
+++ b/drivers/net/wireless/ath5k/base.h
@@ -56,7 +56,7 @@
 
 struct ath5k_buf {
 	struct list_head	list;
-	unsigned int		flags;	/* tx descriptor flags */
+	unsigned int		flags;	/* rx descriptor flags */
 	struct ath5k_desc	*desc;	/* virtual addr of desc */
 	dma_addr_t		daddr;	/* physical addr of desc */
 	struct sk_buff		*skb;	/* skbuff for buf */
diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index c6d12c5..7ca87a5 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -1440,6 +1440,7 @@ int ath5k_hw_stop_tx_dma(struct ath5k_hw *ah, unsigned int queue)
 
 		/* Stop queue */
 		ath5k_hw_reg_write(ah, tx_queue, AR5K_CR);
+		ath5k_hw_reg_read(ah, AR5K_CR);
 	} else {
 		/*
 		 * Schedule TX disable and wait until queue is empty
@@ -1456,6 +1457,8 @@ int ath5k_hw_stop_tx_dma(struct ath5k_hw *ah, unsigned int queue)
 
 		/* Clear register */
 		ath5k_hw_reg_write(ah, 0, AR5K_QCU_TXD);
+		if (pending)
+			return -EBUSY;
 	}
 
 	/* TODO: Check for success else return error */
@@ -1716,6 +1719,7 @@ enum ath5k_int ath5k_hw_set_intr(struct ath5k_hw *ah, enum ath5k_int new_mask)
 
 	/* ..re-enable interrupts */
 	ath5k_hw_reg_write(ah, AR5K_IER_ENABLE, AR5K_IER);
+	ath5k_hw_reg_read(ah, AR5K_IER);
 
 	return old_mask;
 }
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index e78319a..3bf3a86 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4645,8 +4645,7 @@ static int b43_wireless_init(struct ssb_device *dev)
 	}
 
 	/* fill hw info */
-	hw->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
-		    IEEE80211_HW_RX_INCLUDES_FCS |
+	hw->flags = IEEE80211_HW_RX_INCLUDES_FCS |
 		    IEEE80211_HW_SIGNAL_DBM |
 		    IEEE80211_HW_NOISE_DBM;
 
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmit.c
index 8d54502..9dda816 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -192,7 +192,7 @@ int b43_generate_txhdr(struct b43_wldev *dev,
 	const struct b43_phy *phy = &dev->phy;
 	const struct ieee80211_hdr *wlhdr =
 	    (const struct ieee80211_hdr *)fragment_data;
-	int use_encryption = (!(info->flags & IEEE80211_TX_CTL_DO_NOT_ENCRYPT));
+	int use_encryption = !!info->control.hw_key;
 	__le16 fctl = wlhdr->frame_control;
 	struct ieee80211_rate *fbrate;
 	u8 rate, rate_fb;
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index a1b8bf3..2541c81 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -3702,8 +3702,7 @@ static int b43legacy_wireless_init(struct ssb_device *dev)
 	}
 
 	/* fill hw info */
-	hw->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
-		    IEEE80211_HW_RX_INCLUDES_FCS |
+	hw->flags = IEEE80211_HW_RX_INCLUDES_FCS |
 		    IEEE80211_HW_SIGNAL_DBM |
 		    IEEE80211_HW_NOISE_DBM;
 	hw->queues = 1; /* FIXME: hardware has more queues */
@@ -3846,10 +3845,10 @@ static int b43legacy_resume(struct ssb_device *dev)
 			goto out;
 		}
 	}
-	mutex_unlock(&wl->mutex);
 
 	b43legacydbg(wl, "Device resumed.\n");
 out:
+	mutex_unlock(&wl->mutex);
 	return err;
 }
 
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wireless/b43legacy/xmit.c
index e969ed8..68e1f8c 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -192,7 +192,7 @@ static int generate_txhdr_fw3(struct b43legacy_wldev *dev,
 			       u16 cookie)
 {
 	const struct ieee80211_hdr *wlhdr;
-	int use_encryption = (!(info->flags & IEEE80211_TX_CTL_DO_NOT_ENCRYPT));
+	int use_encryption = !!info->control.hw_key;
 	u16 fctl;
 	u8 rate;
 	struct ieee80211_rate *rate_fb;
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 5bf9e00..c6f886e 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6442,6 +6442,7 @@ static int ipw2100_resume(struct pci_dev *pci_dev)
 	if (err) {
 		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
 		       dev->name);
+		mutex_unlock(&priv->action_mutex);
 		return err;
 	}
 	pci_restore_state(pci_dev);
@@ -7146,7 +7147,7 @@ static int ipw2100_wx_get_rate(struct net_device *dev,
 	err = ipw2100_get_ordinal(priv, IPW_ORD_CURRENT_TX_RATE, &val, &len);
 	if (err) {
 		IPW_DEBUG_WX("failed querying ordinals.\n");
-		return err;
+		goto done;
 	}
 
 	switch (val & TX_RATE_MASK) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index c2a7678..a51e0ea 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -630,7 +630,9 @@ static void iwl3945_pass_packet_to_mac80211(struct iwl3945_priv *priv,
 				   struct ieee80211_rx_status *stats)
 {
 	struct iwl3945_rx_packet *pkt = (struct iwl3945_rx_packet *)rxb->skb->data;
+#ifdef CONFIG_IWL3945_LEDS
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)IWL_RX_DATA(pkt);
+#endif
 	struct iwl3945_rx_frame_hdr *rx_hdr = IWL_RX_HDR(pkt);
 	struct iwl3945_rx_frame_end *rx_end = IWL_RX_END(pkt);
 	short len = le16_to_cpu(rx_hdr->len);
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index a44188b..e3427c2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -818,8 +818,7 @@ int iwl_setup_mac(struct iwl_priv *priv)
 	hw->rate_control_algorithm = "iwl-4965-rs";
 
 	/* Tell mac80211 our characteristics */
-	hw->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
-		    IEEE80211_HW_SIGNAL_DBM |
+	hw->flags = IEEE80211_HW_SIGNAL_DBM |
 		    IEEE80211_HW_NOISE_DBM;
 	/* Default value; 4 EDCA QOS priorities */
 	hw->queues = 4;
diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wireless/iwlwifi/iwl-debug.h
index 5838480..d6d729e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-debug.h
@@ -68,12 +68,8 @@ void iwl_dbgfs_unregister(struct iwl_priv *priv);
 #endif
 
 #else
-static inline void IWL_DEBUG(int level, const char *fmt, ...)
-{
-}
-static inline void IWL_DEBUG_LIMIT(int level, const char *fmt, ...)
-{
-}
+#define IWL_DEBUG(level, fmt, args...)
+#define IWL_DEBUG_LIMIT(level, fmt, args...)
 #endif				/* CONFIG_IWLWIFI_DEBUG */
 
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-led.c b/drivers/net/wireless/iwlwifi/iwl-led.c
index 899d7a2..61250e6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-led.c
+++ b/drivers/net/wireless/iwlwifi/iwl-led.c
@@ -268,7 +268,9 @@ static int iwl_get_blink_rate(struct iwl_priv *priv)
 	if (tpt < 0) /* wrapparound */
 		tpt = -tpt;
 
-	IWL_DEBUG_LED("tpt %lld current_tpt %lld\n", tpt, current_tpt);
+	IWL_DEBUG_LED("tpt %lld current_tpt %llu\n",
+		(long long)tpt,
+		(unsigned long long)current_tpt);
 	priv->led_tpt = current_tpt;
 
 	if (!priv->allow_blinking)
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index efc750d..5a00ac2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -270,6 +270,7 @@ static void iwl_rx_scan_results_notif(struct iwl_priv *priv,
 static void iwl_rx_scan_complete_notif(struct iwl_priv *priv,
 				       struct iwl_rx_mem_buffer *rxb)
 {
+#ifdef CONFIG_IWLWIFI_DEBUG
 	struct iwl_rx_packet *pkt = (struct iwl_rx_packet *)rxb->skb->data;
 	struct iwl_scancomplete_notification *scan_notif = (void *)pkt->u.raw;
 
@@ -277,6 +278,7 @@ static void iwl_rx_scan_complete_notif(struct iwl_priv *priv,
 		       scan_notif->scanned_channels,
 		       scan_notif->tsf_low,
 		       scan_notif->tsf_high, scan_notif->status);
+#endif
 
 	/* The HW is no longer scanning */
 	clear_bit(STATUS_SCAN_HW, &priv->status);
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 9b50b10..f72cd0b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -906,7 +906,7 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	 * first entry */
 	iwl_hw_txq_attach_buf_to_tfd(priv, tfd, txcmd_phys, len);
 
-	if (!(info->flags & IEEE80211_TX_CTL_DO_NOT_ENCRYPT))
+	if (info->control.hw_key)
 		iwl_tx_cmd_build_hwcrypto(priv, info, tx_cmd, skb, sta_id);
 
 	/* Set up TFD's 2nd entry to point directly to remainder of skb,
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4a22d3f..7c82ecf 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -2667,7 +2667,7 @@ static int iwl3945_tx_skb(struct iwl3945_priv *priv, struct sk_buff *skb)
 	 * first entry */
 	iwl3945_hw_txq_attach_buf_to_tfd(priv, tfd, txcmd_phys, len);
 
-	if (!(info->flags & IEEE80211_TX_CTL_DO_NOT_ENCRYPT))
+	if (info->control.hw_key)
 		iwl3945_build_tx_cmd_hwcrypto(priv, info, out_cmd, skb, 0);
 
 	/* Set up TFD's 2nd entry to point directly to remainder of skb,
@@ -7899,8 +7899,7 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	priv->ibss_beacon = NULL;
 
 	/* Tell mac80211 our characteristics */
-	hw->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
-		    IEEE80211_HW_SIGNAL_DBM |
+	hw->flags = IEEE80211_HW_SIGNAL_DBM |
 		    IEEE80211_HW_NOISE_DBM;
 
 	/* 4 EDCA QOS priorities */
diff --git a/drivers/net/wireless/libertas/persistcfg.c b/drivers/net/wireless/libertas/persistcfg.c
index 6d0ff8d..3309a9c 100644
--- a/drivers/net/wireless/libertas/persistcfg.c
+++ b/drivers/net/wireless/libertas/persistcfg.c
@@ -48,7 +48,7 @@ static ssize_t bootflag_get(struct device *dev,
 	if (ret)
 		return ret;
 
-	return snprintf(buf, 12, "0x%x\n", le32_to_cpu(defs.bootflag));
+	return snprintf(buf, 12, "%d\n", le32_to_cpu(defs.bootflag));
 }
 
 /**
@@ -63,8 +63,8 @@ static ssize_t bootflag_set(struct device *dev, struct device_attribute *attr,
 	int ret;
 
 	memset(&cmd, 0, sizeof(cmd));
-	ret = sscanf(buf, "%x", &datum);
-	if (ret != 1)
+	ret = sscanf(buf, "%d", &datum);
+	if ((ret != 1) || (datum > 1))
 		return -EINVAL;
 
 	*((__le32 *)&cmd.data[0]) = cpu_to_le32(!!datum);
@@ -91,7 +91,7 @@ static ssize_t boottime_get(struct device *dev,
 	if (ret)
 		return ret;
 
-	return snprintf(buf, 12, "0x%x\n", defs.boottime);
+	return snprintf(buf, 12, "%d\n", defs.boottime);
 }
 
 /**
@@ -106,8 +106,8 @@ static ssize_t boottime_set(struct device *dev,
 	int ret;
 
 	memset(&cmd, 0, sizeof(cmd));
-	ret = sscanf(buf, "%x", &datum);
-	if (ret != 1)
+	ret = sscanf(buf, "%d", &datum);
+	if ((ret != 1) || (datum > 255))
 		return -EINVAL;
 
 	/* A too small boot time will result in the device booting into
@@ -143,7 +143,7 @@ static ssize_t channel_get(struct device *dev,
 	if (ret)
 		return ret;
 
-	return snprintf(buf, 12, "0x%x\n", le16_to_cpu(defs.channel));
+	return snprintf(buf, 12, "%d\n", le16_to_cpu(defs.channel));
 }
 
 /**
@@ -154,11 +154,11 @@ static ssize_t channel_set(struct device *dev, struct device_attribute *attr,
 {
 	struct lbs_private *priv = to_net_dev(dev)->priv;
 	struct cmd_ds_mesh_config cmd;
-	uint16_t datum;
+	uint32_t datum;
 	int ret;
 
 	memset(&cmd, 0, sizeof(cmd));
-	ret = sscanf(buf, "%hx", &datum);
+	ret = sscanf(buf, "%d", &datum);
 	if (ret != 1 || datum < 1 || datum > 11)
 		return -EINVAL;
 
@@ -274,8 +274,8 @@ static ssize_t protocol_id_set(struct device *dev,
 	int ret;
 
 	memset(&cmd, 0, sizeof(cmd));
-	ret = sscanf(buf, "%x", &datum);
-	if (ret != 1)
+	ret = sscanf(buf, "%d", &datum);
+	if ((ret != 1) || (datum > 255))
 		return -EINVAL;
 
 	/* fetch all other Information Element parameters */
@@ -328,8 +328,8 @@ static ssize_t metric_id_set(struct device *dev, struct device_attribute *attr,
 	int ret;
 
 	memset(&cmd, 0, sizeof(cmd));
-	ret = sscanf(buf, "%x", &datum);
-	if (ret != 1)
+	ret = sscanf(buf, "%d", &datum);
+	if ((ret != 1) || (datum > 255))
 		return -EINVAL;
 
 	/* fetch all other Information Element parameters */
@@ -382,8 +382,8 @@ static ssize_t capability_set(struct device *dev, struct device_attribute *attr,
 	int ret;
 
 	memset(&cmd, 0, sizeof(cmd));
-	ret = sscanf(buf, "%x", &datum);
-	if (ret != 1)
+	ret = sscanf(buf, "%d", &datum);
+	if ((ret != 1) || (datum > 255))
 		return -EINVAL;
 
 	/* fetch all other Information Element parameters */
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 5816230..248d31a 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -500,7 +500,7 @@ failed_hw:
 	device_unregister(data->dev);
 failed_drvdata:
 	ieee80211_free_hw(hw);
-	hwsim_radios[i] = 0;
+	hwsim_radios[i] = NULL;
 failed:
 	mac80211_hwsim_free();
 	return err;
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 3558cb2..3078417 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1121,6 +1121,7 @@ static void rt2500usb_write_beacon(struct queue_entry *entry)
 	int pipe = usb_sndbulkpipe(usb_dev, 1);
 	int length;
 	u16 reg;
+	u32 word, len;
 
 	/*
 	 * Add the descriptor in front of the skb.
@@ -1130,6 +1131,17 @@ static void rt2500usb_write_beacon(struct queue_entry *entry)
 	skbdesc->desc = entry->skb->data;
 
 	/*
+	 * Adjust the beacon databyte count. The current number is
+	 * calculated before this function gets called, but falsely
+	 * assumes that the descriptor was already present in the SKB.
+	 */
+	rt2x00_desc_read(skbdesc->desc, 0, &word);
+	len  = rt2x00_get_field32(word, TXD_W0_DATABYTE_COUNT);
+	len += skbdesc->desc_len;
+	rt2x00_set_field32(&word, TXD_W0_DATABYTE_COUNT, len);
+	rt2x00_desc_write(skbdesc->desc, 0, word);
+
+	/*
 	 * Disable beaconing while we are reloading the beacon data,
 	 * otherwise we might be sending out invalid data.
 	 */
@@ -1650,7 +1662,6 @@ static void rt2500usb_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	 * Initialize all hw fields.
 	 */
 	rt2x00dev->hw->flags =
-	    IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
 	    IEEE80211_HW_RX_INCLUDES_FCS |
 	    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
 	    IEEE80211_HW_SIGNAL_DBM;
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 07b03b3..db2dc97 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -108,7 +108,10 @@
 #define SHORT_PIFS		( SIFS + SHORT_SLOT_TIME )
 #define DIFS			( PIFS + SLOT_TIME )
 #define SHORT_DIFS		( SHORT_PIFS + SHORT_SLOT_TIME )
-#define EIFS			( SIFS + (8 * (IEEE80211_HEADER + ACK_SIZE)) )
+#define EIFS			( SIFS + DIFS + \
+				  (8 * (IEEE80211_HEADER + ACK_SIZE)) )
+#define SHORT_EIFS		( SIFS + SHORT_DIFS + \
+				  (8 * (IEEE80211_HEADER + ACK_SIZE)) )
 
 /*
  * Chipset identification
@@ -597,6 +600,7 @@ enum rt2x00_flags {
 	DEVICE_STARTED_SUSPEND,
 	DEVICE_ENABLED_RADIO,
 	DEVICE_DISABLED_RADIO_HW,
+	DEVICE_DIRTY_CONFIG,
 
 	/*
 	 * Driver features
diff --git a/drivers/net/wireless/rt2x00/rt2x00config.c b/drivers/net/wireless/rt2x00/rt2x00config.c
index f20ca71..3f89516 100644
--- a/drivers/net/wireless/rt2x00/rt2x00config.c
+++ b/drivers/net/wireless/rt2x00/rt2x00config.c
@@ -271,7 +271,7 @@ config:
 		libconf.sifs = SIFS;
 		libconf.pifs = short_slot_time ? SHORT_PIFS : PIFS;
 		libconf.difs = short_slot_time ? SHORT_DIFS : DIFS;
-		libconf.eifs = EIFS;
+		libconf.eifs = short_slot_time ? SHORT_EIFS : EIFS;
 	}
 
 	libconf.conf = conf;
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 8c93eb8..f42283a 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1013,6 +1013,7 @@ int rt2x00lib_start(struct rt2x00_dev *rt2x00dev)
 	rt2x00dev->intf_associated = 0;
 
 	__set_bit(DEVICE_STARTED, &rt2x00dev->flags);
+	__set_bit(DEVICE_DIRTY_CONFIG, &rt2x00dev->flags);
 
 	return 0;
 }
@@ -1237,9 +1238,9 @@ int rt2x00lib_resume(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Reconfigure device.
 	 */
-	rt2x00lib_config(rt2x00dev, &rt2x00dev->hw->conf, 1);
-	if (!rt2x00dev->hw->conf.radio_enabled)
-		rt2x00lib_disable_radio(rt2x00dev);
+	retval = rt2x00mac_config(rt2x00dev->hw, &rt2x00dev->hw->conf);
+	if (retval)
+		goto exit;
 
 	/*
 	 * Iterator over each active interface to
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless/rt2x00/rt2x00lib.h
index f2c9b0e..c5fb3a7 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -125,13 +125,6 @@ void rt2x00queue_unmap_skb(struct rt2x00_dev *rt2x00dev, struct sk_buff *skb);
 void rt2x00queue_free_skb(struct rt2x00_dev *rt2x00dev, struct sk_buff *skb);
 
 /**
- * rt2x00queue_free_skb - free a skb
- * @rt2x00dev: Pointer to &struct rt2x00_dev.
- * @skb: The skb to free.
- */
-void rt2x00queue_free_skb(struct rt2x00_dev *rt2x00dev, struct sk_buff *skb);
-
-/**
  * rt2x00queue_write_tx_frame - Write TX frame to hardware
  * @queue: Queue over which the frame should be send
  * @skb: The skb to send
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index f1dcbaa..c3ee4ec 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -63,7 +63,7 @@ static int rt2x00mac_tx_rts_cts(struct rt2x00_dev *rt2x00dev,
 	 */
 	memcpy(skb->cb, frag_skb->cb, sizeof(skb->cb));
 	rts_info = IEEE80211_SKB_CB(skb);
-	rts_info->flags |= IEEE80211_TX_CTL_DO_NOT_ENCRYPT;
+	rts_info->control.hw_key = NULL;
 	rts_info->flags &= ~IEEE80211_TX_CTL_USE_RTS_CTS;
 	rts_info->flags &= ~IEEE80211_TX_CTL_USE_CTS_PROTECT;
 	rts_info->flags &= ~IEEE80211_TX_CTL_REQ_TX_STATUS;
@@ -83,6 +83,7 @@ static int rt2x00mac_tx_rts_cts(struct rt2x00_dev *rt2x00dev,
 				  (struct ieee80211_rts *)(skb->data));
 
 	if (rt2x00queue_write_tx_frame(queue, skb)) {
+		dev_kfree_skb_any(skb);
 		WARNING(rt2x00dev, "Failed to send RTS/CTS frame.\n");
 		return NETDEV_TX_BUSY;
 	}
@@ -96,7 +97,6 @@ int rt2x00mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr *)skb->data;
 	enum data_queue_qid qid = skb_get_queue_mapping(skb);
-	struct rt2x00_intf *intf = vif_to_intf(tx_info->control.vif);
 	struct data_queue *queue;
 	u16 frame_control;
 
@@ -152,18 +152,6 @@ int rt2x00mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 		}
 	}
 
-	/*
-	 * XXX: This is as wrong as the old mac80211 code was,
-	 *	due to beacons not getting sequence numbers assigned
-	 *	properly.
-	 */
-	if (tx_info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
-		if (tx_info->flags & IEEE80211_TX_CTL_FIRST_FRAGMENT)
-			intf->seqno += 0x10;
-		ieee80211hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
-		ieee80211hdr->seq_ctrl |= cpu_to_le16(intf->seqno);
-	}
-
 	if (rt2x00queue_write_tx_frame(queue, skb)) {
 		ieee80211_stop_queue(rt2x00dev->hw, qid);
 		return NETDEV_TX_BUSY;
@@ -322,6 +310,7 @@ EXPORT_SYMBOL_GPL(rt2x00mac_remove_interface);
 int rt2x00mac_config(struct ieee80211_hw *hw, struct ieee80211_conf *conf)
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
+	int force_reconfig;
 
 	/*
 	 * Mac80211 might be calling this function while we are trying
@@ -341,7 +330,17 @@ int rt2x00mac_config(struct ieee80211_hw *hw, struct ieee80211_conf *conf)
 			rt2x00lib_toggle_rx(rt2x00dev, STATE_RADIO_RX_OFF);
 	}
 
-	rt2x00lib_config(rt2x00dev, conf, 0);
+	/*
+	 * When the DEVICE_DIRTY_CONFIG flag is set, the device has recently
+	 * been started and the configuration must be forced upon the hardware.
+	 * Otherwise registers will not be intialized correctly and could
+	 * result in non-working hardware because essential registers aren't
+	 * initialized.
+	 */
+	force_reconfig =
+	    __test_and_clear_bit(DEVICE_DIRTY_CONFIG, &rt2x00dev->flags);
+
+	rt2x00lib_config(rt2x00dev, conf, force_reconfig);
 
 	/*
 	 * Reenable RX only if the radio should be on.
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 7f44203..3b27f6a 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -120,6 +120,7 @@ static void rt2x00queue_create_tx_descriptor(struct queue_entry *entry,
 {
 	struct rt2x00_dev *rt2x00dev = entry->queue->rt2x00dev;
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(entry->skb);
+	struct rt2x00_intf *intf = vif_to_intf(tx_info->control.vif);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)entry->skb->data;
 	struct ieee80211_rate *rate =
 	    ieee80211_get_tx_rate(rt2x00dev->hw, tx_info);
@@ -200,6 +201,31 @@ static void rt2x00queue_create_tx_descriptor(struct queue_entry *entry,
 	}
 
 	/*
+	 * Hardware should insert sequence counter.
+	 * FIXME: We insert a software sequence counter first for
+	 * hardware that doesn't support hardware sequence counting.
+	 *
+	 * This is wrong because beacons are not getting sequence
+	 * numbers assigned properly.
+	 *
+	 * A secondary problem exists for drivers that cannot toggle
+	 * sequence counting per-frame, since those will override the
+	 * sequence counter given by mac80211.
+	 */
+	if (tx_info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
+		spin_lock(&intf->lock);
+
+		if (test_bit(ENTRY_TXD_FIRST_FRAGMENT, &txdesc->flags))
+			intf->seqno += 0x10;
+		hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
+		hdr->seq_ctrl |= cpu_to_le16(intf->seqno);
+
+		spin_unlock(&intf->lock);
+
+		__set_bit(ENTRY_TXD_GENERATE_SEQ, &txdesc->flags);
+	}
+
+	/*
 	 * PLCP setup
 	 * Length calculation depends on OFDM/CCK rate.
 	 */
@@ -466,9 +492,12 @@ void rt2x00queue_init_rx(struct rt2x00_dev *rt2x00dev)
 	if (!rt2x00dev->ops->lib->init_rxentry)
 		return;
 
-	for (i = 0; i < queue->limit; i++)
+	for (i = 0; i < queue->limit; i++) {
+		queue->entries[i].flags = 0;
+
 		rt2x00dev->ops->lib->init_rxentry(rt2x00dev,
 						  &queue->entries[i]);
+	}
 }
 
 void rt2x00queue_init_tx(struct rt2x00_dev *rt2x00dev)
@@ -482,9 +511,12 @@ void rt2x00queue_init_tx(struct rt2x00_dev *rt2x00dev)
 		if (!rt2x00dev->ops->lib->init_txentry)
 			continue;
 
-		for (i = 0; i < queue->limit; i++)
+		for (i = 0; i < queue->limit; i++) {
+			queue->entries[i].flags = 0;
+
 			rt2x00dev->ops->lib->init_txentry(rt2x00dev,
 							  &queue->entries[i]);
+		}
 	}
 }
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.h b/drivers/net/wireless/rt2x00/rt2x00queue.h
index 8945945..a4a8c57 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.h
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.h
@@ -199,6 +199,7 @@ struct txdone_entry_desc {
  * @ENTRY_TXD_RTS_FRAME: This frame is a RTS frame.
  * @ENTRY_TXD_CTS_FRAME: This frame is a CTS-to-self frame.
  * @ENTRY_TXD_OFDM_RATE: This frame is send out with an OFDM rate.
+ * @ENTRY_TXD_GENERATE_SEQ: This frame requires sequence counter.
  * @ENTRY_TXD_FIRST_FRAGMENT: This is the first frame.
  * @ENTRY_TXD_MORE_FRAG: This frame is followed by another fragment.
  * @ENTRY_TXD_REQ_TIMESTAMP: Require timestamp to be inserted.
@@ -210,6 +211,7 @@ enum txentry_desc_flags {
 	ENTRY_TXD_RTS_FRAME,
 	ENTRY_TXD_CTS_FRAME,
 	ENTRY_TXD_OFDM_RATE,
+	ENTRY_TXD_GENERATE_SEQ,
 	ENTRY_TXD_FIRST_FRAGMENT,
 	ENTRY_TXD_MORE_FRAG,
 	ENTRY_TXD_REQ_TIMESTAMP,
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 83862e7..933e6cc 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -122,6 +122,38 @@ int rt2x00usb_vendor_request_buff(struct rt2x00_dev *rt2x00dev,
 }
 EXPORT_SYMBOL_GPL(rt2x00usb_vendor_request_buff);
 
+int rt2x00usb_vendor_request_large_buff(struct rt2x00_dev *rt2x00dev,
+					const u8 request, const u8 requesttype,
+					const u16 offset, void *buffer,
+					const u16 buffer_length,
+					const int timeout)
+{
+	int status = 0;
+	unsigned char *tb;
+	u16 off, len, bsize;
+
+	mutex_lock(&rt2x00dev->usb_cache_mutex);
+
+	tb  = buffer;
+	off = offset;
+	len = buffer_length;
+	while (len && !status) {
+		bsize = min_t(u16, CSR_CACHE_SIZE, len);
+		status = rt2x00usb_vendor_req_buff_lock(rt2x00dev, request,
+							requesttype, off, tb,
+							bsize, timeout);
+
+		tb  += bsize;
+		len -= bsize;
+		off += bsize;
+	}
+
+	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	return status;
+}
+EXPORT_SYMBOL_GPL(rt2x00usb_vendor_request_large_buff);
+
 /*
  * TX data handlers.
  */
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.h b/drivers/net/wireless/rt2x00/rt2x00usb.h
index aad794a..ee3875f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.h
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.h
@@ -70,8 +70,7 @@
 /*
  * Cache size
  */
-#define CSR_CACHE_SIZE			8
-#define CSR_CACHE_SIZE_FIRMWARE		64
+#define CSR_CACHE_SIZE			64
 
 /*
  * USB request types.
@@ -172,6 +171,25 @@ int rt2x00usb_vendor_req_buff_lock(struct rt2x00_dev *rt2x00dev,
 				   const u16 buffer_length, const int timeout);
 
 /**
+ * rt2x00usb_vendor_request_large_buff - Send register command to device (buffered)
+ * @rt2x00dev: Pointer to &struct rt2x00_dev
+ * @request: USB vendor command (See &enum rt2x00usb_vendor_request)
+ * @requesttype: Request type &USB_VENDOR_REQUEST_*
+ * @offset: Register start offset to perform action on
+ * @buffer: Buffer where information will be read/written to by device
+ * @buffer_length: Size of &buffer
+ * @timeout: Operation timeout
+ *
+ * This function is used to transfer register data in blocks larger
+ * then CSR_CACHE_SIZE. Use for firmware upload, keys and beacons.
+ */
+int rt2x00usb_vendor_request_large_buff(struct rt2x00_dev *rt2x00dev,
+					const u8 request, const u8 requesttype,
+					const u16 offset, void *buffer,
+					const u16 buffer_length,
+					const int timeout);
+
+/**
  * rt2x00usb_vendor_request_sw - Send single register command to device
  * @rt2x00dev: Pointer to &struct rt2x00_dev
  * @request: USB vendor command (See &enum rt2x00usb_vendor_request)
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index f7c1f92..fbe2a65 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1544,7 +1544,8 @@ static void rt61pci_write_tx_desc(struct rt2x00_dev *rt2x00dev,
 	rt2x00_set_field32(&word, TXD_W1_CWMIN, txdesc->cw_min);
 	rt2x00_set_field32(&word, TXD_W1_CWMAX, txdesc->cw_max);
 	rt2x00_set_field32(&word, TXD_W1_IV_OFFSET, IEEE80211_HEADER);
-	rt2x00_set_field32(&word, TXD_W1_HW_SEQUENCE, 1);
+	rt2x00_set_field32(&word, TXD_W1_HW_SEQUENCE,
+			   test_bit(ENTRY_TXD_GENERATE_SEQ, &txdesc->flags));
 	rt2x00_set_field32(&word, TXD_W1_BUFFER_COUNT, 1);
 	rt2x00_desc_write(txd, 1, word);
 
@@ -2278,7 +2279,6 @@ static void rt61pci_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	 * Initialize all hw fields.
 	 */
 	rt2x00dev->hw->flags =
-	    IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
 	    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
 	    IEEE80211_HW_SIGNAL_DBM;
 	rt2x00dev->hw->extra_tx_headroom = 0;
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index d383735..9761eaa 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -890,9 +890,6 @@ static int rt73usb_load_firmware(struct rt2x00_dev *rt2x00dev, const void *data,
 	unsigned int i;
 	int status;
 	u32 reg;
-	const char *ptr = data;
-	char *cache;
-	int buflen;
 
 	/*
 	 * Wait for stable hardware.
@@ -911,31 +908,12 @@ static int rt73usb_load_firmware(struct rt2x00_dev *rt2x00dev, const void *data,
 
 	/*
 	 * Write firmware to device.
-	 * We setup a seperate cache for this action,
-	 * since we are going to write larger chunks of data
-	 * then normally used cache size.
 	 */
-	cache = kmalloc(CSR_CACHE_SIZE_FIRMWARE, GFP_KERNEL);
-	if (!cache) {
-		ERROR(rt2x00dev, "Failed to allocate firmware cache.\n");
-		return -ENOMEM;
-	}
-
-	for (i = 0; i < len; i += CSR_CACHE_SIZE_FIRMWARE) {
-		buflen = min_t(int, len - i, CSR_CACHE_SIZE_FIRMWARE);
-
-		memcpy(cache, ptr, buflen);
-
-		rt2x00usb_vendor_request(rt2x00dev, USB_MULTI_WRITE,
-					 USB_VENDOR_REQUEST_OUT,
-					 FIRMWARE_IMAGE_BASE + i, 0,
-					 cache, buflen,
-					 REGISTER_TIMEOUT32(buflen));
-
-		ptr += buflen;
-	}
-
-	kfree(cache);
+	rt2x00usb_vendor_request_large_buff(rt2x00dev, USB_MULTI_WRITE,
+					    USB_VENDOR_REQUEST_OUT,
+					    FIRMWARE_IMAGE_BASE,
+					    data, len,
+					    REGISTER_TIMEOUT32(len));
 
 	/*
 	 * Send firmware request to device to load firmware,
@@ -1303,7 +1281,8 @@ static void rt73usb_write_tx_desc(struct rt2x00_dev *rt2x00dev,
 	rt2x00_set_field32(&word, TXD_W1_CWMIN, txdesc->cw_min);
 	rt2x00_set_field32(&word, TXD_W1_CWMAX, txdesc->cw_max);
 	rt2x00_set_field32(&word, TXD_W1_IV_OFFSET, IEEE80211_HEADER);
-	rt2x00_set_field32(&word, TXD_W1_HW_SEQUENCE, 1);
+	rt2x00_set_field32(&word, TXD_W1_HW_SEQUENCE,
+			   test_bit(ENTRY_TXD_GENERATE_SEQ, &txdesc->flags));
 	rt2x00_desc_write(txd, 1, word);
 
 	rt2x00_desc_read(txd, 2, &word);
@@ -1352,6 +1331,7 @@ static void rt73usb_write_beacon(struct queue_entry *entry)
 	struct skb_frame_desc *skbdesc = get_skb_frame_desc(entry->skb);
 	unsigned int beacon_base;
 	u32 reg;
+	u32 word, len;
 
 	/*
 	 * Add the descriptor in front of the skb.
@@ -1361,6 +1341,17 @@ static void rt73usb_write_beacon(struct queue_entry *entry)
 	skbdesc->desc = entry->skb->data;
 
 	/*
+	 * Adjust the beacon databyte count. The current number is
+	 * calculated before this function gets called, but falsely
+	 * assumes that the descriptor was already present in the SKB.
+	 */
+	rt2x00_desc_read(skbdesc->desc, 0, &word);
+	len  = rt2x00_get_field32(word, TXD_W0_DATABYTE_COUNT);
+	len += skbdesc->desc_len;
+	rt2x00_set_field32(&word, TXD_W0_DATABYTE_COUNT, len);
+	rt2x00_desc_write(skbdesc->desc, 0, word);
+
+	/*
 	 * Disable beaconing while we are reloading the beacon data,
 	 * otherwise we might be sending out invalid data.
 	 */
@@ -1374,10 +1365,10 @@ static void rt73usb_write_beacon(struct queue_entry *entry)
 	 * Write entire beacon with descriptor to register.
 	 */
 	beacon_base = HW_BEACON_OFFSET(entry->entry_idx);
-	rt2x00usb_vendor_request(rt2x00dev, USB_MULTI_WRITE,
-				 USB_VENDOR_REQUEST_OUT, beacon_base, 0,
-				 entry->skb->data, entry->skb->len,
-				 REGISTER_TIMEOUT32(entry->skb->len));
+	rt2x00usb_vendor_request_large_buff(rt2x00dev, USB_MULTI_WRITE,
+					    USB_VENDOR_REQUEST_OUT, beacon_base,
+					    entry->skb->data, entry->skb->len,
+					    REGISTER_TIMEOUT32(entry->skb->len));
 
 	/*
 	 * Clean up the beacon skb.
@@ -1871,7 +1862,6 @@ static void rt73usb_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	 * Initialize all hw fields.
 	 */
 	rt2x00dev->hw->flags =
-	    IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
 	    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
 	    IEEE80211_HW_SIGNAL_DBM;
 	rt2x00dev->hw->extra_tx_headroom = TXD_DESC_SIZE;
diff --git a/drivers/net/wireless/rtl8187.h b/drivers/net/wireless/rtl8187.h
index 3afb49f..1b0d750 100644
--- a/drivers/net/wireless/rtl8187.h
+++ b/drivers/net/wireless/rtl8187.h
@@ -47,11 +47,13 @@ struct rtl8187_rx_hdr {
 struct rtl8187b_rx_hdr {
 	__le32 flags;
 	__le64 mac_time;
-	u8 noise;
-	u8 signal;
+	u8 sq;
+	u8 rssi;
 	u8 agc;
-	u8 reserved;
-	__le32 unused;
+	u8 flags2;
+	__le16 snr_long2end;
+	s8 pwdb_g12;
+	u8 fot;
 } __attribute__((packed));
 
 /* {rtl8187,rtl8187b}_tx_info is in skb */
@@ -100,6 +102,7 @@ struct rtl8187_priv {
 	struct usb_device *udev;
 	u32 rx_conf;
 	u16 txpwr_base;
+	u16 seqno;
 	u8 asic_rev;
 	u8 is_rtl8187b;
 	enum {
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index d3067b1..177988e 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -169,6 +169,7 @@ static int rtl8187_tx(struct ieee80211_hw *dev, struct sk_buff *skb)
 {
 	struct rtl8187_priv *priv = dev->priv;
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr *)skb->data;
 	unsigned int ep;
 	void *buf;
 	struct urb *urb;
@@ -234,6 +235,20 @@ static int rtl8187_tx(struct ieee80211_hw *dev, struct sk_buff *skb)
 			ep = epmap[skb_get_queue_mapping(skb)];
 	}
 
+	/* FIXME: The sequence that follows is needed for this driver to
+	 * work with mac80211 since "mac80211: fix TX sequence numbers".
+	 * As with the temporary code in rt2x00, changes will be needed
+	 * to get proper sequence numbers on beacons. In addition, this
+	 * patch places the sequence number in the hardware state, which
+	 * limits us to a single virtual state.
+	 */
+	if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
+		if (info->flags & IEEE80211_TX_CTL_FIRST_FRAGMENT)
+			priv->seqno += 0x10;
+		ieee80211hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
+		ieee80211hdr->seq_ctrl |= cpu_to_le16(priv->seqno);
+	}
+
 	info->driver_data[0] = dev;
 	info->driver_data[1] = urb;
 
@@ -257,6 +272,7 @@ static void rtl8187_rx_cb(struct urb *urb)
 	struct ieee80211_rx_status rx_status = { 0 };
 	int rate, signal;
 	u32 flags;
+	u32 quality;
 
 	spin_lock(&priv->rx_queue.lock);
 	if (skb->next)
@@ -280,44 +296,57 @@ static void rtl8187_rx_cb(struct urb *urb)
 		flags = le32_to_cpu(hdr->flags);
 		signal = hdr->signal & 0x7f;
 		rx_status.antenna = (hdr->signal >> 7) & 1;
-		rx_status.signal = signal;
 		rx_status.noise = hdr->noise;
 		rx_status.mactime = le64_to_cpu(hdr->mac_time);
-		priv->signal = signal;
 		priv->quality = signal;
+		rx_status.qual = priv->quality;
 		priv->noise = hdr->noise;
+		rate = (flags >> 20) & 0xF;
+		if (rate > 3) { /* OFDM rate */
+			if (signal > 90)
+				signal = 90;
+			else if (signal < 25)
+				signal = 25;
+			signal = 90 - signal;
+		} else {	/* CCK rate */
+			if (signal > 95)
+				signal = 95;
+			else if (signal < 30)
+				signal = 30;
+			signal = 95 - signal;
+		}
+		rx_status.signal = signal;
+		priv->signal = signal;
 	} else {
 		struct rtl8187b_rx_hdr *hdr =
 			(typeof(hdr))(skb_tail_pointer(skb) - sizeof(*hdr));
+		/* The Realtek datasheet for the RTL8187B shows that the RX
+		 * header contains the following quantities: signal quality,
+		 * RSSI, AGC, the received power in dB, and the measured SNR.
+		 * In testing, none of these quantities show qualitative
+		 * agreement with AP signal strength, except for the AGC,
+		 * which is inversely proportional to the strength of the
+		 * signal. In the following, the quality and signal strength
+		 * are derived from the AGC. The arbitrary scaling constants
+		 * are chosen to make the results close to the values obtained
+		 * for a BCM4312 using b43 as the driver. The noise is ignored
+		 * for now.
+		 */
 		flags = le32_to_cpu(hdr->flags);
-		signal = hdr->agc >> 1;
-		rx_status.antenna = (hdr->signal >> 7) & 1;
-		rx_status.signal = 64 - min(hdr->noise, (u8)64);
-		rx_status.noise = hdr->noise;
+		quality = 170 - hdr->agc;
+		if (quality > 100)
+			quality = 100;
+		signal = 14 - hdr->agc / 2;
+		rx_status.qual = quality;
+		priv->quality = quality;
+		rx_status.signal = signal;
+		priv->signal = signal;
+		rx_status.antenna = (hdr->rssi >> 7) & 1;
 		rx_status.mactime = le64_to_cpu(hdr->mac_time);
-		priv->signal = hdr->signal;
-		priv->quality = hdr->agc >> 1;
-		priv->noise = hdr->noise;
+		rate = (flags >> 20) & 0xF;
 	}
 
 	skb_trim(skb, flags & 0x0FFF);
-	rate = (flags >> 20) & 0xF;
-	if (rate > 3) {	/* OFDM rate */
-		if (signal > 90)
-			signal = 90;
-		else if (signal < 25)
-			signal = 25;
-		signal = 90 - signal;
-	} else {	/* CCK rate */
-		if (signal > 95)
-			signal = 95;
-		else if (signal < 30)
-			signal = 30;
-		signal = 95 - signal;
-	}
-
-	rx_status.qual = priv->quality;
-	rx_status.signal = signal;
 	rx_status.rate_idx = rate;
 	rx_status.freq = dev->conf.channel->center_freq;
 	rx_status.band = dev->conf.channel->band;
@@ -1015,9 +1044,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 
 	priv->mode = IEEE80211_IF_TYPE_MNTR;
 	dev->flags = IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
-		     IEEE80211_HW_RX_INCLUDES_FCS |
-		     IEEE80211_HW_SIGNAL_UNSPEC;
-	dev->max_signal = 65;
+		     IEEE80211_HW_RX_INCLUDES_FCS;
 
 	eeprom.data = dev;
 	eeprom.register_read = rtl8187_eeprom_register_read;
@@ -1132,10 +1159,16 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 		(*channel++).hw_value = txpwr >> 8;
 	}
 
-	if (priv->is_rtl8187b)
+	if (priv->is_rtl8187b) {
 		printk(KERN_WARNING "rtl8187: 8187B chip detected. Support "
 			"is EXPERIMENTAL, and could damage your\n"
 			"         hardware, use at your own risk\n");
+		dev->flags |= IEEE80211_HW_SIGNAL_DBM;
+	} else {
+		dev->flags |= IEEE80211_HW_SIGNAL_UNSPEC;
+		dev->max_signal = 65;
+	}
+
 	if ((id->driver_info == DEVICE_RTL8187) && priv->is_rtl8187b)
 		printk(KERN_INFO "rtl8187: inconsistency between id with OEM"
 		       " info!\n");
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index fcc532b..4d7b98b 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -935,7 +935,6 @@ struct ieee80211_hw *zd_mac_alloc_hw(struct usb_interface *intf)
 	hw->wiphy->bands[IEEE80211_BAND_2GHZ] = &mac->band;
 
 	hw->flags = IEEE80211_HW_RX_INCLUDES_FCS |
-		    IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
 		    IEEE80211_HW_SIGNAL_DB;
 
 	hw->max_signal = 100;
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index c5f6e54..741d1a6 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -68,7 +68,8 @@ enum rfkill_state {
  * @user_claim_unsupported: Whether the hardware supports exclusive
  *	RF-kill control by userspace. Set this before registering.
  * @user_claim: Set when the switch is controlled exlusively by userspace.
- * @mutex: Guards switch state transitions
+ * @mutex: Guards switch state transitions.  It serializes callbacks
+ *	and also protects the state.
  * @data: Pointer to the RF button drivers private data which will be
  *	passed along when toggling radio state.
  * @toggle_radio(): Mandatory handler to control state of the radio.
@@ -89,12 +90,13 @@ struct rfkill {
 	const char *name;
 	enum rfkill_type type;
 
-	enum rfkill_state state;
 	bool user_claim_unsupported;
 	bool user_claim;
 
+	/* the mutex serializes callbacks and also protects
+	 * the state */
 	struct mutex mutex;
-
+	enum rfkill_state state;
 	void *data;
 	int (*toggle_radio)(void *data, enum rfkill_state state);
 	int (*get_state)(void *data, enum rfkill_state *state);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7ea44f6..a640385 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -316,7 +316,10 @@ struct sk_buff {
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
-	/* 14 bit hole */
+#if defined(CONFIG_MAC80211) || defined(CONFIG_MAC80211_MODULE)
+	__u8			do_not_encrypt:1;
+#endif
+	/* 0/13/14 bit hole */
 
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 4dd3d93..b527210 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -206,8 +206,6 @@ struct ieee80211_bss_conf {
  * These flags are used with the @flags member of &ieee80211_tx_info.
  *
  * @IEEE80211_TX_CTL_REQ_TX_STATUS: request TX status callback for this frame.
- * @IEEE80211_TX_CTL_DO_NOT_ENCRYPT: send this frame without encryption;
- *	e.g., for EAPOL frame
  * @IEEE80211_TX_CTL_USE_RTS_CTS: use RTS-CTS before sending frame
  * @IEEE80211_TX_CTL_USE_CTS_PROTECT: use CTS protection for the frame (e.g.,
  *	for combined 802.11g / 802.11b networks)
@@ -220,7 +218,6 @@ struct ieee80211_bss_conf {
  * @IEEE80211_TX_CTL_SHORT_PREAMBLE: TBD
  * @IEEE80211_TX_CTL_LONG_RETRY_LIMIT: this frame should be send using the
  *	through set_retry_limit configured long retry value
- * @IEEE80211_TX_CTL_EAPOL_FRAME: internal to mac80211
  * @IEEE80211_TX_CTL_SEND_AFTER_DTIM: send this frame after DTIM beacon
  * @IEEE80211_TX_CTL_AMPDU: this frame should be sent as part of an A-MPDU
  * @IEEE80211_TX_CTL_OFDM_HT: this frame can be sent in HT OFDM rates. number
@@ -253,7 +250,6 @@ struct ieee80211_bss_conf {
  */
 enum mac80211_tx_control_flags {
 	IEEE80211_TX_CTL_REQ_TX_STATUS		= BIT(0),
-	IEEE80211_TX_CTL_DO_NOT_ENCRYPT		= BIT(1),
 	IEEE80211_TX_CTL_USE_RTS_CTS		= BIT(2),
 	IEEE80211_TX_CTL_USE_CTS_PROTECT	= BIT(3),
 	IEEE80211_TX_CTL_NO_ACK			= BIT(4),
@@ -263,7 +259,6 @@ enum mac80211_tx_control_flags {
 	IEEE80211_TX_CTL_FIRST_FRAGMENT		= BIT(8),
 	IEEE80211_TX_CTL_SHORT_PREAMBLE		= BIT(9),
 	IEEE80211_TX_CTL_LONG_RETRY_LIMIT	= BIT(10),
-	IEEE80211_TX_CTL_EAPOL_FRAME		= BIT(11),
 	IEEE80211_TX_CTL_SEND_AFTER_DTIM	= BIT(12),
 	IEEE80211_TX_CTL_AMPDU			= BIT(13),
 	IEEE80211_TX_CTL_OFDM_HT		= BIT(14),
@@ -323,7 +318,6 @@ struct ieee80211_tx_info {
 			struct ieee80211_vif *vif;
 			struct ieee80211_key_conf *hw_key;
 			unsigned long jiffies;
-			int ifindex;
 			u16 aid;
 			s8 rts_cts_rate_idx, alt_retry_rate_idx;
 			u8 retry_limit;
@@ -746,7 +740,6 @@ enum ieee80211_tkip_key_type {
  * 	Measurement, Channel Switch, Quieting, TPC
  */
 enum ieee80211_hw_flags {
-	IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE		= 1<<0,
 	IEEE80211_HW_RX_INCLUDES_FCS			= 1<<1,
 	IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING	= 1<<2,
 	IEEE80211_HW_2GHZ_SHORT_SLOT_INCAPABLE		= 1<<3,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4e0c922..8464017 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -485,6 +485,9 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	C(head);
 	C(data);
 	C(truesize);
+#if defined(CONFIG_MAC80211) || defined(CONFIG_MAC80211_MODULE)
+	C(do_not_encrypt);
+#endif
 	atomic_set(&n->users, 1);
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 8e7ba0e..297c257 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -81,6 +81,7 @@ static int ieee80211_change_iface(struct wiphy *wiphy, int ifindex,
 				  enum nl80211_iftype type, u32 *flags,
 				  struct vif_params *params)
 {
+	struct ieee80211_local *local = wiphy_priv(wiphy);
 	struct net_device *dev;
 	enum ieee80211_if_types itype;
 	struct ieee80211_sub_if_data *sdata;
@@ -95,6 +96,9 @@ static int ieee80211_change_iface(struct wiphy *wiphy, int ifindex,
 	if (itype == IEEE80211_IF_TYPE_INVALID)
 		return -EINVAL;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	ret = ieee80211_if_change_type(sdata, itype);
@@ -117,12 +121,16 @@ static int ieee80211_add_key(struct wiphy *wiphy, struct net_device *dev,
 			     u8 key_idx, u8 *mac_addr,
 			     struct key_params *params)
 {
+	struct ieee80211_local *local = wiphy_priv(wiphy);
 	struct ieee80211_sub_if_data *sdata;
 	struct sta_info *sta = NULL;
 	enum ieee80211_key_alg alg;
 	struct ieee80211_key *key;
 	int err;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	switch (params->cipher) {
@@ -167,10 +175,14 @@ static int ieee80211_add_key(struct wiphy *wiphy, struct net_device *dev,
 static int ieee80211_del_key(struct wiphy *wiphy, struct net_device *dev,
 			     u8 key_idx, u8 *mac_addr)
 {
+	struct ieee80211_local *local = wiphy_priv(wiphy);
 	struct ieee80211_sub_if_data *sdata;
 	struct sta_info *sta;
 	int ret;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	rcu_read_lock();
@@ -211,7 +223,8 @@ static int ieee80211_get_key(struct wiphy *wiphy, struct net_device *dev,
 			     void (*callback)(void *cookie,
 					      struct key_params *params))
 {
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct sta_info *sta = NULL;
 	u8 seq[6] = {0};
 	struct key_params params;
@@ -220,6 +233,11 @@ static int ieee80211_get_key(struct wiphy *wiphy, struct net_device *dev,
 	u16 iv16;
 	int err = -ENOENT;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	rcu_read_lock();
 
 	if (mac_addr) {
@@ -293,8 +311,12 @@ static int ieee80211_config_default_key(struct wiphy *wiphy,
 					struct net_device *dev,
 					u8 key_idx)
 {
+	struct ieee80211_local *local = wiphy_priv(wiphy);
 	struct ieee80211_sub_if_data *sdata;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
 	rcu_read_lock();
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -475,9 +497,15 @@ static int ieee80211_config_beacon(struct ieee80211_sub_if_data *sdata,
 static int ieee80211_add_beacon(struct wiphy *wiphy, struct net_device *dev,
 				struct beacon_parameters *params)
 {
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct beacon_data *old;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	if (sdata->vif.type != IEEE80211_IF_TYPE_AP)
 		return -EINVAL;
 
@@ -492,9 +520,15 @@ static int ieee80211_add_beacon(struct wiphy *wiphy, struct net_device *dev,
 static int ieee80211_set_beacon(struct wiphy *wiphy, struct net_device *dev,
 				struct beacon_parameters *params)
 {
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct beacon_data *old;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	if (sdata->vif.type != IEEE80211_IF_TYPE_AP)
 		return -EINVAL;
 
@@ -508,9 +542,15 @@ static int ieee80211_set_beacon(struct wiphy *wiphy, struct net_device *dev,
 
 static int ieee80211_del_beacon(struct wiphy *wiphy, struct net_device *dev)
 {
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct beacon_data *old;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	if (sdata->vif.type != IEEE80211_IF_TYPE_AP)
 		return -EINVAL;
 
@@ -646,11 +686,14 @@ static void sta_apply_parameters(struct ieee80211_local *local,
 static int ieee80211_add_station(struct wiphy *wiphy, struct net_device *dev,
 				 u8 *mac, struct station_parameters *params)
 {
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata;
 	int err;
 
+	if (dev == local->mdev || params->vlan == local->mdev)
+		return -EOPNOTSUPP;
+
 	/* Prevent a race with changing the rate control algorithm */
 	if (!netif_running(dev))
 		return -ENETDOWN;
@@ -701,10 +744,15 @@ static int ieee80211_add_station(struct wiphy *wiphy, struct net_device *dev,
 static int ieee80211_del_station(struct wiphy *wiphy, struct net_device *dev,
 				 u8 *mac)
 {
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	struct ieee80211_local *local = sdata->local;
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct sta_info *sta;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	if (mac) {
 		rcu_read_lock();
 
@@ -730,10 +778,13 @@ static int ieee80211_change_station(struct wiphy *wiphy,
 				    u8 *mac,
 				    struct station_parameters *params)
 {
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *vlansdata;
 
+	if (dev == local->mdev || params->vlan == local->mdev)
+		return -EOPNOTSUPP;
+
 	rcu_read_lock();
 
 	/* XXX: get sta belonging to dev */
@@ -752,7 +803,7 @@ static int ieee80211_change_station(struct wiphy *wiphy,
 			return -EINVAL;
 		}
 
-		sta->sdata = IEEE80211_DEV_TO_SUB_IF(params->vlan);
+		sta->sdata = vlansdata;
 		ieee80211_send_layer2_update(sta);
 	}
 
@@ -767,15 +818,20 @@ static int ieee80211_change_station(struct wiphy *wiphy,
 static int ieee80211_add_mpath(struct wiphy *wiphy, struct net_device *dev,
 				 u8 *dst, u8 *next_hop)
 {
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct mesh_path *mpath;
 	struct sta_info *sta;
 	int err;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
 	if (!netif_running(dev))
 		return -ENETDOWN;
 
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	if (sdata->vif.type != IEEE80211_IF_TYPE_MESH_POINT)
 		return -ENOTSUPP;
 
@@ -817,14 +873,19 @@ static int ieee80211_change_mpath(struct wiphy *wiphy,
 				    struct net_device *dev,
 				    u8 *dst, u8 *next_hop)
 {
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct mesh_path *mpath;
 	struct sta_info *sta;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
 	if (!netif_running(dev))
 		return -ENETDOWN;
 
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	if (sdata->vif.type != IEEE80211_IF_TYPE_MESH_POINT)
 		return -ENOTSUPP;
 
@@ -891,9 +952,15 @@ static int ieee80211_get_mpath(struct wiphy *wiphy, struct net_device *dev,
 			       u8 *dst, u8 *next_hop, struct mpath_info *pinfo)
 
 {
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct mesh_path *mpath;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	if (sdata->vif.type != IEEE80211_IF_TYPE_MESH_POINT)
 		return -ENOTSUPP;
 
@@ -913,9 +980,15 @@ static int ieee80211_dump_mpath(struct wiphy *wiphy, struct net_device *dev,
 				 int idx, u8 *dst, u8 *next_hop,
 				 struct mpath_info *pinfo)
 {
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *sdata;
 	struct mesh_path *mpath;
 
+	if (dev == local->mdev)
+		return -EOPNOTSUPP;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
 	if (sdata->vif.type != IEEE80211_IF_TYPE_MESH_POINT)
 		return -ENOTSUPP;
 
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index f1a83d4..a4c5b90 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1233,18 +1233,12 @@ static void ieee80211_tasklet_handler(unsigned long data)
 /* Remove added headers (e.g., QoS control), encryption header/MIC, etc. to
  * make a prepared TX frame (one that has been given to hw) to look like brand
  * new IEEE 802.11 frame that is ready to go through TX processing again.
- * Also, tx_packet_data in cb is restored from tx_control. */
+ */
 static void ieee80211_remove_tx_extra(struct ieee80211_local *local,
 				      struct ieee80211_key *key,
 				      struct sk_buff *skb)
 {
 	int hdrlen, iv_len, mic_len;
-	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
-
-	info->flags &=	IEEE80211_TX_CTL_REQ_TX_STATUS |
-			IEEE80211_TX_CTL_DO_NOT_ENCRYPT |
-			IEEE80211_TX_CTL_REQUEUE |
-			IEEE80211_TX_CTL_EAPOL_FRAME;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
 
@@ -1731,8 +1725,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	result = ieee80211_wep_init(local);
 
 	if (result < 0) {
-		printk(KERN_DEBUG "%s: Failed to initialize wep\n",
-		       wiphy_name(local->hw.wiphy));
+		printk(KERN_DEBUG "%s: Failed to initialize wep: %d\n",
+		       wiphy_name(local->hw.wiphy), result);
 		goto fail_wep;
 	}
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index d7c371e..acb0413 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -606,7 +606,6 @@ void ieee80211_sta_tx(struct net_device *dev, struct sk_buff *skb,
 		      int encrypt)
 {
 	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_tx_info *info;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	skb->dev = sdata->local->mdev;
@@ -614,11 +613,8 @@ void ieee80211_sta_tx(struct net_device *dev, struct sk_buff *skb,
 	skb_set_network_header(skb, 0);
 	skb_set_transport_header(skb, 0);
 
-	info = IEEE80211_SKB_CB(skb);
-	memset(info, 0, sizeof(struct ieee80211_tx_info));
-	info->control.ifindex = sdata->dev->ifindex;
-	if (!encrypt)
-		info->flags |= IEEE80211_TX_CTL_DO_NOT_ENCRYPT;
+	skb->iif = sdata->dev->ifindex;
+	skb->do_not_encrypt = !encrypt;
 
 	dev_queue_xmit(skb);
 }
@@ -3303,6 +3299,7 @@ void ieee80211_start_mesh(struct net_device *dev)
 	ifsta = &sdata->u.sta;
 	ifsta->state = IEEE80211_MESH_UP;
 	ieee80211_sta_timer((unsigned long)sdata);
+	ieee80211_if_config(sdata, IEEE80211_IFCC_BEACON);
 }
 #endif
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 0fbadd8..69019e9 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -305,7 +305,7 @@ static void purge_old_ps_buffers(struct ieee80211_local *local)
 	rcu_read_unlock();
 
 	local->total_ps_buffered = total;
-#ifdef MAC80211_VERBOSE_PS_DEBUG
+#ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
 	printk(KERN_DEBUG "%s: PS buffers full - purged %d frames\n",
 	       wiphy_name(local->hw.wiphy), purged);
 #endif
@@ -342,7 +342,7 @@ ieee80211_tx_h_multicast_ps_buf(struct ieee80211_tx_data *tx)
 			purge_old_ps_buffers(tx->local);
 		if (skb_queue_len(&tx->sdata->bss->ps_bc_buf) >=
 		    AP_MAX_BC_BUFFER) {
-#ifdef MAC80211_VERBOSE_PS_DEBUG
+#ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: BC TX buffer full - "
 				       "dropping the oldest frame\n",
@@ -389,7 +389,7 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data *tx)
 			purge_old_ps_buffers(tx->local);
 		if (skb_queue_len(&sta->ps_tx_buf) >= STA_MAX_TX_BUFFER) {
 			struct sk_buff *old = skb_dequeue(&sta->ps_tx_buf);
-#ifdef MAC80211_VERBOSE_PS_DEBUG
+#ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: STA %s TX "
 				       "buffer full - dropping oldest frame\n",
@@ -439,14 +439,14 @@ ieee80211_tx_h_select_key(struct ieee80211_tx_data *tx)
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(tx->skb);
 	u16 fc = tx->fc;
 
-	if (unlikely(info->flags & IEEE80211_TX_CTL_DO_NOT_ENCRYPT))
+	if (unlikely(tx->skb->do_not_encrypt))
 		tx->key = NULL;
 	else if (tx->sta && (key = rcu_dereference(tx->sta->key)))
 		tx->key = key;
 	else if ((key = rcu_dereference(tx->sdata->default_key)))
 		tx->key = key;
 	else if (tx->sdata->drop_unencrypted &&
-		 !(info->flags & IEEE80211_TX_CTL_EAPOL_FRAME) &&
+		 (tx->skb->protocol != cpu_to_be16(ETH_P_PAE)) &&
 		 !(info->flags & IEEE80211_TX_CTL_INJECTED)) {
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_unencrypted);
 		return TX_DROP;
@@ -476,7 +476,7 @@ ieee80211_tx_h_select_key(struct ieee80211_tx_data *tx)
 	}
 
 	if (!tx->key || !(tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE))
-		info->flags |= IEEE80211_TX_CTL_DO_NOT_ENCRYPT;
+		tx->skb->do_not_encrypt = 1;
 
 	return TX_CONTINUE;
 }
@@ -732,6 +732,7 @@ ieee80211_tx_h_fragment(struct ieee80211_tx_data *tx)
 		memcpy(skb_put(frag, copylen), pos, copylen);
 		memcpy(frag->cb, first->cb, sizeof(frag->cb));
 		skb_copy_queue_mapping(frag, first);
+		frag->do_not_encrypt = first->do_not_encrypt;
 
 		pos += copylen;
 		left -= copylen;
@@ -852,7 +853,7 @@ __ieee80211_parse_tx_radiotap(struct ieee80211_tx_data *tx,
 
 	sband = tx->local->hw.wiphy->bands[tx->channel->band];
 
-	info->flags |= IEEE80211_TX_CTL_DO_NOT_ENCRYPT;
+	skb->do_not_encrypt = 1;
 	info->flags |= IEEE80211_TX_CTL_INJECTED;
 	tx->flags &= ~IEEE80211_TX_FRAGMENTED;
 
@@ -925,8 +926,7 @@ __ieee80211_parse_tx_radiotap(struct ieee80211_tx_data *tx,
 				skb_trim(skb, skb->len - FCS_LEN);
 			}
 			if (*iterator.this_arg & IEEE80211_RADIOTAP_F_WEP)
-				info->flags &=
-					~IEEE80211_TX_CTL_DO_NOT_ENCRYPT;
+				tx->skb->do_not_encrypt = 0;
 			if (*iterator.this_arg & IEEE80211_RADIOTAP_F_FRAG)
 				tx->flags |= IEEE80211_TX_FRAGMENTED;
 			break;
@@ -1042,10 +1042,9 @@ static int ieee80211_tx_prepare(struct ieee80211_tx_data *tx,
 				struct sk_buff *skb,
 				struct net_device *mdev)
 {
-	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct net_device *dev;
 
-	dev = dev_get_by_index(&init_net, info->control.ifindex);
+	dev = dev_get_by_index(&init_net, skb->iif);
 	if (unlikely(dev && !is_ieee80211_device(dev, mdev))) {
 		dev_put(dev);
 		dev = NULL;
@@ -1306,8 +1305,8 @@ int ieee80211_master_start_xmit(struct sk_buff *skb,
 	bool may_encrypt;
 	int ret;
 
-	if (info->control.ifindex)
-		odev = dev_get_by_index(&init_net, info->control.ifindex);
+	if (skb->iif)
+		odev = dev_get_by_index(&init_net, skb->iif);
 	if (unlikely(odev && !is_ieee80211_device(odev, dev))) {
 		dev_put(odev);
 		odev = NULL;
@@ -1321,9 +1320,13 @@ int ieee80211_master_start_xmit(struct sk_buff *skb,
 		return 0;
 	}
 
+	memset(info, 0, sizeof(*info));
+
+	info->flags |= IEEE80211_TX_CTL_REQ_TX_STATUS;
+
 	osdata = IEEE80211_DEV_TO_SUB_IF(odev);
 
-	may_encrypt = !(info->flags & IEEE80211_TX_CTL_DO_NOT_ENCRYPT);
+	may_encrypt = !skb->do_not_encrypt;
 
 	headroom = osdata->local->tx_headroom;
 	if (may_encrypt)
@@ -1348,7 +1351,6 @@ int ieee80211_monitor_start_xmit(struct sk_buff *skb,
 				 struct net_device *dev)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_radiotap_header *prthdr =
 		(struct ieee80211_radiotap_header *)skb->data;
 	u16 len_rthdr;
@@ -1371,11 +1373,11 @@ int ieee80211_monitor_start_xmit(struct sk_buff *skb,
 	skb->dev = local->mdev;
 
 	/* needed because we set skb device to master */
-	info->control.ifindex = dev->ifindex;
+	skb->iif = dev->ifindex;
 
-	info->flags |= IEEE80211_TX_CTL_DO_NOT_ENCRYPT;
-	/* Interfaces should always request a status report */
-	info->flags |= IEEE80211_TX_CTL_REQ_TX_STATUS;
+	/* sometimes we do encrypt injected frames, will be fixed
+	 * up in radiotap parser if not wanted */
+	skb->do_not_encrypt = 0;
 
 	/*
 	 * fix up the pointers accounting for the radiotap
@@ -1419,7 +1421,6 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 			       struct net_device *dev)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_tx_info *info;
 	struct ieee80211_sub_if_data *sdata;
 	int ret = 1, head_need;
 	u16 ethertype, hdrlen,  meshhdrlen = 0;
@@ -1645,14 +1646,7 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	nh_pos += hdrlen;
 	h_pos += hdrlen;
 
-	info = IEEE80211_SKB_CB(skb);
-	memset(info, 0, sizeof(*info));
-	info->control.ifindex = dev->ifindex;
-	if (ethertype == ETH_P_PAE)
-		info->flags |= IEEE80211_TX_CTL_EAPOL_FRAME;
-
-	/* Interfaces should always request a status report */
-	info->flags |= IEEE80211_TX_CTL_REQ_TX_STATUS;
+	skb->iif = dev->ifindex;
 
 	skb->dev = local->mdev;
 	dev->stats.tx_packets++;
@@ -1922,6 +1916,8 @@ struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw,
 
 	info = IEEE80211_SKB_CB(skb);
 
+	skb->do_not_encrypt = 1;
+
 	info->band = band;
 	rate_control_get_rate(local->mdev, sband, skb, &rsel);
 
@@ -1931,7 +1927,7 @@ struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw,
 			       "no rate found\n",
 			       wiphy_name(local->hw.wiphy));
 		}
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		skb = NULL;
 		goto out;
 	}
@@ -1940,7 +1936,6 @@ struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw,
 	info->tx_rate_idx = rsel.rate_idx;
 
 	info->flags |= IEEE80211_TX_CTL_NO_ACK;
-	info->flags |= IEEE80211_TX_CTL_DO_NOT_ENCRYPT;
 	info->flags |= IEEE80211_TX_CTL_CLEAR_PS_FILT;
 	info->flags |= IEEE80211_TX_CTL_ASSIGN_SEQ;
 	if (sdata->bss_conf.use_short_preamble &&
diff --git a/net/mac80211/wep.c b/net/mac80211/wep.c
index 872d2fc..5c2bf0a 100644
--- a/net/mac80211/wep.c
+++ b/net/mac80211/wep.c
@@ -31,13 +31,13 @@ int ieee80211_wep_init(struct ieee80211_local *local)
 	local->wep_tx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0,
 						CRYPTO_ALG_ASYNC);
 	if (IS_ERR(local->wep_tx_tfm))
-		return -ENOMEM;
+		return PTR_ERR(local->wep_tx_tfm);
 
 	local->wep_rx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0,
 						CRYPTO_ALG_ASYNC);
 	if (IS_ERR(local->wep_rx_tfm)) {
 		crypto_free_blkcipher(local->wep_tx_tfm);
-		return -ENOMEM;
+		return PTR_ERR(local->wep_rx_tfm);
 	}
 
 	return 0;
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 07edda0..28437f0 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -188,6 +188,9 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 {
 	int i;
 
+	/* XXX: currently broken due to cb/requeue use */
+	return -EPERM;
+
 	/* prepare the filter and save it for the SW queue
 	 * matching the received HW queue */
 
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index 7a560b7..c6f2f38 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -130,7 +130,6 @@ static void update_rfkill_state(struct rfkill *rfkill)
 
 /**
  * rfkill_toggle_radio - wrapper for toggle_radio hook
- *
  * @rfkill: the rfkill struct to use
  * @force: calls toggle_radio even if cache says it is not needed,
  *	and also makes sure notifications of the state will be
@@ -141,8 +140,8 @@ static void update_rfkill_state(struct rfkill *rfkill)
  * calls and handling all the red tape such as issuing notifications
  * if the call is successful.
  *
- * Note that @force cannot override a (possibly cached) state of
- * RFKILL_STATE_HARD_BLOCKED.  Any device making use of
+ * Note that the @force parameter cannot override a (possibly cached)
+ * state of RFKILL_STATE_HARD_BLOCKED.  Any device making use of
  * RFKILL_STATE_HARD_BLOCKED implements either get_state() or
  * rfkill_force_state(), so the cache either is bypassed or valid.
  *
@@ -150,7 +149,7 @@ static void update_rfkill_state(struct rfkill *rfkill)
  * even if the radio is in RFKILL_STATE_HARD_BLOCKED state, so as to
  * give the driver a hint that it should double-BLOCK the transmitter.
  *
- * Caller must have aquired rfkill_mutex.
+ * Caller must have acquired rfkill->mutex.
  */
 static int rfkill_toggle_radio(struct rfkill *rfkill,
 				enum rfkill_state state,
@@ -200,12 +199,12 @@ static int rfkill_toggle_radio(struct rfkill *rfkill,
 
 /**
  * rfkill_switch_all - Toggle state of all switches of given type
- * @type: type of interfaces to be affeceted
+ * @type: type of interfaces to be affected
  * @state: the new state
  *
- * This function toggles state of all switches of given type unless
- * a specific switch is claimed by userspace in which case it is
- * left alone.
+ * This function toggles the state of all switches of given type,
+ * unless a specific switch is claimed by userspace (in which case,
+ * that switch is left alone).
  */
 void rfkill_switch_all(enum rfkill_type type, enum rfkill_state state)
 {
@@ -216,8 +215,11 @@ void rfkill_switch_all(enum rfkill_type type, enum rfkill_state state)
 	rfkill_states[type] = state;
 
 	list_for_each_entry(rfkill, &rfkill_list, node) {
-		if ((!rfkill->user_claim) && (rfkill->type == type))
+		if ((!rfkill->user_claim) && (rfkill->type == type)) {
+			mutex_lock(&rfkill->mutex);
 			rfkill_toggle_radio(rfkill, state, 0);
+			mutex_unlock(&rfkill->mutex);
+		}
 	}
 
 	mutex_unlock(&rfkill_mutex);
@@ -228,7 +230,7 @@ EXPORT_SYMBOL(rfkill_switch_all);
  * rfkill_epo - emergency power off all transmitters
  *
  * This kicks all rfkill devices to RFKILL_STATE_SOFT_BLOCKED, ignoring
- * everything in its path but rfkill_mutex.
+ * everything in its path but rfkill_mutex and rfkill->mutex.
  */
 void rfkill_epo(void)
 {
@@ -236,7 +238,9 @@ void rfkill_epo(void)
 
 	mutex_lock(&rfkill_mutex);
 	list_for_each_entry(rfkill, &rfkill_list, node) {
+		mutex_lock(&rfkill->mutex);
 		rfkill_toggle_radio(rfkill, RFKILL_STATE_SOFT_BLOCKED, 1);
+		mutex_unlock(&rfkill->mutex);
 	}
 	mutex_unlock(&rfkill_mutex);
 }
@@ -252,7 +256,12 @@ EXPORT_SYMBOL_GPL(rfkill_epo);
  * a notification by the firmware/hardware of the current *real*
  * state of the radio rfkill switch.
  *
- * It may not be called from an atomic context.
+ * Devices which are subject to external changes on their rfkill
+ * state (such as those caused by a hardware rfkill line) MUST
+ * have their driver arrange to call rfkill_force_state() as soon
+ * as possible after such a change.
+ *
+ * This function may not be called from an atomic context.
  */
 int rfkill_force_state(struct rfkill *rfkill, enum rfkill_state state)
 {
@@ -367,6 +376,9 @@ static ssize_t rfkill_claim_store(struct device *dev,
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (rfkill->user_claim_unsupported)
+		return -EOPNOTSUPP;
+
 	/*
 	 * Take the global lock to make sure the kernel is not in
 	 * the middle of rfkill_switch_all
@@ -375,19 +387,17 @@ static ssize_t rfkill_claim_store(struct device *dev,
 	if (error)
 		return error;
 
-	if (rfkill->user_claim_unsupported) {
-		error = -EOPNOTSUPP;
-		goto out_unlock;
-	}
 	if (rfkill->user_claim != claim) {
-		if (!claim)
+		if (!claim) {
+			mutex_lock(&rfkill->mutex);
 			rfkill_toggle_radio(rfkill,
 					    rfkill_states[rfkill->type],
 					    0);
+			mutex_unlock(&rfkill->mutex);
+		}
 		rfkill->user_claim = claim;
 	}
 
-out_unlock:
 	mutex_unlock(&rfkill_mutex);
 
 	return error ? error : count;
@@ -516,8 +526,11 @@ static void rfkill_remove_switch(struct rfkill *rfkill)
 {
 	mutex_lock(&rfkill_mutex);
 	list_del_init(&rfkill->node);
-	rfkill_toggle_radio(rfkill, RFKILL_STATE_SOFT_BLOCKED, 1);
 	mutex_unlock(&rfkill_mutex);
+
+	mutex_lock(&rfkill->mutex);
+	rfkill_toggle_radio(rfkill, RFKILL_STATE_SOFT_BLOCKED, 1);
+	mutex_unlock(&rfkill->mutex);
 }
 
 /**
@@ -526,9 +539,10 @@ static void rfkill_remove_switch(struct rfkill *rfkill)
  * @type: type of the switch (RFKILL_TYPE_*)
  *
  * This function should be called by the network driver when it needs
- * rfkill structure. Once the structure is allocated the driver shoud
- * finish its initialization by setting name, private data, enable_radio
+ * rfkill structure.  Once the structure is allocated the driver should
+ * finish its initialization by setting the name, private data, enable_radio
  * and disable_radio methods and then register it with rfkill_register().
+ *
  * NOTE: If registration fails the structure shoudl be freed by calling
  * rfkill_free() otherwise rfkill_unregister() should be used.
  */
@@ -560,7 +574,7 @@ EXPORT_SYMBOL(rfkill_allocate);
  * rfkill_free - Mark rfkill structure for deletion
  * @rfkill: rfkill structure to be destroyed
  *
- * Decrements reference count of rfkill structure so it is destroyed.
+ * Decrements reference count of the rfkill structure so it is destroyed.
  * Note that rfkill_free() should _not_ be called after rfkill_unregister().
  */
 void rfkill_free(struct rfkill *rfkill)
@@ -585,8 +599,10 @@ static void rfkill_led_trigger_register(struct rfkill *rfkill)
 static void rfkill_led_trigger_unregister(struct rfkill *rfkill)
 {
 #ifdef CONFIG_RFKILL_LEDS
-	if (rfkill->led_trigger.name)
+	if (rfkill->led_trigger.name) {
 		led_trigger_unregister(&rfkill->led_trigger);
+		rfkill->led_trigger.name = NULL;
+	}
 #endif
 }
 
@@ -622,8 +638,8 @@ int rfkill_register(struct rfkill *rfkill)
 
 	error = device_add(dev);
 	if (error) {
-		rfkill_led_trigger_unregister(rfkill);
 		rfkill_remove_switch(rfkill);
+		rfkill_led_trigger_unregister(rfkill);
 		return error;
 	}
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index b7fefff..59eb2cf 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -29,16 +29,16 @@ static struct genl_family nl80211_fam = {
 };
 
 /* internal helper: get drv and dev */
-static int get_drv_dev_by_info_ifindex(struct genl_info *info,
+static int get_drv_dev_by_info_ifindex(struct nlattr **attrs,
 				       struct cfg80211_registered_device **drv,
 				       struct net_device **dev)
 {
 	int ifindex;
 
-	if (!info->attrs[NL80211_ATTR_IFINDEX])
+	if (!attrs[NL80211_ATTR_IFINDEX])
 		return -EINVAL;
 
-	ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+	ifindex = nla_get_u32(attrs[NL80211_ATTR_IFINDEX]);
 	*dev = dev_get_by_index(&init_net, ifindex);
 	if (!*dev)
 		return -ENODEV;
@@ -291,21 +291,31 @@ static int nl80211_dump_interface(struct sk_buff *skb, struct netlink_callback *
 
 	mutex_lock(&cfg80211_drv_mutex);
 	list_for_each_entry(dev, &cfg80211_drv_list, list) {
-		if (++wp_idx < wp_start)
+		if (wp_idx < wp_start) {
+			wp_idx++;
 			continue;
+		}
 		if_idx = 0;
 
 		mutex_lock(&dev->devlist_mtx);
 		list_for_each_entry(wdev, &dev->netdev_list, list) {
-			if (++if_idx < if_start)
+			if (if_idx < if_start) {
+				if_idx++;
 				continue;
+			}
 			if (nl80211_send_iface(skb, NETLINK_CB(cb->skb).pid,
 					       cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					       wdev->netdev) < 0)
-				break;
+					       wdev->netdev) < 0) {
+				mutex_unlock(&dev->devlist_mtx);
+				goto out;
+			}
+			if_idx++;
 		}
 		mutex_unlock(&dev->devlist_mtx);
+
+		wp_idx++;
 	}
+ out:
 	mutex_unlock(&cfg80211_drv_mutex);
 
 	cb->args[0] = wp_idx;
@@ -321,7 +331,7 @@ static int nl80211_get_interface(struct sk_buff *skb, struct genl_info *info)
 	struct net_device *netdev;
 	int err;
 
-	err = get_drv_dev_by_info_ifindex(info, &dev, &netdev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &dev, &netdev);
 	if (err)
 		return err;
 
@@ -392,7 +402,7 @@ static int nl80211_set_interface(struct sk_buff *skb, struct genl_info *info)
 	} else
 		return -EINVAL;
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 	ifindex = dev->ifindex;
@@ -477,7 +487,7 @@ static int nl80211_del_interface(struct sk_buff *skb, struct genl_info *info)
 	int ifindex, err;
 	struct net_device *dev;
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 	ifindex = dev->ifindex;
@@ -545,7 +555,7 @@ static int nl80211_get_key(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_MAC])
 		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -618,7 +628,7 @@ static int nl80211_set_key(struct sk_buff *skb, struct genl_info *info)
 	if (!info->attrs[NL80211_ATTR_KEY_DEFAULT])
 		return -EINVAL;
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -699,7 +709,7 @@ static int nl80211_new_key(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -735,7 +745,7 @@ static int nl80211_del_key(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_MAC])
 		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -764,7 +774,7 @@ static int nl80211_addset_beacon(struct sk_buff *skb, struct genl_info *info)
 	struct beacon_parameters params;
 	int haveinfo = 0;
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -843,7 +853,7 @@ static int nl80211_del_beacon(struct sk_buff *skb, struct genl_info *info)
 	int err;
 	struct net_device *dev;
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -937,67 +947,78 @@ static int nl80211_send_station(struct sk_buff *msg, u32 pid, u32 seq,
 }
 
 static int nl80211_dump_station(struct sk_buff *skb,
-		struct netlink_callback *cb)
+				struct netlink_callback *cb)
 {
-	int wp_idx = 0;
-	int if_idx = 0;
-	int sta_idx = cb->args[2];
-	int wp_start = cb->args[0];
-	int if_start = cb->args[1];
 	struct station_info sinfo;
 	struct cfg80211_registered_device *dev;
-	struct wireless_dev *wdev;
+	struct net_device *netdev;
 	u8 mac_addr[ETH_ALEN];
+	int ifidx = cb->args[0];
+	int sta_idx = cb->args[1];
 	int err;
-	int exit = 0;
 
-	/* TODO: filter by device */
-	mutex_lock(&cfg80211_drv_mutex);
-	list_for_each_entry(dev, &cfg80211_drv_list, list) {
-		if (exit)
+	if (!ifidx) {
+		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
+				  nl80211_fam.attrbuf, nl80211_fam.maxattr,
+				  nl80211_policy);
+		if (err)
+			return err;
+
+		if (!nl80211_fam.attrbuf[NL80211_ATTR_IFINDEX])
+			return -EINVAL;
+
+		ifidx = nla_get_u32(nl80211_fam.attrbuf[NL80211_ATTR_IFINDEX]);
+		if (!ifidx)
+			return -EINVAL;
+	}
+
+	netdev = dev_get_by_index(&init_net, ifidx);
+	if (!netdev)
+		return -ENODEV;
+
+	dev = cfg80211_get_dev_from_ifindex(ifidx);
+	if (IS_ERR(dev)) {
+		err = PTR_ERR(dev);
+		goto out_put_netdev;
+	}
+
+	if (!dev->ops->dump_station) {
+		err = -ENOSYS;
+		goto out_err;
+	}
+
+	rtnl_lock();
+
+	while (1) {
+		err = dev->ops->dump_station(&dev->wiphy, netdev, sta_idx,
+					     mac_addr, &sinfo);
+		if (err == -ENOENT)
 			break;
-		if (++wp_idx < wp_start)
-			continue;
-		if_idx = 0;
+		if (err)
+			goto out_err_rtnl;
 
-		mutex_lock(&dev->devlist_mtx);
-		list_for_each_entry(wdev, &dev->netdev_list, list) {
-			if (exit)
-				break;
-			if (++if_idx < if_start)
-				continue;
-			if (!dev->ops->dump_station)
-				continue;
+		if (nl80211_send_station(skb,
+				NETLINK_CB(cb->skb).pid,
+				cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				netdev, mac_addr,
+				&sinfo) < 0)
+			goto out;
 
-			for (;; ++sta_idx) {
-				rtnl_lock();
-				err = dev->ops->dump_station(&dev->wiphy,
-						wdev->netdev, sta_idx, mac_addr,
-						&sinfo);
-				rtnl_unlock();
-				if (err) {
-					sta_idx = 0;
-					break;
-				}
-				if (nl80211_send_station(skb,
-						NETLINK_CB(cb->skb).pid,
-						cb->nlh->nlmsg_seq, NLM_F_MULTI,
-						wdev->netdev, mac_addr,
-						&sinfo) < 0) {
-					exit = 1;
-					break;
-				}
-			}
-		}
-		mutex_unlock(&dev->devlist_mtx);
+		sta_idx++;
 	}
-	mutex_unlock(&cfg80211_drv_mutex);
 
-	cb->args[0] = wp_idx;
-	cb->args[1] = if_idx;
-	cb->args[2] = sta_idx;
 
-	return skb->len;
+ out:
+	cb->args[1] = sta_idx;
+	err = skb->len;
+ out_err_rtnl:
+	rtnl_unlock();
+ out_err:
+	cfg80211_put_dev(dev);
+ out_put_netdev:
+	dev_put(netdev);
+
+	return err;
 }
 
 static int nl80211_get_station(struct sk_buff *skb, struct genl_info *info)
@@ -1016,7 +1037,7 @@ static int nl80211_get_station(struct sk_buff *skb, struct genl_info *info)
 
 	mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -1112,7 +1133,7 @@ static int nl80211_set_station(struct sk_buff *skb, struct genl_info *info)
 		params.plink_action =
 		    nla_get_u8(info->attrs[NL80211_ATTR_STA_PLINK_ACTION]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -1172,7 +1193,7 @@ static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)
 				&params.station_flags))
 		return -EINVAL;
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -1207,7 +1228,7 @@ static int nl80211_del_station(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_MAC])
 		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -1277,68 +1298,78 @@ static int nl80211_send_mpath(struct sk_buff *msg, u32 pid, u32 seq,
 }
 
 static int nl80211_dump_mpath(struct sk_buff *skb,
-		struct netlink_callback *cb)
+			      struct netlink_callback *cb)
 {
-	int wp_idx = 0;
-	int if_idx = 0;
-	int sta_idx = cb->args[2];
-	int wp_start = cb->args[0];
-	int if_start = cb->args[1];
 	struct mpath_info pinfo;
 	struct cfg80211_registered_device *dev;
-	struct wireless_dev *wdev;
+	struct net_device *netdev;
 	u8 dst[ETH_ALEN];
 	u8 next_hop[ETH_ALEN];
+	int ifidx = cb->args[0];
+	int path_idx = cb->args[1];
 	int err;
-	int exit = 0;
 
-	/* TODO: filter by device */
-	mutex_lock(&cfg80211_drv_mutex);
-	list_for_each_entry(dev, &cfg80211_drv_list, list) {
-		if (exit)
+	if (!ifidx) {
+		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
+				  nl80211_fam.attrbuf, nl80211_fam.maxattr,
+				  nl80211_policy);
+		if (err)
+			return err;
+
+		if (!nl80211_fam.attrbuf[NL80211_ATTR_IFINDEX])
+			return -EINVAL;
+
+		ifidx = nla_get_u32(nl80211_fam.attrbuf[NL80211_ATTR_IFINDEX]);
+		if (!ifidx)
+			return -EINVAL;
+	}
+
+	netdev = dev_get_by_index(&init_net, ifidx);
+	if (!netdev)
+		return -ENODEV;
+
+	dev = cfg80211_get_dev_from_ifindex(ifidx);
+	if (IS_ERR(dev)) {
+		err = PTR_ERR(dev);
+		goto out_put_netdev;
+	}
+
+	if (!dev->ops->dump_mpath) {
+		err = -ENOSYS;
+		goto out_err;
+	}
+
+	rtnl_lock();
+
+	while (1) {
+		err = dev->ops->dump_mpath(&dev->wiphy, netdev, path_idx,
+					   dst, next_hop, &pinfo);
+		if (err == -ENOENT)
 			break;
-		if (++wp_idx < wp_start)
-			continue;
-		if_idx = 0;
+		if (err)
+			goto out_err_rtnl;
 
-		mutex_lock(&dev->devlist_mtx);
-		list_for_each_entry(wdev, &dev->netdev_list, list) {
-			if (exit)
-				break;
-			if (++if_idx < if_start)
-				continue;
-			if (!dev->ops->dump_mpath)
-				continue;
+		if (nl80211_send_mpath(skb, NETLINK_CB(cb->skb).pid,
+				       cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				       netdev, dst, next_hop,
+				       &pinfo) < 0)
+			goto out;
 
-			for (;; ++sta_idx) {
-				rtnl_lock();
-				err = dev->ops->dump_mpath(&dev->wiphy,
-						wdev->netdev, sta_idx, dst,
-						next_hop, &pinfo);
-				rtnl_unlock();
-				if (err) {
-					sta_idx = 0;
-					break;
-				}
-				if (nl80211_send_mpath(skb,
-						NETLINK_CB(cb->skb).pid,
-						cb->nlh->nlmsg_seq, NLM_F_MULTI,
-						wdev->netdev, dst, next_hop,
-						&pinfo) < 0) {
-					exit = 1;
-					break;
-				}
-			}
-		}
-		mutex_unlock(&dev->devlist_mtx);
+		path_idx++;
 	}
-	mutex_unlock(&cfg80211_drv_mutex);
 
-	cb->args[0] = wp_idx;
-	cb->args[1] = if_idx;
-	cb->args[2] = sta_idx;
 
-	return skb->len;
+ out:
+	cb->args[1] = path_idx;
+	err = skb->len;
+ out_err_rtnl:
+	rtnl_unlock();
+ out_err:
+	cfg80211_put_dev(dev);
+ out_put_netdev:
+	dev_put(netdev);
+
+	return err;
 }
 
 static int nl80211_get_mpath(struct sk_buff *skb, struct genl_info *info)
@@ -1358,7 +1389,7 @@ static int nl80211_get_mpath(struct sk_buff *skb, struct genl_info *info)
 
 	dst = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -1411,7 +1442,7 @@ static int nl80211_set_mpath(struct sk_buff *skb, struct genl_info *info)
 	dst = nla_data(info->attrs[NL80211_ATTR_MAC]);
 	next_hop = nla_data(info->attrs[NL80211_ATTR_MPATH_NEXT_HOP]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -1446,7 +1477,7 @@ static int nl80211_new_mpath(struct sk_buff *skb, struct genl_info *info)
 	dst = nla_data(info->attrs[NL80211_ATTR_MAC]);
 	next_hop = nla_data(info->attrs[NL80211_ATTR_MPATH_NEXT_HOP]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
@@ -1475,7 +1506,7 @@ static int nl80211_del_mpath(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_MAC])
 		dst = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
 	if (err)
 		return err;
 
-- 
John W. Linville
linville@tuxdriver.com
