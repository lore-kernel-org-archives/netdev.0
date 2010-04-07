From: Dmytro Milinevskyy <milinevskyy@gmail.com>
Subject: [PATCH] [ath5k][leds] Ability to disable leds support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Wed, 7 Apr 2010 21:58:29 +0300
Message-ID: <4be26029.13125e0a.66ce.ffffad95@mx.google.com>
Cc: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lukas Turek <8an@praha12.net>,
	Mark Hindley <mark@hindley.org.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jiri Kosina <jkosina@suse.cz>, Kalle Valo <kalle.valo@iki.fi>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	Luca Verdesca <magooz@salug.it>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmytro Milinevskyy <milinevskyy@gmail.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <git-owner@vger.kernel.org>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Here is the patch to disable ath5k leds support on build stage.
However if the leds support was enabled do not force selection of 802.11 leds layer.

---
 drivers/net/wireless/ath/ath5k/Kconfig  |   10 +++++++---
 drivers/net/wireless/ath/ath5k/Makefile |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h  |   11 ++++++-----
 drivers/net/wireless/ath/ath5k/attach.c |    2 ++
 drivers/net/wireless/ath/ath5k/base.c   |   18 ++++++++++++++++++
 drivers/net/wireless/ath/ath5k/base.h   |   12 ++++++++++++
 drivers/net/wireless/ath/ath5k/gpio.c   |    2 ++
 drivers/net/wireless/ath/ath5k/led.c    |    9 +++++++++
 8 files changed, 57 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/Kconfig b/drivers/net/wireless/ath/ath5k/Kconfig
index eb83b7b..6b5677e 100644
--- a/drivers/net/wireless/ath/ath5k/Kconfig
+++ b/drivers/net/wireless/ath/ath5k/Kconfig
@@ -1,9 +1,6 @@
 config ATH5K
 	tristate "Atheros 5xxx wireless cards support"
 	depends on PCI && MAC80211
-	select MAC80211_LEDS
-	select LEDS_CLASS
-	select NEW_LEDS
 	---help---
 	  This module adds support for wireless adapters based on
 	  Atheros 5xxx chipset.
@@ -18,6 +15,13 @@ config ATH5K
 	  If you choose to build a module, it'll be called ath5k. Say M if
 	  unsure.
 
+
+config ATH5K_LEDS
+	tristate "Atheros 5xxx wireless cards LEDs support"
+	depends on ATH5K
+	---help---
+	  Atheros 5xxx LED support.
+
 config ATH5K_DEBUG
 	bool "Atheros 5xxx debugging"
 	depends on ATH5K
diff --git a/drivers/net/wireless/ath/ath5k/Makefile b/drivers/net/wireless/ath/ath5k/Makefile
index 090dc6d..fd36145 100644
--- a/drivers/net/wireless/ath/ath5k/Makefile
+++ b/drivers/net/wireless/ath/ath5k/Makefile
@@ -10,7 +10,7 @@ ath5k-y				+= phy.o
 ath5k-y				+= reset.o
 ath5k-y				+= attach.o
 ath5k-y				+= base.o
-ath5k-y				+= led.o
 ath5k-y				+= rfkill.o
 ath5k-$(CONFIG_ATH5K_DEBUG)	+= debug.o
+ath5k-$(CONFIG_ATH5K_LEDS) += led.o
 obj-$(CONFIG_ATH5K)		+= ath5k.o
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index ac67f02..8285c07 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -929,6 +929,7 @@ enum ath5k_power_mode {
 	AR5K_PM_NETWORK_SLEEP,
 };
 
+#ifdef CONFIG_ATH5K_LEDS
 /*
  * These match net80211 definitions (not used in
  * mac80211).
@@ -939,11 +940,7 @@ enum ath5k_power_mode {
 #define AR5K_LED_AUTH	2 /*IEEE80211_S_AUTH*/
 #define AR5K_LED_ASSOC	3 /*IEEE80211_S_ASSOC*/
 #define AR5K_LED_RUN	4 /*IEEE80211_S_RUN*/
