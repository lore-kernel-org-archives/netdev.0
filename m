From: Joe Perches <joe@perches.com>
Subject: [PATCH] ath: Convert ath_print(..,
	ATH_DBG_FATAL to ath_err
Date: Wed,  1 Dec 2010 11:08:34 -0800
Message-ID: <dc54885b9f2f0fd51e17ca52227c5f816eac0cfc.1291230236.git.joe@perches.com>
References: <d2a73495a7295cbd01ffd820761f538bc301f6aa.1291224405.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	Peter Stuge <peter@stuge.se>
To: Felix Fietkau <nbd@openwrt.org>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubr
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <d2a73495a7295cbd01ffd820761f538bc301f6aa.1291224405.git.joe@perches.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

So these errors are always emitted at KERN_ERR level.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/ahb.c            |    7 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c     |   12 +---
 drivers/net/wireless/ath/ath9k/ar9002_hw.c      |    6 +-
 drivers/net/wireless/ath/ath9k/beacon.c         |   14 ++---
 drivers/net/wireless/ath/ath9k/eeprom_4k.c      |   13 ++---
 drivers/net/wireless/ath/ath9k/eeprom_9287.c    |   13 ++---
 drivers/net/wireless/ath/ath9k/eeprom_def.c     |   14 ++---
 drivers/net/wireless/ath/ath9k/gpio.c           |    4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c |    4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c   |   27 +++-----
 drivers/net/wireless/ath/ath9k/htc_drv_main.c   |   59 ++++++++---------
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c   |   25 +++-----
 drivers/net/wireless/ath/ath9k/hw.c             |   78 ++++++++++-------------
 drivers/net/wireless/ath/ath9k/init.c           |    6 +-
 drivers/net/wireless/ath/ath9k/mac.c            |   31 ++++-----
 drivers/net/wireless/ath/ath9k/main.c           |   56 +++++++----------
 drivers/net/wireless/ath/ath9k/pci.c            |    7 +-
 drivers/net/wireless/ath/ath9k/rc.c             |    4 +-
 drivers/net/wireless/ath/ath9k/recv.c           |   15 ++---
 drivers/net/wireless/ath/ath9k/xmit.c           |   30 ++++-----
 drivers/net/wireless/ath/key.c                  |   15 ++---
 21 files changed, 186 insertions(+), 254 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ahb.c b/drivers/net/wireless/ath/ath9k/ahb.c
index 1a984b0..25a6e44 100644
--- a/drivers/net/wireless/ath/ath9k/ahb.c
+++ b/drivers/net/wireless/ath/ath9k/ahb.c
@@ -35,10 +35,9 @@ static bool ath_ahb_eeprom_read(struct ath_common *common, u32 off, u16 *data)
 
 	pdata = (struct ath9k_platform_data *) pdev->dev.platform_data;
 	if (off >= (ARRAY_SIZE(pdata->eeprom_data))) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "%s: flash read failed, offset %08x "
-			  "is out of range\n",
-			  __func__, off);
+		ath_err(common,
+			"%s: flash read failed, offset %08x is out of range\n",
+			__func__, off);
 		return false;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/ar5008_phy.c b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
index 06e34d2..9af9f23 100644
--- a/drivers/net/wireless/ath/ath9k/ar5008_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
@@ -173,8 +173,7 @@ static int ar5008_hw_set_channel(struct ath_hw *ah, struct ath9k_channel *chan)
 			channelSel = ((freq - 704) * 2 - 3040) / 10;
 			bModeSynth = 1;
 		} else {
-			ath_print(common, ATH_DBG_FATAL,
-				  "Invalid channel %u MHz\n", freq);
+			ath_err(common, "Invalid channel %u MHz\n", freq);
 			return -EINVAL;
 		}
 
@@ -206,8 +205,7 @@ static int ar5008_hw_set_channel(struct ath_hw *ah, struct ath9k_channel *chan)
 		channelSel = ath9k_hw_reverse_bits((freq - 4800) / 5, 8);
 		aModeRefSel = ath9k_hw_reverse_bits(1, 2);
 	} else {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Invalid channel %u MHz\n", freq);
+		ath_err(common, "Invalid channel %u MHz\n", freq);
 		return -EINVAL;
 	}
 
@@ -448,8 +446,7 @@ static int ar5008_hw_rf_alloc_ext_banks(struct ath_hw *ah)
 #define ATH_ALLOC_BANK(bank, size) do { \
 		bank = kzalloc((sizeof(u32) * size), GFP_KERNEL); \
 		if (!bank) { \
-			ath_print(common, ATH_DBG_FATAL, \
-				  "Cannot allocate RF banks\n"); \
+			ath_err(common, "Cannot allocate RF banks\n"); \
 			return -ENOMEM; \
 		} \
 	} while (0);
@@ -879,8 +876,7 @@ static int ar5008_hw_process_ini(struct ath_hw *ah,
 
 	/* Write analog registers */
 	if (!ath9k_hw_set_rf_regs(ah, chan, freqIndex)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-			  "ar5416SetRfRegs failed\n");
+		ath_err(ath9k_hw_common(ah), "ar5416SetRfRegs failed\n");
 		return -EIO;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_hw.c b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
index 48261b7..7d5cb20 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
@@ -494,9 +494,9 @@ int ar9002_hw_rf_claim(struct ath_hw *ah)
 	case AR_RAD2122_SREV_MAJOR:
 		break;
 	default:
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-			  "Radio Chip Rev 0x%02X not supported\n",
-			  val & AR_RADIO_SREV_MAJOR);
+		ath_err(ath9k_hw_common(ah),
+			"Radio Chip Rev 0x%02X not supported\n",
+			val & AR_RADIO_SREV_MAJOR);
 		return -EOPNOTSUPP;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless/ath/ath9k/beacon.c
