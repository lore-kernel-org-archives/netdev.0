From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Sun,  9 Feb 2014 19:47:47 +0100
Message-ID: <1391971686-9517-10-git-send-email-richard@nod.at>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
To: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:ATHEROS ATH5K WIR...),
	ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org (open list:ATHEROS ATH5K WIR...),
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING DRIVERS),
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1391971686-9517-1-git-send-email-richard-/L3Ra7n9ekc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The symbol is an orphan, get rid of it.

Signed-off-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
---
 drivers/net/wireless/ath/ath5k/Kconfig | 10 +++++-----
 drivers/net/wireless/ath/ath5k/ath5k.h | 28 ----------------------------
 drivers/net/wireless/ath/ath5k/base.c  | 14 --------------
 drivers/net/wireless/ath/ath5k/led.c   |  7 -------
 4 files changed, 5 insertions(+), 54 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/Kconfig b/drivers/net/wireless/ath/ath5k/Kconfig
index c9f81a3..3bc0d57 100644
--- a/drivers/net/wireless/ath/ath5k/Kconfig
+++ b/drivers/net/wireless/ath/ath5k/Kconfig
@@ -1,13 +1,13 @@
 config ATH5K
 	tristate "Atheros 5xxx wireless cards support"
-	depends on (PCI || ATHEROS_AR231X) && MAC80211
+	depends on PCI && MAC80211
 	select ATH_COMMON
 	select MAC80211_LEDS
 	select LEDS_CLASS
 	select NEW_LEDS
 	select AVERAGE
-	select ATH5K_AHB if (ATHEROS_AR231X && !PCI)
-	select ATH5K_PCI if (!ATHEROS_AR231X && PCI)
+	select ATH5K_AHB if !PCI
+	select ATH5K_PCI if PCI
 	---help---
 	  This module adds support for wireless adapters based on
 	  Atheros 5xxx chipset.
@@ -54,14 +54,14 @@ config ATH5K_TRACER
 
 config ATH5K_AHB
 	bool "Atheros 5xxx AHB bus support"
-	depends on (ATHEROS_AR231X && !PCI)
+	depends on !PCI
 	---help---
 	  This adds support for WiSoC type chipsets of the 5xxx Atheros
 	  family.
 
 config ATH5K_PCI
 	bool "Atheros 5xxx PCI bus support"
-	depends on (!ATHEROS_AR231X && PCI)
+	depends on PCI
 	---help---
 	  This adds support for PCI type chipsets of the 5xxx Atheros
 	  family.
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index 74bd54d..5f2843c 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -1646,32 +1646,6 @@ static inline struct ath_regulatory *ath5k_hw_regulatory(struct ath5k_hw *ah)
 	return &(ath5k_hw_common(ah)->regulatory);
 }
 
-#ifdef CONFIG_ATHEROS_AR231X
-#define AR5K_AR2315_PCI_BASE	((void __iomem *)0xb0100000)
-
-static inline void __iomem *ath5k_ahb_reg(struct ath5k_hw *ah, u16 reg)
-{
-	/* On AR2315 and AR2317 the PCI clock domain registers
-	 * are outside of the WMAC register space */
-	if (unlikely((reg >= 0x4000) && (reg < 0x5000) &&
-	    (ah->ah_mac_srev >= AR5K_SREV_AR2315_R6)))
-		return AR5K_AR2315_PCI_BASE + reg;
-
-	return ah->iobase + reg;
-}
-
-static inline u32 ath5k_hw_reg_read(struct ath5k_hw *ah, u16 reg)
-{
-	return ioread32(ath5k_ahb_reg(ah, reg));
-}
-
-static inline void ath5k_hw_reg_write(struct ath5k_hw *ah, u32 val, u16 reg)
-{
-	iowrite32(val, ath5k_ahb_reg(ah, reg));
-}
-
-#else
-
 static inline u32 ath5k_hw_reg_read(struct ath5k_hw *ah, u16 reg)
 {
 	return ioread32(ah->iobase + reg);
@@ -1682,8 +1656,6 @@ static inline void ath5k_hw_reg_write(struct ath5k_hw *ah, u32 val, u16 reg)
 	iowrite32(val, ah->iobase + reg);
 }
 