-
-/* GPIO-controlled software LED */
-#define AR5K_SOFTLED_PIN	0
-#define AR5K_SOFTLED_ON		0
-#define AR5K_SOFTLED_OFF	1
+#endif
 
 /*
  * Chipset capabilities -see ath5k_hw_get_capability-
@@ -1161,11 +1158,13 @@ struct ath5k_hw {
 extern int ath5k_hw_attach(struct ath5k_softc *sc);
 extern void ath5k_hw_detach(struct ath5k_hw *ah);
 
+#ifdef CONFIG_ATH5K_LEDS
 /* LED functions */
 extern int ath5k_init_leds(struct ath5k_softc *sc);
 extern void ath5k_led_enable(struct ath5k_softc *sc);
 extern void ath5k_led_off(struct ath5k_softc *sc);
 extern void ath5k_unregister_leds(struct ath5k_softc *sc);
+#endif
 
 /* Reset Functions */
 extern int ath5k_hw_nic_wakeup(struct ath5k_hw *ah, int flags, bool initial);
@@ -1259,7 +1258,9 @@ extern int ath5k_hw_set_slot_time(struct ath5k_hw *ah, unsigned int slot_time);
 extern int ath5k_hw_init_desc_functions(struct ath5k_hw *ah);
 
 /* GPIO Functions */
+#ifdef CONFIG_ATH5K_LEDS
 extern void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state);
+#endif
 extern int ath5k_hw_set_gpio_input(struct ath5k_hw *ah, u32 gpio);
 extern int ath5k_hw_set_gpio_output(struct ath5k_hw *ah, u32 gpio);
 extern u32 ath5k_hw_get_gpio(struct ath5k_hw *ah, u32 gpio);
diff --git a/drivers/net/wireless/ath/ath5k/attach.c b/drivers/net/wireless/ath/ath5k/attach.c
index dc0786c..c27f741 100644
--- a/drivers/net/wireless/ath/ath5k/attach.c
+++ b/drivers/net/wireless/ath/ath5k/attach.c
@@ -334,8 +334,10 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 
 	ath5k_hw_init_nfcal_hist(ah);
 
+#ifdef CONFIG_ATH5K_LEDS
 	/* turn on HW LEDs */
 	ath5k_hw_set_ledstate(ah, AR5K_LED_INIT);
+#endif
 
 	return 0;
 err_free:
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 3abbe75..db8ca05 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -709,18 +709,22 @@ ath5k_pci_remove(struct pci_dev *pdev)
 #ifdef CONFIG_PM
 static int ath5k_pci_suspend(struct device *dev)
 {
+#ifdef CONFIG_ATH5K_LEDS
 	struct ieee80211_hw *hw = pci_get_drvdata(to_pci_dev(dev));
 	struct ath5k_softc *sc = hw->priv;
 
 	ath5k_led_off(sc);
+#endif
 	return 0;
 }
 
 static int ath5k_pci_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
+#ifdef CONFIG_ATH5K_LEDS
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct ath5k_softc *sc = hw->priv;
+#endif
 
 	/*
 	 * Suspend/Resume resets the PCI configuration space, so we have to
@@ -729,7 +733,9 @@ static int ath5k_pci_resume(struct device *dev)
 	 */
 	pci_write_config_byte(pdev, 0x41, 0);
 
+#ifdef CONFIG_ATH5K_LEDS
 	ath5k_led_enable(sc);
+#endif
 	return 0;
 }
 #endif /* CONFIG_PM */
@@ -859,7 +865,9 @@ ath5k_attach(struct pci_dev *pdev, struct ieee80211_hw *hw)
 	if (!ath_is_world_regd(regulatory))
 		regulatory_hint(hw->wiphy, regulatory->alpha2);
 