index 30724a4..8924612 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -46,8 +46,8 @@ int ath_beaconq_config(struct ath_softc *sc)
 	}
 
 	if (!ath9k_hw_set_txq_props(ah, sc->beacon.beaconq, &qi)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to update h/w beacon queue parameters\n");
+		ath_err(common,
+			"Unable to update h/w beacon queue parameters\n");
 		return 0;
 	} else {
 		ath9k_hw_resettxqueue(ah, sc->beacon.beaconq);
@@ -188,8 +188,7 @@ static struct ath_buf *ath_beacon_generate(struct ieee80211_hw *hw,
 		dev_kfree_skb_any(skb);
 		bf->bf_mpdu = NULL;
 		bf->bf_buf_addr = 0;
-		ath_print(common, ATH_DBG_FATAL,
-			  "dma_mapping_error on beaconing\n");
+		ath_err(common, "dma_mapping_error on beaconing\n");
 		return NULL;
 	}
 
@@ -323,8 +322,7 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 		dev_kfree_skb_any(skb);
 		bf->bf_mpdu = NULL;
 		bf->bf_buf_addr = 0;
-		ath_print(common, ATH_DBG_FATAL,
-			  "dma_mapping_error on beacon alloc\n");
+		ath_err(common, "dma_mapping_error on beacon alloc\n");
 		return -ENOMEM;
 	}
 
@@ -468,8 +466,8 @@ void ath_beacon_tasklet(unsigned long data)
 		 * are still pending on the queue.
 		 */
 		if (!ath9k_hw_stoptxdma(ah, sc->beacon.beaconq)) {
-			ath_print(common, ATH_DBG_FATAL,
-				"beacon queue %u did not stop?\n", sc->beacon.beaconq);
+			ath_err(common, "beacon queue %u did not stop?\n",
+				sc->beacon.beaconq);
 		}
 
 		/* NB: cabq traffic should already be queued and primed */
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_4k.c b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
index c2481b3..f74692d 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_4k.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
@@ -69,8 +69,7 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 	if (!ath9k_hw_use_flash(ah)) {
 		if (!ath9k_hw_nvram_read(common, AR5416_EEPROM_MAGIC_OFFSET,
 					 &magic)) {
-			ath_print(common, ATH_DBG_FATAL,
-				  "Reading Magic # failed\n");
+			ath_err(common, "Reading Magic # failed\n");
 			return false;
 		}
 
@@ -90,9 +89,8 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 					eepdata++;
 				}
 			} else {
-				ath_print(common, ATH_DBG_FATAL,
-					  "Invalid EEPROM Magic. "
-					  "endianness mismatch.\n");
+				ath_err(common,
+					"Invalid EEPROM Magic. endianness mismatch.\n");
 				return -EINVAL;
 			}
 		}
@@ -163,9 +161,8 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 
 	if (sum != 0xffff || ah->eep_ops->get_eeprom_ver(ah) != AR5416_EEP_VER ||
 	    ah->eep_ops->get_eeprom_rev(ah) < AR5416_EEP_NO_BACK_VER) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
-			  sum, ah->eep_ops->get_eeprom_ver(ah));
+		ath_err(common, "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
+			sum, ah->eep_ops->get_eeprom_ver(ah));
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index bcb9ed3..9308b68 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -72,8 +72,7 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 	if (!ath9k_hw_use_flash(ah)) {
 		if (!ath9k_hw_nvram_read(common, AR5416_EEPROM_MAGIC_OFFSET,
 					 &magic)) {
-			ath_print(common, ATH_DBG_FATAL,
-				  "Reading Magic # failed\n");
+			ath_err(common, "Reading Magic # failed\n");
 			return false;
 		}
 
@@ -93,9 +92,8 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 					eepdata++;
 				}
 			} else {
-				ath_print(common, ATH_DBG_FATAL,
-					  "Invalid EEPROM Magic. "
-					  "Endianness mismatch.\n");
+				ath_err(common,
+					"Invalid EEPROM Magic. Endianness mismatch.\n");
 				return -EINVAL;
 			}
 		}
@@ -160,9 +158,8 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 
 	if (sum != 0xffff || ah->eep_ops->get_eeprom_ver(ah) != AR9287_EEP_VER
 	    || ah->eep_ops->get_eeprom_rev(ah) < AR5416_EEP_NO_BACK_VER) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
-			   sum, ah->eep_ops->get_eeprom_ver(ah));
+		ath_err(common, "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
+			sum, ah->eep_ops->get_eeprom_ver(ah));
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index e94216e..d95f4c2 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -96,8 +96,8 @@ static bool ath9k_hw_def_fill_eeprom(struct ath_hw *ah)
 	for (addr = 0; addr < SIZE_EEPROM_DEF; addr++) {
 		if (!ath9k_hw_nvram_read(common, addr + ar5416_eep_start_loc,
 					 eep_data)) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-				  "Unable to read eeprom region\n");
+			ath_err(ath9k_hw_common(ah),
+				"Unable to read eeprom region\n");
 			return false;
 		}
 		eep_data++;
@@ -117,7 +117,7 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 	int i, addr, size;
 
 	if (!ath9k_hw_nvram_read(common, AR5416_EEPROM_MAGIC_OFFSET, &magic)) {
-		ath_print(common, ATH_DBG_FATAL, "Reading Magic # failed\n");
+		ath_err(common, "Reading Magic # failed\n");
 		return false;
 	}
 
@@ -139,9 +139,8 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 					eepdata++;
 				}
 			} else {
-				ath_print(common, ATH_DBG_FATAL,
-					  "Invalid EEPROM Magic. "
-					  "Endianness mismatch.\n");
+				ath_err(common,
+					"Invalid EEPROM Magic. Endianness mismatch.\n");
 				return -EINVAL;
 			}
 		}
@@ -216,8 +215,7 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 
 	if (sum != 0xffff || ah->eep_ops->get_eeprom_ver(ah) != AR5416_EEP_VER ||
 	    ah->eep_ops->get_eeprom_rev(ah) < AR5416_EEP_NO_BACK_VER) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
+		ath_err(common, "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
 			sum, ah->eep_ops->get_eeprom_ver(ah));
 		return -EINVAL;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/ath/ath9k/gpio.c
index 6a1a482..2b1b583 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -103,8 +103,8 @@ static int ath_register_led(struct ath_softc *sc, struct ath_led *led,
 
 	ret = led_classdev_register(wiphy_dev(sc->hw->wiphy), &led->led_cdev);
 	if (ret)
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
-			  "Failed to register led:%s", led->name);
+		ath_err(ath9k_hw_common(sc->sc_ah),
+			"Failed to register led:%s", led->name);
 	else
 		led->registered = 1;
 	return ret;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c b/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
