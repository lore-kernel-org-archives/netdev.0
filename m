From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu, 5 Jan 2012 11:11:56 -0200
Message-ID: <CAOMZO5C7+sfU-nfM+L8Z8aCzMd5HkTJTg5sconpOnxto=8DQLQ@mail.gmail.com>
References: <1325765663-7141-1-git-send-email-festevam@gmail.com>
	<CAL1gcdOrr41Br1Z-JCih6BGdxLmZ9ns+W-cVRxvd+guO2xC_zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, linville@tuxdriver.com,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Gertjan van Wingerde <gwingerde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48341 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab2AENL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 08:11:58 -0500
In-Reply-To: <CAL1gcdOrr41Br1Z-JCih6BGdxLmZ9ns+W-cVRxvd+guO2xC_zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 5, 2012 at 10:33 AM, Gertjan van Wingerde
<gwingerde@gmail.com> wrote:

> A correct fix would be to also select MISC_DEVICES at all locations
> where EEPROM_93CX6 is selected.

Ok, I guess you mean:

diff --git a/drivers/net/ethernet/8390/Kconfig
b/drivers/net/ethernet/8390/Kconfig
index e04ade4..19df534 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -69,6 +69,7 @@ config AX88796
 config AX88796_93CX6
 	bool "ASIX AX88796 external 93CX6 eeprom support"
 	depends on AX88796
+	select MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  Select this if your platform comes with an external 93CX6 eeprom.
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index abd3b71..3b08db7 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -223,6 +223,7 @@ config ADM8211
 	tristate "ADMtek ADM8211 support"
 	depends on MAC80211 && PCI && EXPERIMENTAL
 	select CRC32
+	select MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This driver is for ADM8211A, ADM8211B, and ADM8211C based cards.
diff --git a/drivers/net/wireless/rt2x00/Kconfig
b/drivers/net/wireless/rt2x00/Kconfig
index a0a7854..f9a1028 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -21,6 +21,7 @@ config RT2400PCI
 	tristate "Ralink rt2400 (PCI/PCMCIA) support"
 	depends on PCI
 	select RT2X00_LIB_PCI
+	select MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This adds support for rt2400 wireless chipset family.
@@ -32,6 +33,7 @@ config RT2500PCI
 	tristate "Ralink rt2500 (PCI/PCMCIA) support"
 	depends on PCI
 	select RT2X00_LIB_PCI
+	select MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This adds support for rt2500 wireless chipset family.
@@ -46,6 +48,7 @@ config RT61PCI
 	select RT2X00_LIB_FIRMWARE
 	select RT2X00_LIB_CRYPTO
 	select CRC_ITU_T
+	select MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This adds support for rt2501 wireless chipset family.
@@ -62,6 +65,7 @@ config RT2800PCI
 	select RT2X00_LIB_FIRMWARE
 	select RT2X00_LIB_CRYPTO
 	select CRC_CCITT
+	select MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This adds support for rt27xx/rt28xx/rt30xx wireless chipset family.
diff --git a/drivers/net/wireless/rtl818x/Kconfig
b/drivers/net/wireless/rtl818x/Kconfig
index 17d80fe..2c8c2f2 100644
--- a/drivers/net/wireless/rtl818x/Kconfig
+++ b/drivers/net/wireless/rtl818x/Kconfig
@@ -4,6 +4,7 @@
 config RTL8180
 	tristate "Realtek 8180/8185 PCI support"
 	depends on MAC80211 && PCI && EXPERIMENTAL
+	select MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This is a driver for RTL8180 and RTL8185 based cards.
@@ -60,6 +61,7 @@ config RTL8180
 config RTL8187
 	tristate "Realtek 8187 and 8187B USB support"
 	depends on MAC80211 && USB
+	select MISC_DEVICES
 	select EEPROM_93CX6
 	---help---
 	  This is a driver for RTL8187 and RTL8187B based cards.

,but still get the warnings in this case too.

Regards,

Fabio Estevam