+#ifdef CONFIG_ATH5K_LEDS
 	ath5k_init_leds(sc);
+#endif
 
 	return 0;
 err_queues:
@@ -894,7 +902,9 @@ ath5k_detach(struct pci_dev *pdev, struct ieee80211_hw *hw)
 	ath5k_desc_free(sc, pdev);
 	ath5k_txq_release(sc);
 	ath5k_hw_release_tx_queue(sc->ah, sc->bhalq);
+#ifdef CONFIG_ATH5K_LEDS
 	ath5k_unregister_leds(sc);
+#endif
 
 	/*
 	 * NB: can't reclaim these until after ieee80211_ifdetach
@@ -2470,7 +2480,9 @@ ath5k_stop_locked(struct ath5k_softc *sc)
 	ieee80211_stop_queues(sc->hw);
 
 	if (!test_bit(ATH_STAT_INVALID, sc->status)) {
+#ifdef CONFIG_ATH5K_LEDS
 		ath5k_led_off(sc);
+#endif
 		ath5k_hw_set_imr(ah, 0);
 		synchronize_irq(sc->pdev->irq);
 	}
@@ -3246,8 +3258,10 @@ static void ath5k_bss_info_changed(struct ieee80211_hw *hw,
 		sc->assoc = bss_conf->assoc;
 		if (sc->opmode == NL80211_IFTYPE_STATION)
 			set_beacon_filter(hw, sc->assoc);
+#ifdef CONFIG_ATH5K_LEDS
 		ath5k_hw_set_ledstate(sc->ah, sc->assoc ?
 			AR5K_LED_ASSOC : AR5K_LED_INIT);
+#endif
 		if (bss_conf->assoc) {
 			ATH5K_DBG(sc, ATH5K_DEBUG_ANY,
 				  "Bss Info ASSOC %d, bssid: %pM\n",
@@ -3277,16 +3291,20 @@ static void ath5k_bss_info_changed(struct ieee80211_hw *hw,
 
 static void ath5k_sw_scan_start(struct ieee80211_hw *hw)
 {
+#ifdef CONFIG_ATH5K_LEDS
 	struct ath5k_softc *sc = hw->priv;
 	if (!sc->assoc)
 		ath5k_hw_set_ledstate(sc->ah, AR5K_LED_SCAN);
+#endif
 }
 
 static void ath5k_sw_scan_complete(struct ieee80211_hw *hw)
 {
+#ifdef CONFIG_ATH5K_LEDS
 	struct ath5k_softc *sc = hw->priv;
 	ath5k_hw_set_ledstate(sc->ah, sc->assoc ?
 		AR5K_LED_ASSOC : AR5K_LED_INIT);
+#endif
 }
 
 /**
diff --git a/drivers/net/wireless/ath/ath5k/base.h b/drivers/net/wireless/ath/ath5k/base.h
index 7e1a88a..19208a7 100644
--- a/drivers/net/wireless/ath/ath5k/base.h
+++ b/drivers/net/wireless/ath/ath5k/base.h
@@ -85,15 +85,21 @@ struct ath5k_txq {
 
 #define ATH5K_LED_MAX_NAME_LEN 31
 
+#ifdef CONFIG_ATH5K_LEDS
 /*
  * State for LED triggers
  */
 struct ath5k_led
 {
+#ifdef CONFIG_LEDS_CLASS
 	char name[ATH5K_LED_MAX_NAME_LEN + 1];	/* name of the LED in sysfs */
+#endif
 	struct ath5k_softc *sc;			/* driver state */
+#ifdef CONFIG_LEDS_CLASS
 	struct led_classdev led_dev;		/* led classdev */
+#endif
 };