index 1b72aa4..dd9514e 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
@@ -246,8 +246,8 @@ void ath9k_htc_beaconq_config(struct ath9k_htc_priv *priv)
 	qi.tqi_cwmax = qi_be.tqi_cwmax;
 
 	if (!ath9k_hw_set_txq_props(ah, priv->beaconq, &qi)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-			  "Unable to update beacon queue %u!\n", qnum);
+		ath_err(ath9k_hw_common(ah),
+			"Unable to update beacon queue %u!\n", qnum);
 	} else {
 		ath9k_hw_resettxqueue(ah, priv->beaconq);
 	}
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 071d0c9..20b32f6 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -495,37 +495,31 @@ static int ath9k_init_queues(struct ath9k_htc_priv *priv)
 
 	priv->beaconq = ath9k_hw_beaconq_setup(priv->ah);
 	if (priv->beaconq == -1) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to setup BEACON xmit queue\n");
+		ath_err(common, "Unable to setup BEACON xmit queue\n");
 		goto err;
 	}
 
 	priv->cabq = ath9k_htc_cabq_setup(priv);
 	if (priv->cabq == -1) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to setup CAB xmit queue\n");
+		ath_err(common, "Unable to setup CAB xmit queue\n");
 		goto err;
 	}
 
 	if (!ath9k_htc_txq_setup(priv, WME_AC_BE)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to setup xmit queue for BE traffic\n");
+		ath_err(common, "Unable to setup xmit queue for BE traffic\n");
 		goto err;
 	}
 
 	if (!ath9k_htc_txq_setup(priv, WME_AC_BK)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to setup xmit queue for BK traffic\n");
+		ath_err(common, "Unable to setup xmit queue for BK traffic\n");
 		goto err;
 	}
 	if (!ath9k_htc_txq_setup(priv, WME_AC_VI)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to setup xmit queue for VI traffic\n");
+		ath_err(common, "Unable to setup xmit queue for VI traffic\n");
 		goto err;
 	}
 	if (!ath9k_htc_txq_setup(priv, WME_AC_VO)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to setup xmit queue for VO traffic\n");
+		ath_err(common, "Unable to setup xmit queue for VO traffic\n");
 		goto err;
 	}
 
@@ -670,16 +664,15 @@ static int ath9k_init_priv(struct ath9k_htc_priv *priv,
 
 	ret = ath9k_hw_init(ah);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to initialize hardware; "
-			  "initialization status: %d\n", ret);
+		ath_err(common,
+			"Unable to initialize hardware; initialization status: %d\n",
+			ret);
 		goto err_hw;
 	}
 
 	ret = ath9k_htc_init_debug(ah);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to create debugfs files\n");
+		ath_err(common, "Unable to create debugfs files\n");
 		goto err_debug;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index 8266ce1..a8007af 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -152,9 +152,9 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv *priv,
 	caldata = &priv->caldata[channel->hw_value];
 	ret = ath9k_hw_reset(ah, hchan, caldata, fastcc);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to reset channel (%u Mhz) "
-			  "reset status %d\n", channel->center_freq, ret);
+		ath_err(common,
+			"Unable to reset channel (%u Mhz) reset status %d\n",
+			channel->center_freq, ret);
 		goto err;
 	}
 
@@ -263,8 +263,9 @@ static int ath9k_htc_add_station(struct ath9k_htc_priv *priv,
 	WMI_CMD_BUF(WMI_NODE_CREATE_CMDID, &tsta);
 	if (ret) {
 		if (sta)
-			ath_print(common, ATH_DBG_FATAL,
-			  "Unable to add station entry for: %pM\n", sta->addr);
+			ath_err(common,
+				"Unable to add station entry for: %pM\n",
+				sta->addr);
 		return ret;
 	}
 
@@ -296,9 +297,9 @@ static int ath9k_htc_remove_station(struct ath9k_htc_priv *priv,
 	WMI_CMD_BUF(WMI_NODE_REMOVE_CMDID, &sta_idx);
 	if (ret) {
 		if (sta)
-			ath_print(common, ATH_DBG_FATAL,
-			  "Unable to remove station entry for: %pM\n",
-			  sta->addr);
+			ath_err(common,
+				"Unable to remove station entry for: %pM\n",
+				sta->addr);
 		return ret;
 	}
 
@@ -390,8 +391,8 @@ static int ath9k_htc_send_rate_cmd(struct ath9k_htc_priv *priv,
 
 	WMI_CMD_BUF(WMI_RC_RATE_UPDATE_CMDID, trate);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to initialize Rate information on target\n");
+		ath_err(common,
+			"Unable to initialize Rate information on target\n");
 	}
 
 	return ret;
@@ -895,8 +896,8 @@ static int ath9k_register_led(struct ath9k_htc_priv *priv, struct ath_led *led,
 
 	ret = led_classdev_register(wiphy_dev(priv->hw->wiphy), &led->led_cdev);
 	if (ret)
-		ath_print(ath9k_hw_common(priv->ah), ATH_DBG_FATAL,
-			  "Failed to register led:%s", led->name);
+		ath_err(ath9k_hw_common(priv->ah),
+			"Failed to register led:%s", led->name);
 	else
 		led->registered = 1;
 
@@ -1024,9 +1025,9 @@ static void ath9k_htc_radio_enable(struct ieee80211_hw *hw)
 	/* Reset the HW */
 	ret = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to reset hardware; reset status %d "
-			  "(freq %u MHz)\n", ret, ah->curchan->channel);
+		ath_err(common,
+			"Unable to reset hardware; reset status %d (freq %u MHz)\n",
+			ret, ah->curchan->channel);
 	}
 
 	ath_update_txpow(priv);
@@ -1087,9 +1088,9 @@ static void ath9k_htc_radio_disable(struct ieee80211_hw *hw)
 	/* Reset the HW */
 	ret = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to reset hardware; reset status %d "
-			  "(freq %u MHz)\n", ret, ah->curchan->channel);
+		ath_err(common,
+			"Unable to reset hardware; reset status %d (freq %u MHz)\n",
+			ret, ah->curchan->channel);
 	}
 
 	/* Disable the PHY */