-#endif
-
 static inline enum ath_bus_type ath5k_get_bus_type(struct ath5k_hw *ah)
 {
 	return ath5k_hw_common(ah)->bus_ops->ath_bus_type;
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index ef35da8..d43e546 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -99,15 +99,6 @@ static int ath5k_reset(struct ath5k_hw *ah, struct ieee80211_channel *chan,
 
 /* Known SREVs */
 static const struct ath5k_srev_name srev_names[] = {
-#ifdef CONFIG_ATHEROS_AR231X
-	{ "5312",	AR5K_VERSION_MAC,	AR5K_SREV_AR5312_R2 },
-	{ "5312",	AR5K_VERSION_MAC,	AR5K_SREV_AR5312_R7 },
-	{ "2313",	AR5K_VERSION_MAC,	AR5K_SREV_AR2313_R8 },
-	{ "2315",	AR5K_VERSION_MAC,	AR5K_SREV_AR2315_R6 },
-	{ "2315",	AR5K_VERSION_MAC,	AR5K_SREV_AR2315_R7 },
-	{ "2317",	AR5K_VERSION_MAC,	AR5K_SREV_AR2317_R1 },
-	{ "2317",	AR5K_VERSION_MAC,	AR5K_SREV_AR2317_R2 },
-#else
 	{ "5210",	AR5K_VERSION_MAC,	AR5K_SREV_AR5210 },
 	{ "5311",	AR5K_VERSION_MAC,	AR5K_SREV_AR5311 },
 	{ "5311A",	AR5K_VERSION_MAC,	AR5K_SREV_AR5311A },
@@ -126,7 +117,6 @@ static const struct ath5k_srev_name srev_names[] = {
 	{ "5418",	AR5K_VERSION_MAC,	AR5K_SREV_AR5418 },
 	{ "2425",	AR5K_VERSION_MAC,	AR5K_SREV_AR2425 },
 	{ "2417",	AR5K_VERSION_MAC,	AR5K_SREV_AR2417 },
-#endif
 	{ "xxxxx",	AR5K_VERSION_MAC,	AR5K_SREV_UNKNOWN },
 	{ "5110",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5110 },
 	{ "5111",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5111 },
@@ -142,10 +132,6 @@ static const struct ath5k_srev_name srev_names[] = {
 	{ "5413",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5413 },
 	{ "5424",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5424 },
 	{ "5133",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5133 },
-#ifdef CONFIG_ATHEROS_AR231X
-	{ "2316",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_2316 },
-	{ "2317",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_2317 },
-#endif
 	{ "xxxxx",	AR5K_VERSION_RAD,	AR5K_SREV_UNKNOWN },
 };
 
diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index f77ef36..c36a98f 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -162,20 +162,13 @@ int ath5k_init_leds(struct ath5k_hw *ah)
 {
 	int ret = 0;
 	struct ieee80211_hw *hw = ah->hw;
-#ifndef CONFIG_ATHEROS_AR231X
-	struct pci_dev *pdev = ah->pdev;
-#endif
 	char name[ATH5K_LED_MAX_NAME_LEN + 1];
 	const struct pci_device_id *match;
 
 	if (!ah->pdev)
 		return 0;
 
-#ifdef CONFIG_ATHEROS_AR231X
-	match = NULL;
-#else
 	match = pci_match_id(&ath5k_led_devices[0], pdev);
-#endif
 	if (match) {
 		__set_bit(ATH_STAT_LEDSOFT, ah->status);
 		ah->led_pin = ATH_PIN(match->driver_data);
-- 
1.8.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