+#endif
 
 /* Rfkill */
 struct ath5k_rfkill {
@@ -154,8 +160,10 @@ struct ath5k_softc {
 
 	u8			bssidmask[ETH_ALEN];
 
+#ifdef CONFIG_ATH5K_LEDS
 	unsigned int		led_pin,	/* GPIO pin for driving LED */
 				led_on;		/* pin setting for LED on */
+#endif
 
 	struct tasklet_struct	restq;		/* reset tasklet */
 
@@ -164,7 +172,9 @@ struct ath5k_softc {
 	spinlock_t		rxbuflock;
 	u32			*rxlink;	/* link ptr in last RX desc */
 	struct tasklet_struct	rxtq;		/* rx intr tasklet */
+#ifdef CONFIG_ATH5K_LEDS
 	struct ath5k_led	rx_led;		/* rx led */
+#endif
 
 	struct list_head	txbuf;		/* transmit buffer */
 	spinlock_t		txbuflock;
@@ -172,7 +182,9 @@ struct ath5k_softc {
 	struct ath5k_txq	txqs[AR5K_NUM_TX_QUEUES];	/* tx queues */
 	struct ath5k_txq	*txq;		/* main tx queue */
 	struct tasklet_struct	txtq;		/* tx intr tasklet */
+#ifdef CONFIG_ATH5K_LEDS
 	struct ath5k_led	tx_led;		/* tx led */
+#endif
 
 	struct ath5k_rfkill	rf_kill;
 
diff --git a/drivers/net/wireless/ath/ath5k/gpio.c b/drivers/net/wireless/ath/ath5k/gpio.c
index 64a27e7..9e757b3 100644
--- a/drivers/net/wireless/ath/ath5k/gpio.c
+++ b/drivers/net/wireless/ath/ath5k/gpio.c
@@ -25,6 +25,7 @@
 #include "debug.h"
 #include "base.h"
 
+#ifdef CONFIG_ATH5K_LEDS
 /*
  * Set led state
  */
@@ -76,6 +77,7 @@ void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state)
 	else
 		AR5K_REG_ENABLE_BITS(ah, AR5K_PCICFG, led_5210);
 }
+#endif
 
 /*
  * Set GPIO inputs
diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index 67aa52e..df8e8d2 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -121,6 +121,7 @@ ath5k_led_brightness_set(struct led_classdev *led_dev,
 		ath5k_led_on(led->sc);
 }
 
+#ifdef CONFIG_LEDS_CLASS
 static int
 ath5k_register_led(struct ath5k_softc *sc, struct ath5k_led *led,
 		   const char *name, char *trigger)
@@ -140,13 +141,16 @@ ath5k_register_led(struct ath5k_softc *sc, struct ath5k_led *led,
 	}
 	return err;
 }
+#endif
 
 static void
 ath5k_unregister_led(struct ath5k_led *led)
 {
 	if (!led->sc)
 		return;
+#ifdef CONFIG_LEDS_CLASS
 	led_classdev_unregister(&led->led_dev);
+#endif
 	ath5k_led_off(led->sc);
 	led->sc = NULL;
 }
@@ -177,6 +181,7 @@ int ath5k_init_leds(struct ath5k_softc *sc)
 
 	ath5k_led_enable(sc);
 
+#ifdef CONFIG_LEDS_CLASS
 	snprintf(name, sizeof(name), "ath5k-%s::rx", wiphy_name(hw->wiphy));
 	ret = ath5k_register_led(sc, &sc->rx_led, name,
 		ieee80211_get_rx_led_name(hw));
@@ -186,6 +191,10 @@ int ath5k_init_leds(struct ath5k_softc *sc)
 	snprintf(name, sizeof(name), "ath5k-%s::tx", wiphy_name(hw->wiphy));
 	ret = ath5k_register_led(sc, &sc->tx_led, name,
 		ieee80211_get_tx_led_name(hw));
+#else
+    sc->rx_led.sc = sc;
+    sc->tx_led.sc = sc;
+#endif
 out:
 	return ret;
 }
-- 
1.7.1