@@ -1175,9 +1176,9 @@ static int ath9k_htc_start(struct ieee80211_hw *hw)
 	ath9k_hw_htc_resetinit(ah);
 	ret = ath9k_hw_reset(ah, init_channel, ah->caldata, false);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to reset hardware; reset status %d "
-			  "(freq %u MHz)\n", ret, curchan->center_freq);
+		ath_err(common,
+			"Unable to reset hardware; reset status %d (freq %u MHz)\n",
+			ret, curchan->center_freq);
 		mutex_unlock(&priv->mutex);
 		return ret;
 	}
@@ -1243,8 +1244,7 @@ static void ath9k_htc_stop(struct ieee80211_hw *hw)
 	/* Remove monitor interface here */
 	if (ah->opmode == NL80211_IFTYPE_MONITOR) {
 		if (ath9k_htc_remove_monitor_interface(priv))
-			ath_print(common, ATH_DBG_FATAL,
-				  "Unable to remove monitor interface\n");
+			ath_err(common, "Unable to remove monitor interface\n");
 		else
 			ath_print(common, ATH_DBG_CONFIG,
 				  "Monitor interface removed\n");
@@ -1298,7 +1298,7 @@ static int ath9k_htc_add_interface(struct ieee80211_hw *hw,
 		hvif.opmode = cpu_to_be32(HTC_M_IBSS);
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
+		ath_err(common,
 			"Interface type %d not yet supported\n", vif->type);
 		ret = -EOPNOTSUPP;
 		goto out;
@@ -1405,8 +1405,7 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 					  hw->conf.channel_type);
 
 		if (ath9k_htc_set_channel(priv, hw, &priv->ah->channels[pos]) < 0) {
-			ath_print(common, ATH_DBG_FATAL,
-				  "Unable to set channel\n");
+			ath_err(common, "Unable to set channel\n");
 			mutex_unlock(&priv->mutex);
 			return -EINVAL;
 		}
@@ -1426,8 +1425,7 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 	if (changed & IEEE80211_CONF_CHANGE_MONITOR) {
 		if (conf->flags & IEEE80211_CONF_MONITOR) {
 			if (ath9k_htc_add_monitor_interface(priv))
-				ath_print(common, ATH_DBG_FATAL,
-					  "Failed to set monitor mode\n");
+				ath_err(common, "Failed to set monitor mode\n");
 			else
 				ath_print(common, ATH_DBG_CONFIG,
 					  "HW opmode set to Monitor mode\n");
@@ -1552,7 +1550,7 @@ static int ath9k_htc_conf_tx(struct ieee80211_hw *hw, u16 queue,
 
 	ret = ath_htc_txq_update(priv, qnum, &qi);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL, "TXQ Update failed\n");
+		ath_err(common, "TXQ Update failed\n");
 		goto out;
 	}
 
@@ -1764,8 +1762,7 @@ static int ath9k_htc_ampdu_action(struct ieee80211_hw *hw,
 		spin_unlock_bh(&priv->tx_lock);
 		break;
 	default:
-		ath_print(ath9k_hw_common(priv->ah), ATH_DBG_FATAL,
-			  "Unknown AMPDU action\n");
+		ath_err(ath9k_hw_common(priv->ah), "Unknown AMPDU action\n");
 	}
 
 	return ret;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index 7795867..5bef41f 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -69,8 +69,8 @@ int ath_htc_txq_update(struct ath9k_htc_priv *priv, int qnum,
 	qi.tqi_readyTime = qinfo->tqi_readyTime;
 
 	if (!ath9k_hw_set_txq_props(ah, qnum, &qi)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-			  "Unable to update hardware queue %u!\n", qnum);
+		ath_err(ath9k_hw_common(ah),
+			"Unable to update hardware queue %u!\n", qnum);
 		error = -EIO;
 	} else {
 		ath9k_hw_resettxqueue(ah, qnum);
@@ -296,8 +296,7 @@ void ath9k_htc_txep(void *drv_priv, struct sk_buff *skb,
 		   (ep_id == priv->data_vo_ep)) {
 		skb_pull(skb, sizeof(struct tx_frame_hdr));
 	} else {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unsupported TX EPID: %d\n", ep_id);
+		ath_err(common, "Unsupported TX EPID: %d\n", ep_id);
 		dev_kfree_skb_any(skb);
 		return;
 	}
@@ -337,9 +336,8 @@ bool ath9k_htc_txq_setup(struct ath9k_htc_priv *priv, int subtype)
 		return false;
 
 	if (qnum >= ARRAY_SIZE(priv->hwq_map)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "qnum %u out of range, max %u!\n",
-			  qnum, (unsigned int)ARRAY_SIZE(priv->hwq_map));
+		ath_err(common, "qnum %u out of range, max %zu!\n",
+			qnum, ARRAY_SIZE(priv->hwq_map));
 		ath9k_hw_releasetxqueue(ah, qnum);
 		return false;
 	}
@@ -490,8 +488,7 @@ static bool ath9k_rx_prepare(struct ath9k_htc_priv *priv,
 	__le16 fc;
 
 	if (skb->len <= HTC_RX_FRAME_HEADER_SIZE) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Corrupted RX frame, dropping\n");
+		ath_err(common, "Corrupted RX frame, dropping\n");
 		goto rx_next;
 	}
 
@@ -499,10 +496,9 @@ static bool ath9k_rx_prepare(struct ath9k_htc_priv *priv,
 
 	if (be16_to_cpu(rxstatus->rs_datalen) -
 	    (skb->len - HTC_RX_FRAME_HEADER_SIZE) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Corrupted RX data len, dropping "
-			  "(dlen: %d, skblen: %d)\n",
-			  rxstatus->rs_datalen, skb->len);
+		ath_err(common,
+			"Corrupted RX data len, dropping (dlen: %d, skblen: %d)\n",
+			rxstatus->rs_datalen, skb->len);
 		goto rx_next;
 	}
 
@@ -728,8 +724,7 @@ int ath9k_rx_init(struct ath9k_htc_priv *priv)
 	for (i = 0; i < ATH9K_HTC_RXBUF; i++) {
 		rxbuf = kzalloc(sizeof(struct ath9k_htc_rxbuf), GFP_KERNEL);
 		if (rxbuf == NULL) {
-			ath_print(common, ATH_DBG_FATAL,
-				  "Unable to allocate RX buffers\n");
+			ath_err(common, "Unable to allocate RX buffers\n");
 			goto err;
 		}
 		list_add_tail(&rxbuf->list, &priv->rx.rxbuf);
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 883f6cc..7709cd9 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -211,8 +211,8 @@ u16 ath9k_hw_computetxtime(struct ath_hw *ah,
 		}
 		break;
 	default:
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-			  "Unknown phy %u (rate ix %u)\n", phy, rateix);
+		ath_err(ath9k_hw_common(ah),
+			"Unknown phy %u (rate ix %u)\n", phy, rateix);
 		txTime = 0;
 		break;
 	}
@@ -331,11 +331,9 @@ static bool ath9k_hw_chip_test(struct ath_hw *ah)
 			REG_WRITE(ah, addr, wrData);
 			rdData = REG_READ(ah, addr);
 			if (rdData != wrData) {
-				ath_print(common, ATH_DBG_FATAL,
-					  "address test failed "
-					  "addr: 0x%08x - wr:0x%08x != "
-					  "rd:0x%08x\n",
-					  addr, wrData, rdData);
+				ath_err(common,
+					"address test failed addr: 0x%08x - wr:0x%08x != rd:0x%08x\n",
+					addr, wrData, rdData);
 				return false;
 			}
 		}
