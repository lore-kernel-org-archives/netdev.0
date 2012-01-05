From: Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu,  5 Jan 2012 11:37:53 -0200
Message-ID: <1325770673-17309-1-git-send-email-festevam@gmail.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Fabio Estevam <fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix the following build warning:

warning: (KS8851 && AX88796_93CX6 && RTL8180 && RTL8187 && ADM8211 && RT2400PCI && RT2500PCI && RT61PCI && RT2800PCI && R8187SE) selects EEPROM_93CX6 which has unmet direct dependencies (MISC_DEVICES)

Signed-off-by: Fabio Estevam <fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
---
Changes since v1:
- Place MISC_DEVICES dependency into the 'depends on' line

 drivers/net/ethernet/8390/Kconfig    |    2 +-
 drivers/net/wireless/Kconfig         |    2 +-
 drivers/net/wireless/rt2x00/Kconfig  |    7 ++++---
 drivers/net/wireless/rtl818x/Kconfig |    4 ++--
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index e04ade4..993e0fa 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -68,7 +68,7 @@ config AX88796
 
 config AX88796_93CX6
 	bool "ASIX AX88796 external 93CX6 eeprom support"
-	depends on AX88796
+	depends on AX88796 && MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  Select this if your platform comes with an external 93CX6 eeprom.
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index abd3b71..ef7fff0 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -221,7 +221,7 @@ source "drivers/net/wireless/rtl818x/Kconfig"
 
 config ADM8211
 	tristate "ADMtek ADM8211 support"
-	depends on MAC80211 && PCI && EXPERIMENTAL
+	depends on MAC80211 && PCI && EXPERIMENTAL && MISC_DEVICES
 	select CRC32
 	select EEPROM_93CX6
 	---help---
diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
index a0a7854..bccd5c6 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -19,7 +19,7 @@ if RT2X00
 
 config RT2400PCI
 	tristate "Ralink rt2400 (PCI/PCMCIA) support"
-	depends on PCI
+	depends on PCI && MISC_DEVICES
 	select RT2X00_LIB_PCI
 	select EEPROM_93CX6
 	---help---
@@ -30,7 +30,7 @@ config RT2400PCI
 
 config RT2500PCI
 	tristate "Ralink rt2500 (PCI/PCMCIA) support"
-	depends on PCI
+	depends on PCI && MISC_DEVICES
 	select RT2X00_LIB_PCI
 	select EEPROM_93CX6
 	---help---
@@ -41,7 +41,7 @@ config RT2500PCI
 
 config RT61PCI
 	tristate "Ralink rt2501/rt61 (PCI/PCMCIA) support"
-	depends on PCI
+	depends on PCI && MISC_DEVICES
 	select RT2X00_LIB_PCI
 	select RT2X00_LIB_FIRMWARE
 	select RT2X00_LIB_CRYPTO
@@ -56,6 +56,7 @@ config RT61PCI
 config RT2800PCI
 	tristate "Ralink rt27xx/rt28xx/rt30xx (PCI/PCIe/PCMCIA) support"
 	depends on PCI || RALINK_RT288X || RALINK_RT305X
+	depends on MISC_DEVICES
 	select RT2800_LIB
 	select RT2X00_LIB_PCI if PCI
 	select RT2X00_LIB_SOC if RALINK_RT288X || RALINK_RT305X
diff --git a/drivers/net/wireless/rtl818x/Kconfig b/drivers/net/wireless/rtl818x/Kconfig
index 17d80fe..7d7268e 100644
--- a/drivers/net/wireless/rtl818x/Kconfig
+++ b/drivers/net/wireless/rtl818x/Kconfig
@@ -3,7 +3,7 @@
 #
 config RTL8180
 	tristate "Realtek 8180/8185 PCI support"
-	depends on MAC80211 && PCI && EXPERIMENTAL
+	depends on MAC80211 && PCI && EXPERIMENTAL && MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This is a driver for RTL8180 and RTL8185 based cards.
@@ -59,7 +59,7 @@ config RTL8180
 
 config RTL8187
 	tristate "Realtek 8187 and 8187B USB support"
-	depends on MAC80211 && USB
+	depends on MAC80211 && USB && MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This is a driver for RTL8187 and RTL8187B based cards.
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