@@ -344,11 +342,9 @@ static bool ath9k_hw_chip_test(struct ath_hw *ah)
 			REG_WRITE(ah, addr, wrData);
 			rdData = REG_READ(ah, addr);
 			if (wrData != rdData) {
-				ath_print(common, ATH_DBG_FATAL,
-					  "address test failed "
-					  "addr: 0x%08x - wr:0x%08x != "
-					  "rd:0x%08x\n",
-					  addr, wrData, rdData);
+				ath_err(common,
+					"address test failed addr: 0x%08x - wr:0x%08x != rd:0x%08x\n",
+					addr, wrData, rdData);
 				return false;
 			}
 		}
@@ -476,9 +472,8 @@ static int ath9k_hw_post_init(struct ath_hw *ah)
 
 	ecode = ath9k_hw_rf_alloc_ext_banks(ah);
 	if (ecode) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-			  "Failed allocating banks for "
-			  "external radio\n");
+		ath_err(ath9k_hw_common(ah),
+			"Failed allocating banks for external radio\n");
 		ath9k_hw_rf_free_ext_banks(ah);
 		return ecode;
 	}
@@ -509,8 +504,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 		ah->hw_version.macVersion = AR_SREV_VERSION_9100;
 
 	if (!ath9k_hw_set_reset_reg(ah, ATH9K_RESET_POWER_ON)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Couldn't reset chip\n");
+		ath_err(common, "Couldn't reset chip\n");
 		return -EIO;
 	}
 
@@ -520,7 +514,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 	ath9k_hw_attach_ops(ah);
 
 	if (!ath9k_hw_setpower(ah, ATH9K_PM_AWAKE)) {
-		ath_print(common, ATH_DBG_FATAL, "Couldn't wakeup chip\n");
+		ath_err(common, "Couldn't wakeup chip\n");
 		return -EIO;
 	}
 
@@ -545,10 +539,9 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 		ah->config.max_txtrig_level = MAX_TX_FIFO_THRESHOLD;
 
 	if (!ath9k_hw_macversion_supported(ah)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Mac Chip Rev 0x%02x.%x is not supported by "
-			  "this driver\n", ah->hw_version.macVersion,
-			  ah->hw_version.macRev);
+		ath_err(common,
+			"Mac Chip Rev 0x%02x.%x is not supported by this driver\n",
+			ah->hw_version.macVersion, ah->hw_version.macRev);
 		return -EOPNOTSUPP;
 	}
 
@@ -594,8 +587,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 
 	r = ath9k_hw_init_macaddr(ah);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Failed to initialize MAC address\n");
+		ath_err(common, "Failed to initialize MAC address\n");
 		return r;
 	}
 
@@ -633,17 +625,16 @@ int ath9k_hw_init(struct ath_hw *ah)
 	default:
 		if (common->bus_ops->ath_bus_type == ATH_USB)
 			break;
-		ath_print(common, ATH_DBG_FATAL,
-			  "Hardware device ID 0x%04x not supported\n",
-			  ah->hw_version.devid);
+		ath_err(common, "Hardware device ID 0x%04x not supported\n",
+			ah->hw_version.devid);
 		return -EOPNOTSUPP;
 	}
 
 	ret = __ath9k_hw_init(ah);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to initialize hardware; "
-			  "initialization status: %d\n", ret);
+		ath_err(common,
+			"Unable to initialize hardware; initialization status: %d\n",
+			ret);
 		return ret;
 	}
 
@@ -1145,8 +1136,7 @@ static bool ath9k_hw_channel_change(struct ath_hw *ah,
 	}
 
 	if (!ath9k_hw_rfbus_req(ah)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Could not kill baseband RX\n");
+		ath_err(common, "Could not kill baseband RX\n");
 		return false;
 	}
 
@@ -1154,8 +1144,7 @@ static bool ath9k_hw_channel_change(struct ath_hw *ah,
 
 	r = ath9k_hw_rf_set_freq(ah, chan);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Failed to set channel\n");
+		ath_err(common, "Failed to set channel\n");
 		return false;
 	}
 	ath9k_hw_set_clockrate(ah);
@@ -1287,7 +1276,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	}
 
 	if (!ath9k_hw_chip_reset(ah, chan)) {
-		ath_print(common, ATH_DBG_FATAL, "Chip reset failed\n");
+		ath_err(common, "Chip reset failed\n");
 		return -EINVAL;
 	}
 
@@ -1568,9 +1557,9 @@ static bool ath9k_hw_set_power_awake(struct ath_hw *ah, int setChip)
 				    AR_RTC_FORCE_WAKE_EN);
 		}
 		if (i == 0) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-				  "Failed to wakeup in %uus\n",
-				  POWER_UP_TIME / 20);
+			ath_err(ath9k_hw_common(ah),
+				"Failed to wakeup in %uus\n",
+				POWER_UP_TIME / 20);
 			return false;
 		}
 	}
@@ -1609,8 +1598,7 @@ bool ath9k_hw_setpower(struct ath_hw *ah, enum ath9k_power_mode mode)
 		ath9k_set_power_network_sleep(ah, setChip);
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unknown power mode %u\n", mode);
+		ath_err(common, "Unknown power mode %u\n", mode);
 		return false;
 	}
 	ah->power_mode = mode;
@@ -1801,8 +1789,8 @@ int ath9k_hw_fill_cap_info(struct ath_hw *ah)
 
 	eeval = ah->eep_ops->get_eeprom(ah, EEP_OP_MODE);
 	if ((eeval & (AR5416_OPFLAGS_11G | AR5416_OPFLAGS_11A)) == 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "no band has been marked as supported in EEPROM.\n");
+		ath_err(common,
+			"no band has been marked as supported in EEPROM\n");
 		return -EINVAL;
 	}
 
@@ -2341,9 +2329,9 @@ struct ath_gen_timer *ath_gen_timer_alloc(struct ath_hw *ah,
 	timer = kzalloc(sizeof(struct ath_gen_timer), GFP_KERNEL);
 
 	if (timer == NULL) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-			  "Failed to allocate memory"
-			  "for hw timer[%d]\n", timer_index);
+		ath_err(ath9k_hw_common(ah),
+			"Failed to allocate memory for hw timer[%d]\n",
+			timer_index);
 		return NULL;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 2962ce3..3a40d49 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -283,8 +283,7 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 
 	/* ath_desc must be a multiple of DWORDs */
 	if ((desc_len % 4) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "ath_desc not DWORD aligned\n");
+		ath_err(common, "ath_desc not DWORD aligned\n");
 		BUG_ON((desc_len % 4) != 0);
 		error = -ENOMEM;
 		goto fail;
@@ -569,8 +568,7 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc, u16 subsysid,
 
 	ret = ath9k_init_debug(ah);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to create debugfs files\n");
+		ath_err(common, "Unable to create debugfs files\n");
 		goto err_debug;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index b04b37b..b96e750 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -204,9 +204,8 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 		wait = wait_time;
 		while (ath9k_hw_numtxpending(ah, q)) {
 			if ((--wait) == 0) {
-				ath_print(common, ATH_DBG_FATAL,
-					  "Failed to stop TX DMA in 100 "
-					  "msec after killing last frame\n");
+				ath_err(common,
+					"Failed to stop TX DMA in 100 msec after killing last frame\n");
 				break;
 			}
 			udelay(ATH9K_TIME_QUANTUM);
@@ -368,14 +367,12 @@ int ath9k_hw_setuptxqueue(struct ath_hw *ah, enum ath9k_tx_queue type,
 			    ATH9K_TX_QUEUE_INACTIVE)
 				break;
 		if (q == pCap->total_queues) {
-			ath_print(common, ATH_DBG_FATAL,
-				  "No available TX queue\n");
+			ath_err(common, "No available TX queue\n");
 			return -1;
 		}
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
-			  "Invalid TX queue type: %u\n", type);
+		ath_err(common, "Invalid TX queue type: %u\n", type);
 		return -1;
 	}
 
@@ -383,8 +380,7 @@ int ath9k_hw_setuptxqueue(struct ath_hw *ah, enum ath9k_tx_queue type,
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type != ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "TX queue: %u already active\n", q);
+		ath_err(common, "TX queue: %u already active\n", q);
 		return -1;
 	}
 	memset(qi, 0, sizeof(struct ath9k_tx_queue_info));
@@ -735,9 +731,9 @@ bool ath9k_hw_setrxabort(struct ath_hw *ah, bool set)
 				     AR_DIAG_RX_ABORT));
 
 			reg = REG_READ(ah, AR_OBS_BUS_1);
-			ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
-				  "RX failed to go idle in 10 ms RXSM=0x%x\n",
-				  reg);
+			ath_err(ath9k_hw_common(ah),
+				"RX failed to go idle in 10 ms RXSM=0x%x\n",
+				reg);
 
 			return false;
 		}
@@ -791,12 +787,11 @@ bool ath9k_hw_stopdmarecv(struct ath_hw *ah)
 	}
 
 	if (i == 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "DMA failed to stop in %d ms "
-			  "AR_CR=0x%08x AR_DIAG_SW=0x%08x\n",
-			  AH_RX_STOP_DMA_TIMEOUT / 1000,
-			  REG_READ(ah, AR_CR),
-			  REG_READ(ah, AR_DIAG_SW));
+		ath_err(common,
+			"DMA failed to stop in %d ms AR_CR=0x%08x AR_DIAG_SW=0x%08x\n",
+			AH_RX_STOP_DMA_TIMEOUT / 1000,
+			REG_READ(ah, AR_CR),
+			REG_READ(ah, AR_DIAG_SW));
 		return false;
 	} else {
 		return true;
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 7acd6b0..e863de8 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -268,16 +268,14 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 
 	r = ath9k_hw_reset(ah, hchan, caldata, fastcc);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to reset channel (%u MHz), "
-			  "reset status %d\n",
-			  channel->center_freq, r);
+		ath_err(common,
+			"Unable to reset channel (%u MHz), reset status %d\n",
+			channel->center_freq, r);
 		goto ps_restore;
 	}
 
 	if (ath_startrecv(sc) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to restart recv logic\n");
+		ath_err(common, "Unable to restart recv logic\n");
 		r = -EIO;
 		goto ps_restore;
 	}
@@ -889,16 +887,14 @@ void ath_radio_enable(struct ath_softc *sc, struct ieee80211_hw *hw)
 
 	r = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to reset channel (%u MHz), "
-			  "reset status %d\n",
-			  channel->center_freq, r);
+		ath_err(common,
+			"Unable to reset channel (%u MHz), reset status %d\n",
+			channel->center_freq, r);
 	}
 
 	ath_update_txpow(sc);
 	if (ath_startrecv(sc) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to restart recv logic\n");
+		ath_err(common, "Unable to restart recv logic\n");
 		spin_unlock_bh(&sc->sc_pcu_lock);
 		return;
 	}
@@ -952,10 +948,9 @@ void ath_radio_disable(struct ath_softc *sc, struct ieee80211_hw *hw)
 
 	r = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (r) {
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
-			  "Unable to reset channel (%u MHz), "
-			  "reset status %d\n",
-			  channel->center_freq, r);
+		ath_err(ath9k_hw_common(sc->sc_ah),
+			"Unable to reset channel (%u MHz), reset status %d\n",
+			channel->center_freq, r);
 	}
 
 	ath9k_hw_phy_disable(ah);
@@ -990,12 +985,11 @@ int ath_reset(struct ath_softc *sc, bool retry_tx)
 
 	r = ath9k_hw_reset(ah, sc->sc_ah->curchan, ah->caldata, false);
 	if (r)
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to reset hardware; reset status %d\n", r);
+		ath_err(common,
+			"Unable to reset hardware; reset status %d\n", r);
 
 	if (ath_startrecv(sc) != 0)
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to start recv logic\n");
+		ath_err(common, "Unable to start recv logic\n");
 
 	/*
 	 * We may be doing a reset in response to a request
@@ -1113,10 +1107,9 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	spin_lock_bh(&sc->sc_pcu_lock);
 	r = ath9k_hw_reset(ah, init_channel, ah->caldata, false);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to reset hardware; reset status %d "
-			  "(freq %u MHz)\n", r,
-			  curchan->center_freq);
+		ath_err(common,
+			"Unable to reset hardware; reset status %d (freq %u MHz)\n",
+			r, curchan->center_freq);
 		spin_unlock_bh(&sc->sc_pcu_lock);
 		goto mutex_unlock;
 	}
@@ -1135,8 +1128,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	 * here except setup the interrupt mask.
 	 */
 	if (ath_startrecv(sc) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to start recv logic\n");
+		ath_err(common, "Unable to start recv logic\n");
 		r = -EIO;
 		spin_unlock_bh(&sc->sc_pcu_lock);
 		goto mutex_unlock;
@@ -1375,8 +1367,8 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 		ic_opmode = vif->type;
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
-			"Interface type %d not yet supported\n", vif->type);
+		ath_err(common, "Interface type %d not yet supported\n",
+			vif->type);
 		ret = -EOPNOTSUPP;
 		goto out;
 	}
@@ -1647,8 +1639,7 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 		}
 
 		if (ath_set_channel(sc, hw, &sc->sc_ah->channels[pos]) < 0) {
-			ath_print(common, ATH_DBG_FATAL,
-				  "Unable to set channel\n");
+			ath_err(common, "Unable to set channel\n");
 			mutex_unlock(&sc->mutex);
 			return -EINVAL;
 		}
@@ -1772,7 +1763,7 @@ static int ath9k_conf_tx(struct ieee80211_hw *hw, u16 queue,
 
 	ret = ath_txq_update(sc, txq->axq_qnum, &qi);
 	if (ret)
-		ath_print(common, ATH_DBG_FATAL, "TXQ Update failed\n");
+		ath_err(common, "TXQ Update failed\n");
 
 	if (sc->sc_ah->opmode == NL80211_IFTYPE_ADHOC)
 		if (queue == WME_AC_BE && !ret)
@@ -2021,8 +2012,7 @@ static int ath9k_ampdu_action(struct ieee80211_hw *hw,
 		ath9k_ps_restore(sc);
 		break;
 	default:
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
-			  "Unknown AMPDU action\n");
+		ath_err(ath9k_hw_common(sc->sc_ah), "Unknown AMPDU action\n");
 	}
 
 	local_bh_enable();
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 09f69a9..71339da 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -59,10 +59,9 @@ static bool ath_pci_eeprom_read(struct ath_common *common, u32 off, u16 *data)
 
 	if (pdata) {
 		if (off >= (ARRAY_SIZE(pdata->eeprom_data))) {
-			ath_print(common, ATH_DBG_FATAL,
-				  "%s: eeprom read failed, offset %08x "
-				  "is out of range\n",
-				  __func__, off);
+			ath_err(common,
+				"%s: eeprom read failed, offset %08x is out of range\n",
+				__func__, off);
 		}
 
 		*data = pdata->eeprom_data[off];
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index 3e6ea3b..d8dcaab 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1576,8 +1576,8 @@ static void *ath_rate_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp
 
 	rate_priv = kzalloc(sizeof(struct ath_rate_priv), gfp);
 	if (!rate_priv) {
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
-			  "Unable to allocate private rc structure\n");
+		ath_err(ath9k_hw_common(sc->sc_ah),
+			"Unable to allocate private rc structure\n");
 		return NULL;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 262c815..c477be0 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -269,7 +269,7 @@ static int ath_rx_edma_init(struct ath_softc *sc, int nbufs)
 				dev_kfree_skb_any(skb);
 				bf->bf_mpdu = NULL;
 				bf->bf_buf_addr = 0;
-				ath_print(common, ATH_DBG_FATAL,
+				ath_err(common,
 					"dma_mapping_error() on RX init\n");
 				error = -ENOMEM;
 				goto rx_init_fail;
@@ -335,9 +335,9 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 		error = ath_descdma_setup(sc, &sc->rx.rxdma, &sc->rx.rxbuf,
 				"rx", nbufs, 1, 0);
 		if (error != 0) {
-			ath_print(common, ATH_DBG_FATAL,
-				  "failed to allocate rx descriptors: %d\n",
-				  error);
+			ath_err(common,
+				"failed to allocate rx descriptors: %d\n",
+				error);
 			goto err;
 		}
 
@@ -358,8 +358,8 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 				dev_kfree_skb_any(skb);
 				bf->bf_mpdu = NULL;
 				bf->bf_buf_addr = 0;
-				ath_print(common, ATH_DBG_FATAL,
-					  "dma_mapping_error() on RX init\n");
+				ath_err(common,
+					"dma_mapping_error() on RX init\n");
 				error = -ENOMEM;
 				goto err;
 			}
@@ -1725,8 +1725,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 			dev_kfree_skb_any(requeue_skb);
 			bf->bf_mpdu = NULL;
 			bf->bf_buf_addr = 0;
-			ath_print(common, ATH_DBG_FATAL,
-				  "dma_mapping_error() on RX\n");
+			ath_err(common, "dma_mapping_error() on RX\n");
 			ath_rx_send_to_mac80211(hw, sc, skb, rxs);
 			break;
 		}
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 177a7b1..f2a1f9b 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -985,9 +985,8 @@ struct ath_txq *ath_txq_setup(struct ath_softc *sc, int qtype, int subtype)
 		return NULL;
 	}
 	if (qnum >= ARRAY_SIZE(sc->tx.txq)) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "qnum %u out of range, max %u!\n",
-			  qnum, (unsigned int)ARRAY_SIZE(sc->tx.txq));
+		ath_err(common, "qnum %u out of range, max %u!\n",
+			qnum, (unsigned int)ARRAY_SIZE(sc->tx.txq));
 		ath9k_hw_releasetxqueue(ah, qnum);
 		return NULL;
 	}
@@ -1038,8 +1037,8 @@ int ath_txq_update(struct ath_softc *sc, int qnum,
 	qi.tqi_readyTime = qinfo->tqi_readyTime;
 
 	if (!ath9k_hw_set_txq_props(ah, qnum, &qi)) {
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
-			  "Unable to update hardware queue %u!\n", qnum);
+		ath_err(ath9k_hw_common(sc->sc_ah),
+			"Unable to update hardware queue %u!\n", qnum);
 		error = -EIO;
 	} else {
 		ath9k_hw_resettxqueue(ah, qnum);
@@ -1197,14 +1196,13 @@ void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 	if (npend) {
 		int r;
 
-		ath_print(common, ATH_DBG_FATAL,
-			  "Failed to stop TX DMA. Resetting hardware!\n");
+		ath_err(common, "Failed to stop TX DMA. Resetting hardware!\n");
 
 		r = ath9k_hw_reset(ah, sc->sc_ah->curchan, ah->caldata, false);
 		if (r)
-			ath_print(common, ATH_DBG_FATAL,
-				  "Unable to reset hardware; reset status %d\n",
-				  r);
+			ath_err(common,
+				"Unable to reset hardware; reset status %d\n",
+				r);
 	}
 
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
@@ -1644,8 +1642,8 @@ static struct ath_buf *ath_tx_setup_buffer(struct ieee80211_hw *hw,
 	if (unlikely(dma_mapping_error(sc->dev, bf->bf_buf_addr))) {
 		bf->bf_mpdu = NULL;
 		bf->bf_buf_addr = 0;
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
-			  "dma_mapping_error() on TX\n");
+		ath_err(ath9k_hw_common(sc->sc_ah),
+			"dma_mapping_error() on TX\n");
 		ath_tx_return_buffer(sc, bf);
 		return NULL;
 	}
@@ -2241,16 +2239,16 @@ int ath_tx_init(struct ath_softc *sc, int nbufs)
 	error = ath_descdma_setup(sc, &sc->tx.txdma, &sc->tx.txbuf,
 				  "tx", nbufs, 1, 1);
 	if (error != 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Failed to allocate tx descriptors: %d\n", error);
+		ath_err(common,
+			"Failed to allocate tx descriptors: %d\n", error);
 		goto err;
 	}
 
 	error = ath_descdma_setup(sc, &sc->beacon.bdma, &sc->beacon.bbuf,
 				  "beacon", ATH_BCBUF, 1, 1);
 	if (error != 0) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "Failed to allocate beacon descriptors: %d\n", error);
+		ath_err(common,
+			"Failed to allocate beacon descriptors: %d\n", error);
 		goto err;
 	}
 
diff --git a/drivers/net/wireless/ath/key.c b/drivers/net/wireless/ath/key.c
index 62e3dac..3a47695 100644
--- a/drivers/net/wireless/ath/key.c
+++ b/drivers/net/wireless/ath/key.c
@@ -37,8 +37,7 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry)
 	void *ah = common->ah;
 
 	if (entry >= common->keymax) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "keychache entry %u out of range\n", entry);
+		ath_err(common, "keycache entry %u out of range\n", entry);
 		return false;
 	}
 
@@ -75,8 +74,7 @@ static bool ath_hw_keysetmac(struct ath_common *common,
 	void *ah = common->ah;
 
 	if (entry >= common->keymax) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "keychache entry %u out of range\n", entry);
+		ath_err(common, "keycache entry %u out of range\n", entry);
 		return false;
 	}
 
@@ -117,8 +115,7 @@ static bool ath_hw_set_keycache_entry(struct ath_common *common, u16 entry,
 	u32 keyType;
 
 	if (entry >= common->keymax) {
-		ath_print(common, ATH_DBG_FATAL,
-			  "keycache entry %u out of range\n", entry);
+		ath_err(common, "keycache entry %u out of range\n", entry);
 		return false;
 	}
 
@@ -159,8 +156,7 @@ static bool ath_hw_set_keycache_entry(struct ath_common *common, u16 entry,
 		keyType = AR_KEYTABLE_TYPE_CLR;
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
-			  "cipher %u not supported\n", k->kv_type);
+		ath_err(common, "cipher %u not supported\n", k->kv_type);
 		return false;
 	}
 
@@ -341,8 +337,7 @@ static int ath_setkey_tkip(struct ath_common *common, u16 keyix, const u8 *key,
 	memcpy(hk->kv_mic, key_txmic, sizeof(hk->kv_mic));
 	if (!ath_hw_set_keycache_entry(common, keyix, hk, NULL)) {
 		/* TX MIC entry failed. No need to proceed further */
-		ath_print(common, ATH_DBG_FATAL,
-			  "Setting TX MIC Key Failed\n");
+		ath_err(common, "Setting TX MIC Key Failed\n");
 		return 0;
 	}
 
-- 
1.7.3.2.245.g03276.dirty
